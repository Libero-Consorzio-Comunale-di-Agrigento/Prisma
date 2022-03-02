--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20201013_7.agp_protocolli_dati_accesso_upd

UPDATE AGP_PROTOCOLLI_DATI_ACCESSO
   SET controinteressati = 'N'
 WHERE controinteressati IS NULL
/