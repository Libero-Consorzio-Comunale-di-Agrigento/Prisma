--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_02.grant_per_trasco  runOnChange:true
grant select on ag_abilitazioni_smistamento to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on seg_numerazioni_classifica to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on seg_unita_classifica to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on gdm_cartelle to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on seg_classificazioni to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on links to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on seg_stream_memo_proto to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on seg_note to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on seg_tipi_spedizione to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on seg_modalita_ricevimento to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on collegamenti_esterni to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on SEG_ANAGRAFICI_AS4 to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on gdm_oggetti_file to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on F_ELIMINA_DOCUMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ag_utilities_stampa to ${global.db.agspr.username} WITH GRANT OPTION
/

GRANT EXECUTE ON AG_COMPETENZE_FASCICOLO TO ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on valori_log to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on activity_log to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on dati to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on dati_modello to ${global.db.agspr.username} with grant option
/

grant select on jdms_link to ${global.db.agspr.username} with grant option
/
grant select on view_cartella to ${global.db.agspr.username} with grant option
/
grant all on TMP_FILE to ${global.db.agspr.username} with grant option
/
grant execute on ag_sposta_file_doc_in_rep to ${global.db.agspr.username} with grant option
/