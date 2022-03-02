--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201020_54.ags_filtri_documenti_esterni_ins runOnChange:true stripComments:false

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'CONTRATTI@CONTRATTO',
          '<b>Protocollo: #ANNO# / #NUMERO# del #DATA#</b><br>Fascicolo: #FASCICOLO_NUMERO# / #FASCICOLO_ANNO# - Classificazione: #CLASS_COD#<br>Contratto: #NUMERO_CONTRATTO# / #ANNO_CONTRATTO# - Data stipula: #DATA_STIPULA# - CIG: #CIG#<br>Oggetto: #OGGETTO#',
          'QUANDO_APPROVAZIONE'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'CONTRATTI@CONTRATTO')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.ATTI.2_0@DELIBERA',
          '<b>#DESCR_REGISTRO_DELIBERA# Atto #NUMERO_DETERMINA# / #ANNO_DETERMINA#</b><br>Oggetto: #OGGETTO#<br>Tipologia: #DESCRIZIONE_TIPO_DELIBERA#<br>Esecutiva dal: #DATA_ESECUTIVITA# - Pubblicata dal #DATA_PUBBLICAZIONE# al #DATA_FINE_PUBBLICAZIONE#<br>Protocollo: #NUMERO# del #DATA#',
          'DATA_NUMERO_DELIBERA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.ATTI.2_0@DELIBERA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@M_PROTOCOLLO',
          '<b>#DESCRIZIONE_TIPO_REGISTRO# - #ANNO# / #NUMERO# del #DATA#</b><br>Modalità: #MODALITA#<br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@M_PROTOCOLLO')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.ATTI.2_0@DETERMINA',
          '<b>#DESCR_REGISTRO_DETERMINA# - Proposta #ANNO_PROPOSTA# / #NUMERO_PROPOSTA# - Atto #NUMERO_DETERMINA# / #ANNO_DETERMINA#</b><br>Oggetto: #OGGETTO#<br>Tipologia: #DESCRIZIONE_TIPO_DETERMINA#<br>Esecutiva dal: #DATA_ESECUTIVITA# - Pubblicata dal #DATA_PUBBLICAZIONE# al #DATA_FINE_PUBBLICAZIONE#<br>Protocollo: #NUMERO# del #DATA#',
          'DATA_NUMERO_DETERMINA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.ATTI.2_0@DETERMINA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'QUALITA@PROCEDURA',
          '<b>Oggetto procedura: #OGGETTO_PROCEDURA#.</b><br>Classifica: #CLASSIFICA#.<br>Stato: #STATO_DOCUMENTO#',
          'QUANDO_APPROVAZIONE'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'QUALITA@PROCEDURA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA@MEMO_PROTOCOLLO',
          '<b>Data spedizione: #DATA_SPEDIZIONE_MEMO# - Data ricezione: #DATA_RICEZIONE#</b><br>Mittente: #MITTENTE#<br>Destinatari: #DESTINATARI#<br>Oggetto: #OGGETTO#<br>Tipo messaggio: #TIPO_MESSAGGIO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA@MEMO_PROTOCOLLO')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@M_PROTOCOLLO_INTEROPERABILITA',
          '<b>#DESCRIZIONE_TIPO_REGISTRO# - #ANNO# / #NUMERO# del #DATA#</b><br>Modalità: #MODALITA#<br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@M_PROTOCOLLO_INTEROPERABILITA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.ATTI.2_0@PROPOSTA_DELIBERA',
          '<b>#DESCR_REGISTRO_PROPOSTA# - Proposta #ANNO_PROPOSTA# / #NUMERO_PROPOSTA#</b><br>Oggetto: #OGGETTO#<br>Tipologia: #DESCRIZIONE_TIPO_DELIBERA#',
          'DATA_NUMERO_PROPOSTA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.ATTI.2_0@PROPOSTA_DELIBERA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@DOC_DA_FASCICOLARE',
          '<b>Documento del #DATA#</b><br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@DOC_DA_FASCICOLARE')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@LETTERA_USCITA',
          '<b>#DESCRIZIONE_TIPO_REGISTRO# - #ANNO# / #NUMERO# del #DATA#</b><br>Modalità: #MODALITA#<br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@LETTERA_USCITA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@M_PROTOCOLLO_EMERGENZA',
          '<b>#DESCRIZIONE_TIPO_REGISTRO# - #ANNO# / #NUMERO# del #DATA#</b><br>Modalità: #MODALITA#<br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@M_PROTOCOLLO_EMERGENZA')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@M_PROVVEDIMENTO',
          '<b>#DESCRIZIONE_TIPO_REGISTRO# - #ANNO# / #NUMERO# del #DATA#</b><br>Modalità: #MODALITA#<br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@M_PROVVEDIMENTO')
/

INSERT INTO AGS_FILTRI_DOCUMENTI_ESTERNI (CHIAVE,
                                          DESCRIZIONE,
                                          CAMPO_DATA_ORDINAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO@M_REGISTRO_GIORNALIERO',
          '<b>#DESCRIZIONE_TIPO_REGISTRO# - #ANNO# / #NUMERO# del #DATA#</b><br>Modalità: #MODALITA#<br>Oggetto: #OGGETTO#',
          'DATA'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGS_FILTRI_DOCUMENTI_ESTERNI
               WHERE CHIAVE = 'SEGRETERIA.PROTOCOLLO@M_REGISTRO_GIORNALIERO')
/

COMMIT
/