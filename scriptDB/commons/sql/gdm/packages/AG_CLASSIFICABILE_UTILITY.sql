--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_CLASSIFICABILE_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_CLASSIFICABILE_UTILITY
IS
/******************************************************************************
 NOME:        AG_CLASSIFICABILE_UTILITY
 DESCRIZIONE: Procedure e Funzioni di utility documenti smistabili.
 ANNOTAZIONI: Progetto AFFARI_GENERALI.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 00   10/02/2014 MM     Creazione.
******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION is_in_fasc_riservato (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION get_dati_scarto (p_id_documento IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_stato
      RETURN afc.t_ref_cursor;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_CLASSIFICABILE_UTILITY
IS
/******************************************************************************
 NOME:        AG_CLASSIFICABILE_UTILITY
 DESCRIZIONE: Procedure e Funzioni di utility documenti smistabili.
 ANNOTAZIONI: Progetto AFFARI_GENERALI.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  10/02/2014 MM     Creazione.
 001  24/06/2016 MM     Modifica alla funzione get_dati_scarto.
******************************************************************************/
   s_revisione_body   afc.t_revision := '001';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   FUNCTION is_in_fasc_riservato (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      d_return   NUMBER := 0;
   BEGIN
      SELECT distinct 1
        INTO d_return
        FROM classificabile_view
       WHERE id_documento = p_id_documento
         AND NVL (riservato, 'N') != ag_competenze_protocollo.is_riservato (id_documento);

      RETURN d_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END;

   FUNCTION get_dati_scarto (p_id_documento IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        get_dati_scarto
       DESCRIZIONE: Ritorna il risultato di una query su CLASSIFICABILE_VIEW.
       PARAMETRI:   Chiavi e attributi della table
       RITORNA:     Un ref_cursor che punta al risultato della query.

       NOTE:        .

      ******************************************************************************/
      d_ref_cursor   afc.t_ref_cursor;
   BEGIN

      OPEN d_ref_cursor FOR
         SELECT NVL (CLASSIFICABILE_VIEW.stato_scarto, '**') stato_scarto,
                TO_CHAR (CLASSIFICABILE_VIEW.data_stato_scarto,
                         'dd/mm/yyyy hh24:mi:ss')
                   data_stato_scarto,
                CLASSIFICABILE_VIEW.numero_nulla_osta,
                TO_CHAR (CLASSIFICABILE_VIEW.data_nulla_osta, 'dd/mm/yyyy')
                   data_nulla_osta,
                DECODE (
                   NVL (DOCUMENTI.CONSERVAZIONE, 'xx'),
                   'CC', 1,
                   DECODE (NVL (DOCUMENTI.CONSERVAZIONE, 'xx'),
                           'DC', 1,
                           DECODE (NVL (DOCUMENTI.CONSERVAZIONE, 'xx'), 'IC', 1, 0)))
                   in_conservazione,
                DECODE (
                   ag_utilities.is_fascicolo (p_id_documento),
                   0, AG_FASCICOLO_UTILITY.GET_DESC_SCARTO (
                         seg_fascicoli.id_documento),
                   '')
                   FASC_DESC_SCARTO,
                SEG_FASCICOLI.STATO_SCARTO FASC_STATO_SCARTO
           FROM CLASSIFICABILE_VIEW,
                documenti,
                (SELECT seg_fascicoli.*
                   FROM seg_fascicoli, documenti
                  WHERE     documenti.id_documento = seg_fascicoli.id_documento
                        AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB'))
                seg_fascicoli
          WHERE     documenti.id_documento = CLASSIFICABILE_VIEW.id_documento
                AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND CLASSIFICABILE_VIEW.id_documento = p_id_documento
                AND CLASSIFICABILE_VIEW.class_cod = seg_fascicoli.class_cod(+)
                AND CLASSIFICABILE_VIEW.class_dal = seg_fascicoli.class_dal(+)
                AND CLASSIFICABILE_VIEW.fascicolo_anno =
                       seg_fascicoli.fascicolo_anno(+)
                AND CLASSIFICABILE_VIEW.fascicolo_numero =
                       seg_fascicoli.fascicolo_numero(+)
         ;
      RETURN d_ref_cursor;

   END;

   FUNCTION get_tipi_stato
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT stato STATO_SCARTO, descrizione
           from ag_stati_scarto
          order by 2;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error
                               (-20999,
                                   'AG_CLASSIFICABILE_UTILITY.GET_TIPI_STATO: '
                                || SQLERRM
                               );
   END;

END;
/
