package it.finmatica.protocollo.titolario

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.competenze.DocumentoCompetenze
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggetto
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.TipoCollegamentoRepository
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.DocumentoSoggettoRepository
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScarto
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScartoDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioRepository
import it.finmatica.protocollo.exceptions.FascicoloRuntimeException
import it.finmatica.protocollo.fascicolo.NumerazioneService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang3.tuple.Pair
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionSynchronizationAdapter
import org.springframework.transaction.support.TransactionSynchronizationManager

import javax.persistence.EntityManager
import javax.persistence.TypedQuery
import javax.sql.DataSource
import java.sql.SQLException
import java.text.DateFormat
import java.text.SimpleDateFormat

@Slf4j
@Transactional
@Service
class FascicoloService {
    //private static final Logger log = LoggerFactory.getLogger(FascicoloService)

    public static final String APERTI = 'APERTI'
    public static final String CHIUSI = 'CHIUSI'

    @Autowired
    GestioneDocumentiSpringSecurityService springSecurityService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    ClassificazioneNumeroRepository classificazioneNumeroRepository
    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    TipoCollegamentoRepository tipoCollegamentoRepository
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    DataSource dataSource
    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    DocumentoSoggettoRepository documentoSoggettoRepository
    @Autowired
    DocumentoTitolarioRepository documentoTitolarioRepository
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService

    @Autowired
    EntityManager entityManager
    @Autowired
    NumerazioneService numerazioneService

    Date now = new Date()
    Integer annoCorrente = now.year + 1900

