package it.finmatica.protocollo.scaricoipa

import groovy.util.logging.Slf4j
import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Regione
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.anagrafica.As4Anagrafica
import it.finmatica.as4.anagrafica.As4AnagraficaService
import it.finmatica.as4.anagrafica.As4Contatto
import it.finmatica.as4.anagrafica.As4ContattoService
import it.finmatica.as4.anagrafica.As4Recapito
import it.finmatica.as4.anagrafica.As4RecapitoService
import it.finmatica.as4.dizionari.As4TipoContatto
import it.finmatica.as4.dizionari.As4TipoRecapito
import it.finmatica.as4.dizionari.As4TipoSoggetto
import it.finmatica.protocollo.integrazioni.So4UnitaBase
import it.finmatica.protocollo.integrazioni.ad4.Ad4ComuniProvincieRegioniRepository
import it.finmatica.protocollo.integrazioni.ad4.Ad4Repository
import it.finmatica.protocollo.integrazioni.as4.As4Repository
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.struttura.So4Ottica
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.hibernate.SessionFactory

import java.text.SimpleDateFormat

@Transactional
@Service
@Slf4j
class ScaricoIpaService {

    @Autowired
    As4AnagraficaService as4AnagraficaService
    @Autowired
    As4RecapitoService as4RecapitoService
    @Autowired
    As4ContattoService as4ContattoService
    @Autowired
    So4IpaService so4IpaService
    @Autowired
    So4Repository so4Repository
    @Autowired
    As4Repository as4Repository
    @Autowired
    Ad4Repository ad4Repository
    @Autowired
    Ad4ComuniProvincieRegioniRepository ad4ComuniProvincieRegioniRepository
    @Autowired
    As4IpaService as4IpaService

    private final SessionFactory sessionFactory

    List listaDescrizioneTipologiaAmm = []

    public static final String URL_INDICEIPA_AMM = "https://www.indicepa.gov.it/public-services/opendata-read-service.php?dstype=FS&filename=amministrazioni.txt"
    public static final String URL_INDICEIPA_AOO = "https://www.indicepa.gov.it/public-services/opendata-read-service.php?dstype=FS&filename=aoo.txt"
    public static final String URL_INDICEIPA_UO = "https://www.indicepa.gov.it/public-services/opendata-read-service.php?dstype=FS&filename=ou.txt"
    public static final String URL_INDICEIPA_CFSFE = "https://www.indicepa.gov.it/public-services/opendata-read-service.php?dstype=FS&filename=serv_fatt.txt"

    public static final String URLAMM = "ulrAmministrazioni"
    public static final String URLAOO = "ulrAoo"
    public static final String URLUO = "ulrOu"

    public static final String TIPOLOGIA_AMM = "AMM"
    public static final String TIPOLOGIA_AOO = "AOO"
    public static final String TIPOLOGIA_UO = "UO"

    public static final String VALORE_COMPETENZA = "SI4SO"
    public static final String VALORE_COMPETENZA_ESCLUSIVA = "E"

    public static final String OTTICA_EXTRAISTITUZIONALE = "EXTRAISTITUZIONALE"

    public static final int L_CF_AMM = 11
    public static final int L_FAX = 14
    public static final int L_CAP = 5
    public static final int L_TEL = 14
    public static final int L_INDIRIZZO = 40

    void scaricoIpa(String fileIpa, ScaricoIpaFilter filterForm) {
        def data
        def dataCFSFE
        So4Ottica ottica = so4Repository.getOttica(OTTICA_EXTRAISTITUZIONALE)

        switch (fileIpa) {
            case URLAMM:
                data = new URL(URL_INDICEIPA_AMM).text
                extractionTracedAmm(data, filterForm)
                break;
            case URLAOO:
                data = new URL(URL_INDICEIPA_AOO).text
                extractionTracedAoo(data, filterForm)
                break;
            case URLUO:
                data = new URL(URL_INDICEIPA_UO).text
                //dataCFSFE = new URL(URL_INDICEIPA_CFSFE).text
                extractionTracedOu(data, filterForm, ottica)
                break;
            default:
                break;
        }
    }

