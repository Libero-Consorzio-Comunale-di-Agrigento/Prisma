--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_GESTIONE_COMPONENTI runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_gestione_componenti
AS
/******************************************************************************
   NAME:       AG_GESTIONE_COMPONENTI
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/12/2008             1. Created this package.
******************************************************************************/
   FUNCTION resetta_competenze_smistamenti (
      p_unita    IN   VARCHAR2,
      p_utente        VARCHAR2
   )
      RETURN VARCHAR2;

/******************************************************************************
   NAME:       GET_RESPONSABILE_PRIVILEGIO
   PURPOSE: Dato un ni, un'unità di base, un privielgio, cerca un
            responsabile dell'unità di base con quel privilegio.
            Tale responsabile corrisponde ad un soggetto diverso dall'ni
            passato.
            p_unita                     CODICE UNITA IN CUI CERCARE IL RESPONSABILE
            p_ni                        NI SOGGETTO DA ESCLUDERE
            p_privilegio                CODICE PRIVILEGIO CHE DEVE AVERE IL RESPONSABILE
            p_utente_responsabile       CODICE UTENTE DEL RESPONSABILE
            p_descrizione_responsabile  DESCRIZIONE DEL RESPONSABILE
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2009   SC          1. Created this package body.
******************************************************************************/
   PROCEDURE get_responsabile_privilegio (
      p_unita                            seg_unita.unita%TYPE,
      p_ni                               NUMBER,
      p_privilegio                       ag_privilegi.privilegio%TYPE,
      p_utente_responsabile        OUT   VARCHAR2,
      p_descrizione_responsabile   OUT   VARCHAR2
   );

/******************************************************************************
   NAME:       GET_RESP_PRIVILEGIO_PER_AREA
   PURPOSE: Dato un ni, un'unità di base, un privilegio, cerca il
            primo responsabile dell'unità di base con quel privilegio.
            Tale responsabile corrisponde ad un soggetto diverso dall'ni
            passato.
            L'ordine con cui si stabilisce chi è il primo responsabile è
            il seguente:
            prima cerca un responsabile all'interno dell'unità,
            se non lo trova sale nella gerarchia delle unità
            fino a quando nontrova un responsabile con privilegio richiesto.
   PARAMETRI:
            p_unita                     CODICE UNITA DA CUI CERCARE IL RESPONSABILE
            p_ni                        NI SOGGETTO DA ESCLUDERE
            p_privilegio                CODICE PRIVILEGIO CHE DEVE AVERE IL RESPONSABILE
            p_utente_responsabile       CODICE UTENTE DEL RESPONSABILE
            p_descrizione_responsabile  DESCRIZIONE DEL RESPONSABILE
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2009   SC          1. Created this package body.
******************************************************************************/
   PROCEDURE get_resp_privilegio_per_area (
      p_unita_partenza                   seg_unita.unita%TYPE,
      p_ni                               NUMBER,
      p_privilegio                       ag_privilegi.privilegio%TYPE,
      p_utente_responsabile        OUT   VARCHAR2,
      p_descrizione_responsabile   OUT   VARCHAR2
   );

/******************************************************************************
   NAME:       GET_DOMINIO_RESP_PRIV_PER_AREA
   PURPOSE: Dato un ni, un'unità di base, un privilegio, cerca il
            primo responsabile dell'unità di base con quel privilegio.
            Tale responsabile corrisponde ad un soggetto diverso dall'ni
            passato.
            L'ordine con cui si stabilisce chi è il primo responsabile è
            il seguente:
            prima cerca un responsabile all'interno dell'unità,
            se non lo trova sale nella gerarchia delle unità
            fino a quando non trova un responsabile con privilegio richiesto.
            I valori trovati vengono restituiti in una stringa formattata per essere
            utilizzata dai domini di GDM.
   PARAMETRI:
            p_unita                     CODICE UNITA DA CUI CERCARE IL RESPONSABILE
            p_ni                        NI SOGGETTO DA ESCLUDERE
            p_privilegio                CODICE PRIVILEGIO CHE DEVE AVERE IL RESPONSABILE
            p_campo_codice              NOME CAMPO IN CUI INSERIRE IL CODICE UTENTE DEL RESPONSABILE.
            p_campo_descrizione         NOME CAMPO IN CUI INSERIRE LA DESCRIZIONE DEL RESPONSABILE. (COGNOME NOME)
            p_campo_nome_cognome       NOME CAMPO IN CUI INSERIRE LA NOME COGNOME DEL RESPONSABILE.
   RETURN: UNA STRINGA NEL FORMATO <C><V> utilizzato dai domini di modulistica
            in cui restituisce i campi codice utente e descrizione.
            p_descrizione_responsabile  DESCRIZIONE DEL RESPONSABILE
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2009   SC          1. Created this package body.
              30/07/2009   SC             A33880.0.0 Aggiunto p_campo_nome_cognome.
******************************************************************************/
   FUNCTION get_dominio_resp_priv_per_area (
      p_unita_partenza      seg_unita.unita%TYPE,
      p_ni                  NUMBER,
      p_privilegio          ag_privilegi.privilegio%TYPE,
      p_campo_codice        VARCHAR2,
      p_campo_descrizione   VARCHAR2,
      p_campo_nome_cognome   VARCHAR2
   )
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        GET_COMPONENTI_UO_AD4
 DESCRIZIONE: Dato il codice della UO,
           ritorna la lista dei componenti della UO indicata.
           la strutura di ritorno della function è del tipo <C></C><V></V>

 Rev.  Data        Autore  Descrizione
 ----  ----------  ------  ----------------------------------------------------
 000   16/02/2007  Casalini
                  Zoli      Prima emissione.
       05/06/2009  SC       Copiata da GDM_SO4_UTIlITY che noi non installiamo.
