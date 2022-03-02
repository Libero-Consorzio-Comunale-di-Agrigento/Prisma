package it.finmatica.protocollo.documenti.ricerca

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.as4.As4SoggettoCorrenteDTO
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoAllegatoDTO
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoDTO
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.util.resource.Labels

class MascheraRicercaDocumento {
	
	public static final String NESSUN_VALORE = "-- nessuno --"

	// configurazione dei tipi di oggetto
	Map tipiDocumento = [(Protocollo.CATEGORIA_LETTERA)		: [ricercabile: true
															, domainRicerca: Protocollo
															, domainTipologia: TipoProtocollo
															, tipoAllegato: "idTipoAllegato"
															, tipoCategoria: Protocollo.CATEGORIA_LETTERA
															, popup: "/commons/popupRicercaDocumenti.zul"
															, nome: Labels.getLabel("tipoOggetto.lettere")
															, labelCategoria: Labels.getLabel("label.categoria.lettera")]]

	/*
	 * Vari campi di ricerca
	 */
	// dati identificativi del documento
	String 	tipoDocumento

	// dati del documento
	String 			oggetto
	int 			riservato = 0	// 0: tutti, 1: solo riservati, 2: solo non riservati
	String 			stato = NESSUN_VALORE

	// dati dei soggetti
	As4SoggettoCorrenteDTO soggettoCorrente
	So4UnitaPubbDTO        unitaProtocollante
	Ad4UtenteDTO redattore
	Ad4UtenteDTO firmatario
	Ad4UtenteDTO funzionario

	// dati del protocollo
	Long	numero
	Long	anno
	String 	registro
	Date 	dataDal
	Date 	dataAl
	Long 	numeroDal
	Long 	numeroAl

	// dati della tipologia
	def tipologia

	// dati di pubblicazione
	Long numeroAlboDal
	Long numeroAlboAl
	Long annoAlbo
	Date dataPubblicazioneDal
	Date dataPubblicazioneAl

	// dati di conservazione
	String logConservazione
	String statoConservazione

	TipoAllegatoDTO tipoAllegato

	// eventuale filtro aggiuntivo:
	Closure filtroAggiuntivo = null

	/*
	 * "Dizionari" per riempire le combobox per i filtri di ricerca
	 */
	List<Ad4UtenteDTO> 	listaFirmatari
	List<Ad4UtenteDTO> 	listaRedattori

	List<String>			listaStatiDocumento
	List<Ad4UtenteDTO> 		listaUnitaProtocollanti
	List<TipoDocumentoDTO>  listaTipologie
	List<TipoRegistroDTO>   listaRegistri
	List<TipoAllegatoDTO>   listaTipiAllegato

	List listaRiservati = ["Tutti", "Solo Riservati", "Solo Non Riservati"]

	So4UnitaPubbDTO	unita
	String esito				= "TUTTI"
	Map listaEsiti				= [TUTTI:"-- tutti --"]

	Map orderMap = [anno:'desc', numero:'desc']


	Map exportOptions =   [   idDocumento 				 : [esportabile:false, 	label:'ID', 						index: -1, resize: true, columnType: 'NUMBER']
							, idDocumentoPrincipale		 : [esportabile:false, 	label:'ID Documento Principale', 	index: -1, resize: true, columnType: 'TEXT']
							, tipoDocumento				 : [esportabile:false, 	label:'Tipo Documento', 			index: -1, resize: true, columnType: 'TEXT']
							, tipoDocumentoPrincipale 	 : [esportabile:false, 	label:'Tipo documento Principale', 	index: -1, resize: true, columnType: 'TEXT']
							, anno						 : [esportabile:true, 	label:'Anno Proposta', 				index:  7, resize: true, columnType: 'NUMBER']
							, numero					 : [esportabile:true, 	label:'Numero Proposta', 			index:  6, resize: true, columnType: 'NUMBER']
							, oggetto					 : [esportabile:true, 	label:'Oggetto', 					index:  5, resize: false,columnType: 'TEXT']
							, titoloTipologia			 : [esportabile:true,	label:'Tipologia', 					index:  4, resize: true, columnType: 'TEXT']
							, stato 					 : [esportabile:false, 	label:'Stato', 						index: -1, resize: true, columnType: 'TEXT']
							, uoProtocollanteDescrizione : [esportabile:true,   label:'Unita Protocollante', 		index:  8, resize: true, columnType: 'TEXT']
							, logConservazione			 : [esportabile:false, 	label:'Conservazione', 				index: -1, resize: true, columnType: 'TEXT']
							, titoloStep				 : [esportabile:true, 	label:'Stato', 						index:  9, resize: true, columnType: 'TEXT']
			]


