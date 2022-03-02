--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200717_179.fasc_meno_id_doc_uk failOnError:false

create unique index fasc_meno_id_doc_uk on
    SEG_FASCICOLI(-"ID_DOCUMENTO")
/