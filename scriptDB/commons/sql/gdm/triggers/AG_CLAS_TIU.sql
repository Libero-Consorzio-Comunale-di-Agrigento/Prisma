--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_CLAS_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_CLAS_TIU
BEFORE INSERT OR UPDATE
OF CLASS_COD
  ,CLASS_DAL
ON SEG_CLASSIFICAZIONI
FOR EACH ROW
DECLARE
   a_messaggio       VARCHAR2 (32000);
   a_istruzione      VARCHAR2 (32000);
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            VARCHAR2 (200);
/******************************************************************************
   NAME:       AG_CLAS_TIU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/02/2009  SC           1. Created this trigger. A25969.0.2 D526.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CLAS_TIU
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.23.00, and 17/02/2009 16.23.00
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      SEG_CLASSIFICAZIONI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF UPDATING
   THEN
      IF :NEW.class_cod IS NULL
      THEN
         raise_application_error (-20999,
                                  'Codice Classificazione obbligatorio.'
                                 );
      END IF;

      IF :NEW.class_descr IS NULL
      THEN
         raise_application_error (-20999,
                                  'Descrizione Classificazione obbligatoria.'
                                 );
      END IF;

      IF :NEW.class_dal IS NULL
      THEN
         raise_application_error
                     (-20999,
                      'Data di inizio validita'' Classificazione obbligatoria.'
                     );
      END IF;

      IF :NEW.contenitore_documenti IS NULL
      THEN
         raise_application_error (-20999, 'Campo In Uso obbligatorio.');
      END IF;

      IF :NEW.num_illimitata IS NULL
      THEN
         raise_application_error
                                (-20999,
                                 'Campo Numerazione Illimitata obbligatorio.'
                                );
      END IF;

      IF :NEW.data_creazione IS NULL
      THEN
         raise_application_error (-20999,
                                  'Campo Data Creazione obbligatorio.'
                                 );
      END IF;
   END IF;

   declare
      d_data_dal varchar2(10);
      d_data_al  varchar2(10);
   BEGIN
      a_messaggio :=
                    'Classificazione ' || :NEW.class_cod
                    || ' gia'' presente ';
      d_data_dal := to_char(:NEW.class_dal, 'dd/mm/yyyy');
      d_data_al := to_char(:NEW.class_al, 'dd/mm/yyyy');
      a_istruzione :=
            'Begin '
         || '   AG_CLAS_RRI('
         || :NEW.id_documento
         || ', '''
         || :NEW.class_cod
         || ''', to_date('''
         || d_data_dal
         || ''', ''DD/MM/YYYY'')'
         || ', TO_DATE('''
         || d_data_al
         || ''', ''DD/MM/YYYY'')'
         || ', '''
         || :NEW.codice_amministrazione
         || ''', '''
         || :NEW.codice_aoo
         || '''); '
         || 'end; ';
      integritypackage.set_postevent (a_istruzione, a_messaggio);
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
END ag_clas_tiu;
/
