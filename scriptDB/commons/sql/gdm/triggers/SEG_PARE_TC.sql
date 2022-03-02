--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_SEG_PARE_TC runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER
"SEG_PARE_TC"
/******************************************************************************
 NOME:  AG_PARE_TC
 DESCRIZIONE: TRIGGER FOR CUSTOM FUNCTIONAL CHECK
                    AFTER INSERT OR UPDATE OR DELETE ON TABLE DATI
 ANNOTAZIONI: ESEGUE OPERAZIONI DI POST EVENT PRENOTATE.
 REVISIONI:
 REV. DATA       AUTORE DESCRIZIONE
 ---- ---------- ------ ------------------------------------------------------
 0    __/__/____ __     PRIMA EMISSIONE.
******************************************************************************/
   AFTER INSERT OR UPDATE OR DELETE ON SEG_PARAMETRI_REGG
BEGIN
   /* EXEC POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   INTEGRITYPACKAGE.EXEC_POSTEVENT;
END;
/