	/*
	 * Variabili di stato e configurazione
	 */
	boolean ricercaConservazione = false // indica se si è nella sezione della conservazione
	boolean cercaNelTesto		 = false // indica se si deve ricercare il testo dell'oggetto anche nel blob dell'allegato

	// elenco dei documenti trovati
	List<Documento> listaDocumenti

	// paginazione
	int activePage  = 0
	int pageSize 	= 30
	int totalSize

	MascheraRicercaDocumento () {

	}

	private getProp(String prop) {
		return tipiDocumento[tipoDocumento][prop]
	}

	void caricaListe() {
		caricaListaRegistri()
		caricaListaTipologia()
		listaTipiAllegato()
		caricaListaStatiDocumento()
	}

	void caricaListaRegistri () {
		listaRegistri = TipoRegistro.createCriteria().list() {

			eq ("valido", true)

			order ("commento", "asc")
		}.toDTO()
		listaRegistri.add(0, new TipoRegistroDTO(codice: null, commento: "-- tutti --"))
	}

	boolean isFiltriAttivi () {
		return (!NESSUN_VALORE.equals(stato)||
			soggettoCorrente 		    != null	||
			unitaProtocollante         	!= null	||
			redattore  					!= null ||
			firmatario 			    	!= null ||
			funzionario 		    	!= null ||
			numeroDal          		 	!= null ||
			registro          		  	!= null ||
			anno            			!= null ||
			dataDal         			!= null ||
			dataAl          			!= null ||
			numeroDal     				!= null ||
			numeroAl      				!= null ||
			anno          				!= null ||
			registro      				!= null ||
			tipologia 		        	!= null ||
			numeroAlboDal           	!= null ||
			numeroAlboAl            	!= null ||
			annoAlbo               		!= null ||
			dataPubblicazioneDal    	!= null ||
			dataPubblicazioneAl     	!= null ||
			tipoAllegato            	!= null ||
			esito						!= "TUTTI")
	}

	String getTooltip () {
		def tooltip = []
		if (!NESSUN_VALORE.equals(stato)   ) tooltip.add("Stato: ${stato}")
		if (soggettoCorrente 					!= null) tooltip.add("Relatore: ${soggettoCorrente.denominazione}")
		if (unitaProtocollante     		!= null) tooltip.add("Unità Protocollante: ${unitaProtocollante.descrizione}")
		if (redattore 		        	!= null) tooltip.add("Redattore: ${redattore.nominativoSoggetto}")
		if (firmatario		        	!= null) tooltip.add("Firmatario: ${firmatario.nominativoSoggetto}")
		if (funzionario		        	!= null) tooltip.add("Presidente: ${funzionario.nominativoSoggetto}")
		if (numeroDal           		!= null) tooltip.add("Numero Protocollo Dal: ${numeroDal}")
		if (numeroAl            		!= null) tooltip.add("Numero Protocollo Al: ${numerooAl}")
		if (anno                		!= null) tooltip.add("Anno Protocollo: ${anno}")
		if (registro            		!= null) tooltip.add("Registro Atto: ${registro}")
		if (tipologia 		        	!= null) tooltip.add("Tipologia: ${tipologia.titolo}")
		if (numeroAlboDal           	!= null) tooltip.add("Numero Albo Dal: ${numeroAlboDal}")
		if (numeroAlboAl            	!= null) tooltip.add("Numero Albo Al: ${numeroAlboAl}")
		if (annoAlbo                	!= null) tooltip.add("Anno Albo: ${annoAlbo}")
		if (dataPubblicazioneDal    	!= null) tooltip.add("Data Pubblicazione Dal: ${format(dataPubblicazioneDal)}")
		if (dataPubblicazioneAl     	!= null) tooltip.add("Data Pubblicazione Al: ${format(dataPubblicazioneAl)}")
		if (tipoAllegato            	!= null) tooltip.add("Tipo Allegato: ${tipoAllegato.titolo}")
		if (esito						!= "TUTTI") tooltip.add("Esito: ${listaEsiti[esito]}")

		StringBuffer text = new StringBuffer()
		for (String t : tooltip) {
			text.append("- ${t} \n")
		}

		return text.toString()
	}

	private String format (Date date) {
		return date.format ("dd/MM/yyyy")
	}

	private void caricaListaTipologia() {
		Class DomainTipologia = getProp("domainTipologia")
		listaTipologie = DomainTipologia.list([sort:'codice', order:'asc']).toDTO()
	}

	private void listaTipiAllegato() {
		listaTipiAllegato = TipoAllegato.list([sort:'commento', order:'asc']).toDTO()
		listaTipiAllegato.add(0, new TipoAllegatoDTO(id:-1, commento:NESSUN_VALORE))
	}

