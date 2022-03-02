--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_SPEDIZIONE_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_SPEDIZIONE_UTILITY
AS
   /******************************************************************************
      NAME:       AG_SPEDIZIONE_UTILITY
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/07/2014      mmurabito       1. Created this package.
   ******************************************************************************/

   FUNCTION get_all_modalita_ricevimento (
      p_codice_amm                    IN VARCHAR2,
      p_codice_aoo                    IN VARCHAR2,
      p_documento_tramite             IN VARCHAR2,
      p_descrizione_mod_ricevimento   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_elenco_documenti_partenza (p_anno        IN VARCHAR2,
                                           p_registro    IN VARCHAR,
                                           p_dadata      IN VARCHAR,
                                           p_adata       IN VARCHAR,
                                           p_danum       IN VARCHAR,
                                           p_anum        IN VARCHAR,
                                           p_tipo_sped   IN VARCHAR2,
                                           p_barcode     IN VARCHAR2,
                                           p_unita       IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_documenti_spedizione (p_utente       IN VARCHAR2,
                                      p_anno         IN VARCHAR2,
                                      p_registro     IN VARCHAR,
                                      p_giorni       IN INTEGER,
                                      p_danum        IN VARCHAR,
                                      p_anum         IN VARCHAR,
                                      p_tipo_sped    IN VARCHAR,
                                      p_barcode      IN VARCHAR2,
                                      p_unita_mitt   IN VARCHAR2,
                                      p_unita_dest   IN VARCHAR2,
                                      p_quantita     IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_elenco_registri (p_codice_amm      IN VARCHAR2,
                                 p_codice_aoo      IN VARCHAR,
                                 p_tipo_registro   IN VARCHAR2,
                                 p_anno            IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_ulbc_count (p_gruppo IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN INTEGER;

   PROCEDURE update_ultimo_bc (p_gruppo   IN VARCHAR2,
                               p_tipo     IN VARCHAR2,
                               p_utente   IN VARCHAR2);

   PROCEDURE update_ultimo_bc_manuale (p_gruppo   IN VARCHAR2,
                                       p_bc       IN VARCHAR2,
                                       p_utente   IN VARCHAR2);

   FUNCTION get_ultimo_bc (p_gruppo IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION calcola_codice_controllo_bc (p_bc     IN VARCHAR2,
                                         p_tipo   IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION genera_barcode (p_id_documento   IN VARCHAR2,
                            p_gruppo         IN VARCHAR2,
                            p_tipo           IN VARCHAR2,
                            p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION genera_bc (p_gruppo   IN VARCHAR2,
                       p_tipo     IN VARCHAR2,
                       p_utente   IN VARCHAR2,
                       p_quanti   IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_ricerca_documenti (p_anno        IN VARCHAR2,
                                   p_registro    IN VARCHAR,
                                   p_tipo_sped   IN VARCHAR2,
                                   p_danum       IN NUMBER,
                                   p_anum        IN NUMBER,
                                   p_dadata      IN VARCHAR2,
                                   p_adata       IN VARCHAR2,
                                   p_barcode     IN VARCHAR2,
                                   p_unita       IN VARCHAR2)
      RETURN afc.t_ref_cursor;
END;
/

CREATE OR REPLACE PACKAGE BODY AG_SPEDIZIONE_UTILITY
IS
   /******************************************************************************
      NAME:       AG_SPEDIZIONE_UTILITY
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/07/2014  mmurabito        1. Created this package body.
      1.1        06/10/2020  mmalferrari      modificate update_ultimo_bc_manuale
                                              e update_ultimo_bc.
   ******************************************************************************/

   FUNCTION get_all_modalita_ricevimento (
      p_codice_amm                    IN VARCHAR2,
      p_codice_aoo                    IN VARCHAR2,
      p_documento_tramite             IN VARCHAR2,
      p_descrizione_mod_ricevimento   IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_refcursor   afc.t_ref_cursor;
   BEGIN
      OPEN d_refcursor FOR
           SELECT mod_ricevimento AS documento_tramite,
                  descrizione_mod_ricevimento,
                  costo_euro
             FROM seg_modalita_ricevimento, documenti
            WHERE     codice_amministrazione = p_codice_amm
                  AND codice_aoo = p_codice_aoo
                  AND documenti.id_documento =
                         seg_modalita_ricevimento.id_documento
                  AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                  AND TRUNC (SYSDATE) BETWEEN NVL (
                                                 seg_modalita_ricevimento.dataval_dal,
                                                 TO_DATE (2222222, 'j'))
                                          AND NVL (
                                                 seg_modalita_ricevimento.dataval_al,
                                                 TO_DATE (3333333, 'j'))
                  AND LOWER (mod_ricevimento) LIKE
                         '%' || LOWER (P_DOCUMENTO_TRAMITE) || '%'
                  AND LOWER (descrizione_mod_ricevimento) LIKE
                         '%' || LOWER (P_DESCRIZIONE_MOD_RICEVIMENTO) || '%'
         ORDER BY descrizione_mod_ricevimento;

      RETURN d_refcursor;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GET_ALL_MODALITA_RICEVIMENTO: ' || SQLERRM);
   END get_all_modalita_ricevimento;

   FUNCTION get_ricerca_documenti (p_anno        IN VARCHAR2,
                                   p_registro    IN VARCHAR,
                                   p_tipo_sped   IN VARCHAR2,
                                   p_danum       IN NUMBER,
                                   p_anum        IN NUMBER,
                                   p_dadata      IN VARCHAR2,
                                   p_adata       IN VARCHAR2,
                                   p_barcode     IN VARCHAR2,
                                   p_unita       IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_RICERCA_DOCUMENTI

         DESCRIZIONE: OTTIENE LA LISTA DEI  DESTINATARI A CUI E' STATO SPEDITO UN
                      DOCUMENTO IN DATA ODIERNA
         RITORNO:

         Rev.  Data             Autore      Descrizione.
         00    14/10/2014   MMUR     Prima emissione.
     ********************************************************************************/
      d_result   afc.t_ref_cursor;
      d_danum    NUMBER := NVL (p_danum, 0);
      d_anum     NUMBER := NVL (p_anum, 9999999);
   BEGIN
      OPEN d_result FOR
           SELECT gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     proto_view.id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'R',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N')
                     url,
                  seg_soggetti_protocollo.id_documento,
                  seg_soggetti_protocollo.idrif,
                  proto_view.numero,
                  proto_view.anno,
                  seg_soggetti_protocollo.bc_spedizione,
                  seg_soggetti_protocollo.QUANTITA,
                  seg_soggetti_protocollo.denominazione_vis,
                  seg_soggetti_protocollo.indirizzo_vis,
                  seg_soggetti_protocollo.documento_tramite,
                  seg_tipi_spedizione.descrizione,
                  SEG_MODALITA_RICEVIMENTO.DESCRIZIONE_MOD_RICEVIMENTO,
                  TO_CHAR (SEG_MODALITA_RICEVIMENTO.costo_euro, '999990.99')
                     AS costo_euro,
                  seg_tipi_spedizione.TIPO_SPEDIZIONE,
                  NVL (proto_view.unita_esibente,
                       proto_view.unita_protocollante)
                     AS unita,
                  SEG_UNITA.nome AS nome_unita,
                  seg_soggetti_protocollo.codice_richiesta
             FROM seg_soggetti_protocollo_view seg_soggetti_protocollo,
                  proto_view,
                  seg_tipi_spedizione,
                  seg_modalita_ricevimento,
                  seg_unita,
                  documenti docu_tisp,
                  documenti docu_mori
            WHERE     proto_view.idrif = seg_soggetti_protocollo.idrif
                  AND seg_tipi_spedizione.id_documento = docu_tisp.id_documento
                  AND docu_tisp.stato_documento NOT IN ('CA', 'RE', 'PB')
                  AND seg_modalita_ricevimento.id_documento =
                         docu_mori.id_documento
                  AND docu_mori.stato_documento NOT IN ('CA', 'RE', 'PB')
                  AND SEG_SOGGETTI_PROTOCOLLO.DATA_SPED BETWEEN TO_DATE (
                                                                   p_dadata,
                                                                   'dd/mm/yyyy')
                                                            AND TO_DATE (
                                                                   p_adata,
                                                                   'dd/mm/yyyy')
                  AND seg_soggetti_protocollo.documento_tramite =
                         seg_modalita_ricevimento.mod_ricevimento(+)
                  AND seg_modalita_ricevimento.tipo_spedizione =
                         seg_tipi_spedizione.tipo_spedizione(+)
                  AND proto_view.data BETWEEN NVL (
                                                 seg_modalita_ricevimento.dataval_dal,
                                                 TO_DATE (2222222, 'j'))
                                          AND NVL (
                                                 seg_modalita_ricevimento.dataval_al,
                                                 TO_DATE (3333333, 'j'))
                  AND proto_view.MODALITA = 'PAR'
                  AND seg_soggetti_protocollo.tipo_rapporto <> 'DUMMY'
                  AND NVL (proto_view.annullato, 'N') = 'N'
                  AND proto_view.ANNO = p_anno
                  AND proto_view.TIPO_REGISTRO = p_registro
                  AND NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO, 'POR') =
                         NVL (
                            p_tipo_sped,
                            NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO,
                                 'POR'))
                  AND NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO, 'POR') <>
                         'PEC'
                  AND proto_view.NUMERO BETWEEN d_danum AND d_anum
                  AND NVL (bc_spedizione, ' ') LIKE '%' || p_barcode || '%'
                  AND proto_view.data BETWEEN seg_unita.dal
                                          AND NVL (seg_unita.al,
                                                   TO_DATE (3333333, 'j'))
                  AND SEG_UNITA.unita =
                         NVL (proto_view.unita_esibente,
                              proto_view.unita_protocollante)
                  AND seg_unita.unita LIKE NVL (p_unita, '%')
         ORDER BY PROTO_VIEW.NUMERO DESC,
                  SEG_SOGGETTI_PROTOCOLLO.DATA_SPED DESC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GET_RICERCA_DOCUMENTI: ' || SQLERRM);
   END get_ricerca_documenti;

   FUNCTION get_elenco_documenti_partenza (p_anno        IN VARCHAR2,
                                           p_registro    IN VARCHAR,
                                           p_dadata      IN VARCHAR,
                                           p_adata       IN VARCHAR,
                                           p_danum       IN VARCHAR,
                                           p_anum        IN VARCHAR,
                                           p_tipo_sped   IN VARCHAR2,
                                           p_barcode     IN VARCHAR2,
                                           p_unita       IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
            NOME:        GET_ELENCO_DOCUMENTI_PARTENZA

            DESCRIZIONE: OTTIENE LA LISTA DEI  DOCUMENTI IN PARTENZA DI UN ANNO E DELL'ANNO SELEZIONATO

            RITORNO:

            Rev.  Data             Autore      Descrizione.
            00    08/07/2014   MMUR     Prima emissione.
           ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     proto_view.id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'W',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N')
                     url,
                  seg_soggetti_protocollo.id_documento,
                  seg_soggetti_protocollo.idrif,
                  proto_view.numero,
                  proto_view.anno,
                  seg_soggetti_protocollo.data_sped data_sped,
                  seg_soggetti_protocollo.bc_spedizione,
                  proto_view.MODALITA,
                  seg_soggetti_protocollo.QUANTITA,
                  seg_soggetti_protocollo.denominazione_vis,
                  seg_soggetti_protocollo.indirizzo_vis,
                  seg_soggetti_protocollo.documento_tramite,
                  seg_tipi_spedizione.descrizione,
                  SEG_MODALITA_RICEVIMENTO.DESCRIZIONE_MOD_RICEVIMENTO,
                  TO_CHAR (SEG_MODALITA_RICEVIMENTO.costo_euro, '999990.99')
                     AS costo_euro,
                  NVL (proto_view.unita_esibente,
                       proto_view.unita_protocollante)
                     AS unita,
                  SEG_UNITA.nome AS nome_unita,
                  proto_view.annullato,
                  proto_view.tipo_registro,
                  seg_soggetti_protocollo.tipo_rapporto,
                  TO_DATE (proto_view.data, 'DD/MM/YYYY') AS DATA,
                  proto_view.utente_protocollante,
                  seg_tipi_spedizione.BARCODE_ESTERO,
                  seg_tipi_spedizione.BARCODE_ITALIA,
                  seg_tipi_spedizione.TIPO_SPEDIZIONE,
                  SEG_REGISTRI.ULTIMO_NUMERO_REG,
                  seg_soggetti_protocollo.codice_richiesta
             FROM seg_soggetti_protocollo_view seg_soggetti_protocollo,
                  proto_view,
                  seg_tipi_spedizione,
                  seg_modalita_ricevimento,
                  SEG_UNITA,
                  SEG_REGISTRI
            WHERE     proto_view.idrif = seg_soggetti_protocollo.idrif
                  AND seg_soggetti_protocollo.documento_tramite =
                         seg_modalita_ricevimento.mod_ricevimento(+)
                  AND seg_modalita_ricevimento.tipo_spedizione =
                         seg_tipi_spedizione.tipo_spedizione(+)
                  AND NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO, 'POR') =
                         NVL (
                            p_tipo_sped,
                            NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO,
                                 'POR'))
                  AND NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO, 'POR') <>
                         'PEC'
                  AND proto_view.MODALITA = 'PAR'
                  --AND seg_soggetti_protocollo.tipo_rapporto = 'DEST'
                  AND NVL (proto_view.annullato, 'N') = 'N'
                  AND NVL (TRUNC (SEG_SOGGETTI_PROTOCOLLO.DATA_SPED),
                           TRUNC (SYSDATE)) >= TRUNC (SYSDATE)
                  AND proto_view.NUMERO BETWEEN p_danum AND p_anum
                  AND TRUNC (
                         NVL (
                            SEG_SOGGETTI_PROTOCOLLO.DATA_SPED,
                            NVL (TO_DATE (p_dadata, 'dd/mm/yyyy'),
                                 TRUNC (SYSDATE)))) BETWEEN NVL (
                                                               TO_DATE (
                                                                  p_dadata,
                                                                  'dd/mm/yyyy'),
                                                               TRUNC (SYSDATE))
                                                        AND NVL (
                                                               TO_DATE (
                                                                  p_adata,
                                                                  'dd/mm/yyyy'),
                                                               TRUNC (SYSDATE))
                  AND proto_view.ANNO = p_anno
                  AND proto_view.TIPO_REGISTRO = p_registro
                  AND proto_view.ANNO = SEG_REGISTRI.ANNO_REG
                  AND proto_view.TIPO_REGISTRO = SEG_REGISTRI.TIPO_REGISTRO
                  AND NVL (bc_spedizione, ' ') LIKE '%' || p_barcode || '%'
                  AND proto_view.data BETWEEN seg_unita.dal
                                          AND TO_DATE (
                                                    TO_CHAR (
                                                       NVL (
                                                          seg_unita.al,
                                                          TO_DATE (3333333,
                                                                   'j')),
                                                       'dd/mm/yyyy')
                                                 || '23:59:59',
                                                 'dd/mm/yyyy hh24:mi:ss')
                  AND SEG_UNITA.unita =
                         NVL (proto_view.unita_esibente,
                              proto_view.unita_protocollante)
                  AND seg_unita.unita LIKE NVL (p_unita, '%')
         ORDER BY PROTO_VIEW.NUMERO DESC,
                  SEG_SOGGETTI_PROTOCOLLO.DATA_SPED DESC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_SPEDIZIONE_UTILITY.GET_ELENCO_DOCUMENTI_PARTENZA: '
            || SQLERRM);
   END get_elenco_documenti_partenza;

   FUNCTION get_documenti_spedizione (p_utente       IN VARCHAR2,
                                      p_anno         IN VARCHAR2,
                                      p_registro     IN VARCHAR,
                                      p_giorni       IN INTEGER,
                                      p_danum        IN VARCHAR,
                                      p_anum         IN VARCHAR,
                                      p_tipo_sped    IN VARCHAR,
                                      p_barcode      IN VARCHAR2,
                                      p_unita_mitt   IN VARCHAR2,
                                      p_unita_dest   IN VARCHAR2,
                                      p_quantita     IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
            NOME:        GET_DOCUMENTI_SPEDIZIONE

            DESCRIZIONE: OTTIENE LA LISTA DEI  DOCUMENTI  SPEDITI

            RITORNO:

            Rev.  Data             Autore      Descrizione.
            00    03/09/2014   MMUR     Prima emissione.
           ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     proto_view.id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'R',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N')
                     url,
                  proto_view.anno,
                  proto_view.numero,
                  seg_soggetti_protocollo.data_sped,
                  seg_soggetti_protocollo.denominazione_vis,
                  ufficio_smistamento,
                  des_ufficio_smistamento AS UNITA_DESTINATARIA,
                  ufficio_trasmissione,
                  des_ufficio_trasmissione AS UNITA_MITTENTE,
                  proto_view.TIPO_REGISTRO,
                  proto_view.DESCRIZIONE_TIPO_REGISTRO,
                  PROTO_VIEW.ID_DOCUMENTO_PROTOCOLLO,
                  seg_soggetti_protocollo.idrif,
                  seg_soggetti_protocollo.documento_tramite,
                  seg_soggetti_protocollo.id_documento,
                  SEG_MODALITA_RICEVIMENTO.DESCRIZIONE_MOD_RICEVIMENTO,
                  TO_CHAR (SEG_MODALITA_RICEVIMENTO.costo_euro, '999990.99')
                     AS costo_euro,
                  seg_soggetti_protocollo.bc_spedizione,
                  seg_soggetti_protocollo.QUANTITA,
                  seg_tipi_spedizione.BARCODE_ESTERO,
                  seg_tipi_spedizione.BARCODE_ITALIA,
                  ag_competenze_documento.in_carico (proto_view.id_documento,
                                                     p_utente)
                     IN_CARICO,
                  ag_competenze_documento.da_ricevere (proto_view.id_documento,
                                                       p_utente)
                     DA_RICEVERE,
                  (SELECT NOME
                     FROM DOCUMENTI D, TIPI_DOCUMENTO TP
                    WHERE     D.ID_TIPODOC = TP.ID_TIPODOC
                          AND D.ID_DOCUMENTO = proto_view.id_documento)
                     AS codice_modello,
                  (SELECT AREA
                     FROM DOCUMENTI D, TIPI_DOCUMENTO TP
                    WHERE     D.ID_TIPODOC = TP.ID_TIPODOC
                          AND D.ID_DOCUMENTO = proto_view.id_documento)
                     AS area,
                  (SELECT CODICE_RICHIESTA
                     FROM DOCUMENTI D, TIPI_DOCUMENTO TP
                    WHERE     D.ID_TIPODOC = TP.ID_TIPODOC
                          AND D.ID_DOCUMENTO = proto_view.id_documento)
                     AS codice_richiesta
             FROM proto_view,
                  seg_soggetti_protocollo_view seg_soggetti_protocollo,
                  seg_modalita_ricevimento,
                  seg_tipi_spedizione,
                  seg_smistamenti
            WHERE     seg_soggetti_protocollo.documento_tramite =
                         seg_modalita_ricevimento.mod_ricevimento(+)
                  AND seg_modalita_ricevimento.tipo_spedizione =
                         seg_tipi_spedizione.tipo_spedizione(+)
                  AND proto_view.TIPO_REGISTRO = P_registro
                  AND proto_view.ANNO = P_anno
                  AND proto_view.NUMERO BETWEEN NVL (p_danum, 0)
                                            AND NVL (p_anum, 9999999)
                  AND NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO, 'POR') =
                         NVL (
                            p_tipo_sped,
                            NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO,
                                 'POR'))
                  AND NVL (SEG_MODALITA_RICEVIMENTO.MOD_RICEVIMENTO, 'POR') <>
                         'PEC'
                  AND seg_soggetti_protocollo.tipo_rapporto = 'DEST'
                  AND (   (    TRUNC (seg_smistamenti.smistamento_dal) <=
                                  SYSDATE
                           AND P_giorni IS NULL)
                       OR (TRUNC (seg_smistamenti.smistamento_dal) BETWEEN TRUNC (
                                                                                SYSDATE
                                                                              - P_giorni)
                                                                       AND TRUNC (
                                                                              SYSDATE)))
                  AND seg_smistamenti.idrif = proto_view.idrif
                  AND seg_smistamenti.stato_smistamento <> 'F'
                  AND (   ag_competenze_documento.in_carico (
                             proto_view.id_documento,
                             p_utente) = 1
                       OR ag_competenze_documento.da_ricevere (
                             proto_view.id_documento,
                             p_utente) = 1)
                  AND seg_smistamenti.tipo_smistamento <> 'DUMMY'
                  AND NVL (bc_spedizione, ' ') LIKE ('%' || p_barcode || '%')
                  AND ufficio_smistamento LIKE
                         NVL (DECODE (p_unita_dest, '- -', '', p_unita_dest),
                              '%')
                  AND ufficio_trasmissione LIKE
                         NVL (DECODE (p_unita_mitt, '- -', '', p_unita_mitt),
                              '%')
         ORDER BY proto_view.anno DESC,
                  proto_view.TIPO_REGISTRO ASC,
                  proto_view.numero DESC,
                  denominazione_vis ASC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GET_DOCUMENTI_SPEDIZIONE: ' || SQLERRM);
   END get_documenti_spedizione;


   FUNCTION get_elenco_registri (p_codice_amm      IN VARCHAR2,
                                 p_codice_aoo      IN VARCHAR,
                                 p_tipo_registro   IN VARCHAR2,
                                 p_anno            IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
            NOME:        GET_ELENCO_DOCUMENTI_PARTENZA

            DESCRIZIONE: OTTIENE LA LISTA DEI  REGISTRI

            RITORNO:

            Rev.  Data             Autore      Descrizione.
            00    08/07/2014   MMUR     Prima emissione.
           ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT anno_reg,
                  tipo_registro,
                  anno_reg || ' ' || descrizione_tipo_registro AS descrizione
             FROM seg_registri, documenti
            WHERE     codice_amministrazione = p_codice_amm
                  AND codice_aoo = p_codice_aoo
                  AND in_uso = 'Y'
                  AND documenti.id_documento = seg_registri.id_documento
                  AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                  AND tipo_registro = NVL (p_tipo_registro, tipo_registro)
                  AND anno_reg = NVL (p_anno, anno_reg)
         ORDER BY anno_reg DESC, descrizione_tipo_registro;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GET_ELENCO_REGISTRI: ' || SQLERRM);
   END get_elenco_registri;

   FUNCTION get_ulbc_count (p_gruppo IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN INTEGER
   IS
      /*****************************************************************************
     NOME:        GET_ULBC_COUNT

     DESCRIZIONE: VERIFICA SE PER IL GRUPPO SELEZIONATO ESISTE UN BC

     RITORNO:  1 SE IL GRUPPO HA UN BC VALIDO, 0 SE IL BC=0, -1 ALTRIMENTI

     Rev.  Data             Autore      Descrizione.
     00    08/10/2014   MMUR     Prima emissione.
    ********************************************************************************/
      d_result    INTEGER;
      ultimo_BC   VARCHAR2 (20);
   BEGIN
      SELECT COUNT (*)
        INTO d_result
        FROM ag_ultimi_bc ubc, seg_modalita_ricevimento mori
       WHERE     mori.MOD_RICEVIMENTO = p_gruppo
             AND UBC.TIPO_MODALITA_RICEVIMENTO = MORI.TIPO_SPEDIZIONE
             AND UTENTE = p_utente
             AND SYSDATE BETWEEN NVL (MORI.DATAVAL_DAL,
                                      TO_DATE (2222222, 'J'))
                             AND NVL (MORI.DATAVAL_AL,
                                      TO_DATE (3333333, 'J'));

      IF d_result > 0
      THEN
         SELECT ultimo_bc
           INTO ultimo_BC
           FROM ag_ultimi_bc ubc, seg_modalita_ricevimento mori
          WHERE     mori.MOD_RICEVIMENTO = p_gruppo
                AND UBC.TIPO_MODALITA_RICEVIMENTO = MORI.TIPO_SPEDIZIONE
                AND UTENTE = p_utente
                AND SYSDATE BETWEEN NVL (MORI.DATAVAL_DAL,
                                         TO_DATE (2222222, 'J'))
                                AND NVL (MORI.DATAVAL_AL,
                                         TO_DATE (3333333, 'J'));

         IF ultimo_BC = '0'
         THEN
            d_result := 0;
         ELSE
            d_result := 1;
         END IF;
      ELSE
         d_result := -1;
      END IF;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GET_ULBC_COUNT: ' || SQLERRM);
   END get_ulbc_count;


   PROCEDURE update_ultimo_bc (p_gruppo   IN VARCHAR2,
                               p_tipo     IN VARCHAR2,
                               p_utente   IN VARCHAR2)
   IS
      /*****************************************************************************
     NOME:        UPDATE_ULTIMO_BC

     DESCRIZIONE: AGGIORNA L'ULTIMO BARCODE DEL GRUPPO SELEZIONATO

     RITORNO:

     Rev.  Data             Autore      Descrizione.
     00    08/10/2014   MMUR     Prima emissione.
    ********************************************************************************/
      sStartBC     VARCHAR2 (10);
      sValoreBC    VARCHAR2 (10);
      sCheckBC     VARCHAR2 (10);
      sEndBC       VARCHAR2 (10);

      nValoreBc    INTEGER;
      nLenValore   INTEGER;
   BEGIN
      IF p_tipo = 'E'
      THEN
         SELECT SUBSTR (ultimo_bc, 1, 2),
                SUBSTR (ultimo_bc, 3, LENGTH (ultimo_bc) - 6),
                SUBSTR (ultimo_bc, LENGTH (ultimo_bc) - 2, 1),
                SUBSTR (ultimo_bc, LENGTH (ultimo_bc) - 1)
           INTO sStartBC,
                sValoreBc,
                sCheckBC,
                sEndBC
           FROM ag_ultimi_bc ubc, seg_modalita_ricevimento mori
          WHERE     mori.MOD_RICEVIMENTO = p_gruppo
                AND UBC.TIPO_MODALITA_RICEVIMENTO = MORI.TIPO_SPEDIZIONE
                AND utente = p_utente
                AND SYSDATE BETWEEN NVL (MORI.DATAVAL_DAL,
                                         TO_DATE (2222222, 'J'))
                                AND NVL (MORI.DATAVAL_AL,
                                         TO_DATE (3333333, 'J'));

         nLenValore := LENGTH (sValoreBc);
         nValoreBc := TO_NUMBER (sValoreBc) + 1;
         sValoreBc := LPAD (TO_CHAR (nValoreBc), nLenValore, '0');

         sCheckBC := CALCOLA_CODICE_CONTROLLO_BC (sValoreBc, p_tipo);

         UPDATE ag_ultimi_bc
            SET ultimo_bc = sStartBC || sValoreBc || '-' || sCheckBC || sEndBC
          WHERE     tipo_modalita_ricevimento =
                       (SELECT MORI.TIPO_SPEDIZIONE
                          FROM seg_modalita_ricevimento mori, DOCUMENTI
                         WHERE     mori.MOD_RICEVIMENTO = p_gruppo
                               AND documenti.id_documento = mori.id_documento
                               AND documEnti.stato_documento = 'BO'
                               AND SYSDATE BETWEEN NVL (
                                                      dataval_dal,
                                                      TO_DATE ('2222222',
                                                               'j'))
                                               AND NVL (
                                                      dataval_al,
                                                      TO_DATE ('2222222',
                                                               'j')))
                AND utente = p_utente;
      ELSE
         UPDATE ag_ultimi_bc
            SET ultimo_bc =
                   LPAD (
                      TO_NUMBER (ultimo_bc) + 1,
                      DECODE (
                         LENGTH (TO_NUMBER (ultimo_bc)),
                         LENGTH (TO_NUMBER (ultimo_bc) + 1), LENGTH (
                                                                ultimo_bc),
                         DECODE (SUBSTR (ultimo_bc, 1, 1),
                                 '0', LENGTH (ultimo_bc),
                                 LENGTH (ultimo_bc) + 1)),
                      '0')
          WHERE     tipo_modalita_ricevimento =
                       (SELECT MORI.TIPO_SPEDIZIONE
                          FROM seg_modalita_ricevimento mori, DOCUMENTI
                         WHERE     mori.MOD_RICEVIMENTO = p_gruppo
                               AND documenti.id_documento = mori.id_documento
                               AND documEnti.stato_documento = 'BO'
                               AND SYSDATE BETWEEN NVL (
                                                      dataval_dal,
                                                      TO_DATE ('2222222',
                                                               'j'))
                                               AND NVL (
                                                      dataval_al,
                                                      TO_DATE ('2222222',
                                                               'j')))
                AND utente = p_utente;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.UPDATE_ULTIMO_BC: ' || SQLERRM);
   END update_ultimo_bc;

   PROCEDURE update_ultimo_bc_manuale (p_gruppo   IN VARCHAR2,
                                       p_bc       IN VARCHAR2,
                                       p_utente   IN VARCHAR2)
   IS
      /*****************************************************************************
        NOME:        UPDATE_ULTIMO_BC_MANUALE

        DESCRIZIONE: AGGIORNA L'ULTIMO BARCODE DEL GRUPPO SELEZIONATO QUANDO VIENE
                     INSERITO A MANO DALLA MASCHERA

        RITORNO:

        Rev.  Data             Autore      Descrizione.
        00    15/11/2014   MMUR     Prima emissione.
     *******************************************************************************/
      d_esiste      NUMBER := 0;
      d_tipo_sped   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT MORI.TIPO_SPEDIZIONE
           INTO d_tipo_sped
           FROM seg_modalita_ricevimento mori
          WHERE mori.MOD_RICEVIMENTO = p_gruppo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20999,
                  'Impossibile determinare il tipo di spedizione associato alla modalita'' '
               || p_gruppo);
         WHEN TOO_MANY_ROWS
         THEN
            BEGIN
               SELECT MORI.TIPO_SPEDIZIONE
                 INTO d_tipo_sped
                 FROM seg_modalita_ricevimento mori, documEnti
                WHERE     mori.MOD_RICEVIMENTO = p_gruppo
                      AND documenti.id_documento = mori.id_documento
                      AND documEnti.stato_documento = 'BO'
                      AND SYSDATE BETWEEN NVL (dataval_dal,
                                               TO_DATE ('2222222', 'j'))
                                      AND NVL (dataval_al,
                                               TO_DATE ('2222222', 'j'));
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  raise_application_error (
                     -20999,
                        'Impossibile determinare il tipo di spedizione associato alla modalita'' '
                     || p_gruppo
                     || p_gruppo);
            END;
      END;

      SELECT COUNT (1)
        INTO d_esiste
        FROM ag_ultimi_bc
       WHERE tipo_modalita_ricevimento = d_tipo_sped AND utente = p_utente;


      IF d_esiste > 0
      THEN
         UPDATE ag_ultimi_bc
            SET ultimo_bc = P_BC
          WHERE tipo_modalita_ricevimento = d_tipo_sped AND UTENTE = p_utente;
      ELSE
         INSERT
           INTO ag_ultimi_bc (utente, tipo_modalita_ricevimento, ultimo_bc)
         VALUES (p_utente, d_tipo_sped, p_bc);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.UPDATE_ULTIMO_BC_MANUALE: ' || SQLERRM);
   END update_ultimo_bc_manuale;


   FUNCTION get_ultimo_bc (p_gruppo IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
     NOME:        GET_ULTIMO_BC

     DESCRIZIONE: RESTITUISCE L'ULTIMO BC GENERATO PER PER IL GRUPPO SELEZIONATO

     RITORNO:  RESTITUISCE L'ULTIMO BC GENERATO PER PER IL GRUPPO SELEZIONATO

     Rev.  Data             Autore      Descrizione.
     00    08/10/2014   MMUR     Prima emissione.
    ********************************************************************************/
      ultimo_BC   VARCHAR2 (20);
   BEGIN
      SELECT ultimo_bc
        INTO ultimo_BC
        FROM ag_ultimi_bc ubc, seg_modalita_ricevimento mori
       WHERE     mori.MOD_RICEVIMENTO = p_gruppo
             AND UBC.TIPO_MODALITA_RICEVIMENTO = MORI.TIPO_SPEDIZIONE
             AND UTENTE = p_utente
             AND SYSDATE BETWEEN NVL (MORI.DATAVAL_DAL,
                                      TO_DATE (2222222, 'J'))
                             AND NVL (MORI.DATAVAL_AL,
                                      TO_DATE (3333333, 'J'));

      RETURN ultimo_BC;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GET_ULTIMO_BC: ' || SQLERRM);
   END get_ultimo_bc;

   FUNCTION calcola_codice_controllo_bc (p_bc     IN VARCHAR2,
                                         p_tipo   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
     NOME:        CALCOLA_CODICE_CONTROLLO_BC

     DESCRIZIONE: CALCOLA IL CODICE DI CONTROLLO DEL BC GENERATO
                             Calcola il codice di controllo del barcode di 11 cifre per le spedizioni in Italia, in base al seguente algoritmo:
                             1. Somma le cifre di posto dispari.
                             2. Somma il valore delle cifre diposto pari moltiplicato per 11.
                             3. Somma i valori ottenuti da 1 e 2.
                             4. Somma le cifre del valore ottenuto in 3.
                             5. Restituisce il modulo 10 del valore ottenuto in 4.

                             Calcola il codice di controllo del barcode per le spedizioni all'Estero, in base al seguente algoritmo:
                             1. si moltiplicano i primi 8 numeri della sequenza che appare sotto il codice a barre per i
                                 corrispondenti fattori di peso nel seguente ordine: 8  6  4  2  3  5  9  7
                             2. si sommano i numeri così ottenuti
                             3. si divide il risultato per 11 e si calcola il resto
                             4. il codice di controllo (ultimo numero della sequenza che appare sotto il bar-code) è pari a:
                                 5 se il resto è 0
                                 0 se il resto è 1
                                 11 meno il resto negli altri casi.
     RITORNO:  CODICE DI CONTROLLO

     Rev.  Data             Autore      Descrizione.
     00    08/10/2014   MMUR     Prima emissione.
    ********************************************************************************/
      codice_controllo   VARCHAR2 (20);
      sCodice            VARCHAR2 (20);
      n                  INTEGER := 0;
      nCifra             INTEGER := 0;
      lSomma             INTEGER := 0;
      lSPari             INTEGER := 0;
      lSDispari          INTEGER := 0;
      tmpSomma           INTEGER := 0;
      nPeso              INTEGER := 0;
      nModulo            INTEGER := 0;
   BEGIN
      CASE UPPER (p_tipo)
         WHEN 'I'
         THEN
            FOR n IN 1 .. LENGTH (p_bc)
            LOOP
               nCifra := TO_NUMBER (SUBSTR (p_bc, n, 1));

               IF MOD (n, 2) = 1
               THEN
                  lSDispari := lSDispari + nCifra;
               ELSE
                  lSPari := lSPari + (11 * nCifra);
               END IF;
            END LOOP;

            tmpSomma := lSPari + lSDispari;

            --DBMS_OUTPUT.PUT_LINE('tmpSomma: ' || tmpSomma);

            FOR n IN 1 .. LENGTH (TO_CHAR (tmpSomma))
            LOOP
               nCifra := TO_NUMBER (SUBSTR (TO_CHAR (tmpSomma), n, 1));
               lSomma := lSomma + nCifra;
            END LOOP;

            codice_controllo := TO_CHAR (MOD (lSomma, 10));
         WHEN 'E'
         THEN
            FOR n IN 1 .. LENGTH (p_bc)
            LOOP
               nCifra := TO_NUMBER (SUBSTR (p_bc, n, 1));

               CASE n
                  WHEN 1
                  THEN
                     nPeso := 8;
                  WHEN 2
                  THEN
                     nPeso := 6;
                  WHEN 3
                  THEN
                     nPeso := 4;
                  WHEN 4
                  THEN
                     nPeso := 2;
                  WHEN 5
                  THEN
                     nPeso := 3;
                  WHEN 6
                  THEN
                     nPeso := 5;
                  WHEN 7
                  THEN
                     nPeso := 9;
                  WHEN 8
                  THEN
                     nPeso := 7;
               END CASE;

               lSomma := lSomma + (nCifra * nPeso);
               nModulo := MOD (lSomma, 11);

               CASE nModulo
                  WHEN 0
                  THEN
                     codice_controllo := '5';
                  WHEN 1
                  THEN
                     codice_controllo := '0';
                  ELSE
                     codice_controllo := TO_CHAR (11 - nModulo);
               END CASE;
            END LOOP;
      END CASE;

      RETURN codice_controllo;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.CALCOLA_CODICE_CONTROLLO_BC: ' || SQLERRM);
   END calcola_codice_controllo_bc;


   FUNCTION genera_barcode (p_id_documento   IN VARCHAR2,
                            p_gruppo         IN VARCHAR2,
                            p_tipo           IN VARCHAR2,
                            p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GENERA_BC

        DESCRIZIONE:  genera il nuovo barcode per un tipo di spedizione

        RITORNO:

        Rev.  Data             Autore      Descrizione.
        00    09/10/2014   MMUR     Prima emissione.
       ********************************************************************************/
      barcode           VARCHAR2 (20);
      tmp_barcode       VARCHAR2 (20);
      ultimo_bc_count   INTEGER;
      d_result          afc.t_ref_cursor;
   BEGIN
      ultimo_bc_count := get_ulbc_count (p_gruppo, p_utente);

      IF ultimo_bc_count = 1
      THEN
         update_ultimo_bc (p_gruppo, p_tipo, p_utente);
         tmp_barcode := get_ultimo_bc (p_gruppo, p_utente);

         OPEN d_result FOR
            SELECT DECODE (
                      P_TIPO,
                      'E', tmp_barcode,
                      'I',    tmp_barcode
                           || '-'
                           || calcola_codice_controllo_bc (tmp_barcode, 'I'),
                      '')
                      AS barcode,
                   'OK' AS result,
                   p_id_documento AS id_documento
              FROM DUAL;
      ELSE
         OPEN d_result FOR
            SELECT '' AS barcode,
                   'KO GRUPPO' AS result,
                   p_id_documento AS id_documento
              FROM DUAL;
      END IF;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GENERA_BC: ' || SQLERRM);
   END genera_barcode;

   FUNCTION genera_bc (p_gruppo   IN VARCHAR2,
                       p_tipo     IN VARCHAR2,
                       p_utente   IN VARCHAR2,
                       p_quanti   IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GENERA_BC

        DESCRIZIONE:  genera il nuovo barcode per un tipo di spedizione

        RITORNO:

        Rev.  Data             Autore      Descrizione.
        00    09/10/2014   MMUR     Prima emissione.
       ********************************************************************************/
      barcode           VARCHAR2 (20);
      tmp_barcode       VARCHAR2 (20);
      ultimo_bc_count   INTEGER;
      d_statement       VARCHAR2 (32000);
      d_result          afc.t_ref_cursor;
   BEGIN
      FOR i IN 1 .. p_quanti
      LOOP
         ultimo_bc_count := get_ulbc_count (p_gruppo, p_utente);

         IF ultimo_bc_count = 1
         THEN
            update_ultimo_bc (p_gruppo, p_tipo, p_utente);
            tmp_barcode := get_ultimo_bc (p_gruppo, p_utente);
            d_statement :=
                  d_statement
               || 'SELECT  decode('''
               || P_TIPO
               || ''', ''E'', '''
               || tmp_barcode
               || ''', ''I'', '''
               || tmp_barcode
               || '-'
               || calcola_codice_controllo_bc (tmp_barcode, 'I')
               || ''', '''') AS barcode,
                      ''OK'' AS result
                 FROM DUAL union all ';
         ELSE
            d_statement :=
                  d_statement
               || 'SELECT '''' AS barcode, ''KO GRUPPO'' AS result FROM DUAL union all ';
         END IF;
      END LOOP;

      d_statement := SUBSTR (d_statement, 1, LENGTH (d_statement) - 11);
      DBMS_OUTPUT.put_line (d_statement);

      OPEN d_result FOR d_statement;


      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_SPEDIZIONE_UTILITY.GENERA_BC: ' || SQLERRM);
   END;
END;
/
