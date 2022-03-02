--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_154_modelli_upd_r_protocollo_invio_conservazione

DECLARE
   d_istruzioni   CLOB;
BEGIN
   d_istruzioni :=
      '<USER_QUERY>
SELECT ID,
       ti,
       da,
       cr
  FROM (SELECT DISTINCT d.id_documento ID,
                        d.id_tipodoc ti,
                        d.data_aggiornamento da,
                        d.codice_richiesta cr,
                        proto_view.anno,
                        proto_view.numero,
                        proto_view.tipo_registro
          FROM documenti d, proto_conservabili_view proto_view, tipi_documento tido
         WHERE     proto_view.id_documento = d.id_documento
               AND proto_view.MODALITA IN (''INT'', ''ARR'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND (1=0
                    OR NOT EXISTS
                              (SELECT 1
                                 FROM gdm_t_log_conservazione
                                WHERE id_documento_rif = d.id_documento
                                      AND stato_conservazione <> ''FC''))
               AND tido.nome = DECODE (''--'', ''--'', tido.nome, ''--'')
               AND 1 =
                      (SELECT COUNT (filename)
                         FROM oggetti_file ogfi
                        WHERE ogfi.id_documento = d.id_documento
                              AND ogfi.filename <> ''@HIDDENFILENAME'')
               AND proto_view.DATA >=
                      TO_DATE (''@DATA_DAL'', ''dd/mm/yyyy hh24:mi:ss'')
               AND proto_view.DATA <=
                      TO_DATE (''@DATA_AL''||'' 23:59:59'', ''dd/mm/yyyy hh24:mi:ss'')
               AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
               AND proto_view.codice_amministrazione =
                      ''@CODICE_AMMINISTRAZIONE''
               AND ''Y'' = ''@CHECK_ARRIVO_INTERNI''      
               AND proto_view.codice_aoo = ''@CODICE_AOO''        
               AND proto_view.numero is not null
        UNION ALL
    SELECT DISTINCT d.id_documento ID,
                        d.id_tipodoc ti,
                        d.data_aggiornamento da,
                        d.codice_richiesta cr,
                        proto_view.anno,
                        proto_view.numero,
                        proto_view.tipo_registro
          FROM documenti d,
               proto_conservabili_view proto_view,
               tipi_documento tido,
               registro regi
         WHERE ''N'' =
                  (SELECT NVL (MIN (valore), ''N'')
                     FROM registro regi
                    WHERE regi.stringa = ''MOD_SPED_ATTIVO''
                          AND regi.chiave = ''PRODUCT/AGS/AGSpr/SPED'')
               AND NOT EXISTS
                          (SELECT 1
                             FROM seg_soggetti_protocollo sopr,
                                  documenti docu_sopr
                            WHERE docu_sopr.stato_documento NOT IN
                                     (''CA'', ''RE'')
                                  AND docu_sopr.id_documento =
                                         sopr.id_documento
                                  AND sopr.idrif = proto_view.idrif
                                  AND sopr.tipo_rapporto = ''DEST''
                                  AND sopr.documento_tramite IS NOT NULL)
               AND proto_view.id_documento = d.id_documento
               AND ''Y'' = ''@CHECK_PARTENZA_CARTACEA''      
               AND proto_view.modalita = ''PAR''
               AND d.stato_documento NOT IN (''CA'', ''RE'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND (1=0
                    OR NOT EXISTS
                              (SELECT 1
                                 FROM gdm_t_log_conservazione
                                WHERE id_documento_rif = d.id_documento
                                      AND stato_conservazione <> ''FC''))
               AND tido.nome = DECODE (''--'', ''--'', tido.nome, ''--'')
               AND 1 =
                      (SELECT COUNT (filename)
                         FROM oggetti_file ogfi
                        WHERE ogfi.id_documento = d.id_documento
                              AND ogfi.filename <> ''@HIDDENFILENAME'')
               AND proto_view.DATA >=
                      TO_DATE (''@DATA_DAL'', ''dd/mm/yyyy hh24:mi:ss'')
               AND proto_view.DATA <=
                      TO_DATE (''@DATA_AL''||'' 23:59:59'', ''dd/mm/yyyy hh24:mi:ss'')
               AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
               AND proto_view.codice_amministrazione =
                      ''@CODICE_AMMINISTRAZIONE''
               AND proto_view.codice_aoo = ''@CODICE_AOO''
               AND proto_view.numero is not null
    UNION ALL
    SELECT DISTINCT d.id_documento ID,
                        d.id_tipodoc ti,
                        d.data_aggiornamento da,
                        d.codice_richiesta cr,
                        proto_view.anno,
                        proto_view.numero,
                        proto_view.tipo_registro
          FROM documenti d,
               proto_conservabili_view proto_view,
               tipi_documento tido,
               registro regi
         WHERE ''Y'' =
                  (SELECT NVL (MIN (valore), ''N'')
                     FROM registro regi
                    WHERE regi.stringa = ''MOD_SPED_ATTIVO''
                          AND regi.chiave = ''PRODUCT/AGS/AGSpr/SPED'')
               AND NOT EXISTS
                          (SELECT 1
                             FROM seg_soggetti_protocollo sopr,
                                  documenti docu_sopr
                            WHERE docu_sopr.stato_documento NOT IN
                                     (''CA'', ''RE'')
                                  AND docu_sopr.id_documento =
                                         sopr.id_documento
                                  AND sopr.idrif = proto_view.idrif
                                  AND sopr.tipo_rapporto = ''DEST''
                                  AND sopr.documento_tramite = ''PEC'')
               AND NOT EXISTS
                          (SELECT 1
                             FROM seg_soggetti_protocollo sopr,
                                  documenti docu_sopr
                            WHERE docu_sopr.stato_documento NOT IN
                                     (''CA'', ''RE'')
                                  AND docu_sopr.id_documento =
                                         sopr.id_documento
                                  AND sopr.idrif = proto_view.idrif
                                  AND sopr.tipo_rapporto = ''DEST''
                                  AND sopr.documento_tramite IS NULL)
               AND idrif IN
                      (SELECT idrif
                         FROM seg_soggetti_protocollo sopr,
                              documenti docu_sopr
                        WHERE docu_sopr.stato_documento NOT IN (''CA'', ''RE'')
                              AND docu_sopr.id_documento = sopr.id_documento
                              AND sopr.tipo_rapporto = ''DEST''
                              AND sopr.data_sped >=
                                     TO_DATE (''@DATA_DAL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
                              AND sopr.data_sped <=
                                     TO_DATE (''@DATA_AL''||'' 23:59:59'',
                                              ''dd/mm/yyyy hh24:mi:ss''))
               AND proto_view.id_documento = d.id_documento
               AND proto_view.modalita = ''PAR''
               AND ''Y'' = ''@CHECK_PARTENZA_CARTACEA''      
               AND d.stato_documento NOT IN (''CA'', ''RE'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND (1=0
                    OR NOT EXISTS
                              (SELECT 1
                                 FROM gdm_t_log_conservazione
                                WHERE id_documento_rif = d.id_documento
                                      AND stato_conservazione <> ''FC''))
               AND tido.nome = DECODE (''--'', ''--'', tido.nome, ''--'')
               AND 1 =
                      (SELECT COUNT (filename)
                         FROM oggetti_file ogfi
                        WHERE ogfi.id_documento = d.id_documento
                              AND ogfi.filename <> ''@HIDDENFILENAME'')
               AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
               AND proto_view.codice_amministrazione =
                      ''@CODICE_AMMINISTRAZIONE''
               AND proto_view.codice_aoo = ''@CODICE_AOO''
               AND proto_view.numero is not null
        UNION ALL
    SELECT DISTINCT d.id_documento ID,
                        d.id_tipodoc ti,
                        d.data_aggiornamento da,
                        d.codice_richiesta cr,
                        proto_view.anno,
                        proto_view.numero,
                        proto_view.tipo_registro
          FROM documenti d, proto_conservabili_view proto_view, tipi_documento tido
         WHERE NOT EXISTS
                      (SELECT 1
                         FROM seg_soggetti_protocollo sopr,
                              documenti docu_sopr
                        WHERE docu_sopr.stato_documento NOT IN (''CA'', ''RE'')
                              AND docu_sopr.id_documento = sopr.id_documento
                              AND sopr.idrif = proto_view.idrif
                              AND sopr.tipo_rapporto = ''DEST''
                              AND NVL (sopr.documento_tramite, ''POR'') !=
                                     ''PEC'')
               AND NOT EXISTS
                          (SELECT 1
                             FROM seg_soggetti_protocollo sopr,
                                  documenti docu_sopr
                            WHERE docu_sopr.stato_documento NOT IN
                                     (''CA'', ''RE'')
                                  AND docu_sopr.id_documento =
                                         sopr.id_documento
                                  AND sopr.idrif = proto_view.idrif
                                  AND sopr.tipo_rapporto = ''DEST''
                                  AND sopr.ricevuta_conferma IS NULL
                                  AND sopr.ricevuta_eccezione IS NULL)
               AND proto_view.idrif IN
                      (SELECT idrif
                         FROM seg_soggetti_protocollo sopr,
                              documenti docu_sopr
                        WHERE docu_sopr.stato_documento NOT IN (''CA'', ''RE'')
                              AND docu_sopr.id_documento = sopr.id_documento
                              AND sopr.tipo_rapporto = ''DEST''
                              AND sopr.documento_tramite = ''PEC''
                              AND (sopr.data_ric_eccezione >=
                                         TO_DATE (''@DATA_DAL'',
                                                  ''dd/mm/yyyy hh24:mi:ss'')
                                      AND sopr.data_ric_eccezione <=
                                             TO_DATE (
                                                ''@DATA_AL''||'' 23:59:59'',
                                                ''dd/mm/yyyy hh24:mi:ss'')))
               AND proto_view.id_documento = d.id_documento
               AND proto_view.modalita = ''PAR''
               AND ''Y'' = ''@CHECK_PARTENZA_ELETTRONICA''      
               AND d.stato_documento NOT IN (''CA'', ''RE'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND (1=0
                    OR NOT EXISTS
                              (SELECT 1
                                 FROM gdm_t_log_conservazione
                                WHERE id_documento_rif = d.id_documento
                                      AND stato_conservazione <> ''FC''))
               AND tido.nome = DECODE (''--'', ''--'', tido.nome, ''--'')
               AND 1 =
                      (SELECT COUNT (filename)
                         FROM oggetti_file ogfi
                        WHERE ogfi.id_documento = d.id_documento
                              AND ogfi.filename <> ''@HIDDENFILENAME'')
               AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
               AND proto_view.codice_amministrazione =
                      ''@CODICE_AMMINISTRAZIONE''
               AND proto_view.codice_aoo = ''@CODICE_AOO''
               AND proto_view.numero is not null
union all
    SELECT DISTINCT d.id_documento ID,
                        d.id_tipodoc ti,
                        d.data_aggiornamento da,
                        d.codice_richiesta cr,
                        proto_view.anno,
                        proto_view.numero,
                        proto_view.tipo_registro
          FROM documenti d, proto_conservabili_view proto_view, tipi_documento tido
         WHERE NOT EXISTS
                      (SELECT 1
                         FROM seg_soggetti_protocollo sopr,
                              documenti docu_sopr
                        WHERE docu_sopr.stato_documento NOT IN (''CA'', ''RE'')
                              AND docu_sopr.id_documento = sopr.id_documento
                              AND sopr.idrif = proto_view.idrif
                              AND sopr.tipo_rapporto = ''DEST''
                              AND NVL (sopr.documento_tramite, ''POR'') !=
                                     ''PEC'')
               AND NOT EXISTS
                          (SELECT 1
                             FROM seg_soggetti_protocollo sopr,
                                  documenti docu_sopr
                            WHERE docu_sopr.stato_documento NOT IN
                                     (''CA'', ''RE'')
                                  AND docu_sopr.id_documento =
                                         sopr.id_documento
                                  AND sopr.idrif = proto_view.idrif
                                  AND sopr.tipo_rapporto = ''DEST''
                                  AND sopr.ricevuta_conferma IS NULL
                                  AND sopr.ricevuta_eccezione IS NULL)
               AND proto_view.idrif IN
                      (SELECT idrif
                         FROM seg_soggetti_protocollo sopr,
                              documenti docu_sopr
                        WHERE docu_sopr.stato_documento NOT IN (''CA'', ''RE'')
                              AND docu_sopr.id_documento = sopr.id_documento
                              AND sopr.tipo_rapporto = ''DEST''
                              AND sopr.documento_tramite = ''PEC''
                              AND (sopr.data_ric_conferma >=
                                      TO_DATE (''@DATA_DAL'',
                                               ''dd/mm/yyyy hh24:mi:ss'')
                                   AND sopr.data_ric_conferma <=
                                          TO_DATE (''@DATA_AL''||'' 23:59:59'',
                                                   ''dd/mm/yyyy hh24:mi:ss'')
                                   ))
               AND proto_view.id_documento = d.id_documento
               AND proto_view.modalita = ''PAR''
               AND ''Y'' = ''@CHECK_PARTENZA_ELETTRONICA''      
               AND d.stato_documento NOT IN (''CA'', ''RE'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND (1=0
                    OR NOT EXISTS
                              (SELECT 1
                                 FROM gdm_t_log_conservazione
                                WHERE id_documento_rif = d.id_documento
                                      AND stato_conservazione <> ''FC''))
               AND tido.nome = DECODE (''--'', ''--'', tido.nome, ''--'')
               AND 1 =
                      (SELECT COUNT (filename)
                         FROM oggetti_file ogfi
                        WHERE ogfi.id_documento = d.id_documento
                              AND ogfi.filename <> ''@HIDDENFILENAME'')
               AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
               AND proto_view.codice_amministrazione =
                      ''@CODICE_AMMINISTRAZIONE''
               AND proto_view.codice_aoo = ''@CODICE_AOO''
               AND proto_view.numero is not null
        UNION ALL
        SELECT TO_NUMBER (NULL),
               TO_NUMBER (NULL),
               TO_DATE (NULL),
               TO_CHAR (NULL),
               TO_NUMBER (NULL),
               TO_NUMBER (NULL),
               TO_CHAR (NULL)
          FROM DUAL
        ORDER BY anno ASC, tipo_registro ASC, numero ASC) a,
       DUAL
 WHERE    DECODE (gdm_competenza.gdm_verifica (
                     ''DOCUMENTI'',
                     a.ID,
                     ''L'',
                     ''GDM'',
                     f_trasla_ruolo (''GDM'', ''GDMWEB'', ''GDMWEB''),
                     TO_CHAR (SYSDATE, ''dd/mm/yyyy'')),
                  1, 1,
                  gdm_competenza.gdm_verifica (
                     ''DOCUMENTI'',
                     a.ID,
                     ''L'',
                     ''RPI'',
                     f_trasla_ruolo (''RPI'', ''GDMWEB'', ''GDMWEB''),
                     TO_CHAR (SYSDATE, ''dd/mm/yyyy'')))
       || dummy = ''1X''';

   UPDATE MODELLI
      SET ISTRUZIONI = d_istruzioni
    WHERE AREA = 'SEGRETERIA.PROTOCOLLO' AND CODICE_MODELLO = 'R_PROTOCOLLO_INVIO_CONSERVAZIONE';
END;
/