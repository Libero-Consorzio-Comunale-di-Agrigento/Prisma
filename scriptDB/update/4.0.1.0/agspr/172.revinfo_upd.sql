--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_72020010_172.revinfo_upd

UPDATE REVINFO
   SET REVTSTMP =
          TO_TIMESTAMP (
                SUBSTR (TO_CHAR (REVTSTMP, 'DD/MM/YYYY HH24:MI:SS.FF'), 1, 6)
             || '20'
             || SUBSTR (TO_CHAR (REVTSTMP, 'DD/MM/YYYY HH24:MI:SS.FF'), 9),
             'DD/MM/YYYY HH24:MI:SS.FF')
 WHERE SUBSTR (TO_CHAR (REVTSTMP, 'DD/MM/YYYY HH24:MI:SS.FF'), 7, 2) = '00'
/
