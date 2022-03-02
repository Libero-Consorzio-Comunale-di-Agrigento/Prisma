package it.finmatica.protocollo.documenti

import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.storico.DocumentoStorico
import it.finmatica.gestioneiter.motore.WkfIter
import it.finmatica.gestioneiter.motore.WkfStep
import org.hibernate.Session
import org.hibernate.envers.RevisionType
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

import javax.persistence.EntityManager
import javax.persistence.NoResultException
import javax.sql.DataSource
import java.sql.SQLException

@Slf4j
@CompileStatic
@Repository
@Transactional
class ProtocolloStoricoTrascoRepository {

    private final DataSource dataSource_gdm
    private final DataSource dataSource
    private final EntityManager entityManager

    ProtocolloStoricoTrascoRepository(@Qualifier("dataSource_gdm") DataSource dataSource_gdm, DataSource dataSource, EntityManager entityManager) {
        this.dataSource_gdm = dataSource_gdm
        this.dataSource = dataSource
        this.entityManager = entityManager
    }

    long getNextRevision(Date revisionDate) {
        long nextRevision = ((Number) new Sql(dataSource).firstRow("select hibernate_sequence.nextval VAL from dual").VAL).longValue()

        insertRevision("REVINFO", [REV: nextRevision, REVTSTMP: revisionDate])

        return nextRevision
    }

    long getIdLog(DocumentoStorico storico) {
        Sql sql = new Sql(dataSource_gdm)
        // ottengo l'id log corrispondente al n. di versione:
        GroovyRowResult result = sql.firstRow("""select l.ID_LOG
            from ACTIVITY_LOG l
            where l.ID_DOCUMENTO = :id_documento
        and l.VERSIONE = :versione or l.ID_LOG = :versione""", [id_documento: storico.documento.idDocumentoEsterno, versione: storico.revisione])
        long idLog = ((Number) result?.ID_LOG)?.longValue() ?: -1
        if (idLog == -1) {
            log.warn("PROBLEMA DI TRASCODIFICA: NON HO TROVATO IL LOG SU GDM.ACTIVITY_LOG PER ID_DOCUMENTO = ${storico.documento.idDocumentoEsterno} e versione/id_log=${storico.revisione}")
        }

        return idLog
    }

    void insertLog(LinkedHashMap<String, LinkedHashMap<String, Object>> tables, long revtype) {
        // se ho un revtype di tipo ADD o DELETE, creo la riga di log:
        if (revtype == RevisionType.ADD.ordinal() || revtype == RevisionType.DEL.ordinal()) {
            for (Map.Entry<String, LinkedHashMap<String, Object>> entry : tables) {
                insertLog(entry.key, entry.value, revtype)
            }
        } else {
            boolean ciSonoCampiModificati = false
            // per ogni tabella verifico se ci sono campi modificati e se si, creo una riga.
            for (Map.Entry<String, LinkedHashMap<String, Object>> entry : tables) {
                ciSonoCampiModificati = ciSonoCampiModificati || isCampiModificati(entry.key, entry.value)
            }

            for (Map.Entry<String, LinkedHashMap<String, Object>> entry : tables) {
                insertLog(entry.key, entry.value, revtype, ciSonoCampiModificati)
            }
        }
    }

    boolean insertLog(String tableName, LinkedHashMap<String, Object> campi, long revtype, boolean ciSonoCampiModificati) {
        // se non ci sono campi modificati e sono in update, non devo fare nulla.
        if (revtype == RevisionType.MOD.ordinal() && !ciSonoCampiModificati) {

            // ritorno false per indicare che non ho fatto alcuna modifica.
            return false
        }

        // ottengo i dati dell'ultima riga di storico:
        Map<String, Object> ultimiValori = getCampiAttuali(tableName, campi.entrySet().first().getKey(), campi)

        // mappa dei campi con anche i relativi campi_mod:
        Map<String, Object> campiConMod = (Map<String, Object>) campi.collectEntries { [(it.key): it.value] }

        boolean primoCampo = true
        // per ogni valore diverso, imposto anche il relativo campo "_MOD"
        for (Map.Entry<String, Object> campo : campi) {
            // salto il primo campo perché è la "chiave" della tabella:
            if (primoCampo) {
                primoCampo = false
                continue
            }

            String campoMod = getCampoMod(tableName, campo.key)
            if (campoMod != null) {
                // se sono in ADD, il valore del campo_MOD è sempre FALSE
                if (revtype == RevisionType.ADD.ordinal()) {
                    campiConMod[campoMod] = 0
                } else if (campo.value != ultimiValori[campo.key]) {
                    campiConMod[campoMod] = 1
                } else {
                    campiConMod[campoMod] = 0
                }
            }
        }

        // eseguo la update solo se ho dei campi modificati
        updateRevision(tableName, campi)

        // inserisco la nuova riga di storico
        insertRevision(tableName, campiConMod)

        // ritorno true per indicare che ho aggiunto delle righe di storico.
        return true
    }

