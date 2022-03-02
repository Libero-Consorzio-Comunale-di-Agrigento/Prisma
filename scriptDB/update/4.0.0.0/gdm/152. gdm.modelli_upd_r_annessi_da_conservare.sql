--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_152_modelli_upd_r_annessi_da_conservare

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
          FROM documenti d,
               proto_conservabili_view proto_view,
               tipi_documento tido,
               seg_allegati_protocollo alpr,
               documenti docu_alpr,
               oggetti_file ogfi,
               gdm_t_log_conservazione loco,
               documenti docu_loco
         WHERE     docu_alpr.id_documento = alpr.id_documento
               AND alpr.id_documento = ogfi.id_documento
               AND docu_alpr.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND alpr.idrif = proto_view.idrif
               AND loco.id_documento_rif = proto_view.id_documento
               AND ogfi.data_aggiornamento > loco.data_fine
               AND docu_loco.id_documento = loco.id_documento
               AND docu_loco.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.stato_conservazione = ''CC''
               AND NOT EXISTS
                          (SELECT 1
                             FROM gdm_t_log_annessi loan, documenti docu_loan
                            WHERE     loan.id_documento_rif =
                                         loco.id_documento_rif
                                  AND UPPER (loan.nome_file) =
                                         UPPER (ogfi.filename)
                                  AND loan.data_inizio >
                                         ogfi.data_aggiornamento
                                  AND docu_loan.id_documento =
                                         loan.id_documento
                                  AND docu_loan.stato_documento NOT IN
                                         (''CA'', ''RE'', ''PB'')
                                  AND loan.stato_conservazione <>''FC'')
               AND proto_view.id_documento = d.id_documento
               AND d.id_tipodoc = tido.id_tipodoc
               AND tido.nome =
                      DECODE (''@MODELLO_PROTO'',
                              ''--'', tido.nome,
                              ''@MODELLO_PROTO'')
               AND proto_view.anno = ''@ANNO''
               AND proto_view.DATA BETWEEN TO_DATE (''@DATA_DAL'',
                                                    ''dd/mm/yyyy hh24:mi:ss'')
                                       AND TO_DATE (''@DATA_AL'',
                                                    ''dd/mm/yyyy hh24:mi:ss'')
               AND proto_view.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
               AND proto_view.modalita = ''@MODALITA''
               AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
               AND proto_view.tipo_documento = ''@TIPO_DOCUMENTO''
               AND proto_view.so4_dirigente = ''@SO4_DIRIGENTE''
               AND proto_view.codice_amministrazione =
                      ''@CODICE_AMMINISTRAZIONE''
               AND proto_view.codice_aoo = ''@CODICE_AOO''
               AND proto_view.numero IS NOT NULL
        UNION ALL
        SELECT d.id_documento ID,
               d.id_tipodoc ti,
               d.data_aggiornamento da,
               d.codice_richiesta cr,
               prot.anno,
               prot.numero,
               prot.tipo_registro
          FROM proto_conservabili_view prot,
               riferimenti rife,
               oggetti_file ogfi,
               documenti d,
               documenti docu_rife,
               documenti docu_loco,
               gdm_t_log_conservazione loco,
               tipi_documento tido
         WHERE     prot.id_documento = d.id_documento
               AND prot.id_documento = rife.id_documento
               AND docu_rife.id_documento = ogfi.id_documento
               AND rife.id_documento_rif = ogfi.id_documento
               AND rife.area = ''SEGRETERIA.PROTOCOLLO''
               AND rife.tipo_relazione IN
                      (''PROT_CONF'',
                       ''MAIL'',
                       ''PROT_ECC'',
                       ''PROT_ANN'',
                       ''PROT_AGG'')
               AND UPPER (ogfi.filename) IN
                      (''SEGNATURA.XML'',
                       ''CONFERMA.XML'',
                       ''ECCEZIONE.XML'',
                       ''AGGIORNAMENTO.XML'',
                       ''ANNULLAMENTO.XML'')
               AND docu_rife.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.id_documento_rif = prot.id_documento
               AND ogfi.data_aggiornamento > loco.data_fine
               AND docu_loco.id_documento = loco.id_documento
               AND docu_loco.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.stato_conservazione = ''CC''
               AND NOT EXISTS
                          (SELECT 1
                             FROM gdm_t_log_annessi loan, documenti docu_loan
                            WHERE     loan.id_documento_rif =
                                         loco.id_documento_rif
                                  AND UPPER (loan.nome_file) =
                                         UPPER (ogfi.filename)
                                  AND loan.data_inizio >
                                         ogfi.data_aggiornamento
                                  AND docu_loan.id_documento =
                                         loan.id_documento
                                  AND docu_loan.stato_documento NOT IN
                                         (''CA'', ''RE'', ''PB'')
                                  AND loan.stato_conservazione <>''FC'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND tido.nome =
                      DECODE (''@MODELLO_PROTO'',
                              ''--'', tido.nome,
                              ''@MODELLO_PROTO'')
               AND prot.anno = ''@ANNO''
               AND prot.DATA BETWEEN TO_DATE (''@DATA_DAL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
                                 AND TO_DATE (''@DATA_AL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
               AND prot.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
               AND prot.modalita = ''@MODALITA''
               AND prot.tipo_registro = ''@TIPO_REGISTRO''
               AND prot.tipo_documento = ''@TIPO_DOCUMENTO''
               AND prot.so4_dirigente = ''@SO4_DIRIGENTE''
               AND prot.codice_amministrazione = ''@CODICE_AMMINISTRAZIONE''
               AND prot.codice_aoo = ''@CODICE_AOO''
               AND prot.numero IS NOT NULL
        UNION ALL
        SELECT d.id_documento ID,
               d.id_tipodoc ti,
               d.data_aggiornamento da,
               d.codice_richiesta cr,
               prot.anno,
               prot.numero,
               prot.tipo_registro
          FROM proto_conservabili_view prot,
               riferimenti rife,
               oggetti_file ogfi,
               documenti d,
               documenti docu_rife,
               documenti docu_loco,
               gdm_t_log_conservazione loco,
               tipi_documento tido,
               riferimenti rife_stream
         WHERE     prot.id_documento = d.id_documento
               AND prot.id_documento = rife.id_documento
               AND docu_rife.id_documento = ogfi.id_documento
               AND rife.id_documento_rif = ogfi.id_documento
               AND rife.area = ''SEGRETERIA.PROTOCOLLO''
               AND rife.tipo_relazione = ''MAIL''
               AND rife_stream.tipo_relazione = ''STREAM''
               AND rife.id_documento = rife_stream.id_documento
               AND ogfi.id_documento = rife_stream.id_documento_rif
               AND prot.modalita = ''ARR''
               AND docu_rife.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.id_documento_rif = prot.id_documento
               AND ogfi.data_aggiornamento > loco.data_fine
               AND docu_loco.id_documento = loco.id_documento
               AND docu_loco.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.stato_conservazione = ''CC''
               AND NOT EXISTS
                          (SELECT 1
                             FROM gdm_t_log_annessi loan, documenti docu_loan
                            WHERE     loan.id_documento_rif =
                                         loco.id_documento_rif
                                  AND UPPER (loan.nome_file) =
                                         UPPER (ogfi.filename)
                                  AND loan.data_inizio >
                                         ogfi.data_aggiornamento
                                  AND docu_loan.id_documento =
                                         loan.id_documento
                                  AND docu_loan.stato_documento NOT IN
                                         (''CA'', ''RE'', ''PB'')
                                  AND loan.stato_conservazione <>''FC'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND tido.nome =
                      DECODE (''@MODELLO_PROTO'',
                              ''--'', tido.nome,
                              ''@MODELLO_PROTO'')
               AND prot.anno = ''@ANNO''
               AND prot.DATA BETWEEN TO_DATE (''@DATA_DAL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
                                 AND TO_DATE (''@DATA_AL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
               AND prot.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
               AND prot.modalita = ''@MODALITA''
               AND prot.tipo_registro = ''@TIPO_REGISTRO''
               AND prot.tipo_documento = ''@TIPO_DOCUMENTO''
               AND prot.so4_dirigente = ''@SO4_DIRIGENTE''
               AND prot.codice_amministrazione = ''@CODICE_AMMINISTRAZIONE''
               AND prot.codice_aoo = ''@CODICE_AOO''
               AND prot.numero IS NOT NULL
        UNION ALL
        SELECT d.id_documento ID,
               d.id_tipodoc ti,
               d.data_aggiornamento da,
               d.codice_richiesta cr,
               prot.anno,
               prot.numero,
               prot.tipo_registro
          FROM proto_conservabili_view prot,
               riferimenti rife,
               riferimenti rife_mail,
               riferimenti rife_pec,
               oggetti_file ogfi,
               documenti d,
               documenti docu_rife,
               documenti docu_loco,
               gdm_t_log_conservazione loco,
               tipi_documento tido,
               seg_memo_protocollo memo
         WHERE     prot.id_documento = d.id_documento
               AND prot.id_documento = rife.id_documento
               AND prot.id_documento = rife_MAIL.id_documento
               AND rife_PEC.id_documento_RIF = OGFI.id_documento
               AND rife_MAIL.area = ''SEGRETERIA.PROTOCOLLO''
               AND rife_MAIL.tipo_relazione = ''MAIL''
               AND rife_PEC.TIPO_RELAZIONE = ''PROT_PEC''
               AND RIFE_PEC.ID_DOCUMENTO = rife_MAIL.id_documento_rif
               AND UPPER (ogfi.filename) = ''DATICERT.XML''
               AND memo.id_documento = rife_pec.id_documento_rif
               AND docu_rife.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.id_documento_rif = prot.id_documento
               AND ogfi.data_aggiornamento > loco.data_fine
               AND docu_loco.id_documento = loco.id_documento
               AND docu_loco.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.stato_conservazione = ''CC''
               AND NOT EXISTS
                          (SELECT 1
                             FROM gdm_t_log_annessi loan, documenti docu_loan
                            WHERE     loan.id_documento_rif =
                                         loco.id_documento_rif
                                  AND UPPER (loan.nome_file) =
                                         UPPER (ogfi.filename)
                                  AND loan.data_inizio >
                                         ogfi.data_aggiornamento
                                  AND docu_loan.id_documento =
                                         loan.id_documento
                                  AND docu_loan.stato_documento NOT IN
                                         (''CA'', ''RE'', ''PB'')
                                  AND loan.stato_conservazione <>''FC'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND tido.nome =
                      DECODE (''@MODELLO_PROTO'',
                              ''--'', tido.nome,
                              ''@MODELLO_PROTO'')
               AND prot.anno = ''@ANNO''
               AND prot.DATA BETWEEN TO_DATE (''@DATA_DAL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
                                 AND TO_DATE (''@DATA_AL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
               AND prot.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
               AND prot.modalita = ''@MODALITA''
               AND prot.tipo_registro = ''@TIPO_REGISTRO''
               AND prot.tipo_documento = ''@TIPO_DOCUMENTO''
               AND prot.so4_dirigente = ''@SO4_DIRIGENTE''
               AND prot.codice_amministrazione = ''@CODICE_AMMINISTRAZIONE''
               AND prot.codice_aoo = ''@CODICE_AOO''
               AND prot.numero IS NOT NULL
        UNION ALL
        SELECT d.id_documento ID,
               d.id_tipodoc ti,
               d.data_aggiornamento da,
               d.codice_richiesta cr,
               prot.anno,
               prot.numero,
               prot.tipo_registro
          FROM proto_conservabili_view prot,
               riferimenti rife_mail,
               riferimenti rife_pec,
               oggetti_file ogfi,
               documenti d,
               documenti docu_rife_pec,
               documenti docu_loco,
               gdm_t_log_conservazione loco,
               tipi_documento tido
         WHERE     prot.id_documento = d.id_documento
               AND prot.id_documento = rife_mail.id_documento
               AND docu_rife_pec.id_documento = rife_pec.id_documento_rif
               AND rife_pec.id_documento_rif = ogfi.id_documento
               AND rife_mail.area = ''SEGRETERIA.PROTOCOLLO''
               AND rife_mail.tipo_relazione IN
                      (''PROT_ECC'', ''PROT_AGG'', ''PROT_CONF'', ''PROT_ANN'')
               AND rife_pec.tipo_relazione = ''PROT_PEC''
               AND rife_pec.id_documento = rife_mail.id_documento_rif
               AND UPPER (ogfi.filename) = ''DATICERT.XML''
               AND docu_rife_pec.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.id_documento_rif = prot.id_documento
               AND ogfi.data_aggiornamento > loco.data_fine
               AND docu_loco.id_documento = loco.id_documento
               AND docu_loco.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.stato_conservazione = ''CC''
               AND NOT EXISTS
                          (SELECT 1
                             FROM gdm_t_log_annessi loan, documenti docu_loan
                            WHERE     loan.id_documento_rif =
                                         loco.id_documento_rif
                                  AND UPPER (loan.nome_file) =
                                         UPPER (ogfi.filename)
                                  AND loan.data_inizio >
                                         ogfi.data_aggiornamento
                                  AND docu_loan.id_documento =
                                         loan.id_documento
                                  AND docu_loan.stato_documento NOT IN
                                         (''CA'', ''RE'', ''PB'')
                                  AND loan.stato_conservazione <>''FC'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND tido.nome =
                      DECODE (''@MODELLO_PROTO'',
                              ''--'', tido.nome,
                              ''@MODELLO_PROTO'')
               AND prot.anno = ''@ANNO''
               AND prot.DATA BETWEEN TO_DATE (''@DATA_DAL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
                                 AND TO_DATE (''@DATA_AL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
               AND prot.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
               AND prot.modalita = ''@MODALITA''
               AND prot.tipo_registro = ''@TIPO_REGISTRO''
               AND prot.tipo_documento = ''@TIPO_DOCUMENTO''
               AND prot.so4_dirigente = ''@SO4_DIRIGENTE''
               AND prot.codice_amministrazione = ''@CODICE_AMMINISTRAZIONE''
               AND prot.codice_aoo = ''@CODICE_AOO''
               AND prot.numero IS NOT NULL
        UNION ALL
        SELECT d.id_documento ID,
               d.id_tipodoc ti,
               d.data_aggiornamento da,
               d.codice_richiesta cr,
               prot.anno,
               prot.numero,
               prot.tipo_registro
          FROM proto_conservabili_view prot,
               riferimenti rife,
               mes_albi,
               oggetti_file ogfi,
               mes_relate,
               documenti docu_loco,
               gdm_t_log_conservazione loco,
               tipi_documento tido,
               documenti docu_rela,
               documenti d
         WHERE     prot.id_documento = d.id_documento
               AND prot.id_documento = rife.id_documento
               AND rife.area = ''SEGRETERIA.PROTOCOLLO''
               AND rife.tipo_relazione = ''PROT_ALBO''
               AND rife.id_documento_rif = mes_albi.id_documento
               AND mes_relate.id_documento = ogfi.id_documento
               AND docu_rela.id_documento = mes_relate.id_documento
               AND mes_relate.anno_reg = mes_albi.anno_reg
               AND mes_relate.ultimo_numero_reg = mes_albi.ultimo_numero_reg
               AND INSTR (UPPER (ogfi.filename), ''RELATA'') = 1
               AND docu_rela.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.id_documento_rif = prot.id_documento
               AND ogfi.data_aggiornamento > loco.data_fine
               AND docu_loco.id_documento = loco.id_documento
               AND docu_loco.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
               AND loco.stato_conservazione = ''CC''
               AND NOT EXISTS
                          (SELECT 1
                             FROM gdm_t_log_annessi loan, documenti docu_loan
                            WHERE     loan.id_documento_rif =
                                         loco.id_documento_rif
                                  AND UPPER (loan.nome_file) =
                                         UPPER (ogfi.filename)
                                  AND loan.data_inizio >
                                         ogfi.data_aggiornamento
                                  AND docu_loan.id_documento =
                                         loan.id_documento
                                  AND docu_loan.stato_documento NOT IN
                                         (''CA'', ''RE'', ''PB'')
                                  AND loan.stato_conservazione <>''FC'')
               AND d.id_tipodoc = tido.id_tipodoc
               AND tido.nome =
                      DECODE (''@MODELLO_PROTO'',
                              ''--'', tido.nome,
                              ''@MODELLO_PROTO'')
               AND prot.anno = ''@ANNO''
               AND prot.DATA BETWEEN TO_DATE (''@DATA_DAL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
                                 AND TO_DATE (''@DATA_AL'',
                                              ''dd/mm/yyyy hh24:mi:ss'')
               AND prot.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
               AND prot.modalita = ''@MODALITA''
               AND prot.tipo_registro = ''@TIPO_REGISTRO''
               AND prot.tipo_documento = ''@TIPO_DOCUMENTO''
               AND prot.so4_dirigente = ''@SO4_DIRIGENTE''
               AND prot.codice_amministrazione = ''@CODICE_AMMINISTRAZIONE''
               AND prot.codice_aoo = ''@CODICE_AOO''
               AND prot.numero IS NOT NULL
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
    WHERE AREA = 'SEGRETERIA.PROTOCOLLO' AND CODICE_MODELLO = 'R_ANNESSI_DA_CONSERVARE';
END;
/