    void extractionTracedAmm(def data, ScaricoIpaFilter filterForm) {
        log.info("inizio estrazione AMM")
        def cont = 0

        data.eachLine { it, count ->

            if (count > 0) {
                //if (count >= 4793 && count <= 4793) {
                String[] columnDetail = new String[11];
                columnDetail = it.split("\t");
                ScaricoIpaFilter record = new ScaricoIpaFilter()
                record.setCodiceAmministrazione(columnDetail[0].toUpperCase().trim())
                record.setDescrizione(columnDetail[1].toUpperCase().trim())
                record.setIndirizzo(columnDetail[9].toUpperCase().trim())
                record.setCap(columnDetail[5].toUpperCase().trim())
                record.setCitta(columnDetail[2].toUpperCase().trim())
                record.setProvincia(columnDetail[6].toUpperCase().trim())
                record.setRegione(columnDetail[7].toUpperCase().trim())
                record.setCognomeResponsabile(columnDetail[4].toUpperCase().trim())
                record.setNomeResponsabile(columnDetail[3].toUpperCase().trim())
                record.setTitoloResp(columnDetail[10].toUpperCase().trim())
                record.setMail((columnDetail[17].toUpperCase().trim() == "PEC") ? columnDetail[16].toUpperCase().trim() : ((columnDetail[19].toUpperCase().trim() == "PEC") ? columnDetail[18].toUpperCase().trim() : ((columnDetail[21].toUpperCase().trim() == "PEC") ? columnDetail[20].toUpperCase().trim() : ((columnDetail[23].toUpperCase().trim() == "PEC") ? columnDetail[22].toUpperCase().trim() : ((columnDetail[25].toUpperCase().trim() == "PEC") ? columnDetail[24].toUpperCase().trim() : columnDetail[16].toUpperCase().trim())))))
                record.setSito(columnDetail[8].toUpperCase().trim())
                record.setCodiceFiscaleAmm(columnDetail[15].toUpperCase().trim())
                record.setCompetenzaEsclusiva(VALORE_COMPETENZA_ESCLUSIVA)
                record.setCompetenza(VALORE_COMPETENZA)
                record.setUtenteAggiornamento((filterForm?.utenteAggiornamento) ? filterForm?.utenteAggiornamento : "RPI")
                record.setDataAggiornamento(filterForm?.dataAggiornamento)
                record.setDataSoppressione(null)
                record.setTipologiaEnte(columnDetail[11].toUpperCase().trim())
                record.setCodiceFiscaleAmm((record?.codiceFiscaleAmm.length() > L_CF_AMM) ? "" : record.codiceFiscaleAmm)
                record.setFax("")
                record.setTelefono("")
                record.setCap((record?.cap.length() > L_CAP) ? "" : record.cap)
                record.setFax((record?.fax.length() > L_FAX) ? "" : record.fax)
                record.setTelefono((record?.telefono.length() > L_TEL) ? "" : record.telefono)
                record.setIndirizzo((record?.indirizzo.length() > L_INDIRIZZO) ? record.indirizzo.substring(0, L_INDIRIZZO) : record.indirizzo)

                if (record?.getProvincia() != null) {
                    if (record.getProvincia() == "BO") {
                        record.setRegione("PROV.AUT. BOLZANO")
                    }
                    if (record.getProvincia() == "TN") {
                        record.setRegione("PROV.AUT. TRENTO")
                    }
                }
                record.setAd4Provincia(null)
                record.setAd4Comune(null)

                listaDescrizioneTipologiaAmm << new DescrizioneTipologiaEnteAmministrazioni(columnDetail[0].toUpperCase().trim(), columnDetail[1].toUpperCase().trim(), columnDetail[11].toUpperCase().trim())

                if (valideCondition(record, filterForm, TIPOLOGIA_AMM)) {
                    Ad4Regione ad4Regione = ad4ComuniProvincieRegioniRepository.getRegione(record?.regione)
                    Ad4Comune ad4Comune = ad4ComuniProvincieRegioniRepository.getComune(record?.citta, ad4Regione)[0]
                    if (ad4Comune) {
                        record.setAd4Provincia(ad4Comune.provincia)
                        record.setAd4Comune(ad4Comune)
                    }
                    record.setAd4UtenteAgg(ad4Repository.getUtente(filterForm?.utenteAggiornamento))

                    insertAmm(record)
                }

                record = null
            }
        }
        log.info("fine estrazione AMM")
    }

    void extractionTracedAoo(def data, ScaricoIpaFilter filterForm) {
        log.info("inizio estrazione AOO")
        def cont = 0

        data.eachLine { it, count ->

            if (count > 0) {
                String[] columnDetail = new String[11];
                columnDetail = it.split("\t");

                ScaricoIpaFilter record = new ScaricoIpaFilter()
                record.setCodiceAmministrazione(columnDetail[0].toUpperCase().trim())
                record.setCodiceAoo(columnDetail[1].toUpperCase().trim())
                record.setDescrizione(columnDetail[2].toUpperCase().trim())
                record.setIndirizzo(columnDetail[8].toUpperCase().trim())
                record.setCap(columnDetail[5].toUpperCase().trim())
                record.setCitta(columnDetail[4].toUpperCase().trim())
                record.setProvincia(columnDetail[6].toUpperCase().trim())
                record.setSito("")
                record.setTelefono(columnDetail[9].toUpperCase().trim())
                record.setFax(columnDetail[14].toUpperCase().trim())
                record.setMail((columnDetail[16].toUpperCase().trim() == "PEC") ? columnDetail[15].toUpperCase().trim() : ((columnDetail[18].toUpperCase().trim() == "PEC") ? columnDetail[17].toUpperCase().trim() : ((columnDetail[20].toUpperCase().trim() == "PEC") ? columnDetail[19].toUpperCase().trim() : columnDetail[15].toUpperCase().trim())))
                record.setDataIstituzione(columnDetail[3].toUpperCase().trim())
                record.setDataSoppressione(null)
                record.setCompetenzaEsclusiva(VALORE_COMPETENZA_ESCLUSIVA)
                record.setCompetenza(VALORE_COMPETENZA)
                record.setUtenteAggiornamento((filterForm?.utenteAggiornamento) ? filterForm?.utenteAggiornamento : "RPI")
                record.setDataAggiornamento(filterForm?.dataAggiornamento)
                record.setRegione(columnDetail[7].toUpperCase().trim())

                record.setCap((record?.cap.length() > L_CAP) ? "" : record.cap)
                record.setFax((record?.fax.length() > L_FAX) ? "" : record.fax)
                record.setTelefono((record?.telefono.length() > L_TEL) ? "" : record.telefono)
                record.setIndirizzo((record?.indirizzo.length() > L_INDIRIZZO) ? record.indirizzo.substring(0, L_INDIRIZZO) : record.indirizzo)

                if (record?.getProvincia() != null) {
                    if (record.getProvincia() == "BO") {
                        record.setRegione("PROV.AUT. BOLZANO")
                    }
                    if (record.getProvincia() == "TN") {
                        record.setRegione("PROV.AUT. TRENTO")
                    }
                }
                record.setAd4Provincia(null)
                record.setAd4Comune(null)

                if (valideCondition(record, filterForm, TIPOLOGIA_AOO)) {
                    Ad4Regione ad4Regione = ad4ComuniProvincieRegioniRepository.getRegione(record?.regione)
                    Ad4Comune ad4Comune = ad4ComuniProvincieRegioniRepository.getComune(record?.citta, ad4Regione)[0]
                    if (ad4Comune) {
                        record.setAd4Provincia(ad4Comune.provincia)
                        record.setAd4Comune(ad4Comune)
                    }
                    record.setAd4UtenteAgg(ad4Repository.getUtente(filterForm?.utenteAggiornamento))

                    insertAoo(record)
                }

                record = null
            }
        }
        log.info("fine estrazione AOO")
    }

