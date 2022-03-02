--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SOPR_TC runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER "AG_SOPR_TC"
   /******************************************************************************
    NOME:        DATI_TC
    DESCRIZIONE: TRIGGER FOR CUSTOM FUNCTIONAL CHECK
                       AFTER INSERT OR UPDATE OR DELETE ON TABLE DATI
    ANNOTAZIONI: ESEGUE OPERAZIONI DI POST EVENT PRENOTATE.
    REVISIONI:
    REV. DATA       AUTORE DESCRIZIONE
    ---- ---------- ------ ------------------------------------------------------
    0    21/03/2018 SC     PRIMA EMISSIONE.
   ******************************************************************************/
   AFTER INSERT OR UPDATE OR DELETE
   ON SEG_SOGGETTI_PROTOCOLLO
BEGIN
   /* EXEC POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   INTEGRITYPACKAGE.EXEC_POSTEVENT;
END;
/
