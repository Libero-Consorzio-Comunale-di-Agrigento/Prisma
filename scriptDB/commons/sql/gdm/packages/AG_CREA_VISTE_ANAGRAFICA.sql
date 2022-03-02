--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_CREA_VISTE_ANAGRAFICA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_crea_viste_anagrafica
IS
   /*******************************************************************************
   NOME:        ag_crea_viste_anagrafica
   DESCRIZIONE: Package per creazione viste anagrafica.
   ECCEZIONI:.
   REVISIONI:
   Rev. Data       Autore        Descrizione
   ---- ---------- ------------- --------------------------------------------------
   00   05/08/2010 MMalferrari   Creazione.
   01   15/06/2011 MMAlferrari   Crea senza parametri.
   02   12/12/2011 MMAlferrari   A46983.0.0: Integrazione con anagrafe
                                 clienti/fornitori ce4.
   03   29/10/2012 MMAlferrari   Integrazione con anagrafe GSD.
   04   18/08/2014 MMalferrari   Integrazione con anagrafe ade e dei dipendenti
   *******************************************************************************/
   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE crea;

   PROCEDURE crea (p_cf4       IN NUMBER,
                   p_ce4       IN NUMBER,
                   p_dris      IN NUMBER,
                   p_gsd_tr4   IN NUMBER,
                   p_dip       IN NUMBER,
                   p_ade       IN NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY ag_crea_viste_anagrafica
IS
   FUNCTION versione
      /******************************************************************************
       NOME:        VERSIONE
       DESCRIZIONE: Restituisce la versione e la data di distribuzione del package.
       PARAMETRI:   --
       RITORNA:     stringa varchar2 contenente versione e data.
       ECCEZIONI:   --
       NOTE:        Il secondo numero della versione corrisponde alla revisione
                    del package.
       REVISIONI:
       Rev. Data       Autore       Descrizione
       ---- ---------- ------       -------------------------------------------------
       000  05/08/2010 MMalferrari  Creazione.
       001  01/02/2011 MMalferrari  Gestione UO.
       002  15/06/2011 MMAlferrari  Crea senza parametri.
       003  09/12/2011 MMAlferrari  Gestione campo INDIRIZZO_PEC per anagrafica DRIS.
       004  12/12/2011 MMAlferrari  A46983.0.0: Integrazione con anagrafe
                                    clienti/fornitori ce4.
       005  06/04/2012 MMalferrari  Aggiunta creazione vista SEG_AMM_AOO_UO
       006  09/07/2012 MMalferrari  Gestione campo MAIL_BENEFICIARIO
       007  21/02/2012 MMalferrari  Gestione campI FAX
       008  29/10/2012 MMAlferrari  Integrazione con anagrafe GSD.
       009  03/10/2013 MMalferrari  Creazione indici SEG_AAUO_EMAIL_IK
                                    SEG_AAUO_MAILFAX_IK SEG_AAUO_AMM_AOO_IK
       010  18/08/2014 MMalferrari  Integrazione con anagrafe ade e dei dipendenti
       011  10/12/2014 MMalferrari  Gestione anag_stoplist invece di italian_stoplist.
       012  14/08/2015 MMalferrari  Beneficiari: gestione controllo esistenza cf/pi su
                                    parametro e controllo validita'.
       013  23/02/2017 SCaputo      Gestione codici amm aoo e uo originali.
       014  07/03/2017 MMalferrari  Gestione ragione sociale estesa per i beneficiari
       015  12/09/2017 SCaputo      Gestione nuova AS4
       016  05/08/2019 GMannella    Gestione cf estero
       017  05/08/2019 SCaputo      #29171 Far vedere delle amministrazioni che
                                    NON hanno AOO, tutti i recapiti e
                                    il contatto con tipo_spedizione = MAIL.
                                    Far vedere delle amministrazioni che HANNO AOO,
                                    tutti i recapiti diversi dalla residenza,
                                    con i contatti con tipo_spedizione = MAIL.
                                    Se l'amministrazione ha un contatto
                                    con tipo_spedizione = MAIL associato alla
                                    residenza, farlo vedere.
       018  07/01/2020 SCaputo      Modificata creazione vista seg_anagrafici_as4
       019  07/01/2020 SCaputo      Gestione seg_anagrafici_as4 per sogg. amministrativi
       020  05/02/2020 SCaputo      Gestione seg_anagrafici_as4 per sogg. amministrativi
       021  19/08/2020 MMalferrari  Modificati al is null con >= trunc(sysdate).
      ******************************************************************************/
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'V1.04.021';
   END versione;

   PROCEDURE crea
   IS
      d_cf4    NUMBER;
      d_ce4    NUMBER;
      d_dris   NUMBER;
      d_gsd    NUMBER;
      d_dip    NUMBER;
      d_ade    NUMBER;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_cf4
           FROM ag_tipi_soggetto
          WHERE tipo_soggetto = 7                             -- 'Beneficiari'
                                 ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_cf4 := 0;
      END;

      BEGIN
         SELECT 1
           INTO d_ce4
           FROM ag_tipi_soggetto
          WHERE tipo_soggetto = 8                     -- 'Clienti e Fornitori'
                                 ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_ce4 := 0;
      END;

      BEGIN
         SELECT 1
           INTO d_dris
           FROM ag_tipi_soggetto
          WHERE tipo_soggetto = 3                    -- 'Imprese in provincia'
                                 ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_dris := 0;
      END;

      BEGIN
         SELECT 1
           INTO d_gsd
           FROM ag_tipi_soggetto
          WHERE tipo_soggetto = 9                                -- 'Anagrafe'
                                 ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_gsd := 0;
      END;

      BEGIN
         SELECT 1
           INTO d_dip
           FROM ag_tipi_soggetto
          WHERE tipo_soggetto = 5                      -- 'Dipendenti/Interni'
                                 ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_dip := 0;
      END;

      BEGIN
         SELECT 1
           INTO d_ade
           FROM ag_tipi_soggetto
          WHERE tipo_soggetto = 10                                  -- 'AP@CI'
                                  ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_ade := 0;
      END;

      crea (d_cf4,
            d_ce4,
            d_dris,
            d_gsd,
            d_dip,
            d_ade);
   END;

   PROCEDURE crea (p_cf4       IN NUMBER,
                   p_ce4       IN NUMBER,
                   p_dris      IN NUMBER,
                   p_gsd_tr4   IN NUMBER,
                   p_dip       IN NUMBER,
                   p_ade       IN NUMBER)
   IS
      d_statement   VARCHAR2 (32767);
   BEGIN
      d_statement :=
            'CREATE OR REPLACE FORCE VIEW SEG_SOGGETTI ('
         || 'ni, ni_gsd, denominazione,'
         || 'email,'
         || 'fax,'
         || 'partita_iva,'
         || 'cf,'
         || 'pi,'
         || 'indirizzo,'
         || 'denominazione_per_segnatura,'
         || 'cognome_per_segnatura,'
         || 'nome_per_segnatura,'
         || 'indirizzo_per_segnatura,'
         || 'comune_per_segnatura,'
         || 'cap_per_segnatura,'
         || 'provincia_per_segnatura,'
         || 'cf_per_segnatura,'
         || 'dal,'
         || 'al,'
         || 'ammin,'
         || 'descrizione_amm,'
         || 'aoo,'
         || 'descrizione_aoo,'
         || 'descrizione_uo,'
         || 'cod_amm,'
         || 'cod_amm_originale,'
         || 'cod_aoo,'
         || 'cod_aoo_originale,'
         || 'cod_uo,'
         || 'cod_uo_originale,'
         || 'dati_amm,'
         || 'dati_aoo,'
         || 'dati_uo,'
         || 'ni_amm,'
         || 'dal_amm,'
         || 'tipo,'
         || 'indirizzo_amm,'
         || 'cap_amm,'
         || 'comune_amm,'
         || 'sigla_prov_amm,'
         || 'mail_amm, fax_amm,'
         || 'indirizzo_aoo,'
         || 'cap_aoo,'
         || 'comune_aoo,'
         || 'sigla_prov_aoo,'
         || 'mail_aoo, fax_aoo,'
         || 'indirizzo_uo,'
         || 'cap_uo,'
         || 'comune_uo,'
         || 'sigla_prov_uo,'
         || 'mail_uo,'
         || 'tel_uo,'
         || 'fax_uo,'
         || 'cf_beneficiario,'
         || 'denominazione_beneficiario,'
         || 'pi_beneficiario,'
         || 'comune_beneficiario,'
         || 'indirizzo_beneficiario,'
         || 'cap_beneficiario,'
         || 'data_nascita_beneficiario,'
         || 'provincia_beneficiario,'
         || 'vis_indirizzo,'
         || 'mail_beneficiario,'
         || 'fax_beneficiario,'
         || 'ni_impresa,'
         || 'impresa,'
         || 'denominazione_sede,'
         || 'natura_giuridica,'
         || 'insegna,'
         || 'c_fiscale_impresa,'
         || 'partita_iva_impresa,'
         || 'tipo_localizzazione,'
         || 'comune,'
         || 'c_via_impresa,'
         || 'via_impresa,'
         || 'n_civico_impresa,'
         || 'comune_impresa,'
         || 'cap_impresa,'
         || 'mail_impresa,'
         || 'cf_estero,'
         || 'cognome,'
         || 'nome,'
         || 'indirizzo_res,'
         || 'comune_res,'
         || 'cap_res,'
         || 'provincia_res,'
         || 'tel_res,'
         || 'fax_res,'
         || 'indirizzo_dom,'
         || 'comune_dom,'
         || 'cap_dom,'
         || 'provincia_dom,'
         || 'tel_dom,'
         || 'fax_dom,'
         || 'comune_nascita,'
         || 'data_nascita,'
         || 'sesso,'
         || 'ni_dipendente, dal_dipendente, cognome_dipendente, nome_dipendente, codice_fiscale_dipendente,'
         || 'indirizzo_res_dipendente, comune_res_dipendente, provincia_res_dipendente, cap_res_dipendente,'
         || 'indirizzo_dom_dipendente, comune_dom_dipendente, provincia_dom_dipendente, cap_dom_dipendente,'
         || 'mail_dipendente,'
         || 'id_tipo_recapito,'
         || 'descrizione_tipo_recapito,'
         || 'id_recapito,'
         || 'id_contatto,'
         || 'tipo_spedizione,'
         || 'anagrafica,'
         || 'tipo_soggetto'
         || ') '
         || 'AS '
         || 'SELECT CAST (NULL AS NUMBER) ni,'
         || 'CAST (NULL AS NUMBER) ni_gsd, '
         || 'CAST (NULL AS VARCHAR2 (1)) denominazione,'
         || 'CAST (NULL AS VARCHAR2 (1)) email,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax,'
         || 'CAST (NULL AS VARCHAR2 (1)) partita_iva,'
         || 'CAST (NULL AS VARCHAR2 (1)) cf, CAST (NULL AS VARCHAR2 (1)) pi,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo,'
         || 'CAST (NULL AS VARCHAR2 (1)) denominazione_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) cognome_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) nome_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) provincia_per_segnatura,'
         || 'CAST (NULL AS VARCHAR2 (1)) cf_per_segnatura, '
         || 'CAST (NULL AS DATE) dal, '
         || 'CAST (NULL AS DATE) al, '
         || 'CAST (NULL AS VARCHAR2 (1)) ammin, '
         || 'CAST (NULL AS VARCHAR2 (1)) descrizione_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) descrizione_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) descrizione_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) cod_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) cod_amm_originale,'
         || 'CAST (NULL AS VARCHAR2 (1)) cod_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) cod_aoo_originale,'
         || 'CAST (NULL AS VARCHAR2 (1)) cod_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) cod_uo_originale,'
         || 'CAST (NULL AS VARCHAR2 (1)) dati_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) dati_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) dati_uo,'
         || 'CAST (NULL AS NUMBER) ni_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) dal_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) tipo,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) sigla_prov_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) mail_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax_amm,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) sigla_prov_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) mail_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax_aoo,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) sigla_prov_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) mail_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) tel_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax_uo,'
         || 'CAST (NULL AS VARCHAR2 (1)) cf_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) denominazione_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) pi_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) data_nascita_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) provincia_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) vis_indirizzo,'
         || 'CAST (NULL AS VARCHAR2 (1)) mail_beneficiario,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax_beneficiario,'
         || 'CAST (NULL AS NUMBER) ni_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) denominazione_sede,'
         || 'CAST (NULL AS VARCHAR2 (1)) natura_giuridica,'
         || 'CAST (NULL AS VARCHAR2 (1)) insegna,'
         || 'CAST (NULL AS VARCHAR2 (1)) c_fiscale_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) partita_iva_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) tipo_localizzazione,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune,'
         || 'CAST (NULL AS VARCHAR2 (1)) c_via_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) via_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) n_civico_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_impresa,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_impresa, '
         || 'CAST (NULL AS VARCHAR2 (1)) mail_impresa,'
         || 'CAST (NULL AS VARCHAR2 (40)) cf_estero,'
         || 'CAST (NULL AS VARCHAR2 (1)) cognome,'
         || 'CAST (NULL AS VARCHAR2 (1)) nome,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_res,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_res,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_res,'
         || 'CAST (NULL AS VARCHAR2 (1)) provincia_res,'
         || 'CAST (NULL AS VARCHAR2 (1)) tel_res,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax_res,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_dom,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_dom,'
         || 'CAST (NULL AS VARCHAR2 (1)) cap_dom,'
         || 'CAST (NULL AS VARCHAR2 (1)) provincia_dom,'
         || 'CAST (NULL AS VARCHAR2 (1)) tel_dom,'
         || 'CAST (NULL AS VARCHAR2 (1)) fax_dom,'
         || 'CAST (NULL AS VARCHAR2 (1)) comune_nascita,'
         || 'CAST (NULL AS VARCHAR2 (1)) data_nascita,'
         || 'CAST (NULL AS VARCHAR2 (1)) sesso,'
         || 'CAST (NULL AS NUMBER) ni_dipendente, CAST (NULL AS VARCHAR2 (1)) dal_dipendente, CAST (NULL AS VARCHAR2 (1)) cognome_dipendente, CAST (NULL AS VARCHAR2 (1)) nome_dipendente,'
         || 'CAST (NULL AS VARCHAR2 (1)) codice_fiscale_dipendente,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_res_dipendente, CAST (NULL AS VARCHAR2 (1)) comune_res_dipendente, CAST (NULL AS VARCHAR2 (1)) provincia_res_dipendente, CAST (NULL AS VARCHAR2 (1)) cap_res_dipendente,'
         || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_dom_dipendente, CAST (NULL AS VARCHAR2 (1)) comune_dom_dipendente, CAST (NULL AS VARCHAR2 (1)) provincia_dom_dipendente, CAST (NULL AS VARCHAR2 (1)) cap_dom_dipendente,'
         || 'CAST (NULL AS VARCHAR2 (1)) mail_dipendente,'
         || 'CAST (NULL AS NUMBER (1)) id_tipo_recapito,'
         || 'CAST (NULL AS VARCHAR2 (1)) descrizione_tipo_recapito,'
         || 'CAST (NULL AS NUMBER ) id_recapito,'
         || 'CAST (NULL AS NUMBER ) id_contatto,'
         || 'CAST (NULL AS VARCHAR2 (1)) tipo_spedizione,'
         || '''A'' anagrafica, 1 '
         || ' FROM dual '
         || 'WHERE 1 <> 1';

      IF p_cf4 = 1
      THEN
         DECLARE
            d_dep               VARCHAR2 (100);
            d_des_comune        VARCHAR2 (1000);
            d_sigla_provincia   VARCHAR2 (1000);
         BEGIN
            BEGIN
               SELECT OBJECT_TYPE
                 INTO d_dep
                 FROM OBJ
                WHERE OBJECT_NAME = 'CF4_BEN';

               IF d_dep = 'SYNONYM'
               THEN
                  BEGIN
                     SELECT 'SYNONYM'
                       INTO d_dep
                       FROM user_synonyms
                      WHERE     synonym_name = 'CF4_BEN'
                            AND table_name = 'BEN';
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        d_dep := 'NOCF4';
                  END;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_dep := 'SYNONYM';
            END;

            if d_dep = 'SYNONYM' then
               d_des_comune := ' ad4_comune.get_denominazione( ben.provincia, ben.comune) ';
               d_sigla_provincia := ' ad4_provincia.get_sigla(ben.provincia) ';
            else
               d_des_comune := ' ben.comune ';
               d_sigla_provincia := 'ben.provincia';
            end if;

            d_statement :=
                  d_statement
               || ' UNION ALL '
               || 'SELECT null ni, CAST (NULL AS NUMBER) ni_gsd, TRIM (ben.ragione_sociale_estesa) denominazione, e_mail email, telex fax,'
               || 'TRIM (ben.partita_iva) partita_iva, TRIM (ben.codice_fiscale) cf,'
               || 'TRIM (ben.partita_iva) pi,'
               || 'DECODE (ben.indirizzo,'
               || '  NULL, null,'
               || '  ben.indirizzo || '' '''
               || ' )'
               || '|| DECODE (ben.cap, NULL, null, LPAD (TRIM (ben.cap), 5, ''0'') || '' '')'
               || '|| DECODE ('|| d_des_comune ||','
               || '  NULL, null,'
               || ' '|| d_des_comune ||'|| '' '''

               || ' )'
               || '|| DECODE ('|| d_sigla_provincia ||','
               || ' NULL, null,'
               || ' ''('' || '|| d_sigla_provincia ||' || '')'''
               || ') indirizzo,'
               || 'null denominazione_per_segnatura,'
               || 'TRIM (ben.ragione_sociale_estesa) cognome_per_segnatura,'
               || 'null nome_per_segnatura, TRIM (ben.indirizzo) indirizzo_per_segnatura,'
               || d_des_comune ||' comune_per_segnatura,'
               || 'LPAD (TRIM (ben.cap), 5, ''0'') cap_per_segnatura,'
               || d_sigla_provincia ||' provincia_per_segnatura,'
               || 'TRIM (ben.codice_fiscale) cf_per_segnatura, TO_DATE (NULL) dal,'
               || 'TO_DATE (NULL) al, null ammin, null descrizione_amm, null aoo,'
               || 'null descrizione_aoo, null descrizione_uo, '
               || 'null cod_amm, '
               || 'null cod_amm_originale, '
               || 'null cod_aoo, '
               || 'null cod_aoo_originale, '
               || 'null cod_uo, '
               || 'null cod_uo_originale, '
               || 'null dati_amm, null dati_aoo, null dati_uo, '
               || 'TO_NUMBER (null) ni_amm, null dal_amm, null tipo,'
               || 'null indirizzo_amm, null cap_amm, null comune_amm, null sigla_prov_amm, null mail_amm, null fax_amm, '
               || 'null indirizzo_aoo, null cap_aoo, null comune_aoo, null sigla_prov_aoo, null mail_aoo, null fax_aoo, '
               || 'null indirizzo_uo, null cap_uo, null comune_uo, null sigla_prov_uo, null mail_uo, null tel_uo, null fax_uo, '
               || 'TRIM (ben.codice_fiscale) cf_beneficiario,'
               || 'TRIM (ben.ragione_sociale_estesa) denominazione_beneficiario,'
               || 'TRIM (ben.partita_iva) pi_beneficiario,'
               || d_des_comune ||' comune_beneficiario,'
               || 'TRIM (ben.indirizzo) indirizzo_beneficiario,'
               || 'LPAD (TRIM (ben.cap), 5, ''0'') cap_beneficiario,'
               || 'TO_CHAR (ben.d_data_nascita,'
               || '''dd/mm/yyyy'') data_nascita_beneficiario,'
               || d_sigla_provincia ||' provincia_beneficiario,'
               || 'DECODE (ben.indirizzo,'
               || ' NULL, null,'
               || ' ben.indirizzo || '' '''
               || ')'
               || '|| DECODE (ben.cap, NULL, null, LPAD (TRIM (ben.cap), 5, ''0'') || '' '')'
               || '|| DECODE ('|| d_des_comune ||','
               || 'NULL, null,'
               || ' '|| d_des_comune ||' || '' '''
               || ')'
               || '|| DECODE ('|| d_sigla_provincia ||', NULL, null, '|| d_sigla_provincia ||') vis_indirizzo,'
               || 'e_mail mail_beneficiario, telex fax_beneficiario, '
               || 'NULL ni_impresa, NULL impresa, NULL denominazione_sede,'
               || 'NULL natura_giuridica, NULL insegna, NULL c_fiscale_impresa,'
               || 'NULL partita_iva_impresa, NULL tipo_localizzazione, NULL comune,'
               || 'NULL c_via_impresa, NULL via_impresa, NULL n_civico_impresa,'
               || 'NULL comune_impresa, NULL cap_impresa, NULL mail_impresa, '
               || 'partita_iva_cee cf_estero,'
               || 'NULL cognome,'
               || 'NULL nome,'
               || 'NULL indirizzo_res,'
               || 'NULL comune_res,'
               || 'NULL cap_res,'
               || 'NULL provincia_res,'
               || 'NULL tel_res,'
               || 'NULL fax_res,'
               || 'NULL indirizzo_dom,'
               || 'NULL comune_dom,'
               || 'NULL cap_dom,'
               || 'NULL provincia_dom,'
               || 'NULL tel_dom,'
               || 'NULL fax_dom,'
               || 'NULL comune_nascita,'
               || 'NULL data_nascita,'
               || 'NULL sesso,'
               || 'null ni_dipendente, null dal_dipendente, null cognome_dipendente, null nome_dipendente,'
               || 'null codice_fiscale_dipendente,'
               || 'null indirizzo_res_dipendente, null comune_res_dipendente, null provincia_res_dipendente, null cap_res_dipendente,'
               || 'null indirizzo_dom_dipendente, null comune_dom_dipendente, null provincia_dom_dipendente, null cap_dom_dipendente,'
               || 'null mail_dipendente,'
               || 'null id_tipo_recapito,'
               || 'null descrizione_tipo_recapito,'
               || 'CAST (NULL AS NUMBER ) id_recapito,'
               || 'CAST (NULL AS NUMBER ) id_contatto,'
               || 'NULL tipo_spedizione,'
               || '''B'' anagrafica, 7 '
               || 'FROM cf4_ben ben, parametri para
              WHERE trunc(sysdate) <= nvl(d_scadenza, to_date(''31/12/2999'',''dd/mm/yyyy''))
                AND ( ( ( (   NVL (LENGTH (codice_fiscale), 0) = 16
                         OR NVL (LENGTH (codice_fiscale), 0) = 11
                         OR NVL (LENGTH (partita_iva), 0) = 11))
                     AND NVL (para.valore, ''Y'') = ''Y'')
                   OR NVL (para.valore, ''Y'') = ''N'')
                AND para.tipo_modello = ''@agVar@''
                AND para.codice = ''ANA_FILTRO_1''';
         END;
      END IF;

      IF p_ce4 = 1
      THEN
         d_statement :=
               d_statement
            || ' UNION ALL '
            || 'SELECT null ni, CAST (NULL AS NUMBER) ni_gsd, TRIM (ragione_sociale_estesa) denominazione, e_mail email, telex fax,'
            || 'TRIM (partita_iva) partita_iva, TRIM (codice_fiscale) cf,'
            || 'TRIM (partita_iva) pi,'
            || 'DECODE (indirizzo,'
            || '  NULL, null,'
            || '  indirizzo || '' '''
            || ' )'
            || '|| DECODE (cap, NULL, null, LPAD (TRIM (cap), 5, ''0'') || '' '')'
            || '|| DECODE (ad4_comune.get_denominazione(provincia, comune),'
            || '  NULL, null,'
            || '  ad4_comune.get_denominazione(provincia, comune) || '' '''
            || ' )'
            || '|| DECODE (ad4_provincia.get_sigla(provincia),'
            || ' NULL, null,'
            || ' ''('' || ad4_provincia.get_sigla(provincia) || '')'''
            || ') indirizzo,'
            || 'null denominazione_per_segnatura,'
            || 'TRIM (ragione_sociale_estesa) cognome_per_segnatura,'
            || 'null nome_per_segnatura, TRIM (indirizzo) indirizzo_per_segnatura,'
            || 'ad4_comune.get_denominazione(provincia, comune) comune_per_segnatura,'
            || 'LPAD (TRIM (cap), 5, ''0'') cap_per_segnatura,'
            || 'ad4_provincia.get_sigla(provincia) provincia_per_segnatura,'
            || 'TRIM (codice_fiscale) cf_per_segnatura, TO_DATE (NULL) dal,'
            || 'TO_DATE (NULL) al, null ammin, null descrizione_amm, null aoo,'
            || 'null descrizione_aoo, null descrizione_uo, '
            || 'null cod_amm, '
            || 'null cod_amm_originale, '
            || 'null cod_aoo, '
            || 'null cod_aoo_originale, '
            || 'null cod_uo, '
            || 'null cod_uo_originale, '
            || 'null dati_amm, null dati_aoo, null dati_uo, '
            || 'TO_NUMBER (null) ni_amm, null dal_amm, null tipo,'
            || 'null indirizzo_amm, null cap_amm, null comune_amm, null sigla_prov_amm, null mail_amm, null fax_amm, '
            || 'null indirizzo_aoo, null cap_aoo, null comune_aoo, null sigla_prov_aoo, null mail_aoo, null fax_aoo, '
            || 'null indirizzo_uo, null cap_uo, null comune_uo, null sigla_prov_uo, null mail_uo, null tel_uo, null fax_uo, '
            || 'TRIM (codice_fiscale) cf_beneficiario,'
            || 'TRIM (ragione_sociale_estesa) denominazione_beneficiario,'
            || 'TRIM (partita_iva) pi_beneficiario,'
            || 'ad4_comune.get_denominazione(provincia, comune) comune_beneficiario,'
            || 'TRIM (indirizzo) indirizzo_beneficiario,'
            || 'LPAD (TRIM (cap), 5, ''0'') cap_beneficiario,'
            || 'TO_CHAR (d_data_nascita,'
            || '''dd/mm/yyyy'') data_nascita_beneficiario,'
            || 'ad4_provincia.get_sigla(provincia) provincia_beneficiario,'
            || 'DECODE (indirizzo,'
            || ' NULL, null,'
            || ' indirizzo || '' '''
            || ')'
            || '|| DECODE (cap, NULL, null, LPAD (TRIM (cap), 5, ''0'') || '' '')'
            || '|| DECODE (ad4_comune.get_denominazione(provincia, comune),'
            || 'NULL, null,'
            || ' ad4_comune.get_denominazione(provincia, comune) || '' '''
            || ')'
            || '|| DECODE (ad4_provincia.get_sigla(provincia), NULL, null, ad4_provincia.get_sigla(provincia)) vis_indirizzo,'
            || 'e_mail mail_beneficiario, '
            || 'telex fax_beneficiario, '
            || 'NULL ni_impresa, NULL impresa, NULL denominazione_sede,'
            || 'NULL natura_giuridica, NULL insegna, NULL c_fiscale_impresa,'
            || 'NULL partita_iva_impresa, NULL tipo_localizzazione, NULL comune,'
            || 'NULL c_via_impresa, NULL via_impresa, NULL n_civico_impresa,'
            || 'NULL comune_impresa, NULL cap_impresa, NULL mail_impresa, '
            || 'partita_iva_cee cf_estero,'
            || 'NULL cognome,'
            || 'NULL nome,'
            || 'NULL indirizzo_res,'
            || 'NULL comune_res,'
            || 'NULL cap_res,'
            || 'NULL provincia_res,'
            || 'NULL tel_res,'
            || 'NULL fax_res,'
            || 'NULL indirizzo_dom,'
            || 'NULL comune_dom,'
            || 'NULL cap_dom,'
            || 'NULL provincia_dom,'
            || 'NULL tel_dom,'
            || 'NULL fax_dom,'
            || 'NULL comune_nascita,'
            || 'NULL data_nascita,'
            || 'NULL sesso,'
            || 'null ni_dipendente, null dal_dipendente, null cognome_dipendente, null nome_dipendente,'
            || 'null codice_fiscale_dipendente,'
            || 'null indirizzo_res_dipendente, null comune_res_dipendente, null provincia_res_dipendente, null cap_res_dipendente,'
            || 'null indirizzo_dom_dipendente, null comune_dom_dipendente, null provincia_dom_dipendente, null cap_dom_dipendente,'
            || 'null mail_dipendente,'
            || 'null id_tipo_recapito,'
            || 'null descrizione_tipo_recapito,'
            || 'CAST (NULL AS NUMBER ) id_recapito,'
            || 'CAST (NULL AS NUMBER ) id_contatto,'
            || 'NULL tipo_spedizione,'
            || '''B'' anagrafica, 8 '
            || 'FROM ce4_clifor, parametri para
              WHERE trunc(sysdate) <= nvl(d_scadenza, to_date(''31/12/2999'',''dd/mm/yyyy''))
                AND ( ( ( (   NVL (LENGTH (codice_fiscale), 0) = 16
                         OR NVL (LENGTH (codice_fiscale), 0) = 11
                         OR NVL (LENGTH (partita_iva), 0) = 11))
                     AND NVL (para.valore, ''Y'') = ''Y'')
                   OR NVL (para.valore, ''Y'') = ''N'')
                AND para.tipo_modello = ''@agVar@''
                AND para.codice = ''ANA_FILTRO_1''';
      END IF;

      IF p_dris = 1
      THEN
         DECLARE
            d_dblink     VARCHAR2 (1000);
            d_col_mail   VARCHAR2 (1000);
         BEGIN
            SELECT MIN (db_link)
              INTO d_dblink
              FROM user_synonyms
             WHERE table_name = 'V_IMPRESA';

            IF d_dblink IS NOT NULL
            THEN
               d_dblink := '@' || d_dblink;
            END IF;

            BEGIN
               EXECUTE IMMEDIATE
                     'select column_name from all_tab_columns'
                  || d_dblink
                  || ' where table_name = ''V_IMPRESA'''
                  || '   and column_name = ''INDIRIZZO_PEC'''
                  || '   and owner = ''DRIS'''
                  INTO d_col_mail;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_col_mail := 'null';
            END;

            d_statement :=
                  d_statement
               || ' UNION ALL '
               || 'SELECT null ni, CAST (NULL AS NUMBER) ni_gsd, vimp.denominazione_sede denominazione, '
               || d_col_mail
               || ' email, null fax,'
               || 'vimp.partita_iva partita_iva, TRIM (vimp.c_fiscale_impresa) cf,'
               || 'vimp.partita_iva pi,'
               || 'DECODE (vu.c_via || '' '' || vu.via || '' '' || vu.n_civico,'
               || ' ''  '', null,'
               || ' vu.c_via || '' '' || vu.via || '' '' || vu.n_civico || '' '''
               || ' )'
               || '|| DECODE (vu.cap, NULL, null, LPAD (TRIM (vu.cap), 5, ''0'') || '' '')'
               || '|| DECODE (vu.comune, NULL, null, vu.comune || '' '')'
               || '|| DECODE (ad4_provincia.get_sigla(RTRIM (SUBSTR (vu.c_comune, 1, 3), ''0'')), NULL, null, ''('' || ad4_provincia.get_sigla(RTRIM (SUBSTR (vu.c_comune, 1, 3), ''0'')) || '')'') indirizzo,'
               || 'vimp.denominazione_sede denominazione_per_segnatura,'
               || 'null cognome_per_segnatura, null nome_per_segnatura,'
               || 'vu.c_via || '' '' || vu.via || '' '''
               || '|| vu.n_civico indirizzo_per_segnatura,'
               || 'vu.comune comune_per_segnatura, vu.cap cap_per_segnatura,'
               || 'null provincia_per_segnatura,'
               || 'TRIM (vimp.c_fiscale_impresa) cf_per_segnatura, TO_DATE (NULL) dal,'
               || 'TO_DATE (NULL) al, null ammin, null descrizione_amm, null aoo,'
               || 'null descrizione_aoo, null descrizione_uo, '
               || 'null cod_amm, '
               || 'null cod_amm_originale, '
               || 'null cod_aoo, '
               || 'null cod_aoo_originale, '
               || 'null cod_uo, '
               || 'null cod_uo_originale, '
               || 'null dati_amm, null dati_aoo, null dati_uo, '
               || 'TO_NUMBER (null) ni_amm, null dal_amm, null tipo,'
               || 'null indirizzo_amm, null cap_amm, null comune_amm, null sigla_prov_amm, '
               || 'null mail_amm, null fax_amm, '
               || 'null indirizzo_aoo, null cap_aoo, null comune_aoo, null sigla_prov_aoo, null mail_aoo, null fax_aoo, '
               || 'null indirizzo_uo, null cap_uo, null comune_uo, null sigla_prov_uo, null mail_uo, null tel_uo, null fax_uo, '
               || 'null cf_beneficiario,'
               || 'null denominazione_beneficiario, null pi_beneficiario,'
               || 'null comune_beneficiario, null indirizzo_beneficiario,'
               || 'null cap_beneficiario, null data_nascita_beneficiario,'
               || 'null provincia_beneficiario, null vis_indirizzo,'
               || 'null mail_beneficiario, null fax_beneficiario, '
               || 'vimp.n_iscrizione_rea ni_impresa, vimp.denominazione_sede impresa,'
               || 'vimp.denominazione_sede denominazione_sede,'
               || 'vimp.natura_giuridica natura_giuridica, vu.insegna insegna,'
               || 'TRIM (vimp.c_fiscale_impresa) c_fiscale_impresa,'
               || 'vimp.partita_iva partita_iva_impresa,'
               || 'vu.tipo_localizzazione tipo_localizzazione, vu.comune comune,'
               || 'vu.c_via c_via_impresa, vu.via via_impresa,'
               || 'vu.n_civico n_civico_impresa, vu.comune comune_impresa,'
               || 'vu.cap cap_impresa, '
               || d_col_mail
               || ' mail_impresa,'
               || 'NULL cf_estero,'
               || 'NULL cognome,'
               || 'NULL nome,'
               || 'NULL indirizzo_res,'
               || 'NULL comune_res,'
               || 'NULL cap_res,'
               || 'NULL provincia_res,'
               || 'NULL tel_res,'
               || 'NULL fax_res,'
               || 'NULL indirizzo_dom,'
               || 'NULL comune_dom,'
               || 'NULL cap_dom,'
               || 'NULL provincia_dom,'
               || 'NULL tel_dom,'
               || 'NULL fax_dom,'
               || 'NULL comune_nascita,'
               || 'NULL data_nascita,'
               || 'NULL sesso,'
               || 'null ni_dipendente, null dal_dipendente, null cognome_dipendente, null nome_dipendente,'
               || 'null codice_fiscale_dipendente,'
               || 'null indirizzo_res_dipendente, null comune_res_dipendente, null provincia_res_dipendente, null cap_res_dipendente,'
               || 'null indirizzo_dom_dipendente, null comune_dom_dipendente, null provincia_dom_dipendente, null cap_dom_dipendente,'
               || 'null mail_dipendente,'
               || 'null id_tipo_recapito,'
               || 'null descrizione_tipo_recapito,'
               || 'CAST (NULL AS NUMBER ) id_recapito,'
               || 'CAST (NULL AS NUMBER ) id_contatto,'
               || 'NULL tipo_spedizione,'
               || '''I'' anagrafica, 3 '
               || 'FROM dris_vista_ul vu, dris_v_impresa vimp '
               || 'WHERE vimp.n_iscrizione_rea = vu.fk_rea_n_rea '
               || 'AND vimp.cciaa_regz = vu.fk_rea_cciaa_regz ';
         END;
      END IF;

      IF p_gsd_tr4 = 1
      THEN
         DECLARE
            d_statement_gsd_tr4   VARCHAR2 (32767);
            d_is_tr4              NUMBER := 1;
            d_is_savona           NUMBER := 0;
         BEGIN
            BEGIN
               SELECT 1
                 INTO d_is_tr4
                 FROM user_synonyms
                WHERE synonym_name = 'TR4_ANAAS4';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_is_tr4 := 0;
            END;

            BEGIN
               SELECT 1
                 INTO d_is_savona
                 FROM user_tables
                WHERE table_name = 'SEG_SOGGETTI_SV';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_is_savona := 0;
            END;

            IF d_is_savona = 1
            THEN
               d_statement :=
                     d_statement
                  || ' UNION ALL '
                  || 'SELECT CAST (NULL AS NUMBER) ni,'
                  || 'CAST (NULL AS NUMBER) ni_gsd, '
                  || 'cognome||decode(nome, null, '''', '' ''||nome) denominazione,'
                  || 'email email,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax,'
                  || 'CAST (NULL AS VARCHAR2 (1)) partita_iva,'
                  || 'codfisc cf, CAST (NULL AS VARCHAR2 (1)) pi,'
                  || 'DECODE (indirizzo, NULL, '''', indirizzo || '' '')'
                  || '||DECODE (cap, NULL, null, LPAD (TRIM (cap), 5, ''0'') || '' '')'
                  || '||DECODE (COMUNE,NULL, null,COMUNE || '' '')'
                  || '||DECODE (PROV,NULL, '''', ''('' || PROV || '')'')'
                  || 'indirizzo,'
                  || 'cognome||decode(nome, null, '''', '' ''||nome) denominazione_per_segnatura,'
                  || 'cognome cognome_per_segnatura,'
                  || 'nome nome_per_segnatura,'
                  || 'indirizzo indirizzo_per_segnatura,'
                  || 'comune comune_per_segnatura,'
                  || 'cap cap_per_segnatura,'
                  || 'prov provincia_per_segnatura,'
                  || 'codfisc cf_per_segnatura, '
                  || 'CAST (NULL AS DATE) dal, '
                  || 'CAST (NULL AS DATE) al, '
                  || 'CAST (NULL AS VARCHAR2 (1)) ammin, '
                  || 'CAST (NULL AS VARCHAR2 (1)) descrizione_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) descrizione_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) descrizione_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cod_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cod_amm_originale,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cod_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cod_aoo_originale,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cod_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cod_uo_originale,'
                  || 'CAST (NULL AS VARCHAR2 (1)) dati_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) dati_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) dati_uo,'
                  || 'CAST (NULL AS NUMBER) ni_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) dal_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) tipo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cap_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) sigla_prov_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) mail_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax_amm,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cap_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) sigla_prov_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) mail_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax_aoo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cap_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) sigla_prov_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) mail_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) tel_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax_uo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cf_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) denominazione_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) pi_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cap_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) data_nascita_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) provincia_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) vis_indirizzo,'
                  || 'CAST (NULL AS VARCHAR2 (1)) mail_beneficiario,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax_beneficiario,'
                  || 'CAST (NULL AS NUMBER) ni_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) denominazione_sede,'
                  || 'CAST (NULL AS VARCHAR2 (1)) natura_giuridica,'
                  || 'CAST (NULL AS VARCHAR2 (1)) insegna,'
                  || 'CAST (NULL AS VARCHAR2 (1)) c_fiscale_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) partita_iva_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) tipo_localizzazione,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune,'
                  || 'CAST (NULL AS VARCHAR2 (1)) c_via_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) via_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) n_civico_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cap_impresa, '
                  || 'CAST (NULL AS VARCHAR2 (1)) mail_impresa,'
                  || 'CAST (NULL AS VARCHAR2 (40)) cf_estero,'
                  || 'cognome cognome,'
                  || 'nome nome,'
                  || 'indirizzo indirizzo_res,'
                  || 'comune comune_res,'
                  || 'cap cap_res,'
                  || 'prov provincia_res,'
                  || 'telefono tel_res,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax_res,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_dom,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_dom,'
                  || 'CAST (NULL AS VARCHAR2 (1)) cap_dom,'
                  || 'CAST (NULL AS VARCHAR2 (1)) provincia_dom,'
                  || 'CAST (NULL AS VARCHAR2 (1)) tel_dom,'
                  || 'CAST (NULL AS VARCHAR2 (1)) fax_dom,'
                  || 'CAST (NULL AS VARCHAR2 (1)) comune_nascita,'
                  || 'CAST (NULL AS VARCHAR2 (1)) data_nascita,'
                  || 'sesso sesso,'
                  || 'CAST (NULL AS NUMBER) ni_dipendente, CAST (NULL AS VARCHAR2 (1)) dal_dipendente, CAST (NULL AS VARCHAR2 (1)) cognome_dipendente, CAST (NULL AS VARCHAR2 (1)) nome_dipendente,'
                  || 'CAST (NULL AS VARCHAR2 (1)) codice_fiscale_dipendente,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_res_dipendente, CAST (NULL AS VARCHAR2 (1)) comune_res_dipendente, CAST (NULL AS VARCHAR2 (1)) provincia_res_dipendente, CAST (NULL AS VARCHAR2 (1)) cap_res_dipendente,'
                  || 'CAST (NULL AS VARCHAR2 (1)) indirizzo_dom_dipendente, CAST (NULL AS VARCHAR2 (1)) comune_dom_dipendente, CAST (NULL AS VARCHAR2 (1)) provincia_dom_dipendente, CAST (NULL AS VARCHAR2 (1)) cap_dom_dipendente,'
                  || 'CAST (NULL AS VARCHAR2 (1)) mail_dipendente,'
                  || 'CAST (NULL AS NUMBER (1)) id_tipo_recapito,'
                  || 'CAST (NULL AS VARCHAR2 (1)) descrizione_tipo_recapito,'
                  || 'CAST (NULL AS NUMBER ) id_recapito,'
                  || 'CAST (NULL AS NUMBER ) id_contatto,'
                  || 'CAST (NULL AS VARCHAR2 (1))tipo_spedizione,'
                  || '''G'' anagrafica, 9'
                  || ' FROM seg_soggetti_sv ';
            ELSE
               d_statement_gsd_tr4 :=
                     'create or replace force view SEG_ANAGRAFICI_GSD_TR4 as '
                  || '         SELECT sogg.denominazione,
              indirizzo_web email,
              fax_res fax,
              partita_iva,
              codice_fiscale cf,
              partita_iva pi,
              DECODE (indirizzo_res, NULL, '''', indirizzo_res || '' '')
              || DECODE (cap_res, NULL, null, LPAD (TRIM (cap_res), 5, ''0'') || '' '')
              || DECODE (denominazione_comune_res,
                         NULL, null,
                         denominazione_comune_res || '' '')
              || DECODE (sigla_provincia_res,
                         NULL, '''',
                         ''('' || sigla_provincia_res || '')'')
                 indirizzo,
              decode(cognome, null, denominazione, null) denominazione_per_segnatura,
              cognome cognome_per_segnatura,
              nome nome_per_segnatura,
              indirizzo_res indirizzo_per_segnatura,
              denominazione_comune_res comune_per_segnatura,
              decode(SIGN(length(cap_res) - 5), 1, NULL, cap_res) cap_per_segnatura,
              sigla_provincia_res provincia_per_segnatura,
              codice_fiscale cf_per_segnatura,
              dal,
              al,
              to_number(null) ni_persona,
              TO_CHAR (dal, ''dd/mm/yyyy'') dal_persona,
              ni,
              PARTITA_IVA_CEE cf_estero,
              cognome,
              nome,
              indirizzo_res indirizzo_res,
              decode(SIGN(length(cap_res) - 5), 1, NULL, cap_res) cap_res,
              denominazione_comune_res comune_res,
              sigla_provincia_res provincia_res,
              codice_fiscale codice_fiscale,
              indirizzo_dom,
              denominazione_comune_dom comune_dom,
              decode(SIGN(length(cap_dom) - 5), 1, NULL, cap_dom) cap_dom,
              sigla_provincia_dom provincia_dom,
              indirizzo_web mail_persona,
              tel_res,
              fax_res,
              sesso,
              denominazione_comune_nas comune_nascita,
              TO_CHAR (data_nas, ''dd/mm/yyyy'') data_nascita,
              tel_dom,
              fax_dom,
              DECODE (tipo_soggetto, ''x'', ''Y'', decode(NVL (para.valore, ''Y''),''N'', ''Y'', decode(partita_iva, null, ''N'',''Y''))) cf_nullable,
              to_char(null) ammin,
              to_char(null) descrizione_amm,
              to_char(null) aoo,
              to_char(null) descrizione_aoo,
              to_char(null) descrizione_uo,
              to_char(null) cod_amm,
              to_char(null) cod_amm_originale,
              to_char(null) cod_aoo,
              to_char(null) cod_aoo_originale,
              to_char(null) cod_uo,
              to_char(null) cod_uo_originale,
              to_char(null) dati_amm,
              to_char(null) dati_aoo,
              to_char(null) dati_uo,
              TO_NUMBER(null) ni_amm,
              to_char(null) dal_amm,
              to_char(null) tipo,
              to_char(null) indirizzo_amm,
              to_char(null) cap_amm,
              to_char(null) comune_amm,
              to_char(null) sigla_prov_amm,
              to_char(null) mail_amm,
              to_char(null) fax_amm,
              to_char(null) indirizzo_aoo,
              to_char(null) cap_aoo,
              to_char(null) comune_aoo,
              to_char(null) sigla_prov_aoo,
              to_char(null) mail_aoo,
              to_char(null) fax_aoo,
              to_char(null) indirizzo_uo,
              to_char(null) cap_uo,
              to_char(null) comune_uo,
              to_char(null) sigla_prov_uo,
              to_char(null) mail_uo,
              to_char(null) tel_uo,
              to_char(null) fax_uo,
              to_char(null) cf_beneficiario,
              to_char(null) denominazione_beneficiario,
              to_char(null) pi_beneficiario,
              to_char(null) comune_beneficiario,
              to_char(null) indirizzo_beneficiario,
              to_char(null) cap_beneficiario,
              to_char(null) data_nascita_beneficiario,
              to_char(null) provincia_beneficiario,
              to_char(null) vis_indirizzo,
              NULL mail_beneficiario,
              NULL fax_beneficiario,
              NULL ni_impresa,
              NULL impresa,
              NULL denominazione_sede,
              NULL natura_giuridica,
              NULL insegna,
              NULL c_fiscale_impresa,
              NULL partita_iva_impresa,
              NULL tipo_localizzazione,
              NULL comune,
              NULL c_via_impresa,
              NULL via_impresa,
              NULL n_civico_impresa,
              NULL comune_impresa,
              NULL cap_impresa,
              NULL mail_impresa,
              NULL id_tipo_recapito,
              NULL descrizione_tipo_recapito,
              null id_recapito,
              null id_contatto,
              NULL tipo_spedizione,
              ''G'' anagrafica,
              9 tipo_soggetto
             FROM ';

               IF d_is_tr4 = 1
               THEN
                  d_statement_gsd_tr4 :=
                     d_statement_gsd_tr4 || 'tr4_anaas4 sogg';
               ELSE
                  d_statement_gsd_tr4 :=
                     d_statement_gsd_tr4 || 'gsd_anaas4 sogg';
               END IF;

               d_statement_gsd_tr4 :=
                     d_statement_gsd_tr4
                  || ', parametri para
            WHERE ( ( ( (   NVL (LENGTH (codice_fiscale), 0) = 16
                         OR NVL (LENGTH (codice_fiscale), 0) = 11
                         OR NVL (LENGTH (partita_iva), 0) = 11)
                       OR (tipo_soggetto = ''x''))
                     AND NVL (para.valore, ''Y'') = ''Y'')
                   OR NVL (para.valore, ''Y'') = ''N'')
                  AND para.tipo_modello = ''@agVar@''
                  AND para.codice = ''ANA_FILTRO_1''';

               integrityPackage.LOG (
                  '-------------------- SEG_ANAGRAFICI_GSD_TR4 --------------------');
               integrityPackage.LOG (d_statement_gsd_tr4);

               EXECUTE IMMEDIATE d_statement_gsd_tr4;

               d_statement :=
                     d_statement
                  || ' UNION ALL '
                  || 'SELECT CAST (NULL AS NUMBER) ni, ni ni_gsd, denominazione, email, fax, partita_iva, cf, pi,'
                  || ' indirizzo, denominazione_per_segnatura, cognome_per_segnatura, nome_per_segnatura,'
                  || ' indirizzo_per_segnatura, comune_per_segnatura, cap_per_segnatura,'
                  || ' provincia_per_segnatura, cf_per_segnatura, dal, al, ammin, descrizione_amm, aoo,'
                  || ' descrizione_aoo,  descrizione_uo, '
                  || ' cod_amm,  '
                  || ' cod_amm_originale,  '
                  || ' cod_aoo,  '
                  || ' cod_aoo_originale,  '
                  || ' cod_uo, '
                  || ' cod_uo_originale,  '
                  || ' dati_amm,  dati_aoo,  dati_uo, '
                  || ' ni_amm,  dal_amm,  tipo,'
                  || ' indirizzo_amm,  cap_amm,  comune_amm,  sigla_prov_amm,'
                  || ' mail_amm, fax_amm, indirizzo_aoo,  cap_aoo,  comune_aoo,'
                  || ' sigla_prov_aoo,  mail_aoo, fax_aoo,'
                  || ' indirizzo_uo,  cap_uo,  comune_uo,  sigla_prov_uo,  mail_uo,  tel_uo,  fax_uo,'
                  || ' cf_beneficiario,'
                  || ' denominazione_beneficiario,  pi_beneficiario,'
                  || ' comune_beneficiario,  indirizzo_beneficiario,'
                  || ' cap_beneficiario,  data_nascita_beneficiario,'
                  || ' provincia_beneficiario,  vis_indirizzo,'
                  || ' mail_beneficiario, fax_beneficiario,'
                  || ' ni_impresa, impresa,'
                  || ' denominazione_sede,'
                  || ' natura_giuridica,  insegna,'
                  || ' c_fiscale_impresa,'
                  || ' partita_iva_impresa,'
                  || ' tipo_localizzazione,  comune,'
                  || ' c_via_impresa, via_impresa,'
                  || ' n_civico_impresa, comune_impresa,'
                  || ' cap_impresa,  mail_impresa,'
                  || ' cf_estero,'
                  || ' cognome,'
                  || ' nome,'
                  || ' indirizzo_res,'
                  || ' comune_res,'
                  || ' cap_res,'
                  || ' provincia_res,'
                  || ' tel_res,'
                  || ' fax_res,'
                  || ' indirizzo_dom,'
                  || ' comune_dom,'
                  || ' cap_dom,'
                  || ' provincia_dom,'
                  || ' tel_dom,'
                  || ' fax_dom,'
                  || ' comune_nascita,'
                  || ' data_nascita,'
                  || ' sesso,'
                  || ' null ni_dipendente, null dal_dipendente, null cognome_dipendente, null nome_dipendente,'
                  || ' null codice_fiscale_dipendente,'
                  || ' null indirizzo_res_dipendente, null comune_res_dipendente, null provincia_res_dipendente, null cap_res_dipendente,'
                  || ' null indirizzo_dom_dipendente, null comune_dom_dipendente, null provincia_dom_dipendente, null cap_dom_dipendente,'
                  || ' null mail_dipendente,'
                  || ' null id_tipo_recapito,'
                  || ' null descrizione_tipo_recapito,'
                  || 'CAST (NULL AS NUMBER ) id_recapito,'
                  || 'CAST (NULL AS NUMBER ) id_contatto,'
                  || ' NULL tipo_spedizione,'
                  || 'anagrafica, tipo_soggetto
                  FROM SEG_ANAGRAFICI_GSD_TR4';
            END IF;
         END;
      END IF;

      IF p_dip = 1
      THEN
         d_statement :=
               d_statement
            || ' UNION ALL '
            || 'SELECT null ni, CAST (NULL AS NUMBER) ni_gsd, denominazione, email, fax,'
            || 'TRIM (partita_iva) partita_iva, TRIM (codice_fiscale) cf,'
            || 'TRIM (partita_iva) pi,'
            || 'DECODE (indirizzo_per_segnatura,'
            || '  NULL, null,'
            || '  indirizzo_per_segnatura || '' '''
            || ' )'
            || '|| DECODE (cap_per_segnatura, NULL, null, LPAD (TRIM (cap_per_segnatura), 5, ''0'') || '' '')'
            || '|| DECODE (comune_per_segnatura,'
            || '  NULL, null,'
            || '  comune_per_segnatura || '' '''
            || ' )'
            || '|| DECODE (provincia_per_segnatura,'
            || ' NULL, null,'
            || ' ''('' || provincia_per_segnatura || '')'''
            || ') indirizzo,'
            || 'denominazione denominazione_per_segnatura,'
            || 'cognome_per_segnatura,'
            || 'nome_per_segnatura, indirizzo_per_segnatura,'
            || 'comune_per_segnatura,'
            || 'cap_per_segnatura,'
            || 'provincia_per_segnatura,'
            || 'cf_per_segnatura, TO_DATE (NULL) dal,'
            || 'TO_DATE (NULL) al, null ammin, null descrizione_amm, null aoo,'
            || 'null descrizione_aoo, null descrizione_uo, '
            || 'null cod_amm, '
            || 'null cod_amm_originale, '
            || 'null cod_aoo, '
            || 'null cod_aoo_originale, '
            || 'null cod_uo, '
            || 'null cod_uo_originale, '
            || 'null dati_amm, null dati_aoo, null dati_uo, '
            || 'TO_NUMBER (null) ni_amm, null dal_amm, null tipo,'
            || 'null indirizzo_amm, null cap_amm, null comune_amm, null sigla_prov_amm, null mail_amm, null fax_amm, '
            || 'null indirizzo_aoo, null cap_aoo, null comune_aoo, null sigla_prov_aoo, null mail_aoo, null fax_aoo, '
            || 'null indirizzo_uo, null cap_uo, null comune_uo, null sigla_prov_uo, null mail_uo, null tel_uo, null fax_uo, '
            || 'null cf_beneficiario,'
            || 'null denominazione_beneficiario,'
            || 'null pi_beneficiario,'
            || 'null comune_beneficiario,'
            || 'null indirizzo_beneficiario,'
            || 'null cap_beneficiario,'
            || 'null data_nascita_beneficiario,'
            || 'null provincia_beneficiario,'
            || 'DECODE (indirizzo_res_dipendente,'
            || ' NULL, null,'
            || ' indirizzo_res_dipendente || '' '''
            || ')'
            || '|| DECODE (cap_res_dipendente, NULL, null, LPAD (TRIM (cap_res_dipendente), 5, ''0'') || '' '')'
            || '|| DECODE (provincia_res_dipendente,'
            || 'NULL, null,'
            || ' comune_res_dipendente || '' '''
            || ')'
            || '|| DECODE (provincia_res_dipendente, NULL, null, provincia_res_dipendente) vis_indirizzo,'
            || 'null mail_beneficiario, '
            || 'null fax_beneficiario, '
            || 'NULL ni_impresa, NULL impresa, NULL denominazione_sede,'
            || 'NULL natura_giuridica, NULL insegna, NULL c_fiscale_impresa,'
            || 'NULL partita_iva_impresa, NULL tipo_localizzazione, NULL comune,'
            || 'NULL c_via_impresa, NULL via_impresa, NULL n_civico_impresa,'
            || 'NULL comune_impresa, NULL cap_impresa, NULL mail_impresa, '
            || 'NULL cf_estero,'
            || 'NULL cognome,'
            || 'NULL nome,'
            || 'NULL indirizzo_res,'
            || 'NULL comune_res,'
            || 'NULL cap_res,'
            || 'NULL provincia_res,'
            || 'NULL tel_res,'
            || 'NULL fax_res,'
            || 'NULL indirizzo_dom,'
            || 'NULL comune_dom,'
            || 'NULL cap_dom,'
            || 'NULL provincia_dom,'
            || 'NULL tel_dom,'
            || 'NULL fax_dom,'
            || 'NULL comune_nascita,'
            || 'NULL data_nascita,'
            || 'NULL sesso,'
            || 'ni_dipendente, dal_dipendente, cognome_dipendente, nome_dipendente,'
            || 'codice_fiscale_dipendente,'
            || 'indirizzo_res_dipendente, comune_res_dipendente, provincia_res_dipendente, cap_res_dipendente,'
            || 'indirizzo_dom_dipendente, comune_dom_dipendente, provincia_dom_dipendente, cap_dom_dipendente,'
            || 'mail_dipendente,'
            || 'null id_tipo_recapito,'
            || 'null descrizione_tipo_recapito,'
            || 'CAST (NULL AS NUMBER ) id_recapito,'
            || 'CAST (NULL AS NUMBER ) id_contatto,'
            || 'NULL tipo_spedizione,'
            || '''D'' anagrafica, 5 '
            || 'FROM dipendenti';
      END IF;


      IF p_ade = 1
      THEN
         d_statement :=
               d_statement
            || ' UNION ALL '
            || 'SELECT intproade.idade ni, CAST (NULL AS NUMBER) ni_gsd, TRIM (nvl(intproade.denominazione, nvl(intproade.cognome,'''') || '' '' || nvl(intproade.nome,'''')  )) denominazione, MAIL email, to_char(null) fax,'
            || 'TRIM (decode(lower(intproade.tipo),''cittadino'',to_char(null),intproade.CFISCPIVA) ) partita_iva,  (case when ( length(TRIM(CFISCPIVA))  - 11 )<=0 then to_char(null) else TRIM(CFISCPIVA) end) cf,'
            || ' (case when ( length(TRIM(CFISCPIVA))  - 11 )<=0 then TRIM(CFISCPIVA)  else to_char(null) end) pi,'
            || 'DECODE (intproade.indirizzo,'
            || '  NULL, null,'
            || '  intproade.TIPOINDIRIZZO ||''__''|| intproade.indirizzo ||''__''|| intproade.numciv '
            || ') indirizzo,'
            || 'TRIM(intproade.denominazione) denominazione_per_segnatura,'
            || 'TRIM (intproade.cognome) cognome_per_segnatura,'
            || 'TRIM (intproade.nome)  nome_per_segnatura, '
            || 'DECODE (intproade.indirizzo,'
            || '  NULL, null,'
            || '  intproade.TIPOINDIRIZZO ||''__''|| intproade.indirizzo ||''__''|| intproade.numciv '
            || ') indirizzo_per_segnatura,'
            || 'DECODE (intproade.comune,'
            || '  NULL, null,'
            || '  AD4_COMUNE.GET_DENOMINAZIONE ( to_number(substr(intproade.comune,1,3)), to_number(substr(intproade.comune,4))) || '' '''
            || ' ) comune_per_segnatura,'
            || 'LPAD (TRIM (intproade.cap), 5, ''0'') cap_per_segnatura,'
            || 'TRIM(intproade.provincia) provincia_per_segnatura,'
            || ' (case when ( length(TRIM(CFISCPIVA))  - 11 )<=0 then to_char(null) else TRIM(CFISCPIVA) end) cf_per_segnatura, TO_DATE (NULL) dal,'
            || 'TO_DATE (NULL) al, null ammin, null descrizione_amm, null aoo,'
            || 'null descrizione_aoo, null descrizione_uo, '
            || 'null cod_amm, '
            || 'null cod_amm_originale, '
            || 'null cod_aoo, '
            || 'null cod_aoo_originale, '
            || 'null cod_uo, '
            || 'null cod_uo_originale, '
            || 'null dati_amm, null dati_aoo, null dati_uo, '
            || 'TO_NUMBER (null) ni_amm, null dal_amm, null tipo,'
            || 'null indirizzo_amm, null cap_amm, null comune_amm, null sigla_prov_amm, null mail_amm, null fax_amm, '
            || 'null indirizzo_aoo, null cap_aoo, null comune_aoo, null sigla_prov_aoo, null mail_aoo, null fax_aoo, '
            || 'null indirizzo_uo, null cap_uo, null comune_uo, null sigla_prov_uo, null mail_uo, null tel_uo, null fax_uo, '
            || 'null cf_beneficiario,'
            || 'null denominazione_beneficiario,'
            || 'null pi_beneficiario,'
            || 'null comune_beneficiario,'
            || 'null indirizzo_beneficiario,'
            || 'null cap_beneficiario,'
            || 'null data_nascita_beneficiario,'
            || 'null provincia_beneficiario,'
            || 'null vis_indirizzo,'
            || 'mail mail_beneficiario, null fax_beneficiario, '
            || 'NULL ni_impresa, NULL impresa, NULL denominazione_sede,'
            || 'NULL natura_giuridica, NULL insegna, NULL c_fiscale_impresa,'
            || 'NULL partita_iva_impresa, tipo tipo_localizzazione, NULL comune,'
            || 'NULL c_via_impresa, NULL via_impresa, NULL n_civico_impresa,'
            || 'NULL comune_impresa, NULL cap_impresa, NULL mail_impresa, '
            || 'NULL cf_estero,'
            || 'NULL cognome,'
            || 'NULL nome,'
            || 'NULL indirizzo_res,'
            || 'NULL comune_res,'
            || 'NULL cap_res,'
            || 'NULL provincia_res,'
            || 'NULL tel_res,'
            || 'NULL fax_res,'
            || 'NULL indirizzo_dom,'
            || 'NULL comune_dom,'
            || 'NULL cap_dom,'
            || 'NULL provincia_dom,'
            || 'NULL tel_dom,'
            || 'NULL fax_dom,'
            || 'NULL comune_nascita,'
            || 'NULL data_nascita,'
            || 'NULL sesso,'
            || 'null ni_dipendente, null dal_dipendente, null cognome_dipendente, null nome_dipendente,'
            || 'null codice_fiscale_dipendente,'
            || 'null indirizzo_res_dipendente, null comune_res_dipendente, null provincia_res_dipendente, null cap_res_dipendente,'
            || 'null indirizzo_dom_dipendente, null comune_dom_dipendente, null provincia_dom_dipendente, null cap_dom_dipendente,'
            || 'null mail_dipendente,'
            || 'null id_tipo_recapito,'
            || 'null descrizione_tipo_recapito,'
            || 'CAST (NULL AS NUMBER ) id_recapito,'
            || 'CAST (NULL AS NUMBER ) id_contatto,'
            || 'NULL tipo_spedizione,'
            || '''T'' anagrafica, 10 '
            || 'FROM interpro_ade intproade';
      END IF;

      integrityPackage.LOG (
         '-------------------- SEG_SOGGETTI --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement := 'DROP INDEX SEG_SOGG_DEN_CTX';
      integrityPackage.LOG (
         '-------------------- DROP SEG_SOGG_DEN_CTX --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_SOGG_CF_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_SOGG_CF_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_SOGG_PI_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_SOGG_PI_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP MATERIALIZED VIEW SEG_SOGGETTI_MV ';
      integrityPackage.LOG (
         '-------------------- DROP SEG_SOGGETTI_MV --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -12003
            THEN                           -- materialized view dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement :=
            'CREATE MATERIALIZED VIEW seg_soggetti_mv '
         || ' REFRESH FORCE '
         || 'START WITH SYSDATE '
         || 'NEXT  TRUNC(SYSDATE) + 1 '
         || 'WITH ROWID '
         || 'AS  '
         || 'SELECT denominazione, email, fax, partita_iva, cf, pi, '
         || 'indirizzo, denominazione_per_segnatura, cognome_per_segnatura, nome_per_segnatura, indirizzo_per_segnatura, '
         || 'comune_per_segnatura, cap_per_segnatura, provincia_per_segnatura, cf_per_segnatura, dal, '
         || 'CAST(NULL AS DATE) al, '
         || 'CAST(NULL AS NUMBER) ni_persona, '
         || 'CAST(NULL AS VARCHAR2(1))  dal_persona, '
         || 'to_char(ni) ni, '
         || 'cognome, '
         || 'nome, '
         || 'indirizzo_res, '
         || 'cap_res, '
         || 'comune_res, '
         || 'provincia_res, '
         || 'cf codice_fiscale, '
         || 'indirizzo_dom, '
         || 'comune_dom, '
         || 'cap_dom, '
         || 'provincia_dom, '
         || 'CAST(NULL AS VARCHAR2(1)) mail_persona, '
         || 'tel_res, '
         || 'fax_res, '
         || 'sesso, '
         || 'comune_nascita, '
         || 'data_nascita, '
         || 'tel_dom, '
         || 'fax_dom,'
         || 'CAST(NULL AS VARCHAR2(1)) cf_nullable, '
         || 'ammin, descrizione_amm, aoo, '
         || 'descrizione_aoo, descrizione_uo, '
         || 'cod_amm, '
         || 'cod_amm_originale, '
         || 'cod_aoo, '
         || 'cod_aoo_originale, '
         || 'cod_uo, '
         || 'cod_uo_originale, '
         || 'dati_amm, dati_aoo, dati_uo, '
         || 'ni_amm, dal_amm, tipo, indirizzo_amm, cap_amm, '
         || 'comune_amm, sigla_prov_amm, mail_amm, fax_amm, indirizzo_aoo, cap_aoo, '
         || 'comune_aoo, sigla_prov_aoo, mail_aoo, fax_aoo, '
         || 'indirizzo_uo, cap_uo, comune_uo, sigla_prov_uo, mail_uo, tel_uo, fax_uo,'
         || 'cf_beneficiario, denominazione_beneficiario, '
         || 'pi_beneficiario, comune_beneficiario, indirizzo_beneficiario, cap_beneficiario, data_nascita_beneficiario, '
         || 'provincia_beneficiario, vis_indirizzo, mail_beneficiario, fax_beneficiario,'
         || 'ni_impresa, impresa, denominazione_sede, '
         || 'natura_giuridica, insegna, c_fiscale_impresa, partita_iva_impresa, tipo_localizzazione, '
         || 'comune, c_via_impresa, via_impresa, n_civico_impresa, comune_impresa, '
         || 'cap_impresa, mail_impresa, cf_estero,ni_gsd, '
         || 'ni_dipendente, dal_dipendente, cognome_dipendente, nome_dipendente,'
         || 'codice_fiscale_dipendente,'
         || 'indirizzo_res_dipendente, comune_res_dipendente, provincia_res_dipendente, cap_res_dipendente,'
         || 'indirizzo_dom_dipendente, comune_dom_dipendente, provincia_dom_dipendente, cap_dom_dipendente,'
         || 'mail_dipendente,'
         || 'CAST(NULL AS NUMBER) id_tipo_recapito,'
         || 'CAST(NULL AS VARCHAR2(1)) descrizione_tipo_recapito,'
         || 'CAST (NULL AS NUMBER ) id_recapito,'
         || 'CAST (NULL AS NUMBER ) id_contatto,'
         || 'CAST (NULL AS VARCHAR2 (1))tipo_spedizione,'

         || 'anagrafica, tipo_soggetto '
         || 'FROM seg_soggetti';
      integrityPackage.LOG (
         '-------------------- SEG_SOGGETTI_MV --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement := 'grant select on SEG_SOGGETTI_MV to agspr';
      integrityPackage.LOG (
         '-------------------- Grant a AGSPR di SEG_SOGGETTI_MV --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement :=
            'CREATE INDEX SEG_SOGG_DEN_CTX ON seg_soggetti_mv '
         || '(denominazione) '
         || 'INDEXTYPE IS ctxsys.ctxcat '
         || 'PARAMETERS(''lexer italian_lexer '
         || 'wordlist italian_wordlist '
         || 'stoplist anag_stoplist '
         || 'memory 10M'' '
         || ')';
      integrityPackage.LOG (
         '-------------------- SEG_SOGG_DEN_CTX --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement :=
         'CREATE INDEX SEG_SOGG_CF_IK ON SEG_SOGGETTI_MV (CODICE_FISCALE)';
      integrityPackage.LOG (
         '-------------------- SEG_SOGG_CF_IK --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement :=
         'CREATE INDEX SEG_SOGG_PI_IK ON SEG_SOGGETTI_MV (PARTITA_IVA)';
      integrityPackage.LOG (
         '-------------------- SEG_SOGG_PI_IK --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement := 'DROP INDEX SEG_AAUO_DEN_CTX';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_DEN_CTX --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_DESC_AMM_CTX';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_DESC_AMM_CTX --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_DESC_AOO_CTX';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_DESC_AOO_CTX --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_DESC_UO_CTX';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_DESC_UO_CTX --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_CF_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_CF_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_PI_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_PI_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_EMAIL_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_EMAIL_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_MAILFAX_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_MAILFAX_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP INDEX SEG_AAUO_AMM_AOO_IK';
      integrityPackage.LOG (
         '-------------------- DROP SEG_AAUO_AMM_AOO_IK --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1418
            THEN                                       -- INDEX dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement := 'DROP MATERIALIZED VIEW SEG_AMM_AOO_UO_MV ';
      integrityPackage.LOG (
         '-------------------- DROP VIEW SEG_AMM_AOO_UO_MV --------------------');
      integrityPackage.LOG (d_statement);

      BEGIN
         EXECUTE IMMEDIATE d_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -12003
            THEN                           -- materialized view dos not exists
               NULL;
            ELSE
               RAISE;
            END IF;
      END;

      d_statement :=
            'CREATE OR REPLACE FORCE VIEW SEG_UO_MAIL(COD_AMM, COD_AOO, COD_UO, EMAIL, MAILFAX) '
         || 'AS '
         || '   SELECT cod_amm, '
         || '          cod_aoo, '
         || '          cod_uo, '
         || '          EMAIL, mailfax '
         || '     FROM seg_amm_aoo_uo_mv, '
         || '          (SELECT pamm.valore codice_amministrazione, paoo.valore codice_aoo '
         || '             FROM parametri paoo, parametri pamm '
         || '            WHERE     pamm.tipo_modello = ''@agVar@'' '
         || '                  AND paoo.tipo_modello = ''@agVar@'' '
         || '                  AND pamm.codice = '
         || '                         ''CODICE_AMM_'' || AG_UTILITIES.GET_DEFAULTAOOINDEX '
         || '                  AND paoo.codice = '
         || '                         ''CODICE_AOO_'' || AG_UTILITIES.GET_DEFAULTAOOINDEX) PARA '
         || '    WHERE     COD_AMM = PARA.codice_amministrazione '
         || '          AND COD_AOO = PARA.codice_aoo '
         || '          AND nvl(al, trunc(sysdate)) >= trunc(sysdate) '
         || '          AND TIPO = ''UO'' ';
      integrityPackage.LOG (
         '-------------------- SEG_UO_MAIL --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement :=
            'create or replace force view seg_anagrafici_so4 as '
         || 'SELECT denominazione, email, fax, partita_iva, cf, pi, indirizzo, '
         || 'denominazione_per_segnatura, cognome_per_segnatura, '
         || 'nome_per_segnatura, indirizzo_per_segnatura, comune_per_segnatura, '
         || 'cap_per_segnatura, provincia_per_segnatura, cf_per_segnatura, dal, '
         || 'al, ni_persona, dal_persona, ni, cognome, nome, indirizzo_res, '
         || 'cap_res, comune_res, provincia_res, codice_fiscale, indirizzo_dom, '
         || 'comune_dom, cap_dom, provincia_dom, mail_persona, tel_res, fax_res, '
         || 'sesso, comune_nascita, data_nascita, tel_dom, fax_dom, cf_nullable, '
         || 'ammin, descrizione_amm, aoo, descrizione_aoo, descrizione_uo, '
         || 'cod_amm, '
         || 'cod_amm_originale, '
         || 'cod_aoo, '
         || 'cod_aoo_originale, '
         || 'cod_uo, '
         || 'cod_uo_originale, '
         || 'dati_amm, dati_aoo, dati_uo, '
         || 'ni_amm, dal_amm, tipo, '
         || 'indirizzo_amm, cap_amm, comune_amm, sigla_prov_amm, mail_amm, fax_amm, '
         || 'indirizzo_aoo, cap_aoo, comune_aoo, sigla_prov_aoo, mail_aoo, fax_aoo, '
         || 'indirizzo_uo, cap_uo, comune_uo, sigla_prov_uo, mail_uo, tel_uo, fax_uo,'
         || 'cf_beneficiario, '
         || 'denominazione_beneficiario, pi_beneficiario, comune_beneficiario, '
         || 'indirizzo_beneficiario, cap_beneficiario, data_nascita_beneficiario, '
         || 'provincia_beneficiario, vis_indirizzo, mail_beneficiario, fax_beneficiario,'
         || 'ni_impresa, impresa, '
         || 'denominazione_sede, natura_giuridica, insegna, c_fiscale_impresa, '
         || 'partita_iva_impresa, tipo_localizzazione, comune, c_via_impresa, '
         || 'via_impresa, n_civico_impresa, comune_impresa, cap_impresa, mail_impresa, '
         || 'NULL cf_estero,'
         || 'ni_gsd, '
         || 'null ni_dipendente, null dal_dipendente, null cognome_dipendente, null nome_dipendente,'
         || 'null codice_fiscale_dipendente,'
         || 'null indirizzo_res_dipendente, null comune_res_dipendente, null provincia_res_dipendente, null cap_res_dipendente,'
         || 'null indirizzo_dom_dipendente, null comune_dom_dipendente, null provincia_dom_dipendente, null cap_dom_dipendente,'
         || 'null mail_dipendente,'
         || 'null id_tipo_recapito,'
         || 'null descrizione_tipo_recapito,'
         || 'CAST (NULL AS NUMBER ) id_recapito,'
         || 'CAST (NULL AS NUMBER ) id_contatto,'
         || 'NULL tipo_spedizione,'
         || 'anagrafica, 2 tipo_soggetto '
         || 'FROM seg_amm_aoo_uo_mv';
      integrityPackage.LOG (
         '-------------------- SEG_ANAGRAFICI_SO4 --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      /* -------------------- SEG_ANAGRAFICI_AS4 -------------------- */
      d_statement := 'CREATE OR REPLACE FORCE VIEW SEG_ANAGRAFICI_AS4
(DENOMINAZIONE, EMAIL, FAX, PARTITA_IVA, CF, PI, INDIRIZZO, DENOMINAZIONE_PER_SEGNATURA, COGNOME_PER_SEGNATURA, NOME_PER_SEGNATURA,
    INDIRIZZO_PER_SEGNATURA, COMUNE_PER_SEGNATURA, CAP_PER_SEGNATURA, PROVINCIA_PER_SEGNATURA, CF_PER_SEGNATURA, DAL, AL, NI_PERSONA, DAL_PERSONA, NI,
    COGNOME, NOME, INDIRIZZO_RES, CAP_RES, COMUNE_RES, PROVINCIA_RES, CODICE_FISCALE, INDIRIZZO_DOM, COMUNE_DOM, CAP_DOM, PROVINCIA_DOM, MAIL_PERSONA,
    TEL_RES, FAX_RES, SESSO, COMUNE_NASCITA, DATA_NASCITA, TEL_DOM, FAX_DOM, CF_NULLABLE,
    AMMIN, DESCRIZIONE_AMM, AOO, DESCRIZIONE_AOO, DESCRIZIONE_UO, COD_AMM, COD_AMM_ORIGINALE, COD_AOO, COD_AOO_ORIGINALE, COD_UO, COD_UO_ORIGINALE,
    DATI_AMM, DATI_AOO, DATI_UO, NI_AMM, DAL_AMM, TIPO, INDIRIZZO_AMM, CAP_AMM, COMUNE_AMM, SIGLA_PROV_AMM, MAIL_AMM, FAX_AMM,
    INDIRIZZO_AOO, CAP_AOO, COMUNE_AOO, SIGLA_PROV_AOO, MAIL_AOO, FAX_AOO, INDIRIZZO_UO, CAP_UO, COMUNE_UO, SIGLA_PROV_UO, MAIL_UO, TEL_UO, FAX_UO,
    CF_BENEFICIARIO, DENOMINAZIONE_BENEFICIARIO, PI_BENEFICIARIO, COMUNE_BENEFICIARIO, INDIRIZZO_BENEFICIARIO, CAP_BENEFICIARIO, DATA_NASCITA_BENEFICIARIO,
    PROVINCIA_BENEFICIARIO, VIS_INDIRIZZO, MAIL_BENEFICIARIO, FAX_BENEFICIARIO,
    NI_IMPRESA, IMPRESA, DENOMINAZIONE_SEDE, NATURA_GIURIDICA, INSEGNA, C_FISCALE_IMPRESA, PARTITA_IVA_IMPRESA, TIPO_LOCALIZZAZIONE, COMUNE, C_VIA_IMPRESA,
    VIA_IMPRESA, N_CIVICO_IMPRESA, COMUNE_IMPRESA, CAP_IMPRESA, MAIL_IMPRESA, CF_ESTERO,
    NI_GSD, NI_DIPENDENTE, DAL_DIPENDENTE, COGNOME_DIPENDENTE, NOME_DIPENDENTE, CODICE_FISCALE_DIPENDENTE, INDIRIZZO_RES_DIPENDENTE, COMUNE_RES_DIPENDENTE,
    PROVINCIA_RES_DIPENDENTE, CAP_RES_DIPENDENTE, INDIRIZZO_DOM_DIPENDENTE, COMUNE_DOM_DIPENDENTE, PROVINCIA_DOM_DIPENDENTE, CAP_DOM_DIPENDENTE, MAIL_DIPENDENTE,
    ID_TIPO_RECAPITO, DESCRIZIONE_TIPO_RECAPITO, ID_RECAPITO, ID_CONTATTO, TIPO_SPEDIZIONE, ANAGRAFICA, TIPO_SOGGETTO
)
AS
SELECT anag.denominazione, DECODE(tico.tipo_spedizione, ''MAIL'', cont.valore, TO_CHAR(NULL)) email, DECODE(tico.tipo_spedizione, ''FAX'', cont.valore, TO_CHAR(NULL)) fax,
       partita_iva, codice_fiscale cf, partita_iva pi,
       reca.indirizzo||'' ''||DECODE(reca.cap,NULL, NULL,LPAD(TRIM (reca.cap), 5, ''0'')||'' '')
      ||DECODE(ad4_comuni.denominazione,NULL, NULL,ad4_comuni.denominazione||'' '')
      ||DECODE(ad4_province.sigla,NULL, '''',''(''||ad4_province.sigla||'')'') indirizzo, NULL denominazione_per_segnatura, cognome cognome_per_segnatura, nome nome_per_segnatura,
       reca.indirizzo||'' '' indirizzo_per_segnatura, ad4_comuni.denominazione comune_per_segnatura, reca.cap cap_per_segnatura, ad4_province.sigla provincia_per_segnatura,
       codice_fiscale cf_per_segnatura, anag.dal, anag.al, anag.ni ni_persona, TO_CHAR(anag.dal, ''dd/mm/yyyy'') dal_persona, TO_CHAR(anag.ni) ni, cognome, nome,
       reca.indirizzo indirizzo_res, reca.cap cap_res, ad4_comuni.denominazione comune_res, ad4_province.sigla provincia_res, codice_fiscale codice_fiscale,
       TO_CHAR(NULL) indirizzo_dom, TO_CHAR(NULL) comune_dom, TO_CHAR(NULL) cap_dom, TO_CHAR(NULL) provincia_dom, DECODE(tico.tipo_spedizione, ''MAIL'', cont.valore, TO_CHAR(NULL)) mail_persona,
       DECODE(tico.id_tipo_contatto, 1, cont.valore, TO_CHAR(NULL)) tel_res, DECODE(tico.tipo_spedizione, ''FAX'', cont.valore, TO_CHAR(NULL)) fax_res,
       sesso, comuni_nas.denominazione comune_nascita, TO_CHAR(data_nas, ''dd/mm/yyyy'') data_nascita, TO_CHAR(NULL) tel_dom, TO_CHAR(NULL) fax_dom,
       DECODE(tipo_soggetto,''x'', ''Y'',DECODE(NVL(para.valore, ''Y''),''N'', ''Y'',DECODE(partita_iva, NULL, ''N'', ''Y''))) cf_nullable,
       TO_CHAR(NULL) ammin, TO_CHAR(NULL) descrizione_amm, TO_CHAR(NULL) aoo, TO_CHAR(NULL) descrizione_aoo, TO_CHAR(NULL) descrizione_uo, TO_CHAR(NULL) cod_amm,
       TO_CHAR(NULL) cod_amm_originale, TO_CHAR(NULL) cod_aoo, TO_CHAR(NULL) cod_aoo_originale, TO_CHAR(NULL) cod_uo, TO_CHAR(NULL) cod_uo_originale,
       TO_CHAR(NULL) dati_amm, TO_CHAR(NULL) dati_aoo, TO_CHAR(NULL) dati_uo, TO_NUMBER(NULL) ni_amm, TO_CHAR(NULL)dal_amm, anag.tipo_soggetto tipo,
       TO_CHAR(NULL) indirizzo_amm, TO_CHAR(NULL) cap_amm, TO_CHAR(NULL) comune_amm, TO_CHAR(NULL) sigla_prov_amm, TO_CHAR(NULL) mail_amm, TO_CHAR(NULL) fax_amm,
       TO_CHAR(NULL) indirizzo_aoo, TO_CHAR(NULL) cap_aoo, TO_CHAR(NULL) comune_aoo, TO_CHAR(NULL) sigla_prov_aoo, TO_CHAR(NULL) mail_aoo, TO_CHAR(NULL) fax_aoo,
       TO_CHAR(NULL) indirizzo_uo, TO_CHAR(NULL) cap_uo, TO_CHAR(NULL) comune_uo, TO_CHAR(NULL) sigla_prov_uo, TO_CHAR(NULL) mail_uo, TO_CHAR(NULL) tel_uo, TO_CHAR(NULL) fax_uo,
       TO_CHAR(NULL) cf_beneficiario, TO_CHAR(NULL) denominazione_beneficiario, TO_CHAR(NULL) pi_beneficiario, TO_CHAR(NULL) comune_beneficiario,
       TO_CHAR(NULL) indirizzo_beneficiario, TO_CHAR(NULL) cap_beneficiario, TO_CHAR(NULL) data_nascita_beneficiario, TO_CHAR(NULL) provincia_beneficiario,
       TO_CHAR(NULL) vis_indirizzo, NULL mail_beneficiario, NULL fax_beneficiario,
       TO_NUMBER(NULL) ni_impresa, NULL impresa, NULL denominazione_sede, NULL natura_giuridica, NULL insegna, NULL c_fiscale_impresa, NULL partita_iva_impresa,
       NULL tipo_localizzazione, ad4_comuni.denominazione comune, NULL c_via_impresa, NULL via_impresa, NULL n_civico_impresa, NULL comune_impresa, NULL cap_impresa, NULL mail_impresa,
       CODICE_FISCALE_ESTERO cf_estero,
       TO_NUMBER(NULL) ni_gsd,
       TO_NUMBER(NULL) ni_dipendente, NULL dal_dipendente, NULL cognome_dipendente, NULL nome_dipendente, NULL codice_fiscale_dipendente, NULL indirizzo_res_dipendente,
       NULL comune_res_dipendente, NULL provincia_res_dipendente, NULL cap_res_dipendente, NULL indirizzo_dom_dipendente, NULL comune_dom_dipendente,
       NULL provincia_dom_dipendente, NULL cap_dom_dipendente, NULL mail_dipendente,
       reca.id_tipo_recapito, tire.descrizione descrizione_tipo_recapito, reca.id_recapito id_recapito, cont.id_contatto id_contatto,
       tico.tipo_spedizione, ''A'' anagrafica, 1 tipo_soggetto
  FROM as4_anagrafici     anag,
       as4_recapiti       reca,
       as4_tipi_recapito  tire,
       as4_contatti       cont,
       as4_tipi_contatto  tico,
       ad4_comuni         comuni_nas,
       ad4_province,
       ad4_comuni,
       parametri        para
 WHERE ((((NVL(LENGTH (codice_fiscale), 0) = 16
               OR NVL(LENGTH (codice_fiscale), 0) = 11
               OR NVL(LENGTH (partita_iva), 0) = 11)
                 OR (tipo_soggetto = ''x''))
              AND NVL(para.valore, ''Y'') = ''Y'')
          OR NVL(para.valore, ''Y'') = ''N'')
       AND anag.ni = reca.ni(+)
       AND reca.id_tipo_recapito = tire.id_tipo_recapito(+)
       AND reca.id_recapito = cont.id_recapito(+)
       AND cont.id_tipo_contatto = tico.id_tipo_contatto(+)
       AND cont.id_tipo_contatto(+) <> 1
       AND nvl(anag.al, trunc(sysdate)) >= trunc(sysdate)
       AND nvl(reca.al, trunc(sysdate)) >= trunc(sysdate)
       AND nvl(cont.al, trunc(sysdate)) >= trunc(sysdate)
       AND reca.provincia = AD4_comuni.PROVINCIA_stato(+)
       AND reca.comune = AD4_comuni.comune(+)
       AND ad4_comuni.provincia_stato = ad4_province.provincia(+)
       AND comuni_nas.comune(+) = comune_nas
       AND comuni_nas.provincia_stato(+) = provincia_nas
       AND para.tipo_modello = ''@agVar@''
       AND para.codice = ''ANA_FILTRO_1''
       AND NOT EXISTS
             (SELECT 1
                FROM so4_amministrazioni ammi
               WHERE ammi.ni = anag.ni)
       AND NOT EXISTS
             (SELECT 1
                FROM so4_soggetti_aoo aoo
               WHERE aoo.ni = anag.ni)
       AND NOT EXISTS
             (SELECT 1
                FROM so4_soggetti_unita soun
               WHERE soun.ni = anag.ni)
UNION
SELECT anag.denominazione, TO_CHAR (NULL) email, TO_CHAR (NULL) fax, partita_iva,
       codice_fiscale cf, partita_iva pi,
          reca.indirizzo||'' ''|| DECODE (reca.cap, NULL, NULL, LPAD (TRIM (reca.cap), 5, ''0'') || '' '')
       || DECODE (ad4_comuni.denominazione, NULL, NULL, ad4_comuni.denominazione || '' '')
       || DECODE (ad4_province.sigla, NULL, '''', ''('' || ad4_province.sigla || '')'') indirizzo,
       NULL denominazione_per_segnatura, cognome cognome_per_segnatura, nome nome_per_segnatura,
       reca.indirizzo || '' '' indirizzo_per_segnatura, ad4_comuni.denominazione comune_per_segnatura,
       reca.cap cap_per_segnatura, ad4_province.sigla provincia_per_segnatura,
       codice_fiscale cf_per_segnatura, anag.dal, anag.al, anag.ni ni_persona,
       TO_CHAR (anag.dal, ''dd/mm/yyyy'') dal_persona, TO_CHAR (anag.ni) ni, cognome, nome,
       reca.indirizzo indirizzo_res, reca.cap cap_res, ad4_comuni.denominazione comune_res,
       ad4_province.sigla provincia_res, codice_fiscale codice_fiscale,
       TO_CHAR (NULL) indirizzo_dom, TO_CHAR (NULL) comune_dom,
       TO_CHAR (NULL) cap_dom, TO_CHAR (NULL) provincia_dom,
       TO_CHAR (NULL) mail_persona, TO_CHAR (NULL) tel_res,
       TO_CHAR (NULL) fax_res, sesso, comuni_nas.denominazione comune_nascita,
       TO_CHAR (data_nas, ''dd/mm/yyyy'') data_nascita, TO_CHAR (NULL) tel_dom, TO_CHAR (NULL) fax_dom,
       DECODE (tipo_soggetto, ''x'', ''Y'', DECODE (NVL (para.valore, ''Y''), ''N'', ''Y'', DECODE (partita_iva, NULL, ''N'', ''Y''))) cf_nullable,
       TO_CHAR (NULL) ammin, TO_CHAR (NULL) descrizione_amm, TO_CHAR (NULL) aoo, TO_CHAR (NULL) descrizione_aoo, TO_CHAR (NULL) descrizione_uo,
       TO_CHAR (NULL) cod_amm, TO_CHAR (NULL) cod_amm_originale,
       TO_CHAR (NULL) cod_aoo, TO_CHAR (NULL) cod_aoo_originale, TO_CHAR (NULL) cod_uo, TO_CHAR (NULL) cod_uo_originale,
       TO_CHAR (NULL) dati_amm, TO_CHAR (NULL) dati_aoo, TO_CHAR (NULL) dati_uo,
       TO_NUMBER (NULL) ni_amm, TO_CHAR (NULL) dal_amm,
       anag.tipo_soggetto tipo, TO_CHAR (NULL) indirizzo_amm,  TO_CHAR (NULL) cap_amm,
       TO_CHAR (NULL) comune_amm,  TO_CHAR (NULL) sigla_prov_amm,
       TO_CHAR (NULL) mail_amm, TO_CHAR (NULL) fax_amm,
       TO_CHAR (NULL) indirizzo_aoo, TO_CHAR (NULL) cap_aoo, TO_CHAR (NULL) comune_aoo,
       TO_CHAR (NULL) sigla_prov_aoo, TO_CHAR (NULL) mail_aoo, TO_CHAR (NULL) fax_aoo,
       TO_CHAR (NULL) indirizzo_uo, TO_CHAR (NULL) cap_uo, TO_CHAR (NULL) comune_uo,
       TO_CHAR (NULL) sigla_prov_uo, TO_CHAR (NULL) mail_uo, TO_CHAR (NULL) tel_uo, TO_CHAR (NULL) fax_uo,
       TO_CHAR (NULL) cf_beneficiario, TO_CHAR (NULL) denominazione_beneficiario, TO_CHAR (NULL) pi_beneficiario,
       TO_CHAR (NULL) comune_beneficiario, TO_CHAR (NULL) indirizzo_beneficiario, TO_CHAR (NULL) cap_beneficiario,
       TO_CHAR (NULL) data_nascita_beneficiario, TO_CHAR (NULL) provincia_beneficiario,
       TO_CHAR (NULL) vis_indirizzo, NULL mail_beneficiario, NULL fax_beneficiario,
       TO_NUMBER (NULL) ni_impresa, NULL impresa,  NULL denominazione_sede, NULL natura_giuridica,
       NULL insegna, NULL c_fiscale_impresa, NULL partita_iva_impresa, NULL tipo_localizzazione,
       ad4_comuni.denominazione comune, NULL c_via_impresa, NULL via_impresa, NULL n_civico_impresa,
       NULL comune_impresa, NULL cap_impresa, NULL mail_impresa, CODICE_FISCALE_ESTERO cf_estero,
       TO_NUMBER (NULL) ni_gsd, TO_NUMBER (NULL) ni_dipendente, NULL dal_dipendente,
       NULL cognome_dipendente, NULL nome_dipendente, NULL codice_fiscale_dipendente,
       NULL indirizzo_res_dipendente, NULL comune_res_dipendente, NULL provincia_res_dipendente,
       NULL cap_res_dipendente, NULL indirizzo_dom_dipendente, NULL comune_dom_dipendente,
       NULL provincia_dom_dipendente, NULL cap_dom_dipendente, NULL mail_dipendente,
       reca.id_tipo_recapito, tire.descrizione descrizione_tipo_recapito, reca.id_recapito id_recapito,
       NULL id_contatto, NULL tipo_spedizione, ''A'' anagrafica, 1 tipo_soggetto
  FROM as4_anagrafici anag,
       as4_recapiti reca,
       as4_tipi_recapito tire,
       ad4_comuni comuni_nas,
       ad4_province,
       ad4_comuni,
       parametri para
 WHERE     (   (    (   (   NVL (LENGTH (codice_fiscale), 0) = 16
                         OR NVL (LENGTH (codice_fiscale), 0) = 11
                         OR NVL (LENGTH (partita_iva), 0) = 11)
                     OR (tipo_soggetto = ''x''))
                AND NVL (para.valore, ''Y'') = ''Y'')
            OR NVL (para.valore, ''Y'') = ''N'')
       AND anag.ni = reca.ni(+)
       AND reca.id_tipo_recapito = tire.id_tipo_recapito(+)
       AND NVL (anag.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE)
       AND NVL (reca.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE)
       AND NOT EXISTS
              (SELECT 1
                 FROM as4_contatti cont
                WHERE     cont.id_recapito(+) = reca.id_recapito
                      AND cont.id_tipo_contatto(+) <> 1
                      AND NVL (cont.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE))
       AND reca.provincia = AD4_comuni.PROVINCIA_stato(+)
       AND reca.comune = AD4_comuni.comune(+)
       AND ad4_comuni.provincia_stato = ad4_province.provincia(+)
       AND comuni_nas.comune(+) = comune_nas
       AND comuni_nas.provincia_stato(+) = provincia_nas
       AND para.tipo_modello = ''@agVar@''
       AND para.codice = ''ANA_FILTRO_1''
       AND NOT EXISTS
              (SELECT 1
                 FROM so4_amministrazioni ammi
                WHERE ammi.ni = anag.ni)
       AND NOT EXISTS
              (SELECT 1
                 FROM so4_soggetti_aoo aoo
                WHERE aoo.ni = anag.ni)
       AND NOT EXISTS
              (SELECT 1
                 FROM so4_soggetti_unita soun
                WHERE soun.ni = anag.ni)
UNION
SELECT anag.denominazione_ricerca, TO_CHAR(NULL) email, TO_CHAR(NULL) fax, partita_iva, codice_fiscale cf, partita_iva pi,
       reca.indirizzo||'' ''
      ||DECODE(reca.cap,NULL, NULL,LPAD(TRIM (reca.cap), 5, ''0'')||'' '')
      ||DECODE(ad4_comuni.denominazione,NULL, NULL,ad4_comuni.denominazione||'' '')
      ||DECODE(ad4_province.sigla,NULL, '''',''(''||ad4_province.sigla||'')'') indirizzo, NULL denominazione_per_segnatura,
       cognome cognome_per_segnatura, nome nome_per_segnatura, reca.indirizzo||'' '' indirizzo_per_segnatura, ad4_comuni.denominazione comune_per_segnatura,
       reca.cap cap_per_segnatura, ad4_province.sigla provincia_per_segnatura, codice_fiscale cf_per_segnatura,
       anag.dal, anag.al, anag.ni ni_persona, TO_CHAR(anag.dal, ''dd/mm/yyyy'') dal_persona, TO_CHAR(anag.ni) ni, cognome, nome,
       reca.indirizzo indirizzo_res, reca.cap cap_res, ad4_comuni.denominazione comune_res, ad4_province.sigla provincia_res, codice_fiscale codice_fiscale,
       TO_CHAR(NULL) indirizzo_dom, TO_CHAR(NULL) comune_dom, TO_CHAR(NULL) cap_dom, TO_CHAR(NULL) provincia_dom, TO_CHAR(NULL) mail_persona, TO_CHAR(NULL) tel_res, TO_CHAR(NULL) fax_res,
       sesso,
       comuni_nas.denominazione comune_nascita, TO_CHAR(data_nas, ''dd/mm/yyyy'') data_nascita,
       TO_CHAR(NULL) tel_dom, TO_CHAR(NULL) fax_dom, ''Y'' cf_nullable, TO_CHAR(NULL) ammin,
       DECODE(INSTR (anag.denominazione_ricerca, '':''),0, anag.denominazione_ricerca,
         SUBSTR (anag.denominazione_ricerca,1,INSTR (anag.denominazione_ricerca, '':'') - 1)) descrizione_amm,
       DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,anag.denominazione) aoo,
       DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,anag.denominazione) descrizione_aoo,
       DECODE(INSTR (anag.denominazione_ricerca, '':UO:''),0, NULL,anag.denominazione) descrizione_uo,
       UPPER(DECODE(INSTR (anag.denominazione_ricerca, '':''),0, anag.note,SUBSTR (anag.note, 1, INSTR (anag.note, '':'') - 1))) cod_amm,
       DECODE(INSTR (anag.denominazione_ricerca, '':''),0, anag.note,SUBSTR (anag.note, 1, INSTR (anag.note, '':'') - 1)) cod_amm_originale,
       UPPER(DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,SUBSTR (anag.note, INSTR (anag.note, '':'') + 1))) cod_aoo,
       DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,SUBSTR (anag.note, INSTR (anag.note, '':'') + 1)) cod_aoo_originale,
       UPPER(DECODE(INSTR (anag.denominazione_ricerca, '':UO:''),0, NULL,SUBSTR (anag.note,INSTR (anag.note,'':'',1,2)+ 1))) cod_uo,
       DECODE(INSTR (anag.denominazione_ricerca, '':UO:''),0, NULL,SUBSTR (anag.note,INSTR (anag.note,'':'',1,2)+ 1)) cod_uo_originale,
       TO_CHAR(NULL) dati_amm,
       TO_CHAR(NULL) dati_aoo,
       TO_CHAR(NULL) dati_uo,
       TO_NUMBER(NULL) ni_amm,
       TO_CHAR(NULL) dal_amm,
       anag.tipo_soggetto tipo,
       TO_CHAR(NULL) indirizzo_amm,
       TO_CHAR(NULL) cap_amm,
       TO_CHAR(NULL) comune_amm,
       TO_CHAR(NULL) sigla_prov_amm,
       TO_CHAR(NULL) mail_amm,
       TO_CHAR(NULL) fax_amm,
       TO_CHAR(NULL) indirizzo_aoo,
       TO_CHAR(NULL) cap_aoo,
       TO_CHAR(NULL) comune_aoo,
       TO_CHAR(NULL) sigla_prov_aoo,
       TO_CHAR(NULL) mail_aoo,
       TO_CHAR(NULL) fax_aoo,
       TO_CHAR(NULL) indirizzo_uo,
       TO_CHAR(NULL) cap_uo,
       TO_CHAR(NULL) comune_uo,
       TO_CHAR(NULL) sigla_prov_uo,
       TO_CHAR(NULL) mail_uo,
       TO_CHAR(NULL) tel_uo,
       TO_CHAR(NULL) fax_uo,
       TO_CHAR(NULL) cf_beneficiario,
       TO_CHAR(NULL) denominazione_beneficiario,
       TO_CHAR(NULL) pi_beneficiario,
       TO_CHAR(NULL) comune_beneficiario,
       TO_CHAR(NULL) indirizzo_beneficiario,
       TO_CHAR(NULL) cap_beneficiario,
       TO_CHAR(NULL) data_nascita_beneficiario,
       TO_CHAR(NULL) provincia_beneficiario,
       TO_CHAR(NULL) vis_indirizzo,
       NULL mail_beneficiario,
       NULL fax_beneficiario,
       TO_NUMBER(NULL) ni_impresa,
       NULL impresa,
       NULL denominazione_sede,
       NULL natura_giuridica,
       NULL insegna,
       NULL c_fiscale_impresa,
       NULL partita_iva_impresa,
       NULL tipo_localizzazione,
       ad4_comuni.denominazione comune,
       NULL c_via_impresa,
       NULL via_impresa,
       NULL n_civico_impresa,
       NULL comune_impresa,
       NULL cap_impresa,
       NULL mail_impresa,
       CODICE_FISCALE_ESTERO cf_estero,
       TO_NUMBER(NULL) ni_gsd,
       TO_NUMBER(NULL) ni_dipendente,
       NULL dal_dipendente,
       NULL cognome_dipendente,
       NULL nome_dipendente,
       NULL codice_fiscale_dipendente,
       NULL indirizzo_res_dipendente,
       NULL comune_res_dipendente,
       NULL provincia_res_dipendente,
       NULL cap_res_dipendente,
       NULL indirizzo_dom_dipendente,
       NULL comune_dom_dipendente,
       NULL provincia_dom_dipendente,
       NULL cap_dom_dipendente,
       NULL mail_dipendente,
       reca.id_tipo_recapito,
       tire.descrizione descrizione_tipo_recapito,
       RECA.ID_RECAPITO,
       TO_NUMBER(NULL) ID_CONTATTO,
       TO_CHAR(NULL) tipo_spedizione,
       ''S'' anagrafica,
       2 tipo_soggetto
  FROM as4_anagrafici     anag,
       as4_recapiti       reca,
       as4_tipi_recapito  tire,
       ad4_comuni         comuni_nas,
       ad4_province,
       ad4_comuni
 WHERE anag.ni = reca.ni
       AND reca.id_tipo_recapito = tire.id_tipo_recapito
       AND nvl(anag.al, trunc(sysdate)) >= trunc(sysdate)
       AND nvl(reca.al, trunc(sysdate)) >= trunc(sysdate)
       AND reca.provincia = AD4_comuni.PROVINCIA_stato(+)
       AND reca.comune = AD4_comuni.comune(+)
       AND ad4_comuni.provincia_stato = ad4_province.provincia(+)
       AND comuni_nas.comune(+) = comune_nas
       AND comuni_nas.provincia_stato(+) = provincia_nas
       AND NOT EXISTS
             (SELECT 1
                FROM as4_contatti, as4_tipi_contatto
               WHERE as4_contatti.id_recapito = reca.id_recapito
                   AND as4_contatti.id_tipo_contatto =
                 as4_tipi_contatto.id_tipo_contatto
                   AND as4_tipi_contatto.tipo_spedizione = ''MAIL''
                   AND nvl(as4_contatti.al, trunc(sysdate)) >= trunc(sysdate))
       AND ((EXISTS
              (SELECT 1
                 FROM so4_amministrazioni ammi
                WHERE ammi.ni = anag.ni)
              AND NOT EXISTS
              (SELECT 1
                 FROM SEG_AMM_AOO_UO_TAB
                WHERE NI_AMM = ANAG.NI
                    AND SEG_AMM_AOO_UO_TAB.TIPO = ''AMM''
                    AND nvl(SEG_AMM_AOO_UO_TAB.al, trunc(sysdate)) >= trunc(sysdate)
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.INDIRIZZO_PER_SEGNATURA,
                              '' '')) =
                        UPPER(NVL(reca.indirizzo, '' ''))
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.CAP_PER_SEGNATURA,
                              '' '')) =
                        UPPER(NVL(reca.cap, '' ''))
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.COMUNE_PER_SEGNATURA,
                              '' '')) =
                        UPPER(
                          NVL(ad4_comuni.denominazione, '' ''))
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.PROVINCIA_PER_SEGNATURA,
                              '' '')) =
                        UPPER(NVL(ad4_province.sigla, '' ''))))
          OR (EXISTS
              (SELECT 1
                 FROM so4_soggetti_aoo aoo
                WHERE aoo.ni = anag.ni)
              AND NOT EXISTS
              (SELECT 1
                 FROM SEG_AMM_AOO_UO_TAB
                WHERE SEG_AMM_AOO_UO_TAB.COD_AMM_ORIGINALE
                       ||'':''
                       ||SEG_AMM_AOO_UO_TAB.COD_AOO_ORIGINALE =
                        ANAG.NOTE
                    AND nvl(SEG_AMM_AOO_UO_TAB.al, trunc(sysdate)) >= trunc(sysdate)
                    AND SEG_AMM_AOO_UO_TAB.TIPO = ''AOO''
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.INDIRIZZO_PER_SEGNATURA,
                              '' '')) =
                        UPPER(NVL(reca.indirizzo, '' ''))
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.CAP_PER_SEGNATURA,
                              '' '')) =
                        UPPER(NVL(reca.cap, '' ''))
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.COMUNE_PER_SEGNATURA,
                              '' '')) =
                        UPPER(
                          NVL(ad4_comuni.denominazione, '' ''))
                    AND UPPER(
                          NVL(
                              SEG_AMM_AOO_UO_TAB.PROVINCIA_PER_SEGNATURA,
                              '' '')) =
                        UPPER(NVL(ad4_province.sigla, '' ''))))
          OR     (EXISTS
              (SELECT 1
                 FROM so4_soggetti_unita soun
                WHERE soun.ni = anag.ni))
             AND NOT EXISTS
                   (SELECT 1
                FROM SEG_AMM_AOO_UO_TAB
               WHERE SEG_AMM_AOO_UO_TAB.COD_AMM_ORIGINALE
                      ||'':''
                      ||SEG_AMM_AOO_UO_TAB.COD_AOO_ORIGINALE
                      ||'':''
                      ||SEG_AMM_AOO_UO_TAB.COD_UO_ORIGINALE =
                       ANAG.NOTE
                   AND nvl(SEG_AMM_AOO_UO_TAB.al, trunc(sysdate)) >= trunc(sysdate)
                   AND SEG_AMM_AOO_UO_TAB.TIPO = ''UO''
                   AND UPPER(
                         NVL(
                             SEG_AMM_AOO_UO_TAB.INDIRIZZO_PER_SEGNATURA,
                             '' '')) =
                       UPPER(NVL(reca.indirizzo, '' ''))
                   AND UPPER(
                         NVL(
                             SEG_AMM_AOO_UO_TAB.CAP_PER_SEGNATURA,
                             '' '')) =
                       UPPER(NVL(reca.cap, '' ''))
                   AND UPPER(
                         NVL(
                             SEG_AMM_AOO_UO_TAB.COMUNE_PER_SEGNATURA,
                             '' '')) =
                       UPPER(
                         NVL(ad4_comuni.denominazione, '' ''))
                   AND UPPER(
                         NVL(
                             SEG_AMM_AOO_UO_TAB.PROVINCIA_PER_SEGNATURA,
                             '' '')) =
                       UPPER(NVL(ad4_province.sigla, '' ''))))
