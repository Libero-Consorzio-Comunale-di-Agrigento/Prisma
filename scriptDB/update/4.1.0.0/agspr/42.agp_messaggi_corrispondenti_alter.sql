--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_42.agp_messaggi_corrispondenti_alter failOnError:false

ALTER TABLE agp_messaggi_corrispondenti ADD (
DATA_CONSEGNA                  DATE,
DATA_MANCATA_CONSEGNA          DATE,
DATA_CONSEGNA_CONFERMA         DATE ,
DATA_MANCATA_CONSEGNA_CONFERMA DATE,
DATA_CONSEGNA_AGG              DATE,
DATA_MANCATA_CONSEGNA_AGG      DATE  ,
DATA_CONSEGNA_ANN              DATE,
DATA_MANCATA_CONSEGNA_ANN      DATE
)
/