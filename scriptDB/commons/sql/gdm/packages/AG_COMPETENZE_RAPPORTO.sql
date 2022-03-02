--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_RAPPORTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     "AG_COMPETENZE_RAPPORTO"
IS
/******************************************************************************
 NOME:        Ag_Competenze_Rapporto
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui documenti M_RAPPORTO
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev. Data        Autore   Descrizione.
 00   02/01/2007  SC       Prima emissione.
 01   16/05/2012  MM       Modifiche versione 2.1.
******************************************************************************/
   -- Revisione del Package
   s_revisione CONSTANT VARCHAR2 (40) := 'V1.00';
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
   /*****************************************************************************
    NOME:        VERIFICA_CREAZIONE.
    DESCRIZIONE:
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data              Autore      Descrizione.
    00    16/02/2012    MMur        Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_creazione ( p_iddocumento             VARCHAR2,
      p_utente                  VARCHAR2,
      p_unita   VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
    NOME:        CREAZIONE.
    DESCRIZIONE: Dato che la possibilita' di creare rapporti e' gia' verificata
 dai domini di protezione, qui si restituisce sempre 1.
   INPUT  p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
    FUNCTION CREAZIONE (
      p_utente                  VARCHAR2)
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
   FUNCTION ELIMINAZIONE (
      p_iddocumento             VARCHAR2
    , p_utente                  VARCHAR2)
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
   FUNCTION ELIMINAZIONE (
      p_area                    VARCHAR2
    , p_modello                 VARCHAR2
    , p_codice_richiesta        VARCHAR2
    , p_utente                  VARCHAR2)
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
   FUNCTION MODIFICA (
      p_idDocumento             VARCHAR2
    , p_utente                  VARCHAR2)
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
   FUNCTION MODIFICA (
      p_area                    VARCHAR2
    , p_modello                 VARCHAR2
    , p_codice_richiesta        VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
END AG_COMPETENZE_RAPPORTO;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_RAPPORTO"
IS
   /******************************************************************************
    NOME:        AG_COMPETENZE_RAPPORTO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti M_RAPPORTO.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data       Autore Descrizione.
    000  02/01/2007 SC     Prima emissione.
    001  16/05/2012 MM     Modifiche versione 2.1.
         27/04/2017 SC     ALLINEATO ALLO STANDARD
    002  03/10/2017 MM     Modificata funzione modifica.
    003  25/10/2019 MM     Modificata funzione modifica e lettura per gestione
                           competenze agspr.
    004  23/01/2020 MM     Modificata funzione eliminazione in caso di rapporti
                           associati a documenti non ancora protocollati.
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '004';

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

   -------------------------------------------------------------------------------
   /*****************************************************************************
     NOME:        VERIFICA_CREAZIONE.
     DESCRIZIONE:
    RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
     Rev.  Data              Autore      Descrizione.
     00    16/02/2012    MMur        Prima emissione.
     01    07/04/2017    SC          Gestione date privilegi
    ********************************************************************************/
   FUNCTION verifica_creazione (p_iddocumento    VARCHAR2,
                                p_utente         VARCHAR2,
                                p_unita          VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := 0;
      modalita         VARCHAR2 (15);
      spedito          VARCHAR2 (2);
      datablocco       DATE;
      dataprotocollo   DATE;
   BEGIN
      IF (p_iddocumento IS NULL OR p_iddocumento = '')
      THEN
         retval :=
            ag_utilities.verifica_privilegio_utente (p_unita,
                                                     'MRAP',
                                                     p_utente,
                                                     TRUNC (SYSDATE));
      ELSE
         IF f_valore_campo (p_iddocumento,
                            ag_utilities.campo_stato_protocollo) = 'PR'
         THEN
            datablocco :=
               ag_utilities.get_data_blocco (
                  f_valore_campo (p_iddocumento, 'CODICE_AMMINISTRAZIONE'),
                  f_valore_campo (p_iddocumento, 'CODICE_AOO'));
            dataprotocollo :=
               TRUNC (
                  TO_DATE (
                     f_valore_campo (p_iddocumento,
                                     ag_utilities.campo_data_protocollo),
                     'DD/MM/YYYY HH24.MI.SS'));
            modalita := f_valore_campo (p_iddocumento, 'MODALITA');
            spedito := f_valore_campo (p_iddocumento, 'SPEDITO');

            IF (modalita = 'PAR' AND spedito = 'Y')
            THEN
               IF dataprotocollo <= datablocco
               THEN
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_iddocumento,
                        'IRAPBLC',
                        p_utente);
               ELSE
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_iddocumento,
                        'IRAP',
                        p_utente);
               END IF;
            ELSE
               IF dataprotocollo <= datablocco
               THEN
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_iddocumento,
                        'MRAPBLC',
                        p_utente);
               ELSE
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_iddocumento,
                        'MRAP',
                        p_utente);
               END IF;
            END IF;
         ELSE
            retval :=
               ag_utilities.verifica_privilegio_utente (p_unita,
                                                        'MRAP',
                                                        p_utente,
                                                        TRUNC (SYSDATE));
         END IF;
      END IF;

      RETURN retval;
   END verifica_creazione;

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
      retval := 1;
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
      depidrif         VARCHAR2 (1000);
      idprotocollo     NUMBER;
      retval           NUMBER := 0;
      totrapporti      NUMBER;
      datablocco       DATE;
      dataprotocollo   DATE;
      movimento        VARCHAR2(100);
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         depidrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         idprotocollo := ag_utilities.get_protocollo_per_idrif (depidrif);
         movimento := f_valore_campo (idprotocollo, 'MODALITA');

         IF NVL (
               f_valore_campo (idprotocollo,
                               ag_utilities.campo_stato_protocollo),
               'DP') != 'DP'
         THEN
            BEGIN
               SELECT COUNT (*)
                 INTO totrapporti
                 FROM seg_soggetti_protocollo, documenti
                WHERE     idrif = depidrif
                      AND tipo_rapporto <> 'DUMMY'
                      AND seg_soggetti_protocollo.id_documento =
                             documenti.id_documento
                      AND documenti.stato_documento NOT IN ('CA', 'RE');

               -- se è rimasto un solo rapporto, non consento l'eliminazione a nessuno.
               IF totrapporti > 1 or movimento = 'INT'
               THEN
                  datablocco :=
                     ag_utilities.get_data_blocco (
                        f_valore_campo (idprotocollo,
                                        'CODICE_AMMINISTRAZIONE'),
                        f_valore_campo (idprotocollo, 'CODICE_AOO'));
                  dataprotocollo :=
                     TRUNC (
                        TO_DATE (
                           f_valore_campo (
                              idprotocollo,
                              ag_utilities.campo_data_protocollo),
                           'DD/MM/YYYY HH24.MI.SS'));

                  IF dataprotocollo <= datablocco
                  THEN
                     retval :=
                        ag_competenze_protocollo.verifica_privilegio_protocollo (
                           p_id_documento   => idprotocollo,
                           p_privilegio     => 'ERAPBLC',
                           p_utente         => p_utente);
                  ELSE
                     retval :=
                        ag_competenze_protocollo.verifica_privilegio_protocollo (
                           p_id_documento   => idprotocollo,
                           p_privilegio     => 'ERAP',
                           p_utente         => p_utente);
                  END IF;
               END IF;
            END;
         ELSE
            retval := 1;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

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
      idrif            VARCHAR2 (1000);
      idprotocollo     NUMBER;
      retval           NUMBER := 0;
      datablocco       DATE;
      dataprotocollo   DATE;
      tipo             NUMBER;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         tipo := f_valore_campo (p_iddocumento, 'TIPO_SOGGETTO');

         -- Le anagrafiche recuperate dall'anagrafica Ap@ci non sono modificabili
         IF tipo = 10
         THEN
            retval := 0;
         ELSE
            idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
            idprotocollo := ag_utilities.get_protocollo_per_idrif (idrif);



            IF NVL (
                  f_valore_campo (idprotocollo,
                                  ag_utilities.campo_stato_protocollo),
                  'DP') <> 'DP'
            THEN
               datablocco :=
                  ag_utilities.get_data_blocco (
                     f_valore_campo (idprotocollo, 'CODICE_AMMINISTRAZIONE'),
                     f_valore_campo (idprotocollo, 'CODICE_AOO'));
               dataprotocollo :=
                  TRUNC (
                     TO_DATE (
                        f_valore_campo (idprotocollo,
                                        ag_utilities.campo_data_protocollo),
                        'DD/MM/YYYY HH24.MI.SS'));

               IF dataprotocollo <= datablocco
               THEN
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_id_documento   => idprotocollo,
                        p_privilegio     => 'MRAPBLC',
                        p_utente         => p_utente);
               ELSE
                  --se è una lettera e l'utente è il protocollante
                  -- ha diritto di modifica dei rapporti
                  BEGIN
                     SELECT 1
                       INTO retval
                       FROM spr_lettere_uscita
                      WHERE     id_documento = idprotocollo
                            AND utente_protocollante = p_utente;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;

                  IF retval = 0
                  THEN
                     retval :=
                        ag_competenze_protocollo.verifica_privilegio_protocollo (
                           p_id_documento   => idprotocollo,
                           p_privilegio     => 'MRAP',
                           p_utente         => p_utente);
                  END IF;
               END IF;
            ELSE
               retval :=
                  agspr_competenze_protocollo.modifica_gdm (
                     p_id_documento_esterno   => idprotocollo,
                     p_utente                 => p_utente);
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

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
      idrif          VARCHAR2 (1000);
      idprotocollo   NUMBER;
      retval         NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         idprotocollo := ag_utilities.get_protocollo_per_idrif (idrif);
         retval := agspr_competenze_protocollo.lettura_gdm (idprotocollo, p_utente);
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
END AG_COMPETENZE_RAPPORTO;
/
