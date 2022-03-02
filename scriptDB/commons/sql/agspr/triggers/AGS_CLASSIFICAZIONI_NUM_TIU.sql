--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_CLASSIFICAZIONI_NUM_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  trigger ags_classificazioni_num_tiu
   before insert or update or delete
   on ags_classificazioni_num
   for each row
declare
   d_id_gdm                number (10);
   d_ret                   number;
   d_amministrazione       varchar2 (255);
   d_aoo                   varchar2 (255);
   d_classificazione       varchar2 (255);
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
                                      , 'NUMERAZIONE_CLASSIFICHE'
                                      , null
                                      , :new.utente_ins
                                      , false);
      exception
         when others then
            raise_application_error (-20999, 'Errore in GDM_PROFILO.CREA_DOCUMENTO: ' || sqlerrm);
      end;

      insert into gdm_seg_numerazioni_classifica (id_documento
                                                , anno
                                                , class_cod
                                                , class_dal
                                                , codice_amministrazione
                                                , codice_aoo
                                                , ultimo_numero_sub)
           values (d_id_gdm
                 , :new.anno
                 , d_classificazione
                 , d_classificazione_dal
                 , d_amministrazione
                 , d_aoo
                 , :new.ultimo_numero_fascicolo);
   end if;

   if updating then
      update gdm_seg_numerazioni_classifica
         set ultimo_numero_sub   = :new.ultimo_numero_fascicolo
       where anno = :new.anno
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

         select gsnc.id_documento
           into d_id_gdm
           from gdm_seg_numerazioni_classifica gsnc, gdm_documenti gd
          where gsnc.anno = :old.anno
            and gsnc.codice_amministrazione = d_amministrazione
            and gsnc.codice_aoo = d_aoo
            and gsnc.class_cod = d_classificazione
            and gsnc.class_dal = d_classificazione_dal
            and gd.id_documento = gsnc.id_documento
            and gd.stato_documento = 'BO';

         d_ret   := gdm_profilo.cancella (d_id_gdm, 'RPI');
      exception
         when others then
            null;
      end;
   end if;
end;
/
