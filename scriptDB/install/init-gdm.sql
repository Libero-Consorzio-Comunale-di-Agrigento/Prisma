--liquibase formatted sql
--changeset esasdelli:20200220_INIT_AGSPR
--preconditions onFail:CONTINUE
--precondition-sql-check expectedResult:1 SELECT count(1) FROM user_tables where table_name = 'AG_ABILITAZIONI_SMISTAMENTO'
Insert into DATABASECHANGELOG
   (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, EXECTYPE, MD5SUM, DESCRIPTION, LIQUIBASE, DEPLOYMENT_ID)
 Values
   ('20200219_AGSPR', 'esasdelli', 'install/02.gdm.sql', TO_TIMESTAMP('20/02/2020 14:27:16,198173','DD/MM/YYYY HH24:MI:SS,FF'), 1,
    'EXECUTED', '8:46f441a57e78c3794c89d8c2d0003790', 'sql', '3.8.6', '2205179899')
/