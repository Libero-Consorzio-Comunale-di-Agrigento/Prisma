--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_013.ags_modalita_invio_ricezione failOnError:false
-- in caso di prima installazione, questa vista non c'è:
CREATE OR REPLACE FORCE VIEW AGS_MODALITA_INVIO_RICEZIONE
(
   ID_MODALITA_INVIO_RICEZIONE,
   DESCRIZIONE,
   CODICE,
   ID_TIPO_SPEDIZIONE,
   COSTO,
   ID_ENTE,
   VALIDO_DAL,
   VALIDO_AL,
   DATA_INS,
   UTENTE_INS,
   DATA_UPD,
   UTENTE_UPD,
   VALIDO,
   VERSION
)
AS
   SELECT -m.id_documento AS id_modalita_invio_ricezione,
          descrizione_mod_ricevimento AS descrizione,
          mod_ricevimento AS codice,
          ts.id_documento AS id_tipo_spedizione,
          costo_euro AS costo,
          enti.id_ente,
          dataval_dal AS valido_dal,
          dataval_al AS valido_al,
          TO_DATE (NULL) data_ins,
          NULL utente_ins,
          d.data_aggiornamento data_upd,
          d.utente_aggiornamento utente_upd,
          CAST (DECODE (d.stato_documento, 'CA', 'N', 'Y') AS CHAR (1))
             AS valido,
          0 version
     FROM gdm_modalita_invio_ricezione m,
          gdm_tipi_spedizione ts,
          gdm_documenti d,
          gdo_enti enti
    WHERE     ts.tipo_spedizione(+) = m.tipo_spedizione
          AND d.id_documento = m.id_documento
          AND enti.amministrazione = m.codice_amministrazione
          AND enti.aoo = m.codice_aoo
          AND enti.ottica = gdm_ag_parametro.get_valore (
                               'SO_OTTICA_PROT',
                               m.codice_amministrazione,
                               m.codice_aoo,
                               '')
/

rename ags_modalita_invio_ricezione to ags_modalita_invio_ricez_tmp
/

create table ags_modalita_invio_ricezione (id_modalita_invio_ricezione   number not null
                                         , descrizione                   varchar2 (255) not null
                                         , codice                        varchar2 (255)
                                         , id_tipo_spedizione            number
                                         , costo                         number
                                         , id_documento_esterno number not null
                                         , id_ente                       number not null
                                         , valido_dal                    date not null
                                         , valido_al                     date
                                         , data_ins                      date not null
                                         , utente_ins                    varchar2 (255) not null
                                         , data_upd                      date not null
                                         , utente_upd                    varchar2 (255) not null
                                         , valido                        char (1) default 'Y' not null
                                         , version                       number not null)
/


create index ags_modinvric_agstipspe_fk
   on ags_modalita_invio_ricezione (id_tipo_spedizione)
/


create unique index ags_modalita_invioricez_pk
   on ags_modalita_invio_ricezione (id_modalita_invio_ricezione)
/


create index ags_modinvric_enti_fk
   on ags_modalita_invio_ricezione (id_ente)
/


alter table ags_modalita_invio_ricezione add (
  constraint ags_modalita_invioricez_pk
  primary key
  (id_modalita_invio_ricezione)
  using index ags_modalita_invioricez_pk
  enable validate)
/

alter table ags_modalita_invio_ricezione add (
  constraint ags_modinvric_enti_fk
  foreign key (id_ente)
  references gdo_enti (id_ente)
  enable validate,
  constraint ags_modinvric_tipspe_fk
  foreign key (id_tipo_spedizione)
  references ags_tipi_spedizione (id_tipo_spedizione)
  enable validate)
/

