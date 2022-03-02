package it.finmatica.protocollo.emergenza

import groovy.util.logging.Slf4j
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.as4.As4Repository
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.struttura.So4Ottica
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

//@CompileStatic
@Slf4j
@Transactional
@Service
class ValidazioneProtocolloEmergenzaService {

    @Autowired
    ProtocolloService protocolloSerice
    @Autowired
    So4Repository so4Repository
    @Autowired
    As4Repository as4Repository
    @Autowired
    ClassificazioneRepository classificazioneRepository
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    ProtocolloRepository protocolloRepository

    boolean validazione(def recordXml) {

        if (recordXml.unita.toString().size() > 0) {
            if (isUnitaValida(recordXml.unita.toString(), recordXml.ottica.toString()) == false) {
                return false
            }
        }

        if (recordXml.codiceTipoDocumento.toString().size() > 0 && recordXml.codiceTipoDocumento.toString() != "null") {
            if (isTipoDocumentoValido(recordXml.codiceTipoDocumento.toString()) == false) {
                return false
            }
        }

        if (recordXml.codiceModRic.toString().size() > 0) {
            if (isModalitaRicevimentoValida(recordXml.codiceModRic.toString()) == false) {
                return false
            }
        }

        if (recordXml.codiceClassificazione.toString().size() > 0 && recordXml.codiceClassificazione.toString() != "null") {
            if (isClassificazioneValida(recordXml.codiceClassificazione.toString()) == false) {
                return false
            }
        }

        if (recordXml.codiceUnitaSmistamento.toString().size() > 0) {
            if (isUnitaValida(recordXml.codiceUnitaSmistamento.toString(), recordXml.ottica.toString()) == false) {
                return false
            }
        }

        // i controlli sulla AOO non vengono più eseguiti
        /*
        if (recordXml.mittDest == "A" && recordXml.cognomeCodAmm.toString().size() > 0) {
            if (isAmministrazioneValida(recordXml.cognomeCodAmm.toString()) == false) {
                return false
            }
        }

        if (recordXml.mittDest == "A" && recordXml.nomeCodAoo.toString().size() > 0) {
            if (isAooValida(recordXml.nomeCodAoo.toString(), recordXml.cognomeCodAmm.toString()) == false) {
                return false
            }
        }
        */

        if (recordXml.soggettoUtenteAssegnatario.toString().size() > 0) {
            if (isComponenteValido(recordXml.soggettoUtenteAssegnatario.toString(), recordXml.ottica.toString()) == false) {
                return false
            }
        }

        if (recordXml.fascicoloAnno.toString().size() > 0 && recordXml.fascicoloNumero.toString().size() > 0 && recordXml.codiceClassificazione.toString().size() > 0) {
            if (isFascicoloValido(recordXml.codiceClassificazione.toString(), recordXml.fascicoloAnno.toString(), recordXml.fascicoloNumero.toString()) == false) {
                return false
            }
        }

        return true
    }

