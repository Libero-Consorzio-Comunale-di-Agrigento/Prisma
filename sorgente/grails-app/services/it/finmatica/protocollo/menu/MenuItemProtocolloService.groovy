package it.finmatica.protocollo.menu

import commons.menu.MenuItem
import commons.menu.MenuItemProtocollo
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.AbilitazioneSmistamentoService
import it.finmatica.protocollo.dizionari.AccessoCivicoService
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivicoDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematico
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematicoRepository
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamento
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional(readOnly = true)
@Service
public class MenuItemProtocolloService {

    @Autowired
    ProtocolloPkgService protocolloPkgService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    GestioneDocumentiSpringSecurityService springSecurityService
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    AbilitazioneSmistamentoService abilitazioneSmistamentoService
    @Autowired
    SchemaProtocolloService schemaProtocolloService
    @Autowired
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @Autowired
    ProtocolloRiferimentoTelematicoRepository protocolloRiferimentoTelematicoRepository
    @Autowired
    AccessoCivicoService accessoCivicoService

    /**
     * Ritorna le voci di menu da visualizzare
     **/
    List<String> getVociVisibiliMenu(Protocollo protocollo, boolean competenzaInModifica, List<MenuItem> menuItems) {
        if (protocollo.categoriaProtocollo.codice == CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice) {
            List<String> vociMenu = protocolloPkgService.agpMenuGetBarraMProtocollo(protocollo.idDocumentoEsterno.longValue(), protocollo.categoriaProtocollo.codice, competenzaInModifica)
            vociMenu.add(MenuItemProtocollo.NUOVO_DA_FASCICOLARE_INS)
            vociMenu.add(MenuItemProtocollo.COPIA)
            return vociMenu
        } else {
            List<String> abilitazioniMenuList = new ArrayList<String>()

            for (menuItem in menuItems) {
                if (isAbilitatoMenu(menuItem, protocollo, competenzaInModifica)) {
                    abilitazioniMenuList.add(menuItem.codice)
                }
            }

            return abilitazioniMenuList
        }
    }

