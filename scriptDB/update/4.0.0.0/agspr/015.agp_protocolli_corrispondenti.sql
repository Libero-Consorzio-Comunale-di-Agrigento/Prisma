--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_015.agp_protocolli_corrispondenti
alter table agp_protocolli_corrispondenti add (
      quantita number
    , costo_spedizione number(19,2)
)
/

alter table agp_protocolli_corrispondenti add
constraint agp_prco_miri_fk
 foreign key (id_modalita_invio_ricezione)
 references ags_modalita_invio_ricezione (id_modalita_invio_ricezione)
 enable
 validate
/


create index agp_prco_miri_fk
   on agp_protocolli_corrispondenti (id_modalita_invio_ricezione)
/