    boolean datiObbligatoriPerProtocolloEmergenza(def recordXml) {

        if (ImpostazioniProtocollo.TIPO_DOC_OB.abilitato && (recordXml.codiceTipoDocumento.toString().size() == 0 || recordXml.codiceTipoDocumento.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.CLASS_OB.abilitato && (recordXml.codiceClassificazione.toString().size() == 0 || recordXml.codiceClassificazione.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.OGG_OB.abilitato && (recordXml.oggetto.toString().size() == 0 || recordXml.oggetto.toString() == "null")) {
            return false
        }

        //if (ImpostazioniProtocollo.RAPP_OB.abilitato) {
        //    return false
        //}

        boolean fascicoloObbligatorio = false
        if (ImpostazioniProtocollo.FASC_OB.valore == "PAR") {
            fascicoloObbligatorio = true // essendo il protocollo interno
        } else {
            fascicoloObbligatorio = ImpostazioniProtocollo.FASC_OB.abilitato
        }

        if (fascicoloObbligatorio && (recordXml.fascicoloAnno.toString().size() == 0 || recordXml.fascicoloAnno.toString() == "null")) {
            return false
        }
        if (fascicoloObbligatorio && (recordXml.fascicoloNumero.toString().size() == 0 || recordXml.fascicoloNumero.toString() == "null")) {
            return false
        }

        //if (ImpostazioniProtocollo.SMIST_INT_OB.abilitato && recordXml.tipoMovimento.toString() == "Interno" ) {
        //    return false
        //}
        //if (ImpostazioniProtocollo.ITER_FASC_SMIST_OB.abilitato) {
        //    return false
        //}

        return true
    }

    boolean datiObbligatoriPerProtocollo(def recordXml) {

        if (ImpostazioniProtocollo.TIPO_DOC_OB.abilitato && (recordXml.codiceTipoDocumento.toString().size() == 0 || recordXml.codiceTipoDocumento.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.CLASS_OB.abilitato && (recordXml.codiceClassificazione.toString().size() == 0 || recordXml.codiceClassificazione.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.OGG_OB.abilitato && (recordXml.oggetto.toString().size() == 0 || recordXml.oggetto.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.RAPP_OB.abilitato && (recordXml.cognomeCodAmm.toString().size() == 0 || recordXml.cognomeCodAmm.toString() == "null")) {
            return false
        }

        boolean fascicoloObbligatorio = false
        if (ImpostazioniProtocollo.FASC_OB.valore == "PAR") {
            if (recordXml.tipoMovimento.toString().toUpperCase() == Protocollo.MOVIMENTO_PARTENZA || recordXml.tipoMovimento.toString().toUpperCase() == Protocollo.MOVIMENTO_INTERNO) {
                fascicoloObbligatorio = true
            } else {
                fascicoloObbligatorio = false
            }
        } else {
            fascicoloObbligatorio = ImpostazioniProtocollo.FASC_OB.abilitato
        }
        if (fascicoloObbligatorio && (recordXml.fascicoloAnno.toString().size() == 0 || recordXml.fascicoloAnno.toString() == "null")) {
            return false
        }
        if (fascicoloObbligatorio && (recordXml.fascicoloNumero.toString().size() == 0 || recordXml.fascicoloNumero.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.TRAMITE_ARR_OB.abilitato && recordXml.tipoMovimento.toString() == "Arrivo" && (recordXml.codiceModRic.toString().size() == 0 || recordXml.codiceModRic.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.DATA_ARRIVO_OB.abilitato && recordXml.tipoMovimento.toString() == "Arrivo" && (recordXml.dataArrivoSpedizione.toString().size() == 0 || recordXml.dataArrivoSpedizione.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.SMIST_ARR_OB.abilitato && recordXml.tipoMovimento.toString() == "Arrivo" && (recordXml.codiceUnitaSmistamento.toString().size() == 0 || recordXml.codiceUnitaSmistamento.toString() == "null")) {
            return false
        }
        if (ImpostazioniProtocollo.SMIST_INT_OB.abilitato && recordXml.tipoMovimento.toString() == "Interno" && (recordXml.codiceUnitaSmistamento.toString().size() == 0 || recordXml.codiceUnitaSmistamento.toString() == "null")) {
            return false
        }
        if (ImpostazioniProtocollo.SMIST_PAR_OB.abilitato && recordXml.tipoMovimento.toString() == "Partenza" && (recordXml.codiceUnitaSmistamento.toString().size() == 0 || recordXml.codiceUnitaSmistamento.toString() == "null")) {
            return false
        }

        if (ImpostazioniProtocollo.ITER_FASC_SMIST_OB.abilitato && (recordXml.codiceUnitaSmistamento.toString().size() == 0 || recordXml.codiceUnitaSmistamento.toString() == "null")) {
            return false
        }

        return true
    }

    /* viene verificata che l'unità passata è valida e presente */

    boolean isUnitaValida(String progressivo, String codiceOttica) {
        List<So4UnitaPubb> unitaPubbList = so4Repository.getListUnita(progressivo.toLong(), codiceOttica, new Date())
        return unitaPubbList.size() > 0
    }

    /* viene verificato che il tipo documento passato è presente */

    boolean isTipoDocumentoValido(String codiceTipoDocumento) {
        SchemaProtocollo schemaProtocollo = dizionariRepository.getSchemaProtocollo(codiceTipoDocumento)
        return (schemaProtocollo != null) ? true : false
    }

    /* viene verificata che la classifica passata è valida e presente */

    boolean isClassificazioneValida(String classifica) {
        List<Classificazione> classificazioneList = classificazioneRepository.getListClassificazioneValida(classifica.toLong())
        return classificazioneList.size() > 0
    }

    /* viene verificata che il fascicolo passato sia presente */

    boolean isFascicoloValido(String classifica, String fascicoloAnno, String fascicoloNumero) {
        List<Fascicolo> fascicoloList = fascicoloRepository.getListFascicolo(classifica.toLong(), fascicoloAnno.toInteger(), fascicoloNumero)
        return fascicoloList.size() > 0
    }

    /* viene verificata che la modalità invio ricezione sia presente */

    boolean isModalitaRicevimentoValida(String modalitaRicevimento) {
        ModalitaInvioRicezione modalitaInvioRicezione = dizionariRepository.getModalitaInvioRicezione(modalitaRicevimento)
        return (modalitaInvioRicezione != null) ? true : false
    }

    /* viene verificata che l'amministrazione passata sia valida e presente */

    boolean isAmministrazioneValida(String amm) {
        List<So4Amministrazione> so4AmministrazioneList = so4Repository.getListAmministrazione(amm)
        return so4AmministrazioneList.size() > 0
    }

    /* viene verificata che la AOO passata sia valida e presente */

    boolean isAooValida(String aoo, String amm) {
        List<So4AOO> so4AooList = so4Repository.getListAoo(aoo, amm)
        return so4AooList.size() > 0
    }

    /* viene verificato che il componente passato sia valida e presente */

    boolean isComponenteValido(String idSoggetto, String ottica) {
        As4SoggettoCorrente soggettoCorrente = as4Repository.getSoggettoCorrente(idSoggetto.toLong())
        So4Ottica so4Ottica = so4Repository.getOttica(ottica)
        List<So4ComponentePubb> componentePubbList = so4Repository.getListComponente(soggettoCorrente, so4Ottica, new Date())
        return componentePubbList.size() > 0
    }

    Protocollo getProtocolloEmergenza(def recordXml) {
        Protocollo protocollo = protocolloRepository.getProtocolloDatiEmergenza(new Date().parse("yyyy-M-d H:m:s", recordXml.dataInizio.toString()), new Date().parse("yyyy-M-d H:m:s", recordXml.dataFine.toString()))

        if (protocollo?.numero) {
            return protocollo
        } else {
            return null
        }
    }

    /* viene verificato se esiste già un protocollo per anno, numero e registro di emergenza */

    boolean verificaEsistenzaProtocollo(def recordXml) {
        Protocollo protocollo = protocolloRepository.getProtocolloEmergenza(recordXml.numero.toInteger(), recordXml.anno.toInteger(), recordXml.codiceRegistro.toString())
        return (protocollo) ? true : false
    }

    boolean verificaPresenzaNumerazione(String xml) {
        boolean presenza = false

        def root = new XmlSlurper().parseText(xml)
        root.protocolli.protocollo.each {
            if (verificaEsistenzaProtocollo(it)) {
                presenza = true
            }
        }

        return presenza
    }
}