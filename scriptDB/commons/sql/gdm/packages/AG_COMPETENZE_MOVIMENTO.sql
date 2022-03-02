--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_MOVIMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     "AG_COMPETENZE_MOVIMENTO"
IS
/******************************************************************************
 NOME:        Ag_Competenze_movimento
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui docuemnti DIZ_MOVIMENTI.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
 </CODE>
******************************************************************************/

   -- Revisione del Package
   s_revisione          afc.t_revision := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
/*****************************************************************************
 NOME:        GESTIONE_COMPETENZE.
 DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un modivimento se almeno uno dei suoi ruoli
 ha privilegio MANMOV.


RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION GESTIONE_COMPETENZE (
      p_idDocumento        VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        LETTURA
 DESCRIZIONE: Un utente ha i diritti di visualizzare un movimento se ha
 il privilegio con lo stesso codice del movimento.


RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    12/01/2009  SC  Prima emissione. A35913.1.0.
********************************************************************************/
   FUNCTION lettura (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;
END AG_COMPETENZE_MOVIMENTO;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_MOVIMENTO"
IS
   nome_campo_codice   VARCHAR2 (20) := 'TIPO_MOVIMENTO';
   s_revisione_body    afc.t_revision := '001';

   /******************************************************************************
    NOME:        Ag_Competenze_movimento
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti DIZ_MOVIMENTI.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore   Descrizione.
    000   02/01/2007 SC       Prima emissione.
    001   24/03/2016 MM       Modificata funzione lettura per passaggio data.
          27/04/2017 SC       ALLINEATO ALLO STANDARD
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
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END;                                              -- Ag_Competenza.versione

   /*****************************************************************************
    NOME:        GESTIONE_COMPETENZE.
    DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un movimento se almeno uno dei suoi ruoli
    ha privilegio MANMOV.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION gestione_competenze (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MANMOV';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         -- aooIndex: calcola l'aoo dell'utente
         -- calcola l'ottica dell'aoo.
         --get_ruoli_utente(p_utente);
         retval :=
            ag_utilities.verifica_privilegio_utente (NULL,
                                                     p_utente,
                                                     aprivilegio,
                                                     TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END gestione_competenze;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti di visualizzare un movimento se ha
    il privilegio con lo stesso codice del movimento.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data          Autore   Descrizione.
    000    12/01/2009   SC       Prima emissione. A35913.1.0.
    001   24/03/2016    MM       Modificata funzione per passaggio sysdate ad
                                 ag_utilities.verifica_privilegio_utente.
    002    07/04/2017   SC       Gestione date privilegi
   ********************************************************************************/
   FUNCTION lettura (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval      NUMBER := 0;
      movimento   VARCHAR2 (20);
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         movimento := f_valore_campo (p_iddocumento, nome_campo_codice);
         -- aooIndex: calcola l'aoo dell'utente
         -- calcola l'ottica dell'aoo.
         --get_ruoli_utente(p_utente);
         retval :=
            ag_utilities.verifica_privilegio_utente (NULL,
                                                     movimento,
                                                     p_utente,
                                                     TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;
END AG_COMPETENZE_MOVIMENTO;
/