******************************************************************************/
   FUNCTION get_componenti_uo_ad4 (codice_uo IN VARCHAR2, combo IN VARCHAR2)
      RETURN VARCHAR2;
END ag_gestione_componenti;
/
CREATE OR REPLACE PACKAGE BODY ag_gestione_componenti
AS
/******************************************************************************
   NAME:       RESETTA_COMPETENZE_SMISTAMENTI
   PURPOSE: Rivede le competenze di accesso alle attivita' jsuite degli smistamenti.
            In pratica dato un utente per il quale sono stati modificati o ruolo
            o unita' di appartenenza e data la vecchia unita di appartenenza
            si cercano tutti gli smistamenti da ricevere o in carico per tale unita,
            senza assegnazione o assegnati all'utente.
            Per ognuno di tali smistamenti si ricalcolano i diritti di accesso sulle
            attivita' jsuite e li si sostituisce agli attuali diritti,
            poi, se la  nuova acl calcolata non è vuota, si è finito.
            Se invece a questo punto nessuno accede all'attivita' jsuite,
            si vede se lo smistamento era assegnato:
            se era assegnato si restituisce l'id dello smistamento per poi farlo clonare,
            ma senza assegnazione,
            se non era assegnato significa che nessun componente dell'unita' ha diritti sull'attivita'
            jsuite in questione e quindi è inutile clonare lo smistamento perche'
            anche il nuovo smistamento si troverebbe nella stessa situazione.

            Dato che l'operazione viene eseguita per ogni smistamento a p_unita,
            verra' restituito un elenco di id degli smistamenti da clonare, separati da @.



   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/12/2008             1. Created this package body.
******************************************************************************/
   FUNCTION resetta_competenze_smistamenti (
      p_unita    IN   VARCHAR2,
      p_utente        VARCHAR2
   )
      RETURN VARCHAR2
   IS
      depacl                   VARCHAR2 (32000);
      smistamenti_da_clonare   VARCHAR2 (32000);
   BEGIN
      FOR smistamenti IN
         (SELECT docu.id_documento, docu.area, docu.codice_richiesta,
                 tido.nome codice_modello, smis.codice_assegnatario,
                 ag_parametro.get_valore ('NOME_ITER_SMIST',
                                          '@agStrut@'
                                         ) nome_iter,
                 ROWNUM
            FROM seg_smistamenti smis, documenti docu, tipi_documento tido
           WHERE smis.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE')
             AND tido.id_tipodoc = docu.id_tipodoc
             AND smis.stato_smistamento IN ('R', 'C')
             AND smis.ufficio_smistamento = p_unita
             AND NVL (smis.codice_assegnatario, p_utente) = p_utente
                                                                    --and rownum BETWEEN 1 AND 20
         )
      LOOP
         IF smistamenti.ROWNUM = 1
         THEN
            ag_utilities.inizializza_ag_priv_utente_tmp (p_utente);
            COMMIT;
         END IF;

         depacl :=
            ag_utilities_cruscotto.get_utenti_accesso_smistamento
                          (p_area                    => smistamenti.area,
                           p_modello                 => smistamenti.codice_modello,
                           p_codice_richiesta        => smistamenti.codice_richiesta,
                           p_inizializza_utente      => 'N'
                          );

