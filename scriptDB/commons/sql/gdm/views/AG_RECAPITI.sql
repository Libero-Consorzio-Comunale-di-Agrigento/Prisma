--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_AG_RECAPITI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AG_RECAPITI" ("NI", "ID_RECAPITO", "ID_TIPO_RECAPITO", "DESCRIZIONE", "INDIRIZZO", "CAP", "COMUNE", "PROVINCIA", "DAL", "AL") AS 
  SELECT reca.ni,
          reca.id_recapito,
          tire.id_tipo_recapito,
          tire.descrizione,
          RECA.INDIRIZZO,
          reca.cap,
          COMU.DENOMINAZIONE,
          PROV.SIGLA,
          reca.dal,
          reca.al
     FROM as4_recapiti reca,
          ad4_comuni comu,
          ad4_province prov,
          as4_tipi_recapito tire
    WHERE     RECA.COMUNE = COMU.COMUNE(+)
          AND RECA.PROVINCIA = COMU.PROVINCIA_STATO(+)
          AND COMU.PROVINCIA_STATO = prov.provincia(+)
          AND tire.id_tipo_recapito = reca.id_tipo_recapito

/