    void extractionTracedOu(def data, ScaricoIpaFilter filterForm, So4Ottica ottica) {
        log.info("inizio estrazione UO")
        int cont = 0

        /*List listaCfSFE = []
        dataCFSFE.eachLine {
            String[] columnDetail = new String[11];
            columnDetail = it.split("\t");
            listaCfSFE << new CfSFE(columnDetail[0] + '-' + columnDetail[1], columnDetail[9])
        }*/

        data.eachLine { it, count ->
            if (count > 0) {

                String[] columnDetail = new String[11];
                columnDetail = it.split("\t");
                ScaricoIpaFilter record = new ScaricoIpaFilter()
                record.setCodiceUo(columnDetail[0].toUpperCase().trim())
                record.setCodiceAmministrazione(columnDetail[13].toUpperCase().trim())
                record.setCodiceAoo(columnDetail[1].toUpperCase().trim())
                record.setDescrizioneUo(columnDetail[2].toUpperCase().trim())
                record.setDescrizione(columnDetail[2].toUpperCase().trim())
                record.setNomeResponsabile(columnDetail[9].toUpperCase().trim())
                record.setCognomeResponsabile(columnDetail[10].toUpperCase().trim())
                record.setTitoloResp("")
                record.setMailResp(columnDetail[11].toUpperCase().trim())
                record.setTelephonenumberResp(columnDetail[12].toUpperCase().trim())
                record.setUnita(columnDetail[0].toUpperCase().trim())
                record.setUnitaPadre(columnDetail[14].toUpperCase().trim())
                record.setIndirizzo(columnDetail[7].toUpperCase().trim())
                record.setCap(columnDetail[4].toUpperCase().trim())
                record.setCitta(columnDetail[3].toUpperCase().trim())
                record.setProvincia(columnDetail[5].toUpperCase().trim())
                record.setRegione(columnDetail[6].toUpperCase().trim())
                record.setMail((columnDetail[18].toUpperCase().trim() == "PEC") ? columnDetail[17].toUpperCase().trim() : ((columnDetail[20].toUpperCase().trim() == "PEC") ? columnDetail[19].toUpperCase().trim() : ((columnDetail[22].toUpperCase().trim() == "PEC") ? columnDetail[21].toUpperCase().trim() : columnDetail[17].toUpperCase().trim())))
                record.setSito("")
                record.setTelefono(columnDetail[8].toUpperCase().trim())
                record.setFax(columnDetail[15].toUpperCase().trim())
                //record.setCodiceFiscaleSFE(getCodiceFiscaleSFE(columnDetail[13] + '-' + columnDetail[0], listaCfSFE))
                record.setCodiceFiscaleSFE('')
                record.setCompetenzaEsclusiva(VALORE_COMPETENZA_ESCLUSIVA)
                record.setCompetenza(VALORE_COMPETENZA)
                record.setUtenteAggiornamento((filterForm?.utenteAggiornamento) ? filterForm?.utenteAggiornamento : "RPI")
                record.setDataSoppressione(null)
                record.setDataAggiornamento(filterForm?.dataAggiornamento)
                record.setTipologiaEnte(getTipoligiaEnteAmm(columnDetail[13].toUpperCase().trim(), listaDescrizioneTipologiaAmm))
                //record.setDescrizioneAmministrazione(getDescrizioneAmm(columnDetail[13].toUpperCase().trim(), listaDescrizioneTipologiaAmm))

                record.setCap((record?.cap.length() > L_CAP) ? "" : record.cap)
                record.setFax((record?.fax.length() > L_FAX) ? "" : record.fax)
                record.setTelefono((record?.telefono.length() > L_TEL) ? "" : record.telefono)
                record.setIndirizzo((record?.indirizzo.length() > L_INDIRIZZO) ? record.indirizzo.substring(0, L_INDIRIZZO) : record.indirizzo)

                if (record?.getProvincia() != null) {
                    if (record.getProvincia() == "BO") {
                        record.setRegione("PROV.AUT. BOLZANO")
                    }
                    if (record.getProvincia() == "TN") {
                        record.setRegione("PROV.AUT. TRENTO")
                    }
                }
                record.setAd4Provincia(null)
                record.setAd4Comune(null)

                if (valideCondition(record, filterForm, TIPOLOGIA_UO)) {
                    Ad4Regione ad4Regione = ad4ComuniProvincieRegioniRepository.getRegione(record?.regione)
                    Ad4Comune ad4Comune = ad4ComuniProvincieRegioniRepository.getComune(record?.citta, ad4Regione)[0]
                    if (ad4Comune) {
                        record.setAd4Provincia(ad4Comune?.provincia)
                        record.setAd4Comune(ad4Comune)
                    }
                    record.setAd4UtenteAgg(ad4Repository.getUtente(filterForm?.utenteAggiornamento))

                    insertUo(record, ottica)
                }

                record = null
            }
        }
        log.info("fine estrazione UO")
    }

    boolean valideCondition(ScaricoIpaFilter record, ScaricoIpaFilter form, String tipologia) {
        boolean validationCodice = true
        boolean validationDescrizione = true
        boolean validationRegione = true
        boolean validationProvincia = true
        boolean validationTipoEnte = true

        if (form != null) {

            if (tipologia == TIPOLOGIA_AMM && form.importaTutteAmm == true) {
                return true
            }
            if (tipologia == TIPOLOGIA_AOO && form.importaTutteAoo == false) {
                return false
            }
            if (tipologia == TIPOLOGIA_UO && form.importaTutteUnita == false) {
                return false
            }

            if (tipologia == TIPOLOGIA_AMM || tipologia == TIPOLOGIA_UO) {
                if (form.codiceAmministrazione && form.codiceAmministrazione?.toUpperCase()?.trim() != record.codiceAmministrazione?.toUpperCase()?.trim()) {
                    validationCodice = false
                }
                if (form.descrizioneAmministrazione && !record.descrizione?.toUpperCase()?.trim().contains(form.descrizioneAmministrazione?.toUpperCase()?.trim())) {
                    validationDescrizione = false
                }
                if (form.tipologiaEnte && form.tipologiaEnte?.toUpperCase()?.trim() != record.tipologiaEnte?.toUpperCase()?.trim()) {
                    validationTipoEnte = false
                }
                if (form.regione && form.regione?.toUpperCase()?.trim() != record.regione?.toUpperCase()?.trim()) {
                    validationRegione = false
                }
                if (form.provincia && form.provincia?.toUpperCase()?.trim() != record.provincia?.toUpperCase()?.trim()) {
                    validationProvincia = false
                }
            }

            if (tipologia == TIPOLOGIA_AOO) {
                if (form.codiceAoo && form.codiceAoo?.toUpperCase()?.trim() != record.codiceAoo?.toUpperCase()?.trim()) {
                    validationCodice = false
                }
                if (form.descrizioneAoo && !record.descrizione?.toUpperCase()?.trim().contains(form.descrizioneAoo?.toUpperCase()?.trim())) {
                    validationDescrizione = false
                }
                if (form.regione && form.regione?.toUpperCase()?.trim() != record.regione?.toUpperCase()?.trim()) {
                    validationRegione = false
                }
                if (form.provincia && form.provincia?.toUpperCase()?.trim() != record.provincia?.toUpperCase()?.trim()) {
                    validationProvincia = false
                }
            }
        }

        if (validationCodice && validationDescrizione && validationTipoEnte && validationProvincia && validationRegione) {
            return true
        } else {
            return false
        }
    }

