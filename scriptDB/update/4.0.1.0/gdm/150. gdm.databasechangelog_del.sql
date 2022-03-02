--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20201307_148_DATABASECHANGELOG

DELETE DATABASECHANGELOG
 WHERE filename =
          'update/4.0.0.0/gdm/149. gdm.upd_gdo_file_documento_dim.sql'
/

DELETE DATABASECHANGELOG
 WHERE filename =
          'update/4.0.0.0/gdm/32.parametri_ins.sql'
/

DELETE DATABASECHANGELOG
 WHERE filename =
          'update/4.0.1.0/gdm/168.crea_job_task_smist_assenti.sql'
/

DELETE DATABASECHANGELOG
 WHERE filename =
          'update/4.0.0.0/gdm/149. gdm.upd_gdo_file_documento_dim.sql'
/

DELETE DATABASECHANGELOG
 WHERE filename =
          'update/4.0.1.0/gdm/32.parametri_ins.sql'
/

DELETE DATABASECHANGELOG
 WHERE filename =
          'update/4.0.1.0/gdm/168.crea_job_task_smist_assenti.sql'
/
