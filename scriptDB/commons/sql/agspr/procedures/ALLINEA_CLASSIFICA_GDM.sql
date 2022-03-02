--liquibase formatted sql
--changeset esasdelli:AGSPR_PROCEDURE_ALLINEA_CLASSIFICA_GDM runOnChange:true stripComments:false

CREATE OR REPLACE procedure       allinea_classifica_gdm (p_operazione    varchar2
                                                        , p_new_id_classificazione number
                                                        , p_new_progressivo_padre number
                                                        , p_new_id_documento_esterno number
                                                        , p_new_id_ente   number
                                                        , p_new_classificazione varchar2
                                                        , p_new_descrizione varchar2
                                                        , p_new_classificazione_al varchar2
                                                        , p_new_classificazione_dal varchar2
                                                        , p_new_contenitore_documenti char
                                                        , p_new_num_illimitata char
                                                        , p_new_note      varchar2
                                                        , p_new_doc_fascicoli_sub char
                                                        , p_new_valido    char
                                                        , p_new_utente_ins varchar2
                                                        , p_new_utente_upd varchar2
                                                        , p_old_id_documento_esterno number
                                                        , p_old_progressivo_padre number
                                                        , p_old_valido    char)
--procedure che allinea la classificazioni su GDM
is
   d_id_gdm                   number (10);
   d_ret                      number;
   d_amministrazione          varchar2 (255);
   d_aoo                      varchar2 (255);
   d_codice_spedizione        varchar2 (255);
   d_documento_padre          number;
   d_id_cartella              number;
   d_id_cartella_padre        number;
   d_class_padre              varchar2 (255);
   d_dal_padre                date;
   d_codice_richiesta_padre   number;
