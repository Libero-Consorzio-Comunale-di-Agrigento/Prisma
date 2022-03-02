--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_MODALITA_INVIORICEZ_TIU runOnChange:true stripComments:false

CREATE OR REPLACE  TRIGGER ${global.db.agspr.username}.ags_modalita_invioricez_tiu
   before insert or update or delete
   ON ${global.db.agspr.username}.AGS_MODALITA_INVIO_RICEZIONE
   for each row
declare
   d_id_gdm              number (10);
   d_ret                 number;
   d_amministrazione     varchar2 (255);
   d_aoo                 varchar2 (255);
   d_codice_spedizione   varchar2 (255);
begin
   if inserting
   or updating then
      select amministrazione, aoo
        into d_amministrazione, d_aoo
        from gdo_enti
       where id_ente = :new.id_ente;

      d_codice_spedizione   := null;

      if (:new.id_tipo_spedizione is not null) then
         begin
            select codice
              into d_codice_spedizione
              from ags_tipi_spedizione
             where id_tipo_spedizione = :new.id_tipo_spedizione;
         exception
            when no_data_found then
               d_codice_spedizione   := null;
         end;
      end if;
   end if;

   if inserting then
      begin
         d_id_gdm      :=
            gdm_profilo.crea_documento ('SEGRETERIA'
                                      , 'DIZ_MODALITA_RICEVIMENTO'
                                      , null
                                      , :new.utente_ins
                                      , false);
      exception
         when others then
           raise_application_error (-20999, 'Errore in GDM_PROFILO.CREA_DOCUMENTO: ' || sqlerrm);
      end;

      insert into gdm_modalita_invio_ricezione (codice_amministrazione
                                              , codice_aoo
                                              , costo_euro
                                              , dataval_al
                                              , dataval_dal
                                              , descrizione_mod_ricevimento
                                              , id_documento
                                              , mod_ricevimento
                                              , tipo_spedizione)
           values (d_amministrazione
                 , d_aoo
                 , :new.costo
                 , :new.valido_al
                 , :new.valido_dal
                 , :new.descrizione
                 , d_id_gdm
                 , upper (:new.codice)                                                                                                                                     --'??? TIPO_MOD_RICEVIMENTO')
                 , d_codice_spedizione);

      :new.id_documento_esterno   := d_id_gdm;
   end if;

   if updating then
      update gdm_modalita_invio_ricezione
         set codice_amministrazione        = d_amministrazione
           , codice_aoo                    = d_aoo
           , costo_euro                    = :new.costo
           , dataval_al                    = :new.valido_al
           , dataval_dal                   = :new.valido_dal
           , descrizione_mod_ricevimento   = :new.descrizione
           , mod_ricevimento               = upper (:new.codice)
           , tipo_spedizione               = d_codice_spedizione
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
