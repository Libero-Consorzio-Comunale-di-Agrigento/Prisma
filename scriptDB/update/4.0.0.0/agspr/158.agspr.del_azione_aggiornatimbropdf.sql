--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_158_del_azione_aggiornatimbropdf
DECLARE
   d_idx   NUMBER := -1;
BEGIN
   FOR p IN (SELECT id_pulsante, id_azione
               FROM wkf_diz_pulsanti_azioni
              WHERE id_azione IN (SELECT id_azione
                                    FROM wkf_diz_azioni
                                   WHERE nome_metodo = 'aggiornaTimbroPdf'))
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

DELETE wkf_diz_azioni
 WHERE nome_metodo = 'aggiornaTimbroPdf'
/
