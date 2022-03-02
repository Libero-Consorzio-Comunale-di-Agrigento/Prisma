--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200331_151_upd_azione_invio_smistamenti

DECLARE
   d_idx   NUMBER := -1;
BEGIN
   FOR p IN (SELECT id_pulsante, id_azione
               FROM wkf_diz_pulsanti_azioni
              WHERE id_azione IN (SELECT id_azione
                                    FROM wkf_diz_azioni
                                   WHERE nome = 'Invio Smistamenti'))
   LOOP
      DELETE wkf_diz_pulsanti_azioni
       WHERE id_pulsante = p.id_pulsante AND id_azione = p.id_azione;

      FOR a IN (  SELECT id_pulsante, id_azione
                    FROM wkf_diz_pulsanti_azioni
                   WHERE id_pulsante = p.id_pulsante
                ORDER BY azioni_idx)
      LOOP
         d_idx := d_idx + 1;

         UPDATE wkf_diz_pulsanti_azioni
            SET azioni_idx = d_idx
          WHERE id_pulsante = a.id_pulsante AND id_azione = a.id_azione;
      END LOOP;
   END LOOP;
END;
/

DECLARE
   d_id_azione    NUMBER;
   d_azioni_idx   NUMBER;
BEGIN
   SELECT id_azione
     INTO d_id_azione
     FROM wkf_diz_azioni
    WHERE nome = 'Invio Smistamenti';

   FOR puls IN (SELECT *
                  FROM wkf_diz_pulsanti
                 WHERE etichetta = 'Protocolla')
   LOOP
      SELECT NVL (MAX (azioni_idx), 0) + 1
        INTO d_azioni_idx
        FROM wkf_diz_pulsanti_azioni
       WHERE id_pulsante = puls.id_pulsante;

      INSERT INTO wkf_diz_pulsanti_azioni (ID_PULSANTE,
                                           ID_AZIONE,
                                           AZIONI_IDX)
         SELECT puls.id_pulsante, d_id_azione, d_azioni_idx
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM wkf_diz_pulsanti_azioni
                     WHERE     id_pulsante = puls.id_pulsante
                           AND id_azione = d_id_azione);
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END;
/

-- Nel flusso FIRMA E PROTOCOLLA l'azione deve essere aggiunta come azione di ingresso nel nodo che prevede la protocollazione (come ultima azione)

BEGIN
   FOR nodi
      IN (SELECT DISTINCT cp.id_cfg_step_successivo,
                          SUBSTR (dp.etichetta, 1, 18) etichetta,
                          cs.nome step,
                          cs2.nome step_successivo,
                          a.id_azione
            FROM wkf_cfg_pulsanti cp,
                 wkf_diz_pulsanti dp,
                 wkf_cfg_step cs,
                 wkf_cfg_step cs2,
                 wkf_diz_azioni a
           WHERE     cp.id_pulsante = dp.id_pulsante
                 AND INSTR (LOWER (etichetta), 'firma e protocolla') > 0
                 AND cs.id_cfg_step = cp.id_cfg_step
                 AND cs2.id_cfg_step = cp.id_cfg_step_successivo
                 AND a.nome = 'Invio Smistamenti'
                 AND NOT EXISTS
                        (SELECT 1
                           FROM WKF_CFG_STEP_AZIONI_IN
                          WHERE     ID_CFG_STEP = cp.id_cfg_step_successivo
                                AND ID_AZIONE_IN = a.id_azione))
   LOOP
      INSERT INTO WKF_CFG_STEP_AZIONI_IN (ID_CFG_STEP,
                                          ID_AZIONE_IN,
                                          AZIONI_INGRESSO_IDX)
         SELECT nodi.id_cfg_step_successivo,
                nodi.id_azione,
                NVL (MAX (AZIONI_INGRESSO_IDX), 0) + 1
           FROM WKF_CFG_STEP_AZIONI_IN
          WHERE     ID_CFG_STEP = nodi.id_cfg_step_successivo
                AND NOT EXISTS
                       (SELECT 1
                          FROM WKF_CFG_STEP_AZIONI_IN
                         WHERE     ID_CFG_STEP = nodi.id_cfg_step_successivo
                               AND ID_AZIONE_IN = nodi.id_azione);
   END LOOP;
END;
/

-- Nel flusso PROTOCOLLA E FIRMA l'azione deve essere aggiunta come azione di ingresso nel nodo successivo alla protocollazione

BEGIN
   FOR nodi
      IN (SELECT DISTINCT cp.id_cfg_step_successivo,
                          SUBSTR (dp.etichetta, 1, 18) etichetta,
                          cs.nome step,
                          cs2.nome step_successivo,
                          a.id_azione
            FROM wkf_cfg_pulsanti cp,
                 wkf_diz_pulsanti dp,
                 wkf_cfg_step cs,
                 wkf_cfg_step cs2,
                 wkf_diz_azioni a
           WHERE     cp.id_pulsante = dp.id_pulsante
                 AND INSTR (LOWER (etichetta), 'protocolla e firma') > 0
                 AND cs.id_cfg_step = cp.id_cfg_step
                 AND cs2.id_cfg_step = cp.id_cfg_step_successivo
                 AND a.nome = 'Invio Smistamenti'
                 AND NOT EXISTS
                        (SELECT 1
                           FROM WKF_CFG_STEP_AZIONI_IN
                          WHERE     ID_CFG_STEP = cp.id_cfg_step_successivo
                                AND ID_AZIONE_IN = a.id_azione))
   LOOP
      INSERT INTO WKF_CFG_STEP_AZIONI_IN (ID_CFG_STEP,
                                          ID_AZIONE_IN,
                                          AZIONI_INGRESSO_IDX)
         SELECT nodi.id_cfg_step_successivo,
                nodi.id_azione,
                NVL (MAX (AZIONI_INGRESSO_IDX), 0) + 1
           FROM WKF_CFG_STEP_AZIONI_IN
          WHERE     ID_CFG_STEP = nodi.id_cfg_step_successivo
                AND NOT EXISTS
                       (SELECT 1
                          FROM WKF_CFG_STEP_AZIONI_IN
                         WHERE     ID_CFG_STEP = nodi.id_cfg_step_successivo
                               AND ID_AZIONE_IN = nodi.id_azione);
   END LOOP;
END;
/

COMMIT
/