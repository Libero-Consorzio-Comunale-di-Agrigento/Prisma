--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_SOGGETTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_soggetto
IS
   TYPE sogg_refcursor IS REF CURSOR;

   /******************************************************************************
   NOME:        AG_SOGGETTO
   DESCRIZIONE: Package per gestione SOGGETTI.
   L'inizializzione del soggetto avviene tramite selezione da
   SOGGETTI; quest'ultima puo' essere una table od una vista sull'
   anagrafica di riferimento.
   ECCEZIONI:.
   REVISIONI:
   Rev. Data       Autore        Descrizione
   ---- ---------- ------------- ------------------------------------------------------
   0    04/05/2005 SC            Prima emissione.
   1    13/08/2009 MMalferrari   Modificato nome da SOGGETTO ad AG_SOGGETTO e
                                 create get_denominazione.
   2    12/12/2017 MMalferrari   Creata definizione ESISTE_ANAGRAFICI_PKG
   ******************************************************************************/
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_provincia (
      p_denominazione   IN ad4_province.denominazione%TYPE)
      RETURN ad4_province.provincia%TYPE;

   FUNCTION get_provincia (p_sigla IN ad4_province.sigla%TYPE)
      RETURN ad4_province.provincia%TYPE;

   FUNCTION get_comune (
      p_denominazione     IN     ad4_comuni.denominazione%TYPE,
      p_cap               IN OUT as4_anagrafe_soggetti.cap_res%TYPE,
      p_sigla_provincia   IN OUT ad4_province.sigla%TYPE)
      RETURN ad4_comuni.comune%TYPE;

   FUNCTION get_comune (
      p_denominazione     IN     ad4_comuni.denominazione%TYPE,
      p_cap               IN OUT as4_anagrafe_soggetti.cap_res%TYPE,
      p_sigla_provincia   IN OUT ad4_province.sigla%TYPE,
      p_provincia         IN OUT ad4_province.provincia%TYPE)
      RETURN ad4_comuni.comune%TYPE;

   FUNCTION esiste (
      p_codice_fiscale       as4_anagrafe_soggetti.codice_fiscale%TYPE,
      p_ni               OUT as4_anagrafe_soggetti.ni%TYPE)
      RETURN NUMBER;

   FUNCTION esiste (p_denominazione       VARCHAR2,
                    p_ni              OUT as4_anagrafe_soggetti.ni%TYPE)
      RETURN NUMBER;

   FUNCTION esiste (p_indirizzo_web       VARCHAR2,
                    p_denominazione       VARCHAR2,
                    p_ni              OUT as4_anagrafe_soggetti.ni%TYPE)
      RETURN NUMBER;

   FUNCTION esiste (p_indirizzo_web       VARCHAR2,
                    p_cognome             as4_anagrafe_soggetti.cognome%TYPE,
                    p_nome                as4_anagrafe_soggetti.nome%TYPE,
                    p_ni              OUT as4_anagrafe_soggetti.ni%TYPE)
      RETURN NUMBER;

   FUNCTION esiste (p_cognome       as4_anagrafe_soggetti.cognome%TYPE,
                    p_nome          as4_anagrafe_soggetti.nome%TYPE,
                    p_ni        OUT as4_anagrafe_soggetti.ni%TYPE)
      RETURN NUMBER;

   FUNCTION get_nome (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_cognome (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_denominazione (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_denominazione (p_codice_utente IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_sesso (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_codice_fiscale (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_indirizzo (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_indirizzo_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_cap (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_cap_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_dal (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_comune (p_soggetto IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_comune_dom (p_soggetto IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_competenza (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_competenza_esclusiva (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_des_comune (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_des_comune_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_provincia (p_soggetto IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_provincia_dom (p_soggetto IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_des_provincia (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_des_provincia_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_provincia_sigla (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_provincia_sigla_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_indirizzo_completo (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_data_nascita (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_comune_nas (p_soggetto IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_des_comune_nas (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_provincia_nas (p_soggetto IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_des_provincia_nas (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_provincia_nas_sigla (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_telefono (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_telefono_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_indirizzo_web (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_note (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_utente_aggiornamento (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_data_aggiornamento (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_fax (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_fax_dom (p_soggetto IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE set_nome (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_cognome (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_sesso (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_codice_fiscale (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_partita_iva (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_indirizzo (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_indirizzo_dom (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_cap (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_cap_dom (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_provincia (p_soggetto IN NUMBER, p_valore IN NUMBER);

   PROCEDURE set_provincia (p_soggetto IN NUMBER, p_sigla IN VARCHAR2);

   PROCEDURE set_comune (p_soggetto IN NUMBER, p_valore IN NUMBER);

   PROCEDURE set_comune (p_soggetto IN NUMBER, p_comune_des IN VARCHAR2);

   PROCEDURE set_provincia_nas (p_soggetto IN NUMBER, p_valore IN NUMBER);

   PROCEDURE set_comune_nas (p_soggetto IN NUMBER, p_valore IN NUMBER);

   PROCEDURE set_comune_nas (p_soggetto IN NUMBER, p_comune_den IN VARCHAR2);

   PROCEDURE set_provincia_dom (p_soggetto IN NUMBER, p_valore IN NUMBER);

   PROCEDURE set_provincia_dom (p_soggetto IN NUMBER, p_sigla IN VARCHAR2);

   PROCEDURE set_comune_dom (p_soggetto IN NUMBER, p_valore IN NUMBER);

   PROCEDURE set_comune_dom (p_soggetto IN NUMBER, p_comune_den IN VARCHAR2);

   PROCEDURE set_data_nascita (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_dal (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_telefono (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_telefono_dom (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_fax (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_fax_dom (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_indirizzo_web (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_note (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_competenza (p_soggetto IN NUMBER, p_valore IN VARCHAR2);

   PROCEDURE set_competenza_esclusiva (p_soggetto   IN NUMBER,
                                       p_valore     IN VARCHAR2);

   PROCEDURE update_soggetto (
      p_soggetto         IN OUT as4_anagrafe_soggetti.ni%TYPE,
      p_dal              IN OUT VARCHAR2,
      p_cognome          IN     as4_anagrafe_soggetti.cognome%TYPE,
      p_nome             IN     as4_anagrafe_soggetti.nome%TYPE DEFAULT NULL,
      p_sesso            IN     as4_anagrafe_soggetti.sesso%TYPE DEFAULT NULL,
      p_data_nascita     IN     VARCHAR2 DEFAULT NULL,
      p_provincia_nas    IN     as4_anagrafe_soggetti.provincia_nas%TYPE DEFAULT NULL,
      p_comune_nas       IN     as4_anagrafe_soggetti.comune_nas%TYPE DEFAULT NULL,
      p_codice_fiscale   IN     as4_anagrafe_soggetti.codice_fiscale%TYPE DEFAULT NULL,
      p_partita_iva      IN     as4_anagrafe_soggetti.partita_iva%TYPE DEFAULT NULL,
      p_indirizzo        IN     as4_anagrafe_soggetti.indirizzo_res%TYPE DEFAULT NULL,
      p_provincia        IN     as4_anagrafe_soggetti.provincia_res%TYPE DEFAULT NULL,
      p_comune           IN     as4_anagrafe_soggetti.comune_res%TYPE DEFAULT NULL,
      p_cap              IN     as4_anagrafe_soggetti.cap_res%TYPE DEFAULT NULL,
      p_tel              IN     as4_anagrafe_soggetti.tel_res%TYPE DEFAULT NULL,
      p_fax              IN     as4_anagrafe_soggetti.fax_res%TYPE DEFAULT NULL,
      p_presso           IN     as4_anagrafe_soggetti.presso%TYPE DEFAULT NULL,
      p_indirizzo_dom    IN     as4_anagrafe_soggetti.indirizzo_dom%TYPE DEFAULT NULL,
      p_provincia_dom    IN     as4_anagrafe_soggetti.provincia_dom%TYPE DEFAULT NULL,
      p_comune_dom       IN     as4_anagrafe_soggetti.comune_dom%TYPE DEFAULT NULL,
      p_cap_dom          IN     as4_anagrafe_soggetti.cap_dom%TYPE DEFAULT NULL,
      p_tel_dom          IN     as4_anagrafe_soggetti.tel_dom%TYPE DEFAULT NULL,
      p_fax_dom          IN     as4_anagrafe_soggetti.fax_dom%TYPE DEFAULT NULL,
      p_indirizzo_web    IN     as4_anagrafe_soggetti.indirizzo_web%TYPE DEFAULT NULL,
      p_note             IN     as4_anagrafe_soggetti.note%TYPE DEFAULT NULL,
      p_competenza       IN     as4_anagrafe_soggetti.competenza%TYPE DEFAULT NULL,
      p_comp_escl        IN     as4_anagrafe_soggetti.competenza_esclusiva%TYPE DEFAULT NULL,
      p_utente           IN     as4_anagrafe_soggetti.utente%TYPE DEFAULT NULL,
      p_modifica         IN     VARCHAR2 DEFAULT 'T',
      p_batch            IN     NUMBER DEFAULT 0);

   PROCEDURE update_soggetto (
      p_soggetto              IN OUT as4_anagrafe_soggetti.ni%TYPE,
      p_dal                   IN OUT VARCHAR2,
      p_cognome               IN     as4_anagrafe_soggetti.cognome%TYPE,
      p_nome                  IN     as4_anagrafe_soggetti.nome%TYPE DEFAULT NULL,
      p_sesso                 IN     as4_anagrafe_soggetti.sesso%TYPE DEFAULT NULL,
      p_data_nascita          IN     VARCHAR2 DEFAULT NULL,
      p_sigla_provincia_nas   IN     VARCHAR2 DEFAULT NULL,
      p_den_comune_nas        IN     VARCHAR2 DEFAULT NULL,
      p_codice_fiscale        IN     as4_anagrafe_soggetti.codice_fiscale%TYPE DEFAULT NULL,
      p_partita_iva           IN     as4_anagrafe_soggetti.partita_iva%TYPE DEFAULT NULL,
      p_indirizzo             IN     as4_anagrafe_soggetti.indirizzo_res%TYPE DEFAULT NULL,
      p_sigla_provincia       IN     VARCHAR2 DEFAULT NULL,
      p_den_comune            IN     VARCHAR2 DEFAULT NULL,
      p_cap                   IN     as4_anagrafe_soggetti.cap_res%TYPE DEFAULT NULL,
      p_tel                   IN     as4_anagrafe_soggetti.tel_res%TYPE DEFAULT NULL,
      p_fax                   IN     as4_anagrafe_soggetti.fax_res%TYPE DEFAULT NULL,
      p_presso                IN     as4_anagrafe_soggetti.presso%TYPE DEFAULT NULL,
      p_indirizzo_dom         IN     as4_anagrafe_soggetti.indirizzo_dom%TYPE DEFAULT NULL,
      p_sigla_provincia_dom   IN     VARCHAR2 DEFAULT NULL,
      p_den_comune_dom        IN     VARCHAR2 DEFAULT NULL,
      p_cap_dom               IN     as4_anagrafe_soggetti.cap_dom%TYPE DEFAULT NULL,
      p_tel_dom               IN     as4_anagrafe_soggetti.tel_dom%TYPE DEFAULT NULL,
      p_fax_dom               IN     as4_anagrafe_soggetti.fax_dom%TYPE DEFAULT NULL,
      p_indirizzo_web         IN     as4_anagrafe_soggetti.indirizzo_web%TYPE DEFAULT NULL,
      p_note                  IN     as4_anagrafe_soggetti.note%TYPE DEFAULT NULL,
      p_competenza            IN     as4_anagrafe_soggetti.competenza%TYPE DEFAULT NULL,
      p_comp_escl             IN     as4_anagrafe_soggetti.competenza_esclusiva%TYPE DEFAULT NULL,
      p_utente                IN     as4_anagrafe_soggetti.utente%TYPE DEFAULT NULL,
      p_modifica              IN     VARCHAR2 DEFAULT 'T',
      p_batch                 IN     NUMBER DEFAULT 0);

   FUNCTION ESISTE_ANAGRAFICI_PKG
      RETURN NUMBER;
END ag_soggetto;
/
CREATE OR REPLACE PACKAGE BODY ag_soggetto
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
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Creazione.
 1    14/09/2008 Snegroni     Richiami al package anzichè modifiche diretta a
                              ANAGRAFE_SOGGETTI
 2    03/08/2009  MMalferrari Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
 3    13/08/2009  MMalferrari Modificato nome da SOGGETTO ad AG_SOGGETTO e
                              create get_denominazione.
 4    24/01/2012  MMalferrari ModificatA UPD_SOGGETTO.
 5    23/03/2012  MMalferrari ModificatA UPD_SOGGETTO.
 6    12/12/2017  MMalferrari Modificata versione per modifiche 3.1.1
******************************************************************************/
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'V2.6';
   END versione;

   FUNCTION ESISTE_ANAGRAFICI_PKG
      RETURN NUMBER
   IS
   ret number := 0;
   BEGIN
      SELECT DISTINCT 1
        INTO ret
        FROM ALL_SYNONYMS
       WHERE SYNONYM_NAME = 'AS4_ANAGRAFICI_PKG';
      RETURN ret;
   EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
   END;
   FUNCTION get_provincia (p_denominazione IN ad4_province.denominazione%TYPE)
      RETURN ad4_province.provincia%TYPE
   IS
/******************************************************************************
 NOME:        GET_PROVINCIA.
 DESCRIZIONE: Restituisce il codice della provincia
 PARAMETRI:
 RITORNA:
 ECCEZIONI:
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 1    03/05/2005 SC    Prima emissione.
******************************************************************************/
      d_ritorno   ad4_province.provincia%TYPE;
   BEGIN
      SELECT provincia
        INTO d_ritorno
        FROM ad4_province
       WHERE denominazione = UPPER (p_denominazione);

      RETURN d_ritorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_provincia;

   FUNCTION get_provincia (p_sigla IN ad4_province.sigla%TYPE)
      RETURN ad4_province.provincia%TYPE
   IS
/******************************************************************************
 NOME:        GET_PROVINCIA.
 DESCRIZIONE: Restituisce il codice della provincia
 PARAMETRI:
 RITORNA:
 ECCEZIONI:
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 1    03/05/2005 SC    Prima emissione.
******************************************************************************/
      d_ritorno   ad4_province.provincia%TYPE;
   BEGIN
      SELECT provincia
        INTO d_ritorno
        FROM ad4_province
       WHERE sigla = p_sigla;

      RETURN d_ritorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_provincia;

   FUNCTION get_comune (
      p_denominazione     IN       ad4_comuni.denominazione%TYPE,
      p_cap               IN OUT   as4_anagrafe_soggetti.cap_res%TYPE,
      p_sigla_provincia   IN OUT   ad4_province.sigla%TYPE
   )
      RETURN ad4_comuni.comune%TYPE
   IS
/******************************************************************************
 NOME:        GET_COMUNE.
 DESCRIZIONE: Restituisce il codice del COMUNE.
 PARAMETRI:
 RITORNA:
 ECCEZIONI:
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 1    03/05/2005 SC    Prima emissione.
      04/08/2005 SC    Deve usare AS4_ANAGRAFE_SOGGETTI.CAP_RES%TYPE perchè
                      il type di ad4_comuni.cap è sbagliato, è un NUMBER.
******************************************************************************/
      d_ritorno   ad4_comuni.comune%TYPE;
   BEGIN
      d_ritorno := ad4_comune.get_comune (p_denominazione, p_sigla_provincia);

      IF p_cap IS NULL
      THEN
         p_cap := ad4_comune.get_cap (p_denominazione, p_sigla_provincia);
      END IF;

      RETURN d_ritorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_comune;

   FUNCTION get_comune (
      p_denominazione     IN       ad4_comuni.denominazione%TYPE,
      p_cap               IN OUT   as4_anagrafe_soggetti.cap_res%TYPE,
      p_sigla_provincia   IN OUT   ad4_province.sigla%TYPE,
      p_provincia         IN OUT   ad4_province.provincia%TYPE
   )
      RETURN ad4_comuni.comune%TYPE
   IS
/******************************************************************************
 NOME:        GET_COMUNE.
 DESCRIZIONE: Restituisce il codice del COMUNE.
 PARAMETRI:
 RITORNA:
 ECCEZIONI:
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 1    03/05/2005 SC    Prima emissione.
      04/08/2005 SC    Deve usare AS4_ANAGRAFE_SOGGETTI.CAP_RES%TYPE perchè
                      il type di ad4_comuni.cap è sbagliato, è un NUMBER.
******************************************************************************/
      d_ritorno   ad4_comuni.comune%TYPE;
   BEGIN
      d_ritorno := get_comune (p_denominazione, p_cap, p_sigla_provincia);

      IF p_sigla_provincia IS NOT NULL
      THEN
         p_provincia :=
            ad4_provincia.get_provincia (p_denominazione      => NULL,
                                         p_sigla              => p_sigla_provincia
                                        );
      END IF;

      RETURN d_ritorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION esiste (
      p_codice_fiscale         as4_anagrafe_soggetti.codice_fiscale%TYPE,
      p_ni               OUT   as4_anagrafe_soggetti.ni%TYPE
   )
/******************************************************************************
 NOME:        ESISTE
 DESCRIZIONE: Verifica se esiste un soggetto VALIDO con codice_fiscale o partita_iva
              uguale a p_codice_fiscale.
 PARAMETRI:   --
 RITORNA:      1 Esiste
               0 Non esiste
           -1 Errore
 ECCEZIONI:   --
 NOTE:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    06/02/2006 SC     Creazione.
******************************************************************************/
   RETURN NUMBER
   IS
      d_esiste   NUMBER := 0;
   BEGIN
      SELECT 1, ni
        INTO d_esiste, p_ni
        FROM as4_soggetti
       WHERE codice_fiscale = p_codice_fiscale;

      RETURN d_esiste;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            SELECT 1, ni
              INTO d_esiste, p_ni
              FROM as4_soggetti
             WHERE partita_iva = p_codice_fiscale;

            RETURN d_esiste;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN 0;
            WHEN OTHERS
            THEN
               RETURN -1;
         END;
      WHEN OTHERS
      THEN
         RETURN -1;
   END esiste;

   FUNCTION esiste (
      p_denominazione         VARCHAR2,
      p_ni              OUT   as4_anagrafe_soggetti.ni%TYPE
   )
/******************************************************************************
 NOME:        ESISTE
 DESCRIZIONE: Verifica se esiste un soggetto VALIDO con denominazione passata.
 PARAMETRI:   --
 RITORNA:      > 0 Numero totale soggetti che soddisfano le condizioni di ricerca.
               0 Non esiste
           -1 Errore
 ECCEZIONI:   --
 NOTE:        Se un solo soggetto soddisfa le condizioni, ne restituisce l'ni in p_ni.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    06/02/2006 SC     Creazione.
******************************************************************************/
   RETURN NUMBER
   IS
      d_esiste   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO d_esiste
           FROM as4_soggetti
          WHERE cognome || DECODE (nome, NULL, '', ' ' || nome) =
                                                       UPPER (p_denominazione);
      EXCEPTION
         WHEN OTHERS
         THEN
            d_esiste := -1;
      END;

      IF d_esiste = 1
      THEN
         BEGIN
            SELECT ni
              INTO p_ni
              FROM as4_soggetti
             WHERE cognome || DECODE (nome, NULL, '', ' ' || nome) =
                                                       UPPER (p_denominazione);
         EXCEPTION
            WHEN OTHERS
            THEN
               d_esiste := -1;
         END;
      END IF;

      RETURN d_esiste;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END esiste;

   FUNCTION esiste (
      p_indirizzo_web         VARCHAR2,
      p_denominazione         VARCHAR2,
      p_ni              OUT   as4_anagrafe_soggetti.ni%TYPE
   )
/******************************************************************************
 NOME:        ESISTE
 DESCRIZIONE: Verifica se esiste un soggetto VALIDO con con indirizzo_web e
              denominazione passati.
 PARAMETRI:   --
 RITORNA:      > 0 Numero totale soggetti che soddisfano le condizioni di ricerca.
               0 Non esiste
           -1 Errore
 ECCEZIONI:   --
 NOTE:        Se un solo soggetto soddisfa le condizioni, ne restituisce l'ni in p_ni.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    06/02/2006 SC     Creazione.
******************************************************************************/
   RETURN NUMBER
   IS
      d_esiste   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO d_esiste
           FROM as4_anagrafe_soggetti
          WHERE denominazione = UPPER (p_denominazione)
            AND al IS NULL
            AND LOWER (indirizzo_web) = LOWER (p_indirizzo_web);
      EXCEPTION
         WHEN OTHERS
         THEN
            d_esiste := -1;
      END;

      IF d_esiste = 1
      THEN
         BEGIN
            SELECT ni
              INTO p_ni
              FROM as4_anagrafe_soggetti
             WHERE denominazione = UPPER (p_denominazione)
               AND al IS NULL
               AND LOWER (indirizzo_web) = LOWER (p_indirizzo_web);
         EXCEPTION
            WHEN OTHERS
            THEN
               d_esiste := -1;
         END;
      END IF;

      RETURN d_esiste;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END esiste;

   FUNCTION esiste (
      p_indirizzo_web         VARCHAR2,
      p_cognome               as4_anagrafe_soggetti.cognome%TYPE,
      p_nome                  as4_anagrafe_soggetti.nome%TYPE,
      p_ni              OUT   as4_anagrafe_soggetti.ni%TYPE
   )
/******************************************************************************
 NOME:        ESISTE
 DESCRIZIONE: Verifica se esiste un soggetto VALIDO con indirizzo_web passato
              e cognome/nome uguali.
 PARAMETRI:   --
 RITORNA:
               Numero di omonimi Esiste
               0 Non esiste
           -1 Errore
 ECCEZIONI:  Se c'e' un solo soggetto che soddisfa le condizioni di ricerca, in
             p_ni ne restituisce ni.
 NOTE:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    06/02/2006 SC     Creazione.
******************************************************************************/
   RETURN NUMBER
   IS
      d_esiste   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO d_esiste
           FROM as4_soggetti
          WHERE cognome = UPPER (p_cognome)
            AND NVL (nome, '*') = NVL (p_nome, '*')
            AND LOWER (indirizzo_web) = LOWER (p_indirizzo_web);
      EXCEPTION
         WHEN OTHERS
         THEN
            d_esiste := -1;
      END;

      IF d_esiste = 1
      THEN
         BEGIN
            SELECT ni
              INTO p_ni
              FROM as4_soggetti
             WHERE cognome = UPPER (p_cognome)
               AND NVL (nome, '*') = NVL (p_nome, '*')
               AND LOWER (indirizzo_web) = LOWER (p_indirizzo_web);
         EXCEPTION
            WHEN OTHERS
            THEN
               d_esiste := -1;
         END;
      END IF;

      RETURN d_esiste;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END esiste;

   FUNCTION esiste (
      p_cognome         as4_anagrafe_soggetti.cognome%TYPE,
      p_nome            as4_anagrafe_soggetti.nome%TYPE,
      p_ni        OUT   as4_anagrafe_soggetti.ni%TYPE
   )
/******************************************************************************
 NOME:        ESISTE
 DESCRIZIONE: Verifica se esiste un soggetto VALIDO con cognome/nome passati.
 PARAMETRI:   --
 RITORNA:      1 Esiste
               0 Non esiste
           -1 Errore
 ECCEZIONI:   --
 NOTE:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 0    06/02/2006 SC     Creazione.
******************************************************************************/
   RETURN NUMBER
   IS
      d_esiste   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO d_esiste
           FROM as4_soggetti
          WHERE cognome = UPPER (p_cognome)
            AND NVL (nome, '*') = NVL (p_nome, '*');
      EXCEPTION
         WHEN OTHERS
         THEN
            d_esiste := -1;
      END;

      IF d_esiste = 1
      THEN
         BEGIN
            SELECT ni
              INTO p_ni
              FROM as4_soggetti
             WHERE cognome = UPPER (p_cognome)
               AND NVL (nome, '*') = NVL (p_nome, '*');
         EXCEPTION
            WHEN OTHERS
            THEN
               d_esiste := -1;
         END;
      END IF;

      RETURN d_esiste;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;
   END esiste;

   FUNCTION get_nome
/******************************************************************************
 NOME:        GET_NOME.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il nome.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_nome   as4_soggetti.nome%TYPE;
   BEGIN
      SELECT nome
        INTO d_nome
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_nome;
   END get_nome;

   FUNCTION get_cognome
/******************************************************************************
 NOME:        GET_COGNOME.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il cognome.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_cognome   as4_soggetti.cognome%TYPE;
   BEGIN
      SELECT cognome
        INTO d_cognome
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_cognome;
   END get_cognome;

   function get_denominazione
/******************************************************************************
 NOME:        GET_DENOMINAZIONE.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la denominazione.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 3    13/08/2009 MMalferrari  Prima emissione.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
   return varchar2
   is
      d_denominazione   as4_anagrafe_soggetti.denominazione%TYPE;
   BEGIN
      SELECT denominazione
        INTO d_denominazione
        FROM as4_anagrafe_soggetti
       WHERE ni = p_soggetto
         and al is null;

      RETURN d_denominazione;
   end;

   function get_denominazione
/******************************************************************************
 NOME:        GET_DENOMINAZIONE.
 DESCRIZIONE: Dato l'utente recupera la denominazione del soggetto associato.
 ARGOMENTI:   p_utente:   codice utente.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 3    13/08/2009 MMalferrari  Prima emissione.
******************************************************************************/
   (
      p_codice_utente in varchar2
   )
   return varchar2
   is
      d_return varchar2(4000):= null;
      d_soggetto number;
   begin
      if p_codice_utente is not null then
         d_soggetto := ad4_utente.GET_SOGGETTO(p_codice_utente, 'Y', 0);
         if d_soggetto is not null then
            d_return := ad4_soggetto.GET_DENOMINAZIONE(d_soggetto, 'Y');
         else
            d_return := ad4_utente.GET_NOMINATIVO(p_codice_utente, 'Y', 0);
         end if;

         if d_return is null then
            d_return := p_codice_utente;
         end if;
      end if;
      return d_return;
   end;

   FUNCTION get_sesso
/******************************************************************************
 NOME:        GET_SESSO.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il sesso
              (F / M).
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_sesso   as4_soggetti.sesso%TYPE;
   BEGIN
      SELECT sesso
        INTO d_sesso
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_sesso;
   END get_sesso;

   FUNCTION get_codice_fiscale
/******************************************************************************
 NOME:        GET_CODICE_FISCALE.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              fiscale.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_codice_fiscale   as4_soggetti.codice_fiscale%TYPE;
   BEGIN
      SELECT codice_fiscale
        INTO d_codice_fiscale
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_codice_fiscale;
   END get_codice_fiscale;

   FUNCTION get_indirizzo
/******************************************************************************
 NOME:        GET_INDIRIZZO.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera l'indirizzo.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_indirizzo   as4_soggetti.indirizzo_res%TYPE;
   BEGIN
      SELECT indirizzo_res
        INTO d_indirizzo
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_indirizzo;
   END get_indirizzo;

   FUNCTION get_indirizzo_dom
/******************************************************************************
 NOME:        GET_INDIRIZZO_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera l'indirizzo
              del domicilio.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_indirizzo   as4_soggetti.indirizzo_dom%TYPE;
   BEGIN
      SELECT indirizzo_dom
        INTO d_indirizzo
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_indirizzo;
   END get_indirizzo_dom;

   FUNCTION get_cap
/******************************************************************************
 NOME:        GET_CAP.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il CAP di
              residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER)
      RETURN VARCHAR2
   IS
      d_cap   as4_soggetti.cap_res%TYPE;
   BEGIN
      SELECT cap_res
        INTO d_cap
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_cap;
   END get_cap;

   FUNCTION get_cap_dom
/******************************************************************************
 NOME:        GET_CAP_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il CAP di
              domicilio.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_cap   as4_soggetti.cap_dom%TYPE;
   BEGIN
      SELECT cap_dom
        INTO d_cap
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_cap;
   END get_cap_dom;

   FUNCTION get_dal
/******************************************************************************
 NOME:        GET_DAL.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera valore di dal corrente.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER)
      RETURN VARCHAR2
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      SELECT dal
        INTO d_dal
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_dal;
   END get_dal;

   FUNCTION get_comune
/******************************************************************************
 NOME:        GET_COMUNE.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              del comune di residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN NUMBER
   IS
      d_comune   as4_soggetti.comune_res%TYPE;
   BEGIN
      SELECT comune_res
        INTO d_comune
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_comune;
   END get_comune;

   FUNCTION get_comune_dom
/******************************************************************************
 NOME:        GET_COMUNE_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              del comune di domicilio.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN NUMBER
   IS
      d_comune   as4_soggetti.comune_dom%TYPE;
   BEGIN
      SELECT comune_dom
        INTO d_comune
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_comune;
   END get_comune_dom;

   FUNCTION get_competenza
/******************************************************************************
 NOME:        GET_COMPETENZA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera
              il valore del campo COMPETENZA.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_competenza   as4_soggetti.competenza%TYPE;
   BEGIN
      SELECT competenza
        INTO d_competenza
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_competenza;
   END get_competenza;

   FUNCTION get_competenza_esclusiva
/******************************************************************************
 NOME:        GET_COMPETENZA_ESCLUSIVA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera
              il valore del campo COMPETENZA_ESCLUSIVA.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_comp_escl   as4_soggetti.competenza_esclusiva%TYPE;
   BEGIN
      SELECT competenza_esclusiva
        INTO d_comp_escl
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_comp_escl;
   END get_competenza_esclusiva;

   FUNCTION get_des_comune
/******************************************************************************
 NOME:        GET_DES_COMUNE.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              denominazione del comune di residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT comuni.denominazione
           INTO d_return
           FROM ad4_comuni comuni, as4_soggetti sogg
          WHERE comuni.comune = sogg.comune_res
            AND comuni.provincia_stato = sogg.provincia_res
            AND sogg.ni = p_soggetto;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_des_comune;

   FUNCTION get_des_comune_dom
/******************************************************************************
 NOME:        GET_DES_COMUNE_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              denominazione del comune di residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT comuni.denominazione
           INTO d_return
           FROM ad4_comuni comuni, as4_soggetti sogg
          WHERE comuni.comune = sogg.comune_dom
            AND comuni.provincia_stato = sogg.provincia_dom
            AND sogg.ni = p_soggetto;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_des_comune_dom;

   FUNCTION get_provincia
/******************************************************************************
 NOME:        GET_PROVINCIA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              della provincia di residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN NUMBER
   IS
      d_provincia   as4_soggetti.provincia_res%TYPE;
   BEGIN
      SELECT provincia_res
        INTO d_provincia
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_provincia;
   END get_provincia;

   FUNCTION get_provincia_dom
/******************************************************************************
 NOME:        GET_PROVINCIA_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              della provincia di domicilio.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN NUMBER
   IS
      d_provincia   as4_soggetti.provincia_dom%TYPE;
   BEGIN
      SELECT provincia_dom
        INTO d_provincia
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_provincia;
   END get_provincia_dom;

   FUNCTION get_des_provincia
/******************************************************************************
 NOME:        GET_DES_PROVINCIA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              denominazione della provincia di residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT province.denominazione
           INTO d_return
           FROM ad4_province province, as4_soggetti sogg
          WHERE province.provincia = sogg.provincia_res
            AND sogg.ni = p_soggetto;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_des_provincia;

   FUNCTION get_des_provincia_dom
/******************************************************************************
 NOME:        GET_DES_PROVINCIA_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              denominazione della provincia di domicilio.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT province.denominazione
           INTO d_return
           FROM ad4_province province, as4_soggetti sogg
          WHERE province.provincia = sogg.provincia_dom
            AND sogg.ni = p_soggetto;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_des_provincia_dom;

   FUNCTION get_provincia_sigla
/******************************************************************************
 NOME:        GET_PROVINCIA_SIGLA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              sigla della provincia di residenza.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT province.sigla
           INTO d_return
           FROM ad4_province province, as4_soggetti sogg
          WHERE province.provincia = sogg.provincia_res
            AND sogg.ni = p_soggetto;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_provincia_sigla;

   FUNCTION get_provincia_sigla_dom
/******************************************************************************
 NOME:        GET_PROVINCIA_SIGLA_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              sigla della provincia di domicilio.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT province.sigla
           INTO d_return
           FROM ad4_province province, as4_soggetti sogg
          WHERE province.provincia = sogg.provincia_dom
            AND sogg.ni = p_soggetto;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_provincia_sigla_dom;

   FUNCTION get_indirizzo_completo
/******************************************************************************
 NOME:        GET_INDIRIZZO_COMPLETO.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera l'indirizzo
              di residenza completo di cap, comune e sigla della provincia.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT    sogg.indirizzo_res
                || DECODE (sogg.cap_res, NULL, '', ' - ' || sogg.cap_res)
                || DECODE (sogg.comune_res,
                           NULL, '',
                              ' '
                           || comuni.denominazione
                           || DECODE (sogg.provincia_res,
                                      NULL, '',
                                      ' (' || province.sigla || ')'
                                     )
                          )
           INTO d_return
           FROM ad4_comuni comuni, ad4_province province, as4_soggetti sogg
          WHERE sogg.ni = p_soggetto
            AND comuni.comune(+) = sogg.comune_res
            AND comuni.provincia_stato(+) = sogg.provincia_res
            AND province.provincia(+) = sogg.provincia_res;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_indirizzo_completo;

   FUNCTION get_data_nascita
/******************************************************************************
 NOME:        GET_DATA_NASCITA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la data di
              nascita (come stringa in formato dd/mm/yyyy).
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_data_nascita   as4_soggetti.data_nas%TYPE;
   BEGIN

      SELECT data_nas
        INTO d_data_nascita
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_data_nascita;
   END get_data_nascita;

   FUNCTION get_comune_nas
/******************************************************************************
 NOME:        GET_COMUNE_NAS.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              del comune di nascita.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN NUMBER
   IS
      d_comune_nas   as4_soggetti.comune_nas%TYPE;
   BEGIN
      SELECT comune_nas
        INTO d_comune_nas
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_comune_nas;
   END get_comune_nas;

   FUNCTION get_des_comune_nas
/******************************************************************************
 NOME:        GET_DES_COMUNE_NAS.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              denominazione del comune di nascita.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT comuni.denominazione
           INTO d_return
           FROM ad4_comuni comuni, as4_soggetti sogg
          WHERE sogg.ni = p_soggetto
            AND comuni.comune = sogg.comune_nas
            AND comuni.provincia_stato = sogg.provincia_nas;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_des_comune_nas;

   FUNCTION get_provincia_nas
/******************************************************************************
 NOME:        GET_PROVINCIA_NAS.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              della provincia di nascita.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN NUMBER
   IS
      d_provincia_nas   as4_soggetti.provincia_nas%TYPE;
   BEGIN
      SELECT provincia_nas
        INTO d_provincia_nas
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_provincia_nas;
   END get_provincia_nas;

   FUNCTION get_des_provincia_nas
/******************************************************************************
 NOME:        GET_DES_PROVINCIA_NAS.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              denominazione della provincia di nascita.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT province.denominazione
           INTO d_return
           FROM ad4_province province, as4_soggetti sogg
          WHERE sogg.ni = p_soggetto
            AND province.provincia = sogg.provincia_nas;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_des_provincia_nas;

   FUNCTION get_provincia_nas_sigla
/******************************************************************************
 NOME:        GET_PROVINCIA_NAS_SIGLA.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la
              sigla della provincia di nascita.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
      BEGIN
         SELECT province.sigla
           INTO d_return
           FROM ad4_province province, as4_soggetti sogg
          WHERE sogg.ni = p_soggetto
            AND province.provincia = sogg.provincia_nas;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := TO_CHAR (NULL);
      END;

      RETURN d_return;
   END get_provincia_nas_sigla;

   FUNCTION get_telefono
/******************************************************************************
 NOME:        GET_TELEFONO.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il numero
              di telefono (come stringa).
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_telefono   as4_soggetti.tel_res%TYPE;
   BEGIN
      SELECT tel_res
        INTO d_telefono
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_telefono;
   END get_telefono;

   FUNCTION get_telefono_dom
/******************************************************************************
 NOME:        GET_TELEFONO_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il numero
              di telefono del domicilio(come stringa).
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_telefono   as4_soggetti.tel_dom%TYPE;
   BEGIN
      SELECT tel_dom
        INTO d_telefono
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_telefono;
   END get_telefono_dom;

   FUNCTION get_indirizzo_web
/******************************************************************************
 NOME:        GET_INDIRIZZO_WEB.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera l'indirizzo
              web.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_indirizzo_web   as4_soggetti.indirizzo_web%TYPE;
   BEGIN
      SELECT indirizzo_web
        INTO d_indirizzo_web
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_indirizzo_web;
   END get_indirizzo_web;

   FUNCTION get_note
/******************************************************************************
 NOME:        GET_NOTE.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera le note.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_note   as4_soggetti.note%TYPE;
   BEGIN
      SELECT note
        INTO d_note
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_note;
   END get_note;

   FUNCTION get_utente_aggiornamento
/******************************************************************************
 NOME:        GET_UTENTE_AGGIORNAMENTO.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il codice
              dell'utente che ha effettuato le ultime modifiche al soggetto.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_utente_agg   as4_soggetti.utente%TYPE;
   BEGIN
      SELECT utente
        INTO d_utente_agg
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_utente_agg;
   END get_utente_aggiornamento;

   FUNCTION get_data_aggiornamento
/******************************************************************************
 NOME:        GET_DATA_AGGIORNAMENTO.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera la data in
              cui sono state effettuate le ultime modifiche al soggetto.
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_data_agg   as4_soggetti.data_agg%TYPE;
   BEGIN
      SELECT data_agg
        INTO d_data_agg
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_data_agg;
   END get_data_aggiornamento;

   FUNCTION get_fax
/******************************************************************************
 NOME:        GET_FAX.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il numero
              di fax (come stringa).
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER)
      RETURN VARCHAR2
   IS
      d_fax   as4_soggetti.fax_res%TYPE;
   BEGIN
      SELECT fax_res
        INTO d_fax
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_fax;
   END get_fax;

   FUNCTION get_fax_dom
/******************************************************************************
 NOME:        GET_FAX_DOM.
 DESCRIZIONE: Dato il numero identificativo del soggetto, recupera il numero
              di fax del domicilio(come stringa).
 ARGOMENTI:   p_soggetto:   numero identificativo del soggetto.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      d_fax   as4_soggetti.fax_dom%TYPE;
   BEGIN
      SELECT fax_dom
        INTO d_fax
        FROM as4_soggetti
       WHERE ni = p_soggetto;

      RETURN d_fax;
   END get_fax_dom;


   PROCEDURE set_nome
/******************************************************************************
 NOME:        SET_NOME.
 DESCRIZIONE: Modifica l'attributo NOME del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_nome (p_ni         => p_soggetto,
                                          p_dal        => d_dal,
                                          p_value      => p_valore
                                         );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
                    (-20999,
                     'E'' stato inserito un valore scorretto nel campo NOME.'
                    );
      WHEN OTHERS
      THEN
         RAISE;
   END set_nome;

   PROCEDURE set_cognome
/******************************************************************************
 NOME:        SET_COGNOME.
 DESCRIZIONE: Modifica l'attributo COGNOME del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_cognome (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
                 (-20999,
                  'E'' stato inserito un valore scorretto nel campo COGNOME.'
                 );
      WHEN OTHERS
      THEN
         RAISE;
   END set_cognome;

   PROCEDURE set_sesso
/******************************************************************************
 NOME:        SET_SESSO.
 DESCRIZIONE: Modifica l'attributo SESSO del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo (M, F, null)..
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      IF p_valore IS NOT NULL AND p_valore <> 'F' AND p_valore <> 'M'
      THEN
         raise_application_error
                       (-20998,
                        'Valore non ammesso (Valori possibili: F, M o null).'
                       );
      ELSE
         d_dal := get_dal (p_soggetto);
         as4_anagrafe_soggetti_tpk.set_sesso (p_ni         => p_soggetto,
                                              p_dal        => d_dal,
                                              p_value      => p_valore
                                             );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END set_sesso;

   PROCEDURE set_codice_fiscale
/******************************************************************************
 NOME:        SET_CODICE_FISCALE.
 DESCRIZIONE: Modifica l'attributo CODICE_FISCALE del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_codice_fiscale (p_ni         => p_soggetto,
                                                    p_dal        => d_dal,
                                                    p_value      => p_valore
                                                   );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo CODICE_FISCALE.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_codice_fiscale;

   PROCEDURE set_partita_iva
/******************************************************************************
 NOME:        SET_PARTITA_IVA.
 DESCRIZIONE: Modifica l'attributo PARTITA_IVA del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_partita_iva (p_ni         => p_soggetto,
                                                 p_dal        => d_dal,
                                                 p_value      => p_valore
                                                );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
             (-20999,
              'E'' stato inserito un valore scorretto nel campo PARTITA_IVA.'
             );
      WHEN OTHERS
      THEN
         RAISE;
   END set_partita_iva;

   PROCEDURE set_indirizzo
/******************************************************************************
 NOME:        SET_INDIRIZZO.
 DESCRIZIONE: Modifica l'attributo INDIRIZZO_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_indirizzo_res (p_ni         => p_soggetto,
                                                   p_dal        => d_dal,
                                                   p_value      => p_valore
                                                  );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo INDIRIZZO DI RESIDENZA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_indirizzo;

   PROCEDURE set_indirizzo_dom
/******************************************************************************
 NOME:        SET_INDIRIZZO_DOM.
 DESCRIZIONE: Modifica l'attributo INDIRIZZO_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_indirizzo_dom (p_ni         => p_soggetto,
                                                   p_dal        => d_dal,
                                                   p_value      => p_valore
                                                  );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo INDIRIZZO DI DOMICILIO.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_indirizzo_dom;

   PROCEDURE set_cap
/******************************************************************************
 NOME:        SET_CAP.
 DESCRIZIONE: Modifica l'attributo CAP_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_cap_res (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo CAP DI RESIDENZA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_cap;


   PROCEDURE set_cap_dom
/******************************************************************************
 NOME:        SET_CAP_DOM.
 DESCRIZIONE: Modifica l'attributo CAP_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_cap_dom (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo CAP DI DOMICILIO.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_cap_dom;


   PROCEDURE set_provincia
/******************************************************************************
 NOME:        SET_PROVINCIA.
 DESCRIZIONE: Modifica l'attributo PROVINCIA_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN NUMBER)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_provincia_res (p_ni         => p_soggetto,
                                                   p_dal        => d_dal,
                                                   p_value      => p_valore
                                                  );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo PROVINCIA DI RESIDENZA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_provincia;

   PROCEDURE set_provincia
/******************************************************************************
 NOME:        SET_PROVINCIA.
 DESCRIZIONE: Modifica l'attributo PROVINCIA del soggetto corrente.
 ARGOMENTI:   p_sigla: Sigla provincia di residenza.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
  0    06/03/2006 SC          A14999.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_sigla IN VARCHAR2)
   IS
   BEGIN
      set_provincia (p_soggetto, get_provincia (p_sigla => UPPER (p_sigla)));
   END set_provincia;

   PROCEDURE set_comune
/******************************************************************************
 NOME:        SET_COMUNE.
 DESCRIZIONE: Modifica l'attributo COMUNE_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN NUMBER)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_comune_res (p_ni         => p_soggetto,
                                                p_dal        => d_dal,
                                                p_value      => p_valore
                                               );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo COMUNE DI RESIDENZA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_comune;

   PROCEDURE set_comune
/******************************************************************************
 NOME:        SET_COMUNE.
 DESCRIZIONE: Modifica l'attributo COMUNE_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    DENOMINAZIONE comune di residenza.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_comune_des IN VARCHAR2)
   IS
      dcap         ad4_comuni.cap%TYPE;
      dsigla       ad4_provincie.sigla%TYPE;
      dprovincia   ad4_provincie.provincia%TYPE;
   BEGIN
      set_comune (p_soggetto      => p_soggetto,
                  p_valore        => get_comune (p_comune_des,
                                                 dcap,
                                                 dsigla,
                                                 dprovincia
                                                )
                 );

      IF get_cap (p_soggetto) IS NULL
      THEN
         set_cap (p_soggetto, dcap);
      END IF;

      IF get_provincia (p_soggetto) IS NULL
      THEN
         set_provincia (p_soggetto, dprovincia);
      END IF;
   END set_comune;

   PROCEDURE set_provincia_nas
/******************************************************************************
 NOME:        SET_PROVINCIA_NAS.
 DESCRIZIONE: Modifica l'attributo PROVINCIA_NAS del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN NUMBER)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_provincia_nas (p_ni         => p_soggetto,
                                                   p_dal        => d_dal,
                                                   p_value      => p_valore
                                                  );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo PROVINCIA DI RESIDENZA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_provincia_nas;

   PROCEDURE set_comune_nas
/******************************************************************************
 NOME:        SET_COMUNE_NAS.
 DESCRIZIONE: Modifica l'attributo COMUNE_NAS del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN NUMBER)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_comune_nas (p_ni         => p_soggetto,
                                                p_dal        => d_dal,
                                                p_value      => p_valore
                                               );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo COMUNE DI RESIDENZA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_comune_nas;

   PROCEDURE set_comune_nas
/******************************************************************************
 NOME:        SET_COMUNE.
 DESCRIZIONE: Modifica l'attributo COMUNE_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    DENOMINAZIONE comune di nascita.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_comune_den IN VARCHAR2)
   IS
      dcap         ad4_comuni.cap%TYPE;
      dsigla       ad4_provincie.sigla%TYPE;
      dprovincia   ad4_provincie.provincia%TYPE;
   BEGIN
      set_comune_nas (p_soggetto      => p_soggetto,
                      p_valore        => get_comune (p_comune_den,
                                                     dcap,
                                                     dsigla,
                                                     dprovincia
                                                    )
                     );
      dprovincia := ad4_comune.get_provincia (p_comune_den, NULL, NULL);

      IF (dprovincia IS NOT NULL)
      THEN
         set_provincia_nas (p_soggetto, dprovincia);
      END IF;
   END set_comune_nas;

   PROCEDURE set_provincia_dom
/******************************************************************************
 NOME:        SET_PROVINCIA_DOM.
 DESCRIZIONE: Modifica l'attributo PROVINCIA_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN NUMBER)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_provincia_dom (p_ni         => p_soggetto,
                                                   p_dal        => d_dal,
                                                   p_value      => p_valore
                                                  );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo PROVINCIA DI DOMICILIO.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_provincia_dom;

   PROCEDURE set_provincia_dom
/******************************************************************************
 NOME:        SET_PROVINCIA.
 DESCRIZIONE: Modifica l'attributo PROVINCIA del soggetto corrente.
 ARGOMENTI:   p_sigla: Sigla provincia di residenza.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    06/03/2006 SC           A14999.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_sigla IN VARCHAR2)
   IS
   BEGIN
      set_provincia_dom (p_soggetto,
                         get_provincia (p_sigla => UPPER (p_sigla))
                        );
   END set_provincia_dom;

   PROCEDURE set_comune_dom
/******************************************************************************
 NOME:        SET_COMUNE_DOM.
 DESCRIZIONE: Modifica l'attributo COMUNE_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN NUMBER)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_comune_dom (p_ni         => p_soggetto,
                                                p_dal        => d_dal,
                                                p_value      => p_valore
                                               );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo COMUNE DI DOMICILIO.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_comune_dom;

   PROCEDURE set_comune_dom
/******************************************************************************
 NOME:        SET_COMUNE_DOM.
 DESCRIZIONE: Modifica l'attributo COMUNE_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    DENOMINAZIONE comune di domicilio.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_comune_den IN VARCHAR2)
   IS
      dcap         ad4_comuni.cap%TYPE;
      dsigla       ad4_provincie.sigla%TYPE;
      dprovincia   ad4_provincie.provincia%TYPE;
   BEGIN
      set_comune_dom (p_soggetto      => p_soggetto,
                      p_valore        => get_comune (p_comune_den,
                                                     dcap,
                                                     dsigla,
                                                     dprovincia
                                                    )
                     );

      IF get_cap_dom (p_soggetto) IS NULL
      THEN
         set_cap_dom (p_soggetto, dcap);
      END IF;

      IF get_provincia_dom (p_soggetto) IS NULL
      THEN
         set_provincia_dom (p_soggetto, dprovincia);
      END IF;
   END set_comune_dom;

   PROCEDURE set_data_nascita
/******************************************************************************
 NOME:        SET_DATA_NASCITA.
 DESCRIZIONE: Modifica l'attributo DATA_NAS del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    stringa contenente la data di nascita in formato
                           dd/mm/yyyy.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_data_nas
                                            (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => TO_DATE
                                                                 (p_valore,
                                                                  'dd/mm/yyyy'
                                                                 )
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo DATA DI NASCITA.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_data_nascita;

   PROCEDURE set_dal
/******************************************************************************
 NOME:        SET_DAL.
 DESCRIZIONE: Modifica l'attributo DAL del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    stringa contenente data inizio validita' in formato
                           dd/mm/yyyy.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_dal (p_ni         => p_soggetto,
                                         p_dal        => d_dal,
                                         p_value      => TO_DATE (p_valore,
                                                                  'dd/mm/yyyy'
                                                                 )
                                        );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo DATA DI INIZIO VALIDITA''.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_dal;

   PROCEDURE set_telefono
/******************************************************************************
 NOME:        SET_TELEFONO.
 DESCRIZIONE: Modifica l'attributo TEL_RES del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_tel_res (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
                (-20999,
                 'E'' stato inserito un valore scorretto nel campo TELEFONO.'
                );
      WHEN OTHERS
      THEN
         RAISE;
   END set_telefono;

   PROCEDURE set_telefono_dom
/******************************************************************************
 NOME:        SET_TELEFONO_DOM.
 DESCRIZIONE: Modifica l'attributo TEL_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_tel_dom (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo TELEFONO DEL DOMICILIO.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_telefono_dom;

   PROCEDURE set_fax
/******************************************************************************
 NOME:        SET_FAX.
 DESCRIZIONE: Modifica l'attributo FAX del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_fax_res (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
                     (-20999,
                      'E'' stato inserito un valore scorretto nel campo FAX.'
                     );
      WHEN OTHERS
      THEN
         RAISE;
   END set_fax;

   PROCEDURE set_fax_dom
/******************************************************************************
 NOME:        SET_FAX_DOM.
 DESCRIZIONE: Modifica l'attributo FAX_DOM del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_fax_dom (p_ni         => p_soggetto,
                                             p_dal        => d_dal,
                                             p_value      => p_valore
                                            );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo FAX DEL DOMICILIO.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_fax_dom;

   PROCEDURE set_indirizzo_web
/******************************************************************************
 NOME:        SET_INDIRIZZO_WEB.
 DESCRIZIONE: Modifica l'attributo INDIRIZZO_WEB del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_indirizzo_web (p_ni         => p_soggetto,
                                                   p_dal        => d_dal,
                                                   p_value      => p_valore
                                                  );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
            (-20999,
             'E'' stato inserito un valore scorretto nel campo INDIRIZZO WEB.'
            );
      WHEN OTHERS
      THEN
         RAISE;
   END set_indirizzo_web;

   PROCEDURE set_note
/******************************************************************************
 NOME:        SET_NOTE.
 DESCRIZIONE: Modifica l'attributo NOTE del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_note (p_ni         => p_soggetto,
                                          p_dal        => d_dal,
                                          p_value      => p_valore
                                         );
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         raise_application_error
                    (-20999,
                     'E'' stato inserito un valore scorretto nel campo NOTE.'
                    );
      WHEN OTHERS
      THEN
         RAISE;
   END set_note;

   PROCEDURE set_competenza
/******************************************************************************
 NOME:        SET_COMPETENZA.
 DESCRIZIONE: Modifica l'attributo COMPETENZA del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (p_soggetto IN NUMBER, p_valore IN VARCHAR2)
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_competenza (p_ni         => p_soggetto,
                                                p_dal        => d_dal,
                                                p_value      => p_valore
                                               );
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END set_competenza;

   PROCEDURE set_competenza_esclusiva
/******************************************************************************
 NOME:        SET_COMPETENZA_ESCLUSIVA.
 DESCRIZIONE: Modifica l'attributo COMPETENZA_ESCLUSIVA del soggetto.
 ARGOMENTI:   p_soggetto:  numero individuale del soggetto da modificare.
              p_valore:    valore dell'attributo.
 ECCEZIONI:   -
 ANNOTAZIONI: -
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       ------------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
******************************************************************************/
   (
      p_soggetto   IN   NUMBER,
      p_valore     IN   VARCHAR2
   )
   IS
      d_dal   as4_soggetti.dal%TYPE;
   BEGIN
      d_dal := get_dal (p_soggetto);
      as4_anagrafe_soggetti_tpk.set_competenza_esclusiva (p_ni         => p_soggetto,
                                                          p_dal        => d_dal,
                                                          p_value      => p_valore
                                                         );
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END set_competenza_esclusiva;

   function get_dati_soggetto
   ( p_soggetto in number )
   RETURN as4_anagrafe_soggetti%ROWTYPE
   is
      v_as4_soggetto as4_anagrafe_soggetti%ROWTYPE;
   begin
      SELECT *
        INTO v_as4_soggetto
        FROM as4_anagrafe_soggetti
       WHERE ni = p_soggetto
         AND al is null
      ;
      return v_as4_soggetto;
   end;

   PROCEDURE upd_soggetto
    ( p_soggetto         IN OUT   as4_anagrafe_soggetti.ni%TYPE,
      p_dal              IN OUT   VARCHAR2,
      p_cognome          IN       as4_anagrafe_soggetti.cognome%TYPE,
      p_nome             IN       as4_anagrafe_soggetti.nome%TYPE DEFAULT NULL,
      p_sesso            IN       as4_anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL,
      p_data_nascita     IN       VARCHAR2 DEFAULT NULL,
      p_provincia_nas    IN       as4_anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL,
      p_comune_nas       IN       as4_anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL,
      p_codice_fiscale   IN       as4_anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL,
      p_partita_iva      IN       as4_anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL,
      p_indirizzo        IN       as4_anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL,
      p_provincia        IN       as4_anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL,
      p_comune           IN       as4_anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL,
      p_cap              IN       as4_anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL,
      p_tel              IN       as4_anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL,
      p_fax              IN       as4_anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL,
      p_presso           IN       as4_anagrafe_soggetti.presso%TYPE
            DEFAULT NULL,
      p_indirizzo_dom    IN       as4_anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL,
      p_provincia_dom    IN       as4_anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL,
      p_comune_dom       IN       as4_anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL,
      p_cap_dom          IN       as4_anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL,
      p_tel_dom          IN       as4_anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL,
      p_fax_dom          IN       as4_anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL,
      p_indirizzo_web    IN       as4_anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL,
      p_note             IN       as4_anagrafe_soggetti.note%TYPE DEFAULT NULL,
      p_competenza       IN       as4_anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL,
      p_comp_escl        IN       as4_anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL,
      p_utente           IN       as4_anagrafe_soggetti.utente%TYPE
            DEFAULT NULL,
      p_modifica         IN       VARCHAR2 DEFAULT 'T',
      p_batch            IN       NUMBER default 0
   )
   IS
/******************************************************************************
 NOME:        UPD_SOGGETTO.
 DESCRIZIONE: Insert o update di soggetti.
 ARGOMENTI:   p_soggetto: numero identificativo del soggetto inserito o da
                          aggiornare.
              p_dal: eventuale valore di input viene considerato solo in insert
              p_modifica: Totale (T) o Parziale (P) O Storica (S).
                       Se totale:
                             tutti i valori passati vengono aggiornati
                             indipendentemente   dal fatto che siano nulli o
                             meno,
                  Se storica
                      viene inserito un nuovo record con ni passato e data di inizio validita passata.
                          altrimenti:
                             aggiorna i soli dati significativi (not null).
                          Default: 'T'.
 ECCEZIONI:   20999, Impossibile associare al Soggetto un nome vuoto.>
 ANNOTAZIONI: Previsto aggiornamento solo soggetti validi (al nullo).
 REVISIONI:
 Rev. Data       Autore       Descrizione
 ---- ---------- ------       --------------------------------------------------
 0    04/05/2005 SC           Prima emissione.
 1    07/11/2005 MT           A12363.0 Aggiunta modifica della partita_iva
      14/12/2005 SC           Setta il campo competenza con GS4, altrimenti viene
                              utilizzatoGS4WEB per i soggetti da li' inseriti.
 1    16/01/2006 MT           A12363.4 Gestione dati domicilio
 2    03/08/2009 MMalferrari  Modificata tutta la struttura del package in modo
                              che non utilizzi variabili di package.
 4    24/01/2012 MMalferrari  Modificato il default della competenza da GS4 ad
                              AGS.
 5    23/03/2012 MMalferrari  A47549.0.0: Modifica di un mittente o destinatario
******************************************************************************/
      -- serve solo per i messaggi mentre a ins/upd viene sempre passato null.
      d_denominazione           VARCHAR2 (32000) := p_cognome || ' ' || p_nome;

      v_trovato                 NUMBER;

      d_competenza              VARCHAR2 (100)  := NVL (p_competenza, 'AGS');

      d_utente                  VARCHAR2 (8)    := NVL (p_utente, NVL (si4.utente, SUBSTR (USER, 1, 8)));

      PROCEDURE ANAGRAFICI_PKG_INS (
      p_ni                           IN NUMBER,
      p_dal                          IN DATE,
      p_cognome                      IN VARCHAR2,
      p_nome                         IN VARCHAR2,
      p_sesso                        IN VARCHAR2,
      p_data_nas                     IN DATE,
      p_provincia_nas                IN VARCHAR2,
      p_comune_nas                   IN VARCHAR2,
      p_luogo_nas                    IN VARCHAR2,
      p_codice_fiscale               IN VARCHAR2,
      p_codice_fiscale_estero        IN VARCHAR2,
      p_partita_iva                  IN VARCHAR2,
      p_cittadinanza                 IN VARCHAR2,
      p_gruppo_ling                  IN VARCHAR2,
      p_competenza                   IN VARCHAR2,
      p_competenza_esclusiva         IN VARCHAR2,
      p_tipo_soggetto                IN VARCHAR2,
      p_stato_cee                    IN VARCHAR2,
      p_partita_iva_cee              IN VARCHAR2,
      p_fine_validita                IN DATE,
      p_denominazione                IN VARCHAR2,
      p_note                         IN VARCHAR2,
      p_indirizzo_web                IN VARCHAR2,
      p_indirizzo_res                IN VARCHAR2,
      p_provincia_res                IN VARCHAR2,
      p_comune_res                   IN VARCHAR2,
      p_cap_res                      IN VARCHAR2,
      p_tel_res                      IN VARCHAR2,
      p_fax_res                      IN VARCHAR2,
      p_presso                       IN VARCHAR2,
      p_indirizzo_dom                IN VARCHAR2,
      p_provincia_dom                IN VARCHAR2,
      p_comune_dom                   IN VARCHAR2,
      p_cap_dom                      IN VARCHAR2,
      p_tel_dom                      IN VARCHAR2,
      p_fax_dom                      IN VARCHAR2,
      p_utente                       IN VARCHAR2,
      p_data_agg                     IN DATE DEFAULT SYSDATE ,
      p_batch                        IN NUMBER DEFAULT 0      -- 0 = NON batch
      )
      is
        d_stmt VARCHAR2(32000);
        d_ret  NUMBER;
      begin
         d_stmt :=   'BEGIN '
                   ||':d_ret := AS4_ANAGRAFICI_PKG.ins_anag_dom_e_res_e_mail('
                   ||'p_ni => :p_ni,'
                   ||'p_dal => :p_dal,'
                   ||'p_cognome => :p_cognome,'
                   ||'p_nome => :p_nome,'
                   ||'p_denominazione => :p_denominazione,'
                   ||'p_sesso => :p_sesso,'
                   ||'p_data_nas => :p_data_nas,'
                   ||'p_provincia_nas => :p_provincia_nas,'
                   ||'p_comune_nas => :p_comune_nas,'
                   ||'p_luogo_nas => :p_luogo_nas,'
                   ||'p_codice_fiscale => :p_codice_fiscale,'
                   ||'p_codice_fiscale_estero => :p_codice_fiscale_estero,'
                   ||'p_partita_iva => :p_partita_iva,'
                   ||'p_cittadinanza => :p_cittadinanza,'
                   ||'p_gruppo_ling => :p_gruppo_ling,'
                   ||'p_competenza => :p_competenza,'
                   ||'p_competenza_esclusiva => :p_competenza_esclusiva,'
                   ||'p_tipo_soggetto => :p_tipo_soggetto,'
                   ||'p_stato_cee => :p_stato_cee,'
                   ||'p_partita_iva_cee => :p_partita_iva_cee,'
                   ||'p_fine_validita => :p_fine_validita,'
                   ||'p_note_anag => :p_note,'
                   ||'p_indirizzo_res => :p_indirizzo_res,'
                   ||'p_provincia_res => :p_provincia_res,'
                   ||'p_comune_res => :p_comune_res,'
                   ||'p_cap_res => :p_cap_res,'
                   ||'p_mail => :p_indirizzo_web,'
                   ||'p_tel_res => :p_tel_res,'
                   ||'p_fax_res => :p_fax_res,'
                   ||'p_presso => :p_presso,'
                   ||'p_indirizzo_dom => :p_indirizzo_dom,'
                   ||'p_provincia_dom => :p_provincia_dom,'
                   ||'p_comune_dom => :p_comune_dom,'
                   ||'p_cap_dom => :p_cap_dom,'
                   ||'p_tel_dom => :p_tel_dom,'
                   ||'p_fax_dom => :p_fax_dom,'
                   ||'p_utente => :p_utente,'
                   ||'p_data_agg => :p_data_agg,'
                   ||'p_batch => :p_batch'
                   ||'); '
                   ||'END;';
        EXECUTE IMMEDIATE d_stmt
         USING OUT
             d_ret,
             p_ni,
             p_dal,
             p_cognome,
             p_nome,
             p_denominazione,
             p_sesso,
             p_data_nas,
             p_provincia_nas,
             p_comune_nas,
             p_luogo_nas,
             p_codice_fiscale,
             p_codice_fiscale_estero,
             p_partita_iva,
             p_cittadinanza,
             p_gruppo_ling,
             p_competenza,
             p_competenza_esclusiva,
             p_tipo_soggetto,
             p_stato_cee,
             p_partita_iva_cee,
             p_fine_validita,
             p_note,
             p_indirizzo_res,
             p_provincia_res,
             p_comune_res,
             p_cap_res,
             p_indirizzo_web,
             p_tel_res,
             p_fax_res,
             p_presso,
             p_indirizzo_dom,
             p_provincia_dom,
             p_comune_dom,
             p_cap_dom,
             p_tel_dom,
             p_fax_dom,
             p_utente,
             p_data_agg,
             p_batch
         ;
      end;

      FUNCTION ins_upd
      (p_modifica in varchar2 default 'T')
      return integer
      is
         v_trovato                 NUMBER;
         v_as4_soggetto            as4_anagrafe_soggetti%ROWTYPE;

         d_cognome                 VARCHAR2 (2000);
         d_nome                    VARCHAR2 (2000);
         d_denominazione           varchar2(32000);
         d_sesso                   VARCHAR2 (1);
         d_data_nas                DATE;
         d_provincia_nas           VARCHAR2 (3);
         d_comune_nas              VARCHAR2 (3);
         d_luogo_nas               VARCHAR2 (2000);
         d_codice_fiscale          VARCHAR2 (16);
         d_cittadinanza            VARCHAR2 (3);
         d_indirizzo               VARCHAR2 (2000);
         d_provincia               VARCHAR2 (3);
         d_comune                  VARCHAR2 (3);
         d_cap                     VARCHAR2 (5);
         d_tel                     VARCHAR2 (14);
         d_presso                  VARCHAR2 (2000);
         d_indirizzo_dom           VARCHAR2 (2000);
         d_provincia_dom           VARCHAR2 (3);
         d_comune_dom              VARCHAR2 (3);
         d_cap_dom                 VARCHAR2 (5);
         d_tel_dom                 VARCHAR2 (14);
         d_gruppo_ling             VARCHAR2 (4);
         d_partita_iva             VARCHAR2 (11);
         d_note                    VARCHAR2 (4000);
         d_codice_fiscale_estero   VARCHAR2 (40);
         d_fax                     VARCHAR2 (14);
         d_fax_dom                 VARCHAR2 (14);
         d_indirizzo_web           VARCHAR2 (2000);
         d_tipo_soggetto           VARCHAR2 (8);
         d_competenza_esclusiva    VARCHAR2 (1);
         d_flag_trg                VARCHAR2 (1);
         d_fine_validita           DATE;
         d_partita_iva_cee         as4_anagrafe_soggetti.partita_iva_cee%TYPE;
         d_stato_cee               as4_anagrafe_soggetti.stato_cee%TYPE;
      begin
         v_trovato := 1;

         ------------------------------------------------------
         -- Lettura attributi attuali del soggetto
         ------------------------------------------------------
         IF nvl(p_modifica, 'T') in ('T', 'P', 'S') THEN -- modifica Totale, Parziale o Storica.
            BEGIN
               v_as4_soggetto := get_dati_soggetto(p_soggetto);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_trovato := 0;
            END;
         END IF;

         --------------------
         -- Gestione DAL
         --------------------
         IF nvl(p_modifica, 'T') in ('T', 'P') THEN -- modifica Totale, Parziale.
            p_dal := NVL (p_dal, to_char(trunc(v_as4_soggetto.dal),'dd/mm/yyyy'));
         elsif nvl(p_modifica, 'T') in ('I') THEN -- Inserimento.
            p_dal := NVL (p_dal, NVL (p_data_nascita, TO_CHAR (SYSDATE, 'dd/mm/yyyy')));
         elsif nvl(p_modifica, 'T') = 'S' THEN -- modifica Storica.
            p_dal := NVL (p_dal, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
         end if;

         ---------------------------
         -- Gestione DENOMINAZIONE
         ---------------------------
         if p_cognome is not null then
            d_denominazione := UPPER(p_cognome);
         elsif p_cognome is null and nvl(p_modifica, 'T') = 'P' then
            d_denominazione := v_as4_soggetto.cognome;
         end if;

         if p_nome is not null then
            d_denominazione := d_denominazione||'  '||UPPER(p_nome);
         elsif nvl(p_modifica, 'T') = 'P' then
            d_denominazione := d_denominazione||'  '||v_as4_soggetto.nome;
         end if;
         if v_trovato = 1 or nvl(p_modifica, 'T') = 'S' then
            IF nvl(p_modifica, 'T') in ('T', 'I', 'S') THEN -- modifica Totale o Inserimento o Storica.
               d_cognome         := UPPER(p_cognome);
               d_nome            := UPPER(p_nome);
               d_sesso           := UPPER(p_sesso);
               d_data_nas        := TO_DATE (p_data_nascita, 'dd/mm/yyyy');
               d_provincia_nas   := p_provincia_nas;
               d_comune_nas      := p_comune_nas;
               d_codice_fiscale  := UPPER(p_codice_fiscale);
               d_partita_iva     := p_partita_iva;
               d_indirizzo       := p_indirizzo;
               d_provincia       := p_provincia;
               d_comune          := p_comune;
               d_cap             := p_cap;
               d_tel             := p_tel;
               d_fax             := p_fax;
               d_indirizzo_dom   := p_indirizzo_dom;
               d_provincia_dom   := p_provincia_dom;
               d_comune_dom      := p_comune_dom;
               d_cap_dom         := p_cap_dom;
               d_tel_dom         := p_tel_dom;
               d_fax_dom         := p_fax_dom;
               d_indirizzo_web   := p_indirizzo_web;
               d_note            := p_note;
               d_competenza_esclusiva  := p_comp_escl;
            END IF;

            IF nvl(p_modifica, 'T') in ('P') THEN -- modifica Parziale.
               d_cognome         := NVL(UPPER(p_cognome), v_as4_soggetto.cognome);
               d_nome            := NVL(UPPER(p_nome), v_as4_soggetto.nome);
               d_sesso           := NVL(UPPER(p_sesso), v_as4_soggetto.sesso);
               d_data_nas        := NVL(to_date(p_data_nascita, 'dd/mm/yyyy'), v_as4_soggetto.data_nas);
               d_provincia_nas   := NVL(p_provincia_nas, v_as4_soggetto.provincia_nas);
               d_comune_nas      := NVL(p_comune_nas, v_as4_soggetto.comune_nas);
               d_codice_fiscale  := NVL(p_codice_fiscale, v_as4_soggetto.codice_fiscale);
               d_partita_iva     := NVL(p_partita_iva, v_as4_soggetto.partita_iva);
               d_indirizzo       := NVL(p_indirizzo, v_as4_soggetto.indirizzo_res);
               d_provincia       := NVL(p_provincia, v_as4_soggetto.provincia_res);
               d_comune          := NVL(p_comune, v_as4_soggetto.comune_res);
               d_cap             := NVL(p_cap, v_as4_soggetto.cap_res);
               d_tel             := NVL(p_tel, v_as4_soggetto.tel_res);
               d_fax             := NVL(p_fax, v_as4_soggetto.fax_res);
               d_indirizzo_dom   := NVL(p_indirizzo_dom, v_as4_soggetto.indirizzo_dom);
               d_provincia_dom   := NVL(p_provincia_dom, v_as4_soggetto.provincia_dom);
               d_comune_dom      := NVL(p_comune_dom, v_as4_soggetto.comune_dom);
               d_cap_dom         := NVL(p_cap_dom, v_as4_soggetto.cap_dom);
               d_tel_dom         := NVL(p_tel_dom, v_as4_soggetto.tel_dom);
               d_fax_dom         := NVL(p_fax_dom, v_as4_soggetto.fax_dom);
               d_indirizzo_web   := NVL(p_indirizzo_web, v_as4_soggetto.indirizzo_web);
               d_note            := NVL(p_note, v_as4_soggetto.note);
               d_competenza_esclusiva  := NVL(p_comp_escl, v_as4_soggetto.competenza_esclusiva);
            END IF;

            IF nvl(p_modifica, 'T') in ('T', 'P', 'S') THEN  -- modifica Totale, Parziale o Storica.
               d_luogo_nas             := v_as4_soggetto.luogo_nas;
               d_codice_fiscale_estero := v_as4_soggetto.codice_fiscale_estero;
               d_cittadinanza          := v_as4_soggetto.cittadinanza;
               d_gruppo_ling           := v_as4_soggetto.gruppo_ling;
               d_presso                := v_as4_soggetto.presso;
               d_tipo_soggetto         := v_as4_soggetto.tipo_soggetto;
               d_stato_cee             := v_as4_soggetto.stato_cee;
               d_partita_iva_cee       := v_as4_soggetto.partita_iva_cee;
               d_fine_validita         := v_as4_soggetto.fine_validita;
               d_flag_trg              := v_as4_soggetto.flag_trg;
            END IF;

            IF nvl(p_modifica, 'T') in ('I') THEN    -- Inserimento.
               d_luogo_nas             := NULL;
               d_codice_fiscale_estero := NULL;
               d_cittadinanza          := NULL;
               d_gruppo_ling           := NULL;
               d_presso                := NULL;
               d_tipo_soggetto         := NULL;
               d_stato_cee             := NULL;
               d_partita_iva_cee       := NULL;
               d_fine_validita         := NULL;
               d_flag_trg              := NULL;
            END IF;

            IF nvl(p_modifica, 'T') in ('T', 'P') THEN
               as4_anagrafe_soggetti_tpk.upd
                  (0,
                   p_new_ni                         => p_soggetto,
                   p_old_ni                         => p_soggetto,
                   p_new_dal                        => TO_DATE (p_dal, 'dd/mm/yyyy'),
                   p_old_dal                        => TO_DATE (p_dal, 'dd/mm/yyyy'),
                   p_new_cognome                    => d_cognome,
                   p_new_nome                       => d_nome,
                   p_new_sesso                      => d_sesso,
                   p_new_data_nas                   => d_data_nas,
                   p_new_provincia_nas              => d_provincia_nas,
                   p_new_comune_nas                 => d_comune_nas,
                   p_new_luogo_nas                  => d_luogo_nas,
                   p_new_codice_fiscale             => d_codice_fiscale,
                   p_new_codice_fiscale_estero      => d_codice_fiscale_estero,
                   p_new_partita_iva                => d_partita_iva,
                   p_new_cittadinanza               => d_cittadinanza,
                   p_new_gruppo_ling                => d_gruppo_ling,
                   p_new_indirizzo_res              => d_indirizzo,
                   p_new_provincia_res              => d_provincia,
                   p_new_comune_res                 => d_comune,
                   p_new_cap_res                    => d_cap,
                   p_new_tel_res                    => d_tel,
                   p_new_fax_res                    => d_fax,
                   p_new_presso                     => d_presso,
                   p_new_indirizzo_dom              => d_indirizzo_dom,
                   p_new_provincia_dom              => d_provincia_dom,
                   p_new_comune_dom                 => d_comune_dom,
                   p_new_cap_dom                    => d_cap_dom,
                   p_new_tel_dom                    => d_tel_dom,
                   p_new_fax_dom                    => d_fax_dom,
                   p_new_utente                     => d_utente,
                   p_new_data_agg                   => SYSDATE,
                   p_new_competenza                 => d_competenza,
                   p_new_tipo_soggetto              => d_tipo_soggetto,
                   p_new_stato_cee                  => d_stato_cee,
                   p_new_partita_iva_cee            => d_partita_iva_cee,
                   p_new_fine_validita              => d_fine_validita,
                   p_new_flag_trg                   => d_flag_trg,
                   p_new_denominazione              => d_denominazione,
                   p_new_indirizzo_web              => d_indirizzo_web,
                   p_new_note                       => d_note,
                   p_new_competenza_esclusiva       => d_competenza_esclusiva
                  );
            END IF;

            IF nvl(p_modifica, 'T') in ('I', 'S') THEN
               if ESISTE_ANAGRAFICI_PKG = 1 then
                   ANAGRAFICI_PKG_INS (
                       p_ni                           => p_soggetto,
                       p_dal                          => TO_DATE (p_dal, 'dd/mm/yyyy'),
                       p_cognome                      => UPPER (d_cognome),
                       p_nome                         => UPPER (d_nome),
                       p_sesso                        => d_sesso,
                       p_data_nas                     => d_data_nas,
                       p_provincia_nas                => d_provincia_nas,
                       p_comune_nas                   => d_comune_nas,
                       p_luogo_nas                  => d_luogo_nas,
                       p_codice_fiscale             => d_codice_fiscale,
                       p_codice_fiscale_estero      => d_codice_fiscale_estero,
                       p_partita_iva                => d_partita_iva,
                       p_cittadinanza               => d_cittadinanza,
                       p_gruppo_ling                => d_gruppo_ling,
                       p_competenza                 => d_competenza,
                       p_competenza_esclusiva       => d_competenza_esclusiva,
                       p_tipo_soggetto              => d_tipo_soggetto,
                       p_stato_cee                  => d_stato_cee,
                       p_partita_iva_cee            => d_partita_iva_cee,
                       p_fine_validita              => d_fine_validita,
                       p_denominazione              => d_denominazione,
                       p_note                       => d_note,
                       p_indirizzo_web              => d_indirizzo_web,
                       p_indirizzo_res              => d_indirizzo,
                       p_provincia_res              => d_provincia,
                       p_comune_res                 => d_comune,
                       p_cap_res                    => d_cap,
                       p_tel_res                    => d_tel,
                       p_fax_res                    => d_fax,
                       p_presso                     => d_presso,
                       p_indirizzo_dom              => d_indirizzo_dom,
                       p_provincia_dom              => d_provincia_dom,
                       p_comune_dom                 => d_comune_dom,
                       p_cap_dom                    => d_cap_dom,
                       p_tel_dom                    => d_tel_dom,
                       p_fax_dom                    => d_fax_dom,
                       p_utente                     => d_utente,
                       p_data_agg                   => SYSDATE,
                       p_batch                        => p_batch
                       );
               else
                   as4_anagrafe_soggetti_tpk.ins
                      (p_soggetto,
                       TO_DATE (p_dal, 'dd/mm/yyyy'),
                       UPPER (d_cognome),
                       UPPER (d_nome),
                       d_sesso,
                       d_data_nas,
                       d_provincia_nas,
                       d_comune_nas,
                       p_luogo_nas                  => d_luogo_nas,
                       p_codice_fiscale             => d_codice_fiscale,
                       p_codice_fiscale_estero      => d_codice_fiscale_estero,
                       p_partita_iva                => d_partita_iva,
                       p_cittadinanza               => d_cittadinanza,
                       p_gruppo_ling                => d_gruppo_ling,
                       p_indirizzo_res              => d_indirizzo,
                       p_provincia_res              => d_provincia,
                       p_comune_res                 => d_comune,
                       p_cap_res                    => d_cap,
                       p_tel_res                    => d_tel,
                       p_fax_res                    => d_fax,
                       p_presso                     => d_presso,
                       p_indirizzo_dom              => d_indirizzo_dom,
                       p_provincia_dom              => d_provincia_dom,
                       p_comune_dom                 => d_comune_dom,
                       p_cap_dom                    => d_cap_dom,
                       p_tel_dom                    => d_tel_dom,
                       p_fax_dom                    => d_fax_dom,
                       p_utente                     => d_utente,
                       p_data_agg                   => SYSDATE,
                       p_competenza                 => d_competenza,
                       p_tipo_soggetto              => d_tipo_soggetto,
                       p_flag_trg                   => d_flag_trg,
                       p_stato_cee                  => d_stato_cee,
                       p_partita_iva_cee            => d_partita_iva_cee,
                       p_fine_validita              => d_fine_validita,
                       p_al                         => NULL,
                       p_denominazione              => d_denominazione,
                       p_indirizzo_web              => d_indirizzo_web,
                       p_note                       => d_note,
                       p_competenza_esclusiva       => d_competenza_esclusiva
                      );
               end if;
            end if;
         end if;
         return v_trovato;
      end;
   BEGIN
      ------------------------------------------
      -- Controlli preliminari
      ------------------------------------------
      IF p_modifica NOT IN ('T', 'P', 'S') THEN
         raise_application_error(-20999, 'Il parametro p_modifica puo'' essere: Totale(T) Parziale(P) o Storica(S).');
      END IF;
      IF p_cognome IS NULL and (p_soggetto IS NULL or p_modifica in ('T', 'S')) THEN
         raise_application_error(-20999, 'Impossibile associare al Soggetto un cognome vuoto');
      END IF;

       IF p_soggetto IS NULL THEN
       ------------------------------------------
       -- INSERIMENTO
       ------------------------------------------
         DECLARE
            d_stmt varchar2(1000);
         BEGIN
            -- inizializzazione campo NI
            if ESISTE_ANAGRAFICI_PKG = 1  and p_batch = 0 then
                  d_stmt := 'declare d_soggetto number; begin as4_anagrafici_pkg.init_ni(:d_soggetto); end;';
                  execute immediate d_stmt USING IN OUT p_soggetto;
               else
                  as4_anagrafe_soggetti_pkg.init_ni(p_soggetto);
            end if;
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20999, 'Impossibile associare il numero individuale al nuovo soggetto ('|| d_denominazione || ').' || CHR (10) || REPLACE (SQLERRM, 'ORA-', ''));
         END;
         BEGIN
            v_trovato := ins_upd (p_modifica => 'I');
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20999, 'Fallito inserimento del soggetto ' || d_denominazione || '.' || CHR (10) || REPLACE (SQLERRM, 'ORA-', ''));
         END;
--raise_application_error(-20999, 'D_UTENTE '||D_UTENTE);

      ELSE
      ------------------------------------------
      -- AGGIORNAMENTO
      ------------------------------------------
         BEGIN
            v_trovato := ins_upd(p_modifica);
         EXCEPTION
            WHEN OTHERS THEN
               raise_application_error(-20999, 'Fallito aggiornamento del soggetto '|| d_denominazione || '. ('|| p_modifica ||')' || CHR (10)|| REPLACE (SQLERRM, 'ORA-', ''));
         END;
      -- suppone di essere in update.
         IF p_modifica in ('T', 'P') THEN -- modifica Totale o Parziale.
            -- se non ha trovato il SOGGETTO DA MODIFICARE, LO INSERISCE
            IF v_trovato = 0 THEN
               BEGIN
                  DBMS_OUTPUT.put_line
                     (   'in caso di SQL%RowCount = 0 tenta insert con dal '
                      || TO_DATE (p_dal, 'dd/mm/yyyy')
                     );
--   RAISE_APPLICATION_ERROR(-20999,'      p_SOGGETTO               => '||p_SOGGETTO||',
--      p_dal                  => '||p_dal||',
--      p_cognome                  => '||p_cognome||',
--      p_nome                  => '||p_nome||',
--      p_SeSSO                 => '||p_SeSSO||',
--      p_data_nasCITA          => '||p_data_nasCITA||',
--      p_codice_fiscale        => '||p_codice_fiscale||',
--      p_indirizzO            => '||p_indirizzO||',
--      p_indirizzo_web         => '||p_indirizzo_web||',
--      p_provincia       => '||p_provincia||',
--      p_comune            => '||p_comune||',
--      p_cap                   => '||p_cap||',
--      p_tel                  => '||p_tel);
                  v_trovato := ins_upd (p_modifica => 'I');
               EXCEPTION
                  WHEN OTHERS THEN
                     raise_application_error(-20999, 'Fallito inserimento del soggetto '|| d_denominazione || '.' || CHR (10) || REPLACE (SQLERRM, 'ORA-', ''));
               END;
            END IF;
         END IF;
      END IF;
   END upd_soggetto;

   PROCEDURE upd_soggetto_refresh
    ( p_soggetto         IN OUT   as4_anagrafe_soggetti.ni%TYPE,
      p_dal              IN OUT   VARCHAR2,
      p_cognome          IN       as4_anagrafe_soggetti.cognome%TYPE,
      p_nome             IN       as4_anagrafe_soggetti.nome%TYPE DEFAULT NULL,
      p_sesso            IN       as4_anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL,
      p_data_nascita     IN       VARCHAR2 DEFAULT NULL,
      p_provincia_nas    IN       as4_anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL,
      p_comune_nas       IN       as4_anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL,
      p_codice_fiscale   IN       as4_anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL,
      p_partita_iva      IN       as4_anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL,
      p_indirizzo        IN       as4_anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL,
      p_provincia        IN       as4_anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL,
      p_comune           IN       as4_anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL,
      p_cap              IN       as4_anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL,
      p_tel              IN       as4_anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL,
      p_fax              IN       as4_anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL,
      p_presso           IN       as4_anagrafe_soggetti.presso%TYPE
            DEFAULT NULL,
      p_indirizzo_dom    IN       as4_anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL,
      p_provincia_dom    IN       as4_anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL,
      p_comune_dom       IN       as4_anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL,
      p_cap_dom          IN       as4_anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL,
      p_tel_dom          IN       as4_anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL,
      p_fax_dom          IN       as4_anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL,
      p_indirizzo_web    IN       as4_anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL,
      p_note             IN       as4_anagrafe_soggetti.note%TYPE DEFAULT NULL,
      p_competenza       IN       as4_anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL,
      p_comp_escl        IN       as4_anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL,
      p_utente           IN       as4_anagrafe_soggetti.utente%TYPE
            DEFAULT NULL,
      p_modifica         IN       VARCHAR2 DEFAULT 'T'
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      EXECUTE IMMEDIATE 'BEGIN AS4_ANAGRAFE_SOGGETTI_TPK.SETREFRESHOFF; END;';

      UPD_SOGGETTO( P_SOGGETTO, P_DAL, P_COGNOME, P_NOME, P_SESSO, P_DATA_NASCITA, P_PROVINCIA_NAS, P_COMUNE_NAS, P_CODICE_FISCALE, P_PARTITA_IVA, P_INDIRIZZO, P_PROVINCIA, P_COMUNE, P_CAP, P_TEL, P_FAX, P_PRESSO, P_INDIRIZZO_DOM, P_PROVINCIA_DOM, P_COMUNE_DOM, P_CAP_DOM, P_TEL_DOM, P_FAX_DOM, P_INDIRIZZO_WEB, P_NOTE, P_COMPETENZA, P_COMP_ESCL, P_UTENTE, P_MODIFICA );
      COMMIT;

      EXECUTE IMMEDIATE 'BEGIN AS4_ANAGRAFE_SOGGETTI_PKG.REFRESH_SLAVE; END;';

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   END upd_soggetto_refresh;

   PROCEDURE update_soggetto
    ( p_soggetto         IN OUT   as4_anagrafe_soggetti.ni%TYPE,
      p_dal              IN OUT   VARCHAR2,
      p_cognome          IN       as4_anagrafe_soggetti.cognome%TYPE,
      p_nome             IN       as4_anagrafe_soggetti.nome%TYPE DEFAULT NULL,
      p_sesso            IN       as4_anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL,
      p_data_nascita     IN       VARCHAR2 DEFAULT NULL,
      p_provincia_nas    IN       as4_anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL,
      p_comune_nas       IN       as4_anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL,
      p_codice_fiscale   IN       as4_anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL,
      p_partita_iva      IN       as4_anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL,
      p_indirizzo        IN       as4_anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL,
      p_provincia        IN       as4_anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL,
      p_comune           IN       as4_anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL,
      p_cap              IN       as4_anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL,
      p_tel              IN       as4_anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL,
      p_fax              IN       as4_anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL,
      p_presso           IN       as4_anagrafe_soggetti.presso%TYPE
            DEFAULT NULL,
      p_indirizzo_dom    IN       as4_anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL,
      p_provincia_dom    IN       as4_anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL,
      p_comune_dom       IN       as4_anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL,
      p_cap_dom          IN       as4_anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL,
      p_tel_dom          IN       as4_anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL,
      p_fax_dom          IN       as4_anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL,
      p_indirizzo_web    IN       as4_anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL,
      p_note             IN       as4_anagrafe_soggetti.note%TYPE DEFAULT NULL,
      p_competenza       IN       as4_anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL,
      p_comp_escl        IN       as4_anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL,
      p_utente           IN       as4_anagrafe_soggetti.utente%TYPE
            DEFAULT NULL,
      p_modifica         IN       VARCHAR2 DEFAULT 'T',
      p_batch                 IN       NUMBER default 0
   )
   IS
      v_trovato   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO v_trovato
        FROM all_procedures
       WHERE object_name = 'ANAGRAFE_SOGGETTI_PKG'
         AND procedure_name = 'EXISTS_SLAVE';

      IF v_trovato > 0
      THEN
         EXECUTE IMMEDIATE 'SELECT AS4_ANAGRAFE_SOGGETTI_PKG.EXISTS_SLAVE FROM DUAL'
                      INTO v_trovato;

         IF v_trovato > 0
         THEN
            upd_soggetto_refresh( P_SOGGETTO, P_DAL, P_COGNOME, P_NOME, P_SESSO, P_DATA_NASCITA, P_PROVINCIA_NAS, P_COMUNE_NAS, P_CODICE_FISCALE, P_PARTITA_IVA, P_INDIRIZZO, P_PROVINCIA, P_COMUNE, P_CAP, P_TEL, P_FAX, P_PRESSO, P_INDIRIZZO_DOM, P_PROVINCIA_DOM, P_COMUNE_DOM, P_CAP_DOM, P_TEL_DOM, P_FAX_DOM, P_INDIRIZZO_WEB, P_NOTE, P_COMPETENZA, P_COMP_ESCL, P_UTENTE, P_MODIFICA);
         END IF;
      END IF;

      IF v_trovato = 0
      THEN
         UPD_SOGGETTO( P_SOGGETTO, P_DAL, P_COGNOME, P_NOME, P_SESSO, P_DATA_NASCITA, P_PROVINCIA_NAS, P_COMUNE_NAS, P_CODICE_FISCALE, P_PARTITA_IVA, P_INDIRIZZO, P_PROVINCIA, P_COMUNE, P_CAP, P_TEL, P_FAX, P_PRESSO, P_INDIRIZZO_DOM, P_PROVINCIA_DOM, P_COMUNE_DOM, P_CAP_DOM, P_TEL_DOM, P_FAX_DOM, P_INDIRIZZO_WEB, P_NOTE, P_COMPETENZA, P_COMP_ESCL, P_UTENTE, P_MODIFICA, P_BATCH );
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END update_soggetto;

   PROCEDURE update_soggetto
    ( p_soggetto              IN OUT   as4_anagrafe_soggetti.ni%TYPE,
      p_dal                   IN OUT   VARCHAR2,
      p_cognome               IN       as4_anagrafe_soggetti.cognome%TYPE,
      p_nome                  IN       as4_anagrafe_soggetti.nome%TYPE DEFAULT NULL,
      p_sesso                 IN       as4_anagrafe_soggetti.sesso%TYPE DEFAULT NULL,
      p_data_nascita          IN       VARCHAR2 DEFAULT NULL,
      p_sigla_provincia_nas   IN       VARCHAR2 DEFAULT NULL,
      p_den_comune_nas        IN       VARCHAR2 DEFAULT NULL,
      p_codice_fiscale        IN       as4_anagrafe_soggetti.codice_fiscale%TYPE DEFAULT NULL,
      p_partita_iva           IN       as4_anagrafe_soggetti.partita_iva%TYPE DEFAULT NULL,
      p_indirizzo             IN       as4_anagrafe_soggetti.indirizzo_res%TYPE DEFAULT NULL,
      p_sigla_provincia       IN       VARCHAR2 DEFAULT NULL,
      p_den_comune            IN       VARCHAR2 DEFAULT NULL,
      p_cap                   IN       as4_anagrafe_soggetti.cap_res%TYPE DEFAULT NULL,
      p_tel                   IN       as4_anagrafe_soggetti.tel_res%TYPE DEFAULT NULL,
      p_fax                   IN       as4_anagrafe_soggetti.fax_res%TYPE DEFAULT NULL,
      p_presso                IN       as4_anagrafe_soggetti.presso%TYPE DEFAULT NULL,
      p_indirizzo_dom         IN       as4_anagrafe_soggetti.indirizzo_dom%TYPE DEFAULT NULL,
      p_sigla_provincia_dom   IN       VARCHAR2 DEFAULT NULL,
      p_den_comune_dom        IN       VARCHAR2 DEFAULT NULL,
      p_cap_dom               IN       as4_anagrafe_soggetti.cap_dom%TYPE DEFAULT NULL,
      p_tel_dom               IN       as4_anagrafe_soggetti.tel_dom%TYPE DEFAULT NULL,
      p_fax_dom               IN       as4_anagrafe_soggetti.fax_dom%TYPE DEFAULT NULL,
      p_indirizzo_web         IN       as4_anagrafe_soggetti.indirizzo_web%TYPE DEFAULT NULL,
      p_note                  IN       as4_anagrafe_soggetti.note%TYPE DEFAULT NULL,
      p_competenza            IN       as4_anagrafe_soggetti.competenza%TYPE DEFAULT NULL,
      p_comp_escl             IN       as4_anagrafe_soggetti.competenza_esclusiva%TYPE DEFAULT NULL,
      p_utente                IN       as4_anagrafe_soggetti.utente%TYPE DEFAULT NULL,
      p_modifica              IN       VARCHAR2 DEFAULT 'T',
      p_batch                 IN       NUMBER default 0
   )
   IS
      d_provincia_nas          as4_anagrafe_soggetti.provincia_nas%TYPE;
      d_comune_nas             as4_anagrafe_soggetti.comune_nas%TYPE;
      d_sigla_provincia_nas    ad4_province.sigla%TYPE := p_sigla_provincia_nas;
      d_cap_nas                as4_anagrafe_soggetti.cap_res%TYPE;
      d_provincia              as4_anagrafe_soggetti.provincia_res%TYPE;
      d_comune                 as4_anagrafe_soggetti.comune_res%TYPE;
      d_sigla_provincia        ad4_province.sigla%TYPE := p_sigla_provincia;
      d_cap                    as4_anagrafe_soggetti.cap_res%TYPE := p_cap;
      d_provincia_dom          as4_anagrafe_soggetti.provincia_dom%TYPE;
      d_comune_dom             as4_anagrafe_soggetti.comune_dom%TYPE;
      d_sigla_provincia_dom    ad4_province.sigla%TYPE := p_sigla_provincia_dom;
      d_cap_dom                as4_anagrafe_soggetti.cap_dom%TYPE := p_cap_dom;
   BEGIN
      if p_den_comune_nas is not null then
         d_comune_nas := get_comune(p_den_comune_nas, d_cap_nas, d_sigla_provincia_nas, d_provincia_nas);
      elsif d_sigla_provincia_nas is not null then
         d_provincia_nas := get_provincia(p_sigla => d_sigla_provincia_nas);
      end if;

      if p_den_comune is not null then
         d_comune := get_comune(p_den_comune, d_cap, d_sigla_provincia, d_provincia);
      elsif d_sigla_provincia is not null then
         d_provincia := get_provincia(p_sigla => d_sigla_provincia);
      end if;

      if p_den_comune_dom is not null then
         d_comune_dom := get_comune(p_den_comune_dom, d_cap_dom, d_sigla_provincia_dom, d_provincia_dom);
      elsif d_sigla_provincia_dom is not null then
         d_provincia_dom := get_provincia(p_sigla => d_sigla_provincia_dom);
      end if;

      update_soggetto( p_soggetto, p_dal, p_cognome, p_nome, p_sesso, p_data_nascita, d_provincia_nas, d_comune_nas, p_codice_fiscale, p_partita_iva, p_indirizzo, d_provincia, d_comune, d_cap, p_tel, p_fax, p_presso, p_indirizzo_dom, d_provincia_dom, d_comune_dom, d_cap_dom, p_tel_dom, p_fax_dom, p_indirizzo_web, p_note, p_competenza, p_comp_escl, p_utente, p_modifica, p_batch );
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END update_soggetto;
END ag_soggetto;
/
