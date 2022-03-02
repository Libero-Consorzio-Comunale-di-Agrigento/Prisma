--liquibase formatted sql
--changeset esasdelli:AGGIORNA_ISTANZA_AGS  runAlways:true runOnChange:true
update ad4_istanze set versione = 'V${versione}' where istanza = '${global.db.ags.istanza}'
/

UPDATE ad4_istanze SET NOTE =  CONCAT('Aggiornato il: ', TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')) where istanza = '${global.db.agspr.username}'
/

UPDATE ad4_istanze SET NOTE =  CONCAT('Aggiornato il: ', TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')) where istanza = '${global.db.ags.istanza}'
/
