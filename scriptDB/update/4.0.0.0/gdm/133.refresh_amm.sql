--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_133.refresh_amm failOnError:false

DECLARE
  X NUMBER;
BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'begin AGG_SEG_AMM_AOO_UO(); end;'
     ,next_date => sysdate
     ,no_parse  => FALSE
    );
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
  COMMIT;
END;
/