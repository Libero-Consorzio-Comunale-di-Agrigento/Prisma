package it.finmatica.protocollo.integrazioni

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.ParametriIngresso
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.ParametriUscita
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.protocollo.ws.exception.ClassificazioneWSException
import it.finmatica.protocollo.ws.exception.FascicoloWSException
import it.finmatica.protocollo.ws.exception.GeneralExceptionWS
import it.finmatica.protocollo.ws.exception.ParametroMancanteException
import it.finmatica.protocollo.ws.exception.UnitaOrganizzativaWSException
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
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
class InserisciInTitolarioHelperService {

    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService
    @Autowired
    FascicoloService fascicoloService
    @Autowired
    TipologiaSoggettoService tipologiaSoggettoService
    @Autowired
    ProtocolloService protocolloService

    private static final Logger logger = Logger.getLogger(InserisciInTitolarioHelperService.class)

    ParametriUscita aggiungiAFascicolo(ParametriIngresso parametriIngresso) {
        ParametriUscita ret = new ParametriUscita()
        // Setta il parametro di ritorno a OK
        ret.codice = 0
        try {
            String fascicoloNumero = aggiungiAFascicoloX(parametriIngresso, false)
            ret.descrizione = fascicoloNumero
        } catch (GeneralExceptionWS e) {
            // Rilevo il codice e descrizione dell'errore e lo setto sul parametro di uscita
            ret.codice = e.codice
            ret.descrizione = e.descrizione
            logger.error(e.getCodice()+ ": "+e.getDescrizione())
        }
        logger.info(ret.getCodice()+ ": "+ ret.getDescrizione())
        return ret
    }

    ParametriUscita creaFascicolo(ParametriIngresso parametriIngresso) {
        ParametriUscita ret = new ParametriUscita()
        // Setta il parametro di ritorno a OK
        ret.codice = 0
        try {
            String fascicoloNumero = aggiungiAFascicoloX(parametriIngresso, true)
            ret.descrizione = fascicoloNumero
        } catch (GeneralExceptionWS e) {
            // Rilevo il codice e descrizione dell'errore e lo setto sul parametro di uscita
            ret.codice = e.codice
            ret.descrizione = e.descrizione
            logger.error(e.getCodice()+ ": "+e.getDescrizione())
        }
        logger.info(ret.getCodice()+ ": "+ ret.getDescrizione())
        return ret
    }


