--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_REGG_ASSENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_REGG_ASSENTI" ("ID_DOCUMENTO", "ID_ATTIVITA", "ID_NODO", "ID_ITER", "ESPRESSIONE", "DESCRIZIONE", "URL_RIF", "URL_RIF_DESC", "URL_EXEC", "URL_EXEC_DESC", "SYNC_EXECTYPE", "SYNC_EXECTYPE_DESCR", "TIPO", "SCADENZA", "SCADENZA_STRINGA", "VARIABILEDIRITORNO", "SITUAZIONE_SCADENZA", "PARAM_INIT_ITER", "NOME_ITER", "DESCRIZIONE_ITER", "ACL_CONTROL_ASSIGN", "ACL_CONTROL_TYPE_ASSIGNED", "TIPO_OGGETTO", "OGGETTO", "ATTIVITA_HELP", "ATTIVITA_DESCR", "MESSAGGIO_TODO", "COLORE", "ORDINAMENTO", "DATA_ATTIVAZIONE", "PRESA_IN_CARICO", "ASSEGNA_A", "ESEGUI", "RIMUOVI_IN_CARICO", "UP_DESCRIZIONE", "ATTIVAZIONE") AS 
  SELECT DISTINCT          -999999999,          '' id_attivita,          '' id_nodo,          '' id_iter,          '' espressione,          'Attenzione: non vengono stampati registri di protocollo da almeno 3 giorni!'             descrizione,          '' url_rif,          '' url_rif_desc,          '' url_exec,          '' url_exec_desc,          'DOCUMENTO_GDM' sync_exectype,          'Documento di GDM' sync_exectype_descr,          '16' tipo,          '' scadenza,          '' scadenza_stringa,          '' variabilediritorno,          '' situazione_scadenza,          '' param_init_iter,          '' nome_iter,          '' descrizione_iter,          '' acl_control_assign,          '' acl_control_type_assigned,          '' tipo_oggetto,          '' oggetto,          'Attenzione: non vengono stampati registri di protocollo da almeno 3 giorni!'             attivita_help,          '' attivita_descr,          '' messaggio_todo,          '' colore,          '' ordinamento,          TRUNC (SYSDATE) data_attivazione,          '0' presa_in_carico,          '0' assegna_a,          '0' esegui,          '0' rimuovi_in_carico,          '' up_descrizione,          '' attivazione     FROM DUAL    WHERE (SELECT nvl(TRUNC(max(REGG.DATA)), to_date(3333333, 'j'))                FROM DOCUMENTI DOCU,                     SPR_REGISTRO_GIORNALIERO REGG               WHERE     REGG.ID_DOCUMENTO = DOCU.ID_DOCUMENTO                     AND DOCU.stato_documento NOT IN ('CA', 'RE', 'PB' )) <= trunc(sysdate) - 2
/