    String getCodiceFiscaleSFE(String keyVal, List lista) {
        String retVal = lista.findAll { p -> p.chiave == keyVal }*.codiceFiscaleSFE[0]

        if (retVal != null) {
            if (retVal.length() != 11) {
                retVal = ""
            }
        }

        return retVal
    }

    private String getTipoligiaEnteAmm(String keyVal, List lista) {

        String retVal = lista.findAll { p -> p.codiceAmministrazione == keyVal }*.tipologiaEnte[0]

        if (retVal != null) {
            if (retVal.length() != 11) {
                retVal = ""
            }
        }

        return retVal
    }

    private String getDescrizioneAmm(String keyVal, List lista) {

        String retVal = lista.findAll { p -> p.codiceAmministrazione == keyVal }*.descrizioneAmministrazione[0]

        if (retVal != null) {
            if (retVal.length() != 11) {
                retVal = ""
            }
        }

        return retVal
    }

    void insertAmm(ScaricoIpaFilter record) {
        log.info("-> elaborazione Amministrazione = " + record?.codiceAmministrazione)
        String codiceAmm
        String ni
        boolean ente
        String dataSoppressione
        String utenteAgg
        String msg
        So4Amministrazione amministrazione

        // TODO non essendoci dataSoppressione si può non considerare
        // se esiste una data di soppressione e l'amministrazione e presente in archivio esco
        if (record.dataSoppressione != null && so4Repository.getAmministrazione(record.codiceAmministrazione)) {
            return
        }

        try {
            amministrazione = so4Repository.getAmministrazione(record.codiceAmministrazione)
            if (amministrazione) {
                codiceAmm = amministrazione.codice
                ni = amministrazione.soggetto.id
                ente = amministrazione.ente
                dataSoppressione = amministrazione.dataSoppressione
                utenteAgg = so4IpaService.so4_aoo_pkg_get_utente_aggiornamento(amministrazione.codice)
            }
        } catch (Exception e) {
            log.error("Errore controllo presenza/recupero Amministrazione: " + record.codiceAmministrazione + ". " + e.getMessage())
        }

        // se i dati si riferiscono ad un amministrazione di un ente proprietario
        // o se il record esiste, è stato aggioranto dall'utente ipar e l'utetne di aggiornamento passato non è ipar
        // non si esegue nessuna operazione
        if ((ente == true) || (utenteAgg == "ipar" && record?.utenteAggiornamento != "ipar")) {
            return
        }

        if (!amministrazione) {
            // cerco se esiste un soggetto con quel codice fiscale
            List<As4SoggettoCorrente> listCheckCodiceFiscale = as4Repository.getListSoggettoCorrente(record?.codiceFiscaleAmm)
            if (listCheckCodiceFiscale.size() == 0) {
                ni = insAnagrafica(record)
            } else {
                ni = listCheckCodiceFiscale[0].ni
            }

            msg = so4IpaService.so4_ammi_pkg_ins(record, ni)
            if (msg != "OK") {
                log.warn(msg)
            }

            msg = so4IpaService.so4_inte_pkg_agg_automatico(record, ni, null, null, "AM")
            if (msg != "OK") {
                log.warn(msg)
            }
            log.info("amministrazione non presente, creata con ni=" + ni)
        } else {
            if (record?.mail != null) {
                msg = so4IpaService.so4_inte_pkg_agg_automatico(record, ni, null, null, "AM")
                if (msg != "OK") {
                    log.warn(msg)
                }
            }

            if (utenteAgg != 'ipar' && record?.utenteAggiornamento == 'ipar') {
                msg = so4IpaService.so4_inte_pkg_upd_column(codiceAmm, "UTENTE_AGGIORNAMENTO", "ipar", "S")
                if (msg != "OK") {
                    log.warn(msg)
                }
                msg = so4IpaService.so4_inte_pkg_upd_column(codiceAmm, "DATA_AGGIORNAMENTO", sysdate, "D")
                if (msg != "OK") {
                    log.warn(msg)
                }
            }

            // controllo se è stata modificata l'anagrafica
            if (isAnagraficaModificata(record, ni)) {
                //updAnagrafica(record, ni)
                msg = as4IpaService.as4_anagrafici_pkg_allinea_anagrafica_amm_da_ipa(record, ni)
                if (msg != "OK") {
                    log.warn(msg)
                }
                log.info("amministrazione modificata con ni=" + ni)
            }

            if (dataSoppressione && (record?.dataSoppressione != dataSoppressione)) {
                msg = so4IpaService.so4_inte_pkg_upd_column(codiceAmm, "DATA_SOPPRESSIONE", record.dataSoppressione, "D")
                if (msg != "OK") {
                    log.warn(msg)
                }
            }

        }

        msg = so4IpaService.so4_codici_ipa_tpk_del("AM", ni)
        if (msg != "OK") {
            log.warn(msg)
        }

        msg = so4IpaService.so4_codici_ipa_tpk_ins('AM', ni, record?.codiceAmministrazione)
        if (msg != "OK") {
            log.warn(msg)
        }

    }

