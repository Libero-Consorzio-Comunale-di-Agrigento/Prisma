--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_FLUSSO_LETTERA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     "AG_UTILITIES_FLUSSO_LETTERA"
IS
/******************************************************************************
 NOME:        GDM.AG_UTILITIES_FLUSSO_LETTERA
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
           il flusso LETTERA_USCITA.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    17/05/2007  SC  Prima emissione.
******************************************************************************/-- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_protocollatore
 DESCRIZIONE: Restituisce Cognome e Nome dell'utente protocollante
 INPUT:         utente varchar2 codice dell'utente
 RITORNA:     varchar2 stringa Cognome e Nome dell'utente protocollante,
 NOTE:
 A33814.0.0 SC  29/07/2009 Creazione.
******************************************************************************/
   FUNCTION get_protocollatore (p_utente VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_estremi_protocollo
 DESCRIZIONE: Restituisce una stringa con gli estremi del protocollo
 INPUT:         p_anno VARCHAR2, p_numero VARCHAR2
 RITORNA:     varchar2 stringa con gli estremi del protocollo.
 NOTE:
 A33814.0.0 SC  29/07/2009 Creazione.
******************************************************************************/
   FUNCTION get_estremi_protocollo (p_anno VARCHAR2, p_numero VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_descrizione_stato
 DESCRIZIONE: Restituisce la descrizione dell'attività da compiere in base
                al valore di POSIZIONE_FLUSSO, MODIFICA_FIRMA, TIPO_LETTERA.
 INPUT:         p_posizione_flusso varchar2 valore di POSIZIONE_FLUSSO
                p_modifica_firma varchar2 valore di MODIFICA_FIRMA.
                p_tipo_lettera varchar2 valore di TIPO_LETTERA.
 RITORNA:     varchar2 stringa Descrizione dell'attività da compiere.
 NOTE:
 A33814.0.0 SC  29/07/2009 Creazione.
******************************************************************************/
   FUNCTION get_descrizione_stato (
      p_posizione_flusso   VARCHAR2,
      p_modifica_firma     VARCHAR2,
      p_tipo_lettera       VARCHAR2
   )
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_denominazione_primo_rapporto
 DESCRIZIONE: Restituisce il primo destinatario in ordine alfabetico.
                A secondo del tipo di soggetto è possibile che sia valorizzato
                il campo DENOMINAZIONE_PER_SEGNATURA,
                oppure OGNOME_PER_SEGNATURA e NOME_PER_SEGNATURA
                oppure DESCRIZIONE_AMM.
                Vengono selezionati o messi in ordine alfabetico,
                per poter individuare il primo.
 INPUT:         idrif varchar2 idrif del protocollo di cui vanno individuati i
                rapporti.
 RITORNA:     varchar2 stringa con DENOMINAZIONE_PER_SEGNATURA
                o concatenazione di COGNOME_PER_SEGNATURA e NOME_PER_SEGNATURA
                o DESCRIZIONE_AMM.
 NOTE:
 A33814.0.0 SC  29/07/2009 Creazione.
******************************************************************************/
   FUNCTION get_den_primo_rapporto (p_idrif VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_etichetta_lettera
 DESCRIZIONE: Restituisce LETTERA USC. se tipo lettera è USCITA,
                altrimenti restituisce LETTERA INT.
 INPUT:         idrif varchar2 idrif del protocollo di cui vanno individuati i
                rapporti.
 RITORNA:     varchar2 stringa LETTERA USC. se tipo lettera è USCITA,
 altrimenti restituisce LETTERA INT.
 NOTE:
 A33814.0.0 SC  29/07/2009 Creazione.
******************************************************************************/
   FUNCTION get_etichetta_lettera (p_idrif VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_label_attivita
 DESCRIZIONE: Restituisce LETTERA USC. se tipo lettera è USCITA,
                altrimenti restituisce LETTERA INT.
 INPUT:         idrif varchar2 idrif del protocollo di cui vanno individuati i
                rapporti.
 RITORNA:     varchar2 stringa LETTERA USC. se tipo lettera è USCITA,
 altrimenti restituisce LETTERA INT.
 NOTE:
 A33814.0.0 SC  29/07/2009 Creazione.
******************************************************************************/
   FUNCTION get_label_attivita (p_idrif VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_nome_utente
 DESCRIZIONE: Restituisce Nome dell'utente
 INPUT:         utente varchar2 codice dell'utente
 RITORNA:     varchar2 stringa Nome dell'utente,
 NOTE:
 A36823.0.0 SC  11/03/2010 Creazione.
******************************************************************************/
   FUNCTION get_nome_utente (p_utente VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************
 NOME:        get_cognome_utente
 DESCRIZIONE: Restituisce Cognome dell'utente
 INPUT:         utente varchar2 codice dell'utente
 RITORNA:     varchar2 stringa Cognome dell'utente,
 NOTE:
 A36823.0.0 SC  11/03/2010 Creazione.
******************************************************************************/
   FUNCTION get_cognome_utente (p_utente VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION crea_applet_testo (
      p_utente             VARCHAR2,
      p_area               VARCHAR2,
      p_cm                 VARCHAR2,
      p_cr                 VARCHAR2,
      p_allegato           VARCHAR2,
      p_modello            VARCHAR2,
      p_posizione_flusso   VARCHAR2,
      p_rep                VARCHAR2
   )
      RETURN VARCHAR2;
     FUNCTION get_funzionario (
      p_unita                 VARCHAR2,
      p_nome                  VARCHAR2,
      p_check_funzionario     VARCHAR2 DEFAULT 'Y'
   )
      RETURN VARCHAR2;
      FUNCTION get_responsabile_ruolo (
      p_progr_uo   so4_auor.progr_unita_organizzativa%TYPE,
      p_ruolo      ad4_ruoli.ruolo%TYPE,
      p_nome       VARCHAR2,
      p_ottica     VARCHAR2 DEFAULT NULL

   )
      RETURN VARCHAR2;
      FUNCTION unita_get_responsabile_ruolo (
      p_progr_uo   so4_auor.progr_unita_organizzativa%TYPE,
      p_ruolo      ad4_ruoli.ruolo%TYPE,
      p_nome       VARCHAR2,
      p_ottica     VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;
      FUNCTION get_ottica_default
      RETURN VARCHAR2;
      FUNCTION ad4_utente_get_ruoli (
      p_utente            ad4_utenti.utente%TYPE,
      p_codice_uo         so4_auor.codice_uo%TYPE
            DEFAULT NULL,
      p_data              DATE DEFAULT NULL,
      p_ottica            so4_auor.ottica%TYPE
            DEFAULT NULL,
      p_amministrazione   so4_auor.amministrazione%TYPE
            DEFAULT NULL
   )
      RETURN afc.t_ref_cursor;

      FUNCTION get_documenti_collegati (
      p_id_rif          VARCHAR2,
      p_lista_modelli   VARCHAR2,
      p_sep             VARCHAR2,
      p_doc_princ       NUMBER default 0
   )
      RETURN VARCHAR2;
      function attiva_flusso_lettera (
      p_area          VARCHAR2,
      p_cm   VARCHAR2,
      p_cr             VARCHAR2,
      p_utente VARCHAR2
   )
    RETURN VARCHAR2;
    function add_competenze_firma(
   d_id_doc NUMBER
   ) RETURN VARCHAR2;
END AG_UTILITIES_FLUSSO_LETTERA;
/
CREATE OR REPLACE PACKAGE BODY "AG_UTILITIES_FLUSSO_LETTERA"
IS
   /******************************************************************************
    NOME:        GDM.AG_UTILITIES_FLUSSO_LETTERA
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
              il flusso LETTERA_USCITA.
    ANNOTAZIONI: .
    REVISIONI:   .
    Rev. Data        Autore   Descrizione.
    000  29/07/2009  SC       Prima emissione.
    001  17/05/2012  MM       Modifiche versione 2.1.
    002  15/03/2017  MM       Modifiche versione 2.7.
         26/04/2017  SC       ALLINEATO ALLO STANDARD
   ******************************************************************************/
   s_revisione_body   VARCHAR2 (3) := '002';

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
   END;

   /******************************************************************************
    NOME:        get_den_primo_rapporto
    DESCRIZIONE: Restituisce il primo destinatario in ordine alfabetico.
                   A secondo del tipo di soggetto è possibile che sia valorizzato
                   il campo DENOMINAZIONE_PER_SEGNATURA,
                   oppure OGNOME_PER_SEGNATURA e NOME_PER_SEGNATURA
                   oppure DESCRIZIONE_AMM.
                   Vengono selezionati o messi in ordine alfabetico,
                   per poter individuare il primo.
    INPUT:         idrif varchar2 idrif del protocollo di cui vanno individuati i
                   rapporti.
    RITORNA:     varchar2 stringa con DENOMINAZIONE_PER_SEGNATURA
                   o concatenazione di COGNOME_PER_SEGNATURA e NOME_PER_SEGNATURA
                   o DESCRIZIONE_AMM.
    NOTE:
    A33814.0.0 SC  29/07/2009 Creazione.
   ******************************************************************************/
   FUNCTION get_den_primo_rapporto (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      retval     VARCHAR2 (32000);
      tot_dest   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO tot_dest
        FROM seg_soggetti_protocollo sopr, documenti docu
       WHERE     docu.id_documento = sopr.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE')
             AND sopr.idrif = p_idrif
             AND (   denominazione_per_segnatura IS NOT NULL
                  OR descrizione_amm IS NOT NULL
                  OR cognome_per_segnatura IS NOT NULL)
             AND conoscenza = 'N'
             AND tipo_rapporto = 'DEST';

      SELECT denominazione_per_segnatura
        INTO retval
        FROM (SELECT denominazione_per_segnatura
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE')
                     AND sopr.idrif = p_idrif
                     AND denominazione_per_segnatura IS NOT NULL
                     AND conoscenza = DECODE (tot_dest, 0, conoscenza, 'N')
                     AND tipo_rapporto = 'DEST'
              UNION
              SELECT cognome_per_segnatura || ' ' || nome_per_segnatura
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE')
                     AND sopr.idrif = p_idrif
                     AND cognome_per_segnatura IS NOT NULL
                     AND conoscenza = DECODE (tot_dest, 0, conoscenza, 'N')
                     AND tipo_rapporto = 'DEST'
              UNION
              SELECT descrizione_amm
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE')
                     AND sopr.idrif = p_idrif
                     AND descrizione_amm IS NOT NULL
                     AND conoscenza = DECODE (tot_dest, 0, conoscenza, 'N')
                     AND tipo_rapporto = 'DEST')
       WHERE ROWNUM = 1;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_den_primo_rapporto;

   /******************************************************************************
    NOME:        get_descrizione_stato
    DESCRIZIONE: Restituisce la descrizione dell'attività da compiere in base
                   al valore di POSIZIONE_FLUSSO, MODIFICA_FIRMA, TIPO_LETTERA.
    INPUT:         p_posizione_flusso varchar2 valore di POSIZIONE_FLUSSO
                   p_modifica_firma varchar2 valore di MODIFICA_FIRMA.
                   p_tipo_lettera varchar2 valore di TIPO_LETTERA.
    RITORNA:     varchar2 stringa Descrizione dell'attività da compiere.
    NOTE:
    A33814.0.0 SC  29/07/2009 Creazione.
   ******************************************************************************/
   FUNCTION get_descrizione_stato (p_posizione_flusso    VARCHAR2,
                                   p_modifica_firma      VARCHAR2,
                                   p_tipo_lettera        VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT DECODE (
                p_posizione_flusso,
                'DIRIGENTE', DECODE (
                                p_modifica_firma,
                                'Y', 'ATTENDERE la rigenerazione del testo',
                                'In attesa di firma'),
                'CONTROLLO_TESTO', 'Inserire testo',
                'REVISORE', 'Richiesta revisione',
                'REDATTORE', 'Richiesta revisione',
                'FUNZIONARIO', 'Richiesta visione',
                'DAINVIARE', DECODE (p_tipo_lettera,
                                     'USCITA', 'Da inviare',
                                     'Gestisci'),
                'DAFIRMAREDIGITALMENTE', 'Da firmare digitalmente')
        INTO retval
        FROM DUAL;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_descrizione_stato;

   /******************************************************************************
    NOME:        get_protocollatore
    DESCRIZIONE: Restituisce Cognome e Nome dell'utente protocollante
    INPUT:         utente varchar2 codice dell'utente
    RITORNA:     varchar2 stringa Cognome e Nome dell'utente protocollante,
    NOTE:
    A33814.0.0 SC  29/07/2009 Creazione.
   ******************************************************************************/
   FUNCTION get_protocollatore (p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT cognome || ' ' || nome
        INTO retval
        FROM as4_soggetti sogg, ad4_utenti_soggetti utso
       WHERE sogg.ni = utso.soggetto AND utso.utente = p_utente;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_protocollatore;

   /******************************************************************************
    NOME:        get_nome_utente
    DESCRIZIONE: Restituisce Nome dell'utente
    INPUT:         utente varchar2 codice dell'utente
    RITORNA:     varchar2 stringa Nome dell'utente,
    NOTE:
    A36823.0.0 SC  11/03/2010 Creazione.
   ******************************************************************************/
   FUNCTION get_nome_utente (p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT nome
        INTO retval
        FROM as4_soggetti sogg, ad4_utenti_soggetti utso
       WHERE sogg.ni = utso.soggetto AND utso.utente = p_utente;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_nome_utente;

   /******************************************************************************
    NOME:        get_cognome_utente
    DESCRIZIONE: Restituisce Cognome dell'utente
    INPUT:         utente varchar2 codice dell'utente
    RITORNA:     varchar2 stringa Cognome dell'utente,
    NOTE:
    A36823.0.0 SC  11/03/2010 Creazione.
   ******************************************************************************/
   FUNCTION get_cognome_utente (p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT cognome
        INTO retval
        FROM as4_soggetti sogg, ad4_utenti_soggetti utso
       WHERE sogg.ni = utso.soggetto AND utso.utente = p_utente;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_cognome_utente;

   /******************************************************************************
    NOME:        get_estremi_protocollo
    DESCRIZIONE: Restituisce una stringa con gli estremi del protocollo
    INPUT:         p_anno VARCHAR2, p_numero VARCHAR2
    RITORNA:     varchar2 stringa con gli estremi del protocollo.
    NOTE:
    A33814.0.0 SC  29/07/2009 Creazione.
   ******************************************************************************/
   FUNCTION get_estremi_protocollo (p_anno VARCHAR2, p_numero VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT 'Prot. n. ' || p_numero || '/' || p_anno
        INTO retval
        FROM DUAL;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_estremi_protocollo;

   /******************************************************************************
    NOME:        get_etichetta_lettera
    DESCRIZIONE: Restituisce LETTERA USC. se tipo lettera è USCITA,
                   altrimenti restituisce LETTERA INT.
    INPUT:         idrif varchar2 idrif del protocollo di cui vanno individuati i
                   rapporti.
    RITORNA:     varchar2 stringa LETTERA USC. se tipo lettera è USCITA,
    altrimenti restituisce LETTERA INT.
    NOTE:
    A33814.0.0 SC  29/07/2009 Creazione.
   ******************************************************************************/
   FUNCTION get_etichetta_lettera (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT DECODE (tipo_lettera, 'USCITA', 'LETTERA USC.', 'LETTERA INT.')
        INTO retval
        FROM proto_view prot, documenti docu
       WHERE     idrif = p_idrif
             AND prot.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE');

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_etichetta_lettera;

   /******************************************************************************
    NOME:        get_label_attivita
    DESCRIZIONE: Restituisce LETTERA USC. se tipo lettera è USCITA,
                   altrimenti restituisce LETTERA INT.
    INPUT:         idrif varchar2 idrif del protocollo di cui vanno individuati i
                   rapporti.
    RITORNA:     varchar2 stringa LETTERA USC. se tipo lettera è USCITA,
    altrimenti restituisce LETTERA INT.
    NOTE:
    A33814.0.0 SC  29/07/2009 Creazione.
   ******************************************************************************/
   FUNCTION get_label_attivita (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      retval                   VARCHAR2 (32000);
      dep_den_primo_rapporto   VARCHAR2 (20);
   BEGIN
      dep_den_primo_rapporto :=
         SUBSTR (get_den_primo_rapporto (p_idrif), 1, 20);

      SELECT    get_etichetta_lettera (p_idrif)
             || ' '
             || DECODE (
                   stato_pr,
                   'PR',    '('
                         || get_protocollatore (utente_protocollante)
                         || ') '
                         || get_estremi_protocollo (anno, numero)
                         || ' del '
                         || TO_CHAR (data, 'dd/mm/yyyy'),
                      '('
                   || get_protocollatore (utente_protocollante)
                   || ')'
                   || ' del '
                   || TO_CHAR (oggi, 'dd/mm/yyyy'))
             || ' - '
             || DECODE (
                   get_descrizione_stato (posizione_flusso,
                                          modifica_firma,
                                          tipo_lettera),
                   NULL, '',
                      get_descrizione_stato (posizione_flusso,
                                             modifica_firma,
                                             tipo_lettera)
                   || ' - ')
             || DECODE (dep_den_primo_rapporto,
                        NULL, '',
                        dep_den_primo_rapporto || ' - ')
             || oggetto
        INTO retval
        FROM proto_view
       WHERE idrif = p_idrif;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_label_attivita;

   FUNCTION crea_applet_testo (p_utente              VARCHAR2,
                               p_area                VARCHAR2,
                               p_cm                  VARCHAR2,
                               p_cr                  VARCHAR2,
                               p_allegato            VARCHAR2,
                               p_modello             VARCHAR2,
                               p_posizione_flusso    VARCHAR2,
                               p_rep                 VARCHAR2)
      RETURN VARCHAR2
   IS
      v_applet        VARCHAR2 (2000) := '';
      v_ext           VARCHAR2 (10) := '';
      v_tipo_unione   VARCHAR2 (20) := '';
      v_urlcontesto   VARCHAR2 (200) := '';
      v_url           VARCHAR2 (200) := '';
      v_server        VARCHAR2 (2000);
      v_nome_logico   VARCHAR2 (500);
   BEGIN
      BEGIN
         --SELECT DECODE (substr(LOWER(valore),1,1), '.', substr(LOWER(valore),2), LOWER(valore))
         SELECT DECODE (LOWER (valore),
                        '.odt', 'ODT',
                        '.doc', 'MS-Word',
                        '.rtf', 'RTF',
                        'ODT')
           INTO v_ext
           FROM parametri
          WHERE tipo_modello = '@agStrut@' AND codice = 'EXT_FILE_LETUSC';
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ext := 'ODT';
      END;

      v_nome_logico :=
         p_posizione_flusso || '_' || p_area || '_' || p_cm || '_' || p_cr;

      BEGIN
         SELECT DECODE (LOWER (valore), 'stampaunioneoo', 'UNIONOO', 'UNION')
           INTO v_tipo_unione
           FROM parametri
          WHERE tipo_modello = '@agStrut@' AND codice = 'TIPO_UNIONE_LETUSC';
      EXCEPTION
         WHEN OTHERS
         THEN
            v_tipo_unione := 'UNIONOO';
      END;

      BEGIN
         SELECT LOWER (valore)
           INTO v_url
           FROM parametri
          WHERE tipo_modello = '@agStrut@' AND codice = 'URL_CONTEXT_LETUSC';

         v_urlcontesto :=
            '<param NAME=''urlcontesto'' value=''' || v_url || '''></param>';
      EXCEPTION
         WHEN OTHERS
         THEN
            v_urlcontesto := '';
      END;

      BEGIN
         SELECT LOWER (valore)
           INTO v_server
           FROM parametri
          WHERE tipo_modello = '@agStrut@' AND codice = 'SERVER';

         IF SUBSTR (v_server, -1, 1) = '/' OR SUBSTR (v_server, -1, 1) = '\'
         THEN
            v_server := SUBSTR (v_server, 1, LENGTH (v_server) - 1);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;

      -- >

      --APPLET in 3.6
      --      v_applet :=
      --            '
      --        <applet code=''it/finmatica/jdms/extension/applet/webdav/JAppletLink.class'' archive=''finmatica-jappletlink.jar''  width=300 height=40 ALIGN=bottom>
      --        <param NAME=''t1'' value=''Componi''></param>
      --       <param NAME=''t2'' value=''Elimina''></param>';

      --APPLET in 4.0
      /*v_applet :=
            '
        <applet code=''it/finmatica/jdms/extension/applet/webdav/JAppletLink.class'' archive=''sfinmatica-jappletlink.jar'' codebase=''../../'
         || v_url
         || '/config''   width=300 height=40 ALIGN=bottom>
        <param NAME=''t1'' value=''Componi''></param>
        <param NAME=''t2'' value=''Elimina''></param>';*/

      v_applet :=
            '<applet id=''WDDApplet'' name=''WDDApplet''
               mayscript=''mayscript'' code=''it/finmatica/jdms/extension/applet/webdav/JAppletLink.class''
               archive=''/'
         || v_url
         || 'config/sfinmatica-jappletlink.jar''
               width=300 height=40 ALIGN=bottom>
        <param NAME=''t1'' value=''Componi''></param>
        <param NAME=''t2'' value=''Elimina''></param>';

      IF v_url IS NOT NULL
      THEN
         --APPLET in 3.6
         --        v_applet :=  v_applet ||
         --          '<param NAME=''unLockServletUrl'' value='''||v_server||'/'||v_url||'UnLockFile''></param>';

         -- APPLET in 4.0
         v_applet :=
               v_applet
            || '<param NAME=''unLockServletUrl'' value='''
            || v_server
            || '/'
            || v_url
            || 'UnLockFile40''></param>';
         v_applet :=
               v_applet
            || '  <param NAME=''nomelogico'' value='''
            || v_nome_logico
            || '''></param> ';
      END IF;

      --APPLET in 4.0
      v_applet :=
         v_applet || '<param NAME=''autodeploy'' value=''false''></param>';
      --          '<param NAME=''autodeploy'' value=''true''></param>';
      v_applet :=
            v_applet
         || '
        <param NAME=''debug'' value=''true''></param>
        <param NAME=''mustUpdateEditor'' value=''true''></param>
        '
         || v_urlcontesto
         || '
        <param NAME=''qry'' value=''idmodello='
         || p_modello
         || '&area='
         || p_area
         || '&cm='
         || p_cm
         || '&cr='
         || p_cr
         || '&allegato='
         || p_allegato
         || '&user='
         || p_utente
         || '&rep1='
         || p_rep
         || '&ext='
         || v_ext
         || '&oper='
         || v_tipo_unione
         || '''></param>
          </applet>';
      RETURN v_applet;
   END crea_applet_testo;

   /** FUNZIONARIO **/
   FUNCTION get_ottica_default
      RETURN VARCHAR2
   IS
      v_ottica    VARCHAR2 (4000);
      v_cod_amm   VARCHAR2 (4000);
   BEGIN
      v_cod_amm := ag_parametro.get_valore ('CODICE_AMM_1', '@agVar@');
      v_ottica := so4_ags_pkg.set_ottica_default (NULL, v_cod_amm);
      RETURN v_ottica;
   END get_ottica_default;

   FUNCTION ad4_utente_get_ruoli (
      p_utente             ad4_utenti.utente%TYPE,
      p_codice_uo          so4_auor.codice_uo%TYPE DEFAULT NULL,
      p_data               DATE DEFAULT NULL,
      p_ottica             so4_auor.ottica%TYPE DEFAULT NULL,
      p_amministrazione    so4_auor.amministrazione%TYPE DEFAULT NULL)
      RETURN afc.t_ref_cursor
   IS
      v_versione   ad4_istanze.versione%TYPE;
      v_cursor     afc.t_ref_cursor;
      v_funzione   VARCHAR2 (4000);
   BEGIN
      BEGIN
         SELECT versione
           INTO v_versione
           FROM ad4_istanze ad
          WHERE ad.istanza = 'SO4';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN so4_ags_pkg.ad4_utente_get_ruoli (p_utente, p_codice_uo);
      END;

      IF (INSTR (v_versione, 'V1.3') > 0)
      THEN
         v_funzione :=
            'BEGIN :nome := so4_ags_pkg.ad4_utente_get_ruoli (:utente, :codice); END;';

         EXECUTE IMMEDIATE v_funzione
            USING OUT v_cursor, IN p_utente, p_codice_uo;
      ELSE
         v_funzione :=
            'BEGIN :nome := so4_ags_pkg.ad4_utente_get_ruoli (:utente, :codice, :data, :ottica, :amministrazione); END;';

         EXECUTE IMMEDIATE v_funzione
            USING OUT v_cursor,
                  IN p_utente,
                  p_codice_uo,
                  p_data,
                  NVL (p_ottica, get_ottica_default),
                  p_amministrazione;
      END IF;

      RETURN v_cursor;
   END ad4_utente_get_ruoli;

   FUNCTION unita_get_responsabile_ruolo (
      p_progr_uo    so4_auor.progr_unita_organizzativa%TYPE,
      p_ruolo       ad4_ruoli.ruolo%TYPE,
      p_nome        VARCHAR2,
      p_ottica      VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      v_componenti     afc.t_ref_cursor;
      v_utente         ad4_utenti.utente%TYPE;
      v_ni             ad4_soggetti.soggetto%TYPE;
      v_cognomeenome   VARCHAR2 (200);
      v_ruolo_resp     ad4_ruoli.ruolo%TYPE := 'AGPRESP';
      v_codice_uo      so4_auor.codice_uo%TYPE;
      v_ruolo          ad4_ruoli.ruolo%TYPE;
      v_descrizione    ad4_ruoli.descrizione%TYPE;
      v_ruoli          afc.t_ref_cursor;
      v_responsabile   VARCHAR (200) := NULL;
   BEGIN
      v_codice_uo := so4_auor_pkg.get_codice_uo (p_progr_uo, SYSDATE);
      v_componenti :=
         so4_ags_pkg.unita_get_componenti_ord (
            v_codice_uo,
            p_ruolo,
            NVL (p_ottica, get_ottica_default));

      LOOP
         FETCH v_componenti INTO v_ni, v_cognomeenome, v_utente;

         EXIT WHEN v_componenti%NOTFOUND OR v_responsabile IS NOT NULL;
         v_ruoli :=
            ad4_utente_get_ruoli (v_utente,
                                  v_codice_uo,
                                  NULL,
                                  NVL (p_ottica, get_ottica_default));

         LOOP
            FETCH v_ruoli INTO v_ruolo, v_descrizione;

            EXIT WHEN v_ruoli%NOTFOUND;

            IF UPPER (v_ruolo) = UPPER (v_ruolo_resp)
            THEN
               IF (p_nome = 'Y')
               THEN
                  v_responsabile := v_cognomeenome;
               ELSE
                  v_responsabile := v_utente;
                  EXIT;
               END IF;
            END IF;
         END LOOP;

         CLOSE v_ruoli;
      END LOOP;

      CLOSE v_componenti;

      DBMS_OUTPUT.put_line ('responsabile ' || v_responsabile);
      --      IF (v_responsabile IS NULL)
      --      THEN
      --         v_responsabile :=
      --                          'NESSUN RESPONSABILE TROVATO CON RUOLO ' || p_ruolo;
      --      END IF;
      RETURN v_responsabile;
   END unita_get_responsabile_ruolo;

   FUNCTION get_responsabile_ruolo (
      p_progr_uo    so4_auor.progr_unita_organizzativa%TYPE,
      p_ruolo       ad4_ruoli.ruolo%TYPE,
      p_nome        VARCHAR2,
      p_ottica      VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      v_progr_uo_padre   VARCHAR2 (1000);
      v_responsabile     VARCHAR2 (200);
   BEGIN
      DBMS_OUTPUT.put_line ('unita ' || p_progr_uo || ' ruolo ' || p_ruolo);
      v_responsabile :=
         unita_get_responsabile_ruolo (p_progr_uo,
                                       p_ruolo,
                                       p_nome,
                                       NVL (p_ottica, get_ottica_default));

      IF (v_responsabile IS NULL)
      THEN
         v_progr_uo_padre :=
            so4_ags_pkg.unita_get_unita_padre (
               p_progr_uo,
               NVL (p_ottica, get_ottica_default));
         v_progr_uo_padre := afc.get_substr (v_progr_uo_padre, '#');
         v_responsabile :=
            get_responsabile_ruolo (v_progr_uo_padre,
                                    p_ruolo,
                                    p_nome,
                                    NVL (p_ottica, get_ottica_default));
      END IF;

      RETURN v_responsabile;
   END get_responsabile_ruolo;

   FUNCTION get_funzionario (p_unita                VARCHAR2,
                             p_nome                 VARCHAR2,
                             p_check_funzionario    VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
      v_funzionario           VARCHAR2 (200) := '';
      v_funzione              VARCHAR2 (2000)
         := 'ag_utilities_flusso_lettera.get_responsabile_ruolo (:a, :b, :c)';
      v_progr_uo_proponente   so4_auor.progr_unita_organizzativa%TYPE;
   BEGIN
      BEGIN
         SELECT progr_unita_organizzativa
           INTO v_progr_uo_proponente
           FROM seg_unita
          WHERE unita = p_unita;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF (p_check_funzionario = 'N')
      THEN
         RETURN v_funzionario;
      END IF;

      v_funzione := 'BEGIN :nome := ' || v_funzione || '; END;';

      EXECUTE IMMEDIATE v_funzione
         USING OUT v_funzionario,
               IN v_progr_uo_proponente,
               'AGPFUNZ',
               p_nome;

      RETURN v_funzionario;
   END get_funzionario;



   FUNCTION get_documenti_collegati (p_id_rif           VARCHAR2,
                                     p_lista_modelli    VARCHAR2,
                                     p_sep              VARCHAR2,
                                     p_doc_princ        NUMBER)
      RETURN VARCHAR2
   IS
      v_id_docs         VARCHAR2 (4000);
      v_ord             NUMBER;
      v_pos             NUMBER;
      v_modello         VARCHAR2 (50);
      v_nome_tabella    VARCHAR2 (30);
      v_ref_iddoc       afc.t_ref_cursor;
      v_id_doc          documenti.id_documento%TYPE;
      v_lista_modelli   VARCHAR2 (4000) := '';
      v_area            VARCHAR2 (30) := 'SEGRETERIA.PROTOCOLLO';
   BEGIN
      v_lista_modelli := p_lista_modelli;

      LOOP
         -- ciclo per lo split sui modelli
         v_pos := INSTR (v_lista_modelli, p_sep);

         IF (NVL (v_pos, 0) = 0)
         THEN
            v_modello := v_lista_modelli;
         ELSE
            v_modello :=
               LTRIM (RTRIM (SUBSTR (v_lista_modelli, 1, v_pos - 1)));
            v_lista_modelli := SUBSTR (v_lista_modelli, v_pos + 1);
         END IF;

         IF (v_modello = 'M_ALLEGATO_PROTOCOLLO')
         THEN
            v_area := 'SEGRETERIA';
         ELSE
            v_area := 'SEGRETERIA.PROTOCOLLO';
         END IF;

         -- recupero il nome della tabella
         SELECT aree.acronimo || '_' || alias_modello
           INTO v_nome_tabella
           FROM aree, tipi_documento
          WHERE     aree.area = tipi_documento.area_modello
                AND aree.area = v_area
                AND tipi_documento.nome = v_modello;


         OPEN v_ref_iddoc FOR
               'select id_documento, 1 ord
                                    from proto_view
                                   where idrif = '''
            || p_id_rif
            || ''' and '
            || p_doc_princ
            || ' = 1 union
                                 SELECT modello.id_documento, modello.id_documento
                               FROM '
            || v_nome_tabella
            || ' modello, documenti doc
                               WHERE doc.id_documento = modello.id_documento
                               AND doc.stato_documento = ''BO''
                               AND modello.idrif = '''
            || p_id_rif
            || ''' order by 2';

         LOOP
            FETCH v_ref_iddoc INTO v_id_doc, v_ord;

            EXIT WHEN v_ref_iddoc%NOTFOUND;
            DBMS_OUTPUT.put_line ('id documento ' || v_id_doc);
            v_id_docs := v_id_docs || p_sep || v_id_doc;
         END LOOP;

         -- cursore sugli id_documento
         CLOSE v_ref_iddoc;

         EXIT WHEN (NVL (v_pos, 0) = 0);
      END LOOP;

      -- end ciclo sui modelli
      RETURN TRIM (LEADING p_sep FROM v_id_docs);
   END get_documenti_collegati;

   FUNCTION attiva_flusso_lettera (p_area      VARCHAR2,
                                   p_cm        VARCHAR2,
                                   p_cr        VARCHAR2,
                                   p_utente    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_num        NUMBER;
      d_nomeiter   VARCHAR2 (100) := '';
      d_id_doc     NUMBER;
      d_idrif      VARCHAR2 (15);
      d_modalita   VARCHAR2 (10);
      d_check      NUMBER := 1;
      d_num_rapp   NUMBER := 0;
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

      SELECT id_documento
        INTO d_id_doc
        FROM documenti
       WHERE codice_richiesta = p_cr AND stato_documento NOT IN ('CA', 'RE');

      SELECT idrif, modalita
        INTO d_idrif, d_modalita
        FROM spr_lettere_uscita
       WHERE id_documento = d_id_doc;

      IF (d_modalita = 'PAR')
      THEN
         SELECT COUNT (1)
           INTO d_num_rapp
           FROM seg_soggetti_protocollo sopr, documenti docu
          WHERE     sopr.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE')
                AND sopr.idrif = d_idrif;

         IF (d_num_rapp = 0)
         THEN
            d_check := 0;
         END IF;
      END IF;

      IF (d_check = 1)
      THEN
         d_nomeiter :=
            ag_parametro.get_valore ('NOME_ITER_LETTERA',
                                     '@agStrut@',
                                     'LETTERA_USCITA');

         d_num :=
            jwf_utility.istanzia_iter (
               NULL,
               d_nomeiter,
               '#@#area=' || p_area || '#@#cm=' || p_cm || '#@#cr=' || p_cr,
               NULL,
               p_utente,
               1);
      ELSE
         retval :=
               '<FUNCTION_OUTPUT>'
            || '<RESULT>nonok</RESULT>'
            || '<ERROR>Attenzione: '
            || 'specificare almeno un destinatario per le lettere in partenza'
            || '</ERROR>'
            || '</FUNCTION_OUTPUT>';
      END IF;

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
   END attiva_flusso_lettera;


   /*  01 07/04/2017 SC  Gestione date privilegi*/
   FUNCTION add_competenze_firma (d_id_doc NUMBER)
      RETURN VARCHAR2
   IS
      d_count     NUMBER := 0;
      d_ognitot   NUMBER := 10;
      retval      VARCHAR2 (1000) := 'OK';
   BEGIN
      DBMS_OUTPUT.put_line ('inizio');

      FOR cur0
         IN (SELECT DISTINCT utente
               FROM ag_priv_utente_tmp
              WHERE     privilegio = 'ANNPROT'
                    AND TRUNC (SYSDATE) <= NVL (al, TO_DATE (3333333, 'j'))/*AND (al IS NULL
                                                                                OR TO_DATE (al, 'dd/mm/yyyy') >
                                                                                      TO_DATE (TO_CHAR (SYSDATE, 'dd/mm/yyyy'), 'dd/mm/yyyy') )*/
                                                                           )
      LOOP
         d_count := d_count + 1;

         BEGIN
            retval :=
               si4_competenza.assegna ('DOCUMENTI',
                                       d_id_doc,
                                       'LA',
                                       cur0.UTENTE,
                                       'GDM',
                                       'GDM',
                                       'S',
                                       SYSDATE,
                                       NULL);
            retval :=
               si4_competenza.assegna ('DOCUMENTI',
                                       d_id_doc,
                                       'UA',
                                       cur0.UTENTE,
                                       'GDM',
                                       'GDM',
                                       'S',
                                       SYSDATE,
                                       NULL);
            retval :=
               si4_competenza.assegna ('DOCUMENTI',
                                       d_id_doc,
                                       'L',
                                       cur0.UTENTE,
                                       'GDM',
                                       'GDM',
                                       'S',
                                       SYSDATE,
                                       NULL);
            retval :=
               si4_competenza.assegna ('DOCUMENTI',
                                       d_id_doc,
                                       'U',
                                       cur0.UTENTE,
                                       'GDM',
                                       'GDM',
                                       'S',
                                       SYSDATE,
                                       NULL);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval :=
                     'ID_DOC='
                  || d_id_doc
                  || ' DIRIGENTE='
                  || cur0.UTENTE
                  || 'ERRORE='
                  || SQLCODE
                  || ' -ERROR- '
                  || SQLERRM;
               DBMS_OUTPUT.put_line (retval);
         END;

         IF (MOD (d_count, d_ognitot) = 0)
         THEN
            DBMS_OUTPUT.put_line ('ogni ' || TO_CHAR (d_ognitot));
            COMMIT;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line ('fine');
      COMMIT;
      RETURN retval;
   END add_competenze_firma;
END AG_UTILITIES_FLUSSO_LETTERA;
/