--DBMS_OUTPUT.PUT_LINE(smistamenti.CODICE_RICHIESTA||' '||depacl);
         --chiama la funzione del jwf per la sostituzione
         IF depacl = '@'
         THEN
            IF smistamenti.codice_assegnatario IS NOT NULL
            THEN
               -- chiede che venga creato un nuovo smistamento senza assegnazione
               smistamenti_da_clonare := smistamenti.id_documento || '@';
            ELSE
               -- nessun altro dentro l'unita --- fine
               NULL;
            END IF;
         END IF;
      END LOOP;

      RETURN smistamenti_da_clonare;
   END resetta_competenze_smistamenti;

/******************************************************************************
   NAME:       GET_RESPONSABILE_PRIVILEGIO
   PURPOSE: Dato un ni, un'unità di base, un privielgio, cerca un
            responsabile dell'unità di base con quel privilegio.
            Tale responsabile corrisponde ad un soggetto diverso dall'ni
            passato.
            p_unita                     CODICE UNITA IN CUI CERCARE IL RESPONSABILE
            p_ni                        NI SOGGETTO DA ESCLUDERE
            p_privilegio                CODICE PRIVILEGIO CHE DEVE AVERE IL RESPONSABILE
            p_utente_responsabile       CODICE UTENTE DEL RESPONSABILE
            p_descrizione_responsabile  DESCRIZIONE DEL RESPONSABILE
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2009   SC          1. Created this package body.
******************************************************************************/
   PROCEDURE get_responsabile_privilegio (
      p_unita                            seg_unita.unita%TYPE,
      p_ni                               NUMBER,
      p_privilegio                       ag_privilegi.privilegio%TYPE,
      p_utente_responsabile        OUT   VARCHAR2,
      p_descrizione_responsabile   OUT   VARCHAR2
   )
   IS
      dep_aoo_index                  NUMBER;
      dep_ottica                     VARCHAR2 (1000);
      c_ruoli                        ag_privilegio_ruolo.ag_prru_refcursor;
      c_responsabili                 afc.t_ref_cursor;
      dep_descrizione_responsabile   VARCHAR2 (2000);
      dep_ni_responsabile            NUMBER;
      dep_utente_responsabile        ad4_utenti.utente%TYPE;
      dep_dati_unita_padre           VARCHAR2 (32000);
      dep_ruolo                      ad4_ruoli.ruolo%TYPE;
      dep_uo_codice                  seg_unita.unita%TYPE;
   BEGIN
      dep_aoo_index := ag_utilities.get_defaultaooindex ();
      dep_ottica := ag_utilities.get_ottica_aoo (dep_aoo_index);
      c_ruoli := ag_privilegio_ruolo.get_ruoli (dep_aoo_index, p_privilegio);

-- cerco i ruoli con privilegio dep_privilegio.
      IF c_ruoli%ISOPEN
      THEN
         LOOP
            FETCH c_ruoli
             INTO dep_ruolo;

            EXIT WHEN c_ruoli%NOTFOUND OR dep_ni_responsabile IS NOT NULL;
-- cerco in dep_unita_partenza se ci osno responsabili con ruolo dep_ruolo.
            c_responsabili :=
               so4_AGS_PKG.comp_get_responsabile (p_ni,
                                               p_unita,
                                               dep_ruolo,
                                               dep_ottica
                                              );

            IF c_responsabili%ISOPEN
            THEN
               LOOP
                  FETCH c_responsabili
                   INTO dep_ni_responsabile, p_descrizione_responsabile;

                  EXIT WHEN c_responsabili%NOTFOUND
                        OR dep_ni_responsabile IS NOT NULL;
               END LOOP;

               CLOSE c_responsabili;
            END IF;
         END LOOP;

         CLOSE c_ruoli;
      END IF;

      IF dep_ni_responsabile IS NOT NULL
      THEN
         DBMS_OUTPUT.put_line (p_descrizione_responsabile);
         p_utente_responsabile := ad4_utente.get_utente (dep_ni_responsabile);
      END IF;
   END;

