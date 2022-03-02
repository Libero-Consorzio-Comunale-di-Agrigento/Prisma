--liquibase formatted sql
--changeset esasdelli:4.0.1.0_20200221_181.ag_inserisci_id_padre failOnError:false

DECLARE
  X NUMBER;
BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'begin ag_sistema_id_padre; end;'
     ,next_date => SYSDATE
     ,no_parse  => FALSE
    );
  COMMIT;
END;
/