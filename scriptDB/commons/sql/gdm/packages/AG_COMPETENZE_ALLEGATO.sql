--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_ALLEGATO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_COMPETENZE_ALLEGATO
IS
/******************************************************************************
 NOME:         AG_COMPETENZE_ALLEGATO
 DESCRIZIONE:  Package di funzioni specifiche del progetto AFFARI_GENERALI per
               verificare i diritti degli utenti sui documenti
               M_ALLEGATO_PROTOCOLLO.
 ANNOTAZIONI: .
 REVISIONI:   Le rev > 50 sono quelle apportate in Versione 3.5 o successiva
 <CODE>
 Rev.  Data       Autore   Descrizione.
 00    02/01/2007 SC       Prima emissione.
 01    16/05/2012 MM       Inserimento funzioni eliminazione_testo,
                           modifica_testo, lettura_testo

 51    28/12/2018 MM       Creata verifica_creazione con area, modello e cr.
******************************************************************************/
   -- Revisione del Package
   s_revisione CONSTANT VARCHAR2 (40) := 'V1.51';
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
  /*****************************************************************************
    NOME:        VERIFICA_CREAZIONE.
    DESCRIZIONE:
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data              Autore      Descrizione.
    00    20/02/2012    MMur        Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_creazione ( p_iddocumento             VARCHAR2,
      p_utente                  VARCHAR2)
      RETURN NUMBER;
   FUNCTION verifica_creazione (p_area                VARCHAR2,
                                p_modello             VARCHAR2,
                                p_codice_richiesta    VARCHAR2,
                                p_utente              VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
    NOME:        CREAZIONE.
    DESCRIZIONE: Dato che la possibilita' di creare allegati e' gia' verificata
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
 DESCRIZIONE: Un utente ha i diritti di cancellare un ALLEGATO se il suo ruolo
 ha privilegio EALL.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
********************************************************************************/
   FUNCTION ELIMINAZIONE (
      p_iddocumento             VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*******************************************************************************
   NOME:          ELIMINAZIONE_TESTO.
   DESCRIZIONE:   Verifica la possibilita' dell'utente di eliminare il testo
                  dell'allegato.
   INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                  p_utente       varchar2: utente che richiede di eliminare il
                                           documento.
   RITORNO:       Sempre 1 perche' non gestiamo le competenze sui testi.
*******************************************************************************/
   FUNCTION ELIMINAZIONE_TESTO (p_idDocumento      VARCHAR2,
                            p_utente           VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        LETTURA.
 DESCRIZIONE: Un utente ha i diritti di vedere un ALLEGATO se ha
 tale diritto sul protocollo collegato.
INPUT  p_idDocumento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
********************************************************************************/
   FUNCTION LETTURA (
      p_idDocumento             VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*******************************************************************************
   NOME:          LETTURA_TESTO.
   DESCRIZIONE:   Verifica la possibilita' dell'utente di leggere il testo
                  dell'allegato.
   INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                  p_utente       varchar2: utente che richiede di leggere il
                                           documento.
   RITORNO:       Sempre 1 perche' non gestiamo le competenze sui testi.
*******************************************************************************/
   FUNCTION LETTURA_TESTO (p_idDocumento      VARCHAR2,
                            p_utente           VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        MODIFICA.
 DESCRIZIONE: Un utente ha i diritti di modificare un ALLEGATO se il suo ruolo
 ha privilegio MALL.
INPUT  p_idDocumento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
********************************************************************************/
   FUNCTION MODIFICA (
      p_idDocumento             VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*******************************************************************************
   NOME:          MODIFICA_TESTO.
   DESCRIZIONE:   Verifica la possibilita' dell'utente di modificare il testo
                  dell'allegato.
   INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                  p_utente       varchar2: utente che richiede di leggere il
                                           documento.
   RITORNO:       Sempre 1 perche' non gestiamo le competenze sui testi.
*******************************************************************************/
   FUNCTION MODIFICA_TESTO (p_idDocumento      VARCHAR2,
                            p_utente           VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY     AG_COMPETENZE_ALLEGATO
IS
   /******************************************************************************
    NOME:        GDM.AG_COMPETENZE_ALLEGATO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti M_ALLEGATO_PROTOCOLLO
    ANNOTAZIONI: .
    REVISIONI:   Le rev > 100 sono quelle apportate in Versione 3.5 o successiva
    <CODE>
    Rev.  Data        Autore  Descrizione.
    000   02/01/2007  SC      Prima emissione.
    001   16/05/2012  MM      Inserimento funzioni eliminazione_testo,
                              modifica_testo, lettura_testo.
          26/04/2017  SC      ALLINEATO ALLO STANDARD
    002   28/12/2018  MM      Modificata verifica_creazione per gestire il
                              parametro ALLEGATI_MOD_POST_INVIO.

    101   28/12/2018  MM      Creata verifica_creazione per area, modello e cr
    102   25/10/2019  MM      Modificata funzione modifica per gestione
                              competenze agspr.
    103   27/01/2020  MM      Modificata funzione lettura per gestione documenti
                              da fascicolare.
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '103';

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
      NOME:        VERIFICA_CREAZIONE.
      DESCRIZIONE:
     RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
      Rev.  Data              Autore      Descrizione.
      00    20/02/2012    MMur        Prima emissione.
      01    05/04/2017    SC          Gestione date privilegi
     ********************************************************************************/
   FUNCTION verifica_creazione (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := 0;
      modalita         VARCHAR2 (15);
      spedito          VARCHAR2 (2);
      datablocco       DATE;
      dataprotocollo   DATE;
      mod_post_invio   VARCHAR2 (1);
      d_codice_amm     VARCHAR2 (100);
      d_codice_aoo     VARCHAR2 (100);
   BEGIN
      IF (p_iddocumento IS NULL)
      THEN
         retval :=
            ag_utilities.verifica_privilegio_utente ('',
                                                     'IALL',
                                                     p_utente,
                                                     TRUNC (SYSDATE));
      ELSE
         IF f_valore_campo (p_iddocumento,
                            ag_utilities.campo_stato_protocollo) = 'PR'
         THEN
            d_codice_amm :=
               f_valore_campo (p_iddocumento, 'CODICE_AMMINISTRAZIONE');
            d_codice_aoo := f_valore_campo (p_iddocumento, 'CODICE_AOO');
            datablocco :=
               ag_utilities.get_data_blocco (d_codice_amm, d_codice_aoo);
            dataprotocollo :=
               TRUNC (
                  TO_DATE (
                     f_valore_campo (p_iddocumento,
                                     ag_utilities.campo_data_protocollo),
                     'DD/MM/YYYY HH24.MI.SS'));
            spedito := NVL (f_valore_campo (p_iddocumento, 'SPEDITO'), 'N');

            mod_post_invio :=
               AG_PARAMETRO.GET_VALORE ('ALLEGATI_MOD_POST_INVIO',
                                        d_codice_amm,
                                        d_codice_aoo,
                                        'N');

            IF (spedito = 'N' OR mod_post_invio = 'Y')
            THEN
               IF dataprotocollo <= datablocco
               THEN
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_iddocumento,
                        'IALLBLC',
                        p_utente);
               ELSE
                  retval :=
                     ag_competenze_protocollo.verifica_privilegio_protocollo (
                        p_iddocumento,
                        'IALL',
                        p_utente);
               END IF;
            ELSE
               retval := 0;
            END IF;
         ELSE
            IF ag_utilities.is_prot_interop (p_iddocumento) = 1
            THEN
               retval := 1;
            ELSE
               retval :=
                  ag_competenze_protocollo.verifica_privilegio_protocollo (
                     p_iddocumento,
                     'IALL',
                     p_utente);
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END verifica_creazione;

   --------------------------------------------------------------------------------
   FUNCTION verifica_creazione (p_area                VARCHAR2,
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
         retval := verifica_creazione (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END verifica_creazione;

   --------------------------------------------------------------------------------
   /*****************************************************************************
       NOME:        CREAZIONE.
       DESCRIZIONE: Dato che la possibilita' di creare allegati e' gia' verificata
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
    DESCRIZIONE: Un utente ha i diritti di cancellare uno ALLEGATO se il suo ruolo
    ha privilegio EALL.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION eliminazione (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      idrif            VARCHAR2 (1000);
      idprotocollo     NUMBER;
      retval           NUMBER := 0;
      datablocco       DATE;
      dataprotocollo   DATE;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         idprotocollo := ag_utilities.get_protocollo_per_idrif (idrif);

         IF f_valore_campo (idprotocollo,
                            ag_utilities.campo_stato_protocollo) != 'DP'
         THEN
            datablocco :=
               ag_utilities.get_data_blocco (
                  f_valore_campo (idprotocollo, 'CODICE_AMMINISTRAZIONE'),
                  f_valore_campo (idprotocollo, 'CODICE_AOO'));
            DBMS_OUTPUT.put_line ('datablocco ' || datablocco);
            dataprotocollo :=
               TRUNC (
                  TO_DATE (
                     f_valore_campo (idprotocollo,
                                     ag_utilities.campo_data_protocollo),
                     'DD/MM/YYYY HH24.MI.SS'));
            DBMS_OUTPUT.put_line ('dataprotocollo ' || dataprotocollo);

            IF dataprotocollo <= datablocco
            THEN
               DBMS_OUTPUT.put_line ('dataprotocollo <= datablocoo');
               retval :=
                  ag_competenze_protocollo.verifica_privilegio_protocollo (
                     p_id_documento   => idprotocollo,
                     p_privilegio     => 'EALLBLC',
                     p_utente         => p_utente);
            ELSE
               retval :=
                  ag_competenze_protocollo.verifica_privilegio_protocollo (
                     p_id_documento   => idprotocollo,
                     p_privilegio     => 'EALL',
                     p_utente         => p_utente);
            END IF;
         ELSE
            IF ag_utilities.is_prot_interop (idprotocollo) = 1
            THEN
               retval := 1;
            ELSE
               retval := NULL;
            END IF;
         END IF;

         DECLARE
            d_idrif   VARCHAR2 (1000);
         BEGIN
            SELECT idrif
              INTO d_idrif
              FROM proto_view
             WHERE id_documento = idprotocollo;

            IF AG_UTILITIES.is_lettera_grails (d_idrif) = 1
            THEN
               retval :=
                  agspr_competenze_allegato.eliminazione (idprotocollo,
                                                          p_utente);
            END IF;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END eliminazione;

   /*******************************************************************************
      NOME:          ELIMINAZIONE_TESTO.
      DESCRIZIONE:   Verifica la possibilita' dell'utente di eliminare il testo
                     dell'allegato.
      INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                     p_utente       varchar2: utente che richiede di eliminare il
                                              documento.
      RITORNO:       Sempre 1 perche' non gestiamo le competenze sui testi.

    Rev. Data        Autore   Descrizione.
    001  16/05/2012  MM       Prima emissione.
   *******************************************************************************/
   FUNCTION eliminazione_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER := NULL;
   BEGIN
      d_return := 1;

      RETURN d_return;
   END;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare uno ALLEGATO se il suo ruolo
    ha privilegio MALL. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
    e lo smistamento non deve essere storico nè preso in carico.
   INPUT  p_idDocumento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      idrif            VARCHAR2 (1000);
      idprotocollo     NUMBER;
      retval           NUMBER := 0;
      datablocco       DATE;
      dataprotocollo   DATE;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         idprotocollo := ag_utilities.get_protocollo_per_idrif (idrif);

         IF f_valore_campo (idprotocollo,
                            ag_utilities.campo_stato_protocollo) != 'DP'
         THEN
            datablocco :=
               ag_utilities.get_data_blocco (
                  f_valore_campo (p_iddocumento, 'CODICE_AMMINISTRAZIONE'),
                  f_valore_campo (p_iddocumento, 'CODICE_AOO'));
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
                     p_privilegio     => 'MALLBLC',
                     p_utente         => p_utente);
            ELSE
               retval :=
                  ag_competenze_protocollo.verifica_privilegio_protocollo (
                     p_id_documento   => idprotocollo,
                     p_privilegio     => 'MALL',
                     p_utente         => p_utente);

               IF (    ag_utilities.IS_LETTERA (idprotocollo) = 1
                   AND f_valore_campo (idprotocollo, 'SO4_DIRIGENTE') =
                          p_utente
                   AND f_valore_campo (idprotocollo, 'POSIZIONE_FLUSSO') =
                          'DIRIGENTE')
               THEN
                  retval := 1;
               END IF;
            END IF;
         ELSE
            IF ag_utilities.is_prot_interop (idprotocollo) = 1
            THEN
               retval := 1;
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

      DECLARE
         d_idrif   VARCHAR2 (1000);
      BEGIN
         SELECT idrif
           INTO d_idrif
           FROM proto_view
          WHERE id_documento = idprotocollo;

         IF AG_UTILITIES.is_lettera_grails (d_idrif) = 1
         THEN
            retval :=
               agspr_competenze_allegato.modifica (idprotocollo, p_utente);
         END IF;
      END;

      RETURN retval;
   END modifica;

   /*****************************************************************************
       NOME:        MODIFICA.
       DESCRIZIONE: Un utente ha i diritti di modificare uno ALLEGATO se il suo ruolo
    ha privilegio MALL. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
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

   /*******************************************************************************
      NOME:          MODIFICA_TESTO.
      DESCRIZIONE:   Verifica la possibilita' dell'utente di modificare il testo
                     dell'allegato.
      INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                     p_utente       varchar2: utente che richiede di leggere il
                                              documento.
      RITORNO:       Sempre 1 perche' non gestiamo le competenze sui testi.

    Rev. Data        Autore   Descrizione.
    001  16/05/2012  MM       Prima emissione.
   *******************************************************************************/
   FUNCTION modifica_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER := NULL;
   BEGIN
      d_return := 1;

      RETURN d_return;
   END;

   /*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere uno ALLEGATO non riservato se
                 ha tale diritto sul protocollo collegato.
                 Un utente ha i diritti di vedere uno ALLEGATO riservato se ha
                 i privilegi di lettura di un protocollo riservato.
   INPUT  p_idDocumento varchar2: chiave identificativa del documento.
          p_utente      varchar2: utente che richiede di leggere l'allegato.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_idrif           VARCHAR2 (1000);
      idprotocollo      NUMBER;
      statoprotocollo   VARCHAR2 (100);
      retval            NUMBER := 0;
      riservato         VARCHAR2 (1) := 'N';
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         d_idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         riservato :=
            NVL (
               f_valore_campo (p_iddocumento, ag_utilities.campo_riservato),
               'N');
         idprotocollo := ag_utilities.get_protocollo_per_idrif (d_idrif);
         statoprotocollo :=
            NVL (
               f_valore_campo (idprotocollo,
                               ag_utilities.campo_stato_protocollo),
               'DP');

         IF riservato = 'N' OR (riservato = 'Y' AND statoprotocollo = 'DP')
         THEN
            --retval := ag_competenze_protocollo.lettura (idprotocollo, p_utente); [AM]
            retval :=
               gdm_competenza.si4_verifica ('DOCUMENTI',
                                            idprotocollo,
                                            'L',
                                            p_utente,
                                            'GDM');
         ELSE
            /* Allegato RISERVATO */
            retval :=
               AG_COMPETENZE_PROTOCOLLO.LETTURA_PROTOCOLLO (p_iddocumento,
                                                            p_utente,
                                                            'R',
                                                            'N',
                                                            0);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF NVL (retval, 0) = 0
      THEN
         BEGIN
            IF AG_UTILITIES.is_lettera_grails (d_idrif) = 1
            THEN
               retval :=
                  agspr_competenze_allegato.lettura (idprotocollo, p_utente);
            END IF;
         END;
      END IF;

      IF NVL (retval, 0) = 0
      THEN
         DECLARE
            d_id_doc_da_fasc   NUMBER;
         BEGIN
            SELECT id_documento
              INTO d_id_doc_da_fasc
              FROM spr_da_fascicolare
             WHERE idrif = d_idrif;

            retval :=
               agspr_competenze_documento.lettura_gdm (d_id_doc_da_fasc,
                                                   p_utente);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := NULL;
         END;
      END IF;

      RETURN retval;
   END lettura;

   /*****************************************************************************
       NOME:        LETTURA.
       DESCRIZIONE: Un utente ha i diritti di vedere uno ALLEGATO se ha
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

   /*******************************************************************************
      NOME:          LETTURA_TESTO.
      DESCRIZIONE:   Verifica la possibilita' dell'utente di leggere il testo
                     dell'allegato.
      INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                     p_utente       varchar2: utente che richiede di leggere il
                                              documento.
      RITORNO:       Sempre 1 perche' non gestiamo le competenze sui testi.

    Rev. Data        Autore   Descrizione.
    001  16/05/2012  MM       Prima emissione.
   *******************************************************************************/
   FUNCTION lettura_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER := NULL;
   BEGIN
      d_return := 1;

      RETURN d_return;
   END;
END AG_COMPETENZE_ALLEGATO;
/
