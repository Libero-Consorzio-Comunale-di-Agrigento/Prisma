--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SOPR_TB runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER "AG_SOPR_TB"
   /******************************************************************************
    NOME:        DATI_TB
    DESCRIZIONE: TRIGGER FOR CUSTOM FUNCTIONAL CHECK
                          AT INSERT OR UPDATE OR DELETE ON TABLE DATI
    ANNOTAZIONI: ESEGUE INIZIALIZZAZIONE TABELLA DI POST EVENT.
    REVISIONI:
    REV. DATA       AUTORE DESCRIZIONE
    ---- ---------- ------ ------------------------------------------------------
    0    21/03/2018 SC     PRIMA EMISSIONE.
   ******************************************************************************/
   BEFORE INSERT OR UPDATE OR DELETE
   ON SEG_SOGGETTI_PROTOCOLLO
BEGIN
   /* RESET POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   IF INTEGRITYPACKAGE.GETNESTLEVEL = 0
   THEN
      INTEGRITYPACKAGE.INITNESTLEVEL;
   END IF;
END;
/
