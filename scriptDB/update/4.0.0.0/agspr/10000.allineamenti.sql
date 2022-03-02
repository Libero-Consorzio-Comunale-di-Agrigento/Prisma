--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_10000.rinomina_ags_classificazioni
begin
execute immediate 'DROP TRIGGER AGS_CLASSIFICAZIONI_NEW_TAIU';
exception when others then
    null;
end;
/

begin
execute immediate 'DROP TRIGGER AGS_CLASSIFICAZIONI_NEW_TB';
exception when others then
    null;
end;
/

begin
execute immediate 'DROP TRIGGER AGS_CLASSIFICAZIONI_NEW_TC';
exception when others then
    null;
end;
/

begin
execute immediate 'DROP TRIGGER AGS_CLASSIFICAZIONI_NEW_TIU';
exception when others then
    null;
end;
/

begin
execute immediate 'RENAME AGS_CLASSIFICAZIONI TO AGS_CLASSIFICAZIONI_OLD';
exception when others then
    null;
end;
/

begin
execute immediate 'RENAME AGS_CLASSIFICAZIONI_NEW TO AGS_CLASSIFICAZIONI';
exception when others then
    null;
end;
/