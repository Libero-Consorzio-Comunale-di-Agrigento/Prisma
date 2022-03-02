package it.finmatica.protocollo.notifiche

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.notifiche.Allegato
import it.finmatica.gestionedocumenti.notifiche.NotificaDestinatario
import it.finmatica.gestionedocumenti.notifiche.calcolo.NotificaSoggetto
import it.finmatica.gestionedocumenti.notifiche.calcolo.RegolaCalcoloNotifica.TipoMetodo
import it.finmatica.gestionedocumenti.notifiche.calcolo.TipoNotifica
import it.finmatica.gestionedocumenti.notifiche.calcolo.annotated.AnnotatedRegolaCalcolo
import it.finmatica.gestionedocumenti.notifiche.calcolo.annotated.RegolaCalcolo
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.StampaUnicaService
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamento
import it.finmatica.protocollo.documenti.annullamento.StatoAnnullamento
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.io.IOUtils
import org.apache.cxf.common.util.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

import javax.servlet.ServletContext

@Slf4j
@Component
class RegoleCalcoloNotificheProtocolloRepository implements AnnotatedRegolaCalcolo {

    public static final String NOTIFICA_CAMBIO_NODO = "CAMBIO_NODO"
    public static final String NOTIFICA_CAMBIO_NODO_FIRMATARIO = "CAMBIO_NODO_FIRMATARIO"
    public static final String NOTIFICA_RICHIESTA_ANNULLAMENTO = "RICHIESTA_ANNULLAMENTO"
    public static final String NOTIFICA_RICHIESTA_ANNULLAMENTO_APPROVATA = "ANNULLAMENTO_APPROVATO"
    public static final String NOTIFICA_RICHIESTA_ANNULLAMENTO_RIFIUTATA = "ANNULLAMENTO_RIFIUTATO"
    public static final String NOTIFICA_EMAIL_GDM_SMISTAMENTI_CORRENTI = "NOTIFICA_EMAIL_GDM_SMISTAMENTI_CORRENTI"
    public static final String NOTIFICA_SCADENZA_RISPOSTA_GDM = "NOTIFICA_SCADENZA_RISPOSTA_GDM"
    public static final String NOTIFICA_EMAIL_SCADENZA = "NOTIFICA_EMAIL_SCADENZA"
    public static final String NOTIFICA_TODO_SCADENZA = "NOTIFICA_TODO_SCADENZA"
    public static final String NOTIFICA_TODO_SMISTAMENTI_IN_ERRORE = "NOTIFICA_TODO_SMISTAMENTI_IN_ERRORE"
    public static final String NOTIFICA_PROTOCOLLO_EMERGENZA = "NOTIFICA_PROTOCOLLO_EMERGENZA"
    public static final String ERRORE_REGISTRO_GIORNALIERO = "ERRORE_REGISTRO_GIORNALIERO"

    public static final String NOTIFICA_GENERICA_1 = "NOTIFICA_GENERICA_1"
    public static final String NOTIFICA_GENERICA_2 = "NOTIFICA_GENERICA_2"
    public static final String NOTIFICA_GENERICA_3 = "NOTIFICA_GENERICA_3"
    public static final String NOTIFICA_GENERICA_4 = "NOTIFICA_GENERICA_4"
    public static final String NOTIFICA_GENERICA_5 = "NOTIFICA_GENERICA_5"
    public static final String NOTIFICA_GENERICA_6 = "NOTIFICA_GENERICA_6"
    public static final String NOTIFICA_GENERICA_7 = "NOTIFICA_GENERICA_7"
    public static final String NOTIFICA_GENERICA_8 = "NOTIFICA_GENERICA_8"
    public static final String NOTIFICA_GENERICA_9 = "NOTIFICA_GENERICA_9"
    public static final String NOTIFICA_GENERICA_10 = "NOTIFICA_GENERICA_10"

    @Autowired
    ServletContext servletContext

    @Autowired
    IGestoreFile gestoreFile

    @Autowired
    GestioneTestiService gestioneTestiService

    @Autowired
    StrutturaOrganizzativaService strutturaOrganizzativaService

    @Autowired
    ProtocolloGdmService protocolloGdmService

    @Autowired
    StampaUnicaService stampaUnicaService

    @Autowired
    ProtocolloService protocolloService

    @Autowired
    PrivilegioUtenteService privilegioUtenteService

    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze

