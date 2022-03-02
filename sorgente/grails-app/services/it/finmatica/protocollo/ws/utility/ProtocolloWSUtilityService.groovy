package it.finmatica.protocollo.ws.utility

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloEsternoService
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloWS
import it.finmatica.protocollo.documenti.ProtocolloWSService
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.trasco.TrascoService
import it.finmatica.protocollo.ws.exception.GeneralExceptionWS
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang3.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional


@Transactional
@Service
@Slf4j
class ProtocolloWSUtilityService {

    @Autowired
    ProtocolloService protocolloService
    @Autowired
    TrascoService trascoService
    @Autowired
    ProtocolloWSService protocolloWSService
    @Autowired
    ProtocolloEsternoService protocolloEsternoService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    So4Repository so4Repository
    @Autowired
    ClassificazioneRepository classificazioneRepository
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    PreferenzeUtenteService preferenzeUtenteService
    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    SpringSecurityService springSecurityService

    Protocollo getProtocolloFromIdAndTrasco(Long id) {
        ProtocolloWS prot = protocolloWSService.findOne(id)
        if(prot) {
            return getProtocolloFromWSAndTrasco(prot)
        } else {
            // non dovrebbe mai succedere se l'id viene dalle getDocumenti
            return null
        }
    }

    Protocollo getProtocolloFromWSAndTrasco(ProtocolloWS prot) throws GeneralExceptionWS {
        Protocollo res
        if(prot) {
            if (prot.idDocumento < 0) {
                if (prot.isCategoriaProtocollo()) {
                    Long idNuovo = trascoService.creaProtocolloDaGdm(prot.idDocumentoEsterno)
                    if (!idNuovo) {
                        idNuovo = trascoService.creaProtocolloDaGdm(-prot.idDocumento)
                    }
                    if (idNuovo) {
                        res = protocolloService.findById(idNuovo)
                    } else {
                        throw new GeneralExceptionWS(ErroriWsDocarea.ERRORE_INTERNO.codice, "Problemi in trascodifica")
                    }
                }
            } else {
                res = protocolloService.findById(prot.idDocumento)
            }
        }
        return res
    }

    /**
     *
     * @param idDocumento
     * @param anno
     * @param numero
     * @param tipoRegistro
     * @return
     */
    Protocollo estraiProtoccoloDaProtocolloWS(Long idDocumento, Integer anno, Integer numero, String tipoRegistro) throws GeneralExceptionWS {
        ProtocolloWS protocolloWS = estraiDocumentoDaProtocolloWS(idDocumento, anno, numero, tipoRegistro)
        return completaDatiPerDocumento(protocolloWS)
    }

    ProtocolloWS estraiDocumentoDaProtocolloWS (Long idDocumento, Integer anno, Integer numero, String tipoRegistro) {

        //Estrai documenti dalla vista prima per idDocumento
        ProtocolloWS protocolloWS
        if(idDocumento) {
            protocolloWS =  protocolloWSService.findOne(idDocumento)
        }

        //Se non lo trovo provo per registro anno numero
        if(protocolloWS == null) {
            //Verifica se tipoRegistro è nullo usa quello di default
            String tipoRegistroParam = tipoRegistro
            if( ! StringUtils.isNotBlank(tipoRegistroParam) || tipoRegistroParam == "") {
                tipoRegistroParam = ImpostazioniProtocollo.TIPO_REGISTRO.valore
            }
            protocolloWS = protocolloWSService.findByAnnoAndNumeroAndTipoRegistro(anno, numero, tipoRegistroParam)
        }

        return protocolloWS

    }

    Protocollo completaDatiPerDocumento(ProtocolloWS protocolloWS, boolean salvaDoc = true) {

        Protocollo protocollo
        ProtocolloEsterno protocolloEsterno
        if(protocolloWS != null) {
            //cercalo da noi e verifica se transcodificato
            protocollo = getProtocolloFromWSAndTrasco(protocolloWS)
            //se non lo trovo lo cerco in PROTO_VIEW solo se è un doc "esterno"
            if(salvaDoc) {
                if (!protocollo && ! protocolloWS.isCategoriaProtocollo()) {
                    //Verifica prima se è stato gia' salvato
                    protocollo = protocolloService.findById(protocolloWS.idDocumento)
                    if(protocollo == null) {
                        protocolloEsterno = protocolloEsternoService.getProtocolloEsterno(protocolloWS.idDocumento)
                        //A questo punto devo salvare il documento esterno come se fosse un protocollo con le info minimali
                        protocollo = salvaProtocolloDaDocEsterno(protocolloEsterno, protocolloWS)
                    }
                    //Recupera sempre gli allegati da gdm per i doc "esterni" (in modo da avere sempre quelli aggiornati nel caso siano stati modificati)
                    protocollo = estraiFileDocumentiPerDocGDM(protocollo)
                }
            }
        }
        return protocollo
    }