    boolean insertLog(String tableName, LinkedHashMap<String, Object> campi, long revtype) {
        return insertLog(tableName, campi, revtype, isCampiModificati(tableName, campi))
    }

    private String getCampoMod(String tableName, String nomeCampo) {
        // posso settare direttamente dei campi _MOD (quelli delle collection) per cui li ignoro (sono già gestiti come fossero campi "normali")
        if (nomeCampo.endsWith("_MOD")) {
            return null
        }
        // ignoro i campi di default
        switch (nomeCampo.toUpperCase()) {
            case 'REV':
            case 'REVTYPE':
            case 'REVEND':
                return null
            case 'DATA_UPD':
                return 'LAST_UPDATED_MOD'
            case 'DATA_INS':
                return 'DATE_CREATED_MOD'
            case 'ID_ENTE':
                return 'ENTE_MOD'
            case 'ID_ENGINE_ITER':
                return 'ITER_MOD'
            case 'ID_FASCICOLO':
                return 'FASCICOLO_MOD'
            case 'ID_CLASSIFICAZIONE':
                return 'CLASSIFICAZIONE_MOD'
            case 'ID_SCHEMA_PROTOCOLLO':
                return 'SCHEMA_PROTOCOLLO_MOD'
            case 'ID_TIPO_PROTOCOLLO':
                return 'TIPO_PROTOCOLLO_MOD'
            case 'ID_MODALITA_INVIO_RICEZIONE':
                return 'MODALITA_INVIO_RICEZIONE_MOD'
            case 'ID_STEP_CORRENTE':
                return 'STEP_CORRENTE_MOD'
            case 'ID_CFG_ITER':
                return 'CFG_ITER_MOD'
            case 'ID_DOCUMENTO':
                if (tableName.toUpperCase() == 'AGP_PROTOCOLLI_CORR_LOG') {
                    return null
                }
                return 'DOCUMENTO_MOD'
            case 'ID_MODELLO_TESTO':
                return 'MODELLO_TESTO_MOD'
            case 'FILE_ORIGINALE_ID':
                return 'FILE_ORIGINALE_MOD'
            case 'REVISIONE_STORICO':
                return 'REVISIONE_MOD'
            case 'ID_TIPO_COLLEGAMENTO':
                return 'TIPO_COLLEGAMENTO_MOD'
            case 'ID_COLLEGATO':
                return 'COLLEGATO_MOD'
            default:
                return nomeCampo + '_MOD'
        }
    }

    WkfStep getWkfStep(long idStep) {
        return entityManager.find(WkfStep, idStep)
    }

    WkfStep getFirstWkfStep(WkfIter iter) {
        List<WkfStep> stepList = entityManager.createQuery("select s from WkfStep s where s.iter.id = :idIter order by s.id asc", WkfStep).setParameter("idIter", iter.id).getResultList()
        if (stepList.size() > 0) {
            return stepList[0]
        }
        return null
    }

    boolean isCampiModificati(String tableName, LinkedHashMap campi) {
        Sql sql = new Sql(dataSource)
        // escludo le data di insert/update dalla verifica dei campi
        Map campiNoUpdate = toSqlTypes(campi)
        campiNoUpdate.remove('DATA_INS')
        campiNoUpdate.remove('DATA_UPD')
        campiNoUpdate.remove('REV')
        campiNoUpdate.remove('REVTYPE')

        String sqlString = "select count(1) COUNT from ${tableName} where ${campiNoUpdate.collect { entry -> "${entry.key} = :${entry.key}" }.join(" and ")}"
        if (campi.containsKey('REVTYPE')) {
            sqlString += " and REVEND is null"
        }
        return sql.firstRow(sqlString, campiNoUpdate).COUNT == 0
    }

    private Map<String, Object> getCampiAttuali(String tableName, String key, LinkedHashMap campi) {
        Sql sql = new Sql(dataSource)
        // escludo le data di insert/update dalla verifica dei campi
        Map<String, Object> campiNoUpdate = toSqlTypes(campi)
        campiNoUpdate.remove('DATA_INS')
        campiNoUpdate.remove('DATA_UPD')
        campiNoUpdate.remove('REV')
        campiNoUpdate.remove('REVTYPE')

        Long maxRev = (Long) (sql.firstRow("select max(rev) MAX_REV from ${tableName} where ${key} = :${key}", [(key): campiNoUpdate[key]])?.MAX_REV ?: 0)

        if (maxRev == 0) {
            return new HashMap<String, Object>()
        }

        String sqlString = "select ${campiNoUpdate.keySet().join(", ")} from ${tableName} where ${key} = :${key} and rev = :rev"
        return (Map<String, Object>) sql.firstRow(sqlString, [(key): campiNoUpdate[key], rev: maxRev]).collectEntries {
            [(it.key): it.value]
        }
    }

