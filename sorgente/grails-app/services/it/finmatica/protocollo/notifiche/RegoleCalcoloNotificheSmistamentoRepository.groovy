package it.finmatica.protocollo.notifiche

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.notifiche.NotificaDestinatario
import it.finmatica.gestionedocumenti.notifiche.calcolo.NotificaSoggetto
import it.finmatica.gestionedocumenti.notifiche.calcolo.RegolaCalcoloNotifica.TipoMetodo
import it.finmatica.gestionedocumenti.notifiche.calcolo.TipoNotifica
import it.finmatica.gestionedocumenti.notifiche.calcolo.annotated.AnnotatedRegolaCalcolo
import it.finmatica.gestionedocumenti.notifiche.calcolo.annotated.RegolaCalcolo
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.jdmsutil.data.ProfiloExtend
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.Smistabile
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Component

import javax.sql.DataSource
import java.sql.SQLException

@Component
class RegoleCalcoloNotificheSmistamentoRepository implements AnnotatedRegolaCalcolo {

    public static final String NOTIFICA_DA_RICEVERE_CONOSCENZA = "SMISTAMENTO_DA_RICEVERE_CONOSCENZA"
    public static final String NOTIFICA_DA_RICEVERE_COMPETENZA = "SMISTAMENTO_DA_RICEVERE_COMPETENZA"
    public static final String NOTIFICA_IN_CARICO = "SMISTAMENTO_IN_CARICO"
    public static final String NOTIFICA_IN_CARICO_EMAIL = "SMISTAMENTO_IN_CARICO_EMAIL"
    public static final String NOTIFICA_IN_CARICO_ASSEGNAZIONE = "SMISTAMENTO_IN_CARICO_ASSEGNATO"
    public static final String NOTIFICA_IN_CARICO_ASSEGNAZIONE_EMAIL = "SMISTAMENTO_IN_CARICO_ASSEGNATO_EMAIL"
    public static final String NOTIFICA_RIFIUTO = "SMISTAMENTO_RIFIUTATO"

    public static final String NOTIFICA_IN_CARICO_NP = "SMISTAMENTO_IN_CARICO_DA_NON_PROTOCOLLARE"
    public static final String NOTIFICA_IN_CARICO_ASSEGNAZIONE_NP = "SMISTAMENTO_IN_CARICO_ASSEGNATO_DA_NON_PROTOCOLLARE"
    public static final String NOTIFICA_DA_RICEVERE_CONOSCENZA_NP = "SMISTAMENTO_DA_RICEVERE_CONOSCENZA_DA_NON_PROTOCOLLARE"
    public static final String NOTIFICA_DA_RICEVERE_COMPETENZA_NP = "SMISTAMENTO_DA_RICEVERE_COMPETENZA_DA_NON_PROTOCOLLARE"
    public static final String NOTIFICA_RIFIUTO_NP = "SMISTAMENTO_RIFIUTATO_DA_NON_PROTOCOLLARE"

    public static final String NOTIFICA_IN_CARICO_MEMO = "SMISTAMENTO_IN_CARICO_MEMO"
    public static final String NOTIFICA_IN_CARICO_ASSEGNAZIONE_MEMO = "SMISTAMENTO_IN_CARICO_ASSEGNATO_MEMO"
    public static final String NOTIFICA_DA_RICEVERE_CONOSCENZA_MEMO = "SMISTAMENTO_DA_RICEVERE_CONOSCENZA_MEMO"
    public static final String NOTIFICA_DA_RICEVERE_COMPETENZA_MEMO = "SMISTAMENTO_DA_RICEVERE_COMPETENZA_MEMO"

