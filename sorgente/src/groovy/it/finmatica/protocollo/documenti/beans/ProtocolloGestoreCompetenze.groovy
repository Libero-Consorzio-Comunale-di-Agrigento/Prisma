package it.finmatica.protocollo.documenti.beans

import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.competenze.DocumentoCompetenze
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestioneiter.Attore
import it.finmatica.gestioneiter.IDocumentoIterabile
import it.finmatica.gestioneiter.IGestoreCompetenze
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgCompetenza
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.sinonimi.RadiceAreaUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.login.detail.UnitaOrganizzativa
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.FetchMode
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.zk.ui.util.Clients

import javax.sql.DataSource
import java.sql.SQLException

@Slf4j
class ProtocolloGestoreCompetenze implements IGestoreCompetenze {

    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    DataSource dataSource

    void rimuoviCompetenze(IDocumentoIterabile domainObject,
                           WkfTipoOggetto oggetto, Attore attore, boolean lettura,
                           boolean modifica, boolean cancellazione, WkfCfgCompetenza comp) {
        if (log.isInfoEnabled()) {
            log.info("Rimuovo la competenza (idCfgComp: ${comp?.id}[${oggetto.codice},${domainObject.tipoOggetto.codice}]) [${lettura ? 'lettura' : ''}, ${modifica ? 'modifica' : ''}, ${cancellazione ? 'cancellazione' : ''}] all'attore ${attore} sul documento [${domainObject}]")
        }

        if (oggetto.codice == domainObject.tipoOggetto.codice) {
            // rimuovo le competenze all'oggetto che sta iterando
            rimuoviCompetenzeGenerico(domainObject, attore, lettura, modifica, cancellazione, comp)

            // propago la rimozione delle competenze agli oggetti collegati al documento principale (se questo l'oggetto che sta iterando è un documento principale)
            rimuoviCompetenzeDocumentiCollegati(domainObject, attore, lettura, modifica, cancellazione, comp)
        }
    }

    private void rimuoviCompetenzeDocumentiCollegati(Documento domainObject, Attore attore, boolean lettura, boolean modifica, boolean cancellazione, WkfCfgCompetenza comp) {
        for (DocumentoCollegato dc : domainObject.documentiCollegati) {
            rimuoviCompetenzeGenerico(dc.collegato, attore, true, false, false, comp)
        }
    }

    void assegnaCompetenze(IDocumentoIterabile domainObject,
                           WkfTipoOggetto oggetto, Attore attore, boolean lettura,
                           boolean modifica, boolean cancellazione, WkfCfgCompetenza comp) {
        if (modifica) {
            cancellazione = true
        }

        if (log.isInfoEnabled()) {
            log.info("Assegno la competenza (idCfgComp: ${comp?.id}[${oggetto?.codice},${domainObject.tipoProtocollo?.categoria}]) [${lettura ? 'lettura' : ''}, ${modifica ? 'modifica' : ''}, ${cancellazione ? 'cancellazione' : ''}] all'attore ${attore} sul documento [${domainObject}]")
        }

        // do le competenze all'oggetto che sta iterando
        assegnaCompetenzeGenerico(domainObject, attore, lettura, modifica, cancellazione, comp)
    }

    private void rimuoviCompetenzeGenerico(Object d, Attore attore, boolean lettura, boolean modifica, boolean cancellazione, WkfCfgCompetenza comp) {
        if (log.isDebugEnabled()) {
            log.debug("Rimuovo le competenze (idCfgComp: ${comp?.id}) [${lettura ? 'lettura' : ''}, ${modifica ? 'modifica' : ''}, ${cancellazione ? 'cancellazione' : ''}] all'attore ${attore} sul documento ${d}")
        }

        // WARN: assumo di eliminare solo le competenze in modifica, che una volta che le ho in lettura non le posso mai eliminare.
        //		 questa è una condizione molto forte che verrà a cadere con una gestione migliore delle competenze.
        //getCompetenze(d, attore, comp, { eq("modifica", true) })*.delete()
        def competenzeInModifica = getCompetenze(d, attore, comp, { eq("modifica", true) })

        for (def competenza : competenzeInModifica) {
            competenza.modifica = false
            competenza.cancellazione = false
            competenza.save()
        }
    }