begin
   if p_operazione = 'I'
   or p_operazione = 'U' then
      select amministrazione, aoo
        into d_amministrazione, d_aoo
        from gdo_enti
       where id_ente = p_new_id_ente;

      if p_new_progressivo_padre is not null then
         begin
            --leggo i riferimenti del documento padre (attivo al momento)
            select id_documento_esterno, classificazione, classificazione_dal
              into d_documento_padre, d_class_padre, d_dal_padre
              from ags_classificazioni
             where progressivo = p_new_progressivo_padre
               and classificazione_al is null;
         exception
            when no_data_found then
               begin
                  --leggo i riferimenti del documento padre (con classificazione_al nel futuro....presumo che ce ne sia solo 1
                  select id_documento_esterno, classificazione, classificazione_dal
                    into d_documento_padre, d_class_padre, d_dal_padre
                    from ags_classificazioni
                   where progressivo = p_new_progressivo_padre
                     and trunc (classificazione_al) > trunc (sysdate)
                     and rownum = 1;
               exception
                  when no_data_found then
                     d_documento_padre   := null;
               end;
         end;
      end if;
   end if;

   if p_operazione = 'I' then
      begin
         --recupero la cartella del padre
         if p_new_progressivo_padre is not null and d_documento_padre is not null then
            begin
               select id_cartella
                 into d_id_cartella_padre
                 from gdm_cartelle
                where id_documento_profilo = d_documento_padre;
            exception
               when no_data_found then
                  d_id_cartella_padre   := null;
            end;

            begin
               select codice_richiesta
                 into d_codice_richiesta_padre
                 from gdm_documenti
                where id_documento = d_documento_padre;
            exception
               when no_data_found then
                  d_codice_richiesta_padre   := null;
            end;
         end if;

         --se non ho trovato la cartella padre, su gdm inserisco il documento nella cartella del titolario
         if d_id_cartella_padre is null then
            begin
               select id_cartella
                 into d_id_cartella_padre
                 from gdm_cartelle
                where nome = 'Titolario'
                  and id_cartella < 0;
            exception
               when no_data_found then
                  d_id_cartella_padre   := null;
            end;
         end if;

         d_id_cartella      :=
            gdm_gdm_cartelle.crea_cartella ('SEGRETERIA'
                                          , 'DIZ_CLASSIFICAZIONE'
                                          , p_new_classificazione || ' - ' || p_new_descrizione
                                          , d_id_cartella_padre
                                          , p_new_utente_ins);

         select id_documento_profilo
           into d_id_gdm
           from gdm_cartelle
          where id_cartella = d_id_cartella;
      exception
         when others then
            raise_application_error (-20999, 'Errore in GDM_PROFILO.CREA_DOCUMENTO: ' || sqlerrm);
      end;

      insert into gdm_seg_classificazioni (id_documento
                                         , allegato_principale
                                         , anno
                                         , class_al
                                         , class_cod
                                         , class_dal
                                         , class_descr
                                         , class_padre
                                         , codice_amministrazione
                                         , codice_aoo
                                         , contenitore_documenti
                                         , creata_cartella
                                         , cr_padre
                                         , dal_padre
                                         , data_creazione
                                         , nome
                                         , num_illimitata
                                         , ultimo_numero_sub
                                         , full_text
                                         , note
                                         , ins_doc_in_fasc_con_sub)
           values (d_id_gdm
                 , null
                 , null
                 , to_date (p_new_classificazione_al, 'dd/mm/yyyy')
                 , p_new_classificazione
                 , to_date (p_new_classificazione_dal, 'dd/mm/yyyy')
                 , p_new_descrizione
                 , d_class_padre
                 , d_amministrazione
                 , d_aoo
                 , p_new_contenitore_documenti
                 , 'Y'
                 , d_codice_richiesta_padre
                 , d_dal_padre
                 , sysdate
                 , p_new_classificazione || ' ' || p_new_descrizione
                 , p_new_num_illimitata
                 , 0
                 , null
                 , p_new_note
                 , p_new_doc_fascicoli_sub);

      update ags_classificazioni
         set id_documento_esterno   = d_id_gdm
       where id_classificazione = p_new_id_classificazione;
   end if;

   if p_operazione = 'U' then
      --se non ho id_documento_esterno non lo modifico (in fase di creazione la funzione viene chiamata due volte, in insert e in update)
      if (p_new_id_documento_esterno is null) and (p_old_id_documento_esterno is not null) then
         update ags_classificazioni
            set id_documento_esterno   = p_old_id_documento_esterno
          where id_classificazione = p_new_id_classificazione;
      end if;

      if p_new_progressivo_padre <> p_old_progressivo_padre then
         --recupero la cartella del padre
         if p_new_progressivo_padre is not null
        and d_documento_padre is not null then
            begin
               select id_cartella
                 into d_id_cartella_padre
                 from gdm_cartelle
                where id_documento_profilo = d_documento_padre;

               --aggiorno la link di gdm
               select id_cartella
                 into d_id_cartella
                 from gdm_cartelle
                where id_documento_profilo = p_new_id_documento_esterno;

               update gdm_links
                  set id_cartella   = d_id_cartella_padre
                where tipo_oggetto = 'C'
                  and id_oggetto = d_id_cartella;
            exception
               when no_data_found then
                  d_id_cartella_padre   := null;
            end;

            begin
               select codice_richiesta
                 into d_codice_richiesta_padre
                 from gdm_documenti
                where id_documento = d_documento_padre;

               update gdm_seg_classificazioni
                  set cr_padre   = d_codice_richiesta_padre
                where id_documento = p_new_id_documento_esterno;
            exception
               when no_data_found then
                  d_codice_richiesta_padre   := null;
            end;
         end if;
      end if;

      update gdm_seg_classificazioni
         set class_al                  = to_date (p_new_classificazione_al, 'dd/mm/yyyy')
           , class_cod                 = p_new_classificazione
           , class_dal                 = to_date (p_new_classificazione_dal, 'dd/mm/yyyy')
           , class_descr               = p_new_descrizione
           , class_padre               = d_class_padre
           , codice_amministrazione    = d_amministrazione
           , codice_aoo                = d_aoo
           , contenitore_documenti     = p_new_contenitore_documenti
           , creata_cartella           = 'Y'
           , dal_padre                 = d_dal_padre
           , nome                      = p_new_classificazione || ' - ' || p_new_descrizione
           , num_illimitata            = p_new_num_illimitata
           , note                      = p_new_note
           , ins_doc_in_fasc_con_sub   = p_new_doc_fascicoli_sub
       where id_documento = p_new_id_documento_esterno;


      --Aggiorno la descrizione della cartella
      update gdm_cartelle
         set nome   = p_new_classificazione || ' - ' || p_new_descrizione
       where id_documento_profilo = p_new_id_documento_esterno;

      if nvl (p_new_valido, '*') != nvl (p_old_valido, '*') then
         if nvl (p_new_valido, '*') = 'N' then
            d_ret   := gdm_profilo.cancella (p_new_id_documento_esterno, p_new_utente_upd);
         else
            d_ret   := gdm_profilo.cambia_stato (p_new_id_documento_esterno, p_new_utente_upd, 'BO');
         end if;

         update gdm_documenti
            set data_aggiornamento = sysdate, utente_aggiornamento = p_new_utente_upd
          where id_documento = p_new_id_documento_esterno;
      end if;
   end if;
end;
/
