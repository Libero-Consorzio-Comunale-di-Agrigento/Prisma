package it.finmatica.protocollo.documenti

import groovy.json.JsonSlurper
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.storico.DatoStorico
import it.finmatica.gestionedocumenti.storico.DatoStorico.TipoStorico
import it.finmatica.gestionedocumenti.storico.DocumentoStorico
import it.finmatica.gestionedocumenti.storico.DocumentoStoricoRepository
import it.finmatica.gestioneiter.motore.WkfStep
import it.finmatica.protocollo.corrispondenti.Corrispondente
import org.hibernate.envers.RevisionType
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionTemplate

import javax.persistence.EntityManager
import javax.sql.DataSource

/**
 * Questa classe serve per gestire la trascodifica dello storico da Protocollo 3.5.x a 3.6.0, ovvero dallo storico JSON e GDM 3.5.3
 * allo storico con Envers e GDM 3.5.4 (che ha la gestione migliore del recupero dei file storicizzati)
 */
@Slf4j
@Service
@Transactional
class ProtocolloStoricoTrascoService {

    private final ProtocolloStoricoTrascoRepository protocolloStoricoTrascoRepository
    private final DocumentoStoricoRepository documentoStoricoRepository
    private final PlatformTransactionManager transactionManager
    private final EntityManager entityManager

    @Autowired
    DataSource dataSource

    ProtocolloStoricoTrascoService(ProtocolloStoricoTrascoRepository protocolloStoricoTrascoRepository, DocumentoStoricoRepository documentoStoricoRepository, PlatformTransactionManager transactionManager, EntityManager entityManager) {
        this.protocolloStoricoTrascoRepository = protocolloStoricoTrascoRepository
        this.documentoStoricoRepository = documentoStoricoRepository
        this.transactionManager = transactionManager
        this.entityManager = entityManager
    }

    void trascodificaStorico() {
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager)
        transactionTemplate.setPropagationBehavior(Propagation.REQUIRES_NEW.value())

        // select di tutti gli id dei protocolli
        // quelli che hanno una riga in DocumentoStorico, li trascodifico leggendo il json
        // quelli che non hanno una riga, aggiungo una riga ADD per envers.

        // ottengo i documenti da trascodificare:
        List<Map> protocolliDaTrascodificare = protocolloStoricoTrascoRepository.getIdDocumentiDaTrascodificare(1L)

        for (Map proto : protocolliDaTrascodificare) {
            // non voglio intasare la sessione tenendo tutto in memoria, quindi svuoto di volta in volta.
            entityManager.clear()
            log.info("Trascodifico il documento con id ${proto}")

            if (proto.DOCUMENTI_STORICI > 0) {
                try {
                    transactionTemplate.execute({
                        Protocollo p = Protocollo.get(proto.ID_PROTOCOLLO.longValue())
                        trascodificaStorico(p)
                    })
                } catch (Exception e) {
                    transactionTemplate.execute({
                        // scrivo il log su una riga qualunque dello storico:
                        DocumentoStorico documentoStorico = protocolloStoricoTrascoRepository.getDocumentoStoricoPerIdDocumento(proto.ID_PROTOCOLLO.longValue())
                        documentoStorico.setStatoTrascodifica(DocumentoStorico.ERRORE)
                        StringWriter errors = new StringWriter()
                        e.printStackTrace(new PrintWriter(errors))
                        documentoStorico.setErroreTrascodifica(errors.toString())
                        documentoStoricoRepository.save(documentoStorico)
                    })
                }
            } else {
                try {
                    // altrimenti devo creare una riga di _log per ogni riga di protocollo
                    transactionTemplate.execute({
                        Protocollo p = Protocollo.get(proto.ID_PROTOCOLLO.longValue())
                        creaRigheStoricoEnvers(p)
                    })
                } catch (Exception e) {
                    log.error("Errore in trascodifica envers del protocollo: ${proto} ", e)
                }
            }
        }