    void rimuoviCompetenzeCancellazioneDaDocumentoCompetenze(IDocumentoIterabile domainObject) {
        if (log.isDebugEnabled()) {
            log.debug("Rimuovo le competenze di cancellazione da GDO_DOCUMENTO_COMPETENZE")
        }
        List<DocumentoCompetenze> competenze = DocumentoCompetenze.findAllByDocumento(domainObject)

        for (DocumentoCompetenze competenza : competenze) {
            competenza.cancellazione = false
            competenza.save()
        }
    }

    def getCompetenze(Object d, Attore attore, WkfCfgCompetenza comp = null, Closure filtro = null) {
        return DocumentoCompetenze.createCriteria().list {
            eq("documento", d)

            if (attore.utenteAd4 != null) {
                eq("utenteAd4", attore.utenteAd4)
            } else {
                isNull("utenteAd4")
            }

            if (attore.ruoloAd4 != null) {
                eq("ruoloAd4", attore.ruoloAd4)
            } else {
                isNull("ruoloAd4")
            }

            if (attore.unitaSo4 != null) {
                eq("unitaSo4.progr", attore.unitaSo4.progr)
                eq("unitaSo4.ottica.codice", attore.unitaSo4.ottica.codice)

// RIMUOVO IL DAL (siccome è parte della chiave primaria)				
//						eq ("unitaSo4.dal", 			attore.unitaSo4.dal)
            } else {
                isNull("unitaSo4")
            }

            if (comp != null) {
                eq("cfgCompetenza", comp)
                // WARN: assumo di eliminare solo le competenze assegnate dal flusso, ignoro le altre.
            }

            if (filtro != null) {
                filtro.delegate = delegate
                filtro()
            }
        }
    }

    /**
     * Assegna le competenze al documento per un dato attore.
     *
     * Segue la logica:
     *      1) verifico se ho già una riga di competenza per documento-utente-ruolo-unità
     *      2) inserisco se non c'è
     *      3) aggiorno la riga se c'è
     *      4) è un metodo che "AGGIUNGE" competenze, non "TOGLIE": se quindi viene invocato con lettura:true,modifica:false, e l'utente ha lettura:true,modifica:true, rimarrà uguale. (non verrà tolta modifica)
     *
     * @param d documento su cui aggiornare la competenza
     * @param attore l'attore con la tupla documento-utente-ruolo-unità
     * @param lettura se true: da' le competenze in lettura
     * @param modifica se true: da' le competenze in modifica
     * @param cancellazione se true: da' le competenze in cancellazione
     * @param comp la configurazione che ha generato la competenza da aggiornare
     */
    private void assegnaCompetenzeGenerico(Object d, Attore attore, boolean lettura, boolean modifica, boolean cancellazione, WkfCfgCompetenza comp) {
        if (log.isDebugEnabled()) {
            log.debug("Assegno le competenze (idCfgComp: ${comp?.id}) [${lettura ? 'lettura' : ''}, ${modifica ? 'modifica' : ''}, ${cancellazione ? 'cancellazione' : ''}] all'attore ${attore} sul documento [documento:${d.id}]")
        }

        // ottengo tutte le competenze per l'attore
        def competenze = getCompetenze(d, attore)

        if (competenze == null || competenze.size() == 0) {
            competenze = [DocumentoCompetenze.newInstance()]
        }

        // in teoria ne becco una sola, faccio un for che non si sa mai:
        for (def competenza : competenze) {
            competenza.documento = d
            competenza.cfgCompetenza = comp ?: competenza.cfgCompetenza
            // se la competenza passata è null, riassegno quella esistente.
            // faccio così perché quando assegno le competenze dalle notifiche al jwf,
            // non ho una competenza e passo null. In questo modo, non asfalto quello che già c'è
            // e che mi serve in fase di eliminazione delle competenze.

            // siccome qui sto solo "dando" delle competenze, do priorità a quelle che ho già dato:
            competenza.lettura = (lettura || competenza.lettura)
            competenza.modifica = (modifica || competenza.modifica)
            competenza.cancellazione = (cancellazione || competenza.cancellazione)

            competenza.utenteAd4 = attore.utenteAd4
            if (competenza.utenteAd4 == null) {
                competenza.ruoloAd4 = attore.ruoloAd4
                competenza.unitaSo4 = attore.unitaSo4
            }

            competenza.save()
        }
    }

