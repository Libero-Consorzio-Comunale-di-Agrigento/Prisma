package it.finmatica.protocollo.integrazioni

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.affarigenerali.ducd.pec.ParametriIngresso
import it.finmatica.affarigenerali.ducd.pec.ParametriIngressoPG
import it.finmatica.affarigenerali.ducd.pec.ParametriUscita
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.mail.MailDTO
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.ws.exception.GeneralExceptionWS
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import it.finmatica.smartdoc.api.DocumentaleService
import org.apache.commons.lang.StringUtils
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
@Slf4j
class DucdHelperService {
    @Autowired
    MailService mailService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    AllegatoProtocolloService allegatoProtocolloService

    private static final Logger logger = Logger.getLogger(DucdHelperService.class)

    ParametriUscita invioPecPG(ParametriIngressoPG parametriIngressoPG) {
        ParametriUscita ret = new ParametriUscita()
        // Setta il parametro di ritorno a OK
        ret.codice = 0
        try {
            logger.info("Inizio servizio invioPecPG");
            pecInternaPG(parametriIngressoPG, ret)
        } catch (GeneralExceptionWS e) {
            // Rilevo il codice e descrizione dell'errore e lo setto sul parametro di uscita
            ret.codice = e.codice
            ret.descrizione = e.descrizione
        }
        ret.descrizione = ret.descrizione ?: ""
        logger.info("Parametri Uscita invioPecPG: "
                +"\nCodice:"+ret.codice
                +"\nDescrizione:"+ret.descrizione
                +"\nIdMessaggio:"+ret.msgId
        )
        return ret
    }

    ParametriUscita invioPec(ParametriIngresso parametriIngresso) {
        ParametriUscita ret = new ParametriUscita()
        // Setta il parametro di ritorno a OK
        ret.codice = 0
        try {
            logger.info("Inizio servizio invioPec")
            pecInterna(parametriIngresso, ret)
        } catch (GeneralExceptionWS e) {
            // Rilevo il codice e descrizione dell'errore e lo setto sul parametro di uscita
            ret.codice = e.codice
            ret.descrizione = e.descrizione
        }
        ret.descrizione = ret.descrizione ?: ""
        logger.info("Parametri Uscita invioPecPG: "
                +"\nCodice:"+ret.codice
                +"\nDescrizione:"+ret.descrizione
                +"\nIdMessaggio:"+ret.msgId
        )
        return ret
    }

    private void pecInterna(ParametriIngresso parametriIngresso, ParametriUscita parametriUscita) throws GeneralExceptionWS {

        //verifica paramertiIngresso non nullo
        if(parametriIngresso == null) {
            throw new GeneralExceptionWS(-1, "PARAMETRI IN INGRESSO MANCANTI")
        }

        //Il cliente ha come "cattiva" abitudine mettere -1 quando non ci deve essere... quindi faccio verifica
        if(! ((parametriIngresso.idDocumento < -1 || parametriIngresso.idDocumento > -1) || (!parametriIngresso.anno.equals("-1") && !parametriIngresso.numero.equals("-1"))))
            throw new GeneralExceptionWS(-1, "Passare almeno anno/numero oppure id documento");


        if( ( parametriIngresso.idDocumento == 0  && (  (! StringUtils.isNotBlank(parametriIngresso.anno) || parametriIngresso.anno == "")|| (! StringUtils.isNotBlank(parametriIngresso.numero) || parametriIngresso.numero == "" )))) {
            throw new GeneralExceptionWS(-1, "Passare almeno anno/numero oppure id documento")
        }

        //verifica esistenza utente creazione
        Ad4Utente utenteCreazione
        if(parametriIngresso.utenteCreazione != "" && StringUtils.isNotBlank(parametriIngresso.utenteCreazione)){
            utenteCreazione = Ad4Utente.findByUtente(parametriIngresso.utenteCreazione)
            if(utenteCreazione == null) {
                logger.error("Invio Pec: Utente "+parametriIngresso.utenteCreazione+" non trovato")
                throw new GeneralExceptionWS(-6, "Utente: "+parametriIngresso.utenteCreazione+" non trovato.")
            }
        }

        //verifica destinatari
        List<String> destinatari = parametriIngresso.listaDestinatari?.split("###")
        if(destinatari == null ||destinatari.size() <= 0) {
            throw new GeneralExceptionWS(-1, "Destinatari assenti")
        } else if (destinatari.size()==1 && (!StringUtils.isNotBlank(destinatari.get(0)) ||destinatari.get(0).equals(""))) {
            throw new GeneralExceptionWS(-1, "Destinatari assenti")
        }

        //Se idDocumento è -1 ma ho valorizzato anno e numero setto idDocumento a 0 per non avere problemi nei ragionamenti successivi in trascodifica
        if(parametriIngresso.idDocumento == -1) parametriIngresso.idDocumento = 0

        try {
            logger.info("Parametri Ingresso invioPecPG: "
                    +"\nIdDocumento:"+parametriIngresso.idDocumento
                    +"\nAnno:"+parametriIngresso.anno
                    +"\nNumero:"+parametriIngresso.numero
                    +"\ndestinatari:"+parametriIngresso.listaDestinatari
                    +"\nutente:"+parametriIngresso.utenteCreazione
                    +"\n invioSingolo:"+parametriIngresso.invioSingolo.toString()
                    +"\n segnaturaCompleta:"+parametriIngresso.segnaturaCompleta.toString()
                    +"\n senzaSegnatura:"+parametriIngresso.senzaSegnatura.toString()
            )
        } catch (Exception e) {
            logger.error(e.getMessage());
        }

        Protocollo protocollo = protocolloWSUtilityService.estraiProtoccoloDaProtocolloWS(new Long(parametriIngresso.idDocumento),
                                                                                      StringUtils.isNotBlank(parametriIngresso.anno) && parametriIngresso.anno != "" ? Integer.valueOf(parametriIngresso.anno) : null,
                                                                                      StringUtils.isNotBlank(parametriIngresso.numero) && parametriIngresso.numero != "" ? Integer.valueOf(parametriIngresso.numero): null,
                                                                                      parametriIngresso.tipoRegistro)

        if (protocollo) {
            Long idMsg = completaInvioPec(parametriIngresso, protocollo)
            parametriUscita.msgId = idMsg == 0 ? "" : String.valueOf(idMsg)
        } else {
            throw new GeneralExceptionWS(-2, "Protocollo non trovato")
        }

    }

