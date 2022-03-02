package it.finmatica.protocollo.jobs

import groovy.json.JsonSlurper
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.jobscheduler.JobConfig
import it.finmatica.jobscheduler.JobSchedulerRepository
import it.finmatica.jobscheduler.ScheduledJob
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.RegistroGiornaliero
import it.finmatica.protocollo.documenti.RegistroGiornalieroRepository
import it.finmatica.protocollo.documenti.RegistroGiornalieroService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.transaction.annotation.Transactional

import java.text.SimpleDateFormat

@CompileStatic
@Slf4j
class RegistroGiornalieroJob implements ScheduledJob {

    private @Autowired RegistroGiornalieroService registroGiornalieroService
    private @Autowired JobSchedulerRepository jobSchedulerRepository
    private @Autowired RegistroGiornalieroJobExecutor registroGiornalieroJobExecutor
    private @Autowired RegistroGiornalieroRepository registroGiornalieroRepository
    private @Autowired RegistroGiornalieroTaskAnnullamento registroGiornalieroTaskAnnullamento
    private @Autowired WkfIterService wkfIterService
    @Autowired private NotificheService notificheService


    String getTitolo() {
        return 'Registro giornaliero protocollo, job principale'
    }

    String getBeanName() {
        return 'registroGiornalieroJob'
    }

    @Override
    void run(long idJobLog) {
        JobConfig config = registroGiornalieroService.getConfigForLogId(idJobLog)
        esegui(config)
    }

    @CompileDynamic
    void esegui(JobConfig config) {
        SimpleDateFormat df = new SimpleDateFormat('dd/MM/yyyy HH:mm:ss')
        Map<String,Date> dataRicercaDal = [:]
        Map<String,Date> dataRicercaAl = [:]
        Long idTipoProtocollo
        Date now = new Date()
        JsonSlurper js = new JsonSlurper()
        def result = js.parseText(config.parametri)
        idTipoProtocollo = result.idTipoProtocollo as Long
        Map<String,String> dataInizio = result.dataInizio as Map<String,String>
        List<Ente> enti = registroGiornalieroRepository.findEntiValidi()
        for(ente in enti) {
            registroGiornalieroJobExecutor.rimuoviVecchioToken()
            String codiceLock = "${ente.amministrazione.codice}-${ente.aoo}"
            String utenteBatch = ImpostazioniProtocollo.UTENTI_PROTOCOLLO.valore
            registroGiornalieroJobExecutor.eseguiAutenticazione(utenteBatch,ente.id)
            boolean lockOttenuto = false
            log.info("Eseguo il Job per l'ente con codice: ${codiceLock}")
            try {
                String initError = null
                // come prima cosa ottengo il lock per evitare che due tomcat eseguano questo job in contemporanea:
                lockOttenuto = registroGiornalieroJobExecutor.lock(codiceLock)
                // se non ho ottenuto il lock, significa che c'è un altro job che sta eseguendo, quindi esco.

                if (!lockOttenuto) {
                    initError = "C'è già un token per il job notturno e l'ente: ${codiceLock}. Non eseguo il job."
                }
                if (!initError) {
                    RegistroGiornaliero reg = registroGiornalieroService.findLatest(ente.id)
                    Date dataUltimaEsecuzione = reg?.ricercaDataAl
                    if (dataUltimaEsecuzione) {
                        dataRicercaDal[codiceLock] = (dataUltimaEsecuzione.clearTime()) + 1
                    } else if (dataInizio?.get(codiceLock)) {
                        Date di = df.parse(dataInizio.get(codiceLock)).clearTime()
                        dataRicercaDal[codiceLock] = di
                    } else {
                        initError = "Non è stata impostata la data di inizio per ente ${codiceLock}"
                    }
                }
                if(!initError) {
                    Date mezzanotte = now.clearTime()

                    boolean error = false
                    while (!error && (mezzanotte - dataRicercaDal[codiceLock] > 0)) {
                        dataRicercaAl[codiceLock] = new Date((dataRicercaDal[codiceLock] + 1).time - 1000)
                        log.info('Eseguo registro per ente {}, tipoProtocollo {},  da: {} a: {}',codiceLock,idTipoProtocollo,df.format(dataRicercaDal[codiceLock]),df.format(dataRicercaAl[codiceLock]))
                        RegistroGiornaliero res = registroGiornalieroService.eseguiEnte(dataRicercaDal[codiceLock], dataRicercaAl[codiceLock], idTipoProtocollo, dataRicercaDal[codiceLock], ente)
                        if(res?.errore) {
                            registroGiornalieroService.inviaNotifica(res.protocollo, res)
                            registroGiornalieroTaskAnnullamento.annullaRegistroGiornaliero(res.id)
                        } else {
                            String iter = registroGiornalieroService.istanziaIter(res.protocollo.id)
                            if(iter) {
                                res.errore = iter
                                registroGiornalieroService.save(res)
                                registroGiornalieroService.inviaNotifica(res.protocollo,res)
                                registroGiornalieroTaskAnnullamento.annullaRegistroGiornaliero(res.id)
                            }

                        }
                        dataRicercaDal[codiceLock] = dataRicercaDal[codiceLock] + 1
                    }
                } else {
                    //TODO invia notifica di fallimento
                    log.error("Errore inizializzazione per ente {} - {}",codiceLock,initError ?: '-')
                }
            } catch(Exception e)  {
                //TODO invia notifica di fallimento, sarà ritentato (questo catch se fallisce il lock)
                log.error("Errore creazione registro per ente {}",codiceLock,e)
            }
            finally {
                // rilascio il lock
                if (lockOttenuto) {
                    registroGiornalieroJobExecutor.unlock(codiceLock)
                }

            }
        }
    }

    void rimuoviToken() {
        registroGiornalieroJobExecutor.rimuoviToken()
    }
}