begin
   for c in (select id_modalita_invio_ricezione
                  , descrizione
                  , codice
                  , -id_tipo_spedizione id_tipo_spedizione
                  , costo
                  , id_ente
                  , valido_dal
                  , valido_al
                  , data_ins
                  , utente_ins
                  , data_upd
                  , utente_upd
                  , valido
                  , version
               from ags_modalita_invio_ricez_tmp)
   loop
      insert into ags_modalita_invio_ricezione (codice
                                              , costo
                                              , data_ins
                                              , data_upd
                                              , descrizione
                                              , id_documento_esterno
                                              , id_ente
                                              , id_modalita_invio_ricezione
                                              , id_tipo_spedizione
                                              , utente_ins
                                              , utente_upd
                                              , valido
                                              , valido_al
                                              , valido_dal
                                              , version)
           values (c.codice
                 , c.costo
                 , c.data_upd
                 , c.data_upd
                 , c.descrizione
                 , - c.id_modalita_invio_ricezione
                 , c.id_ente
                 , c.id_modalita_invio_ricezione
                 , c.id_tipo_spedizione
                 , c.utente_upd
                 , c.utente_upd
                 , c.valido
                 , c.valido_al
                 , nvl (c.valido_dal, to_date ('01/01/1970', 'dd/mm/yyyy'))
                 , c.version);
   end loop;

   commit;
end;
/

drop view ags_modalita_invio_ricez_tmp
/

create table ags_modalita_invio_ricezione (id_modalita_invio_ricezione   number not null
                                         , descrizione                   varchar2 (255) not null
                                         , codice                        varchar2 (255)
                                         , id_tipo_spedizione            number
                                         , costo                         number
                                         , id_documento_esterno number not null
                                         , id_ente                       number not null
                                         , valido_dal                    date not null
                                         , valido_al                     date
                                         , data_ins                      date not null
                                         , utente_ins                    varchar2 (255) not null
                                         , data_upd                      date not null
                                         , utente_upd                    varchar2 (255) not null
                                         , valido                        char (1) default 'Y' not null
                                         , version                       number not null)
/


create index ags_modinvric_agstipspe_fk
   on ags_modalita_invio_ricezione (id_tipo_spedizione)
/


create unique index ags_modalita_invioricez_pk
   on ags_modalita_invio_ricezione (id_modalita_invio_ricezione)
/


create index ags_modinvric_enti_fk
   on ags_modalita_invio_ricezione (id_ente)
/


alter table ags_modalita_invio_ricezione add (
  constraint ags_modalita_invioricez_pk
  primary key
  (id_modalita_invio_ricezione)
  using index ags_modalita_invioricez_pk
  enable validate)
/

alter table ags_modalita_invio_ricezione add (
  constraint ags_modinvric_enti_fk
  foreign key (id_ente)
  references gdo_enti (id_ente)
  enable validate,
  constraint ags_modinvric_tipspe_fk
  foreign key (id_tipo_spedizione)
  references ags_tipi_spedizione (id_tipo_spedizione)
  enable validate)
/

begin
   for c in (select id_modalita_invio_ricezione
                  , descrizione
                  , codice
                  , -id_tipo_spedizione id_tipo_spedizione
                  , costo
                  , id_ente
                  , valido_dal
                  , valido_al
                  , data_ins
                  , utente_ins
                  , data_upd
                  , utente_upd
                  , valido
                  , version
               from ags_modalita_invio_ricez_tmp)
   loop
      insert into ags_modalita_invio_ricezione (codice
                                              , costo
                                              , data_ins
                                              , data_upd
                                              , descrizione
                                              , id_documento_esterno
                                              , id_ente
                                              , id_modalita_invio_ricezione
                                              , id_tipo_spedizione
                                              , utente_ins
                                              , utente_upd
                                              , valido
                                              , valido_al
                                              , valido_dal
                                              , version)
           values (c.codice
                 , c.costo
                 , c.data_upd
                 , c.data_upd
                 , c.descrizione
                 , - c.id_modalita_invio_ricezione
                 , c.id_ente
                 , c.id_modalita_invio_ricezione
                 , c.id_tipo_spedizione
                 , c.utente_upd
                 , c.utente_upd
                 , c.valido
                 , c.valido_al
                 , nvl (c.valido_dal, to_date ('01/01/1970', 'dd/mm/yyyy'))
                 , c.version);
   end loop;

   commit;
end;
/

drop view ags_modalita_invio_ricez_tmp
/