package it.finmatica.protocollo.integrazioni

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.affarigenerali.ducd.protocollaSoap.ParametriIngresso
import it.finmatica.affarigenerali.ducd.protocollaSoap.ParametriUscita
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloWS
import it.finmatica.protocollo.ws.exception.GeneralExceptionWS
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import org.apache.commons.lang.StringUtils
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.text.DateFormat
import java.text.SimpleDateFormat

@Transactional
@Service
@Slf4j
class ProtocollaWSHelperService {

    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService
    @Autowired
    ProtocolloService protocolloService

    private static final Logger logger = Logger.getLogger(ProtocollaWSHelperService.class)

    ParametriUscita protocolla(ParametriIngresso parametriIngresso) {
        ParametriUscita ret = new ParametriUscita()
        // Setta il parametro di ritorno a OK
        ret.codice = 0
        try {
            protocollaWS(parametriIngresso, ret)
        } catch (GeneralExceptionWS e) {
            // Rilevo il codice e descrizione dell'errore e lo setto sul parametro di uscita
            ret.codice = e.codice
            ret.descrizione = e.descrizione
            logger.error(e.getCodice()+ ": "+e.getDescrizione())
        }
        logger.info(ret.getCodice()+ ": "+ ret.getDescrizione())
        return ret
    }


     private void protocollaWS(ParametriIngresso parametriIngresso , ParametriUscita parametriUscita) throws GeneralExceptionWS {

         //verifica paramertiIngresso non nullo
         if(parametriIngresso == null) {
             throw new GeneralExceptionWS(-1, "PARAMETRI IN INGRESSO MANCANTI")
         }

         if( parametriIngresso.idDocumento == null || parametriIngresso.idDocumento == 0) {
             throw new GeneralExceptionWS(-1, "PARAMETRO MANCANTE ID DOCUMENTO")
         }

         ProtocolloWS protocolloWs = protocolloWSUtilityService.estraiDocumentoDaProtocolloWS(new Long(parametriIngresso.idDocumento), null, null, null )

         if( !protocolloWs) {
             throw new GeneralExceptionWS(-1, "Documento non trovato in AGP_WS_PROTOCOLLI")
         }

         Protocollo protocollo = protocolloWSUtilityService.completaDatiPerDocumento(protocolloWs)

         //Sovrascrivi registro e oggetto ?
         protocollo.oggetto = parametriIngresso.oggetto
         TipoRegistro tipoRegistro = TipoRegistro.get(parametriIngresso.tipoRegistro)
         // Se nullo provo con quello di default
         if(!tipoRegistro){
             protocollo.tipoRegistro = tipoRegistro
         }

         //Recupera user creazione se valorizzato
         Ad4Utente utenteCreazione
         if(parametriIngresso.utenteCreazione != "" && StringUtils.isNotBlank(parametriIngresso.utenteCreazione)){
             utenteCreazione = Ad4Utente.findByUtente(parametriIngresso.utenteCreazione)
             if(utenteCreazione == null) {
                 throw new GeneralExceptionWS(-10, "UTENTE NON TROVATO PER IL PARAMETRO utenteCreazione: " + parametriIngresso.utenteCreazione)
             }
         }

         //provo a protocollare
         try{
             protocolloService.protocolla(protocollo, true, true, utenteCreazione)
         }
         catch (Exception e) {
             throw new GeneralExceptionWS(-2, "ERRORE IN PROTOCOLLAZIONE." + e.getMessage())
         }

         parametriUscita.oggetto = protocollo.oggetto
         parametriUscita.anno = protocollo.anno.toString()
         parametriUscita.numero = protocollo.numero.toString()
         parametriUscita.registro = protocollo.tipoRegistro.codice
         DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
         parametriUscita.data = format.format(protocollo.data)

        logger.info("Protocollato con: " + "Anno :" + parametriUscita.anno + "\n Numero: " + parametriUscita.numero + "\n Data: " + parametriUscita.data + "\n Registro: " + parametriUscita.registro + "\n Oggetto: " + parametriUscita.oggetto)

     }
}
