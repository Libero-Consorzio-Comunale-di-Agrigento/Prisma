package it.finmatica.protocollo.documenti

import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.integrazioni.ricercadocumenti.DocumentoEsterno
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.protocollo.zk.utils.PaginationUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

import it.finmatica.gestionedocumenti.deleghe.Delega
import it.finmatica.gestionedocumenti.deleghe.DelegaService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.beans.FileDownloader
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.viste.DocumentoStep
import it.finmatica.protocollo.documenti.viste.DocumentoStepDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.so4.login.So4SpringSecurityService
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.login.So4UserDetailService
import org.hibernate.criterion.CriteriaSpecification
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.transaction.annotation.Transactional

import java.text.SimpleDateFormat

@Transactional
@Service
class DocumentoStepDTOService {

    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    So4SpringSecurityService springSecurityService
    @Autowired
    So4UserDetailService userDetailsService
    @Autowired
    FileDownloader fileDownloader
    @Autowired
    DelegaService delegaService
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService

    def inCaricoProtoPec(schemaProtocollo, delegante, statiFirma, String casella, Date dataDal, Date dataAl, String tipoMessaggio, String mittente,
                         int pageSize, int activePage, orderMap, boolean sortContrario) {
        So4UserDetail so4User = null
        // gestiamo le tipologie nel caso in cui ci sia una delega
        def deleghe

        String ordinamentoMittenteProtocollo = null

        if (delegante != null && delegante.nominativo != null && delegante.nominativo != "") {
            so4User = userDetailsService.loadUserByUsername(delegante.nominativo)
            so4User.setOtticaCorrente(springSecurityService.getPrincipal().getOttica())
            deleghe = delegaService.getDeleghe(springSecurityService.currentUser, delegante.domainObject)
        }

        // numeri contenuti nella stringa di ricerca
        // Integer searchNumbers = search.replaceAll("\\D+", "") != "" ? new Integer(search.replaceAll("\\D+", "")) : null

        // risultato query
        List<DocumentoStepDTO> resultQuery = DocumentoStep.createCriteria().list {

            createAlias("protocollo", "p", CriteriaSpecification.INNER_JOIN)
            createAlias("messaggioRicevuto", "mr", CriteriaSpecification.INNER_JOIN)
            createAlias("p.schemaProtocollo", "sc", CriteriaSpecification.LEFT_JOIN)

            projections {
                groupProperty("idDocumento")            // 0
                groupProperty("stato")                  // 1
                groupProperty("statoFirma")             // 2
                groupProperty("statoConservazione")     // 3
                groupProperty("stepNome")               // 4
                groupProperty("stepDescrizione")        // 5
                groupProperty("stepTitolo")             // 6
                groupProperty("tipoOggetto")            // 7
                groupProperty("tipoRegistro")           // 8
                groupProperty("riservato")              // 9
                groupProperty("oggetto")                // 10
                groupProperty("anno")                   // 11
                groupProperty("numero")                 // 12
                groupProperty("idTipologia")            // 13
                groupProperty("titoloTipologia")        // 14
                groupProperty("descrizioneTipologia")   // 15
                groupProperty("lastUpdated")             // 16
                groupProperty("mr.id")   // 17
                groupProperty("mr.mittente")   // 18
                groupProperty("p.movimento")   // 19
                groupProperty("p.classificazione")   // 20
                groupProperty("p.fascicolo")   // 21
                groupProperty("mr.dataSpedizione")   // 22
            }

            and {
                /*if (so4User == null) {
                    DocumentoStepDTOService.controllaCompetenze(delegate)(springSecurityService.principal)
                } else {
                    DocumentoStepDTOService.controllaCompetenze(delegate)(so4User)
                }*/

                isNull("numero")

                if (schemaProtocollo != null && schemaProtocollo.codice != "") {
                    eq("sc.codice", schemaProtocollo.codice)
                }

                if (deleghe) {
                    or {
                        for (Delega delega : deleghe) {
                            and {
                                if (delega.tipologia != null) {
                                    eq("sc.codice", delega.tipologia)
                                }
                                if (delega.progressivoUnita != null && delega.codiceOttica != null) {
                                    def unita = So4UnitaPubb.getUnita(delega.progressivoUnita, delega.codiceOttica)?.get()
                                    if (unita) {
                                        eq("unitaProtocollante", unita)
                                    }
                                }
                            }
                        }
                    }
                }

                if (statiFirma != null) {
                    'in'("statoFirma", statiFirma*.toString())
                }
                /*or {
                    ilike("oggetto", "%" + search + "%")
                    ilike("titoloTipologia", "%" + search + "%")
                    if (searchNumbers != null) {
                        eq("numero", searchNumbers)
                    }
                }*/

                if (casella != null) {
                    ilike("mr.destinatari", "%" + casella + "%")
                }
                if (dataDal != null) {
                    ge("mr.dataRicezione", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(new SimpleDateFormat("dd/MM/yyyy").format(dataDal) + " 00:00:00"))
                }
                if (dataAl != null) {
                    le("mr.dataRicezione", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(new SimpleDateFormat("dd/MM/yyyy").format(dataAl) + " 23:59:59"))
                }
                if (!tipoMessaggio.equals(MessaggiRicevutiService._ITEM_TUTTI)) {
                    if (tipoMessaggio.equals(MessaggiRicevutiService._ITEM_TIPO_POSTA_CERTIFICATA)) {
                        eq("mr.tipo", "PEC")
                    } else {
                        eq("mr.tipo", "NONPEC")
                    }
                }
                if (mittente != null) {
                    ilike("mr.mittente", "%" + mittente + "%")
                }
            }

            if (orderMap != null) {
                for (orderEntry in orderMap) {
                    String key = orderEntry.key
                    if (orderEntry.key == 'mittentiProtocollo') {
                        ordinamentoMittenteProtocollo = orderEntry.value
                        break
                    }

                    if (orderEntry.key == 'classificazione' || orderEntry.key == 'fascicolo' || orderEntry.key == 'movimento') {
                        key = "p." + key
                    } else if (orderEntry.key == 'mittente' || orderEntry.key == 'dataSpedizione') {
                        key = "mr." + key
                    }
                    order key, orderEntry.value
                }
            } else {
                order("mr.dataSpedizione", sortContrario ? "asc" : "desc")
            }
        }.collect { row ->
            new DocumentoStepDTO(
                    idDocumento: row[0]
                    , stato: row[1]
                    , statoFirma: row[2]
                    , statoConservazione: row[3]
                    , stepNome: row[4]
                    , stepDescrizione: row[5]
                    , stepTitolo: row[6]
                    , tipoOggetto: row[7]
                    , tipoRegistro: row[8]
                    , riservato: row[9]
                    , oggetto: row[10]
                    , anno: row[11]
                    , numero: row[12]
                    , idTipologia: row[13]
                    , titoloTipologia: row[14]
                    , descrizioneTipologia: row[15]
                    , lastUpdated: row[16]
                    , messaggioRicevuto: new MessaggioRicevutoDTO(id: row[17], mittente: row[18])
                    , protocollo: new ProtocolloDTO(id: row[0], movimento: row[19], classificazione: row[20]?.toDTO(), fascicolo: row[21]?.toDTO()),
                    dataSpedizione: row[22]

            )
        }
        def exportOptions = [idDocumento           : [esportabile: false, label: 'ID', index: -1, columnType: 'NUMBER']
                             , stato               : [esportabile: false, label: 'Stato', index: -1, columnType: 'TEXT']
                             , statoFirma          : [esportabile: false, label: 'Stato Firma', index: -1, columnType: 'TEXT']
                             , statoConservazione  : [esportabile: false, label: 'Stato Conservazione', index: -1, columnType: 'TEXT']
                             , stepNome            : [esportabile: false, label: 'Step Nome', index: -1, columnType: 'TEXT']
                             , stepDescrizione     : [esportabile: false, label: 'Step Descrizione', index: -1, columnType: 'TEXT']
                             , stepTitolo          : [esportabile: false, label: 'Step Titolo', index: -1, columnType: 'TEXT']
                             , tipoOggetto         : [esportabile: false, label: 'Tipo Oggetto', index: -1, columnType: 'TEXT']
                             , tipoRegistro        : [esportabile: false, label: 'Tipo Registro', index: -1, columnType: 'TEXT']
                             , riservato           : [esportabile: false, label: 'Riservato', index: -1, columnType: 'TEXT']
                             , oggetto             : [esportabile: true, label: 'Oggetto', index: 1, columnType: 'TEXT']
                             , anno                : [esportabile: false, label: 'Anno', index: -1, columnType: 'NUMBER']
                             , numero              : [esportabile: false, label: 'Numero', index: -1, columnType: 'NUMBER']
                             , idTipologia         : [esportabile: false, label: 'ID Tipologia', index: -1, columnType: 'TEXT']
                             , titoloTipologia     : [esportabile: false, label: 'Tipologia', index: -1, columnType: 'TEXT']
                             , descrizioneTipologia: [esportabile: false, label: 'Tipologia', index: -1, columnType: 'TEXT']
                             , lastUpdated         : [esportabile: false, label: 'Ultima Modifica', index: -1, columnType: 'DATE']
                             , mittentiProtocollo  : [esportabile: true, label: 'Mittente', index: 2, columnType: 'TEXT']
                             , dataSpedizione      : [esportabile: true, label: 'Data Spedizione', index: 0, columnType: 'DATE']
                             , mittenti            : [esportabile: true, label: 'Email Mittente', index: 3, columnType: 'TEXT']
        ]

        List<DocumentoStepDTO> result = new ArrayList<DocumentoStepDTO>()
        for (documentoStepDto in resultQuery) {
            Protocollo protocollo = Protocollo.findById(documentoStepDto.idDocumento)
            Map competenzeProtocollo = gestoreCompetenze.getCompetenze(protocollo)
            if (competenzeProtocollo?.lettura) {
                String mittenti = ""
                documentoStepDto.mittente = null
                if (protocollo.corrispondenti?.size() > 0) {

                    for (corrispondente in protocollo.corrispondenti) {
                        if (!mittenti.equals("")) {
                            mittenti += "\n"
                        }
                        mittenti += corrispondente.denominazione + ((corrispondente.email == null) ? "" : (" " + corrispondente.email))
                    }
                }

                if (mittenti != "") {
                    documentoStepDto.mittentiProtocollo = mittenti
                }

                result.add(documentoStepDto)
            }
        }

        if (ordinamentoMittenteProtocollo != null) {
            result.sort { a, b ->
                a.mittentiProtocollo == null ? b.mittentiProtocollo == null ? 0 : 1 : b.mittentiProtocollo == null ? -1 : a.mittentiProtocollo <=> b.mittentiProtocollo
            }
            if (ordinamentoMittenteProtocollo.equals("desc")) {
                result.reverse()
            }
        }
        int total = result.size()
        result = PaginationUtils.getPaginationObject(result, pageSize, activePage)

        return [total: total, result: result, exportOptions: exportOptions]
    }

