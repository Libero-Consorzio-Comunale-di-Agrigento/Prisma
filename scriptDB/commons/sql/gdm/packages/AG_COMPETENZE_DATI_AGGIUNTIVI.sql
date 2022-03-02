--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_DATI_AGGIUNTIVI runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_COMPETENZE_DATI_AGGIUNTIVI
IS
   /******************************************************************************
    NOME:        AG_COMPETENZE_DATI_AGGIUNTIVI
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui DATI_AGGIUNTIVI
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data        Autore   Descrizione.
    00   02/01/2007  SC       Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   /*****************************************************************************
       NOME:        CREAZIONE.
       DESCRIZIONE: Dato che la possibilita' di creare rapporti e' gia' verificata
    dai domini di protezione, qui si restituisce sempre 1.
      INPUT  p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION CREAZIONE (p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare uno RAPPORTO se il suo ruolo
    ha privilegio ERAP.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION ELIMINAZIONE (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        ELIMINAZIONE.
       DESCRIZIONE: Un utente ha i diritti di cancellare uno RAPPORTO se il suo ruolo
    ha privilegio ERAP.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION ELIMINAZIONE (p_area                VARCHAR2,
                          p_modello             VARCHAR2,
                          p_codice_richiesta    VARCHAR2,
                          p_utente              VARCHAR2)
      RETURN NUMBER;

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
   FUNCTION LETTURA (p_idDocumento VARCHAR2, p_utente VARCHAR2)
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
   FUNCTION LETTURA (p_area                VARCHAR2,
                     p_modello             VARCHAR2,
                     p_codice_richiesta    VARCHAR2,
                     p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare uno RAPPORTO se il suo ruolo
    ha privilegio MRAP. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
    e lo smistamento non deve essere storico nè preso in carico.
   INPUT  p_idDocumento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION MODIFICA (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        MODIFICA.
       DESCRIZIONE: Un utente ha i diritti di modificare uno RAPPORTO se il suo ruolo
    ha privilegio MRAP. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
    e lo smistamento non deve essere storico nè preso in carico.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION MODIFICA (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_COMPETENZE_DATI_AGGIUNTIVI
IS
   /******************************************************************************
    NOME:        AG_COMPETENZE_DATI_AGGIUNTIVI
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui DATI_AGGIUNTIVI.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data       Autore Descrizione.
    000  02/01/2007 SC     Prima emissione.
    001  19/06/2020 MM     Gestione id di agspr
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '001';

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
   END;                                              -- Ag_Competenza.versione

   /*****************************************************************************
       NOME:        CREAZIONE.
       DESCRIZIONE: Dato che la possibilita' di creare rapporti e' gia' verificata
    dai domini di protezione, qui si restituisce sempre 1.
      INPUT  p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      retval := AGSPR_COMPETENZE_PROTOCOLLO.CREAZIONE (P_UTENTE);
      RETURN retval;
   END creazione;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare uno RAPPORTO se il suo ruolo
    ha privilegio ERAP.
    Se il documento ha pero' BLOCCO_MODIFICHE = Y, il privilegio necessario è ERAPBLC.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          04/12/2007 A23289.0.0 Se il doc è bloccato , la modifica è consentita solo a chi ha
                                ERAPBLC.

   ********************************************************************************/
   FUNCTION eliminazione (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval            NUMBER := 0;
      d_id_protocollo   NUMBER;
   BEGIN
      d_id_protocollo := f_valore_campo (p_iddocumento, 'ID_PROTOCOLLO');
      retval :=
         AGSPR_COMPETENZE_PROTOCOLLO.ELIMINAZIONE (d_id_protocollo, p_utente);
      RETURN retval;
   END eliminazione;

   /*****************************************************************************
       NOME:        ELIMINAZIONE.
       DESCRIZIONE: Un utente ha i diritti di cancellare uno RAPPORTO se il suo ruolo
    ha privilegio ERAP.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION eliminazione (p_area                VARCHAR2,
                          p_modello             VARCHAR2,
                          p_codice_richiesta    VARCHAR2,
                          p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   NUMBER;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := eliminazione (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END eliminazione;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare uno RAPPORTO se il suo ruolo
    ha privilegio MRAP. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
    e lo smistamento non deve essere storico nè preso in carico.
   INPUT  p_idDocumento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data           Autore  Descrizione.
       00    02/01/2007  SC      Prima emissione.
       002   03/10/2017  MM      Immodificabilità delle anagrafiche Ap@ci.
   ********************************************************************************/
   FUNCTION modifica (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval            NUMBER := 0;
      d_id_protocollo   NUMBER;
   BEGIN
      d_id_protocollo := f_valore_campo (p_iddocumento, 'ID_PROTOCOLLO');
      retval := AGSPR_COMPETENZE_PROTOCOLLO.modifica (d_id_protocollo, p_utente);
      RETURN retval;
   END modifica;

   /*****************************************************************************
       NOME:        MODIFICA.
       DESCRIZIONE: Un utente ha i diritti di modificare uno RAPPORTO se il suo ruolo
    ha privilegio MRAP. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
    e lo smistamento non deve essere storico nè preso in carico.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION modifica (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   NUMBER;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := modifica (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END modifica;

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
   FUNCTION lettura (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval            NUMBER := 0;
      d_id_protocollo   NUMBER;
   BEGIN
      d_id_protocollo := f_valore_campo (p_iddocumento, 'ID_PROTOCOLLO');
      retval := AGSPR_COMPETENZE_PROTOCOLLO.LETTURA (d_id_protocollo, p_utente);
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
   FUNCTION lettura (p_area                VARCHAR2,
                     p_modello             VARCHAR2,
                     p_codice_richiesta    VARCHAR2,
                     p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   NUMBER;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := lettura (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;
END;
/
