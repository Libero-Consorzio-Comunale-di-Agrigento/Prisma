--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_TIPI_SPEDIZIONE_TIU runOnChange:true stripComments:false

CREATE OR REPLACE  trigger ags_tipi_spedizione_tiu
   before insert or update
   on ags_tipi_spedizione
   for each row
declare
   d_id_gdm   number (10);
   d_ret      number;
begin
   if inserting then
      begin
         d_id_gdm      :=
            gdm_profilo.crea_documento ('SEGRETERIA'
                                      , 'DIZ_TIPI_SPEDIZIONE'
                                      , null
                                      , :new.utente_ins
                                      , false);
      exception
         when others then
            raise_application_error (-20999, 'Errore in GDM_PROFILO.CREA_DOCUMENTO: ' || sqlerrm);
      end;

      insert into gdm_tipi_spedizione (barcode_estero
                                     , barcode_italia
                                     , descrizione
                                     , id_documento
                                     , stampa
                                     , tipo_spedizione)
           values (:new.barcode_estero
                 , :new.barcode_italia
                 , :new.descrizione
                 , d_id_gdm
                 , :new.stampa
                 , upper (:new.codice));

      :new.id_documento_esterno   := d_id_gdm;
   end if;

   if updating then
      update gdm_tipi_spedizione
         set barcode_estero    = :new.barcode_estero
           , barcode_italia    = :new.barcode_italia
           , descrizione       = :new.descrizione
           , stampa            = :new.stampa
           , tipo_spedizione   = upper (:new.codice)
       where id_documento = :new.id_documento_esterno;

      if nvl (:new.valido, '*') != nvl (:old.valido, '*') then
         if nvl (:new.valido, '*') = 'N' then
            d_ret   := gdm_profilo.cancella (:new.id_documento_esterno, :new.utente_upd);
         else
            d_ret   := gdm_profilo.cambia_stato (:new.id_documento_esterno, :new.utente_upd, 'BO');
         end if;

         update gdm_documenti
            set data_aggiornamento = sysdate, utente_aggiornamento = :new.utente_upd
          where id_documento = :new.id_documento_esterno;
      end if;
   end if;

   if deleting then
      d_ret   := gdm_profilo.cancella (:old.id_documento_esterno, :old.utente_upd);
   end if;
end;
/
