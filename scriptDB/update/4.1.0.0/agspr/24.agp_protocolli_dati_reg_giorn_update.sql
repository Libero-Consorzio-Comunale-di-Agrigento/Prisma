--liquibase formatted sql
--changeset rcossu:4.1.0.0_20200707_24.agp_protocolli_dati_reg_giorn_update

alter table AGP_PROTOCOLLI_DATI_REG_GIORN
    add ERRORE varchar2(1000)
/