    public static final String NOTIFICA_IN_CARICO_FASCICOLO = "SMISTAMENTO_IN_CARICO_FASCICOLO"
    public static final String NOTIFICA_IN_CARICO_ASSEGNAZIONE_FASCICOLO = "SMISTAMENTO_IN_CARICO_ASSEGNATO_FASCICOLO"
    public static final String NOTIFICA_DA_RICEVERE_CONOSCENZA_FASCICOLO = "SMISTAMENTO_DA_RICEVERE_CONOSCENZA_FASCICOLO"
    public static final String NOTIFICA_DA_RICEVERE_COMPETENZA_FASCICOLO = "SMISTAMENTO_DA_RICEVERE_COMPETENZA_FASCICOLO"


    @Autowired
    RegoleCalcoloNotificheProtocolloRepository regoleCalcoloNotificheProtocolloRepository
    @Autowired
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DocumentaleService documentaleService

    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm

    @Override
    List<TipoNotifica> getListaTipiNotifica() {
        return [new TipoNotifica(codice: NOTIFICA_IN_CARICO, titolo: "Attività del protocollo in carico", descrizione: "Notifica che viene inviata quando un utente prende in carico uno smistamento per una unità", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_EMAIL, titolo: "Attività del protocollo in carico (e-mail)", descrizione: "Notifica E-mail che viene inviata quando un utente prende in carico uno smistamento per una unità", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_ASSEGNAZIONE, titolo: "Attività del protocollo assegnato", descrizione: "Notifica che viene inviata quando un utente prende in carico uno Smistamento assegnato.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_ASSEGNAZIONE_EMAIL, titolo: "Attività del protocollo assegnato (e-mail)", descrizione: "Notifica E-mail che viene inviata quando un utente prende in carico uno Smistamento assegnato.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_DA_RICEVERE_CONOSCENZA, titolo: "Attività del protocollo smistato per conoscenza", descrizione: "Notifica che viene inviata quando un utente riceve uno smistamento per conoscenza.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_DA_RICEVERE_COMPETENZA, titolo: "Attività del protocollo da prendere in carico", descrizione: "Notifica che viene inviata quando un utente riceve uno smistamento per competenza.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_RIFIUTO, titolo: "Smistamento Rifiutato", descrizione: "Notifica che viene inviata quando un utente rifiuta uno smistamento.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_NP, titolo: "Attività del documento da non protocollare in carico", descrizione: "Notifica che viene inviata quando un utente prende in carico uno smistamento di un documento da non protocollare per una unità", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_ASSEGNAZIONE_NP, titolo: "Attività del del documento da non protocollare assegnato", descrizione: "Notifica che viene inviata quando un utente prende in carico uno Smistamento di un documento da non protocollare assegnato.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_DA_RICEVERE_CONOSCENZA_NP, titolo: "Attività del del documento da non protocollare smistato per conoscenza", descrizione: "Notifica che viene inviata quando un utente riceve uno smistamento di un documento da non protocollare per conoscenza.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_DA_RICEVERE_COMPETENZA_NP, titolo: "Attività del del documento da non protocollare da prendere in carico", descrizione: "Notifica che viene inviata quando un utente riceve uno smistamento di un documento da non protocollare per competenza.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_RIFIUTO_NP, titolo: "Smistamento del documento da non protocollare Rifiutato", descrizione: "Notifica che viene inviata quando un utente rifiuta uno smistamento di un documento da non protocollare.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_FASCICOLO, titolo: "Attività del fascicolo in carico", descrizione: "Notifica che viene inviata quando un utente prende in carico uno smistamento di un fascicolo per una unità", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_IN_CARICO_ASSEGNAZIONE_FASCICOLO, titolo: "Attività del fascicolo assegnato", descrizione: "Notifica che viene inviata quando un utente prende in carico uno smistamento di un fascicolo assegnato.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_DA_RICEVERE_CONOSCENZA_FASCICOLO, titolo: "Attività del fascicolo smistato per conoscenza", descrizione: "Notifica che viene inviata quando un utente riceve uno smistamento di un fascicolo per conoscenza.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
                , new TipoNotifica(codice: NOTIFICA_DA_RICEVERE_COMPETENZA_FASCICOLO, titolo: "Attività del fascicolo da prendere in carico", descrizione: "Notifica che viene inviata quando un utente riceve uno smistamento di un fascicolo per competenza.", oggetti: [Smistamento.TIPO_DOCUMENTO, Smistabile.TIPO_DOCUMENTO])
        ]
    }

    @Override
    String getTipoDocumento(Object documento) {
        if (documento?.class == Smistamento) {
            return Smistamento.TIPO_DOCUMENTO
        }
        if (documento?.class == ProfiloExtend) {
            return Smistabile.TIPO_DOCUMENTO
        }
        if (documento?.class == Documento) {
            return Smistabile.TIPO_DOCUMENTO
        }
        return null
    }

    @Override
    String getIdRiferimento(Object documento) {
        if (documento?.class == Smistamento) {
            if (documento.idDocumentoEsterno != null) {
                return documento.idDocumentoEsterno
            }
        } else if (documento?.class == ProfiloExtend) {
            return "${documento.docNumber}"
        } else if (documento?.class == MessaggioRicevuto) {
            return documento.idDocumentoEsterno
        } else if (documento?.class == Documento) {
            return "${documento.id}"
        }
        return null
    }

    @Override
    Object getDocumento(String idRiferimento) {
        try {
            Smistamento s = null
            if (s == null) {
                Long idDocumentoEsterno = Long.parseLong(idRiferimento)
                s = Smistamento.findByIdDocumentoEsterno(idDocumentoEsterno)
            }

            if (s == null) {
                Documento documentoSmart = new Documento()
                documentoSmart.id = idRiferimento
                documentoSmart = documentaleService.getDocumento(documentoSmart, [Documento.COMPONENTI])
                if (documentoSmart == null) {
                    return null
                } else if (documentoSmart.trovaMappaChiaviExtra("CODICE") == ProtocolloGdmService.CODICE_MODELLO_SMISTAMENTO) {
                    return documentoSmart
                } else {
                    return null
                }
            } else {
                return s
            }
        }
        catch (NumberFormatException e) {
            return null
        }
        catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    /*
     * Regole di calcolo per i soggetti della notifica
     */

    @RegolaCalcolo(codice = "DESTINATARI_SMISTAMENTO", tipo = TipoMetodo.DESTINATARI, titolo = "Destinatari dello smistamento", descrizione = "L'unità di smistamento o l'utente assegnatario se presente.", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getDestinatariSmistamento(Smistamento smistamento, NotificaDestinatario notificaDestinatario) {
        if (smistamento.utenteAssegnatario != null) {
            return [new NotificaSoggetto(utente: smistamento.utenteAssegnatario.toDTO())]
        }
        return getComponentiUnitaConPrivilegioPerSmistamenti(smistamento, smistamento.unitaSmistamento)
    }

    /*
     * Regole di calcolo per i soggetti della notifica
     */

    @RegolaCalcolo(codice = "DESTINATARI_UNITA_TRASMISSIONE", tipo = TipoMetodo.DESTINATARI, titolo = "Destinatari dell'unità di trasmissione", descrizione = "Componenti dell'unità di trasmissione.", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getDestinatariUnitaTrasmissione(Smistamento smistamento, NotificaDestinatario notificaDestinatario) {
        return getComponentiUnitaConPrivilegioPerSmistamenti(smistamento, smistamento.unitaTrasmissione)
    }

    @RegolaCalcolo(codice = "UTENTI_UNITA_PROTOCOLLANTE", tipo = TipoMetodo.DESTINATARI, titolo = "Utenti dell'unità Protocollante per Smistamento", descrizione = "Unità Protocollante per Smistamento", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getDestinatarioUnitaProtocollante(Smistamento smistamento, NotificaDestinatario notificaDestinatario) {
        So4UnitaPubb uoProtocollante = smistamento.protocollo?.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4
        if (uoProtocollante != null) {
            return getComponentiUnita(uoProtocollante)
        }
        return []
    }

    List<NotificaSoggetto> getComponentiUnita(So4UnitaPubb uo) {
        List<So4ComponentePubb> componenti = strutturaOrganizzativaService.getComponentiInUnita(uo)
        So4UnitaPubbDTO unitaSmistamento = uo.toDTO()
        List<NotificaSoggetto> soggetti = []
        for (So4ComponentePubb componente : componenti) {
            soggetti << new NotificaSoggetto(unitaSo4: unitaSmistamento, utente: componente.soggetto.utenteAd4.toDTO(), soggetto: componente.soggetto.toDTO())
        }
        return soggetti
    }

    @RegolaCalcolo(codice = "GET_SOGGETTO_REDATTORE", tipo = TipoMetodo.DESTINATARI, titolo = "Il Redattore del documento", descrizione = "Il Redattore del documento.", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getSoggettoREDATTORE(Smistamento smistamento, NotificaDestinatario notificaDestinatario) {
        return regoleCalcoloNotificheProtocolloRepository.getSoggettoREDATTORE(smistamento.documento, notificaDestinatario)
    }

    @RegolaCalcolo(codice = "GET_SOGGETTO_FUNZIONARIO", tipo = TipoMetodo.DESTINATARI, titolo = "Il Funzionario del documento", descrizione = "Il Funzionario del documento.", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getSoggettoFUNZIONARIO(Smistamento smistamento, NotificaDestinatario notificaDestinatario) {
        return regoleCalcoloNotificheProtocolloRepository.getSoggettoFUNZIONARIO((Protocollo) smistamento.documento, notificaDestinatario)
    }

    @RegolaCalcolo(codice = "GET_SOGGETTO_DIRIGENTE", tipo = TipoMetodo.DESTINATARI, titolo = "Il Dirigente del documento", descrizione = "Il Dirigente Firmatario del documento.", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    List<NotificaSoggetto> getSoggettoDIRIGENTE(Smistamento smistamento, NotificaDestinatario notificaDestinatario) {
        return regoleCalcoloNotificheProtocolloRepository.getSoggettoDIRIGENTE((Protocollo) smistamento.documento, notificaDestinatario)
    }

    /**
     *
     * @param smistamento può essere nullo
     * @param uo
     * @param documentoRiservato
     * @return
     */
    List<NotificaSoggetto> getComponentiUnitaConPrivilegioPerSmistamenti(Smistamento smistamento, So4UnitaPubb uo, boolean documentoRiservato = false) {
        String privilegioVis = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        if (smistamento != null && protocolloService.isRiservato(smistamento.protocollo) || documentoRiservato) {
            privilegioVis = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        }
        String privilegioCarico = PrivilegioUtente.SMISTAMENTO_CARICO
        List<So4ComponentePubb> componenti = So4ComponentePubb.executeQuery("""
			select c
              from So4ComponentePubb c, PrivilegioUtente pu2,  PrivilegioUtente pu1
             where c.progrUnita = :uoProgr
               and :uoOttica = c.ottica.codice
               and c.dal <= :dataRif
               and (c.al is null or c.al >= :dataRif)
               and c.dal <= :dataRif
               and c.ottica.codice = :codiceOttica
               and pu1.codiceUnita = :uoCodice
               and pu2.codiceUnita = :uoCodice
               and pu1.privilegio = :privilegioCarico
               and pu2.privilegio = :privilegioVis
                and pu1.appartenenza = 'D'
                and pu2.appartenenza = 'D'
               and c.soggetto.utenteAd4 = pu1.utente
               and c.soggetto.utenteAd4 = pu2.utente
               and (pu1.al is null or pu1.al >= :dataRif)
                  and pu1.dal <= :dataRif
                     and (pu2.al is null or pu2.al >= :dataRif)
                     and pu2.dal <= :dataRif
			""", [dataRif: new Date(), codiceOttica: Impostazioni.OTTICA_SO4.valore, privilegioCarico: privilegioCarico, privilegioVis: privilegioVis, uoOttica: uo.ottica.codice, uoProgr: uo.progr, uoCodice: uo.codice])
        So4UnitaPubbDTO unitaSmistamento = uo.toDTO()

        if (componenti == null || componenti.size() == 0) {
            componenti = So4ComponentePubb.executeQuery("""
			select c
              from So4ComponentePubb c,  PrivilegioUtente pu1
             where c.progrUnita = :uoProgr
               and :uoOttica = c.ottica.codice
               and c.dal <= :dataRif
               and (c.al is null or c.al >= :dataRif)
               and c.dal <= :dataRif
               and c.ottica.codice = :codiceOttica
               and pu1.codiceUnita = :uoCodice
               and pu1.privilegio = :privilegioCarico
               and pu1.appartenenza = 'D'
               and c.soggetto.utenteAd4 = pu1.utente
            
               and (pu1.al is null or pu1.al >= :dataRif)
                  and pu1.dal <= :dataRif
			""", [dataRif: new Date(), codiceOttica: Impostazioni.OTTICA_SO4.valore, privilegioCarico: privilegioCarico, uoOttica: uo.ottica.codice, uoProgr: uo.progr, uoCodice: uo.codice])
        }
        List<NotificaSoggetto> soggetti = []
        for (So4ComponentePubb componente : componenti) {
            soggetti << new NotificaSoggetto(unitaSo4: unitaSmistamento, utente: componente.soggetto.utenteAd4.toDTO())
        }
        return soggetti
    }

    @RegolaCalcolo(codice = "ANNO_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Anno di Protocollo", descrizione = "Contiene l'anno di protocollo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getAnnoProtocollo(Smistamento smistamento) {
        return smistamento.protocollo?.anno?.toString() ?: ""
    }

    @RegolaCalcolo(codice = "NUMERO_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Numero di Protocollo", descrizione = "Contiene il numero di protocollo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getNumeroProtocollo(Smistamento smistamento) {
        return smistamento.protocollo?.numero?.toString() ?: ""
    }

    @RegolaCalcolo(codice = "NUMERO_7_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Numero di Protocollo lpad7", descrizione = "Contiene il numero di protocollo a 7 cifre (ad es: 0000123)", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getNumero7Protocollo(Smistamento smistamento) {
        return smistamento.protocollo?.numero?.toString()?.padLeft(7, '0').toString() ?: ""
    }

    @RegolaCalcolo(codice = "DATA_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Data di Protocollo", descrizione = "Data di Protocollo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getDataProtocollo(Smistamento smistamento) {
        return smistamento.protocollo.data?.format("dd/MM/yyyy") ?: ""
    }

    @RegolaCalcolo(codice = "CATEGORIA", tipo = TipoMetodo.TAG, titolo = "Categoria", descrizione = "Categoria del documento smistato", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getCAtegoriaProtocollo(Smistamento smistamento) {
        return smistamento.protocollo?.categoriaProtocollo?.descrizione ?: ""
    }

    @RegolaCalcolo(codice = "STATO_SMISTAMENTO", tipo = TipoMetodo.TAG, titolo = "Stato dello smistamento", descrizione = "Contiene lo stato dello smistamento, ad esempio 'Da Ricevere', 'Assegnato', 'In Carico', 'Rifiutato', 'Eseguito'", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getStatoSmistamento(Smistamento smistamento) {
        if (smistamento.statoSmistamento == Smistamento.DA_RICEVERE) {
            if (smistamento.utenteAssegnatario != null) {
                return "Assegnato"
            } else {
                return "Da Ricevere"
            }
        } else if (smistamento.statoSmistamento == Smistamento.STORICO && smistamento.utenteRifiuto != null) {
            return "Rifiutato"
        } else if (smistamento.statoSmistamento == Smistamento.IN_CARICO) {
            return "In Carico"
        } else if (smistamento.statoSmistamento == Smistamento.ESEGUITO) {
            return "Eseguito"
        } else {
            return ""
        }
    }

    @RegolaCalcolo(codice = "UNITA_PROTOCOLLANTE", tipo = TipoMetodo.TAG, titolo = "Unità Protocollante", descrizione = "Unità Protocollante", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getUnitaProtocollante(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getUnitaProtocollante(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "MOVIMENTO", tipo = TipoMetodo.TAG, titolo = "Movimento del protocollo (INTERNO / PARTENZA / ARRIVO)", descrizione = "Movimento del protocollo (INTERNO / PARTENZA / ARRIVO)", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getMovimento(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getMovimento(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "STATO_DOCUMENTO", tipo = TipoMetodo.TAG, titolo = "Stato del documento", descrizione = "Stato del documento", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getStato(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getStato(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "OGGETTO", tipo = TipoMetodo.TAG, titolo = "Oggetto del protocollo", descrizione = "Oggetto del protocollo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getOggetto(Smistamento smistamento) {
        if (smistamento.documento.class == MessaggioRicevuto.class) {
            return regoleCalcoloNotificheProtocolloRepository.getOggetto(MessaggioRicevuto.get(smistamento.documento.id))
        } else return regoleCalcoloNotificheProtocolloRepository.getOggetto(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "TIPO_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Tipologia del protocollo", descrizione = "Tipologia del protocollo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getTitoloTipologia(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getTitoloTipologia(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "DATA_REDAZIONE", tipo = TipoMetodo.TAG, titolo = "Data di Redazione", descrizione = "Data di Redazione", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getDataRedazione(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getDataRedazione(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "DATI_PROTOCOLLO", tipo = TipoMetodo.TAG, titolo = "Dati di protocollo", descrizione = "Dati di protocollazione NUMERO / ANNO / REGISTRO", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getDatiProtocollazione(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getDatiProtocollazione(Protocollo.get(smistamento.documento.id))
    }

    @RegolaCalcolo(codice = "URL_DOCUMENTO", tipo = TipoMetodo.TAG, titolo = "Url del Documento", descrizione = "Url a cui è possibile accedere il documento", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getUrlDocumento(Smistamento smistamento) {
        return regoleCalcoloNotificheProtocolloRepository.getUrlDocumento(smistamento.documento)
    }

    @RegolaCalcolo(codice = "CLASSIFICA_CODICE", tipo = TipoMetodo.TAG, titolo = "Codice classifica del fascicolo", descrizione = "Codice classifica del fascicolo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getClassificaCodice(Smistamento smistamento) {
        if(smistamento.documento.class == Fascicolo) {
            return smistamento.documento.classificazione?.codice
        }
        return ""

    }

    @RegolaCalcolo(codice = "OGGETTO_FASCICOLO", tipo = TipoMetodo.TAG, titolo = "Oggetto del fascicolo", descrizione = "Oggetto del fascicolo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getOggettoFascicolo(Smistamento smistamento) {
        if(smistamento.documento.class == Fascicolo) {
            return it.finmatica.protocollo.utils.StringUtils.cleanTextContent(new String(smistamento.documento.oggetto))
        }
        return ""
    }

    @RegolaCalcolo(codice = "ANNO_FASCICOLO", tipo = TipoMetodo.TAG, titolo = "Anno del fascicolo", descrizione = "Anno del fascicolo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getAnnoFascicolo(Smistamento smistamento) {
        return smistamento.documento.anno?.toString() ?: ""
    }

    @RegolaCalcolo(codice = "NUMERO_FASCICOLO", tipo = TipoMetodo.TAG, titolo = "Numero del fascicolo", descrizione = "Numero del fascicolo", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getNnumeroFascicolo(Smistamento smistamento) {
        return smistamento.documento.numero ?: ""
    }
    @RegolaCalcolo(codice = "NUMERO_7_FASCICOLO", tipo = TipoMetodo.TAG, titolo = "Numero del fascicolo lpad7", descrizione = "Numero del fascicolo lpad7", tipiDocumento = [Smistamento.TIPO_DOCUMENTO])
    String getNnumero7Fascicolo(Smistamento smistamento) {
        return smistamento.documento.numero?.padLeft(7, '0').toString() ?: ""
    }
}