UNION
SELECT anag.denominazione_ricerca,
       DECODE(tico.tipo_spedizione, ''MAIL'', cont.valore, TO_CHAR(NULL)) email,
       DECODE(tico.tipo_spedizione, ''FAX'', cont.valore, TO_CHAR(NULL)) fax,
       partita_iva,
       codice_fiscale cf,
       partita_iva pi,
        reca.indirizzo||'' ''||DECODE(reca.cap,NULL, NULL,LPAD(TRIM (reca.cap), 5, ''0'')||'' '')
      ||DECODE(ad4_comuni.denominazione,NULL, NULL,ad4_comuni.denominazione||'' '')
      ||DECODE(ad4_province.sigla,NULL, '''',''(''||ad4_province.sigla||'')'') indirizzo,
       NULL denominazione_per_segnatura,
       cognome cognome_per_segnatura,
       nome nome_per_segnatura,
       reca.indirizzo||'' '' indirizzo_per_segnatura,
       ad4_comuni.denominazione comune_per_segnatura,
       reca.cap cap_per_segnatura,
       ad4_province.sigla provincia_per_segnatura,
       codice_fiscale cf_per_segnatura,
       anag.dal,
       anag.al,
       anag.ni ni_persona,
       TO_CHAR(anag.dal, ''dd/mm/yyyy'') dal_persona,
       TO_CHAR(anag.ni) ni,
       cognome,
       nome,
       reca.indirizzo indirizzo_res,
       reca.cap cap_res,
       ad4_comuni.denominazione comune_res,
       ad4_province.sigla provincia_res,
       codice_fiscale codice_fiscale,
       TO_CHAR(NULL) indirizzo_dom,
       TO_CHAR(NULL) comune_dom,
       TO_CHAR(NULL) cap_dom,
       TO_CHAR(NULL) provincia_dom,
       DECODE(tico.tipo_spedizione, ''MAIL'', cont.valore, TO_CHAR(NULL)) mail_persona,
       DECODE(tico.id_tipo_contatto, 1, cont.valore, TO_CHAR(NULL)) tel_res,
       DECODE(tico.tipo_spedizione, ''FAX'', cont.valore, TO_CHAR(NULL)) fax_res,
       sesso,
       comuni_nas.denominazione comune_nascita,
       TO_CHAR(data_nas, ''dd/mm/yyyy'') data_nascita,
       TO_CHAR(NULL) tel_dom,
       TO_CHAR(NULL) fax_dom,
       ''Y'' cf_nullable,
       TO_CHAR(NULL) ammin,
       DECODE(INSTR (anag.denominazione_ricerca, '':''),0, anag.denominazione_ricerca,SUBSTR (anag.denominazione_ricerca,1,INSTR (anag.denominazione_ricerca, '':'') - 1)) descrizione_amm,
       DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,anag.denominazione) aoo,
       DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,anag.denominazione) descrizione_aoo,
       DECODE(INSTR (anag.denominazione_ricerca, '':UO:''),0, NULL,anag.denominazione) descrizione_uo,
       UPPER(DECODE(INSTR (anag.denominazione_ricerca, '':''),0, anag.note,SUBSTR (anag.note, 1, INSTR (anag.note, '':'') - 1))) cod_amm,
       DECODE(INSTR (anag.denominazione_ricerca, '':''),0, anag.note,SUBSTR (anag.note, 1, INSTR (anag.note, '':'') - 1)) cod_amm_originale,
       UPPER(DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,SUBSTR (anag.note, INSTR (anag.note, '':'') + 1))) cod_aoo,
       DECODE(INSTR (anag.denominazione_ricerca, '':AOO:''),0, NULL,SUBSTR (anag.note, INSTR (anag.note, '':'') + 1)) cod_aoo_originale,
       UPPER(DECODE(INSTR (anag.denominazione_ricerca, '':UO:''),0, NULL,SUBSTR (anag.note,INSTR (anag.note,'':'',1,2)+ 1))) cod_uo,
       DECODE(INSTR (anag.denominazione_ricerca, '':UO:''),0, NULL,SUBSTR (anag.note,INSTR (anag.note,'':'',1,2)+ 1)) cod_uo_originale,
       TO_CHAR(NULL) dati_amm,
       TO_CHAR(NULL) dati_aoo,
       TO_CHAR(NULL) dati_uo,
       TO_NUMBER(NULL) ni_amm,
       TO_CHAR(NULL) dal_amm,
       anag.tipo_soggetto tipo,
       TO_CHAR(NULL) indirizzo_amm,
       TO_CHAR(NULL) cap_amm,
       TO_CHAR(NULL) comune_amm,
       TO_CHAR(NULL) sigla_prov_amm,
       TO_CHAR(NULL) mail_amm,
       TO_CHAR(NULL) fax_amm,
       TO_CHAR(NULL) indirizzo_aoo,
       TO_CHAR(NULL) cap_aoo,
       TO_CHAR(NULL) comune_aoo,
       TO_CHAR(NULL) sigla_prov_aoo,
       TO_CHAR(NULL) mail_aoo,
       TO_CHAR(NULL) fax_aoo,
       TO_CHAR(NULL) indirizzo_uo,
       TO_CHAR(NULL) cap_uo,
       TO_CHAR(NULL) comune_uo,
       TO_CHAR(NULL) sigla_prov_uo,
       TO_CHAR(NULL) mail_uo,
       TO_CHAR(NULL) tel_uo,
       TO_CHAR(NULL) fax_uo,
       TO_CHAR(NULL) cf_beneficiario,
       TO_CHAR(NULL) denominazione_beneficiario,
       TO_CHAR(NULL) pi_beneficiario,
       TO_CHAR(NULL) comune_beneficiario,
       TO_CHAR(NULL) indirizzo_beneficiario,
       TO_CHAR(NULL) cap_beneficiario,
       TO_CHAR(NULL) data_nascita_beneficiario,
       TO_CHAR(NULL) provincia_beneficiario,
       TO_CHAR(NULL) vis_indirizzo,
       NULL mail_beneficiario,
       NULL fax_beneficiario,
       TO_NUMBER(NULL) ni_impresa,
       NULL impresa,
       NULL denominazione_sede,
       NULL natura_giuridica,
       NULL insegna,
       NULL c_fiscale_impresa,
       NULL partita_iva_impresa,
       NULL tipo_localizzazione,
       ad4_comuni.denominazione comune,
       NULL c_via_impresa,
       NULL via_impresa,
       NULL n_civico_impresa,
       NULL comune_impresa,
       NULL cap_impresa,
       NULL mail_impresa,
       CODICE_FISCALE_ESTERO cf_estero,
       TO_NUMBER(NULL) ni_gsd,
       TO_NUMBER(NULL) ni_dipendente,
       NULL dal_dipendente,
       NULL cognome_dipendente,
       NULL nome_dipendente,
       NULL codice_fiscale_dipendente,
       NULL indirizzo_res_dipendente,
       NULL comune_res_dipendente,
       NULL provincia_res_dipendente,
       NULL cap_res_dipendente,
       NULL indirizzo_dom_dipendente,
       NULL comune_dom_dipendente,
       NULL provincia_dom_dipendente,
       NULL cap_dom_dipendente,
       NULL mail_dipendente,
       reca.id_tipo_recapito,
       tire.descrizione descrizione_tipo_recapito,
       RECA.ID_RECAPITO,
       CONT.ID_CONTATTO,
       tico.tipo_spedizione,
       ''S'' anagrafica,
       2 tipo_soggetto
  FROM as4_anagrafici     anag,
       as4_recapiti       reca,
       as4_tipi_recapito  tire,
       as4_contatti       cont,
       as4_tipi_contatto  tico,
       ad4_comuni         comuni_nas,
       ad4_province,
       ad4_comuni
 WHERE anag.ni = reca.ni
       AND reca.id_tipo_recapito = tire.id_tipo_recapito
       AND reca.id_recapito = cont.id_recapito
       AND cont.id_tipo_contatto = tico.id_tipo_contatto
       AND tico.tipo_spedizione = ''MAIL''
       AND nvl(anag.al, trunc(sysdate)) >= trunc(sysdate)
       AND nvl(reca.al, trunc(sysdate)) >= trunc(sysdate)
       AND nvl(cont.al, trunc(sysdate)) >= trunc(sysdate)
       AND reca.provincia = AD4_comuni.PROVINCIA_stato(+)
       AND reca.comune = AD4_comuni.comune(+)
       AND ad4_comuni.provincia_stato = ad4_province.provincia(+)
       AND comuni_nas.comune(+) = comune_nas
       AND comuni_nas.provincia_stato(+) = provincia_nas
       AND ((EXISTS
              (SELECT 1
                 FROM so4_amministrazioni ammi
                WHERE ammi.ni = anag.ni)
              AND NOT EXISTS
              (SELECT 1
                 FROM SEG_AMM_AOO_UO_TAB
                WHERE NI_AMM = ANAG.NI
                    AND SEG_AMM_AOO_UO_TAB.TIPO = ''AMM''
                    AND nvl(SEG_AMM_AOO_UO_TAB.al, trunc(sysdate)) >= trunc(sysdate)
                    AND UPPER(SEG_AMM_AOO_UO_TAB.EMAIL) =
                        UPPER(cont.valore)))
          OR (EXISTS
              (SELECT 1
                 FROM so4_soggetti_aoo aoo
                WHERE aoo.ni = anag.ni)
              AND NOT EXISTS
              (SELECT 1
                 FROM SEG_AMM_AOO_UO_TAB
                WHERE SEG_AMM_AOO_UO_TAB.COD_AMM
                       ||'':''
                       ||SEG_AMM_AOO_UO_TAB.COD_AOO =
                        UPPER(ANAG.NOTE)
                    AND nvl(SEG_AMM_AOO_UO_TAB.al, trunc(sysdate)) >= trunc(sysdate)
                    AND SEG_AMM_AOO_UO_TAB.TIPO = ''AOO''
                    AND UPPER(SEG_AMM_AOO_UO_TAB.EMAIL) =
                        UPPER(cont.valore)))
          OR (EXISTS
              (SELECT 1
                 FROM so4_soggetti_unita uo
                WHERE uo.ni = anag.ni)
              AND NOT EXISTS
              (SELECT 1
                 FROM SEG_AMM_AOO_UO_TAB
                WHERE SEG_AMM_AOO_UO_TAB.COD_AMM
                       ||'':''
                       ||SEG_AMM_AOO_UO_TAB.COD_AOO
                       ||'':''
                       ||SEG_AMM_AOO_UO_TAB.COD_UO =
                        UPPER(ANAG.NOTE)
                    AND nvl(SEG_AMM_AOO_UO_TAB.al, trunc(sysdate)) >= trunc(sysdate)
                    AND SEG_AMM_AOO_UO_TAB.TIPO = ''UO''
                    AND UPPER(SEG_AMM_AOO_UO_TAB.EMAIL) =
                        UPPER(cont.valore))))';
      integrityPackage.LOG (
         '-------------------- SEG_ANAGRAFICI_AS4_NUOVO --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;

      d_statement :=
            'CREATE OR REPLACE FORCE VIEW seg_anagrafici '
         || 'AS '
         || 'SELECT denominazione, email, fax, partita_iva, cf, pi, indirizzo, '
         || 'denominazione_per_segnatura, cognome_per_segnatura, '
         || 'nome_per_segnatura, indirizzo_per_segnatura, comune_per_segnatura, '
         || 'cap_per_segnatura, provincia_per_segnatura, cf_per_segnatura, dal, '
         || 'al, ni_persona, dal_persona, ni, cognome, nome, indirizzo_res, '
         || 'cap_res, comune_res, provincia_res, codice_fiscale, indirizzo_dom, '
         || 'comune_dom, cap_dom, provincia_dom, mail_persona, tel_res, fax_res, '
         || 'sesso, comune_nascita, data_nascita, tel_dom, fax_dom, cf_nullable, '
         || 'ammin, descrizione_amm, aoo, descrizione_aoo, descrizione_uo, '
         || 'cod_amm, '
         || 'cod_amm_originale, '
         || 'cod_aoo, '
         || 'cod_aoo_originale, '
         || 'cod_uo, '
         || 'cod_uo_originale, '
         || 'dati_amm, dati_aoo, dati_uo, '
         || 'ni_amm, dal_amm, tipo, '
         || 'indirizzo_amm, cap_amm, comune_amm, sigla_prov_amm, mail_amm, fax_amm, '
         || 'indirizzo_aoo, cap_aoo, comune_aoo, sigla_prov_aoo, mail_aoo, fax_aoo, '
         || 'indirizzo_uo, cap_uo, comune_uo, sigla_prov_uo, mail_uo, tel_uo, fax_uo,'
         || 'cf_beneficiario, '
         || 'denominazione_beneficiario, pi_beneficiario, comune_beneficiario, '
         || 'indirizzo_beneficiario, cap_beneficiario, data_nascita_beneficiario, '
         || 'provincia_beneficiario, vis_indirizzo, mail_beneficiario, fax_beneficiario, '
         || 'ni_impresa, impresa, '
         || 'denominazione_sede, natura_giuridica, insegna, c_fiscale_impresa, '
         || 'partita_iva_impresa, tipo_localizzazione, comune, c_via_impresa, '
         || 'via_impresa, n_civico_impresa, comune_impresa, cap_impresa, mail_impresa, '
         || 'ni_gsd, '
         || 'ni_dipendente, dal_dipendente, cognome_dipendente, nome_dipendente,'
         || 'codice_fiscale_dipendente,'
         || 'indirizzo_res_dipendente, comune_res_dipendente, provincia_res_dipendente, cap_res_dipendente,'
         || 'indirizzo_dom_dipendente, comune_dom_dipendente, provincia_dom_dipendente, cap_dom_dipendente,'
         || 'mail_dipendente,'
         || 'id_tipo_recapito,'
         || 'descrizione_tipo_recapito,'
         || 'tipo_spedizione,'
         || 'sogg.cf_estero,'
         || 'anagrafica, sogg.tipo_soggetto, '
         || 'ag_tipi_soggetto.descrizione|| DECODE (anagrafica, ''ST'', '' Indice Regionale'', NULL)    desc_tipo_soggetto '
         || 'FROM seg_anagrafici_as4 sogg, ag_tipi_soggetto '
         || ' WHERE sogg.tipo_soggetto = ag_tipi_soggetto.tipo_soggetto(+) '
         || 'UNION ALL '
         || 'SELECT denominazione, email, fax, partita_iva, cf, pi, indirizzo, '
         || 'denominazione_per_segnatura, cognome_per_segnatura, '
         || 'nome_per_segnatura, indirizzo_per_segnatura, comune_per_segnatura, '
         || 'cap_per_segnatura, provincia_per_segnatura, cf_per_segnatura, dal, '
         || 'al, ni_persona, dal_persona, ni, cognome, nome, indirizzo_res, '
         || 'cap_res, comune_res, provincia_res, codice_fiscale, indirizzo_dom, '
         || 'comune_dom, cap_dom, provincia_dom, mail_persona, tel_res, fax_res, '
         || 'sesso, comune_nascita, data_nascita, tel_dom, fax_dom, cf_nullable, '
         || 'ammin, descrizione_amm, aoo, descrizione_aoo, descrizione_uo, '
         || 'cod_amm, '
         || 'cod_amm_originale, '
         || 'cod_aoo, '
         || 'cod_aoo_originale, '
         || 'cod_uo, '
         || 'cod_uo_originale, '
         || 'dati_amm, dati_aoo, dati_uo, '
         || 'ni_amm, dal_amm, tipo, '
         || 'indirizzo_amm, cap_amm, comune_amm, sigla_prov_amm, mail_amm, fax_amm, '
         || 'indirizzo_aoo, cap_aoo, comune_aoo, sigla_prov_aoo, mail_aoo, fax_aoo, '
         || 'indirizzo_uo, cap_uo, comune_uo, sigla_prov_uo, mail_uo, tel_uo, fax_uo,'
         || 'cf_beneficiario, '
         || 'denominazione_beneficiario, pi_beneficiario, comune_beneficiario, '
         || 'indirizzo_beneficiario, cap_beneficiario, data_nascita_beneficiario, '
         || 'provincia_beneficiario, vis_indirizzo, mail_beneficiario, fax_beneficiario, '
         || 'ni_impresa, impresa, '
         || 'denominazione_sede, natura_giuridica, insegna, c_fiscale_impresa, '
         || 'partita_iva_impresa, tipo_localizzazione, comune, c_via_impresa, '
         || 'via_impresa, n_civico_impresa, comune_impresa, cap_impresa, mail_impresa, '
         || 'ni_gsd, '
         || 'ni_dipendente, dal_dipendente, cognome_dipendente, nome_dipendente,'
         || 'codice_fiscale_dipendente,'
         || 'indirizzo_res_dipendente, comune_res_dipendente, provincia_res_dipendente, cap_res_dipendente,'
         || 'indirizzo_dom_dipendente, comune_dom_dipendente, provincia_dom_dipendente, cap_dom_dipendente,'
         || 'mail_dipendente,'
         || 'id_tipo_recapito,'
         || 'descrizione_tipo_recapito,'
         || 'tipo_spedizione,'
         || 'sogg.cf_estero,'
         || 'anagrafica, sogg.tipo_soggetto, '
         || 'ag_tipi_soggetto.descrizione||decode(anagrafica, ''ST'', '' Indice Regionale'', null) desc_tipo_soggetto '
         || 'FROM seg_anagrafici_so4 sogg, ag_tipi_soggetto '
         || ' WHERE sogg.tipo_soggetto = ag_tipi_soggetto.tipo_soggetto(+) '
         || 'UNION ALL '
         || 'SELECT denominazione, email, fax, partita_iva, cf, pi, indirizzo, '
         || 'denominazione_per_segnatura, cognome_per_segnatura, '
         || 'nome_per_segnatura, indirizzo_per_segnatura, comune_per_segnatura, '
         || 'cap_per_segnatura, provincia_per_segnatura, cf_per_segnatura, dal, '
         || 'al, ni_persona, dal_persona, ni, cognome, nome, indirizzo_res, '
         || 'cap_res, comune_res, provincia_res, codice_fiscale, indirizzo_dom, '
         || 'comune_dom, cap_dom, provincia_dom, mail_persona, tel_res, fax_res, '
         || 'sesso, comune_nascita, data_nascita, tel_dom, fax_dom, cf_nullable, '
         || 'ammin, descrizione_amm, aoo, descrizione_aoo, descrizione_uo, '
         || 'cod_amm, '
         || 'cod_amm_originale, '
         || 'cod_aoo, '
         || 'cod_aoo_originale, '
         || 'cod_uo, '
         || 'cod_uo_originale, '
         || 'dati_amm, dati_aoo, dati_uo, '
         || 'ni_amm, dal_amm, tipo, '
         || 'indirizzo_amm, cap_amm, comune_amm, sigla_prov_amm, mail_amm, fax_amm, '
         || 'indirizzo_aoo, cap_aoo, comune_aoo, sigla_prov_aoo, mail_aoo, fax_aoo, '
         || 'indirizzo_uo, cap_uo, comune_uo, sigla_prov_uo, mail_uo, tel_uo, fax_uo,'
         || 'cf_beneficiario, '
         || 'denominazione_beneficiario, pi_beneficiario, comune_beneficiario, '
         || 'indirizzo_beneficiario, cap_beneficiario, data_nascita_beneficiario, '
         || 'provincia_beneficiario, vis_indirizzo, mail_beneficiario, fax_beneficiario, '
         || 'ni_impresa, impresa, '
         || 'denominazione_sede, natura_giuridica, insegna, c_fiscale_impresa, '
         || 'partita_iva_impresa, tipo_localizzazione, comune, c_via_impresa, '
         || 'via_impresa, n_civico_impresa, comune_impresa, cap_impresa, mail_impresa, '
         || 'ni_gsd, '
         || 'ni_dipendente, dal_dipendente, cognome_dipendente, nome_dipendente,'
         || 'codice_fiscale_dipendente,'
         || 'indirizzo_res_dipendente, comune_res_dipendente, provincia_res_dipendente, cap_res_dipendente,'
         || 'indirizzo_dom_dipendente, comune_dom_dipendente, provincia_dom_dipendente, cap_dom_dipendente,'
         || 'mail_dipendente,'
         || 'id_tipo_recapito,'
         || 'descrizione_tipo_recapito,'
         || 'tipo_spedizione,'
         || 'sogg.cf_estero,'
         || 'anagrafica, sogg.tipo_soggetto, '
         || 'ag_tipi_soggetto.descrizione desc_tipo_soggetto '
         || 'FROM seg_soggetti_mv sogg, ag_tipi_soggetto '
         || ' WHERE sogg.tipo_soggetto = ag_tipi_soggetto.tipo_soggetto(+) ';
      integrityPackage.LOG (
         '-------------------- SEG_ANAGRAFICI --------------------');
      integrityPackage.LOG (d_statement);

      EXECUTE IMMEDIATE d_statement;
   END;
END;
/
