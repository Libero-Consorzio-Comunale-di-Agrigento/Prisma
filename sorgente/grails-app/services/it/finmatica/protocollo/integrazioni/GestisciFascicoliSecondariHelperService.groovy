package it.finmatica.protocollo.integrazioni

import groovy.util.logging.Slf4j
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.ParametriIngresso
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.ParametriUscita
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloWS
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.ws.exception.GeneralExceptionWS
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import org.apache.commons.lang.StringUtils
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
@Slf4j
class GestisciFascicoliSecondariHelperService {

    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService
    @Autowired
    FascicoloService fascicoloService
    @Autowired
    TitolarioService titolarioService

    private static final Logger logger = Logger.getLogger(GestisciFascicoliSecondariHelperService.class)

    ParametriUscita aggiungiFascicoliSecondari(ParametriIngresso parametriIngresso) {
        ParametriUscita ret = new ParametriUscita()
        // Setta il parametro di ritorno a OK
        ret.codice = 0
        try {
            aggiungiFascicoliSecondariInterna(parametriIngresso)
        } catch (GeneralExceptionWS e) {
            // Rilevo il codice e descrizione dell'errore e lo setto sul parametro di uscita
            ret.codice = e.codice
            ret.descrizione = e.descrizione
            logger.error(e.getCodice()+ ": "+e.getDescrizione())
        }
        logger.info(ret.getCodice()+ ": "+ ret.getDescrizione())
        return ret
    }

    private void aggiungiFascicoliSecondariInterna(ParametriIngresso parametriIngresso) throws GeneralExceptionWS {

        //verifica paramertiIngresso non nullo
        if(parametriIngresso == null) {
            throw new GeneralExceptionWS(-1, "PARAMETRI IN INGRESSO MANCANTI")
        }

        if(! StringUtils.isNotBlank(parametriIngresso.iddocumento) || parametriIngresso.iddocumento == "") {
            throw new GeneralExceptionWS(-1, "PARAMETRO MANCANTE ID DOCUMENTO")
        }

        if(parametriIngresso.fascicoliSecondari == null || parametriIngresso.fascicoliSecondari.item == null || parametriIngresso.fascicoliSecondari.item.isEmpty()) {
            throw new GeneralExceptionWS(-1, "PARAMETRO MANCANTE LISTA FASCICOLI SECONDARI")
        }

        //Cosa deve accadere per i doc "esterni" (contratti , determine , delibere..etc) ? attualmente aggiungo anche questi a fascicoli secondari

        Protocollo protocollo
        ProtocolloWS protocolloWS = protocolloWSUtilityService.estraiDocumentoDaProtocolloWS(new Long (parametriIngresso.iddocumento), null, null, null)
        if(protocolloWS) {
            protocollo = protocolloWSUtilityService.completaDatiPerDocumento(protocolloWS)
            if(!protocollo) {
                throw new GeneralExceptionWS(-1, "Protocollo non trovato")
            }
        } else {
            throw new GeneralExceptionWS(-1, "Documento non trovato in AGP_WS_PROTOCOLLI")
        }

        List<it.finmatica.affarigenerali.ducd.fascicoliSecondari.Fascicolo> fascicoliNonPresentiASistema = new ArrayList<it.finmatica.affarigenerali.ducd.fascicoliSecondari.Fascicolo>()
        List<Fascicolo> fascicoliValidi = new ArrayList<Fascicolo>()
        for (it.finmatica.affarigenerali.ducd.fascicoliSecondari.Fascicolo fascicoloSecondario : parametriIngresso.fascicoliSecondari.item) {

            //Devo verificare l'esistenza dei fascicoli
            it.finmatica.affarigenerali.ducd.fascicoliSecondari.Fascicolo fasc = fascicoloSecondario

            Ente ente = protocolloWSUtilityService.getEnteFascicoliSecondari(fasc.codiceAmm, fasc.codiceAoo)

            if(!ente) {
                throw new GeneralExceptionWS(-1, "Non è stato trovato nessun ente. Verificare i parametri codiceAMM e codiceA00")
            }

            Fascicolo fascicolo = fascicoloService.getFascicoloPerWsFascicoliSecondari(fasc.classifica, fasc.anno, fasc.progressivo, ente?.id)

            if(!fascicolo) {
                fascicoliNonPresentiASistema.add(fasc)
            } else {
                fascicoliValidi.add(fascicolo)
            }
        }

        if(!fascicoliNonPresentiASistema.isEmpty()) {
            String msg = ""
            for(it.finmatica.affarigenerali.ducd.fascicoliSecondari.Fascicolo fascNonPresente : fascicoliNonPresentiASistema) {
                msg = msg + "Codice classifica: " + fascNonPresente.classifica + " Anno Fascicolo: " + fascNonPresente.anno.toString() + " Numero Fascicolo: " + fascNonPresente.progressivo + "\n"
            }
            throw new GeneralExceptionWS(-1, "Non sono stati trovati i seguenti fascicoli:" + msg)
        }

        //Se i parametri di ingresso sono validi e ho trovato il documento nella vista procedo con l'aggiunta in fascicoli secondari
        for(Fascicolo fasc : fascicoliValidi) {

            Fascicolo fascicolo = fasc
            Classificazione classificazione = fasc.classificazione
            DocumentoTitolario documentoTitolario = new DocumentoTitolario(fascicolo: fascicolo, classificazione: classificazione, documento: protocollo)

            //salva solo se non è già presente, altrimenti procedo nell'iterazione
            if(! esisteFascicoloSecondario(protocollo, documentoTitolario)) {
                titolarioService.salva(protocollo, [documentoTitolario.toDTO()])
            }
        }
    }

    /**
     * Verifica se esiste un fascicolo secondario associato al protocollo il confronto avviene per chiave di unicità
     *
     * @param protocollo
     * @param documentoTitolario
     * @return
     */
    private boolean esisteFascicoloSecondario(Protocollo protocollo, DocumentoTitolario documentoTitolario) {
        boolean presente = false
        for(DocumentoTitolario docTit : protocollo.titolari) {

            if(docTit.documento == documentoTitolario.documento &&
                docTit.fascicolo == documentoTitolario.fascicolo &&
                docTit.classificazione == documentoTitolario.classificazione) {

                presente = true
                break
            }

        }
        return  presente
    }

}
