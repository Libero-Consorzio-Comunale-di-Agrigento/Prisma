--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_012.ags_tipi_spedizione
-- in fase di installazione, potrei non avere questa vista. Quindi la creo
CREATE OR REPLACE FORCE VIEW ags_tipi_spedizione
(
   ID_TIPO_SPEDIZIONE,
   DESCRIZIONE,
   CODICE,
   BARCODE_ESTERO,
   BARCODE_ITALIA,
   STAMPA,
   DATA_UPD,
   UTENTE_UPD,
   VALIDO
)
AS
   SELECT -ts.id_documento AS id_tipo_spedizione,
          ts.descrizione,
          ts.tipo_spedizione AS codice,
          CAST (ts.barcode_estero AS CHAR (1)) barcode_estero,
          CAST (ts.barcode_italia AS CHAR (1)) barcode_italia,
          CAST (ts.stampa AS CHAR (1)) stampa,
          d.data_aggiornamento data_upd,
          d.utente_aggiornamento utente_upd,
          CAST (DECODE (d.stato_documento, 'CA', 'N', 'Y') AS CHAR (1))
             AS valido
     FROM gdm_tipi_spedizione ts, gdm_documenti d
    WHERE d.id_documento = ts.id_documento
/
rename ags_tipi_spedizione to ags_tipi_spedizione_tmp
/
create table ags_tipi_spedizione (id_tipo_spedizione   number not null
                                , descrizione          varchar2 (2000) not null
                                , codice               varchar2 (255) not null
                                , barcode_estero       char (1) default 'N' not null
                                , barcode_italia       char (1) default 'Y' not null
                                , stampa               char (1) default 'N' not null
                                , id_documento_esterno number not null
                                , id_ente              number not null
                                , valido               char (1) default 'Y' not null
                                , utente_ins           varchar2 (255) not null
                                , data_ins             date not null
                                , utente_upd           varchar2 (255) not null
                                , data_upd             date not null
                                , version              number not null)
/

create index ags_tipspe_enti_fk
   on ags_tipi_spedizione (id_ente)
/

create unique index ags_tipi_spedizione_pk
   on ags_tipi_spedizione (id_tipo_spedizione)
/

alter table ags_tipi_spedizione add (
  constraint ags_tipi_spedizione_pk
  primary key
  (id_tipo_spedizione)
  using index ags_tipi_spedizione_pk
  enable validate)
/

alter table ags_tipi_spedizione add (
  constraint ags_tipspe_enti_fk
  foreign key (id_ente)
  references gdo_enti (id_ente)
  enable validate)
/

begin
   for c in (select t.id_tipo_spedizione
                  , t.descrizione
                  , t.codice
                  , t.barcode_estero
                  , t.barcode_italia
                  , t.stampa
                  , t.data_upd
                  , t.utente_upd
                  , t.valido
                  , e.id_ente
               from ags_tipi_spedizione_tmp t, gdo_enti e) -- devo copiare i tipi di spedizione per ogni ente.
   loop
      insert into ags_tipi_spedizione (barcode_estero
                                     , barcode_italia
                                     , codice
                                     , data_ins
                                     , data_upd
                                     , descrizione
                                     , id_documento_esterno
                                     , id_ente
                                     , id_tipo_spedizione
                                     , stampa
                                     , utente_ins
                                     , utente_upd
                                     , valido
                                     , version)
           values (c.barcode_estero
                 , c.barcode_italia
                 , c.codice
                 , c.data_upd
                 , c.data_upd
                 , c.descrizione
                 , - c.id_tipo_spedizione
                 , c.id_ente
                 , c.id_tipo_spedizione
                 , c.stampa
                 , c.utente_upd
                 , c.utente_upd
                 , c.valido
                 , 0);
   end loop;
   commit;
end;
/

drop view ags_tipi_spedizione_tmp
/