    private void updateRevision(String tableName, LinkedHashMap campi) {
        if (campi.containsKey('REVTYPE')) {
            Sql sql = new Sql(dataSource)
            String idColumn = campi.entrySet().first().getKey()
            String sqlString = "update ${tableName} set REVEND = :rev where ${idColumn} = :id and REVEND is null".toString()
            sql.executeUpdate(sqlString, [rev: campi.REV, id: campi[idColumn]])
        }
    }

    private void insertRevision(String tableName, Map campi) {
        Sql sql = new Sql(dataSource)
        String sqlString = "insert into ${tableName} (${campi.keySet().join(", ")}) values (${campi.keySet().collect { ":${it}" }.join(", ")})".toString()
        try {
            log.debug("Eseguo la insert: {}", sqlString)
            sql.executeInsert(sqlString, toSqlTypes(campi))
        } catch (SQLException e) {
            log.error("Errore nell'eseguire la insert: {}", sqlString)

            throw new RuntimeException(e)
        }
    }

    private Map<String, Object> toSqlTypes(Map<String, Object> campi) {
        return (Map<String, Object>) campi.collectEntries { String key, Object value ->
            if (value instanceof Date) {
                return [(key): new java.sql.Timestamp(value.time)]
            }
            return [(key): value]
        }
    }

    Allegato getAllegato(long idAllegato) {
        return entityManager.find(Allegato, idAllegato)
    }

    DocumentoCollegato getDocumentoCollegato(long idAllegato) {
        // questa query deve poter ritornare anche i documenticollegati non più validi, quindi disabilito il filtro automatico sui non validi:
        Session session = entityManager.unwrap(Session)
        session.disableFilter(AbstractDomain.SOLO_VALIDI_FILTER)
        try {
            return entityManager.createQuery("select d from DocumentoCollegato d where d.collegato.id = :idAllegato and d.tipoCollegamento.codice = :codiceCollegamento", DocumentoCollegato)
                    .setParameter("idAllegato", idAllegato)
                    .setParameter("codiceCollegamento", Allegato.CODICE_TIPO_COLLEGAMENTO)
                    .getSingleResult()
        } catch (NoResultException e) {
            return null
        } finally {
            session.enableFilter(AbstractDomain.SOLO_VALIDI_FILTER)
        }
    }

    long getIdAllegato(long idDocumentoEsterno) {
        // questa query deve poter ritornare anche i documenticollegati non più validi, quindi disabilito il filtro automatico sui non validi:
        Session session = entityManager.unwrap(Session)
        session.disableFilter(AbstractDomain.SOLO_VALIDI_FILTER)
        try {
            return entityManager.createQuery("select a from Allegato a where a.idDocumentoEsterno = :idDocumentoEsterno", Allegato)
                    .setParameter("idDocumentoEsterno", idDocumentoEsterno)
                    .getSingleResult().id
        } finally {
            session.enableFilter(AbstractDomain.SOLO_VALIDI_FILTER)
        }
    }

    @CompileDynamic
    List<Map> getIdDocumentiDaTrascodificare(long idEnte) {
        entityManager.createNativeQuery("""select ID_PROTOCOLLO, DOCUMENTI_STORICI, PROTOCOLLI_LOG
  from (
select p.id_documento id_protocollo
     , (select count(1) from gdo_documenti_storico ds where ds.id_documento = p.id_documento and ds.stato_trascodifica is null) documenti_storici
     , (select count(1) from agp_protocolli_log pl where pl.id_documento = p.id_documento) protocolli_log
  from agp_protocolli p
     , gdo_documenti d
 where p.id_documento = d.id_documento
   and d.id_ente = :idEnte
 order by d.data_ins asc) t where t.protocolli_log = 0""").setParameter("idEnte", idEnte).getResultList().collect {
            [ID_PROTOCOLLO: it[0], DOCUMENTI_STORICI: it[1], PROTOCOLLI_LOG: it[2]]
        }
    }

    DocumentoStorico getDocumentoStoricoPerIdDocumento(long idDocumento) {
        return entityManager.createQuery("select d from DocumentoStorico d where d.documento.id = :idDocumento order by d.dateCreated asc", DocumentoStorico).setParameter("idDocumento", idDocumento).getResultList()[0]
    }
}
