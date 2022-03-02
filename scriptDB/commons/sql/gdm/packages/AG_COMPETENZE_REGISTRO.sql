--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_REGISTRO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     "AG_COMPETENZE_REGISTRO"
IS
/******************************************************************************
 NOME:        Ag_Competenze_registro
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui docuemnti DIZ_REGISTRI.
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
 NOME:        CREAZIONE.
 DESCRIZIONE: Un utente ha i diritti in creazione su un registro se il suo ruolo
 ha privilegio CREREG.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION CREAZIONE (
      p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        GESTIONE_COMPETENZE.
 DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un registro se almeno uno dei suoi ruoli
 ha privilegio MANREG.


RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION GESTIONE_COMPETENZE (
      p_idDocumento        VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
END AG_COMPETENZE_REGISTRO;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_REGISTRO"
IS
   /******************************************************************************
    NOME:        Ag_Competenze_registro
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti DIZ_REGISTRI.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          27/04/2017  SC  ALLINEATO ALLO STANDARD
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
    NOME:        CREAZIONE.
    DESCRIZIONE: Un utente ha i diritti in creazione su un registro se il suo ruolo
    ha privilegio CREREG.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'CREREG';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END creazione;

   /*****************************************************************************
 NOME:        GESTIONE_COMPETENZE.
 DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un registro se almeno uno dei suoi ruoli
 ha privilegio MANREG.


RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
 01    07/04/2017  SC  Gestione date privilegi
********************************************************************************/
   FUNCTION gestione_competenze (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MANREG';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END gestione_competenze;
END AG_COMPETENZE_REGISTRO;
/
