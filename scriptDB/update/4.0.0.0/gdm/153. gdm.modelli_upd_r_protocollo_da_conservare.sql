--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_153_modelli_upd_r_protocollo_da_conservare

DECLARE
   d_istruzioni   CLOB;
BEGIN
   d_istruzioni :=
      '<USER_QUERY>
SELECT ID, ti, da, cr
  FROM (SELECT DISTINCT d.id_documento ID, d.id_tipodoc ti,
                        d.data_aggiornamento da, d.codice_richiesta cr,
                        proto_view.anno, proto_view.numero, proto_view.tipo_registro
                   FROM documenti d, proto_conservabili_view proto_view, tipi_documento tido
                  WHERE proto_view.id_documento = d.id_documento
                   /* AND ag_utilities.VERIFICA_CATEGORIA_DOCUMENTO(d.id_documento, ''DETE'') = 0
                    AND ag_utilities.VERIFICA_CATEGORIA_DOCUMENTO(d.id_documento, ''DELI'') = 0*/
                    AND d.id_tipodoc = tido.id_tipodoc
                    AND (   1=0 
                         OR NOT EXISTS (
                               SELECT 1
                                 FROM gdm_t_log_conservazione
                                WHERE id_documento_rif = d.id_documento
                                  AND stato_conservazione <> ''FC'')
                        )
                    AND tido.nome =
                           DECODE (''@MODELLO_PROTO'',
                                   ''--'', tido.nome,
                                   ''@MODELLO_PROTO''
                                  )
                     AND ( (tido.area_modello in (''SEGRETERIA'', ''SEGRETERIA.PROTOCOLLO'') and
                       1 = (SELECT COUNT (filename)
                              FROM oggetti_file ogfi
                             WHERE ogfi.id_documento = d.id_documento
                               AND ogfi.filename <> ''@HIDDENFILENAME'')
                               )
                               OR
                               (tido.area_modello not in (''SEGRETERIA'', ''SEGRETERIA.PROTOCOLLO''))
                               )                    
                    AND proto_view.anno = ''@ANNO''
                    AND proto_view.DATA BETWEEN TO_DATE
                                                      (''@DATA_DAL'',
                                                       ''dd/mm/yyyy hh24:mi:ss''
                                                      )
                                            AND TO_DATE
                                                      (''@DATA_AL'',
                                                       ''dd/mm/yyyy hh24:mi:ss''
                                                      )
                    AND proto_view.numero BETWEEN ''@NUMERO_DAL'' AND ''@NUMERO_AL''
                    AND proto_view.modalita = ''@MODALITA''
                    AND proto_view.tipo_registro = ''@TIPO_REGISTRO''
                    AND proto_view.tipo_documento = ''@TIPO_DOCUMENTO''
                    AND proto_view.so4_dirigente = ''@SO4_DIRIGENTE''
                    AND proto_view.codice_amministrazione =
                                                     ''@CODICE_AMMINISTRAZIONE''
                    AND proto_view.codice_aoo = ''@CODICE_AOO''
                    AND proto_view.numero is not null
        UNION ALL
         SELECT TO_NUMBER (NULL), TO_NUMBER (NULL), TO_DATE (NULL), TO_CHAR (NULL), TO_NUMBER (NULL),
  TO_NUMBER (NULL) , TO_CHAR (NULL)
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
    WHERE AREA = 'SEGRETERIA.PROTOCOLLO' AND CODICE_MODELLO = 'R_PROTOCOLLO_DA_CONSERVARE';
END;
/