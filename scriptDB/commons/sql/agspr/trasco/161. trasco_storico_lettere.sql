--liquibase formatted sql
--changeset mmalferrari:trasco_storico_lettere runOnChange:true stripComments:false
CREATE OR REPLACE PROCEDURE sistema_record_storici
IS
   d_id_revisione   NUMBER;
BEGIN
   BEGIN
      FOR i
         IN (SELECT *
               FROM wkf_engine_iter
              WHERE NOT EXISTS
                       (SELECT 1
                          FROM wkf_engine_iter_log
                         WHERE id_engine_iter =
                                  wkf_engine_iter.id_engine_iter))
      LOOP
         d_id_revisione :=
            agp_trasco_pkg.crea_revinfo (
               TO_TIMESTAMP (SYSDATE, 'DD/MM/YYYY HH24:MI:SS,FF'));

         INSERT INTO WKF_ENGINE_ITER_LOG (ID_ENGINE_ITER,
                                          REV,
                                          REVTYPE,
                                          DATA_FINE,
                                          DATA_INIZIO,
                                          DATA_INS,
                                          DATA_UPD,
                                          ID_CFG_ITER,
                                          ENTE,
                                          ID_STEP_CORRENTE,
                                          UTENTE_INS,
                                          UTENTE_UPD)
              VALUES (i.ID_ENGINE_ITER,
                      d_id_revisione,
                      0,
                      i.DATA_FINE,
                      i.DATA_INIZIO,
                      i.DATA_INS,
                      i.DATA_UPD,
                      i.ID_CFG_ITER,
                      i.ENTE,
                      i.ID_STEP_CORRENTE,
                      i.UTENTE_INS,
                      i.UTENTE_UPD);
      END LOOP;

      COMMIT;
   END;

   BEGIN
      FOR c
         IN (SELECT *
               FROM GDO_DOCUMENTI
              WHERE     NOT EXISTS
                           (SELECT 1
                              FROM GDO_DOCUMENTI_LOG
                             WHERE ID_DOCUMENTO = GDO_DOCUMENTI.ID_DOCUMENTO)
                    AND id_documento IN (SELECT id_documento
                                           FROM agp_protocolli
                                          WHERE idrif IS NOT NULL
                                         UNION
                                         SELECT a.id_documento
                                           FROM gdo_allegati a,
                                                gdo_documenti_collegati c
                                          WHERE     c.id_collegato =
                                                       A.ID_DOCUMENTO
                                                AND c.id_documento IN (SELECT ID_DOCUMENTO
                                                                         FROM agp_protocolli
                                                                        WHERE idrif
                                                                                 IS NOT NULL)))
      LOOP
         d_id_revisione :=
            agp_trasco_pkg.crea_revinfo (
               TO_TIMESTAMP (SYSDATE, 'DD/MM/YYYY HH24:MI:SS,FF'));

         INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                        REV,
                                        REVTYPE,
                                        DATA_INS,
                                        DATE_CREATED_MOD,
                                        DATA_UPD,
                                        VALIDO,
                                        ID_DOCUMENTO_ESTERNO,
                                        RISERVATO,
                                        RISERVATO_MOD,
                                        STATO,
                                        STATO_CONSERVAZIONE,
                                        STATO_FIRMA,
                                        UTENTE_INS,
                                        UTENTE_UPD,
                                        ID_ENTE,
                                        ID_ENGINE_ITER,
                                        TIPO_OGGETTO)
              VALUES (c.id_documento,
                      d_id_revisione,
                      0,
                      c.data_ins,
                      1,
                      c.data_upd,
                      c.valido,
                      c.id_documento_esterno,
                      c.RISERVATO,
                      0,
                      c.STATO,
                      c.STATO_CONSERVAZIONE,
                      c.STATO_FIRMA,
                      c.utente_ins,
                      c.utente_upd,
                      c.ID_ENTE,
                      c.ID_ENGINE_ITER,
                      c.TIPO_OGGETTO);
      END LOOP;

      COMMIT;
   END;

   BEGIN
      FOR c
         IN (SELECT ID_DOCUMENTO_COLLEGATO,
                    data_ins,
                    VALIDO,
                    utente_ins,
                    id_collegato,
                    id_documento,
                    ID_TIPO_COLLEGAMENTO
               FROM GDO_DOCUMENTI_COLLEGATI
              WHERE NOT EXISTS
                       (SELECT 1
                          FROM gdo_documenti_collegati_log
                         WHERE id_documento_collegato =
                                  gdo_documenti_collegati.id_documento_collegato))
      LOOP
         d_id_revisione :=
            agp_trasco_pkg.crea_revinfo (
               TO_TIMESTAMP (SYSDATE, 'DD/MM/YYYY HH24:MI:SS,FF'));

         INSERT INTO GDO_DOCUMENTI_COLLEGATI_LOG (ID_DOCUMENTO_COLLEGATO,
                                                  REV,
                                                  REVTYPE,
                                                  DATA_INS,
                                                  DATA_UPD,
                                                  VALIDO,
                                                  UTENTE_INS,
                                                  UTENTE_UPD,
                                                  ID_COLLEGATO,
                                                  ID_DOCUMENTO,
                                                  ID_TIPO_COLLEGAMENTO)
              VALUES (c.ID_DOCUMENTO_COLLEGATO,
                      d_id_revisione,
                      0,
                      c.data_ins,
                      c.data_ins,
                      c.VALIDO,
                      c.utente_ins,
                      c.utente_ins,
                      c.id_collegato,
                      c.id_documento,
                      c.ID_TIPO_COLLEGAMENTO);
      END LOOP;

      COMMIT;
   END;

   BEGIN
      FOR c
         IN (SELECT *
               FROM GDO_FILE_DOCUMENTO
              WHERE     NOT EXISTS
                           (SELECT 1
                              FROM GDO_FILE_DOCUMENTO_LOG
                             WHERE id_FILE_DOCUMENTo =
                                      GDO_FILE_DOCUMENTO.id_FILE_DOCUMENTo)
                    AND id_documento IN (SELECT id_documento
                                           FROM agp_protocolli
                                          WHERE idrif IS NOT NULL
                                         UNION
                                         SELECT a.id_documento
                                           FROM gdo_allegati a,
                                                gdo_documenti_collegati c
                                          WHERE     c.id_collegato =
                                                       A.ID_DOCUMENTO
                                                AND c.id_documento IN (SELECT ID_DOCUMENTO
                                                                         FROM agp_protocolli
                                                                        WHERE idrif
                                                                                 IS NOT NULL)))
      LOOP
         d_id_revisione :=
            agp_trasco_pkg.crea_revinfo (
               TO_TIMESTAMP (SYSDATE, 'DD/MM/YYYY HH24:MI:SS,FF'));

         INSERT INTO GDO_FILE_DOCUMENTO_LOG (id_file_documento,
                                             rev,
                                             revtype,
                                             data_ins,
                                             date_created_mod,
                                             data_upd,
                                             last_updated_mod,
                                             valido,
                                             valido_mod,
                                             codice,
                                             codice_mod,
                                             content_type,
                                             content_type_mod,
                                             dimensione,
                                             dimensione_mod,
                                             firmato,
                                             firmato_mod,
                                             id_file_esterno,
                                             id_file_esterno_mod,
                                             modificabile,
                                             modificabile_mod,
                                             nome,
                                             nome_mod,
                                             sequenza,
                                             sequenza_mod,
                                             utente_ins,
                                             utente_ins_mod,
                                             utente_upd,
                                             utente_upd_mod,
                                             id_documento,
                                             documento_mod,
                                             revisione_storico,
                                             revisione_mod)
            SELECT c.id_file_documento,
                   d_id_revisione,
                   0,
                   c.data_ins,
                   1,
                   c.data_upd,
                   1,
                   c.valido,
                   1,
                   c.codice,
                   1,
                   c.content_type,
                   1,
                   c.dimensione,
                   1,
                   c.firmato,
                   1,
                   c.id_file_esterno,
                   1 id_file_esterno_mod,
                   c.modificabile,
                   1,
                   c.nome,
                   1,
                   c.sequenza,
                   1,
                   c.utente_ins,
                   1,
                   c.utente_upd,
                   1,
                   c.id_documento,
                   1,
                   NULL,
                   1
              FROM DUAL;
      END LOOP;

      COMMIT;
   END;

   BEGIN
      FOR c
         IN (SELECT *
               FROM AGP_PROTOCOLLI
              WHERE     IDRIF IS NOT NULL
                    AND NOT EXISTS
                           (SELECT 1
                              FROM AGP_PROTOCOLLI_LOG
                             WHERE id_DOCUMENTo = AGP_PROTOCOLLI.id_DOCUMENTo))
      LOOP
         SELECT MAX (rev)
           INTO d_id_revisione
           FROM gdo_documenti_log
          WHERE id_documento = c.id_documento;

         DBMS_OUTPUT.put_line (c.id_documento || ' ' || d_id_revisione);

         INSERT INTO AGP_PROTOCOLLI_LOG (id_documento,
                                         rev,
                                         anno,
                                         data,
                                         idrif,
                                         numero,
                                         tipo_registro)
              VALUES (c.id_documento,
                      d_id_revisione,
                      c.anno,
                      c.data,
                      c.idrif,
                      c.numero,
                      c.tipo_registro);
      END LOOP;

      COMMIT;
   END;

   BEGIN
      FOR c
         IN (SELECT *
               FROM GDO_ALLEGATI
              WHERE     NOT EXISTS
                           (SELECT 1
                              FROM GDO_ALLEGATI_LOG
                             WHERE id_DOCUMENTo = GDO_ALLEGATI.id_DOCUMENTo)
                    AND id_documento IN (SELECT c.id_collegato
                                           FROM gdo_documenti_collegati c
                                          WHERE c.id_documento IN (SELECT ID_DOCUMENTO
                                                                     FROM agp_protocolli
                                                                    WHERE idrif
                                                                             IS NOT NULL)))
      LOOP
         SELECT MAX (rev)
           INTO d_id_revisione
           FROM gdo_documenti_log
          WHERE id_documento = c.id_documento;

         DBMS_OUTPUT.put_line (c.id_documento || ' ' || d_id_revisione);

         INSERT INTO GDO_ALLEGATI_LOG (ID_DOCUMENTO,
                                       REV,
                                       COMMENTO,
                                       COMMENTO_MOD,
                                       DESCRIZIONE,
                                       DESCRIZIONE_MOD,
                                       NUM_PAGINE,
                                       NUM_PAGINE_MOD,
                                       QUANTITA,
                                       QUANTITA_MOD,
                                       UBICAZIONE,
                                       UBICAZIONE_MOD)
              VALUES (c.id_documento,
                      d_id_revisione,
                      c.COMMENTO,
                      0,
                      c.DESCRIZIONE,
                      0,
                      c.NUM_PAGINE,
                      0,
                      c.QUANTITA,
                      0,
                      c.UBICAZIONE,
                      0);
      END LOOP;

      COMMIT;
   END;

   BEGIN
      FOR c
         IN (SELECT *
               FROM AGP_PROTOCOLLI_CORRISPONDENTI
              WHERE     NOT EXISTS
                           (SELECT 1
                              FROM AGP_PROTOCOLLI_CORR_LOG
                             WHERE id_PROTOCOLLO_CORRISPONDENTE =
                                      AGP_PROTOCOLLI_CORRISPONDENTI.id_PROTOCOLLO_CORRISPONDENTE)
                    AND id_documento IN (SELECT id_documento
                                           FROM agp_protocolli
                                          WHERE idrif IS NOT NULL))
      LOOP
         d_id_revisione :=
            agp_trasco_pkg.crea_revinfo (
               TO_TIMESTAMP (SYSDATE, 'DD/MM/YYYY HH24:MI:SS,FF'));

         INSERT INTO AGP_PROTOCOLLI_CORR_LOG (ID_PROTOCOLLO_CORRISPONDENTE,
                                              REV,
                                              REVTYPE,
                                              DATA_INS,
                                              DATE_CREATED_MOD,
                                              DATA_UPD,
                                              DENOMINAZIONE,
                                              COGNOME,
                                              NOME,
                                              CONOSCENZA,
                                              DENOMINAZIONE_MOD,
                                              COGNOME_MOD,
                                              NOME_MOD,
                                              CONOSCENZA_MOD,
                                              UTENTE_INS,
                                              UTENTE_UPD,
                                              ID_DOCUMENTO)
              VALUES (c.ID_PROTOCOLLO_CORRISPONDENTE,
                      d_id_revisione,
                      0,
                      c.DATA_INS,
                      0,
                      c.DATA_UPD,
                      c.DENOMINAZIONE,
                      c.COGNOME,
                      c.NOME,
                      c.CONOSCENZA,
                      0,
                      0,
                      0,
                      0,
                      c.UTENTE_INS,
                      c.UTENTE_UPD,
                      c.ID_DOCUMENTO);
      END LOOP;

      COMMIT;
   END;
