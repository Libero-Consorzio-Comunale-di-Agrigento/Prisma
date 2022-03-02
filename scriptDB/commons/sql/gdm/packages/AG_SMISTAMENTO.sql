--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_SMISTAMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_smistamento
IS
   /******************************************************************************
    NOME:        AG_SMISTAMENTO.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 SMISTAMENTI.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   04/02/2011 MM     Creazione.
    01   14/08/2015 MM     Creazione elimina_smistamenti (spostata da ag_memo_utility),
                           upd_data_attivazione e is_possibile_smistare.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.01';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION crea_task_esterni (
      p_area                         VARCHAR2,
      p_codice_modello               VARCHAR2,
      p_codice_richiesta             VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION crea_task_esterno (
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_utente_esterno               VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************
    NOME:        DELETE_TASK_ESTERNI
    DESCRIZIONE: Cancella un task esterno mediante id_riferimento del task.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
         27/11/2017 SC     Eliminazione con worklist_service, parametro utente
   ******************************************************************************/
   PROCEDURE delete_task_esterni (p_id_riferimento    VARCHAR2,
                                  p_utente            VARCHAR2);

   PROCEDURE delete_task_esterni (p_id_riferimento VARCHAR2);

   PROCEDURE delete_task_esterni_commit (p_id_riferimento VARCHAR2);

   PROCEDURE delete_task_esterni_commit (p_id_riferimento    VARCHAR2,
                                         p_utente            VARCHAR2);

   --

   PROCEDURE chiudi_iter_scrivania (p_area                VARCHAR2,
                                    p_codice_modello      VARCHAR2,
                                    p_codice_richiesta    VARCHAR2);

   PROCEDURE gest_smist_manuali_scaduti;

   FUNCTION calcola_url_query_iter (p_id_oggetto           NUMBER,
                                    p_unita                VARCHAR2,
                                    p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION calcola_url_query_iter_doc (p_unita                VARCHAR2,
                                        p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION calcola_url_query_iter_fasc (p_unita                VARCHAR2,
                                         p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE invia_a_unita (p_id_documento                 NUMBER,
                            p_utente                       VARCHAR2,
                            p_unita_tras                   VARCHAR2,
                            p_unita_ric                    VARCHAR2,
                            p_storicizza_assegnati         VARCHAR2,
                            p_codice_amministrazione       VARCHAR2,
                            p_codice_aoo                   VARCHAR2,
                            p_des_unita_tras               VARCHAR2,
                            p_des_unita_ric                VARCHAR2,
                            p_messaggio                OUT VARCHAR2,
                            p_errore                   OUT NUMBER);

   PROCEDURE invia_fasc_a_unita (p_id_documento                 NUMBER,
                                 p_id_cartella                  NUMBER,
                                 p_utente                       VARCHAR2,
                                 p_unita_tras                   VARCHAR2,
                                 p_unita_ric                    VARCHAR2,
                                 p_storicizza_assegnati         VARCHAR2,
                                 p_codice_amministrazione       VARCHAR2,
                                 p_codice_aoo                   VARCHAR2,
                                 p_des_unita_tras               VARCHAR2,
                                 p_des_unita_ric                VARCHAR2,
                                 p_messaggio                OUT VARCHAR2,
                                 p_errore                   OUT NUMBER);

   PROCEDURE elimina_smistamenti (p_idrif VARCHAR2);

   PROCEDURE upd_data_attivazione (p_idrif VARCHAR2, p_data VARCHAR2);

   FUNCTION is_possibile_smistare (p_idrif                IN VARCHAR2,
                                   p_unita_trasmissione   IN VARCHAR2,
                                   p_utente               IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_task_esterni_utente (
      p_area                         VARCHAR2,
      p_codice_modello               VARCHAR2,
      p_codice_richiesta             VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL,
      a_utente                       VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************
    NOME:        INVIA_MAIL_SMISTAMENTO
    DESCRIZIONE: Invia una mail a seguito
                 dello smistamento se
                 - lo smistamento è per competenza
                 e se
                 - se esiste uno smistamento con mail e sequenza per la stessa
                   unità associato al tipo documento
                 oppure, in seconda battuta
                 - se l'unità ha indirizzo MANUALE


    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  27/09/2017 SC     Creazione.
   ******************************************************************************/
   PROCEDURE invia_mail_smistamento (p_id_smistamento       NUMBER,
                                     p_stato_smistamento    VARCHAR2);

   FUNCTION crea_task_esterno_new (P_ID_RIFERIMENTO           IN VARCHAR2,
                                   P_ATTIVITA_DESCRIZIONE     IN VARCHAR2,
                                   P_TOOLTIP_ATTIVITA_DESCR   IN VARCHAR2,
                                   P_URL_RIF                  IN VARCHAR2,
                                   P_URL_RIF_DESC             IN VARCHAR2,
                                   P_URL_EXEC                 IN VARCHAR2,
                                   P_TOOLTIP_URL_EXEC         IN VARCHAR2,
                                   P_DATA_SCAD                IN DATE,
                                   P_PARAM_INIT_ITER          IN VARCHAR2,
                                   P_NOME_ITER                IN VARCHAR2,
                                   P_DESCRIZIONE_ITER         IN VARCHAR2,
                                   P_COLORE                   IN VARCHAR2,
                                   P_ORDINAMENTO              IN VARCHAR2,
                                   P_UTENTE_ESTERNO           IN VARCHAR2,
                                   P_CATEGORIA                IN VARCHAR2,
                                   P_DESKTOP                  IN VARCHAR2,
                                   P_STATO                    IN VARCHAR2,
                                   P_STATO_PER_ATTIVITA       IN VARCHAR2,
                                   D_STATO_PER_DESCRIZIONE    IN VARCHAR2,
                                   D_UFFICIO_RICEVENTE        IN VARCHAR2,
                                   P_TIPOLOGIA                IN VARCHAR2,
                                   P_DATIAPPLICATIVI1         IN VARCHAR2,
                                   P_DATIAPPLICATIVI2         IN VARCHAR2,
                                   P_DATASMIST                IN DATE,
                                   P_DATIAPPLICATIVI3         IN VARCHAR2,
                                   P_ID_PROTOCOLLO            IN NUMBER,
                                   P_TIPO_SMISTAMENTO         IN VARCHAR2,
                                   P_DES_UFF_TRASMISSIONE     IN VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY ag_smistamento
IS
   /******************************************************************************
    NOME:        AG_SMISTAMENTO
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 SMISTAMENTI.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 MM     Creazione.
    001  17/01/2011 MM     A47434.0.0: Ordinamento scrivania: vengono elencati
                           prima i documenti smistati senza wf e poi quelli
                           con wf indipendentemente da stato e anno/numero.
    002  27/01/2011 MM     Modificate le funzioni crea_task_esterno e
                           crea_task_esterni per gestire il caso in cui non sia
                           previsto iter dei documenti (parametro
                           ITER_DOCUMENTI_n = N).
    003  17/12/2012 MM     Modificate la procedure upd_ogg_smist_task_est_commit
                           con to_char(id_riferimento) per compatibilita' con
                           agsde 1.2.5.
    004  28/10/2013 SC     Gestione invio a altra unità.
    005  14/08/2015 MM     Creazione elimina_smistamenti (spostata da ag_memo_utility),
                           upd_data_attivazione e is_possibile_smistare.
    006  28/10/2015 MM     Modificata invia_a_unita per gestione smistamenti eseguiti.
    007  16/09/2016 MM     Modificata is_possibile_smistare
         27/04/2017 SC     ALLINEATO ALLO STANDARD
    008  08/01/2018 MM     Modificata invia_mail_smistamento in modo che non faccia
                           nulla se mittente o mail sono nulli
    009  01/06/2018 SC     Spostate le delete_task_esterni in ag_utilities_cruscotto
    010  14/09/2020 SC     Bug #27312 Attivazione bottoni in multiselezione
                           in SmartDesktop
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '010';
   s_server           parametri.valore%TYPE;
   s_context          parametri.valore%TYPE;
   s_idworkarea       NUMBER;

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   FUNCTION get_descrizione_attivita_fasc (p_id_fascicolo        NUMBER,
                                           p_stato               VARCHAR2,
                                           p_tiposmist           VARCHAR2,
                                           p_codice_amm          VARCHAR2,
                                           p_codice_aoo          VARCHAR2,
                                           p_tooltip_url_exec    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_attivita_descrizione   VARCHAR2 (32000);
      d_vardescr               VARCHAR2 (32000);
      d_descr                  VARCHAR2 (32000);
   BEGIN
      IF p_stato = 'R'
      THEN
         IF p_tiposmist = 'CONOSCENZA'
         THEN
            d_vardescr := 'URL_DA_RIC_CON_DESC_F_';
         ELSE
            d_vardescr := 'URL_DA_RIC_COMP_DESC_F_';
         END IF;
      ELSE
         IF p_stato = 'C'
         THEN
            d_vardescr := 'URL_CARICO_DESC_F_';
         ELSE
            d_vardescr := 'URL_ASS_DESC_F_';
         END IF;
      END IF;

      d_descr :=
         NVL (ag_parametro.get_valore (d_vardescr,
                                       p_codice_amm,
                                       p_codice_aoo,
                                       'X'),
              'X');

      --  raise_application_error(-20999,'--->'||p_area_docpadre||'@'||p_codice_modello_docpadre||'@'||p_codice_richiesta_docpadre);
      IF d_descr = 'X'
      THEN
         d_attivita_descrizione := p_tooltip_url_exec;
      ELSE
         d_descr :=
            REPLACE (
               d_descr,
               '$anno',
               NVL (f_valore_campo (p_id_fascicolo, 'FASCICOLO_ANNO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$numeroR',
               ag_utilities_ricerca.get_numero_fascicolo_ricerca (
                  NVL (f_valore_campo (p_id_fascicolo, 'FASCICOLO_NUMERO'),
                       '')));
         d_descr :=
            REPLACE (
               d_descr,
               '$numero',
               NVL (f_valore_campo (p_id_fascicolo, 'FASCICOLO_NUMERO'), ''));
         d_descr :=
            REPLACE (d_descr,
                     '$class_cod',
                     NVL (f_valore_campo (p_id_fascicolo, 'CLASS_COD'), 'X'));
         d_descr :=
            REPLACE (
               d_descr,
               '$oggetto',
               NVL (f_valore_campo (p_id_fascicolo, 'FASCICOLO_OGGETTO'), ''));
         d_attivita_descrizione := SUBSTR (d_descr, 1, 4000);
      END IF;

      RETURN d_attivita_descrizione;
   END;

   FUNCTION get_descrizione_attivita_proto (a_id_protocollo       NUMBER,
                                            a_stato               VARCHAR2,
                                            a_tiposmist           VARCHAR2,
                                            a_codice_amm          VARCHAR2,
                                            a_codice_aoo          VARCHAR2,
                                            a_pec                 VARCHAR2,
                                            a_tooltip_url_exec    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_vardescr               parametri.codice%TYPE;
      d_descr                  VARCHAR2 (32000);
      d_attivita_descrizione   VARCHAR2 (32000);
      d_modalita               VARCHAR2 (32000);
   BEGIN
      IF a_stato = 'R'
      THEN
         IF a_tiposmist = 'CONOSCENZA'
         THEN
            d_vardescr := 'URL_DA_RIC_CON_DESC_';
         ELSE
            d_vardescr := 'URL_DA_RIC_COMP_DESC_';
         END IF;
      ELSE
         IF a_stato = 'C'
         THEN
            d_vardescr := 'URL_CARICO_DESC_';
         ELSE
            d_vardescr := 'URL_ASS_DESC_';
         END IF;
      END IF;

      d_descr :=
         NVL (ag_parametro.get_valore (d_vardescr,
                                       a_codice_amm,
                                       a_codice_aoo,
                                       'X'),
              'X');

      --  raise_application_error(-20999,'--->'||p_area_docpadre||'@'||p_codice_modello_docpadre||'@'||p_codice_richiesta_docpadre);
      IF d_descr = 'X'
      THEN
         d_attivita_descrizione := a_tooltip_url_exec;
      ELSE
         d_descr :=
            REPLACE (d_descr,
                     '$anno',
                     NVL (f_valore_campo (a_id_protocollo, 'ANNO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$numero7',
               LPAD (NVL (f_valore_campo (a_id_protocollo, 'NUMERO'), ''),
                     7,
                     '0'));
         d_descr :=
            REPLACE (d_descr,
                     '$numero',
                     NVL (f_valore_campo (a_id_protocollo, 'NUMERO'), ''));
         d_descr := REPLACE (d_descr, '$tipo', a_pec);
         d_modalita := NVL (f_valore_campo (a_id_protocollo, 'MODALITA'), 'X');

         IF d_modalita <> 'X'
         THEN
            IF d_modalita = 'ARR'
            THEN
               d_modalita := 'Arrivo';
            ELSE
               IF d_modalita = 'PAR'
               THEN
                  d_modalita := 'Partenza';
               ELSE
                  d_modalita := 'Interno';
               END IF;
            END IF;
         ELSE
            d_modalita := '';
         END IF;

         d_descr := REPLACE (d_descr, '$modalita', UPPER (d_modalita));
         d_descr :=
            REPLACE (d_descr,
                     '$oggetto',
                     NVL (f_valore_campo (a_id_protocollo, 'OGGETTO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$data',
               SUBSTR (NVL (f_valore_campo (a_id_protocollo, 'DATA'), ''),
                       1,
                       10));
         d_attivita_descrizione := SUBSTR (d_descr, 1, 4000);
      END IF;

      RETURN d_attivita_descrizione;
   END;

   FUNCTION get_descrizione_attivita_memo (a_id_protocollo       NUMBER,
                                           a_stato               VARCHAR2,
                                           a_tiposmist           VARCHAR2,
                                           a_codice_amm          VARCHAR2,
                                           a_codice_aoo          VARCHAR2,
                                           a_pec                 VARCHAR2,
                                           a_tooltip_url_exec    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_vardescr               parametri.codice%TYPE;
      d_descr                  VARCHAR2 (32000);
      d_attivita_descrizione   VARCHAR2 (32000);
      d_modalita               VARCHAR2 (32000);
   BEGIN
      IF a_stato = 'R'
      THEN
         IF a_tiposmist = 'CONOSCENZA'
         THEN
            d_vardescr := 'URL_DA_RIC_CON_DESC_MEMO_';
         ELSE
            d_vardescr := 'URL_DA_RIC_COMP_DESC_MEMO_';
         END IF;
      ELSE
         IF a_stato = 'C'
         THEN
            d_vardescr := 'URL_CARICO_DESC_MEMO_';
         ELSE
            d_vardescr := 'URL_ASS_DESC_MEMO_';
         END IF;
      END IF;

      d_descr :=
         NVL (ag_parametro.get_valore (d_vardescr,
                                       a_codice_amm,
                                       a_codice_aoo,
                                       'X'),
              'X');

      --  raise_application_error(-20999,'--->'||p_area_docpadre||'@'||p_codice_modello_docpadre||'@'||p_codice_richiesta_docpadre);
      IF d_descr = 'X'
      THEN
         d_attivita_descrizione := a_tooltip_url_exec;
      ELSE
         d_descr :=
            REPLACE (d_descr,
                     '$oggetto',
                     NVL (f_valore_campo (a_id_protocollo, 'OGGETTO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$data',
               SUBSTR (
                  NVL (f_valore_campo (a_id_protocollo, 'DATA_RICEZIONE'),
                       ''),
                  1,
                  10));
         d_attivita_descrizione := SUBSTR (d_descr, 1, 4000);
      END IF;

      RETURN d_attivita_descrizione;
   END;

   FUNCTION get_descrizione_attivita_np (a_id_protocollo       NUMBER,
                                         a_stato               VARCHAR2,
                                         a_tiposmist           VARCHAR2,
                                         a_codice_amm          VARCHAR2,
                                         a_codice_aoo          VARCHAR2,
                                         a_pec                 VARCHAR2,
                                         a_tooltip_url_exec    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_vardescr               parametri.codice%TYPE;
      d_descr                  VARCHAR2 (32000);
      d_attivita_descrizione   VARCHAR2 (32000);
      d_modalita               VARCHAR2 (32000);
   BEGIN
      IF a_stato = 'R'
      THEN
         IF a_tiposmist = 'CONOSCENZA'
         THEN
            d_vardescr := 'URL_DA_RIC_CON_DESC_NP_';
         ELSE
            d_vardescr := 'URL_DA_RIC_COMP_DESC_NP_';
         END IF;
      ELSE
         IF a_stato = 'C'
         THEN
            d_vardescr := 'URL_CARICO_DESC_NP_';
         ELSE
            d_vardescr := 'URL_ASS_DESC_NP_';
         END IF;
      END IF;

      d_descr :=
         NVL (ag_parametro.get_valore (d_vardescr,
                                       a_codice_amm,
                                       a_codice_aoo,
                                       'X'),
              'X');

      IF d_descr = 'X'
      THEN
         d_attivita_descrizione := a_tooltip_url_exec;
      ELSE
         d_descr :=
            REPLACE (d_descr,
                     '$oggetto',
                     NVL (f_valore_campo (a_id_protocollo, 'OGGETTO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$data',
               SUBSTR (NVL (f_valore_campo (a_id_protocollo, 'DATA'), ''),
                       1,
                       10));
         d_attivita_descrizione := SUBSTR (d_descr, 1, 4000);
      END IF;

      RETURN d_attivita_descrizione;
   END;

   /******************************************************************************
    NOME:        CREA_TASK_ESTERNI
    DESCRIZIONE: Creazione di tanti task esterni (per tutti gli utenti che hanno
                 accesso alla riga di attività jsync associata allo smistamento
                 identificato da area, modello e codice_richiesta passati).
                 Parametri da passare per la creazione dei task esterni:
               P_AREA
               P_CODICE_MODELLO
               P_CODICE_RICHIESTA
               P_ID_RIFERIMENTO           indica id di riferimento da utilizzare
                                          come chiave di ricerca
               P_ATTIVITA_DESCRIZIONE     indica la descrizione dell'attività
                                          (colonna  nella scrivania virtuale)
               P_TOOLTIP_ATTIVITA_DESCR   indica la descrizione del tooltip
                                          della colonna descrizione
               P_URL_RIF                  indica l'eventuale link ad una pagina
                                          di riferimento
               P_URL_RIF_DESC             indica il tooltip della pagina di
                                          riferimento
               P_URL_EXEC                 indica url della pagina che verrà
                                          eseguita
               P_TOOLTIP_URL_EXEC         indica il tooltip dell'icona esegui
               P_SCADENZA                 indica la scadenza (colonna scadenza
                                          dalla scrivania)
               P_PARAM_INIT_ITER          indica un parametro da utilizzare per
                                          catalogare i vari task esterni
                                          (utilizzato per l'operazione di
                                          eliminazione)
               P_NOME_ITER                indica il nome dell'iter (colonna
                                          della scrivania)
               P_DESCRIZIONE_ITER         indica la descrizione dell'iter
                                          (colonna scrivania)
               P_COLORE                   indica il colore da attribuire al
                                          relativo task in formato R,G,B
               P_ORDINAMENTO              indica un criterio di ordinamento
               P_DATA_ATTIVAZIONE         indica la data di attiviazione
                                          dell'attività
               P_UTENTE_ESTERNO           indica id dell'utente
               P_CATEGORIA                indica la categoria (default viene
                                          specificata la categoria visibile a
                                          tutti TUTTI)
               P_DESKTOP                  indica il nome desktop (default viene
                                          specificato TUTTI con categoria TUTTI)
    RITORNA:   La funzione restituisce la stringa di ID_ATTIVITA inserite separate
               da @. Ogni id_attività sarà utile per effettuare un eventuale
               operazione di aggiornamento e di eliminazione sui task esterni.
    NOTE:      --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
    002  27/01/2011 MM     Gestione del caso in cui non sia previsto l'iter dei
                           documenti (parametro ITER_DOCUMENTI_n = N).
   ******************************************************************************/
   FUNCTION crea_task_esterni (
      p_area                         VARCHAR2,
      p_codice_modello               VARCHAR2,
      p_codice_richiesta             VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      listaacl          VARCHAR2 (32000);
      listaidattivita   VARCHAR2 (10000);
      d_id_attivita     NUMBER;
      p_2               VARCHAR2 (32000);
      p_sel             VARCHAR2 (32000);

      TYPE rc_sql IS REF CURSOR;

      c_utenti          rc_sql;
      p_utente          VARCHAR2 (1000);
   BEGIN
      listaacl :=
         ag_utilities_cruscotto.get_utenti_accesso_smistamento (
            p_area,
            p_codice_modello,
            p_codice_richiesta);
      listaidattivita := 'X';

      DBMS_OUTPUT.put_line ('listaacl ' || listaacl);

      p_2 := REPLACE (listaacl, '@', ''',''');
      p_2 := SUBSTR (p_2, 3);
      p_2 := SUBSTR (p_2, 1, LENGTH (p_2) - 2);
      p_sel := 'select utente from ad4_utenti where utente in (' || p_2 || ')';


      BEGIN
         OPEN c_utenti FOR p_sel;

         LOOP
            FETCH c_utenti INTO p_utente;

            EXIT WHEN c_utenti%NOTFOUND;

            BEGIN
               --dbms_output.put_line('ute-->'||cElencoUtenti.utente);
               d_id_attivita :=
                  crea_task_esterno (p_id_riferimento,
                                     p_codice_amm,
                                     p_codice_aoo,
                                     p_area_docpadre,
                                     p_codice_modello_docpadre,
                                     p_codice_richiesta_docpadre,
                                     p_url_rif,
                                     p_url_rif_desc,
                                     p_url_exec,
                                     p_tooltip_url_exec,
                                     p_utente,
                                     p_stato,
                                     p_tipologia,
                                     p_datiapplicativi1,
                                     p_datiapplicativi2,
                                     p_datiapplicativi3,
                                     p_param_init_iter);

               -- Rev. 002 27/01/2011 MM: Parametro ITER_DOCUMENTI_n = N, quindi non deve
               -- essere creata l'attivita' in scrivania.
               IF d_id_attivita IS NOT NULL
               THEN
                  -- Rev. 002 27/01/2011 MM: fine mod.
                  IF listaidattivita = 'X'
                  THEN
                     listaidattivita := TO_CHAR (d_id_attivita);
                  ELSE
                     listaidattivita :=
                        listaidattivita || '@' || TO_CHAR (d_id_attivita);
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error (
                     -20999,
                        'Errore in creazione task esterno per utente '
                     || p_utente
                     || '.Errore: '
                     || SQLERRM);
            END;
         END LOOP;

         IF c_utenti%ISOPEN
         THEN
            CLOSE c_utenti;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF c_utenti%ISOPEN
            THEN
               CLOSE c_utenti;
            END IF;
      END;

      RETURN listaidattivita;
   END;

   FUNCTION crea_task_esterni_utente (
      p_area                         VARCHAR2,
      p_codice_modello               VARCHAR2,
      p_codice_richiesta             VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL,
      a_utente                       VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      listaacl          VARCHAR2 (32000);
      listaidattivita   VARCHAR2 (10000);
      d_id_attivita     NUMBER;
      p_2               VARCHAR2 (32000);
      p_sel             VARCHAR2 (32000);

      TYPE rc_sql IS REF CURSOR;

      c_utenti          rc_sql;
      p_utente          VARCHAR2 (1000);
   BEGIN
      DBMS_OUTPUT.put_line ('crea_task_esterni_utente 1');
      listaacl :=
         ag_utilities_cruscotto.get_utenti_accesso_smistamento (
            p_area,
            p_codice_modello,
            p_codice_richiesta);
      DBMS_OUTPUT.put_line ('crea_task_esterni_utente 2');
      listaidattivita := 'X';
      p_2 := REPLACE (listaacl, '@', ''',''');
      p_2 := SUBSTR (p_2, 3);
      p_2 := SUBSTR (p_2, 1, LENGTH (p_2) - 2);
      p_sel := 'select utente from ad4_utenti where utente in (' || p_2 || ')';

      IF a_utente IS NOT NULL
      THEN
         p_sel := p_sel || ' and utente = ''' || a_utente || '''';
      END IF;

      DBMS_OUTPUT.put_line ('crea_task_esterni_utente ' || p_sel);

      BEGIN
         OPEN c_utenti FOR p_sel;

         LOOP
            FETCH c_utenti INTO p_utente;

            EXIT WHEN c_utenti%NOTFOUND;

            BEGIN
               --dbms_output.put_line('ute-->'||cElencoUtenti.utente);
               d_id_attivita :=
                  crea_task_esterno (p_id_riferimento,
                                     p_codice_amm,
                                     p_codice_aoo,
                                     p_area_docpadre,
                                     p_codice_modello_docpadre,
                                     p_codice_richiesta_docpadre,
                                     p_url_rif,
                                     p_url_rif_desc,
                                     p_url_exec,
                                     p_tooltip_url_exec,
                                     p_utente,
                                     p_stato,
                                     p_tipologia,
                                     p_datiapplicativi1,
                                     p_datiapplicativi2,
                                     p_datiapplicativi3,
                                     p_param_init_iter);

               -- Rev. 002 27/01/2011 MM: Parametro ITER_DOCUMENTI_n = N, quindi non deve
               -- essere creata l'attivita' in scrivania.
               IF d_id_attivita IS NOT NULL
               THEN
                  -- Rev. 002 27/01/2011 MM: fine mod.
                  IF listaidattivita = 'X'
                  THEN
                     listaidattivita := TO_CHAR (d_id_attivita);
                  ELSE
                     listaidattivita :=
                        listaidattivita || '@' || TO_CHAR (d_id_attivita);
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error (
                     -20999,
                        'Errore in creazione task esterno per utente '
                     || p_utente
                     || '.Errore: '
                     || SQLERRM);
            END;
         END LOOP;

         IF c_utenti%ISOPEN
         THEN
            CLOSE c_utenti;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF c_utenti%ISOPEN
            THEN
               CLOSE c_utenti;
            END IF;
      END;

      RETURN listaidattivita;
   END;

   FUNCTION crea_task_esterno_old (
      P_ID_RIFERIMENTO           IN     VARCHAR2,
      P_ATTIVITA_DESCRIZIONE     IN OUT VARCHAR2,
      P_TOOLTIP_ATTIVITA_DESCR   IN OUT VARCHAR2,
      P_URL_RIF                  IN     VARCHAR2,
      P_URL_RIF_DESC             IN     VARCHAR2,
      P_URL_EXEC                 IN     VARCHAR2,
      P_TOOLTIP_URL_EXEC         IN     VARCHAR2,
      P_DATA_SCAD                IN OUT DATE,
      P_PARAM_INIT_ITER          IN OUT VARCHAR2,
      P_NOME_ITER                IN OUT VARCHAR2,
      P_DESCRIZIONE_ITER         IN OUT VARCHAR2,
      P_COLORE                   IN OUT VARCHAR2,
      P_ORDINAMENTO              IN OUT VARCHAR2,
      P_UTENTE_ESTERNO           IN     VARCHAR2,
      P_CATEGORIA                IN OUT VARCHAR2,
      P_DESKTOP                  IN OUT VARCHAR2,
      P_STATO                    IN     VARCHAR2,
      P_STATO_PER_ATTIVITA       IN OUT VARCHAR2,
      P_TIPOLOGIA                IN     VARCHAR2,
      P_DATIAPPLICATIVI1         IN     VARCHAR2,
      P_DATIAPPLICATIVI2         IN     VARCHAR2,
      P_DATASMIST                IN OUT DATE,
      P_DATIAPPLICATIVI3         IN     VARCHAR2)
      RETURN NUMBER
   AS
      d_id_attivita   NUMBER;
   BEGIN
      d_id_attivita :=
         jwf_utility.f_crea_task_esterno (
            p_id_riferimento,
            SUBSTR (p_attivita_descrizione, 1, 4000),
            SUBSTR (p_tooltip_attivita_descr, 1, 4000),
            p_url_rif,
            SUBSTR (p_url_rif_desc, 1, 4000),
            p_url_exec,
            SUBSTR (p_tooltip_url_exec, 1, 4000),
            p_data_scad,
            p_param_init_iter,
            p_nome_iter,
            p_descrizione_iter,
            p_colore,
            p_ordinamento,
            SYSDATE,
            p_utente_esterno,
            p_categoria,
            p_desktop,
            NVL (p_stato, p_stato_per_attivita),
            p_tipologia,
            SUBSTR (p_datiapplicativi1, 1, 1024),
            NVL (p_datiapplicativi2,
                 TO_CHAR (p_datasmist, 'dd/mm/yyyy HH24:mi:ss')),
            p_datiapplicativi3);
      RETURN d_id_attivita;
   END;

   FUNCTION crea_task_esterno_new (P_ID_RIFERIMENTO           IN VARCHAR2,
                                   P_ATTIVITA_DESCRIZIONE     IN VARCHAR2,
                                   P_TOOLTIP_ATTIVITA_DESCR   IN VARCHAR2,
                                   P_URL_RIF                  IN VARCHAR2,
                                   P_URL_RIF_DESC             IN VARCHAR2,
                                   P_URL_EXEC                 IN VARCHAR2,
                                   P_TOOLTIP_URL_EXEC         IN VARCHAR2,
                                   P_DATA_SCAD                IN DATE,
                                   P_PARAM_INIT_ITER          IN VARCHAR2,
                                   P_NOME_ITER                IN VARCHAR2,
                                   P_DESCRIZIONE_ITER         IN VARCHAR2,
                                   P_COLORE                   IN VARCHAR2,
                                   P_ORDINAMENTO              IN VARCHAR2,
                                   P_UTENTE_ESTERNO           IN VARCHAR2,
                                   P_CATEGORIA                IN VARCHAR2,
                                   P_DESKTOP                  IN VARCHAR2,
                                   P_STATO                    IN VARCHAR2,
                                   P_STATO_PER_ATTIVITA       IN VARCHAR2,
                                   D_STATO_PER_DESCRIZIONE    IN VARCHAR2,
                                   D_UFFICIO_RICEVENTE        IN VARCHAR2,
                                   P_TIPOLOGIA                IN VARCHAR2,
                                   P_DATIAPPLICATIVI1         IN VARCHAR2,
                                   P_DATIAPPLICATIVI2         IN VARCHAR2,
                                   P_DATASMIST                IN DATE,
                                   P_DATIAPPLICATIVI3         IN VARCHAR2,
                                   P_ID_PROTOCOLLO            IN NUMBER,
                                   P_TIPO_SMISTAMENTO         IN VARCHAR2,
                                   P_DES_UFF_TRASMISSIONE     IN VARCHAR2)
      RETURN NUMBER
   AS
      dep_file_scartato           VARCHAR2 (32000);
      d_id_attivita               NUMBER;
      d_des_unita_ricevente       VARCHAR2 (32000);
      d_des_unita_trasmissione    VARCHAR2 (32000);
      dep_des_query               VARCHAR2 (32000) := 'Documenti ';
      dep_se_assegna              VARCHAR2 (1);
      dep_stmt                    VARCHAR2 (32000);
      dep_dettaglio               VARCHAR2 (32000);
      dep_ente                    VARCHAR2 (1000);
      --dep_des_ente            VARCHAR2 (1000);
      dep_tipo_oggetto            VARCHAR2 (1) := 'D';
      dep_url_rif                 VARCHAR2 (32000);
      dep_url_exec                VARCHAR2 (32000);
      dep_tipologia_descrizione   VARCHAR2 (256);
      dep_prendere_visione        VARCHAR2 (1000) := 'Da prendere visione';
      dep_presa_visione           VARCHAR2 (1000) := 'Presa visione';
      dep_presa_visione_ass       VARCHAR2 (1000) := 'Presa visione - ASS';
      dep_prendere_carico         VARCHAR2 (1000) := 'Prendi in carico';
      dep_prendere_carico_ass     VARCHAR2 (1000) := 'Prendi in carico - ASS';
      dep_preso_carico            VARCHAR2 (1000) := 'In carico';
      dep_assegnato               VARCHAR2 (1000) := 'Assegnato';
      dep_mittdest                VARCHAR2 (32000) := ' ';
      dep_presenza_note           VARCHAR2 (2) := 'NO';
      dep_note_smistamento        VARCHAR2 (32000);
      dep_url_servlet             VARCHAR2 (32000)
         :=    '../agspr/WorklistAllegatiServlet?idDocumento='
            || P_ID_PROTOCOLLO
            || '&utente='
            || p_utente_esterno;
      dep_file_ini                VARCHAR2 (32000);
   BEGIN
      dep_file_ini := ag_parametro.get_valore ('FILE_GDM_INI', '@agStrut@');
      dep_url_exec := p_url_exec; --ag_utilities_cruscotto.ADD_SERVER_TO_URL (p_url_exec);
      dep_url_rif := p_url_rif; --ag_utilities_cruscotto.ADD_SERVER_TO_URL (p_url_rif);

      IF f_valore_campo (P_ID_RIFERIMENTO, 'CODICE_ASSEGNATARIO') IS NOT NULL
      THEN
         dep_prendere_carico := dep_prendere_carico_ass;
         dep_presa_visione := dep_presa_visione_ass;
      END IF;

      IF p_tipologia = 'ATTIVA_ITER_FASCICOLARE'
      THEN
         dep_tipo_oggetto := 'F';
      END IF;

      DBMS_OUTPUT.put_line ('crea_task_esterno_new 1 ' || dep_tipo_oggetto);
      AG_UTILITIES_CRUSCOTTO.RIMUOVI_TUTTO_SMARTDESKTOP;

      --      IF dep_tipo_oggetto = 'D'
      --      THEN
      --
      --         ag_utilities_cruscotto.ADD_FILE_SMARTDESKTOP (P_ID_PROTOCOLLO);
      --         for allegati in (select alpr.id_documento
      --                            from seg_allegati_protocollo alpr
      --                               , documenti docu
      --                           where idrif = f_valore_campo(P_ID_PROTOCOLLO, 'IDRIF')
      --                             and alpr.id_documento = docu.id_documento
      --                             and docu.stato_documento not in ('CA', 'RE', 'PB')) loop
      --            ag_utilities_cruscotto.ADD_FILE_SMARTDESKTOP (allegati.id_documento, 'Allegato', 3);
      --         end loop;
      --      END IF;

      IF dep_tipo_oggetto = 'D'
      THEN
         dep_mittdest :=
            ag_utilities_cruscotto.GET_DENOMINAZIONE_CORR (P_ID_PROTOCOLLO);
      END IF;

      IF dep_tipo_oggetto = 'F'
      THEN
         dep_des_query := 'Fascicoli ';
      END IF;

      --dbms_output.put_line('P_URL_RIF_DESC '||P_URL_RIF_DESC);

      IF INSTR (P_URL_RIF_DESC, 'da ricevere') > 0
      THEN
         dep_des_query := dep_des_query || 'da ricevere';
      ELSIF INSTR (P_URL_RIF_DESC, 'in carico') > 0
      THEN
         dep_des_query := dep_des_query || 'in carico';
      ELSE
         dep_des_query := dep_des_query || 'assegnati';
      END IF;

      --dep_des_query
      dep_stmt :=
            'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO('''
         || REPLACE (dep_des_query, '''', '''''')
         || ''''
         || ', '''
         || P_URL_RIF
         || ''', 1);'
         || 'end;';

      EXECUTE IMMEDIATE dep_stmt;

      --  dbms_output.put_line('crea_task_esterno_new 2');
      --  dbms_output.put_line('crea_task_esterno_new 3');

      dep_stmt :=
            'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Tipo smistamento'''
         || ', '''
         || P_TIPO_SMISTAMENTO
         || ''');'
         || ' end;';

      EXECUTE IMMEDIATE dep_stmt;

      IF (TO_CHAR (p_datasmist, 'dd/mm/yyyy HH24:mi:ss') IS NOT NULL)
      THEN
         dep_dettaglio := TO_CHAR (p_datasmist, 'dd/mm/yyyy HH24:mi:ss');
         dep_stmt :=
               'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Data Stato'''
            || ', '''
            || dep_dettaglio
            || ''');'
            || ' end;';

         EXECUTE IMMEDIATE dep_stmt;
      END IF;

      /*IF (dep_tipo_oggetto != 'F' AND p_datiapplicativi2 IS NOT NULL)
      THEN
         dep_stmt :=
               'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO('''''
            || ', NVL ('''
            || REPLACE (p_datiapplicativi2, '''', '''''')
            || ''','
            || '''''));'
            || ' end;';

         EXECUTE IMMEDIATE dep_stmt;
      END IF;*/

      --     dbms_output.put_line('crea_task_esterno_new 4');

      dep_stmt :=
            'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Unita'''' trasmissione'''
         || ', '''
         || REPLACE (p_des_uff_trasmissione, '''', '''''')
         || ''');'
         || ' end;';

      EXECUTE IMMEDIATE dep_stmt;

      IF (P_PARAM_INIT_ITER IS NOT NULL)
      THEN
         d_des_unita_ricevente :=
            SUBSTR (P_PARAM_INIT_ITER,
                    INSTR (P_PARAM_INIT_ITER, 'SMISTAMENTO a ') + 14);
         dep_stmt :=
               'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Unita'''' ricevente'''
            || ', '''
            || REPLACE (d_des_unita_ricevente, '''', '''''')
            || ''');'
            || ' end;';

         EXECUTE IMMEDIATE dep_stmt;
      END IF;

      dep_stmt :=
            'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Corrispondente'''
         || ', '''
         || REPLACE (TRIM (dep_mittdest), '''', '''''')
         || ''');'
         || ' end;';

      EXECUTE IMMEDIATE dep_stmt;


      dep_note_smistamento := f_valore_campo (P_ID_RIFERIMENTO, 'NOTE');

      IF dep_note_smistamento IS NOT NULL
      THEN
         dep_presenza_note := 'SI';
      END IF;

      dep_stmt :=
            'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Note smistamento'''
         || ', '''
         || REPLACE (dep_presenza_note, '''', '''''')
         || ''');'
         || ' end;';

      EXECUTE IMMEDIATE dep_stmt;


      --     dbms_output.put_line('crea_task_esterno_new 5');
      DECLARE
         dep_urlazione            VARCHAR2 (32000);
         dep_urlserver            VARCHAR2 (32000);
         dep_contextpath          VARCHAR2 (32000);
         dep_fileIni              VARCHAR2 (32000);
         dep_urlDocumentoView     VARCHAR2 (32000);
         dep_nominativo           ad4_utenti.nominativo%TYPE;
         dep_wareaProtocollo      VARCHAR2 (100);
         dep_id_wareaProtocollo   NUMBER;
         dep_idquery              NUMBER;
         d_amm_aoo                afc.t_ref_cursor;
         d_cod_amm                VARCHAR2 (1000);
         d_cod_aoo                VARCHAR2 (1000);
      BEGIN
         dep_ente := ag_parametro.get_valore ('ENTE', '@agStrut@', 'ENTE');

         --BEGIN
         --            SELECT descrizione
         --              INTO dep_des_ente
         --              FROM ad4_enti
         --             WHERE ente = dep_ente;
         --         EXCEPTION
         --            WHEN OTHERS
         --            THEN
         --               dep_des_ente := dep_ente;
         --         END;

         dep_urlserver := '..'; --AG_PARAMETRO.GET_VALORE ('AG_SERVER_URL', '@ag@');
         dep_contextpath :=
            AG_PARAMETRO.GET_VALORE ('AG_CONTEXT_PATH_AGSPR',
                                     '@ag@',
                                     'agspr');
         dep_fileIni := AG_PARAMETRO.GET_VALORE ('FILE_GDM_INI', '@agStrut@');
         dep_nominativo := AD4_UTENTE.GET_NOMINATIVO (p_utente_esterno);

         /*dep_se_assegna :=
            AG_UTILITIES.VERIFICA_PRIVILEGIO_UTENTE (
               D_UFFICIO_RICEVENTE,
               'ASS',
               p_utente_esterno,
               AG_UTILITIES.GET_DATA_RIF_PRIVILEGI (P_ID_PROTOCOLLO));*/
         IF dep_tipo_oggetto != 'F'
         THEN
            FOR bottone
               IN (  SELECT azione,
                            tipo_azione,
                            azione_multipla,
                            label,
                            tooltip,
                            icona,
                            modello,
                            modello_azione,
                            assegnazione,
                            url_azione
                       FROM seg_bottoni_notifiche
                      WHERE     tipo = 'ATTIVA_ITER_DOCUMENTALE'
                            AND stato = d_stato_per_descrizione
                            AND INSTR (tipo_smistamento,
                                       '#' || p_tipo_smistamento) > 0
                   ORDER BY sequenza)
            LOOP
               dep_urlDocumentoView :=
                  AG_PARAMETRO.GET_VALORE ('URL_DOC_W', '@agStrut@');

               /* dep_urlDocumentoView :=
                   ag_utilities_cruscotto.ADD_SERVER_TO_URL (
                      dep_urlDocumentoView);*/

               SELECT MAX (id_query)
                 INTO dep_idquery
                 FROM query, documenti docu
                WHERE     query.codiceads =
                                'SEGRETERIA.PROTOCOLLO#DOCUMENTI_'
                             || bottone.modello
                      AND docu.id_documento = query.id_documento_profilo
                      AND docu.stato_documento NOT IN ('CA', 'RE');

               -- Per i fascicoli  mettiamo solo i bottoni senza FORM perchè non esistono
               -- le maschere per iter dei fasicoli, le faremo in zk
               IF bottone.tipo_azione = 'FORM'
               THEN
                  --SC 09/02/2018 tolgo il controllo sul privilegio ASS
                  --perchè l'utente potrebbe avere diritti di assegnazione
                  --su altre unità e perchè in grails è piu' comodo non verificarlo
                  /*IF    bottone.assegnazione = 'N'
                     OR (bottone.assegnazione = 'Y' AND dep_se_assegna = 1)
                  THEN*/
                  d_amm_aoo := ag_utilities.get_default_ammaoo;

                  IF d_amm_aoo%ISOPEN
                  THEN
                     FETCH d_amm_aoo INTO d_cod_amm, d_cod_aoo;
                  END IF;

                  dep_wareaProtocollo :=
                     AG_PARAMETRO.GET_VALORE ('WKAREA_PROT_',
                                              d_cod_amm,
                                              d_cod_aoo,
                                              'Protocollo',
                                              '@agVar@');

                  SELECT ID_CARTELLA
                    INTO dep_id_wareaProtocollo
                    FROM CARTELLE
                   WHERE NOME = dep_wareaProtocollo AND ID_CARTELLA < 0;

                  dep_urlDocumentoView :=
                     REPLACE (dep_urlDocumentoView,
                              ':area',
                              'SEGRETERIA.PROTOCOLLO');
                  dep_urlDocumentoView :=
                     REPLACE (dep_urlDocumentoView,
                              ':cm',
                              bottone.modello_azione);
                  dep_urlDocumentoView :=
                     REPLACE (dep_urlDocumentoView, '&cr=:cr', '');
                  dep_urlDocumentoView :=
                        dep_urlDocumentoView
                     || '&idCartProveninez='
                     || dep_id_wareaProtocollo;
                  dep_urlDocumentoView :=
                     dep_urlDocumentoView || '&Provenienza=Q';
                  dep_urlDocumentoView :=
                        dep_urlDocumentoView
                     || '&idQueryProveninez='
                     || dep_idquery;
                  dep_urlDocumentoView :=
                        dep_urlDocumentoView
                     || '&GDC_Link=..%2Fcommon%2FClosePageAndRefresh.do%3FidQueryProveninez%3D'
                     || dep_idquery;
                  dep_urlDocumentoView := bottone.url_azione; --'../protocollo/documenti/standalone.zul';
                  --operazione=APRI_CARICO_ASSEGNA&PAR_AGSPR_UNITA=EX0&LISTA_ID=XXXX
                  /*dep_urlazione :=
                        dep_urlDocumentoView
                     || '&PAR_AGSPR_UNITA='
                     || D_UFFICIO_RICEVENTE
                     || '&PAR_AGSPR_TIPO_RICERCA=M_'
                     || bottone.modello
                     || '&LISTA_ID=XXXX';*/
                  dep_urlazione := dep_urlDocumentoView || bottone.azione;
                  IF bottone.azione NOT IN ('operazione=CARICO',
                                            'operazione=ESEGUI',
                                            'operazione=CARICO_ESEGUI')
                  THEN
                     dep_urlazione :=
                           dep_urlazione
                        || '&PAR_AGSPR_UNITA='
                        || D_UFFICIO_RICEVENTE;
                  END IF;
                  dep_urlazione :=
                           dep_urlazione|| '&LISTA_ID=XXXX';

                  dep_stmt :=
                        'begin jwf_worklist_services.aggiungi_bottone( '
                     || ''''
                     || bottone.label
                     || ''''
                     || ', '
                     || ''''
                     || bottone.tooltip
                     || ''''
                     || ', '
                     || ''''
                     || bottone.icona
                     || ''''
                     || ', '
                     || ''''
                     || bottone.tipo_azione
                     || ''''
                     || ', '
                     || ''''
                     || bottone.azione_multipla
                     || ''''
                     || ', '
                     || ''''
                     || dep_urlazione
                     || ''''
                     || ', '
                     || P_ID_RIFERIMENTO
                     || ', '
                     || 'null);'
                     || ' end;';

                  --DBMS_OUTPUT.PUT_LINE('CREA TASK ESTERNO 5.1 '||P_ID_PROTOCOLLO);
                  /*   insert into prova   (testo, data)
                     values (dep_stmt, sysdate);
                     commit;*/
                  EXECUTE IMMEDIATE dep_stmt;
               --DBMS_OUTPUT.PUT_LINE('CREA TASK ESTERNO 5.1.1');
               --END IF;
               ELSE
                  /*    010  14/09/2020 SC     Bug #27312 Attivazione bottoni in multiselezione
                                             in SmartDesktop   */
                  dep_urlazione :=
                        dep_urlserver
                     || '/'
                     || dep_contextpath
                     || '/WorklistActionServlet?XMLAZIONE=<IN><AZIONE>'
                     || bottone.azione
                     || '</AZIONE><PROPERTIES>'
                     || dep_fileIni
                     || '</PROPERTIES><UTENTE>'
                     || ':UTENTE_ESTERNO'
                     || '</UTENTE><NOMINATIVO>'
                     || ':NOMINATIVO_ESTERNO'
                     || '</NOMINATIVO><PARAMETRI>'
                     || '<PARAMETRO NOME="IDQUERYPROVENIENZA">'
                     || dep_idquery
                     || '</PARAMETRO></PARAMETRI><XXXX></XXXX></IN>';
                  dep_stmt :=
                        'begin jwf_worklist_services.aggiungi_bottone( '
                     || ''''
                     || bottone.label
                     || ''''
                     || ', '
                     || ''''
                     || bottone.tooltip
                     || ''''
                     || ', '
                     || ''''
                     || bottone.icona
                     || ''''
                     || ', '
                     || ''''
                     || bottone.tipo_azione
                     || ''''
                     || ', '
                     || ''''
                     || bottone.azione_multipla
                     || ''''
                     || ', '
                     || ''''
                     || dep_urlazione
                     || ''''
                     || ', '
                     || ''''
                     || dep_tipo_oggetto
                     || '#'
                     || P_ID_PROTOCOLLO
                     || ''''
                     || ', '
                     || '''PAR_AGSPR_UNITA='
                     || D_UFFICIO_RICEVENTE
                     || '&PAR_AGSPR_TIPO_RICERCA=M_'
                     || bottone.modello
                     || ''');'
                     || ' end;';

                  EXECUTE IMMEDIATE dep_stmt;
               END IF;
            END LOOP;
         END IF;
      --              DBMS_OUTPUT.PUT_LINE('CREA_TASK_ESTERNO 5.2 '||p_utente_esterno);
      END;

      IF d_stato_per_descrizione = 'C'
      THEN
         dep_tipologia_descrizione := dep_preso_carico;
      ELSIF d_stato_per_descrizione = 'A'
      THEN
         dep_tipologia_descrizione := dep_assegnato;
      ELSIF d_stato_per_descrizione = 'R'
      THEN
         IF p_tipo_smistamento = 'COMPETENZA'
         THEN
            dep_tipologia_descrizione := dep_prendere_carico;
         --            if f_valore_campo(P_ID_RIFERIMENTO, 'CODICE_ASSEGNATARIO') != NULL then
         --               dep_tipologia_descrizione := dep_prendere_carico_ass;
         --            else
         --
         --            end if;
         ELSE
            dep_tipologia_descrizione := dep_presa_visione;
         END IF;
      END IF;

      --http://svi-ora03:9080/agspr/WorklistAllegatiServlet?idDocumento=14387831&utente=ROMAGNOL&fileProp=/workarea/tomcat-7/webapps/jgdm/config/gd4dm.properties&tipoDoc=M
      BEGIN
         dep_url_servlet :=
            dep_url_servlet || '&fileProp=' || dep_file_ini || '&tipoDoc=';

         IF AG_UTILITIES.VERIFICA_CATEGORIA_DOCUMENTO (P_ID_PROTOCOLLO,
                                                       'PROTO') = 1
         THEN
            dep_url_servlet := dep_url_servlet || 'P';
         ELSIF AG_UTILITIES.VERIFICA_CATEGORIA_DOCUMENTO (
                  P_ID_PROTOCOLLO,
                  'POSTA_ELETTRONICA') = 1
         THEN
            dep_url_servlet := dep_url_servlet || 'M';
         ELSE
            dep_url_servlet := dep_url_servlet || 'D';
         END IF;
      END;

      dep_stmt :=
            'BEGIN '
         || ' :ID := jwf_worklist_services.CREA_ATTIVITA ( '
         || ' P_ID_RIFERIMENTO => '
         || p_id_riferimento
         || ', P_ATTIVITA_DESCRIZIONE => '
         || ''''
         || REPLACE (SUBSTR (p_attivita_descrizione, 1, 4000), '''', '''''')
         || ''''
         || ', P_TOOLTIP_ATTIVITA_DESCR => '
         || ''''
         || REPLACE (SUBSTR (p_tooltip_attivita_descr, 1, 4000),
                     '''',
                     '''''')
         || ''''
         || ', P_URL_RIF => '
         || ''''
         || dep_url_rif
         || ''''
         || ', P_URL_RIF_DESC => '
         || ''''
         || REPLACE (SUBSTR (p_url_rif_desc, 1, 4000), '''', '''''')
         || ''''
         || ', P_URL_EXEC => '
         || ''''
         || dep_url_exec
         || ''''
         || ', P_TOOLTIP_URL_EXEC => '
         || ''''
         || REPLACE (SUBSTR (p_tooltip_url_exec, 1, 4000), '''', '''''')
         || ''''
         || ', P_SCADENZA => '
         || 'to_date('''
         || TO_CHAR (p_data_scad, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')'
         || ', P_PARAM_INIT_ITER => '
         || ''''
         || REPLACE (p_param_init_iter, '''', '''''')
         || ''''
         || ', P_NOME_ITER => '
         || ''''
         || p_nome_iter
         || ''''
         || ', P_DESCRIZIONE_ITER => '
         || ''''
         || REPLACE (p_descrizione_iter, '''', '''''')
         || ''''
         || ', P_COLORE => '
         || ''''
         || p_colore
         || ''''
         || ', P_ORDINAMENTO => '
         || ''''
         || REPLACE (p_ordinamento, '''', '''''')
         || ''''
         || ', P_DATA_ATTIVAZIONE => '
         || 'SYSDATE'
         || ', P_UTENTE_ESTERNO => '
         || ''''
         || p_utente_esterno
         || ''''
         || ', P_CATEGORIA => '
         || ''''
         || p_categoria
         || ''''
         || ', P_DESKTOP => '
         || ''''
         || p_desktop
         || ''''
         || ', P_STATO => '
         || ''''
         || NVL (p_stato, p_stato_per_attivita)
         || ''''
         || ', P_TIPOLOGIA => '
         || ''''
         || p_tipologia
         || ''''
         || ', P_DATI_APPLICATIVI_1 => '
         || ''''
         || REPLACE (SUBSTR (p_datiapplicativi1, 1, 1024), '''', '''''')
         || ''''
         || ', P_DATI_APPLICATIVI_2 => '
         || ''''
         || NVL (REPLACE (p_datiapplicativi2, '''', ''''''),
                 TO_CHAR (p_datasmist, 'dd/mm/yyyy HH24:mi:ss'))
         || ''''
         || ', P_DATI_APPLICATIVI_3 => '
         || ''''
         || REPLACE (p_datiapplicativi3, '''', '''''')
         || ''''
         || ', P_ESPRESSIONE => '
         || '''FORM'''
         || ', P_MESSAGGIO_TODO => null'
         || ', P_DATA_ARRIVO => '
         || 'to_date('''
         || TO_CHAR (SYSDATE, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')'
         || ', P_LIVELLO_PRIORITA => null'
         || ', P_NOTE => null'
         || ', P_APPLICATIVO => null '
         --|| '''Protocollo'''
         || ', P_ENTE => '
         || ''''
         || REPLACE (dep_ente, '''', '''''')
         || ''''
         || ', P_TIPOLOGIA_DESCR => '''
         || dep_tipologia_descrizione
         || ''''
         || ', P_ORDINA_STRINGA_ETICHETTA => '
         || '''Ordinamento smistamenti'''
         || ', P_ORDINA_STRINGA_VALORE => '
         || ''''
         || REPLACE (SUBSTR (p_datiapplicativi1, 1, 500), '''', '''''')
         || ''''
         || ', P_ORDINA_DATA_ETICHETTA => ''Data smistamento'''
         || ', P_ORDINA_DATA_VALORE => '
         || 'to_date('''
         || TO_CHAR (p_datasmist, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')'
         || ', P_ORDINA_NUMERO_ETICHETTA => null'
         || ', P_ORDINA_NUMERO_VALORE => null'
         || ', P_URL_ALLEGATI_DINAMICI => '''
         || dep_url_servlet
         || ''''
         || ');'
         || 'END;';

      /*      insert into prova   (testo, data)
            values (dep_stmt, sysdate);
            commit;*/

      EXECUTE IMMEDIATE dep_stmt USING OUT d_id_attivita;

      RETURN d_id_attivita;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('CREA_TASK_ESTERNO_NEW ' || SQLERRM);
   END;

   /******************************************************************************
    NOME:         CREA_TASK_ESTERNO
    DESCRIZIONE:  Creazione di un task esterno.
    RITORNA:      La funzione restituisce ID_ATTIVITA inserita utile per
                  effettuare un eventuale operazione di aggiornamento e di
                  eliminazione sui task esterni.
    NOTE:      --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
    001  17/01/2011 MM     A47434.0.0: Ordinamento scrivania: vengono elencati
                           prima i documenti smistati senza wf e poi quelli
                           con wf indipendentemente da stato e anno/numero.
    002  27/01/2011 MM     Gestione del caso in cui non sia previsto l'iter dei
                           documenti (parametro ITER_DOCUMENTI_n = N).
   ******************************************************************************/
   FUNCTION crea_task_esterno (
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_utente_esterno               VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      d_attivita_descrizione     VARCHAR2 (32000);
      d_tooltip_attivita_descr   VARCHAR2 (32000);
      d_param_init_iter          VARCHAR2 (4000)
         := NVL (p_param_init_iter, 'ATTIVA_ITER_DOCUMENTALE');
      d_nome_iter                VARCHAR2 (100) := NULL;
      d_descrizione_iter         VARCHAR2 (2000) := NULL;
      d_data_scad                DATE;
      d_colore                   VARCHAR2 (15) := NULL;
      d_ordinamento              VARCHAR2 (1) := NULL;
      -- A47434.0.0: modificato da '1' a null
      d_categoria                VARCHAR2 (10) := NULL;
      d_desktop                  VARCHAR2 (10) := NULL;
      d_stato_per_attivita       VARCHAR2 (100);
      d_stato_per_descrizione    VARCHAR2 (100);
      d_id_attivita              NUMBER;
      d_utentesmis               VARCHAR2 (256);
      d_datasmist                DATE;
      d_tiposmist                seg_smistamenti.tipo_smistamento%TYPE;
      d_vardescr                 VARCHAR2 (100);
      d_descr                    VARCHAR2 (32000);
      iddocumento                NUMBER;
      d_pec                      VARCHAR2 (3);
      d_modalita                 VARCHAR2 (50);
      d_des_uff_trasmissione     seg_smistamenti.des_ufficio_trasmissione%TYPE;
      d_ufficio_ricevente        seg_smistamenti.ufficio_smistamento%TYPE;
   BEGIN
      DBMS_OUTPUT.put_line ('crea_task_esterno 1');

      -- Rev. 002 27/01/2011 MM: Parametro ITER_DOCUMENTI_n = N, quindi non deve
      -- essere creata l'attivita' in scrivania.
      IF    (    p_tipologia = 'ATTIVA_ITER_DOCUMENTALE'
             AND ag_parametro.get_valore ('ITER_DOCUMENTI',
                                          p_codice_amm,
                                          p_codice_aoo,
                                          'Y') = 'Y')
         OR (    p_tipologia = 'ATTIVA_ITER_FASCICOLARE'
             AND ag_parametro.get_valore ('ITER_FASCICOLI',
                                          p_codice_amm,
                                          p_codice_aoo,
                                          'Y') = 'Y')
      THEN
         DBMS_OUTPUT.put_line ('crea_task_esterno 2');

         -- Rev. 002 27/01/2011 MM: fine mod.
         BEGIN
            DBMS_OUTPUT.PUT_LINE ('CREA_TASK_ESTERNO 1');

            SELECT DECODE (NVL (codice_assegnatario, ' '),
                           ' ', stato_smistamento,
                           'A'),
                   DECODE (
                      stato_smistamento,
                      'R', 'R',
                      DECODE (NVL (codice_assegnatario, ' '),
                              ' ', stato_smistamento,
                              'A')),
                     SYSDATE
                   + ag_parametro.get_valore (
                        DECODE (stato_smistamento,
                                'C', 'SMIST_C_TIMEOUT_',
                                'R', 'SMIST_R_TIMEOUT_'),
                        p_codice_amm,
                        p_codice_aoo,
                        90),
                   DECODE (stato_smistamento,
                           'R', smistamento_dal,
                           NVL (assegnazione_dal, presa_in_carico_dal)),
                   NVL (codice_assegnatario, presa_in_carico_utente),
                   tipo_smistamento,
                   DECODE (p_codice_modello_docpadre,
                           'M_PROTOCOLLO_INTEROPERABILITA', 'PEC',
                           ''),
                   ufficio_smistamento,
                   des_ufficio_trasmissione
              INTO d_stato_per_attivita,
                   d_stato_per_descrizione,
                   d_data_scad,
                   d_datasmist,
                   d_utentesmis,
                   d_tiposmist,
                   d_pec,
                   d_ufficio_ricevente,
                   d_des_uff_trasmissione
              FROM seg_smistamenti
             WHERE id_documento = p_id_riferimento;

            DBMS_OUTPUT.PUT_LINE ('CREA_TASK_ESTERNO 2');
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
         END;

         DBMS_OUTPUT.PUT_LINE ('p_area_docpadre ' || p_area_docpadre);
         DBMS_OUTPUT.PUT_LINE (
            'p_codice_modello_docpadre ' || p_codice_modello_docpadre);
         DBMS_OUTPUT.PUT_LINE (
            'p_codice_richiesta_docpadre ' || p_codice_richiesta_docpadre);

         iddocumento :=
            ag_utilities.get_id_documento (p_area_docpadre,
                                           p_codice_modello_docpadre,
                                           p_codice_richiesta_docpadre);

         --  DBMS_OUTPUT.PUT_LINE('CREA_TASK_ESTERNO 3 '||iddocumento);
         IF p_tipologia = 'ATTIVA_ITER_DOCUMENTALE'
         THEN
            IF ag_utilities.verifica_categoria_documento (iddocumento,
                                                          'PROTO') = 1
            THEN
               d_attivita_descrizione :=
                  get_descrizione_attivita_proto (iddocumento,
                                                  d_stato_per_descrizione,
                                                  d_tiposmist,
                                                  p_codice_amm,
                                                  p_codice_aoo,
                                                  d_pec,
                                                  p_tooltip_url_exec);
            --            DBMS_OUTPUT.PUT_LINE('CREA_TASK_ESTERNO 4');
            ELSIF ag_utilities.verifica_categoria_documento (
                     iddocumento,
                     'POSTA_ELETTRONICA') = 1
            THEN
               d_attivita_descrizione :=
                  get_descrizione_attivita_memo (iddocumento,
                                                 d_stato_per_descrizione,
                                                 d_tiposmist,
                                                 p_codice_amm,
                                                 p_codice_aoo,
                                                 d_pec,
                                                 p_tooltip_url_exec);
            --   DBMS_OUTPUT.PUT_LINE('CREA_TASK_ESTERNO 4.1');
            ELSIF ag_utilities.verifica_categoria_documento (
                     iddocumento,
                     'CLASSIFICABILE') = 1
            THEN
               --       DBMS_OUTPUT.PUT_LINE('CREA_TASK_ESTERNO 4.2 '||d_attivita_descrizione);
               d_attivita_descrizione :=
                  get_descrizione_attivita_np (iddocumento,
                                               d_stato_per_descrizione,
                                               d_tiposmist,
                                               p_codice_amm,
                                               p_codice_aoo,
                                               d_pec,
                                               p_tooltip_url_exec);
            ELSE
               d_attivita_descrizione := p_tooltip_url_exec;
            END IF;
         ELSE
            d_attivita_descrizione :=
               get_descrizione_attivita_fasc (iddocumento,
                                              d_stato_per_descrizione,
                                              d_tiposmist,
                                              p_codice_amm,
                                              p_codice_aoo,
                                              p_tooltip_url_exec);
         END IF;

         --DBMS_OUTPUT.PUT_LINE('CREA_TASK_ESTERNO 5 '||p_utente_esterno);
         d_tooltip_attivita_descr := p_tooltip_url_exec;
         DBMS_OUTPUT.put_line ('crea_task_esterno 3');

         IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
         THEN
            DBMS_OUTPUT.PUT_LINE ('iddocumento ' || iddocumento);
            D_ID_ATTIVITA :=
               crea_task_esterno_new (P_ID_RIFERIMENTO,
                                      D_ATTIVITA_DESCRIZIONE,
                                      D_TOOLTIP_ATTIVITA_DESCR,
                                      P_URL_RIF,
                                      P_URL_RIF_DESC,
                                      P_URL_EXEC,
                                      P_TOOLTIP_URL_EXEC,
                                      D_DATA_SCAD,
                                      D_PARAM_INIT_ITER,
                                      D_NOME_ITER,
                                      D_DESCRIZIONE_ITER,
                                      D_COLORE,
                                      D_ORDINAMENTO,
                                      P_UTENTE_ESTERNO,
                                      D_CATEGORIA,
                                      D_DESKTOP,
                                      P_STATO,
                                      D_STATO_PER_ATTIVITA,
                                      D_STATO_PER_DESCRIZIONE,
                                      D_UFFICIO_RICEVENTE,
                                      P_TIPOLOGIA,
                                      P_DATIAPPLICATIVI1,
                                      P_DATIAPPLICATIVI2,
                                      D_DATASMIST,
                                      P_DATIAPPLICATIVI3,
                                      iddocumento,
                                      d_tiposmist,
                                      d_des_uff_trasmissione);
         ELSE
            DBMS_OUTPUT.put_line ('crea_task_esterno 4');
            D_ID_ATTIVITA :=
               crea_task_esterno_old (P_ID_RIFERIMENTO,
                                      D_ATTIVITA_DESCRIZIONE,
                                      D_TOOLTIP_ATTIVITA_DESCR,
                                      P_URL_RIF,
                                      P_URL_RIF_DESC,
                                      P_URL_EXEC,
                                      P_TOOLTIP_URL_EXEC,
                                      D_DATA_SCAD,
                                      D_PARAM_INIT_ITER,
                                      D_NOME_ITER,
                                      D_DESCRIZIONE_ITER,
                                      D_COLORE,
                                      D_ORDINAMENTO,
                                      P_UTENTE_ESTERNO,
                                      D_CATEGORIA,
                                      D_DESKTOP,
                                      P_STATO,
                                      D_STATO_PER_ATTIVITA,
                                      P_TIPOLOGIA,
                                      P_DATIAPPLICATIVI1,
                                      P_DATIAPPLICATIVI2,
                                      D_DATASMIST,
                                      P_DATIAPPLICATIVI3);
         END IF;
      END IF;

      RETURN d_id_attivita;
   END;

   /******************************************************************************
    NOME:        DELETE_TASK_ESTERNI
    DESCRIZIONE: Cancella un task esterno mediante id_riferimento del task ed
                 esegue il commit o il rollback se viene generato un errore.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
         27/11/2017 SC     Aggiunto utente
    009  01/06/2018 SC     Spostate le delete_task_esterni in ag_utilities_cruscotto
   ******************************************************************************/
   PROCEDURE delete_task_esterni_commit (p_id_riferimento    VARCHAR2,
                                         p_utente            VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      ag_utilities_cruscotto.delete_task_esterni_commit (
         p_id_riferimento   => p_id_riferimento,
         p_utente           => p_utente);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   /******************************************************************************
    NOME:        DELETE_TASK_ESTERNI
    DESCRIZIONE: Cancella un task esterno mediante id_riferimento del task ed
                 esegue il commit o il rollback se viene generato un errore.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
    009  01/06/2018 SC     Spostate le delete_task_esterni in ag_utilities_cruscotto
   ******************************************************************************/
   PROCEDURE delete_task_esterni_commit (p_id_riferimento VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      ag_utilities_cruscotto.delete_task_esterni_commit (
         p_id_riferimento   => p_id_riferimento,
         p_utente           => NULL);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   /******************************************************************************
    NOME:        DELETE_TASK_ESTERNI
    DESCRIZIONE: Cancella un task esterno mediante id_riferimento del task.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
         27/11/2017 SC     Eliminazione con worklist_service, parametro utente
    009  01/06/2018 SC     Spostate le delete_task_esterni in ag_utilities_cruscotto
   ******************************************************************************/
   PROCEDURE delete_task_esterni (p_id_riferimento    VARCHAR2,
                                  p_utente            VARCHAR2)
   IS
   --dep_stmt   VARCHAR2 (32000);
   BEGIN
      ag_utilities_cruscotto.delete_task_esterni (
         p_id_riferimento   => p_id_riferimento,
         p_utente           => p_utente);
   --      IF (p_utente IS NULL)
   --      THEN
   --         delete_task_esterni (p_id_riferimento);
   --      ELSE
   --         IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
   --         THEN
   --            dep_stmt :=
   --                  'begin JWF_WORKLIST_SERVICES.ELIMINA_ATTIVITA('
   --               || '  P_ID_RIFERIMENTO => '''
   --               || p_id_riferimento
   --               || ''''
   --               || ', P_UTENTE => '''
   --               || p_utente
   --               || '''); end;';
   --            DBMS_OUTPUT.PUT_LINE (dep_stmt);
   --
   --            EXECUTE IMMEDIATE dep_stmt;
   --         ELSE
   --            jwf_utility.p_elimina_task_esterno (NULL, p_id_riferimento, NULL);
   --         END IF;
   --      END IF;
   END;


   /******************************************************************************
    NOME:        DELETE_TASK_ESTERNI
    DESCRIZIONE: Cancella un task esterno mediante id_riferimento del task.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
    009  01/06/2018 SC     Spostate le delete_task_esterni in ag_utilities_cruscotto
   ******************************************************************************/
   PROCEDURE delete_task_esterni (p_id_riferimento VARCHAR2)
   IS
   BEGIN
      ag_utilities_cruscotto.delete_task_esterni (
         p_id_riferimento   => p_id_riferimento,
         p_utente           => NULL);
   END;

   /******************************************************************************
    NOME:        INVIA_MAIL_SMISTAMENTO
    DESCRIZIONE: Invia una mail a seguito
                 dello smistamento se
                 - lo smistamento è per competenza
                 e se
                 - se esiste uno smistamento con mail e sequenza per la stessa
                   unità associato al tipo documento
                 oppure, in seconda battuta
                 - se l'unità ha indirizzo MANUALE


    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  27/09/2017 SC     Creazione.
   ******************************************************************************/
   PROCEDURE invia_mail_smistamento (p_id_smistamento       NUMBER,
                                     p_stato_smistamento    VARCHAR2)
   IS
      d_progr_unita              NUMBER;
      d_codice_unita             VARCHAR2 (100);
      d_des_unita                VARCHAR2 (32000);
      d_stato                    VARCHAR2 (100);
      d_ottica                   VARCHAR2 (100);
      d_amministrazione          VARCHAR2 (100);
      d_idrif                    VARCHAR2 (100);
      d_tipo_documento           VARCHAR2 (100);
      d_sequenza                 NUMBER;
      d_ret                      NUMBER;
      d_indirizzo                VARCHAR2 (1000);
      d_utente                   VARCHAR2 (100);
      d_codice_amministrazione   VARCHAR2 (100);
      d_codice_aoo               VARCHAR2 (100);
      d_oggetto                  VARCHAR2 (100);
      d_testo                    VARCHAR2 (32000);
      d_id_tipodoc               NUMBER;
      d_id_documento             NUMBER;
      d_des_documento            VARCHAR2 (32000);
      d_mittente                 VARCHAR2 (1000);
      d_tag_invio                VARCHAR2 (100);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      d_mittente :=
         ag_parametro.get_valore ('MITTENTE_INVIO_MAIL', '@agStrut@');
      d_tag_invio := ag_parametro.get_valore ('TAG_INVIO_MAIL', '@agStrut@');

      IF d_mittente IS NOT NULL AND d_tag_invio IS NOT NULL
      THEN
         BEGIN
            SELECT idrif,
                   ufficio_smistamento,
                   codice_amministrazione,
                   codice_aoo,
                   utente_trasmissione,
                   des_ufficio_smistamento,
                   DECODE (p_stato_smistamento,
                           'R', ' da ricevere per ',
                           ' in carico a ')
              INTO d_idrif,
                   d_codice_unita,
                   d_codice_amministrazione,
                   d_codice_aoo,
                   d_utente,
                   d_des_unita,
                   d_stato
              FROM seg_smistamenti
             WHERE     id_documento = p_id_smistamento
                   AND tipo_smistamento = 'COMPETENZA';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_idrif := NULL;
         END;

         DBMS_OUTPUT.put_line ('d_idrif ' || d_idrif);

         BEGIN
            SELECT NVL (tipo_documento, '***'),
                   documenti.id_tipodoc,
                   smistabile_view.id_documento
              INTO d_tipo_documento, d_id_tipodoc, d_id_documento
              FROM smistabile_view, documenti
             WHERE     idrif = d_idrif
                   AND documenti.id_documento = smistabile_view.id_documento
            UNION
            SELECT '***', documenti.id_tipodoc, seg_fascicoli.id_documento
              FROM seg_fascicoli, documenti
             WHERE     idrif = d_idrif
                   AND documenti.id_documento = seg_fascicoli.id_documento;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         DBMS_OUTPUT.put_line ('d_tipo_documento ' || d_tipo_documento);

         BEGIN
            SELECT email
              INTO d_indirizzo
              FROM seg_smistamenti_tipi_documento
             WHERE     tipo_documento = d_tipo_documento
                   AND ufficio_smistamento = d_codice_unita
                   AND email IS NOT NULL
                   AND tipo_smistamento = 'COMPETENZA'
                   AND sequenza IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_progr_unita :=
                  so4_util.anuo_get_progr (
                     ag_utilities.get_ottica_utente (
                        d_utente,
                        d_codice_amministrazione,
                        d_codice_aoo),
                     d_codice_amministrazione,
                     d_codice_unita,
                     TRUNC (SYSDATE));

               d_indirizzo :=
                  so4_indirizzo_telematico.get_indirizzo ('UO',
                                                          'M',
                                                          NULL,
                                                          NULL,
                                                          d_progr_unita);
         END;

         DBMS_OUTPUT.put_line ('d_indirizzo ' || d_indirizzo);

         IF NVL (d_indirizzo, '*') <> '*'
         THEN
            IF AG_UTILITIES.is_protocollo (d_id_tipodoc) = 1
            THEN
               d_oggetto := 'PG ' || d_stato || ' unita ' || d_des_unita;

               SELECT anno || '/' || numero || ' ' || oggetto
                 INTO d_des_documento
                 FROM proto_view
                WHERE id_documento = d_id_documento;

               d_testo :=
                     'Il PG '
                  || d_des_documento
                  || ' è '
                  || d_stato
                  || ' unita '
                  || d_des_unita;
            ELSIF AG_UTILITIES.is_fascicolo (d_id_documento) = 1
            THEN
               d_oggetto :=
                  'Fascicolo ' || d_stato || ' unita ' || d_des_unita;

               SELECT    fascicolo_anno
                      || '/'
                      || fascicolo_numero
                      || ' '
                      || fascicolo_oggetto
                 INTO d_des_documento
                 FROM seg_fascicoli
                WHERE id_documento = d_id_documento;

               d_testo :=
                     'Il Fascicolo '
                  || d_des_documento
                  || ' è '
                  || d_stato
                  || ' unita '
                  || d_des_unita;
            ELSE
               d_oggetto :=
                  'Documento ' || d_stato || ' unita ' || d_des_unita;

               SELECT    DECODE (
                            data,
                            NULL, '',
                            'del ' || TO_CHAR (data, 'dd/mm/yyyy') || ' ')
                      || oggetto
                 INTO d_des_documento
                 FROM classificabile_view
                WHERE id_documento = d_id_documento;

               d_testo :=
                     'Il Documento '
                  || d_des_documento
                  || ' è '
                  || d_stato
                  || ' unita '
                  || d_des_unita;
            END IF;

            DBMS_OUTPUT.put_line ('d_oggetto ' || d_oggetto);

            BEGIN
               d_ret :=
                  amvweb.send_msg (d_mittente,
                                   d_indirizzo,
                                   d_oggetto,
                                   d_testo,
                                   d_tag_invio);
               DBMS_OUTPUT.put_line ('d_ret ' || d_ret);
               COMMIT;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RAISE;
            END;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END invia_mail_smistamento;


   /******************************************************************************
    NOME:        CHIUDI_ITER_SCRIVANIA
    DESCRIZIONE: Chiude iter specificato.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
   ******************************************************************************/
   PROCEDURE chiudi_iter_scrivania (p_area                VARCHAR2,
                                    p_codice_modello      VARCHAR2,
                                    p_codice_richiesta    VARCHAR2)
   IS
      retval   NUMBER;
   BEGIN
      retval :=
         jwf_utility.chiudi_iter_where (
               'where codice=''$DOCMASTER'' and valore='''
            || p_area
            || '@'
            || p_codice_modello
            || '@'
            || p_codice_richiesta
            || ''' AND '
            || ' exists (select 1 from valori v where v.id_iter=valori.id_iter and  codice=''NOMEIT'' '
            || ' and valore=''ATTIVA_ITER_SCRIVANIA_SMISTAMENTI'') ',
            0);
   END;

   /******************************************************************************
    NOME:        GEST_SMIST_MANUALI_SCADUTI
    DESCRIZIONE: Gestione degli smistamenti scaduti.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
   ******************************************************************************/
   PROCEDURE gest_smist_manuali_scaduti
   IS
      c_defammaoo        afc.t_ref_cursor;
      p_aoo              VARCHAR2 (100);
      p_amm              VARCHAR2 (100);
      p_datanotifica     VARCHAR2 (10);
      p_devonotificare   NUMBER (5);
      p_ggnotificascad   NUMBER (5);
      p_indiceaoo        NUMBER;
      retval             NUMBER;

      CURSOR c_listasmistamenti (
         r_timeout      NUMBER,
         c_timeout      NUMBER,
         p_indiceaoo    NUMBER)
      IS
         SELECT seg_smistamenti.id_documento idsmistamento,
                spr_protocolli.id_documento idprotocollo,
                key_iter_smistamento,
                ufficio_trasmissione,
                documenti.area,
                tipi_documento.nome cm,
                documenti.codice_richiesta,
                seg_smistamenti.stato_smistamento
           FROM seg_smistamenti,
                documenti,
                smistabile_view spr_protocolli,
                tipi_documento
          WHERE     stato_smistamento IN ('C', 'R')
                AND NVL (key_iter_smistamento, -1) = -1
                AND tipo_smistamento IN ('COMPETENZA', 'CONOSCENZA')
                AND documenti.id_documento = seg_smistamenti.id_documento
                AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA', 'RE')
                AND DECODE (
                       stato_smistamento,
                       'R',   TRUNC (SYSDATE)
                            - (TRUNC (smistamento_dal) + r_timeout),
                       'C',   TRUNC (SYSDATE)
                            - (TRUNC (presa_in_carico_dal) + c_timeout)) >= 0
                AND spr_protocolli.idrif = seg_smistamenti.idrif
                AND 0 =
                       (SELECT COUNT (*)
                          FROM ag_smistamenti_scaduti
                         WHERE     ag_smistamenti_scaduti.id_smistamento =
                                      seg_smistamenti.id_documento
                               AND indice_aoo = p_indiceaoo)
                AND documenti.id_tipodoc = tipi_documento.id_tipodoc
         UNION
         SELECT seg_smistamenti.id_documento idsmistamento,
                seg_fascicoli.id_documento idfascicolo,
                key_iter_smistamento,
                ufficio_trasmissione,
                documenti.area,
                tipi_documento.nome cm,
                documenti.codice_richiesta,
                seg_smistamenti.stato_smistamento
           FROM seg_smistamenti,
                documenti,
                seg_fascicoli,
                tipi_documento
          WHERE     stato_smistamento IN ('C', 'R')
                AND NVL (key_iter_smistamento, -1) = -1
                AND tipo_smistamento IN ('COMPETENZA', 'CONOSCENZA')
                AND documenti.id_documento = seg_smistamenti.id_documento
                AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA', 'RE')
                AND DECODE (
                       stato_smistamento,
                       'R',   TRUNC (SYSDATE)
                            - (TRUNC (smistamento_dal) + r_timeout),
                       'C',   TRUNC (SYSDATE)
                            - (TRUNC (presa_in_carico_dal) + c_timeout)) >= 0
                AND seg_fascicoli.idrif = seg_smistamenti.idrif
                AND 0 =
                       (SELECT COUNT (*)
                          FROM ag_smistamenti_scaduti
                         WHERE     ag_smistamenti_scaduti.id_smistamento =
                                      seg_smistamenti.id_documento
                               AND indice_aoo = p_indiceaoo)
                AND documenti.id_tipodoc = tipi_documento.id_tipodoc;
   BEGIN
      --dbms_output.put_line('aaa');
      c_defammaoo := ag_utilities.get_default_ammaoo ();

      IF c_defammaoo%ISOPEN
      THEN
         LOOP
            FETCH c_defammaoo INTO p_amm, p_aoo;

            EXIT WHEN c_defammaoo%NOTFOUND;
         END LOOP;
      END IF;

      IF NVL (p_amm, '') = '' OR NVL (p_aoo, '') = ''
      THEN
         raise_application_error (
            -20999,
            'Non riesco a valorizzare codAmm e/o codAoo di default');
      END IF;

      IF ag_parametro.get_valore ('NOTIFICA_SCAD_',
                                  p_amm,
                                  p_aoo,
                                  'N') = 'Y'
      THEN
         p_ggnotificascad :=
            TO_NUMBER (ag_parametro.get_valore ('GG_NOTIFICA_SCAD_',
                                                p_amm,
                                                p_aoo,
                                                '0'));

         IF p_ggnotificascad > 0
         THEN
            --Mi calcolo se devo notificare
            SELECT NVL (SYSDATE - (MAX (data_notifica) + p_ggnotificascad),
                        1)
              INTO p_devonotificare
              FROM ag_smistamenti_scaduti
             WHERE stato_notifica = 'Y';

            IF p_devonotificare >= 0
            THEN
               SELECT TO_CHAR (SYSDATE, 'DD/MM/YYYY')
                 INTO p_datanotifica
                 FROM DUAL;

               p_indiceaoo := ag_utilities.get_indice_aoo (p_amm, p_aoo);

               FOR clistasmistamenti IN c_listasmistamenti (ag_parametro.get_valore (
                                                               'SMIST_R_TIMEOUT_',
                                                               p_amm,
                                                               p_aoo,
                                                               'N'),
                                                            ag_parametro.get_valore (
                                                               'SMIST_C_TIMEOUT_',
                                                               p_amm,
                                                               p_aoo,
                                                               'N'),
                                                            p_indiceaoo)
               LOOP
                  --dbms_output.put_line('idSmistamento-->'||clistaSmistamenti.idSmistamento);
                  BEGIN
                     BEGIN
                        --Storicizzo lo smistamento
                        UPDATE seg_smistamenti
                           SET stato_smistamento =
                                  DECODE (stato_smistamento,
                                          'R', 'F',
                                          'C', 'E'),
                               note =
                                     DECODE (NVL (note, ' '),
                                             ' ', '',
                                             note || ' ')
                                  || 'Smistamento sbloccato automaticamente per raggiunti termini di scadenza in data '
                                  || p_datanotifica
                         WHERE id_documento = clistasmistamenti.idsmistamento;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           raise_application_error (
                              -20999,
                                 'Errore in storicizzazione smistamento con id = '
                              || clistasmistamenti.idsmistamento
                              || '.Errore: '
                              || SQLERRM);
                     END;

                     BEGIN
                        --Inserisco negli smistamenti scaduti
                        INSERT INTO ag_smistamenti_scaduti (id_iter,
                                                            id_smistamento,
                                                            id_protocollo,
                                                            stato_notifica,
                                                            data_notifica,
                                                            indice_aoo)
                           SELECT NVL (
                                     clistasmistamenti.key_iter_smistamento,
                                     -1),
                                  clistasmistamenti.idsmistamento,
                                  clistasmistamenti.idprotocollo,
                                  DECODE (
                                     clistasmistamenti.stato_smistamento,
                                     'C', 'C',
                                     'N'),
                                  TO_DATE (p_datanotifica, 'DD/MM/YYYY'),
                                  ag_utilities.get_indice_aoo (p_amm, p_aoo)
                             FROM DUAL;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           raise_application_error (
                              -20999,
                                 'Errore inserimento in AG_SMISTAMENTI_SCADUTI dello smistamento con id = '
                              || clistasmistamenti.idsmistamento
                              || '.Errore: '
                              || SQLERRM);
                     END;

                     BEGIN
                        IF clistasmistamenti.key_iter_smistamento = -1
                        THEN
                           delete_task_esterni (
                              clistasmistamenti.idsmistamento);
                        ELSE
                           CHIUDI_ITER_SCRIVANIA (
                              clistaSmistamenti.area,
                              clistaSmistamenti.cm,
                              clistaSmistamenti.codice_richiesta);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           raise_application_error (
                              -20999,
                                 'Errore chiusura TASK ITER SCRIVANIA relativi allo smistamento con id = '
                              || clistasmistamenti.idsmistamento
                              || '.Errore: '
                              || SQLERRM);
                     END;

                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                        ag_utilities_protocollo.crea_log (SQLERRM);
                  END;
               END LOOP;
            END IF;
         END IF;
      END IF;
   END;

   PROCEDURE invia_fasc_a_unita (p_id_documento                 NUMBER,
                                 p_id_cartella                  NUMBER,
                                 p_utente                       VARCHAR2,
                                 p_unita_tras                   VARCHAR2,
                                 p_unita_ric                    VARCHAR2,
                                 p_storicizza_assegnati         VARCHAR2,
                                 p_codice_amministrazione       VARCHAR2,
                                 p_codice_aoo                   VARCHAR2,
                                 p_des_unita_tras               VARCHAR2,
                                 p_des_unita_ric                VARCHAR2,
                                 p_messaggio                OUT VARCHAR2,
                                 p_errore                   OUT NUMBER)
   IS
      dep_is_smistabile            NUMBER;
      dep_idrif                    spr_protocolli.idrif%TYPE;
      dep_is_unita_chiusa          NUMBER;
      dep_tipo_smistamento         ag_tipi_smistamento.tipo_smistamento%TYPE;
      dep_importanza               ag_tipi_smistamento.importanza%TYPE;
      dep_id_nuovo_smistamento     NUMBER;
      dep_stato_smistamento        seg_smistamenti.stato_smistamento%TYPE;
      dep_data                     DATE;
      dep_attivita_help            jwf_task_esterni.attivita_help%TYPE;
      dep_attivita_descr           jwf_task_esterni.attivita_descr%TYPE;
      dep_anno                     spr_protocolli.anno%TYPE;
      dep_numero                   spr_protocolli.numero%TYPE;
      dep_oggetto                  spr_protocolli.oggetto%TYPE;
      dep_url_rif                  jwf_task_esterni.url_rif%TYPE;
      dep_url_rif_desc             jwf_task_esterni.url_rif_desc%TYPE;
      dep_url_exec                 jwf_task_esterni.url_exec%TYPE;
      dep_nome_iter                parametri.valore%TYPE;
      dep_area                     documenti.area%TYPE;
      dep_codice_modello           tipi_documento.nome%TYPE;
      dep_codice_richiesta         documenti.codice_richiesta%TYPE;
      dep_dati_applicativi         jwf_task_esterni.dati_applicativi_1%TYPE;
      dep_attivita                 VARCHAR2 (32000);
      dep_codice_richiesta_smi     documenti.codice_richiesta%TYPE;
      dep_crea_nuovo_smistamento   NUMBER := 1;
      dep_azione                   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT 0
           INTO dep_is_unita_chiusa
           FROM seg_unita
          WHERE     codice_amministrazione = p_codice_amministrazione
                AND codice_aoo = p_codice_aoo
                AND unita = p_unita_tras
                AND al IS NULL;

         dep_azione := 'SMISTA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            dep_is_unita_chiusa := 1;
            dep_azione := 'INOLTRA';
      END;

      -- VERIFICA SE L'UTENTE PUO' SMISTARE IL DOCUMENTO
      dep_is_smistabile :=
         ag_competenze_fascicolo.abilita_azione_smistamento (p_id_documento,
                                                             p_utente,
                                                             dep_azione);

      IF dep_is_smistabile = 0
      THEN
         p_messaggio := 'non smistabile';
         p_errore := 1;
         RETURN;
      END IF;

      SELECT idrif
        INTO dep_idrif
        FROM seg_fascicoli
       WHERE id_documento = p_id_documento;

      DECLARE
         dep_smistamento_esistente   NUMBER := 0;
      BEGIN
         SELECT COUNT (*)
           INTO dep_smistamento_esistente
           FROM seg_smistamenti, documenti
          WHERE     seg_smistamenti.id_documento = documenti.id_documento
                AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND stato_smistamento NOT IN ('N', 'F')
                AND ufficio_trasmissione = p_unita_tras
                AND ufficio_smistamento = p_unita_ric
                AND idrif = dep_idrif;

         IF dep_smistamento_esistente > 0
         THEN
            IF dep_is_unita_chiusa = 0
            THEN
               p_messaggio :=
                     ' è già presente uno smistamento all''unità '
                  || p_des_unita_ric
                  || '.';
               p_errore := 1;
               RETURN;
            ELSE
               p_messaggio :=
                  ' smistamento a ' || p_des_unita_ric || ' già presente.';
               dep_crea_nuovo_smistamento := 0;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF dep_crea_nuovo_smistamento > 0
      THEN
         FOR ts
            IN (SELECT DISTINCT
                       absm.tipo_smistamento_generabile,
                       tism.importanza,
                       DECODE (dep_is_unita_chiusa,
                               0, smis.stato_smistamento,
                               'C')
                          stato_smistamento
                  FROM seg_smistamenti smis,
                       documenti docu_smis,
                       ag_abilitazioni_smistamento absm,
                       ag_tipi_smistamento tism
                 WHERE     smis.id_documento = docu_smis.id_documento
                       AND docu_smis.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND smis.idrif = dep_idrif
                       AND smis.ufficio_smistamento = p_unita_tras
                       AND smis.stato_smistamento != 'F'
                       AND absm.azione = dep_azione
                       AND absm.aoo = ag_utilities.get_defaultaooindex
                       AND (   (    dep_is_unita_chiusa = 0
                                AND absm.stato_smistamento =
                                       smis.stato_smistamento)
                            OR (    dep_is_unita_chiusa = 1
                                AND smis.stato_smistamento IN ('C', 'E')))
                       AND absm.tipo_smistamento = smis.tipo_smistamento
                       AND tism.aoo = absm.aoo
                       AND tism.tipo_smistamento =
                              absm.tipo_smistamento_generabile)
         LOOP
            IF dep_tipo_smistamento IS NULL
            THEN
               dep_tipo_smistamento := ts.tipo_smistamento_generabile;
               dep_importanza := ts.importanza;

               IF dep_is_unita_chiusa = 0
               THEN
                  dep_stato_smistamento := 'R';
               ELSE
                  dep_stato_smistamento := ts.stato_smistamento;
               END IF;
            ELSE
               IF dep_importanza >= ts.importanza
               THEN
                  dep_tipo_smistamento := ts.tipo_smistamento_generabile;
                  dep_importanza := ts.importanza;

                  IF dep_is_unita_chiusa = 0
                  THEN
                     dep_stato_smistamento := 'R';
                  ELSE
                     IF    (    dep_stato_smistamento = 'R'
                            AND ts.stato_smistamento != 'R')
                        OR (    dep_stato_smistamento = 'C'
                            AND ts.stato_smistamento != 'E')
                     THEN
                        dep_stato_smistamento := ts.stato_smistamento;
                        dep_stato_smistamento := ts.stato_smistamento;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF dep_tipo_smistamento IS NULL
         THEN
            p_messaggio :=
               'non esistono smistamenti attivi per l''unità selezionata';
            p_errore := 1;
            RETURN;
         END IF;

         dep_id_nuovo_smistamento :=
            gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                        p_modello                   => 'M_SMISTAMENTO',
                                        p_cr                        => NULL,
                                        p_utente                    => p_utente,
                                        p_crea_record_orizzontale   => 1);

         SELECT codice_richiesta
           INTO dep_codice_richiesta_smi
           FROM documenti
          WHERE id_documento = dep_id_nuovo_smistamento;

         dep_data := SYSDATE;

         UPDATE seg_smistamenti
            SET stato_smistamento = dep_stato_smistamento,
                ufficio_trasmissione = p_unita_tras,
                des_ufficio_trasmissione = p_des_unita_tras,
                ufficio_smistamento = p_unita_ric,
                des_ufficio_smistamento = p_des_unita_ric,
                codice_amministrazione = p_codice_amministrazione,
                codice_aoo = p_codice_aoo,
                idrif = dep_idrif,
                note =
                      'Smistamento creato automaticamente in data '
                   || TO_CHAR (dep_data, 'dd/mm/yyyy hh24:mi:ss')
                   || ' in fase di invio ad unità.',
                presa_in_carico_dal =
                   DECODE (dep_stato_smistamento, 'R', NULL, dep_data),
                presa_in_carico_utente =
                   DECODE (dep_stato_smistamento, 'R', NULL, p_utente),
                smistamento_dal = dep_data,
                tipo_smistamento = dep_tipo_smistamento,
                data_esecuzione =
                   DECODE (dep_stato_smistamento, 'E', dep_data, NULL),
                utente_esecuzione =
                   DECODE (dep_stato_smistamento, 'E', p_utente, NULL)
          WHERE id_documento = dep_id_nuovo_smistamento;

         UPDATE documenti
            SET id_documento_padre = p_id_documento
          WHERE id_documento = dep_id_nuovo_smistamento;

         IF dep_stato_smistamento IN ('R', 'C')
         THEN
            IF dep_tipo_smistamento = 'COMPETENZA'
            THEN
               IF dep_stato_smistamento = 'C'
               THEN
                  dep_attivita_help := 'In carico -';
               ELSE
                  dep_attivita_help := 'Prendi in carico';
               END IF;
            ELSE
               dep_attivita_help := 'Presa visione';
            END IF;

            dep_nome_iter := 'ATTIVA_ITER_FASCICOLARE';

            SELECT documenti.area, tipi_documento.nome, codice_richiesta
              INTO dep_area, dep_codice_modello, dep_codice_richiesta
              FROM documenti, tipi_documento
             WHERE     documenti.id_documento = p_id_documento
                   AND documenti.area = tipi_documento.area_modello
                   AND documenti.id_tipodoc = tipi_documento.id_tipodoc;

            dep_url_rif_desc := 'Visualizza elenco fascicoli ';

            IF dep_stato_smistamento = 'C'
            THEN
               dep_url_rif_desc := dep_url_rif_desc || 'in carico ';
               dep_url_exec :=
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     p_id_cartella,
                                                     'C',
                                                     '',
                                                     '',
                                                     '',
                                                     'W',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N');
            ELSE
               dep_url_rif_desc := dep_url_rif_desc || 'da ricevere ';
               dep_url_exec :=
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     p_id_cartella,
                                                     'C',
                                                     '',
                                                     '',
                                                     '',
                                                     'R',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N');
            END IF;

            dep_url_rif_desc := dep_url_rif_desc || ' per ' || p_des_unita_ric;
            dep_url_rif :=
               calcola_url_query_iter (p_id_documento,
                                       p_unita_ric,
                                       dep_stato_smistamento);

            SELECT    dep_attivita_help
                   || ' - '
                   || fasc.class_cod
                   || ' - '
                   || fasc.fascicolo_anno
                   || '/'
                   || fascicolo_numero
                   || ' '
                   || fascicolo_oggetto,
                      fasc.class_cod
                   || ' - '
                   || fasc.fascicolo_anno
                   || '/'
                   || fascicolo_numero
                   || ' '
                   || fascicolo_oggetto
              INTO dep_attivita_help, dep_dati_applicativi
              FROM seg_fascicoli fasc
             WHERE fasc.id_documento = p_id_documento;

            dep_attivita :=
               crea_task_esterni ('SEGRETERIA',
                                  'M_SMISTAMENTO',
                                  dep_codice_richiesta_smi,
                                  dep_area,
                                  dep_codice_modello,
                                  dep_codice_richiesta,
                                  dep_id_nuovo_smistamento,
                                  p_codice_amministrazione,
                                  p_codice_aoo,
                                  dep_url_rif,
                                  dep_url_rif_desc,
                                  dep_url_exec,
                                  dep_attivita_help,
                                  TO_CHAR (NULL),
                                  dep_nome_iter,
                                  dep_dati_applicativi);
         END IF;
      END IF;

      DECLARE
         dep_conta_storicizzati      NUMBER := 0;
         dep_storicizza_assegnati    VARCHAR2 (1) := p_storicizza_assegnati;
         dep_esistono_assegnazioni   NUMBER := 0;
      BEGIN
         IF dep_tipo_smistamento = 'COMPETENZA' OR dep_is_unita_chiusa = 1
         THEN
            IF     dep_tipo_smistamento = 'COMPETENZA'
               AND dep_storicizza_assegnati = 'N'
            THEN
               BEGIN
                  SELECT COUNT (seg_smistamenti.id_documento)
                    INTO dep_esistono_assegnazioni
                    FROM seg_smistamenti, documenti
                   WHERE     documenti.id_documento =
                                seg_smistamenti.id_documento
                         AND idrif = dep_idrif
                         AND stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND seg_smistamenti.id_documento !=
                                NVL (dep_id_nuovo_smistamento, 0)
                         AND stato_smistamento != 'F'
                         AND NVL (codice_assegnatario, p_utente) <> p_utente
                         AND ufficio_smistamento = p_unita_tras;

                  IF dep_esistono_assegnazioni > 0
                  THEN
                     p_messaggio :=
                        ' esistono smistamenti per COMPETENZA per l''unità selezionata, assegnati ad altri';
                     p_errore := 1;
                     RETURN;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
            END IF;

            FOR s
               IN (SELECT seg_smistamenti.id_documento
                     FROM seg_smistamenti, documenti
                    WHERE     documenti.id_documento =
                                 seg_smistamenti.id_documento
                          AND idrif = dep_idrif
                          AND stato_documento NOT IN ('CA', 'RE', 'PB')
                          AND seg_smistamenti.id_documento !=
                                 NVL (dep_id_nuovo_smistamento, 0)
                          AND stato_smistamento != 'F'
                          AND DECODE (
                                 dep_storicizza_assegnati,
                                 'N', NVL (codice_assegnatario, p_utente),
                                 p_utente) = p_utente
                          AND ufficio_smistamento = p_unita_tras)
            LOOP
               UPDATE seg_smistamenti
                  SET stato_smistamento = 'F',
                      note =
                            DECODE (note,
                                    NULL, '',
                                    note || CHR (10) || CHR (13))
                         || 'Smistamento storicizzato automaticamente in data '
                         || TO_CHAR (dep_data, 'dd/mm/yyyy hh24:mi:ss')
                         || ' in fase di invio ad unità.'
                WHERE id_documento = s.id_documento;

               IF SQL%ROWCOUNT > 0
               THEN
                  dep_conta_storicizzati := 1;
               END IF;

               delete_task_esterni (s.id_documento);
            END LOOP;
         END IF;

         IF dep_conta_storicizzati > 0
         THEN
            IF p_messaggio IS NOT NULL
            THEN
               p_messaggio :=
                     p_messaggio
                  || ' Gli smistamenti a '
                  || p_des_unita_tras
                  || ' sono stati storicizzati.';
            END IF;
         ELSE
            IF p_messaggio IS NOT NULL
            THEN
               p_errore := 1;
               RETURN;
            END IF;
         END IF;
      END;
   END invia_fasc_a_unita;

   PROCEDURE invia_a_unita (p_id_documento                 NUMBER,
                            p_utente                       VARCHAR2,
                            p_unita_tras                   VARCHAR2,
                            p_unita_ric                    VARCHAR2,
                            p_storicizza_assegnati         VARCHAR2,
                            p_codice_amministrazione       VARCHAR2,
                            p_codice_aoo                   VARCHAR2,
                            p_des_unita_tras               VARCHAR2,
                            p_des_unita_ric                VARCHAR2,
                            p_messaggio                OUT VARCHAR2,
                            p_errore                   OUT NUMBER)
   IS
      dep_is_protocollo            NUMBER;
      dep_is_smistabile            NUMBER;
      dep_idrif                    spr_protocolli.idrif%TYPE;
      dep_is_unita_chiusa          NUMBER;
      dep_tipo_smistamento         ag_tipi_smistamento.tipo_smistamento%TYPE;
      dep_importanza               ag_tipi_smistamento.importanza%TYPE;
      dep_id_nuovo_smistamento     NUMBER;
      dep_stato_smistamento        seg_smistamenti.stato_smistamento%TYPE;
      dep_data                     DATE;
      dep_attivita_help            jwf_task_esterni.attivita_help%TYPE;
      dep_attivita_descr           jwf_task_esterni.attivita_descr%TYPE;
      dep_anno                     spr_protocolli.anno%TYPE;
      dep_numero                   spr_protocolli.numero%TYPE;
      dep_oggetto                  spr_protocolli.oggetto%TYPE;
      dep_url_rif                  jwf_task_esterni.url_rif%TYPE;
      dep_url_rif_desc             jwf_task_esterni.url_rif_desc%TYPE;
      dep_url_exec                 jwf_task_esterni.url_exec%TYPE;
      dep_nome_iter                parametri.valore%TYPE;
      dep_area                     documenti.area%TYPE;
      dep_codice_modello           tipi_documento.nome%TYPE;
      dep_codice_richiesta         documenti.codice_richiesta%TYPE;
      dep_dati_applicativi         jwf_task_esterni.dati_applicativi_1%TYPE;
      dep_attivita                 VARCHAR2 (32000);
      dep_codice_richiesta_smi     documenti.codice_richiesta%TYPE;
      dep_crea_nuovo_smistamento   NUMBER := 1;
      dep_azione                   VARCHAR2 (100);
   BEGIN
      p_errore := 0;


      BEGIN
         SELECT 0
           INTO dep_is_unita_chiusa
           FROM seg_unita
          WHERE     codice_amministrazione = p_codice_amministrazione
                AND codice_aoo = p_codice_aoo
                AND unita = p_unita_tras
                AND al IS NULL;

         dep_azione := 'SMISTA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            dep_is_unita_chiusa := 1;
            dep_azione := 'INOLTRA';
      END;


      -- VERIFICA SE L'UTENTE PUO' SMISTARE IL DOCUMENTO
      dep_is_protocollo :=
         ag_utilities.verifica_categoria_documento (p_id_documento, 'PROTO');

      IF dep_is_protocollo = 1
      THEN
         dep_is_smistabile :=
            ag_competenze_protocollo.abilita_azione_smistamento (
               p_id_documento,
               p_utente,
               dep_azione);
      ELSE
         dep_is_smistabile :=
            ag_competenze_documento.abilita_azione_smistamento (
               p_id_documento,
               p_utente,
               dep_azione);
      END IF;

      IF dep_is_smistabile = 0
      THEN
         p_messaggio :=
               'non smistabile (azione: '
            || dep_azione
            || ', idDoc: '
            || p_id_documento
            || ')';
         p_errore := 1;
         RETURN;
      END IF;

      SELECT idrif
        INTO dep_idrif
        FROM smistabile_view
       WHERE id_documento = p_id_documento;

      DECLARE
         dep_smistamento_esistente   NUMBER := 0;
      BEGIN
         SELECT COUNT (*)
           INTO dep_smistamento_esistente
           FROM seg_smistamenti, documenti
          WHERE     seg_smistamenti.id_documento = documenti.id_documento
                AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND stato_smistamento NOT IN ('N', 'F')
                AND ufficio_trasmissione = p_unita_tras
                AND ufficio_smistamento = p_unita_ric
                AND idrif = dep_idrif;

         IF dep_smistamento_esistente > 0
         THEN
            IF dep_is_unita_chiusa = 0
            THEN
               p_messaggio :=
                     ' è già presente uno smistamento all''unità '
                  || p_des_unita_ric
                  || '.';
               p_errore := 1;
               RETURN;
            ELSE
               p_messaggio :=
                  ' smistamento a ' || p_des_unita_ric || ' già presente.';
               dep_crea_nuovo_smistamento := 0;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      DBMS_OUTPUT.put_line (
         'dep_crea_nuovo_smistamento:' || dep_crea_nuovo_smistamento);



      IF dep_crea_nuovo_smistamento > 0
      THEN
         DBMS_OUTPUT.put_line ('p_unita_tras:' || p_unita_tras);
         DBMS_OUTPUT.put_line ('dep_idrif:' || dep_idrif);
         DBMS_OUTPUT.put_line ('dep_is_unita_chiusa:' || dep_is_unita_chiusa);
         DBMS_OUTPUT.put_line ('dep_azione:' || dep_azione);
         DBMS_OUTPUT.put_line (
               'ag_utilities.get_defaultaooindex:'
            || ag_utilities.get_defaultaooindex);


         FOR ts
            IN (SELECT DISTINCT
                       absm.tipo_smistamento_generabile,
                       tism.importanza,
                       DECODE (dep_is_unita_chiusa,
                               0, smis.stato_smistamento,
                               'C')
                          stato_smistamento
                  FROM seg_smistamenti smis,
                       documenti docu_smis,
                       ag_abilitazioni_smistamento absm,
                       ag_tipi_smistamento tism
                 WHERE     smis.id_documento = docu_smis.id_documento
                       AND docu_smis.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND smis.idrif = dep_idrif
                       AND smis.ufficio_smistamento = p_unita_tras
                       AND smis.stato_smistamento != 'F'
                       AND absm.azione = dep_azione
                       AND absm.aoo = ag_utilities.get_defaultaooindex
                       AND (   (    dep_is_unita_chiusa = 0
                                AND absm.stato_smistamento =
                                       smis.stato_smistamento)
                            OR (    dep_is_unita_chiusa = 1
                                AND smis.stato_smistamento IN ('C', 'E')))
                       AND absm.tipo_smistamento = smis.tipo_smistamento
                       AND tism.aoo = absm.aoo
                       AND tism.tipo_smistamento =
                              absm.tipo_smistamento_generabile)
         LOOP
            DBMS_OUTPUT.put_line (
               'dep_tipo_smistamento:' || dep_tipo_smistamento);

            IF dep_tipo_smistamento IS NULL
            THEN
               -- primo smistamento a p_unita
               dep_tipo_smistamento := ts.tipo_smistamento_generabile;
               dep_importanza := ts.importanza;

               IF dep_is_unita_chiusa = 0
               THEN
                  dep_stato_smistamento := 'R';
               ELSE
                  dep_stato_smistamento := ts.stato_smistamento;
               END IF;
            ELSE
               -- smistamento a p_unita successivo al primo
               IF dep_importanza >= ts.importanza
               THEN
                  dep_tipo_smistamento := ts.tipo_smistamento_generabile;
                  dep_importanza := ts.importanza;

                  IF dep_is_unita_chiusa = 0
                  THEN
                     dep_stato_smistamento := 'R';
                  ELSE
                     IF    (    dep_stato_smistamento = 'R'
                            AND ts.stato_smistamento != 'R')
                        OR (    dep_stato_smistamento = 'C'
                            AND ts.stato_smistamento != 'E')
                     THEN
                        dep_stato_smistamento := ts.stato_smistamento;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF dep_tipo_smistamento IS NULL
         THEN
            p_messaggio :=
               'non esistono smistamenti attivi per l''unità selezionata';
            p_errore := 1;
            RETURN;
         END IF;

         dep_id_nuovo_smistamento :=
            gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                        p_modello                   => 'M_SMISTAMENTO',
                                        p_cr                        => NULL,
                                        p_utente                    => p_utente,
                                        p_crea_record_orizzontale   => 1);

         SELECT codice_richiesta
           INTO dep_codice_richiesta_smi
           FROM documenti
          WHERE id_documento = dep_id_nuovo_smistamento;

         dep_data := SYSDATE;

         UPDATE seg_smistamenti
            SET stato_smistamento = dep_stato_smistamento,
                ufficio_trasmissione = p_unita_tras,
                des_ufficio_trasmissione = p_des_unita_tras,
                ufficio_smistamento = p_unita_ric,
                des_ufficio_smistamento = p_des_unita_ric,
                codice_amministrazione = p_codice_amministrazione,
                codice_aoo = p_codice_aoo,
                idrif = dep_idrif,
                utente_trasmissione = p_utente,
                key_iter_smistamento = -1,
                note =
                      'Smistamento creato automaticamente in data '
                   || TO_CHAR (dep_data, 'dd/mm/yyyy hh24:mi:ss')
                   || ' in fase di invio ad unità.',
                presa_in_carico_dal =
                   DECODE (dep_stato_smistamento, 'R', NULL, dep_data),
                presa_in_carico_utente =
                   DECODE (dep_stato_smistamento, 'R', NULL, p_utente),
                smistamento_dal = dep_data,
                tipo_smistamento = dep_tipo_smistamento,
                data_esecuzione =
                   DECODE (dep_stato_smistamento, 'E', dep_data, NULL),
                utente_esecuzione =
                   DECODE (dep_stato_smistamento, 'E', p_utente, NULL)
          WHERE id_documento = dep_id_nuovo_smistamento;

         UPDATE documenti
            SET id_documento_padre = p_id_documento
          WHERE id_documento = dep_id_nuovo_smistamento;

         IF dep_stato_smistamento IN ('R', 'C')
         THEN
            IF dep_tipo_smistamento = 'COMPETENZA'
            THEN
               IF dep_stato_smistamento = 'C'
               THEN
                  dep_attivita_help := 'In carico';
               ELSE
                  dep_attivita_help := 'Prendi in carico';
               END IF;
            ELSE
               dep_attivita_help := 'Presa visione';
            END IF;

            dep_nome_iter :=
               ag_parametro.get_valore ('NOME_ITER_SMIST', '@agStrut@');

            SELECT documenti.area, tipi_documento.nome, codice_richiesta
              INTO dep_area, dep_codice_modello, dep_codice_richiesta
              FROM documenti, tipi_documento
             WHERE     documenti.id_documento = p_id_documento
                   AND documenti.area = tipi_documento.area_modello
                   AND documenti.id_tipodoc = tipi_documento.id_tipodoc;

            dep_url_rif_desc := 'Visualizza elenco documenti ';

            IF dep_stato_smistamento = 'C'
            THEN
               dep_url_rif_desc := dep_url_rif_desc || 'in carico ';
               dep_url_exec :=
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     p_id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'W',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N');
            ELSE
               dep_url_rif_desc := dep_url_rif_desc || 'da ricevere ';
               dep_url_exec :=
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     p_id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'R',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N');
            END IF;

            dep_url_rif_desc := dep_url_rif_desc || ' per ' || p_des_unita_ric;
            dep_url_rif :=
               calcola_url_query_iter (p_id_documento,
                                       p_unita_ric,
                                       dep_stato_smistamento);

            IF dep_is_protocollo = 1
            THEN
               SELECT anno, numero, oggetto
                 INTO dep_anno, dep_numero, dep_oggetto
                 FROM proto_view
                WHERE id_documento = p_id_documento;

               dep_dati_applicativi :=
                  dep_anno || '/' || LPAD (dep_numero, '0', 7);

               IF ag_utilities.verifica_categoria_documento (
                     p_id_documento,
                     'PROTO_ARRIVO_PEC') = 1
               THEN
                  dep_attivita_help := dep_attivita_help || ' - da PEC PG';
               ELSE
                  dep_attivita_help := dep_attivita_help || ' - PG';
               END IF;

               dep_attivita_help :=
                     dep_attivita_help
                  || dep_anno
                  || ' / '
                  || dep_numero
                  || ': '
                  || dep_oggetto;
            ELSE
               SELECT dep_attivita_help || ' - ' || doc.des, doc.des
                 INTO dep_attivita_help, dep_dati_applicativi
                 FROM (SELECT    DECODE (
                                    DATA,
                                    NULL, '',
                                       'Documento del '
                                    || TO_CHAR (DATA, 'dd/mm/yyyy'))
                              || DECODE (oggetto,
                                         NULL, '',
                                         ' oggetto: ' || oggetto)
                                 des
                         FROM spr_da_fascicolare
                        WHERE id_documento = p_id_documento
                       UNION
                       SELECT 'Messaggio con oggetto ' || oggetto des
                         FROM seg_memo_protocollo
                        WHERE id_documento = p_id_documento) doc;
            END IF;

            dep_attivita :=
               crea_task_esterni ('SEGRETERIA',
                                  'M_SMISTAMENTO',
                                  dep_codice_richiesta_smi,
                                  dep_area,
                                  dep_codice_modello,
                                  dep_codice_richiesta,
                                  dep_id_nuovo_smistamento,
                                  p_codice_amministrazione,
                                  p_codice_aoo,
                                  dep_url_rif,
                                  dep_url_rif_desc,
                                  dep_url_exec,
                                  dep_attivita_help,
                                  TO_CHAR (NULL),
                                  dep_nome_iter,
                                  dep_dati_applicativi);
         END IF;
      END IF;

      DECLARE
         dep_conta_storicizzati   NUMBER := 0;
      BEGIN
         FOR s
            IN (SELECT seg_smistamenti.id_documento
                  FROM seg_smistamenti, documenti
                 WHERE     documenti.id_documento =
                              seg_smistamenti.id_documento
                       AND idrif = dep_idrif
                       AND stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND seg_smistamenti.id_documento !=
                              NVL (dep_id_nuovo_smistamento, 0)
                       AND stato_smistamento != 'F'
                       AND DECODE (p_storicizza_assegnati,
                                   'N', NVL (codice_assegnatario, p_utente),
                                   p_utente) = p_utente
                       AND ufficio_smistamento = p_unita_tras
                       AND dep_is_unita_chiusa = 1)
         LOOP
            UPDATE seg_smistamenti
               SET stato_smistamento = 'F',
                   note =
                         DECODE (note,
                                 NULL, '',
                                 note || CHR (10) || CHR (13))
                      || 'Smistamento storicizzato automaticamente in data '
                      || TO_CHAR (dep_data, 'dd/mm/yyyy hh24:mi:ss')
                      || ' in fase di invio ad unità.'
             WHERE id_documento = s.id_documento;

            IF SQL%ROWCOUNT > 0
            THEN
               dep_conta_storicizzati := 1;
            END IF;

            delete_task_esterni (s.id_documento);
         END LOOP;

         IF dep_conta_storicizzati > 0
         THEN
            IF p_messaggio IS NOT NULL
            THEN
               p_messaggio :=
                     p_messaggio
                  || ' Gli smistamenti a '
                  || p_des_unita_tras
                  || ' sono stati storicizzati.';
            END IF;
         ELSE
            IF p_messaggio IS NOT NULL
            THEN
               p_errore := 1;
               RETURN;
            END IF;
         END IF;
      END;
   END invia_a_unita;

   FUNCTION calcola_url_query_iter (p_id_oggetto           NUMBER,
                                    p_unita                VARCHAR2,
                                    p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      s_server := '..'; --AG_PARAMETRO.GET_VALORE ('SERVER', '@agStrut@', '');
      s_context := AG_PARAMETRO.GET_VALORE ('AG_CONTEXT_PATH', '@ag@', '');

      SELECT id_cartella
        INTO s_idworkarea
        FROM cartelle
       WHERE nome = AG_PARAMETRO.GET_VALORE ('WKAREA_PROT_1', '@agVar@', '');

      --dbms_output.put_line('prima calcola_url_query_iter');
      IF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'FASC') = 1
      THEN
         RETURN calcola_url_query_iter_fasc (p_unita, p_stato_smistamento);
      ELSE
         RETURN calcola_url_query_iter_doc (p_unita, p_stato_smistamento);
      END IF;
   END calcola_url_query_iter;

   FUNCTION calcola_url_query_iter_doc (p_unita                VARCHAR2,
                                        p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_id_query   NUMBER;
      dep_tipo       VARCHAR2 (100);
   BEGIN
      SELECT MAX (QUERY.id_query),
             DECODE (p_stato_smistamento,
                     'R', 'M_DA_RICEVERE',
                     'M_IN_CARICO')
        INTO dep_id_query, dep_tipo
        FROM QUERY
       WHERE codiceads =
                   'SEGRETERIA.PROTOCOLLO#DOCUMENTI_'
                || DECODE (p_stato_smistamento,
                           'R', 'DA_RICEVERE',
                           'IN_CARICO');

      RETURN    s_server
             || '/'
             || s_context
             || '/common/WorkArea.do?WRKSP='
             || s_idworkarea
             || '&idQuery='
             || dep_id_query
             || '&PAR_AGSPR_UNITA='
             || p_unita
             || '&PAR_AGSPR_TIPO_RICERCA='
             || dep_tipo;
   END calcola_url_query_iter_doc;

   FUNCTION calcola_url_query_iter_fasc (p_unita                VARCHAR2,
                                         p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_id_query   NUMBER;
      dep_tipo       VARCHAR2 (100);
   BEGIN
      SELECT MAX (QUERY.id_query),
             DECODE (p_stato_smistamento,
                     'R', 'M_DA_RICEVERE',
                     'M_IN_CARICO')
        INTO dep_id_query, dep_tipo
        FROM QUERY
       WHERE codiceads =
                   'SEGRETERIA#FASCICOLI_'
                || DECODE (p_stato_smistamento,
                           'R', 'DA_RICEVERE',
                           'IN_CARICO');

      RETURN    s_server
             || '/'
             || s_context
             || '/common/WorkArea.do?WRKSP='
             || s_idworkarea
             || '&idQuery='
             || dep_id_query
             || '&PAR_AGSPR_UNITA='
             || p_unita
             || '&PAR_AGSPR_TIPO_RICERCA='
             || dep_tipo;
   END calcola_url_query_iter_fasc;

   PROCEDURE elimina_smistamenti (p_idrif VARCHAR2)
   IS
      a_ret   NUMBER;
   BEGIN
      FOR s
         IN (SELECT seg_smistamenti.id_documento
               FROM seg_smistamenti, documenti
              WHERE     seg_smistamenti.idrif = p_idrif
                    AND documenti.id_documento = seg_smistamenti.id_documento
                    AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB'))
      LOOP
         a_ret := f_elimina_documento_logico (s.id_documento, 'RPI', 0);
      END LOOP;
   END;

   /******************************************************************************
    NOME:        UPD_DATA_ATTIVAZIONE
    DESCRIZIONE: Aggiornamento dei campi smistamento_dal e assegnazione_dal.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    005  18/08/2015 MM     Creazione.
   ******************************************************************************/
   PROCEDURE upd_data_attivazione (p_idrif VARCHAR2, p_data VARCHAR2)
   IS
      d_data   DATE;
   BEGIN
      IF p_data IS NOT NULL
      THEN
         d_data := TO_DATE (p_data, 'dd/mm/yyyy hh24:mi:ss');
      END IF;

      UPDATE seg_smistamenti
         SET seg_smistamenti.smistamento_dal = NVL (smistamento_dal, d_data)
       WHERE     seg_smistamenti.idrif = p_idrif
             AND seg_smistamenti.smistamento_dal <
                    NVL (smistamento_dal, d_data)
             AND seg_smistamenti.tipo_smistamento <> 'DUMMY';

      UPDATE seg_smistamenti
         SET seg_smistamenti.assegnazione_dal = NVL (assegnazione_dal, d_data)
       WHERE     seg_smistamenti.idrif = p_idrif
             AND seg_smistamenti.assegnazione_dal IS NOT NULL
             AND seg_smistamenti.assegnazione_dal <
                    NVL (assegnazione_dal, d_data)
             AND seg_smistamenti.tipo_smistamento <> 'DUMMY';
   END;

   /******************************************************************************
    NOME:        is_possibile_smistare
    DESCRIZIONE: Controlla se un utente può smistare un determinato documento ad
                 una determinata unita di trasmissione.
                 In particolare è possibile smistare SE:
                 - esiste almeno uno smistamento per l'unità scelta per
                   competenza e preso in carico / eseguito / da ricevere
                 - esiste almeno uno smistamento per l'unità scelta per
                   conoscenza
                 - l'utente ha privilegio ISMITOT sull'unita di trasmissione
                 - per i protocolli, il doc è stato protocollato e l'unità
                   di trasmissione equivale all'unità protocollante
                 - per i doc da fascicolare, l'unità di trasmissione equivale
                   all'unità di creazione
                 - per i memo, l'unità di trasmissione equivale all'unità di
                   trasmissione del primo smistamento

    PARAMETRI:   p_idrif              IDRIF dello smistamento
                 p_unita_trasmissione ufficio di trasmissione dello smistamento
                 p_utente             utente che esegue lo smistamento

    RITORNA:     0 se non è possibile eseguire alcuno smistamento,
                 1 se è possibile smistare solo per conoscenza,
                 2 se è possibile smistare sia per conoscenza che per competenza.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    005  19/08/2015 MM     Creazione.
    007  16/09/2016 MM     Aggiunta la possibilità di smistare per conoscenza
                           anche per i doc. smistati per competenza in stato da
                           ricevere.
   ******************************************************************************/
   FUNCTION is_possibile_smistare (p_idrif                IN VARCHAR2,
                                   p_unita_trasmissione   IN VARCHAR2,
                                   p_utente               IN VARCHAR2)
      RETURN NUMBER
   IS
      d_ret                   NUMBER := 0;
      d_id_padre              NUMBER;
      d_unita_protocollante   VARCHAR2 (100);
      d_stato_protocollo      VARCHAR2 (10);
      d_tipo_documento        VARCHAR2 (255);
   BEGIN
      -- se lo smistamento non e' ancora associato a nessun documento significa
      -- che il padre e' nuovo => è possibile smistare sia per conoscenza che
      -- per competenza
      BEGIN
         SELECT id_documento, unita_protocollante, stato_pr
           INTO d_id_padre, d_unita_protocollante, d_stato_protocollo
           FROM smistabile_view s
          WHERE idrif = p_idrif;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_ret := 2;
      END;

      IF d_ret = 0
      THEN
         BEGIN
            -- e' un protocollo?
            SELECT unita_protocollante, stato_pr, tipo_documento
              INTO d_unita_protocollante,
                   d_stato_protocollo,
                   d_tipo_documento
              FROM proto_view
             WHERE id_documento = d_id_padre;

            IF AG_TIPI_DOCUMENTO_UTILITY.HAS_SEQUENZA_SMISTAMENTI (
                  d_tipo_documento) = 1
            THEN
               d_ret := 1;
            ELSE
               -- se non ho ancora protocollato e non conosco l'unità di trasmissione, allora posso smistare
               IF p_unita_trasmissione IS NULL AND d_stato_protocollo = 'DP'
               THEN
                  d_ret := 2;
               ELSE
                  --se ho già protocollato e sono l'unità protocollante, allora posso smistare
                  IF     d_stato_protocollo = 'PR'
                     AND p_unita_trasmissione = d_unita_protocollante
                  THEN
                     d_ret := 2;
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- non e' un protocollo. E' un doc da fascicolare?
               BEGIN
                  SELECT unita_protocollante
                    INTO d_unita_protocollante
                    FROM spr_da_fascicolare
                   WHERE id_documento = d_id_padre;

                  -- l'unità di trasmissione equivale all'unità di creazione
                  IF p_unita_trasmissione = d_unita_protocollante
                  THEN
                     d_ret := 2;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- non e' un protocollo, non e' un doc da fascicolare,
                     -- non e' un fascicolo. E' un memo?
                     BEGIN
                        SELECT unita_protocollante
                          INTO d_unita_protocollante
                          FROM seg_memo_protocollo
                         WHERE id_documento = d_id_padre;

                        -- l'unità di trasmissione equivale all'unità di
                        -- trasmissione del primo smistamento
                        IF p_unita_trasmissione = d_unita_protocollante
                        THEN
                           d_ret := 2;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           -- non e' un protocollo, ne' un doc da fascicolare,
                           -- ne' un memo.
                           -- Nessun controllo specifico deve essere fatto.
                           NULL;
                     END;
               END;
         END;
      END IF;

      IF d_ret = 0
      THEN
         -- l'utente ha privilegio ISMITOT sull'unita di trasmissione??
         DECLARE
            d_ismitot   NUMBER;
         BEGIN
            SELECT COUNT (1)
              INTO d_ismitot
              FROM ag_priv_utente_tmp priv, seg_unita unit
             WHERE     priv.utente = p_utente
                   AND priv.privilegio = 'ISMITOT'
                   AND priv.unita = unit.unita
                   AND TRUNC (SYSDATE) BETWEEN unit.dal
                                           AND NVL (unit.al,
                                                    TO_DATE (3333333, 'j'))
                   AND priv.unita = p_unita_trasmissione
                   AND TRUNC (SYSDATE) <=
                          NVL (priv.al, TO_DATE (3333333, 'j'));

            IF d_ismitot > 0
            THEN
               d_ret := 2;
            END IF;
         END;
      END IF;

      IF d_ret = 0
      THEN
         -- esiste uno smistamento per l'unità scelta per competenza e preso in
         -- carico / eseguito / da riceve oppure uno smistamento per conoscenza?
         FOR smis
            IN (SELECT stato_smistamento, tipo_smistamento
                  FROM seg_smistamenti s, documenti d
                 WHERE     idrif = p_idrif
                       AND tipo_smistamento <> 'DUMMY'
                       AND d.id_documento = s.id_documento
                       AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND ufficio_smistamento = p_unita_trasmissione)
         LOOP
            IF     smis.tipo_smistamento = 'COMPETENZA'
               AND smis.stato_smistamento IN ('C', 'E', 'R')
            THEN
               d_ret := 2;
               EXIT;
            END IF;

            IF smis.tipo_smistamento = 'CONOSCENZA'
            THEN
               d_ret := 1;
            END IF;
         END LOOP;
      END IF;

      RETURN d_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;
END;
/
