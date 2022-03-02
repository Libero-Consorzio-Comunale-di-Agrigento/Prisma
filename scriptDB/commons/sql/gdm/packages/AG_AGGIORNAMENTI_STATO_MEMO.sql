--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_AGGIORNAMENTI_STATO_MEMO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_AGGIORNAMENTI_STATO_MEMO
AS
   PROCEDURE agg_stato_memo;
   FUNCTION get_data_stato_memo (p_id_documento NUMBER)
      RETURN DATE;
END;
/
CREATE OR REPLACE PACKAGE BODY ag_aggiornamenti_stato_memo
AS
   FUNCTION get_data_stato_memo (p_id_documento NUMBER)
      RETURN DATE
   IS
      retval   DATE;
   BEGIN
      SELECT MIN (data_aggiornamento)
        INTO retval
        FROM stati_documento
       WHERE id_documento = p_id_documento;

      RETURN retval;
   END;

   PROCEDURE agg_stato_memo
   AS
   BEGIN
      UPDATE seg_memo_protocollo
         SET stato_memo = 'DG',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     NOT EXISTS
                        (SELECT 1
                           FROM riferimenti
                          WHERE     id_documento_rif =
                                       seg_memo_protocollo.id_documento
                                AND tipo_relazione = 'MAIL')
             AND memo_in_partenza = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'DP',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti, spr_protocolli_intero
                      WHERE     id_documento_rif =
                                   seg_memo_protocollo.id_documento
                            AND tipo_relazione = 'MAIL'
                            AND spr_protocolli_intero.id_documento =
                                   riferimenti.id_documento
                            AND spr_protocolli_intero.stato_pr = 'DP')
             AND EXISTS
                    (SELECT 1
                       FROM oggetti_file
                      WHERE     oggetti_file.id_documento =
                                   seg_memo_protocollo.id_documento
                            AND UPPER (oggetti_file.filename) IN
                                   ('SEGNATURA.XML',
                                    'SEGNATURA_CITTADINO.XML'))
             AND memo_in_partenza = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'DPS',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti, spr_protocolli_intero
                      WHERE     id_documento_rif =
                                   seg_memo_protocollo.id_documento
                            AND tipo_relazione = 'MAIL'
                            AND spr_protocolli_intero.id_documento =
                                   riferimenti.id_documento
                            AND spr_protocolli_intero.stato_pr = 'DP')
             AND NOT EXISTS
                        (SELECT 1
                           FROM oggetti_file
                          WHERE     oggetti_file.id_documento =
                                       seg_memo_protocollo.id_documento
                                AND UPPER (oggetti_file.filename) IN
                                       ('SEGNATURA.XML',
                                        'SEGNATURA_CITTADINO.XML'))
             AND memo_in_partenza = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'GE',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE memo_in_partenza = 'N' AND generata_eccezione = 'Y';

      COMMIT;

      FOR m
         IN (SELECT id_documento,
                    'PR' stato,
                    get_data_stato_memo (seg_memo_protocollo.id_documento)
                       d_stato_memo
               FROM seg_memo_protocollo
              WHERE     EXISTS
                           (SELECT 1
                              FROM riferimenti, spr_protocolli_intero
                             WHERE     id_documento_rif =
                                          seg_memo_protocollo.id_documento
                                   AND tipo_relazione = 'MAIL'
                                   AND spr_protocolli_intero.id_documento =
                                          riferimenti.id_documento
                                   AND spr_protocolli_intero.stato_pr != 'DP')
                    AND memo_in_partenza = 'N'
                    AND NVL (generata_eccezione, 'N') = 'N'
                    AND stato_memo IS NULL)
      LOOP
         UPDATE seg_memo_protocollo
            SET stato_memo = m.stato, data_stato_memo = m.d_stato_memo
          WHERE id_documento = m.id_documento;

         UPDATE seg_memo_protocollo
            SET stato_memo = m.stato, data_stato_memo = m.d_stato_memo
          WHERE id_documento IN
                   (SELECT id_documento
                      FROM riferimenti
                     WHERE     id_documento_rif = m.id_documento
                           AND tipo_relazione = 'PRINCIPALE');
      END LOOP;

      --      UPDATE seg_memo_protocollo
      --         SET stato_memo = 'PR',
      --             data_stato_memo =
      --                        get_data_stato_memo (seg_memo_protocollo.id_documento)
      --       WHERE EXISTS (
      --                SELECT 1
      --                  FROM riferimenti, spr_protocolli_intero
      --                 WHERE id_documento_rif = seg_memo_protocollo.id_documento
      --                   AND tipo_relazione = 'MAIL'
      --                   AND spr_protocolli_intero.id_documento =
      --                                                      riferimenti.id_documento
      --                   AND spr_protocolli_intero.stato_pr != 'DP')
      --         AND memo_in_partenza = 'N'
      --         AND NVL (generata_eccezione, 'N') = 'N'
      --         AND stato_memo IS NULL;
      --
      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'G',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti rife, seg_memo_protocollo memo_pas
                      WHERE     rife.id_documento_rif =
                                   seg_memo_protocollo.id_documento
                            AND rife.tipo_relazione = 'PROT_PEC'
                            AND memo_pas.id_documento = rife.id_documento
                            AND memo_pas.memo_in_partenza = 'Y')
             AND memo_in_partenza = 'N'
             AND NVL (generata_eccezione, 'N') = 'N';

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo =
                (SELECT stato_memo
                   FROM seg_memo_protocollo memo_att, riferimenti
                  WHERE     riferimenti.id_documento_rif =
                               memo_att.id_documento
                        AND riferimenti.tipo_relazione = 'PRINCIPALE'
                        AND riferimenti.id_documento =
                               seg_memo_protocollo.id_documento
                        AND memo_att.stato_memo != 'DG'),
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti, seg_memo_protocollo memo_att
                      WHERE     riferimenti.id_documento =
                                   seg_memo_protocollo.id_documento
                            AND tipo_relazione = 'PRINCIPALE'
                            AND riferimenti.id_documento_rif =
                                   memo_att.id_documento
                            AND memo_att.stato_memo != 'DG')
             AND memo_in_partenza = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND NVL (stato_memo, 'DG') = 'DG';

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'G',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti, proto_view prot
                      WHERE     id_documento_rif =
                                   seg_memo_protocollo.id_documento
                            AND tipo_relazione = 'PROT_ECC'
                            AND prot.id_documento = riferimenti.id_documento)
             AND memo_in_partenza = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo = 'DG';

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'GE',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti, seg_memo_protocollo memo2
                      WHERE     riferimenti.id_documento =
                                   seg_memo_protocollo.id_documento
                            AND tipo_relazione = 'PROT_ECC'
                            AND memo2.id_documento =
                                   riferimenti.id_documento_rif
                            AND NVL (memo2.memo_in_partenza, 'N') = 'Y')
             AND NVL (memo_in_partenza, 'N') = 'N'
             AND NVL (generata_eccezione, 'N') = 'Y'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'DG',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     NVL (memo_in_partenza, 'N') = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND processato_ag = 'N'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'G',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti rife, seg_memo_protocollo memo_pas
                      WHERE     rife.id_documento =
                                   seg_memo_protocollo.id_documento
                            AND rife.tipo_relazione = 'PROT_PEC'
                            AND memo_pas.id_documento = rife.id_documento_rif
                            AND NVL (memo_pas.memo_in_partenza, 'N') = 'N'
                            AND memo_pas.stato_memo = 'GE')
             AND NVL (memo_in_partenza, 'N') = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'G',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     EXISTS
                    (SELECT 1
                       FROM riferimenti rife, proto_view prot
                      WHERE     rife.id_documento_rif =
                                   seg_memo_protocollo.id_documento
                            AND rife.tipo_relazione IN
                                   ('PROT_ANN', 'PROT_AGG', 'PROT_CONF')
                            AND prot.id_documento = rife.id_documento)
             AND NVL (memo_in_partenza, 'N') = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo = 'DG';

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'G',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     NOT EXISTS
                        (SELECT 1
                           FROM riferimenti rife
                          WHERE     rife.id_documento =
                                       seg_memo_protocollo.id_documento
                                AND rife.tipo_relazione != 'STREAM')
             AND NOT EXISTS
                        (SELECT 1
                           FROM riferimenti rife
                          WHERE     rife.id_documento_rif =
                                       seg_memo_protocollo.id_documento
                                AND rife.tipo_relazione != 'STREAM')
             AND NVL (memo_in_partenza, 'N') = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'G',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     NVL (memo_in_partenza, 'N') = 'N'
             AND NVL (generata_eccezione, 'N') = 'N'
             AND processato_ag = 'Y'
             AND stato_memo IS NULL;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET stato_memo = 'DG',
             data_stato_memo =
                get_data_stato_memo (seg_memo_protocollo.id_documento)
       WHERE     memo_in_partenza IS NULL
             AND generata_eccezione IS NULL
             AND processato_ag IS NULL
             AND stato_memo IS NULL;

      COMMIT;


      FOR memo
         IN (SELECT i.id_documento id_documento_prot,
                    m.id_documento,
                    m.stato_memo,
                    d.data_aggiornamento
               FROM spr_protocolli_intero i,
                    documenti d,
                    seg_memo_protocollo m,
                    riferimenti r
              WHERE     i.id_documento = d.id_documento
                    AND NVL (stato_documento, 'BO') <> 'BO'
                    AND r.id_documento_rif = m.id_documento
                    AND r.id_documento = i.id_documento
                    AND r.tipo_relazione = 'MAIL'
                    AND m.stato_memo NOT IN ('PR', 'NP', 'SC', 'GE', 'G')
                    AND NOT EXISTS
                               (SELECT 1
                                  FROM riferimenti r1, documenti d1
                                 WHERE     r1.id_documento = d1.id_documento
                                       AND NVL (d1.stato_documento, 'BO') <>
                                              'BO'
                                       AND r1.id_documento <> i.id_documento
                                       AND r1.id_documento_rif =
                                              m.id_documento
                                       AND r1.tipo_relazione = 'MAIL'))
      LOOP
         UPDATE seg_memo_protocollo
            SET stato_memo = 'SC'
          WHERE id_documento = memo.id_documento;

         COMMIT;
      END LOOP;
   END;
END;
/
