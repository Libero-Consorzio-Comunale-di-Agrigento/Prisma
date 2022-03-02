--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_DOC_DA_FASC_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_doc_da_fasc_utility
IS
   /******************************************************************************
    NOME:        AG_DOC_DA_FASC_UTILITY.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 documenti da fascicolare.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   16/01/2013 MM     Creazione.
    01   14/08/2015 MM     Aggiunta elimina_smistamenti.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.01';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_documento (p_id_documento IN NUMBER, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION competenza_creazione (p_utente IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_unita_utente (p_utente        IN VARCHAR2,
                              p_utente_prot   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE elimina_smistamenti (p_id_documento NUMBER);
END ag_doc_da_fasc_utility;
/
CREATE OR REPLACE PACKAGE BODY ag_doc_da_fasc_utility
IS
   /******************************************************************************
    NOME:        AG_DOC_DA_FASC_UTILITY.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 documenti da fascicolare.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000   16/01/2013 MM     Creazione.
    001   14/08/2015 MM     Aggiunta elimina_smistamenti.
          26/04/2017 SC     ALLINEATO ALLO STANDARD
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

   FUNCTION competenza_creazione (p_utente IN VARCHAR2)
      RETURN NUMBER
   IS
      d_competenza   NUMBER;
   BEGIN
      d_competenza := ag_competenze_documento.creazione (p_utente);

      RETURN d_competenza;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;


   FUNCTION get_documento (p_id_documento IN NUMBER, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
       NOME:        GET_DOCUMENTO

       DESCRIZIONE:

       RITORNO:

       Rev.  Data       Autore  Descrizione.
       000   16/01/2013 MM      Creazione.
     *******************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT docu_da_fasc.*,
                docu.codice_richiesta,
                seg_classificazioni.class_descr descrizione_classifica,
                ag_fascicolo_utility.get_oggetto (seg_fascicoli.id_documento,
                                                  p_utente)
                   descrizione_fascicolo,
                ag_fascicolo_utility.get_desc_ubicazione (
                   docu_da_fasc.class_cod,
                   TO_CHAR (docu_da_fasc.class_dal, 'dd/mm/yyyy'),
                   docu_da_fasc.fascicolo_anno,
                   docu_da_fasc.fascicolo_numero)
                   ubicazione_fascicolo,
                ag_competenze_documento.creazione (p_utente) creazione,
                ag_competenze_documento.lettura (docu_da_fasc.id_documento,
                                                 p_utente)
                   lettura,
                ag_competenze_documento.modifica (docu_da_fasc.id_documento,
                                                  p_utente)
                   modifica,
                NVL (seg_fascicoli.stato_scarto, '**') fasc_stato_scarto
           FROM spr_da_fascicolare docu_da_fasc,
                documenti docu,
                (SELECT seg_classificazioni.*
                   FROM seg_classificazioni,
                        documenti docu_clas,
                        cartelle cart_clas
                  WHERE     docu_clas.id_documento =
                               seg_classificazioni.id_documento
                        AND docu_clas.stato_documento NOT IN ('CA',
                                                              'RE',
                                                              'PB')
                        AND cart_clas.id_documento_profilo =
                               seg_classificazioni.id_documento
                        AND NVL (cart_clas.stato, 'BO') <> 'CA')
                seg_classificazioni,
                (SELECT seg_fascicoli.*
                   FROM seg_fascicoli,
                        documenti docu_fasc,
                        cartelle cart_fasc
                  WHERE     docu_fasc.id_documento =
                               seg_fascicoli.id_documento
                        AND docu_fasc.stato_documento NOT IN ('CA',
                                                              'RE',
                                                              'PB')
                        AND cart_fasc.id_documento_profilo =
                               seg_fascicoli.id_documento
                        AND NVL (cart_fasc.stato, 'BO') <> 'CA')
                seg_fascicoli
          WHERE     seg_fascicoli.class_cod(+) = docu_da_fasc.class_cod
                AND seg_fascicoli.class_dal(+) = docu_da_fasc.class_dal
                AND seg_fascicoli.fascicolo_anno(+) =
                       docu_da_fasc.fascicolo_anno
                AND seg_fascicoli.fascicolo_numero(+) =
                       docu_da_fasc.fascicolo_numero
                AND seg_classificazioni.class_cod(+) = docu_da_fasc.class_cod
                AND seg_classificazioni.class_dal(+) = docu_da_fasc.class_dal
                AND docu_da_fasc.id_documento = p_id_documento
                AND docu.id_documento = docu_da_fasc.id_documento
                AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB');

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DOC_DA_FASC_UTILITY.GET_DOCUMENTO: ' || SQLERRM);
   END;

   /*  01  07/04/2017   SC Gestione date privilegi   */
   FUNCTION get_unita_utente (p_utente        IN VARCHAR2,
                              p_utente_prot   IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT DISTINCT seg_unita.unita, seg_unita.nome
           FROM seg_unita, ag_priv_utente_tmp
          WHERE     TRUNC (SYSDATE) BETWEEN SEG_UNITA.DAL
                                        AND NVL (seg_unita.al,
                                                 TRUNC (SYSDATE))
                AND ag_priv_utente_tmp.utente = NVL (p_utente_prot, p_utente)
                AND ag_priv_utente_tmp.privilegio = 'DAFASC'
                AND seg_unita.unita = ag_priv_utente_tmp.unita
                AND TRUNC (SYSDATE) <= /*BETWEEN NVL (ag_priv_utente_tmp.dal,
                                                 TRUNC (SYSDATE)
                                                )
                                        AND */
                       NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'));

      RETURN d_result;
   END;

   PROCEDURE elimina_smistamenti (p_id_documento NUMBER)
   IS
      d_idrif   VARCHAR2 (100);
   BEGIN
      SELECT idrif
        INTO d_idrif
        FROM spr_da_fascicolare
       WHERE id_documento = p_id_documento;

      ag_smistamento.elimina_smistamenti (d_idrif);
   END;
END ag_doc_da_fasc_utility;
/