    //Devo inviare solo per un protocollo a partire dall'estrazione dei dati dal ProtocolloWS per anno numero e tipoRegistro
    private void pecInternaPG(ParametriIngressoPG parametriIngressoPG, ParametriUscita parametriUscita) throws GeneralExceptionWS {

        //verifica paramertiIngresso non nullo
        if(parametriIngressoPG == null) {
            throw new GeneralExceptionWS(-1, "PARAMETRI IN INGRESSO MANCANTI")
        }

        if( parametriIngressoPG.anno <= 0 || parametriIngressoPG.numero <=0) {
            throw new GeneralExceptionWS(-1, "PASSARE ANNO E NUMERO")
        }

        //verifica esistenza utente creazione
        Ad4Utente utenteCreazione
        if(parametriIngressoPG.utenteCreazione != "" && StringUtils.isNotBlank(parametriIngressoPG.utenteCreazione)){
            utenteCreazione = Ad4Utente.findByUtente(parametriIngressoPG.utenteCreazione)
            if(utenteCreazione == null) {
                logger.error("Invio PecPG: Utente "+parametriIngressoPG.utenteCreazione+" non trovato")
                throw new GeneralExceptionWS(-6, "Utente: "+parametriIngressoPG.utenteCreazione+" non trovato.")
            }
        }

        //verifica destinatari
        List<String> destinatari = parametriIngressoPG.listaDestinatari?.split("###")
        if(destinatari == null ||destinatari.size() <= 0) {
            throw new GeneralExceptionWS(-1, "Destinatari assenti")
        } else if (destinatari.size()==1 && (!StringUtils.isNotBlank(destinatari.get(0)) ||destinatari.get(0).equals(""))) {
            throw new GeneralExceptionWS(-1, "Destinatari assenti")
        }

        try {
            logger.info("Parametri Ingresso invioPecPG: "
                    +"\nAnno:"+parametriIngressoPG.anno
                    +"\nNumero:"+parametriIngressoPG.numero
                    +"\ndestinatari:"+parametriIngressoPG.listaDestinatari
                    +"\nutente:"+parametriIngressoPG.utenteCreazione
                    +"\n invioSingolo:"+parametriIngressoPG.invioSingolo.toString()
                    +"\n segnaturaCompleta:"+parametriIngressoPG.segnaturaCompleta.toString()
                    +"\n senzaSegnatura:"+parametriIngressoPG.senzaSegnatura.toString()
            )
        } catch (Exception e) {
            logger.error(e.getMessage());
        }

        Protocollo protocollo = protocolloWSUtilityService.estraiProtoccoloDaProtocolloWS(null,
                                                                                          ( parametriIngressoPG.anno != 0  &&  parametriIngressoPG.anno != -1) ? Integer.valueOf(parametriIngressoPG.anno) : null,
                                                                                          ( parametriIngressoPG.numero != 0 && parametriIngressoPG.numero != -1 ) ? Integer.valueOf(parametriIngressoPG.numero): null,
                                                                                           parametriIngressoPG.tipoRegistro)

        if(protocollo){

            String anno = String.valueOf(parametriIngressoPG.getAnno())
            String numero = String.valueOf(parametriIngressoPG.getNumero())
            String tipoReg = protocollo.tipoRegistro.codice

            ParametriIngresso pi = new ParametriIngresso()
            pi.utenteCreazione = parametriIngressoPG.utenteCreazione
            pi.listaDestinatari = parametriIngressoPG.listaDestinatari
            pi.anno = anno
            pi.numero = numero
            pi.tipoRegistro = tipoReg
            pi.invioSingolo = parametriIngressoPG.invioSingolo
            pi.senzaSegnatura = parametriIngressoPG.senzaSegnatura
            pi.idDocumento = protocollo.idDocumentoEsterno.intValue()
            pi.segnaturaCompleta = parametriIngressoPG.segnaturaCompleta

            Long idMsg = completaInvioPec (pi, protocollo)
            parametriUscita.msgId = idMsg == 0 ? "" : String.valueOf(idMsg)
        }
        else {
            throw new GeneralExceptionWS(-2, "Protocollo non trovato")
        }
    }

