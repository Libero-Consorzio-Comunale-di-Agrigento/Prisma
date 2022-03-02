package it.finmatica.protocollo.impostazioni

import commons.PopupImportAllegatiEmailViewModel
import commons.PopupImportAllegatiViewModel
import commons.PopupInvioPecViewModel
import commons.PopupNotificaEccezioneViewModel
import commons.PopupRichiediAnnullamentoViewModel
import commons.PopupRiferimentiTelematiciViewModel
import commons.PopupRifiutaSmistamentoViewModel
import commons.PopupScegliUnitaCaricoEseguiViewModel
import commons.PopupSceltaTipologiaViewModel
import commons.menu.MenuItemProtocollo
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.gestionetesti.TipoFile
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.StampaUnicaService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.integrazioni.segnatura.interop.SegnaturaInteropService
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.utils.FileInputStreamDeleteOnClose
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import org.apache.commons.io.IOUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.bind.annotation.Command
import org.zkoss.zhtml.Filedownload
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import javax.sql.DataSource

@CompileStatic
@Transactional
@Service
class FunzioniService {

    @Autowired
    AllegatoProtocolloService allegatoProtocolloService
    @Autowired
    PreferenzeUtenteService preferenzeUtenteService
    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    TipoProtocolloService tipoProtocolloService
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    GestioneDocumentiSpringSecurityService springSecurityService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    StampaUnicaService stampaUnicaService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    SegnaturaInteropService segnaturaInteropService
    @Autowired
    WkfIterService wkfIterService
    @Autowired
    DataSource dataSource
    @Autowired
    MailService mailService

    @Value("\${finmatica.protocollo.jasper.jdbcNameGdm}")
    String jdbcNameGdm