    def getListaCompetenze(domainObject) {
        return DocumentoCompetenze.createCriteria().list {
            eq("documento", domainObject)

            fetchMode("unitaSo4", FetchMode.JOIN)
            fetchMode("ruoloAd4", FetchMode.JOIN)
            fetchMode("utenteAd4", FetchMode.JOIN)
        }
    }

    /**
     * Copia le competenze di un documento su un altro.
     * Se viene specificato "solaLettura=true" allora verranno copiate tutte le competenze ma verranno messe in sola lettura.
     *
     * @param daDocumento il documento di cui copiare le competenze
     * @param aDocumento il documento su cui copiare le competenze
     * @param solaLettura se true le nuove competenze verranno create come sola lettura, altrimenti verranno copiate normalmente.
     */
    void copiaCompetenze(daDocumento, aDocumento, boolean solaLettura) {
        def competenze = getListaCompetenze(daDocumento)
        for (def c : competenze) {
            Attore attore = new Attore(utenteAd4: c.utenteAd4, ruoloAd4: c.ruoloAd4, unitaSo4: c.unitaSo4)
            assegnaCompetenzeGenerico(aDocumento, attore, solaLettura ? true : c.lettura, solaLettura ? false : c.modifica, solaLettura ? false : c.cancellazione, c.cfgCompetenza)
        }
    }

    /**
     * ritorna una mappa  [lettura: (boolean), modifica: (boolean), cancellazione: (boolean)] con le competenze calcolate sul documento per l'utente corrente.
     *
     * @param domainObject oggetto di cui si vogliono controllare le competenze
     * @return la mappa delle competenze.
     */
    @Override
    Map<String, Boolean> getCompetenze(IDocumentoIterabile domainObject) {
        if (domainObject.id > 0) {
            Map<String, Boolean> competenze = getCompetenzeFunzionali(domainObject)

            // se sono presenti competenze funzionali, ritorno subito quelle.
            if (competenze != null) {
                return controllaStatoAnnullamento(competenze, domainObject)
            }

            // altrimenti cerco le competenze del documento su AGSPR.
            competenze = internalGetCompetenze(domainObject)
            return controllaStatoAnnullamento(competenze, domainObject)
        } else {
            return [lettura: true, modifica: true, cancellazione: true]
        }
    }

    private Map<String, Boolean> controllaStatoAnnullamento(Map<String, Boolean> competenze, IDocumentoIterabile domainObject) {
        if (competenze?.modifica && domainObject.class == Protocollo.class) {
            if (domainObject.stato == StatoDocumento.RICHIESTO_ANNULLAMENTO || domainObject.stato == StatoDocumento.DA_ANNULLARE || domainObject.stato == StatoDocumento.ANNULLATO) {
                return [lettura: true, modifica: false, cancellazione: false]
            }
        }
        return competenze
    }