    private Long completaInvioPec(ParametriIngresso parametriIngresso, Protocollo protocollo) {

        String tipoConsegna = ImpostazioniProtocollo.TIPO_CONSEGNA.getValore() ?: ImpostazioniProtocollo.TIPO_CONSEGNA.valore
        MailDTO mittente
        List<FileDocumentoDTO> allegati
        List<CorrispondenteDTO> corrispondenti

        //ESTRAI DESTINATARI
        List<String> destinatari = parametriIngresso.listaDestinatari?.split("###")
        protocollo = protocolloWSUtilityService.aggiungiCorrispendentiAPrtocolloWS(protocollo, destinatari)
       //recupero gli allegati
       allegati = estraiFilePrincipaleEAllegati(protocollo)

       corrispondenti = protocollo.corrispondenti?.toDTO() asList()
       //filtro solo quelli che hanno un indirizzo mail
       corrispondenti = corrispondenti?.findAll { it.email != null }

       if (null == corrispondenti || corrispondenti.size() <= 0) {
           logger.info("Invio Pec : Non sono stati trovati destinatari");
           throw new GeneralExceptionWS(-1, "Non sono stati trovati destinatari")
       }

       List<MailDTO> mittenti = mailService.ricercaMittenti(protocollo.id, parametriIngresso.utenteCreazione)
       mittente = mittenti ? mittenti.first() : null

       if (mittente == null) {
           logger.info("Invio Pec : Non sono stati trovati mittenti");
           throw new GeneralExceptionWS(-1, "Mittente non trovato")
       }

       //Chiamo il servizio di invioPec per inviare la mail
       try {
           mailService.invioPec(protocollo.toDTO() as ProtocolloDTO, mittente, "", protocollo.oggetto, parametriIngresso.invioSingolo, !parametriIngresso.senzaSegnatura, parametriIngresso.segnaturaCompleta, allegati, corrispondenti, tipoConsegna)
           logger.info("Invio Pec terminato");
           return 0

       } catch (Exception e) {
           logger.error("Errore invio pec: " + e.getMessage())
           throw new GeneralExceptionWS(-1, "Problemi in invioPec:" + e.getMessage())
       }

       return 0
    }

    private List<FileDocumentoDTO> estraiFilePrincipaleEAllegati (Protocollo protocollo){
        List<FileDocumento> listaFilesAllegato = new ArrayList<FileDocumentoDTO>()

        //Recupero il file principale
        listaFilesAllegato = allegatoProtocolloService.getAllegatiByIdAndCodice(protocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE)
        //Questa serve per quelli che ho aggiunto come allegati al documento per i documenti "esterni" (contratti, delibere, determine etc.)
        listaFilesAllegato.addAll(allegatoProtocolloService.getAllegatiByIdAndCodice(protocollo.id, FileDocumento.CODICE_FILE_ALLEGATO))

        //Recupero i file legati al documento (principale) e tutti gli allegati
        for(Allegato allegato : protocollo.allegati) {
            listaFilesAllegato.addAll(allegatoProtocolloService.getAllegatiByIdAndCodice(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO))
        }
        return listaFilesAllegato.toDTO()
    }

}
