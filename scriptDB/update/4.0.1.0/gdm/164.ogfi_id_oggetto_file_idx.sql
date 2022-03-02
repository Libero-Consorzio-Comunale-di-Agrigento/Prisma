--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200625_163_ogfi_id_oggetto_file_idx failOnError:false

CREATE INDEX ogfi_id_oggetto_file_idx ON OGGETTI_FILE_LOG
(id_oggetto_file)
/