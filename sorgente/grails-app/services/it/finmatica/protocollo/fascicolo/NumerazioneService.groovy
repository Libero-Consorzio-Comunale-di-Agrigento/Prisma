package it.finmatica.protocollo.fascicolo

import groovy.util.logging.Slf4j
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneNumero
import it.finmatica.protocollo.titolario.ClassificazioneNumeroRepository
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional
@Service
class NumerazioneService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloService fascicoloService
    @Autowired
    ClassificazioneRepository classificazioneRepository
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ClassificazioneNumeroRepository classificazioneNumeroRepository

    Date now = new Date()
    boolean apriSerieAperte = true
    Integer annoApertura = now.year + 1900
    String oggi = new Date().format('dd/MM')

    void numerazione() {
        try {
            log.info("Numerazioni Classifiche")
            ciclaSuClassifiche(annoApertura, apriSerieAperte)
            log.info("Numerazioni Fascicoli")
            numeraFascicoliPreparati(annoApertura, apriSerieAperte)
            log.info("Fine Numerazioni")
        } catch (Exception e) {
            log.error("Errore in fase di numerazione", e)
        }
    }

    private void ciclaSuClassifiche(Integer annoApertura, boolean apriSerieAperte) throws Exception {
        List<Classificazione> classificazioneList = []

        if (!apriSerieAperte) {
            // se non devo aprire la numerazione per le serie aperte, filtro solo le chiuse, numerazione illimitata = false
            classificazioneList = classificazioneRepository.getListClassificheNonAperte()
        } else {
            classificazioneList = classificazioneRepository.getListClassifiche()
        }

        classificazioneList.each {
            creaNumerazione(it, annoApertura?.toInteger())
        }
    }

    private void creaNumerazione(Classificazione classifica, Integer annoApertura) throws Exception {
        Integer ultimoNumeroFascicolo = 0
        if (classifica.numIllimitata) {
            ultimoNumeroFascicolo = getUltimoNumero(classifica, annoApertura - 1)
        }
        ClassificazioneNumero cn = classificazioneNumeroRepository.getClassificaNumero(classifica, annoApertura)
        if (!cn) {
            classificazioneService.salvaNumero(classifica, annoApertura, ultimoNumeroFascicolo)
        }
    }

    private Integer getUltimoNumero(Classificazione classifica, Integer annoApertura) {
        ClassificazioneNumero cn = classificazioneNumeroRepository.getClassificaNumero(classifica, annoApertura)
        if (cn) {
            return cn.ultimoNumeroFascicolo
        } else {
            return 0
        }
    }

    private void numeraFascicoliPreparati(Integer annoApertura, boolean apriSerieAperte) throws Exception {
        List<Fascicolo> fascicoloList = fascicoloRepository.listFascicoliDaNumerare()
        def titolario = null
        fascicoloList.each {
            setNumerazioneFascicolo(it, annoApertura, it.classificazione)
        }
    }

    private void setNumerazioneFascicolo(Fascicolo fascicolo, Integer anno, def titolario) {
        if (titolario instanceof Classificazione) {
            fascicolo.numero = classificazioneService.getNuovoNumeroSub(anno, fascicolo.classificazione)
        } else {
            // sub
            String sub = fascicoloService.getNuovoNumeroSub(titolario.toDTO())
            fascicolo.numero = titolario.numero + ImpostazioniProtocollo.SEP_FASCICOLO.valore + sub
            fascicolo.idFascicoloPadre = titolario.id
            fascicolo.sub = sub?.toInteger()
        }
        fascicolo.anno = anno
        fascicolo.annoNumero = anno + "/" + fascicolo.numero?.toUpperCase()
        fascicolo.nome = anno + "/" + fascicolo.numero?.toUpperCase() + " - " + fascicolo.oggetto
        fascicolo.numeroOrd = fascicoloService.numeroOrdinato(fascicolo.numero)
        fascicolo.numeroProssimoAnno = false
        fascicolo.save()
    }
}
