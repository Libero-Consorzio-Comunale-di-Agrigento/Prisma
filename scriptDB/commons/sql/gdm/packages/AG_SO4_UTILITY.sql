--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_SO4_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_so4_utility
IS
   /******************************************************************************
    NOME:        ag_so4_utility.
    DESCRIZIONE: Procedure e Funzioni di utility per lo scarico ipa e ricerca amm,
                 aoo e uo.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   10/05/2011 MM     Creazione.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   -- Aggiornamento dati AMM da IPAR

     PROCEDURE agg_automatico_amm (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_descrizione              IN as4_anagrafe_soggetti.nome%TYPE,
      p_indirizzo                IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_istituzione         IN as4_anagrafe_soggetti.dal%TYPE,
      p_data_soppressione        IN as4_anagrafe_soggetti.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE);

   PROCEDURE agg_automatico_amm (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_descrizione              IN as4_anagrafe_soggetti.nome%TYPE,
      p_indirizzo                IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_istituzione         IN as4_anagrafe_soggetti.dal%TYPE,
      p_data_soppressione        IN as4_anagrafe_soggetti.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_codice_fiscale_amm       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE);

   -- Aggiornamento dati AMM da IPA
   PROCEDURE agg_automatico_amm (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_descrizione              IN as4_anagrafe_soggetti.nome%TYPE,
      p_indirizzo                IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_contatti                 IN VARCHAR2,
      p_data_istituzione         IN as4_anagrafe_soggetti.dal%TYPE,
      p_data_soppressione        IN as4_anagrafe_soggetti.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_codice_fiscale_amm       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE);

   FUNCTION trova_amm (
      p_codice                 IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_ni                     IN so4_amministrazioni.ni%TYPE,
      p_denominazione          IN as4_anagrafe_soggetti.cognome%TYPE,
      p_indirizzo              IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                    IN as4_anagrafe_soggetti.cap_res%TYPE,
      p_citta                  IN VARCHAR2,
      p_provincia              IN VARCHAR2,
      p_regione                IN VARCHAR2,
      p_sito_istituzionale     IN as4_anagrafe_soggetti.indirizzo_web%TYPE,
      p_indirizzo_telematico   IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_riferimento       IN so4_amministrazioni.data_istituzione%TYPE DEFAULT TRUNC (
                                                                                       SYSDATE))
      RETURN afc.t_ref_cursor;

   -- Aggiornamento dati AOO da scarico IPAR
   PROCEDURE agg_automatico_aoo (
      p_codice_amministrazione   IN so4_aoo.codice_amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE,
      p_descrizione              IN so4_aoo.descrizione%TYPE,
      p_indirizzo                IN so4_aoo.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_istituzione         IN so4_aoo.dal%TYPE,
      p_data_soppressione        IN so4_aoo.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE);

   -- Aggiornamento dati AOO da scarico IPA
   PROCEDURE agg_automatico_aoo (
      p_codice_amministrazione   IN so4_aoo.codice_amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE,
      p_descrizione              IN so4_aoo.descrizione%TYPE,
      p_indirizzo                IN so4_aoo.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_contatti                 IN VARCHAR2,
      p_data_istituzione         IN so4_aoo.dal%TYPE,
      p_data_soppressione        IN so4_aoo.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE);

   FUNCTION trova_aoo (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE,
      p_ni                       IN so4_aoo.progr_aoo%TYPE,
      p_denominazione            IN so4_aoo.descrizione%TYPE,
      p_indirizzo                IN so4_aoo.indirizzo%TYPE,
      p_cap                      IN so4_aoo.cap%TYPE,
      p_citta                    IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_regione                  IN VARCHAR2,
      p_sito_istituzionale       IN as4_anagrafe_soggetti.indirizzo_web%TYPE,
      p_indirizzo_telematico     IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_riferimento         IN so4_aoo.dal%TYPE DEFAULT TRUNC (SYSDATE))
      RETURN afc.t_ref_cursor;

   -- Aggiornamento dati UO da scarico IPAR

   PROCEDURE agg_automatico_uo (
      p_codice_amministrazione   IN so4_auor.amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE DEFAULT NULL,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_descrizione              IN VARCHAR2,
      p_dal                      IN so4_auor.dal%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_soppressione        IN so4_auor.al%TYPE,
      p_utente_aggiornamento     IN so4_auor.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_auor.data_aggiornamento%TYPE);

   PROCEDURE agg_automatico_uo (
      p_codice_amministrazione   IN so4_auor.amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE ,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_descrizione              IN VARCHAR2,
      p_dal                      IN so4_auor.dal%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_soppressione        IN so4_auor.al%TYPE,
      p_utente_aggiornamento     IN so4_auor.utente_aggiornamento%TYPE ,
      p_codice_fiscale_sfe       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE ,
      p_data_aggiornamento       IN so4_auor.data_aggiornamento%TYPE );

   -- Aggiornamento dati UO da scarico IPA
   PROCEDURE agg_automatico_uo (
      p_codice_amministrazione   IN so4_auor.amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE ,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_descrizione              IN VARCHAR2,
      p_dal                      IN so4_auor.dal%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_contatti                 IN VARCHAR2,
      p_data_soppressione        IN so4_auor.al%TYPE,
      p_utente_aggiornamento     IN so4_auor.utente_aggiornamento%TYPE ,
      p_codice_fiscale_sfe       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE ,
      p_data_aggiornamento       IN so4_auor.data_aggiornamento%TYPE );

   FUNCTION check_cf (p_codice_fiscale VARCHAR2)
      RETURN NUMBER;

   FUNCTION trova_uo (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_ni                       IN so4_auor.progr_unita_organizzativa%TYPE,
      p_denominazione            IN so4_auor.descrizione%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN so4_auor.cap%TYPE,
      p_citta                    IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_regione                  IN VARCHAR2,
      p_indirizzo_telematico        so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_riferimento            so4_aoo.dal%TYPE DEFAULT TRUNC (SYSDATE))
      RETURN afc.t_ref_cursor;

   FUNCTION check_esistenza (p_codice_amm VARCHAR2, p_codice_aoo VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_descr_abbreviata_padre (p_codice_uo               VARCHAR2,
                                        p_data_protocollazione    DATE)
      RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY ag_so4_utility
IS
   /******************************************************************************
    NOME:        ag_so4_utility
    DESCRIZIONE: Procedure e Funzioni di utility per lo scarico ipa e ricerca amm, aoo e uo.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data        Autore   Descrizione
    ---- ----------  ------   ------------------------------------------------------
    000  10/05/2011  MM       Creazione.
    001  16/05/2012  MM       Modifiche V2.1.
    002  25/01/2013  MM       Adeguamento per Interpro
    004  09/03/2015  MM       Modificato scarico aoo per gestione dal (se
                              data_istituzione < dal amm).
                              Modificata ricerca amm e aoo in modo ricerchi la
                              descrizione per uguaglianza .
    005  25/08/2015  MM       Modificata trova_amm in mod che ricerchi le
                              amministrazioni anche solo per mail.
    006  14/08/2018  MM       Modificata agg_automatico_uo perchè non consideri
                              il campo codice_fiscale_sfe (per le province di
                              Bolzano e Trento e' lo stesso ed uguale all'amm
                              per tutte le uo) e tolto inserimento soggetto e
                              legame soggetto-unita' in quanto demandato ad so4.
    007 19/12/2018  MM       Modificata agg_automatico_aoo per gestione
                              aggiornamento dal dell'aoo se minore di quello
                              dell'amministrazione.
    008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
    009 11/09/2020   SC     Bug #44596 Individuazione mittenti messaggi senza
                                     segnatura quando sono mail di uo da IPA
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '009';
   L_FAX_RES          NUMBER;
   L_CAP_RES          NUMBER;
   L_TEL_RES          NUMBER;
   L_INDIRIZZO_RES    NUMBER;
   L_FAX              NUMBER;
   L_CAP              NUMBER;
   L_TELEFONO         NUMBER;
   L_DESCRIZIONE      NUMBER;

   FUNCTION get_lunghezza_dato (
      p_nome_tabella    all_tab_columns.table_name%TYPE,
      p_nome_campo      all_tab_columns.column_name%TYPE,
      p_owner           all_tab_columns.owner%TYPE DEFAULT NULL)
      RETURN NUMBER
   IS
      ret   NUMBER;
   BEGIN
      BEGIN
         SELECT data_length
           INTO ret
           FROM all_tab_columns
          WHERE     table_name = p_nome_tabella
                AND column_name = p_nome_campo
                AND owner = NVL (p_owner, owner);
      EXCEPTION
         WHEN OTHERS
         THEN
            ret := -1;
      END;

      RETURN ret;
   END get_lunghezza_dato;


   FUNCTION check_cf (p_codice_fiscale VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER := -1;
   BEGIN
      SELECT ni
        INTO ret
        FROM as4_soggetti
       WHERE codice_fiscale = p_codice_fiscale AND ROWNUM = 1;

      RETURN ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            ret := -1;
         END;

         RETURN ret;
   END check_cf;

   FUNCTION get_user_so4
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (100);
   BEGIN
      SELECT DISTINCT table_owner
        INTO d_return
        FROM user_synonyms
       WHERE synonym_name = 'SO4_AOO';

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;

   FUNCTION get_user_as4
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (100);
   BEGIN
      SELECT DISTINCT table_owner
        INTO d_return
        FROM user_synonyms
       WHERE synonym_name = 'AS4_ANAGRAFE_SOGGETTI_TPK';

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;

   FUNCTION check_esistenza (p_codice_amm VARCHAR2, p_codice_aoo VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER;
   BEGIN
      BEGIN
         IF (p_codice_aoo IS NULL)
         THEN
            SELECT 1
              INTO ret
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM SEG_AMM_AOO_UO_MV
                        WHERE LOWER (cod_amm) = LOWER (p_codice_amm));
         ELSE
            SELECT 1
              INTO ret
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM SEG_AMM_AOO_UO_MV
                        WHERE     LOWER (cod_amm) = LOWER (p_codice_amm)
                              AND LOWER (cod_aoo) = LOWER (p_codice_aoo));
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ret := 0;
      END;

      RETURN ret;
   END check_esistenza;

   FUNCTION get_descr_abbreviata_padre (p_codice_uo               VARCHAR2,
                                        p_data_protocollazione    DATE)
      RETURN VARCHAR2
   IS
      d_codice_unita_padre   VARCHAR2 (30);
      d_temp                 VARCHAR2 (200);
      ret                    VARCHAR2 (30);
      d_startpos             NUMBER;
      d_stoppos              NUMBER;
   BEGIN
      BEGIN
         SELECT so4_ags_pkg.unita_get_unita_padre (
                   p_codice_uo,
                   ag_parametro.get_valore ('SO_OTTICA_PROT_1', '@agVar@'),
                   p_data_protocollazione,
                   NULL)
           INTO d_temp
           FROM DUAL;

         DBMS_OUTPUT.put_line (d_temp);

         IF d_temp IS NULL
         THEN
            SELECT desc_abbreviata
              INTO ret
              FROM seg_unita unit
             WHERE     unita = p_codice_uo
                   AND p_data_protocollazione BETWEEN unit.dal
                                                  AND NVL (
                                                         unit.al,
                                                         TO_DATE ('3333333',
                                                                  'j'));
         ELSE
            d_startpos := INSTR (d_temp, '#') + 1;
            d_stoppos := INSTR (d_temp, '#', d_startpos);
            d_codice_unita_padre :=
               SUBSTR (d_temp, d_startpos, d_stoppos - d_startpos);

            SELECT desc_abbreviata
              INTO ret
              FROM seg_unita unit
             WHERE     unita = d_codice_unita_padre
                   AND p_data_protocollazione BETWEEN unit.dal
                                                  AND NVL (
                                                         unit.al,
                                                         TO_DATE ('3333333',
                                                                  'j'));
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ret := '';
      END;

      RETURN ret;
   END get_descr_abbreviata_padre;

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

  PROCEDURE agg_automatico_amm (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_descrizione              IN as4_anagrafe_soggetti.nome%TYPE,
      p_indirizzo                IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_istituzione         IN as4_anagrafe_soggetti.dal%TYPE,
      p_data_soppressione        IN as4_anagrafe_soggetti.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE)
   IS
   BEGIN
      agg_automatico_amm (p_codice_amministrazione,
                          p_descrizione,
                          p_indirizzo,
                          p_cap,
                          p_localita,
                          p_provincia,
                          p_telefono,
                          p_fax,
                          p_mail_istituzionale,
                          '',
                          p_data_istituzione,
                          p_data_soppressione,
                          p_utente_aggiornamento,
                          '',
                          p_data_aggiornamento);
   END;


   PROCEDURE agg_automatico_amm (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_descrizione              IN as4_anagrafe_soggetti.nome%TYPE,
      p_indirizzo                IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_istituzione         IN as4_anagrafe_soggetti.dal%TYPE,
      p_data_soppressione        IN as4_anagrafe_soggetti.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_codice_fiscale_amm       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE)
   IS
   BEGIN
      agg_automatico_amm (p_codice_amministrazione,
                          p_descrizione,
                          p_indirizzo,
                          p_cap,
                          p_localita,
                          p_provincia,
                          p_telefono,
                          p_fax,
                          p_mail_istituzionale,
                          '',
                          p_data_istituzione,
                          p_data_soppressione,
                          p_utente_aggiornamento,
                          p_data_aggiornamento);
   END;

   PROCEDURE agg_automatico_amm (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_descrizione              IN as4_anagrafe_soggetti.nome%TYPE,
      p_indirizzo                IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_contatti                 IN VARCHAR2,
      p_data_istituzione         IN as4_anagrafe_soggetti.dal%TYPE,
      p_data_soppressione        IN as4_anagrafe_soggetti.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_codice_fiscale_amm       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE)
   IS
      /******************************************************************************
       NOME:        agg_automatico_amm
       DESCRIZIONE: Verifica se i dati passati sono stati modificati;
                    in caso affermativo si esegue una storicizzazione
                    altrimenti non si esegue alcuna operazione
                    Se i dati non esistevano vengono inseriti
                    -
       RITORNA:     -
      ******************************************************************************/
      d_codice_amm           so4_amministrazioni.codice_amministrazione%TYPE;
      d_ni                   so4_amministrazioni.ni%TYPE;
      d_ente                 so4_amministrazioni.ente%TYPE;
      d_data_soppressione    so4_amministrazioni.data_soppressione%TYPE;
      d_codice_comune        as4_anagrafe_soggetti.comune_res%TYPE;
      d_codice_provincia     as4_anagrafe_soggetti.provincia_res%TYPE;
      d_fax                  as4_anagrafe_soggetti.fax_res%TYPE;
      d_cap                  as4_anagrafe_soggetti.cap_res%TYPE;
      d_telefono             as4_anagrafe_soggetti.tel_res%TYPE;
      d_indirizzo            as4_anagrafe_soggetti.indirizzo_res%TYPE;
      d_utente_agg           so4_amministrazioni.utente_aggiornamento%TYPE;
      d_codice_fiscale_amm   AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE;
      d_aggiornamento        NUMBER (1);
      d_dal                  DATE;
      uscita                 EXCEPTION;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      integritypackage.LOG ('inizio');

      --integritypackage.LOG ('get_user_as4 ' || get_user_as4);

      IF LENGTH (p_codice_fiscale_amm) > 11
      THEN
         d_codice_fiscale_amm := '';
      ELSE
         d_codice_fiscale_amm := p_codice_fiscale_amm;
      END IF;

      integritypackage.LOG ('d_codice_fiscale_amm ' || d_codice_fiscale_amm);


      IF LENGTH (p_fax) > L_FAX_RES
      THEN
         d_fax := '';
      ELSE
         d_fax := p_fax;
      END IF;

      integritypackage.LOG ('d_fax ' || d_fax);

      IF LENGTH (p_cap) > L_CAP_RES
      THEN
         d_cap := '';
      ELSE
         d_cap := p_cap;
      END IF;

      integritypackage.LOG ('d_cap ' || d_cap);

      IF LENGTH (p_telefono) > L_TEL_RES
      THEN
         d_telefono := '';
      ELSE
         d_telefono := p_telefono;
      END IF;

      integritypackage.LOG ('d_telefono ' || d_telefono);

      IF LENGTH (p_indirizzo) > L_INDIRIZZO_RES
      THEN
         d_indirizzo := SUBSTR (p_indirizzo, 1, L_INDIRIZZO_RES);
      ELSE
         d_indirizzo := p_indirizzo;
      END IF;

      integritypackage.LOG ('d_indirizzo ' || d_indirizzo);

      IF (    p_data_soppressione IS NOT NULL
          AND NOT check_esistenza (trim(p_codice_amministrazione), NULL) = 0)
      THEN
         RETURN;
      END IF;

      integritypackage.LOG ('dopo check_esistenza ');

      BEGIN
         SELECT codice_amministrazione,
                ni,
                ente,
                data_soppressione,
                utente_aggiornamento
           INTO d_codice_amm,
                d_ni,
                d_ente,
                d_data_soppressione,
                d_utente_agg
           FROM so4_amministrazioni
          WHERE codice_amministrazione =
                   UPPER (LTRIM (RTRIM (p_codice_amministrazione)));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_codice_amm := NULL;
            d_ni := NULL;
            d_ente := 'NO';
            d_data_soppressione := NULL;
            d_utente_agg := NULL;
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
                  'Errore in lettura amministrazione '
               || p_codice_amministrazione
               || ' - '
               || SQLERRM);
      END;

      -- Se i dati si riferiscono ad una amministrazione di un ente proprietario
      -- o se il record esiste, e' stato aggiornato dall'utente ipar e l'utente
      -- di aggiornamento passato non e' ipar,
      -- non si esegue nessuna operazione.
      IF    d_ente = 'SI'
         OR (d_utente_agg = 'ipar' AND p_utente_aggiornamento <> 'ipar')
      THEN
         RAISE uscita;
      END IF;

      --
      -- Ricerca codice comune
      --
      BEGIN
         SELECT comu.comune, comu.provincia_stato
           INTO d_codice_comune, d_codice_provincia
           FROM ad4_comuni comu, ad4_provincie prov
          WHERE     comu.denominazione = UPPER (TRIM (p_localita))
                AND comu.provincia_stato = prov.provincia
                AND prov.sigla = NVL (UPPER (TRIM (p_provincia)), prov.sigla)
                AND comu.data_soppressione IS NULL
                AND comu.provincia_fusione IS NULL
                AND comu.comune_fusione IS NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_codice_comune := NULL;
            d_codice_provincia := NULL;
      END;