    // il campo sort contrario serve ad ordinare i documenti dal più vecchio al più recente
    def inCarico(String search, tipiOggetto, tipoRegistro, schemaProtocollo, delegante, statiFirma, int pageSize, int activePage, orderMap, boolean sortContrario, boolean tutti = false) {

        So4UserDetail so4User = null
        // gestiamo le tipologie nel caso in cui ci sia una delega
        def deleghe

        if (delegante != null && delegante.nominativo != null && delegante.nominativo != "") {
            so4User = userDetailsService.loadUserByUsername(delegante.nominativo)
            so4User.setOtticaCorrente(springSecurityService.getPrincipal().getOttica())
            deleghe = delegaService.getDeleghe(springSecurityService.currentUser, delegante.domainObject)
        }

        // numeri contenuti nella stringa di ricerca
        Integer searchNumbers = search.replaceAll("\\D+", "") != "" ? new Integer(search.replaceAll("\\D+", "")) : null

        // risultato query
        def result = DocumentoStep.createCriteria().list {

            createAlias("protocollo", "p", CriteriaSpecification.INNER_JOIN)
            createAlias("p.schemaProtocollo", "sc", CriteriaSpecification.LEFT_JOIN)
            createAlias("messaggioRicevuto", "mr", CriteriaSpecification.LEFT_JOIN)

            projections {
                groupProperty("idDocumento")            // 0
                groupProperty("stato")                  // 1
                groupProperty("statoFirma")             // 2
                groupProperty("statoConservazione")     // 3
                groupProperty("stepNome")               // 4
                groupProperty("stepDescrizione")        // 5
                groupProperty("stepTitolo")             // 6
                groupProperty("tipoOggetto")            // 7
                groupProperty("tipoRegistro")           // 8
                groupProperty("riservato")              // 9
                groupProperty("oggetto")                // 10
                groupProperty("anno")                   // 11
                groupProperty("numero")                 // 12
                groupProperty("idTipologia")            // 13
                groupProperty("titoloTipologia")        // 14
                groupProperty("descrizioneTipologia")   // 15
                groupProperty("lastUpdated")             // 16
                groupProperty("mr.id")   // 17
            }

            and {
                if (so4User == null) {
                    DocumentoStepDTOService.controllaCompetenze(delegate)(springSecurityService.principal)
                } else {
                    DocumentoStepDTOService.controllaCompetenze(delegate)(so4User)
                }

                or {
                    isNull("mr.id")

                    and {
                        isNotNull("mr.id")
                        isNotNull("numero")
                    }
                }

                if (tipiOggetto != null && tipiOggetto.size() > 0) {
                    'in'("tipoOggetto", tipiOggetto)
                }

                if (tipoRegistro != null && tipoRegistro.size() > 0) {
                    'in'("tipoRegistro", tipoRegistro)
                }

                if (schemaProtocollo != null && schemaProtocollo.codice != "") {
                    eq("sc.codice", schemaProtocollo.codice)
                }

                if (deleghe) {
                    or {
                        for (Delega delega : deleghe) {
                            and {
                                if (delega.tipologia != null) {
                                    eq("sc.codice", delega.tipologia)
                                }
                                if (delega.progressivoUnita != null && delega.codiceOttica != null) {
                                    def unita = So4UnitaPubb.getUnita(delega.progressivoUnita, delega.codiceOttica)?.get()
                                    if (unita) {
                                        eq("unitaProtocollante", unita)
                                    }
                                }
                            }
                        }
                    }
                }

                if (statiFirma != null) {
                    'in'("statoFirma", statiFirma*.toString())
                }
                or {
                    ilike("oggetto", "%" + search + "%")
                    ilike("titoloTipologia", "%" + search + "%")
                    if (searchNumbers != null) {
                        eq("numero", searchNumbers)
                    }
                }
            }
            if (orderMap != null) {
                orderMap.each { k, v -> order k, v }
            } else {
                order("anno", sortContrario ? "asc" : "desc")
                order("numero", sortContrario ? "asc" : "desc")
            }

            if (!tutti) {
                firstResult(pageSize * activePage)
                maxResults(pageSize)
            }
        }.collect { row ->
            new DocumentoStepDTO(
                    idDocumento: row[0]
                    , stato: row[1]
                    , statoFirma: row[2]
                    , statoConservazione: row[3]
                    , stepNome: row[4]
                    , stepDescrizione: row[5]
                    , stepTitolo: row[6]
                    , tipoOggetto: row[7]
                    , tipoRegistro: row[8]
                    , riservato: row[9]
                    , oggetto: row[10]
                    , anno: row[11]
                    , numero: row[12]
                    , idTipologia: row[13]
                    , titoloTipologia: row[14]
                    , descrizioneTipologia: row[15]
                    , lastUpdated: row[16]
                    , messaggioRicevuto: new MessaggioRicevutoDTO(id: row[17])

            )
        }
        def exportOptions = [idDocumento           : [esportabile: false, label: 'ID', index: -1, columnType: 'NUMBER']
                             , stato               : [esportabile: false, label: 'Stato', index: -1, columnType: 'TEXT']
                             , statoFirma          : [esportabile: false, label: 'Stato Firma', index: -1, columnType: 'TEXT']
                             , statoConservazione  : [esportabile: false, label: 'Stato Conservazione', index: -1, columnType: 'TEXT']
                             , stepNome            : [esportabile: false, label: 'Step Nome', index: -1, columnType: 'TEXT']
                             , stepDescrizione     : [esportabile: false, label: 'Step Descrizione', index: -1, columnType: 'TEXT']
                             , stepTitolo          : [esportabile: true, label: 'Step Titolo', index: 4, columnType: 'TEXT']
                             , tipoOggetto         : [esportabile: false, label: 'Tipo Oggetto', index: -1, columnType: 'TEXT']
                             , tipoRegistro        : [esportabile: false, label: 'Tipo Registro', index: -1, columnType: 'TEXT']
                             , riservato           : [esportabile: false, label: 'Riservato', index: -1, columnType: 'TEXT']
                             , oggetto             : [esportabile: true, label: 'Oggetto', index: 3, columnType: 'TEXT']
                             , anno                : [esportabile: true, label: 'Anno', index: 2, columnType: 'NUMBER']
                             , numero              : [esportabile: true, label: 'Numero', index: 1, columnType: 'NUMBER']
                             , idTipologia         : [esportabile: false, label: 'ID Tipologia', index: -1, columnType: 'TEXT']
                             , titoloTipologia     : [esportabile: true, label: 'Tipologia', index: 0, columnType: 'TEXT']
                             , descrizioneTipologia: [esportabile: false, label: 'Tipologia', index: -1, columnType: 'TEXT']
                             , lastUpdated         : [esportabile: false, label: 'Ultima Modifica', index: -1, columnType: 'DATE']
        ]
        // totale di righe
        def total = DocumentoStep.createCriteria().count() {

            createAlias("protocollo", "p", CriteriaSpecification.INNER_JOIN)
            createAlias("p.schemaProtocollo", "sc", CriteriaSpecification.LEFT_JOIN)

            projections {
                groupProperty("idDocumento")
            }

            and {
                if (so4User == null) {
                    DocumentoStepDTOService.controllaCompetenze(delegate)(springSecurityService.principal)
                } else {
                    DocumentoStepDTOService.controllaCompetenze(delegate)(so4User)
                }

                if (tipiOggetto != null && tipiOggetto.size() > 0) {
                    'in'("tipoOggetto", tipiOggetto)
                }

                if (tipoRegistro != null && tipoRegistro.size() > 0) {
                    'in'("tipoRegistro", tipoRegistro)
                }

                if (schemaProtocollo != null && schemaProtocollo.codice != "") {
                    eq("sc.codice", schemaProtocollo.codice)
                }

                if (deleghe) {
                    or {
                        for (Delega delega : deleghe) {
                            and {
                                if (delega.tipologia != null) {
                                    eq("sc.codice", delega.tipologia)
                                }
                                if (delega.progressivoUnita != null && delega.codiceOttica != null) {
                                    def unita = So4UnitaPubb.getUnita(delega.progressivoUnita, delega.codiceOttica)?.get()
                                    if (unita) {
                                        eq("unitaProtocollante", unita)
                                    }
                                }
                            }
                        }
                    }
                }

                if (statiFirma != null) {
                    'in'("statoFirma", statiFirma*.toString())
                }
                or {
                    ilike("oggetto", "%" + search + "%")
                    ilike("titoloTipologia", "%" + search + "%")
                    if (searchNumbers != null) {
                        eq("numero", searchNumbers)
                    }
                }
            }
        }

        return [total: total, result: result, exportOptions: exportOptions]
    }

