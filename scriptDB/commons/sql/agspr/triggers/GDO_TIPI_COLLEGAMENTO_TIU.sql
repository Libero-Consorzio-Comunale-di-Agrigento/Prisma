--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_TIPI_COLLEGAMENTO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  trigger ${global.db.agspr.username}.gdo_tipi_collegamento_tiu
   before insert or update
   on ${global.db.agspr.username}.gdo_tipi_collegamento
   for each row
declare
   d_area_segreteria              varchar2 (255) := 'SEGRETERIA';
   d_area_segreteria_protocollo   varchar2 (255) := 'SEGRETERIA.PROTOCOLLO';
begin
   if length (:new.tipo_collegamento) > 10 then
      raise_application_error (-20999, 'Il codice del tipo collegamento non può essere più lungo di 10 caratteri');
   end if;

   if inserting then
      insert into gdm_tipi_relazione (area
                                    , tipo_relazione
                                    , descrizione
                                    , visibile
                                    , dipendenza
                                    , data_aggiornamento
                                    , utente_aggiornamento)
         select d_area_segreteria
              , :new.tipo_collegamento
              , :new.descrizione
              , 'S'
              , 'N'
              , sysdate
              , :new.utente_upd
           from agspr_dual
          where not exists
                   (select 1
                      from gdm_tipi_relazione
                     where area = d_area_segreteria
                       and tipo_relazione = :new.tipo_collegamento);

      insert into gdm_tipi_relazione (area
                                    , tipo_relazione
                                    , descrizione
                                    , visibile
                                    , dipendenza
                                    , data_aggiornamento
                                    , utente_aggiornamento)
         select d_area_segreteria_protocollo
              , :new.tipo_collegamento
              , :new.descrizione
              , 'S'
              , 'N'
              , sysdate
              , :new.utente_upd
           from agspr_dual
          where not exists
                   (select 1
                      from gdm_tipi_relazione
                     where area = d_area_segreteria_protocollo
                       and tipo_relazione = :new.tipo_collegamento);
   end if;

   if updating then
      update gdm_tipi_relazione
         set descrizione            = :new.descrizione
           , data_aggiornamento     = :new.data_upd
           , utente_aggiornamento   = :new.utente_upd
           , tipo_relazione         = :new.tipo_collegamento
       where area = d_area_segreteria
         and tipo_relazione = :old.tipo_collegamento;

      update gdm_tipi_relazione
         set descrizione            = :new.descrizione
           , data_aggiornamento     = :new.data_upd
           , utente_aggiornamento   = :new.utente_upd
           , tipo_relazione         = :new.tipo_collegamento
       where area = d_area_segreteria_protocollo
         and tipo_relazione = :old.tipo_collegamento;
   end if;
end;
/
