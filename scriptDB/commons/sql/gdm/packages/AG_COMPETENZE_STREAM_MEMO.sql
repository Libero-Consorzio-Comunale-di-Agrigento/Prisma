--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_STREAM_MEMO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE       "AG_COMPETENZE_STREAM_MEMO"
IS
/******************************************************************************
 NOME:        Ag_Competenze_STREAM_memo
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui documenti STREAM_MEMO dell'area SYSMAIL
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione CONSTANT VARCHAR2 (40) := 'V1.00';
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

/*****************************************************************************
 NOME:        LETTURA.
 DESCRIZIONE: Un utente ha i diritti di vedere uno RAPPORTO se ha
 tale diritto sul protocollo collegato.
INPUT  p_idDocumento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION LETTURA (
      p_idDocumento             VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere uno RAPPORTO se ha
 tale diritto sul protocollo collegato.
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION LETTURA (
      p_area                    VARCHAR2
    , p_modello                 VARCHAR2
    , p_codice_richiesta        VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;

END Ag_Competenze_STREAM_memo;
/
CREATE OR REPLACE PACKAGE BODY       "AG_COMPETENZE_STREAM_MEMO"
IS
/******************************************************************************
-- NOME:        Ag_Competenze_memo
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui docuemnti STREAM_MEMO dell'area sysmail.
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
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere uno STREA_MEMO se ha
    tale diritto sul MEMO collegato.
   INPUT  p_idDocumento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      idmemo   NUMBER;
      retval   NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         SELECT id_documento
           INTO idmemo
           FROM riferimenti rife
          WHERE rife.tipo_relazione = 'STREAM'
            AND id_documento_rif = p_iddocumento;

         retval := ag_competenze_memo.lettura (idmemo, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;

/*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere uno RAPPORTO se ha
 tale diritto sul protocollo collegato.
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER
   IS
      iddocumento   NUMBER;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta
                                          );
         retval := lettura (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;
END ag_competenze_stream_memo;
/
