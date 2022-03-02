package it.finmatica.protocollo.integrazioni.gdm

import commons.PopupSceltaSmistamentiViewModel.DatiSmistamento
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.gdm.converters.BooleanConverter
import it.finmatica.gestionedocumenti.integrazioni.gdm.converters.StatoFirmaConverter
import it.finmatica.gestionedocumenti.notifiche.Notifica
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.notifiche.calcolo.NotificaSoggetto
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.JWorklistNotificheDispatcher
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.jdmsutil.data.ProfiloExtend
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.Indirizzo
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.RegistroGiornaliero
import it.finmatica.protocollo.documenti.Smistabile
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamento
import it.finmatica.protocollo.documenti.annullamento.StatoAnnullamento
import it.finmatica.protocollo.documenti.emergenza.ProtocolloDatiEmergenza
import it.finmatica.protocollo.documenti.scarto.ProtocolloDatiScarto
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.converters.LetteraMovimentoConverter
import it.finmatica.protocollo.integrazioni.gdm.converters.MovimentoConverter
import it.finmatica.protocollo.integrazioni.gdm.converters.StatoArchivioConverter
import it.finmatica.protocollo.integrazioni.gdm.converters.StatoSmistamentoConverter
import it.finmatica.protocollo.integrazioni.gdm.converters.StepFlussoConverter
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheSmistamentoRepository
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.segreteria.common.ParametriSegreteria
import it.finmatica.segreteria.common.struttura.Classificazione
import it.finmatica.segreteria.common.struttura.Titolario
import it.finmatica.segreteria.jprotocollo.struttura.FactoryDocumenti
import it.finmatica.segreteria.jprotocollo.struttura.IProfiloSmistabile
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Campo
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.smartdoc.api.struct.Riferimento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.cxf.common.util.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.beans.factory.annotation.Value
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.Connection
import java.text.SimpleDateFormat

@Slf4j
@Transactional
@Service
class ProtocolloGdmService {

    public static final String CODICE_MODELLO_SMISTAMENTO = "M_SMISTAMENTO"
    public static final String CODICE_MODELLO_CORRISPONDENTE = "M_SOGGETTO"
    public static final String CODICE_MODELLO_MEMO = "MEMO_PROTOCOLLO"
    public static final String CODICE_CAMPO_IDRIF = "IDRIF"
    public static final String CANCELLATO = "CA"

    public static final String ESISTONO_FILE_NON_UNIVOCI_PROTOCOLLO = "Y"

    @Autowired
    RegoleCalcoloNotificheSmistamentoRepository regoleCalcoloNotificheSmistamentoRepository
    @Autowired
    JWorklistNotificheDispatcher jWorklistNotificheDispatcher
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    NotificheService notificheService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    @Qualifier("dataSource_gdm")
    DataSource dataSource_gdm
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DateService dateService

    @Value("\${finmatica.protocollo.gdm.area}")
    private String areaSegreteria