END;
/

CREATE OR REPLACE PROCEDURE trasco_storico_lettere
IS
   P_ID_DOCUMENTO              NUMBER;
   p_is_finito_aggiornamento   VARCHAR2 (1) := 'N';
BEGIN
   SELECT NVL (valore, 'N')
     INTO p_is_finito_aggiornamento
     FROM gdo_impostazioni
    WHERE codice = 'AGGIORNAMENTO_TERMINATO';

   IF p_is_finito_aggiornamento = 'Y'
   THEN
      -- lettere
      FOR p
         IN (  SELECT d.id_documento_esterno ID_DOCUMENTO
                 FROM agp_protocolli p, gdo_documenti d, agp_tipi_protocollo tp
                WHERE     idrif IS NOT NULL
                      AND tp.id_tipo_protocollo = p.id_tipo_protocollo
                      AND tp.categoria = 'LETTERA'
                      AND anno IS NOT NULL
                      AND numero IS NOT NULL
                      AND NOT EXISTS
                             (SELECT 1
                                FROM gdo_documenti_log pl
                               WHERE     pl.id_documento = p.id_documento
                                     AND PL.UTENTE_INS = 'TRASCO')
                      AND d.id_documento = p.id_documento
             ORDER BY 1)
      LOOP
         BEGIN
            AGP_TRASCO_STORICO_PKG.elimina_storico_documento (P.ID_DOCUMENTO);
            AGP_TRASCO_STORICO_PKG.crea (P.ID_DOCUMENTO);
         END;

         COMMIT;
      END LOOP;

      sistema_record_storici();
   END IF;
END;
/

create or replace procedure attiva_trasco_storico_lettere
is
   X   NUMBER;
BEGIN
   SELECT MIN (job)
     INTO X
     FROM user_jobs
    WHERE what = 'BEGIN trasco_storico_lettere(); END;';

   SYS.DBMS_JOB.BROKEN (job => X, broken => FALSE);
   COMMIT;
END;
/

DECLARE
  X NUMBER;
BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'BEGIN trasco_storico_lettere(); END;'
     ,next_date => sysdate
     ,no_parse  => FALSE
    );
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    SYS.DBMS_JOB.BROKEN
     (job    => X,
      broken => TRUE);
  COMMIT;
END;
/