	private void caricaListaStatiDocumento() {
		Class DomainRicercaDocumento = getProp("domainRicerca")

		listaStatiDocumento = [NESSUN_VALORE] + DomainRicercaDocumento.createCriteria().list {
			projections {
				groupProperty("stato")
			}
			isNotNull("stato")
			order("stato", "asc")
		}
	}

	void ricerca (utente) {
		activePage = 0
		pagina (utente)
	}

	void pagina (final utente, boolean tutti = false) {

		// ottengo la domain class che mappa la vista di ricerca
		Class DomainRicercaDocumento = getProp("domainRicerca")

		// risultato query
		listaDocumenti = DomainRicercaDocumento.createCriteria().list {
            projections {
				groupProperty ("id")              			// 0
				groupProperty ("tipoProtocollo")	 		// 2
				groupProperty ("anno")                  	// 4
				groupProperty ("numero")                	// 5
				groupProperty ("oggetto")                   // 6
			}

			// se ho l'utente, controllo le competenze
            if (utente != null) {
                controllaCompetenze(delegate)(utente)
            }

			// applico i filtri
			controllaFiltri(delegate)()

			orderMap.each{ k, v -> order(k, v) }

			if (! tutti){
				firstResult (pageSize * activePage)
				maxResults  (pageSize)
			}
		}.collect {
					row -> [id               			: row[0],
							tipoProtocollo	 		 	: row[1],
							anno                  		: row[2],
							numero                		: row[3],
							oggetto                   	: row[4]
		]}

		// totale di righe
		totalSize = DomainRicercaDocumento.createCriteria().get() {
			projections {
				countDistinct("id")
			}

			// se ho l'utente, controllo le competenze
			if (utente != null) {
				controllaCompetenze(delegate)(utente)
			}

			// applico i filtri
			controllaFiltri(delegate)()
		}

	}

	private controllaFiltri (delegate) {

		if (filtroAggiuntivo != null) {
			filtroAggiuntivo.delegate = delegate
		}

		def c = {

			if (registro != null) {
				eq ("registro", registro)
			}

			// dati di protocollo
			if (anno > 0) {
				eq ("anno", anno)
			}

			if (numeroDal > 0) {
				ge ("numero", numeroDal)
			}

			if (numeroAl > 0) {
				le ("numero", numeroAl)
			}

			// dati del documento
			if (oggetto?.trim()?.length() > 0) {
				or {
					ilike ("oggetto", "%${oggetto}%")
    				if (cercaNelTesto) {
						or {
							testo {
								ilike("testo", "%${oggetto}%")
							}
							ilike("all.testo", "%${oggetto}%")
						}
    				}
				}
			}

			if (ricercaConservazione) {
				or {
					eq ("statoConservazione", it.finmatica.gestionedocumenti.documenti.StatoConservazione.DA_CONSERVARE.toString())
					eq ("statoConservazione", it.finmatica.gestionedocumenti.documenti.StatoConservazione.ERRORE.toString())

					and {
						eq ("statoConservazione", it.finmatica.gestionedocumenti.documenti.StatoConservazione.IN_CONSERVAZIONE.toString())
						isNotNull ("logConservazione")
					}
				}
			}

			if (stato != null && stato != listaStatiDocumento[0]) {
				eq ("stato", stato)
			}

			// dati di pubblicazione
			if (dataPubblicazioneDal != null) {
				le ("dataInizioPubblicazione", dataPubblicazioneDal)
			}

			if (dataPubblicazioneAl != null) {
				ge ("dataFinePubblicazione", dataPubblicazioneAl)
			}

			if (annoAlbo > 0) {
				eq ("annoAlbo", annoAlbo)
			}

			if (numeroAlboDal > 0) {
				ge ("numeroAlbo", numeroAlboDal)
			}

			if (numeroAlboAl > 0) {
				le ("numeroAlbo", numeroAlboAl)
			}

			if (tipologia != null) {
				eq("idTipologia", tipologia.id)
			}

			if (tipoAllegato?.id > 0) {
				eq (getProp("tipoAllegato"), tipoAllegato?.id)
			}

			if (esito != "TUTTI" && esito != null) {
				eq ("esito", esito)
			}

			if (filtroAggiuntivo != null) {
				filtroAggiuntivo ()
			}

			or {

				if (redattore != null) {
					and {
						eq ("utenteSoggetto.id", 	redattore.id)
						eq ("tipoSoggetto", 		it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.REDATTORE)
					}
				}
				if (firmatario != null) {
					and {
						eq("utenteSoggetto.id", 	firmatario.id)
						eq("tipoSoggetto", 			it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.FIRMATARIO)
					}
				}
				if (funzionario != null) {
					and {
						eq("utenteSoggetto.id", 	funzionario.id)
						eq("tipoSoggetto", 			it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.FUNZIONARIO)
					}
				}
				if (unitaProtocollante != null) {
					and {
						eq("unitaProtocollante.progr", 			unitaProtocollante.progr)
						eq("unitaProtocollante.ottica.codice", 	unitaProtocollante.ottica.codice)
						eq("unitaProtocollante.dal", 			unitaProtocollante.dal)
						eq("tipoSoggetto", 					    it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.UO_PROTOCOLLANTE)
					}
				}

				if (unita != null) {
					and {
						eq("unitaRedazione.progr", 			unita.progr)
						eq("unitaRedazione.ottica.codice", 	unita.ottica.codice)
						eq("unitaRedazione.dal", 			unita.dal)
					}
				}
			}
		}

		c.delegate = delegate
		return c
	}