/******************************************************************************
   NAME:       GET_RESP_PRIVILEGIO_PER_AREA
   PURPOSE: Dato un ni, un'unità di base, un privilegio, cerca il
            primo responsabile dell'unità di base con quel privilegio.
            Tale responsabile corrisponde ad un soggetto diverso dall'ni
            passato.
            L'ordine con cui si stabilisce chi è il primo responsabile è
            il seguente:
            prima cerca un responsabile all'interno dell'unità,
            se non lo trova sale nella gerarchia delle unità
            fino a quando nontrova un responsabile con privilegio richiesto.
   PARAMETRI:
            p_unita                     CODICE UNITA DA CUI CERCARE IL RESPONSABILE
            p_ni                        NI SOGGETTO DA ESCLUDERE
            p_privilegio                CODICE PRIVILEGIO CHE DEVE AVERE IL RESPONSABILE
            p_utente_responsabile       CODICE UTENTE DEL RESPONSABILE
            p_descrizione_responsabile  DESCRIZIONE DEL RESPONSABILE
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2009   SC          1. Created this package body.
******************************************************************************/
   PROCEDURE get_resp_privilegio_per_area (
      p_unita_partenza                   seg_unita.unita%TYPE,
      p_ni                               NUMBER,
      p_privilegio                       ag_privilegi.privilegio%TYPE,
      p_utente_responsabile        OUT   VARCHAR2,
      p_descrizione_responsabile   OUT   VARCHAR2
   )
   IS
      dep_aoo_index             NUMBER;
      dep_ottica                VARCHAR2 (1000);
      dep_utente_responsabile   ad4_utenti.utente%TYPE;
      c_ascendenti              afc.t_ref_cursor;
      dep_uo_progr              NUMBER;
      dep_uo_codice             seg_unita.unita%TYPE;
      dep_uo_descrizione        VARCHAR2 (32000);
      dep_uo_dal                DATE;
      dep_uo_al                 DATE;
   BEGIN
      get_responsabile_privilegio (p_unita_partenza,
                                   p_ni,
                                   p_privilegio,
                                   p_utente_responsabile,
                                   p_descrizione_responsabile
                                  );

-- in dep_unita_partenza non ho trovato nessun responsabile con ruolo con privilegio dep_privilegio
-- quindi riprendo su i ruoli con privilegio dep_privilegio per cercare nelle unità superiori.
-- In pratica ripete l'operazione sull'unità superiore fino a quando non trova un responsabile
-- o non ci sono più unità superiori.
      IF p_utente_responsabile IS NULL
      THEN
         dep_aoo_index := ag_utilities.get_defaultaooindex ();
         dep_ottica := ag_utilities.get_ottica_aoo (dep_aoo_index);
         c_ascendenti :=
            so4_AGS_PKG.unita_get_ascendenti (p_unita_partenza, NULL,
                                           dep_ottica);

         IF c_ascendenti%ISOPEN
         THEN
            LOOP
               FETCH c_ascendenti
                INTO dep_uo_progr, dep_uo_codice, dep_uo_descrizione,
                     dep_uo_dal, dep_uo_al;

               EXIT WHEN c_ascendenti%NOTFOUND
                     OR p_utente_responsabile IS NOT NULL;

               IF dep_uo_al IS NULL AND dep_uo_codice != p_unita_partenza
               THEN
                  get_responsabile_privilegio (dep_uo_codice,
                                               p_ni,
                                               p_privilegio,
                                               p_utente_responsabile,
                                               p_descrizione_responsabile
                                              );
               END IF;
            END LOOP;

            CLOSE c_ascendenti;
         END IF;
      END IF;
   END get_resp_privilegio_per_area;