    private Protocollo estraiFileDocumentiPerDocGDM(Protocollo protocollo) {

        List<File> files = caricaFileDaDocumentale(protocollo.idDocumentoEsterno)
        //Rimuovi tutto e reinserisci
        List<FileDocumento> listaFileDaEliminare = protocollo.fileDocumenti
        protocollo.fileDocumenti?.removeAll(listaFileDaEliminare)
        for (File fileSmart : files) {
            protocollo.addToFileDocumenti(new FileDocumento(nome: fileSmart.nome, idFileEsterno: new Long(fileSmart.id), contentType: fileSmart.contentType ?: "application/octet-stream"))
        }
        protocolloService.salva(protocollo, false, false,true)

        return protocollo
    }

    List<File> caricaFileDaDocumentale(Long idDocumentoEsterno) {
        Documento documentoSmart = new Documento()
        documentoSmart.setId(Long.toString(idDocumentoEsterno))
        documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        documentoSmart = documentaleService.getDocumento(documentoSmart, [Documento.COMPONENTI.FILE])
        //per ogni file devo fare un nuovo filedocumento in cui metto il nome e l'iddocEsterno (iddocsmart)
        return documentoSmart.files
    }

    /**
     *
     * @param protocolloEsterno
     * @param protocolloWS
     * @return
     */
    Protocollo salvaProtocolloDaDocEsterno(ProtocolloEsterno protocolloEsterno, ProtocolloWS protocolloWS) {

        Protocollo protocollo = new Protocollo()
        protocollo.idDocumentoEsterno = protocolloWS.idDocumentoEsterno
        protocollo.idrif = protocolloWS.idrif
        protocollo.oggetto = protocolloWS.oggetto
        protocollo.numero = protocolloWS.numero
        protocollo.anno = protocolloWS.anno
        protocollo.data = protocolloWS.data
        //indico che è un documento/protocollo creato dal ws
        protocollo.note = 'WS'
        protocollo.dataRedazione = new Date()
        protocollo.classificazione = protocolloWS.classificazione ? classificazioneService.findByCodice(protocolloWS.classificazione) : null
        //se ho i dati del fascicolo provo ad estrarlo
        if(protocolloWS.annoFascicolo != null && protocolloWS.numeroFascicolo != null) {
            protocollo.fascicolo = fascicoloRepository.getFascicolo(protocollo.classificazione?.id, protocolloWS.annoFascicolo, protocolloWS.numeroFascicolo)
        }
        protocollo.movimento = Protocollo.MOVIMENTO_INTERNO//protocolloWS.modalita ?: (preferenzeUtenteService.getModalita() ?: CategoriaProtocollo.CATEGORIA_DOCUMENTO_ESTERNO.movimenti.first())
        protocollo.tipoRegistro = TipoRegistro.get(protocolloWS.tipoRegistro)
        TipoProtocollo tipoProtocollo = dizionariRepository.getTipoProtocolloDefault(Protocollo.CATEGORIA_DOCUMENTO_ESTERNO)
        //unita protocollante di default per proto automatici
        So4UnitaPubb unita = So4UnitaPubb.findByCodiceAndAlIsNull(ImpostazioniProtocollo.UNITA_PROTOCOLLO.valore)
        protocollo.setSoggetto(TipoSoggetto.REDATTORE, springSecurityService.currentUser, null)
        protocollo.setSoggetto(TipoSoggetto.UO_PROTOCOLLANTE, springSecurityService.currentUser, unita)
        protocollo.tipoProtocollo = tipoProtocollo

        protocolloService.salva(protocollo, false, false,true)

        return protocollo
    }

    /**
     *
     * @param protocollo
     * @param destinatari
     * @return
     */
    Protocollo aggiungiCorrispendentiAPrtocolloWS(Protocollo protocollo , List<String> destinatari) {

        for (String destinatario : destinatari) {
            boolean destPresente = false
            for(Corrispondente corrispondente : protocollo.corrispondenti) {
                if(corrispondente.email == destinatario) {
                    destPresente = true
                    break
                }
            }
            if(!destPresente) {
                //Se non presente tra i corrispondenti devo aggiungerlo
                protocollo.addToCorrispondenti(new Corrispondente(email: destinatario, denominazione: destinatario))
            }
        }
        protocolloService.salva(protocollo, false, false,true)

        return protocollo
    }


    So4UnitaPubb getUnitaByCodiceSenzaControlloValiditaSo4(String codice) {
        so4Repository.getUnitaByCodiceSenzaControlloValiditaSo4(codice)
    }

    List<Classificazione> getListClassificazioneValidaByCodice (String codice) {
        classificazioneRepository.getListClassificazioneValidaByCodice(codice, new Date())
    }

    List<Fascicolo> getFascicoloValido(Long classifica, Integer fascicoloAnno, String fascicoloNumero) {
        return fascicoloRepository.getListFascicolo(classifica, fascicoloAnno, fascicoloNumero)
    }

    Ente getEnteFascicoliSecondari(String codiceAmm, String codiceAOO) {
        So4Amministrazione amm = So4Amministrazione.findByCodice(codiceAmm)
        Ente ente =  Ente.findByValidoAndAmministrazioneAndAOO(true, amm, codiceAOO)
    }
}
