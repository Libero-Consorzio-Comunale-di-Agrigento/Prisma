--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_COMPETENZE_DOCUMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AGP_COMPETENZE_DOCUMENTO"
IS
   /******************************************************************************
    NOME:        AGP_COMPETENZE_DOCUMENTO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data        Autore   Descrizione.
    00   11/07/2019  MM       Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION lettura (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_testo (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_testo_gdm (p_id_documento_esterno    VARCHAR2,
                               p_utente                  VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_testo (p_idDocumento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_testo_gdm (p_id_documento_esterno    VARCHAR2,
                                p_utente                  VARCHAR2)
      RETURN NUMBER;

   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION eliminazione (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION eliminazione_gdm (p_id_documento_esterno    VARCHAR2,
                              p_utente                  VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY "AGP_COMPETENZE_DOCUMENTO"
IS
   /******************************************************************************
    NOME:        AGP_COMPETENZE_DOCUMENTO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
                 verificare i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data        Autore Descrizione.
   000  11/07/2019  MM     Creazione.
   002  17/12/2019  MM     Modificata funzione get_competenza
   ******************************************************************************/

   s_revisione_body   CONSTANT afc.t_revision := '002';

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

   FUNCTION get_id_doc_from_id_esterno (p_id_documento_esterno VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
   BEGIN
      SELECT id_documento
        INTO d_id_documento
        FROM gdo_documenti
       WHERE id_documento_esterno = p_id_documento_esterno;

      RETURN d_id_documento;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_competenza_documento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_competenza      VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
      retval           NUMBER;
   BEGIN
      BEGIN
         SELECT 1
           INTO retval
           FROM gdo_documenti_competenze
          WHERE     id_documento = p_id_documento
                AND utente = p_utente
                AND (   (modifica = 'Y' AND p_competenza = 'modifica')
                     OR (lettura = 'Y' AND p_competenza = 'lettura')
                     OR (    cancellazione = 'Y'
                         AND p_competenza = 'cancellazione'))
         UNION
         SELECT 1
           FROM gdo_documenti_competenze comp, ag_priv_utente_tmp u
          WHERE     comp.id_documento = p_id_documento
                AND u.utente = p_utente
                AND comp.unita_progr = u.progr_unita
                AND comp.utente IS NULL
                AND NVL (comp.ruolo, u.ruolo) = u.ruolo
                AND (   (modifica = 'Y' AND p_competenza = 'modifica')
                     OR (lettura = 'Y' AND p_competenza = 'lettura')
                     OR (    cancellazione = 'Y'
                         AND p_competenza = 'cancellazione'))
                AND SYSDATE BETWEEN u.dal
                                AND NVL (u.al, TO_DATE (3333333, 'j'))
         UNION
         SELECT 1
           FROM gdo_documenti_competenze comp, ag_priv_utente_tmp u
          WHERE     comp.id_documento = p_id_documento
                AND u.utente = p_utente
                AND comp.unita_progr IS NULL
                AND comp.utente IS NULL
                AND comp.ruolo = u.ruolo
                AND (   (modifica = 'Y' AND p_competenza = 'modifica')
                     OR (lettura = 'Y' AND p_competenza = 'lettura')
                     OR (    cancellazione = 'Y'
                         AND p_competenza = 'cancellazione'))
                AND SYSDATE BETWEEN u.dal
                                AND NVL (u.al, TO_DATE (3333333, 'j'));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END;

   FUNCTION get_competenza (p_id_documento    NUMBER,
                            p_utente          VARCHAR2,
                            p_competenza      VARCHAR2)
      RETURN NUMBER
   IS
      retval                   NUMBER := NULL;
      d_id_documento_esterno   NUMBER;
   BEGIN
      BEGIN
         SELECT d.id_documento_esterno
           INTO d_id_documento_esterno
           FROM gdo_documenti d
          WHERE d.id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20999,
                  'Impossibile determinare id documento esterno per id '
               || p_id_documento);
      END;

      IF p_competenza = 'lettura'
      THEN
         retval :=
            gdm_ag_competenze_documento.lettura (d_id_documento_esterno,
                                                 p_utente);
      END IF;

      IF p_competenza = 'modifica'
      THEN
         retval :=
            gdm_ag_competenze_documento.modifica (d_id_documento_esterno,
                                                  p_utente);
      END IF;

      IF p_competenza = 'cancellazione'
      THEN
         retval := 0;
      END IF;

      IF NVL (retval, 0) = 0
      THEN
         retval :=
            get_competenza_documento (p_id_documento, p_utente, p_competenza);
      END IF;


      RETURN retval;
   END;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON protocollato se il documento
    è in arrivo e collegato ad una mail e se ha un privilegio che gli consente di gestire
    il tag_mail presente sulla mail stessa, altrimenti il controllo è demandato al
    documentale.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, null altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    26/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura_non_protocollati (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      retval := 1;

      RETURN retval;
   END lettura_non_protocollati;

   -------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        creazione
    DESCRIZIONE: Un utente ha i diritti in creazione di protocolli se:
   - ha ruolo con privilegio CPROT.
   INPUT  p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := NULL;
   BEGIN
      retval := 1;

      RETURN retval;
   END creazione;

   /*****************************************************************************
    NOME:        MODIFICA.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data        Autore  Descrizione.
    00    11/07/2019  MM  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN get_competenza (p_id_documento, p_utente, 'modifica');
   END modifica;

   /* funzione associata al modello DOC_DA_FASCICOLARE per il calcolo delle competenze */
   FUNCTION modifica_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

      IF d_id_documento IS NOT NULL
      THEN
         retval := modifica (d_id_documento, p_utente);
      ELSE
         NULL;
         retval :=
            gdm_ag_competenze_documento.modifica (p_id_documento_esterno,
                                                  p_utente);
      END IF;

      RETURN retval;
   END;

   /*******************************************************************************
      NOME:          MODIFICA_TESTO.
      INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                     p_utente       varchar2: utente che richiede di leggere il
                                              documento.
      RITORNO:       Un testo è modificabile se è leggibile.

    Rev. Data       Autore   Descrizione.
    00    11/07/2019  MM  Prima emissione.
   *******************************************************************************/
   FUNCTION modifica_testo (p_idDocumento NUMBER, p_utente VARCHAR2)
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

   FUNCTION modifica_testo_gdm (p_id_documento_esterno    VARCHAR2,
                                p_utente                  VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      IF p_id_documento_esterno = 'PARNONINTERPRETATO'
      THEN
         RETVAL := 1;
      ELSE
         d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

         IF d_id_documento IS NOT NULL
         THEN
            retval := modifica_testo (d_id_documento, p_utente);
         ELSE
            NULL;
            retval :=
               gdm_ag_competenze_documento.modifica (p_id_documento_esterno,
                                                     p_utente);
         END IF;
      END IF;

      RETURN retval;
   END;

   /*****************************************************************************
    NOME:        eliminazione.

   INPUT  p_id_documento    varchar2: chiave identificativa del documento.
          p_utente          varchar2: utente che vuole eliminare il documento
   RITORNO:  se il documento è protocollato restituisce sempre 0, altrimenti
             restituisce null.

    Rev.  Data       Autore Descrizione.
    00    11/07/2019  MM  Prima emissione.
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN get_competenza (p_id_documento, p_utente, 'cancellazione');
   END eliminazione;

   /* funzione associata al modello LETTERA_USCITA per il calcolo delle competenze */
   FUNCTION eliminazione_gdm (p_id_documento_esterno    VARCHAR2,
                              p_utente                  VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

      IF d_id_documento IS NOT NULL
      THEN
         retval := eliminazione (d_id_documento, p_utente);
      ELSE
         retval :=
            gdm_ag_competenze_documento.eliminazione (p_id_documento_esterno,
                                                      p_utente);
      END IF;

      RETURN retval;
   END;

   FUNCTION lettura (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN get_competenza (p_id_documento, p_utente, 'lettura');
   END;

   /* funzione associata al modello LETTERA_USCITA per il calcolo delle competenze */
   FUNCTION lettura_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

      IF d_id_documento IS NOT NULL
      THEN
         retval := lettura (d_id_documento, p_utente);
      ELSE
         NULL;
         retval :=
            gdm_ag_competenze_documento.lettura (p_id_documento_esterno,
                                                 p_utente);
      END IF;

      RETURN retval;
   END;

   FUNCTION lettura_testo (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := NULL;
   BEGIN
      retval := 1;

      RETURN retval;
   END;

   FUNCTION lettura_testo_gdm (p_id_documento_esterno    VARCHAR2,
                               p_utente                  VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      IF p_id_documento_esterno = 'PARNONINTERPRETATO'
      THEN
         RETVAL := 1;
      ELSE
         d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

         IF d_id_documento IS NOT NULL
         THEN
            retval := lettura_testo (d_id_documento, p_utente);
         ELSE
            NULL;
            retval :=
               gdm_ag_competenze_documento.lettura (p_id_documento_esterno,
                                                    p_utente);
         END IF;
      END IF;

      RETURN retval;
   END;
END;
/
