--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_LOG_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON AG_LOG
   FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   FOUND             BOOLEAN;
   inizio            date;
BEGIN
   BEGIN                                                 -- Set DATA Integrity
      /* NONE */
      NULL;
   END;

   BEGIN                                           -- Set FUNCTIONAL Integrity
      IF IntegrityPackage.GetNestLevel = 0
      THEN
         IntegrityPackage.NextNestLevel;

         BEGIN                       -- Global FUNCTIONAL Integrity at Level 0
            /* NONE */
            NULL;
         END;

         IntegrityPackage.PreviousNestLevel;
      END IF;

      IntegrityPackage.NextNestLevel;

      BEGIN                          -- Full FUNCTIONAL Integrity at Any Level
         IF :NEW.LOG_ID IS NULL
         THEN
            SELECT AG_LOG_SQ.NEXTVAL INTO :NEW.LOG_ID FROM DUAL;
         END IF;
      END;

      IntegrityPackage.PreviousNestLevel;

      IF     :new.LOG_ELAPSED_TIME IS NULL
         AND :new.LOG_TITLE = 'Protocolla (flex) fine'
      THEN
         SELECT LOG_DATE
           INTO inizio
           FROM ag_log
          WHERE log_id =
                   (SELECT MAX (log_id)
                      FROM ag_log
                     WHERE     LOG_USER = :new.log_user
                           AND log_title = 'Protocolla (flex)');
         -- IN MILLISECONDI
         :new.LOG_ELAPSED_TIME := (:new.LOG_DATE - inizio)  * 24 * 60 * 60 * 1000;
      END IF;
   END;
EXCEPTION
   WHEN integrity_error
   THEN
      IntegrityPackage.InitNestLevel;
      raise_application_error (errno, errmsg);
   WHEN OTHERS
   THEN
      IntegrityPackage.InitNestLevel;
      RAISE;
END;
/
