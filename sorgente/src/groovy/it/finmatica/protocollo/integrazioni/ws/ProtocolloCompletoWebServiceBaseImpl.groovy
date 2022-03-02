package it.finmatica.protocollo.integrazioni.ws

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.Holders
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.multiente.MultiEnteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.jdocarea.AOO
import it.finmatica.protocollo.integrazioni.jdocarea.Documento
import it.finmatica.protocollo.integrazioni.jdocarea.Intestazione
import it.finmatica.protocollo.integrazioni.jdocarea.Parametro
import it.finmatica.protocollo.integrazioni.jdocarea.Persona
import it.finmatica.protocollo.integrazioni.jdocarea.Segnatura
import it.finmatica.protocollo.integrazioni.jdocarea.SegnaturaService
import it.finmatica.protocollo.integrazioni.ws.dati.Allegato
import it.finmatica.protocollo.integrazioni.ws.dati.Protocollo
import it.finmatica.protocollo.integrazioni.ws.dati.ProtocolloCompleto
import it.finmatica.protocollo.integrazioni.ws.dati.Soggetto
import it.finmatica.protocollo.integrazioni.ws.dati.response.CaricaProtocolloCompletoResponse
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.segreteria.common.ParametriSegreteria
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.apache.commons.lang3.time.DateUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional

import javax.jws.WebParam
import javax.servlet.ServletContext

@Slf4j
@Transactional
class ProtocolloCompletoWebServiceBaseImpl extends ProtocolloWebServiceBase implements ProtocolloCompletoWebService {

    @Autowired private SegnaturaService segnaturaService
    @Autowired private ClassificazioneService classificazioneService
    @Autowired private FascicoloRepository fascicoloRepository
    @Autowired private MultiEnteService multiEnteService
    @Autowired private So4UnitaPubbService so4UnitaPubbService