    /**
     * Salva i dati passati dal dto attraverso la classe ProfiloExtend
     *
     */
    it.finmatica.smartdoc.api.struct.Documento salvaProtocollo(Protocollo protocollo, boolean escludiControlloCompetenze = false, boolean escludiFascicolazione = false) {
        try {

            if (protocollo.isValido()) {
                protocollo.save()
            }

            it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()
            boolean aggiornamento = false
            if (escludiControlloCompetenze) {
                documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
            }
            if (protocollo.idDocumentoEsterno > 0) {
                aggiornamento = true
                documentoSmart.setId(String.valueOf(protocollo.idDocumentoEsterno))
                if (escludiControlloCompetenze) {
                    documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
                }
                documentoSmart = documentaleService.getDocumento(documentoSmart, new ArrayList<Documento.COMPONENTI>())
                documentoSmart.addChiaveExtra("STATO_DOCUMENTO", "BO")
            } else {
                if (protocollo.idrif == null) {
                    protocollo.idrif = calcolaIdrif()
                }
                // caso di utilizzo con smartdoc.properties ->
                // documentoSmart.setTipo(protocollo.categoriaProtocollo.codice)
                // caso di utilizzo con mappaChiaviExtra (sfrutta la configurazione delle categorie)
                documentoSmart.addChiaveExtra("MODELLO", protocollo.categoriaProtocollo.codiceModelloGdm)
                documentoSmart.addChiaveExtra("AREA", protocollo.categoriaProtocollo.codiceAreaGdm)

                documentoSmart.addCampo(new Campo(CODICE_CAMPO_IDRIF, protocollo.idrif))

                // questo campo viene settato a "-1" per consentire al Protocollo GDM di "riconoscere" i documenti creati da AGSPR
                // in modo tale da non creare le notifiche (che vengono già gestite da AGSPR)
                if (protocollo.categoriaProtocollo.codice != CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice) {
                    documentoSmart.addCampo(new Campo(protocollo.categoriaProtocollo.codiceCampoKeyIter, '-1'))
                }
            }

            if (aggiornamento && !protocollo.valido) {
                documentaleService.eliminaDocumento(documentoSmart)
                return documentoSmart
            }

            documentoSmart.addCampo(new Campo("RISERVATO", BooleanConverter.Y_N.INSTANCE.convert(protocollo.riservato)))
            documentoSmart.addCampo(new Campo("OGGETTO", protocollo.oggetto ?: ""))

            if (protocollo.dataVerifica != null) {
                documentoSmart.addCampo(new Campo("DATA_VERIFICA", getDateSql(protocollo.dataVerifica)))
            }

            if (protocollo.dataComunicazione != null) {
                documentoSmart.addCampo(new Campo("DATA_ARRIVO", getDateSql(protocollo.dataComunicazione)))
            }

            if (protocollo.codiceRaccomandata != null) {
                documentoSmart.addCampo(new Campo("RACCOMANDATA_NUMERO", protocollo.codiceRaccomandata))
            }

            if (protocollo.dataDocumentoEsterno != null) {
                documentoSmart.addCampo(new Campo("DATA_DOCUMENTO", getDateSql(protocollo.dataDocumentoEsterno)))
            }

            if (protocollo.numeroDocumentoEsterno != null) {
                documentoSmart.addCampo(new Campo("NUMERO_DOCUMENTO", protocollo.numeroDocumentoEsterno))
            }

            if (protocollo.dataStatoArchivio != null) {
                documentoSmart.addCampo(new Campo("DATA_STATO", getDateSql(protocollo.dataStatoArchivio)))
            }

            if (protocollo.statoArchivio != null) {
                documentoSmart.addCampo(new Campo("TIPO_STATO", new StatoArchivioConverter().convert(protocollo.statoArchivio.name())))
            }

            if (protocollo.modalitaInvioRicezione != null) {
                documentoSmart.addCampo(new Campo("DOCUMENTO_TRAMITE", protocollo.modalitaInvioRicezione.codice))
            }

            documentoSmart.addCampo(new Campo("NOTE", protocollo.note ?: ""))

            documentoSmart.addCampo(new Campo("CODICE_AMMINISTRAZIONE", protocollo.ente?.amministrazione?.codice))
            documentoSmart.addCampo(new Campo("CODICE_AOO", protocollo.ente?.aoo))
            if (protocollo.movimento != null) {
                documentoSmart.addCampo(new Campo("MODALITA", MovimentoConverter.INSTANCE.convert(protocollo.movimento)))
            }

            // imposto i soggetti:
            Ad4Utente utenteDirigente = protocollo.getSoggetto(TipoSoggetto.FIRMATARIO)?.utenteAd4
            Ad4Utente utenteRedattore = protocollo.getSoggetto(TipoSoggetto.REDATTORE)?.utenteAd4
            As4SoggettoCorrente dirigente = utenteDirigente ? As4SoggettoCorrente.findByUtenteAd4(utenteDirigente) : null
            As4SoggettoCorrente redattore = utenteRedattore ? As4SoggettoCorrente.findByUtenteAd4(utenteRedattore) : null

            // FIXME: spostare questo riferimento a CATEGORIA in CategoriaProtocollo?
            if (protocollo.tipoProtocollo.categoria == Protocollo.CATEGORIA_LETTERA) {
                documentoSmart.addCampo(new Campo("CHECK_FUNZIONARIO", BooleanConverter.Y_N.INSTANCE.convert(protocollo.controlloFunzionario)))
                documentoSmart.addCampo(new Campo("SO4_DIRIGENTE", utenteDirigente?.id ?: ""))
                documentoSmart.addCampo(new Campo("DIRIGENTE_NOME_COGNOME", dirigente?.denominazione ?: ""))
                documentoSmart.addCampo(new Campo("COGNOME", redattore?.cognome ?: ""))
                documentoSmart.addCampo(new Campo("NOME", redattore?.nome ?: ""))
                documentoSmart.addCampo(new Campo("TIPO_LETTERA", LetteraMovimentoConverter.INSTANCE.convert(protocollo.movimento)))
                documentoSmart.addCampo(new Campo("OGGI", getDateSql(dateService.getCurrentDate())))
                if (!StringUtils.isEmpty(protocollo.iter?.stepCorrente?.cfgStep?.nome)) {
                    documentoSmart.addCampo(new Campo("POSIZIONE_FLUSSO", StepFlussoConverter.INSTANCE.convert(protocollo.iter.stepCorrente.cfgStep.nome, protocollo.movimento)))
                }
            }
            documentoSmart.addCampo(new Campo("UTENTE_PROTOCOLLANTE", utenteRedattore?.id ?: ""))
            documentoSmart.addCampo(new Campo("UNITA_PROTOCOLLANTE", protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4?.codice ?: ""))

            // #31344 per le pec non si devono salvare i dati dell'unità esibente
            if (!protocollo.categoriaProtocollo.pec && CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice != protocollo.categoriaProtocollo.codice) {
                documentoSmart.addCampo(new Campo("UNITA_ESIBENTE", protocollo.getSoggetto(TipoSoggetto.UO_ESIBENTE)?.unitaSo4?.codice ?: ""))
            }

            // #44598 questo generava lock su AGSPR<->GDM perché scattava il trigger AGSPR_PRIN_DATI_INTEROP_TIU che riportava sempre su
            // protocollo.datiInteroperabilita di AGSPR lo stesso flag da me settato qui. In realtà con il nuovo metodo , il flag lo settiamo noi
            // con il vecchio ci pensa il trigger a riportarlo in AGSPR
            /*if (protocollo.categoriaProtocollo.pec && protocollo.datiInteroperabilita != null) {
                documentoSmart.addCampo(new Campo("INVIATA_CONF_RIC", protocollo.datiInteroperabilita.inviataConferma?"Y":"N" ))
            }*/

            if (protocollo.getSoggetto(TipoSoggetto.FUNZIONARIO) != null) {
                documentoSmart.addCampo(new Campo("SO4_FUNZIONARIO", protocollo.getSoggetto(TipoSoggetto.FUNZIONARIO)?.utenteAd4?.id ?: ""))
            }

            if (protocollo.datiInteroperabilita?.motivoInterventoOperatore != null) {
                documentoSmart.addCampo(new Campo("MOTIVO_RICH_INTERVENTO", protocollo.datiInteroperabilita.motivoInterventoOperatore))
            }

            if (protocollo.categoriaProtocollo.codice != CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice) {
                String stato = documentoSmart.trovaCampo(new Campo("STATO_PR"))?.valore
                if (stato != "PR" && stato != "DN" && stato != "AN") {
                    if (protocollo.numero > 0) {
                        documentoSmart.addCampo(new Campo("ANNO", protocollo.anno ?: ""))
                        documentoSmart.addCampo(new Campo("NUMERO", protocollo.numero ?: ""))
                        documentoSmart.addCampo(new Campo("DATA", getDateSql(protocollo.data)))
                        documentoSmart.addCampo(new Campo("TIPO_REGISTRO", protocollo.tipoRegistro?.codice ?: ""))
                        documentoSmart.addCampo(new Campo("STATO_PR", "PR"))
                    } else {
                        documentoSmart.addCampo(new Campo("STATO_PR", "DP"))
                    }
                } else if (protocollo.numero == null) {
                    //se è protocollato su gdm ma non ho salvato il numero su agspr, lo recupero e lo salvo
                    protocollo.anno = documentoSmart.trovaCampo(new Campo("ANNO"))?.valore.toInteger()
                    protocollo.numero = documentoSmart.trovaCampo(new Campo("NUMERO"))?.valore.toInteger()
                    if (protocollo.tipoRegistro == null) {
                        protocollo.tipoRegistro = TipoRegistro.findByCodice(documentoSmart.trovaCampo(new Campo("TIPO_REGISTRO"))?.valore)
                    }
                    protocollo.data = new SimpleDateFormat("dd'/'MM'/'yyyy HH:mm:ss").parse(documentoSmart.trovaCampo(new Campo("DATA"))?.valore)
                    return
                }

                documentoSmart.addCampo(new Campo("VERIFICA_FIRMA", protocollo.esitoVerifica ?: ""))
                documentoSmart.addCampo(new Campo("STATO_FIRMA", StatoFirmaConverter.INSTANCE.convert(protocollo.statoFirma) ?: ""))
                documentoSmart.addCampo(new Campo("MASTER", "Y"))

                if (protocollo.tipoProtocollo.categoria != Protocollo.CATEGORIA_PROVVEDIMENTO) {
                    documentoSmart.addCampo(new Campo("DESCRIZIONE_TIPO_DOCUMENTO", protocollo.schemaProtocollo?.descrizione ?: ""))
                }
            } else {
                //Caso in cui è un doc da fascicolare inserisco anche la data di redazione
                documentoSmart.addCampo(new Campo("DATA", getDateSql(protocollo.dataRedazione)))
            }

            if (protocollo.tipoProtocollo.categoria != Protocollo.CATEGORIA_PROVVEDIMENTO) {
                documentoSmart.addCampo(new Campo("TIPO_DOCUMENTO", protocollo.schemaProtocollo?.codice ?: ""))
            }

// 		    documentoSmart.addCampo((statoConservazione, output)    //TODO con l'attività relativa
            ProtocolloAnnullamento pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.RIFIUTATO)
            if (protocollo.stato == null && pa != null) {
                documentoSmart.addCampo(new Campo("STATO_PR", "PR"))
                documentoSmart.addCampo(new Campo("ACCETTAZIONE_ANNULLAMENTO", "N"))
            } else if (protocollo.stato == StatoDocumento.RICHIESTO_ANNULLAMENTO) {
                pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.RICHIESTO)
                documentoSmart.addCampo(new Campo("STATO_PR", "DN"))
                documentoSmart.addCampo(new Campo("MOTIVO_ANN", pa.motivo))
                documentoSmart.addCampo(new Campo("UTENTE_RICHIESTA_ANN", springSecurityService.principal.id))
                documentoSmart.addCampo(new Campo("UNITA_RICHIESTA_ANN", pa.unita.codice))
                documentoSmart.addCampo(new Campo("DATA_RICHIESTA_ANN", getDateSql(dateService.getCurrentDate())))
                documentoSmart.addCampo(new Campo("NOMINATIVO_UTENTE_RICH_ANN", springSecurityService.principal.cognomeNome))
                documentoSmart.addCampo(new Campo("ACCETTAZIONE_ANNULLAMENTO", "X"))
            } else if (protocollo.stato == StatoDocumento.DA_ANNULLARE) {
                pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.ACCETTATO)
                documentoSmart.addCampo(new Campo("ACCETTAZIONE_ANNULLAMENTO", "Y"))
                documentoSmart.addCampo(new Campo("DATA_ACCETTAZIONE_ANN", getDateSql(pa.dataAccettazioneRifiuto)))
            } else if (protocollo.annullato) {
                pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.ANNULLATO)
                if (pa == null) {
                    pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.ACCETTATO)
                }
                if (pa) {
                    documentoSmart.addCampo(new Campo("UTENTE_ANN", springSecurityService.principal.id))
                    documentoSmart.addCampo(new Campo("MOTIVO_ANN", pa.motivo))
                    documentoSmart.addCampo(new Campo("ANNULLATO", "Y"))
                    documentoSmart.addCampo(new Campo("PROVVEDIMENTO_ANN", protocollo.provvedimentoAnnullamento))
                    documentoSmart.addCampo(new Campo("DATA_ANN", getDateSql(dateService.getCurrentDate())))
                    documentoSmart.addCampo(new Campo("STATO_PR", "AN"))
                }
            }

            ProtocolloDatiScarto scarto = protocollo.datiScarto
            if (scarto != null) {
                documentoSmart.addCampo(new Campo("STATO_SCARTO", scarto.stato.codiceGdm))
                documentoSmart.addCampo(new Campo("DATA_STATO_SCARTO", getDateSql(scarto.dataStato)))
                documentoSmart.addCampo(new Campo("NUMERO_NULLA_OSTA", scarto.nullaOsta ?: ""))
                documentoSmart.addCampo(new Campo("DATA_NULLA_OSTA", getDateSql(scarto.dataNullaOsta)))
            }

            ProtocolloDatiEmergenza emergenza = protocollo.datiEmergenza
            if (emergenza != null) {
                documentoSmart.addCampo(new Campo("DATA_INIZIO_EMERGENZA", getDateSql(emergenza.dataInizioEmergenza)))
                documentoSmart.addCampo(new Campo("DATA_FINE_EMERGENZA", getDateSql(emergenza.dataFineEmergenza)))
                documentoSmart.addCampo(new Campo("MOTIVO_EMERGENZA", emergenza.motivoEmergenza ?: ""))
                documentoSmart.addCampo(new Campo("PROVV_EMERGENZA", emergenza.provvedimentoEmergenza ?: ""))
            }

            if (protocollo.numeroEmergenza != null) {
                documentoSmart.addCampo(new Campo("ANNO_EMERGENZA", protocollo.annoEmergenza))
                documentoSmart.addCampo(new Campo("NUMERO_EMERGENZA", protocollo.numeroEmergenza))
                documentoSmart.addCampo(new Campo("REGISTRO_EMERGENZA", protocollo.registroEmergenza))
            }
            RegistroGiornaliero registroGiornaliero = protocollo.registroGiornaliero
            if (registroGiornaliero != null) {
                documentoSmart.addCampo(new Campo("DATA_INIZIO", getDateSql(registroGiornaliero.dataPrimoNumero)))
                documentoSmart.addCampo(new Campo("DATA_FINE", getDateSql(registroGiornaliero.dataUltimoNumero)))
                documentoSmart.addCampo(new Campo("NUMERO_INIZIO", registroGiornaliero.primoNumero))
                documentoSmart.addCampo(new Campo("NUMERO_FINE", registroGiornaliero.ultimoNumero))
                documentoSmart.addCampo(new Campo("NUMERO_TOTALE", registroGiornaliero.totaleProtocolli))
                documentoSmart.addCampo(new Campo("TOTALE_ANNULLATI", registroGiornaliero.totaleAnnullati))
                documentoSmart.addCampo(new Campo("RICERCA_INIZIO", getDateSql(registroGiornaliero.ricercaDataDal)))
                documentoSmart.addCampo(new Campo("RICERCA_FINE", getDateSql(registroGiornaliero.ricercaDataAl)))
            }

            if (!aggiornamento) {
                protocollo.idrif = calcolaIdrif()
                documentoSmart.addCampo(new Campo(CODICE_CAMPO_IDRIF, protocollo.idrif))
            }

            documentoSmart = documentaleService.salvaDocumento(documentoSmart)
            protocollo.idDocumentoEsterno = Long.parseLong(documentoSmart.id)

            // eseguo la fascicolazione
            if (!escludiFascicolazione) {
                fascicola(protocollo, escludiControlloCompetenze)
            }

            if (protocollo.tipoProtocollo.categoria == Protocollo.CATEGORIA_PROVVEDIMENTO) {
                //salva doc collegati al provvedimento in gdm
                salvaDocumentiCollegatiProvvedimento(protocollo)
            }

            return documentoSmart
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException("Errore nel salvataggio sul documentale: ${t.message}", t)
        }
    }

    /**
     * Cambia lo step su gdm
     */
    void cambiaStep(Protocollo protocollo) {
        try {
            Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
            String codiceModello = protocollo.categoriaProtocollo.codiceModelloGdm
            String codiceArea = protocollo.categoriaProtocollo.codiceAreaGdm

            if (codiceArea == null || codiceArea.trim().length() == 0) {
                throw new ProtocolloRuntimeException("Non è possibile salvare il documento ${protocollo} sul Documentale. Il codice dell'area è vuoto.")
            }
            if (codiceModello == null || codiceModello.trim().length() == 0) {
                throw new ProtocolloRuntimeException("Non è possibile salvare il documento ${protocollo} sul Documentale. Il codice del modello è vuoto.")
            }

            String convert = StepFlussoConverter.INSTANCE.convert(protocollo.iter.stepCorrente.cfgStep.nome, protocollo.movimento)
            if (!StringUtils.isEmpty(convert)) {
                Documento smartDocumento = buildDocumentoSmart(protocollo.idDocumentoEsterno, false, true)
                if (!StringUtils.isEmpty(convert)) {
                    if (protocollo.tipoProtocollo.categoria == Protocollo.CATEGORIA_LETTERA) {
                        smartDocumento.addCampo(new Campo("POSIZIONE_FLUSSO", convert))
                    }
                    documentaleService.salvaDocumento(smartDocumento)
                }
            }
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    private it.finmatica.segreteria.jprotocollo.struttura.Protocollo istanziaProtocolloGdm(Long idDocumentoEsterno) {
        try {
            Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, connGdm, 0)
            pg.setControlloCompetenzeAttivo(false)

            String codiceArea = areaSegreteria

            if (codiceArea == null || codiceArea.trim().length() == 0) {
                throw new ProtocolloRuntimeException("Non è possibile salvare sul Documentale. Il codice dell'area è vuoto.")
            }

            if (idDocumentoEsterno == null) {
                throw new ProtocolloRuntimeException("Id Documento Esterno non presente")
            }

            it.finmatica.segreteria.jprotocollo.struttura.Protocollo pGdm =
                    new it.finmatica.segreteria.jprotocollo.struttura.Protocollo(idDocumentoEsterno?.toString(), springSecurityService.principal.id, null, pg)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    IProfiloSmistabile istanziaSmistabileGdmDaSmistamento(Long iSmistamentoEsterno) {
        try {
            Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, connGdm, 0)
            pg.setControlloCompetenzeAttivo(false)

            String codiceArea = areaSegreteria

            if (codiceArea == null || codiceArea.trim().length() == 0) {
                throw new ProtocolloRuntimeException("Non è possibile salvare sul Documentale. Il codice dell'area è vuoto.")
            }

            if (iSmistamentoEsterno == null) {
                throw new ProtocolloRuntimeException("Id Documento Esterno non presente")
            }

            ProfiloExtend smistamentoGdm = new ProfiloExtend(String.valueOf(iSmistamentoEsterno), springSecurityService.principal.id, null, connGdm, false)
            return FactoryDocumenti.getInstanceSmistabileByIdrif(smistamentoGdm.getCampo("IDRIF"), springSecurityService.principal.id, pg)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    IProfiloSmistabile istanziaSmistabileGdm(Long idDocumentoEsterno) {
        try {
            Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, connGdm, 0)
            pg.setControlloCompetenzeAttivo(false)

            String codiceArea = areaSegreteria

            if (codiceArea == null || codiceArea.trim().length() == 0) {
                throw new ProtocolloRuntimeException("Non è possibile salvare sul Documentale. Il codice dell'area è vuoto.")
            }

            if (idDocumentoEsterno == null) {
                throw new ProtocolloRuntimeException("Id Documento Esterno non presente")
            }

            return FactoryDocumenti.getInstanceSmistabile(idDocumentoEsterno.toString(), springSecurityService.principal.id, pg)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    void rinominaFileProtocollato(Protocollo protocollo) {
        // Cambio del nome del file
        // es.: Lettera_PROT_2017_100.pdf.P7M
        FileDocumento principale = protocollo.getFilePrincipale()
        if (!principale) {
            return
        }
        String nome = principale.nome
        int index = nome.indexOf(".")
        if (index < 0) {
            return
        }

        String extension = nome.substring(index, nome.size())
        nome = "${protocollo.tipoProtocollo.categoria}_${protocollo.tipoRegistro.codice}_${protocollo.anno}_${protocollo.numero}${extension}"
        principale.nome = nome
        principale.save()

        // salvo il nome su gdm
        gestoreFile.renameFileName(protocollo.idDocumentoEsterno, principale.idFileEsterno, nome)
    }

    String pubblicaAlbo(Long idDocumentoEsterno) {
        try {
            it.finmatica.segreteria.jprotocollo.struttura.Protocollo pGdm = istanziaProtocolloGdm(idDocumentoEsterno)

            return pGdm.pubblicaAlbo(springSecurityService.principal.id, null)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Salva i dati del corrispondente
     *
     */
    Documento salvaCorrispondente(Corrispondente corrispondente, boolean listaDistribuzione = false, boolean escludiControlloCompentenze = false) {
        try {
            String codiceArea = areaSegreteria
            String codiceModello = CODICE_MODELLO_CORRISPONDENTE

            it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()

            boolean aggiornamento = corrispondente.idDocumentoEsterno != null

            if (aggiornamento) {
                documentoSmart.setId(String.valueOf(corrispondente.idDocumentoEsterno))
                documentoSmart = documentaleService.getDocumento(documentoSmart, new ArrayList<Documento.COMPONENTI>())
            } else {
                documentoSmart.addChiaveExtra("MODELLO", codiceModello)
                documentoSmart.addChiaveExtra("AREA", codiceArea)
            }

            documentoSmart.addChiaveExtra("ID_DOCUMENTO_PADRE", Long.toString(corrispondente.protocollo.idDocumentoEsterno))

            if (!aggiornamento) {
                documentoSmart.addCampo(new Campo(CODICE_CAMPO_IDRIF, corrispondente.protocollo.idrif))
            }

            documentoSmart.addCampo(new Campo("DENOMINAZIONE_PER_SEGNATURA", corrispondente.denominazione ?: ""))

            String denominazione = corrispondente.denominazione
            if (denominazione != null && denominazione != "") {
                if (denominazione.contains(":UO:")) {
                    String[] uo = denominazione.split(":UO:")
                    documentoSmart.addCampo(new Campo("DESCRIZIONE_AMM", uo[0] ?: ""))
                    documentoSmart.addCampo(new Campo("DESCRIZIONE_UO", uo[1] ?: ""))
                } else if (denominazione.contains(":AOO:")) {
                    String[] aoo = denominazione.split(":AOO:")
                    documentoSmart.addCampo(new Campo("DESCRIZIONE_AMM", aoo[0] ?: ""))
                    documentoSmart.addCampo(new Campo("DESCRIZIONE_AOO", aoo[1] ?: ""))
                }
                //guardare se è possibile fare qualcosa di più stabile
                else if (corrispondente.tipoSoggetto?.id == new Long(2)) {
                    documentoSmart.addCampo(new Campo("DESCRIZIONE_AMM", denominazione))
                }
            }
            documentoSmart.addCampo(new Campo("INDIRIZZO_PER_SEGNATURA", corrispondente.indirizzo ?: ""))
            documentoSmart.addCampo(new Campo("EMAIL", corrispondente.email ? corrispondente.email.trim() : ""))
            documentoSmart.addCampo(new Campo("PARTITA_IVA", corrispondente.partitaIva ?: ""))
            documentoSmart.addCampo(new Campo("CODICE_FISCALE", corrispondente.codiceFiscale ?: ""))
            documentoSmart.addCampo(new Campo("CF_PER_SEGNATURA", corrispondente.codiceFiscale ?: ""))
            documentoSmart.addCampo(new Campo("NOME_PER_SEGNATURA", corrispondente.nome ?: ""))
            documentoSmart.addCampo(new Campo("COGNOME_PER_SEGNATURA", corrispondente.cognome ?: ""))
            documentoSmart.addCampo(new Campo("FAX", corrispondente.fax ?: ""))
            documentoSmart.addCampo(new Campo("COMUNE_PER_SEGNATURA", corrispondente.comune ?: ""))
            documentoSmart.addCampo(new Campo("CAP_PER_SEGNATURA", corrispondente.cap ?: ""))
            documentoSmart.addCampo(new Campo("PROVINCIA_PER_SEGNATURA", corrispondente.provinciaSigla ?: ""))
            documentoSmart.addCampo(new Campo("TIPO_RAPPORTO", corrispondente.tipoCorrispondente ?: ""))
            documentoSmart.addCampo(new Campo("CODICE_AMMINISTRAZIONE", corrispondente.protocollo.ente?.amministrazione?.codice))
            documentoSmart.addCampo(new Campo("CODICE_AOO", corrispondente.protocollo.ente?.aoo))
            documentoSmart.addCampo(new Campo("DOCUMENTO_TRAMITE", corrispondente.modalitaInvioRicezione?.codice ?: ""))
            documentoSmart.addCampo(new Campo("CONOSCENZA", BooleanConverter.Y_N.INSTANCE.convert(corrispondente.conoscenza)))

            if (!listaDistribuzione) {
                for (Indirizzo indirizzo : corrispondente.indirizzi) {
                    if (indirizzo.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE) {
                        documentoSmart.addCampo(new Campo("COD_AMM", indirizzo.codice ?: ""))
                    } else if (indirizzo.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_AOO) {
                        documentoSmart.addCampo(new Campo("COD_AOO", indirizzo.codice ?: ""))
                    } else if (indirizzo.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_UO) {
                        documentoSmart.addCampo(new Campo("COD_UO", indirizzo.codice ?: ""))
                    }
                }
            }

            if (escludiControlloCompentenze) {
                documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
            }

            documentoSmart = documentaleService.salvaDocumento(documentoSmart)

            corrispondente.idDocumentoEsterno = Long.parseLong(documentoSmart.id)
            corrispondente.save()

            return documentoSmart
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    private boolean smistamentoSuGdm(Smistamento smistamento) {
        boolean crea = true
        try {
            smistamento.protocollo.idrif
        }
        catch (Exception e) {
            crea = false
        }

        return crea
    }

    /**
     * Salva i dati del smistamento
     *
     */
    Documento salvaSmistamento(Smistamento smistamento, boolean escludiControlloCompetenze = false) {
        try {

            if (!smistamentoSuGdm(smistamento)) {
                return
            }

            Documento documentoSmart = null
            if (!smistamento.idDocumentoEsterno) {
                documentoSmart = buildSmistamentoSmartInCreazione(smistamento)
            } else {
                documentoSmart = buildSmistamentoSmartDaModifica(smistamento.idDocumentoEsterno)
            }

            documentoSmart.addCampo(new Campo("TIPO_SMISTAMENTO", smistamento.tipoSmistamento))
            documentoSmart.addCampo(new Campo("STATO_SMISTAMENTO", StatoSmistamentoConverter.INSTANCE.convert(smistamento.statoSmistamento)))
            documentoSmart.addCampo(new Campo("NOTE", smistamento.note ?: ""))
            documentoSmart.addCampo(new Campo("NOTE_UTENTE", smistamento.noteUtente ?: ""))
            documentoSmart.addCampo(new Campo("DATA_ESECUZIONE", getDateSql(smistamento.dataEsecuzione)))
            documentoSmart.addCampo(new Campo("SMISTAMENTO_DAL", getDateSql(smistamento.dataSmistamento)))
            documentoSmart.addCampo(new Campo("PRESA_IN_CARICO_DAL", getDateSql(smistamento.dataPresaInCarico)))
            documentoSmart.addCampo(new Campo("CODICE_ASSEGNATARIO", smistamento.utenteAssegnatario?.id ?: ""))
            documentoSmart.addCampo(new Campo("DES_ASSEGNATARIO", smistamento.utenteAssegnatario?.nominativoSoggetto ?: ""))
            documentoSmart.addCampo(new Campo("UTENTE_ESECUZIONE", smistamento.utenteEsecuzione?.id ?: ""))
            documentoSmart.addCampo(new Campo("UTENTE_TRASMISSIONE", smistamento.utenteTrasmissione?.id ?: ""))
            documentoSmart.addCampo(new Campo("PRESA_IN_CARICO_UTENTE", smistamento.utentePresaInCarico?.id ?: ""))
            documentoSmart.addCampo(new Campo("DES_UFFICIO_SMISTAMENTO", smistamento.unitaSmistamento?.descrizione ?: ""))
            documentoSmart.addCampo(new Campo("UFFICIO_SMISTAMENTO", smistamento.unitaSmistamento?.codice ?: ""))
            documentoSmart.addCampo(new Campo("DES_UFFICIO_TRASMISSIONE", smistamento.unitaTrasmissione?.descrizione ?: ""))
            documentoSmart.addCampo(new Campo("UFFICIO_TRASMISSIONE", smistamento.unitaTrasmissione?.codice ?: ""))
            documentoSmart.addCampo(new Campo("ASSEGNAZIONE_DAL", getDateSql(smistamento.dataAssegnazione)))

            documentoSmart.addCampo(new Campo("CODICE_AMMINISTRAZIONE", smistamento.documento.ente?.amministrazione?.codice ?: ""))
            documentoSmart.addCampo(new Campo("CODICE_AOO", smistamento.documento.ente?.aoo ?: ""))
            documentoSmart.addCampo(new Campo("KEY_ITER_SMISTAMENTO", -1))

            if (escludiControlloCompetenze) {
                documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
            }

            documentoSmart = documentaleService.salvaDocumento(documentoSmart)

            smistamento.idDocumentoEsterno = Long.parseLong(documentoSmart.id)
            smistamento.save()
            return documentoSmart
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    private Documento buildSmistamentoSmartDaModifica(Long idDocumentoEsterno) {

        Documento documentoSmart = new Documento(id: String.valueOf(idDocumentoEsterno))
        documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        documentoSmart.setId(String.valueOf(idDocumentoEsterno))
        documentoSmart = documentaleService.getDocumento(documentoSmart, new ArrayList<Documento.COMPONENTI>())

        return documentoSmart
    }

    private Documento buildSmistamentoSmartInCreazione(Smistamento smistamento) {
        String codiceArea = areaSegreteria
        String codiceModello = CODICE_MODELLO_SMISTAMENTO

        Documento documentoSmart = new Documento()

        documentoSmart.addChiaveExtra("MODELLO", codiceModello)
        documentoSmart.addChiaveExtra("AREA", codiceArea)

        documentoSmart.addCampo(new Campo(CODICE_CAMPO_IDRIF, smistamento.protocollo.idrif))

        if (smistamento.protocollo.idDocumentoEsterno != null) {
            documentoSmart.addChiaveExtra("ID_DOCUMENTO_PADRE", Long.toString(smistamento.protocollo.idDocumentoEsterno))
        }

        return documentoSmart
    }

    Documento buildDocumentoSmart(Long idDocumentoEsterno) {
        return buildDocumentoSmart(idDocumentoEsterno, false, false, false)
    }

    Documento buildDocumentoSmart(Long idDocumentoEsterno, boolean retriveAllegati) {
        return buildDocumentoSmart(idDocumentoEsterno, retriveAllegati, false, false)
    }

    Documento buildDocumentoSmart(Long idDocumentoEsterno, boolean retriveAllegati, boolean escludiControlloCompetenze) {
        return buildDocumentoSmart(idDocumentoEsterno, retriveAllegati, escludiControlloCompetenze, false)
    }

    Documento buildDocumentoSmart(Long idDocumentoEsterno, boolean retriveAllegati, boolean escludiControlloCompetenze, boolean retriveDocumentiFigli) {

        ArrayList<Documento.COMPONENTI> componentiArrayList = new ArrayList<Documento.COMPONENTI>()

        Documento documentoSmart = new Documento(id: String.valueOf(idDocumentoEsterno))
        if (retriveAllegati) {
            componentiArrayList.add(Documento.COMPONENTI.FILE)
        }
        if (retriveDocumentiFigli) {
            componentiArrayList.add(Documento.COMPONENTI.DOCUMENTI_FIGLI)
        }
        if (escludiControlloCompetenze) {
            documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        }
        documentoSmart = documentaleService.getDocumento(documentoSmart, componentiArrayList)
        return documentoSmart
    }

    /**
     * @SmartDesktop
     * Prende in carico lo smistamento richiesto.
     * Se lo smistamento è di tipo CONOSCENZA, lo statoSmistamento diventa ESEGUITO, altrimenti diventa IN_CARICO.
     *
     * @param idSmistamentoEsterno
     * @param utentePresaInCarico
     * @param dataPresaInCarico
     */
    Documento prendiInCaricoSmistamento(Long idSmistamentoEsterno, Ad4Utente utentePresaInCarico, Date dataPresaInCarico = Utils.getCurrentDate(), boolean inviaNotifica = true) {
        try {

            Documento documentoSmart = buildSmistamentoSmartDaModifica(idSmistamentoEsterno)

            // se lo smistamento è per conoscenza e l'utente di presa in carico è lo stesso dell'utente di assegnazione oppure se l'utente di assegnazione è null, allora deve diventare anche ESEGUITO
            // il succo è che non deve diventare subito eseguito quando è assegnato ad un utente diverso da chi prende in carico. Questo
            // serve per poter richiamare questa funzione dalla prendiInCaricoEAssegna
            if (documentoSmart.trovaCampo(new Campo("TIPO_SMISTAMENTO"))?.valore == Smistamento.CONOSCENZA &&
                    (documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == "" ||
                            documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == null ||
                            documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == utentePresaInCarico.id)) {
                return eseguiSmistamento(idSmistamentoEsterno, utentePresaInCarico, dataPresaInCarico, false)
            }

            documentoSmart.addCampo(new Campo("STATO_SMISTAMENTO", StatoSmistamentoConverter.INSTANCE.convert(Smistamento.IN_CARICO)))
            documentoSmart.addCampo(new Campo("PRESA_IN_CARICO_UTENTE", utentePresaInCarico.id))
            documentoSmart.addCampo(new Campo("PRESA_IN_CARICO_DAL", getDateSql(dataPresaInCarico)))

            documentoSmart = documentaleService.salvaDocumento(documentoSmart)

            // elimino tutte le notifiche esistenti di questo smistamento
            if (inviaNotifica) {
                //notificheService.eliminaNotifica(null, idSmistamentoEsterno, null)
                jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), null)
            }

            if (inviaNotifica) {
                // invio la notifica di presa in carico
                this.inviaNotifica(documentoSmart)
            }

            return documentoSmart
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * @SmartDesktop
     * Esegue lo smistamento richiesto
     * Imposta utente e data esecuzione, stato smistamento = ESEGUITO
     *
     * @param idSmistamentoEsterno
     * @param utenteEsecuzione
     * @param dataEsecuzione
     */
    Documento eseguiSmistamento(Long idSmistamentoEsterno, Ad4Utente utenteEsecuzione, Date dataEsecuzione = dateService.getCurrentDate(), boolean cancellaNotifiche = true) {
        try {

            Documento documentoSmart = buildSmistamentoSmartDaModifica(idSmistamentoEsterno)

            if (documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == "" || documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == null || utenteEsecuzione.id == documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore) {
                documentoSmart.addCampo(new Campo("STATO_SMISTAMENTO", StatoSmistamentoConverter.INSTANCE.convert(Smistamento.ESEGUITO)))
                documentoSmart.addCampo(new Campo("UTENTE_ESECUZIONE", utenteEsecuzione.id))
                documentoSmart.addCampo(new Campo("DATA_ESECUZIONE", getDateSql(dataEsecuzione)))

                if (documentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_DAL"))?.valore == "" || documentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_DAL"))?.valore == null) {
                    documentoSmart.addCampo(new Campo("PRESA_IN_CARICO_DAL", getDateSql(dataEsecuzione)))
                }
                if (documentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_UTENTE"))?.valore == "" || documentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_UTENTE"))?.valore == null) {
                    documentoSmart.addCampo(new Campo("PRESA_IN_CARICO_UTENTE", utenteEsecuzione.id))
                }
                documentoSmart = documentaleService.salvaDocumento(documentoSmart)

                if (cancellaNotifiche) {
                    jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), null)
                }

                return documentoSmart
            }
            return null
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * @SmartDesktop
     * Storicizza lo smistamento richiesto
     * Imposta utente e data esecuzione, stato smistamento = STORICO
     *
     * @param idSmistamentoEsterno
     * @param utenteEsecuzione
     * @param dataEsecuzione
     */
    Documento storicizzaSmistamento(Long idSmistamentoEsterno, boolean eliminaNotifiche = true) {
        try {

            Documento documentoSmart = buildSmistamentoSmartDaModifica(idSmistamentoEsterno)
            documentoSmart.addCampo(new Campo("STATO_SMISTAMENTO", StatoSmistamentoConverter.INSTANCE.convert(Smistamento.STORICO)))
            documentoSmart = documentaleService.salvaDocumento(documentoSmart)

            // elimino qualsiasi notifica per qualsiasi utente per questo smistamento:
            //notificheService.eliminaNotifica(null, idSmistamentoEsterno, null)
            if (eliminaNotifiche) {
                jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), null)
            }

            return documentoSmart
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Assegna uno smistamento ed eventualmente ne crea di nuovi in base alla modalità di assegnazione:
     * - se lo smistamento richiesto non ha un assegnatario, verrà assegnato al nuovo destinatario (il primo della lista), indipendentemente dalla modalità di assegnazione scelta
     * - se lo smistamento richiesto ha un assegnatario, se la modalità di assegnazione è "SOSTITUISCI", allora quest'ultimo verrà sostituito, altrimenti verrà creato un nuovo smistamento
     *
     * @param smistamento lo smistamento da assegnare
     * @param unitaTrasmissione l'unità di trasmissione dell'eventuale nuovo smistamento
     * @param utenteAssegnante l'utente che sta assegnando lo smistamento
     * @param modalitaAssegnazione la modalità di assegnazione: SOSTITUISCI o AGGIUNGI. Se null, verrà usato SOSTITUISCI
     * @param destinatari il destinatari dello smistamento (si considerano solo gli utenti)
     * @param dataAssegnazione la data di assegnazione
     */
    void assegnaSmistamento(Long idSmistamentoEsterno, Ad4Utente utenteAssegnante, String modalitaAssegnazione, List<Map> destinatari, Date dataAssegnazione = Utils.getCurrentDate()) {

        List<Map> destinatariSmistamento = destinatari
        if (modalitaAssegnazione == null) {
            modalitaAssegnazione = DatiSmistamento.MODALITA_ASSEGNAZIONE_SOSTITUISCI
        }

        try {

            Documento documentoSmart = buildSmistamentoSmartDaModifica(idSmistamentoEsterno)

            // indipendentemente dalla modalità di assegnazione, se lo smistamento non ha già un assegnatario, viene assegnato
            if (documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == "" || documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == null || modalitaAssegnazione == DatiSmistamento.MODALITA_ASSEGNAZIONE_SOSTITUISCI) {

                // elimino eventuali notifiche per l'utente precedente
                String codiceAssegnatario = documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore

                // prendo il primo destinatario:
                Map destinatario = destinatari[0]
                assegnaSmistamento(documentoSmart, utenteAssegnante, (Ad4Utente) destinatario.utente, (String) destinatario.note, dataAssegnazione)

                if (codiceAssegnatario != null && codiceAssegnatario != "") {
                    // notificheService.eliminaNotifica(null, idSmistamentoEsterno, Ad4Utente.get(codiceAssegnatario))
                    jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), Ad4Utente.get(codiceAssegnatario))
                } else {
                    // notificheService.eliminaNotifica(null, idSmistamentoEsterno, null)
                    jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), null)
                }

                // invio le relative notifiche
                jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), null)
                inviaNotifica(documentoSmart)

                // elimino il primo destinatario:
                destinatariSmistamento = destinatari.takeRight(destinatari.size() - 1)
            }

            if ((documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == "" || documentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == null) && modalitaAssegnazione == DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI) {
                jWorklistNotificheDispatcher.elimina(null, idSmistamentoEsterno.toString(), null)
            }

            // per ogni destinatario (che in questo caso sono solo soggetti a cui assegnare), creo il relativo smistamento:
            for (Map destinatario : destinatariSmistamento) {

                Documento duplicato = duplicaSmistamento(documentoSmart)
                assegnaSmistamento(duplicato, utenteAssegnante, (Ad4Utente) destinatario.utente, (String) destinatario.note, dataAssegnazione)
                inviaNotifica(duplicato)
            }
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Duplica uno smistamento esistente
     *
     * @param protocollo il protocollo a cui aggiungere il nuovo smistamento
     * @param smistamento lo smistamento da duplicare
     * @return lo smistamento creato
     */
    Documento duplicaSmistamento(Documento smistamentoSmart) {
        try {

            Documento duplica = new Documento()
            duplica.addChiaveExtra("MODELLO", CODICE_MODELLO_SMISTAMENTO)
            duplica.addChiaveExtra("AREA", areaSegreteria)

            duplica.addCampo(new Campo("TIPO_SMISTAMENTO", smistamentoSmart.trovaCampo(new Campo("TIPO_SMISTAMENTO"))?.valore))
            duplica.addCampo(new Campo("STATO_SMISTAMENTO", smistamentoSmart.trovaCampo(new Campo("STATO_SMISTAMENTO"))?.valore))
            duplica.addCampo(new Campo("NOTE", smistamentoSmart.trovaCampo(new Campo("NOTE"))?.valore))
            duplica.addCampo(new Campo("NOTE_UTENTE", smistamentoSmart.trovaCampo(new Campo("NOTE_UTENTE"))?.valore))
            duplica.addCampo(new Campo("DATA_ESECUZIONE", smistamentoSmart.trovaCampo(new Campo("DATA_ESECUZIONE"))?.valore))
            duplica.addCampo(new Campo("SMISTAMENTO_DAL", smistamentoSmart.trovaCampo(new Campo("SMISTAMENTO_DAL"))?.valore))
            duplica.addCampo(new Campo("PRESA_IN_CARICO_DAL", smistamentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_DAL"))?.valore))
            duplica.addCampo(new Campo("CODICE_ASSEGNATARIO", smistamentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore))
            duplica.addCampo(new Campo("DES_ASSEGNATARIO", smistamentoSmart.trovaCampo(new Campo("DES_ASSEGNATARIO"))?.valore))
            duplica.addCampo(new Campo("UTENTE_ESECUZIONE", smistamentoSmart.trovaCampo(new Campo("UTENTE_ESECUZIONE"))?.valore))
            duplica.addCampo(new Campo("UTENTE_TRASMISSIONE", smistamentoSmart.trovaCampo(new Campo("UTENTE_TRASMISSIONE"))?.valore))
            duplica.addCampo(new Campo("PRESA_IN_CARICO_UTENTE", smistamentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_UTENTE"))?.valore))
            duplica.addCampo(new Campo("DES_UFFICIO_SMISTAMENTO", smistamentoSmart.trovaCampo(new Campo("DES_UFFICIO_SMISTAMENTO"))?.valore))
            duplica.addCampo(new Campo("UFFICIO_SMISTAMENTO", smistamentoSmart.trovaCampo(new Campo("UFFICIO_SMISTAMENTO"))?.valore))
            duplica.addCampo(new Campo("DES_UFFICIO_TRASMISSIONE", smistamentoSmart.trovaCampo(new Campo("DES_UFFICIO_TRASMISSIONE"))?.valore))
            duplica.addCampo(new Campo("UFFICIO_TRASMISSIONE", smistamentoSmart.trovaCampo(new Campo("UFFICIO_TRASMISSIONE"))?.valore))

            duplica.addCampo(new Campo("CODICE_AMMINISTRAZIONE", smistamentoSmart.trovaCampo(new Campo("CODICE_AMMINISTRAZIONE"))?.valore))
            duplica.addCampo(new Campo("CODICE_AOO", smistamentoSmart.trovaCampo(new Campo("CODICE_AOO"))?.valore))
            duplica.addCampo(new Campo("KEY_ITER_SMISTAMENTO", smistamentoSmart.trovaCampo(new Campo("KEY_ITER_SMISTAMENTO"))?.valore))

            duplica.addCampo(new Campo("IDRIF", smistamentoSmart.trovaCampo(new Campo("IDRIF"))?.valore))

            return documentaleService.salvaDocumento(duplica)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }

        return null
    }

    /**
     * Assegna un utente ad uno smistamento ed invia la relativa notifica.
     *
     * @param smistamento
     * @param utenteAssegnante
     * @param utenteAssegnatario
     * @param dataAssegnazione
     */
    void assegnaSmistamento(Documento smistamentoSmart, Ad4Utente utenteAssegnante, Ad4Utente utenteAssegnatario, String note, Date dataAssegnazione = Utils.getCurrentDate()) {
        try {

            smistamentoSmart.addCampo(new Campo("CODICE_ASSEGNATARIO", utenteAssegnatario?.id ?: ""))
            smistamentoSmart.addCampo(new Campo("DES_ASSEGNATARIO", utenteAssegnatario?.nominativoSoggetto ?: ""))
            smistamentoSmart.addCampo(new Campo("NOTE", note ?: ""))
            smistamentoSmart.addCampo(new Campo("ASSEGNAZIONE_DAL", getDateSql(dataAssegnazione)))

            documentaleService.salvaDocumento(smistamentoSmart)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Crea un nuovo Smistamento sulla base di quello esistente smistamento esistente ed invia la relativa notifica.
     *
     */
    boolean inoltraSmistamento(Long idSmistamentoSmart, Date inoltro, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, So4UnitaPubb unitaSmistamento, Ad4Utente utenteAssegnatario = null, String noteSmistamento = null, String tipoSmistamento = null) {
        try {

            Documento smistamentoSmart = buildSmistamentoSmartDaModifica(idSmistamentoSmart)

            Documento smistamentoSmartNuovo = new Documento()
            smistamentoSmartNuovo.addChiaveExtra("MODELLO", CODICE_MODELLO_SMISTAMENTO)
            smistamentoSmartNuovo.addChiaveExtra("AREA", areaSegreteria)

            smistamentoSmartNuovo.addCampo(new Campo(CODICE_CAMPO_IDRIF, smistamentoSmart.trovaCampo(new Campo(CODICE_CAMPO_IDRIF))?.valore))
            smistamentoSmartNuovo.addCampo(new Campo("CODICE_AMMINISTRAZIONE", smistamentoSmart.trovaCampo(new Campo("CODICE_AMMINISTRAZIONE"))?.valore))
            smistamentoSmartNuovo.addCampo(new Campo("CODICE_AOO", smistamentoSmart.trovaCampo(new Campo("CODICE_AOO"))?.valore))
            smistamentoSmartNuovo.addCampo(new Campo("KEY_ITER_SMISTAMENTO", -1))
            smistamentoSmartNuovo.addChiaveExtra("ID_DOCUMENTO_PADRE", smistamentoSmart.trovaMappaChiaviExtra("ID_DOCUMENTO_PADRE"))

            String tipoSmistamentoPrecedente = smistamentoSmart.trovaCampo(new Campo("TIPO_SMISTAMENTO"))?.valore
            String statoSmistamentoPrecedente = smistamentoSmart.trovaCampo(new Campo("STATO_SMISTAMENTO"))?.valore

            smistamentoSmartNuovo.addCampo(new Campo("STATO_SMISTAMENTO", StatoSmistamentoConverter.INSTANCE.convert(Smistamento.DA_RICEVERE)))
            smistamentoSmartNuovo.addCampo(new Campo("SMISTAMENTO_DAL", getDateSql(inoltro)))

            if (statoSmistamentoPrecedente == "R" && tipoSmistamento == Smistamento.COMPETENZA) {
                return false
            }
            if (statoSmistamentoPrecedente != "R" && tipoSmistamentoPrecedente == Smistamento.CONOSCENZA && tipoSmistamento == Smistamento.COMPETENZA) {
                return false
            }
            if (tipoSmistamento == null) {
                if (statoSmistamentoPrecedente == "R") {
                    tipoSmistamento = Smistamento.CONOSCENZA
                } else {
                    tipoSmistamento = tipoSmistamentoPrecedente
                }
            }

            smistamentoSmartNuovo.addCampo(new Campo("TIPO_SMISTAMENTO", tipoSmistamento))
            smistamentoSmartNuovo.addCampo(new Campo("UFFICIO_TRASMISSIONE", unitaTrasmissione?.codice ?: ""))
            smistamentoSmartNuovo.addCampo(new Campo("DES_UFFICIO_TRASMISSIONE", unitaTrasmissione?.descrizione ?: ""))
            smistamentoSmartNuovo.addCampo(new Campo("UTENTE_TRASMISSIONE", utenteTrasmissione?.id ?: ""))
            smistamentoSmartNuovo.addCampo(new Campo("NOTE", noteSmistamento ?: ""))
            smistamentoSmartNuovo.addCampo(new Campo("DES_UFFICIO_SMISTAMENTO", unitaSmistamento?.descrizione ?: ""))
            smistamentoSmartNuovo.addCampo(new Campo("UFFICIO_SMISTAMENTO", unitaSmistamento?.codice ?: ""))

            if (utenteAssegnatario != null) {
                smistamentoSmartNuovo.addCampo(new Campo("CODICE_ASSEGNATARIO", utenteAssegnatario?.id ?: ""))
                smistamentoSmartNuovo.addCampo(new Campo("DES_ASSEGNATARIO", utenteAssegnatario?.nominativoSoggetto ?: ""))
            }

            smistamentoSmartNuovo = documentaleService.salvaDocumento(smistamentoSmartNuovo)

            // invio le relative notifiche
            inviaNotifica(smistamentoSmartNuovo)
            return true
        } catch (Throwable t) {
            log.error(t.message)
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Salva Documento collegato sul documentale
     *
     */
    Documento salvaDocumentoCollegamento(IDocumentoEsterno documento, IDocumentoEsterno collegato, String codiceTipoCollegamento) {

        try {

            if (codiceTipoCollegamento == null) {
                return
            }

            if (documento?.idDocumentoEsterno == null || collegato?.idDocumentoEsterno == null) {
                return
            }
            Documento documentoSmart = buildDocumentoSmart(documento.idDocumentoEsterno)

            // nota: su gdm il riferimento del protocollo precedente è "invertito": cioè diventa: protocolloPrecedente ha un riferimento di tipo "PROT_PREC" sul documento protocolloPrincipale.
            // nella tabella "riferimenti" si traduce in: ID_DOCUMENTO=id_protocollo_precedente, tipo=PROT_PREC, id_doc_rif=id_protocollo_principale
            if (codiceTipoCollegamento == TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE || codiceTipoCollegamento == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO) {
                documentoSmart.addDocumentoReferente(new Riferimento(Long.toString(collegato.idDocumentoEsterno), codiceTipoCollegamento))
            } else {
                documentoSmart.addDocumentoRiferito(new Riferimento(Long.toString(collegato.idDocumentoEsterno), codiceTipoCollegamento))
            }

            if (codiceTipoCollegamento == TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE) {
                Protocollo precedente = (Protocollo) collegato
                documentoSmart.addCampo(new Campo("ANNO_PROT_PREC_SUCC", precedente.anno))
                documentoSmart.addCampo(new Campo("PROT_PREC_SUCC", precedente.numero))
            }

            return documentaleService.salvaDocumento(documentoSmart)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Elimina Documento collegato su GDM
     *
     */
    void eliminaDocumentoCollegato(Protocollo documento, it.finmatica.gestionedocumenti.documenti.Documento collegato, String codiceTipoCollegamento) {
        try {

            if (codiceTipoCollegamento == null) {
                return
            }
            if (documento?.idDocumentoEsterno == null) {
                return
            }

            Documento documentoSmart = buildDocumentoSmart(documento.idDocumentoEsterno)

            // nota: su gdm il riferimento del protocollo precedente è "invertito": cioè diventa: protocolloPrecedente ha un riferimento di tipo "PROT_PREC" sul documento protocolloPrincipale.
            // nella tabella "riferimenti" si traduce in: ID_DOCUMENTO=id_protocollo_precedente, tipo=PROT_PREC, id_doc_rif=id_protocollo_principale
            if (codiceTipoCollegamento == TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE || codiceTipoCollegamento == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO) {
                documentoSmart.removeDocumentoReferente(new Riferimento(Long.toString(collegato.idDocumentoEsterno), codiceTipoCollegamento))
            } else {
                documentoSmart.removeDocumentoRiferito(new Riferimento(Long.toString(collegato.idDocumentoEsterno), codiceTipoCollegamento))
            }

            documentaleService.salvaDocumento(documentoSmart)

            if (codiceTipoCollegamento == TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_RIFERIMENTO) {
                //Se sono su un documento con collegamento PROT_RIFE ed il collegato è un memo_protocollo
                //allora devo cambiare lo stato del memo a DA GESTIRE
                Documento documentoSmartMemo = buildDocumentoSmart(collegato.idDocumentoEsterno, false, true)
                String modello = documentoSmartMemo.getMappaChiaviExtra().get("MODELLO")

                if (modello == CODICE_MODELLO_MEMO) {
                    documentoSmartMemo.addCampo(new Campo("STATO_MEMO", "DG"))
                    documentoSmartMemo.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
                    documentaleService.salvaDocumento(documentoSmartMemo)
                }
            }
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Restituisce se è presente almeno uno smistamento con stato DA_RICEVERE, IN_CARICO, ESEGUITO
     *
     */
    List<So4UnitaPubb> unitaSmistamentoCorrenti(Protocollo documento, String tipo, String user = springSecurityService.principal.id, String password = null) {
        try {
            List<So4UnitaPubb> unitaList = new ArrayList<So4UnitaPubb>()
            Vector<it.finmatica.segreteria.jprotocollo.struttura.Smistamento> smistamentiGdm = new Vector<>()
            it.finmatica.segreteria.jprotocollo.struttura.Protocollo pGdm = istanziaProtocolloGdm(documento.idDocumentoEsterno)
            if (tipo == null) {
                smistamentiGdm = pGdm.getSmistamenti(false)
            } else {
                smistamentiGdm = pGdm.getSmistamentiPerTipo(tipo, false)
            }
            for (it.finmatica.segreteria.jprotocollo.struttura.Smistamento s : smistamentiGdm) {
                if (!Smistamento.STORICO.equals(s.stato)) {
                    unitaList.add(So4UnitaPubb.allaData().perOttica(Impostazioni.OTTICA_SO4.valore).findByCodice(s.getUfficioRicevente()))
                }
            }
            return unitaList
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    void fascicola(it.finmatica.gestionedocumenti.documenti.Documento documento, boolean escludiControlloCompetenze = false) {
        try {
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)

            // ottengo il profilo gdm:
            if (!(documento.idDocumentoEsterno > 0)) {
                return
            }

            Documento documentoSmart = buildDocumentoSmart(documento.idDocumentoEsterno, false, escludiControlloCompetenze)

            // se i dati sono tutti uguali, non devo aggiornare niente ed esco:
            if (documento.classificazione?.codice?.equals(documentoSmart.trovaCampo(new Campo("CLASS_COD"))?.valore) &&
                    documento.classificazione?.dal?.format("dd/MM/yyyy")?.equals(documentoSmart.trovaCampo(new Campo("CLASS_DAL"))?.valore) &&
                    documento.fascicolo?.numero?.equals(documentoSmart.trovaCampo(new Campo("FASCICOLO_NUMERO"))?.valore) &&
                    documento.fascicolo?.anno?.toString()?.equals(documentoSmart.trovaCampo(new Campo("FASCICOLO_ANNO"))?.valore)) {
                return
            }

            // tolgo il documento dalla classificazione in cui si trovava prima:
            Titolario titolarioCorrente = getTitolarioCorrente(documentoSmart, pg)

            if (documento.fascicolo == null) {
                if (titolarioCorrente != null) {
                    titolarioCorrente.togliDocumento(String.valueOf(documento.idDocumentoEsterno))
                }

                documentoSmart.addCampo(new Campo("FASCICOLO_NUMERO", ""))
                documentoSmart.addCampo(new Campo("FASCICOLO_ANNO", ""))
                documentoSmart.addCampo(new Campo("CLASS_COD", documento.classificazione?.codice ?: ""))
                documentoSmart.addCampo(new Campo("CLASS_DAL", (documento.classificazione?.dal != null ? new java.sql.Date(documento.classificazione?.dal?.getTime()) : null)))

                documentaleService.salvaDocumento(documentoSmart)
                return
            }

            if (!(documento.classificazione?.codice?.trim()?.length() > 0 && documento.classificazione?.dal != null)) {
                return
            }

            if (titolarioCorrente != null) {
                titolarioCorrente.togliDocumento(String.valueOf(documento.idDocumentoEsterno))
            }

            // metto il documento nella nuova classificazione/fascicolo
            Titolario nuovoTitolario = getTitolario(documento, pg)
            if (nuovoTitolario != null) {
                documentoSmart.addCampo(new Campo("FASCICOLO_NUMERO", documento.fascicolo?.numero ?: ""))
                documentoSmart.addCampo(new Campo("FASCICOLO_ANNO", (documento.fascicolo?.anno != null) ? Integer.toString(documento.fascicolo?.anno) : ""))
                documentoSmart.addCampo(new Campo("CLASS_COD", documento.classificazione?.codice ?: ""))
                documentoSmart.addCampo(new Campo("CLASS_DAL", (documento.classificazione?.dal != null ? new java.sql.Date(documento.classificazione?.dal?.getTime()) : null)))
                documentaleService.salvaDocumento(documentoSmart)

                nuovoTitolario.aggiungiDocumento(String.valueOf(documento.idDocumentoEsterno), true, false)
            }
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    @Transactional
    void fascicolaTitolarioSecondario(DocumentoTitolario documentoTitolario) {
        try {
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)

            it.finmatica.gestionedocumenti.documenti.Documento documento = (it.finmatica.gestionedocumenti.documenti.Documento) documentoTitolario.documento

            // ottengo il profilo gdm:
            if (!(documento?.idDocumentoEsterno > 0)) {
                return
            }

            Documento documentoSmart = buildDocumentoSmart(documento.idDocumentoEsterno)
            Titolario titolarioSecondario = getTitolarioSecondario(documentoSmart, pg, documentoTitolario.classificazione, documentoTitolario.fascicolo)

            if (titolarioSecondario != null) {
                titolarioSecondario.aggiungiDocumento(String.valueOf(documento.idDocumentoEsterno), false, false)
            }
        } catch (Exception t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    List<AllegatoEsterno> getFileAllegatiDocumento(long idDocumento) {
        try {
            List<AllegatoEsterno> allegati = []
            Documento documentoSmart = buildDocumentoSmart(idDocumento, true)

            for (File file : documentoSmart.files) {
                allegati << new AllegatoEsterno(nome: file.nome, idFileEsterno: Long.parseLong(file.id), idDocumentoEsterno: idDocumento, contentType: 'application/octet-stream')
            }

            return allegati
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    private Titolario getTitolarioCorrente(Documento documentoSmart, ParametriSegreteria pg) {
        try {
            // ritorno la classifica
            String classCod = documentoSmart.trovaCampo(new Campo("CLASS_COD"))?.valore

            // se non ho neanche il codice classifica, ritorno null
            if (!(classCod?.trim()?.length() > 0)) {
                return null
            }

            java.sql.Date classDal = new java.sql.Date(dateService.getCurrentDate().parse("dd/MM/yyyy", documentoSmart.trovaCampo("CLASS_DAL")?.valore).getTime())

            // se ho il fascicolo, il documento si trova lì dentro:
            if (documentoSmart.trovaCampo(new Campo("FASCICOLO_NUMERO"))?.valore?.trim()?.length() > 0) {
                Integer annoFascicolo = Integer.parseInt(documentoSmart.trovaCampo("FASCICOLO_ANNO")?.valore)
                String numeroFascicolo = documentoSmart.trovaCampo(new Campo("FASCICOLO_NUMERO")).valore

                return it.finmatica.segreteria.common.struttura.Fascicolo.getInstanceFascicolo("FASCICOLO", "SEGRETERIA", annoFascicolo, numeroFascicolo, classCod, classDal, springSecurityService.principal.id, null, pg)
            }

            return Classificazione.getInstanceClassificazione("DIZ_CLASSIFICAZIONE", "SEGRETERIA", classCod, classDal, springSecurityService.principal.id, null, pg)
        } catch (Exception t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    private Titolario getTitolarioSecondario(Documento documentoSmart, ParametriSegreteria pg, it.finmatica.protocollo.dizionari.Classificazione classificazione, Fascicolo fascicolo) {
        try {
            // ritorno la classifica
            String classCod = classificazione?.codice

            // se non ho neanche il codice classifica, ritorno null
            if (!(classCod?.trim()?.length() > 0)) {
                return null
            }
            java.sql.Date classDal = new java.sql.Date(classificazione?.dal.getTime())

            // se ho il fascicolo, il documento si trova lì dentro:
            if (fascicolo?.numero?.trim()?.length() > 0) {
                Integer annoFascicolo = fascicolo?.anno
                String numeroFascicolo = fascicolo?.numero

                return it.finmatica.segreteria.common.struttura.Fascicolo.getInstanceFascicolo("FASCICOLO", "SEGRETERIA", annoFascicolo, numeroFascicolo, classCod, classDal, springSecurityService.principal.id, null, pg)
            }

            return Classificazione.getInstanceClassificazione("DIZ_CLASSIFICAZIONE", "SEGRETERIA", classCod, classDal, springSecurityService.principal.id, null, pg)
        } catch (Exception t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    private Titolario getTitolario(it.finmatica.gestionedocumenti.documenti.Documento documento, ParametriSegreteria pg) {
        try {
            // ritorno la classifica
            String classCod = documento.classificazione?.codice

            // se non ho neanche il codice classifica, ritorno null
            if (!(classCod?.trim()?.length() > 0)) {
                return null
            }

            java.sql.Date classDal = new java.sql.Date(documento.classificazione.dal?.getTime())

            // se ho il fascicolo, il documento si trova lì dentro:
            if (documento.fascicolo?.numero?.trim()?.length() > 0) {
                Integer annoFascicolo = documento.fascicolo?.anno
                String numeroFascicolo = documento.fascicolo?.numero

                return it.finmatica.segreteria.common.struttura.Fascicolo.getInstanceFascicolo("FASCICOLO", "SEGRETERIA", annoFascicolo, numeroFascicolo, classCod, classDal, springSecurityService.principal.id, null, pg)
            }

            return Classificazione.getInstanceClassificazione("DIZ_CLASSIFICAZIONE", "SEGRETERIA", classCod, classDal, springSecurityService.principal.id, null, pg)
        } catch (Exception t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    Documento rimuoviFascicolo(DocumentoTitolario documentoTitolario, String user, String password) {
        try {
            Connection connGdm = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, connGdm, 0)
            pg.setControlloCompetenzeAttivo(false)

            String codiceArea = areaSegreteria

            if (codiceArea == null || codiceArea.trim().length() == 0) {
                throw new ProtocolloRuntimeException("Non è possibile salvare il documento ${documentoTitolario} sul Documentale. Il codice dell'area è vuoto.")
            }

            Documento documentoSmart = buildDocumentoSmart(documentoTitolario.documento?.idDocumentoEsterno)
            Titolario titolarioSecondario = getTitolarioSecondario(documentoSmart, pg, documentoTitolario.classificazione, documentoTitolario.fascicolo)

            if (titolarioSecondario != null) {
                titolarioSecondario.togliDocumento(String.valueOf(documentoTitolario.documento?.idDocumentoEsterno))
            }

            return documentoSmart
        } catch (Exception t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Setta lo stato a CA (Cancellato) su GDM
     *
     */
    void cancellaDocumento(String idDocumentoEsterno, boolean escludiControlloCompetenze = false) {
        try {

            Documento documento = new Documento(id: idDocumentoEsterno)
            if (escludiControlloCompetenze) {
                documento.addChiaveExtra('ESCLUDI_CONTROLLO_COMPETENZE', 'Y')
            }

            documentaleService.eliminaDocumento(documento)
        } catch (Exception t) {
            throw new ProtocolloRuntimeException(t)
        }
    }

    /**
     * Calcola IdDocumento (funzione : f_iddoc_from_cartella)
     *
     **/
    String calcolaIdDocFromCartella(Long idFolder) {
        String idDocumentoEsterno = ""
        Sql sql = new Sql(dataSource_gdm)
        sql.call("""BEGIN 
			               ? := f_iddoc_from_cartella (?);
		             END; """,
                [Sql.VARCHAR, idFolder]) { row ->
            idDocumentoEsterno = row
        }
        return idDocumentoEsterno
    }

    /**
     * Calcola Idrif (funzione : ag_get_idrif)
     *
     **/
    String calcolaIdrif() {
        String idRif = ""
        Sql sql = new Sql(dataSource_gdm)
        sql.call("""BEGIN 
			               ? := ag_get_idrif ();
		             END; """,
                [Sql.VARCHAR]) { row ->
            idRif = row
        }
        return idRif
    }

    java.sql.Date getDateSql(Date d) {
        return (d == null) ? null : new java.sql.Date(d.getTime())
    }

    /**
     * Invio Asicrono delle notifiche degli smistamenti tramite la SmartDesktop
     *
     **/
    void inviaNotifica(Documento smistamentoSmart) {
        Smistamento smistamento = Smistamento.findByIdDocumentoEsterno(new Long(smistamentoSmart.id))

        // se ho lo smistamento, invio la notifica tramite il solito meccansimo di notifiche.
        // Faccio così perché il testo e l'oggetto delle notifiche sta su AGSPR.
        // in caso contrario, il testo e l'oggetto delle notifiche stanno su GDM.
        if (smistamento) {
            inviaNotificaAgspr(smistamento)
        } else {
            inviaNotificaSmartDesktop(smistamentoSmart)
        }
    }

    private void inviaNotificaAgspr(Smistamento smistamento) {
        String tipoNotifica = getTipoNotificaSmistamento(smistamento)
        if (tipoNotifica != null) {
            notificheService.invia(tipoNotifica, smistamento, null, false)
        }
    }

    private String getTipoNotificaSmistamento(Smistamento smistamento) {
        // la notifica non è da inviare.
        return getTipoNotificaSmistamento((Smistamento.IN_CARICO == smistamento.statoSmistamento)
                , smistamento.utenteAssegnatario != null
                , (Smistamento.DA_RICEVERE == smistamento.statoSmistamento)
                , smistamento.isPerCompetenza(), smistamento.protocollo.categoriaProtocollo.isDaNonProtocollare())
    }

    private void inviaNotificaSmartDesktop(Documento smistamentoProfilo) {
        // categoria: dallo smistamento recupero l'id rif e lo recupero su smistabili
        String idRif = smistamentoProfilo.trovaCampo(new Campo("IDRIF"))?.valore
        Smistabile smistabile = Smistabile.findByIdrif(idRif)
        boolean riservato = smistabile.riservato

        So4UnitaPubb unitaSmistamento = So4UnitaPubb.findByCodiceAndAlIsNull(smistamentoProfilo.trovaCampo(new Campo("UFFICIO_SMISTAMENTO"))?.valore)
        String assegnatario = smistamentoProfilo.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore
        boolean assegnato = !StringUtils.isEmpty(assegnatario)
        boolean perCompetenza = smistamentoProfilo.trovaCampo(new Campo("TIPO_SMISTAMENTO")).valore == Smistamento.COMPETENZA

        // calcolo i destinatari della notifica
        List<NotificaSoggetto> destinatari
        if (assegnato) {
            destinatari = [new NotificaSoggetto(unitaSo4: unitaSmistamento?.toDTO(), utente: Ad4Utente.get(assegnatario)?.toDTO())]
        } else {
            destinatari = regoleCalcoloNotificheSmistamentoRepository.getComponentiUnitaConPrivilegioPerSmistamenti(null, unitaSmistamento, riservato)
        }

        // se non trovo la notifica da inviare, esco e non faccio nulla
        Notifica notifica = getNotificaSmartDesktop(smistamentoProfilo, assegnato, perCompetenza, smistabile.categoriaProtocollo.isDaNonProtocollare())
        if (notifica == null) {
            return
        }

        // se non trovo l'oggetto, non devo inviare la notifica.
        String oggetto = getOggettoNotificaSmartDesktop(smistabile, smistamentoProfilo, assegnato, perCompetenza)
        if (oggetto == null) {
            return
        }

        // sostituisco i campi con i relativi valori
        oggetto = oggetto.replaceAll("[\$]oggetto", smistabile.oggetto ?: "")
                .replaceAll("[\$]modalita", smistabile.movimento ?: "")
                .replaceAll("[\$]anno", smistabile.anno?.toString() ?: "")
                .replaceAll("[\$]numero7", smistabile.numero7 ?: "")
                .replaceAll("[\$]tipo", smistabile.categoria ?: "")
                .replaceAll("[\$]numero", smistabile.numero?.toString() ?: "")
                .replaceAll("[\$]data", smistabile.data?.format("dd/MM/yyyy") ?: "")
        // concordato con Mia di lasciare solo la data senza ore:minuti perché fa così anche "nel vecchio"
        jWorklistNotificheDispatcher.invia(notifica, smistamentoProfilo, destinatari, oggetto, oggetto, null, false)
    }

    private Notifica getNotificaSmartDesktop(Documento smistamentoProfilo, boolean assegnato, boolean perCompetenza, boolean daNonProtocollare) {
        String tipoNotifica = getTipoNotificaSmartDesktop(smistamentoProfilo, assegnato, perCompetenza, daNonProtocollare)

        if (tipoNotifica == null) {
            return null
        }

        return Notifica.findByTipoNotifica(tipoNotifica)
    }

    private String getTipoNotificaSmartDesktop(Documento smistamentoProfilo, boolean assegnato, boolean perCompetenza, boolean daNonProtocollare) {
        return getTipoNotificaSmistamento((smistamentoProfilo.trovaCampo(new Campo("STATO_SMISTAMENTO"))?.valore == StatoSmistamentoConverter.INSTANCE.convert(Smistamento.IN_CARICO))
                , assegnato
                , (smistamentoProfilo.trovaCampo(new Campo("STATO_SMISTAMENTO"))?.valore == StatoSmistamentoConverter.INSTANCE.convert(Smistamento.DA_RICEVERE))
                , perCompetenza
                , daNonProtocollare)
    }

    private String getOggettoNotificaSmartDesktop(Smistabile smistabile, Documento smistamentoProfilo, boolean assegnato, boolean perCompetenza) {
        if (smistamentoProfilo.trovaCampo(new Campo("STATO_SMISTAMENTO"))?.valore == StatoSmistamentoConverter.INSTANCE.convert(Smistamento.IN_CARICO)) {
            return smistabile.categoriaProtocollo.getOggettoNotificaInCarico(assegnato)
        } else if (smistamentoProfilo.trovaCampo(new Campo("STATO_SMISTAMENTO"))?.valore == StatoSmistamentoConverter.INSTANCE.convert(Smistamento.DA_RICEVERE)) {
            return smistabile.categoriaProtocollo.getOggettoNotificaDaRicevere(perCompetenza)
        }

        return null
    }

    private String getTipoNotificaSmistamento(boolean inCarico, boolean assegnato, boolean daRicevere, boolean perCompetenza, boolean daNonProtocollare) {
        if (inCarico) {
            if (assegnato) {
                return !daNonProtocollare ? RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_ASSEGNAZIONE : RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_ASSEGNAZIONE_NP
            } else {
                return !daNonProtocollare ? RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO : RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_NP
            }
        } else if (daRicevere) {
            if (perCompetenza) {
                return !daNonProtocollare ? RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_COMPETENZA : RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_COMPETENZA_NP
            } else {
                return !daNonProtocollare ? RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_CONOSCENZA : RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_CONOSCENZA_NP
            }
        }

        // la notifica non è da inviare.
        return null
    }

    String getLinkDocumento(Long idDocumentoEsterno, String RW = "W") {
        String link = ""
        Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
        Sql sql = new groovy.sql.Sql(conn)
        sql.call("""BEGIN 
					  ? := ag_utilities.get_url_oggetto ('',
                                                              '',
                                                              ?,
                                                              'D',
                                                              '',
                                                              '',
                                                              '',
                                                              ?,
                                                              '',
                                                              '',
                                                              '5',
                                                              'N',
                                                              'N',
                                                              'N');
					END; """,
                [Sql.VARCHAR, idDocumentoEsterno, RW]) {
            row -> link = row
        }

        return link
    }

    void generaImpronteFile(Protocollo protocollo) {
        generaImpronteFileDocumento(protocollo)

        for (Allegato allegato : protocollo.allegati) {
            generaImpronteFileDocumento(allegato)
        }
    }

    private void generaImpronteFileDocumento(Documento documento) {
        Connection connection = DataSourceUtils.getConnection(dataSource_gdm)
        for (FileDocumento fileDocumento : documento.fileDocumenti) {
            if (fileDocumento.codice != FileDocumento.CODICE_FILE_ORIGINALE) {
                ProfiloExtend profiloExtend = new ProfiloExtend(documento.idDocumentoEsterno.toString(), springSecurityService.principal.id, null, connection)
                if (profiloExtend == null) {
                    throw new ProtocolloRuntimeException("Non ho trovato il documento gdm con id ${documento.idDocumentoEsterno}")
                }
                profiloExtend.generaImpronta512(fileDocumento.nome)
            }
        }
    }

    /**
     * Questo metodo salva in SPR_PROVVEDIMENTI ogni volta la nuova lista di ELENCO_ANNULLANDI per i provvedimenti di annullamento
     *
     * @param protocollo
     */
    void salvaDocumentiCollegatiProvvedimento(Protocollo protocollo) {
        try {
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)

            // ottengo il profilo gdm:
            if (!(protocollo.idDocumentoEsterno > 0)) {
                return
            }

            Documento documentoSmart = buildDocumentoSmart(protocollo.idDocumentoEsterno)

            String idProtocolliDaAnnullare = ""
            for (DocumentoCollegato docCollegato : protocollo.documentiCollegati) {
                idProtocolliDaAnnullare = (String.valueOf(docCollegato.collegato.idDocumentoEsterno)).concat("#").concat(idProtocolliDaAnnullare)
            }
            documentoSmart.addCampo(new Campo("ELENCO_ANNULLANDI", idProtocolliDaAnnullare ?: ""))
            documentaleService.salvaDocumento(documentoSmart)
        } catch (Throwable t) {
            throw new ProtocolloRuntimeException(t)
        }
    }
}