    void insertAoo(ScaricoIpaFilter record) {
        log.info("-> elaborazione AOO = " + record?.codiceAoo + ", con  amministrazione: " + record?.codiceAmministrazione)

        String progrAoo = null
        boolean ente
        String utenteAgg
        String msg
        Date dal = null
        Date al = null
        Date dalAmm
        So4Amministrazione amministrazione

        // se esiste una data di soppressione e l'aoo non è presente in archivio esco
        // TODO non essendoci dataSoppressione si può non considerare
        if (record.dataSoppressione != null && !so4Repository.getAoo(record.codiceAoo, record.codiceAmministrazione)) {
            return
        }

        amministrazione = so4Repository.getAmministrazione(record.codiceAmministrazione)
        if (amministrazione) {
            ente = amministrazione.ente
            dalAmm = amministrazione.dataIstituzione
            utenteAgg = so4IpaService.so4_aoo_pkg_get_utente_aggiornamento(amministrazione.codice)
        } else {
            log.info("amm non presente, esco")
            return
        }

        // se i dati si riferiscono ad un amministrazione di un ente proprietario
        // o se il record esiste, è stato aggioranto dall'utente ipar e l'utetne di aggiornamento passato non è ipar
        // non si esegue nessuna operazione
        if ((ente == true) || (utenteAgg == "ipar" && record?.utenteAggiornamento != "ipar")) {
            return
        }

        List<So4AOO> listSo4Aoo = so4IpaService.listAooByAsAmmAsAoo(record.codiceAmministrazione, record.codiceAoo)
        if (listSo4Aoo.size() > 0) {
            progrAoo = listSo4Aoo[0][0]
            dal = listSo4Aoo[0][1]
            al = listSo4Aoo[0][2]
        }

        if (progrAoo == null) {
            dal = (record?.dataIstituzione) ? (new Date().parse('yyyy-MM-dd', record.dataIstituzione)) : (new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy')))
            if (dalAmm > dal) {
                dal = dalAmm
            }

            progrAoo = so4IpaService.so4_aoo_pkg_get_id_area()

            msg = so4IpaService.so4_aoo_pkg_ins(record, progrAoo, dal)
            if (msg != "OK") {
                log.warn(msg)
            }

            if (record?.mail.trim() != null) {
                msg = so4IpaService.so4_inte_pkg_agg_automatico(record, null, progrAoo, null, "AO")
                if (msg != "OK") {
                    log.warn(msg)
                }
            }
            log.info("aoo non presente, creata con progressivo=" + progrAoo)
        } else {
            // controllo se è stata modificata l'aoo
            List<So4AOO> listAooModificato = so4Repository.isAooModificataIpa(progrAoo.toLong(), dal, record?.descrizione, record?.indirizzo, record?.cap, (record?.ad4Provincia?.provincia ? record?.ad4Provincia?.provincia : 0), (record?.ad4Comune?.comune ? record?.ad4Comune?.comune : 0), record?.telefono, record?.fax)
            if (listAooModificato.size() > 0) {
                if (dal == new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))) {
                    if (record.descrizione) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "DESCRIZIONE", record.descrizione, "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record.indirizzo) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "INDIRIZZO", record.indirizzo, "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record.cap) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "CAP", record.cap, "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record.ad4Provincia) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "PROVINCIA", record?.ad4Provincia?.id.toString(), "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.ad4Comune) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "COMUNE", record?.ad4Comune?.comune.toString(), "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.telefono) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "TELEFONO", record.telefono, "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.fax) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "FAX", record.fax, "S")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    log.info("aoo modificata con progressivo=" + progrAoo + " (dal==sysdate)")
                } else {
                    if (record?.dataSoppressione != null && new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy')) > new Date().parse('dd/MM/yyyy', record?.dataSoppressione)) {
                        msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "AL", record?.dataSoppressione, "D")
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    } else {
                        if (dalAmm > al) {
                            msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "DAL", new SimpleDateFormat("dd/MM/yyyy").format(dalAmm), "D")
                            if (msg != "OK") {
                                log.warn(msg)
                            }
                        }
                    }

                    msg = so4IpaService.so4_aoo_pkg_ins(record, progrAoo, new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy')))
                    if (msg != "OK") {
                        log.warn(msg)
                    }
                    log.info("aoo modificata con progressivo=" + progrAoo + " (dal!=sysdate)")
                }
            } else {
                // TODO non essendoci dataSoppressione si può non considerare
                if (record?.dataSoppressione != null && new Date().parse('yyyy-MM-dd', record.dataSoppressione) != dal) {
                    msg = so4IpaService.so4_aoo_pkg_upd_column(progrAoo, dal, "AL", record?.dataSoppressione, "D")
                    if (msg != "OK") {
                        log.warn(msg)
                    }
                }
            }

            if (record?.mail.trim() != null) {
                msg = so4IpaService.so4_inte_pkg_agg_automatico(record, null, progrAoo, null, "AO")
                if (msg != "OK") {
                    log.warn(msg)
                }
            }
        }

        msg = so4IpaService.so4_codici_ipa_tpk_del("AO", progrAoo)
        if (msg != "OK") {
            log.warn(msg)
        }
        msg = so4IpaService.so4_codici_ipa_tpk_ins('AO', progrAoo, record.codiceAoo)
        if (msg != "OK") {
            log.warn(msg)
        }
    }

    void insertUo(ScaricoIpaFilter record, So4Ottica ottica) {
        log.info("-> elaborazione uo: " + record?.codiceUo + ", con  amministrazione: " + record?.codiceAmministrazione)
        Date al
        Date dal
        boolean ente
        String progrAoo
        String progrUo
        String utenteAgg
        String msg

        So4Amministrazione amministrazione = so4Repository.getAmministrazione(record?.codiceAmministrazione)
        if (amministrazione && record?.codiceAmministrazione != null) {
            ente = amministrazione.ente
            utenteAgg = so4IpaService.so4_aoo_pkg_get_utente_aggiornamento(amministrazione.codice)
            // manca utente aggiornamento su so4Amministrazioni
        } else {
            log.info("amm non presente, esco")
            return
        }

        // se i dati si riferiscono ad un amministrazione di un ente proprietario
        // o se il record esiste, è stato aggioranto dall'utente ipar e l'utetne di aggiornamento passato non è ipar
        // non si esegue nessuna operazione
        if ((ente == true) || (utenteAgg == "ipar" && record?.utenteAggiornamento != "ipar")) {
            return
        }

        // Ricerca progr_aoo
        So4AOO so4AOO = so4Repository.getAoo(record?.codiceAoo, record?.codiceAmministrazione)
        if (so4AOO) {
            progrAoo = so4AOO.progr_aoo
        } else {
            progrAoo = null
        }

        // Verifica se uo già presente in anagrafica
        List<So4UnitaBase> listSo4Unita = so4IpaService.listUnitaByAsAmmAsUo(record.codiceAmministrazione, record.codiceUo)
        if (listSo4Unita.size() > 0) {
            progrUo = listSo4Unita[0][0]
            dal = listSo4Unita[0][1]
            al = listSo4Unita[0][2]
        } else {
            progrUo = null
            dal = null
            al = null
        }

        if (progrUo == null) {
            progrUo = so4IpaService.so4_auor_pkg_get_id_unita()

            msg = so4IpaService.so4_auor_pkg_ins(record, progrUo, new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy')), ottica, progrAoo)
            if (msg != "OK") {
                log.warn(msg)
            }

            msg = so4IpaService.so4_inte_pkg_agg_automatico(record, null, null, progrUo, "UO")
            if (msg != "OK") {
                log.warn(msg)
            }
            log.info("uo non presente, creata con progressivo=" + progrUo)
        } else {
            if (record?.mail.trim() != null) {
                msg = so4IpaService.so4_inte_pkg_agg_automatico(record, null, null, progrUo, "UO")
                if (msg != "OK") {
                    log.warn(msg)
                }
            }

            // verifico se è stata modificata l'unità
            List<So4UnitaBase> listUoModificato = so4IpaService.isUnitaBaseModificataIpa(progrUo.toLong(), dal, record?.descrizione, record?.indirizzo, record?.cap, (record?.ad4Provincia?.id ? record?.ad4Provincia?.id : 0), (record?.ad4Comune?.comune ? record?.ad4Comune?.comune : 0), record?.telefono, record?.fax)
            if (listUoModificato.size() > 0) {

                if (dal == new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))) {
                    if (record?.descrizione) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "DESCRIZIONE", record?.descrizione, 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.indirizzo) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "INDIRIZZO", record?.indirizzo, 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.cap) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "CAP", record?.cap, 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.ad4Provincia) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "PROVINCIA", record?.ad4Provincia?.id.toString(), 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }

                    if (record?.ad4Comune) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "COMUNE", record?.ad4Comune?.comune.toString(), 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.telefono) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "TELEFONO", record?.telefono, 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                    if (record?.fax) {
                        msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "FAX", record?.fax, 'S')
                        if (msg != "OK") {
                            log.warn(msg)
                        }
                    }
                } else {
                    if (record?.dataSoppressione != null) {
                        if (new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy')) > new Date().parse('yyyy-MM-dd', record?.dataSoppressione)) {
                            dal = new Date().parse('yyyy-MM-dd', record?.dataSoppressione)
                        } else {
                            dal = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
                        }
                    }

                    msg = so4IpaService.so4_auor_pkg_ins(record, progrUo, new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy')), ottica, progrAoo)
                    if (msg != "OK") {
                        log.warn(msg)
                    }
                }
                log.info("uo modificata con progressivo=" + progrUo)
            } else {
                if (record?.dataSoppressione != null && new Date().parse('yyyy-MM-dd', record.dataSoppressione) != al) {
                    msg = so4IpaService.so4_auor_pkg_upd_column(progrUo, dal, "AL", record?.dataSoppressione, 'D')
                    if (msg != "OK") {
                        log.warn(msg)
                    }
                }
            }
        }

        msg = so4IpaService.so4_codici_ipa_tpk_del("UO", progrUo)
        if (msg != "OK") {
            log.warn(msg)
        }

        msg = so4IpaService.so4_codici_ipa_tpk_ins('UO', progrUo, record.codiceUo)
        if (msg != "OK") {
            log.warn(msg)
        }
    }

    int insAnagrafica(ScaricoIpaFilter record) {
        Date dataIst
        Date dataAgg

        if (record?.dataIstituzione != null) {
            dataIst = new Date().parse('yyyy-MM-dd', record.dataIstituzione)
        } else {
            dataIst = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record.dataAggiornamento)
        } else {
            dataAgg = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        // CREAZIONE ANAGRAFICA - RECAPITO - CONTATTI
        As4Anagrafica anagrafica = new As4Anagrafica()
        anagrafica.tipoSoggetto = As4TipoSoggetto.findByTipoSoggetto("E")
        anagrafica.competenzaEsclusiva = record.competenzaEsclusiva
        anagrafica.competenza = record.competenza
        anagrafica.codFiscale = record.codiceFiscaleAmm
        anagrafica.partitaIva = record.codiceFiscaleAmm
        anagrafica.utente = record.utenteAggiornamento
        anagrafica.cognome = record.descrizione
        anagrafica.denominazione = record.descrizione
        anagrafica.dataAgg = dataAgg
        anagrafica.dal = dataIst
        Long idAnagrafica = as4AnagraficaService.inserisciAnagrafica(anagrafica)

        As4Anagrafica a = As4Anagrafica.get(idAnagrafica)

        As4Recapito recapito = new As4Recapito()
        recapito.ni = a.ni     // anag.codice
        recapito.dal = dataIst
        recapito.competenza = record.competenza
        recapito.competenzaEsclusiva = record.competenzaEsclusiva
        recapito.utenteAggiornamento = record.ad4UtenteAgg
        recapito.dataAggiornamento = dataAgg
        recapito.tipoRecapito = as4Repository.getTipoRecapito("RESIDENZA")
        recapito.indirizzo = record.indirizzo
        recapito.provincia = record.ad4Provincia
        recapito.comune = record.ad4Comune
        recapito.cap = record.cap.toUpperCase().trim()
        as4RecapitoService.inserisci(recapito)

        As4Recapito recapitoInserito = As4Recapito.findById(recapito.id)
        As4TipoContatto as4TipoContattoFax = as4Repository.getTipoContatto("FAX")
        As4TipoContatto as4TipoContattoTelefono = as4Repository.getTipoContatto("TELEFONO")
        As4TipoContatto as4TipoContattoMail = as4Repository.getTipoContatto("MAIL")
        As4TipoContatto as4TipoContattoSitoWeb = as4Repository.getTipoContatto("SITOWEB")

        if (record.fax != "" && as4TipoContattoFax) {
            As4Contatto contattoFax = new As4Contatto()
            contattoFax.dataAggiornamento = dataAgg
            contattoFax.utenteAggiornamento = record.utenteAggiornamento
            contattoFax.competenza = record.competenza
            contattoFax.competenzaEsclusiva = record.competenzaEsclusiva
            contattoFax.dal = dataIst
            contattoFax.recapito = recapitoInserito
            contattoFax.tipoContatto = as4TipoContattoFax
            contattoFax.valore = record.fax
            as4ContattoService.inserisci(contattoFax)
        }

        if (record.telefono != "" && as4TipoContattoTelefono) {
            As4Contatto contattoTel = new As4Contatto()
            contattoTel.dataAggiornamento = dataAgg
            contattoTel.utenteAggiornamento = record.utenteAggiornamento
            contattoTel.competenza = record.competenza
            contattoTel.competenzaEsclusiva = record.competenzaEsclusiva
            contattoTel.dal = dataIst
            contattoTel.recapito = recapitoInserito
            contattoTel.tipoContatto = as4TipoContattoTelefono
            contattoTel.valore = record.telefono
            as4ContattoService.inserisci(contattoTel)
        }

        if (record.mail != "" && as4TipoContattoMail) {
            As4Contatto contattoMail = new As4Contatto()
            contattoMail.dataAggiornamento = dataAgg
            contattoMail.utenteAggiornamento = record.utenteAggiornamento
            contattoMail.competenza = record.competenza
            contattoMail.competenzaEsclusiva = record.competenzaEsclusiva
            contattoMail.dal = dataIst
            contattoMail.recapito = recapitoInserito
            contattoMail.tipoContatto = as4TipoContattoMail
            contattoMail.valore = record.mail
            as4ContattoService.inserisci(contattoMail)
        }

        if (record.sito != "" && as4TipoContattoSitoWeb) {
            As4Contatto contattoSito = new As4Contatto()
            contattoSito.dataAggiornamento = dataAgg
            contattoSito.utenteAggiornamento = record.utenteAggiornamento
            contattoSito.competenza = record.competenza
            contattoSito.competenzaEsclusiva = record.competenzaEsclusiva
            contattoSito.dal = dataIst
            contattoSito.recapito = recapitoInserito
            contattoSito.tipoContatto = as4TipoContattoSitoWeb
            contattoSito.valore = record.sito
            as4ContattoService.inserisci(contattoSito)
        }

        log.info("anagrafica creata con ni=" + a.ni)
        return a.ni
    }

    void updAnagrafica(ScaricoIpaFilter record, String ni) {

        Date dataIst
        Date dataAgg

        if (record?.dataIstituzione != null) {
            dataIst = new Date().parse('yyyy-MM-dd', record.dataIstituzione)
        } else {
            dataIst = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record.dataAggiornamento)
        } else {
            dataAgg = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        // MODIFICA ANAGRAFICA - RECAPITO - CONTATTI
        As4Anagrafica anagrafica = as4Repository.getAnagrafica(ni.toLong())
        anagrafica.ni = ni.toLong()
        anagrafica.tipoSoggetto = As4TipoSoggetto.findByTipoSoggetto("E")
        anagrafica.competenzaEsclusiva = record.competenzaEsclusiva
        anagrafica.competenza = record.competenza
        anagrafica.codFiscale = record.codiceFiscaleAmm
        anagrafica.partitaIva = record.codiceFiscaleAmm
        anagrafica.utente = record.utenteAggiornamento
        anagrafica.cognome = record.descrizione
        anagrafica.denominazione = record.descrizione
        anagrafica.dataAgg = dataAgg
        anagrafica.statoSoggetto = 'U'
        anagrafica.dataAgg = dataAgg
        anagrafica.dal = dataIst
        //anagrafica.al = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        as4AnagraficaService.modifica(anagrafica)

        As4Recapito recapito = as4Repository.getAs4Recapito(ni.toLong(), as4Repository.getTipoRecapito("RESIDENZA"))
        recapito.ni = ni.toLong()
        recapito.dal = dataAgg
        //recapito.al = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        recapito.competenza = record.competenza
        recapito.competenzaEsclusiva = record.competenzaEsclusiva
        recapito.utenteAggiornamento = record.ad4UtenteAgg
        recapito.dataAggiornamento = dataAgg
        recapito.tipoRecapito = as4Repository.getTipoRecapito("RESIDENZA")
        recapito.indirizzo = record.indirizzo
        recapito.provincia = record.ad4Provincia
        recapito.comune = record.ad4Comune
        recapito.cap = record.cap
        as4RecapitoService.modifica(recapito)

        if (record.fax != "") {
            getContatti(recapito, as4Repository.getTipoContatto("FAX")).each {
                //As4Contatto contattoFax = as4Repository.getAs4Contatto(recapito, as4Repository.getTipoContatto("FAX"))
                //As4Contatto contattoFax = getContatto(recapito, as4Repository.getTipoContatto("FAX"))
                As4Contatto contattoFax = As4Contatto.get(it.id)
                contattoFax.dataAggiornamento = dataAgg
                contattoFax.utenteAggiornamento = record.utenteAggiornamento
                contattoFax.competenza = record.competenza
                contattoFax.competenzaEsclusiva = record.competenzaEsclusiva
                contattoFax.dal = dataAgg
                //contattoFax.al = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
                contattoFax.recapito = recapito
                contattoFax.tipoContatto = as4Repository.getTipoContatto("FAX")
                contattoFax.valore = record.fax
                as4ContattoService.modifica(contattoFax)
            }
        }
        if (record.telefono != "") {
            getContatti(recapito, as4Repository.getTipoContatto("TELEFONO")).each {
                //As4Contatto contattoTel = as4Repository.getAs4Contatto(recapito, as4Repository.getTipoContatto("TELEFONO"))
                //As4Contatto contattoTel = getContatto(recapito, as4Repository.getTipoContatto("TELEFONO"))
                As4Contatto contattoTel = As4Contatto.get(it.id)
                contattoTel.dataAggiornamento = dataAgg
                contattoTel.utenteAggiornamento = record.utenteAggiornamento
                contattoTel.competenza = record.competenza
                contattoTel.competenzaEsclusiva = record.competenzaEsclusiva
                contattoTel.dal = dataAgg
                //contattoTel.al = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
                contattoTel.recapito = recapito
                contattoTel.tipoContatto = as4Repository.getTipoContatto("TELEFONO")
                contattoTel.valore = record.telefono
                as4ContattoService.modifica(contattoTel)
            }
        }
        if (record.mail != "") {
            getContatti(recapito, as4Repository.getTipoContatto("MAIL")).each {
                //As4Contatto contattoMail = as4Repository.getAs4Contatto(recapito, as4Repository.getTipoContatto("MAIL"))
                //As4Contatto contattoMail = getContatto(recapito,as4Repository.getTipoContatto("MAIL"))
                As4Contatto contattoMail = As4Contatto.get(it.id)
                contattoMail.dataAggiornamento = dataAgg
                contattoMail.utenteAggiornamento = record.utenteAggiornamento
                contattoMail.competenza = record.competenza
                contattoMail.competenzaEsclusiva = record.competenzaEsclusiva
                contattoMail.dal = dataAgg
                //contattoMail.al = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
                contattoMail.recapito = recapito
                contattoMail.tipoContatto = as4Repository.getTipoContatto("MAIL")
                contattoMail.valore = record.mail
                as4ContattoService.modifica(contattoMail)
            }
        }
        if (record.sito != "") {
            getContatti(recapito, as4Repository.getTipoContatto("SITOWEB")).each {
                //As4Contatto contattoSito = as4Repository.getAs4Contatto(recapito, as4Repository.getTipoContatto("SITOWEB"))
                //As4Contatto contattoSito = getContatto(recapito, as4Repository.getTipoContatto("SITOWEB"))
                As4Contatto contattoSito = As4Contatto.get(it.id)
                contattoSito.dataAggiornamento = dataAgg
                contattoSito.utenteAggiornamento = record.utenteAggiornamento
                contattoSito.competenza = record.competenza
                contattoSito.competenzaEsclusiva = record.competenzaEsclusiva
                contattoSito.dal = dataAgg
                //contattoSito.al = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
                contattoSito.recapito = recapito
                contattoSito.tipoContatto = as4Repository.getTipoContatto("SITOWEB")
                contattoSito.valore = record.mail
                as4ContattoService.modifica(contattoSito)
            }
        }
    }

    // verifica se è stata modificata l'anagrafica
    boolean isAnagraficaModificata(ScaricoIpaFilter record, def ni) {
        boolean aggiornamento = false
        List<As4Anagrafica> listAnagModificata = as4Repository.isAnagraficaModificataIpa(ni.toLong(), record?.descrizione.toUpperCase().trim(), record?.codiceFiscaleAmm.toUpperCase().trim())

        if (listAnagModificata.size() == 0) {
            As4TipoRecapito as4TipoRecapito = as4Repository.getTipoRecapito("RESIDENZA")

            List<As4Recapito> listRecapitoModificato = as4Repository.isRecapitoModificatoIpa(ni.toLong(), as4TipoRecapito, record?.indirizzo.toUpperCase().trim(), record?.cap.toUpperCase().trim(), record?.ad4Provincia, record?.ad4Comune)

            if (listRecapitoModificato.size() == 0) {

                As4Recapito recapitoRicerca = as4Repository.getAs4Recapito(ni.toLong(), as4TipoRecapito)
                As4TipoContatto as4TipoContattoFax = as4Repository.getTipoContatto("FAX")
                As4TipoContatto as4TipoContattoTelefono = as4Repository.getTipoContatto("TELEFONO")
                As4TipoContatto as4TipoContattoMail = as4Repository.getTipoContatto("MAIL")

                List<As4Contatto> listContattoFaxModificato = []
                List<As4Contatto> listContattoTelefonoModificato = []
                List<As4Contatto> listContattoEmailModificato = []
                if (record.fax != "") {
                    listContattoFaxModificato = as4Repository.isContattoModificatoIpa(recapitoRicerca, as4TipoContattoFax, record?.fax.toUpperCase().trim())
                }
                if (record.telefono != "") {
                    listContattoTelefonoModificato = as4Repository.isContattoModificatoIpa(recapitoRicerca, as4TipoContattoTelefono, record?.telefono.toUpperCase().trim())
                }
                if (record.mail != "") {
                    listContattoEmailModificato = as4Repository.isContattoModificatoIpa(recapitoRicerca, as4TipoContattoMail, record?.mail.toUpperCase().trim())
                }

                if (listContattoFaxModificato.size() > 0 || listContattoTelefonoModificato.size() > 0 || listContattoEmailModificato.size() > 0) {
                    log.info("contatto modificato")
                    aggiornamento = true
                }
            } else {
                log.info("recapito modificato")
                aggiornamento = true
            }
        } else {
            log.info("anagrafica modificata")
            aggiornamento = true
        }

        return aggiornamento
    }

    List<As4Contatto> getContatti(As4Recapito as4Recapito, As4TipoContatto as4TipoContatto) {

        List<As4Contatto> listContatti = As4Contatto.createCriteria().list {
            eq("recapito", as4Recapito)
            eq("tipoContatto", as4TipoContatto)
            //isNull("al")
        }

        return listContatti
    }
}