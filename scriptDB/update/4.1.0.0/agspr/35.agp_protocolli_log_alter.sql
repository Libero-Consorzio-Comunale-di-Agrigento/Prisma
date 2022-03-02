--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_35.agp_protocolli_log_alter failOnError:false

create index agp_prlo_clas_fk
   on agp_protocolli_log (id_classificazione);
/

alter table agp_protocolli_log add (
constraint agp_prlo_clas_fk
  foreign key (id_classificazione)
  references ags_classificazioni (id_classificazione))
/

create index agp_prlo_fasc_fk
   on agp_protocolli_log (id_fascicolo)
/

alter table agp_protocolli_log add (
constraint agp_prlo_fasc_fk
  foreign key (id_fascicolo)
  references ags_fascicoli (id_documento))
/
