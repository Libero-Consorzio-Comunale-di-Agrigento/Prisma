--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_01.drop-oggetti-non-utilizzati
begin
execute immediate 'drop PACKAGE AGP_DATI_AGGIUNTIVI_PKG';
exception when others then
    null;
end;
/

begin
execute immediate 'drop trigger GDO_REGISTRI_TIO';
exception when others then
    null;
end;
/

begin
execute immediate 'drop trigger GDO_TIPI_ALLEGATO_TIO';
exception when others then
    null;
end;
/

begin
execute immediate 'drop view GDO_TIPI_ALLEGATO_VIEW';
exception when others then
    null;
end;
/

begin
execute immediate 'drop trigger GDO_TIPI_DOCUMENTO_TIO';
exception when others then
    null;
end;
/

begin
execute immediate 'drop view GDO_TIPI_DOCUMENTO_VIEW';
exception when others then
    null;
end;
/

-- elimino il sinonimo se presente perché è diventato una vista
begin
    execute immediate 'drop synonym AG_PRIV_UTENTE_TMP';
exception when others then
    null;
end;
/
-- elimino il sinonimo se presente perché è diventato una vista
begin
    execute immediate 'drop synonym AG_RADICI_AREA_UTENTE_TMP';
exception when others then
    null;
end;
/
-- elimino il sinonimo se presente perché è diventato una vista
begin
    execute immediate 'drop synonym SNAP_USER_SOURCE_CREATE_PKG';
exception when others then
    null;
end;
/

-- tento di creare questa tabella che non è chiaro quando c'è e quando no:
begin
    execute immediate 'CREATE GLOBAL TEMPORARY TABLE TEMP_DOCUMENTI_DATI_RIFIUTO
(
   ID_DOCUMENTO_GDM   NUMBER NOT NULL,
   DATA_SMISTAMENTO   DATE,
   UTENTE_RIFIUTO     VARCHAR2 (20),
   DATA_RIFIUTO       DATE,
   MOTIVO_RIFIUTO     VARCHAR2 (4000)
) ON COMMIT DELETE ROWS';
exception when others then
    null;
end;
/
