--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_26_1.agp_documenti_titolario_log_ins
DECLARE
   d_rev   NUMBER;
BEGIN
   FOR t IN (SELECT ID_DOCUMENTO_TITOLARIO,
                    d_rev,
                    0,
                    NULL,
                    ID_DOCUMENTO,
                    ID_CLASSIFICAZIONE,
                    ID_FASCICOLO,
                    VALIDO,
                    UTENTE_INS,
                    DATA_INS,
                    UTENTE_UPD,
                    DATA_UPD
               FROM AGP_DOCUMENTI_TITOLARIO)
   LOOP
      d_rev := REVINFO_PKG.CREA_REVINFO (NVL (t.data_ins, SYSTIMESTAMP));
      DBMS_OUTPUT.put_line (
         'inserisco ' || t.ID_DOCUMENTO_TITOLARIO || ' rev ' || d_rev);

      INSERT INTO AGP_DOCUMENTI_TITOLARIO_LOG (ID_DOCUMENTO_TITOLARIO,
                                               REV,
                                               REVTYPE,
                                               ID_DOCUMENTO,
                                               ID_CLASSIFICAZIONE,
                                               ID_FASCICOLO,
                                               VALIDO,
                                               UTENTE_INS,
                                               DATA_INS,
                                               UTENTE_UPD,
                                               DATA_UPD)
         SELECT t.ID_DOCUMENTO_TITOLARIO,
                d_rev,
                0,
                t.ID_DOCUMENTO,
                t.ID_CLASSIFICAZIONE,
                t.ID_FASCICOLO,
                t.VALIDO,
                t.UTENTE_INS,
                t.DATA_INS,
                t.UTENTE_UPD,
                t.DATA_UPD
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM AGP_DOCUMENTI_TITOLARIO_LOG
                     WHERE ID_DOCUMENTO_TITOLARIO = t.ID_DOCUMENTO_TITOLARIO);
   END LOOP;
END;
/