    /**
     * ritorna una mappa  [lettura: (boolean), modifica: (boolean), cancellazione: (boolean)] con le competenze calcolate sul documento per l'utente corrente
     * Richiama le funzioni oracle: AGP_COMPETENZE_PROTOCOLLO.MODIFICA (p_id_documento VARCHAR2, p_utente VARCHAR2)
     * AGP_COMPETENZE_PROTOCOLLO.LETTURA (p_id_documento VARCHAR2, p_utente VARCHAR2)
     *
     * Ritorna una mappa [lettura: true, modifica: false, cancellazione:false] se l'utente ha le sole competenze di lettura.
     * Ritorna una mappa [lettura: true, modifica: true, cancellazione: true] se l'utente ha i diritti di modifica
     * Ritorna NULL se non vengono trovate competenze funzionali: in questo caso, vanno poi verificate le competenze "normali" su AGSPR.
     *
     * @param domainObject oggetto di cui si vogliono controllare le competenze
     * @return la mappa delle competenze oppure NULL se non ci sono competenze funzionali
     */
    private Map<String, Boolean> getCompetenzeFunzionali(IDocumentoIterabile domainObject) {
        try {
            Sql sql = new Sql(dataSource)

            GroovyRowResult result

            if (domainObject.categoriaProtocollo?.isSmistamentoAttivoInCreazione()) {

                result = sql.firstRow('select AGP_COMPETENZE_DOCUMENTO.MODIFICA (?, ?) MODIFICA from dual', [domainObject.id, springSecurityService.principal.id])

                if (result.MODIFICA == 1) {
                    return [lettura: true, modifica: true, cancellazione: true]
                }

                result = sql.firstRow('select AGP_COMPETENZE_DOCUMENTO.LETTURA (?, ?) LETTURA from dual', [domainObject.id, springSecurityService.principal.id])

            } else {

                result = sql.firstRow('select AGP_COMPETENZE_PROTOCOLLO.MODIFICA (?, ?) MODIFICA from dual', [domainObject.id, springSecurityService.principal.id])

                if (result.MODIFICA == 1) {
                    return [lettura: true, modifica: true, cancellazione: true]
                }

                result = sql.firstRow('select AGP_COMPETENZE_PROTOCOLLO.LETTURA (?, ?) LETTURA from dual', [domainObject.id, springSecurityService.principal.id])

            }

            if (result.LETTURA == null) {
                return null
            }

            if (result.LETTURA == 1) {
                return [lettura: true, modifica: false, cancellazione: false]
            }

            return [lettura: false, modifica: false, cancellazione: false]
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    /**
     * ritorna una mappa  [lettura: (boolean), modifica: (boolean), cancellazione: (boolean)] con le competenze calcolate sul fascicolo per l'utente corrente
     * Richiama le funzioni oracle: AGP_COMPETENZE_FASCICOLO.LETTURA (id_dodumento_esterno VARCHAR2, p_utente VARCHAR2)
     *
     * Ritorna una mappa [lettura: true, modifica: false, cancellazione:false] se l'utente ha le sole competenze di lettura.
     * Ritorna NULL se non vengono trovate competenze
     *
     * @param domainObject oggetto di cui si vogliono controllare le competenze
     * @return la mappa delle competenze oppure NULL se non ci sono competenze funzionali
     */
    public Map<String, Boolean> getCompetenzeFascicolo(Fascicolo domainObject) {
        try {
            Sql sql = new Sql(dataSource)

            GroovyRowResult result

            result = sql.firstRow('select AGP_COMPETENZE_FASCICOLO.LETTURA_BY_ID_DOC (?, ?) LETTURA from dual', [domainObject.idDocumentoEsterno, springSecurityService.principal.id])

            if (result.LETTURA == null) {
                return null
            }

            if (result.LETTURA == 1) {
                return [lettura: true, modifica: false, cancellazione: false]
            }

            return [lettura: false, modifica: false, cancellazione: false]

        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    private Map<String, Boolean> internalGetCompetenze(domainObject) {
        So4UserDetail utente = springSecurityService.principal
        def map = [lettura: false, modifica: false, cancellazione: false]

        def res = DocumentoCompetenze.createCriteria().get {
            projections {
                documento {
                    groupProperty("id")
                }

                max("lettura")
                max("modifica")
                max("cancellazione")
            }

            eq("documento", domainObject)

            ProtocolloGestoreCompetenze.controllaCompetenze(delegate)(utente)
        }

        // l'utente amministratore ha competenze di lettura su tutti i record trovati
        // le altre competenze invece vengono lette da db
        if (Utils.isUtenteAmministratore()) {
            map.lettura = true
        } else {
            map.lettura = (res != null && res[1])
        }
        map.modifica = (res != null && res[2])
        map.cancellazione = (res != null && res[3])

        return map
    }

    /**
     * Ritorna l'elenco degli attori che hanno competenze sul documento.
     * È possibile specificare se si vogliono solo le competenze in lettura, in modifica o tutte.
     *
     * @param domainObject oggetto di cui si vogliono ottenere le competenze
     * @param lettura se true, indica di selezionare solo le competenze in "lettura" sul documento.
     * @param modifica se true, indica di selezionare solo le competenze in "modifica" sul documento.
     * @return Elenco degli attori che hanno competenza sul documento.
     */
    List<Attore> getAttoriCompetenze(domainObject, boolean lettura = false, boolean modifica = false) {
        def competenze = DocumentoCompetenze.createCriteria().list {
            eq(documento, domainObject)
        }

        List<Attore> attori = []

        for (def competenza : competenze) {
            // aggiungo solo gli attori che hanno le competenze richieste
            if ((lettura == false || (lettura && competenza.lettura)) &&
                    (modifica == false || (modifica && competenza.modifica))) {
                attori << new Attore(utenteAd4: competenza.utenteAd4, ruoloAd4: competenza.ruoloAd4, unitaSo4: competenza.unitaSo4)
            }
        }

        return attori
    }

    /**
     * Criterio di controllo delle competenze:
     *
     * 	1) per ogni uo di #delegate (successivamente indicata come #uoiesima) verifico che
     * 		a) se l'utente non è nullo questo
     * 				-> sia pari al mio
     * 		b) non è indicato nè ruolo, nè unità nè utente
     * 		c) se l'utente è nullo e ruolo o unità sono indicati verifico che
     * 				-> l'unità indicata è #uoiesima e ho i ruoli indicati
     * 				-> l'unità è nulla ma ho i ruoli indicati
     * 				-> l'unità indicata è uoiesima e non ci sono ruoli indicati
     *
     * @param delegate
     * @return
     */
    static controllaCompetenze(delegate, String propertyUtente = "utenteAd4", String propertyUnita = "unitaSo4", String propertyRuolo = "ruoloAd4") {
        def c = { utente ->
            or {
                // se sono l'utente
                eq("${propertyUtente}.id", utente.id)

                // se ho il ruolo con unità null
                and {
                    isNull(propertyUnita)
                    or {
                        for (String codice : utente?.uo()?.ruoli?.flatten()?.codice?.unique()) {
                            eq("${propertyRuolo}.ruolo", codice)
                        }
                    }
                }

                for (UnitaOrganizzativa uo : utente.uo()) {

                    // se ho il ruolo per l'unità
                    and {
                        and {
                            eq("${propertyUnita}.progr", uo.id)
                            eq("${propertyUnita}.ottica.codice", uo.ottica)
                        }
                        or {
                            for (def r : uo.ruoli) {
                                eq("${propertyRuolo}.ruolo", r.codice)
                            }

                            // se ho l'unità ma con il ruolo null
                            isNull(propertyRuolo)
                        }
                    }
                }
            }
        }

        c.delegate = delegate
        return c
    }

    /**
     * @return true se l'utente corrente è abilitato alla visualizzazione dei documenti riservati.
     */
    boolean utenteCorrenteVedeRiservato(Documento documento, String utente = springSecurityService.principal.id) {
        try {
            GroovyRowResult result
            Sql sql = new Sql(dataSource)

            if (!(documento instanceof Protocollo)) {
                return true
            }
            if (documento.categoriaProtocollo?.isSmistamentoAttivoInCreazione()) {
                result = sql.firstRow('select AGP_COMPETENZE_DOCUMENTO.LETTURA (?, ?) LETTURA from dual', [documento.id, springSecurityService.principal.id])
            } else {
                result = sql.firstRow('select AGP_COMPETENZE_PROTOCOLLO.LETTURA (?, ?) LETTURA from dual', [documento.id, utente])
            }

            if (result.LETTURA == 1) {
                return true
            }
            return false

        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    boolean controllaRiservato(Protocollo documento) {
        if ((documento.riservato || documento.fascicolo.riservato) && !utenteCorrenteVedeRiservato(documento)) {
            Clients.showNotification("Attenzione: l'utente corrente non è abilitato alla visione del testo: il documento è riservato.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
            return false
        }
        return true
    }

    List<So4UnitaPubb> getUnitaPerPrivilegio(Ad4Utente utente, String privilegio) {
        List<String> codiciUnita

        if (privilegio.equals(RadiceAreaUtente.VISUALIZZA_AREA_UNITA)) {
            codiciUnita = RadiceAreaUtente.getPrivilegi(utente, privilegio).list().codiceUnita
        } else {
            codiciUnita = privilegioUtenteService.getPrivilegi(utente, privilegio).codiceUnita
        }
        if (codiciUnita?.size() == 0) {
            return []
        }
        return So4UnitaPubb.allaData().perOttica(Impostazioni.OTTICA_SO4.valore).findAllByCodiceInList(codiciUnita)
    }

    boolean utenteHaPrivilegio(Ad4Utente utente, String privilegio, String codiceUnita = null) {
        return privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegio, codiceUnita, utente)
    }

    boolean controllaPrivilegio(String privilegio) {
        return privilegioUtenteService.utenteHaPrivilegio(privilegio)
    }

    /**
     * Verifica se l'utente ha le competenze di lettura sul documento
     *
     */
    boolean verificaCompetenzeLettura(Protocollo protocollo) {
        Map competenze = getCompetenze(protocollo)
        if (!competenze || !competenze?.lettura) {
            return false
        }
        return true
    }
}
