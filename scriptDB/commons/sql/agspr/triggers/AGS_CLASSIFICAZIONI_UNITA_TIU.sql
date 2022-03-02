--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_CLASSIFICAZIONI_UNITA_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  trigger ags_classificazioni_unita_tiu
   before insert or update or delete
   on ags_classificazioni_unita
   for each row
declare
   d_id_gdm                number (10);
   d_ret                   number;
   d_amministrazione       varchar2 (255);
   d_aoo                   varchar2 (255);
   d_classificazione       varchar2 (255);
   d_codice_unita          varchar2 (255);
   d_classificazione_dal   date;
begin
   if inserting
   or updating then
      select amministrazione, aoo
        into d_amministrazione, d_aoo
        from gdo_enti
       where id_ente = :new.id_ente;

      select classificazione, classificazione_dal
        into d_classificazione, d_classificazione_dal
        from ags_classificazioni
       where id_classificazione = :new.id_classificazione;
   end if;

   if inserting then
      begin
         d_id_gdm      :=
            gdm_profilo.crea_documento ('SEGRETERIA'
                                      , 'M_UNITA_CLASSIFICA'
                                      , null
                                      , :new.utente_ins
                                      , false);
      exception
         when others then
            raise_application_error (-20999, 'Errore in GDM_PROFILO.CREA_DOCUMENTO: ' || sqlerrm);
      end;

      insert into gdm_seg_unita_classifica (id_documento
                                          , class_cod
                                          , class_dal
                                          , codice_amministrazione
                                          , codice_aoo
                                          , descrizione_unita_smistamento
                                          , unita)
           values (d_id_gdm
                 , d_classificazione
                 , d_classificazione_dal
                 , d_amministrazione
                 , d_aoo
                 , agp_utility_pkg.get_uo_descrizione (:new.unita_progr, :new.unita_dal)
                 , so4_ags_pkg.unita_get_codice_valido (:new.unita_progr, :new.unita_dal));
   end if;

   if updating then
      update gdm_seg_unita_classifica
         set descrizione_unita_smistamento = agp_utility_pkg.get_uo_descrizione (:new.unita_progr, :new.unita_dal), unita = so4_ags_pkg.unita_get_codice_valido (:new.unita_progr, :new.unita_dal)
       where codice_amministrazione = d_amministrazione
         and class_cod = d_classificazione
         and class_dal = d_classificazione_dal;
   end if;

   if deleting then
      begin
         select amministrazione, aoo
           into d_amministrazione, d_aoo
           from gdo_enti
          where id_ente = :old.id_ente;

         select classificazione, classificazione_dal
           into d_classificazione, d_classificazione_dal
           from ags_classificazioni
          where id_classificazione = :old.id_classificazione;

         select codice
           into d_codice_unita
           from so4_v_unita_organizzative_pubb
          where progr = :old.unita_progr
            and dal = :old.unita_dal
            and ottica = :old.unita_ottica;

         select gsuc.id_documento
           into d_id_gdm
           from gdm_seg_unita_classifica gsuc, gdm_documenti gd
          where gsuc.codice_amministrazione = d_amministrazione
            and gsuc.codice_aoo = d_aoo
            and gsuc.class_cod = d_classificazione
            and gsuc.class_dal = d_classificazione_dal
            and gsuc.unita = d_codice_unita
            and gd.id_documento = gsuc.id_documento
            and gd.stato_documento = 'BO';

         d_ret   := gdm_profilo.cancella (d_id_gdm, 'RPI');
      exception
         when others then
            null;
      end;
   end if;
end;
/
