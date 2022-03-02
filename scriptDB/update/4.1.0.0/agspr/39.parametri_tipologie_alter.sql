--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_39.parametri_tipologie_alter failOnError:false

create index pati_id_tipo_protocollo_ik on PARAMETRI_TIPOLOGIE (ID_TIPO_PROTOCOLLO)
/
