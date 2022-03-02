--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_156_agp_schemi_prot_categorie_add_modificabile

alter table AGP_SCHEMI_PROT_CATEGORIE
add modificabile char(1) default 'Y' not null
/