--008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
      --
      -- Ricerca codice provincia
      --
--      IF d_codice_provincia IS NULL
--      THEN
--         BEGIN
--            SELECT prov.provincia
--              INTO d_codice_provincia
--              FROM ad4_provincie prov
--             WHERE prov.sigla = UPPER (TRIM (p_provincia));
--         EXCEPTION
--            WHEN OTHERS
--            THEN
--               d_codice_provincia := NULL;
--         END;
--      END IF;

      if d_codice_comune is null or d_codice_provincia is null then
         d_codice_comune := NULL;
         d_codice_provincia := NULL;
      end if;
--END 008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
      --
      d_aggiornamento := 0;

      IF d_codice_amm IS NULL
      THEN
         DBMS_OUTPUT.put_line ('sono qua');
         -- cerco se esite un soggetto con quel codice fiscale
         d_ni := check_cf (d_codice_fiscale_amm);

         IF (d_ni IS NULL OR d_ni < 0)
         THEN
            d_ni := NULL;
            as4_anagrafe_soggetti_pkg.init_ni (d_ni);
            as4_anagrafe_soggetti_tpk.ins (
               p_ni                     => d_ni,
               p_dal                    => NVL (p_data_istituzione, TRUNC (SYSDATE)),
               p_cognome                => UPPER (TRIM (p_descrizione)),
               p_indirizzo_res          => UPPER (TRIM (d_indirizzo)),
               p_provincia_res          => d_codice_provincia,
               p_comune_res             => d_codice_comune,
               p_cap_res                => d_cap,
               p_tel_res                => d_telefono,
               p_fax_res                => d_fax,
               p_tipo_soggetto          => 'E',
               p_utente                 => p_utente_aggiornamento,
               p_data_agg               => p_data_aggiornamento,
               p_competenza             => 'SI4SO',
               p_codice_fiscale         => d_codice_fiscale_amm,
               --               p_partita_iva            => d_codice_fiscale_amm,
               p_competenza_esclusiva   => 'E');
         END IF;

         so4_ammi_pkg.ins (
            p_codice_amministrazione   => TRIM (p_codice_amministrazione),
            p_ni                       => d_ni,
            p_data_istituzione         => NVL (p_data_istituzione,
                                               TRUNC (SYSDATE)),
            p_data_soppressione        => p_data_soppressione,
            p_ente                     => 'NO',
            p_utente_aggiornamento     => p_utente_aggiornamento,
            p_data_aggiornamento       => p_data_aggiornamento);
         integritypackage.LOG ('p_tipo_entita ' || 'AM');
         integritypackage.LOG ('p_id_amministrazione ' || d_ni);
         integritypackage.LOG ('p_indirizzo ' || TRIM (p_mail_istituzionale));
         integritypackage.LOG (
            'p_utente_aggiornamento ' || p_utente_aggiornamento);
         integritypackage.LOG (
            'p_data_aggiornamento ' || p_data_aggiornamento);

         so4_inte_pkg.agg_automatico (
            p_tipo_entita            => 'AM',
            p_id_amministrazione     => d_ni,
            p_tipo_indirizzo         => 'I',
            p_indirizzo              => TRIM (p_mail_istituzionale),
            p_contatti               => p_contatti,
            p_utente_aggiornamento   => p_utente_aggiornamento,
            p_data_aggiornamento     => p_data_aggiornamento);
         integritypackage.LOG ('AGGIORNATO INTE');
      ELSE
         IF TRIM (p_mail_istituzionale) IS NOT NULL
         THEN
            integritypackage.LOG ('p_tipo_entita ' || 'AM');
            integritypackage.LOG ('p_id_amministrazione ' || d_ni);
            integritypackage.LOG (
               'p_indirizzo ' || TRIM (p_mail_istituzionale));
            integritypackage.LOG (
               'p_utente_aggiornamento ' || p_utente_aggiornamento);
            integritypackage.LOG (
               'p_data_aggiornamento ' || p_data_aggiornamento);
            so4_inte_pkg.agg_automatico (
               p_tipo_entita            => 'AM',
               p_id_amministrazione     => d_ni,
               p_tipo_indirizzo         => 'I',
               p_indirizzo              => TRIM (p_mail_istituzionale),
               p_contatti               => p_contatti,
               p_utente_aggiornamento   => p_utente_aggiornamento,
               p_data_aggiornamento     => p_data_aggiornamento);
            integritypackage.LOG ('agg_automatico ');
         END IF;

         IF d_utente_agg <> 'ipar' AND p_utente_aggiornamento = 'ipar'
         THEN
            so4_ammi_pkg.upd_column (d_codice_amm,
                                     'UTENTE_AGGIORNAMENTO',
                                     'ipar');
            so4_ammi_pkg.upd_column (d_codice_amm,
                                     'DATA_AGGIORNAMENTO',
                                     SYSDATE);
         END IF;

         BEGIN
            SELECT COUNT (1), MAX (dal)
              INTO d_aggiornamento, d_dal
              FROM as4_soggetti
             WHERE     ni = d_ni
                   AND (   UPPER (cognome) <> UPPER (TRIM (p_descrizione))
                        OR UPPER (NVL (indirizzo_res, ' ')) <>
                              UPPER (NVL (TRIM (d_indirizzo), ' '))
                        OR NVL (provincia_res, 0) <>
                              NVL (d_codice_provincia, 0)
                        OR NVL (comune_res, 0) <> NVL (d_codice_comune, 0)
                        OR NVL (cap_res, ' ') <> NVL (d_cap, ' ')
                        OR NVL (tel_res, ' ') <> NVL (d_telefono, ' ')
                        OR NVL (fax_res, ' ') <> NVL (d_fax, ' ')
                        OR NVL (fax_res, ' ') <> NVL (d_fax, ' ')
                        OR NVL (codice_fiscale, ' ') <>
                              NVL (d_codice_fiscale_amm, ' ')
                        OR NVL (indirizzo_web, ' ') <>
                              NVL (p_mail_istituzionale, ' '));
         EXCEPTION
            WHEN OTHERS
            THEN
               d_aggiornamento := 0;
         END;

         integritypackage.LOG ('d_aggiornamento =' || d_aggiornamento);

         --
         IF d_aggiornamento = 1
         THEN
            /*
               DECLARE
                  d_competenza             as4_anagrafe_soggetti.competenza%TYPE;
                  d_competenza_esclusiva   as4_anagrafe_soggetti.competenza_esclusiva%TYPE;
            */
            BEGIN
               /*
               SELECT competenza, competenza_esclusiva
                 INTO d_competenza, d_competenza_esclusiva
                 FROM as4_soggetti
                WHERE ni = d_ni AND dal = d_dal;

               IF d_competenza_esclusiva <> 'E'
                  OR d_competenza NOT IN ('AGS', 'GS4', 'SI4SO')
               THEN
                  d_competenza := 'SI4SO';
               END IF;
               */
               AS4_anagrafici_pkg.allinea_anagrafica_amm_da_ipa(
                  p_ni                     => d_ni,
                  p_cognome                => UPPER (TRIM (p_descrizione)),
                  p_codice_fiscale         => d_codice_fiscale_amm,
                  p_competenza             => 'SI4SO',
                  p_competenza_esclusiva   => 'E',
                  p_tipo_soggetto          => 'E',
                  p_stato_soggetto         => 'U',
                  p_note_anag              => p_codice_amministrazione,
      ----- dati residenza
                  p_indirizzo_res          => UPPER (TRIM (d_indirizzo)),
                  p_provincia_res          => d_codice_provincia,
                  p_comune_res             => d_codice_comune,
                  p_cap_res                => d_cap,
      ---- tel_res
                  p_tel_res                => d_telefono,
      ---- fax_res
                  p_fax_res                => d_fax,
                  p_utente                 => p_utente_aggiornamento,
                  p_data_agg               => p_data_aggiornamento);

 /*              as4_anagrafe_soggetti_tpk.ins (
                  p_ni                     => d_ni,
                  p_dal                    => TRUNC (SYSDATE),
                  p_cognome                => UPPER (TRIM (p_descrizione)),
                  p_indirizzo_res          => UPPER (TRIM (d_indirizzo)),
                  p_provincia_res          => d_codice_provincia,
                  p_comune_res             => d_codice_comune,
                  p_cap_res                => d_cap,
                  p_tel_res                => d_telefono,
                  p_fax_res                => d_fax,
                  p_tipo_soggetto          => 'E',
                  p_utente                 => p_utente_aggiornamento,
                  p_data_agg               => p_data_aggiornamento,
                  p_competenza             => 'SI4SO',
                  p_codice_fiscale         => d_codice_fiscale_amm,
                  p_indirizzo_web          => p_mail_istituzionale,
                  --               p_partita_iva            => d_codice_fiscale_amm,
                  p_competenza_esclusiva   => 'E');*/
            /*IF TRUNC (SYSDATE) = TRUNC (d_dal)
            THEN
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'COGNOME',
                                                     p_descrizione);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'INDIRIZZO_RES',
                                                     d_indirizzo);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'PROVINCIA_RES',
                                                     d_codice_provincia);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'COMUNE_RES',
                                                     d_codice_comune);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'CAP_RES',
                                                     d_cap);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'TEL_RES',
                                                     d_telefono);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'FAX_RES',
                                                     d_fax);
               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'CODICE_FISCALE',
                                                     d_codice_fiscale_amm);
               --as4_anagrafe_soggetti_tpk.upd_column (d_ni,
               --                                      d_dal,
                --                                     'PARTITA_IVA',
                  --                                   d_codice_fiscale_amm);



               as4_anagrafe_soggetti_tpk.upd_column (d_ni,
                                                     d_dal,
                                                     'INDIRIZZO_WEB',
                                                     p_mail_istituzionale);

            ELSE

               d_ni := check_cf (d_codice_fiscale_amm);

               IF (d_ni IS NULL OR d_ni < 0)
               THEN
                  d_ni := NULL;
                  as4_anagrafe_soggetti_pkg.init_ni (d_ni);
                  as4_anagrafe_soggetti_tpk.ins (
                     p_ni                     => d_ni,
                     p_dal                    => TRUNC (SYSDATE),
                     p_cognome                => UPPER (TRIM (p_descrizione)),
                     p_indirizzo_res          => UPPER (TRIM (d_indirizzo)),
                     p_provincia_res          => d_codice_provincia,
                     p_comune_res             => d_codice_comune,
                     p_cap_res                => d_cap,
                     p_tel_res                => d_telefono,
                     p_fax_res                => d_fax,
                     p_tipo_soggetto          => 'E',
                     p_utente                 => p_utente_aggiornamento,
                     p_data_agg               => p_data_aggiornamento,
                     p_competenza             => d_competenza,
                     p_codice_fiscale         => d_codice_fiscale_amm,
                     --                        p_partita_iva            => d_codice_fiscale_amm,
                     p_indirizzo_web          => p_mail_istituzionale,
                     p_competenza_esclusiva   => 'E');
               END IF;

               so4_ammi_pkg.upd_column (
                  p_codice_amministrazione   => d_codice_amm,
                  p_column                   => 'NI',
                  p_value                    => d_ni);

            END IF;
            */
            END;
         END IF;

         IF NVL (d_data_soppressione, TO_DATE ('3333333', 'j')) <>
               NVL (p_data_soppressione, TO_DATE ('3333333', 'j'))
         THEN
            so4_ammi_pkg.upd_column (
               p_codice_amministrazione   => d_codice_amm,
               p_column                   => 'DATA_SOPPRESSIONE',
               p_value                    => p_data_soppressione);
         END IF;
      END IF;

      BEGIN
         integritypackage.LOG ('GESTIONE CODICI_IPA');
         so4_codici_ipa_tpk.del (p_tipo_entita => 'AM', p_progressivo => d_ni);
         integritypackage.LOG ('CANCELLATA DA CODICI_IPA');
      EXCEPTION
         WHEN AFC_ERROR.MODIFIED_BY_OTHER_USER
         THEN
            NULL;
      END;

      so4_codici_ipa_tpk.ins ('AM',
                              d_ni,
                              LTRIM (RTRIM (p_codice_amministrazione)));
      integritypackage.LOG ('INSERITA IN CODICI_IPA');

      COMMIT;
   EXCEPTION
      WHEN uscita
      THEN
         COMMIT;
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   END;                                                  -- agg_automatico_amm

   FUNCTION trova_amm (
      p_codice                 IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_ni                     IN so4_amministrazioni.ni%TYPE,
      p_denominazione          IN as4_anagrafe_soggetti.cognome%TYPE,
      p_indirizzo              IN as4_anagrafe_soggetti.indirizzo_res%TYPE,
      p_cap                    IN as4_anagrafe_soggetti.cap_res%TYPE,
      p_citta                  IN VARCHAR2,
      p_provincia              IN VARCHAR2,
      p_regione                IN VARCHAR2,
      p_sito_istituzionale     IN as4_anagrafe_soggetti.indirizzo_web%TYPE,
      p_indirizzo_telematico   IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_riferimento       IN so4_amministrazioni.data_istituzione%TYPE DEFAULT TRUNC (
                                                                                       SYSDATE))
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       nome:        trova_amm
       descrizione: trova le so4_amministrazioni che soddisfano le condizioni di ricerca
                    passate.
                    Lavora su amministrazione valide alla data di riferimento.
       parametri:   p_codice                  in so4_amministrazioni.codice_amministrazione%type
                    p_ni                      in as4_anagrafe_soggetti.ni%type
                    p_denominazione           in as4_anagrafe_soggetti.cognome%type
                    p_indirizzo               in as4_anagrafe_soggetti.indirizzo_res%type
                    p_cap                     in as4_anagrafe_soggetti.cap_res%type
                    p_citta                   in varchar2
                    p_provincia               in varchar2
                    p_regione               in varchar2
                    p_indirizzo_telematico    in so4_indirizzi_telematici.indirizzo%type
                    p_data_riferimento        in so4_amministrazioni.data_istituzione%type
                                              date dalla alla quale la registrazione
                                              deve essere valida.
       ritorna:     restituisce i record trovati in so4_amministrazioni
       note:
       revisioni:
       rev. data        autore   descrizione
       ---- ----------  ------   ------------------------------------------------------
       000  27/02/2006  sc       a14999. per j-protocollo.
       005  25/08/2015  MM       Modificata trova_amm in mod che ricerchi le
                                 amministrazioni anche solo per mail.
      ******************************************************************************/
      p_ammi_rc                afc.t_ref_cursor;
      ddatariferimento         DATE;
      ddataal                  DATE;
      dsiglaprovincia          VARCHAR2 (32000);
      dcodiceprovincia         ad4_province.provincia%TYPE;
      dcodiceregione           ad4_regioni.regione%TYPE;
      dcodicecomune            ad4_comuni.comune%TYPE;
      dcap                     ad4_comuni.cap%TYPE;
      dtempcap                 ad4_comuni.cap%TYPE;
      ddenominazione           VARCHAR2 (32000);
      dindirizzo               VARCHAR2 (32000);
      dsitoistituzionale       VARCHAR2 (32000);
      dindirizzotelematico     VARCHAR2 (32000);
      dcodiceamministrazione   VARCHAR2 (32000);
      dsql                     VARCHAR2 (32767);
      dwhere                   VARCHAR2 (32767) := 'where ';
      ddatarifdal              VARCHAR2 (100);
      ddatarifal               VARCHAR2 (100);
   BEGIN
      ddenominazione := TRIM (UPPER (REPLACE (p_denominazione, '''', '''''')));
      dindirizzo := UPPER (TRIM (REPLACE (p_indirizzo, '''', '''''')));
      dsitoistituzionale := UPPER (p_sito_istituzionale);
      dindirizzotelematico := UPPER (TRIM (p_indirizzo_telematico));
      dcodiceamministrazione := UPPER (TRIM (p_codice));
      ddatariferimento := NVL (p_data_riferimento, TRUNC (SYSDATE));
      dcap := TRIM (p_cap);
      dsiglaprovincia := UPPER (TRIM (p_provincia));
      ddataal := TRUNC (SYSDATE);

      IF ddatariferimento > ddataal
      THEN
         ddataal := ddatariferimento;
      END IF;

      ddatarifdal :=
            ' to_date('''
         || TO_CHAR (ddatariferimento, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')';
      ddatarifal :=
            ' to_date('''
         || TO_CHAR (ddataal, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')';
      dsql :=
         'select sogg.ni, sogg.dal from so4_amministrazioni ammi, as4_storico_dati_soggetto sogg ';
      dwhere :=
            dwhere
         || ' ammi.ni = sogg.ni '
         || ' and '
         || ddatarifdal
         || ' between sogg.dal and nvl(sogg.al, '
         || ddatarifal
         || ') ';

      dwhere :=
            dwhere
         || 'and ('''
         || dcodiceamministrazione
         || ''' is not null or '''
         || p_ni
         || ''' is not null or '''
         || ddenominazione
         || ''' is not null or '''
         || dindirizzotelematico
         || ''' is not null)';

      IF dcodiceamministrazione IS NOT NULL
      THEN
         --dcodiceamministrazione := dcodiceamministrazione || '%';
         dwhere :=
               dwhere
            || 'and upper(codice_amministrazione) like '''
            || dcodiceamministrazione
            || ''' ';
      END IF;

      IF dindirizzo IS NOT NULL
      THEN
         dindirizzo := dindirizzo || '%';
         dwhere :=
               dwhere
            || 'and upper(sogg.indirizzo_res) like '''
            || dindirizzo
            || ''' ';
      END IF;

      IF dsitoistituzionale IS NOT NULL
      THEN
         dsitoistituzionale := dsitoistituzionale || '%';
         dwhere :=
               dwhere
            || 'and upper(sogg.indirizzo_web) like '''
            || dsitoistituzionale
            || ''' ';
      END IF;

      IF ddenominazione IS NOT NULL
      THEN
         dwhere := dwhere || 'and trim(sogg.cognome) ';

         IF SUBSTR (ddenominazione, 1, 1) = '='
         THEN
            ddenominazione := '= ''' || SUBSTR (ddenominazione, 2) || '''';
         ELSE
            ddenominazione := 'like ''' || ddenominazione || '%''';
         END IF;

         dwhere := dwhere || ddenominazione;
      END IF;

      --      IF dindirizzotelematico IS NOT NULL
      --      THEN
      --         dindirizzotelematico := dindirizzotelematico || '%';
      --         dwhere :=
      --               dwhere
      --            || 'and upper(INDIRIZZO_TELEMATICO.GET_INDIRIZZO'
      --            || '(INDIRIZZO_TELEMATICO.GET_CHIAVE(''AM'',ammi.ni,'
      --            || ''''','''', ''I''))) like '''
      --            || dindirizzotelematico
      --            || ''' ';
      --      END IF;
      IF dindirizzotelematico IS NOT NULL
      THEN
         dsql := dsql || ', so4_indirizzi_telematici inte ';
         dindirizzotelematico := dindirizzotelematico || '%';
         dwhere :=
               dwhere
            || 'and upper(inte.INDIRIZZO) LIKE upper('''
            || dindirizzotelematico
            || ''') and inte.TIPO_ENTITA = ''AM'' and inte.TIPO_INDIRIZZO = ''I'' and inte.ID_AMMINISTRAZIONE = sogg.ni ';
      END IF;

      IF p_citta IS NOT NULL
      THEN
         dcodicecomune :=
            ad4_comune.get_comune (
               p_denominazione     => p_citta,
               p_sigla_provincia   => dsiglaprovincia,
               p_soppresso         => ad4_comune.is_soppresso (
                                        p_denominazione     => p_citta,
                                        p_sigla_provincia   => dsiglaprovincia));
      END IF;

      IF p_regione IS NOT NULL
      THEN
         dcodiceregione :=
            ad4_regione.get_regione (p_denominazione => p_regione);
      END IF;

      IF dsiglaprovincia IS NOT NULL
      THEN
         dsql := dsql || ', ad4_provincie prov ';
         dsql := dsql || dwhere;
         dsql := dsql || 'and sogg.provincia_res = prov.provincia ';
         dsql := dsql || 'and prov.sigla = ''' || dsiglaprovincia || ''' ';
      ELSE
         dsql := dsql || dwhere;
      END IF;

      IF dcodicecomune IS NOT NULL
      THEN
         dsql := dsql || 'and sogg.comune_res = ''' || dcodicecomune || ''' ';
      END IF;

      IF dcodiceprovincia IS NOT NULL
      THEN
         dsql :=
               dsql
            || 'and sogg.provincia_res = '''
            || dcodiceprovincia
            || ''' ';
      END IF;

      IF dcodiceregione IS NOT NULL
      THEN
         dsql :=
            dsql || 'and sogg.regione_res = ''' || dcodiceregione || ''' ';

         IF dsiglaprovincia IS NULL
         THEN
            FOR c IN (SELECT provincia
                        FROM ad4_province
                       WHERE regione = dcodiceregione)
            LOOP
               dsiglaprovincia := dsiglaprovincia || ',' || c.provincia;
            END LOOP;

            dsiglaprovincia := SUBSTR (dsiglaprovincia, 2);
            dsql :=
                  dsql
               || 'and sogg.provincia_res in ('
               || dsiglaprovincia
               || ') ';
         END IF;
      END IF;

      IF dcap IS NOT NULL
      THEN
         dsql := dsql || 'and sogg.cap_res = ''' || dcap || ''' ';
      END IF;

      IF NVL (p_ni, 0) > 0
      THEN
         dsql := dsql || ' and sogg.ni = ' || p_ni;
      END IF;

      DBMS_OUTPUT.put_line (SUBSTR (dsql, 1, 255));
      DBMS_OUTPUT.put_line (SUBSTR (dsql, 256, 255));
      DBMS_OUTPUT.put_line (SUBSTR (dsql, 511, 255));

      OPEN p_ammi_rc FOR dsql;

      RETURN p_ammi_rc;
   END trova_amm;

   PROCEDURE agg_automatico_aoo (
      p_codice_amministrazione   IN so4_aoo.codice_amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE,
      p_descrizione              IN so4_aoo.descrizione%TYPE,
      p_indirizzo                IN so4_aoo.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_istituzione         IN so4_aoo.dal%TYPE,
      p_data_soppressione        IN so4_aoo.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE)
   IS
   BEGIN
      agg_automatico_aoo (upper(trim(p_codice_amministrazione)),
                          p_codice_aoo,
                          p_descrizione,
                          p_indirizzo,
                          p_cap,
                          p_localita,
                          p_provincia,
                          p_telefono,
                          p_fax,
                          p_mail_istituzionale,
                          '',
                          p_data_istituzione,
                          p_data_soppressione,
                          p_utente_aggiornamento,
                          p_data_aggiornamento);
   END;

   PROCEDURE agg_automatico_aoo (
      p_codice_amministrazione   IN so4_aoo.codice_amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE,
      p_descrizione              IN so4_aoo.descrizione%TYPE,
      p_indirizzo                IN so4_aoo.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_contatti                 IN VARCHAR2,
      p_data_istituzione         IN so4_aoo.dal%TYPE,
      p_data_soppressione        IN so4_aoo.al%TYPE,
      p_utente_aggiornamento     IN so4_aoo.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_aoo.data_aggiornamento%TYPE)
   IS
      /******************************************************************************
       NOME:        agg_automatico_aoo
       DESCRIZIONE: Verifica se i dati passati sono stati modificati;
                    in caso affermativo si esegue una storicizzazione
                    altrimenti non si esegue alcuna operazione
                    Se i dati non esistevano vengono inseriti
                    -
       RITORNA:     -
      ******************************************************************************/
      d_codice_amm         so4_aoo.codice_amministrazione%TYPE;
      d_ente               so4_amministrazioni.ente%TYPE;
      d_dal_amm            so4_amministrazioni.data_istituzione%TYPE;
      d_codice_comune      so4_aoo.comune%TYPE;
      d_codice_provincia   so4_aoo.provincia%TYPE;
      d_progr_aoo          so4_aoo.progr_aoo%TYPE;
      d_dal                so4_aoo.dal%TYPE;
      d_al                 so4_aoo.al%TYPE;
      d_aggiornamento      NUMBER (1);
      d_fax                so4_aoo.fax%TYPE;
      d_cap                so4_aoo.cap%TYPE;
      d_telefono           so4_aoo.telefono%TYPE;
      d_utente_agg         so4_aoo.utente_aggiornamento%TYPE;
      uscita               EXCEPTION;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
integritypackage.LOG (' p_data_soppressione '||p_data_soppressione);
      IF LENGTH (p_fax) > L_FAX
      THEN
         d_fax := '';
      ELSE
         d_fax := p_fax;
      END IF;

      IF LENGTH (p_cap) > L_CAP
      THEN
         d_cap := '';
      ELSE
         d_cap := p_cap;
      END IF;

      IF LENGTH (p_telefono) > L_TELEFONO
      THEN
         d_telefono := '';
      ELSE
         d_telefono := p_telefono;
      END IF;

      IF (    p_data_soppressione IS NOT NULL
          AND check_esistenza (p_codice_amministrazione, p_codice_aoo) = 0)
      THEN
         RETURN;
      END IF;
integritypackage.LOG (' 2');
      BEGIN
         SELECT codice_amministrazione,
                ente,
                utente_aggiornamento,
                data_istituzione
           INTO d_codice_amm,
                d_ente,
                d_utente_agg,
                d_dal_amm
           FROM so4_amministrazioni
          WHERE codice_amministrazione =
                   UPPER (TRIM (p_codice_amministrazione));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20999,
                  'Amministrazione '
               || p_codice_amministrazione
               || ' non caricata - Impossibile procedere');
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
                  'Errore in lettura amministrazione '
               || p_codice_amministrazione
               || ' - '
               || SQLERRM);
      END;
integritypackage.LOG (' 3');
      --
      -- Se i dati si riferiscono ad una AOO di un ente proprietario
      -- non si esegue nessuna operazione
      --
      IF    d_ente = 'SI'
         OR (d_utente_agg = 'ipar' AND p_utente_aggiornamento <> 'ipar')
      THEN
         RAISE uscita;
      END IF;
integritypackage.LOG (' 4');
      --
      -- Ricerca codice comune
      --
      BEGIN
         SELECT comu.comune, comu.provincia_stato
           INTO d_codice_comune, d_codice_provincia
           FROM ad4_comuni comu, ad4_provincie prov
          WHERE     comu.denominazione = UPPER (TRIM (p_localita))
                AND comu.provincia_stato = prov.provincia
                AND prov.sigla = NVL (UPPER (TRIM (p_provincia)), prov.sigla)
                AND comu.data_soppressione IS NULL
                AND comu.provincia_fusione IS NULL
                AND comu.comune_fusione IS NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_codice_comune := NULL;
            d_codice_provincia := NULL;
      END;
integritypackage.LOG (' 5');

--008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
      --
      -- Ricerca codice provincia
      --
--      IF d_codice_provincia IS NULL
--      THEN
--         BEGIN
--            SELECT prov.provincia
--              INTO d_codice_provincia
--              FROM ad4_provincie prov
--             WHERE prov.sigla = UPPER (TRIM (p_provincia));
--         EXCEPTION
--            WHEN OTHERS
--            THEN
--               d_codice_provincia := NULL;
--         END;
--      END IF;
      if d_codice_comune is null or d_codice_provincia is null then
         d_codice_comune := NULL;
         d_codice_provincia := NULL;
      end if;

-- END 008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
integritypackage.LOG (' 6');
      --
      -- Si verifica se i dati sono stati modificati
      --
      BEGIN
         SELECT a1.progr_aoo, a1.dal, a1.al
           INTO d_progr_aoo, d_dal, d_al
           FROM so4_aoo a1
          WHERE     a1.codice_amministrazione =
                       UPPER (RTRIM (LTRIM (p_codice_amministrazione)))
                AND a1.codice_aoo = UPPER (TRIM (p_codice_aoo))
                AND NVL (a1.al, TO_DATE ('3333333', 'j')) =
                       (SELECT MAX (NVL (a2.al, TO_DATE ('3333333', 'j')))
                          FROM so4_aoo a2
                         WHERE     a2.codice_amministrazione =
                                      UPPER (TRIM (p_codice_amministrazione))
                               AND a2.codice_aoo =
                                      UPPER (TRIM (p_codice_aoo)));
      EXCEPTION
         WHEN OTHERS
         THEN
            d_progr_aoo := NULL;
            d_dal := NULL;
            d_al := NULL;
      END;
integritypackage.LOG (' 7');
      --
      IF d_progr_aoo IS NULL
      THEN
         d_dal := NVL (p_data_istituzione, TRUNC (SYSDATE));

         IF d_dal_amm > d_dal
         THEN
            d_dal := d_dal_amm;
         END IF;
integritypackage.LOG (' inserisco nuova AO '||p_codice_aoo);
         d_progr_aoo := so4_aoo_pkg.get_id_area;
integritypackage.LOG (' inserisco nuova AO progr '||d_progr_aoo);
         so4_aoo_pkg.ins (
            p_progr_aoo                => d_progr_aoo,
            p_dal                      => d_dal,
            p_codice_amministrazione   => UPPER (TRIM (p_codice_amministrazione)),
            p_codice_aoo               => TRIM (p_codice_aoo),
            p_descrizione              => UPPER (TRIM (p_descrizione)),
            p_indirizzo                => UPPER (TRIM (p_indirizzo)),
            p_cap                      => d_cap,
            p_provincia                => d_codice_provincia,
            p_comune                   => d_codice_comune,
            p_telefono                 => d_telefono,
            p_fax                      => d_fax,
            p_al                       => p_data_soppressione,
            p_utente_aggiornamento     => p_utente_aggiornamento,
            p_data_aggiornamento       => p_data_aggiornamento);

integritypackage.LOG (' inserita nuova AO progr '||d_progr_aoo);

         d_dal := NULL;

         IF TRIM (p_mail_istituzionale) IS NOT NULL
         THEN
            integritypackage.LOG ('p_tipo_entita ' || 'AO');
            integritypackage.LOG ('p_id_amministrazione ' || d_progr_aoo);
            integritypackage.LOG (
               'p_indirizzo ' || TRIM (p_mail_istituzionale));
            integritypackage.LOG (
               'p_utente_aggiornamento ' || p_utente_aggiornamento);
            integritypackage.LOG (
               'p_data_aggiornamento ' || p_data_aggiornamento);
            so4_inte_pkg.agg_automatico (
               p_tipo_entita            => 'AO',
               p_id_aoo                 => d_progr_aoo,
               p_tipo_indirizzo         => 'I',
               p_indirizzo              => TRIM (p_mail_istituzionale),
               p_contatti               => p_contatti,
               p_utente_aggiornamento   => p_utente_aggiornamento,
               p_data_aggiornamento     => p_data_aggiornamento);
         END IF;
      ELSE
         BEGIN
            SELECT 1
              INTO d_aggiornamento
              FROM so4_aoo
             WHERE     progr_aoo = d_progr_aoo
                   AND dal = d_dal
                   AND (   UPPER (descrizione) !=
                              UPPER (TRIM (p_descrizione))
                        OR NVL (UPPER (indirizzo), ' ') !=
                              NVL (UPPER (TRIM (p_indirizzo)), ' ')
                        OR NVL (cap, 0) != NVL (d_cap, 0)
                        OR NVL (provincia, 0) != NVL (d_codice_provincia, 0)
                        OR NVL (comune, 0) != NVL (d_codice_comune, 0)
                        OR NVL (telefono, ' ') != NVL (d_telefono, ' ')
                        OR NVL (fax, ' ') != NVL (d_fax, ' '));
         EXCEPTION
            WHEN OTHERS
            THEN
               d_aggiornamento := 0;
         END;

         IF d_aggiornamento = 1
         THEN
            IF d_dal = TRUNC (SYSDATE)
            THEN
               --aggiorno
               so4_aoo_pkg.upd_column (
                  p_progr_aoo   => d_progr_aoo,
                  p_dal         => d_dal,
                  p_column      => 'DESCRIZIONE',
                  p_value       => UPPER (TRIM (p_descrizione)));
               so4_aoo_pkg.upd_column (
                  p_progr_aoo   => d_progr_aoo,
                  p_dal         => d_dal,
                  p_column      => 'INDIRIZZO',
                  p_value       => UPPER (TRIM (p_indirizzo)));
               so4_aoo_pkg.upd_column (p_progr_aoo   => d_progr_aoo,
                                       p_dal         => d_dal,
                                       p_column      => 'CAP',
                                       p_value       => d_cap);
               so4_aoo_pkg.upd_column (
                  p_progr_aoo   => d_progr_aoo,
                  p_dal         => d_dal,
                  p_column      => 'PROVINCIA',
                  p_value       => NVL (d_codice_provincia, 0));
               so4_aoo_pkg.upd_column (
                  p_progr_aoo   => d_progr_aoo,
                  p_dal         => d_dal,
                  p_column      => 'COMUNE',
                  p_value       => NVL (d_codice_comune, 0));
               so4_aoo_pkg.upd_column (p_progr_aoo   => d_progr_aoo,
                                       p_dal         => d_dal,
                                       p_column      => 'TELEFONO',
                                       p_value       => NVL (d_telefono, ' '));
               so4_aoo_pkg.upd_column (p_progr_aoo   => d_progr_aoo,
                                       p_dal         => d_dal,
                                       p_column      => 'FAX',
                                       p_value       => NVL (d_fax, ' '));
            ELSE
               /* modifica per evitare aggiornamenti di aoo chiuse */
               IF TRUNC (SYSDATE) > p_data_soppressione
               THEN
                  so4_aoo_pkg.upd_column (
                     p_progr_aoo   => d_progr_aoo,
                     p_dal         => d_dal,
                     p_column      => 'AL',
                     p_value       => p_data_soppressione);
               ELSE
                  IF d_dal_amm > d_dal
                  THEN
                     so4_aoo_pkg.upd_column (d_progr_aoo,
                                             d_dal,
                                             'DAL',
                                             d_dal_amm);
                  END IF;
                  d_dal := TRUNC (SYSDATE);
                  so4_aoo_pkg.ins (
                     p_progr_aoo                => d_progr_aoo,
                     p_dal                      => TRUNC (SYSDATE),
                     p_codice_amministrazione   => UPPER (TRIM (p_codice_amministrazione)),
                     p_codice_aoo               => TRIM (p_codice_aoo),
                     p_descrizione              => UPPER (
                                                     TRIM (p_descrizione)),
                     p_indirizzo                => UPPER (TRIM (p_indirizzo)),
                     p_cap                      => d_cap,
                     p_provincia                => d_codice_provincia,
                     p_comune                   => d_codice_comune,
                     p_telefono                 => d_telefono,
                     p_fax                      => d_fax,
                     p_al                       => p_data_soppressione,
                     p_utente_aggiornamento     => p_utente_aggiornamento,
                     p_data_aggiornamento       => p_data_aggiornamento);
               END IF;
            END IF;
         ELSE
            IF     p_data_soppressione IS NOT NULL
               AND p_data_soppressione <>
                      NVL (d_al, TO_DATE ('3333333', 'j'))
            THEN
               so4_aoo_pkg.upd_column (p_progr_aoo   => d_progr_aoo,
                                       p_dal         => d_dal,
                                       p_column      => 'AL',
                                       p_value       => p_data_soppressione);
            END IF;
         END IF;

         IF TRIM (p_mail_istituzionale) IS NOT NULL
         THEN
            integritypackage.LOG ('p_tipo_entita ' || 'AO');
            integritypackage.LOG ('p_id_amministrazione ' || d_progr_aoo);
            integritypackage.LOG (
               'p_indirizzo ' || TRIM (p_mail_istituzionale));
            integritypackage.LOG (
               'p_utente_aggiornamento ' || p_utente_aggiornamento);
            integritypackage.LOG (
               'p_data_aggiornamento ' || p_data_aggiornamento);
            so4_inte_pkg.agg_automatico (
               p_tipo_entita            => 'AO',
               p_id_aoo                 => d_progr_aoo,
               p_tipo_indirizzo         => 'I',
               p_indirizzo              => TRIM (p_mail_istituzionale),
               p_contatti               => p_contatti,
               p_utente_aggiornamento   => p_utente_aggiornamento,
               p_data_aggiornamento     => p_data_aggiornamento);
         END IF;

      END IF;

      BEGIN
         so4_codici_ipa_tpk.del (p_tipo_entita   => 'AO',
                                 p_progressivo   => d_progr_aoo);
      EXCEPTION
         WHEN AFC_ERROR.MODIFIED_BY_OTHER_USER
         THEN
            NULL;
      END;

      so4_codici_ipa_tpk.ins ('AO',
                              d_progr_aoo,
                              LTRIM (RTRIM (p_codice_aoo)));

      COMMIT;
   --
   EXCEPTION
      WHEN uscita
      THEN
         COMMIT;
      WHEN OTHERS
      THEN
         RAISE;
         ROLLBACK;
   END;                                                  -- agg_automatico_aoo

   FUNCTION trova_aoo (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE,
      p_ni                       IN so4_aoo.progr_aoo%TYPE,
      p_denominazione            IN so4_aoo.descrizione%TYPE,
      p_indirizzo                IN so4_aoo.indirizzo%TYPE,
      p_cap                      IN so4_aoo.cap%TYPE,
      p_citta                    IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_regione                  IN VARCHAR2,
      p_sito_istituzionale          as4_anagrafe_soggetti.indirizzo_web%TYPE,
      p_indirizzo_telematico        so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_riferimento            so4_aoo.dal%TYPE DEFAULT TRUNC (SYSDATE))
      RETURN afc.t_ref_cursor
   IS                                                         /* SLAVE_COPY */
      /******************************************************************************
       NOME:        TROVA_so4_aoo
       DESCRIZIONE: Trova le AOO che soddisfano le condizioni di ricerca passate.
                    Lavora su so4_aoo valide alla data di riferimento.
       PARAMETRI:   p_codice_amministrazione  IN so4_amministrazioni.CODICE_AMMINISTRAZIONE%TYPE
                    p_codice_aoo              IN so4_aoo.CODICE_AOO%TYPE
                    p_ni                      IN so4_aoo.PROGR_AOO%TYPE
                    p_denominazione           IN so4_aoo.DESCRIZIONE%TYPE
                    p_indirizzo               IN so4_aoo.INDIRIZZO%TYPE
                    p_cap                     IN so4_aoo.CAP%TYPE
                    p_citta                   IN VARCHAR2
                    p_provincia               IN VARCHAR2
                    p_regione                 in varchar2
                    p_indirizzo_telematico    IN so4_indirizzi_telematici.INDIRIZZO%TYPE
                    p_data_riferimento        IN SO4_AOO.DAL%TYPE
       RITORNA:     Restituisce i record trovati in so4_aoo.
       NOTE:
       REVISIONI:
       Rev. Data        Autore      Descrizione
       ---- ----------  ------      ------------------------------------------------------
       0    28/02/2006   SC          A14999. Per J-Protocollo.
      ******************************************************************************/
      p_aoo_rc                 afc.t_ref_cursor;
      ddatariferimento         DATE;
      ddataal                  DATE;
      dsiglaprovincia          ad4_province.sigla%TYPE;
      dcodiceprovincia         ad4_province.provincia%TYPE;
      dcodiceregione           ad4_regioni.regione%TYPE;
      dcodicecomune            ad4_comuni.comune%TYPE;
      dcap                     ad4_comuni.cap%TYPE;
      dtempcap                 ad4_comuni.cap%TYPE;
      ddenominazione           VARCHAR2 (32000);
      dindirizzo               VARCHAR2 (32000);
      dsitoistituzionale       VARCHAR2 (32000);
      dindirizzotelematico     VARCHAR2 (32000);
      dcodiceamministrazione   VARCHAR2 (32000);
      dcodiceaoo               VARCHAR2 (32000);
      dsql                     VARCHAR2 (32767);
      dwhere                   VARCHAR2 (32767) := 'where 1=1 ';
      ddatarifdal              VARCHAR2 (100);
      ddatarifal               VARCHAR2 (100);
   BEGIN
      ddenominazione := TRIM (UPPER (REPLACE (p_denominazione, '''', '''''')));
      dindirizzo := UPPER (TRIM (REPLACE (p_indirizzo, '''', '''''')));
      dsitoistituzionale := UPPER (TRIM (p_sito_istituzionale));
      dindirizzotelematico := UPPER (TRIM (p_indirizzo_telematico));
      dcodiceamministrazione := UPPER (TRIM (p_codice_amministrazione));
      dcodiceaoo := UPPER (TRIM (p_codice_aoo));
      ddatariferimento := NVL (p_data_riferimento, TRUNC (SYSDATE));
      dcap := p_cap;
      dsiglaprovincia := UPPER (TRIM (p_provincia));
      ddataal := TRUNC (SYSDATE);

      IF ddatariferimento > ddataal
      THEN
         ddataal := ddatariferimento;
      END IF;

      ddatarifdal :=
            ' to_date('''
         || TO_CHAR (ddatariferimento, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')';
      ddatarifal :=
            ' to_date('''
         || TO_CHAR (ddataal, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')';
      dsql :=
         'select so4_aoo.progr_aoo, so4_aoo.dal from so4_aoo, ad4_province, ad4_regioni ';
      dwhere :=
            dwhere
         || 'and'
         || ddatarifdal
         || ' between so4_aoo.dal and nvl(so4_aoo.al, '
         || ddatarifal
         || ') '
         || ' and ad4_province.provincia (+) = so4_aoo.provincia '
         || ' and ad4_regioni.regione (+) = ad4_province.regione ';

      dwhere :=
            dwhere
         || 'and ('''
         || dcodiceamministrazione
         || ''' is not null or '''
         || dcodiceaoo
         || ''' is not null or '''
         || p_ni
         || ''' is not null or '''
         || dindirizzotelematico
         || ''' is not null or '''
         || ddenominazione
         || ''' is not null)';

      IF dcodiceaoo IS NOT NULL
      THEN
         --dcodiceaoo := dcodiceaoo || '%';
         dwhere :=
               dwhere
            || 'and upper(so4_aoo.codice_aoo) like '''
            || dcodiceaoo
            || ''' ';
      END IF;

      IF dcodiceamministrazione IS NOT NULL
      THEN
         --dcodiceamministrazione := dcodiceamministrazione || '%';
         dwhere :=
               dwhere
            || 'and upper(so4_aoo.codice_amministrazione) like '''
            || dcodiceamministrazione
            || ''' ';
      END IF;

      IF dindirizzo IS NOT NULL
      THEN
         dindirizzo := dindirizzo || '%';
         dwhere :=
               dwhere
            || 'and upper(so4_aoo.indirizzo) like '''
            || dindirizzo
            || ''' ';
      END IF;

      IF ddenominazione IS NOT NULL
      THEN
         dwhere := dwhere || 'and trim(so4_aoo.descrizione) ';

         IF SUBSTR (ddenominazione, 1, 1) = '='
         THEN
            ddenominazione := '= ''' || SUBSTR (ddenominazione, 2) || '''';
         ELSE
            ddenominazione := 'like ''' || ddenominazione || '%''';
         END IF;

         dwhere := dwhere || ddenominazione;
      END IF;

      --   if dIndirizzoTelematico is not null then
      --      dIndirizzoTelematico := dIndirizzoTelematico||'%';
      --      dWhere := dWhere||'and upper(INDIRIZZO_TELEMATICO.GET_INDIRIZZO'
      --                      ||'(INDIRIZZO_TELEMATICO.GET_CHIAVE(''AO'','''','
      --                      ||'so4_aoo.progr_aoo,'''', ''I''))) like '''||dIndirizzoTelematico||''' ';
      --   end if;
      IF dindirizzotelematico IS NOT NULL
      THEN
         dsql := dsql || ', so4_indirizzi_telematici inte ';
         dindirizzotelematico := dindirizzotelematico || '%';
         dwhere :=
               dwhere
            || 'and upper(inte.INDIRIZZO) LIKE upper('''
            || dindirizzotelematico
            || ''') and inte.TIPO_ENTITA = ''AO'' and inte.TIPO_INDIRIZZO = ''I'' and inte.ID_AOO = so4_aoo.progr_aoo ';
      END IF;

      IF p_citta IS NOT NULL
      THEN
         -- NON passa dCap a questa funzione per non sovrascrivere l'eventuale cap
         -- passato. Se anche fosse stato passato nullo, e' sbagliato sovrascriverlo
         -- in ricerca perche' passare null significa che vanno bene tutti.
         /*      dCodiceComune := ad4_comune.get_comune( p_denominazione => p_citta
                                                     , p_cap => dTempCap
                                                     , p_sigla_provincia => dSiglaProvincia
                                                     , p_provincia => dCodiceProvincia);*/
         dcodicecomune :=
            ad4_comune.get_comune (
               p_denominazione     => p_citta,
               p_sigla_provincia   => dsiglaprovincia,
               p_soppresso         => ad4_comune.is_soppresso (
                                        p_denominazione     => p_citta,
                                        p_sigla_provincia   => dsiglaprovincia));
      END IF;

      IF dsiglaprovincia IS NOT NULL
      THEN
         dsql := dsql || ', ad4_provincie prov ';
         dsql := dsql || dwhere;
         dsql := dsql || 'and so4_aoo.PROVINCIA = prov.PROVINCIA ';
         dsql := dsql || 'and prov.SIGLA = ''' || dsiglaprovincia || ''' ';
      ELSE
         dsql := dsql || dwhere;
      END IF;

      IF p_regione IS NOT NULL
      THEN
         dcodiceregione :=
            ad4_regione.get_regione (p_denominazione => p_regione);
      END IF;

      IF dcodicecomune IS NOT NULL
      THEN
         dsql := dsql || 'and so4_aoo.COMUNE = ''' || dcodicecomune || ''' ';
      END IF;

      IF dcodiceprovincia IS NOT NULL
      THEN
         dsql :=
            dsql || 'and so4_aoo.PROVINCIA = ''' || dcodiceprovincia || ''' ';
      END IF;

      IF dcodiceregione IS NOT NULL
      THEN
         dsql :=
            dsql || 'and ad4_regione.regione = ''' || dcodiceregione || ''' ';
      END IF;

      IF dcap IS NOT NULL
      THEN
         dsql := dsql || 'and so4_aoo.cap = ''' || dcap || ''' ';
      END IF;

      IF NVL (p_ni, 0) > 0
      THEN
         dsql := dsql || ' and so4_aoo.progr_aoo = ' || p_ni;
      END IF;

      integritypackage.LOG (dSql);

      OPEN p_aoo_rc FOR dsql;

      RETURN p_aoo_rc;
   END trova_aoo;

   PROCEDURE agg_automatico_uo (
      p_codice_amministrazione   IN so4_auor.amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE DEFAULT NULL,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_descrizione              IN VARCHAR2,
      p_dal                      IN so4_auor.dal%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_soppressione        IN so4_auor.al%TYPE,
      p_utente_aggiornamento     IN so4_auor.utente_aggiornamento%TYPE,
      p_data_aggiornamento       IN so4_auor.data_aggiornamento%TYPE)
   IS
   BEGIN
      agg_automatico_uo (p_codice_amministrazione,
                         p_codice_aoo,
                         p_codice_uo,
                         p_descrizione,
                         p_dal,
                         p_indirizzo,
                         p_cap,
                         p_localita,
                         p_provincia,
                         p_telefono,
                         p_fax,
                         p_mail_istituzionale,
                         '',
                         p_data_soppressione,
                         p_utente_aggiornamento,
                         '',
                         p_data_aggiornamento);
   END;


   PROCEDURE agg_automatico_uo (
      p_codice_amministrazione   IN so4_auor.amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE ,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_descrizione              IN VARCHAR2,
      p_dal                      IN so4_auor.dal%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_soppressione        IN so4_auor.al%TYPE,
      p_utente_aggiornamento     IN so4_auor.utente_aggiornamento%TYPE ,
      p_codice_fiscale_sfe       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE ,
      p_data_aggiornamento       IN so4_auor.data_aggiornamento%TYPE )
   IS
   BEGIN
      agg_automatico_uo (upper(trim(p_codice_amministrazione)),
                         upper(trim(p_codice_aoo)),
                         p_codice_uo,
                         p_descrizione,
                         p_dal,
                         p_indirizzo,
                         p_cap,
                         p_localita,
                         p_provincia,
                         p_telefono,
                         p_fax,
                         p_mail_istituzionale,
                         '',
                         p_data_soppressione,
                         p_utente_aggiornamento,
                         p_codice_fiscale_sfe,
                         p_data_aggiornamento);
   END;

   PROCEDURE agg_automatico_uo (
      p_codice_amministrazione   IN so4_auor.amministrazione%TYPE,
      p_codice_aoo               IN so4_aoo.codice_aoo%TYPE ,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_descrizione              IN VARCHAR2,
      p_dal                      IN so4_auor.dal%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN VARCHAR2,
      p_localita                 IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_telefono                 IN VARCHAR2,
      p_fax                      IN VARCHAR2,
      p_mail_istituzionale       IN so4_indirizzi_telematici.indirizzo%TYPE,
      p_contatti                 IN VARCHAR2,
      p_data_soppressione        IN so4_auor.al%TYPE,
      p_utente_aggiornamento     IN so4_auor.utente_aggiornamento%TYPE ,
      p_codice_fiscale_sfe       IN AS4_ANAGRAFE_SOGGETTI.CODICE_FISCALE%TYPE ,
      p_data_aggiornamento       IN so4_auor.data_aggiornamento%TYPE )
   IS
      /******************************************************************************
       NOME:        agg_automatico_uo
       DESCRIZIONE: Verifica se i dati passati sono stati modificati;
                    in caso affermativo si esegue una storicizzazione
                    altrimenti non si esegue alcuna operazione
                    Se i dati non esistevano vengono inseriti
                    -
       RITORNA:     -
      ******************************************************************************/
      d_codice_amm               so4_auor.amministrazione%TYPE;
      d_ente                     so4_amministrazioni.ente%TYPE;
      d_progr_aoo                so4_aoo.progr_aoo%TYPE;
      d_progr_uo                 so4_auor.progr_unita_organizzativa%TYPE;
      d_codice_comune            so4_aoo.comune%TYPE;
      d_codice_provincia         so4_aoo.provincia%TYPE;
      d_dal                      so4_auor.dal%TYPE;
      d_al                       so4_auor.al%TYPE;
      d_ottica                   so4_auor.ottica%TYPE;
      d_fax                      so4_aoo.fax%TYPE;
      d_cap                      so4_aoo.cap%TYPE;
      d_telefono                 so4_aoo.telefono%TYPE;
      d_indirizzo                as4_anagrafe_soggetti.indirizzo_res%TYPE;
      d_aggiornamento            NUMBER (1) := 0;
      d_aggiornamento_soggetto   NUMBER (1) := 0;
      uscita                     EXCEPTION;
      d_descrizione              so4_auor.descrizione%TYPE;
      d_utente_agg               so4_aoo.utente_aggiornamento%TYPE;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF LENGTH (p_fax) > L_FAX
      THEN
         d_fax := '';
      ELSE
         d_fax := p_fax;
      END IF;

      IF LENGTH (p_cap) > L_CAP
      THEN
         d_cap := '';
      ELSE
         d_cap := p_cap;
      END IF;

      IF LENGTH (p_telefono) > L_TELEFONO
      THEN
         d_telefono := '';
      ELSE
         d_telefono := p_telefono;
      END IF;

      IF LENGTH (p_descrizione) > L_DESCRIZIONE
      THEN
         d_descrizione := SUBSTR (p_descrizione, 1, L_DESCRIZIONE);
      ELSE
         d_descrizione := p_descrizione;
      END IF;

      IF LENGTH (p_indirizzo) > L_INDIRIZZO_RES
      THEN
         d_indirizzo := SUBSTR (p_indirizzo, 1, L_INDIRIZZO_RES);
      ELSE
         d_indirizzo := p_indirizzo;
      END IF;

      --
      -- Se i dati si riferiscono ad una UO di un ente proprietario
      -- non si esegue nessuna operazione
      --
      IF    d_ente = 'SI'
         OR (d_utente_agg = 'ipar' AND p_utente_aggiornamento <> 'ipar')
      THEN
         RAISE uscita;
      END IF;

      --
      -- Ricerca codice comune
      --
      /* INSERT INTO test_alex (valore, codice, last_Date)
            VALUES (
                      '022',
                      'Ricerca codice comune',
                      TO_CHAR (SYSTIMESTAMP, 'HH24:MI:SS.FF6'));*/

      BEGIN
         SELECT comu.comune, comu.provincia_stato
           INTO d_codice_comune, d_codice_provincia
           FROM ad4_comuni comu, ad4_provincie prov
          WHERE     comu.denominazione = UPPER (TRIM (p_localita))
                AND comu.provincia_stato = prov.provincia
                AND prov.sigla = NVL (UPPER (TRIM (p_provincia)), prov.sigla)
                AND comu.data_soppressione IS NULL
                AND comu.provincia_fusione IS NULL
                AND comu.comune_fusione IS NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_codice_comune := NULL;
            d_codice_provincia := NULL;
      END;

--008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
      --
      -- Ricerca codice provincia
      --

--      IF d_codice_provincia IS NULL
--      THEN
--         BEGIN
--            SELECT prov.provincia
--              INTO d_codice_provincia
--              FROM ad4_provincie prov
--             WHERE prov.sigla = UPPER (TRIM (p_provincia));
--         EXCEPTION
--            WHEN OTHERS
--            THEN
--               d_codice_provincia := NULL;
--         END;
--      END IF;

      if d_codice_comune is null or d_codice_provincia is null then
         d_codice_comune := NULL;
         d_codice_provincia := NULL;
      end if;

--END 008 03/01/2020          Bug #39593 Scarico IPA: comuni che hanno cambiato provincia
      --
      -- Ricerca progr_aoo
      --
      BEGIN
         SELECT a1.progr_aoo
           INTO d_progr_aoo
           FROM so4_aoo a1
          WHERE a1.codice_aoo = UPPER (TRIM (p_codice_aoo));
      EXCEPTION
         WHEN OTHERS
         THEN
            d_progr_aoo := NULL;
      END;

      --
      -- Ricerca Ottica
      --

      d_ottica := 'EXTRAISTITUZIONALE';

      --
      -- Verifica se uo già presente in anagrafica
      --
      BEGIN
         SELECT a1.progr_unita_organizzativa, a1.dal, a1.al
           INTO d_progr_uo, d_dal, d_al
           FROM so4_auor a1
          WHERE     a1.amministrazione =
                       UPPER (TRIM (p_codice_amministrazione))
                AND a1.codice_uo = UPPER (TRIM (p_codice_uo))
                AND NVL (a1.al, TO_DATE ('3333333', 'j')) =
                       (SELECT MAX (NVL (a2.al, TO_DATE ('3333333', 'j')))
                          FROM so4_auor a2
                         WHERE     a2.amministrazione =
                                      UPPER (TRIM (p_codice_amministrazione))
                               AND a2.codice_uo = UPPER (TRIM (p_codice_uo)));
      EXCEPTION
         WHEN OTHERS
         THEN
            d_progr_uo := NULL;
            d_dal := NULL;
            d_al := NULL;
      END;


      integritypackage.LOG ('d_progr_uo ' || d_progr_uo);

      -- se unita non esiste
      IF d_progr_uo IS NULL
      THEN
         -- insert into test_alex(valore,codice,last_Date) values('02_bis','non esiste unita',to_char(systimestamp, 'HH24:MI:SS.FF6'));

         d_progr_uo :=  so4_auor_pkg.get_id_unita;
         integritypackage.LOG ('d_progr_uo nuova ' || d_progr_uo);

         --- da inserire anche d_ni  poi aggiunge questo pck la riga dentro so4_soggetti_unita
         so4_auor_pkg.ins (
            p_progr_unita_organizzativa   => d_progr_uo,
            p_dal                         => NVL (p_dal, TRUNC (SYSDATE)),
            p_codice_uo                   => TRIM (p_codice_uo),
            p_descrizione                 => UPPER (TRIM (d_descrizione)),
            p_ottica                      => UPPER (TRIM (d_ottica)),
            p_amministrazione             => UPPER (TRIM (
                                                  p_codice_amministrazione)),
            p_progr_aoo                   => d_progr_aoo,
            p_indirizzo                   => UPPER (TRIM (p_indirizzo)),
            p_cap                         => d_cap,
            p_provincia                   => d_codice_provincia,
            p_comune                      => d_codice_comune,
            p_telefono                    => d_telefono,
            p_fax                         => d_fax,
            p_utente_aggiornamento        => p_utente_aggiornamento,
            p_data_aggiornamento          => p_data_aggiornamento);


--         IF (p_mail_istituzionale IS NOT NULL)
--         THEN
--            BEGIN
--               integritypackage.LOG ('p_tipo_entita ' || 'UO');
--               integritypackage.LOG ('p_id_amministrazione ' || p_codice_amministrazione);
--               integritypackage.LOG (
--                  'p_indirizzo ' || TRIM (p_mail_istituzionale));
--               integritypackage.LOG (
--                  'p_utente_aggiornamento ' || p_utente_aggiornamento);
--               integritypackage.LOG (
--                  'p_data_aggiornamento ' || p_data_aggiornamento);
--               so4_inte_pkg.ins (
--                  p_tipo_entita              => 'UO',
--                  p_id_indirizzo             => NULL,
--                  p_tipo_indirizzo           => 'I',
--                  p_id_unita_organizzativa   => d_progr_uo,
--                  p_indirizzo                => TRIM (p_mail_istituzionale),
--                  p_utente_aggiornamento     => p_utente_aggiornamento,
--                  p_data_aggiornamento       => p_data_aggiornamento);
--            END;
--         END IF;

         so4_inte_pkg.agg_automatico (
            p_tipo_entita              => 'UO',
            p_id_unita_organizzativa   => d_progr_uo,
            p_tipo_indirizzo           => 'I',
            p_indirizzo                => TRIM (p_mail_istituzionale),
            p_contatti                 => p_contatti,
            p_utente_aggiornamento     => p_utente_aggiornamento,
            p_data_aggiornamento       => p_data_aggiornamento);
      ELSE
         --se l'unita  esiste
         DBMS_OUTPUT.put_line ('ELSE');

         IF TRIM (p_mail_istituzionale) IS NOT NULL
         THEN
            integritypackage.LOG ('p_tipo_entita ' || 'UO');
            integritypackage.LOG ('p_id_amministrazione ' || d_progr_uo);
            integritypackage.LOG (
               'p_indirizzo ' || TRIM (p_mail_istituzionale));
            integritypackage.LOG (
               'p_utente_aggiornamento ' || p_utente_aggiornamento);
            integritypackage.LOG (
               'p_data_aggiornamento ' || p_data_aggiornamento);

            integritypackage.LOG ('SONO QUI ');

            BEGIN
               so4_inte_pkg.agg_automatico (
                  p_tipo_entita              => 'UO',
                  p_id_unita_organizzativa   => d_progr_uo,
                  p_tipo_indirizzo           => 'I',
                  p_indirizzo                => TRIM (p_mail_istituzionale),
                  p_contatti                 => p_contatti,
                  p_utente_aggiornamento     => p_utente_aggiornamento,
                  p_data_aggiornamento       => p_data_aggiornamento);
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            DBMS_OUTPUT.put_line (
               'lanciato il pkg so4_inte_pkg.agg_automatico se esiste mail istituzionale');

            integritypackage.LOG ('POST agg_automatico ');
         -- insert into test_alex(valore,codice,last_Date) values('05','sonoi qui',to_char(systimestamp, 'HH24:MI:SS.FF6'));
         END IF;

         DBMS_OUTPUT.put_line ('-- qui vedo se CE da aggiornare unita');
         -- qui vedo se c'e' da aggiornare unita
         BEGIN
            SELECT 1
              INTO d_aggiornamento
              FROM so4_auor
             WHERE     progr_unita_organizzativa = d_progr_uo
                   AND dal = d_dal
                   AND (   UPPER (descrizione) !=
                              UPPER (TRIM (d_descrizione))
                        OR NVL (UPPER (indirizzo), ' ') !=
                              NVL (UPPER (TRIM (p_indirizzo)), ' ')
                        OR NVL (cap, 0) != NVL (d_cap, 0)
                        OR NVL (provincia, 0) != NVL (d_codice_provincia, 0)
                        OR NVL (comune, 0) != NVL (d_codice_comune, 0)
                        OR NVL (telefono, ' ') != NVL (d_telefono, ' ')
                        OR NVL (fax, ' ') != NVL (d_fax, ' '));
         EXCEPTION
            WHEN OTHERS
            THEN
               d_aggiornamento := 0;
         END;

         /*
                  INSERT INTO test_alex (valore, codice, last_Date)
                       VALUES (
                                 '08',
                                 'd_aggiornamento=' || d_aggiornamento,
                                 TO_CHAR (SYSTIMESTAMP, 'HH24:MI:SS.FF6'));
         */
         IF d_aggiornamento = 1
         THEN
            IF d_dal = TRUNC (SYSDATE)
            THEN
               DBMS_OUTPUT.put_line ('XXXXXXXXXXXXXXXXXXXXXXXXXXXX');
               -- aggiorno
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'DESCRIZIONE',
                  p_value                       => UPPER (
                                                     TRIM (d_descrizione)));
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'INDIRIZZO',
                  p_value                       => UPPER (TRIM (p_indirizzo)));
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'CAP',
                  p_value                       => d_cap);
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'PROVINCIA',
                  p_value                       => NVL (d_codice_provincia, 0));
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'COMUNE',
                  p_value                       => NVL (d_codice_comune, 0));
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'TELEFONO',
                  p_value                       => NVL (d_telefono, ' '));
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'FAX',
                  p_value                       => NVL (d_fax, ' '));
            ELSE
               integritypackage.LOG ('DAL DIVERSO DA OGGI');
               integritypackage.LOG ('PRIMA DELLA INS');

               IF TRUNC (SYSDATE) > p_data_soppressione
               THEN
                  d_dal := p_data_soppressione;
               ELSE
                  d_dal := TRUNC (SYSDATE);
               END IF;

               integritypackage.LOG ('d_progr_uo ' || d_progr_uo);
               integritypackage.LOG ('p_dal ' || TRUNC (SYSDATE));

               integritypackage.LOG (
                  'p_codice_uo ' || UPPER (TRIM (p_codice_uo)));
               integritypackage.LOG (
                  'p_descrizione ' || UPPER (TRIM (d_descrizione)));

               integritypackage.LOG ('p_ottica ' || UPPER (TRIM (d_ottica)));
               integritypackage.LOG (
                     'p_amministrazione '
                  || UPPER (TRIM (p_codice_amministrazione)));

               integritypackage.LOG ('p_progr_aoo ' || d_progr_aoo);
               integritypackage.LOG (
                  'p_indirizzo ' || UPPER (TRIM (p_indirizzo)));
               integritypackage.LOG ('p_cap ' || d_cap);
               integritypackage.LOG ('p_provincia ' || d_codice_provincia);
               integritypackage.LOG ('p_comune ' || d_codice_comune);
               integritypackage.LOG ('p_telefono ' || D_telefono);
               integritypackage.LOG ('p_fax ' || D_fax);
               integritypackage.LOG ('p_al ' || p_data_soppressione);
               integritypackage.LOG (
                  'p_utente_aggiornamento ' || p_utente_aggiornamento);
               integritypackage.LOG (
                  'p_data_aggiornamento ' || p_data_aggiornamento);
               so4_auor_pkg.ins (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => TRUNC (SYSDATE),
                  p_codice_uo                   => TRIM (p_codice_uo),
                  p_descrizione                 => UPPER (
                                                     TRIM (d_descrizione)),
                  p_ottica                      => UPPER (TRIM (d_ottica)),
                  p_amministrazione             => UPPER (TRIM (
                                                        p_codice_amministrazione)),
                  p_progr_aoo                   => d_progr_aoo,
                  p_indirizzo                   => UPPER (TRIM (p_indirizzo)),
                  p_cap                         => d_cap,
                  p_provincia                   => d_codice_provincia,
                  p_comune                      => d_codice_comune,
                  p_telefono                    => d_telefono,
                  p_fax                         => d_fax,
                  p_al                          => p_data_soppressione,
                  p_utente_aggiornamento        => p_utente_aggiornamento,
                  p_data_aggiornamento          => p_data_aggiornamento);
               integritypackage.LOG ('DOPO LA INS');
            END IF;
         ELSE
            IF     p_data_soppressione IS NOT NULL
               AND p_data_soppressione <>
                      NVL (d_al, TO_DATE ('3333333', 'j'))
            THEN
               so4_auor_pkg.upd_column (
                  p_progr_unita_organizzativa   => d_progr_uo,
                  p_dal                         => d_dal,
                  p_column                      => 'AL',
                  p_value                       => p_data_soppressione);
            END IF;
         END IF;
      END IF;


      BEGIN
         so4_codici_ipa_tpk.del (p_tipo_entita   => 'UO',
                                 p_progressivo   => d_progr_uo);
      EXCEPTION
         WHEN AFC_ERROR.MODIFIED_BY_OTHER_USER
         THEN
            NULL;
      END;

      so4_codici_ipa_tpk.ins ('UO', d_progr_uo, LTRIM (RTRIM (p_codice_uo)));
      COMMIT;
   EXCEPTION
      WHEN uscita
      THEN
         COMMIT;
      WHEN OTHERS
      THEN
         RAISE;
         ROLLBACK;
   END;                                                   -- agg_automatico_uo

   FUNCTION trova_uo (
      p_codice_amministrazione   IN so4_amministrazioni.codice_amministrazione%TYPE,
      p_codice_uo                IN so4_auor.codice_uo%TYPE,
      p_ni                       IN so4_auor.progr_unita_organizzativa%TYPE,
      p_denominazione            IN so4_auor.descrizione%TYPE,
      p_indirizzo                IN so4_auor.indirizzo%TYPE,
      p_cap                      IN so4_auor.cap%TYPE,
      p_citta                    IN VARCHAR2,
      p_provincia                IN VARCHAR2,
      p_regione                  IN VARCHAR2,
      p_indirizzo_telematico        so4_indirizzi_telematici.indirizzo%TYPE,
      p_data_riferimento            so4_aoo.dal%TYPE DEFAULT TRUNC (SYSDATE))
      RETURN afc.t_ref_cursor
   IS                                                         /* SLAVE_COPY */
      /******************************************************************************
       NOME:        TROVA
       DESCRIZIONE: Trova le UO che soddisfano le condizioni di ricerca passate.
                    Lavora su UO valide alla data di riferimento.
       PARAMETRI:   p_codice_amministrazione  IN SO4_AMMINISTRAZIONI.CODICE_AMMINISTRAZIONE%TYPE
                    p_codice_aoo              IN so4_aoo.CODICE_AOO%TYPE
                    p_ni                      IN so4_aoo.PROGR_AOO%TYPE
                    p_denominazione           IN so4_aoo.DESCRIZIONE%TYPE
                    p_indirizzo               IN so4_aoo.INDIRIZZO%TYPE
                    p_cap                     IN so4_aoo.CAP%TYPE
                    p_citta                   IN VARCHAR2
                    p_provincia               IN VARCHAR2
                    p_regione                 in varchar2
                    p_indirizzo_telematico    IN so4_indirizzi_telematici.INDIRIZZO%TYPE
                    p_data_riferimento        IN so4_aoo.DAL%TYPE
       RITORNA:     Restituisce i record trovati in UO.
       NOTE:
       REVISIONI:
       Rev. Data        Autore      Descrizione
       ---- ----------  ------      ------------------------------------------------------
       0    28/02/2006   SC          A14999. Per J-Protocollo.
            11/09/2020   SC          Bug #44596 Individuazione mittenti messaggi senza
                                     segnatura quando sono mail di uo da IPA
      ******************************************************************************/
      p_uo_rc                  afc.t_ref_cursor;
      ddatariferimento         DATE;
      ddataal                  DATE;
      dsiglaprovincia          ad4_province.sigla%TYPE;
      dcodiceprovincia         ad4_province.provincia%TYPE;
      dcodiceregione           ad4_regioni.regione%TYPE;
      dcodicecomune            ad4_comuni.comune%TYPE;
      dcap                     ad4_comuni.cap%TYPE;
      dtempcap                 ad4_comuni.cap%TYPE;
      ddenominazione           VARCHAR2 (32000);
      dindirizzo               VARCHAR2 (32000);
      dindirizzotelematico     VARCHAR2 (32000);
      dcodiceamministrazione   VARCHAR2 (32000);
      dcodiceuo                VARCHAR2 (32000) := p_codice_uo;
      dsql                     VARCHAR2 (32767);
      dwhere                   VARCHAR2 (32767) := 'where 1=1 ';
      ddatarifdal              VARCHAR2 (100);
      ddatarifal               VARCHAR2 (100);
   BEGIN
      ddenominazione := TRIM (UPPER (REPLACE (p_denominazione, '''', '''''')));
      dindirizzo := UPPER (TRIM (REPLACE (p_indirizzo, '''', '''''')));
      dindirizzotelematico := UPPER (p_indirizzo_telematico);
      dcodiceamministrazione := UPPER (p_codice_amministrazione);
      ddatariferimento := NVL (p_data_riferimento, TRUNC (SYSDATE));
      dcap := p_cap;
      dsiglaprovincia := UPPER (p_provincia);
      ddataal := TRUNC (SYSDATE);

      IF ddatariferimento > ddataal
      THEN
         ddataal := ddatariferimento;
      END IF;

      ddatarifdal :=
            ' to_date('''
         || TO_CHAR (ddatariferimento, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')';
      ddatarifal :=
            ' to_date('''
         || TO_CHAR (ddataal, 'dd/mm/yyyy')
         || ''', ''dd/mm/yyyy'')';
      dsql :=
         'select so4_auor.progr_unita_organizzativa, nvl(so4_auor.dal_pubb, so4_auor.dal) from so4_auor, ad4_province, ad4_regioni ';
      dwhere :=
            dwhere
         || 'and'
         || ddatarifdal
         || ' between nvl(so4_auor.dal_pubb, so4_auor.dal) and nvl(nvl(so4_auor.al_pubb, so4_auor.al), '
         || ddatarifal
         || ') '
         || ' and ad4_province.provincia (+) = so4_auor.provincia '
         || ' and ad4_regioni.regione (+) = ad4_province.regione ';

      dwhere :=
            dwhere
         || 'and ('''
         || dcodiceamministrazione
         || ''' is not null or '''
         || dcodiceuo
         || ''' is not null or '''
         || p_ni
         || ''' is not null or '''
         || dindirizzotelematico
         || ''' is not null or '''
         || ddenominazione
         || ''' is not null)';

      IF dcodiceuo IS NOT NULL
      THEN
         dwhere :=
               dwhere
            || 'and upper(so4_auor.codice_uo) = upper('''
            || dcodiceuo
            || ''') ';
      END IF;

      IF dcodiceamministrazione IS NOT NULL
      THEN
         dcodiceamministrazione := dcodiceamministrazione || '%';
         dwhere :=
               dwhere
            || 'and upper(so4_auor.amministrazione) like '''
            || dcodiceamministrazione
            || ''' ';
      END IF;

      IF dindirizzo IS NOT NULL
      THEN
         dindirizzo := dindirizzo || '%';
         dwhere :=
               dwhere
            || 'and upper(so4_auor.indirizzo) like '''
            || dindirizzo
            || ''' ';
      END IF;

      /*   if dSitoIstituzionale is not null then
            dSitoIstituzionale := dSitoIstituzionale||'%';
           dWhere := dWhere||'and upper(sogg.INDIRIZZO_WEB) like '''||dSitoIstituzionale||''' ';
         end if;*/
      IF ddenominazione IS NOT NULL
      THEN
         dwhere := dwhere || 'and so4_auor.descrizione ';

         IF SUBSTR (ddenominazione, 1, 1) = '='
         THEN
            ddenominazione := '= ''' || SUBSTR (ddenominazione, 2) || '''';
         ELSE
            ddenominazione := 'like ''' || ddenominazione || '%''';
         END IF;

         dwhere := dwhere || ddenominazione;
      END IF;

      --   if dIndirizzoTelematico is not null then
      --      dIndirizzoTelematico := dIndirizzoTelematico||'%';
      --      dWhere := dWhere||'and upper(INDIRIZZO_TELEMATICO.GET_INDIRIZZO'
      --                      ||'(INDIRIZZO_TELEMATICO.GET_CHIAVE(''AO'','''','
      --                      ||'so4_aoo.progr_aoo,'''', ''I''))) like '''||dIndirizzoTelematico||''' ';
      --   end if;
      IF dindirizzotelematico IS NOT NULL
      THEN
         dsql := dsql || ', so4_indirizzi_telematici inte ';
         dindirizzotelematico := dindirizzotelematico || '%';
         dwhere :=
               dwhere
            || 'and upper(inte.INDIRIZZO) LIKE upper('''
            || dindirizzotelematico
            || ''') and inte.TIPO_ENTITA = ''UO'' and inte.TIPO_INDIRIZZO = ''I'' and inte.id_unita_organizzativa = so4_auor.progr_unita_organizzativa ';
      END IF;

      IF p_citta IS NOT NULL
      THEN
         -- NON passa dCap a questa funzione per non sovrascrivere l'eventuale cap
         -- passato. Se anche fosse stato passato nullo, e' sbagliato sovrascriverlo
         -- in ricerca perche' passare null significa che vanno bene tutti.
         /*      dCodiceComune := ad4_comune.get_comune( p_denominazione => p_citta
                                                     , p_cap => dTempCap
                                                     , p_sigla_provincia => dSiglaProvincia
                                                     , p_provincia => dCodiceProvincia);*/
         dcodicecomune :=
            ad4_comune.get_comune (
               p_denominazione     => p_citta,
               p_sigla_provincia   => dsiglaprovincia,
               p_soppresso         => ad4_comune.is_soppresso (
                                        p_denominazione     => p_citta,
                                        p_sigla_provincia   => dsiglaprovincia));
      END IF;

      IF dsiglaprovincia IS NOT NULL
      THEN
         dsql := dsql || ', ad4_provincie prov ';
         dsql := dsql || dwhere;
         dsql := dsql || 'and so4_auor.PROVINCIA = prov.PROVINCIA ';
         dsql := dsql || 'and prov.SIGLA = ''' || dsiglaprovincia || ''' ';
      ELSE
         dsql := dsql || dwhere;
      END IF;

      IF p_regione IS NOT NULL
      THEN
         dcodiceregione :=
            ad4_regione.get_regione (p_denominazione => p_regione);
      END IF;

      IF dcodicecomune IS NOT NULL
      THEN
         dsql := dsql || 'and so4_auor.COMUNE = ''' || dcodicecomune || ''' ';
      END IF;

      IF dcodiceprovincia IS NOT NULL
      THEN
         dsql :=
               dsql
            || 'and so4_auor.PROVINCIA = '''
            || dcodiceprovincia
            || ''' ';
      END IF;

      IF dcodiceregione IS NOT NULL
      THEN
         dsql :=
            dsql || 'and ad4_regione.regione = ''' || dcodiceregione || ''' ';
      END IF;

      IF dcap IS NOT NULL
      THEN
         dsql := dsql || 'and so4_auor.cap = ''' || dcap || ''' ';
      END IF;

      IF NVL (p_ni, 0) > 0
      THEN
         dsql := dsql || ' and so4_auor.progr_unita_organizzativa = ' || p_ni;
      END IF;

      DBMS_OUTPUT.put_line (SUBSTR (dsql, 1, 255));
      DBMS_OUTPUT.put_line (SUBSTR (dsql, 256, 255));
      DBMS_OUTPUT.put_line (SUBSTR (dsql, 511, 255));

      OPEN p_uo_rc FOR dsql;

      RETURN p_uo_rc;
   END trova_uo;
BEGIN
   L_FAX_RES :=
      get_lunghezza_dato ('ANAGRAFE_SOGGETTI', 'FAX_RES', get_user_as4);
   L_CAP_RES :=
      get_lunghezza_dato ('ANAGRAFE_SOGGETTI', 'CAP_RES', get_user_as4);
   L_TEL_RES :=
      get_lunghezza_dato ('ANAGRAFE_SOGGETTI', 'TEL_RES', get_user_as4);
   L_INDIRIZZO_RES :=
      get_lunghezza_dato ('ANAGRAFE_SOGGETTI', 'INDIRIZZO_RES', get_user_as4);
   L_FAX := get_lunghezza_dato ('AOO', 'FAX', get_user_so4);
   L_CAP := get_lunghezza_dato ('AOO', 'CAP', get_user_so4);
   L_TELEFONO := get_lunghezza_dato ('AOO', 'TELEFONO', get_user_so4);
   L_DESCRIZIONE :=
      get_lunghezza_dato ('ANAGRAFE_UNITA_ORGANIZZATIVE',
                          'DESCRIZIONE',
                          get_user_so4);
END;
/
