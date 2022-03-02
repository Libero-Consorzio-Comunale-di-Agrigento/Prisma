--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_SEG_PARE_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER SEG_PARE_TU
   AFTER UPDATE
   ON SEG_PARAMETRI_REGG
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   tmpVar            VARCHAR2 (1000);
   tmpNumber         NUMBER;
   tmpDate           DATE;
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            VARCHAR2 (200);
/******************************************************************************
   NAME:       SEG_PARE_TU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/01/2016      SCaputo       1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SEG_PARE_TU
      Sysdate:         26/01/2016
      Date and Time:   26/01/2016, 12:16:17, and 26/01/2016 12:16:17
      Username:        SCaputo (set in TOAD Options, Proc Templates)
      Table Name:      SEG_PARAMETRI_REGG (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF :new.parametro = 'DATA_REG_PROT'
   THEN
      BEGIN
         SELECT 1
           INTO tmpNumber
           FROM DUAL
          WHERE LENGTH (SUBSTR (:new.valore,
                                  INSTR (:new.valore,
                                         '/',
                                         1,
                                         2)
                                + 1)) = 4;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
               'La data deve essere nel formato dd/mm/yyyy');
      END;

      BEGIN
         SELECT TO_DATE (:new.valore, 'dd/mm/yyyy') INTO tmpDate FROM DUAL;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
               'La data deve essere nel formato dd/mm/yyyy');
      END;
   END IF;

   IF :new.parametro = 'FIRMA_REG_PROT' OR :NEW.PARAMETRO = 'CONS_ATTIVA'
   THEN
      IF :new.valore NOT IN ('Y', 'N')
      THEN
         raise_application_error (-20999, 'Valori ammessi Y/N');
      END IF;
   END IF;

   IF :new.parametro = 'TIPO_DOC_REG_PROT'
   THEN
      BEGIN
         SELECT TIDO.TIPO_DOCUMENTO
           INTO tmpVar
           FROM seg_tipi_documento tido, documenti docu
          WHERE     TIDO.TIPO_DOCUMENTO = :new.valore
                AND docu.id_documento = tido.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (-20999, 'Tipo documento inesistente');
      END;
   END IF;

   IF :new.parametro = 'TIPO_ALL_REG_MOD'
   THEN
      BEGIN
         SELECT TIDO.TIPO_ALLEGATO
           INTO tmpVar
           FROM seg_tipi_allegato tido, documenti docu
          WHERE     TIDO.TIPO_ALLEGATO = :new.valore
                AND docu.id_documento = tido.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (-20999, 'Tipo allegato inesistente');
      END;
   END IF;

   IF :new.parametro = 'RESP_GEST_DOC'
   THEN
      BEGIN
         SELECT cognome
           INTO tmpVar
           FROM as4_soggetti
          WHERE as4_soggetti.ni = :new.valore;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
               'Il responsabile della gestione documentale deve essere presente in anagrafica.');
      END;
   END IF;

   DECLARE
      dep_parametro      VARCHAR2 (100);
      dep_tipo_modello   VARCHAR2 (100);
      a_messaggio        VARCHAR2 (1000);
      a_istruzione       VARCHAR2 (32000);
   BEGIN
      a_messaggio := 'Parametro non modificabile ';

      IF :new.parametro IN ('DATA_REG_PROT',
                            'FIRMA_REG_PROT',
                            'CONS_ATTIVA',
                            'TIPO_DOC_REG_PROT',
                            'TIPO_ALL_REG_MOD',
                            'RESP_GEST_DOC')
      THEN
         SELECT    :new.parametro
                || '_'
                || (SELECT SUBSTR (codice,
                                   DECODE (INSTR (codice,
                                                  '_',
                                                  1,
                                                  2),
                                           0, TO_NUMBER (NULL),
                                           (  INSTR (codice,
                                                     '_',
                                                     1,
                                                     2)
                                            + 1)),
                                   LENGTH (codice))
                      FROM parametri
                     WHERE     valore = :new.codice_aoo
                           AND tipo_modello = '@agVar@'
                           AND codice IN (SELECT    'CODICE_AOO_'
                                                 || SUBSTR (
                                                       codice,
                                                       DECODE (
                                                          INSTR (codice,
                                                                 '_',
                                                                 1,
                                                                 2),
                                                          0, TO_NUMBER (NULL),
                                                          (  INSTR (codice,
                                                                    '_',
                                                                    1,
                                                                    2)
                                                           + 1)),
                                                       LENGTH (codice))
                                            FROM parametri
                                           WHERE     valore =
                                                        :new.codice_amministrazione
                                                 AND tipo_modello = '@agVar@'
                                                 AND codice LIKE
                                                        'CODICE_AMM_' || '%'))
           INTO dep_parametro
           FROM DUAL;

         dep_tipo_modello := '@agVar@';
      ELSE
         dep_parametro := :new.parametro;
         dep_tipo_modello := '@agStrut@';
      END IF;

      a_istruzione :=
            'Begin '
         || '   AG_PARE_RRI('''
         || dep_parametro
         || ''', '''
         || :NEW.valore
         || ''', '''
         || dep_tipo_modello
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
END SEG_PARE_TU;
/
