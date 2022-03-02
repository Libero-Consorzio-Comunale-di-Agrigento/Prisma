package it.finmatica.protocollo.notifiche

import com.sun.star.auth.InvalidArgumentException
import commons.menu.MenuItemProtocollo
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.atti.integrazioniws.ads.jworkflow.MetadatoUtente
import it.finmatica.gestionedocumenti.integrazioni.gdm.IntegrazioneGdmService
import it.finmatica.gestionedocumenti.notifiche.Notifica
import it.finmatica.gestionedocumenti.notifiche.calcolo.NotificaSoggetto
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.BottoneNotificaJWorklist
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.DettaglioNotificaJWorklist
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.JWorklistNotificheDispatcher
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.NotificaJWorklist
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.NotificaJWorklistBuilder
import it.finmatica.jdmsutil.data.ProfiloExtend
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.Smistabile
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.viste.BottoneNotifica
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.gdm.converters.StatoSmistamentoGdmConverter
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.segreteria.common.ParametriSegreteria
import it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.cxf.common.util.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.transaction.annotation.Transactional

import javax.servlet.ServletContext
import javax.sql.DataSource
import java.sql.Connection
import java.sql.SQLException
import java.text.DateFormat
import java.text.SimpleDateFormat

/**
 * Created by esasdelli on 12/04/2017.
 */
@Slf4j
class ProtocolloNotificaJWorklistBuilder implements NotificaJWorklistBuilder {

    public static final String PRIORITA_ALTA = "PA"
    public static final String PRIORITA_NORMALE = "PN"
    public static final String UTENTE_SENZA_COMPETENZE_LETTURA = "L'UTENTE NON HA COMPETENZA DI LETTURA"
    public static final String OGGETTO_RISERVATO = "RISERVATO"

    @Autowired
    IntegrazioneGdmService integrazioneGdmService

    @Autowired
    ProtocolloGdmService protocolloGdmService

    @Autowired
    ProtocolloService protocolloService

    @Autowired
    SpringSecurityService springSecurityService

    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm

    @Autowired
    RegoleCalcoloNotificheProtocolloRepository regoleCalcoloNotificheProtocolloRepository

    @Autowired
    RegoleCalcoloNotificheSmistamentoRepository regoleCalcoloNotificheSmistamentoRepository

    @Autowired
    ServletContext servletContext

    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze

    @Transactional
    NotificaJWorklist creaNotificaJWorklist(Notifica notifica, Object documento, NotificaSoggetto soggetto, String testo, String oggetto, String messaggioTODO) {

        Protocollo protocollo = null
        if (documento instanceof Protocollo) {
            protocollo = documento
        } else if (documento instanceof Smistamento) {
            protocollo = Protocollo.get(documento.documento.id)
        }
        if (protocollo != null) {
            if (soggetto.utente != null) {
                if (!gestoreCompetenze.utenteCorrenteVedeRiservato(protocollo, soggetto.utente.id)) {
                    if (protocolloService.isRiservato(protocollo)) {
                        notifica.oggetto = regoleCalcoloNotificheProtocolloRepository.getDatiProtocollazione(protocollo) + ": " + OGGETTO_RISERVATO
                    } else {
                        notifica.oggetto = regoleCalcoloNotificheProtocolloRepository.getDatiProtocollazione(protocollo) + ": " + UTENTE_SENZA_COMPETENZE_LETTURA
                    }
                    testo = notifica.testo
                    oggetto = notifica.oggetto
                }
            }
        }
        return creaNotifica(notifica, documento, soggetto, testo, oggetto, messaggioTODO)
    }

    @Transactional
    List<NotificaJWorklist> creaNotificaJWorklist(Notifica notifica, Object documento, List<NotificaSoggetto> soggetti, String testo, String oggetto, String messaggioTODO) {

        List<NotificaJWorklist> notificaJWorklists = new ArrayList<NotificaJWorklist>()
        log.info("Creazione notifica di tipo: " + notifica.tipoNotifica + " sul documento di tipo " + documento.class.canonicalName)
        Object doc = null
        if (documento instanceof Protocollo) {
            doc = documento
        } else if (documento.class == MessaggioRicevuto) {
            doc = MessaggioRicevuto.get(documento.documento.id)
        } else if (documento.class == Smistamento) {
            if (documento.documento.class == Protocollo) {
                doc = Protocollo.get(documento.documento.id)
            } else if (documento.documento.class == MessaggioRicevuto) {
                doc = MessaggioRicevuto.get(documento.documento.id)
            }
        }

        if (doc != null) {
            List<NotificaSoggetto> soggettiNonVedonoRiservati = new ArrayList<NotificaSoggetto>()
            for (NotificaSoggetto soggetto : soggetti) {
                if (soggetto.utente != null) {
                    if (!gestoreCompetenze.utenteCorrenteVedeRiservato(doc, soggetto.utente.id)) {
                        soggettiNonVedonoRiservati.add(soggetto)
                    }
                }
            }
            if (soggettiNonVedonoRiservati.size() > 0) {
                String oggettoRiservato = oggetto
                if (protocolloService.isRiservato(doc)) {
                    oggettoRiservato = regoleCalcoloNotificheProtocolloRepository.getDatiProtocollazione(doc) + ": " + OGGETTO_RISERVATO
                } else {
                    oggettoRiservato = regoleCalcoloNotificheProtocolloRepository.getDatiProtocollazione(doc) + ": " + UTENTE_SENZA_COMPETENZE_LETTURA
                }
                notificaJWorklists.add(creaNotifica(notifica, documento, soggettiNonVedonoRiservati, oggettoRiservato, oggettoRiservato, messaggioTODO, true))
                soggetti.removeAll(soggettiNonVedonoRiservati)
            }
        }

        if (soggetti?.size() > 0) {
            notificaJWorklists.add(creaNotifica(notifica, documento, soggetti, testo, oggetto, messaggioTODO))
        }
        return notificaJWorklists
    }

