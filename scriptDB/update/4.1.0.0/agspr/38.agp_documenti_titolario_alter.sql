--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_38.agp_documenti_titolario_alter failOnError:false

create index agp_doti_clas_fk
   on agp_documenti_titolario (id_classificazione)
/

alter table agp_documenti_titolario add (
constraint agp_doti_clas_fk
  foreign key (id_classificazione)
  references ags_classificazioni (id_classificazione))
/

create index agp_doti_fasc_fk
   on agp_documenti_titolario (id_fascicolo)
/

alter table agp_documenti_titolario add (
constraint agp_doti_fasc_fk
  foreign key (id_fascicolo)
  references ags_fascicoli (id_documento))
/


