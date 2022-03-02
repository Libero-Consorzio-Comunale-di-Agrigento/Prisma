--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_WS_PROTOCOLLI runOnChange:true stripComments:false

create or replace force view agp_ws_protocolli
(
   id_documento
 , id_documento_esterno
 , idrif
 , anno
 , numero
 , tipo_registro
 , data
 , oggetto
 , modalita
 , class_cod
 , fascicolo_anno
 , fascicolo_numero
 , tipo_documento
 , descrizione_tipo_documento
 , descrizione_tipo_registro
 , class_dal
 , stato_pr
 , unita_protocollante
 , area_modello
 , codice_modello
 , categoria
)
as
   select case
             when td.nome in ('M_PROTOCOLLO'
                            , 'M_REGISTRO_GIORNALIERO'
                            , 'M_PROTOCOLLO_INTEROPERABILITA'
                            , 'M_PROTOCOLLO_EMERGENZA'
                            , 'LETTERA_USCITA'
                            , 'M_PROVVEDIMENTO'
                            , 'PROTOCOLLO') then
                decode (ap.idrif, null, -p.id_documento, gd.id_documento)
             else
                decode (gd.id_documento, null, -p.id_documento, gd.id_documento)
          end
             id_documento
        , p.id_documento
        , p.idrif
        , p.anno
        , p.numero
        , p.tipo_registro
        , p.data
        , p.oggetto
        , p.modalita modalita
        , p.class_cod
        , p.fascicolo_anno
        , p.fascicolo_numero
        , p.tipo_documento
        , std.descrizione_tipo_documento
        , p.descrizione_tipo_registro
        , p.class_dal
        , p.stato_pr
        , p.unita_protocollante
        , td.area_modello
        , td.nome
        , case
             when td.nome in ('M_PROTOCOLLO'
                            , 'M_REGISTRO_GIORNALIERO'
                            , 'M_PROTOCOLLO_INTEROPERABILITA'
                            , 'M_PROTOCOLLO_EMERGENZA'
                            , 'LETTERA_USCITA'
                            , 'M_PROVVEDIMENTO'
                            , 'PROTOCOLLO') then
                'PROTOCOLLO'
             else
                td.nome
          end
             categoria
     from gdm_proto_view p
        , agp_protocolli ap
        , gdo_documenti gd
        , gdm_documenti d
        , gdm_tipi_documento td
        , gdm_seg_tipi_documento std
    where d.id_documento = p.id_documento
      and d.stato_documento = 'BO'
      and d.id_documento = gd.id_documento_esterno(+)
      and ap.id_documento(+) = gd.id_documento
      and nvl (gd.valido, 'Y') = 'Y'
      and td.id_tipodoc(+) = d.id_tipodoc
      and p.tipo_documento = std.tipo_documento(+)
/