	def ricercaSoggetti (String filtro, String tipoSoggetto, int pageSize, int activePage) {
		// ottengo la domain class che mappa la vista di ricerca
		Class DomainRicercaDocumento = getProp("domainRicerca")

		// risultato query
		def listaUtentiAd4 = DomainRicercaDocumento.createCriteria().list {
			projections {
				groupProperty ("utenteSoggetto")            // 0
				utenteSoggetto {
					groupProperty ("nominativoSoggetto")	// 1
				}
			}

			eq ("tipoSoggetto", tipoSoggetto)
			utenteSoggetto {
				ilike ("nominativoSoggetto", "%"+filtro+"%")
				order("nominativoSoggetto", "asc")
			}

			firstResult (pageSize * activePage)
			maxResults  (pageSize)
		}.collect { row -> row[0].toDTO() }

		// totale di righe
		int totalSize = DomainRicercaDocumento.createCriteria().get {
			projections {
				countDistinct("utenteSoggetto.id")
			}

			utenteSoggetto {
				ilike ("nominativoSoggetto", "%"+filtro+"%")
			}

			eq("tipoSoggetto", tipoSoggetto)
		}

		return [totalCount: totalSize, lista: listaUtentiAd4]
	}

	def ricercaUoProtocollante (String filtro, int pageSize, int activePage) {
		// ottengo la domain class che mappa la vista di ricerca
		Class DomainRicercaDocumento = getProp("domainRicerca")

		// Sembra che non sia fattibile contare il n. di record con una group by su più colonne. Sono benvenute soluzioni migliori di questa.
		def listaUnita = DomainRicercaDocumento.createCriteria().list {
			projections {
				groupProperty ("uoProtocollante")            // 0
				uoProtocollante {
					groupProperty ("descrizione")	// 1
				}
			}

			uoProtocollante {
				ilike ("descrizione", "%"+filtro+"%")
				order("descrizione", "asc")
			}

		}.collect { row -> row[0].toDTO() }

		// siccome non riesco a fare la count per paginare con grails, faccio la paginazione manuale.
		// confido che le unità proponenti non siano mai troppe.
		return [totalCount: listaUnita.size(), lista: listaUnita.drop(pageSize * activePage).take(pageSize)]
	}

	/**
	 * Criterio di controllo delle competenze (appiattite nella vista documenti competenze):
	 *
	 *  1) utente indicato pari all'utente loggato (chiamato successivamente #delegate)
	 *  2) per ogni uo di #delegate (successivamente indicata come #uoiesima) verifico che
	 * 		a) l'unità indicata è #uoiesima e il ruolo è nullo
	 * 		b) per ogni ruolo che #delegate ha nella #uoiesima (successivamente chiamato #ruoloiesimo) verifico che
	 * 			->  l'unità è nulla o pari a #uoiesima e il ruolo sia pari a #ruoloiesimo
	 *
	 *  NB1: non è consentito avere uo, ruolo, utente tutti nulli per indicare con competenze a tutti altrimenti la query è lentissima
	 *	NB2: query ottimizzata grazie agli indici!
	 *
	 * @param delegate
	 * @return
	 */
	private controllaCompetenze (delegate) {

		if (Utils.isUtenteAmministratore()) {
			// se sono utente amministratore, ritorno una closure che non fa niente:
			return { utente ->
				// non fa niente.
			}
		}

		return ProtocolloGestoreCompetenze.controllaCompetenze (delegate, "compUtente", "compUnita", "compRuolo")
	}

	/**
	 * Metodo per la modifica dell'ordinamento delle colonne.
	 * Inserisce in testa il campo con l'ordinamento specificato eliminandolo dall'elenco degli ordinamenti se già presente.
	 * @param campo
	 * @param ordinamento
	 */
	void modificaColonnaOrdinamento (String campo, String ordinamento){
		orderMap.remove(campo)
		orderMap = [(campo):ordinamento] + orderMap
	}
}