    private String aggiungiAFascicoloX(ParametriIngresso parametriIngresso, boolean bOnlyCreaFasc) throws GeneralExceptionWS {

        //verifica paramertiIngresso non nullo
        if(parametriIngresso == null) {
            throw new GeneralExceptionWS(-1, "PARAMETRI IN INGRESSO MANCANTI")
        }

        //leggo parametro crea
        String creaFascicolo = ImpostazioniProtocollo.CREA_FASCICOLO_DA_WS.valore

        //Recupera i dati dell'utente
        Ad4Utente utenteCreazione
        if(parametriIngresso.utenteCreazione != "" && StringUtils.isNotBlank(parametriIngresso.utenteCreazione)){
            utenteCreazione = Ad4Utente.findByUtente(parametriIngresso.utenteCreazione)
            if(utenteCreazione == null) {
                throw new GeneralExceptionWS(-2, "UTENTE NON TROVATO ")
            }
        } else {
            throw new GeneralExceptionWS(-1, "PARAMETRO UTENTE_CREAZIONE MANCANTE")
        }

        Fascicolo fascicolo
        Classificazione classificazione

        //Controllo se esiste classifica
        if( StringUtils.isNotBlank(parametriIngresso.classificazione) || parametriIngresso.classificazione != "") {
            //La classifica valida per un dato codice dovrebbe essere solo una. Gestisco cmq il caso in cui possano essercene piu' di una , in questo caso genero un'eccezione
            List<Classificazione> classificazioni = protocolloWSUtilityService.getListClassificazioneValidaByCodice(parametriIngresso.classificazione)
            if(classificazioni == null || classificazioni.size() <= 0) {
                throw new ClassificazioneWSException(-1, "CLASSIFICA NON ESISTENTE")
            }
            if(classificazioni.size() > 1) {
                throw new ClassificazioneWSException(-1, "SONO PRESENTI PIU' CLASSIFICHE VALIDE CON LO STESSO CODICE")
            } else {
                classificazione = classificazioni.get(0)
            }
        } else {
            throw new ParametroMancanteException(-2, "PARAMETRO CLASSIFICAZIONE MANCANTE")
        }

        //Controllo esistenza unita' e se aperta
        So4UnitaPubb uo
        if(creaFascicolo == "Y") {
            if(parametriIngresso.ufficioCompetenza != "" && StringUtils.isNotBlank(parametriIngresso.ufficioCompetenza)) {
                uo = protocolloWSUtilityService.getUnitaByCodiceSenzaControlloValiditaSo4(parametriIngresso.ufficioCompetenza)
                if(uo == null) {
                    throw new UnitaOrganizzativaWSException(-8,"UNITA NON ESISTENTE.")
                }
                else if(uo != null && uo.al != null && uo.al.before(new Date().clearTime())){
                    throw new UnitaOrganizzativaWSException(-9,"UNITA ESISTENTE CHIUSA.")
                }
            } else {
                throw new ParametroMancanteException(-1, "PARAMETRO UFFICIO_COMPETENZA MANCANTE")
            }
        }

        //controllo parametro data apertura se nullo imposto oggi
        if( ! StringUtils.isNotBlank(parametriIngresso.dataApertura) || parametriIngresso.dataApertura == ""){
            DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
            parametriIngresso.dataApertura = format.format(new Date().clearTime())
        }

        Fascicolo fascicoloPadre

        if(parametriIngresso.fascicoloAnno > 0){
            List<Fascicolo> fascicoli = protocolloWSUtilityService.getFascicoloValido(classificazione.id, parametriIngresso.fascicoloAnno.toInteger(), parametriIngresso.fascicoloNumero)
            if(null == fascicoli || fascicoli.size() <= 0) {
                //se non trovo fascicoli verifico se posso crearlo
                if(creaFascicolo != "Y"){
                    throw new FascicoloWSException(-4,"FASCICOLO NON ESISTENTE, DIVIETO DI CREAZIONE.")
                } else if (! privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.CREF, utenteCreazione)) {
                    throw new FascicoloWSException(-5, "FASCICOLO NON CREATO. L'UTENTE NON DISPONE DEI DIRITTI NECESSARI PER LA CREAZIONE DEL FASCICOLO")
                } else {
                    if(parametriIngresso.fascicoloOggetto != "" || StringUtils.isNotBlank(parametriIngresso.fascicoloOggetto) ||
                       parametriIngresso.dataApertura != "" || StringUtils.isNotBlank(parametriIngresso.dataApertura) ) {
                        //Verifico il padre
                        if(StringUtils.isNotBlank(parametriIngresso.fascicoloNumeroPadre) || parametriIngresso.fascicoloNumeroPadre != "" ) {
                            List<Fascicolo> fascicoliPadre = protocolloWSUtilityService.getFascicoloValido(classificazione.id, parametriIngresso.fascicoloAnno.toInteger(), parametriIngresso.fascicoloNumeroPadre)
                            if(null == fascicoliPadre || fascicoliPadre.size() <= 0) {
                                throw new FascicoloWSException( -4 , "FASCICOLO PADRE NON TROVATO CON NUMERO " + parametriIngresso.fascicoloNumeroPadre )
                            } else if ( fascicoliPadre.size() > 1 ) {
                                throw new FascicoloWSException( -5 , "TROVATI PIU' FASCICOLI PADRE CON NUMERO " + parametriIngresso.fascicoloNumeroPadre )
                            } else {
                                try {
                                    fascicoloPadre = fascicoliPadre.get(0)
                                    //PROVO A CREARE IL FASCICOLO
                                    logger.info("CERCO DI CREARE IL FASCICOLO")
                                    logger.info("CERCO DI INSERIRLO NEL PADRE :"+ parametriIngresso.fascicoloNumeroPadre)
                                    fascicolo = creaFascicoloDaWs(parametriIngresso, classificazione, fascicoloPadre, uo, utenteCreazione)
                                } catch ( Exception e) {
                                    throw new GeneralExceptionWS( -1 , "ERRORE IN CREAZIONE FASCICOLO " + e.getMessage())
                                }
                            }
                        }
                        else {
                            //Nessun padre nei parametri di input...inserisco senza padre (in zk posso farlo)
                            logger.info("Creazione fascicolo senza padre")
                            try{
                                fascicolo = creaFascicoloDaWs(parametriIngresso, classificazione, null, uo, utenteCreazione)
                            } catch (Exception e ){
                                throw new GeneralExceptionWS(-1, "ERRORE IN CREAZIONE FASCICOLO " + e.getMessage())
                            }
                        }
                    } else {
                        throw new ParametroMancanteException(-2, "PARAMETRO MANCANTE. FASCICOLO_OGGETTO E/O DATA APERTURA")
                    }
                }
            } else if(fascicoli.size() > 1){
                throw new FascicoloWSException(-6, "SONO STATI TROVATI PIU' FASCICOLI VALIDI CON STESSO ANNO E NUMERO")
            } else {
                fascicolo = fascicoli.get(0)
            }
        } else {
            throw new ParametroMancanteException(-2, "PARAMETRO MANCANTE: FASCICOLO ANNO")
        }