    private boolean isAbilitatoMenu(MenuItem menuItem, Protocollo protocollo, boolean competenzaInModifica) {
        boolean isAbilitato
        switch (menuItem.codice) {
            case MenuItemProtocollo.NUOVO: isAbilitato = isAbilitatoNuovo(protocollo); break;
            case MenuItemProtocollo.NUOVO_INS: isAbilitato = isAbilitatoNuovoIns(protocollo); break;
            case MenuItemProtocollo.NUOVA_LETTERA: isAbilitato = isAbilitatoNuovaLettera(protocollo); break;
            case MenuItemProtocollo.NUOVA_LETTERA_INS: isAbilitato = isAbilitatoNuovaLetteraIns(protocollo); break;
        //TODO eventualmente si voglia vedere questa voce in altre categorie occoore implementare il metorodo isAbilitatoNuovoDaFascicolare
        //case MenuItemProtocollo.NUOVO_DA_FASCICOLARE: isAbilitato = isAbilitatoNuovoDaFascicolare(protocollo); break;
            case MenuItemProtocollo.NUOVO_DA_FASCICOLARE_INS: isAbilitato = isAbilitatoNuovoDaFascicolareIns(protocollo); break;
            case MenuItemProtocollo.COPIA: isAbilitato = isAbilitatoCopia(protocollo); break;
            case MenuItemProtocollo.RISPOSTA: isAbilitato = isAbilitatoRisposta(protocollo, competenzaInModifica, false); break;
            case MenuItemProtocollo.ANNULLA_PROTOCOLLO: isAbilitato = isAbilitatoAnnulla(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.RISPOSTA_CON_LETTERA: isAbilitato = isAbilitatoRisposta(protocollo, competenzaInModifica, true); break;
            case MenuItemProtocollo.RICHIEDI_ANNULLAMENTO: isAbilitato = isAbilitatoRichiediAnnullamento(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.MAIL: isAbilitato = isAbilitatoInvioPec(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.PUBBLICA_ALBO: isAbilitato = isAbilitatoPubblicaAlbo(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.APRI_MOTIVO_ECCEZIONE: isAbilitato = isAbilitatoNotificaEccezione(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.INVIA_RICEVUTA: isAbilitato = /*true*/isAbilitatoInviaRicevuta(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.ALLEGATI_MAIL: isAbilitato = isAbilitatoAllegatiMail(protocollo); break;
            case MenuItemProtocollo.MAIL_ORIGINALE: isAbilitato = isAbilitatoScaricaMailOriginale(protocollo); break;
            case MenuItemProtocollo.CREA_INOLTRO: isAbilitato = isAbilitatoCreaInoltro(protocollo, false); break;
            case MenuItemProtocollo.CREA_INOLTRO_LETTERA: isAbilitato = isAbilitatoCreaInoltro(protocollo, true); break;
            case MenuItemProtocollo.IMPORT_ALLEGATI: isAbilitato = isAbilitatoImportAllegatiDaDocumentale(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.STAMPA_BC: isAbilitato = isAbilitatoStampaBarcode_StampaProtocollo(protocollo); break;
            case MenuItemProtocollo.STAMPA_DOCUMENTO: isAbilitato = isAbilitatoStampaBarcode_StampaProtocollo(protocollo); break;
            case MenuItemProtocollo.STAMPA_RICEVUTA: isAbilitato = isAbilitatoStampaRicevuta(protocollo, competenzaInModifica); break;
            case MenuItemProtocollo.STAMPA_SMISTAMENTI_INTEGRATI: isAbilitato = isAbilitatoStampaSmistamentiIntegrati(protocollo); break;
            case MenuItemProtocollo.STAMPA_UNICA: isAbilitato = isAbilitatoStampaUnica_UnicaSubito(protocollo, false); break;
            case MenuItemProtocollo.STAMPA_UNICA_SUBITO: isAbilitato = isAbilitatoStampaUnica_UnicaSubito(protocollo, true); break;
            case MenuItemProtocollo.SCARICA_ZIP_ALLEGATI: isAbilitato = true; break;
            case MenuItemProtocollo.GESTIONE_ANAGRAFICA: isAbilitato = isAbilitatoGestioneAnagrafica(); break;
            case MenuItemProtocollo.CARICO: isAbilitato = isPrendiInCarico(protocollo); break;
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA: isAbilitato = isPrendiInCaricoEdAssegna(protocollo); break;
            case MenuItemProtocollo.APRI_CARICO_FLEX: isAbilitato = isPrendiInCaricoEdInoltra(protocollo); break;
            case MenuItemProtocollo.CARICO_ESEGUI: isAbilitato = isPrendiInCaricoEdEsegui(protocollo, false); break;
            case MenuItemProtocollo.APRI_ESEGUI_FLEX: isAbilitato = isPrendiInCaricoEdEsegui(protocollo, true); break;
            case MenuItemProtocollo.RIPUDIO: isAbilitato = isRifiutaSmistamento(protocollo); break;
            case MenuItemProtocollo.FATTO: isAbilitato = (competenzaInModifica) ? isEsegui(protocollo) : false; break;
            case MenuItemProtocollo.FATTO_IN_VISUALIZZA: isAbilitato = (!competenzaInModifica) ? isEsegui(protocollo) : false; break;
            case MenuItemProtocollo.APRI_ASSEGNA: isAbilitato = isAssegna(protocollo); break;
            case MenuItemProtocollo.APRI_INOLTRA_FLEX: isAbilitato = isInoltra(protocollo); break;
            case MenuItemProtocollo.APRI_SMISTA_FLEX: isAbilitato = isInserimentoNuovoSmismamento(protocollo); break;
            case MenuItemProtocollo.IMPORTA_RIFERIMENTI_TELEMATICI: isAbilitato = isAbilitatoImportaRiferimentiTelematici(protocollo); break;
            case MenuItemProtocollo.VISUALIZZA_SEGNATURA: isAbilitato = isAbilitatoVisualizzaSegnatura(protocollo); break;

            default: isAbilitato = false;
        }

        return isAbilitato
    }

    /**
     * Utente ha privilegio CPROT valido
     * Il Documento è di categoria Protocollo o PEC o LETTERA o da NON PROTOCOLLARE
     * */
    public boolean isAbilitatoNuovo(Protocollo protocollo) {
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_PROTOCOLLO, springSecurityService.currentUser) &&
                (protocollo.categoriaProtocollo.isLettera() ||
                        protocollo.categoriaProtocollo.isPec() ||
                        protocollo.categoriaProtocollo.isDaNonProtocollare()
                )) {
            return true
        }

        return false
    }

    /**
     * Utente ha privilegio CPROT valido
     * Il Documento è di categoria Protocollo o PEC o LETTERA o da NON PROTOCOLLARE
     * */
    public boolean isAbilitatoNuovoIns(Protocollo protocollo) {
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_PROTOCOLLO, springSecurityService.currentUser) &&
                (protocollo.categoriaProtocollo.isProtocollo()
                )) {
            return true
        }

        return false
    }

    /**
     * Utente ha privilegio REDLET
     * Il Documento è di categoria Protocollo o PEC o LETTERA
     *
     * */
    public boolean isAbilitatoNuovaLettera(Protocollo protocollo) {
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_LETTERA, springSecurityService.currentUser) &&
                (protocollo.categoriaProtocollo.isProtocollo() ||
                        protocollo.categoriaProtocollo.isPec()
                )) {
            return true
        }

        return false
    }

    /**
     * Utente ha privilegio REDLET
     * Il Documento è di categoria Protocollo o PEC o LETTERA
     *
     * */
    public boolean isAbilitatoNuovaLetteraIns(Protocollo protocollo) {
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_LETTERA, springSecurityService.currentUser) &&
                (protocollo.categoriaProtocollo.isLettera()
                )) {
            return true
        }

