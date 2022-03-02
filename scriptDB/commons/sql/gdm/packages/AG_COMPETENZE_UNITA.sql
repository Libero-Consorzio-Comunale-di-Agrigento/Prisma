--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_UNITA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_COMPETENZE_UNITA"
IS
/******************************************************************************
 NOME:        Ag_Competenze_Unita
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui docuemnti UNITA.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
 </CODE>
******************************************************************************/

   -- Revisione del Package
   s_revisione          CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
/*****************************************************************************
 NOME:        LETTURA.
 DESCRIZIONE: Un utente ha i diritti di inserire documenti o cartelle in
 su una UNITA  se appartiene all'unita stessa o a un'unita dello stesso ramo.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION LETTURA (
      p_id_documento            VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        INSERIMENTO.
 DESCRIZIONE: Un utente ha i diritti di inserire documenti o cartelle in
 su una UNITA  se appartiene all'unita stessa.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION INSERIMENTO (
      p_id_documento            VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        lettura_query_iter.
 DESCRIZIONE: Dato in id_query e un codice utente, verifica se l'utente
    appartiene all'unita' associata alla query.

INPUT  p_id_query NUMBER: id query.
      p_id_utente varchar2: utente che richiede di leggere.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    12/12/2008  SC  Prima emissione. A30381.0.0.
********************************************************************************/
   FUNCTION lettura_query_iter (p_id_query NUMBER, p_id_utente VARCHAR2)
      RETURN NUMBER;
END Ag_Competenze_Unita;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_UNITA"
IS
/******************************************************************************
 NOME:        Ag_Competenze_Unita
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui docuemnti M_FASCICOLO.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
******************************************************************************/
   FUNCTION versione
      RETURN VARCHAR2
   IS
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilità del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
   BEGIN
      RETURN s_revisione;
   END;                                              -- Ag_Competenza.versione

--------------------------------------------------------------------------------
/*****************************************************************************
 NOME:        GET_UFFICIO_COMPETENZA.
 DESCRIZIONE: Restitusice il codice dell'unita identificato da p_id_viewcartella.

INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
RITORNO: valore del campo riservato

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_codice_unita (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        seg_unita.unita%TYPE;
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'UNITA');
      RETURN retval;
   END get_codice_unita;

/*****************************************************************************
 NOME:        GET_AL.
 DESCRIZIONE: Restitusice il valore del campo al dell'unita
              identificato da p_id_viewcartella.

INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
RITORNO: valore del campo riservato

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_al (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1000);
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'AL');
      RETURN retval;
   END get_al;

/*****************************************************************************
 NOME:        LETTURA.
 DESCRIZIONE: Un utente ha i diritti vedere
 una UNITA  se appartiene all'unita stessa o a un'unita dello stesso ramo.
 Se l'unita e' chiusa nessuno ha diritto di vederla.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval        NUMBER                 := 0;
      codiceunita   seg_unita.unita%TYPE;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF get_al (p_id_documento) IS NULL
      THEN
         codiceunita := get_codice_unita (p_id_documento);

         BEGIN
            retval :=
               ag_utilities.verifica_ramo_utente (p_unita       => codiceunita,
                                                  p_utente      => p_utente
                                                 );
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END lettura;

/*****************************************************************************
 NOME:        INSERIMENTO.
 DESCRIZIONE: Un utente ha i diritti di inserire documenti o cartelle in
 una UNITA  se appartiene all'unita stessa.
  Se l'unita e' chiusa nessuno ha diritto di inserirvi documenti.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION inserimento (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF get_al (p_id_documento) IS NULL
      THEN
         BEGIN
            retval :=
               ag_utilities.verifica_unita_utente
                                (p_unita       => get_codice_unita
                                                               (p_id_documento),
                                 p_utente      => p_utente
                                );
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END inserimento;

/*****************************************************************************
 NOME:        lettura_query_iter.
 DESCRIZIONE: Dato in id_query e un codice utente, verifica se l'utente
    appartiene all'unita' associata alla query.

INPUT  p_id_query NUMBER: id query.
      p_id_utente varchar2: utente che richiede di leggere.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    12/12/2008  SC  Prima emissione. A30381.0.0.
********************************************************************************/
   FUNCTION lettura_query_iter (p_id_query NUMBER, p_id_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_codice_ufficio   seg_unita.unita%TYPE;
   BEGIN
      IF ag_utilities.inizializza_utente (p_id_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      SELECT f_valore_campo (id_documento_profilo, 'UFFICIO_SMISTAMENTO')
        INTO d_codice_ufficio
        FROM QUERY
       WHERE id_query = p_id_query;

      RETURN ag_utilities.verifica_unita_utente (d_codice_ufficio,
                                                 p_id_utente);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END lettura_query_iter;
END ag_competenze_unita;
/
