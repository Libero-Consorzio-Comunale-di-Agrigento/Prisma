--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200910_42.gdo_documenti_soggetti_log_ins failOnError:false

DECLARE
   d_id_rev   NUMBER;
BEGIN
   FOR ds
      IN (SELECT *
            FROM GDO_DOCUMENTI_SOGGETTI
           WHERE NOT EXISTS
                    (SELECT 1
                       FROM GDO_DOCUMENTI_SOGGETTI_LOG
                      WHERE ID_DOCUMENTO_SOGGETTO =
                               GDO_DOCUMENTI_SOGGETTI.ID_DOCUMENTO_SOGGETTO))
   LOOP
      d_id_rev := REVINFO_PKG.CREA_REVINFO (SYSTIMESTAMP);

      INSERT INTO GDO_DOCUMENTI_SOGGETTI_LOG (ID_DOCUMENTO_SOGGETTO,
                                              ID_DOCUMENTO,
                                              REV,
                                              REVTYPE,
                                              VERSION,
                                              UTENTE,
                                              ATTIVO,
                                              TIPO_SOGGETTO,
                                              SEQUENZA,
                                              UNITA_PROGR,
                                              UNITA_DAL,
                                              UNITA_OTTICA)
           VALUES (ds.ID_DOCUMENTO_SOGGETTO,
                   ds.id_documento,
                   d_id_rev,
                   0,
                   0,
                   ds.utente,
                   ds.attivo,
                   ds.tipo_soggetto,
                   0,
                   ds.unita_progr,
                   ds.unita_dal,
                   ds.unita_ottica);
   END LOOP;
END;
/
