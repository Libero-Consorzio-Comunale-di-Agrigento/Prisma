--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_SMISTABILE_VIEW runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_SMISTABILE_VIEW" ("ID_DOCUMENTO", "ID_DOCUMENTO_ESTERNO", "ANNO", "ID_CLASSIFICAZIONE", "ID_FASCICOLO", "DATA", "IDRIF", "MOVIMENTO", "NUMERO", "NUMERO_7", "OGGETTO", "ID_SCHEMA_PROTOCOLLO", "TIPO_REGISTRO", "ID_ENTE", "CATEGORIA", "RISERVATO", "FIRMATO") AS 
  SELECT -p."ID_DOCUMENTO" id_documento,
       p.id_documento id_documento_esterno,
       p."ANNO",
       -cl.id_documento id_classificazione,
       -f.id_documento id_fascicolo,
       p."DATA",
       p."IDRIF",
       DECODE (p."MODALITA",
               'ARR', 'ARRIVO',
               'PAR', 'PARTENZA',
               'INT', 'INTERNO',
               '')
          movimento,
       p."NUMERO",
       LPAD (NVL (p.NUMERO, ''), 7, '0') numero_7,
       p."OGGETTO",
       -sp.id_documento id_schema_protocollo,
       p."TIPO_REGISTRO",
       enti.id_ente id_ente,
       /*gdc_utility_pkg.f_get_url_oggetto ('',
                                          '',
                                          p.id_documento,
                                          'D',
                                          '',
                                          '',
                                          '',
                                          'R',
                                          '',
                                          '',
                                          '5',
                                          'N')
          link_documento,*/
       DECODE (NVL (td.nome, 'M_PROTOCOLLO'),
               'M_REGISTRO_GIORNALIERO', 'REGISTRO_GIORNALIERO',
               'M_PROTOCOLLO_INTEROPERABILITA', 'PEC',
               'M_PROTOCOLLO_EMERGENZA', 'EMERGENZA',
               'LETTERA_USCITA', 'LETTERA',
               'M_PROVVEDIMENTO', 'PROVVEDIMENTO',
               'MEMO_PROTOCOLLO', 'MEMO_PROTOCOLLO',
               'DOC_DA_FASCICOLARE', 'DA_NON_PROTOCOLLARE',
               'PROTOCOLLO')
          categoria /*
        td.area_modello,
        NVL (td.nome, 'M_PROTOCOLLO'),
        d.CODICE_RICHIESTA,
        D.UTENTE_AGGIORNAMENTO*/
                   ,
       CAST (NVL (P.RISERVATO, 'N') AS CHAR (1)) RISERVATO,
       CAST (NVL (FIRMATO, 'N') AS CHAR (1)) FIRMATO
  FROM gdm_smistabile_view p,
       gdm_documenti d,
       gdo_enti enti,
       gdm_tipi_documento td,
       gdm_classificazioni cl,
       gdm_fascicoli f,
       gdm_seg_tipi_documento sp
 WHERE     d.id_documento = p.id_documento
       AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
       AND enti.amministrazione =
              NVL (p.codice_amministrazione,
                   gdm_ag_parametro.get_valore ('CODICE_AMM_1', '@agVar@'))
       AND enti.aoo =
              NVL (p.codice_aoo,
                   gdm_ag_parametro.get_valore ('CODICE_AOO_1', '@agVar@'))
       AND enti.ottica =
              gdm_ag_parametro.get_valore ('SO_OTTICA_PROT_1', '@agVar@')
       AND td.id_tipodoc(+) = d.id_tipodoc
       AND cl.class_cod(+) = p.class_cod
       AND cl.class_dal(+) = p.class_dal
       AND f.class_cod(+) = p.class_cod
       AND f.class_dal(+) = p.class_dal
       AND f.fascicolo_anno(+) = p.fascicolo_anno
       AND f.fascicolo_numero(+) = p.fascicolo_numero
       AND sp.tipo_documento(+) = p.tipo_documento
       AND sp.codice_amministrazione(+) =
              NVL (p.codice_amministrazione,
                   gdm_ag_parametro.get_valore ('CODICE_AMM_1', '@agVar@'))
       AND sp.codice_aoo(+) =
              NVL (p.codice_aoo,
                   gdm_ag_parametro.get_valore ('CODICE_AOO_1', '@agVar@'))
/
