--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_CLASSIFICAZIONI_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGS_CLASSIFICAZIONI_TIU
   before insert or update or delete
   ON AGS_CLASSIFICAZIONI
   for each row
declare
   d_ret                      number;
begin
   if deleting then
      d_ret   := gdm_profilo.cancella (:old.id_documento_esterno, :old.utente_upd);
   end if;
end;
/
