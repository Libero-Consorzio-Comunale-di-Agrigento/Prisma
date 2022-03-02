--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_PARA_TC runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER "AG_PARA_TC"
/******************************************************************************
 NOME:        AG_PARA_TC
 DESCRIZIONE: TRIGGER FOR CUSTOM FUNCTIONAL CHECK
                    AFTER INSERT OR UPDATE OR DELETE ON TABLE DATI
 ANNOTAZIONI: ESEGUE OPERAZIONI DI POST EVENT PRENOTATE.
 REVISIONI:
 REV. DATA       AUTORE DESCRIZIONE
 ---- ---------- ------ ------------------------------------------------------
 0    __/__/____ __     PRIMA EMISSIONE.
******************************************************************************/
   AFTER INSERT OR UPDATE OR DELETE ON PARAMETRI
BEGIN
   /* EXEC POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   INTEGRITYPACKAGE.EXEC_POSTEVENT;
END;
/
