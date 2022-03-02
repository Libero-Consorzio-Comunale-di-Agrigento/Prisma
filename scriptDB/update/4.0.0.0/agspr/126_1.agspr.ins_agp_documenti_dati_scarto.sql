--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_126_1_ins_agp_documenti_dati_scarto

INSERT INTO AGP_DOCUMENTI_DATI_SCARTO (ID_DOCUMENTO_DATI_SCARTO,
                                       STATO,
                                       DATA_STATO,
                                       NULLA_OSTA,
                                       DATA_NULLA_OSTA,
                                       UTENTE_INS,
                                       DATA_INS,
                                       UTENTE_UPD,
                                       DATA_UPD,
                                       VERSION)
   SELECT ID_PROTOCOLLO_DATI_SCARTO,
          STATO,
          DATA_STATO,
          NULLA_OSTA,
          DATA_NULLA_OSTA,
          UTENTE_INS,
          DATA_INS,
          UTENTE_UPD,
          DATA_UPD,
          VERSION
     FROM AGP_PROTOCOLLI_DATI_SCARTO
/
commit
/   