--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_37.agp_msg_ricevuti_dati_prot_log_alter failOnError:false

create index agp_mrdl_clas_fk
   on agp_msg_ricevuti_dati_prot_log (id_classificazione)
/

alter table agp_msg_ricevuti_dati_prot_log add (
constraint agp_mrdl_clas_fk
  foreign key (id_classificazione)
  references ags_classificazioni (id_classificazione))
/

create index agp_mrdl_fasc_fk
   on agp_msg_ricevuti_dati_prot_log (id_fascicolo)
/

alter table agp_msg_ricevuti_dati_prot_log add (
constraint agp_mrdl_fasc_fk
  foreign key (id_fascicolo)
  references ags_fascicoli (id_documento))
/