    FascicoloDTO salva(FascicoloDTO fascicoloDTO, Map soggetti, def titolario, boolean creazione, boolean duplica, List<DocumentoCollegatoDTO> listaCollegamenti, boolean salvaDaWS = false, Ad4Utente utente = springSecurityService.currentUser) {

        boolean smistamentiAbilitati = ImpostazioniProtocollo.ITER_FASCICOLI.abilitato

        if (!titolario) {
            titolario = fascicoloDTO.classificazione
        }

        Fascicolo fascicolo = Fascicolo.get(fascicoloDTO.id) ?: new Fascicolo()

        fascicolo.anno = fascicoloDTO.anno
        fascicolo.annoArchiviazione = fascicoloDTO.annoArchiviazione
        fascicolo.dataArchiviazione = fascicoloDTO.dataArchiviazione
        fascicolo.digitale = fascicoloDTO.digitale
        fascicolo.dataApertura = fascicoloDTO.dataApertura
        fascicolo.dataChiusura = fascicoloDTO.dataChiusura
        fascicolo.dataCreazione = fascicoloDTO.dataCreazione
        fascicolo.oggetto = fascicoloDTO.oggetto?.toUpperCase()
        fascicolo.tipoOggetto = WkfTipoOggetto.get(Fascicolo.TIPO_DOCUMENTO)
        fascicolo.classificazione = fascicoloDTO.classificazione?.domainObject
        fascicolo.note = fascicoloDTO.note?.toUpperCase()
        fascicolo.numeroProssimoAnno = fascicoloDTO.numeroProssimoAnno
        fascicolo.responsabile = fascicoloDTO.responsabile?.toUpperCase()
        fascicolo.riservato = fascicoloDTO.riservato
        fascicolo.dataStato = fascicoloDTO.dataStato
        fascicolo.statoFascicolo = fascicoloDTO.statoFascicolo
        fascicolo.sub = 0
        fascicolo.topografia = fascicoloDTO.topografia?.toUpperCase()

        if (salvaDaWS) {
            fascicolo.numero = fascicoloDTO.numero
        }

        if (ImpostazioniProtocollo.ITER_FASCICOLI.abilitato && !creazione) {
            if (soggetti?.UO_COMPETENZA?.unita?.domainObject.id != fascicolo?.getSoggetto(TipoSoggetto.UO_COMPETENZA)?.unitaSo4?.id) {
                // cambio UO Competenza
                modificaUoCompetenza(fascicolo, soggetti?.UO_COMPETENZA?.unita?.domainObject)
            }
        }

        fascicolo.setSoggetto(TipoSoggetto.UO_CREAZIONE, null, soggetti?.UO_CREAZIONE?.unita?.domainObject)
        fascicolo.setSoggetto(TipoSoggetto.UO_COMPETENZA, null, soggetti?.UO_COMPETENZA?.unita?.domainObject)

        if (creazione) {
            fascicolo.ultimoNumeroSub = 0
            fascicolo.idrif = protocolloGdmService.calcolaIdrif()
            fascicolo.movimento == fascicolo.MOVIMENTO_INTERNO

            if (!salvaDaWS) {
                if (titolario?.domainObject instanceof Fascicolo && duplica == false) {
                    fascicolo.idFascicoloPadre = titolario.id
                }
            } else {
                fascicolo.idFascicoloPadre = fascicoloDTO.idFascicoloPadre
            }

            if (!salvaDaWS) {
                // numerazione
                if (!fascicoloDTO.numeroProssimoAnno) {
                    if (titolario?.domainObject instanceof Classificazione || duplica) {
                        setNumerazioneFascicolo(fascicolo, fascicolo.anno, fascicolo.classificazione)
                    } else {
                        setNumerazioneFascicolo(fascicolo, fascicolo.anno, titolario?.domainObject)
                    }
                }
            }
        }

        if (fascicolo.anno && fascicolo.numero) {
            fascicolo.annoNumero = fascicolo.anno + "/" + fascicolo.numero?.toUpperCase()
            fascicolo.nome = fascicolo.anno + "/" + fascicolo.numero?.toUpperCase() + " - " + fascicoloDTO.oggetto?.toUpperCase()
        } else {
            fascicolo.annoNumero = "/"
            fascicolo.nome = "/" + " - " + fascicoloDTO.oggetto
            fascicolo.numeroOrd = numeroOrdinato(null)
        }

        DocumentoDatiScartoDTO scartoDTO = fascicoloDTO.datiScarto
        if (scartoDTO != null) {
            DocumentoDatiScarto scarto = new DocumentoDatiScarto()
            scarto.dataStato = scartoDTO.dataStato
            scarto.stato = scartoDTO.stato?.domainObject
            scarto.dataNullaOsta = scartoDTO.dataNullaOsta
            scarto.nullaOsta = scartoDTO.nullaOsta
            scarto.save()
            fascicolo.datiScarto = scarto
        }

        fascicolo.dataUltimaOperazione = new Date()
        fascicolo.save()

        new DocumentoCompetenze(documento: fascicolo, utenteAd4: utente, lettura: true, modifica: true, cancellazione: true).save()
        fascicolo.save()

        // smistamento di default in creazione
        if (creazione && smistamentiAbilitati) {
            SmistamentoDTO smistamentoAttivoCompetenza = fascicoloDTO?.smistamenti?.find {
                it.tipoSmistamento == Smistamento.COMPETENZA && (it.statoSmistamento == Smistamento.DA_RICEVERE || it.statoSmistamento == Smistamento.IN_CARICO || it.statoSmistamento == Smistamento.CREATO)
            }
            if (smistamentoAttivoCompetenza == null) {
                // creo lo smistamento
                Smistamento smistamento = smistamentoService.creaSmistamento(fascicolo, Smistamento.COMPETENZA, soggetti?.UO_CREAZIONE?.unita?.domainObject, utente, soggetti?.UO_COMPETENZA?.unita?.domainObject, null, null)
                smistamento.statoSmistamento = Smistamento.DA_RICEVERE
                smistamentoService.prendiInCarico(fascicolo, utente)
            }
        }

        listaCollegamenti.each {
            setCollegamenti(it.documento.domainObject, it.collegato.domainObject, it.tipoCollegamento.domainObject)
        }

        smistamentoService.salva(fascicolo, fascicoloDTO?.smistamenti?.toList() ?: [])
        fascicolo.save()

        return fascicolo.toDTO()
    }

    @Transactional(readOnly = true)
    List anniNumerazione(Classificazione classificazione) {
        List resultList = []

        if (classificazione?.codice == ImpostazioniProtocollo.CLAS_FASC_PERS.getValore() && !gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.USA_FASCICOLI_PERSONALE)) {
            return resultList
        }

        classificazioneNumeroRepository.getListAnnoNumerazioneFascicolo(classificazione).each {
            resultList << it
        }

