--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_PROT_ALLEPRIN_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SPR_PROT_ALLEPRIN_TU
   BEFORE UPDATE
   ON SPR_PROTOCOLLI
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
BEGIN
/*Feature #37886 PERSONALIZZAZIONE ASST MANTOVA: Crea PG in Partenza da messaggio in arrivo
  Per evitare che dia errore se il file non è firmato quando crea da Crea PG in Partenza,
  annullo allegato_principale
*/
   :NEW.ALLEGATO_PRINCIPALE := NULL;
end;
/