    NotificaJWorklist creaNotifica(Notifica notifica, Smistamento smistamento, NotificaSoggetto soggetto, String testo, String oggetto, String messaggioTODO) {
        try {
            log.info("Notifica di Smistamento")

            Object protocollo = getDocumento(smistamento)
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)

            it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil pu = new it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil(pg)
            String serverUrl = "../"
            String urlEsecuzione = regoleCalcoloNotificheSmistamentoRepository.getUrlDocumento(smistamento)

            String tipologia = "ATTIVA_ITER_DOCUMENTALE"
            if (notifica.tipoNotificaScrivania != null) {
                tipologia = notifica.tipoNotificaScrivania
            }

            //FIXME Verificare se andare sempre sul nuovo ...
            String urlRiferimento = getUrlRiferimentoSmartDesktop(smistamento)//getUrlRiferimento(smistamento, pu)
            NotificaJWorklist notificaJWorklist = new NotificaJWorklist(idRiferimento: regoleCalcoloNotificheSmistamentoRepository.getIdRiferimento(smistamento)
                    , testo: oggetto // sarebbe il campo attivita_help
                    , tooltip: oggetto // sarebbe il campo tooltip_attivita_descrizione
                    , urlEsecuzione: urlEsecuzione
                    , tooltipUrlEsecuzione: "Apri il documento"
                    , utenteEsterno: new MetadatoUtente(utenteAD4: soggetto.utente.id)
                    , notificaSoggettoList: new ArrayList<NotificaSoggetto>().add(soggetto)
                    , tipologia: tipologia
                    , datiApplicativi1: getNumeroProtocollo(protocollo)
                    , datiApplicativi2: getDataProtocollo(protocollo)
                    , priorita: PRIORITA_NORMALE
                    , messaggioToDo: messaggioTODO
                    , urlRiferimento: urlRiferimento
                    , tooltipUrlRiferimento: getTooltipUrlRiferimento(smistamento)
                    , paramInitIter: "SMISTAMENTO a ${smistamento.unitaSmistamento.descrizione}"
                    , dataScadenza: getDataScadenza(smistamento, pg)
                    , stato: getStato(smistamento))

            if (!StringUtils.isEmpty(messaggioTODO)) {
                notificaJWorklist.espressione = JWorklistNotificheDispatcher.ATTIVITA_TODO
            }
            return notificaJWorklist
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    NotificaJWorklist creaNotifica(Notifica notifica, ProfiloExtend profiloExtend, NotificaSoggetto soggetto, String testo, String oggetto, String messaggioTODO) {
        try {
            log.info("Notifica di Smistamento (GDM)")

            Smistabile smistabile = Smistabile.findByIdrif(profiloExtend.getCampo("IDRIF"))

            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)

            it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil pu = new it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil(pg)
            String urlEsecuzione = protocolloGdmService.getLinkDocumento(new Long(smistabile.idDocumentoEsterno))


            String tipologia = "ATTIVA_ITER_DOCUMENTALE"
            if (notifica.tipoNotificaScrivania != null) {
                tipologia = notifica.tipoNotificaScrivania
            }

            String urlRiferimento = getUrlRiferimento(profiloExtend)

            NotificaJWorklist notificaJWorklist = new NotificaJWorklist(idRiferimento: regoleCalcoloNotificheSmistamentoRepository.getIdRiferimento(profiloExtend)
                    , testo: oggetto // sarebbe il campo attivita_help
                    , tooltip: oggetto // sarebbe il campo tooltip_attivita_descrizione
                    , urlEsecuzione: urlEsecuzione
                    , tooltipUrlEsecuzione: "Apri il documento"
                    , utenteEsterno: new MetadatoUtente(utenteAD4: soggetto.utente.id)
                    , notificaSoggettoList: new ArrayList<NotificaSoggetto>().add(soggetto)
                    , tipologia: tipologia
                    , datiApplicativi1: smistabile.numero
                    , datiApplicativi2: smistabile.data
                    , priorita: PRIORITA_NORMALE
                    , messaggioToDo: messaggioTODO
                    , urlRiferimento: urlRiferimento
                    , tooltipUrlRiferimento: getTooltipUrlRiferimento(profiloExtend)
                    , paramInitIter: "SMISTAMENTO a ${profiloExtend.getCampo("DES_UFFICIO_SMISTAMENTO")}"
                    , dataScadenza: getDataScadenza(StatoSmistamentoGdmConverter.newInstance().convert(profiloExtend.getCampo("STATO_SMISTAMENTO")), pg)
                    , stato: profiloExtend.getCampo("STATO_SMISTAMENTO"))

            if (!StringUtils.isEmpty(messaggioTODO)) {
                notificaJWorklist.espressione = JWorklistNotificheDispatcher.ATTIVITA_TODO
            }
            return notificaJWorklist
        } catch (SQLException e) {
            new ProtocolloRuntimeException(e)
        }
    }

