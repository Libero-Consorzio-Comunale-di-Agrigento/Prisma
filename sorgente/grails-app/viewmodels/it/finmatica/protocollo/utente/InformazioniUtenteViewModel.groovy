package it.finmatica.protocollo.utente

import groovy.util.logging.Slf4j
import groovy.xml.StreamingMarkupBuilder
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.config.Ad4Properties
import it.finmatica.ad4.utility.UtenteService
import it.finmatica.gestionedocumenti.commons.Ad4Service
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.beans.FileDownloader
import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.firma.GestioneDocumentiFirmaService
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.preferenze.PreferenzeUtente
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang3.time.FastDateFormat
import org.springframework.transaction.support.TransactionTemplate
import org.zkoss.bind.BindContext
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class InformazioniUtenteViewModel {
	
	public static final String LETTERA = "LETTERA"
	public static final String ARRIVO   = 'ARRIVO'
	public static final String PARTENZA = 'PARTENZA'
	public static final String INTERNO             = 'INTERNO'
	public static final String PREFERENZA_MODALITA            = 'Modalita'
	public static final String PREFERENZA_UNITA_PROTOCOLLANTE = 'UnitaProtocollante'
	public static final String PREFERENZA_UNITA_ITER    = 'UnitaIter'
	public static final String PREFERENZA_REPORT_TIMBRO = 'ReportTimbro'

	@WireVariable private GestioneDocumentiFirmaService gestioneDocumentiFirmaService
	@WireVariable private GestioneDocumentiSpringSecurityService springSecurityService
	@WireVariable private GestioneTestiService 		gestioneTestiService
	@WireVariable private Ad4Properties 				ad4Properties
    @WireVariable private DocumentoService            documentoService
	@WireVariable private FileDownloader				fileDownloader
	@WireVariable private UtenteService 				utenteService
	@WireVariable private IGestoreFile 				gestoreFile
	@WireVariable private Ad4Service	 				ad4Service
	@WireVariable private TransactionTemplate transactionTemplate
	@WireVariable private PreferenzeUtenteService preferenzeUtenteService
	@WireVariable private PrivilegioUtenteService privilegioUtenteService
	@WireVariable private So4Repository so4Repository
	@WireVariable private DateService dateService

	// component
	Window self

	String nominativo
	String cognomeNome
	String codiceUtente

	String amministrazione
	String ottica
	String ruoloAccesso

	String vecchiaPassword
	String nuovaPassword
	String confermaPassword
	boolean passwordVerificata = false
	boolean editaTestoAppletJava = true

	def ruoliUo

	long idAllegato, idFileAllegato

	String urlDocumento
	String tipoEditor

	Map<String,?> preferenze = [:]
	List<PreferenzeUtente> allPrefs
	List<PrivilegioUtente> privilegiUtente
	List<String> listaModalita = ['']
	boolean haMovimentoArrivo
	boolean haMovimentoPartenza
	boolean haMovimentoInterno
	List<String> listaUnitaProtocollo = ['']
	List<String> listaUnitaIter = ['']
	List<PrivilegioUtente> listaPrivDiretto
	FastDateFormat fdf = FastDateFormat.getInstance('dd/MM/yyyy')


	@Init init(@ContextParam(ContextType.COMPONENT) Window w) {
		self 		= w
		idAllegato  = -1
		idFileAllegato = -1
		nominativo  = springSecurityService.principal.username
		cognomeNome = springSecurityService.principal.cognomeNome?:""
		codiceUtente= springSecurityService.principal.id
		Ad4Ruolo r = Ad4Ruolo.get(springSecurityService.principal.authorities.authority[0])

		ruoloAccesso = "${r.ruolo.substring(ad4Properties.modulo.length()+1)} - ${r.descrizione}"

		amministrazione = springSecurityService.principal.amm().codice+" - "+springSecurityService.principal.amm().descrizione
		ottica = springSecurityService.principal.ottica().codice+" - "+springSecurityService.principal.ottica().descrizione

		ruoliUo = []
		for (def uo : springSecurityService.principal.uo()) {
			ruoliUo << [tipo:"uo", codice:uo.id, dal:uo.dal, descrizione:uo.descrizione]

			for (def ruolo : uo.ruoli) {
				ruoliUo << [tipo:"ruolo", codice:ruolo.codice, descrizione:ruolo.descrizione]
			}
		}

		tipoEditor = Impostazioni.EDITOR_DEFAULT.valore
		gestioneTestiService.setDefaultEditor(Impostazioni.EDITOR_DEFAULT.valore, Impostazioni.EDITOR_DEFAULT_PATH.valore)
		privilegiUtente = privilegioUtenteService.getAllPrivilegi(springSecurityService.principal.utente)
		haMovimentoArrivo = privilegiUtente.find { it.privilegio == PrivilegioUtente.MOVIMENTO_ARRIVO }
		haMovimentoPartenza = privilegiUtente.find { it.privilegio == PrivilegioUtente.MOVIMENTO_PARTENZA }
		haMovimentoInterno = privilegiUtente.find { it.privilegio == PrivilegioUtente.MOVIMENTO_INTERNO }
		if(haMovimentoArrivo) listaModalita.add ARRIVO
		if(haMovimentoPartenza) listaModalita.add PARTENZA
		if(haMovimentoInterno) listaModalita.add INTERNO
		listaPrivDiretto = privilegiUtente.findAll {it.appartenenza == 'D'}
		listaUnitaProtocollo.addAll(listaPrivDiretto.findAll {['CPROT','REDLET','DAFASC' ].contains(it.privilegio)}
				.collect {it.codiceUnita}.unique())
		listaUnitaIter.addAll(listaPrivDiretto.collect({it.codiceUnita}).unique())
		allPrefs = preferenzeUtenteService.findAll(springSecurityService.principal.utente)
		for(pref in allPrefs) {
			setPreferenza(preferenze,pref)
		}
	}


	@NotifyChange("idAllegato")
    @Command
	void onTestFirma (@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        String url = null
        logAd4("TEST - Firma.")
		transactionTemplate.execute {
            eliminaAllegato ()

            Allegato allegato 		= new Allegato()
            allegato.descrizione 	= "ALLEGATO PER FIRMA DI TEST, SI PUO' ELIMINARE SENZA PROBLEMI."
            allegato.statoFirma 	= StatoFirma.DA_FIRMARE
            allegato.tipoAllegato 	= TipoAllegato.get(1)
            allegato.save()

            documentoService.uploadFile(allegato, event.media)

            gestioneDocumentiFirmaService.aggiungiFirmatarioAllaCoda(allegato, springSecurityService.currentUser)
            gestioneDocumentiFirmaService.preparaFirmatarioInCoda(allegato)
            gestioneDocumentiFirmaService.preparaFilePerFirma(allegato.fileDocumenti.first())
            gestioneDocumentiFirmaService.finalizzaTransazioneFirma()
            url = gestioneDocumentiFirmaService.getUrlPopupFirma()

            idAllegato 		= allegato.id
            idFileAllegato 	= allegato.fileDocumenti.first().id
        }

        logAd4("TEST - Apro popup di firma: $url")
        Executions.createComponents("/commons/popupFirma.zul", self, [urlPopupFirma: url]).doModal()
    }

	@NotifyChange("tipoEditor")
	@Command onAggiornaEditor () {
		tipoEditor = Impostazioni.EDITOR_DEFAULT.valore
		
		gestioneTestiService.setDefaultEditor(Impostazioni.EDITOR_DEFAULT.valore, Impostazioni.EDITOR_DEFAULT_PATH.valore)
	}
	
	@Command onAbilitaAppletJava () {
		if (editaTestoAppletJava) {
			gestioneTestiService.abilitaApplet()
		} else {
			gestioneTestiService.abilitaJnlp()
		}
	}

	@Command onTestEditaTesto () {
		logAd4("TEST - Edita Testo.")
		if (urlDocumento == null) {
			// scelgo un modello a caso tra determine o delibere
			GestioneTestiModello m = GestioneTestiModello.createCriteria().get {
				tipoModello {
					'in'("codice", [LETTERA])
				}

				eq ("tipo", Impostazioni.FORMATO_DEFAULT.valore)

				maxResults(1)
				eq ("valido", true)
			}
			String query = new String(m.tipoModello.query)
			def xml = new XmlSlurper().parseText(query)
			def outputBuilder = new StreamingMarkupBuilder()
			if (xml.testStaticData.documentRoot.text() == "") {
				Clients.showNotification("Non è possibile testare il modello perché nell'XML della query non ci sono i dati di prova nel tag <testStaticData>", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 8000, true)
				return
			}
			String staticData = outputBuilder.bind{ mkp.yield xml.testStaticData.documentRoot }
			InputStream testo = gestioneTestiService.stampaUnione (new ByteArrayInputStream(m.fileTemplate), staticData, Impostazioni.FORMATO_DEFAULT.valore)

			urlDocumento = gestioneTestiService.apriEditorTesto(testo, "FILE_DI_TEST_DA_ELIMINARE.${Impostazioni.FORMATO_DEFAULT.valore}")

			logAd4("TEST - Testo creato con successo: $urlDocumento")
		}
	}

	@Command onCambiaPassword () {
		logAd4("TEST - Cambio password.")
		utenteService.updatePassword(vecchiaPassword, nuovaPassword, confermaPassword)
		Clients.showNotification("Password aggiornata con successo.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
	}

	@NotifyChange("passwordVerificata")
	@Command onVerificaPassword(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx) {
		String conferma = ctx?.triggerEvent?.value?:confermaPassword
		passwordVerificata = nuovaPassword?.length() > 0 && nuovaPassword.equals(conferma)
	}

	@Command onDownloadFileFirmato () {
		logAd4("TEST - Download del File Firmato per verifica.")
		fileDownloader.downloadFileAllegato(Allegato.get(idAllegato), FileDocumento.get(idFileAllegato))
	}

	@Command onClose () {
		if (gestioneTestiService.isEditorAperto()) {
			// se ho un documento ancora aperto, do errore:
			throw new GestioneDocumentiRuntimeException("Per proseguire è necessario chiudere l'editor aperto.")
		}
		
		if (urlDocumento != null) {
			gestioneTestiService.eliminaFileDaWebdav(urlDocumento)
		}

		Events.postEvent("onClose", self, null)
	}

	@Command
	void onSalva() {
		for(pref in allPrefs) {
			String preferenza = pref.preferenza
			def value = preferenze[preferenza]
			pref.valore = value
		}
		preferenzeUtenteService.saveAll(allPrefs)
	}

	@Command
	void onSalvaChiudi() {
		onSalva()
		onClose()
	}

	private void eliminaAllegato () {
		if (idAllegato > 0) {
			transactionTemplate.execute {
				Allegato a = Allegato.get(idAllegato)
				FileDocumento f = FileDocumento.get(idFileAllegato)
				a.removeFromFileDocumenti(f)
				gestoreFile.removeFile(a, f)
				a.delete()
				idAllegato = -1
				idFileAllegato = -1
			}
		}
	}

	private void logAd4 (String note) {
		String testo   = "ip macchina client: ${Executions.getCurrent().getRemoteAddr()} - browser: ${Executions.getCurrent().getHeader("User-Agent")}"
		ad4Service.logAd4(note, testo)
	}

	private void setPreferenza(Map<String,?> prefs, PreferenzeUtente pref) {
		String preferenza = pref.preferenza
		if(pref.valore == null) {
			switch (preferenza) {
				case PREFERENZA_MODALITA: pref.valore = ""; break
				case PREFERENZA_UNITA_PROTOCOLLANTE: pref.valore = getunitaProtocollanteDefault(); break
				case PREFERENZA_UNITA_ITER: pref.valore = getUnitaIterDefault(); break
				case PREFERENZA_REPORT_TIMBRO: pref.valore = getReportTimbroDefault(); break
			}
		}
		prefs[preferenza] = pref.valore
	}

	private String getunitaProtocollanteDefault() {
		if(listaUnitaProtocollo) {
			return listaUnitaProtocollo.first()
		} else {
			return null
		}
	}

	private getUnitaIterDefault() {
		if(listaUnitaIter) {
			return listaUnitaIter.first()
		} else {
			return null
		}
	}

	private getReportTimbroDefault() {
		""
	}

	So4UnitaPubb getUnita(String codiceUnita) {
		String ottica = Impostazioni.OTTICA_SO4.valore
		PrivilegioUtente priv = listaPrivDiretto.find {it.codiceUnita == codiceUnita}
		if(priv) {
			try {
				return so4Repository.getUnita(priv.progrUnita, ottica, dateService.getCurrentDate())
			} catch(Exception e) {
				log.error('Errore lettura unità {}',codiceUnita,e)
				return null
			}
		} else {
			return null
		}
	}

	String unitaString(So4UnitaPubb unita) {
		return unita ? "${unita.codice} - ${unita.descrizione}${unita.al ? ' - al ':''}${unita.al ? fdf.format(unita.al) : ''}" : ''
	}
}
