--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_UTILITY_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE agp_utility_pkg
IS
   /******************************************************************************
    NOME        AGP_UTILITY_PKG
    DESCRIZIONE: package di utility (utilizzate nei modelli di testo).
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    00    13/06/2017    mmalferrari   Prima emissione.
    01    12/04/2018    mmalferrari   Creata funzione get_funzionario_documento
    02    31/10/2018    mmalferrari   Create get_delegante, get_firmatario_effettivo
                                      e get_descrizione_firmatario.
    03    07/01/2019    mmalferrari   Create get_firmatario_doc_cognome,
                                      get_firmatario_doc_nome,
                                      get_firmatario_eff_cognome,
                                      get_firmatario_eff_nome
    04    17/10/2019    mfrancesconi  Creata funzione get_corrispondenti_protocollo
    05    09/01/2020    mmalferrari   Creata get_id_ente
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.05';

   TYPE split_tbl IS TABLE OF VARCHAR2 (32767);

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_codice_unita (p_unita_progr NUMBER, p_unita_dal DATE)
      RETURN VARCHAR2;

   FUNCTION get_cognome (p_ni NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_nome (p_ni NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_cognome_nome (p_ni NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_cognome_nome (p_utente VARCHAR2)
      RETURN VARCHAR2;


   FUNCTION get_firmatario_documento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_in_firma        VARCHAR2 DEFAULT 'Y',
                                      p_solo_nome       VARCHAR2 DEFAULT 'N',
                                      p_solo_cognome    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2;

   FUNCTION get_firmatario_doc_cognome (
      p_id_documento    NUMBER,
      p_utente          VARCHAR2,
      p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2;

   FUNCTION get_firmatario_doc_nome (
      p_id_documento    NUMBER,
      p_utente          VARCHAR2,
      p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2;

   FUNCTION get_classificazione_protocollo (p_id_documento    NUMBER,
                                            p_utente          VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_anno_fasc_protocollo (p_id_documento      NUMBER,
                                      p_utente            VARCHAR2,
                                      p_calcola_subito    NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION get_numero_fasc_protocollo (p_id_documento      NUMBER,
                                        p_utente            VARCHAR2,
                                        p_calcola_subito    NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION get_oggetto_protocollo (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_desc_ascendenti_unita (p_codice_uo     VARCHAR2,
                                       p_data          DATE DEFAULT NULL,
                                       p_ottica        VARCHAR2,
                                       p_separatore    VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION get_ni_soggetto (p_utente IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_suddivisione_descrizione (p_unita_progr     NUMBER,
                                          p_unita_dal       DATE,
                                          p_suddivisione    VARCHAR2,
                                          p_id_ente         NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_uo_descrizione (p_unita_progr NUMBER, p_unita_dal DATE)
      RETURN VARCHAR2;

   FUNCTION get_uo_padre_descrizione (p_unita_progr    NUMBER,
                                      p_unita_dal      DATE,
                                      p_ottica         VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION giorno_lettere (p_data IN DATE)
      RETURN VARCHAR2;

   FUNCTION mese_lettere (a_numero IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION numero_lettere (a_numero IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION join_str (p_cursor SYS_REFCURSOR, p_del VARCHAR2 := ',')
      RETURN VARCHAR2;

   FUNCTION join_clob (p_cursor SYS_REFCURSOR, p_del VARCHAR2 := ',')
      RETURN CLOB;

   FUNCTION split_str (p_list VARCHAR2, p_del VARCHAR2 := ',')
      RETURN split_tbl
      PIPELINED;

   FUNCTION get_data_firma_documento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2;

   FUNCTION get_descrizione_firmatario (p_utente VARCHAR2, p_id_ente NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_delegante (p_firmatario    VARCHAR2,
                           p_utente        VARCHAR2,
                           p_id_ente       NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_suddivisione_protocollo (p_id_documento    NUMBER,
                                         p_suddivisione    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_funzionario_documento (p_id_documento      NUMBER,
                                       p_utente            VARCHAR2,
                                       p_calcola_subito    NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   PROCEDURE aggiorna_codice_ente (
      p_codice_ente_new    VARCHAR2,
      p_codice_ente_old    VARCHAR2 DEFAULT NULL,
      p_check_old          NUMBER DEFAULT 0);

   FUNCTION get_delegante (p_id_documento    NUMBER,
                           p_utente          VARCHAR2,
                           p_id_ente         NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_firmatario_eff_cognome (
      p_id_documento    NUMBER,
      p_utente          VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_firmatario_eff_nome (
      p_id_documento    NUMBER,
      p_utente          VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_firmatario_effettivo (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_solo_nome       VARCHAR2 DEFAULT 'N',
                                      p_solo_cognome    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2;

   FUNCTION get_descrizione_firmatario (p_id_documento    NUMBER,
                                        p_utente          VARCHAR2,
                                        p_id_ente         NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_corrispondenti_protocollo (p_id_documento    NUMBER,
                                           p_tipo_corrispondente   VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_id_ente (p_codice_amm VARCHAR2, p_codice_aoo VARCHAR2, p_ottica VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY agp_utility_pkg
IS
   /******************************************************************************
    NOME        AGP_UTILITY_PKG
    DESCRIZIONE: package di utility (utilizzate nei modelli di testo).
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   13/06/2017    mmalferrari   Prima emissione.
    001   12/04/2018    mmalferrari   Creata funzione get_funzionario_documento
    002   17/07/2018    mmalferrari   Modificate get_anno_fasc_protocollo e
                                      get_numero_fasc_protocollo
    003   31/10/2018    mmalferrari   Create get_delegante, get_firmatario_effettivo
                                      e get_descrizione_firmatario.
    004   07/01/2019    mmalferrari   Create get_firmatario_doc_cognome,
                                      get_firmatario_doc_nome,
                                      get_firmatario_eff_cognome,
                                      get_firmatario_eff_nome
    005   17/10/2019    mfrancesconi  Creata funzione get_corrispondenti_protocollo
    006   09/01/2020    mmalferrari   Creata get_id_ente
    007   11/08/2020    mmalferrari   Gestione tabella AGS_FASCICOLI (sostituita alla vista)
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '007';

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
   END;

   FUNCTION get_codice_unita (p_unita_progr NUMBER, p_unita_dal DATE)
      RETURN VARCHAR2
   /***************************************************************
   Funzione che restituisce il codice di unità su SO4
   ***************************************************************/
   IS
      d_codice_desc   VARCHAR2 (255) := NULL;
   BEGIN
      BEGIN
         d_codice_desc :=
            so4_util.anuo_get_codice_uo (p_unita_progr, p_unita_dal);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_codice_desc := NULL;
      END;

      RETURN d_codice_desc;
   END get_codice_unita;

   FUNCTION get_cognome (p_ni NUMBER)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL COGNOME||' '||NOME DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
       ******************************************************************************/
      d_cognome_nome   VARCHAR2 (500);
   BEGIN
      IF (p_ni IS NULL)
      THEN
         RETURN '';
      END IF;

      BEGIN
         SELECT cognome
           INTO d_cognome_nome
           FROM as4_v_soggetti_correnti
          WHERE ni = p_ni AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto

         -- in anagrafica ha più di un utente collegato:
         -- in tali casi infatti nella vista as4_v_soggetti_correnti
         -- ci sono più righe con stesso ni.

         RETURN d_cognome_nome;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
            -- comunque funzioni.
            RETURN '';
      END;
   END get_cognome;

   FUNCTION get_cognome_nome (p_ni NUMBER)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL COGNOME||' '||NOME DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
       ******************************************************************************/
      d_cognome_nome   VARCHAR2 (500);
   BEGIN
      IF (p_ni IS NULL)
      THEN
         RETURN '';
      END IF;

      BEGIN
         SELECT cognome || ' ' || nome
           INTO d_cognome_nome
           FROM as4_v_soggetti_correnti
          WHERE ni = p_ni AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto

         -- in anagrafica ha più di un utente collegato:
         -- in tali casi infatti nella vista as4_v_soggetti_correnti
         -- ci sono più righe con stesso ni.

         RETURN d_cognome_nome;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
            -- comunque funzioni.
            RETURN '';
      END;
   END get_cognome_nome;

   FUNCTION get_cognome_nome (p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL COGNOME||' '||NOME DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
       ******************************************************************************/
      d_cognome_nome   VARCHAR2 (500);
   BEGIN
      IF (p_utente IS NULL)
      THEN
         RETURN '';
      END IF;

      BEGIN
         SELECT cognome || ' ' || nome
           INTO d_cognome_nome
           FROM as4_v_soggetti_correnti
          WHERE utente = p_utente AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto

         -- in anagrafica ha più di un utente collegato:
         -- in tali casi infatti nella vista as4_v_soggetti_correnti
         -- ci sono più righe con stesso ni.

         RETURN d_cognome_nome;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
            -- comunque funzioni.
            RETURN '';
      END;
   END get_cognome_nome;

   FUNCTION get_firmatario_doc_nome (p_id_documento    NUMBER,
                                     p_utente          VARCHAR2,
                                     p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_firmatario_documento (p_id_documento,
                                       p_utente,
                                       p_in_firma,
                                       'Y');
   END;

   FUNCTION get_firmatario_doc_cognome (
      p_id_documento    NUMBER,
      p_utente          VARCHAR2,
      p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_firmatario_documento (p_id_documento,
                                       p_utente,
                                       p_in_firma,
                                       'N',
                                       'Y');
   END;

   FUNCTION get_firmatario_documento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_in_firma        VARCHAR2 DEFAULT 'Y',
                                      p_solo_nome       VARCHAR2 DEFAULT 'N',
                                      p_solo_cognome    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL COGNOME||' '||NOME DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
       ******************************************************************************/
      d_in_firma   VARCHAR2 (100);
      d_return     VARCHAR2 (4000) := '';
   BEGIN
      IF p_in_firma = 'Y'
      THEN
         IF p_utente IS NOT NULL
         THEN
            BEGIN
               SELECT 'Y'
                 INTO d_in_firma
                 FROM GDO_CODA_FIRMA
                WHERE     id_documento = p_id_documento
                      AND UTENTE_FIRMATARIO = p_utente
                      AND DATA_FIRMA IS NOT NULL
                      AND FIRMATO = 'N';

               IF d_in_firma = 'Y'
               THEN
                  BEGIN
                     SELECT    DECODE (p_solo_nome, 'Y', '', cognome)
                            || DECODE (p_solo_nome,
                                       'Y', '',
                                       DECODE (p_solo_cognome, 'Y', '', ' '))
                            || DECODE (p_solo_cognome, 'Y', '', nome)
                       INTO d_return
                       FROM as4_v_soggetti_correnti
                      WHERE utente = p_utente AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto
                               -- in anagrafica ha più di un utente collegato:
                   -- in tali casi infatti nella vista as4_v_soggetti_correnti
                                           -- ci sono più righe con stesso ni.
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
                        -- comunque funzioni.
                        d_return := '';
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_return := '';
            END;
         END IF;
      ELSE
         SELECT    DECODE (p_solo_nome, 'Y', '', cognome)
                || DECODE (p_solo_nome,
                           'Y', '',
                           DECODE (p_solo_cognome, 'Y', '', ' '))
                || DECODE (p_solo_cognome, 'Y', '', nome)
           INTO d_return
           FROM as4_v_soggetti_correnti
          WHERE utente = p_utente AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto
                               -- in anagrafica ha più di un utente collegato:
                   -- in tali casi infatti nella vista as4_v_soggetti_correnti
                                           -- ci sono più righe con stesso ni.
      END IF;

      RETURN d_return;
   END get_firmatario_documento;

   FUNCTION get_nome_firmatario_doc (p_id_documento    NUMBER,
                                     p_utente          VARCHAR2,
                                     p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_firmatario_documento (p_id_documento,
                                       p_utente,
                                       p_in_firma,
                                       'Y');
   END;

   FUNCTION get_cognome_firmatario_doc (
      p_id_documento    NUMBER,
      p_utente          VARCHAR2,
      p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_firmatario_documento (p_id_documento,
                                       p_utente,
                                       p_in_firma,
                                       'N',
                                       'Y');
   END;

   FUNCTION get_firmatario_eff_nome (p_id_documento    NUMBER,
                                     p_utente          VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_firmatario_effettivo (p_id_documento, p_utente, 'Y');
   END;

   FUNCTION get_firmatario_eff_cognome (p_id_documento    NUMBER,
                                        p_utente          VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_firmatario_effettivo (p_id_documento,
                                       p_utente,
                                       'N',
                                       'Y');
   END;

   FUNCTION get_firmatario_effettivo (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_solo_nome       VARCHAR2 DEFAULT 'N',
                                      p_solo_cognome    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL COGNOME||' '||NOME DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
       ******************************************************************************/
      d_in_firma                      VARCHAR2 (100);
      d_utente_firmatario_effettivo   VARCHAR2 (4000);
      d_return                        VARCHAR2 (4000) := '';
   BEGIN
      IF p_utente IS NOT NULL
      THEN
         BEGIN
            SELECT 'Y', utente_firmatario_effettivo
              INTO d_in_firma, d_utente_firmatario_effettivo
              FROM GDO_CODA_FIRMA
             WHERE     id_documento = p_id_documento
                   AND UTENTE_FIRMATARIO = p_utente
                   AND DATA_FIRMA IS NOT NULL
                   AND FIRMATO = 'N';

            IF d_in_firma = 'Y'
            THEN
               BEGIN
                  SELECT    DECODE (p_solo_nome, 'Y', '', cognome)
                         || DECODE (p_solo_nome,
                                    'Y', '',
                                    DECODE (p_solo_cognome, 'Y', '', ' '))
                         || DECODE (p_solo_cognome, 'Y', '', nome)
                    INTO d_return
                    FROM as4_v_soggetti_correnti
                   WHERE     utente =
                                NVL (d_utente_firmatario_effettivo, p_utente)
                         AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto
               -- in anagrafica ha più di un utente collegato:
               -- in tali casi infatti nella vista as4_v_soggetti_correnti
               -- ci sono più righe con stesso ni.
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
                     -- comunque funzioni.
                     d_return := ' ';
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_return := '';
         END;
      END IF;


      RETURN d_return;
   END get_firmatario_effettivo;


   FUNCTION get_data_firma_documento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_in_firma        VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
      d_return     VARCHAR2 (4000) := '';
      d_in_firma   VARCHAR2 (100);
   BEGIN
      IF p_in_firma = 'Y'
      THEN
         IF p_utente IS NOT NULL
         THEN
            BEGIN
               SELECT 'Y'
                 INTO d_in_firma
                 FROM GDO_CODA_FIRMA
                WHERE     id_documento = p_id_documento
                      AND UTENTE_FIRMATARIO = p_utente
                      AND DATA_FIRMA IS NOT NULL
                      AND FIRMATO = 'N';

               IF d_in_firma = 'Y'
               THEN
                  d_return := TO_CHAR (SYSDATE, 'dd/mm/yyyy');
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_return := '';
            END;
         END IF;
      ELSE
         d_return := TO_CHAR (SYSDATE, 'dd/mm/yyyy');
      END IF;

      RETURN d_return;
   END get_data_firma_documento;

   FUNCTION get_classificazione_protocollo (p_id_documento    NUMBER,
                                            p_utente          VARCHAR2)
      RETURN VARCHAR2
   IS
      d_in_firma   VARCHAR2 (100);
      d_return     VARCHAR2 (4000) := '';
   BEGIN
      IF p_utente IS NOT NULL
      THEN
         BEGIN
            SELECT 'Y'
              INTO d_in_firma
              FROM GDO_CODA_FIRMA
             WHERE     id_documento = p_id_documento
                   AND UTENTE_FIRMATARIO = p_utente
                   AND DATA_FIRMA IS NOT NULL
                   AND FIRMATO = 'N';

            IF d_in_firma = 'Y'
            THEN
               BEGIN
                  SELECT NVL (c.classificazione, ' ')
                    INTO d_return
                    FROM agp_protocolli p, ags_classificazioni c
                   WHERE     p.id_documento = p_id_documento
                         AND c.id_classificazione = p.id_classificazione;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
                     -- comunque funzioni.
                     d_return := ' ';
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_return := '';
         END;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_anno_fasc_protocollo (p_id_documento      NUMBER,
                                      p_utente            VARCHAR2,
                                      p_calcola_subito    NUMBER DEFAULT 0)
      RETURN VARCHAR2
   IS
      d_in_firma   VARCHAR2 (100);
      d_return     VARCHAR2 (4000) := '';
   BEGIN
      IF p_calcola_subito = 1
      THEN
         BEGIN
            /*
               Accede ad ags_fascicoli con id_documento_esterno invece che  con
               id_fascicolo perchè possa andare per indice su gdm.seg_fascicoli
            */
            SELECT TO_CHAR (f.anno)
              INTO d_return
              FROM agp_protocolli p, ags_fascicoli f
             WHERE     p.id_documento = p_id_documento
                   AND f.id_documento = p.id_fascicolo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- in caso di errore, ritorno stringa vuota in modo che la stampa
               -- comunque funzioni.
               d_return := '';
         END;
      ELSE
         IF p_utente IS NOT NULL
         THEN
            BEGIN
               SELECT 'Y'
                 INTO d_in_firma
                 FROM GDO_CODA_FIRMA
                WHERE     id_documento = p_id_documento
                      AND UTENTE_FIRMATARIO = p_utente
                      AND DATA_FIRMA IS NOT NULL
                      AND FIRMATO = 'N';

               IF d_in_firma = 'Y'
               THEN
                  BEGIN
                     /*
                        Accede ad ags_fascicoli con id_documento_esterno invece che  con
                        id_fascicolo perchè possa andare per indice su gdm.seg_fascicoli
                     */
                     SELECT NVL (TO_CHAR (f.anno), ' ')
                       INTO d_return
                       FROM agp_protocolli p, ags_fascicoli f
                      WHERE     p.id_documento = p_id_documento
                            AND f.id_documento = p.id_fascicolo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        -- in caso di errore, ritorno stringa vuota in modo che la stampa
                        -- comunque funzioni.
                        d_return := ' ';
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_return := '';
            END;
         END IF;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_numero_fasc_protocollo (p_id_documento      NUMBER,
                                        p_utente            VARCHAR2,
                                        p_calcola_subito    NUMBER DEFAULT 0)
      RETURN VARCHAR2
   IS
      d_in_firma   VARCHAR2 (100);
      d_return     VARCHAR2 (4000) := '';
   BEGIN
      IF p_calcola_subito = 1
      THEN
         BEGIN
            /*
               Accede ad ags_fascicoli con id_documento_esterno invece che  con
               id_fascicolo perchè possa andare per indice su gdm.seg_fascicoli
            */
            SELECT f.numero
              INTO d_return
              FROM agp_protocolli p, ags_fascicoli f
             WHERE     p.id_documento = p_id_documento
                   AND f.id_documento = p.id_fascicolo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- in caso di errore, ritorno stringa vuota in modo che la stampa
               -- comunque funzioni.
               d_return := '';
         END;
      ELSE
         IF p_utente IS NOT NULL
         THEN
            BEGIN
               SELECT 'Y'
                 INTO d_in_firma
                 FROM GDO_CODA_FIRMA
                WHERE     id_documento = p_id_documento
                      AND UTENTE_FIRMATARIO = p_utente
                      AND DATA_FIRMA IS NOT NULL
                      AND FIRMATO = 'N';

               IF d_in_firma = 'Y'
               THEN
                  BEGIN
                     /*
                         Accede ad ags_fascicoli con id_documento_esterno invece che  con
                         id_fascicolo perchè possa andare per indice su gdm.seg_fascicoli
                      */
                     SELECT NVL (f.numero, ' ')
                       INTO d_return
                       FROM agp_protocolli p, ags_fascicoli f
                      WHERE     p.id_documento = p_id_documento
                            AND f.id_documento = p.id_fascicolo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        -- in caso di errore, ritorno stringa vuota in modo che la stampa
                        -- comunque funzioni.
                        d_return := ' ';
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_return := '';
            END;
         END IF;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_nominativo_soggetto (p_id_documento     NUMBER,
                                     p_tipo_soggetto    VARCHAR2)
      RETURN VARCHAR2
   /******************************************************************************
    restituisce il cognome||' '||nome di un soggetto della delibera
   ******************************************************************************/
   IS
      d_utente       VARCHAR2 (255) := NULL;
      d_nominativo   VARCHAR2 (255) := NULL;
   BEGIN
      BEGIN
         SELECT utente
           INTO d_utente
           FROM gdo_documenti_soggetti
          WHERE     id_documento = p_id_documento
                AND tipo_soggetto = p_tipo_soggetto;

         d_nominativo := get_cognome_nome (get_ni_soggetto (d_utente));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_nominativo := NULL;
      END;

      RETURN d_nominativo;
   END;

   FUNCTION get_funzionario_documento (p_id_documento      NUMBER,
                                       p_utente            VARCHAR2,
                                       p_calcola_subito    NUMBER DEFAULT 0)
      RETURN VARCHAR2
   IS
      d_in_firma   VARCHAR2 (100);
      d_return     VARCHAR2 (4000) := '';
   BEGIN
      IF p_calcola_subito = 1
      THEN
         d_return := get_nominativo_soggetto (p_id_documento, 'FUNZIONARIO');
      ELSE
         IF p_utente IS NOT NULL
         THEN
            BEGIN
               SELECT 'Y'
                 INTO d_in_firma
                 FROM GDO_CODA_FIRMA
                WHERE     id_documento = p_id_documento
                      AND UTENTE_FIRMATARIO = p_utente
                      AND DATA_FIRMA IS NOT NULL
                      AND FIRMATO = 'N';

               IF d_in_firma = 'Y'
               THEN
                  d_return :=
                     NVL (
                        get_nominativo_soggetto (p_id_documento,
                                                 'FUNZIONARIO'),
                        ' ');
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_return := '';
            END;
         END IF;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_oggetto_protocollo (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      d_in_firma   VARCHAR2 (100);
      d_return     VARCHAR2 (4000) := '';
   BEGIN
      IF p_utente IS NOT NULL
      THEN
         BEGIN
            SELECT 'Y'
              INTO d_in_firma
              FROM GDO_CODA_FIRMA
             WHERE     id_documento = p_id_documento
                   AND UTENTE_FIRMATARIO = p_utente
                   AND DATA_FIRMA IS NOT NULL
                   AND FIRMATO = 'N';

            IF d_in_firma = 'Y'
            THEN
               BEGIN
                  SELECT p.oggetto
                    INTO d_return
                    FROM agp_protocolli p
                   WHERE p.id_documento = p_id_documento;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- in caso di errore, ritorno stringa vuota in modo che la stampa
                     -- comunque funzioni.
                     d_return := '';
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_return := '';
         END;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_desc_ascendenti_unita (p_codice_uo     VARCHAR2,
                                       p_data          DATE DEFAULT NULL,
                                       p_ottica        VARCHAR2,
                                       p_separatore    VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE LA STRUTTURA DEGLI ASCENDENTI A PARTIRE DALL'UNITA' CON ETICHETTA E SEPARATORE
       ******************************************************************************/

      v_struttura           SYS_REFCURSOR;

      d_ottica              VARCHAR2 (18);
      d_separatore          VARCHAR2 (1) := CHR (10);
      d_desc_suddivisione   VARCHAR2 (60);
      d_result              VARCHAR2 (32000);

      TYPE v_struttura_t IS RECORD
      (
         progr_uo          NUMBER (8),
         codice_uo         VARCHAR2 (50),
         desc_uo           VARCHAR2 (240),
         dal               DATE,
         al                DATE,
         id_suddivisione   NUMBER (8)
      );

      v_struttura_row       v_struttura_t;
   BEGIN
      d_ottica := so4_util.set_ottica_default (p_ottica);

      IF p_separatore IS NOT NULL
      THEN
         d_separatore := p_separatore;
      END IF;

      v_struttura :=
         so4_util.unita_get_ascendenti_sudd (p_codice_uo, p_data, d_ottica);

      IF v_struttura%ISOPEN
      THEN
         LOOP
            FETCH v_struttura INTO v_struttura_row;

            EXIT WHEN v_struttura%NOTFOUND;


            BEGIN
               SELECT descrizione
                 INTO d_desc_suddivisione
                 FROM so4_suddivisioni_struttura
                WHERE     ottica = p_ottica
                      AND id_suddivisione = v_struttura_row.id_suddivisione;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_desc_suddivisione := NULL;
            END;

            d_result :=
                  d_desc_suddivisione
               || ': '
               || v_struttura_row.desc_uo
               || d_separatore
               || d_result;
         END LOOP;
      END IF;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_desc_ascendenti_unita;

   FUNCTION get_ni_soggetto (p_utente IN VARCHAR2)
      /******************************************************************************
        RESTITUISCE NI DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
      ******************************************************************************/
      RETURN NUMBER
   IS
      d_ni   NUMBER;
   BEGIN
      IF (p_utente IS NULL)
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         SELECT ni
           INTO d_ni
           FROM as4_v_soggetti_correnti
          WHERE utente = p_utente AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto

         -- in anagrafica ha più di un utente collegato:
         -- in tali casi infatti nella vista as4_v_soggetti_correnti
         -- ci sono più righe con stesso ni.

         RETURN d_ni;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- in caso di errore, cioè di ni non trovato, ritorno null in modo che la stampa
            -- comunque funzioni.
            RETURN NULL;
      END;
   END get_ni_soggetto;

   FUNCTION get_nome (p_ni NUMBER)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL COGNOME||' '||NOME DEL SOGGETTO LEGGENDO DALLA VISTA AS4_V_SOGGETTI_CORRENTI
       ******************************************************************************/
      d_cognome_nome   VARCHAR2 (500);
   BEGIN
      IF (p_ni IS NULL)
      THEN
         RETURN '';
      END IF;

      BEGIN
         SELECT nome
           INTO d_cognome_nome
           FROM as4_v_soggetti_correnti
          WHERE ni = p_ni AND ROWNUM = 1; -- questo serve per parare i casi (errati) in cui un soggetto

         -- in anagrafica ha più di un utente collegato:
         -- in tali casi infatti nella vista as4_v_soggetti_correnti
         -- ci sono più righe con stesso ni.

         RETURN d_cognome_nome;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- in caso di errore, cioè di ni non trovato, ritorno stringa vuota in modo che la stampa
            -- comunque funzioni.
            RETURN '';
      END;
   END get_nome;

   FUNCTION get_suddivisione_descrizione (p_unita_progr     NUMBER,
                                          p_unita_dal       DATE,
                                          p_suddivisione    VARCHAR2,
                                          p_id_ente         NUMBER)
      RETURN VARCHAR2
   /***************************************************************
   Funzione che restituisce la descrizione di una suddivisione (AREA / SERVIZIO)
   a partire da un'unità su SO4
   ***************************************************************/
   IS
      d_id_suddivisione      NUMBER (19);
      d_suddivisione_progr   NUMBER (19);
      d_ottica               VARCHAR2 (255);
      d_descrizione          VARCHAR2 (4000);
   BEGIN
      d_ottica :=
         gdo_impostazioni_pkg.get_impostazione ('OTTICA_SO4', p_id_ente);

      SELECT id_suddivisione
        INTO d_id_suddivisione
        FROM so4_v_suddivisioni_struttura
       WHERE     codice =
                    gdo_impostazioni_pkg.get_impostazione (p_suddivisione,
                                                           p_id_ente)
             AND ottica = d_ottica;

      d_suddivisione_progr :=
         so4_util.get_area_unita (d_id_suddivisione,
                                  p_unita_progr,
                                  p_unita_dal,
                                  d_ottica);

      d_descrizione := get_uo_descrizione (d_suddivisione_progr, p_unita_dal);

      RETURN d_descrizione;
   END get_suddivisione_descrizione;

   FUNCTION get_uo_descrizione (p_unita_progr NUMBER, p_unita_dal DATE)
      RETURN VARCHAR2
   /***************************************************************
   Funzione che restituisce la descrizione di unità su SO4
   ***************************************************************/
   IS
      d_descrizione   VARCHAR2 (4000);
   BEGIN
      BEGIN
         d_descrizione :=
            so4_util.anuo_get_descrizione (p_unita_progr, p_unita_dal);
      EXCEPTION
         WHEN OTHERS
         THEN
            d_descrizione := '--';
      END;

      RETURN d_descrizione;
   END get_uo_descrizione;

   FUNCTION get_uo_padre_descrizione (p_unita_progr    NUMBER,
                                      p_unita_dal      DATE,
                                      p_ottica         VARCHAR2)
      RETURN VARCHAR2
   /***************************************************************
   Funzione che restituisce la descrizione dell'unità padre su SO4 a partire da un'unità
   ***************************************************************/
   IS
      d_descrizione   VARCHAR2 (4000);
   BEGIN
      BEGIN
         d_descrizione :=
            so4_util.unita_get_unita_padre (p_unita_progr,
                                            p_ottica,
                                            p_unita_dal);

         d_descrizione :=
            SUBSTR (d_descrizione,
                    INSTR (d_descrizione, '#', -1) + 1,
                    LENGTH (d_descrizione) - INSTR (d_descrizione, '#', -1));
      EXCEPTION
         WHEN OTHERS
         THEN
            d_descrizione := '';
      END;

      RETURN d_descrizione;
   END get_uo_padre_descrizione;

   FUNCTION giorno_lettere (p_data IN DATE)
      RETURN VARCHAR2
   IS
      /******************************************************************************
      RESTITUISCE IL GIORNO DELLA SETTIMANA
     ******************************************************************************/
      d_valore     VARCHAR2 (10);
      dep_giorno   VARCHAR2 (10);
   BEGIN
      SELECT TRIM (
                UPPER (TO_CHAR (p_data, 'DAY', 'NLS_DATE_LANGUAGE=italian')))
        INTO dep_giorno
        FROM DUAL;

      IF dep_giorno = 'LUNEDÌ'
      THEN
         d_valore := 'lunedi''';
      ELSIF dep_giorno = 'MARTEDÌ'
      THEN
         d_valore := 'martedi''';
      ELSIF dep_giorno = 'MERCOLEDÌ'
      THEN
         d_valore := 'mercoledi''';
      ELSIF dep_giorno = 'GIOVEDÌ'
      THEN
         d_valore := 'giovedi''';
      ELSIF dep_giorno = 'VENERDÌ'
      THEN
         d_valore := 'venerdi''';
      ELSIF dep_giorno = 'SABATO'
      THEN
         d_valore := 'sabato';
      ELSIF dep_giorno = 'DOMENICA'
      THEN
         d_valore := 'domenica';
      END IF;

      RETURN d_valore;
   END giorno_lettere;

   FUNCTION mese_lettere (a_numero IN NUMBER)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       RESTITUISCE IL MESE IN LETTERE
      ******************************************************************************/
      d_stringa   VARCHAR2 (256);
   BEGIN
      IF a_numero = 1
      THEN
         d_stringa := 'GENNAIO';
      ELSIF a_numero = 2
      THEN
         d_stringa := 'FEBBRAIO';
      ELSIF a_numero = 3
      THEN
         d_stringa := 'MARZO';
      ELSIF a_numero = 4
      THEN
         d_stringa := 'APRILE';
      ELSIF a_numero = 5
      THEN
         d_stringa := 'MAGGIO';
      ELSIF a_numero = 6
      THEN
         d_stringa := 'GIUGNO';
      ELSIF a_numero = 7
      THEN
         d_stringa := 'LUGLIO';
      ELSIF a_numero = 8
      THEN
         d_stringa := 'AGOSTO';
      ELSIF a_numero = 9
      THEN
         d_stringa := 'SETTEMBRE';
      ELSIF a_numero = 10
      THEN
         d_stringa := 'OTTOBRE';
      ELSIF a_numero = 11
      THEN
         d_stringa := 'NOVEMBRE';
      ELSIF a_numero = 12
      THEN
         d_stringa := 'DICEMBRE';
      END IF;

      RETURN LOWER (d_stringa);
   END mese_lettere;

   FUNCTION numero_lettere (a_numero IN NUMBER)
      /******************************************************************************
      RESTITUISCE IL NUMERO IN FORMATO LETTERE
      ******************************************************************************/
      RETURN VARCHAR2
   IS
      d_importo       VARCHAR2 (12);
      d_importo_dec   VARCHAR2 (2);
      d_cifra         NUMBER;
      d_stringa       VARCHAR2 (256);
   BEGIN
      d_stringa := NULL;
      d_importo := LPAD (TO_CHAR (TRUNC (a_numero)), 12, '0');
      d_cifra := MOD (ROUND (a_numero, 2), 1) * 100;

      IF d_cifra > 9
      THEN
         d_importo_dec :=
            RPAD (TO_CHAR (MOD (ROUND (a_numero, 2), 1) * 100), 2, '0');
      ELSE
         d_importo_dec :=
            LPAD (TO_CHAR (MOD (ROUND (a_numero, 2), 1) * 100), 2, '0');
      END IF;

      --
      FOR i IN 1 .. 12
      LOOP
         d_cifra := SUBSTR (d_importo, i, 1);

         --
         /* TEST SULLE CENTINAIA */
         --
         IF i IN (1,
                  4,
                  7,
                  10)
         THEN
            --
            IF d_cifra = 2
            THEN
               d_stringa := d_stringa || 'DUE';
            ELSIF d_cifra = 3
            THEN
               d_stringa := d_stringa || 'TRE';
            ELSIF d_cifra = 4
            THEN
               d_stringa := d_stringa || 'QUATTRO';
            ELSIF d_cifra = 5
            THEN
               d_stringa := d_stringa || 'CINQUE';
            ELSIF d_cifra = 6
            THEN
               d_stringa := d_stringa || 'SEI';
            ELSIF d_cifra = 7
            THEN
               d_stringa := d_stringa || 'SETTE';
            ELSIF d_cifra = 8
            THEN
               d_stringa := d_stringa || 'OTTO';
            ELSIF d_cifra = 9
            THEN
               d_stringa := d_stringa || 'NOVE';
            END IF;

            IF d_cifra != 0
            THEN
               d_stringa := d_stringa || 'CENTO';
            END IF;
         /* TEST SULLE DECINE */
         ELSIF i IN (2,
                     5,
                     8,
                     11)
         THEN
            IF d_cifra = 2
            THEN
               d_stringa := d_stringa || 'VENT';
            ELSIF d_cifra = 3
            THEN
               d_stringa := d_stringa || 'TRENT';
            ELSIF d_cifra = 4
            THEN
               d_stringa := d_stringa || 'QUARANT';
            ELSIF d_cifra = 5
            THEN
               d_stringa := d_stringa || 'CINQUANT';
            ELSIF d_cifra = 6
            THEN
               d_stringa := d_stringa || 'SESSANT';
            ELSIF d_cifra = 7
            THEN
               d_stringa := d_stringa || 'SETTANT';
            ELSIF d_cifra = 8
            THEN
               d_stringa := d_stringa || 'OTTANT';
            ELSIF d_cifra = 9
            THEN
               d_stringa := d_stringa || 'NOVANT';
            END IF;

            IF d_cifra = 2
            THEN
               IF SUBSTR (d_importo, i + 1, 1) IN (1, 8)
               THEN
                  NULL;
               ELSE
                  d_stringa := d_stringa || 'I';
               END IF;
            ELSIF d_cifra > 2
            THEN
               IF SUBSTR (d_importo, i + 1, 1) IN (1, 8)
               THEN
                  NULL;
               ELSE
                  d_stringa := d_stringa || 'A';
               END IF;
            END IF;

            IF d_cifra = 1
            THEN
               IF SUBSTR (d_importo, i + 1, 1) = 0
               THEN
                  d_stringa := d_stringa || 'DIECI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 1
               THEN
                  d_stringa := d_stringa || 'UNDICI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 2
               THEN
                  d_stringa := d_stringa || 'DODICI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 3
               THEN
                  d_stringa := d_stringa || 'TREDICI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 4
               THEN
                  d_stringa := d_stringa || 'QUATTORDICI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 5
               THEN
                  d_stringa := d_stringa || 'QUINDICI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 6
               THEN
                  d_stringa := d_stringa || 'SEDICI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 7
               THEN
                  d_stringa := d_stringa || 'DICIASSETTE';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 8
               THEN
                  d_stringa := d_stringa || 'DICIOTTO';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 9
               THEN
                  d_stringa := d_stringa || 'DICIANNOVE';
               END IF;
            ELSE
               IF SUBSTR (d_importo, i + 1, 1) = 1
               THEN
                  IF SUBSTR (d_importo, i - 1, 3) = '001'
                  THEN
                     IF i IN (2, 5)
                     THEN
                        d_stringa := d_stringa || 'UN';
                     ELSIF i = 11
                     THEN
                        d_stringa := d_stringa || 'UNO';
                     END IF;
                  ELSE
                     d_stringa := d_stringa || 'UNO';
                  END IF;
               ELSIF SUBSTR (d_importo, i + 1, 1) = 2
               THEN
                  d_stringa := d_stringa || 'DUE';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 3
               THEN
                  d_stringa := d_stringa || 'TRE';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 4
               THEN
                  d_stringa := d_stringa || 'QUATTRO';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 5
               THEN
                  d_stringa := d_stringa || 'CINQUE';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 6
               THEN
                  d_stringa := d_stringa || 'SEI';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 7
               THEN
                  d_stringa := d_stringa || 'SETTE';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 8
               THEN
                  d_stringa := d_stringa || 'OTTO';
               ELSIF SUBSTR (d_importo, i + 1, 1) = 9
               THEN
                  d_stringa := d_stringa || 'NOVE';
               END IF;
            END IF;
         END IF;

         --
         IF i = 2
         THEN
            IF SUBSTR (d_importo, 1, 3) = '000'
            THEN
               NULL;
            ELSIF SUBSTR (d_importo, 1, 3) = '001'
            THEN
               d_stringa := d_stringa || 'MILIARDO';
            ELSE
               d_stringa := d_stringa || 'MILIARDI';
            END IF;
         ELSIF i = 5
         THEN
            IF SUBSTR (d_importo, 4, 3) = '000'
            THEN
               NULL;
            ELSIF SUBSTR (d_importo, 4, 3) = '001'
            THEN
               d_stringa := d_stringa || 'MILIONE';
            ELSE
               d_stringa := d_stringa || 'MILIONI';
            END IF;
         ELSIF i = 8
         THEN
            IF SUBSTR (d_importo, 7, 3) = '000'
            THEN
               NULL;
            ELSIF SUBSTR (d_importo, 7, 3) = '001'
            THEN
               d_stringa := d_stringa || 'MILLE';
            ELSE
               d_stringa := d_stringa || 'MILA';
            END IF;
         END IF;
      --
      END LOOP;

      --
      IF d_importo = '000000000000'
      THEN
         d_stringa := 'ZERO';
      END IF;

      --
      IF d_importo_dec != '00'
      THEN
         d_stringa := d_stringa || ' VIRGOLA ';
         d_cifra := SUBSTR (d_importo_dec, 1, 1);

         IF SUBSTR (d_importo_dec, 2, 1) != 0
         THEN
            IF d_cifra = 0
            THEN
               d_stringa := d_stringa || 'ZERO';
            ELSIF d_cifra = 2
            THEN
               d_stringa := d_stringa || 'VENT';
            ELSIF d_cifra = 3
            THEN
               d_stringa := d_stringa || 'TRENT';
            ELSIF d_cifra = 4
            THEN
               d_stringa := d_stringa || 'QUARANT';
            ELSIF d_cifra = 5
            THEN
               d_stringa := d_stringa || 'CINQUANT';
            ELSIF d_cifra = 6
            THEN
               d_stringa := d_stringa || 'SESSANT';
            ELSIF d_cifra = 7
            THEN
               d_stringa := d_stringa || 'SETTANT';
            ELSIF d_cifra = 8
            THEN
               d_stringa := d_stringa || 'OTTANT';
            ELSIF d_cifra = 9
            THEN
               d_stringa := d_stringa || 'NOVANT';
            END IF;

            IF d_cifra = 2
            THEN
               IF SUBSTR (d_importo_dec, 2, 1) IN (1, 8)
               THEN
                  NULL;
               ELSE
                  d_stringa := d_stringa || 'I';
               END IF;
            ELSIF d_cifra > 2
            THEN
               IF SUBSTR (d_importo_dec, 2, 1) IN (1, 8)
               THEN
                  NULL;
               ELSE
                  d_stringa := d_stringa || 'A';
               END IF;
            END IF;

            IF d_cifra = 1
            THEN
               IF SUBSTR (d_importo_dec, 2, 1) = 1
               THEN
                  d_stringa := d_stringa || 'UNDICI';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 2
               THEN
                  d_stringa := d_stringa || 'DODICI';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 3
               THEN
                  d_stringa := d_stringa || 'TREDICI';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 4
               THEN
                  d_stringa := d_stringa || 'QUATTORDICI';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 5
               THEN
                  d_stringa := d_stringa || 'QUINDICI';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 6
               THEN
                  d_stringa := d_stringa || 'SEDICI';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 7
               THEN
                  d_stringa := d_stringa || 'DICIASSETTE';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 8
               THEN
                  d_stringa := d_stringa || 'DICIOTTO';
               ELSIF SUBSTR (d_importo_dec, 2, 1) = 9
               THEN
                  d_stringa := d_stringa || 'DICIANNOVE';
               END IF;
            END IF;
         END IF;

         IF d_cifra = 1 AND SUBSTR (d_importo_dec, 2, 1) > 0
         THEN
            NULL;
         ELSE
            IF SUBSTR (d_importo_dec, 2, 1) != 0
            THEN
               d_cifra := SUBSTR (d_importo_dec, 2, 1);
            END IF;

            IF d_cifra = 1
            THEN
               d_stringa := d_stringa || 'UNO';
            ELSIF d_cifra = 2
            THEN
               d_stringa := d_stringa || 'DUE';
            ELSIF d_cifra = 3
            THEN
               d_stringa := d_stringa || 'TRE';
            ELSIF d_cifra = 4
            THEN
               d_stringa := d_stringa || 'QUATTRO';
            ELSIF d_cifra = 5
            THEN
               d_stringa := d_stringa || 'CINQUE';
            ELSIF d_cifra = 6
            THEN
               d_stringa := d_stringa || 'SEI';
            ELSIF d_cifra = 7
            THEN
               d_stringa := d_stringa || 'SETTE';
            ELSIF d_cifra = 8
            THEN
               d_stringa := d_stringa || 'OTTO';
            ELSIF d_cifra = 9
            THEN
               d_stringa := d_stringa || 'NOVE';
            END IF;
         END IF;
      END IF;

      --
      RETURN LOWER (d_stringa);
   END numero_lettere;

   FUNCTION join_str (p_cursor SYS_REFCURSOR, p_del VARCHAR2 := ',')
      RETURN VARCHAR2
   IS
      l_value    VARCHAR2 (32767);
      l_result   VARCHAR2 (32767);
   BEGIN
      LOOP
         FETCH p_cursor INTO l_value;

         EXIT WHEN p_cursor%NOTFOUND;

         IF l_result IS NOT NULL
         THEN
            l_result := l_result || p_del;
         END IF;

         l_result := l_result || l_value;
      END LOOP;

      RETURN l_result;
   END join_str;

   FUNCTION join_clob (p_cursor SYS_REFCURSOR, p_del VARCHAR2 := ',')
      RETURN CLOB
   IS
      l_value    VARCHAR2 (32767);
      l_result   VARCHAR2 (32767);
      d_clob     CLOB := EMPTY_CLOB ();
   BEGIN
      DBMS_LOB.createtemporary (d_clob, TRUE, DBMS_LOB.call);

      LOOP
         FETCH p_cursor INTO l_value;

         EXIT WHEN p_cursor%NOTFOUND;

         IF d_clob IS NOT NULL
         THEN
            d_clob := d_clob || p_del;
         END IF;

         d_clob := d_clob || l_value;
      END LOOP;

      RETURN d_clob;
      DBMS_LOB.freetemporary (d_clob);
   END join_clob;

   FUNCTION split_str (p_list VARCHAR2, p_del VARCHAR2 := ',')
      RETURN split_tbl
      PIPELINED
   IS
      l_idx     PLS_INTEGER;
      l_list    VARCHAR2 (32767) := p_list;
      l_value   VARCHAR2 (32767);
   BEGIN
      LOOP
         l_idx := INSTR (l_list, p_del);

         IF l_idx > 0
         THEN
            PIPE ROW (SUBSTR (l_list, 1, l_idx - 1));
            l_list := SUBSTR (l_list, l_idx + LENGTH (p_del));
         ELSE
            PIPE ROW (l_list);
            EXIT;
         END IF;
      END LOOP;

      RETURN;
   END split_str;

   FUNCTION get_descrizione_firmatario (p_utente VARCHAR2, p_id_ente NUMBER)
      RETURN VARCHAR2
   IS
      v_utente   VARCHAR2 (4000);
   BEGIN
      IF (p_utente IS NULL)
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         SELECT utente
           INTO v_utente
           FROM so4_v_utenti_ruoli_sogg_uo
          WHERE     utente = p_utente
                AND ruolo =
                       gdo_impostazioni_pkg.get_impostazione (
                          'RUOLO_SO4_DIRIGENTE',
                          p_id_ente)
                AND ROWNUM = 1;

         RETURN gdo_impostazioni_pkg.get_impostazione ('STAMPE_DIRIGENTE',
                                                       p_id_ente);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- in caso di errore, cioè di utente non trovato, vuol dire che non si tratta
            -- del dirigente quindi ritorniamo il testo presente sotto l'impostazione;
            RETURN gdo_impostazioni_pkg.get_impostazione (
                      'STAMPE_FIRMATARIO',
                      p_id_ente);
      END;
   END get_descrizione_firmatario;

   FUNCTION get_descrizione_firmatario (p_id_documento    NUMBER,
                                        p_utente          VARCHAR2,
                                        p_id_ente         NUMBER)
      RETURN VARCHAR2
   IS
      d_in_firma                      VARCHAR2 (100);
      d_utente_firmatario_effettivo   VARCHAR2 (4000);
      d_return                        VARCHAR2 (4000) := '';
   BEGIN
      IF p_utente IS NOT NULL
      THEN
         BEGIN
            SELECT 'Y', utente_firmatario_effettivo
              INTO d_in_firma, d_utente_firmatario_effettivo
              FROM GDO_CODA_FIRMA
             WHERE     id_documento = p_id_documento
                   AND UTENTE_FIRMATARIO = p_utente
                   AND DATA_FIRMA IS NOT NULL
                   AND FIRMATO = 'N';

            IF d_in_firma = 'Y'
            THEN
               RETURN NVL (
                         get_descrizione_firmatario (
                            d_utente_firmatario_effettivo,
                            p_id_ente),
                         ' ');
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_return := '';
         END;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_delegante (p_firmatario    VARCHAR2,
                           p_utente        VARCHAR2,
                           p_id_ente       NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      IF (p_utente IS NULL)
      THEN
         RETURN NULL;
      END IF;

      IF (p_firmatario IS NOT NULL AND p_firmatario <> p_utente)
      THEN
         RETURN    '('
                || gdo_impostazioni_pkg.get_impostazione ('STAMPE_DELEGATO',
                                                          p_id_ente)
                || ' '
                || get_cognome_nome (get_ni_soggetto (p_utente))
                || ')';
      END IF;

      RETURN '';
   END get_delegante;

   FUNCTION get_delegante (p_id_documento    NUMBER,
                           p_utente          VARCHAR2,
                           p_id_ente         NUMBER)
      RETURN VARCHAR2
   IS
      d_in_firma                      VARCHAR2 (100);
      d_utente_firmatario_effettivo   VARCHAR2 (4000);
      d_return                        VARCHAR2 (4000) := '';
   BEGIN
      IF p_utente IS NOT NULL
      THEN
         BEGIN
            SELECT 'Y', utente_firmatario_effettivo
              INTO d_in_firma, d_utente_firmatario_effettivo
              FROM GDO_CODA_FIRMA
             WHERE     id_documento = p_id_documento
                   AND UTENTE_FIRMATARIO = p_utente
                   AND DATA_FIRMA IS NOT NULL
                   AND FIRMATO = 'N';

            IF d_in_firma = 'Y'
            THEN
               RETURN NVL (
                         get_delegante (d_utente_firmatario_effettivo,
                                        p_utente,
                                        p_id_ente),
                         ' ');
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_return := '';
         END;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_suddivisione_protocollo (p_id_documento    NUMBER,
                                         p_suddivisione    VARCHAR2)
      RETURN VARCHAR2
   /***************************************************************
    Funzione che restituisce la descrizione della suddivisione in
    base al codice richiesto.
    Il calcolo viene fatto a partire dall'unità  protocollante.
   ***************************************************************/
   IS
      d_unita_progr    NUMBER (19);
      d_unita_dal      DATE;
      d_suddivisione   VARCHAR2 (255) := NULL;
      d_id_ente        NUMBER;
   BEGIN
      BEGIN
         SELECT ds.unita_progr, NVL (p.data, d.data_ins), d.id_ente
           INTO d_unita_progr, d_unita_dal, d_id_ente
           FROM gdo_documenti_soggetti ds, agp_protocolli p, gdo_documenti d
          WHERE     ds.id_documento = p.id_documento
                AND p.id_documento = p_id_documento
                AND tipo_soggetto = 'UO_PROTOCOLLANTE'
                AND d.id_documento = p.id_documento;

         d_suddivisione :=
            get_suddivisione_descrizione (d_unita_progr,
                                          d_unita_dal,
                                          p_suddivisione,
                                          d_id_ente);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_suddivisione := NULL;
      END;

      RETURN d_suddivisione;
   END get_suddivisione_protocollo;

   PROCEDURE aggiorna_codice_ente (
      p_codice_ente_new    VARCHAR2,
      p_codice_ente_old    VARCHAR2 DEFAULT NULL,
      p_check_old          NUMBER DEFAULT 0)
   AS
      dep_stmt   VARCHAR2 (32000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FOR tabelle
         IN (SELECT user_tab_columns.table_name nome
               FROM user_tab_columns, tab
              WHERE     user_tab_columns.column_name = 'ENTE'
                    AND tab.tname = user_tab_columns.table_name
                    AND tab.tabtype = 'TABLE'
                    AND tab.tname NOT LIKE 'BIN$%')
      LOOP
         dep_stmt := '';
         dep_stmt :=
               'update '
            || tabelle.nome
            || ' set ente = '''
            || UPPER (p_codice_ente_new)
            || '''';

         IF p_check_old = 1
         THEN
            dep_stmt := dep_stmt || ' where ente ';

            IF p_codice_ente_old IS NOT NULL
            THEN
               dep_stmt := dep_stmt || ' = ''' || p_codice_ente_old || '''';
            ELSE
               dep_stmt := dep_stmt || 'is null ';
            END IF;
         END IF;

         EXECUTE IMMEDIATE dep_stmt;

         COMMIT;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
         ROLLBACK;
   END;

   FUNCTION get_corrispondenti_protocollo (p_id_documento           NUMBER,
                                           p_tipo_corrispondente    VARCHAR2)
      RETURN VARCHAR2
   /************************************************************************
    Funzione che restituisce l'elenco dei corrispondenti di un protocollo
   ************************************************************************/
   IS
      d_return   VARCHAR2 (4000) := NULL;
   BEGIN
      BEGIN
            SELECT list mitt_dest
                 INTO d_return
                 FROM (SELECT *
                         FROM (SELECT id_documento,
                                      id_protocollo_corrispondente,
                                      denominazione
                                       || DECODE (codice_fiscale, NULL, NULL, ' - C.F.: ' || codice_fiscale)
                                       || DECODE (partita_iva, NULL, NULL, ' P.I.: ' || partita_iva)
                                       || DECODE (indirizzo, NULL, NULL, ' - ' || indirizzo)
                                       || DECODE (comune, NULL, NULL, ' ' || comune)
                                       || DECODE (provincia_sigla, NULL, NULL, ' (' || provincia_sigla || ')')
                                       || DECODE (cap, NULL, NULL, ' C.A.P. ' || cap)
                                       || DECODE (email, NULL, NULL, ' - ' || email)
                                          corrispondente,
                                      LAG (id_documento)
                                         OVER (PARTITION BY id_documento ORDER BY id_protocollo_corrispondente)
                                         prior_table
                                FROM agp_protocolli_corrispondenti
                                WHERE id_documento = p_id_documento AND tipo_corrispondente = p_tipo_corrispondente)
                       MODEL
                          DIMENSION BY (id_documento, ROW_NUMBER ()
                                               OVER (PARTITION BY id_documento
                                                     ORDER BY id_protocollo_corrispondente) rn)
                          MEASURES (corrispondente, prior_table, CAST (NULL AS VARCHAR2 (4000)) list, COUNT (
                                                                                                  *)
                                                                                               OVER (
                                                                                                  PARTITION BY id_documento) cnt, ROW_NUMBER ()
                                                                                                                           OVER (
                                                                                                                              PARTITION BY id_documento
                                                                                                                              ORDER BY
                                                                                                                                 id_protocollo_corrispondente) rnk)
                          RULES
                             (list [ANY, ANY]
                                ORDER BY id_documento, rn =
                                   CASE
                                      WHEN prior_table[CV (), CV ()] IS NULL
                                      THEN
                                         corrispondente[CV (), CV ()]
                                      ELSE
                                            corrispondente[CV (), CV ()]
                                         --|| ','
                                         || CHR (13) || CHR (10)
                                         || list[CV (), rnk[CV (), CV ()] - 1]
                                   END))
                WHERE cnt = rn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := NULL;
      END;

      RETURN d_return;
   END get_corrispondenti_protocollo;

   FUNCTION get_id_ente (p_codice_amm    VARCHAR2,
                         p_codice_aoo    VARCHAR2,
                         p_ottica        VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      SELECT ID_ENTE
        INTO d_return
        FROM GDO_ENTI
       WHERE     amministrazione = p_codice_amm
             AND aoo = p_codice_aoo
             AND ottica IN NVL (p_ottica,
                                (SELECT gdm_ag_parametro.get_valore (
                                           'SO_OTTICA_PROT',
                                           p_codice_amm,
                                           p_codice_aoo,
                                           '')
                                   FROM DUAL));

      RETURN d_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 1;
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;
END;
/
