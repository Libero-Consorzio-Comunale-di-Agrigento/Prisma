--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_MESSAGGI runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW AGP_MESSAGGI
(
   ID_DOCUMENTO,
   MITTENTE,
   DESTINATARI,
   DESTINATARI_CONOSCENZA,
   DESTINATARI_ENTE,
   DESTINATARI_CONOSCENZA_ENTE,
   DESTINATARI_NASCOSTI,
   OGGETTO,
   CORPO,
   MESSAGE_ID,
   IN_PARTENZA,
   SPEDITO,
   DATA_SPEDIZIONE_MEMO,
   DATA_RICEZIONE,
   STATO_MEMO,
   DATA_STATO_MEMO,
   ID_CLASSIFICAZIONE,
   ID_FASCICOLO,
   IDRIF,
   TIPO_MESSAGGIO,
   TIPO_CORPO,
   MOTIVO_NO_PROC,
   RISERVATO,
   GENERATA_ECCEZIONE,
   REGISTRATA_ACCETTAZIONE,
   REGISTRATA_NON_ACCETTAZIONE,
   TAGMAIL_INVIO,
   MITTENTE_AMMINISTRAZIONE,
   MITTENTE_AOO,
   MITTENTE_CODICE_UO,
   ID_DOCUMENTO_ESTERNO,
   LINK_DOCUMENTO,
   VALIDO,
   UNITA,
   UTENTE_INS,
   DATA_INS,
   UTENTE_UPD,
   DATA_UPD,
   VERSION
)
AS
   SELECT -M.ID_DOCUMENTO ID_DOCUMENTO,
          MITTENTE,
          DESTINATARI_CLOB DESTINATARI,
          DESTINATARI_CC_CLOB DESTINATARI_CONOSCENZA,
          DESTINATARI DESTINATARI_ENTE,
          DESTINATARI_CONOSCENZA DESTINATARI_CONOSCENZA_ENTE,
          TO_CLOB (DESTINATARI_NASCOSTI) DESTINATARI_NASCOSTI,
          OGGETTO,
          CORPO,
          MESSAGE_ID,
          CAST (NVL (MEMO_IN_PARTENZA, 'N') AS CHAR (1)) IN_PARTENZA,
          CAST (NVL (SPEDITO, 'N') AS CHAR (1)) SPEDITO,
          DECODE (
             NVL (MEMO_IN_PARTENZA, 'N'),
             'Y', DECODE (
                     STATO_SPEDIZIONE,
                     'SENTOK', TO_CHAR (DATA_MODIFICA,
                                        'dd/mm/yyyy hh24:mi:ss'),
                     TO_CHAR (NULL)),
             DATA_SPEDIZIONE_MEMO)
             DATA_SPEDIZIONE_MEMO,
          DATA_RICEZIONE,
          DECODE (
             NVL (MEMO_IN_PARTENZA, 'N'),
             'Y', DECODE (
                     STATO_SPEDIZIONE,
                     'SENTFAILED', 'Inoltro a casella per invio FALLITO',
                     'SENTOK', 'Inoltrato a casella per invio',
                     'SENDING', 'In fase di inoltro a casella',
                     'READYTOSEND', 'In attesa di inoltro a casella',
                     STATO_SPEDIZIONE),
             STATO_MEMO)
             STATO_MEMO,
          DATA_STATO_MEMO,
          -ts.id_documento id_classificazione,
          -f.id_documento id_fascicolo,
          m.IDRIF,
          TIPO_MESSAGGIO,
          TIPO_CORPO,
          MOTIVO_NO_PROC,
          CAST (NVL (m.RISERVATO, 'N') AS CHAR (1)) RISERVATO,
          CAST (NVL (m.generata_eccezione, 'N') AS CHAR (1))
             generata_eccezione,
          CAST (NVL (REGISTRATA_ACCETTAZIONE, 'N') AS CHAR (1))
             REGISTRATA_ACCETTAZIONE,
          CAST (NVL (REGISTRATA_NON_ACCETTAZIONE, 'N') AS CHAR (1))
             REGISTRATA_NON_ACCETTAZIONE,
          MM.TAGMAIL tagmail_invio,
          MM.AMMINISTRAZIONE mittente_amministrazione,
          MM.AOO mittente_aoo,
          MM.CODICE_UO mittente_codice_uo,
          M.ID_DOCUMENTO ID_DOCUMENTO_ESTERNO,
          gdc_utility_pkg.f_get_url_oggetto ('',
                                             '',
                                             m.id_documento,
                                             'D',
                                             '',
                                             '',
                                             '',
                                             'R',
                                             '',
                                             '',
                                             '5',
                                             'N')
             link_documento,
          CAST (
             DECODE (NVL (d.stato_documento, 'BO'), 'CA', 'N', 'Y') AS CHAR (1))
             valido,
          m.unita_protocollante unita,
          UTENTE_PROTOCOLLANTE UTENTE_INS,
          TO_DATE (NULL) DATA_INS,
          d.utente_aggiornamento UTENTE_UPD,
          d.data_aggiornamento DATA_UPD,
          0 VERSION
     FROM gdm_seg_memo_protocollo m,
          gdm_classificazioni ts,
          gdm_fascicoli f,
          gdm_documenti d,
          gdm_ag_cs_messaggi c,
          agp_messaggi_mittente mm
    WHERE     d.id_documento = m.id_documento
          AND ts.class_cod(+) = m.class_cod
          AND ts.class_dal(+) = m.class_dal
          AND f.class_cod(+) = m.class_cod
          AND f.class_dal(+) = m.class_dal
          AND f.fascicolo_anno(+) = m.fascicolo_anno
          AND f.fascicolo_numero(+) = m.fascicolo_numero
          AND c.id_documento_memo(+) = m.id_documento
          AND mm.id_messaggio(+) = m.id_documento
          AND NOT EXISTS
                 (SELECT 1
                    FROM gdo_documenti
                   WHERE id_documento_esterno = M.ID_DOCUMENTO)
   UNION ALL
   SELECT M.ID_DOCUMENTO,
          MITTENTE,
          DESTINATARI,
          DESTINATARI_CONOSCENZA,
          '' DESTINATARI_ENTE,
          '' DESTINATARI_CONOSCENZA_ENTE,
          DESTINATARI_NASCOSTI,
          m.OGGETTO,
          TESTO,
          '' MESSAGE_ID,
          CAST ('N' AS CHAR (1)) IN_PARTENZA,
          'N' SPEDITO,
          TO_CHAR (DATA_SPEDIZIONE, 'DD/MM/YYYY HH24:MI:SS')
             DATA_SPEDIZIONE_MEMO,
          DATA_RICEZIONE,
          m.STATO STATO_MEMO,
          m.DATA_STATO DATA_STATO_MEMO,
          id_classificazione,
          id_fascicolo,
          '' IDRIF,
          TIPO TIPO_MESSAGGIO,
          MIME_TESTO TIPO_CORPO,
          NOTE MOTIVO_NO_PROC,
          'N' RISERVATO,
          DECODE (m.STATO, 'GE', 'Y', 'N') generata_eccezione,
          'N' REGISTRATA_ACCETTAZIONE,
          'N' REGISTRATA_NON_ACCETTAZIONE,
          '' tagmail_invio,
          '' mittente_amministrazione,
          '' mittente_aoo,
          '' mittente_codice_uo,
          D.ID_DOCUMENTO_ESTERNO ID_DOCUMENTO_ESTERNO,
          '' link_documento,
          valido,
          u.codice unita,
          d.UTENTE_INS,
          d.DATA_INS,
          d.UTENTE_UPD,
          d.DATA_UPD,
          d.VERSION
     FROM agp_msg_ricevuti_dati_prot m,
          gdo_documenti d,
          gdo_documenti_soggetti s,
          so4_v_unita_organizzative_pubb u
    WHERE     d.id_documento = m.id_documento
          AND s.id_documento = d.id_documento
          AND S.TIPO_SOGGETTO = 'UO_MESSAGGIO'
          AND u.ottica(+) = S.UNITA_OTTICA
          AND U.PROGR(+) = S.UNITA_PROGR
          AND U.DAL(+) = S.UNITA_DAL
   UNION ALL
   SELECT M.ID_DOCUMENTO,
          M.MITTENTE,
          DESTINATARI,
          DESTINATARI_CONOSCENZA,
          '' DESTINATARI_ENTE,
          '' DESTINATARI_CONOSCENZA_ENTE,
          TO_CLOB (DESTINATARI_NASCOSTI) DESTINATARI_NASCOSTI,
          OGGETTO,
          TESTO,
          '' MESSAGE_ID,
          'Y' IN_PARTENZA,
          'Y' SPEDITO,
          DECODE (
             STATO_SPEDIZIONE,
             'SENTOK', TO_CHAR (DATA_SPEDIZIONE, 'dd/mm/yyyy hh24:mi:ss'),
             TO_CHAR (NULL))
             DATA_SPEDIZIONE_MEMO,
          NULL DATA_RICEZIONE,
          DECODE (STATO_SPEDIZIONE,
                  'SENTFAILED', 'Inoltro a casella per invio FALLITO',
                  'SENTOK', 'Inoltrato a casella per invio',
                  'SENDING', 'In fase di inoltro a casella',
                  'READYTOSEND', 'In attesa di inoltro a casella',
                  STATO_SPEDIZIONE)
             STATO_MEMO,
          DATA_SPEDIZIONE DATA_STATO_MEMO,
          TO_NUMBER (NULL) id_classificazione,
          TO_NUMBER (NULL) id_fascicolo,
          '' IDRIF,
          '' TIPO_MESSAGGIO,
          '' TIPO_CORPO,
          '' MOTIVO_NO_PROC,
          'N' RISERVATO,
          'N' generata_eccezione,
          ACCETTAZIONE,
          NON_ACCETTAZIONE REGISTRATA_NON_ACCETTAZIONE,
          TAGMAIL tagmail_invio,
          mittente_amministrazione,
          mittente_aoo mittente_aoo,
          mittente_uo mittente_codice_uo,
          D.ID_DOCUMENTO_ESTERNO ID_DOCUMENTO_ESTERNO,
          '' link_documento,
          valido,
          u.codice unita,
          d.UTENTE_INS,
          d.DATA_INS,
          d.UTENTE_UPD,
          d.DATA_UPD,
          d.VERSION
     FROM agp_msg_inviati_dati_prot m,
          gdo_documenti d,
          gdo_documenti_soggetti s,
          so4_v_unita_organizzative_pubb u
    WHERE     d.id_documento = m.id_documento
          AND s.id_documento(+) = d.id_documento
          AND S.TIPO_SOGGETTO(+) = 'UO_MESSAGGIO'
          AND u.ottica(+) = S.UNITA_OTTICA
          AND U.PROGR(+) = S.UNITA_PROGR
          AND U.DAL(+) = S.UNITA_DAL
/