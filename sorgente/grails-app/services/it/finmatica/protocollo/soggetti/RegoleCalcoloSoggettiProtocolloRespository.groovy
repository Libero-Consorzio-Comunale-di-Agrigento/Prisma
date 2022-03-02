package it.finmatica.protocollo.soggetti

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.IRegoleCalcoloSoggettiRepository
import it.finmatica.gestionedocumenti.soggetti.MetodoCalcoloSoggetti
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.so4.struttura.So4SuddivisioneStruttura
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubbService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.springframework.beans.factory.annotation.Autowired

import static it.finmatica.gestionedocumenti.soggetti.MetodoCalcoloSoggetti.Categoria.COMPONENTE
import static it.finmatica.gestionedocumenti.soggetti.MetodoCalcoloSoggetti.Categoria.UNITA

// TODO[SPRINGBOOT]: il nome di questa classe contiene un Typo! :"Respository" vs "Repository"
class RegoleCalcoloSoggettiProtocolloRespository implements IRegoleCalcoloSoggettiRepository {

    @Autowired StrutturaOrganizzativaService strutturaOrganizzativaService
    @Autowired So4ComponentePubbService so4ComponentePubbService
    @Autowired PreferenzeUtenteService preferenzeUtenteService
    @Autowired SpringSecurityService springSecurityService
    @Autowired So4UnitaPubbService so4UnitaPubbService
    @Autowired DateService dateService
    @Autowired PrivilegioUtenteService privilegioUtenteService

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "Utente corrente", descrizione = "Utente corrente")
    So4ComponentePubb getUtenteCorrente(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return So4ComponentePubb.allaData(new java.util.Date()).findBySoggetto(As4SoggettoCorrente.findByUtenteAd4(springSecurityService.currentUser))
        //return So4ComponentePubb.findBySoggettoAndAlIsNull(As4SoggettoCorrente.findByUtenteAd4(springSecurityService.currentUser))
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Componenti con ruolo", descrizione = "Lista componenti con uno specifico ruolo")
    List<So4ComponentePubb> getListaComponentiConRuolo(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return strutturaOrganizzativaService.getComponentiConRuoloInOttica(codiceRuolo, codiceOttica)
    }

    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Unità utente", descrizione = "Lista delle unità a cui appartiene l'utente loggato")
    List<So4UnitaPubb> getUnitaUtente(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return strutturaOrganizzativaService.getUnitaUtente(springSecurityService.principal.id, springSecurityService.principal.ottica().codice)
    }

    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Ricerca unità utente", descrizione = "Ricerca tra le unità a cui appartiene l'utente loggato")
    List<So4UnitaPubb> ricercaUnitaUtente(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return strutturaOrganizzativaService.ricercaUnitaUtente(springSecurityService.principal.id, springSecurityService.principal.ottica().codice, filtro)
    }

    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Ricerca unità utente con ruolo", descrizione = "Ricerca tra le unità a cui appartiene l'utente loggato")
    List<So4UnitaPubb> ricercaUnitaUtenteConRuolo(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return strutturaOrganizzativaService.ricercaUnitaUtenteConRuolo(springSecurityService.principal.id, codiceRuolo, springSecurityService.principal.ottica().codice, filtro)
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE,
            tipo = MetodoCalcoloSoggetti.Tipo.LISTA,
            titolo = "Ricerca componenti con ruolo presenti nella Uo del soggetto di partenza",
            descrizione = "Es.: Ricerca i firmatari presenti nella UO del redattore")
    List<So4ComponentePubb> ricercaListaComponentiConRuoloUoPartenza(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        if (soggetti[tipoSoggettoPartenza]?.unita == null) {
            return null
        }

        So4UnitaPubb uo = soggetti[tipoSoggettoPartenza].unita?.domainObject
        return strutturaOrganizzativaService.ricercaComponentiConRuoloInUnita(codiceRuolo, uo.progr, uo.ottica.codice, filtro).unique {
            it.soggetto.utenteAd4
        }
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE,
            tipo = MetodoCalcoloSoggetti.Tipo.LISTA,
            titolo = "Ricerca componenti con ruolo presenti nella Uo del soggetto di partenza e nella sua stessa Area",
            descrizione = "Es.: Ricerca i firmatari presenti nella UO del redattore e nella stessa area del Redattore (verso l'alto)")
    List<So4ComponentePubb> ricercaListaComponentiConRuoloInUnitaPadri(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        if (soggetti[tipoSoggettoPartenza]?.unita == null) {
            return null
        }

        def uo = soggetti[tipoSoggettoPartenza].unita
        return strutturaOrganizzativaService.ricercaComponentiConRuoloInUnitaPadri(codiceRuolo, uo.progr, uo.ottica.codice, dateService.currentDate, filtro).unique {
            it.soggetto.utenteAd4
        }
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE,
            tipo = MetodoCalcoloSoggetti.Tipo.LISTA,
            titolo = "Ricerca componenti con ruolo presenti nella Uo del soggetto di partenza e nella sua stessa Area fino a Suddivisione",
            descrizione = "Es.: Ricerca i firmatari presenti nella UO del redattore e nella stessa area del Redattore (fino a Suddivisione)")
    List<So4ComponentePubb> ricercaComponentiConRuoloInPadriFinoASuddivisione(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        if (soggetti[tipoSoggettoPartenza]?.unita == null) {
            throw new ProtocolloRuntimeException("Bisogna definire prima " + tipoSoggettoPartenza)
        }

        def uo = soggetti[tipoSoggettoPartenza].unita
        So4SuddivisioneStruttura suddivisione = So4SuddivisioneStruttura.getSuddivisione(Impostazioni.SO4_SUDDIVISIONE_AREA.valore, uo.ottica.codice).get()

        if (suddivisione == null) {
            throw new ProtocolloRuntimeException("Non è stato possibile trovare la suddivisione con codice '${Impostazioni.SO4_SUDDIVISIONE_AREA.valore}' per l'ottica ${uo.ottica?.descrizione}")
        }
        return strutturaOrganizzativaService.ricercaComponentiConRuoloInPadriFinoASuddivisione(codiceRuolo, uo.progr, uo.ottica.codice, dateService.currentDate, suddivisione.id, filtro).unique {
            it.soggetto.utenteAd4
        }
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE,
            tipo = MetodoCalcoloSoggetti.Tipo.LISTA,
            titolo = "Ricerca componenti con ruolo presenti nella Uo del soggetto di partenza e nella sua stessa Area (anche pari livello)",
            descrizione = "Es.: Ricerca i firmatari presenti nella UO del redattore e nella stessa area del Redattore (anche pari livello)")
    List<So4ComponentePubb> ricercaComponentiConRuoloInUnitaEPadri(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        if (soggetti[tipoSoggettoPartenza]?.unita == null) {
            throw new ProtocolloRuntimeException("Bisogna definire prima " + tipoSoggettoPartenza)
        }

        def uo = soggetti[tipoSoggettoPartenza].unita
        return strutturaOrganizzativaService.ricercaComponentiConRuoloInUnitaEPadri(codiceRuolo, uo.progr, uo.ottica.codice, dateService.currentDate, filtro).unique {
            it.soggetto.utenteAd4
        }
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "L'utente RESPONSABILE e con RUOLO nell'unità del soggetto e nelle sue unità padri.", descrizione = "L'utente RESPONSABILE e con RUOLO nell'unità del soggetto e nelle sue unità padri.")
    So4ComponentePubb getResponsabileConRuoloInUnita(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        def uo = soggetti[tipoSoggettoPartenza]?.unita
        if (uo == null) {
            return null
        }

        def ruoli = [ImpostazioniProtocollo.RUOLO_SO4_RESPONSABILE.valore]
        if (codiceRuolo) {
            ruoli.add(codiceRuolo)
        }
        So4UnitaPubb unita = So4UnitaPubb.getUnita(uo.progr, uo.ottica.codice, uo.dal).get()

        while (unita != null) {
            def componenti = so4ComponentePubbService.getComponentiUnitaPubbConRuoli(ruoli, unita, new java.util.Date(), StrutturaOrganizzativaService.ASSEGNAZIONE_PREVALENTE, StrutturaOrganizzativaService.TIPO_ASSEGNAZIONE)
            if (componenti?.size() > 0) {
                return componenti[0]
            }

            unita = unita.getUnitaPubbPadre()
        }

        return null
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "L'utente RESPONSABILE e con RUOLO nell'ottica", descrizione = "L'utente RESPONSABILE e con RUOLO nell'ottica")
    So4ComponentePubb getResponsabileConRuoloInOttica(def documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        String ruolo = ImpostazioniProtocollo.RUOLO_SO4_RESPONSABILE.valore
        String codiceOttica = springSecurityService.principal.ottica().codice
        List<So4ComponentePubb> c = strutturaOrganizzativaService.getComponentiConRuoliInOttica([ruolo, codiceRuolo], codiceOttica)
        if (c?.size() > 0) {
            return c[0]
        }
        return null
    }

	@MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "Utente con ruolo in area.", descrizione = "Utente con ruolo in area.")
	So4ComponentePubb getComponenteConRuoloInArea  (def documento, def soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
		List<So4ComponentePubb> componenti = getListaComponentiConRuoloInArea(documento, soggetti, codiceRuolo, tipoSoggettoPartenza, filtro)

		if (componenti?.size() > 0) {
			return componenti[0]
		} else {
			return null
		}
	}

	/**
	 * La regola è la seguente:
	 * ottengo l'unità suddivisione "padre", verificando che la UO di partenza abbia una suddivisione valorizzata;
	 * poi recupero tutti i componenti con il ruolo specificato nella uo 'padre' e nelle uo figlie
 	*/
	@MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Utenti con ruolo in area.", descrizione = "Utenti con ruolo in area.")
	List<So4ComponentePubb> getListaComponentiConRuoloInArea  (def documento, def soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
		if (soggetti[tipoSoggettoPartenza]?.unita == null) {
			return null
		}

		So4UnitaPubb uo = soggetti[tipoSoggettoPartenza].unita?.domainObject
		So4SuddivisioneStruttura suddivisione = So4SuddivisioneStruttura.getSuddivisione(Impostazioni.SO4_SUDDIVISIONE_AREA.valore, uo.ottica.codice).get()

		if (suddivisione == null) {
			throw new ProtocolloRuntimeException("Non è stato possibile trovare la suddivisione con codice '${Impostazioni.SO4_SUDDIVISIONE_AREA.valore}' per l'ottica ${uo.ottica?.descrizione}")
		}

		return strutturaOrganizzativaService.getComponentiConRuoloInSuddivisione(codiceRuolo, uo.progr, uo.ottica.codice, uo.dal, suddivisione.id)
	}

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Ricerca utenti con ruolo in area.", descrizione = "Ricerca utenti con ruolo in area.")
    List<So4ComponentePubb> ricercaListaComponentiConRuoloInArea(def documento, def soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        if (soggetti[tipoSoggettoPartenza]?.unita == null) {
            return null
        }

        def uo = soggetti[tipoSoggettoPartenza].unita
        So4SuddivisioneStruttura suddivisione = So4SuddivisioneStruttura.getSuddivisione(Impostazioni.SO4_SUDDIVISIONE_AREA.valore, uo.ottica.codice).get()

        if (suddivisione == null) {
            throw new ProtocolloRuntimeException("Non è stato possibile trovare la suddivisione con codice '${Impostazioni.SO4_SUDDIVISIONE_AREA.valore}' per l'ottica ${uo.ottica?.descrizione}")
        }

        return strutturaOrganizzativaService.ricercaComponentiConRuoloInSuddivisione(codiceRuolo, uo.progr, uo.ottica.codice, uo.dal, suddivisione.id, filtro)
    }

    /**
     * Ritorna l'unità protocollante di default (vedi {@link #ricercaUnitaProtocollanteConPrivilegi})
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "L'unità protocollante di default per l'utente corrente con Privilegi", descrizione = "L'utente protocollante di default per l'utente corrente considerando i privilegi di creazione")
    So4UnitaPubb getUnitaProtocollanteConPrivilegiDefault(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {

        So4UnitaPubb unitaProtocollante = preferenzeUtenteService.getUnitaProtocollante()

        List<So4UnitaPubb> unitaUtenteConRuoloList = ricercaUnitaProtocollanteConPrivilegi(documento, soggetti, codiceRuolo, tipoSoggettoPartenza, "")

        if (unitaProtocollante != null) {
            if(unitaUtenteConRuoloList?.contains(unitaProtocollante)){
                return unitaProtocollante
            }
        }

        if (unitaUtenteConRuoloList?.size() > 0) {
            return unitaUtenteConRuoloList[0]
        }

        return null
    }

    /**
     * Ritorna l'ufficio esibente di default.
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "L'ufficio esibente di default", descrizione = "L'utente protocollante di default per il tipo di documento")
    So4UnitaPubb getUfficioEsibenteDefault(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {

        // ottengo il codice dell'ufficio esibente per poi ricercarne uno valido alla data odierna. Faccio così per evitare problemi con le revisioni di struttura.
        String codiceUfficioEsibente = documento?.schemaProtocollo?.ufficioEsibente?.codice
        if (codiceUfficioEsibente != null) {
            return So4UnitaPubb.allaData().findByCodice(codiceUfficioEsibente)
        } else {
            return null
        }
    }

    /**
     * Le possibili unità protocollanti di un utente devono essere visualizzate tutte le unità dell'utente valide ad oggi con privilegio CPROT valido ad oggi
     * e per cui esiste un record in ag_priv_utente_tmp aperto ad oggi su un'unità valida ad oggi a cui l'utente appartiene direttamente
     * che abbia la stessa unità radice d'area dell'unità presa in considerazione
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Le possibili unità protocollanti per l'utente corrente con privilegi estesi", descrizione = "Le possibili unità protocollanti per l'utente corrente considerando i privilegi estesi")
    List<So4UnitaPubb> ricercaUnitaProtocollanteConPrivilegi(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        List<So4UnitaPubb> unitaUtentePerPrivilegioEstesoList = privilegioUtenteService.listUnitaPerPrivilegiEstesi(springSecurityService.currentUser, documento.categoriaProtocollo?.privilegioCreazione, filtro)
        return unitaUtentePerPrivilegioEstesoList
    }

    /**
     * Ritorna l'unità protocollante di default per i messaggi in arrivo
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "L'unità protocollante di default per l'utente corrente per i messaggi in arrivo", descrizione = "L'utente protocollante di default per l'utente corrente per i messaggi in arrivo")
    So4UnitaPubb getUnitaProtocollanteDefaultMessaggiArrivo(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        So4UnitaPubb unitaProtocollante = preferenzeUtenteService.getUnitaProtocollante()
        if (unitaProtocollante != null) {
            return unitaProtocollante
        }

        List<So4UnitaPubb> unitaUtentePerPrivilegioList = privilegioUtenteService.getUnitaPerPrivilegi(springSecurityService.currentUser, PrivilegioUtente.REDATTORE_PROTOCOLLO, true)
        if (unitaUtentePerPrivilegioList?.size() > 0) {
            return unitaUtentePerPrivilegioList[0]
        }

        return null
    }

    /**
     * Ricerca le possibili unità protocollanti per l'utente corrente per i messaggi in arrivo
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Le possibili unità protocollanti per l'utente corrente per i messaggi in arrivo", descrizione = "Le possibili unità protocollanti per l'utente corrente per i messaggi in arrivo")
    List<So4UnitaPubb> ricercaUnitaProtocollanteMessaggiArrivo(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return privilegioUtenteService.getUnitaPerPrivilegi(springSecurityService.currentUser, PrivilegioUtente.REDATTORE_PROTOCOLLO, true)
    }

    /**
     * Ricerca le possibili unità di creazione per l'utente corrente per i fascicoli
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Ricerca le possibili unità di creazione per l'utente corrente per i fascicoli", descrizione = "Ricerca le possibili unità di creazione per l'utente corrente per i fascicoli")
    List<So4UnitaPubb> ricercaUnitaCreazioneFascicolo(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return privilegioUtenteService.listUnitaPerPrivilegiEstesi(springSecurityService.currentUser, PrivilegioUtente.CREF, filtro)
    }

    /**
     * Ricerca le possibili unità di creazione per l'utente corrente per i fascicoli
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @return
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "Ricerca le possibili unità di creazione per l'utente corrente per i fascicoli default", descrizione = "Ricerca le possibili unità di creazione per l'utente corrente per i fascicoli default")
    List<So4UnitaPubb> ricercaUnitaCreazioneFascicoloDefault(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        return privilegioUtenteService.listUnitaPerPrivilegiEstesi(springSecurityService.currentUser, PrivilegioUtente.CREF, filtro)[0]
    }

    /**
     * Ritorna l'elenco di unità organizzative che appartengono all'amministrazione e all'ottica alla data indicata (opzionale, default sysdate)
     * Il risultato è ordinato alfabeticamente.
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @param filtro la stringa su cui si filtra per like %${filtro}% nel campo descrizione (default null: non filtra)
     * @return l'elenco piatto ordinato alfabeticamente delle unità organizzative trovate
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Ricerca unità", descrizione = "Ricerca unità")
    List<So4UnitaPubb> ricercaUnitaPubb(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        String ente = springSecurityService.principal.amm()?.codice
        if (ente == null) {
            ente = Ente.get(1)?.amministrazione?.id
        }

        String ottica = springSecurityService.principal.ottica()?.codice
        if (ottica == null) {
            ottica = Impostazioni.OTTICA_SO4.valore
        }
        List<So4UnitaPubb> lista = strutturaOrganizzativaService.cercaUnitaPubb(ente, ottica, dateService.getCurrentDate(), filtro)
        return lista
    }

    /**
     * Ritorna l'elenco di unità organizzative che appartengono all'amministrazione e all'ottica alla data indicata (opzionale, default sysdate)
     * Il risultato è ordinato alfabeticamente.
     *
     * @param soggetti
     * @param codiceRuolo
     * @param tipoSoggettoPartenza
     * @param filtro la stringa su cui si filtra per like %${filtro}% nel campo descrizione (default null: non filtra)
     * @return l'elenco piatto ordinato alfabeticamente delle unità organizzative trovate
     */
    @MetodoCalcoloSoggetti(categoria = UNITA, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "Ricerca unità default", descrizione = "Ricerca unità default")
    List<So4UnitaPubb> ricercaUnitaPubbDefault(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        String ente = springSecurityService.principal.amm()?.codice
        if (ente == null) {
            ente = Ente.get(1)?.amministrazione?.id
        }

        String ottica = springSecurityService.principal.ottica()?.codice
        if (ottica == null) {
            ottica = Impostazioni.OTTICA_SO4.valore
        }
        List<So4UnitaPubb> lista = strutturaOrganizzativaService.cercaUnitaPubb(ente, ottica, dateService.getCurrentDate(), filtro)
        return lista[0]
    }

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.DEFAULT, titolo = "Utente con ruolo nell'ottica.", descrizione = "Utente con ruolo nell'ottica.")
    So4ComponentePubb getComponenteConRuoloInOttica(
			documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {

		def componenti = getListaComponentiConRuoloInOttica(documento, soggetti, codiceRuolo, tipoSoggettoPartenza, filtro)
		if (componenti?.size() > 0) {
			componenti.sort { it.nominativoSoggetto }
			return componenti[0]
		} else {
			return null
		}
	}

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Utenti con ruolo nell'ottica.", descrizione = "Utenti con ruolo nell'ottica.")
    List<So4ComponentePubb> getListaComponentiConRuoloInOttica(
			documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {

		String codiceOttica = springSecurityService.principal.ottica().codice
		return strutturaOrganizzativaService.getComponentiConRuoloInOttica(codiceRuolo, codiceOttica).unique { it.soggetto.utenteAd4 }
	}

    @MetodoCalcoloSoggetti(categoria = COMPONENTE, tipo = MetodoCalcoloSoggetti.Tipo.LISTA, titolo = "Ricerca componenti con ruolo nell'ottica", descrizione = "Ricerca tra i componenti con uno specifico ruolo nell'ottica")
    List<So4ComponentePubb> ricercaListaComponentiConRuoloInOttica(documento, soggetti, String codiceRuolo, String tipoSoggettoPartenza, String filtro) {
        String codiceOttica = springSecurityService.principal.ottica().codice
        return strutturaOrganizzativaService.ricercaComponentiPubbOtticaConRuolo(codiceRuolo, codiceOttica, filtro).unique {
            it.soggetto.utenteAd4
        }
    }
}