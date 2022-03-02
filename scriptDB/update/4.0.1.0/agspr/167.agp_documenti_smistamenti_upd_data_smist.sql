--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200707_167.agp_documenti_smistamenti_upd_data_smist

BEGIN
   FOR c
      IN (SELECT data_ins,
                 (SELECT data
                    FROM agp_protocolli
                   WHERE id_documento =
                            agp_documenti_smistamenti.id_documento)
                    data_protocollo,
                 id_documento_smistamento,
                 id_documento_esterno
            FROM agp_documenti_smistamenti
           WHERE     data_smistamento = data_assegnazione
                 AND (   data_smistamento > data_presa_in_carico
                      OR     data_smistamento = data_presa_in_carico
                         AND utente_presa_in_carico <> utente_trasmissione))
   LOOP
      IF (c.data_ins > c.data_protocollo)
      THEN
         UPDATE agp_documenti_smistamenti
            SET data_smistamento = c.data_ins
          WHERE id_documento_smistamento = c.id_documento_smistamento;

         UPDATE gdm_seg_smistamenti
            SET smistamento_dal = c.data_ins
          WHERE id_documento = c.id_documento_esterno;
      ELSE
         UPDATE agp_documenti_smistamenti
            SET data_smistamento = c.data_protocollo
          WHERE id_documento_smistamento = c.id_documento_smistamento;

         UPDATE gdm_seg_smistamenti
            SET smistamento_dal = c.data_protocollo
          WHERE id_documento = c.id_documento_esterno;
      END IF;
   END LOOP;
END;
/
