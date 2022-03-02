--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_PARAMETRI_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_PARAMETRI_TIU
   AFTER UPDATE
   ON PARAMETRI
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            VARCHAR2 (200);
/******************************************************************************
   NAME:       AG_PARAMETRI_TIU
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/01/2016      SCaputo       1. Created this trigger.
   NOTES:
   Automatically available Auto Replace Keywords:
      Object Name:     AG_PARAMETRI_TIU
      Sysdate:         28/01/2016
      Date and Time:   28/01/2016, 11:24:47, and 28/01/2016 11:24:47
      Username:        SCaputo (set in TOAD Options, Proc Templates)
      Table Name:      PARAMETRI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF     (   :NEW.CODICE LIKE 'DATA_REG_PROT_%'
           OR :NEW.CODICE LIKE 'FIRMA_REG_PROT_%'
           OR :NEW.CODICE LIKE 'CONS_ATTIVA_%'
           OR :NEW.CODICE LIKE 'TIPO_DOC_REG_PROT_%'
           OR :NEW.CODICE LIKE 'TIPO_ALL_REG_MOD_%'
           OR :NEW.CODICE LIKE 'RESP_GEST_DOC_%'
           OR :NEW.CODICE IN ('CRON_STAMPA_REG_PROT',
                              'CRON_PROTOCOLLA_REG_PROT'))
      AND integritypackage.getnestlevel = 0
   THEN
      raise_application_error (
         -20999,
         'Modifica consentita solo da workarea Amministrazione -> Parametri -> Registro giornaliero');
   END IF;

   declare
      a_messaggio varchar2(32000);
      a_istruzione varchar2(32000);
   BEGIN
      IF  (UPDATING OR INSERTING)
      AND (:NEW.CODICE LIKE 'TITOLI_ROMANI'
       OR :NEW.CODICE LIKE 'CLASSFASC_RICERCA_MAX_NUM') THEN
         a_messaggio :=
                    'Il Parametro CLASSFASC_RICERCA_MAX_NUM ha valore superiore a 300.';
         a_istruzione :=
            'Begin '
            || '   AG_PARA_RRI('''||:NEW.CODICE||''', '''||:NEW.TIPO_MODELLO||''', '''||:NEW.VALORE||'''); '
            || 'end; ';
         integritypackage.set_postevent (a_istruzione, a_messaggio);
      END IF;
   END;
   BEGIN
      IF integritypackage.getnestlevel = 0
      THEN
         integritypackage.nextnestlevel;
         BEGIN
            /* NONE */
            NULL;
         END;
         integritypackage.previousnestlevel;
      END IF;
      integritypackage.nextnestlevel;
      BEGIN
         /* NONE */
         NULL;
      END;
      integritypackage.previousnestlevel;
   END;
EXCEPTION
   WHEN integrity_error
   THEN
      integritypackage.initnestlevel;
      raise_application_error (errno, errmsg);
   WHEN OTHERS
   THEN
      integritypackage.initnestlevel;
      RAISE;
END AG_PARAMETRI_TIU;
/
