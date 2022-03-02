--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_FASC_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_fasc_tiu
   BEFORE INSERT OR UPDATE OF class_cod,
                              class_dal,
                              fascicolo_anno,
                              fascicolo_numero,
                              stato_scarto
   ON seg_fascicoli
   FOR EACH ROW
DECLARE
   a_messaggio       VARCHAR2 (32000);
   a_istruzione      VARCHAR2 (32000);
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
/******************************************************************************
   NAME:       AG_FASC_TIU.
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/03/2009  SC           1. Created this trigger. A31537.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_FASC_TIU
      Sysdate:         03/03/2009
      Date and Time:   03/032009, 16.23.00, and 17/02/2009 16.23.00
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      SEG_FASCICOLI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF :NEW.idrif IS NULL
   THEN
      SELECT seq_idrif.NEXTVAL
        INTO :NEW.idrif
        FROM DUAL;
   END IF;

   BEGIN
      IF     :NEW.class_cod IS NOT NULL
         AND :NEW.class_dal IS NOT NULL
         AND :NEW.fascicolo_anno IS NOT NULL
         AND :NEW.fascicolo_numero IS NOT NULL
      THEN
         a_messaggio :=
                   'Fascicolo ' || :NEW.class_cod ||' '||:NEW.fascicolo_anno ||'/'||:NEW.fascicolo_numero
                   || ' ('||:NEW.id_documento||')'
                   ||' per amministrazione '||:NEW.codice_amministrazione||' e aoo '||:NEW.codice_aoo
                   || ' gia'' presente ';
         a_istruzione :=
               'Begin '
            || '   AG_FASC_RRI('
            || :NEW.id_documento
            || ', '''
            || :NEW.class_cod
            || ''', TO_DATE('''
            || TO_CHAR (:NEW.class_dal, 'DD/MM/YYYY')
            || ''', ''DD/MM/YYYY''), '
            || :NEW.fascicolo_anno
            || ', '''
            || :NEW.fascicolo_numero
            || ''', '''
            || :NEW.codice_amministrazione
            || ''', '''
            || :NEW.codice_aoo
            || '''); '
            || 'end; ';
         integritypackage.set_postevent (a_istruzione, a_messaggio);
      END IF;
   END;

   BEGIN
      IF NVL (:NEW.stato_scarto, '**') != NVL (:OLD.stato_scarto, '**')
      THEN
         :NEW.data_stato_scarto := SYSDATE;
      END IF;
   END;

   BEGIN
      IF     NVL (:NEW.stato_scarto, '**') != NVL (:OLD.stato_scarto, '**')
         AND :NEW.stato_scarto = 'AA'
      THEN
         IF    :NEW.descrizione_scarto IS NULL
            OR :NEW.anno_minimo_scarto IS NULL
            OR :NEW.ubicazione_scarto IS NULL
            OR :NEW.anno_massimo_scarto IS NULL
            OR :NEW.peso_scarto IS NULL
            OR :NEW.pezzi_scarto IS NULL
         THEN
            raise_application_error
               (-20999,
                'Dettagli della richiesta di approvazione dello scarto incompleti (operazione consentita solo da apposita maschera ''Fascicoli da scartare'').'
               );
         END IF;

         :NEW.data_stato_scarto := SYSDATE;
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
END ag_fasc_tiu;
/