    NotificaJWorklist creaNotifica(Notifica notifica, Smistamento smistamento, List<NotificaSoggetto> soggetti, String testo, String oggetto, String messaggioTODO, boolean nascondiDettagli = false) {
        log.info("Notifica di Smistamento")

        try {
            Object documento = getDocumento(smistamento)
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)
            List<MetadatoUtente> utentiEsterni = new ArrayList<MetadatoUtente>()
            for (NotificaSoggetto soggetto : soggetti) {
                if (soggetto.utente != null) {
                    utentiEsterni.add(new MetadatoUtente(utenteAD4: soggetto.utente.id))
                }
            }
            String stato = getStato(smistamento)
            String tipologiaFiltro = getTipologiaFiltro(smistamento)

            String tipologia = "ATTIVA_ITER_DOCUMENTALE"
            if (notifica.tipoNotificaScrivania != null) {
                tipologia = notifica.tipoNotificaScrivania
            }

            it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil pu = new it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil(pg)
            String serverUrl = "../"
            String urlEsecuzione = regoleCalcoloNotificheSmistamentoRepository.getUrlDocumento(smistamento)

            //FIXME verificare se andare sempre sul nuovo
            String urlRiferimento = getUrlRiferimentoSmartDesktop(smistamento)//getUrlRiferimento(smistamento, pu)
            String idRiferimento = regoleCalcoloNotificheSmistamentoRepository.getIdRiferimento(smistamento)
            String idRiferimentoDocumento = regoleCalcoloNotificheProtocolloRepository.getIdRiferimento(documento)

            ArrayList<BottoneNotificaJWorklist> bottoneList = calcolaBottoni(tipologia, smistamento.tipoSmistamento, smistamento.unitaSmistamento.codice, stato, idRiferimento, idRiferimentoDocumento)
            String descCorrispondente = ""
            if (documento.class == Protocollo) {
                descCorrispondente = calcolaCorrispondenteJWorklist(documento.corrispondenti)
            }

            Date d = null
            if (smistamento.statoSmistamento == Smistamento.DA_RICEVERE) {
                d = smistamento.dataSmistamento
            } else {
                d = smistamento.dataAssegnazione

                if (d == null) {
                    d = smistamento.dataPresaInCarico
                }
            }

            DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
            String data = ""
            if (d) {
                data = format.format(d)// 28/02/2018 17:34:57
            }

            ArrayList<DettaglioNotificaJWorklist> dettagliList = new ArrayList<DettaglioNotificaJWorklist>()
            if (!nascondiDettagli) {
                dettagliList = calcolaDettagli(smistamento.utenteAssegnatario, smistamento.unitaTrasmissione.descrizione, smistamento.unitaSmistamento.descrizione, smistamento.statoSmistamento, data, urlRiferimento, descCorrispondente, smistamento.tipoSmistamento, (smistamento.note ? "SI" : "NO"))
            }

            String urlAllegatiDinamici = null
            // TODO: Gestire i messaggi ricevuti (SERVLET) -> PRENDERE IL PRIMO FILEDOCUMENTO E RISALIRE AL PADRE (ATTACCATO DIRETTAMENT) -> documento.categoriaProtocollo.tipoDocumentoJWorklist ? REPOSITORY???
            if (!nascondiDettagli && documento.class == Protocollo) {
                urlAllegatiDinamici = "../agspr/WorklistAllegatiServlet?idDocumento=" + documento.idDocumentoEsterno + "&utente=" + "P_UTENTE" + "&fileProp=" + ImpostazioniProtocollo.FILE_GDM_INI.valore + "&tipoDoc=" + documento.categoriaProtocollo.tipoDocumentoJWorklist
            }

            NotificaJWorklist notificaJWorklist = new NotificaJWorklist(idRiferimento: regoleCalcoloNotificheSmistamentoRepository.getIdRiferimento(smistamento)
                    , testo: oggetto // sarebbe il campo attivita_help
                    , tooltip: oggetto // sarebbe il campo tooltip_attivita_descrizione
                    , urlEsecuzione: urlEsecuzione
                    , tooltipUrlEsecuzione: "Apri il documento"
                    , utenteEsternoList: utentiEsterni
                    , notificaSoggettoList: soggetti
                    , tipologia: tipologia
                    , tipologiaDescrizione: tipologiaFiltro
                    , datiApplicativi1: getNumeroProtocollo(documento)
                    , datiApplicativi2: getDataProtocollo(documento)
                    , priorita: PRIORITA_NORMALE
                    , messaggioToDo: messaggioTODO
                    , urlRiferimento: urlRiferimento
                    , tooltipUrlRiferimento: getTooltipUrlRiferimento(smistamento)
                    , paramInitIter: "SMISTAMENTO a ${smistamento.unitaSmistamento.descrizione}"
                    , dataScadenza: getDataScadenza(smistamento.statoSmistamento, pg)
                    , stato: stato
                    , bottoniNotificaJWorklistList: bottoneList
                    , dettagliNotificaJWorklistList: dettagliList
                    , allegatiNotificaJWorklistList: null
                    , ordinamentoStringaLabel: "Ordinamento smistamenti"
                    , ordinamentoStringaValore: getNumeroProtocollo(documento)
                    , ordinamentoDataLabel: "Data smistamento"
                    , ordinamentoDataValore: smistamento.getDataSmistamento()
                    , urlAllegatiDinamici: urlAllegatiDinamici
            )

            if (!StringUtils.isEmpty(messaggioTODO)) {
                notificaJWorklist.espressione = JWorklistNotificheDispatcher.ATTIVITA_TODO
            }
            return notificaJWorklist
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    NotificaJWorklist creaNotifica(Notifica notifica, ProfiloExtend profiloExtend, List<NotificaSoggetto> soggetti, String testo, String oggetto, String messaggioTODO) {
        try {
            log.info("Notifica di Smistamento GDM")

            Smistabile smistabile = Smistabile.findByIdrif(profiloExtend.getCampo("IDRIF"))
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)

            List<MetadatoUtente> utentiEsterni = new ArrayList<MetadatoUtente>()
            for (NotificaSoggetto soggetto : soggetti) {
                if (soggetto.utente != null) {
                    utentiEsterni.add(new MetadatoUtente(utenteAD4: soggetto.utente.id))
                }
            }

            String tipologiaFiltro = getTipologiaFiltro(profiloExtend)
            String tipologia = "ATTIVA_ITER_DOCUMENTALE"
            if (notifica.tipoNotificaScrivania != null) {
                tipologia = notifica.tipoNotificaScrivania
            }

            String statoSmistamento = StatoSmistamentoGdmConverter.newInstance().convert(profiloExtend.getCampo("STATO_SMISTAMENTO"))
            String rw = "W"
            if (statoSmistamento == Smistamento.DA_RICEVERE) {
                rw = "R"
            }

            String urlEsecuzione = protocolloGdmService.getLinkDocumento(new Long(smistabile.idDocumentoEsterno), rw)
            it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil pu = new it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil(pg)
            String urlRiferimento = getUrlRiferimento(profiloExtend)

            ArrayList<BottoneNotificaJWorklist> bottoneList = calcolaBottoni(tipologia, profiloExtend.getCampo("TIPO_SMISTAMENTO"), profiloExtend.getCampo("UFFICIO_SMISTAMENTO"), profiloExtend.getCampo("STATO_SMISTAMENTO"), profiloExtend.getDocNumber(), smistabile.idDocumentoEsterno.toString())
            String descCorrispondente = calcolaCorrispondenteJWorklist(smistabile.getIdDocumentoEsterno().toString())

            String data = ""
            if (statoSmistamento == Smistamento.DA_RICEVERE) {
                data = profiloExtend.getCampo("SMISTAMENTO_DAL")
            } else {
                data = profiloExtend.getCampo("ASSEGNAZIONE_DAL")

                if (data != null && data != "") {
                    data = profiloExtend.getCampo("PRESA_IN_CARICO_DAL")
                }
            }

            String presenzaNote = "SI"
            String noteSmistamento = profiloExtend.getCampo("NOTE")
            if (noteSmistamento == null || noteSmistamento.equals("")) {
                presenzaNote = "NO"
            }

            ArrayList<DettaglioNotificaJWorklist> dettagliList = calcolaDettagli(Ad4Utente.get(profiloExtend.getCampo("CODICE_ASSEGNATARIO")), profiloExtend.getCampo("DES_UFFICIO_TRASMISSIONE"), profiloExtend.getCampo("DES_UFFICIO_SMISTAMENTO"), statoSmistamento, data, urlRiferimento, descCorrispondente, profiloExtend.getCampo("TIPO_SMISTAMENTO"), presenzaNote)
            Date date = null
            if (profiloExtend.getCampo("SMISTAMENTO_DAL") != null && profiloExtend.getCampo("SMISTAMENTO_DAL") != "") {
                DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
                date = format.parse(profiloExtend.getCampo("SMISTAMENTO_DAL")) // 28/02/2018 17:34:57
            }

            String urlAllegatiDinamici = "../agspr/WorklistAllegatiServlet?idDocumento=" + smistabile.idDocumentoEsterno + "&utente=" + "RPI" + "&fileProp=" + ImpostazioniProtocollo.FILE_GDM_INI.valore + "&tipoDoc=" + smistabile.categoriaProtocollo.tipoDocumentoJWorklist
            NotificaJWorklist notificaJWorklist = new NotificaJWorklist(
                    idRiferimento: regoleCalcoloNotificheSmistamentoRepository.getIdRiferimento(profiloExtend)
                    , testo: oggetto // sarebbe il campo attivita_help
                    , tooltip: oggetto // sarebbe il campo tooltip_attivita_descrizione
                    , urlEsecuzione: urlEsecuzione
                    , tooltipUrlEsecuzione: "Apri il documento"
                    , utenteEsternoList: utentiEsterni
                    , notificaSoggettoList: soggetti
                    , tipologia: tipologia
                    , tipologiaDescrizione: tipologiaFiltro
                    , datiApplicativi1: smistabile.numero
                    , datiApplicativi2: smistabile.data
                    , priorita: PRIORITA_NORMALE
                    , messaggioToDo: messaggioTODO
                    , urlRiferimento: urlRiferimento
                    , tooltipUrlRiferimento: getTooltipUrlRiferimento(profiloExtend)
                    , paramInitIter: "SMISTAMENTO a ${profiloExtend.getCampo("DES_UFFICIO_SMISTAMENTO")}"
                    , dataScadenza: getDataScadenza(statoSmistamento, pg)
                    , stato: profiloExtend.getCampo("STATO_SMISTAMENTO")
                    , bottoniNotificaJWorklistList: bottoneList
                    , dettagliNotificaJWorklistList: dettagliList
                    , allegatiNotificaJWorklistList: null//allegatiList
                    , ordinamentoStringaLabel: "Ordinamento smistamenti"
                    , ordinamentoStringaValore: smistabile.numero
                    , ordinamentoDataLabel: "Data smistamento"
                    , ordinamentoDataValore: date
                    , urlAllegatiDinamici: urlAllegatiDinamici
            )

            if (!StringUtils.isEmpty(messaggioTODO)) {
                notificaJWorklist.espressione = JWorklistNotificheDispatcher.ATTIVITA_TODO
            }

            return notificaJWorklist
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    NotificaJWorklist creaNotifica(Notifica notifica, it.finmatica.smartdoc.api.struct.Documento documento, NotificaSoggetto soggetto, String testo, String oggetto, String messaggioTODO) {
        Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
        ProfiloExtend smistamentoGdm = new ProfiloExtend(String.valueOf(documento.id), springSecurityService.principal.id, null, connGdm, false)
        return creaNotifica(notifica, smistamentoGdm, soggetto, testo, oggetto, messaggioTODO)
    }

    NotificaJWorklist creaNotifica(Notifica notifica, it.finmatica.smartdoc.api.struct.Documento documento, List<NotificaSoggetto> soggetti, String testo, String oggetto, String messaggioTODO) {
        log.info("Notifica di Smistamento SMARTDOC -GDM")
        Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
        ProfiloExtend profiloExtend = new ProfiloExtend(String.valueOf(documento.id), springSecurityService.principal.id, null, connGdm, false)
        return creaNotifica(notifica, profiloExtend, soggetti, testo, oggetto, messaggioTODO)
    }

    private ArrayList<BottoneNotificaJWorklist> calcolaBottoni(Protocollo protocollo, String tipologia) {
        String serverUrl = ".."
        String urlAzione = ""

        List<BottoneNotificaJWorklist> bottoni = new ArrayList<BottoneNotificaJWorklist>()
        List<BottoneNotifica> bottoniDaAggiungere = BottoneNotifica.createCriteria().list {
            eq("tipo", tipologia)
            or {
                eq("stato", protocollo.statoFirma?.toString())
                eq("stato", "*")
            }
            order("sequenza", "asc")
        }

        for (BottoneNotifica bottone : bottoniDaAggiungere) {
            BottoneNotificaJWorklist b = new BottoneNotificaJWorklist()
            b.setEtichetta(bottone.label)
            b.setTooltip(bottone.tooltip)
            b.setIcona(bottone.icona)
            b.setTipologia(bottone.tipoAzione)
            b.setMultiplo(bottone.azioneMultipla)

            if (bottone.tipoAzione.equals("FORM")) {
                if (bottone.urlAzione != null && bottone.urlAzione.indexOf("..") != -1) {
                    urlAzione = bottone.urlAzione.replaceFirst("..", serverUrl)
                } else {
                    urlAzione = bottone.urlAzione
                }
            } else {
                urlAzione = "TODO"
            }

            b.setUrlAzione(urlAzione) //urlazione
            b.setIdentificativoRiferimento(protocollo?.getIdDocumentoEsterno().toString() ?: (new Date()).toString())

            bottoni.add(b)
        }
        bottoni
    }

    private ArrayList<BottoneNotificaJWorklist> calcolaBottoni(String tipologia, String tipoSmistamento, String codiceUnitaSmistamento, String statoGdm, String idRiferimento, String idSmistabile) {
        List<BottoneNotificaJWorklist> bottoni = new ArrayList<BottoneNotificaJWorklist>()
        List<BottoneNotifica> bottoniDaAggiungere = BottoneNotifica.createCriteria().list {
            like("tipoSmistamento", "%#" + tipoSmistamento + "%")
            eq("tipo", tipologia)
            eq("stato", statoGdm)
            order("sequenza", "asc")
        }
        String codiceUnita = codiceUnitaSmistamento
        String serverUrl = "../"
        String urlAzione

        for (BottoneNotifica bottone : bottoniDaAggiungere) {
            BottoneNotificaJWorklist b = new BottoneNotificaJWorklist()
            String codiceAdsQuery = "SEGRETERIA.PROTOCOLLO#DOCUMENTI_" + bottone.modello
            int idQuery = integrazioneGdmService.getIdQueryByCodiceAds(codiceAdsQuery)
            if (bottone.tipoAzione.equals("FORM")) {

                String parametroUnita = "&PAR_AGSPR_UNITA=" + codiceUnita
                // CARICO, ESEGUI, CARICO ESEGUI: nuova gestione per l'esecuzione automatica multi unita' (non deve esserci il parametro nella url per permettere di multiselezionare smistamenti su più unita')
                if (bottone.azione == "operazione=" + MenuItemProtocollo.CARICO_ESEGUI ||
                        bottone.azione == "operazione=" + MenuItemProtocollo.ESEGUI ||
                        bottone.azione == "operazione=" + MenuItemProtocollo.CARICO) {
                    parametroUnita = ""
                }

                urlAzione = bottone.urlAzione + bottone.azione + parametroUnita + "&LISTA_ID=XXXX"

                b.setEtichetta(bottone.label)
                b.setTooltip(bottone.tooltip)
                b.setIcona(bottone.icona)
                b.setTipologia(bottone.tipoAzione)
                b.setMultiplo(bottone.azioneMultipla)
                b.setUrlAzione(urlAzione)
                b.setIdentificativoRiferimento(idRiferimento)
                // parametri utili per ricerche etc...
                b.setParametri("&PAR_AGSPR_UNITA=" + codiceUnita + "&PAR_AGSPR_TIPO_RICERCA=M_" + bottone.getModello())

            } else {
                urlAzione = serverUrl
                urlAzione += ImpostazioniProtocollo.AG_CONTEXT_PATH_AGSPR.valore
                urlAzione += "/WorklistActionServlet?XMLAZIONE=<IN><AZIONE>"
                urlAzione += bottone.azione
                urlAzione += "</AZIONE><PROPERTIES>"
                urlAzione += ImpostazioniProtocollo.FILE_GDM_INI.valore
                urlAzione += "</PROPERTIES><UTENTE>"
                urlAzione += ":UTENTE_ESTERNO"
                urlAzione += "</UTENTE><NOMINATIVO>"
                urlAzione += ":NOMINATIVO_ESTERNO"
                urlAzione += "</NOMINATIVO><PARAMETRI>"
                urlAzione += "<PARAMETRO NOME=\"IDQUERYPROVENIENZA\">"
                urlAzione += String.valueOf(idQuery)
                urlAzione += "</PARAMETRO></PARAMETRI><XXXX></XXXX></IN>"
                b.setEtichetta(bottone.label)
                b.setTooltip(bottone.tooltip)
                b.setIcona(bottone.icona)
                b.setTipologia(bottone.tipoAzione)
                b.setMultiplo(bottone.azioneMultipla)
                b.setUrlAzione(urlAzione)
                b.setIdentificativoRiferimento("D#" + idSmistabile)
                b.setParametri("PAR_AGSPR_UNITA=" + codiceUnita + "&PAR_AGSPR_TIPO_RICERCA=M_" + bottone.getModello())
            }
            bottoni.add(b)
        }
        bottoni
    }

    private ArrayList<DettaglioNotificaJWorklist> calcolaDettagli(Ad4Utente utenteAssegnatario, String descrizioneUnitaTrasmissione, String descrizioneUnitaRicevente, String stato, String dataSmistamento, String urlRiferimento, String corrispondente, String tipoSmistamento, String presenzaNote) {
        List<DettaglioNotificaJWorklist> dettagli = new ArrayList<DettaglioNotificaJWorklist>()

        DettaglioNotificaJWorklist d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = "Documenti "

        if (stato == Smistamento.DA_RICEVERE) {
            d.nomeDettaglio += "da ricevere"
        }

        if (stato == Smistamento.IN_CARICO) {
            if (utenteAssegnatario != null) {
                d.nomeDettaglio += "assegnati"
            } else {
                d.nomeDettaglio += "in carico"
            }
        }

        d.valoreDettaglio = urlRiferimento
        d.url = 1
        dettagli.add(d)
        d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = "Tipo smistamento"
        d.valoreDettaglio = tipoSmistamento
        dettagli.add(d)
        d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = "Data Stato"
        d.valoreDettaglio = dataSmistamento
        dettagli.add(d)
        d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = "Unità trasmissione"
        d.valoreDettaglio = descrizioneUnitaTrasmissione
        dettagli.add(d)
        d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = "Unità ricevente"
        d.valoreDettaglio = descrizioneUnitaRicevente
        dettagli.add(d)
        d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = "Note smistamento"
        d.valoreDettaglio = presenzaNote
        dettagli.add(d)

        DettaglioNotificaJWorklist dCorrispondente = new DettaglioNotificaJWorklist()
        dCorrispondente.nomeDettaglio = "Corrispondente"
        dCorrispondente.valoreDettaglio = corrispondente
        dettagli.add(dCorrispondente)

        return dettagli
    }

    private String calcolaCorrispondenteJWorklist(Set<Corrispondente> corrispondenti) {
        Long idMassimo = Long.MAX_VALUE
        Long idMinimo = idMassimo
        for (Corrispondente corrispondente : corrispondenti) {
            if (!corrispondente.conoscenza && corrispondente.id < idMassimo) {
                idMinimo = corrispondente.id
            }
        }
        if (idMinimo < idMassimo) {
            Corrispondente primoCorrispondente = Corrispondente.get(idMinimo)
            return primoCorrispondente.denominazione?.trim()
        }
        return ""
    }

    private String calcolaCorrispondenteJWorklist(String idProtocollo) {
        return integrazioneGdmService.getDenominazioneCorr(idProtocollo)
    }

    private ArrayList<DettaglioNotificaJWorklist> calcolaDettagli(String messaggioTODO, String urlEsecuzione, String urlRiferimento, String corrispondente) {
        List<DettaglioNotificaJWorklist> dettagli = new ArrayList<DettaglioNotificaJWorklist>()

        if (urlRiferimento != null) {
            DettaglioNotificaJWorklist d = creaDettaglio("Riferimento", urlRiferimento, 1)
            dettagli.add(d)
        }

        DettaglioNotificaJWorklist dCorrispondente = new DettaglioNotificaJWorklist()
        dCorrispondente.nomeDettaglio = "Corrispondente"
        dCorrispondente.valoreDettaglio = corrispondente
        dettagli.add(dCorrispondente)

        return dettagli
    }

    private DettaglioNotificaJWorklist creaDettaglio(String descrizione, String valore, int seUrl) {
        DettaglioNotificaJWorklist d = new DettaglioNotificaJWorklist()
        d.nomeDettaglio = descrizione
        d.valoreDettaglio = valore
        d.url = seUrl

        return d
    }

    NotificaJWorklist creaNotifica(Notifica notifica, Protocollo protocollo, NotificaSoggetto soggetto, String testo, String oggetto, String messaggioTODO) {
        log.info("Notifica di Protocollo")

        String tipologia = protocollo.tipoProtocollo.categoria
        if (notifica.tipoNotificaScrivania != null) {
            tipologia = notifica.tipoNotificaScrivania
        }

        String serverUrl = "../"
        String urlEsecuzione = regoleCalcoloNotificheProtocolloRepository.getUrlDocumento(protocollo)

        String urlRiferimento = getUrlRiferimento(protocollo)

        NotificaJWorklist notificaJworklist = new NotificaJWorklist(
                idRiferimento: regoleCalcoloNotificheProtocolloRepository.getIdRiferimento(protocollo)
                , testo: oggetto // sarebbe il campo attivita_help
                , tooltip: testo // sarebbe il campo tooltip_attivita_descrizione
                , urlEsecuzione: urlEsecuzione
                , tooltipUrlEsecuzione: "Apri il documento"
                , nomeIter: protocollo.iter?.cfgIter?.nome
                , descrizioneIter: protocollo.iter?.cfgIter?.descrizione
                , utenteEsterno: new MetadatoUtente(utenteAD4: soggetto.utente.id)
                , notificaSoggettoList: new ArrayList<NotificaSoggetto>().add(soggetto)
                , tipologia: tipologia
                , datiApplicativi1: getNumeroProtocollo(protocollo)
                , datiApplicativi2: getDataProtocollo(protocollo)
                , priorita: PRIORITA_NORMALE
                , tooltipUrlRiferimento: getTooltipUrlRiferimento(protocollo)
                , messaggioToDo: messaggioTODO
                , urlRiferimento: urlRiferimento)

        if (!StringUtils.isEmpty(messaggioTODO)) {
            notificaJworklist.espressione = JWorklistNotificheDispatcher.ATTIVITA_TODO
        }

        return notificaJworklist
    }

    @Transactional
    NotificaJWorklist creaNotifica(Notifica notifica, Protocollo protocollo, List<NotificaSoggetto> soggetti, String testo, String oggetto, String messaggioTODO, boolean nascondereDettagli = false) {
        try {
            log.info("Notifica di Protocollo")

            String tipologia = protocollo.tipoProtocollo?.categoria

            if (notifica.tipoNotificaScrivania != null) {
                tipologia = notifica.tipoNotificaScrivania
            }

            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)
            List<MetadatoUtente> utentiEsterni = new ArrayList<MetadatoUtente>()

            for (NotificaSoggetto soggetto : soggetti) {
                if (soggetto.utente != null) {
                    utentiEsterni.add(new MetadatoUtente(utenteAD4: soggetto.utente.id))
                }
            }

            String serverUrl = "../"
            String urlEsecuzione = regoleCalcoloNotificheProtocolloRepository.getUrlDocumento(protocollo)
            String urlRiferimento = getUrlRiferimento(protocollo)
            //http://svi-ora03:9080/agspr/WorklistAllegatiServlet?idDo
            String tipoDoc = protocollo.categoriaProtocollo.tipoDocumentoJWorklist
            String urlAllegatiDinamici = null
            if (!nascondereDettagli) {
                urlAllegatiDinamici = "../agspr/WorklistAllegatiServlet?idDocumento=" + protocollo.idDocumentoEsterno + "&utente=P_UTENTE&fileProp=" + ImpostazioniProtocollo.FILE_GDM_INI.valore + "&tipoDoc=" + tipoDoc
            }

            it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil pu = new it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil(pg)
            ArrayList<BottoneNotificaJWorklist> bottoneList = calcolaBottoni(protocollo, tipologia)
            String corrispondente = calcolaCorrispondenteJWorklist(protocollo.corrispondenti)
            ArrayList<DettaglioNotificaJWorklist> dettagliList = new ArrayList<DettaglioNotificaJWorklist>()

            if (!nascondereDettagli) {
                dettagliList = calcolaDettagli(messaggioTODO, urlEsecuzione, urlRiferimento, corrispondente)
            }

            NotificaJWorklist notificaJworklist = new NotificaJWorklist(
                    idRiferimento: regoleCalcoloNotificheProtocolloRepository.getIdRiferimento(protocollo)
                    , testo: oggetto // sarebbe il campo attivita_help
                    , tooltip: testo // sarebbe il campo tooltip_attivita_descrizione
                    , urlEsecuzione: urlEsecuzione
                    , tooltipUrlEsecuzione: "Apri il documento"
                    , nomeIter: protocollo.iter?.cfgIter?.nome
                    , descrizioneIter: protocollo.iter?.cfgIter?.descrizione
                    , utenteEsternoList: utentiEsterni
                    , notificaSoggettoList: soggetti
                    , tipologia: tipologia
                    , datiApplicativi1: getNumeroProtocollo(protocollo)
                    , datiApplicativi2: getDataProtocollo(protocollo)
                    , priorita: PRIORITA_NORMALE
                    , tooltipUrlRiferimento: getTooltipUrlRiferimento(protocollo)
                    , messaggioToDo: messaggioTODO
                    , urlRiferimento: urlRiferimento
                    , bottoniNotificaJWorklistList: bottoneList
                    , allegatiNotificaJWorklistList: null
                    , dettagliNotificaJWorklistList: dettagliList
                    , ordinamentoStringaLabel: "Ordina"
                    , ordinamentoStringaValore: getNumeroProtocollo(protocollo)
                    , urlAllegatiDinamici: urlAllegatiDinamici)

            if (!StringUtils.isEmpty(messaggioTODO)) {
                notificaJworklist.espressione = JWorklistNotificheDispatcher.ATTIVITA_TODO
            }

            return notificaJworklist
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    Date getDataScadenza(String statoSmistamento, ParametriSegreteria pg) {
        if (statoSmistamento == Smistamento.DA_RICEVERE) {
            try {
                return new Date() + Integer.parseInt(pg.getSMIST_R_TIMEOUT())
            } catch (NumberFormatException e) {
                return new Date() + 90
            }
        }

        if (statoSmistamento == Smistamento.IN_CARICO) {
            try {
                return new Date() + Integer.parseInt(pg.getSMIST_C_TIMEOUT())
            } catch (NumberFormatException e) {
                return new Date() + 90
            }
        }

        return null
    }

    String getStato(Smistamento smistamento) {
        if (smistamento.statoSmistamento == Smistamento.DA_RICEVERE) {
            return "R"
        }

        if (smistamento.statoSmistamento == Smistamento.IN_CARICO && smistamento.utenteAssegnatario == null) {
            return "C"
        }

        if (smistamento.statoSmistamento == Smistamento.IN_CARICO && smistamento.utenteAssegnatario != null) {
            return "A"
        }

        return ""
    }

    String getTipologiaFiltro(Smistamento smistamento) {
        if (smistamento.statoSmistamento == Smistamento.STORICO && smistamento.utenteRifiuto != null) {
            return "Smistamento rifiutato"
        }

        return getTipologiaFiltro(smistamento.statoSmistamento, smistamento.tipoSmistamento, smistamento.utenteAssegnatario)
    }

    String getTipologiaFiltro(ProfiloExtend smistamento) {
        String statoSmistamento = StatoSmistamentoGdmConverter.newInstance().convert(smistamento.getCampo("STATO_SMISTAMENTO"))
        String tipoSmistamento = smistamento.getCampo("TIPO_SMISTAMENTO")
        Ad4Utente utenteAssegnatario = Ad4Utente.get(smistamento.getCampo("CODICE_ASSEGNATARIO"))

        return getTipologiaFiltro(statoSmistamento, tipoSmistamento, utenteAssegnatario)
    }

    String getTipologiaFiltro(String statoSmistamento, String tipoSmistamento, Ad4Utente utenteAssegnatario) {
        String s = ""
        if (statoSmistamento == Smistamento.DA_RICEVERE) {
            if (tipoSmistamento == "CONOSCENZA") {
                s = "Presa visione"
            } else {
                s = "Prendi in carico"
            }
            if (utenteAssegnatario != null) {
                s += " - ASS"
            }
            return s
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario == null) {
            return "In carico"
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario != null) {
            return "Assegnato"
        }

        return s
    }

    String getTooltipUrlRiferimento(Smistamento smistamento) {
        return getTooltipUrlRiferimentoSmistamento(smistamento.statoSmistamento, smistamento.unitaSmistamento, smistamento.utenteAssegnatario)
    }

    private String getTooltipUrlRiferimentoSmistamento(String statoSmistamento, So4UnitaPubb unitaSmistamento, Ad4Utente utenteAssegnatario) {
        if (statoSmistamento == Smistamento.DA_RICEVERE) {
            return "Visualizza elenco documenti da ricevere per ${unitaSmistamento.descrizione}"
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario == null) {
            return "Visualizza elenco documenti in carico per ${unitaSmistamento.descrizione}"
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario != null) {
            return "Visualizza elenco documenti assegnati a ${utenteAssegnatario.nominativoSoggetto} ${unitaSmistamento.descrizione}"
        }

        return ""
    }

    String getTooltipUrlRiferimento(ProfiloExtend smistamento) {
        String statoSmistamento = StatoSmistamentoGdmConverter.newInstance().convert(smistamento.getCampo("STATO_SMISTAMENTO"))
        So4UnitaPubb unitaSmistamento = So4UnitaPubb.findByCodiceAndAlIsNull(smistamento.getCampo("UFFICIO_SMISTAMENTO"))
        Ad4Utente utenteAssegnatario = Ad4Utente.get(smistamento.getCampo("CODICE_ASSEGNATARIO"))

        return getTooltipUrlRiferimentoSmistamento(statoSmistamento, unitaSmistamento, utenteAssegnatario)
    }

    @Deprecated
    String getUrlRiferimento(Smistamento smistamento, ProtocolloUtil pu) {
        String serverUrl = "../"

        String urlRiferimento

        if (smistamento.statoSmistamento == Smistamento.DA_RICEVERE) {
            urlRiferimento = pu.getUrlDaRicevere(smistamento.unitaSmistamento.codice)
            if (!urlRiferimento.toUpperCase().startsWith(serverUrl.toUpperCase())
                    && urlRiferimento.startsWith("../")) {
                urlRiferimento = urlRiferimento.replaceFirst("../", serverUrl)
            }
            return urlRiferimento
        }

        if (smistamento.statoSmistamento == Smistamento.IN_CARICO && smistamento.utenteAssegnatario == null) {
            urlRiferimento = pu.getUrlInCarico(smistamento.unitaSmistamento.codice)
            if (!urlRiferimento.toUpperCase().startsWith(serverUrl.toUpperCase())
                    && urlRiferimento.startsWith("../")) {
                urlRiferimento = urlRiferimento.replaceFirst("../", serverUrl)
            }
            return urlRiferimento
        }

        if (smistamento.statoSmistamento == Smistamento.IN_CARICO && smistamento.utenteAssegnatario != null) {
            urlRiferimento = pu.getUrlAssegnati(smistamento.unitaSmistamento.codice)
            if (!urlRiferimento.toUpperCase().startsWith(serverUrl.toUpperCase())
                    && urlRiferimento.startsWith("../")) {
                urlRiferimento = urlRiferimento.replaceFirst("../", serverUrl)
            }
            return urlRiferimento
        }

        return ""
    }

    String getUrlRiferimentoSmartDesktop(Smistamento smistamento) {
        String serverUrl = "../"

        String urlRiferimento

        String prefixTipoDoc = smistamento.documento?.class == Fascicolo.class? "F_" : "P_"

        if (smistamento.statoSmistamento == Smistamento.DA_RICEVERE) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione="+prefixTipoDoc+"DA_RICEVERE&PAR_AGSPR_UNITA="+smistamento.unitaSmistamento.codice
        }

        if (smistamento.statoSmistamento == Smistamento.IN_CARICO && smistamento.utenteAssegnatario == null) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione="+prefixTipoDoc+"IN_CARICO&PAR_AGSPR_UNITA="+smistamento.unitaSmistamento.codice
        }

        if (smistamento.statoSmistamento == Smistamento.IN_CARICO && smistamento.utenteAssegnatario != null) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione="+prefixTipoDoc+"ASSEGNATI&PAR_AGSPR_UNITA="+smistamento.unitaSmistamento.codice
        }

        return ""
    }

