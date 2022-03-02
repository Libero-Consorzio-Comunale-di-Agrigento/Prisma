--liquibase formatted sql
--changeset esasdelli:4.1.0.0_20200827_23.job_trasco_fascicoli

DECLARE
  X NUMBER;
BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X 
     ,what      => 'DECLARE I NUMBER; BEGIN I := AGP_TRASCO_FASCICOLO_PKG.TRASCO; END;'
     ,no_parse  => FALSE
    );
  COMMIT;
END;
/
