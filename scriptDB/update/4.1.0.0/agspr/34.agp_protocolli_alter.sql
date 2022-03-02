--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_34.agp_protocolli_alter failOnError:false

create index agp_prot_clas_fk
   on agp_protocolli (id_classificazione)
/

alter table agp_protocolli add (
constraint agp_prot_clas_fk
  foreign key (id_classificazione)
  references ags_classificazioni (id_classificazione))
/

create index agp_prot_fasc_fk
   on agp_protocolli (id_fascicolo)
/

alter table agp_protocolli add (
constraint agp_prot_fasc_fk
  foreign key (id_fascicolo)
  references ags_fascicoli (id_documento))
/
