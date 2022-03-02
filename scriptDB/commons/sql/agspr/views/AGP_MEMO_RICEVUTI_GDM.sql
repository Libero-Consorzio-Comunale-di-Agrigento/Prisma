--liquibase formatted sql
--changeset mmalferrari:AGSPR_VIEW_AGP_AGP_MEMO_RICEVUTI_GDM runOnChange:true stripComments:false

create or replace force view agp_memo_ricevuti_gdm
(
   id_documento
 , id_messaggio_si4cs
 , mittente
 , destinatari
 , destinatari_conoscenza
 , destinatari_nascosti
 , oggetto
 , testo
 , data_spedizione
 , data_ricezione
 , stato
 , data_stato
 , id_classificazione
 , id_fascicolo
 , idrif
 , tipo
 , mime_testo
 , note
 , id_documento_esterno
 , link_documento
 , valido
 , unita
 , utente_ins
 , data_ins
 , utente_upd
 , data_upd
 , version
)
as
   select -m.id_documento id_documento
        , to_number (null) id_messaggio_si4cs
        , mittente
        , destinatari_clob destinatari
        , destinatari_cc_clob destinatari_conoscenza
        , to_clob (destinatari_nascosti) destinatari_nascosti
        , oggetto
        , corpo testo
        , data_spedizione_memo data_spedizione
        , data_ricezione
        , decode (m.stato_memo
                , 'DG', 'DA_GESTIRE'
                , 'G', 'GESTITO'
                , 'GE', 'GENERATA_ECCEZIONE'
                , 'NP', 'NON_PROTOCOLLATO'
                , 'SC', 'SCARTATO'
                , 'PR', 'PROTOCOLLATO'
                , 'DPS', 'DA_PROTOCOLLARE_SENZA_SEGNATURA'
                , 'DP', 'DA_PROTOCOLLARE_CON_SEGNATURA')
             stato
        , data_stato
        , -ts.id_documento id_classificazione
        , -f.id_documento id_fascicolo
        , m.idrif
        , tipo_messaggio tipo
        , tipo_corpo mime_testo
        , motivo_no_proc note
        , m.id_documento id_documento_esterno
        , gdc_utility_pkg.f_get_url_oggetto (''
                                           , ''
                                           , m.id_documento
                                           , 'D'
                                           , ''
                                           , ''
                                           , ''
                                           , 'R'
                                           , ''
                                           , ''
                                           , '5'
                                           , 'N')
             link_documento
        , cast (decode (nvl (d.stato_documento, 'BO'), 'CA', 'N', 'Y') as char (1)) valido
        , m.unita_protocollante unita
        , utente_protocollante utente_ins
        , to_date (null) data_ins
        , d.utente_aggiornamento utente_upd
        , d.data_aggiornamento data_upd
        , 0 version
     from gdm_seg_memo_protocollo m
        , gdm_classificazioni ts
        , gdm_fascicoli f
        , gdm_documenti d
    where d.id_documento = m.id_documento
      and ts.class_cod(+) = m.class_cod
      and ts.class_dal(+) = m.class_dal
      and f.class_cod(+) = m.class_cod
      and f.class_dal(+) = m.class_dal
      and f.fascicolo_anno(+) = m.fascicolo_anno
      and f.fascicolo_numero(+) = m.fascicolo_numero
      and not exists
             (select 1
                from agp_msg_ricevuti_dati_prot mdp, gdo_documenti gd
               where mdp.id_documento = gd.id_documento
                 and gd.id_documento_esterno = m.id_documento
              union
              select 1
                from agp_msg_ricevuti_dati_prot mdp, gdo_documenti gd
               where mdp.id_documento = gd.id_documento
                 and gd.id_documento_esterno = m.id_documento)
      and nvl (m.memo_in_partenza, 'N') = 'N'
/