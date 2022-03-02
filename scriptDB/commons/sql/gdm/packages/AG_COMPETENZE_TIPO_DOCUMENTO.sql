--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_TIPO_DOCUMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_COMPETENZE_TIPO_DOCUMENTO"
IS
   /******************************************************************************
    NOME:        Ag_Competenze_tipo_documento
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti DIZ_TIPI_DOCUMENTO.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    </CODE>
   ******************************************************************************/

   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   /*****************************************************************************
    NOME:        CREAZIONE.
    DESCRIZIONE: Un utente ha i diritti in creazione su un tipo_documento se il suo ruolo
    ha privilegio CRETIDO.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION CREAZIONE (p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare un tipo_documento se il suo ruolo
    ha privilegio ETIDO.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION ELIMINAZIONE (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        GESTIONE_COMPETENZE.
    DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un tipo_documento se almeno uno dei suoi ruoli
    ha privilegio MANTIDO.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION GESTIONE_COMPETENZE (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        UTILIZZO_IN_PROT.
    DESCRIZIONE: Si usa per fare i diritti in utilizzo del tipo
    documento in protocollazione.
    Non ci sono limiti per RPI e utenti con privilegio MTOT.
    Non ci sono limiti se non sono state associate unità al tipo documento.
    Negli altri casi bisogna avere CPROT per una delle unità associate.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    22/05/2017  SC  Utilizzo di CPROT.
   ********************************************************************************/
   FUNCTION utilizzo_in_prot (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare un tipo_documento se il suo ruolo
    ha privilegio MTIDO.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION MODIFICA (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;
END AG_COMPETENZE_TIPO_DOCUMENTO;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_TIPO_DOCUMENTO"
IS
   /******************************************************************************
    NOME:        Ag_Competenze_tipo_documento
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti DIZ_TIPI_DOCUMENTO.
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
    DESCRIZIONE: Un utente ha i diritti in creazione su un tipo_documento se il suo ruolo
    ha privilegio CRETIDO.

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
      aprivilegio   ag_privilegi.privilegio%TYPE := 'CRETIDO';
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
    DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un tipo_documento se almeno uno dei suoi ruoli
    ha privilegio MANTIDO.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION gestione_competenze (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MANTIDO';
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

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare un tipo_documento se il suo ruolo
    ha privilegio ETIDO.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'ETIDO';
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
   END eliminazione;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare un tipo_documento se il suo ruolo
    ha privilegio MTIDO.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MTIDO';
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
   END modifica;

   /*****************************************************************************
    NOME:        UTILIZZO_IN_PROT.
    DESCRIZIONE: Si usa per fare i diritti in utilizzo del tipo
    documento in protocollazione.
    Non ci sono limiti per RPI e utenti con privilegio MTOT.
    Non ci sono limiti se non sono state associate unità al tipo documento.
    Negli altri casi bisogna avere CPROT per una delle unità associate.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    22/05/2017  SC  Utilizzo di CPROT.
   ********************************************************************************/
   FUNCTION utilizzo_in_prot (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval     NUMBER := 0;
      risposta   VARCHAR2 (1);
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = ag_utilities.utente_superuser_segreteria
         THEN
            RETURN 1;
         END IF;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => 'MTOT',
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF NVL (retval, 0) = 0
      THEN
         DECLARE
            d_esiste_unita_associata   NUMBER;
         BEGIN
            SELECT DISTINCT 1
              INTO d_esiste_unita_associata
              FROM seg_unita_tipi_doc untd,
                   documenti docu_untd,
                   seg_tipi_documento tido,
                   documenti docu_tido
             WHERE     untd.id_documento = docu_untd.id_documento
                   AND docu_untd.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND tido.id_documento = docu_tido.id_documento
                   AND docu_tido.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND tido.id_documento = p_id_documento
                   AND tido.tipo_documento = untd.tipo_documento;

            BEGIN
               SELECT DISTINCT 1
                 INTO retval
                 FROM seg_unita_tipi_doc untd,
                      documenti docu_untd,
                      seg_tipi_documento tido,
                      documenti docu_tido,
                      ag_priv_utente_tmp priv
                WHERE     untd.id_documento = docu_untd.id_documento
                      AND docu_untd.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND tido.id_documento = docu_tido.id_documento
                      AND docu_tido.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND tido.id_documento = p_id_documento
                      AND tido.tipo_documento = untd.tipo_documento
                      AND untd.unita = priv.unita
                      AND priv.utente = p_utente
                      AND priv.al IS NULL
                      AND priv.privilegio = 'CPROT';
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := 1;
         END;
      END IF;

      RETURN retval;
   END utilizzo_in_prot;
END AG_COMPETENZE_TIPO_DOCUMENTO;
/
