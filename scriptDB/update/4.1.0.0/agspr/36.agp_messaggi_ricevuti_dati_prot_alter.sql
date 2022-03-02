--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_36.agp_protocolli_log_alter failOnError:false

create index agp_mrda_clas_fk
   on agp_msg_ricevuti_dati_prot (id_classificazione)
/

alter table agp_msg_ricevuti_dati_prot add (
constraint agp_mrda_clas_fk
  foreign key (id_classificazione)
  references ags_classificazioni (id_classificazione))
/

create index agp_mrda_fasc_fk
   on agp_msg_ricevuti_dati_prot (id_fascicolo)
/

alter table agp_msg_ricevuti_dati_prot add (
constraint agp_mrda_fasc_fk
  foreign key (id_fascicolo)
  references ags_fascicoli (id_documento))
/
