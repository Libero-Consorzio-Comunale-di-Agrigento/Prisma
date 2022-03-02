--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_COMPETENZE_ALLEGATO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AGP_COMPETENZE_ALLEGATO"
IS
/******************************************************************************
 NOME:        AGP_COMPETENZE_ALLEGATO
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui protocolli.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev. Data        Autore   Descrizione.
 00   02/01/2007  SC       Prima emissione.
******************************************************************************/
-- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';
-- variabile globale per contenere il ritorno del lancio delle funzioni di protocollo
-- che viene fatto via sqlexecute perche' esistono solo se c'è l'integrazione.
   g_diritto              NUMBER (1);

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION lettura (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION lettura_testo (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY "AGP_COMPETENZE_ALLEGATO"
IS
   /******************************************************************************
    NOME:        AGP_COMPETENZE_ALLEGATO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data       Autore Descrizione.
   000  02/01/2007 SC     Prima emissione.
   ******************************************************************************/

   s_revisione_body    CONSTANT afc.t_revision := '000';

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
      RETURN afc.VERSION (s_revisione, NVL (s_revisione_body, '000'));
   END;

   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := NULL;
   BEGIN
      retval := 1;

      RETURN retval;
   END creazione;

   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
   BEGIN
      retval := 1;

      RETURN retval;
   END modifica;

   FUNCTION modifica_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_ret   NUMBER;
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      d_ret := 1;

      RETURN d_ret;
   END;

   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval     NUMBER := NULL;
      continua   NUMBER := 0;
   BEGIN
     retval := 1;

      RETURN retval;

   END eliminazione;
 FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
   BEGIN
      retval := 1;

      RETURN retval;
   END;

 FUNCTION lettura_testo (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
   BEGIN
      retval := 1;

      RETURN retval;
   END;

END;
/
