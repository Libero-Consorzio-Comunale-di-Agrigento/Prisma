--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_PREFERENZE_UTENTE_TIOU runOnChange:true stripComments:false
CREATE OR REPLACE  trigger agp_preferenze_utente_tiou
   /******************************************************************************
                   NOME:        AGP_PREFERENZE_UTENTE_TIOU
                   DESCRIZIONE: Trigger instead of UPDATE on View AGP_PREFERENZE_UTENTE
                   ANNOTAZIONI: -
                   REVISIONI:
                   Rev. Data       Autore         Descrizione
                   ---- ---------- -------------  ------------------------------------------------------
                      0 04/09/2019 MFrancesconi  Creazione.
                      1 11/11/2019 MFrancesconi  Modificata query per usare agspr_dual.
                  ******************************************************************************/
   instead of update
   on agp_preferenze_utente
   for each row
declare
   d_trovato   number;
   d_db_user   varchar2 (10) := 'GDM';
   d_modulo    varchar2 (10) := 'AGSPR';
   d_valore    varchar2 (4000);
begin
   if updating then
      if (upper (:new.preferenza) = 'MODALITA') then
         select decode (:new.valore,  'ARRIVO', 'ARR',  'PARTENZA', 'PAR',  'INTERNO', 'INT') into d_valore from agspr_dual;
      else
         d_valore   := :new.valore;
      end if;

      select count (1)
        into d_trovato
        from gdm_registro
       where (chiave = 'SI4_DB_USERS/' || :new.utente || '|' || d_db_user || '/PRODUCTS/' || d_modulo)
         and upper (stringa) = upper (:new.preferenza);

      if d_trovato > 0 then
         update gdm_registro
            set valore   = d_valore
          where (chiave = 'SI4_DB_USERS/' || :new.utente || '|' || d_db_user || '/PRODUCTS/' || d_modulo)
            and upper (stringa) = upper (:new.preferenza);
      else
         insert into gdm_registro (chiave, stringa, valore)
              values ('SI4_DB_USERS/' || :new.utente || '|' || d_db_user || '/PRODUCTS/' || d_modulo, :new.preferenza, d_valore);
      end if;
   end if;
exception
   when others then
      raise;
end;
/
