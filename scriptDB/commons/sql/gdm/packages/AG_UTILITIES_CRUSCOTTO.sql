--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_CRUSCOTTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_UTILITIES_CRUSCOTTO"
IS
   /******************************************************************************
    NOME:        Ag_utilities_cruscotto
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per semplificare
              la gestione delle attivita' nel cruscotto.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore   Descrizione.
    00    17/05/2007 SC       Prima emissione.
    01    25/01/2013 MM       Creazione funzione istanzia_iter e istanzia_iter_e_termina.
    02    12/03/2013 MM       Inserimento funzione is_rapporto
    03    16/09/2016 MM       Inserimento chiudi_flusso_smist_nocommit
    04    14/12/2017 SC       Adeguamento SmartDesktop
   ******************************************************************************/
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.02';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_utenti_accesso_smistamento (p_area                VARCHAR2,
                                            p_modello             VARCHAR2,
                                            p_codice_richiesta    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_utenti_accesso_smistamento (p_area                  VARCHAR2,
                                            p_modello               VARCHAR2,
                                            p_codice_richiesta      VARCHAR2,
                                            p_inizializza_utente    VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   /******************************************************************************
 NOME:        is_smistamento
 INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
 DESCRIZIONE: Verifica se il documento identificato da p_id_documento è uno smistamento.
 RITORNA:     number 1 se è uno smistamento, 0 altrimenti.
 NOTE:
******************************************************************************/
   FUNCTION is_smistamento (p_id_documento NUMBER)
      RETURN NUMBER;

   /******************************************************************************
 NOME:        chiudi_flusso_smistamento
 INPUT:     p_id_documento id del documento associato al flusso

 DESCRIZIONE: Chiude il flusso associato allo smistamento p_id_documento il cui id è memorizzato
 in SEG_SMISTAMENTI.KEY_ITER_SMISTAMENTO.

 NOTE:
******************************************************************************/
   PROCEDURE chiudi_flusso_smistamento (p_id_documento NUMBER);

   PROCEDURE chiudi_flusso_smist_nocommit (p_id_documento NUMBER);

   FUNCTION is_lettera (p_id_documento NUMBER)
      RETURN NUMBER;

   PROCEDURE chiudi_flusso_lettera (p_id_documento NUMBER);

   PROCEDURE notifica_ins_doc_fasc (p_id_documento    NUMBER,
                                    p_id_cartella     NUMBER);

   FUNCTION istanzia_iter (p_nome_iter    VARCHAR2,
                           p_parametri    VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION istanzia_iter_e_termina (p_nome_iter    VARCHAR2,
                                     p_parametri    VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION is_rapporto (p_id_documento NUMBER)
      RETURN NUMBER;

   PROCEDURE notifica_rifiuto_annullamento (p_id_note NUMBER);

   PROCEDURE notifica_accettazione_ann (p_id_documento NUMBER);

   FUNCTION attiva_flusso_SU (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE ADD_FILE_SMARTDESKTOP (
      P_ID_PROTOCOLLO   IN NUMBER,
      P_TOOLTIP            VARCHAR2 DEFAULT 'File principale',
      P_PRIORITA           NUMBER DEFAULT 1);

   PROCEDURE RIMUOVI_TUTTO_SMARTDESKTOP;

   FUNCTION crea_task_esterno_TODO (
      P_ID_RIFERIMENTO           IN VARCHAR2,
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
      P_TIPOLOGIA                IN VARCHAR2,
      P_DATIAPPLICATIVI1         IN VARCHAR2,
      P_DATIAPPLICATIVI2         IN VARCHAR2,
      P_DATIAPPLICATIVI3         IN VARCHAR2,
      P_TIPO_BOTTONE             IN VARCHAR2,
      P_DATA_ATTIVAZIONE         IN DATE,
      P_DES_DETTAGLIO_1          IN VARCHAR2,
      P_DETTAGLIO_1              IN VARCHAR2,
      P_ID_DOCUMENTO             IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION ADD_SERVER_TO_URL (P_URL VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION GET_FILES_SMARTDESKTOP (P_ID_DOCUMENTO     IN NUMBER,
                                    P_TIPO_DOCUMENTO   IN VARCHAR2,
                                    P_INDEX            IN NUMBER,
                                    P_UTENTE           IN VARCHAR2)
      RETURN VARCHAR2;


   FUNCTION GET_DENOMINAZIONE_CORR (P_ID_PROTOCOLLO IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE UPD_DETT_TASK_EST (p_id_rapporto VARCHAR2);

   PROCEDURE UPD_DETT_TASK_EST (p_idrif VARCHAR2);

   PROCEDURE upd_ogg_task_est_commit (p_idrif           VARCHAR2,
                                      p_oggetto         VARCHAR2,
                                      p_old_oggetto     VARCHAR2,
                                      p_anno_proto      NUMBER,
                                      p_numero_proto    NUMBER);


   PROCEDURE upd_ogg_task_est_nocommit (p_idrif           VARCHAR2,
                                        p_oggetto         VARCHAR2,
                                        p_old_oggetto     VARCHAR2,
                                        p_anno_proto      NUMBER,
                                        p_numero_proto    NUMBER);

   PROCEDURE delete_task_esterni (p_id_riferimento    VARCHAR2,
                                  p_utente            VARCHAR2);

   PROCEDURE delete_task_esterni (p_id_riferimento VARCHAR2);

   PROCEDURE delete_task_esterni_commit (p_id_riferimento VARCHAR2);

   PROCEDURE delete_task_esterni_commit (p_id_riferimento    VARCHAR2,
                                         p_utente            VARCHAR2);
END AG_UTILITIES_CRUSCOTTO;
/
CREATE OR REPLACE PACKAGE BODY "AG_UTILITIES_CRUSCOTTO"
IS
   s_revisione_body   VARCHAR2 (3) := '007';

   /******************************************************************************
    NOME:        GDM.Ag_utilities_cruscotto
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per semplificare
              la gestione delle attivita' nel cruscotto.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore   Descrizione.
    000   02/01/2007 SC       Prima emissione.
    001   11/01/2012 MM       A47345.0.0: Effettuando la presa in carico su un pg
                              smistato a unità chiusa con storico ruoli = Y, il
                              sistema permette la presa in carico, ma non torna
                              sulla scrivania l'attività "in carico".
    002   17/05/2012 MM       Modifiche versione 2.1.
    003   12/03/2013 MM       Creata is_rapporto
    004   08/05/2013 MM       Modificata funzione get_utenti_accesso_smistamento.
    005   16/09/2016 MM       Creata chiudi_flusso_smist_nocommit
          26/04/2017 SC       ALLINEATO ALLO STANDARD
    006   14/12/2017 SC       Adeguamento SmartDesktop
    007   25/08/2020 MM       Modificata UPD_DETT_TASK_EST in modo da passare --
                              ad AGGIUNGI_DETTAGLIO invece che null (campo valore
                              obbligatorio).
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
      RETURN s_revisione || '.' || s_revisione_body;
   END;

   /******************************************************************************
    NOME:        get_utenti_accesso_smistamento
    DESCRIZIONE: Calcola gli utenti che hanno accesso alla riga di attività jsync
                 associata allo smistamento identificato da area, modello e codice_richiesta
                 passati.
    RITORNA:     varchar2 stringa contenente l'elenco di utenti abilitati.
                   Se nessun utente è abilitato restituisce '@'
                   se ci sono degli utenti restituisce una stringa del tipo
                   '@codiceUtente1@codiceUtente2@codiceUtenteN@'.
                   In caso di errori restituire la stringa @p_area@p_modello@p_codice_richiesta@
                   concatenata con la segnalazione di errore.
    NOTE:        La stringa inizia e finice sempre con @.
    A26738.0.0 SC 31/03/2008 Restituisco la stringa @p_area@p_modello@p_codice_richiesta@
                   concatenata con la segnalazione di errore in caso di problemi.
   ******************************************************************************/
   FUNCTION get_utenti_accesso_smistamento (p_area                VARCHAR2,
                                            p_modello             VARCHAR2,
                                            p_codice_richiesta    VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_utenti_accesso_smistamento (p_area,
                                             p_modello,
                                             p_codice_richiesta,
                                             'Y');
   END;

   /******************************************************************************
    NOME:        get_utenti_accesso_smistamento
    DESCRIZIONE: Calcola gli utenti che hanno accesso alla riga di attività jsync
                 associata allo smistamento identificato da area, modello e codice_richiesta
                 passati.
    RITORNA:     varchar2 stringa contenente l'elenco di utenti abilitati.
                   Se nessun utente è abilitato restituisce '@'
                   se ci sono degli utenti restituisce una stringa del tipo
                   '@codiceUtente1@codiceUtente2@codiceUtenteN@'.
                   In caso di errori restituire la stringa @p_area@p_modello@p_codice_richiesta@
                   concatenata con la segnalazione di errore.
    NOTE:        La stringa inizia e finice sempre con @.
    A26738.0.0 SC 31/03/2008 Restituisco la stringa @p_area@p_modello@p_codice_richiesta@
                   concatenata con la segnalazione di errore in caso di problemi.
    Rev.  Data        Autore  Descrizione.
    001   11/01/2012  MM      A47345.0.0: Effettuando la presa in carico su un pg
                              smistato a unità chiusa con storico ruoli = Y, il
                              sistema permette la presa in carico, ma non torna
                              sulla scrivania l'attività "in carico".
    004   08/05/2013 MM       Aggiunto parametro p_calcola_estensioni alla chiamata
                              a inizializza_ag_priv_utente_tmp in modo che non
                              calcoli i privilegi per estensione che non creano
                              l'attivita' in scrivania.
   ******************************************************************************/
   FUNCTION get_utenti_accesso_smistamento (p_area                  VARCHAR2,
                                            p_modello               VARCHAR2,
                                            p_codice_richiesta      VARCHAR2,
                                            p_inizializza_utente    VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento          NUMBER;
      retval               VARCHAR2 (32000) := '@';
      codiceunita          VARCHAR2 (100);
      codiceassegnatario   VARCHAR2 (100);
      deputente            VARCHAR2 (100);
      ottica               VARCHAR2 (100);
      componentiunita      ag_utilities.t_ref_cursor;
      nicomponente         NUMBER;
      denominazione        VARCHAR2 (32000);
      statosmistamento     VARCHAR2 (1);
      datasmistamento      DATE;
      codamm               VARCHAR2 (100);
      codaoo               VARCHAR2 (100);
      storicoruoli         VARCHAR2 (1);
   BEGIN
      storicoruoli :=
         ag_parametro.get_valore (
            'STORICO_RUOLI_' || ag_utilities.get_indice_aoo (NULL, NULL),
            '@agVar@');

      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);

         --DBMS_OUTPUT.put_line ('iddocumento ' || iddocumento);
         IF iddocumento IS NULL
         THEN
            RETURN    '@'
                   || p_area
                   || '@'
                   || p_modello
                   || '@'
                   || p_codice_richiesta
                   || '@DOCUMENTO NON TROVATO';
         END IF;

         SELECT ufficio_smistamento,
                codice_assegnatario,
                stato_smistamento,
                TRUNC (smistamento_dal),
                codice_amministrazione,
                codice_aoo
           INTO codiceunita,
                codiceassegnatario,
                statosmistamento,
                datasmistamento,
                codamm,
                codaoo
           FROM seg_smistamenti
          WHERE id_documento = iddocumento;

         --DBMS_OUTPUT.put_line ('codiceunita ' || codiceunita);
         IF codiceunita IS NULL
         THEN
            RETURN    '@'
                   || p_area
                   || '@'
                   || p_modello
                   || '@'
                   || p_codice_richiesta
                   || '@UNITA DI CARICO MANCANTE';
         END IF;

         --DBMS_OUTPUT.put_line ('statosmistamento ' || statosmistamento);
         IF statosmistamento IS NULL
         THEN
            RETURN    '@'
                   || p_area
                   || '@'
                   || p_modello
                   || '@'
                   || p_codice_richiesta
                   || '@STATO SMISTAMENTO MANCANTE';
         END IF;

         IF (    codiceunita IS NOT NULL
             AND statosmistamento != 'N'
             AND statosmistamento != 'F')
         THEN
            -- se c'è l'assegnatario, solo lui accede all'attivita'
            -- verifica però che abbia i privilegi di accesso al documento
            IF (codiceassegnatario IS NOT NULL)
            THEN
               IF ag_competenze_smistamento.accesso_smistamento_cruscotto (
                     iddocumento,
                     codiceassegnatario) = 1
               THEN
                  retval := retval || codiceassegnatario || '@';
               --   DBMS_OUTPUT.put_line ('retval ' || retval);
               END IF;
            ELSE
               -- se non c'è l'assegnatario, tutti i membri dell'unita' che hanno accesso al documento
               -- hanno accesso all'unita'
               ottica := ag_utilities.get_ottica_utente (NULL, codamm, codaoo);

               -- Rev.  001   11/01/2012  MM      A47345.0.0
               IF storicoruoli = 'N'
               THEN
                  datasmistamento := TRUNC (SYSDATE);
               END IF;

               --componentiunita := so4_ags_pkg.unita_get_componenti (codiceunita, NULL, ottica);
               --SC 19/04/2017
               -- cercherebbe i componenti alla data dello smistamento
               -- per chi ha storico unita = Y
               -- e ad oggi per chi non ce l'ha
               -- Dato che poi i privilegi li controlliamo ad oggi
               -- e che questa funzione serve a creare le attività in scrivania
               -- ha senso cercare i componenti dell'unità ad oggi anzichè
               -- distinguere.
               componentiunita :=
                  so4_ags_pkg.unita_get_componenti (codiceunita,
                                                    NULL,
                                                    ottica,
                                                    TRUNC (SYSDATE)--datasmistamento
                                                    );

               -- Rev.  001   11/01/2012  MM      A47345.0.0: fine mod.
               IF componentiunita%ISOPEN
               THEN
                  LOOP
                     FETCH componentiunita INTO nicomponente, denominazione;

                     EXIT WHEN componentiunita%NOTFOUND;
                     DBMS_OUTPUT.put_line (
                           'nicomponente, denominazione '
                        || nicomponente
                        || ', '
                        || denominazione);

                     IF nicomponente IS NOT NULL
                     THEN
                        deputente := NULL;

                        BEGIN
                           deputente :=
                              so4_ags_pkg.comp_get_utente (nicomponente);

                           IF deputente IS NOT NULL
                           THEN
                              IF ag_competenze_smistamento.accesso_smistamento_cruscotto (
                                    iddocumento,
                                    deputente) = 1
                              THEN
                                 IF INSTR (retval, '@' || deputente || '@') =
                                       0
                                 THEN
                                    retval := retval || deputente || '@';
                                 END IF;
                              --    DBMS_OUTPUT.put_line ('retval ' || retval);
                              END IF;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              --A34544 SC Si prosegue sempre col componente successivo.
                              NULL;
                        --                             IF p_inizializza_utente = 'Y' THEN
                        --                               ROLLBACK;
                        --                             END IF;
                        END;
                     ELSE
                        EXIT;
                     END IF;
                  END LOOP;

                  CLOSE componentiunita;
               ELSE
                  retval :=
                        '@'
                     || p_area
                     || '@'
                     || p_modello
                     || '@'
                     || p_codice_richiesta
                     || '@'
                     || 'NON CI SONO COMPONENTI';
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval :=
                  '@'
               || p_area
               || '@'
               || p_modello
               || '@'
               || p_codice_richiesta
               || '@'
               || SQLERRM;
      END;

      RETURN retval;
   END get_utenti_accesso_smistamento;

   /******************************************************************************
    NOME:        is_smistamento
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento è uno smistamento.
    RITORNA:     number 1 se è uno smistamento, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_smistamento (p_id_documento NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN ag_utilities.is_smistamento (p_id_documento);
   END is_smistamento;

   FUNCTION is_lettera (p_id_documento NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN ag_utilities.is_lettera (p_id_documento);
   END is_lettera;

   /*******************************************************************************
    NOME:        chiudi_flusso_smistamento
    INPUT:     p_id_documento id del documento associato al flusso

    DESCRIZIONE: A27756.5.0 Chiude il flusso associato allo smistamento il cui id è
                 memorizzato in SEG_SMISTAMENTI.KEY_ITER_SMISTAMENTO.

                 ATTENZIONE: esegue COMMIT in AUTONOMOUS_TRANSACTION.
   *******************************************************************************/
   PROCEDURE chiudi_flusso_smistamento (p_id_documento NUMBER)
   IS
      dep_id_iter    NUMBER;
      ret_chiusura   NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      chiudi_flusso_smist_nocommit (p_id_documento);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END chiudi_flusso_smistamento;

   /*******************************************************************************
    NOME:        chiudi_flusso_smistamento_nocommit
    INPUT:     p_id_documento id del documento associato al flusso

    DESCRIZIONE: A27756.5.0 Chiude il flusso associato allo smistamento il cui id è
                 memorizzato in SEG_SMISTAMENTI.KEY_ITER_SMISTAMENTO.
   *******************************************************************************/
   PROCEDURE chiudi_flusso_smist_nocommit (p_id_documento NUMBER)
   IS
      dep_id_iter    NUMBER;
      ret_chiusura   NUMBER;
   BEGIN
      --  DBMS_OUTPUT.put_line ('INIZIO');
      BEGIN
         SELECT DISTINCT key_iter_smistamento
           INTO dep_id_iter
           FROM seg_smistamenti smis
          WHERE smis.id_documento = p_id_documento;

         --DBMS_OUTPUT.put_line ('dep_id_iter ' || dep_id_iter);
         IF dep_id_iter IS NOT NULL
         THEN
            BEGIN
               IF dep_id_iter <> -1
               THEN
                  ret_chiusura := jwf_utility.chiudi_iter (dep_id_iter, 0);
               ELSE
                  ag_smistamento.delete_task_esterni (p_id_documento);
               END IF;
            --   DBMS_OUTPUT.put_line ('ret_chiusura ' || ret_chiusura);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  --     DBMS_OUTPUT.put_line ('ERORE ');
                  IF dep_id_iter <> -1
                  THEN
                     raise_application_error (
                        -20999,
                        'NON E'' POSSIBILE CANCELLARE LO SMISTAMENTO PER FALLITA CHIUSURA ITER ASSOCIATO.');
                  ELSE
                     raise_application_error (
                        -20999,
                        'NON E'' POSSIBILE CANCELLARE LO SMISTAMENTO PER FALLITA CANCELLAZIONE TASK ESTERNI ASSOCIATI.');
                  END IF;
            END;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- DBMS_OUTPUT.put_line ('NO_DATA_FOUND ');
            NULL;
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
            RAISE;
      END;
   END;

   PROCEDURE chiudi_flusso_lettera (p_id_documento NUMBER)
   IS
      dep_id_iter    NUMBER;
      ret_chiusura   NUMBER;
   BEGIN
      --   DBMS_OUTPUT.put_line ('INIZIO');
      BEGIN
         SELECT DISTINCT key_iter_lettera
           INTO dep_id_iter
           FROM spr_lettere_uscita
          WHERE id_documento = p_id_documento;

         --  se non trovo il key_iter_lettera cerco sulla valori di jwf
         IF dep_id_iter IS NULL
         THEN
            BEGIN
               SELECT id_iter
                 INTO dep_id_iter
                 FROM jwf_valori
                WHERE valore = TO_CHAR (p_id_documento) AND codice = 'ID_DOC';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
         END IF;

         --  DBMS_OUTPUT.put_line ('dep_id_iter ' || dep_id_iter);
         IF dep_id_iter IS NOT NULL
         THEN
            BEGIN
               IF dep_id_iter <> -1
               THEN
                  ret_chiusura := jwf_utility.chiudi_iter (dep_id_iter);
               END IF;
            --  DBMS_OUTPUT.put_line ('ret_chiusura ' || ret_chiusura);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  --    DBMS_OUTPUT.put_line ('ERORE ');
                  IF dep_id_iter <> -1
                  THEN
                     raise_application_error (
                        -20999,
                        'NON E'' POSSIBILE CANCELLARE LA KETTERA PER FALLITA CHIUSURA ITER ASSOCIATO.');
                  END IF;
            END;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.put_line ('NO_DATA_FOUND ');
            NULL;
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
            RAISE;
      END;
   END chiudi_flusso_lettera;

   PROCEDURE notifica_ins_doc_fasc (p_id_documento    NUMBER,
                                    p_id_cartella     NUMBER)
   IS
      d_tipologia                VARCHAR2 (2000) := 'NOTIFICA_INS_DOC_FASC';
      d_attivita_descrizione     VARCHAR2 (32000);
      d_tooltip_attivita_descr   VARCHAR2 (32000);
      d_param_init_iter          VARCHAR2 (200) := d_tipologia;
      d_nome_iter                VARCHAR2 (100) := d_tipologia;
      d_descrizione_iter         VARCHAR2 (2000) := NULL;
      d_descrizione_documento    VARCHAR2 (32000) := NULL;
      d_data_scad                DATE;
      d_colore                   VARCHAR2 (15) := NULL;
      d_ordinamento              VARCHAR2 (1) := NULL;
      d_categoria                VARCHAR2 (10) := NULL;
      d_desktop                  VARCHAR2 (10) := NULL;
      d_stato                    VARCHAR2 (100);
      d_id_attivita              NUMBER;
      d_class_cod                VARCHAR2 (100);
      --d_class_dal                DATE;
      d_fascicolo_anno           NUMBER;
      d_fascicolo_numero         VARCHAR2 (100);
      d_url_exec                 VARCHAR2 (500);
      d_idrif                    VARCHAR2 (32000);
      d_ufficio_competenza       seg_unita.unita%TYPE;
      d_area                     documenti.area%TYPE;
      d_codice_richiesta         documenti.codice_richiesta%TYPE;
      d_codice_modello           tipi_documento.nome%TYPE;
      d_utenti_notifica          VARCHAR2 (32000) := '@';
      d_codice_amm               VARCHAR2 (32000);
      d_codice_aoo               VARCHAR2 (32000);
      p_url_rif                  VARCHAR2 (32000);
      p_url_rif_desc             VARCHAR2 (32000);
      p_tooltip_url_exec         VARCHAR2 (32000);
      p_stato                    VARCHAR2 (32000);
      d_id_fascicolo             NUMBER;
      d_stato_pr                 VARCHAR2 (10) := 'NP';
      d_da_notificare            NUMBER := 1;
      d_id_viewcartella          NUMBER;
      d_unita_notifica           seg_unita.unita%TYPE;
      d_tipo_comp                VARCHAR2 (20);
      d_maschile_femminile       VARCHAR2 (1) := 'o';
      d_id_riferimento           VARCHAR2 (100)
         := TO_CHAR (SYSTIMESTAMP, 'yyyymmddhh24missff6');
      d_utente_aggiornamento     VARCHAR2 (100);
      d_esistenza_smistamento    NUMBER := 0;
   BEGIN
      DBMS_OUTPUT.put_line ('notifica_ins_doc_fasc ' || 1);

      BEGIN
         SELECT class_cod,
                fascicolo_anno,
                fascicolo_numero,
                seg_fascicoli.idrif,
                ufficio_competenza,
                seg_fascicoli.codice_amministrazione,
                seg_fascicoli.codice_aoo,
                seg_fascicoli.id_documento,
                view_cartella.id_viewcartella
           INTO d_class_cod,
                d_fascicolo_anno,
                d_fascicolo_numero,
                d_idrif,
                d_ufficio_competenza,
                d_codice_amm,
                d_codice_aoo,
                d_id_fascicolo,
                d_id_viewcartella
           FROM seg_fascicoli, cartelle, view_cartella
          WHERE     cartelle.id_cartella = p_id_cartella
                AND cartelle.id_documento_profilo =
                       seg_fascicoli.id_documento
                AND view_cartella.id_cartella = cartelle.id_cartella;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      DBMS_OUTPUT.put_line ('notifica_ins_doc_fasc ' || d_codice_amm);
      DBMS_OUTPUT.put_line ('notifica_ins_doc_fasc ' || d_codice_aoo);

      IF     ag_parametro.get_valore ('ITER_FASCICOLI',
                                      d_codice_amm,
                                      d_codice_aoo,
                                      'N') = 'Y'
         AND ag_parametro.get_valore ('NOTIFICA_INS_DOC_FASC',
                                      d_codice_amm,
                                      d_codice_aoo,
                                      'N') = 'Y'
      THEN
         DBMS_OUTPUT.put_line ('notifica_ins_doc_fasc ' || 3);

         BEGIN
            SELECT descrizione, stato_pr, utente_aggiornamento
              INTO d_descrizione_documento,
                   d_stato_pr,
                   d_utente_aggiornamento
              FROM (SELECT    'Il PG '
                           || anno
                           || '/'
                           || numero
                           || ' '
                           || oggetto
                              descrizione,
                           stato_pr,
                           d.utente_aggiornamento
                      FROM proto_view p, documenti d
                     WHERE     p.id_documento = p_id_documento
                           AND d.id_documento = p.id_documento
                           AND ag_utilities.verifica_categoria_documento (
                                  p_id_documento,
                                  'ATTI') = 0
                           AND NVL (stato_pr, 'DP') != 'DP'
                    UNION
                    SELECT    'Il documento '
                           || DECODE (DATA,
                                      NULL, '',
                                      'del ' || TO_CHAR (DATA, 'dd/mm/yyyy'))
                           || DECODE (oggetto,
                                      NULL, '',
                                      ' con oggetto ' || oggetto),
                           NULL,
                           d.utente_aggiornamento
                      FROM spr_da_fascicolare p, documenti d
                     WHERE     p.id_documento = p_id_documento
                           AND d.id_documento = p.id_documento
                    UNION
                    SELECT 'Il messaggio con oggetto ' || oggetto,
                           NULL,
                           d.utente_aggiornamento
                      FROM seg_memo_protocollo m, documenti d
                     WHERE     m.id_documento = p_id_documento
                           AND d.id_documento = m.id_documento);

            DBMS_OUTPUT.put_line ('d_stato_pr ' || d_stato_pr);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line ('1 ' || SQLERRM);

               DECLARE
                  esiste_atti   NUMBER := 0;
                  d_stmt        VARCHAR2 (32000);
               BEGIN
                  SELECT 1
                    INTO esiste_atti
                    FROM categorie
                   WHERE categoria = 'ATTI';

                  d_stmt :=
                        'select nvl(blocco_vis_dete, tipo_atto||'' ''||decode(n_determina,null,n_proposta||''/''||anno_proposta,n_determina||''/''||anno_determina||'' (''||tipo_registro||'')'' )) from atti_view where  id_documento = '
                     || p_id_documento;
                  d_maschile_femminile := 'a';

                  EXECUTE IMMEDIATE d_stmt INTO d_descrizione_documento;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     DBMS_OUTPUT.put_line ('2 ' || SQLERRM);
                     d_descrizione_documento := NULL;
                     d_maschile_femminile := 'o';
               END;
         END;

         DBMS_OUTPUT.put_line ('notifica_ins_doc_fasc ' || 4);

         IF     NVL (d_descrizione_documento, '*') = '*'
            AND ag_utilities.verifica_categoria_documento (p_id_documento,
                                                           'PROTO') = 0
         THEN
            d_descrizione_documento :=
               'Il documento identificato da ' || p_id_documento;
         END IF;

         IF d_descrizione_documento IS NULL
         THEN
            RETURN;
         END IF;

         DBMS_OUTPUT.put_line ('4');

         BEGIN
            FOR s
               IN (SELECT documenti.area,
                          documenti.codice_richiesta,
                          tipi_documento.nome,
                          ufficio_smistamento uff_carico,
                          'CARICO' tipo_comp
                     FROM seg_smistamenti, documenti, tipi_documento
                    WHERE     idrif = d_idrif
                          AND stato_smistamento IN ('C', 'E')
                          AND tipo_smistamento = 'COMPETENZA'
                          AND seg_smistamenti.id_documento =
                                 documenti.id_documento
                          AND documenti.stato_documento NOT IN ('CA',
                                                                'RE',
                                                                'PB')
                          AND documenti.id_tipodoc =
                                 tipi_documento.id_tipodoc)
            LOOP
               DBMS_OUTPUT.put_line ('uff_carico ' || s.uff_carico);
               DBMS_OUTPUT.put_line ('AREA ' || s.area);
               DBMS_OUTPUT.put_line ('CM ' || s.nome);
               DBMS_OUTPUT.put_line ('CR ' || s.codice_richiesta);
               d_utenti_notifica :=
                  get_utenti_accesso_smistamento (s.area,
                                                  s.nome,
                                                  s.codice_richiesta);
               d_tipo_comp := s.tipo_comp;
               d_unita_notifica := s.uff_carico;
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
               d_utenti_notifica := '@';
         END;

         DBMS_OUTPUT.put_line ('3');
         DBMS_OUTPUT.put_line ('   d_utenti_notifica ' || d_utenti_notifica);
         DBMS_OUTPUT.put_line ('   d_idrif ' || d_idrif);

         IF NVL (d_utenti_notifica, '@') = '@'
         THEN
            BEGIN
               SELECT documenti.area,
                      documenti.codice_richiesta,
                      tipi_documento.nome
                 INTO d_area, d_codice_richiesta, d_codice_modello
                 FROM seg_smistamenti, documenti, tipi_documento
                WHERE     idrif = d_idrif
                      AND stato_smistamento IN ('R')
                      AND tipo_smistamento = 'COMPETENZA'
                      AND seg_smistamenti.id_documento =
                             documenti.id_documento
                      AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND documenti.id_tipodoc = tipi_documento.id_tipodoc
                      AND ROWNUM = 1;

               --se lo smistamento per comp è in stato R
               -- non si manda nessuna notifica
               d_utenti_notifica := '@';
               d_da_notificare := 0;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_utenti_notifica := '@';
            END;
         END IF;

         DBMS_OUTPUT.put_line ('   d_da_notificare ' || d_da_notificare);
         DBMS_OUTPUT.put_line ('   d_utenti_notifica ' || d_utenti_notifica);
         DBMS_OUTPUT.put_line (
            '   d_ufficio_competenza ' || d_ufficio_competenza);

         -- se non c'è uno smistamento per comp
         -- attivo, si manda notifica all'uff competente
         -- cioè agli utenti con CREF dell'ufficio competente
         IF NVL (d_utenti_notifica, '@') = '@' AND d_da_notificare = 1
         THEN
            IF d_ufficio_competenza IS NOT NULL
            THEN
               d_tipo_comp := 'COMPETENTE';
               d_unita_notifica := d_ufficio_competenza;
               d_utenti_notifica :=
                  ag_competenze_fascicolo.get_utenti_cref_uff_competenza (
                     d_ufficio_competenza);
            END IF;
         END IF;

         DBMS_OUTPUT.put_line ('   d_utenti_notifica ' || d_utenti_notifica);

         BEGIN
            SELECT DISTINCT 1
              INTO d_esistenza_smistamento
              FROM seg_smistamenti, documenti, proto_view
             WHERE     proto_view.idrif = seg_smistamenti.idrif
                   AND stato_smistamento IN ('R', 'C')
                   AND seg_smistamenti.id_documento = documenti.id_documento
                   AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND proto_view.id_documento = p_id_documento
                   AND tipo_smistamento != 'DUMMY'
                   AND ufficio_smistamento = d_unita_notifica --AND codice_assegnatario IS NULL
                                                             ;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_esistenza_smistamento := 0;
         END;

         DBMS_OUTPUT.put_line (
            '   d_esistenza_smistamento ' || d_esistenza_smistamento);
         DBMS_OUTPUT.put_line (
            '    d_utente_aggiornamento ' || d_utente_aggiornamento);
         DBMS_OUTPUT.put_line ('    d_da_notificare ' || d_da_notificare);

         IF     d_esistenza_smistamento = 0
            AND NVL (d_utenti_notifica, '@') != '@'
            AND d_da_notificare = 1
            AND INSTR (d_utenti_notifica,
                       '@' || d_utente_aggiornamento || '@') = 0
         THEN
            d_attivita_descrizione :=
                  d_descrizione_documento
               || ' e'' stat'
               || d_maschile_femminile
               || ' inserit'
               || d_maschile_femminile
               || ' nel fascicolo '
               || d_class_cod
               || ' - '
               || d_fascicolo_anno
               || '/'
               || d_fascicolo_numero;

            DBMS_OUTPUT.put_line (
               '    d_attivita_descrizione ' || d_attivita_descrizione);

            p_url_rif_desc :=
                  'Visualizza fascicolo '
               || d_class_cod
               || ' - '
               || d_fascicolo_anno
               || '/'
               || d_fascicolo_numero;

            DBMS_OUTPUT.put_line ('    p_url_rif_desc ' || p_url_rif_desc);

            d_tooltip_attivita_descr := d_attivita_descrizione;
            d_url_exec :=
               ag_utilities.get_url_oggetto ('',
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
                                             'N',
                                             'N');

            DBMS_OUTPUT.put_line ('    d_url_exec ' || d_url_exec);

            p_url_rif :=
               ag_utilities.get_url_oggetto ('',
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
                                             'N',
                                             'N');
            --D_URL_EXEC:='http://svi-ora03/jdms/common/DocumentoView.do?idDoc=12541588&rw=R&cm=M_PROTOCOLLO&area=SEGRETERIA.PROTOCOLLO&cr=DMSERVER12528405&idCartProveninez=&idQueryProveninez=10000998&Provenienza=D&stato=BO&MVPG=ServletModulisticaDocumento&GDC_Link=../common/ClosePageAndRefresh.do%3FidQueryProveninez%3D10000998';
            DBMS_OUTPUT.put_line ('d_url_exec ' || d_url_exec);

            FOR u
               IN (SELECT utente
                     FROM ad4_utenti
                    WHERE INSTR (d_utenti_notifica, '@' || utente || '@') > 0)
            LOOP
               IF     gdm_competenza.gdm_verifica ('DOCUMENTI',
                                                   p_id_documento,
                                                   'L',
                                                   u.utente,
                                                   'GDM') = 1
                  AND gdm_competenza.gdm_verifica ('VIEW_CARTELLA',
                                                   d_id_viewcartella,
                                                   'L',
                                                   u.utente,
                                                   'GDM') = 1
               THEN
                  DBMS_OUTPUT.put_line (
                     'p_id_riferimento ' || p_id_documento);
                  DBMS_OUTPUT.put_line (
                     'p_attivita_descrizione ' || d_attivita_descrizione);
                  DBMS_OUTPUT.put_line (
                     'p_tooltip_attivita_descr ' || d_tooltip_attivita_descr);
                  DBMS_OUTPUT.put_line ('p_url_rif ' || p_url_rif);
                  DBMS_OUTPUT.put_line ('p_url_rif_desc ' || p_url_rif_desc);
                  DBMS_OUTPUT.put_line ('p_url_exec ' || d_url_exec);
                  DBMS_OUTPUT.put_line (
                     'p_tooltip_url_exec ' || 'Visualizza documento');
                  DBMS_OUTPUT.put_line ('p_scadenza ' || NULL);
                  DBMS_OUTPUT.put_line (
                     'p_param_init_iter ' || d_param_init_iter);
                  DBMS_OUTPUT.put_line ('p_nome_iter ' || d_nome_iter);
                  DBMS_OUTPUT.put_line (
                        'p_descrizione_iter '
                     || 'Notifica di inserimento documenti in fascicolo');
                  DBMS_OUTPUT.put_line ('p_colore ' || d_colore);
                  DBMS_OUTPUT.put_line ('p_ordinamento ' || d_ordinamento);
                  DBMS_OUTPUT.put_line ('p_data_attivazione ' || SYSDATE);
                  DBMS_OUTPUT.put_line ('p_utente_esterno ' || u.utente);
                  DBMS_OUTPUT.put_line ('p_categoria ' || d_categoria);
                  DBMS_OUTPUT.put_line ('p_desktop ' || d_desktop);
                  DBMS_OUTPUT.put_line ('p_stato ' || p_stato);
                  DBMS_OUTPUT.put_line ('p_tipologia ' || d_tipologia);
                  DBMS_OUTPUT.put_line ('p_espressione ' || 'TODO');
                  DBMS_OUTPUT.put_line (
                     'p_messaggio_todo ' || d_attivita_descrizione);
                  --                  d_id_attivita :=
                  --                     jwf_utility.f_crea_task_esterno (
                  --                        p_id_riferimento           => d_id_riferimento,
                  --                        p_attivita_descrizione     => d_attivita_descrizione,
                  --                        p_tooltip_attivita_descr   => d_tooltip_attivita_descr,
                  --                        p_url_rif                  => p_url_rif,
                  --                        p_url_rif_desc             => p_url_rif_desc,
                  --                        p_url_exec                 => d_url_exec,
                  --                        p_tooltip_url_exec         => 'Visualizza documento',
                  --                        p_scadenza                 => NULL,
                  --                        p_param_init_iter          => d_param_init_iter,
                  --                        p_nome_iter                => d_nome_iter,
                  --                        p_descrizione_iter         => 'Notifica di inserimento documenti in fascicolo',
                  --                        p_colore                   => d_colore,
                  --                        p_ordinamento              => d_ordinamento,
                  --                        p_data_attivazione         => SYSDATE,
                  --                        p_utente_esterno           => u.utente,
                  --                        p_categoria                => d_categoria,
                  --                        p_desktop                  => d_desktop,
                  --                        p_stato                    => p_stato,
                  --                        p_tipologia                => d_tipologia,
                  --                        p_espressione              => 'TODO',
                  --                        p_messaggio_todo           => d_attivita_descrizione,
                  --                        p_dati_applicativi_1       => p_id_documento,
                  --                        p_dati_applicativi_2       => p_id_cartella,
                  --                        p_dati_applicativi_3       =>    d_tipo_comp
                  --                                                      || '#'
                  --                                                      || d_unita_notifica);
                  d_id_attivita :=
                     crea_task_esterno_TODO (
                        P_ID_RIFERIMENTO           => d_id_riferimento,
                        P_ATTIVITA_DESCRIZIONE     => d_attivita_descrizione,
                        P_TOOLTIP_ATTIVITA_DESCR   => d_tooltip_attivita_descr,
                        P_URL_RIF                  => p_url_rif,
                        P_URL_RIF_DESC             => p_url_rif_desc,
                        P_URL_EXEC                 => d_url_exec,
                        P_TOOLTIP_URL_EXEC         => 'Visualizza documento',
                        P_DATA_SCAD                => NULL,
                        P_PARAM_INIT_ITER          => d_param_init_iter,
                        P_NOME_ITER                => d_nome_iter,
                        P_DESCRIZIONE_ITER         => 'Notifica di inserimento documenti in fascicolo',
                        P_COLORE                   => d_colore,
                        P_ORDINAMENTO              => d_ordinamento,
                        P_UTENTE_ESTERNO           => u.utente,
                        P_CATEGORIA                => d_categoria,
                        P_DESKTOP                  => d_desktop,
                        P_STATO                    => p_stato,
                        P_TIPOLOGIA                => d_tipologia,
                        P_DATIAPPLICATIVI1         => p_id_documento,
                        P_DATIAPPLICATIVI2         => p_id_cartella,
                        P_DATIAPPLICATIVI3         => d_tipo_comp,
                        P_TIPO_BOTTONE             => d_tipologia,
                        P_DATA_ATTIVAZIONE         => SYSDATE,
                        P_DES_DETTAGLIO_1          => 'Motivo notifica',
                        P_DETTAGLIO_1              => d_attivita_descrizione);
                  DBMS_OUTPUT.put_line ('d_id_attivita ' || d_id_attivita);
               END IF;
            END LOOP;
         END IF;
      END IF;

      DBMS_OUTPUT.put_line (d_id_attivita);
   END;

   FUNCTION istanzia_iter (p_nome_iter    VARCHAR2,
                           p_parametri    VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      RETURN jwf_utility.istanzia_iter (
                nome_iter       => p_nome_iter,
                parametri       => p_parametri,
                utente          => ag_utilities.utente_superuser_segreteria,
                esegui_commit   => 1);
   END;

   FUNCTION istanzia_iter_e_termina (p_nome_iter    VARCHAR2,
                                     p_parametri    VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      retval   NUMBER;
   BEGIN
      retval := istanzia_iter (p_nome_iter, p_parametri);

      IF retval = 1
      THEN
         RETURN    '<FUNCTION_OUTPUT>'
                || '<RESULT>ok</RESULT>'
                || '<DOC>'
                || 'Iter correttamente istanziato'
                || '</DOC>'
                || '</FUNCTION_OUTPUT>';
      ELSE
         raise_application_error (-20999, 'Iter non istanziato');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN    '<FUNCTION_OUTPUT>'
                || '<RESULT>nonok</RESULT>'
                || '<ERROR>'
                || SQLERRM
                || '</ERROR>'
                || '</FUNCTION_OUTPUT>';
   END;

   /******************************************************************************
    NOME:        is_rapporto
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: Verifica se il documento identificato da p_id_documento e' un rapporto.
    RITORNA:     number 1 se e' un rapporto, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_rapporto (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM seg_soggetti_protocollo
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   PROCEDURE crea_notifica_annullamento (
      p_id_documento               NUMBER,
      p_utente_notifica            VARCHAR2,
      p_descrizione_documento      VARCHAR2,
      p_note                       VARCHAR2,
      p_accettato               IN NUMBER)
   IS
      d_tipologia                VARCHAR2 (2000);
      d_attivita_descrizione     VARCHAR2 (32000);
      d_tooltip_attivita_descr   VARCHAR2 (32000);
      d_param_init_iter          VARCHAR2 (200) := d_tipologia;
      d_nome_iter                VARCHAR2 (100) := d_tipologia;
      d_descrizione_iter         VARCHAR2 (2000) := NULL;
      d_data_scad                DATE;
      d_colore                   VARCHAR2 (15) := NULL;
      d_ordinamento              VARCHAR2 (1) := NULL;
      d_categoria                VARCHAR2 (10) := NULL;
      d_desktop                  VARCHAR2 (10) := NULL;
      d_stato                    VARCHAR2 (100);
      d_id_attivita              NUMBER;
      d_url_exec                 VARCHAR2 (500);

      p_tooltip_url_exec         VARCHAR2 (32000);
      d_id_riferimento           VARCHAR2 (100)
         := TO_CHAR (SYSTIMESTAMP, 'yyyymmddhh24missff6');
   BEGIN
      IF p_accettato = 0
      THEN
         d_tipologia := 'RIFIUTA_RICHIESTA_ANNULLAMENTO';
      ELSE
         d_tipologia := 'ACCETTAZIONE_RICHIESTA_ANNULLAMENTO';
      END IF;


      /*
      La richiesta di annullamento del documento n° :$DOCMASTER->NUMERO/:$DOCMASTER->ANNO è stata accettata. L'annullamento avverrà con successivo Provvedimento
      Notifica accettazione richiesta di annullamento per il documento n° :$DOCMASTER->NUMERO/:$DOCMASTER->ANNO

      La richiesta di annullamento del documento n° :$PROTOCOLLO->NUMERO/:$PROTOCOLLO->ANNO è stata rifiutata con la seguente motivazione :$DOCMASTER->NOTE
      Notifica rifiuto richiesta di annullamento per il documento n° :$PROTOCOLLO->NUMERO/:$PROTOCOLLO->ANNO
      */


      IF NVL (p_utente_notifica, '@') != '@'
      THEN
         /*
         La richiesta di annullamento del documento n° :$DOCMASTER->NUMERO/:$DOCMASTER->ANNO è stata accettata. L'annullamento avverrà con successivo Provvedimento
         Notifica accettazione richiesta di annullamento per il documento n° :$DOCMASTER->NUMERO/:$DOCMASTER->ANNO

         La richiesta di annullamento del documento n° :$PROTOCOLLO->NUMERO/:$PROTOCOLLO->ANNO è stata rifiutata con la seguente motivazione :$DOCMASTER->NOTE
         Notifica rifiuto richiesta di annullamento per il documento n° :$PROTOCOLLO->NUMERO/:$PROTOCOLLO->ANNO
         */

         d_attivita_descrizione :=
               'La richiesta di annullamento del documento n. '
            || p_descrizione_documento
            || ' e'' stata ';

         d_descrizione_iter := 'Notifica ';

         IF p_accettato = 0
         THEN
            d_attivita_descrizione :=
                  d_attivita_descrizione
               || 'rifiutata con la seguente motivazione: '
               || p_note;
            d_descrizione_iter := d_descrizione_iter || 'rifiuto ';
         ELSE
            d_attivita_descrizione :=
                  d_attivita_descrizione
               || 'accettata. L''annullamento avverra'' con successivo Provvedimento';
            d_descrizione_iter := d_descrizione_iter || 'accettazione ';
         END IF;

         d_descrizione_iter :=
               d_descrizione_iter
            || 'richiesta di annullamento per il documento n. '
            || p_descrizione_documento;

         d_tooltip_attivita_descr := d_attivita_descrizione;
         d_url_exec :=
            ag_utilities.get_url_oggetto ('',
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
                                          'N',
                                          'N');
         DBMS_OUTPUT.put_line (
            'd_attivita_descrizione ' || d_attivita_descrizione);
         DBMS_OUTPUT.put_line ('p_id_documento ' || p_id_documento);

         --         d_id_attivita :=
         --            jwf_utility.f_crea_task_esterno (
         --               p_id_riferimento           => d_id_riferimento,
         --               p_attivita_descrizione     => d_attivita_descrizione,
         --               p_tooltip_attivita_descr   => d_tooltip_attivita_descr,
         --               p_url_rif                  => '',
         --               p_url_rif_desc             => '',
         --               p_url_exec                 => d_url_exec,
         --               p_tooltip_url_exec         => 'Visualizza documento',
         --               p_scadenza                 => NULL,
         --               p_param_init_iter          => d_param_init_iter,
         --               p_nome_iter                => d_nome_iter,
         --               p_descrizione_iter         => d_descrizione_iter,
         --               p_colore                   => d_colore,
         --               p_ordinamento              => d_ordinamento,
         --               p_data_attivazione         => SYSDATE,
         --               p_utente_esterno           => p_utente_notifica,
         --               p_categoria                => d_categoria,
         --               p_desktop                  => d_desktop,
         --               p_stato                    => NULL,
         --               p_tipologia                => d_tipologia,
         --               p_espressione              => 'TODO',
         --               p_messaggio_todo           => d_attivita_descrizione,
         --               p_dati_applicativi_2       => '',
         --               p_dati_applicativi_3       => '');
         d_id_attivita :=
            crea_task_esterno_TODO (
               P_ID_RIFERIMENTO           => d_id_riferimento,
               P_ATTIVITA_DESCRIZIONE     => d_attivita_descrizione,
               P_TOOLTIP_ATTIVITA_DESCR   => d_tooltip_attivita_descr,
               P_URL_RIF                  => '',
               P_URL_RIF_DESC             => '',
               P_URL_EXEC                 => d_url_exec,
               P_TOOLTIP_URL_EXEC         => 'Visualizza documento',
               P_DATA_SCAD                => NULL,
               P_PARAM_INIT_ITER          => d_param_init_iter,
               P_NOME_ITER                => d_nome_iter,
               P_DESCRIZIONE_ITER         => d_descrizione_iter,
               P_COLORE                   => d_colore,
               P_ORDINAMENTO              => d_ordinamento,
               P_UTENTE_ESTERNO           => p_utente_notifica,
               P_CATEGORIA                => d_categoria,
               P_DESKTOP                  => d_desktop,
               P_STATO                    => NULL,
               P_TIPOLOGIA                => d_tipologia,
               P_DATIAPPLICATIVI1         => '',
               P_DATIAPPLICATIVI2         => '',
               P_DATIAPPLICATIVI3         => '',
               P_TIPO_BOTTONE             => 'NOTIFICA_ANN',
               P_DATA_ATTIVAZIONE         => SYSDATE,
               P_DES_DETTAGLIO_1          => 'Motivo notifica',
               P_DETTAGLIO_1              => d_attivita_descrizione,
               P_ID_DOCUMENTO             => p_id_documento);
      END IF;

      DBMS_OUTPUT.put_line (d_id_attivita);
   END;

   PROCEDURE notifica_rifiuto_annullamento (p_id_note NUMBER)
   IS
      d_note                    VARCHAR2 (32000);
      d_id_documento            NUMBER;
      d_descrizione_documento   VARCHAR2 (100);
      d_utente_notifica         VARCHAR2 (32000) := '@';
      d_da_notificare           NUMBER := 1;
   BEGIN
      BEGIN
         SELECT n.utente_richiesta_ann,
                n.note,
                p.id_documento,
                p.numero || '/' || p.anno
           INTO d_utente_notifica,
                d_note,
                d_id_documento,
                d_descrizione_documento
           FROM seg_note n, proto_view p
          WHERE n.id_documento = p_id_note AND p.idrif = n.idrif;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_utente_notifica := '@';
            d_da_notificare := 0;
      END;

      DBMS_OUTPUT.put_line ('   d_utente_notifica ' || d_utente_notifica);

      IF NVL (d_utente_notifica, '@') != '@' AND d_da_notificare = 1
      THEN
         crea_notifica_annullamento (d_id_documento,
                                     d_utente_notifica,
                                     d_descrizione_documento,
                                     d_note,
                                     0);
      END IF;
   END;

   PROCEDURE notifica_accettazione_ann (p_id_documento NUMBER)
   IS
      d_utente_notifica         VARCHAR2 (32000) := '@';
      d_descrizione_documento   VARCHAR2 (100);
   BEGIN
      SELECT UTENTE_RICHIESTA_ANN, numero || '/' || anno
        INTO d_utente_notifica, d_descrizione_documento
        FROM proto_view
       WHERE id_documento = p_id_documento;

      IF NVL (d_utente_notifica, '@') != '@'
      THEN
         crea_notifica_annullamento (p_id_documento,
                                     d_utente_notifica,
                                     d_descrizione_documento,
                                     '',
                                     1);
      END IF;
   END;

   FUNCTION attiva_flusso_SU (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      d_num        NUMBER;
      d_nomeiter   VARCHAR2 (100) := 'STAMPA_UNICA';
      d_area       VARCHAR2 (100);
      d_cm         VARCHAR2 (100);
      d_cr         VARCHAR2 (100);
      retval       VARCHAR2 (1000) := '';
   BEGIN
      retval :=
            '<FUNCTION_OUTPUT>'
         || '<RESULT>ok</RESULT>'
         || '<FORCE_REDIRECT/>'
         || '<REDIRECT/>'
         || '<DOC>'
         || '</DOC>'
         || '</FUNCTION_OUTPUT>';

      BEGIN
         SELECT d.area, d.codice_richiesta, t.nome
           INTO d_area, d_cr, d_cm
           FROM documenti d, tipi_documento t, proto_view p
          WHERE     d.id_documento = p_id_documento
                AND d.id_tipodoc = t.id_tipodoc
                AND p.id_documento = d.id_documento
                AND p.anno IS NOT NULL
                AND p.numero IS NOT NULL;

         d_num :=
            jwf_utility.istanzia_iter (
               NULL,
               d_nomeiter,
               '#@#area=' || d_area || '#@#cm=' || d_cm || '#@#cr=' || d_cr,
               NULL,
               p_utente,
               1);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval :=
                  '<FUNCTION_OUTPUT>'
               || '<RESULT>nonok</RESULT>'
               || '<ERROR>Attenzione: '
               || 'protocollo con id '
               || p_id_documento
               || ' non esistente o non ancora numerato.'
               || '</ERROR>'
               || '</FUNCTION_OUTPUT>';
         WHEN OTHERS
         THEN
            retval :=
                  '<FUNCTION_OUTPUT>'
               || '<RESULT>nonok</RESULT>'
               || '<ERROR>Attenzione: '
               || SQLERRM
               || '</ERROR>'
               || '</FUNCTION_OUTPUT>';
      END;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         retval :=
               '<FUNCTION_OUTPUT>'
            || '<RESULT>nonok</RESULT>'
            || '<ERROR>Attenzione: '
            || 'Errore nella creazione del flusso'
            || '</ERROR>'
            || '</FUNCTION_OUTPUT>';
         RETURN retval;
   END attiva_flusso_SU;

   FUNCTION ADD_SERVER_TO_URL (P_URL VARCHAR2)
      RETURN VARCHAR2
   AS
      dep_url          VARCHAR2 (32000);
      dep_server_url   VARCHAR2 (1000);
   BEGIN
      dep_server_url := ag_parametro.get_valore ('AG_SERVER_URL', '@ag@');

      IF     (   INSTR (p_url, dep_server_url) = 0
              OR INSTR (p_url, dep_server_url) > 1)
         AND INSTR (p_url, '../') = 1
      THEN
         dep_url := LTRIM (p_url, '../');
         dep_url := dep_server_url || '/' || dep_url;
      ELSE
         dep_url := p_url;
      END IF;

      RETURN dep_url;
   END;

   PROCEDURE ADD_FILE_SMARTDESKTOP (
      P_ID_PROTOCOLLO   IN NUMBER,
      P_TOOLTIP            VARCHAR2 DEFAULT 'File principale',
      P_PRIORITA           NUMBER DEFAULT 1)
   AS
      dep_id_allegato      NUMBER;
      dep_url_server       VARCHAR2 (32000);
      dep_url_principale   VARCHAR2 (32000);
      dep_s_firmato        VARCHAR2 (10);
      dep_ver_firma        VARCHAR2 (1);
      dep_n_firmato        NUMBER;
      dep_file_scartato    VARCHAR2 (32000);
      dep_nome_file        VARCHAR2 (32000);
      dep_stmt             VARCHAR2 (32000);
   BEGIN
      dep_url_server := '..'; --ag_parametro.get_valore('AG_SERVER_URL', '@ag@');

      FOR f
         IN (SELECT ID_OGGETTO_FILE, filename
               FROM oggetti_file
              WHERE     id_documento = P_ID_PROTOCOLLO
                    AND filename <> 'LETTERAUNIONE.RTFHIDDEN')
      LOOP
         dep_id_allegato := f.ID_OGGETTO_FILE;
         dep_nome_file := f.filename;

         IF INSTR (LOWER (dep_nome_file), '.p7m') > 0
         THEN
            dep_s_firmato := 'F';
         ELSE
            dep_s_firmato :=
               NVL (f_valore_campo (P_ID_PROTOCOLLO, 'STATO_FIRMA'), 'N');
         END IF;

         dep_ver_firma :=
            NVL (f_valore_campo (P_ID_PROTOCOLLO, 'VERIFICA_FIRMA'), 'N');

         IF dep_s_firmato = 'F' OR dep_ver_firma != 'N'
         THEN
            dep_s_firmato := '&firma=S';
            dep_n_firmato := 1;
         ELSE
            dep_s_firmato := NULL;
            dep_n_firmato := 0;
         END IF;

         dep_url_principale :=
               dep_url_server
            || ag_utilities.servletVisualizza
            || 'iddoc='
            || P_ID_PROTOCOLLO
            || '&ca='
            || dep_id_allegato
            || dep_s_firmato;
         dep_stmt :=
               'begin jwf_worklist_services.AGGIUNGI_ALLEGATO('
            || '  P_ETICHETTA => '''
            || dep_nome_file
            || ''''
            || ', P_TOOLTIP => '''
            || P_TOOLTIP
            || ''''
            || ', P_NOMEFILE => '''
            || dep_nome_file
            || ''''
            || ', P_URL => '''
            || dep_url_principale
            || ''''
            || ', P_PRIORITA => '
            || P_PRIORITA
            || ', P_MIMETYPE => NULL'
            || ', P_FIRMATO => '
            || dep_n_firmato
            || '); end;';

         EXECUTE IMMEDIATE dep_stmt;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         dep_url_principale := NULL;
   END ADD_FILE_SMARTDESKTOP;

   PROCEDURE RIMUOVI_TUTTO_SMARTDESKTOP
   AS
      dep_id_allegato      NUMBER;
      dep_url_server       VARCHAR2 (32000);
      dep_url_principale   VARCHAR2 (32000);
      dep_s_firmato        VARCHAR2 (10);
      dep_ver_firma        VARCHAR2 (1);
      dep_n_firmato        NUMBER;
      dep_file_scartato    VARCHAR2 (32000);
      dep_nome_file        VARCHAR2 (32000);
      dep_stmt             VARCHAR2 (32000)
         := 'begin jwf_worklist_services.rimuovi_tutto(); end;';
   BEGIN
      EXECUTE IMMEDIATE dep_stmt;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END RIMUOVI_TUTTO_SMARTDESKTOP;



   /*****************************************************************************
       NOME:        crea_task_esterno_TODO.
       DESCRIZIONE: Crea task_esterno JWF_WORKLIST_SERVICES
                    e bottone in multiselezione per eliminare le
                    attività TODO se esiste JWF_WORKLIST_SERVICES,
                    altrimenti crea attività TODO classica.

      Rev.  Data        Autore      Descrizione.
      006   14/12/2017 SC       Adeguamento SmartDesktop

   ********************************************************************************/
   FUNCTION crea_task_esterno_TODO (
      P_ID_RIFERIMENTO           IN VARCHAR2,
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
      P_TIPOLOGIA                IN VARCHAR2,
      P_DATIAPPLICATIVI1         IN VARCHAR2,
      P_DATIAPPLICATIVI2         IN VARCHAR2,
      P_DATIAPPLICATIVI3         IN VARCHAR2,
      P_TIPO_BOTTONE             IN VARCHAR2,
      P_DATA_ATTIVAZIONE         IN DATE,
      P_DES_DETTAGLIO_1          IN VARCHAR2,
      P_DETTAGLIO_1              IN VARCHAR2,
      P_ID_DOCUMENTO             IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      d_id_attivita      NUMBER;
      dep_stmt           VARCHAR2 (32000);
      dep_ente           VARCHAR2 (1000);
      dep_des_ente       VARCHAR2 (1000);
      d_id_riferimento   NUMBER
         := NVL (p_id_riferimento,
                 TO_CHAR (SYSTIMESTAMP, 'yyyymmddhh24missff6'));
      dep_url_exec       VARCHAR2 (32000);
      dep_url_rif        VARCHAR2 (32000);
      dep_url_servlet    VARCHAR2 (32000);
      dep_file_ini       VARCHAR2 (32000);
      dep_id_documento   NUMBER := NVL (P_ID_DOCUMENTO, p_id_riferimento); --in alcuni casi in p_id_riferimento mettiamo una stringa univoca
                                               -- che non è l'id del documento
             -- in tal caso per cercare gli allegati devo usare P_ID_DOCUMENTO
   BEGIN
      dep_url_servlet :=
            '../agspr/WorklistAllegatiServlet?idDocumento='
         || dep_id_documento
         || '&utente='
         || p_utente_esterno;
      DBMS_OUTPUT.PUT_LINE (
         'CREA_TASK_ESTERNO p_id_documento ' || p_id_documento);
      DBMS_OUTPUT.PUT_LINE (
         'CREA_TASK_ESTERNO dep_id_documento ' || dep_id_documento);
      dep_file_ini := ag_parametro.get_valore ('FILE_GDM_INI', '@agStrut@');
      dep_url_exec := ADD_SERVER_TO_URL (p_url_exec);
      dep_url_rif := ADD_SERVER_TO_URL (p_url_rif);

      IF ag_utilities.EXISTS_SMART_DESKTOP = 1
      THEN
         DBMS_OUTPUT.put_line ('crea_task_esterno_new 1');
         dep_stmt := 'begin jwf_worklist_services.rimuovi_tutto(); end;';

         EXECUTE IMMEDIATE dep_stmt;

         --add_file_smartdesktop(P_ID_RIFERIMENTO);
         DBMS_OUTPUT.put_line ('crea_task_esterno_new 2');

         IF (P_DES_DETTAGLIO_1 IS NOT NULL)
         THEN
            dep_stmt :=
                  'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO('''
               || REPLACE (P_DES_DETTAGLIO_1, '''', '''''')
               || ''''
               || ', '''
               || REPLACE (P_DETTAGLIO_1, '''', '''''')
               || ''');'
               || 'end;';

            EXECUTE IMMEDIATE dep_stmt;
         END IF;

         /* if (dep_url_exec is not null) then
             dep_stmt := 'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Riferimento'''
                ||', '''||dep_url_exec||''', 1);'
                ||'end;';
             execute immediate dep_stmt;
          end if;*/
         DBMS_OUTPUT.put_line ('crea_task_esterno_new 3');

         --            if (NVL (p_datiapplicativi2,
         --                        TO_CHAR (p_datasmist, 'dd/mm/yyyy HH24:mi:ss')) is not null) then
         --               dep_dettaglio := TO_CHAR (p_datasmist, 'dd/mm/yyyy HH24:mi:ss');
         --               dep_stmt := 'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Data Prot.'''
         --                  ||', NVL ('''||p_datiapplicativi2||''','
         --                  ||''''||dep_dettaglio||'''));'
         --                  ||' end;';
         --               execute immediate dep_stmt;
         --            end if;
         --dbms_output.put_line('crea_task_esterno_new 4');
         --        if (P_PARAM_INIT_ITER is not null) then
         --           d_des_unita_ricevente := substr(P_PARAM_INIT_ITER, instr(P_PARAM_INIT_ITER, 'SMISTAMENTO a ')+14);
         --           dep_stmt := 'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Unita'''' ricevente'''
         --               ||', '''
         --               ||d_des_unita_ricevente||''');'
         --               ||' end;';
         --           execute immediate dep_stmt;
         --        end if;
         --dbms_output.put_line('crea_task_esterno_new 5');
         DECLARE
            dep_urlazione            VARCHAR2 (32000);
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

            BEGIN
               SELECT REPLACE (descrizione, '''', '''''')
                 INTO dep_des_ente
                 FROM ad4_enti
                WHERE ente = dep_ente;
            EXCEPTION
               WHEN OTHERS
               THEN
                  dep_des_ente := dep_ente;
            END;

            dep_nominativo := AD4_UTENTE.GET_NOMINATIVO (p_utente_esterno);
            DBMS_OUTPUT.put_line ('p_utente_esterno ' || p_utente_esterno);

            FOR bottone IN (  SELECT azione,
                                     tipo_azione,
                                     azione_multipla,
                                     label,
                                     tooltip,
                                     icona,
                                     modello,
                                     modello_azione,
                                     assegnazione
                                FROM seg_bottoni_notifiche
                               WHERE tipo = P_TIPO_BOTTONE
                            ORDER BY sequenza)
            LOOP
               dep_urlazione := 'TODO';
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
                  || d_id_riferimento
                  || ', '
                  || 'null);'
                  || ' end;';

               EXECUTE IMMEDIATE dep_stmt;
            END LOOP;


            DBMS_OUTPUT.PUT_LINE (
               'CREA_TASK_ESTERNO 5.2 ' || p_utente_esterno);
            DBMS_OUTPUT.put_line ('crea task esterno 5.3');
            DBMS_OUTPUT.put_line (
               REPLACE (SUBSTR (p_attivita_descrizione, 1, 4000),
                        '''',
                        ''''''));
         END;

         --http://svi-ora03:9080/agspr/WorklistAllegatiServlet?idDocumento=14387831&utente=ROMAGNOL&fileProp=/workarea/tomcat-7/webapps/jgdm/config/gd4dm.properties&tipoDoc=M
         IF dep_id_documento IS NOT NULL
         THEN
            BEGIN
               dep_url_servlet :=
                     dep_url_servlet
                  || '&fileProp='
                  || dep_file_ini
                  || '&tipoDoc=';

               IF AG_UTILITIES.VERIFICA_CATEGORIA_DOCUMENTO (
                     dep_id_documento,
                     'PROTO') = 1
               THEN
                  dep_url_servlet := dep_url_servlet || 'P';
               ELSIF AG_UTILITIES.VERIFICA_CATEGORIA_DOCUMENTO (
                        dep_id_documento,
                        'POSTA_ELETTRONICA') = 1
               THEN
                  dep_url_servlet := dep_url_servlet || 'M';
               ELSE
                  dep_url_servlet := dep_url_servlet || 'D';
               END IF;
            END;
         ELSE
            dep_url_servlet := NULL;
         END IF;

         dep_stmt :=
               'BEGIN '
            || ' :ID := jwf_worklist_services.CREA_ATTIVITA ( '
            || ' P_ID_RIFERIMENTO => '
            || d_id_riferimento
            || ', P_ATTIVITA_DESCRIZIONE => '
            || ''''
            || REPLACE (SUBSTR (p_attivita_descrizione, 1, 4000),
                        '''',
                        '''''')
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
            || p_param_init_iter
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
            || p_ordinamento
            || ''''
            || ', P_DATA_ATTIVAZIONE => '
            || 'to_date('''
            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ''', ''dd/mm/yyyy hh24:mi:ss'')'
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
            || p_stato
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
            || REPLACE (p_datiapplicativi2, '''', '''''')
            || ''''
            || ', P_DATI_APPLICATIVI_3 => '
            || ''''
            || REPLACE (p_datiapplicativi3, '''', '''''')
            || ''''
            || ', P_ESPRESSIONE => '
            || '''TODO'''
            || ', P_MESSAGGIO_TODO => '
            || ''''
            || REPLACE (p_dettaglio_1, '''', '''''')
            || ''''
            || ', P_DATA_ARRIVO => '
            || 'to_date('''
            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ''', ''dd/mm/yyyy hh24:mi:ss'')'
            || ', P_LIVELLO_PRIORITA => null'
            || ', P_NOTE => null'
            || ', P_APPLICATIVO => null'
            --|| '''Protocollo'''
            || ', P_ENTE => '
            || ''''
            || dep_des_ente
            || ''''
            || ', P_TIPOLOGIA_DESCR => null'
            || ', P_ORDINA_STRINGA_ETICHETTA => '
            || '''Ordina'''
            || ', P_ORDINA_STRINGA_VALORE => '
            || ''''
            || REPLACE (SUBSTR (p_datiapplicativi1, 1, 500), '''', '''''')
            || ''''
            || ', P_ORDINA_DATA_ETICHETTA => null'
            || ', P_ORDINA_DATA_VALORE => null'
            || ', P_ORDINA_NUMERO_ETICHETTA => null'
            || ', P_ORDINA_NUMERO_VALORE => null'
            || ', P_URL_ALLEGATI_DINAMICI => '''
            || dep_url_servlet
            || ''''
            || ');'
            || 'END;';

         --    INSERT INTO PROVA (
         --       TESTO)
         --    VALUES ( dep_stmt );
         --    commit;
         EXECUTE IMMEDIATE dep_stmt USING OUT d_id_attivita;
      ELSE
         d_id_attivita :=
            jwf_utility.f_crea_task_esterno (
               p_id_riferimento           => p_id_riferimento,
               p_attivita_descrizione     => p_attivita_descrizione,
               p_tooltip_attivita_descr   => p_tooltip_attivita_descr,
               p_url_rif                  => p_url_rif,
               p_url_rif_desc             => p_url_rif_desc,
               p_url_exec                 => p_url_exec,
               p_tooltip_url_exec         => p_tooltip_url_exec,
               p_scadenza                 => p_data_scad,
               p_param_init_iter          => p_param_init_iter,
               p_nome_iter                => p_nome_iter,
               p_descrizione_iter         => p_descrizione_iter,
               p_colore                   => p_colore,
               p_ordinamento              => p_ordinamento,
               p_data_attivazione         => p_data_attivazione,
               p_utente_esterno           => p_utente_esterno,
               p_categoria                => p_categoria,
               p_desktop                  => p_desktop,
               p_stato                    => p_stato,
               p_tipologia                => p_tipologia,
               p_espressione              => 'TODO',
               p_messaggio_todo           => P_DETTAGLIO_1,
               p_dati_applicativi_2       => p_datiapplicativi2,
               p_dati_applicativi_3       => p_datiapplicativi3);
      END IF;

      RETURN d_id_attivita;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END crea_task_esterno_TODO;

   FUNCTION GET_FILES_SMARTDESKTOP (P_ID_DOCUMENTO     IN NUMBER,
                                    P_TIPO_DOCUMENTO   IN VARCHAR2,
                                    P_INDEX            IN NUMBER,
                                    P_UTENTE           IN VARCHAR2)
      RETURN VARCHAR2
   AS
      dep_id_allegato      NUMBER;
      dep_url_server       VARCHAR2 (32000);
      dep_url_principale   VARCHAR2 (32000);
      dep_s_firmato        VARCHAR2 (10);
      dep_ver_firma        VARCHAR2 (1);
      dep_n_firmato        NUMBER;
      dep_file_scartato    VARCHAR2 (32000);
      dep_nome_file        VARCHAR2 (32000);
      dep_stmt             VARCHAR2 (32000);
      dep_conta            NUMBER := p_index;
      dep_tooltip          VARCHAR2 (32000);
      dep_tooltip_base     VARCHAR2 (32000) := 'Allegato';
      dep_priorita         NUMBER;
      dep_priorita_base    NUMBER := 3;
      dep_ret              VARCHAR2 (32000) := ' ';
      dep_id_documento     NUMBER := P_ID_DOCUMENTO;
   BEGIN
      --VERIFICO SE L'UTENTE PUO' VEDERE I FILE DEL DOCUMENTO
      IF     P_TIPO_DOCUMENTO IN ( 'P','D')
         AND gdm_competenza.gdm_verifica ('DOCUMENTI',
                                          P_ID_DOCUMENTO,
                                          'LA',
                                          P_UTENTE,
                                          'GDM',
                                          TO_CHAR (SYSDATE, 'dd/mm/yyyy')) =
                0
      THEN
         RETURN NULL;
      END IF;

      IF p_tipo_documento = 'M'
      THEN
         BEGIN
            SELECT id_documento_rif
              INTO dep_id_documento
              FROM riferimenti
             WHERE     id_documento = P_ID_DOCUMENTO
                   AND tipo_relazione = 'PRINCIPALE'
                   AND area = 'SEGRETERIA';
         EXCEPTION
            WHEN OTHERS
            THEN
               dep_id_documento := P_ID_DOCUMENTO;
         END;
      END IF;

      dep_url_server := '..'; --ag_parametro.get_valore('AG_SERVER_URL', '@ag@');

      FOR f
         IN (SELECT ID_OGGETTO_FILE, filename
               FROM oggetti_file
              WHERE     id_documento = dep_id_documento
                    AND filename <> 'LETTERAUNIONE.RTFHIDDEN')
      LOOP
         dep_id_allegato := f.ID_OGGETTO_FILE;
         dep_nome_file := f.filename;

         IF INSTR (LOWER (dep_nome_file), '.p7m') > 0
         THEN
            dep_s_firmato := 'F';
         ELSE
            dep_s_firmato :=
               NVL (f_valore_campo (dep_id_documento, 'STATO_FIRMA'), 'N');
         END IF;

         dep_ver_firma :=
            NVL (f_valore_campo (dep_id_documento, 'VERIFICA_FIRMA'), 'N');

         IF dep_s_firmato = 'F' OR dep_ver_firma != 'N'
         THEN
            dep_s_firmato := '&firma=S';
            dep_n_firmato := 1;
         ELSE
            dep_s_firmato := NULL;
            dep_n_firmato := 0;
         END IF;

         dep_conta := dep_conta + 1;

         IF P_TIPO_DOCUMENTO = 'P' AND dep_conta = 1
         THEN
            dep_tooltip := 'File principale';
            dep_priorita := 1;
         ELSE
            dep_tooltip := dep_tooltip_base;
            dep_priorita := dep_priorita_base;
         END IF;

         dep_url_principale :=
               dep_url_server
            || ag_utilities.servletVisualizza
            || 'iddoc='
            || dep_id_documento
            || '&ca='
            || dep_id_allegato
            || dep_s_firmato;

         dep_ret := dep_ret || '<allegato>';
         dep_ret := dep_ret || '<url>';
         dep_ret := dep_ret || '<![CDATA[';
         dep_ret := dep_ret || dep_url_principale;
         dep_ret := dep_ret || ']]>';
         dep_ret := dep_ret || '</url>';
         dep_ret := dep_ret || '<tooltip>';
         dep_ret := dep_ret || '<![CDATA[';
         dep_ret := dep_ret || dep_tooltip;
         dep_ret := dep_ret || ']]>';
         dep_ret := dep_ret || '</tooltip>';
         dep_ret := dep_ret || '<priorita>';
         dep_ret := dep_ret || dep_priorita;
         dep_ret := dep_ret || '</priorita>';
         dep_ret := dep_ret || '<nomeFile>';
         dep_ret := dep_ret || '<![CDATA[';
         dep_ret := dep_ret || dep_nome_file;
         dep_ret := dep_ret || ']]>';
         dep_ret := dep_ret || '</nomeFile>';
         dep_ret := dep_ret || '<nome>';
         dep_ret := dep_ret || '<![CDATA[';
         dep_ret := dep_ret || dep_nome_file;
         dep_ret := dep_ret || ']]>';
         dep_ret := dep_ret || '</nome>';
         dep_ret := dep_ret || '<firmato>';
         dep_ret := dep_ret || dep_n_firmato;
         dep_ret := dep_ret || '</firmato>';
         dep_ret := dep_ret || '<descrizione>';
         dep_ret := dep_ret || '<![CDATA[';
         dep_ret := dep_ret || dep_nome_file;
         dep_ret := dep_ret || ']]>';
         dep_ret := dep_ret || '</descrizione>';
         dep_ret := dep_ret || '<allegatiTaskIdx>';
         dep_ret := dep_ret || dep_conta;
         dep_ret := dep_ret || '</allegatiTaskIdx>';
         dep_ret := dep_ret || '</allegato>';
      END LOOP;

      RETURN TRIM (dep_ret);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_FILES_SMARTDESKTOP;


   FUNCTION GET_DENOMINAZIONE_CORR (P_ID_PROTOCOLLO IN VARCHAR2)
      RETURN VARCHAR2
   AS
      conta          NUMBER := 0;
      dep_mittdest   VARCHAR2 (32000) := '';
   BEGIN
      FOR rapporti
         IN (  SELECT sopr.id_documento,
                      DECODE (
                         sopr.cognome_per_segnatura,
                         NULL, NVL (
                                  sopr.denominazione_per_segnatura,
                                     descrizione_amm
                                  || DECODE (descrizione_aoo,
                                             NULL, '',
                                             ' - ' || descrizione_aoo)),
                            sopr.cognome_per_segnatura
                         || DECODE (sopr.nome_per_segnatura,
                                    NULL, '',
                                    ' ' || sopr.nome_per_segnatura))
                         denominazione_per_segnatura
                 FROM seg_soggetti_protocollo sopr, documenti docu
                WHERE     idrif = f_valore_campo (P_ID_PROTOCOLLO, 'IDRIF')
                      AND NVL (sopr.conoscenza, 'N') = 'N'
                      AND sopr.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND tipo_rapporto != 'DUMMY'
             ORDER BY sopr.id_documento)
      LOOP
         conta := conta + 1;

         IF conta > 1
         THEN
            EXIT;
         ELSE
            dep_mittdest := rapporti.denominazione_per_segnatura;
         END IF;
      END LOOP;

      RETURN dep_mittdest;
   END;

   /******************************************************************************
    NOME:        UPD_DETT_SMIST_TASK_EST_COMMIT
    DESCRIZIONE: Aggiornamento dei campi descrizione, attivita_help e
                 attivita_descr.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  21/03/2018 SC     Creazione.
   ******************************************************************************/
   PROCEDURE UPD_DETT_TASK_EST (p_idrif VARCHAR2)
   IS
      --PRAGMA AUTONOMOUS_TRANSACTION;
      dep_conta   NUMBER := 0;
      dep_stmt    VARCHAR2 (32000);
   BEGIN
      --   RAISE_APPLICATION_ERROR(-20999, nvl(P_IDRIF, 'idrif nullo'));
      IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
      THEN
         FOR rapporti
            IN (  SELECT sopr.id_documento,
                         sopr.idrif,
                         REPLACE (
                            TRIM (
                               DECODE (
                                  sopr.cognome_per_segnatura,
                                  NULL, NVL (
                                           sopr.denominazione_per_segnatura,
                                              descrizione_amm
                                           || DECODE (descrizione_aoo,
                                                      NULL, '',
                                                      ' - ' || descrizione_aoo)),
                                     sopr.cognome_per_segnatura
                                  || DECODE (sopr.nome_per_segnatura,
                                             NULL, '',
                                             ' ' || sopr.nome_per_segnatura))),
                            '''',
                            '''''')
                            denominazione_per_segnatura
                    FROM seg_soggetti_protocollo sopr, documenti docu
                   WHERE     idrif = p_idrif
                         AND sopr.conoscenza = 'N'
                         AND sopr.id_documento = docu.id_documento
                         AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND tipo_rapporto != 'DUMMY'
                ORDER BY sopr.id_documento)
         LOOP
            dep_conta := dep_conta + 1;

            IF (dep_conta > 1)
            THEN
               EXIT;
            END IF;

            AG_UTILITIES_CRUSCOTTO.RIMUOVI_TUTTO_SMARTDESKTOP;
            dep_stmt :=
                  'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Corrispondente'''
               || ', '''
               || rapporti.denominazione_per_segnatura
               || ''');'
               || ' end;';

            --RAISE_APPLICATION_ERROR(-20999, 'dep_stmt '||dep_stmt);
            --DBMS_OUTPUT.PUT_LINE('dep_stmt DETT '||dep_stmt);
            EXECUTE IMMEDIATE dep_stmt;
         END LOOP;

         IF dep_conta = 0
         THEN
            AG_UTILITIES_CRUSCOTTO.RIMUOVI_TUTTO_SMARTDESKTOP;
            dep_stmt :=
                  'begin jwf_worklist_services.AGGIUNGI_DETTAGLIO(''Corrispondente'''
               || ', '
               || '''--'''
               || ');'
               || ' end;';

            --RAISE_APPLICATION_ERROR(-20999, 'dep_stmt '||dep_stmt);
            --DBMS_OUTPUT.PUT_LINE('dep_stmt DETT '||dep_stmt);
            EXECUTE IMMEDIATE dep_stmt;
         END IF;

         FOR smistamenti
            IN (SELECT s.id_documento
                  FROM seg_smistamenti s, documenti d
                 WHERE     d.id_documento = s.id_documento
                       AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND s.stato_smistamento IN ('R', 'C')
                       AND idrif = p_idrif)
         LOOP
            dep_stmt :=
                  'begin jwf_worklist_services.AGGIORNA_ATTIVITA(P_ID_ATTIVITA => NULL'
               || ', '
               || 'P_ID_RIFERIMENTO => '''
               || smistamenti.id_documento
               || ''''
               || ');'
               || ' end;';

            --RAISE_APPLICATION_ERROR(-20999, 'dep_stmt '||dep_stmt);
            --DBMS_OUTPUT.PUT_LINE('dep_stmt '||dep_stmt);
            EXECUTE IMMEDIATE dep_stmt;
         END LOOP;

         FOR protocolli
            IN (SELECT p.id_documento
                  FROM proto_view p, documenti d
                 WHERE     d.id_documento = p.id_documento
                       AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND idrif = p_idrif)
         LOOP
            dep_stmt :=
                  'begin jwf_worklist_services.AGGIORNA_ATTIVITA(P_ID_ATTIVITA => NULL'
               || ', '
               || 'P_ID_RIFERIMENTO => '''
               || protocolli.id_documento
               || ''''
               || ');'
               || ' end;';

            --RAISE_APPLICATION_ERROR(-20999, 'dep_stmt '||dep_stmt);
            --DBMS_OUTPUT.PUT_LINE('dep_stmt '||dep_stmt);
            EXECUTE IMMEDIATE dep_stmt;
         END LOOP;
      END IF;
   --COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         --ROLLBACK;
         RAISE;
   END;


   PROCEDURE UPD_DETT_TASK_EST (p_id_rapporto VARCHAR2)
   IS
   BEGIN
      UPD_DETT_TASK_EST (p_idrif => f_valore_campo (p_id_rapporto, 'IDRIF'));
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   /******************************************************************************
    NOME:        UPD_OGG_SMIST_TASK_EST_COMMIT
    DESCRIZIONE: Aggiornamento dei campi descrizione, attivita_help e
                 attivita_descr.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
   ******************************************************************************/
   PROCEDURE upd_ogg_task_est_commit (p_idrif           VARCHAR2,
                                      p_oggetto         VARCHAR2,
                                      p_old_oggetto     VARCHAR2,
                                      p_anno_proto      NUMBER,
                                      p_numero_proto    NUMBER)
   IS
      pgannonumero   VARCHAR2 (100);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
      THEN
         DECLARE
            dep_stmt   VARCHAR2 (32000);
         BEGIN
            /*JWF_WORKLIST_SERVICES.SOSTITUISCI_DESCR_ATTIVITA(
                    P_ID_ATTIVITA                       NUMBER,
                    P_ID_RIFERIMENTO                 VARCHAR2,
                    P_OLD_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL,
                    P_NEW_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL,
                    P_OLD_TOOLTIP_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL,
                    P_NEW_TOOLTIP_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL
                    );    */
            FOR s
               IN (SELECT TO_CHAR (seg_smistamenti.id_documento) id_documento
                     FROM seg_smistamenti
                    WHERE seg_smistamenti.idrif = p_idrif)
            LOOP
               dep_stmt :=
                     'BEGIN '
                  || ' jwf_worklist_services.SOSTITUISCI_DESCR_ATTIVITA ( '
                  || '  P_ID_ATTIVITA => null '
                  || ', P_ID_RIFERIMENTO => '
                  || ''''
                  || s.id_documento
                  || ''''
                  || ', P_OLD_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_OLD_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ');'
                  || 'END;';

               EXECUTE IMMEDIATE dep_stmt;
            END LOOP;

            FOR p IN (SELECT TO_CHAR (id_documento) id_documento
                        FROM proto_view
                       WHERE proto_view.idrif = p_idrif)
            LOOP
               dep_stmt :=
                     'BEGIN '
                  || ' jwf_worklist_services.SOSTITUISCI_DESCR_ATTIVITA ( '
                  || '  P_ID_ATTIVITA => null '
                  || ', P_ID_RIFERIMENTO => '
                  || ''''
                  || p.id_documento
                  || ''''
                  || ', P_OLD_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_OLD_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ');'
                  || 'END;';

               EXECUTE IMMEDIATE dep_stmt;
            END LOOP;
         END;
      ELSE
         UPDATE jwf_task_esterni
            SET descrizione = REPLACE (descrizione, p_old_oggetto, p_oggetto),
                attivita_help =
                   REPLACE (attivita_help, p_old_oggetto, p_oggetto),
                attivita_descr =
                   REPLACE (attivita_descr, p_old_oggetto, p_oggetto)
          WHERE id_riferimento IN (SELECT TO_CHAR (
                                             seg_smistamenti.id_documento)
                                     FROM seg_smistamenti
                                    WHERE seg_smistamenti.idrif = p_idrif);

         UPDATE jwf_task_esterni
            SET descrizione = REPLACE (descrizione, p_old_oggetto, p_oggetto),
                attivita_help =
                   REPLACE (attivita_help, p_old_oggetto, p_oggetto),
                attivita_descr =
                   REPLACE (attivita_descr, p_old_oggetto, p_oggetto)
          WHERE id_riferimento IN (SELECT TO_CHAR (proto_view.id_documento)
                                     FROM proto_view
                                    WHERE proto_view.idrif = p_idrif);
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   END;

   PROCEDURE upd_ogg_task_est_nocommit (p_idrif           VARCHAR2,
                                        p_oggetto         VARCHAR2,
                                        p_old_oggetto     VARCHAR2,
                                        p_anno_proto      NUMBER,
                                        p_numero_proto    NUMBER)
   IS
      pgannonumero   VARCHAR2 (100);
   BEGIN
      IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
      THEN
         DECLARE
            dep_stmt   VARCHAR2 (32000);
         BEGIN
            /*JWF_WORKLIST_SERVICES.SOSTITUISCI_DESCR_ATTIVITA(
                    P_ID_ATTIVITA                       NUMBER,
                    P_ID_RIFERIMENTO                 VARCHAR2,
                    P_OLD_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL,
                    P_NEW_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL,
                    P_OLD_TOOLTIP_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL,
                    P_NEW_TOOLTIP_ATTIVITA_DESCR        VARCHAR2 DEFAULT NULL
                    );    */
            FOR s
               IN (SELECT TO_CHAR (seg_smistamenti.id_documento) id_documento
                     FROM seg_smistamenti
                    WHERE seg_smistamenti.idrif = p_idrif)
            LOOP
               dep_stmt :=
                     'BEGIN '
                  || ' jwf_worklist_services.SOSTITUISCI_DESCR_ATTIVITA ( '
                  || '  P_ID_ATTIVITA => null '
                  || ', P_ID_RIFERIMENTO => '
                  || ''''
                  || s.id_documento
                  || ''''
                  || ', P_OLD_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_OLD_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ');'
                  || 'END;';

               EXECUTE IMMEDIATE dep_stmt;
            END LOOP;

            FOR p IN (SELECT TO_CHAR (id_documento) id_documento
                        FROM proto_view
                       WHERE proto_view.idrif = p_idrif)
            LOOP
               dep_stmt :=
                     'BEGIN '
                  || ' jwf_worklist_services.SOSTITUISCI_DESCR_ATTIVITA ( '
                  || '  P_ID_ATTIVITA => null '
                  || ', P_ID_RIFERIMENTO => '
                  || ''''
                  || p.id_documento
                  || ''''
                  || ', P_OLD_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_OLD_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_old_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ', P_NEW_TOOLTIP_ATTIVITA_DESCR => '
                  || ''''
                  || REPLACE (SUBSTR (p_oggetto, 1, 4000), '''', '''''')
                  || ''''
                  || ');'
                  || 'END;';

               EXECUTE IMMEDIATE dep_stmt;
            END LOOP;
         END;
      ELSE
         UPDATE jwf_task_esterni
            SET descrizione = REPLACE (descrizione, p_old_oggetto, p_oggetto),
                attivita_help =
                   REPLACE (attivita_help, p_old_oggetto, p_oggetto),
                attivita_descr =
                   REPLACE (attivita_descr, p_old_oggetto, p_oggetto)
          WHERE id_riferimento IN (SELECT TO_CHAR (
                                             seg_smistamenti.id_documento)
                                     FROM seg_smistamenti
                                    WHERE seg_smistamenti.idrif = p_idrif);

         UPDATE jwf_task_esterni
            SET descrizione = REPLACE (descrizione, p_old_oggetto, p_oggetto),
                attivita_help =
                   REPLACE (attivita_help, p_old_oggetto, p_oggetto),
                attivita_descr =
                   REPLACE (attivita_descr, p_old_oggetto, p_oggetto)
          WHERE id_riferimento IN (SELECT TO_CHAR (proto_view.id_documento)
                                     FROM proto_view
                                    WHERE proto_view.idrif = p_idrif);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

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
                                  p_utente            VARCHAR2)
   IS
      dep_stmt   VARCHAR2 (32000);
   BEGIN
      IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
      THEN
         dep_stmt :=
               'begin JWF_WORKLIST_SERVICES.ELIMINA_ATTIVITA('
            || '  P_ID_RIFERIMENTO => '''
            || p_id_riferimento
            || ''''
            || ', P_UTENTE => '''
            || NVL (p_utente, 'RPI')
            || '''); end;';
         DBMS_OUTPUT.PUT_LINE (dep_stmt);

         EXECUTE IMMEDIATE dep_stmt;
      ELSE
         jwf_utility.p_elimina_task_esterno (NULL, p_id_riferimento, NULL);
      END IF;
   END;


   /******************************************************************************
    NOME:        DELETE_TASK_ESTERNI
    DESCRIZIONE: Cancella un task esterno mediante id_riferimento del task.
    NOTE:        --
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 GM     Creazione.
   ******************************************************************************/
   PROCEDURE delete_task_esterni (p_id_riferimento VARCHAR2)
   IS
   BEGIN
      delete_task_esterni (p_id_riferimento, NULL);
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
   ******************************************************************************/
   PROCEDURE delete_task_esterni_commit (p_id_riferimento    VARCHAR2,
                                         p_utente            VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      delete_task_esterni (p_id_riferimento, p_utente);
      COMMIT;
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
   ******************************************************************************/
   PROCEDURE delete_task_esterni_commit (p_id_riferimento VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      delete_task_esterni (p_id_riferimento);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;
END;
/
