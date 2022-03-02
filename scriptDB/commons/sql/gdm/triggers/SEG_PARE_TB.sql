--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_SEG_PARE_TB runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER "SEG_PARE_TB"
/******************************************************************************
 NOME:  AG_PARE_TB
 DESCRIZIONE: TRIGGER FOR CUSTOM FUNCTIONAL CHECK
                       AT INSERT OR UPDATE OR DELETE ON TABLE DATI
 ANNOTAZIONI: ESEGUE INIZIALIZZAZIONE TABELLA DI POST EVENT.
 REVISIONI:
 REV. DATA       AUTORE DESCRIZIONE
 ---- ---------- ------ ------------------------------------------------------
 0    __/__/____ __     PRIMA EMISSIONE.
******************************************************************************/
   BEFORE INSERT OR UPDATE OR DELETE ON SEG_PARAMETRI_REGG
BEGIN
   /* RESET POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   IF INTEGRITYPACKAGE.GETNESTLEVEL = 0 THEN
      INTEGRITYPACKAGE.INITNESTLEVEL;
   END IF;
END;
/