    /**
     * Criterio di controllo dell'incarico nella wkf_engine_step (appiattita nella vista documenti step):
     *
     *  1) utente indicato pari all'utente loggato (chiamato successivamente #delegate)
     *  2) per ogni uo di #delegate (successivamente indicata come #uoiesima) verifico che
     * 		a) l'unità indicata è #uoiesima e il ruolo è nullo
     * 		b) per ogni ruolo che #delegate ha nella #uoiesima (successivamente chiamato #ruoloiesimo) verifico che
     * 			->  l'unità è nulla o pari a #uoiesima e il ruolo sia pari a #ruoloiesimo
     *
     *  NB1: non è consentito avere uo, ruolo, utente tutti nulli per indicare con competenze a tutti altrimenti la query è lentissima
     * 	NB2: query ottimizzata grazie agli indici!
     *
     * @param delegate
     * @return
     */
    static controllaCompetenze(delegate) {
        return ProtocolloGestoreCompetenze.controllaCompetenze(delegate, "stepUtente", "stepUnita", "stepRuolo")
    }

    /*
     * METODI PER POPOLARE I MENU POPUP DEGLI ALLEGATI E VISTI DI UN DOCUMENTO
     */

    def caricaAllegatiDocumento(long idDocumento, String tipoOggetto) {
        def listaAllegati
        switch (tipoOggetto) {
            case Protocollo.TIPO_DOCUMENTO:
                listaAllegati = caricaAllegatiProtocollo(idDocumento)
                break
            default:
                throw new ProtocolloRuntimeException("Attenzione: tipo di documento ${tipoOggetto} non riconosciuto.")
                break
        }

        if (listaAllegati == null) {
            listaAllegati = []
        }

        if (listaAllegati.size() == 0) {
            listaAllegati.add([titolo: "Nessun File", idFileAllegato: -1, idDocumento: -1, classeDoc: null])
        }

        return listaAllegati
    }

    private caricaAllegatiProtocollo(long idDocumento) {
        def listaAllegati = []

        Protocollo protocollo = Protocollo.get(idDocumento)

        if (protocollo?.filePrincipale != null && (!protocollo.riservato || gestoreCompetenze.utenteCorrenteVedeRiservato(protocollo))) {
            listaAllegati.add([titolo: "Testo", idFileAllegato: protocollo.filePrincipale.id, idDocumento: protocollo.id, classeDoc: Protocollo])
        }

        return listaAllegati
    }

    void downloadFileAllegato(value) {
        // leggo la classe del documento
        if (value.idFileAllegato == -1) {
            // se viene cliccato nessun file allora non viene restituito nulla
            return
        }
        FileDocumento fAllegato = FileDocumento.createCriteria().get() {
            eq("id", value.idFileAllegato)
        }
        fileDownloader.downloadFileAllegato(new DocumentoEsterno(), fAllegato)
    }
}