    String getUrlRiferimento(ProfiloExtend smistamento) {
        String serverUrl = "../"

        String urlRiferimento

        String statoSmistamento = StatoSmistamentoGdmConverter.newInstance().convert(smistamento.getCampo("STATO_SMISTAMENTO"))
        Ad4Utente utenteAssegnatario = Ad4Utente.get(smistamento.getCampo("CODICE_ASSEGNATARIO"))

        if (statoSmistamento == Smistamento.DA_RICEVERE) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=P_DA_RICEVERE&PAR_AGSPR_UNITA="+smistamento.getCampo("UFFICIO_SMISTAMENTO")
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario == null) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=P_IN_CARICO&PAR_AGSPR_UNITA="+smistamento.getCampo("UFFICIO_SMISTAMENTO")
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario != null) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=P_ASSEGNATI&PAR_AGSPR_UNITA="+smistamento.getCampo("UFFICIO_SMISTAMENTO")
        }

        return ""
    }

    @Deprecated
    String getUrlRiferimento(ProfiloExtend smistamento, ProtocolloUtil pu) {
        String serverUrl = "../"

        String urlRiferimento

        String statoSmistamento = StatoSmistamentoGdmConverter.newInstance().convert(smistamento.getCampo("STATO_SMISTAMENTO"))
        Ad4Utente utenteAssegnatario = Ad4Utente.get(smistamento.getCampo("CODICE_ASSEGNATARIO"))

        if (statoSmistamento == Smistamento.DA_RICEVERE) {
            urlRiferimento = pu.getUrlDaRicevere(smistamento.getCampo("UFFICIO_SMISTAMENTO"))
            if (!urlRiferimento.toUpperCase().startsWith(serverUrl.toUpperCase())
                    && urlRiferimento.startsWith("../")) {
                urlRiferimento = urlRiferimento.replaceFirst("../", serverUrl)
            }
            return urlRiferimento
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario == null) {
            urlRiferimento = pu.getUrlInCarico(smistamento.getCampo("UFFICIO_SMISTAMENTO"))
            if (!urlRiferimento.toUpperCase().startsWith(serverUrl.toUpperCase())
                    && urlRiferimento.startsWith("../")) {
                urlRiferimento = urlRiferimento.replaceFirst("../", serverUrl)
            }
            return urlRiferimento
        }

        if (statoSmistamento == Smistamento.IN_CARICO && utenteAssegnatario != null) {
            urlRiferimento = pu.getUrlAssegnati(smistamento.getCampo("UFFICIO_SMISTAMENTO"))
            if (!urlRiferimento.toUpperCase().startsWith(serverUrl.toUpperCase())
                    && urlRiferimento.startsWith("../")) {
                urlRiferimento = urlRiferimento.replaceFirst("../", serverUrl)
            }
            return urlRiferimento
        }

        return ""
    }

    String getTooltipUrlRiferimento(Protocollo protocollo) {
        if (isNodoFirma(protocollo)) {
            return "Apri documenti da firmare"
        }

        return null
    }

    String getUrlRiferimento(Protocollo protocollo) {
        // se il protocollo in questione è in un nodo con un pulsante di firma, allora devo aprire la maschera dei file da firmare:
        if (isNodoFirma(protocollo)) {
            return ".." + servletContext.getContextPath() + "/standalone.zul?operazione=DA_FIRMARE"
        }

        return null
    }

    boolean isNodoFirma(Protocollo protocollo) {
        return (protocollo.iter?.stepCorrente?.cfgStep?.cfgPulsanti?.pulsante?.azioni?.flatten()?.find {
            it.nomeMetodo == "finalizzaTransazioneFirma"
        } != null)
    }

    private Object getDocumento(Object documento) {
        if (documento.class == Protocollo || documento.class == MessaggioRicevuto) {
            return documento
        } else if (documento.class == Smistamento) {
            if (documento.documento.class == Protocollo) {
                return Protocollo.get(documento.documento.id)
            } else if (documento.documento.class == MessaggioRicevuto) {
                return MessaggioRicevuto.get(documento.documento.id)
            } else if (documento.documento.class == Fascicolo) {
                return Fascicolo.get(documento.documento.id)
            }
        } else {
            throw new InvalidArgumentException("Documento non gestito: ${documento}")
        }
    }

    String getNumeroProtocollo(Object protocollo) {
        if (protocollo.class == Protocollo) {
            return protocollo.numero > 0 ? "${protocollo.anno}/${protocollo.numero.toString().padLeft(7, '0')}" : ""
        }
        return ""
    }

    String getDataProtocollo(Object protocollo) {
        if (protocollo.class == Protocollo) {
            return protocollo.data?.format("dd/MM/yyyy HH:mm:ss") ?: ""
        }
        return ""
    }
}

