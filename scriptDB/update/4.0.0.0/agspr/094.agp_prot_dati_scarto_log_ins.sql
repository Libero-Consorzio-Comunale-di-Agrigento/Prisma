--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_094.agp_prot_dati_scarto_log_ins
DECLARE
   d_id_rev   NUMBER;
BEGIN
   FOR sc IN (SELECT *
                FROM AGP_PROTOCOLLI_DATI_SCARTO)
   LOOP
      SELECT hibernate_sequence.NEXTVAL INTO d_id_rev FROM DUAL;

      INSERT INTO REVINFO (REV, REVTSTMP)
           VALUES (d_id_rev, sysdate);

      INSERT INTO AGP_PROTOCOLLI_DATI_SCARTO_LOG (ID_PROTOCOLLO_DATI_SCARTO,
                                                  REV,
                                                  REVTYPE,
                                                  STATO,
                                                  STATO_MOD,
                                                  DATA_STATO,
                                                  DATA_STATO_MOD,
                                                  NULLA_OSTA,
                                                  NULLA_OSTA_MOD,
                                                  DATA_NULLA_OSTA,
                                                  DATA_NULLA_OSTA_MOD,
                                                  UTENTE_INS,
                                                  UTENTE_INS_MOD,
                                                  DATA_INS,
                                                  DATE_CREATED_MOD,
                                                  UTENTE_UPD,
                                                  UTENTE_UPD_MOD,
                                                  DATA_UPD,
                                                  LAST_UPDATED_MOD)
           VALUES (sc.ID_PROTOCOLLO_DATI_SCARTO,
                   d_id_rev,
                   0,
                   sc.STATO,
                   DECODE (sc.STATO, NULL, 0, 1),
                   sc.DATA_STATO,
                   DECODE (sc.DATA_STATO, NULL, 0, 1),
                   sc.NULLA_OSTA,
                   DECODE (sc.NULLA_OSTA, NULL, 0, 1),
                   sc.DATA_NULLA_OSTA,
                   DECODE (sc.DATA_NULLA_OSTA, NULL, 0, 1),
                   sc.UTENTE_INS,
                   DECODE (sc.UTENTE_INS, NULL, 0, 1),
                   sc.DATA_INS,
                   DECODE (sc.DATA_INS, NULL, 0, 1),
                   sc.UTENTE_UPD,
                   DECODE (sc.UTENTE_UPD, NULL, 0, 1),
                   sc.DATA_UPD,
                   DECODE (sc.DATA_UPD, NULL, 0, 1));
   END LOOP;
   commit;
END;
/