    @Override
    CaricaProtocolloCompletoResponse creaProtocollo(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = "protocollo") ProtocolloCompleto protocollo) {
        CaricaProtocolloCompletoResponse resp =  new CaricaProtocolloCompletoResponse()
        log.info("INIZIO: Chiamata al WS di creazione del protocollo")
        try {
            login(operatore, ente)

            it.finmatica.protocollo.documenti.Protocollo p = creaProtocolloDaWS(protocollo)

            resp.id = p.id
            resp.idDocumentoEsterno = p.idDocumentoEsterno
            resp.url = Impostazioni.AG_SERVER_URL.valore + Holders.getApplicationContext().getBean(ServletContext).contextPath + "/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento=LETTERA&idDoc=" + p.idDocumentoEsterno
            resp.esito = "OK"

        } catch (Throwable t) {
            log.error(t.message, t)
            throw new ProtocolloRuntimeException(t)
        }
        log.info("FINE: Chiamata al WS di creazione del protocollo")
        return resp
    }

    @Override
    CaricaProtocolloCompletoResponse creaProtocolloDaSegnatura(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = "xmlSegnatura") String xmlSegnatura, @WebParam(name = "allegati") List<Allegato> allegati) {
        // TODO che fare se malformato?
        CaricaProtocolloCompletoResponse resp =  new CaricaProtocolloCompletoResponse()
        try {
            Segnatura segnatura = segnaturaService.leggiSegnatura(xmlSegnatura)
            login(operatore, ente)
            it.finmatica.protocollo.documenti.Protocollo p = salvaProtocolloDaSegnatura(operatore, ente, segnatura, allegati)
            resp.id = p.id
            resp.idDocumentoEsterno = p.idDocumentoEsterno
            resp.url = Impostazioni.AG_SERVER_URL.valore + Holders.getApplicationContext().getBean(ServletContext).contextPath + "/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento=LETTERA&idDoc=" + p.idDocumentoEsterno
            resp.esito = "OK"
        } catch (Throwable t) {
            log.error(t.message, t)
            throw new ProtocolloRuntimeException(t)
        }
        return resp

    }

    @Override
    protected it.finmatica.protocollo.documenti.Protocollo buildProtocolloWS(Protocollo pws) {
        it.finmatica.protocollo.documenti.Protocollo protocollo =  super.buildProtocolloWS(pws)
        ProtocolloCompleto protocolloWs = pws as ProtocolloCompleto
        protocollo.campiProtetti = protocolloWs.campiProtetti
        protocollo.codiceRaccomandata = protocolloWs.codiceRaccomandata
        protocollo.dataComunicazione = protocolloWs.dataComunicazione
        protocollo.dataStatoArchivio = protocolloWs.dataStatoArchivio
        protocollo.dataVerifica = protocolloWs.dataVerifica
        protocollo.esitoVerifica = protocolloWs.esitoVerifica
        protocollo.annoEmergenza = protocolloWs.annoEmergenza
        protocollo.numeroEmergenza = protocolloWs.numeroEmergenza
        protocollo.registroEmergenza = protocolloWs.registroEmergenza
        protocollo.idrif = protocolloWs.idrif
        protocollo.modalitaInvioRicezione = protocolloWs.modalitaInvioRicezione ? dizionariRepository.getModalitaInvioRicezione(protocolloWs.modalitaInvioRicezione) : null
        protocollo.noteTrasmissione = protocolloWs.noteTrasmissione
        protocollo.tipoRegistro = protocolloWs.tipoRegistro ? dizionariRepository.getTipoRegistro(protocolloWs.tipoRegistro) : null
    }

    @Override
    protected Protocollo caricaProtocolloWs(Long id) {
        ProtocolloCompleto protocolloWs = new ProtocolloCompleto()
        protocolloWs = super.caricaProtocolloWs(id,protocolloWs) { it.finmatica.protocollo.documenti.Protocollo protocollo ->
            protocolloWs.campiProtetti = protocollo.campiProtetti
            protocolloWs.codiceRaccomandata = protocollo.codiceRaccomandata
            protocolloWs.dataComunicazione = protocollo.dataComunicazione
            protocolloWs.dataStatoArchivio = protocollo.dataStatoArchivio
            protocolloWs.dataVerifica = protocollo.dataVerifica
            protocolloWs.esitoVerifica = protocollo.esitoVerifica
            protocolloWs.annoEmergenza = protocollo.annoEmergenza
            protocolloWs.numeroEmergenza = protocollo.numeroEmergenza
            protocolloWs.registroEmergenza = protocollo.registroEmergenza
            protocolloWs.idrif = protocollo.idrif
            protocolloWs.modalitaInvioRicezione = protocollo.modalitaInvioRicezione?.codice
            protocolloWs.noteTrasmissione = protocollo.noteTrasmissione
            protocolloWs.tipoRegistro = protocollo.tipoRegistro?.codice
        }
        return protocolloWs
    }

    private it.finmatica.protocollo.documenti.Protocollo salvaProtocolloDaSegnatura(Soggetto operatore,long ente, Segnatura segnatura, List<Allegato> allegati) {
        Ente e = multiEnteService.ente
        So4Amministrazione amm = e.amministrazione
        it.finmatica.protocollo.documenti.Protocollo protocollo = new it.finmatica.protocollo.documenti.Protocollo()
        Intestazione intestazione = segnatura.intestazione
        protocollo.oggetto = intestazione.oggetto
        String movimento = intestazione.identificatore.flusso
        switch(movimento) {
            case(ParametriSegreteria.CODICE_MOVIMENTO_ARRIVO): protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_ARRIVO
                if(intestazione.mittente?.persona || intestazione.mittente?.AOO || intestazione.mittente?.amministrazione) {
                    Corrispondente mittente = new Corrispondente()
                    mittente.tipoCorrispondente = Corrispondente.MITTENTE
                    if(intestazione.mittente.persona) {
                        Persona persona = intestazione.mittente.persona
                        mittente.nome = persona.nome
                        mittente.cognome = persona.cognome
                        mittente.codiceFiscale = persona.codiceFiscale
                        mittente.email = persona.indirizzoTelematico?.content
                    } else if(intestazione.mittente.AOO) {
                        AOO aoo = intestazione.mittente.AOO
                        mittente.denominazione = aoo.denominazione
                    } else if(intestazione.mittente.amministrazione) {
                        it.finmatica.protocollo.integrazioni.jdocarea.Amministrazione ammin = intestazione.mittente.amministrazione
                        mittente.denominazione = ammin.denominazione
                    }
                    protocollo.addToCorrispondenti(mittente)

                }
                break
            case(ParametriSegreteria.CODICE_MOVIMENTO_PARTENZA): protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_PARTENZA
                if(intestazione.destinatario?.persona || intestazione.destinatario?.AOO || intestazione.destinatario?.amministrazione) {
                    Corrispondente destinatario = new Corrispondente()
                    destinatario.email = intestazione.destinatario.indirizzoTelematico?.content
                    destinatario.tipoCorrispondente = Corrispondente.DESTINATARIO
                    if(intestazione.destinatario.persona) {
                        Persona persona = intestazione.destinatario.persona
                        destinatario.nome = persona.nome
                        destinatario.cognome = persona.cognome
                        destinatario.codiceFiscale = persona.codiceFiscale
                        destinatario.email = persona.indirizzoTelematico?.content
                    } else if(intestazione.destinatario.AOO) {
                        AOO aoo = intestazione.destinatario.AOO
                        destinatario.denominazione = aoo.denominazione
                    } else if(intestazione.destinatario.amministrazione) {
                        it.finmatica.protocollo.integrazioni.jdocarea.Amministrazione ammin = intestazione.destinatario.amministrazione
                        destinatario.denominazione = ammin.denominazione
                    }
                    protocollo.addToCorrispondenti(destinatario)

                }
                break
            case(ParametriSegreteria.CODICE_MOVIMENTO_INTERNO): protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO; break
        }
        protocollo.classificazione = classificazioneService.findByCodice(intestazione.classifica.codiceTitolario)
        protocollo.fascicolo = fascicoloRepository.getFascicolo(protocollo.classificazione.id,Integer.valueOf(intestazione.fascicolo.anno),intestazione.fascicolo.numero)
        protocollo.smistamenti = new HashSet<>()
        List<Parametro> parametri = segnatura.applicativoProtocollo.parametro
        String up = parametri.find {it.nome == 'uo'}
        List so4UnitaPubbs = so4UnitaPubbService.cercaUnitaPubb(amm.codice, Impostazioni.OTTICA_SO4.valore)
        So4UnitaPubb unitaProtocollante = so4UnitaPubbs.find {it.codice == up}
        DocumentoSoggetto unitaProt = new DocumentoSoggetto()
        unitaProt.unitaSo4 = unitaProtocollante
        unitaProt.tipoSoggetto = TipoSoggetto.UO_PROTOCOLLANTE
        unitaProt.attivo = true
        protocollo.addToSoggetti(unitaProt)
        List<String> smistamenti = parametri.findAll {it.nome == 'smistamento'}.collect {it.valore}
        for(smist in smistamenti) {
            def (unitaSmistamento,tipoSmistamento) = smist.split('@@')
            Smistamento smistamento = new Smistamento()
            smistamento.unitaSmistamento = so4UnitaPubbs.find {it.codice == unitaSmistamento}
            smistamento.tipoSmistamento = tipoSmistamento
            protocollo.addToSmistamenti(smistamento)
        }

        String annoPrecStringa = parametri.find {it.nome == 'annoPrecedente'}
        String numeroPrecStringa = parametri.find {it.nome == 'numeroPrecedente'}
        String dataDocumento = parametri.find {it.nome == "dataDocumento"}
        if(dataDocumento) {
            protocollo.dataComunicazione = DateUtils.parseDate(dataDocumento,'dd/MM/yyyy')
        }
        protocollo.tipoProtocollo = dizionariRepository.getTipoProtocolloDefault(it.finmatica.protocollo.documenti.Protocollo.TIPO_DOCUMENTO)
        protocolloService.salva()
        WkfCfgIter cfgIter = protocollo.tipoProtocollo.getCfgIter()
        wkfIterService.istanziaIter(cfgIter, protocollo)
        if(annoPrecStringa && numeroPrecStringa) {
            it.finmatica.protocollo.documenti.Protocollo precedente = protocolloService.findByAnnoAndNumeroAndTipoRegistro(Integer.valueOf(annoPrecStringa), Integer.valueOf(numeroPrecStringa))
            if(precedente) {
                protocollo.addDocumentoCollegato(precedente, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
            }
        }
        if(segnatura.descrizione.documento) {
            // questo è il file principale
            Documento filePrinc = segnatura.descrizione.documento
            Allegato allegato = allegati.find {Long.valueOf(it.idRiferimento) == filePrinc.id}
            GestioneTestiModello modelloTesto
            if (protocollo.tipoProtocollo != null) {
                modelloTesto = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            }

            FileDocumento fileAllegato = new FileDocumento(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                    , nome: filePrinc.nome
                    , contentType: allegato.contentType
                    , valido: true
                    , modificabile: true
                    , firmato: false
                    , modelloTesto: modelloTesto)
            protocollo.addToFileDocumenti(fileAllegato)
            fileAllegato.save()
            gestoreFile.addFile(protocollo, fileAllegato, allegato.file.inputStream)

        }
        if(segnatura.descrizione.allegati) {
            // questi sono gli allegati
            for(documento in segnatura.descrizione.allegati.documento) {
                it.finmatica.gestionedocumenti.documenti.Allegato allegato = new it.finmatica.gestionedocumenti.documenti.Allegato()
                Allegato doc = allegati.find {Long.valueOf(it.idRiferimento) == documento.id}
                allegato.descrizione = documento.nome
                allegato.commento = documento.nome
                allegato.origine = "WS"
                allegato.ubicazione = "WS"
                allegato.tipoAllegato = dizionariRepository.getTipoAllegato(TipoAllegato.CODICE_TIPO_ALLEGATO)
                allegato.save()
                protocollo.addDocumentoAllegato(allegato)
                documentoService.uploadFile(allegato, documento.nome, doc.contentType, doc.file.inputStream)
            }
        }


    }
}