        log.info("Inizio la Trascodifica Storico Lettere")
        try {

            callProcedureTrascoStoricoLettere()

        } catch (Exception e) {
            log.error("Errore in Trascodifica Storico Lettere", e)
        }
        log.info("Fine della Trascodifica Storico Lettere")
    }

    void creaRigheStoricoEnvers(Protocollo protocollo) {

        long rev = protocolloStoricoTrascoRepository.getNextRevision(protocollo.dateCreated)
        long revtype = RevisionType.ADD.ordinal()

        protocolloStoricoTrascoRepository.insertLog("GDO_DOCUMENTI_LOG", [ID_DOCUMENTO             : protocollo.id
                                                                          , REV                    : rev
                                                                          , REVTYPE                : revtype
                                                                          , ID_DOCUMENTO_ESTERNO   : protocollo.idDocumentoEsterno
                                                                          , ID_ENGINE_ITER         : protocollo.iter?.id
                                                                          , TIPO_OGGETTO           : protocollo.tipoOggetto?.codice
                                                                          , FILE_DOCUMENTI_MOD     : (protocollo.filePrincipale != null) ? 1 : 0
                                                                          , DOCUMENTI_COLLEGATI_MOD: (protocollo.allegati != null) ? 1 : 0
                                                                          , DATA_INS               : protocollo.dateCreated
                                                                          , DATA_UPD               : protocollo.lastUpdated
                                                                          , VALIDO                 : protocollo.valido ? 'Y' : 'N'
                                                                          , UTENTE_INS             : protocollo.utenteIns?.id
                                                                          , UTENTE_UPD             : protocollo.utenteUpd?.id
                                                                          , ID_ENTE                : protocollo.ente?.id], revtype)

        protocolloStoricoTrascoRepository.insertLog("AGP_PROTOCOLLI_LOG", [ID_DOCUMENTO        : protocollo.id
                                                                           , REV               : rev
                                                                           , ANNO              : protocollo.anno
                                                                           , DATA              : protocollo.data
                                                                           , MOVIMENTO         : protocollo.movimento
                                                                           , NOTE              : protocollo.note
                                                                           , NOTE_TRASMISSIONE : protocollo.noteTrasmissione
                                                                           , NUMERO            : protocollo.numero
                                                                           , OGGETTO           : protocollo.oggetto
                                                                           , TIPO_REGISTRO     : protocollo.tipoRegistro?.codice
                                                                           , CORRISPONDENTI_MOD: (protocollo.corrispondenti != null) ? 1 : 0
                                                                           , ID_CLASSIFICAZIONE: protocollo.classificazione?.id
                                                                           , ID_FASCICOLO      : protocollo.fascicolo?.id], revtype)

        if (protocollo.iter != null) {
            protocolloStoricoTrascoRepository.insertLog("WKF_ENGINE_ITER_LOG", [ID_ENGINE_ITER    : protocollo.iter.id
                                                                                , REV             : rev
                                                                                , REVTYPE         : revtype
                                                                                , ID_CFG_ITER     : protocollo.iter.cfgIter.id
                                                                                , ID_STEP_CORRENTE: protocollo.iter.stepCorrente?.id
                                                                                , DATA_INIZIO     : protocollo.iter.dataInizio
                                                                                , DATA_FINE       : null
                                                                                , DATA_INS        : protocollo.iter.dateCreated
                                                                                , DATA_UPD        : protocollo.iter.lastUpdated
                                                                                , UTENTE_INS      : protocollo.iter.utenteIns?.id
                                                                                , UTENTE_UPD      : protocollo.iter.utenteUpd?.id
                                                                                , ENTE            : protocollo.iter.ente?.codice], revtype)
        }

        if (protocollo.filePrincipale != null) {
            FileDocumento filePrincipale = protocollo.filePrincipale
            protocolloStoricoTrascoRepository.insertLog("GDO_FILE_DOCUMENTO_LOG", [ID_FILE_DOCUMENTO  : filePrincipale.id
                                                                                   , CODICE           : FileDocumento.CODICE_FILE_PRINCIPALE
                                                                                   , DATA_INS         : filePrincipale.dateCreated
                                                                                   , DATA_UPD         : filePrincipale.lastUpdated
                                                                                   , ID_DOCUMENTO     : protocollo.id
                                                                                   , ID_FILE_ESTERNO  : filePrincipale.idFileEsterno
                                                                                   , NOME             : filePrincipale.nome
                                                                                   , REV              : rev
                                                                                   , REVISIONE_STORICO: filePrincipale.revisione
                                                                                   , REVTYPE          : revtype
                                                                                   , UTENTE_INS       : filePrincipale.utenteIns?.id
                                                                                   , UTENTE_UPD       : filePrincipale.utenteUpd?.id], revtype)
        }

        if (protocollo.corrispondenti != null) {
            for (Corrispondente corrispondente : protocollo.corrispondenti) {
                protocolloStoricoTrascoRepository.insertLog("AGP_PROTOCOLLI_CORR_LOG", [ID_PROTOCOLLO_CORRISPONDENTE: corrispondente.id
                                                                                        , REV                       : rev
                                                                                        , REVTYPE                   : revtype
                                                                                        , DENOMINAZIONE             : corrispondente.denominazione
                                                                                        , ID_DOCUMENTO              : protocollo.id
                                                                                        , DATA_INS                  : corrispondente.dateCreated
                                                                                        , DATA_UPD                  : corrispondente.lastUpdated
                                                                                        , UTENTE_INS                : corrispondente.utenteIns?.id
                                                                                        , UTENTE_UPD                : corrispondente.utenteUpd?.id], revtype)
            }
        }

        if (protocollo.allegati != null) {

            for (DocumentoCollegato documentoCollegato : protocollo.documentiCollegati) {
                if (documentoCollegato.collegato instanceof Allegato) {
                    Allegato allegato = (Allegato) documentoCollegato.collegato
                    protocolloStoricoTrascoRepository.insertLog("GDO_DOCUMENTI_LOG", [ID_DOCUMENTO          : allegato.id
                                                                                      , REV                 : rev
                                                                                      , REVTYPE             : revtype
                                                                                      , ID_DOCUMENTO_ESTERNO: allegato.idDocumentoEsterno
                                                                                      , TIPO_OGGETTO        : allegato.tipoOggetto?.codice
                                                                                      , RISERVATO           : allegato.riservato
                                                                                      , VALIDO              : allegato.valido
                                                                                      , FILE_DOCUMENTI_MOD  : (allegato.fileDocumenti?.size() > 0) ? 1 : 0
                                                                                      , DATA_INS            : allegato.dateCreated
                                                                                      , DATA_UPD            : allegato.lastUpdated
                                                                                      , UTENTE_INS          : allegato.utenteIns?.id
                                                                                      , UTENTE_UPD          : allegato.utenteUpd?.id
                                                                                      , ID_ENTE             : allegato.ente?.id], revtype)

                    protocolloStoricoTrascoRepository.insertLog("GDO_ALLEGATI_LOG", [ID_DOCUMENTO : allegato.id
                                                                                     , DESCRIZIONE: allegato.descrizione
                                                                                     , REV        : rev], revtype)

                    protocolloStoricoTrascoRepository.insertLog("GDO_DOCUMENTI_COLLEGATI_LOG", [ID_DOCUMENTO_COLLEGATO: documentoCollegato.id
                                                                                                , REV                 : rev
                                                                                                , REVTYPE             : RevisionType.ADD.ordinal()
                                                                                                , DATA_INS            : documentoCollegato.dateCreated
                                                                                                , DATA_UPD            : documentoCollegato.lastUpdated
                                                                                                , VALIDO              : 'Y'
                                                                                                , UTENTE_INS          : documentoCollegato.utenteIns?.id
                                                                                                , UTENTE_UPD          : documentoCollegato.utenteUpd?.id
                                                                                                , ID_COLLEGATO        : allegato.id
                                                                                                , ID_DOCUMENTO        : documentoCollegato.documento?.id
                                                                                                , ID_TIPO_COLLEGAMENTO: documentoCollegato.tipoCollegamento?.id], RevisionType.ADD.ordinal())

                    for (FileDocumento file : allegato.fileDocumenti) {
                        protocolloStoricoTrascoRepository.insertLog("GDO_FILE_DOCUMENTO_LOG", [ID_FILE_DOCUMENTO  : file.id
                                                                                               , CODICE           : FileDocumento.CODICE_FILE_ALLEGATO
                                                                                               , DATA_INS         : file.dateCreated
                                                                                               , DATA_UPD         : file.lastUpdated
                                                                                               , ID_DOCUMENTO     : allegato.id
                                                                                               , ID_FILE_ESTERNO  : file.idFileEsterno
                                                                                               , NOME             : file.nome
                                                                                               , REV              : rev
                                                                                               , REVISIONE_STORICO: file.revisione
                                                                                               , REVTYPE          : revtype
                                                                                               , UTENTE_INS       : file.utenteIns?.id
                                                                                               , UTENTE_UPD       : file.utenteUpd?.id], revtype)
                    }
                }
            }
        }
    }

    void callProcedureTrascoStoricoLettere() {
        Sql sql = new Sql(dataSource)
        sql.call("BEGIN attiva_trasco_storico_lettere(); END;")
    }

    void trascodificaStorico(Protocollo protocollo) {
        // recupero tutti i json storicizzati
        List<DocumentoStorico> documentiStorici = documentoStoricoRepository.ricerca(protocollo.id, null, null)

        for (int i = 0; i < documentiStorici.size(); i++) {
            DocumentoStorico documentoStorico = documentiStorici[i]

            // inizializzo la revisione se ancora non l'ho fatto
            long rev = protocolloStoricoTrascoRepository.getNextRevision(documentoStorico.dateCreated)

            int revtype = RevisionType.MOD.ordinal()
            if (i == 0) {
                revtype = RevisionType.ADD.ordinal()
            }

            // parso i dati storici
            List<DatoStorico> datiModificati = parseDatiModificati(documentoStorico.datiModificati)
            def json = new JsonSlurper().parseText(documentoStorico.getDatiStoricizzati())

            // inserisco i dati per il protocollo
            insertProtocolloLog(protocollo, documentoStorico, json, rev, revtype, datiModificati)

            // inserisco i dati per l'iter
            insertWkfStepLog(protocollo, documentoStorico, json.step, rev, revtype)

            // inserisco i dati per il testo principale
            if (json.testoPrincipale != null) {
                insertFilePrincipaleLog(protocollo, documentoStorico, json.testoPrincipale, rev, revtype)
            }

            // inserisco i dati per i corrispondenti
            insertCorrispondentiLog(protocollo, documentoStorico, datiModificati, rev, revtype)

            // inserisco i dati per gli allegati
            insertAllegatiLog(documentoStorico, datiModificati, json, rev, revtype)

            documentoStorico.statoTrascodifica = DocumentoStorico.TRASCODIFICATO
            documentoStoricoRepository.save(documentoStorico)
        }
    }

    private void insertWkfStepLog(Protocollo protocollo, DocumentoStorico storico, def jsonStep, long rev, int revtype) {

        WkfStep step = null
        if (jsonStep != null) {
            // recupero lo step originale confidando che non sia mai stato cancellato:
            step = protocolloStoricoTrascoRepository.getWkfStep(jsonStep._key)
        } else if (protocollo.iter != null && revtype == RevisionType.ADD.ordinal()) {
            // se non ho lo step json e sono in add del protocollo, aggiungo il primo nodo dell'iter:
            step = protocolloStoricoTrascoRepository.getFirstWkfStep(protocollo.iter)
        }

        // metti mai che torni null, non faccio niente
        if (step == null) {
            return
        }

        protocolloStoricoTrascoRepository.insertLog("WKF_ENGINE_ITER_LOG", [ID_ENGINE_ITER    : step.iter.id
                                                                            , REV             : rev
                                                                            , REVTYPE         : revtype
                                                                            , ID_CFG_ITER     : step.iter.cfgIter.id
                                                                            , ID_STEP_CORRENTE: step.id
                                                                            , DATA_INIZIO     : step.iter.dataInizio
                                                                            , DATA_FINE       : null
                                                                            , DATA_INS        : step.iter.dateCreated
                                                                            , DATA_UPD        : storico.lastUpdated
                                                                            , UTENTE_INS      : step.iter.utenteIns.id
                                                                            , UTENTE_UPD      : storico.utenteIns.id
                                                                            , ENTE            : step.iter.ente.codice], revtype)
    }

    private void insertProtocolloLog(Protocollo protocollo, DocumentoStorico storico, def json, long rev, int revtype, List<DatoStorico> datiModificati) {

        boolean testoPrincipaleModificato = datiModificati.find { it.campo.startsWith("testoPrincipale") } != null
        boolean allegatiModificati = datiModificati.find { it.campo.startsWith("allegati") } != null
        boolean corrispondentiModificati = datiModificati.find { it.campo.startsWith("destinatari") } != null

        protocolloStoricoTrascoRepository.insertLog([GDO_DOCUMENTI_LOG : [ID_DOCUMENTO             : protocollo.id
                                                                          , REV                    : rev
                                                                          , REVTYPE                : revtype
                                                                          , ID_DOCUMENTO_ESTERNO   : protocollo.idDocumentoEsterno
                                                                          , ID_ENGINE_ITER         : protocollo.iter?.id
                                                                          , TIPO_OGGETTO           : protocollo.tipoOggetto?.codice
                                                                          , FILE_DOCUMENTI_MOD     : testoPrincipaleModificato ? 1 : 0
                                                                          , DOCUMENTI_COLLEGATI_MOD: allegatiModificati ? 1 : 0
                                                                          , DATA_INS               : protocollo.dateCreated
                                                                          , DATA_UPD               : storico.dateCreated
                                                                          , VALIDO                 : protocollo.valido ? 'Y' : 'N'
                                                                          , UTENTE_INS             : protocollo.utenteIns.id
                                                                          , UTENTE_UPD             : storico.utenteIns.id
                                                                          , ID_ENTE                : protocollo.ente.id],
                                                     AGP_PROTOCOLLI_LOG: [ID_DOCUMENTO        : protocollo.id
                                                                          , REV               : rev
                                                                          , ANNO              : getAnno(json.numero?._dataModifica)
                                                                          , DATA              : parseDate(json.numero?._dataModifica)
                                                                          , MOVIMENTO         : json.movimento?._value
                                                                          , CORRISPONDENTI_MOD: corrispondentiModificati ? 1 : 0
                                                                          , NOTE              : json.note
                                                                          , NOTE_TRASMISSIONE : json.noteTrasmissione
                                                                          , TIPO_REGISTRO     : protocollo.tipoProtocollo?.codice
                                                                          , NUMERO            : json.numero?._value
                                                                          , OGGETTO           : json.oggetto?._value
                                                                          , ID_CLASSIFICAZIONE: json.classificazione?._key
                                                                          , ID_FASCICOLO      : json.fascicolo?._key]], revtype)
    }

    private void insertFilePrincipaleLog(Protocollo protocollo, DocumentoStorico storico, def testoPrincipale, long rev, int revtype) {
        FileDocumento filePrincipale = protocollo.filePrincipale
        protocolloStoricoTrascoRepository.insertLog("GDO_FILE_DOCUMENTO_LOG", [ID_FILE_DOCUMENTO  : testoPrincipale._key
                                                                               , CODICE           : FileDocumento.CODICE_FILE_PRINCIPALE
                                                                               , DATA_INS         : filePrincipale?.dateCreated ?: storico.dateCreated
                                                                               , DATA_UPD         : storico.dateCreated
                                                                               , ID_DOCUMENTO     : protocollo.id
                                                                               , ID_FILE_ESTERNO  : testoPrincipale._idFileEsterno
                                                                               , NOME             : testoPrincipale._value
                                                                               , REV              : rev
                                                                               , REVISIONE_STORICO: protocolloStoricoTrascoRepository.getIdLog(storico)
                                                                               , REVTYPE          : revtype
                                                                               , UTENTE_INS       : storico.utenteIns.id
                                                                               , UTENTE_UPD       : storico.utenteUpd.id], revtype)
    }

    private void insertFileAllegatoLog(Allegato allegato, DocumentoStorico storico, Map file, long rev, int revtype) {
        protocolloStoricoTrascoRepository.insertLog("GDO_FILE_DOCUMENTO_LOG", [ID_FILE_DOCUMENTO  : file.id
                                                                               , CODICE           : FileDocumento.CODICE_FILE_ALLEGATO
                                                                               , DATA_INS         : storico.dateCreated
                                                                               , DATA_UPD         : storico.dateCreated
                                                                               , ID_DOCUMENTO     : allegato.id
                                                                               , ID_FILE_ESTERNO  : file.idFileEsterno
                                                                               , NOME             : file.nome
                                                                               , REV              : rev
                                                                               , REVISIONE_STORICO: protocolloStoricoTrascoRepository.getIdLog(storico)
                                                                               , REVTYPE          : file.TIPO_STORICO
                                                                               , UTENTE_INS       : storico.utenteIns.id
                                                                               , UTENTE_UPD       : storico.utenteUpd.id], revtype)
    }

    private void insertCorrispondentiLog(Protocollo protocollo, DocumentoStorico storico, List<DatoStorico> datiModificati, long rev, int revtype) {
        // per ogni destinatario aggiunto / modificato / cancellato:
        List<DatoStorico> corrispondentiModificati = datiModificati.findAll { it.campo == "destinatari._value" }

        for (DatoStorico storicoCorrispondente : corrispondentiModificati) {
            revtype = getRevisionType(storicoCorrispondente.tipoStorico)

            protocolloStoricoTrascoRepository.insertLog("AGP_PROTOCOLLI_CORR_LOG", [ID_PROTOCOLLO_CORRISPONDENTE: storicoCorrispondente.dati._key
                                                                                    , REV                       : rev
                                                                                    , REVTYPE                   : revtype
                                                                                    , DENOMINAZIONE             : storicoCorrispondente.dati._value
                                                                                    , ID_DOCUMENTO              : protocollo.id
                                                                                    , DATA_INS                  : storico.dateCreated
                                                                                    , DATA_UPD                  : storico.lastUpdated
                                                                                    , UTENTE_INS                : storico.utenteIns.id
                                                                                    , UTENTE_UPD                : storico.utenteUpd.id], revtype)
        }
    }

    private void insertAllegatiLog(DocumentoStorico storico, List<DatoStorico> datiModificati, def json, long rev, int revtype) {
        // per ogni destinatario aggiunto / modificato / cancellato:
        List<Map> allegatiModificati = getDatiModificatiAllegati(datiModificati, json)

        for (Map allegato : allegatiModificati) {

            // se non ho più l'allegato o il documentoCollegato, non storicizzo niente (gli allegati non vengono eliminati ma resi "non validi") per cui questo dovrebbe essere un errore presente solo in sviluppo:
            Allegato alle = protocolloStoricoTrascoRepository.getAllegato(allegato.id)
            if (alle == null) {
                continue
            }
            DocumentoCollegato documentoCollegato = protocolloStoricoTrascoRepository.getDocumentoCollegato(allegato.id)
            if (documentoCollegato == null) {
                continue
            }

            // TIPO_STORICO == null significa che è stato solo aggiunto / eliminato un file.
            // TIPO_STORICO != null significa che è stato modificato Allegato.
            long alleRevType = allegato.TIPO_STORICO == RevisionType.ADD.ordinal() ? RevisionType.ADD.ordinal() : RevisionType.MOD.ordinal()

            protocolloStoricoTrascoRepository.insertLog([GDO_DOCUMENTI_LOG: [ID_DOCUMENTO          : alle.id
                                                                             , REV                 : rev
                                                                             , REVTYPE             : alleRevType // un allegato viene solo aggiunto o modificato. non viene mai eliminato (viene solo messo come "non valido")
                                                                             , ID_DOCUMENTO_ESTERNO: alle.idDocumentoEsterno
                                                                             , TIPO_OGGETTO        : alle.tipoOggetto?.codice
                                                                             , RISERVATO           : allegato.riservato
                                                                             , VALIDO              : allegato.valido
                                                                             , DATA_INS            : alle.dateCreated
                                                                             , DATA_UPD            : storico.dateCreated
                                                                             , UTENTE_INS          : alle.utenteIns.id
                                                                             , UTENTE_UPD          : storico.utenteIns.id
                                                                             , ID_ENTE             : alle.ente.id],
                                                         GDO_ALLEGATI_LOG : [ID_DOCUMENTO : allegato.id
                                                                             , DESCRIZIONE: allegato.descrizione
                                                                             , REV        : rev]], alleRevType)

            // un allegato non viene mai "eliminato" ma solo reso "non valido". Quindi in fase di ADD è certamente "valido":
            if (allegato.TIPO_STORICO == RevisionType.ADD.ordinal()) {
                // ricreo il record di collegamento:
                // non avendo lo storico di questo record, lo ricreo usando la versione attuale presente su db.
                // questa dovrebbe comunque essere una approssimazione sufficiente in quanto il documentoCollegato viene solo creato e mai modificato se non quando viene reso "non valido"
                protocolloStoricoTrascoRepository.insertLog("GDO_DOCUMENTI_COLLEGATI_LOG", [ID_DOCUMENTO_COLLEGATO: documentoCollegato.id
                                                                                            , REV                 : rev
                                                                                            , REVTYPE             : RevisionType.ADD.ordinal()
                                                                                            , DATA_INS            : documentoCollegato.dateCreated
                                                                                            , DATA_UPD            : storico.lastUpdated
                                                                                            , VALIDO              : 'Y'
                                                                                            , UTENTE_INS          : documentoCollegato.utenteIns.id
                                                                                            , UTENTE_UPD          : storico.utenteUpd.id
                                                                                            , ID_COLLEGATO        : allegato.id
                                                                                            , ID_DOCUMENTO        : storico.documento.id
                                                                                            , ID_TIPO_COLLEGAMENTO: documentoCollegato.tipoCollegamento.id], RevisionType.ADD.ordinal())
            }

            // se sto cancellando un allegato, in realtà questo viene solo messo come "non valido" e non realmente cancellato
            if (allegato.TIPO_STORICO == RevisionType.DEL.ordinal()) {
                protocolloStoricoTrascoRepository.insertLog("GDO_DOCUMENTI_COLLEGATI_LOG", [ID_DOCUMENTO_COLLEGATO: documentoCollegato.id
                                                                                            , REV                 : rev
                                                                                            , REVTYPE             : RevisionType.MOD.ordinal()
                                                                                            , DATA_INS            : documentoCollegato.dateCreated
                                                                                            , DATA_UPD            : storico.lastUpdated
                                                                                            , VALIDO              : 'N'
                                                                                            , UTENTE_INS          : documentoCollegato.utenteIns.id
                                                                                            , UTENTE_UPD          : storico.utenteUpd.id
                                                                                            , ID_COLLEGATO        : allegato.id
                                                                                            , ID_DOCUMENTO        : documentoCollegato.documento.id
                                                                                            , ID_TIPO_COLLEGAMENTO: documentoCollegato.tipoCollegamento.id], RevisionType.MOD.ordinal())
            }

            if (allegato.file?.size() > 0) {
                for (Map file : allegato.file) {
                    insertFileAllegatoLog(alle, storico, file, rev, revtype)
                }
            }
        }
    }

    private Integer getAnno(String jsonDate) {
        Date date = parseDate(jsonDate)
        if (date == null) {
            return null
        }
        Calendar calendar = Calendar.getInstance()
        calendar.setTime(date)
        return calendar.get(Calendar.YEAR)
    }

    private Date parseDate(String jsonDate) {
        if (jsonDate == null) {
            return null
        }

        if (jsonDate.trim().length() == 0) {
            return null
        }

        return Date.parse("yyyy-MM-dd'T'HH:mm:ssZ", jsonDate)
    }

    private List<Map> getDatiModificatiAllegati(List<DatoStorico> datiModificati, def json) {
        List<Map> allegati = []
        Map allegato = null

        for (DatoStorico datoStorico : datiModificati) {
            if (datoStorico.campo == "allegati._value") {
                if (datoStorico.dati._key != null) {
                    allegato = [:]
                    allegati << allegato
                    allegato.id = datoStorico.dati._key
                    allegato.descrizione = datoStorico.dati._value
                    allegato.TIPO_STORICO = getRevisionType(datoStorico.tipoStorico)
                    allegato.valido = (allegato.TIPO_STORICO == RevisionType.DEL.ordinal()) ? 'N' : 'Y'
                }
            }

            if (datoStorico.campo == "allegati.riservato") {
                if (allegato == null) {
                    allegato = [:]
                }
                allegato.riservato = (datoStorico.valoreNuovo == "Si") ? 'Y' : 'N'
            }

            if (datoStorico.campo == "allegati.file._value") {
                if (allegato == null) {
                    allegato = [:]
                    allegati << allegato

                    allegato.TIPO_STORICO = RevisionType.MOD.ordinal()
                    allegato.valido = 'Y'
                }

                if (allegato.id == null) {
                    // in questo caso, non ho nessun record "allegati._value" ma ho solo i record
                    // di modifica del file. Devo quindi recuperare l'id dell'allegato:
                    allegato.id = protocolloStoricoTrascoRepository.getIdAllegato(datoStorico.dati._idDocumentoEsterno)
                }

                if (allegato.file == null) {
                    allegato.file = []
                }

                if (allegato.riservato == null || allegato.descrizione == null) {
                    // prendo gli altri dati dalla "fotografia" dell'allegato:
                    def a = json.allegati.find { it._key == allegato.id }

                    // se non trovo l'id è perché è stato cancellato l'allegato.
                    if (a != null) {
                        allegato.riservato = (a.riservato == "Si") ? 'Y' : 'N'
                        allegato.descrizione = (a._value)
                    } else {
                        allegato.TIPO_STORICO = RevisionType.DEL.ordinal()
                    }
                }

                Map file = [:]
                allegato.file << file

                file.TIPO_STORICO = getRevisionType(datoStorico.tipoStorico)
                file.id = datoStorico.dati._key
                file.nome = datoStorico.dati._value
                file.idFileEsterno = datoStorico.dati._idFileEsterno
                file.idDocumento = allegato.id
                file.idDocumentoEsterno = datoStorico.dati._idDocumentoEsterno
            }
        }

        return allegati
    }

    private List<DatoStorico> parseDatiModificati(String datiModificati) {
        if (datiModificati?.length() > 0) {
            List datiStorici = new JsonSlurper().parseText(datiModificati)
            return datiStorici.collect { new DatoStorico(it) }
        }

        return []
    }

    private int getRevisionType(TipoStorico tipoStorico) {
        switch (tipoStorico) {
            case TipoStorico.AGGIUNTO:
                return RevisionType.ADD.ordinal()
            case TipoStorico.MODIFICATO:
                return RevisionType.MOD.ordinal()
            case TipoStorico.CANCELLATO:
                return RevisionType.DEL.ordinal()
        }
    }
}
