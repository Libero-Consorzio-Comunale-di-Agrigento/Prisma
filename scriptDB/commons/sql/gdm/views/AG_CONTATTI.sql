--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_AG_CONTATTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AG_CONTATTI" ("ID_RECAPITO", "ID_CONTATTO", "TIPO_SPEDIZIONE", "VALORE", "DAL", "AL") AS 
  SELECT cont.id_recapito,
          cont.id_contatto,
          tico.tipo_spedizione,
          cont.valore,
          cont.dal,
          cont.al
     FROM as4_contatti cont, as4_tipi_contatto tico
    WHERE tico.id_tipo_contatto = cont.id_tipo_contatto

/
