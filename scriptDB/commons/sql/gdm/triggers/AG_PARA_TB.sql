--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_PARA_TB runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER "AG_PARA_TB"
/******************************************************************************
 NOME:        AG_PARA_TB
 DESCRIZIONE: TRIGGER FOR CUSTOM FUNCTIONAL CHECK
                       AT INSERT OR UPDATE OR DELETE ON TABLE DATI
 ANNOTAZIONI: ESEGUE INIZIALIZZAZIONE TABELLA DI POST EVENT.
 REVISIONI:
 REV. DATA       AUTORE DESCRIZIONE
 ---- ---------- ------ ------------------------------------------------------
 0    __/__/____ __     PRIMA EMISSIONE.
******************************************************************************/
   BEFORE INSERT OR UPDATE OR DELETE ON PARAMETRI
BEGIN
   /* RESET POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   IF INTEGRITYPACKAGE.GETNESTLEVEL = 0 THEN
      INTEGRITYPACKAGE.INITNESTLEVEL;
   END IF;
END;
/
