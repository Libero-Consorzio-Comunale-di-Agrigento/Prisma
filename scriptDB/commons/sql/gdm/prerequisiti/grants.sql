--liquibase formatted sql
--property name:global.db.agspr.username value:PROVA
--changeset esasdelli:_20200220_01.gdm  runOnChange:true stripComments:false

grant execute on AG_BARRA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_COMPETENZE_PROTOCOLLO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_COMPONENTI_LISTA_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AG_CS_MESSAGGI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_FASCICOLO_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_LISTE_DIST_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_PARAMETRO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_PARAMETRO to ${global.db.so4.username} WITH GRANT OPTION
/

grant select on AG_PRIVILEGI_RUOLO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AG_PRIV_UTENTE_TMP to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AG_RADICI_AREA_UTENTE_TMP to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_REGISTRO_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AGS_RIFERIMENTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AG_STATI_SCARTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_TIPI_DOCUMENTO_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_TIPI_FRASE_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AG_TIPI_SOGGETTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_UTILITIES to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AMVWEB to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on CARTELLE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on DOCUMENTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on GDC_UTILITY_PKG to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on GDM_PROFILO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on GET_RAPPORTI_DOC to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on IMPRONTE_FILE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on LINKS to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on OGGETTI_FILE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on OGGETTI_FILE_LOG to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on PARAMETRI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on PROTO_VIEW to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on REGISTRO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on REGISTRO_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on RIFERIMENTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_ALLEGATI_PROTOCOLLO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_AMM_AOO_UO_TAB to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_BOTTONI_NOTIFICHE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_CLASSIFICAZIONI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_COMPONENTI_LISTA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_FASCICOLI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_LISTE_DISTRIBUZIONE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_MEMO_PROTOCOLLO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_MODALITA_RICEVIMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_REGISTRI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_SMISTAMENTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_SMISTAMENTI_TIPI_DOCUMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_SOGGETTI_MV to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_SOGGETTI_PROTOCOLLO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_TIPI_ALLEGATO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_TIPI_DOCUMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_TIPI_FRASE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_TIPI_SPEDIZIONE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on SEG_UNITA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEG_UNITA_TIPI_DOC to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on SEG_UO_MAIL to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SEQ_IDRIF to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on SMISTABILE_VIEW to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SPR_LETTERE_USCITA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SPR_PROTOCOLLI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on SPR_PROTOCOLLI_INTERO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on STATI_DOCUMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on TIPI_DOCUMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ag_memo_utility to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ag_competenze_documento to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on tipi_relazione to ${global.db.agspr.username} WITH GRANT OPTION
/

GRANT SELECT ON SO4_AOO TO ${global.db.agspr.username} with grant option
/

GRANT SELECT ON SO4_SOGGETTI_AOO TO ${global.db.agspr.username} WITH GRANT OPTION
/

GRANT SELECT ON SO4_SOGGETTI_UNITA TO ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on AG_OGGETTI_FILE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on ag_abilitazioni_smistamento to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on seg_numerazioni_classifica to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select, insert, update on seg_unita_classifica to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on gdm_cartelle to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on seg_stream_memo_proto to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on seg_note to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on collegamenti_esterni to ${global.db.agspr.username} with grant option
/

grant select on SEG_ANAGRAFICI_AS4 to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on gdm_oggetti_file to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on F_ELIMINA_DOCUMENTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ag_utilities_stampa to ${global.db.agspr.username} WITH GRANT OPTION
/

GRANT EXECUTE ON AG_COMPETENZE_FASCICOLO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on valori_log to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on activity_log to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on dati to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on dati_modello to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ag_comp_crea_protocollo to ${global.db.jwf.username} WITH GRANT OPTION
/

grant execute on ag_riferimenti_utility to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on spr_da_fascicolare to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on spr_scarico_ipa to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ag_verifica_privilegi_utente to ${global.db.jwf.username} WITH GRANT OPTION
/