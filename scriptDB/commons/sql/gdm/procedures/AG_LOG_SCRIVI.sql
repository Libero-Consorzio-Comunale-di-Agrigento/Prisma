--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_LOG_SCRIVI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE     AG_LOG_SCRIVI (P_USER     VARCHAR2,
                                           P_TITLE     VARCHAR2,
                                           P_TEXT      CLOB,
                                           P_ELAPSED_TIME VARCHAR2,
                                           P_LEVEL    VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   d_is_log_attivo varchar2(100);
BEGIN

   select nvl(max(valore), 'N')
     into d_is_log_attivo
     from parametri
    where codice = 'AG_LOG'	
      and tipo_modello = '@agStrut@';

   if d_is_log_attivo = 'Y' then
       INSERT INTO AG_LOG (LOG_DATE,
                           LOG_TITLE,
                           LOG_TEXT,
                           LOG_USER,
                           LOG_ELAPSED_TIME,
                           LOG_LEVEL)
            VALUES (SYSDATE,
                    P_TITLE,
                    P_TEXT,
                    P_USER,
                    P_ELAPSED_TIME,
                    P_LEVEL);

       COMMIT;
   end if;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      RAISE;
END;
/
