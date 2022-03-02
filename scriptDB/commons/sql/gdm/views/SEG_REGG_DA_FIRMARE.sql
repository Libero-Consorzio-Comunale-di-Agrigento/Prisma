--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_REGG_DA_FIRMARE runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_REGG_DA_FIRMARE" ("ID_DOCUMENTO", "ID_ATTIVITA", "ID_NODO", "ID_ITER", "ESPRESSIONE", "DESCRIZIONE", "URL_RIF", "URL_RIF_DESC", "URL_EXEC", "URL_EXEC_DESC", "SYNC_EXECTYPE", "SYNC_EXECTYPE_DESCR", "TIPO", "SCADENZA", "SCADENZA_STRINGA", "VARIABILEDIRITORNO", "SITUAZIONE_SCADENZA", "PARAM_INIT_ITER", "NOME_ITER", "DESCRIZIONE_ITER", "ACL_CONTROL_ASSIGN", "ACL_CONTROL_TYPE_ASSIGNED", "TIPO_OGGETTO", "OGGETTO", "ATTIVITA_HELP", "ATTIVITA_DESCR", "MESSAGGIO_TODO", "COLORE", "ORDINAMENTO", "DATA_ATTIVAZIONE", "PRESA_IN_CARICO", "ASSEGNA_A", "ESEGUI", "RIMUOVI_IN_CARICO", "UP_DESCRIZIONE", "ATTIVAZIONE") AS 
  SELECT DISTINCT
          QUER.id_query ID_DOCUMENTO,
          '' id_attivita,
          '' id_nodo,
          '' id_iter,
          '' espressione,
             'Registro di protocollo del '
          || TO_CHAR (regg.ricerca_fine, 'dd/mm/yyyy')
          || ' da firmare'
             descrizione,
             '/jdms/common/WorkArea.do?WRKSP='
          || (-CART.id_cartella)
          || CHR (38)
          || 'idQuery='
          || QUER.id_query
             url_rif,
          'Registri di protocollo da firmare' url_rif_desc,
             '/jdms/common/WorkArea.do?WRKSP='
          || (-CART.id_cartella)
          || CHR (38)
          || 'idQuery='
          || QUER.id_query
             url_exec,
          'Registri di protocollo da firmare' url_exec_desc,
          'DOCUMENTO_GDM' sync_exectype,
          'Documento di GDM' sync_exectype_descr,
          '16' tipo,
          '' scadenza,
          '' scadenza_stringa,
          '' variabilediritorno,
          '' situazione_scadenza,
          '' param_init_iter,
          '' nome_iter,
          '' descrizione_iter,
          '' acl_control_assign,
          '' acl_control_type_assigned,
          '' tipo_oggetto,
          '' oggetto,
          'Registri di protocollo da firmare' attivita_help,
          '' attivita_descr,
          '' messaggio_todo,
          '' colore,
          '' ordinamento,
          SYSDATE data_attivazione,
          '0' presa_in_carico,
          '0' assegna_a,
          '1' esegui,
          '0' rimuovi_in_carico,
          '' up_descrizione,
          '' attivazione
     FROM DOCUMENTI DOCU,
          SPR_REGISTRO_GIORNALIERO REGG,
          cartelle CART,
          query QUER
    WHERE     REGG.ID_DOCUMENTO = DOCU.ID_DOCUMENTO
          AND CART.codiceads = 'SEGRETERIA.PROTOCOLLO#PROTOCOLLO'
          AND QUER.codiceads =
                 'SEGRETERIA.PROTOCOLLO#FIRMA_REGISTRI_DI_PROTOCOLLO'
          AND REGG.STATO_PR = 'DP'
          AND REGG.STATO_FIRMA IS NULL
          AND REGG.VERIFICA_FIRMA IS NULL
          AND DOCU.stato_documento NOT IN ('CA', 'RE', 'PB')
/