        //QUESTA PARTE VIENE ESEGUITA SOLO SE DEVO ASSOCIARE IL FASCICOLO CON UN PROTOCOLLO
        if (!bOnlyCreaFasc) {
            //Se ho i parametri per aggiungerlo ad un protocollo, allora interrogo AGP_WS_PROTOCOLLO
            if ((parametriIngresso.idDocumento == 0 && (parametriIngresso.anno == 0 || parametriIngresso.numero == 0))) {
                throw new GeneralExceptionWS(-1, "Passare almeno anno/numero oppure id documento")
            }

            Protocollo protocollo = protocolloWSUtilityService.estraiProtoccoloDaProtocolloWS(new Long(parametriIngresso.idDocumento),
                    parametriIngresso.anno != 0 ? Integer.valueOf(parametriIngresso.anno) : null,
                    parametriIngresso.numero != 0 ? Integer.valueOf(parametriIngresso.numero) : null, parametriIngresso.registro)

            if (protocollo) {
                try {
                    //La classifica la sovrascrivo con la nuova derivante dai parametri di input
                    protocollo = fascicoloService.associaClassificaEFascicoloAProtocollo(protocollo.id, classificazione, fascicolo)
                } catch (Exception e) {
                    throw new GeneralExceptionWS(-7, "INSERIMENTO IN TITOLARIO NON RIUSCITO." + e.getMessage())
                }
            } else {
                throw new GeneralExceptionWS(-1, "PROTOCOLLO NON TROVATO :" + parametriIngresso.idDocumento, " ANNO: " + parametriIngresso.anno + " NUMERO: " + parametriIngresso.numero + " REGISTRO: " + parametriIngresso.registro);
            }
        }

        return fascicolo.numero ?: "0"

    }

    private Fascicolo creaFascicoloDaWs(ParametriIngresso parametriIngresso, Classificazione classificazione, Fascicolo fascicoloPadre, So4UnitaPubb uo, Ad4Utente utente) {

        Fascicolo fascicoloDaCreare = new Fascicolo()
        fascicoloDaCreare.numero = parametriIngresso.fascicoloNumero
        fascicoloDaCreare.classificazione = classificazione
        fascicoloDaCreare.anno = parametriIngresso.fascicoloAnno
        if(fascicoloPadre) {
            fascicoloDaCreare.idFascicoloPadre = fascicoloPadre.id
        }
        fascicoloDaCreare.dataApertura = new Date().parse('dd/MM/yyyy', parametriIngresso.dataApertura)
        fascicoloDaCreare.dataCreazione = new Date().clearTime()
        fascicoloDaCreare.oggetto = parametriIngresso.fascicoloOggetto
        //Aggiungi soggetti
        Map soggetti = [:]
        soggetti = tipologiaSoggettoService.calcolaSoggetti(fascicoloDaCreare,  fascicoloService.getTipologia())
        soggetti?.UO_CREAZIONE?.unita = uo.toDTO()
        soggetti?.UO_COMPETENZA?.unita = uo.toDTO()

        return fascicoloService.salva(fascicoloDaCreare.toDTO() as FascicoloDTO, soggetti, null, true, false,  [],true, utente)?.domainObject

    }
}
