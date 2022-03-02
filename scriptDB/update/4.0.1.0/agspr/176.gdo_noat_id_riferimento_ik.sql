--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200711_176.gdo_noat_id_riferimento_ik failOnError:false

CREATE INDEX gdo_noat_id_riferimento_ik
   ON GDO_NOTIFICHE_ATTIVITA (ID_RIFERIMENTO)
/