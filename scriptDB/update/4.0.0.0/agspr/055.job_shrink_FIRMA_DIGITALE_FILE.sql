--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_055.job_shrink_FIRMA_DIGITALE_FILE

DECLARE
  X NUMBER;
BEGIN
    SYS.DBMS_JOB.SUBMIT
    ( job       => X 
     ,what      => 'BEGIN
execute immediate ''alter table FIRMA_DIGITALE_FILE modify lob (FILE_DA_FIRMARE) (SHRINK SPACE)'';
execute immediate ''alter table FIRMA_DIGITALE_FILE modify lob (FILE_FIRMATO) (SHRINK SPACE)'';
END;'
     ,interval  => 'to_date(to_char(sysdate + 1, ''dd/mm/yyyy'')||'' 01:00:00'', ''dd/mm/yyyy hh24:mi:ss'')'
     ,no_parse  => FALSE
    );
  COMMIT;
END;
/