    void onNuovo(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        Window w = ProtocolloViewModel.apriPopup(CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codice)
        w.addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void onNuovoDaFascicolare(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        Window w = ProtocolloViewModel.apriPopup(CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice)
        w.addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void onNuovaLettera(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        Window w = ProtocolloViewModel.apriPopup(CategoriaProtocollo.CATEGORIA_LETTERA.codice)
        w.addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void onStampaProtocollo(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        openPopupStampa("StampaDocumento", [ANNO: protocollo.anno, NUMERO: protocollo.numero, TIPO_REGISTRO: protocollo.tipoRegistro?.codice])
    }

    void onStampaBc(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        if (preferenzeUtenteService.abilitaStampaBcDiretta) {
            openPopupStampaDiretta(preferenzeUtenteService.reportTimbro, [ID_DOCUMENTO_PROTOCOLLO: protocollo.idDocumentoEsterno, STAMPANTE: "rra1"])
        } else {
            openPopupStampa(preferenzeUtenteService.reportTimbro, [ID_DOCUMENTO_PROTOCOLLO: protocollo.idDocumentoEsterno])
        }
    }

    void onStampaBcAllegato(AllegatoDTO allegato) {
        it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()
        documentoSmart.setId(String.valueOf(allegato.idDocumentoEsterno))
        documentoSmart = documentaleService.getDocumento(documentoSmart, new ArrayList<Documento.COMPONENTI>())
        //AREA e CM sono costanti valutare una classe dove metterli o verificare se sono già censiti
        String codiceRichiesta = documentoSmart.getMappaChiaviExtra().get("CODICE_RICHIESTA")
        openPopupStampaAllegato(preferenzeUtenteService.reportTimbroAllegatoBc, [AREA: "SEGRETERIA", CM: "M_ALLEGATO_PROTOCOLLO", CR: codiceRichiesta])
    }

    void onStampaRicevuta(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        if (preferenzeUtenteService.abilitaStampaRicevutaDiretta) {
            openPopupStampaDiretta("Ricevuta", [ANNO: protocollo.anno, NUMERO: protocollo.numero, TIPO_REGISTRO: protocollo.tipoRegistro?.codice, STAMPANTE: "rra2"])
        } else {
            openPopupStampa("Ricevuta", [ANNO: protocollo.anno, NUMERO: protocollo.numero, TIPO_REGISTRO: protocollo.tipoRegistro?.codice])
        }
    }

    void onStampaPassaggi(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        openPopupStampa("Smistamenti_iter_fascicoli", [ID_DOCUMENTO_PROTOCOLLO: protocollo.idDocumentoEsterno])
    }

    void creaInoltro(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        ProtocolloDTO inoltro = protocolloService.creaInoltro(protocollo.domainObject)
        ProtocolloViewModel.apriPopup(inoltro).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void creaInoltroConLettera(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        List<TipoProtocolloDTO> tipiProtocollo = tipoProtocolloService.tipologiePerCompetenza(CategoriaProtocollo.CATEGORIA_LETTERA.codice)
        if (tipiProtocollo.size() == 1) {
            apriCreaInoltroConLettera(menuItemProtocollo, protocollo.domainObject, tipiProtocollo[0].domainObject)
        } else {
            PopupSceltaTipologiaViewModel.apriPopup(menuItemProtocollo.getParent()
                    , CategoriaProtocollo.CATEGORIA_LETTERA.codice
                    , tipiProtocollo).addEventListener(Events.ON_CLOSE) { Event event ->
                if (event.data instanceof TipoProtocolloDTO) {
                    TipoProtocolloDTO tipoProtocolloDTO = (TipoProtocolloDTO) event.data
                    apriCreaInoltroConLettera(menuItemProtocollo, protocollo.domainObject, tipoProtocolloDTO.domainObject)
                }
            }
        }
    }

    private void apriCreaInoltroConLettera(MenuItemProtocollo menuItemProtocollo, Protocollo protocollo, TipoProtocollo tipoProtocollo) {
        ProtocolloDTO inoltro = protocolloService.creaInoltroConLettera(protocollo, tipoProtocollo)
        ProtocolloViewModel.apriPopup(inoltro).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void copiaProtocollo(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        ProtocolloDTO copia = protocolloService.copia(protocollo.domainObject)
        Window w = ProtocolloViewModel.apriPopup(copia, copia.categoriaProtocollo.codice)
        w.addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void onInvioPec(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        if (protocollo.statoFirma?.firmaInterrotta) {
            ClientsUtils.showError("Attenzione! Il documento non è in firma: non è possibile inviare")
            return
        }
        PopupInvioPecViewModel.apriPopup(protocollo).addEventListener(Events.ON_CLOSE) {
            wkfIterService.sbloccaDocumento(protocollo.domainObject)
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void onPrendiIncarico(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(protocollo, MenuItemProtocollo.CARICO).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void onPrendiIncaricoEsegui(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(protocollo, MenuItemProtocollo.CARICO_ESEGUI).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void onEsegui(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(protocollo, MenuItemProtocollo.FATTO).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void onRisposta(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        ProtocolloDTO copia = protocolloService.rispondi(protocollo.domainObject)
        ProtocolloViewModel.apriPopup(copia).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void onRispostaConLettera(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        List<TipoProtocolloDTO> tipiProtocollo = tipoProtocolloService.tipologiePerCompetenza(CategoriaProtocollo.CATEGORIA_LETTERA.codice).findAll {
            Protocollo.MOVIMENTO_PARTENZA.equals(it.movimento)
        }
        PopupSceltaTipologiaViewModel.apriPopup(menuItemProtocollo.getParent()
                , CategoriaProtocollo.CATEGORIA_LETTERA.codice
                , tipiProtocollo).addEventListener(Events.ON_CLOSE) { Event event ->
            if (event.data instanceof TipoProtocolloDTO) {
                TipoProtocolloDTO tipoProtocolloDTO = (TipoProtocolloDTO) event.data
                apriRispondiConLettera(menuItemProtocollo, protocollo.domainObject, tipoProtocolloDTO.domainObject)
            }
        }
    }

    void onImportaRiferimentiTelematici(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupRiferimentiTelematiciViewModel.apriPopup(null, protocollo).addEventListener(Events.ON_OK) {
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void onVisualizzaSegnatura(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        String xmlSegnatura
        xmlSegnatura = segnaturaInteropService.produciSegnatura(protocollo.domainObject, true, true, true)

        Filedownload.save(IOUtils.toByteArray(xmlSegnatura), "application/xml", "segnatura.xml")
    }

    private void apriRispondiConLettera(MenuItemProtocollo menuItemProtocollo, Protocollo protocollo, TipoProtocollo tipoProtocollo) {
        ProtocolloDTO risposta = protocolloService.rispondiConLettera(protocollo, tipoProtocollo)
        ProtocolloViewModel.apriPopup(risposta).addEventListener(Events.ON_CLOSE) {
            menuItemProtocollo.fireOnClose()
        }
        menuItemProtocollo.fireOnHide()
    }

    void scaricaScampaUnica(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        Protocollo p = protocollo.domainObject
        File file = stampaUnicaService.getStampaUnicaProtocollo(p)
        protocollo.version = p.version
        if (!file) {
            throw new ProtocolloRuntimeException("Non è possibile creare la stampa unica")
        }
        Filedownload.save(new FileInputStreamDeleteOnClose(file), TipoFile.PDF.contentType, p.nomeFileStampaUnica)
    }

    void scaricaZipAllegati(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        if (protocolloService.isFileDoppiPresenti(protocollo.domainObject)) {
            Messagebox.show("Esistono dei file con lo stesso nome. Vuoi comunque creare lo zip? " +
                    "Per i file con lo stesso nome verrà riportato nello zip solo il primo utile",
                    "Attenzione!",
                    Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                    new org.zkoss.zk.ui.event.EventListener() {
                        void onEvent(Event e) {
                            if (Messagebox.ON_OK.equals(e.getName())) {
                                File fileZip = protocolloService.creaFileZipAllegati(protocollo.domainObject)
                                Filedownload.save(new FileInputStreamDeleteOnClose(fileZip), "applicazion/zip", fileZip.name)
                            }
                        }
                    }
            )
        } else {
            File fileZip = protocolloService.creaFileZipAllegati(protocollo.domainObject)
            Filedownload.save(new FileInputStreamDeleteOnClose(fileZip), "applicazion/zip", fileZip.name)
        }
    }

    void onAnnullamento(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        annullamento(menuItemProtocollo, protocollo, false)
    }

    void onAnnullamentoDiretto(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        if (gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO)) {
            annullamento(menuItemProtocollo, protocollo, true)
        } else {
            ClientsUtils.showError("Non hai i privilegi per l'Annullamento del Protocollo")
        }
    }

    void onRifiutaSmistamento(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupRifiutaSmistamentoViewModel.apriPopup(protocollo).addEventListener(Events.ON_CLOSE) { Event event ->
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void apriNotificaEccezione(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupNotificaEccezioneViewModel.apriPopup(protocollo).addEventListener(Events.ON_CLOSE) { Event event ->
            if (!ImpostazioniProtocollo.PROTOCOLLA_NOT_ECC.abilitato) {
                menuItemProtocollo.fireOnClose()
            } else {
                menuItemProtocollo.fireOnAggiornaMaschera()
            }
        }
    }

    void inviaRicevuta(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        mailService.inviaRicevuta(protocollo.domainObject)
        ClientsUtils.showInfo("Ricevuta Inviata")
    }

    void apriImportaAllegatiEmail(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupImportAllegatiEmailViewModel.apriPopup(menuItemProtocollo, protocollo, true).addEventListener(Events.ON_CLOSE) { Event event ->
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void importaAllegatiDocumentale(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        PopupImportAllegatiViewModel.apriPopup(menuItemProtocollo, protocollo).addEventListener(Events.ON_CLOSE) { Event event ->
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void scaricaEmailOriginale(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo) {
        InputStream inputStream = allegatoProtocolloService.getStreamEmailOriginale(protocollo.domainObject)
        Filedownload.save(inputStream, "message/rfc822", "email.eml")
    }

    private void annullamento(MenuItemProtocollo menuItemProtocollo, ProtocolloDTO protocollo, boolean diretto) {
        PopupRichiediAnnullamentoViewModel.apriPopup(protocollo, diretto).addEventListener(Events.ON_CLOSE) { Event event ->
            menuItemProtocollo.fireOnAggiornaMaschera()
        }
    }

    void onStampaReportFascicoli(String report, Map params) {
        openPopupStampa(report, params)
    }

    @CompileDynamic
    private void openPopupStampa(String reportName, Map params) {
        String url = "/../jasperserver4/jasperservlet?project=jprotocollostampe&report=${reportName}&conn=${jdbcNameGdm}&" + mapToUrl(params)
        Clients.evalJavaScript(" window.open('" + url + "'); ")
    }

    @CompileDynamic
    private void openPopupStampaAllegato(String reportName, Map params) {
        String url = "/../jasperserver4/jasperservlet?project=jprotocollostampe&report=${reportName}&conn=${jdbcNameGdm}&" + mapToUrl(params)
        Clients.evalJavaScript(" window.open('" + url + "'); ")
    }

    @CompileDynamic
    private void openPopupStampaDiretta(String reportName, Map params) {
        String urlJasper = Impostazioni.AG_SERVER_URL.valore + "/jasperserver4/jasperservlet?" + mapToUrl([project: "jprotocollostampe", report: reportName, conn: jdbcNameGdm] + params)
        String filename = ImpostazioniProtocollo.TEMP_PATH.valore + "/${new Date().getTime()}.${params.STAMPANTE}"
        String url = "/../documentviewerservlet/viewDocument?open=SAVEFILE&filename=${filename}&save=yes&url=${urlJasper}"
        Clients.evalJavaScript(" window.open('" + url + "'); ")
    }

    private String mapToUrl(Map params) {
        return params.collect {
            it.key.toString() + "=" + URLEncoder.encode(it.value.toString(), "UTF-8")
        }.join("&")
    }
}