        return false
    }

    /**
     * Utente ha privilegio CPROT valido
     * Il Documento è da NON PROTOCOLLARE
     * */
    public boolean isAbilitatoNuovoDaFascicolareIns(Protocollo protocollo) {
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_PROTOCOLLO, springSecurityService.currentUser) &&
                (protocollo.categoriaProtocollo.isDaNonProtocollare()
                )) {
            return true
        }

        return false
    }

    /**
     * Il Documento non ha numero di protocollo
     * L'Utente ha privilegio CPROT ed il Documento è di categoria Protocollo
     *      oppure
     * L'Utente ha privilegio REDLET ed il Documento è di categoria LETTERA
     * */
    private boolean isAbilitatoCopia(Protocollo protocollo) {
        if (protocollo.isProtocollato() || protocollo.categoriaProtocollo.isDaNonProtocollare()) {
            if (protocollo.categoriaProtocollo.isLettera() || protocollo.categoriaProtocollo.isProtocollo()) {
                if (privilegioUtenteService.utenteHaPrivilegio(protocollo.categoriaProtocollo.privilegioCreazione, springSecurityService.currentUser)) {
                    return true
                }
            }
        }

        return false
    }

    /**
     * Il Documento ha numero di protocollo
     *
     * Il Documento non è annullato, non è da a annullare e non è stata effettuata nessuna richiesta di annullamento
     *
     * L'utente ha privilegio CPROT (senza lettera) e il Documento è di categoria PROTOCOLLO O PEC
     *
     * Il Documento non è interno (senza lettera)
     *
     * o Il Documento è in arrivo (con lettera)
     *
     * Il Documento non ha tipo documento
     *     oppure
     * Il Documento ha un tipo documento senza risposta associata
     *     oppure
     * Il Documento ha un tipo documento con risposta associata ma non ancora creata
     *
     *  Il Documento non ha tipo documento
     *     oppure
     * Il Documento ha un tipo documento senza risposta associata
     * */
    private boolean isAbilitatoRisposta(Protocollo protocollo, boolean competenzaInModifica, boolean conLettera) {

        String privilegio = (conLettera) ? PrivilegioUtente.REDATTORE_LETTERA : PrivilegioUtente.REDATTORE_PROTOCOLLO

        if (!protocollo.isProtocollato()) {
            return false
        }

        if (protocollo.isAnnullato()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (protocollo.statoFirma?.firmaInterrotta) {
            return false
        }

        if (!(privilegioUtenteService.utenteHaPrivilegio(privilegio, springSecurityService.currentUser)) &&
                (protocollo.categoriaProtocollo.isProtocollo() ||
                        protocollo.categoriaProtocollo.isPec()
                )) {
            return false
        }

        if (!conLettera && protocollo.movimento == Protocollo.MOVIMENTO_INTERNO) {
            return false
        }

        if (conLettera && protocollo.movimento != Protocollo.MOVIMENTO_ARRIVO) {
            return false
        }

        // non fare comparire "rispondi con lettera" se il protocollo ha flag DOMANDA_ACCESSO = 'Y'
        if (conLettera && protocollo.schemaProtocollo?.domandaAccesso) {
            return false
        }

        if (protocollo.idDocumentoEsterno) {
            ProtocolloDTO p = protocollo.toDTO()
            if (p) {
                ProtocolloAccessoCivicoDTO protocolloAccessoCivico = accessoCivicoService.recuperaDatiAccessoDallaDomanda(p)
                Protocollo risposta = protocolloAccessoCivico?.protocolloRisposta?.domainObject
                if (risposta && !risposta.annullato) {
                    return false
                }
            }
        }
        return true
    }

    /**
     * Il Documento ha numero di protocollo
     *
     * Il Documento non è annullato e non è da annullare
     *
     * L'impostazione ANN_DIRETTO vale Y
     *
     * L'utente ha privilegio ANNPROT
     *
     * Il Doccumento è aperto in modifica
     *  oppure
     * Il Documento è aperto in lettura ma con firma in corso
     * */
    private boolean isAbilitatoAnnulla(Protocollo protocollo, boolean competenzaInModifica) {
        if (!(ImpostazioniProtocollo.ANN_DIRETTO.isAbilitato())) {
            return false
        }

        if (!protocollo.isProtocollato()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (!(privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO, springSecurityService.currentUser))) {
            return false
        }

        if (!competenzaInModifica && protocollo.statoFirma?.isFirmaInterrotta()) {
            return true
        }

        if (!competenzaInModifica) {
            return false
        }

        return true
    }

    /**
     * Il Documento ha numero di protocollo
     *
     * Il Documento non è annullato e non è da annullare e non da richiesta annullamento
     *
     * Il Documento è aperto in modifica
     *
     * L'impostazione ANN_DIRETTO vale N
     *
     * Il Doccumento è aperto in modifica
     *  oppure
     * Il Documento è aperto in lettura ma con firma in corso
     * */
    private boolean isAbilitatoRichiediAnnullamento(Protocollo protocollo, boolean competenzaInModifica) {

        if (ImpostazioniProtocollo.ANN_DIRETTO.isAbilitato()) {
            return false
        }

        if (!protocollo.isProtocollato()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (protocollo.tipoProtocollo?.categoriaProtocollo?.isProvvedimento()) {
            return false
        }

        if (!competenzaInModifica && protocollo.statoFirma?.isFirmaInterrotta()) {
            return true
        }

        if (!competenzaInModifica) {
            return false
        }

        return true
    }

    /**
     * Il Documento è aperto in modifica
     *
     * Il Documento è in partenza
     *
     * Il Documento ha numero di protocollo
     *
     * Il Documento non è annullato e non è da annullare
     * */
    private boolean isAbilitatoInvioPec(Protocollo protocollo, boolean competenzaInModifica) {
        if (!competenzaInModifica) {
            return false
        }

        if (protocollo.movimento != Protocollo.MOVIMENTO_PARTENZA) {
            return false
        }

        if (!protocollo.isProtocollato()) {
            return false
        }

        if (protocollo.isAnnullato()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (protocollo.statoFirma?.firmaInterrotta) {
            return false
        }

        return true
    }

    /**
     * Il Documento è aperto in modifica
     *
     * Il Documento ha numero di protocollo
     *
     * L'utente ha il privilegio PUBALBO
     * */
    private boolean isAbilitatoPubblicaAlbo(Protocollo protocollo, boolean competenzaInModifica) {
        if (!competenzaInModifica) {
            return false
        }

        if (protocollo.isAnnullato()) {
            return false
        }

        if (!protocollo.isProtocollato()) {
            return false
        }

        if (!(privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PUBALBO, springSecurityService.currentUser))) {
            return false
        }

        if (protocollo.statoFirma?.firmaInterrotta) {
            return false
        }

        return true
    }

    /**
     * Il Documento è aperto in modifica
     *
     * Il Documento è di categoria PEC
     *
     * Il Documento non è protocollato
     *
     * Il parametro IS_ENTE_INTERPRO vale N
     *  oppure
     * Il parametro IS_ENTE_INTERPRO vale Y ed il documento è nato da un messaggio di segnatura
     * */
    private boolean isAbilitatoNotificaEccezione(Protocollo protocollo, boolean competenzaInModifica) {
        boolean abilitazione

        if (!competenzaInModifica) {
            return false
        }

        if (!protocollo.categoriaProtocollo.isPec()) {
            return false
        }

        if (protocollo.isProtocollato()) {
            return false
        }

        abilitazione = true
        if (ImpostazioniProtocollo.IS_ENTE_INTERPRO.isAbilitato()) {
            abilitazione = abilitazione && protocolloUtilService.isConSegnatura(protocollo)
        }

        return abilitazione
    }

    /**
     * Il Documento è aperto in modifica
     *
     * Il Documento è di categoria PEC
     *
     * Il parametro IS_ENTE_INTERPRO vale N
     *
     * Il documento è nato da un messaggio senza segnatura
     * */
    private boolean isAbilitatoInviaRicevuta(Protocollo protocollo, boolean competenzaInModifica) {
        if (!competenzaInModifica) {
            return false
        }

        if (!protocollo.categoriaProtocollo.isPec()) {
            return false
        }

        if (ImpostazioniProtocollo.IS_ENTE_INTERPRO.isAbilitato()) {
            return false
        }

        if (protocolloUtilService.isConSegnatura(protocollo)) {
            return false
        }

        if (!protocollo.protocollato) {
            return false
        }

        return true
    }

    /**
     * Il Documento è di categoria PEC
     *
     * Il Documento non è annullato e non è da annullare
     *
     * L'utente ha i privilegi per poter creare nuovi allegati
     * */
    private boolean isAbilitatoAllegatiMail(Protocollo protocollo) {
        if (!protocollo.categoriaProtocollo.isPec()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (!privilegioUtenteService.isInserimentoAllegati((ProtocolloDTO) protocollo.toDTO())) {
            return false
        }

        return true
    }

    /**
     * Il Documento è di categoria PEC
     *
     * Il Documento è protocollato
     * */
    private boolean isAbilitatoScaricaMailOriginale(Protocollo protocollo) {
        return protocollo.categoriaProtocollo.isPec() && protocollo.isProtocollato()
    }

    /**
     * Il Documento è protocollato
     *
     * Il Documento è interno o in arrivo
     *
     * Il Documento è di categoria PEC,PROTOCOLLO, LETTERA
     *
     * L'utente ha privilegio CPROT O REDLET (se con lettera o meno)
     * */
    private boolean isAbilitatoCreaInoltro(Protocollo protocollo, boolean conLettera) {
        if (!protocollo.isProtocollato()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (protocollo.movimento != Protocollo.MOVIMENTO_INTERNO && protocollo.movimento != Protocollo.MOVIMENTO_ARRIVO) {
            return false
        }

        if (!(protocollo.categoriaProtocollo.isProtocollo() ||
                protocollo.categoriaProtocollo.isPec() ||
                protocollo.categoriaProtocollo.isLettera())) {
            return false
        }

        String privilegio = (conLettera) ? PrivilegioUtente.REDATTORE_LETTERA : PrivilegioUtente.REDATTORE_PROTOCOLLO
        if (!privilegioUtenteService.utenteHaPrivilegio(privilegio, springSecurityService.currentUser)) {
            return false
        }

        return true
    }

    /**
     * L'impostazione IMPORT_ALLEGATO_GDM vale Y
     *
     * L'utente ha i privilegi per poter creare nuovi allegati
     *
     * Il Documento è di categoria PROTOCOLLO, LETTERA
     * */
    private boolean isAbilitatoImportAllegatiDaDocumentale(Protocollo protocollo, boolean competenzaInModifica) {
        if (!ImpostazioniProtocollo.IMPORT_ALLEGATO_GDM.isAbilitato()) {
            return false
        }

        if (!competenzaInModifica) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (!privilegioUtenteService.isInserimentoAllegati((ProtocolloDTO) protocollo.toDTO())) {
            return false
        }

        if (!(protocollo.categoriaProtocollo.isProtocollo() || protocollo.categoriaProtocollo.isLettera())) {
            return false
        }

        return true
    }

    /**
     * Il Documento è protocollato
     * */
    private boolean isAbilitatoStampaBarcode_StampaProtocollo(Protocollo protocollo) {
        return protocollo.isProtocollato()
    }

    /**
     * Il Documento è in arrivo
     * Il Documento è protocollato
     * Il Documento è aperto in modifica
     *  oppure
     * Il Documento è annullato
     * */
    private boolean isAbilitatoStampaRicevuta(Protocollo protocollo, boolean competenzaInModifica) {

        if (protocollo.movimento != Protocollo.MOVIMENTO_ARRIVO) {
            return false
        }

        if (!protocollo.isProtocollato()) {
            return false
        }

        if (protocollo.isAnnullamentoInCorso()) {
            return false
        }

        if (!competenzaInModifica) {
            return false
        }

        return true
    }

    /**
     * Il Documento è protocollato
     * L'impostazione ITER_FASCICOLI vale Y
     * */
    private boolean isAbilitatoStampaSmistamentiIntegrati(Protocollo protocollo) {

        return ImpostazioniProtocollo.ITER_FASCICOLI.isAbilitato() && protocollo.isProtocollato()
    }

    /**
     * Il Documento è protocollato
     *
     * L'impostazione STAMPA_UNICA vale Y (per il pulsante stampaUnica)
     * L'impostazione STAMPA_UNICA_SUBITO vale Y (per il pulsante stampaUnicaSubito)
     * */
    private boolean isAbilitatoStampaUnica_UnicaSubito(Protocollo protocollo, boolean subito) {
        if (!protocollo.isProtocollato()) {
            return false
        }

        if (!((ImpostazioniProtocollo.STAMPA_UNICA.isAbilitato() && !subito) ||
                (ImpostazioniProtocollo.STAMPA_UNICA_SUBITO.isAbilitato() && subito))) {
            return false
        }

        return true
    }

    /**
     * L'utente ha uno dei ruoli elencati nell'impostazione RUOLI_GEST_ANAG
     * */
    private boolean isAbilitatoGestioneAnagrafica() {
        for (valore in ImpostazioniProtocollo.RUOLI_GEST_ANAG.valori) {
            if (springSecurityService.principal.hasRuolo(valore)) {
                return true
            }
        }

        return false

        //Todo verifica con mia che sia così come scritto sopra oppure deve usare i ruoli di ad4
        /*String ruoliGestAnag = "#" + StringUtility.nvl(ImpostazioniProtocollo.RUOLI_GEST_ANAG.valore, "") + "#"

        for (ruolo in springSecurityService.currentUser.ruoli) {
            if (ruoliGestAnag.indexOf("#" + ruolo.ruolo + "#") != -1) {
                abilitazione = true
            }
        }*/
    }

    /**
     * Il documento ha uno smistamento in stato da ricevere per un'unica cui l'utetne appartiene
     * L'utente deve avere privilegi
     * VS (VSR se il documento è riservato) e CARICO sull'unità di smistamento e il documenti non deve essere assegnato
     * oppure
     * L'utente deve essere assegnatario del documento
     * */
    public isPrendiInCarico(ISmistabile smistabile) {
        boolean abilitazione

        if ((smistabile instanceof Protocollo) && (smistabile.getIdDocumentoEsterno() == null)) {
            return false
        }

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile,
                [Smistamento.DA_RICEVERE])
        if (listaSmistamentiDaRiceverePerUnitaAppartenenza.size() == 0) {
            return false
        }

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenzaConPrivilegi = smistamentiPrivilegiVSAndCaricoSuUnita(smistabile, listaSmistamentiDaRiceverePerUnitaAppartenenza)
        if (listaSmistamentiDaRiceverePerUnitaAppartenenzaConPrivilegi.size() > 0) {
            boolean almenoUnoPerCompentenza = false
            for (Smistamento s : listaSmistamentiDaRiceverePerUnitaAppartenenzaConPrivilegi) {
                if (s.perCompetenza) {
                    almenoUnoPerCompentenza = true
                    break
                }
            }

            if (almenoUnoPerCompentenza) {
                return true
            }
        }

        // controllo che io sia l'assegnatario di uno smistamento per competenza
        for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
            smistamento.utenteAssegnatario != null && smistamento.tipoSmistamento == Smistamento.COMPETENZA && (smistamento.utenteAssegnatario?.id == springSecurityService.currentUser.id)
        }

        return abilitazione
    }

    public isPrendiInCaricoIgnorandoTipo(ISmistabile smistabile) {
        boolean abilitazione

        if ((smistabile instanceof Protocollo) && (smistabile.getIdDocumentoEsterno() == null)) {
            return false
        }

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile,
                [Smistamento.DA_RICEVERE])
        if (listaSmistamentiDaRiceverePerUnitaAppartenenza.size() == 0) {
            return false
        }

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenzaConPrivilegi = smistamentiPrivilegiVSAndCaricoSuUnita(smistabile, listaSmistamentiDaRiceverePerUnitaAppartenenza)
        if (listaSmistamentiDaRiceverePerUnitaAppartenenzaConPrivilegi.size() > 0) {
            return true
        }

        // controllo che io sia l'assegnatario di uno smistamento per competenza
        for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
            smistamento.utenteAssegnatario != null && (smistamento.utenteAssegnatario?.id == springSecurityService.currentUser.id)
        }

        return abilitazione
    }

    /**
     * Il documento ha uno smistamento in stato da ricevere per un'unica cui l'utetne appartiene
     * L'utente deve avere privilegi
     * VS (VSR se il documento è riservato) e CARICO sull'unità di smistamento e il documenti non deve essere assegnato
     * oppure
     * L'utente deve essere assegnatario del documento
     * L'utente ha privilegio ASSTOT
     * oppure
     * L'utente ha privilegio ASS per l'ufficio dello smistamento
     * L'unità ricevente è aperta
     * Il tipoSmistamento, statoSmistamento e azione ASSEGNA sono presenti in AbilitazioniSmistamenti
     * */
    public isPrendiInCaricoEdAssegna(ISmistabile smistabile) {

        boolean abilitazione, privilegioAssTot

        if (!isPrendiInCarico(smistabile)) {
            return false
        }

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile,
                [Smistamento.DA_RICEVERE])

        privilegioAssTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VISUALIZZA_COMPONENTI_TUTTE_UNITA, springSecurityService.currentUser)

        for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
            abilitazione = abilitazione || (
                    smistamento.getUnitaSmistamento().al == null &&
                            (privilegioAssTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA))
                            && (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                            smistamento.statoSmistamento, "ASSEGNA").size() > 0))
        }

        return abilitazione
    }

    /**
     * E' valida la condizione di "prendi in carico"
     *
     * Per almeno uno smistamento (s) di (S) del prendi in carico:
     *      L'unità ricevente è aperta
     *
     *      L'utente ha privilegio ISMITOT
     *          oppure
     *      L'utente ha privilegio ISMI per l'ufficio dello smistamento
     *
     *      il tipoSmistamento, statoSmistamento e azione INOLTRA sono presenti in AbilitazioniSmistamenti
     *
     * Il protocollo ha tipologia di documento con sequenza e l'ultimo ufficio non è quello di uno degli smistamenti di (S) (todo.. da verificare con MIA)
     *  oppure
     * Il protocollo non ha associata una tipologia di documento con sequenza
     * */
    public isPrendiInCaricoEdInoltra(ISmistabile smistabile) {

        if (!isPrendiInCaricoIgnorandoTipo(smistabile)) {
            return false
        }

        boolean abilitazione, privilegioIsmiTot

        privilegioIsmiTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, springSecurityService.currentUser)

        List<SchemaProtocolloSmistamento> schemaProtocolloSmistamentoList
        if (smistabile?.schemaProtocollo != null) {
            schemaProtocolloSmistamentoList = schemaProtocolloService.getSchemiProtocolloSmistamento(smistabile.schemaProtocollo.id)
        } else {
            schemaProtocolloSmistamentoList = new ArrayList<SchemaProtocolloSmistamento>()
        }

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile,
                [Smistamento.DA_RICEVERE])

        for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
            if (smistamento.getUnitaSmistamento().al == null &&
                    (privilegioIsmiTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.SMISTAMENTO_CREA)) &&
                    (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                            smistamento.statoSmistamento, "INOLTRA").size() > 0)) {
                if (schemaProtocolloSmistamentoList.size() == 0) {
                    return true
                } else {
                    abilitazione = abilitazione ||
                            (schemaProtocolloSmistamentoList.get(schemaProtocolloSmistamentoList.size() - 1).unitaSo4Smistamento.id != smistamento.unitaSmistamento.id)
                }
            }
        }

        return abilitazione
    }

    /**
     * E' valida la condizione di "prendi in carico"
     *
     * L'unità ricevente di almeno uno smistamento (S) ha
     * tipoSmistamento, statoSmistamento e azione ESEGUI/ESEGUISMISTA per lo smista presente in AbilitazioniSmistamenti
     * */
    public isPrendiInCaricoEdEsegui(ISmistabile smistabile, boolean smista) {
        if (!isPrendiInCaricoIgnorandoTipo(smistabile)) {
            return false
        }

        String tipoAzione = "ESEGUI"
        if (smista) {
            tipoAzione = "ESEGUISMISTA"
        }

        boolean abilitazione, privilegioIsmiTot

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile, [Smistamento.DA_RICEVERE])

        for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
            abilitazione = abilitazione || (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                    smistamento.statoSmistamento, tipoAzione).size() > 0)
        }

        if (!abilitazione) {
            return false
        }

        if (smista) {
            privilegioIsmiTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, springSecurityService.currentUser)

            for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {

                abilitazione = (privilegioIsmiTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.SMISTAMENTO_CREA)) &&
                        (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                                smistamento.statoSmistamento, tipoAzione).size() > 0)
            }
        }

        return abilitazione
    }

    /**
     * E' valida la condizione di "prendi in carico"
     *
     * Il protocollo non ha tipo di documento associato
     *  oppure
     * Il protocollo non ha associata una tipologia di documento con sequenza
     *  oppure
     * Il protocollo ha tipologia di documento con sequenza ma non si è al primo passo della sequenza
     * */
    public isRifiutaSmistamento(ISmistabile protocollo) {

        if ((!isPrendiInCaricoIgnorandoTipo(protocollo))) {
            return false
        }

        if (protocollo.schemaProtocollo != null) {
            List<SchemaProtocolloSmistamento> schemaProtocolloSmistamentoList = schemaProtocolloService.getSchemiProtocolloSmistamento(protocollo.schemaProtocollo.id)

            if (schemaProtocolloSmistamentoList.size() == 0) {
                return true
            }

            List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(protocollo, [Smistamento.DA_RICEVERE])

            //Controllo come primo schemaProtocolloSmistamento un'unità diversa da alemno uno degli smistamenti da ricevere per unità di appartenenza
            for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
                if (schemaProtocolloSmistamentoList.get(0).unitaSo4Smistamento.id != smistamento.getUnitaSmistamento().id) {
                    return true
                }
            }
        } else {
            true
        }
    }

    /**
     * Il documento ha uno o più smistamenti (S) in stato in carico per un'unità cui l'utente appartiene
     *
     * L'utente ha privilegi VS (VSR se riservato)
     *
     * Il singolo smistamento (s) di (S) non deve essere assegnato
     *  oppure
     * L'utente deve essere l'assegnatario di (s)
     * */
    public isEsegui(ISmistabile smistabile) {
        boolean abilitazione

        if (smistabile instanceof Protocollo && smistabile.idDocumentoEsterno == null) {
            return false
        }

        if (smistabile.isAnnullamentoInCorso()) {
            return false
        }

        List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile, [Smistamento.IN_CARICO])

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        abilitazione = controllaPrivilegiVSAndCaricoSuUnita(smistabile, listaSmistamentiInCaricoPerUnitaAppartenenza)
        if (abilitazione) {
            return true
        }

        for (smistamento in listaSmistamentiInCaricoPerUnitaAppartenenza) {
            abilitazione = abilitazione || (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                    smistamento.statoSmistamento, "ESEGUI").size() > 0)
        }

        return abilitazione
    }

    private boolean controllaPrivilegiSuUnita(ISmistabile smistabile, List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza) {

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        String privilegio
        if (smistabile.riservato) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        } else {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        }

        int numeroDiUnitaConPrivilegio = 0

        for (Smistamento s : listaSmistamentiInCaricoPerUnitaAppartenenza)
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegio, s.unitaSmistamento.codice, springSecurityService.currentUser)) {
                numeroDiUnitaConPrivilegio = numeroDiUnitaConPrivilegio + 1
            }

        return (numeroDiUnitaConPrivilegio > 0)
    }

    private boolean controllaPrivilegiVSAndVDAndCaricoSuUnita(Protocollo protocollo, List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza) {

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        String privilegioVd
        if (protocollo.riservato) {
            privilegioVd = PrivilegioUtente.VDDRR
        } else {
            privilegioVd = PrivilegioUtente.VDDR
        }

        String privilegio
        if (protocollo.riservato) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        } else {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        }

        int numeroDiUnitaConPrivilegio = 0

        for (Smistamento s : listaSmistamentiInCaricoPerUnitaAppartenenza)
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegio, s.unitaSmistamento.codice, springSecurityService.currentUser) &&
                    privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegioVd, s.unitaSmistamento.codice, springSecurityService.currentUser) &&
                    privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_CARICO, s.unitaSmistamento.codice, springSecurityService.currentUser)) {
                numeroDiUnitaConPrivilegio = numeroDiUnitaConPrivilegio + 1
            }

        return (numeroDiUnitaConPrivilegio > 0)
    }

    private boolean controllaPrivilegiVSAndCaricoSuUnita(ISmistabile smistabile, List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza) {

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        String privilegio
        if (smistabile.getRiservato()) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        } else {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        }

        int numeroDiUnitaConPrivilegio = 0

        for (Smistamento s : listaSmistamentiInCaricoPerUnitaAppartenenza)
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegio, s.unitaSmistamento.codice, springSecurityService.currentUser) &&
                    privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_CARICO, s.unitaSmistamento.codice, springSecurityService.currentUser)) {
                numeroDiUnitaConPrivilegio = numeroDiUnitaConPrivilegio + 1
            }

        return (numeroDiUnitaConPrivilegio > 0)
    }

    private List<Smistamento> smistamentiPrivilegiVSAndCaricoSuUnita(ISmistabile smistabile, List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza) {

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return []
        }

        List<Smistamento> smistamentiConPrivilegi = new ArrayList<Smistamento>()

        String privilegio
        if (smistabile.getRiservato()) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        } else {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        }

        for (Smistamento s : listaSmistamentiInCaricoPerUnitaAppartenenza)
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegio, s.unitaSmistamento.codice, springSecurityService.currentUser) &&
                    privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_CARICO, s.unitaSmistamento.codice, springSecurityService.currentUser)) {
                smistamentiConPrivilegi.add(s)
            }

        return smistamentiConPrivilegi
    }

    /**
     * Il documento ha uno o più smistamenti (S) in stato in carico od eseguito per un'unità cui l'utente appartiene
     *
     * L'utente ha privilegi VS (VSR se riservato)
     *
     * Per almeno uno smistamento (s) di (S):
     *      Il singolo smistamento non deve essere assegnato
     *            oppure
     *      L'utente deve esserne l'assegnatario
     *
     *      L'utente ha privilegio ASSTOT
     *          oppure
     *      L'utente ha privilegio ASS per l'ufficio ricevente
     *
     *      L'unita ricevente è aperta
     *
     *      tipo_smistamento, stato_smistamento e azione ASSEGNA sono presenti in AbilitazioniSmistamenti
     * */
    public isAssegna(ISmistabile smistabile) {
        boolean abilitazione
        String privilegioAssTot

        if (smistabile instanceof Protocollo && smistabile.idDocumentoEsterno == null) {
            return false
        }

        if (smistabile.isAnnullamentoInCorso()) {
            return false
        }

        List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile, [Smistamento.IN_CARICO, Smistamento.ESEGUITO])

        if (!controllaPrivilegiSuUnita(smistabile, listaSmistamentiInCaricoPerUnitaAppartenenza)) {
            return false
        }
        privilegioAssTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VISUALIZZA_COMPONENTI_TUTTE_UNITA, springSecurityService.currentUser)
        for (smistamento in listaSmistamentiInCaricoPerUnitaAppartenenza) {
            abilitazione = abilitazione ||
                    ((smistamento.utenteAssegnatario == null || smistamento.utenteAssegnatario?.id == springSecurityService.currentUser.id) &&
                            (privilegioAssTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA)) &&
                            (smistamento.getUnitaSmistamento().al == null) &&
                            (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                                    smistamento.statoSmistamento, "ASSEGNA").size() > 0)
                    )
        }

        return abilitazione
    }

    /**
     * Il documento ha uno o più smistamenti (S) in stato in carico od eseguito per un'unità cui l'utente appartiene
     *
     * L'utente ha privilegi VS (VSR se riservato)
     *
     * Per almeno uno smistamento (s) di (S):
     *      Il singolo smistamento non deve essere assegnato
     *            oppure
     *      L'utente deve esserne l'assegnatario
     *
     *      L'utente ha privilegio ISMITOT
     *          oppure
     *      L'utente ha privilegio ISMI per l'ufficio ricevente
     *
     *      tipo_smistamento, stato_smistamento e azione INOLTRA sono presenti in AbilitazioniSmistamenti
     *
     * Il protocollo ha tipologia di documento con sequenza e l'ultimo ufficio non è quello di uno degli smistamenti di (S) (todo.. da verificare con MIA)
     *  oppure
     * Il protocollo non ha associata una tipologia di documento con sequenza
     * */
    public isInoltra(ISmistabile smistabile) {
        boolean abilitazione
        String privilegio, privilegioIsmiTot

        if (smistabile.idDocumentoEsterno == null) {
            return false
        }

        if (smistabile.isAnnullamentoInCorso()) {
            return false
        }

        List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile, [Smistamento.IN_CARICO, Smistamento.ESEGUITO])

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        if (!controllaPrivilegiSuUnita(smistabile, listaSmistamentiInCaricoPerUnitaAppartenenza)) {
            return false
        }

        List<SchemaProtocolloSmistamento> schemaProtocolloSmistamentoList = (smistabile.schemaProtocollo != null) ?
                schemaProtocolloService.getSchemiProtocolloSmistamento(smistabile.schemaProtocollo.id) : (new ArrayList<SchemaProtocolloSmistamento>())
        privilegioIsmiTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, springSecurityService.currentUser)
        for (smistamento in listaSmistamentiInCaricoPerUnitaAppartenenza) {
            if ((smistamento.utenteAssegnatario == null || smistamento.utenteAssegnatario?.id == springSecurityService.currentUser.id) &&
                    (privilegioIsmiTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA)) &&
                    (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                            smistamento.statoSmistamento, "INOLTRA").size() > 0)
            ) {
                if (schemaProtocolloSmistamentoList.size() == 0) {
                    abilitazione = true
                    break;
                } else {
                    abilitazione = abilitazione ||
                            (schemaProtocolloSmistamentoList.get(schemaProtocolloSmistamentoList.size() - 1).unitaSo4Smistamento.id != smistamento.unitaSmistamento.id)
                }
            }
        }

        return abilitazione
    }

    /**
     * L'utente ha privilegio ISMITOT
     *  oppure
     * L'utente ha privilegio ISMI e il documento non è protocollato
     *  oppure
     * Il documento è protocollato o annullato o da annullare
     *      L'utente è l'utente protocollatore
     *          oppure
     *      L'utente fa parte dell'unità protocollante o esibente con privilegio ISMI + CPROT
     *          oppure
     *      L'utente fa parte di un'unità ricevente e tipo_smistamento, stato_smistamento e azione
     *      SMISTA sono presenti in AbilitazioniSmistamenti
     * */
    private isInserimentoNuovoSmismamento(Protocollo protocollo) {

        if (!protocollo.isProtocollato()) {
            return true
        }

        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, springSecurityService.currentUser)) {
            return true
        }

        if ((protocollo.isProtocollato()) || (protocollo.stato == StatoDocumento.RICHIESTO_ANNULLAMENTO)) {
            DocumentoSoggetto utenteProtocollatore = protocollo.getSoggetto(TipoSoggetto.REDATTORE)
            DocumentoSoggetto unitaProtocollante = protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)

            if (utenteProtocollatore != null && utenteProtocollatore.utenteAd4.id == springSecurityService.currentUser.id) {
                return true
            }

            List<So4UnitaPubb> listaUnitaUtente = strutturaOrganizzativaService.getUnitaUtente(springSecurityService.principal.id,
                    springSecurityService.principal.ottica().codice)

            if (unitaProtocollante != null && listaUnitaUtente != null && listaUnitaUtente.find {
                it.id == unitaProtocollante.unitaSo4.id
            }) {
                return true
            }

            if (listaUnitaUtente != null) {
                for (smistamento in protocollo.getSmistamentiValidi()) {
                    if (listaUnitaUtente.find { it.id == smistamento.getUnitaSmistamento().id } &&
                            (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                                    smistamento.statoSmistamento, "SMISTA").size() > 0)) {
                        return true
                    }
                }
            }
        }

        return false
    }

    private boolean isAbilitatoImportaRiferimentiTelematici(Protocollo protocollo) {
        // issue #36469: Aggiungere importa riferimenti telematici se il protocollo è di caregoria PEC
        if (protocollo.categoriaProtocollo.isPec()) {
            boolean esistonoRifTelematici = protocolloRiferimentoTelematicoRepository.findByProtocollo(protocollo).find {
                ProtocolloRiferimentoTelematico rif -> !rif.scaricato
            }
            return esistonoRifTelematici
        }
    }

    private boolean isAbilitatoVisualizzaSegnatura(Protocollo protocollo) {
        return protocollo.isProtocollato()
    }
}