/******************************************************************************
   NAME:       GET_DOMINIO_RESP_PRIV_PER_AREA
   PURPOSE: Dato un ni, un'unità di base, un privilegio, cerca il
            primo responsabile dell'unità di base con quel privilegio.
            Tale responsabile corrisponde ad un soggetto diverso dall'ni
            passato.
            L'ordine con cui si stabilisce chi è il primo responsabile è
            il seguente:
            prima cerca un responsabile all'interno dell'unità,
            se non lo trova sale nella gerarchia delle unità
            fino a quando non trova un responsabile con privilegio richiesto.
            I valori trovati vengono restituiti in una stringa formattata per essere
            utilizzata dai domini di GDM.
   PARAMETRI:
            p_unita                     CODICE UNITA DA CUI CERCARE IL RESPONSABILE
            p_ni                        NI SOGGETTO DA ESCLUDERE
            p_privilegio                CODICE PRIVILEGIO CHE DEVE AVERE IL RESPONSABILE
            p_campo_codice              NOME CAMPO IN CUI INSERIRE IL CODICE UTENTE DEL RESPONSABILE.
            p_campo_descrizione         NOME CAMPO IN CUI INSERIRE LA DESCRIZIONE DEL RESPONSABILE. (COGNOME NOME)
            p_campo_nome_cognome       NOME CAMPO IN CUI INSERIRE LA NOME COGNOME DEL RESPONSABILE.
   RETURN: UNA STRINGA NEL FORMATO <C><V> utilizzato dai domini di modulistica
            in cui restituisce i campi codice utente e descrizione.
            p_descrizione_responsabile  DESCRIZIONE DEL RESPONSABILE
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2009   SC          1. Created this package body.
              30/07/2009   SC             A33880.0.0 Aggiunto p_campo_nome_cognome.
******************************************************************************/
   FUNCTION get_dominio_resp_priv_per_area (
      p_unita_partenza       seg_unita.unita%TYPE,
      p_ni                   NUMBER,
      p_privilegio           ag_privilegi.privilegio%TYPE,
      p_campo_codice         VARCHAR2,
      p_campo_descrizione    VARCHAR2,
      p_campo_nome_cognome   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      dep_utente_responsabile        ad4_utenti.utente%TYPE;
      dep_descrizione_responsabile   VARCHAR2 (32000);
      dep_nome_cognome               VARCHAR2 (32000);
   BEGIN
      get_resp_privilegio_per_area (p_unita_partenza,
                                    p_ni,
                                    p_privilegio,
                                    dep_utente_responsabile,
                                    dep_descrizione_responsabile
                                   );

      SELECT DECODE (nome, NULL, '', nome || ' ') || cognome
        INTO dep_nome_cognome
        FROM as4_soggetti sogg, ad4_utenti_soggetti utso
       WHERE sogg.ni = utso.soggetto AND utso.utente = dep_utente_responsabile;

      RETURN    '<C>'
             || p_campo_codice
             || '</C><V>'
             || dep_utente_responsabile
             || '</V>'
             || '<C>'
             || p_campo_descrizione
             || '</C><V>'
             || dep_descrizione_responsabile
             || '</V>'
             || '<C>'
             || p_campo_nome_cognome
             || '</C><V>'
             || dep_nome_cognome
             || '</V>';
   END get_dominio_resp_priv_per_area;

/******************************************************************************
 NOME:        GET_COMPONENTI_UO_AD4
 DESCRIZIONE: Dato il codice della UO,
           ritorna la lista dei componenti della UO indicata.
           la strutura di ritorno della function è del tipo <C></C><V></V>

 Rev.  Data        Autore  Descrizione
 ----  ----------  ------  ----------------------------------------------------
 000   16/02/2007  Casalini
                  Zoli      Prima emissione.
       05/06/2009  SC       Copiata da GDM_SO4_UTIlITY che noi non installiamo.
******************************************************************************/
   FUNCTION get_componenti_uo_ad4 (codice_uo IN VARCHAR2, combo IN VARCHAR2)
      RETURN VARCHAR2
   IS
      -- Tipo di Dato Vettore che contiene le unità
      TYPE t_lista_componenti IS TABLE OF VARCHAR2 (400)
         INDEX BY BINARY_INTEGER;

      d_stringa           VARCHAR2 (4000);
      uo                  afc.t_ref_cursor;
      c                   VARCHAR2 (400);
      v                   VARCHAR2 (400);
      esci                INTEGER;
      i                   INTEGER;
      n                   INTEGER;
      lc                  t_lista_componenti;
      codice_ad4_cursor   afc.t_ref_cursor;
      codice_ad4          VARCHAR2 (400);
      v_codice_ad4        VARCHAR2 (400);
   BEGIN
      n := 0;
      uo := so4_AGS_PKG.unita_get_componenti (codice_uo);
      d_stringa := '';

      LOOP
         FETCH uo
          INTO c, v;

         EXIT WHEN uo%NOTFOUND;
         -- Controllo che il responsabile caricato non sià già presente nel vettore
           -- dei responsabili.
         i := 1;
         esci := 0;

         IF n > 0
         THEN
            WHILE (esci = 0 AND i <= lc.COUNT)
            LOOP
               IF lc (i) = c
               THEN
                  esci := 1;
               END IF;

               i := i + 1;
            END LOOP;
         END IF;

         -- Solo se non esiste nel vettore lo inserisco per non avere duplicati
         IF esci = 0
         THEN
            n := n + 1;
            lc (n) := c;

            -- Apro un nuovo cursore per poter caricare l'utente AD4 dato il codice NI
            OPEN codice_ad4_cursor FOR
               SELECT ad4_utenti_soggetti.utente, ad4_utenti_soggetti.utente
                 FROM ad4_utenti_soggetti
                WHERE soggetto = c;

            LOOP
               FETCH codice_ad4_cursor
                INTO codice_ad4, v_codice_ad4;

               EXIT WHEN codice_ad4_cursor%NOTFOUND;
               d_stringa :=
                  d_stringa || '<C>' || codice_ad4 || '</C><V>' || v
                  || '</V>';
            END LOOP;
         END IF;
      END LOOP;

      RETURN d_stringa;

      CLOSE uo;
   END get_componenti_uo_ad4;
END ag_gestione_componenti;
/
