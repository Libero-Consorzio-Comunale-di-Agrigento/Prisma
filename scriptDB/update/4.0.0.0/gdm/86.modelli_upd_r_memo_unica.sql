--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_86.modelli_upd_r_memo_unica failOnError:false
DECLARE
   d_istruzioni   CLOB;
BEGIN
   d_istruzioni :=
      '<USER_QUERY>
SELECT ID, ti, da, cr
  FROM (SELECT DISTINCT d.id_documento ID, d.id_tipodoc ti,
                        d.data_aggiornamento da, d.codice_richiesta cr,
                        memo_protocollo.data_ricezione,
                        memo_protocollo.destinatari,
                        memo_protocollo.memo_in_partenza,
                        memo_protocollo.generata_eccezione,
                        memo_protocollo.stato_memo, memo_protocollo.oggetto,
                        memo_protocollo.message_id
                   FROM documenti d,
                        seg_memo_protocollo memo_protocollo
                  WHERE memo_protocollo.id_documento = d.id_documento
                    AND NVL (memo_protocollo.memo_in_partenza, ''N'') = ''N''
                    AND contains (oggetto, ''@OGGETTO'') > 0
                    AND contains (mittente, ag_utilities_ricerca.get_stringa_per_contains(''@MITTENTE'')) > 0
                    AND (   ''@TIPO_MESSAGGIO'' = tipo_messaggio
                         OR ''@TIPO_MESSAGGIO'' = ''TUTTI''
                        )
                    AND (   ''@INCLUDI_MSG_PEC'' = ''Y''
                         OR (    UPPER (NVL (oggetto, ''*'')) NOT LIKE
                                                              ''ACCETTAZIONE:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE
                                                   ''AVVISO MANCATA CONSEGNA:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE
                                                ''AVVISO DI MANCATA CONSEGNA:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE
                                                                  ''ERRORE_DI_CONSEGNA:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE

                                                                  ''CONSEGNA:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE
                                                                  ''AVVENUTA_CONSEGNA:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE

                                                           ''PRESA IN CARICO:%''
                             AND UPPER (NVL (oggetto, ''*'')) NOT LIKE
                                                                    ''ERRORE:%''
                            )
                        )
                    AND NOT EXISTS (
                           SELECT ''1''
                             FROM riferimenti r,
                                  seg_memo_protocollo memo_main
                            WHERE r.id_documento_rif =
                                                  memo_protocollo.id_documento
                              AND memo_main.id_documento = r.id_documento
                              AND tipo_relazione = ''PRINCIPALE''
                              AND (NVL (memo_main.oggetto, '' '') LIKE
                                                                   ''CONSEGNA%'' or
                                   NVL (memo_main.oggetto, '' '') LIKE
                                                                   ''AVVENUTA_CONSEGNA%''))
                    AND NOT EXISTS (
                           SELECT ''1''
                             FROM riferimenti r,
                                  seg_memo_protocollo memo_main
                            WHERE r.id_documento_rif =
                                                  memo_protocollo.id_documento
                              AND memo_main.id_documento = r.id_documento
                              AND tipo_relazione = ''PRINCIPALE''
                              AND NVL (memo_main.oggetto, '' '') LIKE
                                                                   ''ANOMALIA%'')
                    AND memo_protocollo.data_ricezione
                           BETWEEN TO_DATE (''@DATA_RICEZIONE_DAL'',
                                            ''dd/mm/yyyy hh24:mi:ss''
                                           )
                               AND TO_DATE (''@DATA_RICEZIONE_AL'',
                                            ''dd/mm/yyyy hh24:mi:ss''
                                           )
                    AND NVL (memo_protocollo.generata_eccezione, ''N'') =
                                                         ''@GENERATA_ECCEZIONE''
                    AND (   NVL (memo_protocollo.stato_memo, ''DG'') =
                                                                 ''@STATO_MEMO''
                         OR ''@STATO_MEMO'' = ''TUTTI''
                        )
                    AND d.stato_documento NOT IN (''CA'', ''RE'')
                    AND (   ag_utilities.concat_instr (lower(destinatari),
                                                       lower(destinatari_conoscenza),
                                                       ''@CASELLA''
                                                      ) > 0
                         OR ''@CASELLA'' = ''%''
                         OR (    ag_utilities.concat_instr (lower(destinatari),
                                                       lower(destinatari_conoscenza),
                                                       ''@CASELLA''
                                                      ) = 0
                             AND ''@CASELLA'' =
                                    (SELECT LOWER (inte.indirizzo)
                                       FROM so4_aoo aoo,
                                            so4_indirizzi_telematici inte,
                                            (SELECT pamm.valore
                                                       codice_amministrazione,
                                                    paoo.valore codice_aoo
                                               FROM parametri paoo,
                                                    parametri pamm
                                              WHERE paoo.tipo_modello =
                                                                     ''@agVar@''
                                                AND pamm.tipo_modello =
                                                                     ''@agVar@''
                                                AND pamm.codice =
                                                          ''CODICE_AMM_''
                                                       || ag_utilities.get_defaultaooindex
                                                AND paoo.codice =
                                                          ''CODICE_AOO_''
                                                       || ag_utilities.get_defaultaooindex) para
                                      WHERE inte.id_aoo(+) = aoo.progr_aoo
                                        AND inte.tipo_entita(+) = ''AO''
                                        AND inte.tipo_indirizzo(+) =
                                               DECODE (tipo_messaggio,
                                                       ''FAX'', ''F'',
                                                       ''I''
                                                      )
                                        AND aoo.codice_amministrazione =
                                                   para.codice_amministrazione
                                        AND aoo.codice_aoo = para.codice_aoo
                                        AND aoo.al IS NULL)
                        AND (       NVL (tipo_messaggio, '' '') <> ''FAX''
                                AND NOT EXISTS
                                       (  SELECT 1
                                            FROM seg_uo_mail
                                           WHERE email IS NOT NULL
                                          HAVING ag_utilities.concat_instr
                                                      (lower(destinatari),
                                                       lower(destinatari_conoscenza),
                                                       LOWER (email)
                                                      ) > 0
                                        GROUP BY email)
                             OR (    tipo_messaggio = ''FAX''
                                 AND NOT EXISTS
                                        (  SELECT 1
                                             FROM seg_uo_mail
                                            WHERE mailfax IS NOT NULL
                                          HAVING ag_utilities.concat_instr
                                                      (lower(destinatari),
                                                       lower(destinatari_conoscenza),
                                                       LOWER (mailfax)
                                                      ) > 0
                                         GROUP BY mailfax)))
                            )
                        )
        UNION ALL
        SELECT   TO_NUMBER (NULL), TO_NUMBER (NULL), TO_DATE (NULL),
                 TO_CHAR (NULL), TO_DATE (NULL), TO_CHAR (NULL),
                 TO_CHAR (NULL), TO_CHAR (NULL), TO_CHAR (NULL),
                 TO_CHAR (NULL), TO_CHAR (NULL)
            FROM DUAL
        ORDER BY ID ASC) a,
       DUAL
 WHERE    gdm_competenza.gdm_verifica (''DOCUMENTI'',
                                       a.ID,
                                       ''L'',
                                       '':UtenteGDM'',
                                       f_trasla_ruolo ('':UtenteGDM'',
                                                       ''GDMWEB'',
                                                       ''GDMWEB''
                                                      ),
                                       TO_CHAR (SYSDATE, ''dd/mm/yyyy'')
                                      )
       || dummy = ''1X''';

   UPDATE MODELLI
      SET ISTRUZIONI = d_istruzioni
    WHERE AREA = 'SEGRETERIA' AND CODICE_MODELLO = 'R_MEMO_UNICA';
END;
/