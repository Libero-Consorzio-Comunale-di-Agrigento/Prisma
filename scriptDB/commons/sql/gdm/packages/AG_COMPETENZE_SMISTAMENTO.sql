--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_SMISTAMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_COMPETENZE_SMISTAMENTO"
IS
   /******************************************************************************
    NOME:        Ag_Competenze_SMISTAMENTO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui documenti M_SMISTAMENTO
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          27/04/2017  SC  ATTENZIONE CAMBIATE DUE INTERFACCE
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
       DESCRIZIONE: Dato che la possibilita' di creare smistamenti e' gia' verificata
    dai DOMINI di protezione, qui si restituisce sempre 1.
      INPUT  p_utente VARCHAR2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  DATA       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION verifica_privilegi_utente (d_riservato            VARCHAR2,
                                       p_utente               VARCHAR2,
                                       p_stato_smistamento    VARCHAR2,
                                       p_unita_ricevente      VARCHAR2,
                                       p_dal                  DATE)
      RETURN NUMBER;

   FUNCTION CREAZIONE (p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare uno SMISTAMENTO se il suo ruolo
    ha privilegio ESMI.
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
       DESCRIZIONE: Un utente ha i diritti di cancellare uno SMISTAMENTO se il suo ruolo
    ha privilegio ESMI.
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
    DESCRIZIONE: Un utente ha i diritti di vedere uno SMISTAMENTO se ha
    tale diritto sul protocollo collegato.
   INPUT  p_idDocumento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          08/02/2010  SC  A35655.0.0
   ********************************************************************************/
   FUNCTION LETTURA (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        LETTURA.
       DESCRIZIONE: Un utente ha i diritti di vedere uno SMISTAMENTO se ha
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
    DESCRIZIONE: Un utente ha i diritti di modificare uno SMISTAMENTO se il suo ruolo
    ha privilegio MSMI. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
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
       DESCRIZIONE: Un utente ha i diritti di modificare uno SMISTAMENTO se il suo ruolo
    ha privilegio MSMI. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
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

   /*****************************************************************************
       NOME:        ACCESSO_SMISTAMENTO_CRUSCOTTO.
       DESCRIZIONE: Funzione per verificare se l'utente deve vedere la riga di
       iter documentale del cruscotto.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a ricevere o prendere in carico il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
       01    20/05/2009  SC  A32979.0.0 Invece che verificare solo se l'utente può
                               vedere il protocollo, si verifica se lo può
                               ricevere o prendere in carico.
      ********************************************************************************/
   FUNCTION ACCESSO_SMISTAMENTO_CRUSCOTTO (p_idDocumento    VARCHAR2,
                                           p_utente         VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        ACCESSO_SMISTAMENTO_CRUSCOTTO.
       DESCRIZIONE: Funzione per verificare se l'utente deve vedere la riga di
       iter documentale del cruscotto.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a ricevere o prendere in carico il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
       01    20/05/2009  SC  A32979.0.0 Invece che verificare solo se l'utente può
                               vedere il protocollo, si verifica se lo può
                               ricevere o prendere in carico.
      ********************************************************************************/
   FUNCTION ACCESSO_SMISTAMENTO_CRUSCOTTO (p_area                VARCHAR2,
                                           p_modello             VARCHAR2,
                                           p_codice_richiesta    VARCHAR2,
                                           p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        SMISTAMENTO_IN_CARICO.
       DESCRIZIONE: Funzione per verificare se lo smistamento è in carico per l'utente.
       Si usa per abilitare i bottoni nella relativa barra del protocollo.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a vedere il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION SMISTAMENTO_IN_CARICO (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        SMISTAMENTO_DA_RICEVERE.
       DESCRIZIONE: Funzione per verificare se lo smistamento è da ricevere per l'utente.
       Si usa per abilitare i bottoni nella relativa barra del protocollo.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a vedere il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION SMISTAMENTO_DA_RICEVERE (p_idDocumento    VARCHAR2,
                                     p_utente         VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
 NOME:        AcheckSmistamentoPerArea.
 DESCRIZIONE: Funzione per verificare se l'utente avente privilegio SMISTAAREA puo' smistare per.
 l'unita ricevente passata
INPUT   d_nome_utente VARCHAR2(20),
         d_unita_ricevente VARCHAR2(20),
         d_codice_amm VARCHAR2(20),
         d_codice_aoo VARCHAR2(20),
         d_data_smistamento DATE
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    23/09/2008  AM  Prima emissione.
 01    09/03/2010  SC A34954.3.1 D1037.
********************************************************************************/
   FUNCTION IS_POSSIBILE_SMISTARE (d_nome_utente            VARCHAR2,
                                   d_unita_ricevente        VARCHAR2,
                                   d_unita_trasmissione     VARCHAR2,
                                   d_codice_amm             VARCHAR2,
                                   d_codice_aoo             VARCHAR2,
                                   d_data_smistamento       VARCHAR2,
                                   d_codice_assegnatario    VARCHAR2,
                                   d_idrif                  VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
 NOME:        CHECK_PRIVILEGIO_UTENTE.
 DESCRIZIONE: Funzione per verificare se l'utente ha un determinato privilegio
INPUT   d_nome_utente VARCHAR2,
        d_privilegio VARCHAR2
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    23/09/2008  AM  Prima emissione.
********************************************************************************/
   FUNCTION CHECK_PRIVILEGIO_UTENTE (d_nome_utente    VARCHAR2,
                                     d_privilegio     VARCHAR2,
                                     d_data           DATE)
      RETURN NUMBER;
END Ag_Competenze_Smistamento;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_SMISTAMENTO"
IS
   /******************************************************************************
    NOME:         AG_COMPETENZE_SMISTAMENTO
    DESCRIZIONE:  Package di funzioni specifiche del progetto AFFARI_GENERALI per
                  verificare i diritti degli utenti sui documenti M_SMISTAMENTO.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.    Data       Autore Descrizione.
    000     02/01/2007 SC     Prima emissione.
    002     23/05/2011 MM     A42830.0.0: modificata IS_POSSIBILE_SMISTARE
    003     27/01/2011 MM     Modificata la funzione eliminazione per gestire il
                              caso in cui non sia previsto iter dei documenti
                              (parametro ITER_DOCUMENTI_n = N).
    004     09/03/2012 MM     Modificata la funzione accesso_smistamento_cruscotto.
    005     20/08/2015 MM
            27/04/2017 SC     ALLINEATO CON LO STANDARD
    006     25/10/2019 MM     Modificata funzione lettura per gestione
                              competenze agspr.
    007     21/05/2020 SC   Bug #41226 data riferimento sempre sysdate in
                            IS_POSSIBILE_SMISTARE.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '007';

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

   PROCEDURE close_cursore (v_cur afc.t_ref_cursor)
   IS
   BEGIN
      IF v_cur%ISOPEN
      THEN
         CLOSE v_cur;
      END IF;
   END;

   /*****************************************************************************
       NOME:        verifica_privilegi_utente.
       DESCRIZIONE:


      INPUT

      RITORNO:
       Rev.  Data       Autore  Descrizione.
       01    05/04/2017  SC     Inserito commento. Gestione date privilegi
      ********************************************************************************/
   FUNCTION verifica_privilegi_utente (d_riservato            VARCHAR2,
                                       p_utente               VARCHAR2,
                                       p_stato_smistamento    VARCHAR2,
                                       p_unita_ricevente      VARCHAR2,
                                       p_dal                  DATE)
      RETURN NUMBER
   IS
      p_ret      NUMBER := 0;
      v_ottica   VARCHAR2 (100);
   BEGIN
      v_ottica := ag_utilities.get_ottica_utente (p_utente, NULL, NULL);


      /*DBMS_OUTPUT.put_line ('d_riservato ' || d_riservato);
      DBMS_OUTPUT.put_line ('dep_progr_unita_ricevente ' || dep_progr_unita_ricevente);
      DBMS_OUTPUT.put_line ('p_dal ' || p_dal);*/

      IF p_utente IS NOT NULL
      THEN
         --DBMS_OUTPUT.put_line ('p_utente ' || p_utente);

         IF p_stato_smistamento = 'C'
         THEN
            /* DBMS_OUTPUT.put_line (
                'p_stato_smistamento ' || p_stato_smistamento);*/

            SELECT DISTINCT (1)
              INTO p_ret
              FROM ag_priv_d_utente_tmp
             WHERE     utente = p_utente
                   AND unita = p_unita_ricevente
                   AND privilegio =
                          'VS' || DECODE (d_riservato, 'Y', 'R', '')
                   AND (p_dal <= /*IS NULL
                      OR p_dal BETWEEN dal
                                   AND*/
                                NVL (al, TO_DATE (3333333, 'j')));
         --DBMS_OUTPUT.put_line ('FINE SELECT C ');
         ELSE
            /*DBMS_OUTPUT.put_line (
               'p_stato_smistamento ' || p_stato_smistamento);*/

            SELECT DISTINCT (1)
              INTO p_ret
              FROM ag_priv_d_utente_tmp pvs, ag_priv_d_utente_tmp pcarico
             WHERE     pvs.utente = p_utente
                   AND pvs.unita = p_unita_ricevente
                   AND pvs.privilegio =
                          'VS' || DECODE (d_riservato, 'Y', 'R', '')
                   AND pcarico.unita = pvs.unita
                   AND pcarico.utente = pvs.utente
                   AND pcarico.privilegio = 'CARICO'
                   AND (         /*p_dal IS NULL
                              OR*/
                        p_dal <= /*BETWEEN pcarico.dal
                                AND*/
                                NVL (pcarico.al, TO_DATE (3333333, 'j')))
                   AND (         /*p_dal IS NULL
                              OR*/
                        p_dal <= /*BETWEEN pvs.dal
                                AND*/
                                NVL (pvs.al, TO_DATE (3333333, 'j')));
         --DBMS_OUTPUT.put_line ('FINE SELECT R ');
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('verifica_privilegi_utente ' || p_ret);
      RETURN p_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         --DBMS_OUTPUT.put_line (SQLERRM);
         RETURN 0;
   END verifica_privilegi_utente;

   /*****************************************************************************
       NOME:        verifica_privilegi_utente.
       DESCRIZIONE:


      INPUT

      RITORNO:
       Rev.  Data       Autore  Descrizione.
       01    05/04/2017  SC     Inserito commento. Gestione date privilegi
      ********************************************************************************/
   FUNCTION verifica_privilegi_d_utente (d_riservato            VARCHAR2,
                                         p_utente               VARCHAR2,
                                         p_stato_smistamento    VARCHAR2,
                                         p_unita_ricevente      VARCHAR2,
                                         p_dal                  DATE,
                                         p_codice_amm           VARCHAR2,
                                         p_codice_aoo           VARCHAR2)
      RETURN NUMBER
   IS
      p_ret      NUMBER := 0;
      v_ottica   VARCHAR2 (100);
   BEGIN
      /*DBMS_OUTPUT.put_line ('d_riservato ' || d_riservato);
      DBMS_OUTPUT.put_line ('p_unita_ricevente ' || p_unita_ricevente);
      DBMS_OUTPUT.put_line ('p_dal ' || p_dal);*/
      v_ottica :=
         ag_utilities.get_ottica_utente (p_utente,
                                         p_codice_amm,
                                         p_codice_aoo);

      IF p_utente IS NOT NULL
      THEN
         DBMS_OUTPUT.put_line ('p_utente ' || p_utente);

         IF p_stato_smistamento = 'C'
         THEN
            DBMS_OUTPUT.put_line (
               'p_stato_smistamento ' || p_stato_smistamento);

            SELECT DISTINCT (1)
              INTO p_ret
              FROM ag_priv_d_utente_tmp
             WHERE     utente = p_utente
                   AND unita = p_unita_ricevente
                   AND privilegio =
                          'VS' || DECODE (d_riservato, 'Y', 'R', '')
                   AND (       /*p_dal IS NULL
                            OR */
                        p_dal <= /*BETWEEN dal
                                AND*/
                                NVL (al, TO_DATE (3333333, 'j')));

            DBMS_OUTPUT.put_line ('FINE SELECT C ');
         ELSE
            DBMS_OUTPUT.put_line (
               'p_stato_smistamento ' || p_stato_smistamento);

            SELECT DISTINCT (1)
              INTO p_ret
              FROM ag_priv_d_utente_tmp pvs, ag_priv_d_utente_tmp pcarico
             WHERE     pvs.utente = p_utente
                   AND pvs.unita = p_unita_ricevente
                   AND pvs.privilegio =
                          'VS' || DECODE (d_riservato, 'Y', 'R', '')
                   AND pcarico.unita = pvs.unita
                   AND pcarico.utente = pvs.utente
                   AND pcarico.privilegio = 'CARICO'
                   AND (       /*p_dal IS NULL
                            OR */
                        p_dal <= /*BETWEEN pcarico.dal
                                AND*/
                                NVL (pcarico.al, TO_DATE (3333333, 'j')))
                   AND (       /*p_dal IS NULL
                            OR */
                        p_dal <= /*BETWEEN pvs.dal
                                AND*/
                                NVL (pvs.al, TO_DATE (3333333, 'j')));

            DBMS_OUTPUT.put_line ('FINE SELECT R ');
         END IF;
      END IF;

      DBMS_OUTPUT.put_line ('verifica_privilegi_d_utente ' || p_ret);
      RETURN p_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         RETURN 0;
   END verifica_privilegi_d_utente;

   FUNCTION is_smistamento_di_documento (p_id_smistamento NUMBER)
      RETURN NUMBER
   IS
      iddocumento         NUMBER;
      retval              NUMBER := 1;
      dep_idrif           VARCHAR2 (100);
      id_protocollo       NUMBER;
      movimento           VARCHAR2 (3);
      conta_smistamenti   NUMBER := 0;
      stato_protocollo    VARCHAR2 (2);
   BEGIN
      dep_idrif := f_valore_campo (p_id_smistamento, ag_utilities.campo_idrif);
      id_protocollo := ag_utilities.get_protocollo_per_idrif (dep_idrif);

      IF id_protocollo IS NOT NULL
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END is_smistamento_di_documento;

   /*****************************************************************************
       NOME:        CHECK_SMISTAMENTO_OBBLIGATORIO.
       DESCRIZIONE: Funzione per verificare se lo smistamento identificato
           da p_id_smistamento si puo' cancellare.
           Se il documento è protocollato, lo smistamento è eliminabile
           se il movimento del protocollo non prevede
           smistamento obbligatorio, oppure se non è l'unico smistamento
           del protocollo.
           Se il documento non è protocollato è sempre eliminabile.


      INPUT  p_id_smistamento NUMBER id documento dello smistamento

      RITORNO:  1 se lo smistamento è eliminabile, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    16/12/2008  SC  Prima emissione. A30390.0.0
      ********************************************************************************/
   FUNCTION check_smistamento_obbligatorio (p_id_smistamento NUMBER)
      RETURN NUMBER
   IS
      iddocumento         NUMBER;
      retval              NUMBER := 1;
      dep_idrif           VARCHAR2 (100);
      id_protocollo       NUMBER;
      movimento           VARCHAR2 (3);
      conta_smistamenti   NUMBER := 0;
      stato_protocollo    VARCHAR2 (2);
   BEGIN
      IF is_smistamento_di_documento (p_id_smistamento) = 1
      THEN
         dep_idrif :=
            f_valore_campo (p_id_smistamento, ag_utilities.campo_idrif);
         id_protocollo := ag_utilities.get_protocollo_per_idrif (dep_idrif);
         movimento := f_valore_campo (id_protocollo, 'MODALITA');
         stato_protocollo := f_valore_campo (id_protocollo, 'STATO_PR');

         IF     stato_protocollo != 'DP'
            AND ag_parametro.get_valore (
                   'SMIST_' || movimento || '_OB_',
                   f_valore_campo (p_id_smistamento,
                                   'CODICE_AMMINISTRAZIONE'),
                   f_valore_campo (p_id_smistamento, 'CODICE_AOO'),
                   'N') = 'Y'
         THEN
            IF ag_parametro.get_valore (
                  'ITER_FASCICOLI_',
                  f_valore_campo (p_id_smistamento, 'CODICE_AMMINISTRAZIONE'),
                  f_valore_campo (p_id_smistamento, 'CODICE_AOO'),
                  'N') = 'Y'
            THEN
               DECLARE
                  dep_class_cod          VARCHAR2 (1000);
                  dep_class_dal          DATE;
                  dep_fascicolo_anno     NUMBER;
                  dep_fascicolo_numero   VARCHAR2 (1000);
                  dep_id_cartella        NUMBER;
               BEGIN
                  SELECT class_cod,
                         class_dal,
                         fascicolo_anno,
                         fascicolo_numero
                    INTO dep_class_cod,
                         dep_class_dal,
                         dep_fascicolo_anno,
                         dep_fascicolo_numero
                    FROM proto_view
                   WHERE id_documento = id_protocollo;

                  IF     dep_class_cod IS NOT NULL
                     AND dep_class_dal IS NOT NULL
                     AND dep_fascicolo_anno IS NOT NULL
                     AND dep_fascicolo_numero IS NOT NULL
                  THEN
                     SELECT id_cartella
                       INTO dep_id_cartella
                       FROM seg_fascicoli, cartelle
                      WHERE     class_cod = dep_class_cod
                            AND class_dal = dep_class_dal
                            AND fascicolo_anno = dep_fascicolo_anno
                            AND fascicolo_numero = dep_fascicolo_numero
                            AND cartelle.id_documento_profilo =
                                   seg_fascicoli.id_documento
                            AND NVL (cartelle.stato, 'BO') = 'BO';

                     IF ag_fascicolo_utility.restano_smistamenti_attivi (
                           dep_id_cartella) = 1
                     THEN
                        RETURN retval;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;

            SELECT COUNT (*)
              INTO conta_smistamenti
              FROM seg_smistamenti smis, documenti docu
             WHERE     idrif = dep_idrif
                   AND smis.id_documento = docu.id_documento
                   AND smis.id_documento <> p_id_smistamento
                   AND tipo_smistamento <> 'DUMMY'
                   AND docu.stato_documento NOT IN ('CA', 'RE');

            IF conta_smistamenti = 0
            THEN
               retval := 0;
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END check_smistamento_obbligatorio;

   --------------------------------------------------------------------------------
   /*****************************************************************************
      NOME:        CREAZIONE.
      DESCRIZIONE: Dato che la possibilita' di creare smistamenti e' gia' verificata
   dai DOMINI di protezione, qui si restituisce sempre 1.
     INPUT  p_utente VARCHAR2: utente che richiede di leggere il documento.
     RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
      Rev.  DATA       Autore  Descrizione.
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
    DESCRIZIONE: Si possono cancellare solo smistamenti con stato N, perche' per gli altri
    esiste un flusso istanziato che non puo' essere eliminato.
   COME DOVRA' FUNZIONARE A REGIME:
   Un utente ha i diritti di cancellare uno SMISTAMENTO se il suo ruolo
    ha privilegio ESMI e se lo smistamento è ancora in stato R.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    000   02/01/2007 SC    Prima emissione.
          06/06/2008 SC    A27756.3.0
          08/02/2010 SC    A35655.0.0
    003   27/01/2011 MM    Se parametro ITER_DOCUMENTI_n = N non verifica lo stato
                           dello smistamento in eliminazione (non esistono flussi
                           ne' task esterni associati ad esso).
   ********************************************************************************/
   FUNCTION eliminazione (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      idrif                VARCHAR2 (1000);
      idprotocollo         NUMBER;
      stato_smistamento    VARCHAR2 (1);
      retval               NUMBER := 0;
      unita_trasmissione   VARCHAR2 (1000);
      dep_data_rif         DATE;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      integritypackage.LOG ('inizializzato utente ' || p_utente);
      stato_smistamento :=
         f_valore_campo (p_iddocumento, ag_utilities.campo_stato_smistamento);
      idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
      idprotocollo := AG_UTILITIES.get_documento_per_idrif (idrif);
      dep_data_rif := AG_UTILITIES.get_data_rif_privilegi (idprotocollo);

      IF is_smistamento_di_documento (p_iddocumento) = 1
      THEN
         BEGIN
            retval := check_smistamento_obbligatorio (p_iddocumento);

            IF retval = 1
            THEN
               IF stato_smistamento = 'N'
               THEN
                  retval := 1;
               ELSIF    stato_smistamento = 'R'
                     --SC  A35655.0.0
                     OR (ag_parametro.get_valore (
                            'ITER_DOCUMENTI_',
                            f_valore_campo (p_iddocumento,
                                            'CODICE_AMMINISTRAZIONE'),
                            f_valore_campo (p_iddocumento, 'CODICE_AOO'),
                            'Y') = 'N')
               THEN
                  retval :=
                     ag_utilities.verifica_privilegio_utente (
                        NULL,
                        'ESMITOT',
                        p_utente,
                        TRUNC (SYSDATE));



                  IF retval = 0
                  THEN
                     unita_trasmissione :=
                        f_valore_campo (
                           p_iddocumento,
                           ag_utilities.campo_unita_trasmissione);
                     retval :=
                        ag_utilities.verifica_privilegio_utente (
                           unita_trasmissione,
                           'ESMI',
                           p_utente,
                           dep_data_rif);
                  END IF;
               ELSE
                  retval := 0;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      ELSE
         integritypackage.LOG ('smistamento non di documento');

         IF stato_smistamento = 'N'
         THEN
            retval := 1;
         ELSIF    stato_smistamento = 'R'
               --SC  A35655.0.0
               OR (ag_parametro.get_valore (
                      'ITER_FASCICOLI_',
                      f_valore_campo (p_iddocumento,
                                      'CODICE_AMMINISTRAZIONE'),
                      f_valore_campo (p_iddocumento, 'CODICE_AOO'),
                      'Y') = 'N')
         THEN
            integritypackage.LOG ('smistamento non di documento');
            retval :=
               ag_utilities.verifica_privilegio_utente (NULL,
                                                        'ESMITOT',
                                                        p_utente,
                                                        TRUNC (SYSDATE));


            IF retval = 0
            THEN
               unita_trasmissione :=
                  f_valore_campo (p_iddocumento,
                                  ag_utilities.campo_unita_trasmissione);
               retval :=
                  ag_utilities.verifica_privilegio_utente (
                     unita_trasmissione,
                     'ESMI',
                     p_utente,
                     dep_data_rif);
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END eliminazione;

   /*****************************************************************************
       NOME:        ELIMINAZIONE.
       DESCRIZIONE: Un utente ha i diritti di cancellare uno SMISTAMENTO se il suo ruolo
    ha privilegio ESMI.
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
    DESCRIZIONE: Un utente ha i diritti di modificare uno SMISTAMENTO se il suo ruolo
    ha privilegio MSMI. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
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
      idrif               VARCHAR2 (1000);
      idprotocollo        NUMBER;
      stato_smistamento   VARCHAR2 (1);
      retval              NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         stato_smistamento :=
            f_valore_campo (p_iddocumento,
                            ag_utilities.campo_stato_smistamento);

         IF stato_smistamento = 'N'               --OR stato_smistamento = 'R'
         THEN
            idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
            idprotocollo := ag_utilities.get_protocollo_per_idrif (idrif);
            retval :=
               ag_competenze_protocollo.verifica_privilegio_protocollo (
                  p_id_documento   => idprotocollo,
                  p_privilegio     => 'ISMI',
                  p_utente         => p_utente);
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
       DESCRIZIONE: Un utente ha i diritti di modificare uno SMISTAMENTO se il suo ruolo
    ha privilegio MSMI. Inoltre deve appartenere all'unita' di trasmissione dello smistamento
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
    DESCRIZIONE:  Un utente ha i diritti di vedere uno SMISTAMENTO se ha
                  tale diritto sul protocollo collegato.
    INPUT:        p_idDocumento varchar2: chiave identificativa del documento.
                  p_utente varchar2: utente che richiede di leggere il documento.
    RITORNO:      1 se l'utente ha diritti, 0 altrimenti.
    Rev. Data        Autore   Descrizione.
    000  02/01/2007  SC       Prima emissione.
    005  20/08/2015  MM       Modificata la chiamata a ag_competenze_protocollo.lettura
                              eliminando il terzo parametro (p_verifica_esistenza_attivita)
                              ora non piu' gestito.
   *****************************************************************************/
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
         retval :=
            agspr_competenze_protocollo.lettura_gdm (idprotocollo, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;

   /*****************************************************************************
       NOME:        LETTURA.
       DESCRIZIONE: Un utente ha i diritti di vedere uno SMISTAMENTO se ha
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

   /*****************************************************************************
       NOME:        ACCESSO_SMISTAMENTO_CRUSCOTTO.
       DESCRIZIONE: Funzione per verificare se l'utente deve vedere la riga di
       iter documentale del cruscotto.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a ricevere o prendere in carico il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data          Autore   Descrizione.
       000   02/01/2007    SC       Prima emissione.
       001   20/05/2009    SC       A32979.0.0 Invece che verificare solo se
                                    l'utente può vedere il protocollo, si verifica
                                    se lo può ricevere o prendere in carico.
       004   09/03/2012    MM       Verifica se l'utente appartiene all'unita
                                    ricevente oggi (prima non venivano fatti
                                    controlli sulla data).
      ********************************************************************************/
   FUNCTION accesso_smistamento_cruscotto (p_iddocumento    VARCHAR2,
                                           p_utente         VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      codiceassegnatario   VARCHAR2 (100);
      id_protocollo        NUMBER;
      id_fascicolo         NUMBER;
      is_riservato         VARCHAR2 (1);
   BEGIN
      --DBMS_OUTPUT.put_line ('INIZIO');
      IF ag_utilities.inizializza_utente (p_utente, TRUNC (SYSDATE)) = 1
      THEN
         --DBMS_OUTPUT.put_line ('dopo inizializza_ag_priv_utente_tmp');
         BEGIN
            --verifica se l'utente è assegnatario dello smistamento
            -- in tal caso vede lo smistamento sicuramente.
            codiceassegnatario :=
               f_valore_campo (p_iddocumento,
                               ag_utilities.campo_assegnatario);

            IF     codiceassegnatario IS NOT NULL
               AND codiceassegnatario = p_utente
            THEN
               retval := 1;
            END IF;

            --SE L'UTENTE APPARTIENE ALL'UNITA RICEVENTE, PUO' VEDERE L'ATTIVITA' DEL CRUSCOTTO SE PUO' VEDERE
            --IL PROTOCOLLO.
            -- A32979.0.0 SC invece di controllare le comp in lettura verifica se l'utente ha il documento da ricevere,
            --o in carico. Infatti la lettura è troppo generale e darebbe accesso alle attività di scrivania
            --anche a chi in realtà non può svolgere tali attività.
            IF retval = 0
            THEN
               --VERIFICA SE L'UTENTE PUO' VEDERE IL PROTOCOLLO CHE E' STATO SMISTATO.
               --retval := lettura (p_iddocumento, p_utente);
               id_protocollo :=
                  ag_utilities.get_protocollo_per_idrif (
                     f_valore_campo (p_iddocumento, ag_utilities.campo_idrif));
               is_riservato :=
                  ag_competenze_protocollo.is_riservato (id_protocollo);

               IF id_protocollo IS NULL
               THEN
                  id_protocollo :=
                     ag_utilities.get_documento_per_idrif (
                        f_valore_campo (p_iddocumento,
                                        ag_utilities.campo_idrif));
                  is_riservato :=
                     ag_competenze_documento.is_riservato (id_protocollo);
               END IF;

               -- Ora viene fatto al login non serve farlo ad ogni smistamento
               --ag_priv_d_utente_tmp_utility.init_ag_priv_d_utente_tmp (p_utente);

               IF id_protocollo IS NOT NULL
               THEN
                  retval :=
                     verifica_privilegi_d_utente (
                        NVL (is_riservato, 'N'),
                        p_utente,
                        f_valore_campo (p_iddocumento, 'STATO_SMISTAMENTO'),
                        f_valore_campo (p_iddocumento, 'UFFICIO_SMISTAMENTO'),
                        TRUNC (SYSDATE),
                        f_Valore_campo (id_protocollo,
                                        'CODICE_AMMINISTRAZIONE'),
                        f_valore_campo (id_protocollo, 'CODICE_AOO'));
               ELSE
                  id_fascicolo :=
                     ag_utilities.get_fascicolo_per_idrif (
                        f_valore_campo (p_iddocumento,
                                        ag_utilities.campo_idrif));
                  DBMS_OUTPUT.put_line ('id_fascicolo ' || id_fascicolo);

                  IF id_fascicolo IS NOT NULL
                  THEN
                     DBMS_OUTPUT.put_line (
                           'UFFICIO_SMISTAMENTO '
                        || f_valore_campo (p_iddocumento,
                                           'UFFICIO_SMISTAMENTO'));
                     retval :=
                        verifica_privilegi_d_utente (
                           NVL (f_valore_campo (id_fascicolo, 'RISERVATO'),
                                'N'),
                           p_utente,
                           f_valore_campo (p_iddocumento,
                                           'STATO_SMISTAMENTO'),
                           f_valore_campo (p_iddocumento,
                                           'UFFICIO_SMISTAMENTO'),
                           TRUNC (SYSDATE),
                           f_valore_campo (id_fascicolo,
                                           'CODICE_AMMINISTAZIONE'),
                           f_valore_campo (id_fascicolo, 'CODICE_AOO'));
                  ELSE
                     retval := 0;
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               -- DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
               retval := 0;
         END;
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
         retval := 0;
   END accesso_smistamento_cruscotto;

   /*****************************************************************************
       NOME:        SMISTAMENTO_DA_RICEVERE.
       DESCRIZIONE: Funzione per verificare se lo smistamento è da ricevere per l'utente.
       Si usa per abilitare i bottoni nella relativa barra del protocollo.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a vedere il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION smistamento_da_ricevere (p_iddocumento    VARCHAR2,
                                     p_utente         VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      codiceassegnatario   VARCHAR2 (100);
      d_idrif              VARCHAR2 (100);
      idprotocollo         NUMBER;
      dep_data_rif         DATE;
   BEGIN
      BEGIN
         codiceassegnatario :=
            f_valore_campo (p_iddocumento, 'CODICE_ASSEGNATARIO');
         d_idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         dep_data_rif := ag_utilities.get_data_rif_privilegi (p_iddocumento);

         /*SELECT TRUNC (
                   DECODE (ag_utilities.storicoruoli,
                           'Y', data,
                           SYSDATE))
           INTO dep_data_rif
           FROM classificabile_view
          WHERE idrif = d_idrif
         UNION
         SELECT TRUNC (
                   DECODE (ag_utilities.storicoruoli,
                           'Y', data,
                           SYSDATE))
           FROM proto_view
          WHERE idrif = d_idrif
         UNION
         SELECT TRUNC (
                   DECODE (ag_utilities.storicoruoli,
                           'Y', data_creazione,
                           SYSDATE))
           FROM seg_fascicoli
          WHERE idrif = d_idrif;*/

         IF codiceassegnatario IS NOT NULL AND codiceassegnatario = p_utente
         THEN
            retval := 1;
         ELSIF codiceassegnatario IS NULL
         THEN
            --VERIFICA SE L'UTENTE APPARTIENE ALL'UNITA RICEVENTE
            IF f_valore_campo (p_iddocumento,
                               ag_utilities.campo_stato_smistamento) =
                  ag_utilities.smistamento_da_ricevere
            THEN
               retval :=
                  ag_utilities.verifica_unita_utente (
                     f_valore_campo (p_iddocumento,
                                     ag_utilities.campo_unita_carico),
                     p_utente,
                     dep_data_rif);
            END IF;

            --SE L'UTENTE APPARTIENE ALL'UNITA RICEVENTE, PUO' VEDERE L'ATTIVITA' DEL CRUSCOTTO SE PUO' VEDERE
            --IL PROTOCOLLO.
            IF retval = 1
            THEN
               --VERIFICA SE L'UTENTE PUO' VEDERE IL PROTOCOLLO CHE E' STATO SMISTATO.
               retval := lettura (p_iddocumento, p_utente);
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END smistamento_da_ricevere;

   /*****************************************************************************
       NOME:        SMISTAMENTO_IN_CARICO.
       DESCRIZIONE: Funzione per verificare se lo smistamento è in carico per l'utente.
       Si usa per abilitare i bottoni nella relativa barra del protocollo.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a vedere il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION smistamento_in_carico (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      codiceassegnatario   VARCHAR2 (100);
      d_idrif              VARCHAR2 (100);
      dep_data_rif         DATE;
   BEGIN
      BEGIN
         codiceassegnatario :=
            f_valore_campo (p_iddocumento, 'CODICE_ASSEGNATARIO');
         d_idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         dep_data_rif := ag_utilities.get_data_rif_privilegi (p_iddocumento);

         /*SELECT TRUNC (
                   DECODE (ag_utilities.storicoruoli,
                           'Y', data,
                           SYSDATE))
           INTO dep_data_rif
           FROM classificabile_view
          WHERE idrif = d_idrif
         UNION
         SELECT TRUNC (
                   DECODE (ag_utilities.storicoruoli,
                           'Y', data,
                           SYSDATE))
           FROM proto_view
          WHERE idrif = d_idrif
         UNION
         SELECT TRUNC (
                   DECODE (ag_utilities.storicoruoli,
                           'Y', data_creazione,
                           SYSDATE))
           FROM seg_fascicoli
          WHERE idrif = d_idrif;*/

         IF codiceassegnatario IS NOT NULL AND codiceassegnatario = p_utente
         THEN
            retval := 1;
         ELSIF codiceassegnatario IS NULL
         THEN
            --VERIFICA SE L'UTENTE APPARTIENE ALL'UNITA RICEVENTE
            IF f_valore_campo (p_iddocumento,
                               ag_utilities.campo_stato_smistamento) =
                  ag_utilities.smistamento_in_carico
            THEN
               retval :=
                  ag_utilities.verifica_unita_utente (
                     f_valore_campo (p_iddocumento,
                                     ag_utilities.campo_unita_carico),
                     p_utente,
                     dep_data_rif);
            END IF;
         END IF;

         --SE L'UTENTE APPARTIENE ALL'UNITA RICEVENTE, PUO' VEDERE L'ATTIVITA' DEL CRUSCOTTO SE PUO' VEDERE
         --IL PROTOCOLLO.
         IF retval = 1
         THEN
            --VERIFICA SE L'UTENTE PUO' VEDERE IL PROTOCOLLO CHE E' STATO SMISTATO.
            retval := lettura (p_iddocumento, p_utente);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END smistamento_in_carico;

   /*****************************************************************************
       NOME:        ACCESSO_SMISTAMENTO_CRUSCOTTO.
       DESCRIZIONE: Funzione per verificare se l'utente deve vedere la riga di
       iter documentale del cruscotto.
       Un utente la deve vedere se fa parte dell'unita' ricevente e se ha diritto
       a vedere il protocollo.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION accesso_smistamento_cruscotto (p_area                VARCHAR2,
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
         retval := accesso_smistamento_cruscotto (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END accesso_smistamento_cruscotto;

   /*****************************************************************************
       NOME:        IS_POSSIBILE_SMISTARE.
       DESCRIZIONE: Funzione per verificare se l'utente avente privilegio SMISTAAREA puo' smistare per.
       l'unita ricevente passata
      INPUT   d_nome_utente VARCHAR2,
               d_unita_ricevente VARCHAR2,
               d_unita_trasmissione VARCHAR2,
               d_codice_amm VARCHAR2,
               d_codice_aoo VARCHAR2,
               d_data_smistamento VARCHAR2,
               d_codice_assegnatario VARCHAR2
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore   Descrizione.
       000   23/09/2008 AM       Prima emissione.
       001   09/03/2010 SC       A34954.5 . 1 D1039 Per verificare se l'unità
                                 ricevente fa parte dell'area si devono scorrere
                                 tutti i discendenti dell'area.
       002  23/05/2011  MM       A42830.0.0: Mancata gestione priv ASS
                                 se AL sul ruolo > sysdate.
       001  31/03/2017  SC       Gestione date per privilegi
      ********************************************************************************/
   FUNCTION is_possibile_smistare (d_nome_utente            VARCHAR2,
                                   d_unita_ricevente        VARCHAR2,
                                   d_unita_trasmissione     VARCHAR2,
                                   d_codice_amm             VARCHAR2,
                                   d_codice_aoo             VARCHAR2,
                                   d_data_smistamento       VARCHAR2,
                                   d_codice_assegnatario    VARCHAR2,
                                   d_idrif                  VARCHAR2)
      RETURN NUMBER
   IS
      v_ottica                    VARCHAR (18) := '';
      dep_codice_unita            seg_unita.unita%TYPE;
      dep_progr_unita             seg_unita.progr_unita_organizzativa%TYPE;
      dep_dal_unita               DATE;
      dep_al_unita                DATE;
      v_retunitasmistaarea        VARCHAR2 (4000) := '';
      v_radice_ricezione          VARCHAR2 (20);
      c_privilegiotutti           VARCHAR2 (20) := 'SMISTATUTTI';
      c_privilegioassegnatutti    VARCHAR2 (20) := 'ASSTOT';
      c_privilegioassegna         VARCHAR2 (20) := 'ASS';
      v_formato_data              VARCHAR (10);
      v_cur                       afc.t_ref_cursor;
      v_ret                       NUMBER := 0;

      dep_data_rif                DATE;
      dep_progr_unita_ricevente   NUMBER;
      dep_id_documento            NUMBER;
   BEGIN
      IF ag_utilities.inizializza_utente (d_nome_utente) = 0
      THEN
         IF d_nome_utente = ag_utilities.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END IF;

      v_formato_data :=
         ag_parametro.get_valore ('FORMATO_DATA', '@agStrut@', 'dd/MM/yyyy');
      dep_id_documento := ag_utilities.get_id_documento_from_idrif (d_idrif);
      /*007     21/05/2020 SC   Bug #41226 data riferimento sempre sysdate in
                                  IS_POSSIBILE_SMISTARE.  */
      dep_data_rif := TRUNC (SYSDATE); --ag_utilities.get_data_rif_privilegi (dep_id_documento);
      /*SELECT TRUNC (
                DECODE (ag_utilities.storicoruoli,
                        'Y', data,
                        SYSDATE))
        INTO dep_data_rif
        FROM classificabile_view
       WHERE idrif = d_idrif
      UNION
      SELECT TRUNC (
                DECODE (ag_utilities.storicoruoli,
                        'Y', data,
                        SYSDATE))
        FROM proto_view
       WHERE idrif = d_idrif
      UNION
      SELECT TRUNC (
                DECODE (ag_utilities.storicoruoli,
                        'Y', data_creazione,
                        SYSDATE))
        FROM seg_fascicoli
       WHERE idrif = d_idrif;*/



      --Calcolo l'ottica dell'utente
      v_ottica :=
         ag_utilities.get_ottica_utente (d_nome_utente,
                                         d_codice_amm,
                                         d_codice_aoo);
      dep_progr_unita_ricevente :=
         so4_ags_pkg.anuo_get_progr (p_ottica      => v_ottica,
                                     p_codice_uo   => d_unita_ricevente,
                                     p_data        => dep_data_rif);

      -- Se l'utente e' il super user ha sempre tutti i diritti
      IF (UPPER (d_nome_utente) = ag_utilities.utente_superuser_segreteria)
      THEN
         v_ret := 1;
      ELSE
         IF (ag_competenze_smistamento.check_privilegio_utente (
                d_nome_utente,
                c_privilegiotutti,
                TRUNC (SYSDATE)) = 1)
         THEN
            --Se ho SMISTATUTTI
            IF d_codice_assegnatario IS NULL
            THEN
               v_ret := 1;
            ELSE
               IF (ag_competenze_smistamento.check_privilegio_utente (
                      d_nome_utente,
                      c_privilegioassegnatutti,
                      dep_data_rif) = 1)
               THEN
                  v_ret := 1;
               ELSE
                  close_cursore (v_cur);
                  v_cur :=
                     ag_utilities.get_unita_priviegio_utente (
                        d_nome_utente,
                        c_privilegioassegna);

                  --FETCH v_cur INTO dep_codice_unita, dep_dal_unita, dep_al_unita;
                  --IF v_cur%FOUND and d_unita_trasmissione is not null
                  IF v_cur%ISOPEN AND dep_progr_unita_ricevente IS NOT NULL
                  THEN
                     --devo scorrere il cursore e cercare l'unita di trasmissione
                     LOOP
                        -- costruisce una stringa delle unita di livello 0 dell'area per cui l'utente
                        -- ha privilegio SMISTAAREA, i codici sono separati da @.
                        FETCH v_cur
                           INTO dep_codice_unita,
                                dep_dal_unita,
                                dep_al_unita,
                                dep_progr_unita;

                        EXIT WHEN v_cur%NOTFOUND;

                        -- Rev. 002  23/05/2011  MM  A42830.0.0: Mancata gestione priv ASS se AL sul ruolo > sysdate.
                        IF (                            --dep_al_unita IS NULL
                            dep_data_rif <= /*BETWEEN TRUNC (dep_dal_unita)
                                                AND*/
                                   TRUNC (
                                      NVL (dep_al_unita,
                                           TO_DATE (3333333, 'J')))
                            AND dep_progr_unita = dep_progr_unita_ricevente)
                        THEN
                           -- Rev. 002  23/05/2011  MM  A42830.0.0: fine mod.
                           v_ret := 1;
                           EXIT;
                        END IF;
                     END LOOP;

                     close_cursore (v_cur);
                  ELSE
                     v_ret := 0;
                  END IF;
               END IF;
            END IF;
         ELSE
            --SC A34954.5 . 1 D1039 Per verificare se l'unità ricevente fa parte dell'area
            -- si devono scorrere tutti i discendenti dell'area.
            FOR c
               IN (SELECT progr_unita, unita_radice_area
                     FROM ag_radici_area_utente_tmp
                    WHERE     utente = d_nome_utente
                          AND privilegio = ag_utilities.privilegio_smistaarea)
            LOOP
               IF ag_utilities.is_unita_in_area (c.progr_unita,
                                                 dep_progr_unita_ricevente,
                                                 dep_data_rif,
                                                 v_ottica) = 1
               THEN
                  IF d_codice_assegnatario IS NULL
                  THEN
                     v_ret := 1;
                  ELSE
                     IF (ag_competenze_smistamento.check_privilegio_utente (
                            d_nome_utente,
                            c_privilegioassegnatutti,
                            dep_Data_rif) = 1)
                     THEN
                        v_ret := 1;
                     ELSE
                        IF v_cur%ISOPEN
                        THEN
                           CLOSE v_cur;
                        END IF;

                        v_cur :=
                           ag_utilities.get_unita_priviegio_utente (
                              d_nome_utente,
                              c_privilegioassegna);

                        --FETCH v_cur INTO dep_codice_unita, dep_dal_unita, dep_al_unita;
                        IF v_cur%ISOPEN AND d_unita_ricevente IS NOT NULL
                        THEN
                           --devo scorrere il cursore e cercare l'unita di trasmissione
                           LOOP
                              FETCH v_cur
                                 INTO dep_codice_unita,
                                      dep_dal_unita,
                                      dep_al_unita,
                                      dep_progr_unita;


                              EXIT WHEN v_cur%NOTFOUND;

                              IF (    dep_data_rif <= /*
                                         BETWEEN TRUNC (dep_dal_unita)
                                             AND */
                                         TRUNC (
                                            NVL (dep_al_unita,
                                                 TO_DATE (3333333, 'J')))
                                  AND dep_progr_unita =
                                         dep_progr_unita_ricevente)
                              THEN
                                 v_ret := 1;
                                 EXIT;
                              END IF;
                           END LOOP;

                           IF v_cur%ISOPEN
                           THEN
                              CLOSE v_cur;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN v_ret;
   END;

   /*****************************************************************************
       NOME:        CHECK_PRIVILEGIO_UTENTE.
       DESCRIZIONE:

      INPUT






      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00
       01    03/04/2017 Inserito commento e gestione progressivo

      ********************************************************************************/
   FUNCTION check_privilegio_utente (d_nome_utente    VARCHAR2,
                                     d_privilegio     VARCHAR2,
                                     d_data           DATE)
      RETURN NUMBER
   IS
      v_cur              afc.t_ref_cursor;
      v_ret              NUMBER := 0;
      dep_codice_unita   seg_unita.unita%TYPE;
      dep_progr_unita    seg_unita.progr_unita_organizzativa%TYPE;
      dep_dal_unita      DATE;
      dep_al_unita       DATE;
   BEGIN
      v_cur :=
         ag_utilities.get_unita_priviegio_utente (d_nome_utente,
                                                  d_privilegio);

      WHILE v_cur%ISOPEN AND v_ret = 0
      LOOP
         FETCH v_cur
            INTO dep_codice_unita,
                 dep_dal_unita,
                 dep_al_unita,
                 dep_progr_unita;


         EXIT WHEN v_cur%NOTFOUND;



         IF d_data <= NVL (dep_al_unita, TO_DATE (3333333, 'j'))
         THEN
            v_ret := 1;
         END IF;
      END LOOP;


      close_cursore (v_cur);
      RETURN v_ret;
   END;
END ag_competenze_smistamento;
/