    @Override
    List<TipoNotifica> getListaTipiNotifica() {
        return [new TipoNotifica(codice: NOTIFICA_CAMBIO_NODO, titolo: "Cambio Nodo", descrizione: "Notifica che viene inviata quando il documento passa da un nodo all'altro del flusso.", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_CAMBIO_NODO_FIRMATARIO, titolo: "Cambio Nodo Firmatario", descrizione: "Notifica di cambio nodo che viene inviata al Firmatario", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_RICHIESTA_ANNULLAMENTO, titolo: "Richiesta Annullamento", descrizione: "Notifica che viene inviata quando viene inoltrata la richiesta di annullamento.", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_RICHIESTA_ANNULLAMENTO_APPROVATA, titolo: "Richiesta Annullamento Approvata", descrizione: "Notifica che viene inviata quando la richiesta di annullamento viene approvata.", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_EMAIL_SCADENZA, titolo: "Email Scadenza", descrizione: "Email Scadenza", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_TODO_SCADENZA, titolo: "Attività TODO Scadenza", descrizione: "Attività TODO Scadenza", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_TODO_SMISTAMENTI_IN_ERRORE, titolo: "Notifica di Errore durante gli simstamenti", descrizione: "Notifica di Errore durante gli simstamenti", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_RICHIESTA_ANNULLAMENTO_RIFIUTATA, titolo: "Richiesta Annullamento Rifiutata", descrizione: "Notifica che viene inviata quando la richiesta di annullamento viene rifiutata.", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_EMAIL_GDM_SMISTAMENTI_CORRENTI, titolo: "Notifica E-mail Smistamenti correnti", descrizione: "Notifica E-mail Smistamenti correnti", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_SCADENZA_RISPOSTA_GDM, titolo: "Notifica TODO Smistamenti correnti", descrizione: "Notifica TODO Smistamenti correnti", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_PROTOCOLLO_EMERGENZA, titolo: "Notifica Protocollo Emergenza", descrizione: "Notifica Protocollo Emergenza", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: ERRORE_REGISTRO_GIORNALIERO, titolo: "Errore registro giornaliero", descrizione: "Errore registro giornaliero", oggetti: [Protocollo.TIPO_DOCUMENTO])

                // configurazione delle notifiche generiche
                , new TipoNotifica(codice: NOTIFICA_GENERICA_1, titolo: "Notifica Generica 1", descrizione: "Notifica Generica 1", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_2, titolo: "Notifica Generica 2", descrizione: "Notifica Generica 2", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_3, titolo: "Notifica Generica 3", descrizione: "Notifica Generica 3", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_4, titolo: "Notifica Generica 4", descrizione: "Notifica Generica 4", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_5, titolo: "Notifica Generica 5", descrizione: "Notifica Generica 5", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_6, titolo: "Notifica Generica 6", descrizione: "Notifica Generica 6", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_7, titolo: "Notifica Generica 7", descrizione: "Notifica Generica 7", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_8, titolo: "Notifica Generica 8", descrizione: "Notifica Generica 8", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_9, titolo: "Notifica Generica 9", descrizione: "Notifica Generica 9", oggetti: [Protocollo.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_GENERICA_10, titolo: "Notifica Generica 10", descrizione: "Notifica Generica 10", oggetti: [Protocollo.TIPO_DOCUMENTO])
        ]
    }

    @Override
    String getTipoDocumento(Object documento) {
        if (documento.class == Protocollo) {
            //log.debug(documento.class.toString())
            return Protocollo.TIPO_DOCUMENTO
        }

        return null
    }

    @Override
    String getIdRiferimento(Object documento) {
        if (documento?.class == Protocollo) {
            return documento.idDocumentoEsterno
        } else if (documento?.class == MessaggioRicevuto) {
            return documento.idDocumentoEsterno
        }
        return null
    }

    @Override
    Object getDocumento(String idRiferimento) {
        try {
            long idDocumentoEsterno = Long.parseLong(idRiferimento)
            return Protocollo.findByIdDocumentoEsterno(idDocumentoEsterno)
        } catch (NumberFormatException e) {
            return null
        }
    }

    @RegolaCalcolo(codice = "GET_SOGGETTO_REDATTORE", tipo = TipoMetodo.DESTINATARI, titolo = "Il Redattore del documento", descrizione = "Il Redattore del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getSoggettoREDATTORE(Documento documento, NotificaDestinatario notificaDestinatario) {
        return getSoggetto(documento, TipoSoggetto.REDATTORE)
    }

    @RegolaCalcolo(codice = "GET_SOGGETTO_FUNZIONARIO", tipo = TipoMetodo.DESTINATARI, titolo = "Il Funzionario del documento", descrizione = "Il Funzionario del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getSoggettoFUNZIONARIO(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        return getSoggetto(documento, TipoSoggetto.FUNZIONARIO)
    }

    @RegolaCalcolo(codice = "GET_SOGGETTO_DIRIGENTE", tipo = TipoMetodo.DESTINATARI, titolo = "Il Dirigente del documento", descrizione = "Il Dirigente Firmatario del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getSoggettoDIRIGENTE(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        return getSoggetto(documento, TipoSoggetto.FIRMATARIO)
    }

    @RegolaCalcolo(codice = "GET_UTENTE_RICHIESTA_ANNULLAMENTO", tipo = TipoMetodo.DESTINATARI, titolo = "L'utente che ha effettuato la Richiesta di Annullamento", descrizione = "L'utente che ha effettuato la Richiesta di Annullamento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getUtenteRichiestaAnnullamento(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        Ad4Utente utente = ProtocolloAnnullamento.findByProtocollo(documento)?.utenteIns
        if (utente == null) {
            return []
        }

        As4SoggettoCorrente soggetto = As4SoggettoCorrente.findByUtenteAd4(utente)

        return [new NotificaSoggetto(utente: utente?.toDTO(), email: soggetto?.indirizzoWeb, soggetto: soggetto?.toDTO())]
    }

    @RegolaCalcolo(codice = "UTENTI_PER_NOTIFICA_RICHIESTA_ANNULLAMENTO", tipo = TipoMetodo.DESTINATARI, titolo = "Utenti che possono accettare o rifiutare una Richiesta di Annullamento", descrizione = "Utenti che possono accettare o rifiutare una Richiesta di Annullamento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getUtentiNotificaRichiestaAnnullamento(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        List<NotificaSoggetto> utentiPerNotificaRichiestaAnnullamento = new ArrayList<NotificaSoggetto>()
        ProtocolloAnnullamento protocolloAnnullamento = ProtocolloAnnullamento.findByProtocolloAndStato(documento, StatoAnnullamento.RICHIESTO)
        if (protocolloAnnullamento == null) {
            return []
        }
        List<Ad4Utente> utentiConPrivilegioAnnullamentoProtocollo = privilegioUtenteService.getAllUtenti(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO)

        for (Ad4Utente utentiPrivilegioAnnProt : utentiConPrivilegioAnnullamentoProtocollo) {
            As4SoggettoCorrente soggetto = As4SoggettoCorrente.findByUtenteAd4(utentiPrivilegioAnnProt)
            NotificaSoggetto ns = new NotificaSoggetto(utente: utentiPrivilegioAnnProt?.toDTO(), email: soggetto?.indirizzoWeb, soggetto: soggetto?.toDTO())
            utentiPerNotificaRichiestaAnnullamento.add(ns)
        }
        return utentiPerNotificaRichiestaAnnullamento
    }

    @RegolaCalcolo(codice = "UTENTI_UNITA_PROTOCOLLANTE", tipo = TipoMetodo.DESTINATARI, titolo = "Utenti dell'unità Protocollante del documento", descrizione = "Unità Protocollante", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getDestinatarioUnitaProtocollante(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        So4UnitaPubb uoProtocollante = documento?.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4
        if (uoProtocollante != null) {
            return getComponentiUnita(uoProtocollante)
        }
        return []
    }

    @RegolaCalcolo(codice = "INDIRIZZO_MANUALE_UNITA_PROTOCOLLANTE", tipo = TipoMetodo.DESTINATARI, titolo = "Unità Protocollante del documento (Indirizzo telematico manuale)", descrizione = "Unità Protocollante del documento (Indirizzo telematico manuale)", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getIndirizzotelematicoManuale(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        List<NotificaSoggetto> soggetti = []
        So4UnitaPubb uoProtocollante = documento?.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4
        if (uoProtocollante != null) {
            NotificaSoggetto ns = getIndirizzotelematicoManuale(uoProtocollante)
            if (ns != null) {
                soggetti << ns
            }
        }
        return soggetti
    }

    /**
     * Recupera le unità (indirizzi telematici) degli smistamenti correnti su GDM, se non ce ne sono restituisce l'Unità Protocollante
     *
     * @param documento
     * @param notificaDestinatario
     * @return
     */
    @RegolaCalcolo(codice = "UNITA_SMISTAMENTI_CORRENTI_GDM", tipo = TipoMetodo.DESTINATARI, titolo = "", descrizione = "Unità (indirizzi telematici) degli smistamenti correnti su GDM, se non ce ne sono restituisce l'Unità Protocollante", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> unitaSmistamentiCorrentiGdm(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        List<So4UnitaPubb> unitaPubbList = protocolloGdmService.unitaSmistamentoCorrenti(documento, Smistamento.COMPETENZA)
        if (unitaPubbList.size() == 0) {
            unitaPubbList = []
            unitaPubbList << documento?.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4
        }

        List<NotificaSoggetto> soggetti = []
        for (So4UnitaPubb uo : unitaPubbList) {
            NotificaSoggetto ns = getIndirizzotelematicoManuale(uo)
            if (ns != null) {
                soggetti << ns
            }
        }
        return soggetti
    }

    /**
     * Recupera i componenti delle unità degli smistamenti correnti su GDM, se non ce ne sono restituisce quelli dell'Unità Protocollante
     *
     * @param documento
     * @param notificaDestinatario
     * @return
     */
    @RegolaCalcolo(codice = "COMPONENTI_UNITA_SMIST_CORRENTI_GDM", tipo = TipoMetodo.DESTINATARI, titolo = "", descrizione = "Componenti delle Unità degli smistamenti correnti su GDM, se non ce ne sono restituisce l'Unità Protocollante", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<NotificaSoggetto> componentiUnitaSmistamentiCorrentiGdm(Protocollo documento, NotificaDestinatario notificaDestinatario) {
        List<So4UnitaPubb> unitaPubbList = protocolloGdmService.unitaSmistamentoCorrenti(documento, Smistamento.COMPETENZA)
        if (unitaPubbList.size() == 0) {
            unitaPubbList = []
            unitaPubbList << documento?.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4
        }

        List<NotificaSoggetto> soggetti = []
        for (So4UnitaPubb uo : unitaPubbList) {
            soggetti.addAll(getComponentiUnita(uo))
        }
        return soggetti
    }

    List<NotificaSoggetto> getComponentiUnita(So4UnitaPubb uo) {
        List<So4ComponentePubb> componenti = strutturaOrganizzativaService.getComponentiInUnita(uo)
        So4UnitaPubbDTO unita = uo.toDTO()
        List<NotificaSoggetto> soggetti = []
        for (So4ComponentePubb componente : componenti) {
            soggetti << new NotificaSoggetto(unitaSo4: unita, utente: componente.soggetto.utenteAd4.toDTO(), soggetto: componente.soggetto.toDTO())
        }
        return soggetti
    }

    NotificaSoggetto getIndirizzotelematicoManuale(So4UnitaPubb uo) {
        NotificaSoggetto soggetto = null
        String mail = So4IndirizzoTelematico.findByUnitaAndTipoIndirizzo(uo, So4IndirizzoTelematico.PROTOCOLLO_MANUALE)?.indirizzo
        if (!StringUtils.isEmpty(mail)) {
            soggetto = new NotificaSoggetto(unitaSo4: uo.toDTO(), email: mail)
        }

        return soggetto
    }

    private As4SoggettoCorrente getSoggettoCorrente(Documento documento, String tipoSoggetto) {
        def soggettoDocumento = documento.getSoggetto(tipoSoggetto)

        // se non trovo il soggetto sul documento,
        if (soggettoDocumento == null) {
            return null
        }

        Ad4Utente utente = soggettoDocumento.utenteAd4
        if (utente == null) {
            return null
        }

        return As4SoggettoCorrente.findByUtenteAd4(utente)
    }

    private List<NotificaSoggetto> getSoggetto(Documento documento, String tipoSoggetto) {
        As4SoggettoCorrente soggetto = getSoggettoCorrente(documento, tipoSoggetto)
        if (soggetto == null) {
            return []
        }

        Ad4Utente utente = soggetto.utenteAd4
        if (utente == null) {
            return []
        }

        return [new NotificaSoggetto(utente: utente?.toDTO(), email: soggetto?.indirizzoWeb, soggetto: soggetto?.toDTO())]
    }

    /*
     * Metodi per il calcolo dei campi della notifica
     */

    @RegolaCalcolo(codice = "REDATTORE", tipo = TipoMetodo.TAG, titolo = "Il Redattore del documento", descrizione = "Il Redattore del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getREDATTORE(Protocollo documento) {
        As4SoggettoCorrente soggetto = getSoggettoCorrente(documento, TipoSoggetto.REDATTORE)
        if (soggetto == null) {
            return ""
        }

        return "${soggetto.cognome ?: ''} ${soggetto.nome ?: ''}"
    }

    @RegolaCalcolo(codice = "FUNZIONARIO", tipo = TipoMetodo.TAG, titolo = "Il Funzionario del documento", descrizione = "Il Funzionario del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getFUNZIONARIO(Protocollo documento) {
        As4SoggettoCorrente soggetto = getSoggettoCorrente(documento, TipoSoggetto.FUNZIONARIO)
        if (soggetto == null) {
            return ""
        }

        return "${soggetto.cognome ?: ''} ${soggetto.nome ?: ''}"
    }

    @RegolaCalcolo(codice = "DIRIGENTE", tipo = TipoMetodo.TAG, titolo = "Il Dirigente del documento", descrizione = "Il Dirigente Firmatario del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getDIRIGENTE(Protocollo documento) {
        As4SoggettoCorrente soggetto = getSoggettoCorrente(documento, TipoSoggetto.FIRMATARIO)
        if (soggetto == null) {
            return ""
        }
        return "${soggetto.cognome ?: ''} ${soggetto.nome ?: ''}"
    }

    @RegolaCalcolo(codice = "PRIMO_DESTINATARIO", tipo = TipoMetodo.TAG, titolo = "Primo Destinatario", descrizione = "Cognome / Nome del primo destinatario", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getPrimoDestinatario(Protocollo protocollo) {

        Corrispondente corrispondente = protocollo.corrispondenti?.sort { it.id }.find {
            it.tipoCorrispondente == Corrispondente.DESTINATARIO
        }
        if (corrispondente == null) {
            return ""
        }

        return "${corrispondente.denominazione ?: ''}"
    }

    @RegolaCalcolo(codice = "UNITA_PROTOCOLLANTE", tipo = TipoMetodo.TAG, titolo = "Unità Protocollante", descrizione = "Unità Protocollante", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getUnitaProtocollante(Protocollo documento) {
        return documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4?.descrizione
    }

    @RegolaCalcolo(codice = "NOME_NODO", tipo = TipoMetodo.TAG, titolo = "Nome del nodo in cui si trova il documento", descrizione = "Nome del nodo in cui si trova il documento", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getNomeNodo(Protocollo documento) {
        String stepCorrente = documento.iter?.stepCorrente?.cfgStep?.titolo
        String stepNome = documento.iter?.stepCorrente?.cfgStep?.nome
        if (stepNome == Protocollo.STEP_DA_INVIARE) {
            if (Protocollo.MOVIMENTO_INTERNO.equals(documento.movimento)) {
                return "Gestisci"
            } else {
                return stepCorrente
            }
        } else if (stepNome == Protocollo.STEP_INVIATO) {
            if (Protocollo.MOVIMENTO_INTERNO.equals(documento.movimento)) {
                return "Concluso"
            } else {
                return stepCorrente
            }
        }
        return stepCorrente
    }

    @RegolaCalcolo(codice = "MOVIMENTO", tipo = TipoMetodo.TAG, titolo = "Movimento del protocollo (INTERNO / PARTENZA/ ARRIVO)", descrizione = "Movimento del protocollo (INTERNO / PARTENZA /ARRIVO)", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getMovimento(Protocollo documento) {
        if (documento) {
            return documento.movimento
        }

        return Protocollo.MOVIMENTO_INTERNO
    }

    @RegolaCalcolo(codice = "STATO_DOCUMENTO", tipo = TipoMetodo.TAG, titolo = "Stato del documento", descrizione = "Stato del documento", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getStato(Protocollo documento) {
        if (documento) {
            return documento.stato?.toString()
        }
        return ""
    }

    @RegolaCalcolo(codice = "OGGETTO", tipo = TipoMetodo.TAG, titolo = "Oggetto del documento", descrizione = "Oggetto del documento", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getOggetto(Object documento) {
        if (documento) {
            return it.finmatica.protocollo.utils.StringUtils.cleanTextContent(new String(documento.oggetto))
        }
        return ""
    }

    @RegolaCalcolo(codice = "TIPO_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Tipo di protocollo", descrizione = "Tipo di protocollo (Flusso)", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getTitoloTipologia(Protocollo documento) {
        if (documento) {
            return documento.tipoProtocollo.descrizione
        }
        return ""
    }

    @RegolaCalcolo(codice = "DATA_REDAZIONE", tipo = TipoMetodo.TAG, titolo = "Data di Redazione", descrizione = "Data di Redazione", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getDataRedazione(Protocollo documento) {
        return documento?.dataRedazione?.format("dd/MM/yyyy") ?: ""
    }

    @RegolaCalcolo(codice = "DATI_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Dati di protocollo", descrizione = "Dati di protocollazione ANNO / NUMERO / REGISTRO", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getDatiProtocollazione(Protocollo documento) {
        if (documento?.numero > 0) {
            return "Prot n. ${documento.anno} / ${documento.numero} ${documento.tipoRegistro?.codice} del ${documento.data.format("dd/MM/yyyy")}"
        }

        return ""
    }

    @RegolaCalcolo(codice = "ANNO_PROTOCOLLO_PROT", tipo = TipoMetodo.TAG, titolo = "Anno di Protocollo", descrizione = "Contiene l'anno di protocollo", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getAnnoProtocollo(Protocollo protocollo) {
        return protocollo?.anno?.toString() ?: ""
    }

    @RegolaCalcolo(codice = "NUMERO_PROTOCOLLO_PROT", tipo = TipoMetodo.TAG, titolo = "Numero di Protocollo", descrizione = "Contiene il numero di protocollo", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getNumeroProtocollo(Protocollo protocollo) {
        return protocollo?.numero?.toString() ?: ""
    }

    @RegolaCalcolo(codice = "NUMERO_7_PROTOCOLLO_PROT", tipo = TipoMetodo.TAG, titolo = "Numero di Protocollo lpad7", descrizione = "Contiene il numero di protocollo a 7 cifre (ad es: 0000123)", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getNumero7Protocollo(Protocollo protocollo) {
        return protocollo?.numero?.toString().padLeft(7, '0').toString() ?: ""
    }

    @RegolaCalcolo(codice = "CATEGORIA", tipo = TipoMetodo.TAG, titolo = "Categoria", descrizione = "Categoria del documento", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getCAtegoriaProtocollo(Protocollo protocollo) {
        return protocollo?.categoriaProtocollo?.descrizione ?: ""
    }

    @RegolaCalcolo(codice = "DATA_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Data di Protocollo", descrizione = "Data di Protocollo", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getDataProtocollo(Protocollo protocollo) {
        return protocollo?.data?.format("dd/MM/yyyy") ?: ""
    }

    @RegolaCalcolo(codice = "URL_DOCUMENTO_INTERNO", tipo = TipoMetodo.TAG, titolo = "Url del Documento dell'applicativo Protocollo", descrizione = "Url del Documento dell'applicativo Protocollo", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getUrlDocumento(Object documento) {
        if (documento.class == MessaggioRicevuto) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=APRI_MESSAGGIO_RICEVUTO&id=${documento.id}"
        } else if (documento.class == Fascicolo) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=APRI_FASCICOLO&id=${documento.id}"
        } else {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento=${documento.tipoProtocollo.categoria}&id=${documento.id}&_idEnte=${documento.ente.id}&idDoc=${documento.idDocumentoEsterno}"
        }
    }

    @RegolaCalcolo(codice = "URL_DOCUMENTO", tipo = TipoMetodo.TAG, titolo = "Url del Documento", descrizione = "Url a cui è possibile accedere il documento", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getUrlDocumentoProtocolloEsterno(Protocollo documento) {
        return Impostazioni.AG_SERVER_URL.valore + "/.." + ProtocolloEsterno.findByIdDocumentoEsterno(documento.idDocumentoEsterno)?.linkDocumento
    }

    @RegolaCalcolo(codice = "MOTIVO_RIFIUTO", tipo = TipoMetodo.TAG, titolo = "Motivo del Rifiuto della Richiesta di Annullamento", descrizione = "Motivo del Rifiuto della Richiesta di Annullamento", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    String getMotivoRifiutoRichiestaAnnullamento(Protocollo documento) {
        return ProtocolloAnnullamento.findByProtocollo(documento)?.motivoRifiuto ?: ""
    }

    @RegolaCalcolo(codice = "TESTO", tipo = TipoMetodo.ALLEGATO, titolo = "Il testo del documento", descrizione = "Il testo del documento.", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<Allegato> getTesto(Protocollo documento) {
        FileDocumento fd = documento.getFilePrincipale()
        if (fd == null && fd.idFileEsterno > 0) {
            return null
        }

        return [new Allegato(fd.nome, new ByteArrayInputStream(IOUtils.toByteArray(gestoreFile.getFile(documento, fd))))]
    }

    @RegolaCalcolo(codice = "TESTO_PDF", tipo = TipoMetodo.ALLEGATO, titolo = "Il testo del documento trasformato in PDF", descrizione = "Il testo del documento trasformato in PDF", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<Allegato> getTestoPdf(documento) {
        Allegato testo = getTesto(documento)
        if (testo == null) {
            return null
        }

        // se il testo è già pdf o p7m, lo ritorno così com'è
        if (testo.nome.toLowerCase().endsWith("p7m") || testo.nome.toLowerCase().endsWith("pdf")) {
            return testo
        }

        // converto il testo in pdf:
        testo.nome = testo.nome.replaceAll(/\..+$/, ".pdf")
        InputStream testoPdf = gestioneTestiService.converti(testo.testo, GestioneTestiService.FORMATO_PDF)
        testo.testo = new ByteArrayInputStream(IOUtils.toByteArray(testoPdf))

        return [testo]
    }

    @RegolaCalcolo(codice = "TUTTI", tipo = TipoMetodo.ALLEGATO, titolo = "Il testo dell'documento e tutti i files ad esso associati", descrizione = "Il testo dell'documento e tutti i files ad esso associati", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<Allegato> getTuttiFile(documento) {
        List<Allegato> allegatiMail = []

        try {
            log.debug("getTuttiFile: aggiungo il frontespizio")
            aggiungiAllegati(allegatiMail, FileDocumento.CODICE_FILE_FRONTESPIZIO, documento)

            log.debug("getTuttiFile: aggiungo il testo")
            allegatiMail.addAll(getTesto(documento))

            log.debug("getTuttiFile: cerco gli allegati del documento")

            log.debug("getTuttiFile: aggiungo i vari allegati")
            for (it.finmatica.gestionedocumenti.documenti.Allegato a : documento.getAllegati()) {
                a.fileDocumenti?.sort { it.id }
                for (FileDocumento f : a.fileDocumenti) {
                    if (f.codice != FileDocumento.CODICE_FILE_FRONTESPIZIO) {
                        InputStream inputStream = gestoreFile.getFile(a, f)
                        byte[] bytes = IOUtils.toByteArray(inputStream)
                        allegatiMail.add(new Allegato(f.nome, new ByteArrayInputStream(bytes)))
                    }
                }
            }

            log.debug("getTuttiFile: aggiungo la stampa unica")
            List<Allegato> su = getStampaUnica(documento)
            if (su != null) {
                allegatiMail.addAll(su)
            }
        } catch (Throwable e) {
            // in caso di eccezione non eliminare i file (per evenutale debug)
            throw e
        }

        return allegatiMail
    }

    @RegolaCalcolo(codice = "STAMPA_UNICA", tipo = TipoMetodo.ALLEGATO, titolo = "La stampa unica", descrizione = "La stampa unica", tipiDocumento = [Protocollo.TIPO_DOCUMENTO])
    List<Allegato> getStampaUnica(documento) {
        it.finmatica.gestionedocumenti.documenti.Allegato su = stampaUnicaService.getAllegatoStampaUnica(documento)
        FileDocumento fd = su.getFile(FileDocumento.CODICE_FILE_ALLEGATO)
        if (fd != null) {
            return [new Allegato(fd.nome, new ByteArrayInputStream(IOUtils.toByteArray(gestoreFile.getFile(documento, fd))))]
        } else {
            return []
        }
    }

    private void aggiungiAllegati(ArrayList<Allegato> files, String codice, Documento protocollo) {
        for (it.finmatica.gestionedocumenti.documenti.Allegato a : protocollo.getAllegati()) {
            for (FileDocumento f : a.fileDocumenti) {
                if (!StringUtils.isEmpty(codice) && codice == f.codice) {
                    InputStream inputStream = gestoreFile.getFile(a, f)
                    byte[] bytes = IOUtils.toByteArray(inputStream)
                    files.add(new Allegato(f.nome, new ByteArrayInputStream(bytes)))
                }
            }
        }
    }
}