        if (gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.CFFUTURO)) {
            classificazioneNumeroRepository.getListAnnoNumerazioneFascicoloCFFUTURO(classificazione).each {
                resultList << it
            }
        }

        if (gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.CFANYY)) {
            classificazioneNumeroRepository.getListAnnoNumerazioneFascicoloCFANYY(classificazione).each {
                resultList << it
            }
        }

        return resultList
    }

    @Transactional(readOnly = true)
    String numeroOrdinato(String numero) {
        String result = ""
        String[] str

        if (!numero) {
            numero = "0"
        }
        str = numero.tokenize('.')

        for (String values : str) {
            result = result + values.padLeft(7, '0')
        }

        return result
    }

    @Transactional(readOnly = true)
    String numeroRicerca(String numero) {
        String result = ""
        String[] str

        if (!numero) {
            numero = "0"
        }
        str = numero.tokenize('.')

        for (String values : str) {
            result = result + values.padLeft(7, '0') + "."
        }

        return result.substring(0, result.length() - 1)
    }

    @Transactional(readOnly = true)
    boolean isEsistonoDocumentiAltrove(Fascicolo fascicolo) {
        List<String> statiSmistamento = [Smistamento.DA_RICEVERE, Smistamento.IN_CARICO, Smistamento.ESEGUITO]
        Long progrUnita = fascicolo.getSoggetto(TipoSoggetto.UO_COMPETENZA)?.unitaSo4?.progr

        Integer smistamentoInUnitaDiverse = fascicoloRepository.getSmistamentoFascicoloDocumentoInUnitaDiverse(fascicolo.id, progrUnita, Smistamento.COMPETENZA, statiSmistamento)

        return smistamentoInUnitaDiverse >= 1 ? true : false
    }

    @Transactional(readOnly = true)
    String getNuovoNumeroSub(FascicoloDTO fascicoloDTO) {
        Integer ultimoNumero = fascicoloRepository.getUltimoNumeroSub(fascicoloDTO?.domainObject)
        Integer nuovoNumero = (ultimoNumero + 1)?.toInteger()
        fascicoloRepository.modificaUltimoNumeroFascicolo(nuovoNumero, fascicoloDTO?.domainObject.id)
        return nuovoNumero
    }

    @Transactional(readOnly = true)
    List<TipoCollegamento> getTipiCollegamentoUtilizzabili() {
        return tipoCollegamentoRepository.utilizzabiliPerFascicolo(TipoCollegamentoConstants.perFascicolo)
    }

    @Transactional(readOnly = true)
    List<DocumentoCollegato> getCollegamentiVisibili(Fascicolo fascicolo) {
        return documentoCollegatoRepository.collegamentiVisibiliFascicolo(fascicolo, TipoCollegamentoConstants.perFascicolo)
    }

    private void setCollegamenti(Fascicolo documento, Fascicolo collegato, TipoCollegamento tipoCollegamento) {
        DocumentoCollegato documentoCollegato = new DocumentoCollegato()
        documentoCollegato.documento = documento
        documentoCollegato.collegato = collegato
        documentoCollegato.tipoCollegamento = tipoCollegamento
        documentoCollegato.save()
        //protocolloGdmService.salvaDocumentoCollegamento(documento, collegato, tipoCollegamento.codice)
    }

    void eliminaDocumentoCollegato(Fascicolo fascicolo, it.finmatica.gestionedocumenti.documenti.Documento documento, String codiceTipoCollegamento) {
        fascicolo.removeDocumentoCollegato(documento, codiceTipoCollegamento)
        fascicolo.save()
    }

    @Transactional(readOnly = true)
    List<Fascicolo> findByFilter(FascicoloJPAQLFilter filter) {
        def query = filter.toJPAQL()
        TypedQuery<Fascicolo> q = entityManager.createQuery(query, Fascicolo)
        for (Map.Entry<String, Object> entry in filter.params) {
            q.setParameter(entry.key, entry.value)
        }
        return q.resultList
    }

    DocumentoTitolario salvaFascicoloSecondario(Protocollo protocollo, Fascicolo fascicolo, Classificazione classificazione) {
        DocumentoTitolario doc = new DocumentoTitolario()
        doc.documento = protocollo
        doc.fascicolo = fascicolo
        doc.classificazione = classificazione
        return documentoTitolarioRepository.save(doc)
    }

    DocumentoTitolario salvaFascicoloSecondario(Documento documento, Fascicolo fascicolo, Classificazione classificazione) {
        DocumentoTitolario doc = new DocumentoTitolario()
        doc.documento = documento
        doc.fascicolo = fascicolo
        doc.classificazione = classificazione
        return documentoTitolarioRepository.save(doc)
    }

    void spostaFascicolo(Documento documento, Fascicolo fascicoloDestinazione, Classificazione classificazioneDestinazione, Fascicolo fascicoloOriginario) {
        DocumentoTitolario dt = documentoTitolarioRepository.getDocumentoTitolario(documento.id, fascicoloOriginario.id, fascicoloOriginario.classificazione.id)
        if (dt) {
            // fascicolo secondario
            protocolloGdmService.rimuoviFascicolo(dt, springSecurityService.principal.id, null)
            documentoTitolarioRepository.delete(dt)
            DocumentoTitolario dts = salvaFascicoloSecondario(documento, fascicoloDestinazione, classificazioneDestinazione)
            // allineo i dati su GDM
            protocolloGdmService.fascicolaTitolarioSecondario(dts)
        } else {
            // controllo fascicolo primario
            Protocollo protocollo = Protocollo.findByIdAndFascicolo(documento.id, fascicoloOriginario)
            if (protocollo) {
                protocollo.fascicolo = fascicoloDestinazione
                protocollo.save()
                protocolloGdmService.fascicola(protocollo)
            }
        }
    }

    private void setNumerazioneFascicolo(Fascicolo fascicolo, Integer anno, def titolario) {
        if (titolario instanceof Classificazione) {
            fascicolo.numero = classificazioneService.getNuovoNumeroSub(anno, fascicolo.classificazione)
        } else {
            // sub
            String sub = getNuovoNumeroSub(titolario.toDTO())
            fascicolo.numero = titolario.numero + ImpostazioniProtocollo.SEP_FASCICOLO.valore + sub
            fascicolo.idFascicoloPadre = titolario.id
            fascicolo.sub = sub?.toInteger()
        }
        fascicolo.anno = anno
        fascicolo.annoNumero = anno + "/" + fascicolo.numero?.toUpperCase()
        fascicolo.nome = anno + "/" + fascicolo.numero?.toUpperCase() + " - " + fascicolo.oggetto
        fascicolo.numeroOrd = numeroOrdinato(fascicolo.numero)
        fascicolo.numeroProssimoAnno = false
        fascicolo.save()
    }

    @Transactional(readOnly = true)
    boolean isVuoto(FascicoloDTO fascicolo) {
        List<Long> listaRicerca = []

        // protocolli con id_fascicolo
        List<Long> listaProtocolli = Protocollo.createCriteria().list() {
            projections {
                distinct("id")
            }
            eq("fascicolo.id", fascicolo.id)
        }

        // sub fascicoli
        List<Long> listaFascicoli = Fascicolo.createCriteria().list() {
            projections {
                distinct("id")
            }
            eq("idFascicoloPadre", fascicolo.id)
        }

        // documenti titolario
        List<Long> listaDocumentiTitolario = DocumentoTitolario.createCriteria().list() {
            projections {
                distinct("documento.id")
            }
            eq("fascicolo.id", fascicolo.id)
        }

        listaProtocolli.each {
            listaRicerca << it
        }
        listaFascicoli.each {
            listaRicerca << it
        }
        listaDocumentiTitolario.each {
            listaRicerca << it
        }

        if (listaRicerca.size() > 0) {
            return false
        } else {
            return true
        }
    }

    @Transactional(readOnly = true)
    boolean isUltimo(FascicoloDTO fascicolo) {

        // fascicolo non numerato
        if (!fascicolo?.numero) {
            return true
        }

        if (fascicolo.idFascicoloPadre) {
            // è un sub
            Fascicolo fascicoloPadre = Fascicolo.findById(fascicolo.idFascicoloPadre)
            if (fascicolo.sub == fascicoloPadre.sub) {
                return true
            }
        } else {
            // non è un sub
            List<Fascicolo> fascicoloList = fascicoloRepository.listFascicoliAfterNumero(fascicolo?.classificazione.domainObject, fascicolo?.anno, fascicolo?.numeroOrd)
            if (fascicoloList.size() == 0) {
                return true
            }
        }

        return false
    }

    @Transactional(readOnly = true)
    boolean isFuturo(FascicoloDTO fascicolo) {

        if (!fascicolo?.numero) {
            // fascicolo non numerato
            return true
        } else {
            if (fascicolo.dataApertura > new Date()) {
                return true
            }
        }

        return false
    }

    void elimina(Fascicolo fascicolo, boolean escludiControlloCompetenze = false) {
        try {
            // FIXME allineo il documento su gdm e tramite un trigger elimina anche su AGSPR
            protocolloGdmService.cancellaDocumento(fascicolo.idDocumentoEsterno.toString(), escludiControlloCompetenze)
        } catch (SQLException e) {
            throw new FascicoloRuntimeException(e)
        }
    }

    Pair<Integer, List<FascicoloDTO>> list(int pageSize, int activePage, Map filtriRicerca) {

        PagedResultList<Fascicolo> lista = Fascicolo.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
            Date now = new Date()
            now.clearTime()
            createAlias('soggetti', 'ds', CriteriaSpecification.INNER_JOIN)
            eq("ds.tipoSoggetto", TipoSoggetto.UO_COMPETENZA)

            // classifica
            if (filtriRicerca.classifica != "") {
                eq("classificazione.id", filtriRicerca.classifica)
            }

            // anno
            if (filtriRicerca.filtro == APERTI || filtriRicerca.filtro == CHIUSI) {
                if (filtriRicerca.annoFine == null && filtriRicerca.annoInizio != null) {
                    filtriRicerca.annoFine = filtriRicerca.annoInizio
                }
                if (filtriRicerca.annoInizio == null && filtriRicerca.annoFine != null) {
                    filtriRicerca.annoInizio = filtriRicerca.annoFine
                }
                if (filtriRicerca.annoInizio != null && filtriRicerca.annoFine != null) {
                    ge("anno", filtriRicerca.annoInizio)
                    le("anno", filtriRicerca.annoFine)
                }
            }
            if (filtriRicerca.filtro == 'TUTTI') {
                or {
                    and {
                        ge("anno", filtriRicerca.annoInizio)
                        le("anno", filtriRicerca.annoFine)
                    }
                    isNull("anno")
                }
            }

            // numero
            if (filtriRicerca.numeroInizio == "0000000" && filtriRicerca.numeroFine != "0000000") {
                filtriRicerca.numeroInizio = filtriRicerca.numeroFine
            }
            if (filtriRicerca.numeroFine == "0000000" && filtriRicerca.numeroInizio != "0000000") {
                filtriRicerca.numeroFine = filtriRicerca.numeroInizio
            }
            if (filtriRicerca.numeroInizio != "0000000" && filtriRicerca.numeroFine != "0000000") {
                ge("numeroOrd", filtriRicerca.numeroInizio)
                le("numeroOrd", filtriRicerca.numeroFine)
            }

            // oggetto
            if (filtriRicerca.oggetto != "" && filtriRicerca.oggetto != null) {
                ilike("oggetto", "%" + filtriRicerca.oggetto + "%")
            }

            // uo comptenza
            if (filtriRicerca.uoCompetenza != "" && filtriRicerca.uoCompetenza != null) {
                eq("ds.unitaSo4.progr", filtriRicerca.uoCompetenza)
            }

            // visualizzazione
            if (filtriRicerca.filtro == APERTI) {
                isNull("dataChiusura")
            }
            if (filtriRicerca.filtro == CHIUSI) {
                isNotNull("dataChiusura")
            }
            if (filtriRicerca.filtro == 'FUTURI') {
                or {
                    isNull("numero")
                    ge("dataApertura", new Date())
                }
            }

            order('anno', 'asc')
            order('numeroOrd', 'asc')
        }

        // Richiedono che nella ricerca vengano mostrato l'albero fino alla foglia che soddisfa il criterio di ricerca.
        List<Fascicolo> tempListFascicoliPadre = []
        List<Fascicolo> listTemp = []
        List<Fascicolo> listaPadri = []
        lista.findAll { it.idFascicoloPadre }.each {
            listaPadri = listPadri(it, listTemp)
            listaPadri.each {
                tempListFascicoliPadre << it
            }
            listaPadri.removeAll(listaPadri)
        }
        tempListFascicoliPadre.unique().each { fp ->
            if (!lista.collect { it.id }.contains(fp.id)) {
                lista << fp
            }
        }

        List<FascicoloDTO> listaDTO = lista.toDTO()

        return Pair.of(lista.totalCount, listaDTO)
    }

    @Transactional(readOnly = true)
    Long list(Map filtriRicerca) {

        Long lista = Fascicolo.createCriteria().count() {

            createAlias('soggetti', 'ds', CriteriaSpecification.INNER_JOIN)
            eq("ds.tipoSoggetto", TipoSoggetto.UO_COMPETENZA)

            // classifica
            if (filtriRicerca.classifica != "") {
                eq("classificazione.id", filtriRicerca.classifica)
            }

            // anno
            if (filtriRicerca.filtro == APERTI || filtriRicerca.filtro == CHIUSI) {
                if (filtriRicerca.annoFine == null && filtriRicerca.annoInizio != null) {
                    filtriRicerca.annoFine = filtriRicerca.annoInizio
                }
                if (filtriRicerca.annoInizio == null && filtriRicerca.annoFine != null) {
                    filtriRicerca.annoInizio = filtriRicerca.annoFine
                }
                if (filtriRicerca.annoInizio != null && filtriRicerca.annoFine != null) {
                    ge("anno", filtriRicerca.annoInizio)
                    le("anno", filtriRicerca.annoFine)
                }
            }
            if (filtriRicerca.filtro == 'TUTTI') {
                or {
                    and {
                        ge("anno", filtriRicerca.annoInizio)
                        le("anno", filtriRicerca.annoFine)
                    }
                    isNull("anno")
                }
            }

            // numero
            if (filtriRicerca.numeroInizio == "0000000" && filtriRicerca.numeroFine != "0000000") {
                filtriRicerca.numeroInizio = filtriRicerca.numeroFine
            }
            if (filtriRicerca.numeroFine == "0000000" && filtriRicerca.numeroInizio != "0000000") {
                filtriRicerca.numeroFine = filtriRicerca.numeroInizio
            }
            if (filtriRicerca.numeroInizio != "0000000" && filtriRicerca.numeroFine != "0000000") {
                ge("numeroOrd", filtriRicerca.numeroInizio)
                le("numeroOrd", filtriRicerca.numeroFine)
            }

            // oggetto
            if (filtriRicerca.oggetto != "" && filtriRicerca.oggetto != null) {
                ilike("oggetto", "%" + filtriRicerca.oggetto + "%")
            }

            // uo comptenza
            if (filtriRicerca.uoCompetenza != "" && filtriRicerca.uoCompetenza != null) {
                eq("ds.unitaSo4.progr", filtriRicerca.uoCompetenza)
            }

            // visualizzazione
            if (filtriRicerca.filtro == APERTI) {
                isNull("dataChiusura")
            }
            if (filtriRicerca.filtro == CHIUSI) {
                isNotNull("dataChiusura")
            }
            if (filtriRicerca.filtro == 'FUTURI') {
                or {
                    isNull("numero")
                    ge("dataApertura", new Date())
                }
            }
        }

        return lista
    }

    @Transactional(readOnly = true)
    List<Fascicolo> listPadri(Fascicolo fascicolo, List<Fascicolo> result) {
        Fascicolo f

        if (fascicolo.idFascicoloPadre) {
            f = fascicoloRepository.getFascicoloFromId(fascicolo.idFascicoloPadre)
            result << f

            if (f?.idFascicoloPadre) {
                listPadri(f, result)
            }
        }

        return result
    }

    @Transactional(readOnly = true)
    boolean verificaRicongiungiAFascicolo(Documento documento) {

        boolean haRicongiungiAFascicolo

        //se ho l'iter fascicoli abilitato
        if (ImpostazioniProtocollo.ITER_FASCICOLI.abilitato) {

            // e il documento ha un fascicolo
            if (documento?.fascicolo != null) {

                //Per il fascicolo uso una lista lo smistamento dovrebbe essere comunque solo uno.
                List<Smistamento> smistamentiPerCompetenzaFascicolo = estraiSmistamentiPerRicongiungimentoAFascicolo(documento.fascicolo)
                List<Smistamento> smistamentiPerCompetenzaDocumento = estraiSmistamentiPerRicongiungimentoAFascicolo(documento)

                //ASSTOT su una qualsiasi unità
                boolean privilegioAssTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VISUALIZZA_COMPONENTI_TUTTE_UNITA, springSecurityService.currentUser)

                for (Smistamento smistamentoFascicolo : smistamentiPerCompetenzaFascicolo) {
                    for (Smistamento smistamentoDocumento : smistamentiPerCompetenzaDocumento) {
                        if (smistamentoFascicolo.unitaSmistamento.progr == smistamentoDocumento.unitaSmistamento.progr &&
                                smistamentoFascicolo.unitaSmistamento.ottica.codice == smistamentoDocumento.unitaSmistamento.ottica.codice &&
                                smistamentoDocumento.unitaSmistamento.dal == smistamentoFascicolo.unitaSmistamento.dal) {
                            //Verifica privilegi ASSTOT
                            //oppure che ha l'utente ha il privilegio ASS sull'unità di smistamento del fascicolo
                            //oppure che sia l'assegnatario del documento
                            boolean haPrivilegioAssPerUfficioSmistamentoFascicolo = privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamentoFascicolo, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA)
                            boolean assegnatarioSmistamentoDocumento = smistamentoDocumento.utenteAssegnatario != null && (smistamentoDocumento.utenteAssegnatario?.id == springSecurityService.currentUser.id)
                            if (privilegioAssTot || haPrivilegioAssPerUfficioSmistamentoFascicolo || assegnatarioSmistamentoDocumento) {
                                haRicongiungiAFascicolo = true
                                break
                            }
                        }
                    }
                    if (haRicongiungiAFascicolo) {
                        break
                    }
                }
            }
        }

        return haRicongiungiAFascicolo
    }

    void ricongiungiAFascicolo(Documento documento) {

        //Per il fascicolo uso una lista lo smistamento dovrebbe essere comunque solo uno.
        List<Smistamento> smistamentiPerCompetenzaFascicolo = estraiSmistamentiPerRicongiungimentoAFascicolo(documento.fascicolo)
        List<Smistamento> smistamentiPerCompetenzaDocumento = estraiSmistamentiPerRicongiungimentoAFascicolo(documento)

        for (Smistamento smistamentoFascicolo : smistamentiPerCompetenzaFascicolo) {
            for (Smistamento smistamentoDocumento : smistamentiPerCompetenzaDocumento) {
                if (smistamentoFascicolo.unitaSmistamento.progr == smistamentoDocumento.unitaSmistamento.progr &&
                        smistamentoFascicolo.unitaSmistamento.ottica.codice == smistamentoDocumento.unitaSmistamento.ottica.codice &&
                        smistamentoDocumento.unitaSmistamento.dal == smistamentoFascicolo.unitaSmistamento.dal) {
                    DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
                    String dateString = format.format(new Date())
                    String noteMsg = "Smistamento storicizzato automaticamente in data " + dateString + " per ricongiungimento a Fascicolo " + documento.fascicolo.classificazione.codice + " - " + documento.fascicolo.numerazione
                    smistamentoDocumento.setNote(noteMsg)
                    smistamentoService.storicizzaSmistamento(smistamentoDocumento)
                }
            }
        }
    }

    void modificaUoCompetenza(Fascicolo fascicolo, So4UnitaPubb uoCompetenza) {
        DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
        String dateString = format.format(new Date())
        String noteMsg = ""

        List<Smistamento> smistamentiPerCompetenzaFascicolo = estraiSmistamentiPerRicongiungimentoAFascicolo(fascicolo)

        for (Smistamento smistamentoFascicolo : smistamentiPerCompetenzaFascicolo) {
            // creo smistamento
            Smistamento smistamentoNuovo = smistamentoService.creaSmistamento(fascicolo, Smistamento.COMPETENZA, fascicolo?.getSoggetto(TipoSoggetto.UO_CREAZIONE)?.unitaSo4, springSecurityService.currentUser, uoCompetenza, null, null)
            smistamentoNuovo.statoSmistamento = Smistamento.DA_RICEVERE
            noteMsg = "Smistamento creato automaticamente in data " + dateString + " per modifica dell'ufficio di compenteza del Fascicolo " + fascicolo.classificazione.codice + " - " + fascicolo.numerazione
            smistamentoNuovo.setNote(noteMsg)
            smistamentoService.prendiInCarico(fascicolo, springSecurityService.currentUser)
            // storicizzazione
            noteMsg = "Smistamento storicizzato automaticamente in data " + dateString + " per modifica dell'ufficio di compenteza del Fascicolo " + fascicolo.classificazione.codice + " - " + fascicolo.numerazione
            smistamentoFascicolo.setNote(noteMsg)
            smistamentoService.storicizzaSmistamento(smistamentoFascicolo)
        }
    }

    @Transactional(readOnly = true)
    List<Smistamento> estraiSmistamentiPerRicongiungimentoAFascicolo(ISmistabile smistabile) {
        Set<Smistamento> smistamentiAttivi = smistamentoService.getSmistamentiAttivi(smistabile)
        List<Smistamento> smistamentiAttiviPerCompetenza = smistamentoService.getSistamentiPerTipo(smistamentiAttivi.toList(), [Smistamento.COMPETENZA])
        return smistamentiAttiviPerCompetenza
    }

    Documento associaClassificaEFascicoloAProtocollo(Long idDocumento, Classificazione classifica, Fascicolo fascicolo) {

        Documento doc = Documento.get(idDocumento)
        if(doc.class == Protocollo.class){
            Protocollo p = (Protocollo) doc
            p.classificazione = classifica
            p.fascicolo = fascicolo
            protocolloService.salva(p, false, true, true, true)
        }
        if(doc.class == MessaggioRicevuto.class){
            MessaggioRicevuto m = (MessaggioRicevuto) doc
            m.classificazione = classifica
            m.fascicolo = fascicolo
            messaggiRicevutiService.salva(m)
        }

        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
            @Override
            void afterCommit() {
                protocolloGdmService.fascicola(doc, true)
            }
        })

        return doc
    }

    // Tipoologia soggetti
    @Transactional(readOnly = true)
    TipologiaSoggetto getTipologia() {
        return TipologiaSoggetto.findByTipoOggetto(WkfTipoOggetto.get("FASCICOLO"))
    }

    @Transactional(readOnly = true)
    Fascicolo getFascicoloPerWsFascicoliSecondari(String codiceClassifica, Integer anno, String numero, Long idEnte) {
        fascicoloRepository.getFascicoloPerWsFascicoliSecondari(codiceClassifica, anno, numero, idEnte)
    }

    @Transactional(readOnly = true)
    String iconcaFascicolo(Fascicolo fascicolo, boolean iterFascicolare) {
        if (iterFascicolare && isEsistonoDocumentiAltrove(fascicolo)) {
            if (fascicolo?.dataChiusura) {
                return '/images/ags/18x18/folderclose_red.png'
            } else {
                return '/images/ags/18x18/folder_red.png'
            }
        } else {
            if (fascicolo?.dataChiusura) {
                return '/images/icon/action/18x18/folderclose.png'
            } else {
                return '/images/icon/action/18x18/folder.png'
            }
        }
    }

    @Transactional(readOnly = true)
    boolean isEliminabile(FascicoloDTO fascicolo) {
        boolean eliminabile
        int presenzaDocumenti = 0

        if (fascicolo.idDocumentoEsterno) {
            if (fascicolo.numero && ((fascicolo.dataChiusura == null && privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_FASCICOLI_APERTI)) || (fascicolo.dataChiusura != null && privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_FASCICOLI_CHIUSI)))) {
                if (isUltimo(fascicolo)) {
                    if (fascicoloRepository.listSottoFascicoli(fascicolo.id).size() == 0) {
                        it.finmatica.smartdoc.api.struct.Documento documentoSmartFascicolo = protocolloGdmService.buildDocumentoSmart(fascicolo?.idDocumentoEsterno, false, true, true)
                        presenzaDocumenti = documentoSmartFascicolo.documentiFigli.findAll {
                            it.isFoglia()
                        }.size()
                        if (documentoSmartFascicolo && presenzaDocumenti == 0) {
                            return true
                        }
                    }
                }
            }
        }

        return eliminabile
    }

    @Transactional(readOnly = true)
    void eliminaFascicolo(FascicoloDTO fascicoloDTO) {
        classificazioneNumeroRepository.modificaUltimoNumeroFascicolo(fascicoloDTO.classificazione.domainObject, fascicoloDTO.anno)
        elimina(fascicoloDTO.domainObject)
    }

    @Transactional(readOnly = true)
    String getUbicazione (FascicoloDTO fascicoloDTO, boolean codice) {
        if (codice) {
            return fascicoloRepository.getUbicazioneCodice(fascicoloDTO.id)
        } else {
            return fascicoloRepository.getUbicazione(fascicoloDTO.id)
        }
    }
}