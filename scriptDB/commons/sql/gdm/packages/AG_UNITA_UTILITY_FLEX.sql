--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UNITA_UTILITY_FLEX runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     ag_unita_utility_flex
IS
/******************************************************************************
 NOME:        ag_unita_utility_flex
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI
              per la gestione delle unitÃ  mediante alberi
 ANNOTAZIONI:

 REVISIONI:   .

 Rev.    Data        Autore   Descrizione.
 00      30/07/2008  SN       Prima emissione.
 01      20/05/2010  MM       Modificata get_tree_smistamenti_utente per gestire
                              ricerca nell'albero delle unita'/componenti.
 02      24/08/2011  MM       Tolte dallo specification tutte le funzioni private.
 03      16/05/2012  DN       Aggiunte get_tree e get_ramo.
******************************************************************************/
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.03';

   FUNCTION versione
      RETURN VARCHAR2;
FUNCTION get_invalidcharescseq (p_stringa IN VARCHAR2)
      RETURN VARCHAR2;
/******************************************************************************
 NOME:        get_tree_smistamenti_utente
 DESCRIZIONE: Dato utente, codice amministrazione, codice aoo, restituisce il ramo di tree view
                delle unita dell'aoo in questione, alle quali p_utente puo' smistare.
                Vengono elencati anche i componenti sotto le unita' per le quali p_utente
                ha privilegio ASS, oppure se ha genericamente il privilegio ASSTOT.
                L'utente smista a tutte le unita se ha privilegio SMISTATUTTI.
                Se invece ha privilegio SMISTAAREA, smista solo all'interno
                del ramo delle unita per le quali ha codesto privilegio.

 PARAMETRI:   p_utente   codice utente
                p_Codice_Amministrazione codice dell'amministrazione per la quale p_utente lavora
                p_codice_aoo codice dell'aoo per la quale p_utente lavora

 RITORNA:     clob    xml nel formato:<uo id=".." nome = ""><componente id ="" nome ="" /></uo>
******************************************************************************/
   FUNCTION get_tree (
      p_codice_amministrazione        VARCHAR2,
      p_codice_aoo                    VARCHAR2,
      p_ricerca                  IN   VARCHAR2 DEFAULT ''
   )
      RETURN CLOB;

/******************************************************************************
 NOME:        get_tree_smistamenti_utente
 DESCRIZIONE: Dato utente, codice amministrazione, codice aoo, restituisce il ramo di tree view
                delle unita dell'aoo in questione, alle quali p_utente puo' smistare.
                Vengono elencati anche i componenti sotto le unita' per le quali p_utente
                ha privilegio ASS, oppure se ha genericamente il privilegio ASSTOT.
                L'utente smista a tutte le unita se ha privilegio SMISTATUTTI.
                Se invece ha privilegio SMISTAAREA, smista solo all'interno
                del ramo delle unita per le quali ha codesto privilegio.

 PARAMETRI:   p_utente   codice utente
                p_Codice_Amministrazione codice dell'amministrazione per la quale p_utente lavora
                p_codice_aoo codice dell'aoo per la quale p_utente lavora

 RITORNA:     clob    xml nel formato:<uo id=".." nome = ""><componente id ="" nome ="" /></uo>
******************************************************************************/
   PROCEDURE get_unita_figlie_e_componenti (
      p_unita                    IN       VARCHAR2,
      p_codice_amministrazione   IN       VARCHAR2,
      p_codice_aoo               IN       VARCHAR2,
      p_utente                   IN       ad4_utenti.utente%TYPE,
      p_ottica                   IN       VARCHAR2,
      p_assegnautti              IN       NUMBER,
      p_clob                     IN OUT   CLOB,
      p_livello                  IN       NUMBER DEFAULT NULL,
      p_info_abilitazione        IN       NUMBER default 1,
      p_visualizza_comp          IN       NUMBER default 1
   );

   FUNCTION get_tree_smistamenti_utente (
      p_utente                   IN   AD4_UTENTI.UTENTE%TYPE,
      p_codice_amministrazione        VARCHAR2,
      p_codice_aoo                    VARCHAR2,
      p_ricerca                  IN   VARCHAR2 DEFAULT ''
   )
      RETURN CLOB;
   FUNCTION get_tipi_smistamento(
      p_codice_amm               IN   VARCHAR2,
      p_codice_aoo               IN   VARCHAR2,
      p_area                     IN   VARCHAR2,
      p_modello                  IN   VARCHAR2,
      p_modello_obb              IN   VARCHAR2
   )
   RETURN AFC.t_ref_cursor;

   FUNCTION get_default_tipo_smistamento(
      p_idRif                    IN   VARCHAR2,
      p_codice_amm               IN   VARCHAR2,
      p_codice_aoo               IN   VARCHAR2,
      p_area                     IN   VARCHAR2,
      p_modello                  IN   VARCHAR2,
      p_utente                   IN   VARCHAR2,
      p_competenza               IN   VARCHAR2
   )
     RETURN VARCHAR2;

   FUNCTION get_ramo_unita (
      p_unita                   IN   VARCHAR2,
      p_codice_amministrazione  IN   VARCHAR2,
      p_codice_aoo              IN   VARCHAR2,
      p_utente                  IN   AD4_UTENTI.UTENTE%TYPE
   )
      RETURN CLOB;

   FUNCTION get_ramo (
      p_unita                   IN   VARCHAR2,
      p_codice_amministrazione  IN   VARCHAR2,
      p_codice_aoo              IN   VARCHAR2
   )
      RETURN CLOB;

   FUNCTION get_tree_responsabili_fasc (
      p_utente       IN   ad4_utenti.utente%TYPE,
      p_codice_amm   IN   VARCHAR2,
      p_codice_aoo   IN   VARCHAR2
   )
      RETURN CLOB;
END ag_unita_utility_flex;
/
CREATE OR REPLACE PACKAGE BODY ag_unita_utility_flex
IS
   /******************************************************************************
    NOME:        ag_unita_utility_flex
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI
                 per la gestione delle unita'  mediante alberi
    ANNOTAZIONI:

    REVISIONI:   .

    Rev. Data        Autore   Descrizione.
    000  30/07/2008  SN       Prima emissione.
    001  20/05/2010  MM       Modificata get_tree_smistamenti_utente per gestire
                              ricerca nell'albero delle unita'/componenti.
    002  24/08/2011  MM       A45326.0.0: Per evitare che gli utenti smistino ad
                              unita' che non hanno componenti abilitati all'utilizzo
                              del sistema di protocollo sarebbe opportuno aggiungere
                              un'indicazione in cui si specifica che l'unita' non
                              ha componenti abilitati.
                              Modificate:
                              get_componenti_unita, get_unita_figlie_e_componenti,
                              get_tree_smistamenti_utente, is_unita_con_componenti
    003  16/05/2012  DN       Aggiunte get_tree e get_ramo.
    004  19/12/2012  MM       Modificate is_unita_valida e unita_get_descrizione
                              in modo che vadano per progressivo.
    005  11/10/2016  MM       Modificata get_componenti_unita in modo che ritorni
                              l'attributo abilitato su ogni componente.
         26/04/2017  SC       RIPORTATO NELLO STANDARD
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '005';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
   NOME:        versione
   DESCRIZIONE: Versione e revisione di distribuzione del package.
   RITORNA:     varchar2 stringa contenente versione e revisione.
   NOTE:        Primo numero  : versione compatibilita'  del Package.
                Secondo numero: revisione del Package specification.
                Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END;

   FUNCTION get_invalidcharescseq (p_stringa IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:         get_invalidCharEscSeq.
       DESCRIZIONE:  Conversione di una stringa nella corrispondente stringa in cui
                     i caratteri '<','>','&','''','"','!',':1' vengono sostituiti con
                     i caratteri di escape XML utilizzando le entita' '' del tipo &#n;
                     dove n corrisponde al valore ASCII a 7 bit del carattere.
       PARAMETRI:    p_stringa IN varchar2: stringa da convertire.
       RITORNA:      varchar2 stringa convertita.
       NOTE:        .
       REVISIONI:
        Rev. Data       Autore Descrizione
        ---- ---------- ------ ------------------------------------------------------
        001 31/07/2008  SN     Creazione.
      ******************************************************************************/
      d_return   VARCHAR2 (32767);
      iloop      INTEGER := 1;
   BEGIN
      WHILE iloop <= LENGTH (p_stringa)
      LOOP
         IF SUBSTR (p_stringa, iloop, 1) IN (CHR (60),                  --'<',
                                             CHR (62),                  --'>',
                                             CHR (38),                  --'&',
                                             CHR (39),                 --'''',
                                             CHR (34),                  --'"',
                                             CHR (33),                  --'!',
                                             CHR (63),                  --'?',
                                             CHR (224),                 --'à',
                                             CHR (232),                 --'è',
                                             CHR (233),                 --'é',
                                             CHR (236),                 --'ì',
                                             CHR (242),                 --'ò',
                                             CHR (249),                 --'ù',
                                             CHR (192),                 --'À',
                                             CHR (200),                 --'È',
                                             CHR (201),                 --'É',
                                             CHR (204),                 --'Ì',
                                             CHR (210),                 --'Ò',
                                             CHR (217),                 --'Ù',
                                             CHR (176),                 --'°',
                                             CHR (163)                   --'£'
                                                      )
         THEN
            d_return :=
                  d_return
               || '&#'
               || ASCII (SUBSTR (p_stringa, iloop, 1))
               || ';';
         ELSE
            d_return := d_return || SUBSTR (p_stringa, iloop, 1);
         END IF;

         iloop := iloop + 1;
      END LOOP;

      RETURN d_return;
   END get_invalidcharescseq;

   PROCEDURE chiudi_tag (p_stringa IN VARCHAR2, p_clob IN OUT CLOB)
   IS
      /******************************************************************************
      NOME:        chiudi_tag

      DESCRIZIONE: chiude l'ultimo tag del clob passato come parametro

      RITORNA:     clob
      Rev.  Data        Autore       Descrizione
      ----  ----------  -----------  ----------------------------------------------------
      0     15/12/2008  SN           Prima emissione.
      ******************************************************************************/
      d_amount   BINARY_INTEGER := 32767;
   BEGIN
      d_amount := LENGTH (p_stringa);
      DBMS_LOB.writeappend (p_clob, d_amount, p_stringa);
   END;

   /*****************************************************************************
    NOME:        get_componenti_unita
    DESCRIZIONE: Restituisce un nodo COMPONENTI contenente l'elenco dei
                 componenti dell'unita' passata come parametro.
    RITORNO:

    ANNOTAZIONI: il parametro p_ramo discrimina da quale funzione del package
                 la get_componenti_unita viene invocata e serve per chiudere
                 correttamente i tag del clob restituito in uscita.
    Rev.  Data       Autore   Descrizione.
    000   03/11/2008 SN       Prima emissione.
    002   24/08/2011 MM       A45326.0.0: Per evitare che gli utenti smistino ad
                              unita' che non hanno componenti abilitati all'utilizzo
                              del sistema di protocollo sarebbe opportuno aggiungere
                              un'indicazione in cui si specifica che l'unita' non
                              ha componenti abilitati.
   ********************************************************************************/
   PROCEDURE get_componenti_unita (
      p_unita               IN     VARCHAR2,
      p_ottica              IN     VARCHAR2,
      p_clob                IN OUT CLOB,
      p_esiste_abilitato    IN OUT NUMBER,
      p_ramo                IN     BOOLEAN DEFAULT TRUE,
      p_get_xml             IN     BOOLEAN DEFAULT TRUE,
      p_info_abilitazione   IN     NUMBER DEFAULT 1)
   IS
      d_utente           ad4_utenti.utente%TYPE;
      d_esiste_comp      BOOLEAN := FALSE;

      TYPE v_componente_type IS RECORD
      (
         ni             as4_anagrafe_soggetti.ni%TYPE,
         des_soggetto   VARCHAR2 (1000),
         codutente      ad4_utenti.utente%TYPE
      );

      v_componente_row   v_componente_type;
      v_componente       afc.t_ref_cursor;

      TYPE v_ruolo_type IS RECORD
      (
         ruolo         ad4_ruoli.ruolo%TYPE,
         descrizione   ad4_ruoli.descrizione%TYPE
      );

      d_esiste_ruolo     INTEGER := 0;
      d_abilitato        VARCHAR2 (1) := 'N';
      d_xml              VARCHAR2 (32000) := '';
      d_amount           BINARY_INTEGER := 32767;
      d_revisione        NUMBER;
      d_progr_unita      NUMBER;
   BEGIN
      p_esiste_abilitato := 0;
      d_revisione := so4_rest_pkg.get_revisione_mod (p_ottica);
      d_progr_unita :=
         so4_ags_pkg.anuo_get_progr (
            p_ottica      => p_ottica,
            p_codice_uo   => p_unita,
            p_data        => so4_ags_pkg.set_data_default (TO_DATE (NULL)));

      IF NOT p_get_xml
      THEN
         BEGIN
            SELECT COUNT (1)
              INTO p_esiste_abilitato
              FROM SO4_VPCO c, SO4_VPRU r
             WHERE     c.ottica = p_ottica
                   AND NVL (c.revisione_assegnazione, -2) != d_revisione
                   AND TRUNC (SYSDATE) BETWEEN r.dal
                                           AND NVL (
                                                  DECODE (
                                                     c.revisione_cessazione,
                                                     d_revisione, TO_DATE (
                                                                     NULL),
                                                     r.al),
                                                  TO_DATE ('3333333', 'j'))
                   AND c.id_componente = r.id_componente
                   AND c.progr_unita_organizzativa = d_progr_unita
                   AND EXISTS
                          (SELECT 1
                             FROM ag_privilegi_ruolo
                            WHERE ruolo = r.ruolo)
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
         END;

         IF p_esiste_abilitato > 0
         THEN
            p_esiste_abilitato := 1;
         ELSE
            BEGIN
               SELECT COUNT (1)
                 INTO p_esiste_abilitato
                 FROM SO4_VPCO c
                WHERE     c.ottica = p_ottica
                      AND NVL (c.revisione_assegnazione, -2) != d_revisione
                      AND TRUNC (SYSDATE) BETWEEN c.dal
                                              AND NVL (
                                                     DECODE (
                                                        c.revisione_cessazione,
                                                        d_revisione, TO_DATE (
                                                                        NULL),
                                                        c.al),
                                                     TO_DATE ('3333333', 'j'))
                      AND c.progr_unita_organizzativa = d_progr_unita
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RAISE;
            END;

            IF p_esiste_abilitato > 0
            THEN
               p_esiste_abilitato := -1;
            END IF;
         END IF;
      ELSE
         v_componente :=
            so4_ags_pkg.unita_get_componenti_ord (p_unita, NULL, p_ottica);

         LOOP
            FETCH v_componente INTO v_componente_row;

            IF v_componente%FOUND
            THEN
               DBMS_OUTPUT.put_line ('v_componente%FOUND');
               p_esiste_abilitato := -1;  -- con componenti senza abilitazione
               d_xml := '';
               d_utente := v_componente_row.codutente;
               DBMS_OUTPUT.put_line (
                  'v_componente_row.codutente ' || v_componente_row.codutente);

               IF d_utente IS NOT NULL
               THEN
                  IF d_esiste_comp = FALSE
                  THEN
                     d_esiste_comp := TRUE;

                     IF p_get_xml
                     THEN
                        IF p_ramo
                        THEN
                           d_xml := '"';
                        END IF;

                        d_xml :=
                              d_xml
                           || '><row componente = "G" nome = "COMPONENTI" >';
                     END IF;
                  END IF;

                  d_esiste_ruolo := 0;

                  DBMS_OUTPUT.put_line (
                     'v_componente_row.ni ' || v_componente_row.ni);

                  BEGIN
                     SELECT 1
                       INTO d_esiste_ruolo
                       FROM SO4_VPCO c, SO4_VPRU r
                      WHERE     c.ni = v_componente_row.ni
                            AND c.ottica = p_ottica
                            AND NVL (c.revisione_assegnazione, -2) !=
                                   d_revisione
                            AND TRUNC (SYSDATE) BETWEEN r.dal
                                                    AND NVL (
                                                           DECODE (
                                                              c.revisione_cessazione,
                                                              d_revisione, TO_DATE (
                                                                              NULL),
                                                              r.al),
                                                           TO_DATE (
                                                              '3333333',
                                                              'j'))
                            AND c.id_componente = r.id_componente
                            AND c.progr_unita_organizzativa = d_progr_unita
                            AND EXISTS
                                   (SELECT 1
                                      FROM ag_privilegi_ruolo
                                     WHERE ruolo = r.ruolo)
                            AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        d_esiste_ruolo := 0;
                  END;

                  DBMS_OUTPUT.put_line ('d_esiste_ruolo ' || d_esiste_ruolo);

                  IF d_esiste_ruolo > 0
                  THEN
                     d_abilitato := 'Y';
                  ELSE
                     d_abilitato := 'N';
                  END IF;

                  d_xml :=
                        d_xml
                     || '<row componente = "1" cod_utente="'
                     || d_utente
                     || '" ni="'
                     || v_componente_row.ni
                     || '" id_unita="'
                     || p_unita
                     || '" note="'
                     || '" abilitato="'
                     || d_abilitato
                     || '" nome="'
                     || get_invalidcharescseq (v_componente_row.des_soggetto);

                  IF d_abilitato = 'Y'
                  THEN
                     d_xml := d_xml || '"></row>';
                  ELSE
                     d_xml := d_xml || ' (NON ABILITATO) "></row>';
                  END IF;

                  d_amount := LENGTH (d_xml);
                  DBMS_LOB.writeappend (p_clob, d_amount, d_xml);
                  d_xml := '';
               END IF;
            ELSE
               DBMS_OUTPUT.put_line ('v_componente%NOTFOUND');

               IF p_get_xml
               THEN
                  IF d_esiste_comp
                  THEN
                     chiudi_tag ('</row>', p_clob);
                  ELSE
                     IF p_ramo
                     THEN
                        chiudi_tag ('">', p_clob);
                     ELSE
                        chiudi_tag ('>', p_clob);
                     END IF;
                  END IF;
               END IF;

               EXIT;
            END IF;
         END LOOP;

         CLOSE v_componente;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_componenti_unita: ' || SQLERRM);
   END get_componenti_unita;

   /*****************************************************************************
    NOME:        unita_con_componenti
    DESCRIZIONE: Verifica se l'unita' passata come parametro ha o meno
                 dei componenti

    RITORNO:     1  se l'unita' ha componenti
                 0  se l'unita' non ha componenti
                 -1 se l'unita' ha componenti ma nessuno abilitato al protocollo

    Rev.  Data       Autore   Descrizione.
    000   15/12/2008 SN       Prima emissione.
    002   24/08/2011 MM       A45326.0.0: Per evitare che gli utenti smistino ad
                              unita' che non hanno componenti abilitati all'utilizzo
                              del sistema di protocollo sarebbe opportuno aggiungere
                              un'indicazione in cui si specifica che l'unita' non
                              ha componenti abilitati.
   ********************************************************************************/
   FUNCTION is_unita_con_componenti (
      p_unita               IN VARCHAR2,
      p_ottica              IN VARCHAR2,
      p_info_abilitazione   IN NUMBER DEFAULT 1)
      RETURN INTEGER
   IS
      d_xml           CLOB;
      d_esiste_comp   INTEGER := 0;
   BEGIN
      get_componenti_unita (p_unita,
                            p_ottica,
                            d_xml,
                            d_esiste_comp,
                            TRUE,
                            FALSE,
                            p_info_abilitazione);
      RETURN d_esiste_comp;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.is_unita_con_componenti: ' || SQLERRM);
   END is_unita_con_componenti;

   /*****************************************************************************
    NOME:        IS_UNITA_VALIDA
    DESCRIZIONE: Verifica che la generica unita' passata in input sia valida,

    RITORNO:  1 se l'unita è valida
              0 altrimenti

    Rev. Data        Autore   Descrizione.
    000  29/10/2008  SN       Prima emissione.
    004  19/12/2012  MM       Modificata in modo che vada per progressivo.
   ********************************************************************************/
   FUNCTION is_unita_valida (p_progr_unita NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      SELECT 1
        INTO ret
        FROM seg_unita
       WHERE     seg_unita.progr_unita_organizzativa = p_progr_unita
             AND seg_unita.al IS NULL;

      RETURN ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN TOO_MANY_ROWS
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.is_unita_valida ' || SQLERRM);
   END is_unita_valida;

   FUNCTION verifica_privilegio_ass_utente (p_unita     VARCHAR2,
                                            p_utente    VARCHAR2)
      RETURN NUMBER
   IS
      retval         NUMBER := 0;
      depunita       seg_unita.unita%TYPE;
      p_privilegio   VARCHAR2 (20) := 'ASS';
   BEGIN
      IF p_unita IS NULL
      THEN
         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp
             WHERE     utente = p_utente
                   AND privilegio = p_privilegio
                   AND TRUNC (SYSDATE) <=                 /*BETWEEN dal AND */
                                         NVL (al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      ELSE
         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp
             WHERE     utente = p_utente
                   AND privilegio = p_privilegio
                   AND TRUNC (SYSDATE) <=                  /*BETWEEN dal AND*/
                                         NVL (al, TO_DATE (3333333, 'j'))
                   AND unita = p_unita
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;

      RETURN retval;
   END verifica_privilegio_ass_utente;

   /*****************************************************************************
    NOME:        unita_get_descrizione.

    DESCRIZIONE: Restituisce la descrizione dell'unita'  valida corrispondente
                 al progressivo p_progr.

   RITORNO:

    Rev  Data         Autore  Descrizione.
    000  16/09/2008  SN       Prima emissione.
    004  19/12/2012  MM       Modificata in modo che vada per progressivo.
   ********************************************************************************/
   FUNCTION unita_get_descrizione (p_progr NUMBER)
      RETURN VARCHAR2
   IS
      d_descrizione_unita   VARCHAR2 (32767);
   BEGIN
      SELECT seg_unita.nome
        INTO d_descrizione_unita
        FROM seg_unita
       WHERE     seg_unita.progr_unita_organizzativa = p_progr
             AND seg_unita.al IS NULL;

      RETURN d_descrizione_unita;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'ag_unita_utility_flex.unita_get_descrizione: ricerca fallita per l''unita''  con progressivo '
            || p_progr
            || ' '
            || SQLERRM);
   END;

   /*****************************************************************************
    NOME:        get_unita_figlie_e_componenti
    DESCRIZIONE: Restituisce un CLOB che concatena le unita' figlie di p_unita
                 passata in input e, in base ai privilegi dell'utente p_utente,
                 gli eventuali componenti.
                 Si addentra nell'albero delle unutà fino al livello p_livello.
                 Se p_livello = 0: non entra nell'albero.
                 Se p_livello = null naviga l'albero fino al livello piu' interno.
    RITORNO:
    Rev.  Data       Autore   Descrizione.
    000   03/11/2008 SN       Prima emissione.
    002   24/08/2011 MM       A45326.0.0: Per evitare che gli utenti smistino ad
                              unita' che non hanno componenti abilitati all'utilizzo
                              del sistema di protocollo sarebbe opportuno aggiungere
                              un'indicazione in cui si specifica che l'unita' non
                              ha componenti abilitati.
   ********************************************************************************/
   PROCEDURE get_unita_figlie (
      p_unita                    IN     VARCHAR2,
      p_codice_amministrazione   IN     VARCHAR2,
      p_codice_aoo               IN     VARCHAR2,
      p_ottica                   IN     VARCHAR2,
      p_clob                     IN OUT CLOB,
      p_livello                  IN     NUMBER DEFAULT NULL)
   IS
      v_ramo                afc.t_ref_cursor;

      TYPE v_ramo_type IS RECORD
      (
         progr_unita_organizzativa   so4_auor.progr_unita_organizzativa%TYPE,
         uo                          so4_auor.codice_uo%TYPE,
         des_uo                      so4_auor.descrizione%TYPE,
         dal                         DATE,
         al                          DATE
      );

      v_ramo_row            v_ramo_type;
      d_xml                 VARCHAR2 (32000) := '';
      d_amount              BINARY_INTEGER := 32767;
      dep_next_livello      NUMBER := NULL;
      dep_nome              seg_unita.nome%TYPE;
      dep_desc_abbreviata   seg_unita.desc_abbreviata%TYPE;
      dep_tag_mail          seg_unita.tag_mail%TYPE;
      dep_al_unita          DATE;
   BEGIN
      IF p_livello IS NOT NULL AND p_livello > 0
      THEN
         dep_next_livello := p_livello - 1;
      END IF;

      /* Se p_livello = 0: non entra nell'albero.
      Se p_livello = null naviga l'albero fino al livello piu' interno.  */
      IF p_livello IS NULL OR p_livello > 0
      THEN
         BEGIN
            v_ramo :=
               so4_ags_pkg.unita_get_unita_figlie_ord (p_unita, p_ottica);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         LOOP
            FETCH v_ramo INTO v_ramo_row;

            EXIT WHEN v_ramo%NOTFOUND;

            IF     v_ramo_row.uo IS NOT NULL
               AND is_unita_valida (v_ramo_row.progr_unita_organizzativa) = 1
            THEN
               BEGIN
                  SELECT nome,
                         desc_abbreviata,
                         tag_mail,
                         al
                    INTO dep_nome,
                         dep_desc_abbreviata,
                         dep_tag_mail,
                         dep_al_unita
                    FROM seg_unita
                   WHERE     progr_unita_organizzativa =
                                v_ramo_row.progr_unita_organizzativa
                         AND seg_unita.al IS NULL;

                  d_xml :=
                        '<row componente = "0'
                     || '" ni="'
                     || v_ramo_row.uo
                     || '" id_unita="'
                     || v_ramo_row.uo
                     || '" dal="'
                     || TO_CHAR (v_ramo_row.dal, 'dd/mm/yyyy')
                     || '" al="'
                     || TO_CHAR (dep_al_unita, 'dd/mm/yyyy')
                     || '" note="'
                     || '" nome="'
                     || get_invalidcharescseq (dep_nome)
                     || '" progr_unita_organizzativa="'
                     || v_ramo_row.progr_unita_organizzativa
                     || '" desc_abbreviata="'
                     || get_invalidcharescseq (dep_desc_abbreviata)
                     || '" tag_mail="'
                     || get_invalidcharescseq (dep_tag_mail)
                     || '"> ';
                  d_amount := LENGTH (d_xml);
                  DBMS_LOB.writeappend (p_clob, d_amount, d_xml);
                  get_unita_figlie (v_ramo_row.uo,
                                    p_codice_amministrazione,
                                    p_codice_aoo,
                                    p_ottica,
                                    p_clob,
                                    dep_next_livello);
                  chiudi_tag ('</row>', p_clob);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END LOOP;

         CLOSE v_ramo;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_unita_figlie: ' || SQLERRM);
   END get_unita_figlie;

   FUNCTION get_tree (p_codice_amministrazione   IN VARCHAR2,
                      p_codice_aoo               IN VARCHAR2,
                      p_ricerca                  IN VARCHAR2 DEFAULT '')
      RETURN CLOB
   IS
      /******************************************************************************
       NOME:        get_tree
       DESCRIZIONE: Dato utente, codice amministrazione, codice aoo, restituisce il ramo di tree view
                      delle unita dell'aoo in questione, alle quali p_utente puo' smistare.
                      Vengono elencati anche i componenti sotto le unita' per le quali p_utente
                      ha privilegio ASS, oppure se ha genericamente il privilegio ASSTOT.
                      L'utente smista a tutte le unita se ha privilegio SMISTATUTTI.
                      Se invece ha privilegio SMISTAAREA, smista solo all'interno
                      del ramo delle unita per le quali ha codesto privilegio.

       PARAMETRI:   p_utente   codice utente
                    p_Codice_Amministrazione codice dell'amministrazione per la quale p_utente lavora
                    p_codice_aoo codice dell'aoo per la quale p_utente lavora

       RITORNA:     clob    xml


       REVISIONI:
       Rev.  Data        Autore        Descrizione
       ----  ----------  -----------   ----------------------------------------------------
       0     19/12/2011 SC            Prima emissione.
      ******************************************************************************/
      v_uo_elenco           afc.t_ref_cursor;

      TYPE v_uo_elenco_type IS RECORD
      (
         uo       so4_auor.codice_uo%TYPE,
         des_uo   so4_auor.descrizione%TYPE,
         dal      DATE,
         al       DATE
      );

      v_uo_elenco_row       v_uo_elenco_type;
      d_xml                 VARCHAR2 (32000) := '';
      d_amount              BINARY_INTEGER := 32767;
      d_clob                CLOB := EMPTY_CLOB ();
      d_ottica              VARCHAR2 (18);
      v_unitasmistaarea     afc.t_ref_cursor;
      d_unitasmistaarea     VARCHAR2 (32000) := '';
      dep_progressivo       so4_auor.progr_unita_organizzativa%TYPE;
      dep_codice_unita      so4_auor.codice_uo%TYPE;
      dep_nome              seg_unita.nome%TYPE;
      dep_desc_abbreviata   seg_unita.desc_abbreviata%TYPE;
      dep_tag_mail          seg_unita.tag_mail%TYPE;
      dep_dal_unita         DATE;
      dep_al_unita          DATE;
      d_data_riferimento    DATE := TRUNC (SYSDATE);
      d_unita_radice        VARCHAR2 (32000) := '';
      d_comp                NUMBER := 0;
      dep_expand_level      NUMBER := 0;
   BEGIN
      -- ottica da utilizzare dipende da utente e aoo
      d_ottica :=
         ag_utilities.get_ottica_aoo (
            ag_utilities.get_indice_aoo (p_codice_amministrazione,
                                         p_codice_aoo));
      DBMS_OUTPUT.put_line ('d_ottica ' || d_ottica);

      -- Se sto cercando cerco in tutta la struttura
      IF (p_ricerca IS NOT NULL)
      THEN
         dep_expand_level := 20;
      END IF;

      DBMS_LOB.createtemporary (d_clob, TRUE, DBMS_LOB.CALL);
      d_xml := '<struttura>';
      d_amount := LENGTH (d_xml);
      DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
      v_uo_elenco := so4_ags_pkg.get_all_unita_radici (d_ottica);


      LOOP
         FETCH v_uo_elenco INTO v_uo_elenco_row;

         EXIT WHEN v_uo_elenco%NOTFOUND;

         dep_progressivo :=
            so4_ags_pkg.anuo_get_progr (
               p_amministrazione   => p_codice_amministrazione,
               p_codice_uo         => v_uo_elenco_row.uo,
               p_data              => TRUNC (SYSDATE));

         DBMS_OUTPUT.put_line ('U= ' || v_uo_elenco_row.uo);

         IF     v_uo_elenco_row.uo IS NOT NULL
            AND is_unita_valida (dep_progressivo) = 1
         THEN
            BEGIN
               SELECT nome,
                      desc_abbreviata,
                      tag_mail,
                      al
                 INTO dep_nome,
                      dep_desc_abbreviata,
                      dep_tag_mail,
                      dep_al_unita
                 FROM seg_unita
                WHERE     progr_unita_organizzativa = dep_progressivo
                      AND seg_unita.al IS NULL;

               d_xml :=
                     '<row componente = "0'
                  || '" ni="'
                  || v_uo_elenco_row.uo
                  || '" id_unita="'
                  || v_uo_elenco_row.uo
                  || '" dal="'
                  || TO_CHAR (v_uo_elenco_row.dal, 'dd/mm/yyyy')
                  || '" al="'
                  || TO_CHAR (dep_al_unita, 'dd/mm/yyyy')
                  || '" note="'
                  || '" nome="'
                  || get_invalidcharescseq (dep_nome)
                  || '" progr_unita_organizzativa="'
                  || dep_progressivo
                  || '" desc_abbreviata="'
                  || get_invalidcharescseq (dep_desc_abbreviata)
                  || '" tag_mail="'
                  || get_invalidcharescseq (dep_tag_mail)
                  || '"> ';

               d_amount := LENGTH (d_xml);
               DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
               DBMS_OUTPUT.put_line ('XML= ' || d_xml);

               IF dep_expand_level > 0
               THEN
                  get_unita_figlie (v_uo_elenco_row.uo,
                                    p_codice_amministrazione,
                                    p_codice_aoo,
                                    d_ottica,
                                    d_clob,
                                    dep_expand_level);
               END IF;

               chiudi_tag ('</row>', d_clob);
            END;
         END IF;
      END LOOP;

      CLOSE v_uo_elenco;

      chiudi_tag ('</struttura>', d_clob);
      RETURN d_clob;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_tree: ' || SQLERRM);
   END get_tree;

   /*****************************************************************************
       NOME:        get_tipi_smistamento.

       DESCRIZIONE: Restituisce un cusore con tutti i possibili tipi di smistamento
                    consentiti.

       RITORNO:

       Rev.  Data        Autore  Descrizione.
       00    16/09/2008  SN      Prima emissione.
   ********************************************************************************/
   FUNCTION get_tipi_smistamento (p_codice_amm    IN VARCHAR2,
                                  p_codice_aoo    IN VARCHAR2,
                                  p_area          IN VARCHAR2,
                                  p_modello       IN VARCHAR2,
                                  p_modello_obb   IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT tsmo.tipo_smistamento, tism.descrizione
           FROM ag_tipi_smistamento_modello tsmo, ag_tipi_smistamento tism
          WHERE     tsmo.aoo =
                       ag_utilities.get_indice_aoo (p_codice_amm,
                                                    p_codice_aoo)
                AND tsmo.area = p_area
                AND tsmo.codice_modello = p_modello
                AND NVL (p_modello_obb, 'N') = 'Y'
                AND tsmo.tipo_smistamento = tism.tipo_smistamento
                AND tsmo.aoo = tism.aoo
         UNION
         SELECT tism.tipo_smistamento, tism.descrizione
           FROM ag_tipi_smistamento tism
          WHERE     NVL (p_modello_obb, 'N') = 'N'
                AND tism.aoo =
                       ag_utilities.get_indice_aoo (p_codice_amm,
                                                    p_codice_aoo);

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_tipi_smistamento: ' || SQLERRM);
   END;

   /*****************************************************************************
       NOME:        get_default_tipo_smistamento.

       DESCRIZIONE: Restituisce il tipo smistamento che l'utente di procedura
                    può associare al documento identificato dall'idrif passato
                    come parametro.

       INPUT        p_idRif
                    p_codice_amm
                    p_codice_aoo
                    p_area
                    p_modello
                    p_utente
                    p_competenza

      RITORNO:

       Rev.  Data        Autore  Descrizione.
       00    10/09/2008  SN      Prima emissione.
   ********************************************************************************/
   FUNCTION get_default_tipo_smistamento (p_idrif        IN VARCHAR2,
                                          p_codice_amm   IN VARCHAR2,
                                          p_codice_aoo   IN VARCHAR2,
                                          p_area         IN VARCHAR2,
                                          p_modello      IN VARCHAR2,
                                          p_utente       IN VARCHAR2,
                                          p_competenza   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (32767);
   BEGIN
      SELECT NVL (ag_competenze_protocollo.default_tipo_smistamento (
                     p_idrif,
                     p_codice_amm,
                     p_codice_aoo,
                     p_area,
                     p_modello,
                     p_utente,
                     p_competenza),
                  ag_utilities.get_default_tipo_smistamento (p_codice_amm,
                                                             p_codice_aoo,
                                                             p_area,
                                                             p_modello))
        INTO d_return
        FROM DUAL;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_default_tipo_smistamento: ' || SQLERRM);
   END;

   /*****************************************************************************
    NOME:        get_unita_figlie_e_componenti
    DESCRIZIONE: Restituisce un CLOB che concatena le unita' figlie di p_unita
                 passata in input e, in base ai privilegi dell'utente p_utente,
                 gli eventuali componenti.
                 Si addentra nell'albero delle unutà fino al livello p_livello.
                 Se p_livello = 0: non entra nell'albero.
                 Se p_livello = null naviga l'albero fino al livello piu' interno.
    RITORNO:
    Rev.  Data       Autore   Descrizione.
    000   03/11/2008 SN       Prima emissione.
    002   24/08/2011 MM       A45326.0.0: Per evitare che gli utenti smistino ad
                              unita' che non hanno componenti abilitati all'utilizzo
                              del sistema di protocollo sarebbe opportuno aggiungere
                              un'indicazione in cui si specifica che l'unita' non
                              ha componenti abilitati.
   ********************************************************************************/
   PROCEDURE get_unita_figlie_e_componenti (
      p_unita                    IN     VARCHAR2,
      p_codice_amministrazione   IN     VARCHAR2,
      p_codice_aoo               IN     VARCHAR2,
      p_utente                   IN     ad4_utenti.utente%TYPE,
      p_ottica                   IN     VARCHAR2,
      p_assegnautti              IN     NUMBER,
      p_clob                     IN OUT CLOB,
      p_livello                  IN     NUMBER DEFAULT NULL,
      p_info_abilitazione        IN     NUMBER DEFAULT 1,
      p_visualizza_comp          IN     NUMBER DEFAULT 1)
   IS
      v_ramo             afc.t_ref_cursor;

      TYPE v_ramo_type IS RECORD
      (
         progr_unita_organizzativa   so4_auor.progr_unita_organizzativa%TYPE,
         uo                          so4_auor.codice_uo%TYPE,
         des_uo                      so4_auor.descrizione%TYPE,
         dal                         DATE,
         al                          DATE
      );

      v_ramo_row         v_ramo_type;
      d_xml              VARCHAR2 (32000) := '';
      d_amount           BINARY_INTEGER := 32767;
      dep_next_livello   NUMBER := NULL;
      d_comp             INTEGER := 0;
   BEGIN
      IF p_livello IS NOT NULL AND p_livello > 0
      THEN
         dep_next_livello := p_livello - 1;
      END IF;

      /* Se p_livello = 0: non entra nell'albero.
      Se p_livello = null naviga l'albero fino al livello piu' interno.  */
      IF p_livello IS NULL OR p_livello > 0
      THEN
         BEGIN
            DBMS_OUTPUT.put_line (
                  '          CERCO unita_get_unita_figlie_ord ('''
               || p_unita
               || ''', '''
               || p_ottica
               || ''', sysdate, '''
               || p_codice_amministrazione
               || ''')'
               || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
            v_ramo :=
               so4_ags_pkg.unita_get_unita_figlie_ord (
                  p_unita,
                  p_ottica,
                  TRUNC (SYSDATE),
                  p_codice_amministrazione);
            DBMS_OUTPUT.put_line (
                  '          DOPO unita_get_unita_figlie_ord ('''
               || p_unita
               || ''', '''
               || p_ottica
               || ''', sysdate, '''
               || p_codice_amministrazione
               || ''')'
               || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         LOOP
            FETCH v_ramo INTO v_ramo_row;

            EXIT WHEN v_ramo%NOTFOUND;

            IF     v_ramo_row.uo IS NOT NULL
               AND is_unita_valida (v_ramo_row.progr_unita_organizzativa) = 1
            THEN
               DBMS_OUTPUT.put_line (
                     '          CERCO is_unita_con_componenti  '
                  || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
               d_comp :=
                  is_unita_con_componenti (v_ramo_row.uo,
                                           p_ottica,
                                           p_info_abilitazione);
               DBMS_OUTPUT.put_line (
                     '          dopo is_unita_con_componenti  '
                  || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
               d_xml := '<row componente = "0';

               IF d_comp = 0
               THEN
                  d_xml := d_xml || 'SC';
               ELSIF d_comp = -1
               THEN
                  d_xml := d_xml || 'SA';
               END IF;

               d_xml :=
                     d_xml
                  || '" ni="'
                  || v_ramo_row.uo
                  || '" id_unita="'
                  || v_ramo_row.uo
                  || '" note="'
                  || '" nome="'
                  || get_invalidcharescseq (
                        unita_get_descrizione (
                           v_ramo_row.progr_unita_organizzativa));

               IF d_comp <= 0 AND p_info_abilitazione = 1
               THEN
                  d_xml := d_xml || ' (SENZA COMPONENTI';

                  IF d_comp < 0
                  THEN
                     d_xml := d_xml || ' ABILITATI';
                  END IF;

                  d_xml := d_xml || ')';
               END IF;

               d_amount := LENGTH (d_xml);
               DBMS_LOB.writeappend (p_clob, d_amount, d_xml);

               -- Se vengo da chiamata ricorsiva dovuta all'espansione automatica di
               -- n livelli (dep_next_livello IS NOT NULL), nell'ultimo non devo calcolare i componenti perchè
               -- vengono ricalcolati al click sul ramo.
               IF dep_next_livello IS NULL OR dep_next_livello > 0
               THEN
                  IF     p_visualizza_comp = 1
                     AND (   p_assegnautti = 1
                          OR p_utente = 'no'
                          OR (    p_utente <> 'no'
                              AND verifica_privilegio_ass_utente (
                                     v_ramo_row.uo,
                                     p_utente) = 1))
                  THEN
                     DBMS_OUTPUT.put_line (
                           '          CERCO get_componenti_unita  '
                        || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
                     get_componenti_unita (v_ramo_row.uo,
                                           p_ottica,
                                           p_clob,
                                           d_comp,
                                           TRUE,
                                           TRUE,
                                           p_info_abilitazione);
                     DBMS_OUTPUT.put_line (
                           '          dopo get_componenti_unita  '
                        || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
                  ELSE
                     d_xml := '">';
                     chiudi_tag (d_xml, p_clob);
                  END IF;
               ELSE
                  d_xml := '">';
                  d_amount := LENGTH (d_xml);
                  DBMS_LOB.writeappend (p_clob, d_amount, d_xml);
               END IF;

               get_unita_figlie_e_componenti (v_ramo_row.uo,
                                              p_codice_amministrazione,
                                              p_codice_aoo,
                                              p_utente,
                                              p_ottica,
                                              p_assegnautti,
                                              p_clob,
                                              dep_next_livello,
                                              p_info_abilitazione,
                                              p_visualizza_comp);
               chiudi_tag ('</row>', p_clob);
            END IF;
         END LOOP;

         CLOSE v_ramo;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'ag_unita_utility_flex.get_unita_figlie_e_componenti: '
            || SQLERRM);
   END get_unita_figlie_e_componenti;

   /******************************************************************************
    NOME:          get_ramo_unita

    DESCRIZIONE:   compone un xml con l'elenco, opportunamente indentato, delle unita' figlie
                   ( e relativi componenti) dell'unita' p_unita passata come parametro.

    PARAMETRI:     p_utente   codice utente
                   p_codice_amministrazione codice dell'amministrazione cui p_utente appartiene
                   p_codice_aoo codice dell'aoo cui p_utente appartiene
                   p_utente    codice utente tomcat

    RITORNA:       clob    xml


    REVISIONI:
    Rev.  Data        Autore       Descrizione
    ----  ----------  -----------  ----------------------------------------------------
    0     29/10/2008  SN           Prima emissione.
   ******************************************************************************/
   FUNCTION get_ramo_unita (
      p_unita                    IN VARCHAR2,
      p_codice_amministrazione   IN VARCHAR2,
      p_codice_aoo               IN VARCHAR2,
      p_utente                   IN ad4_utenti.utente%TYPE)
      RETURN CLOB
   IS
      d_xml           VARCHAR2 (32000) := '';
      d_amount        BINARY_INTEGER := 32767;
      d_clob          CLOB := EMPTY_CLOB ();
      d_ottica        VARCHAR2 (18);
      assegnaatutti   NUMBER := 0;
      d_comp          INTEGER := 0;
   BEGIN
      DBMS_LOB.createtemporary (d_clob, TRUE, DBMS_LOB.CALL);
      d_xml := '<struttura';
      d_amount := LENGTH (d_xml);
      DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
      d_ottica :=
         ag_utilities.get_ottica_utente (p_utente,
                                         p_codice_amministrazione,
                                         p_codice_aoo);
      assegnaatutti :=
         ag_utilities.verifica_privilegio_utente (NULL,
                                                  'ASSTOT',
                                                  p_utente,
                                                  TRUNC (SYSDATE));

      IF    assegnaatutti = 1
         OR verifica_privilegio_ass_utente (p_unita, p_utente) = 1
      THEN
         get_componenti_unita (p_unita,
                               d_ottica,
                               d_clob,
                               d_comp,
                               FALSE);
      ELSE
         chiudi_tag ('>', d_clob);
      END IF;

      get_unita_figlie_e_componenti (p_unita,
                                     p_codice_amministrazione,
                                     p_codice_aoo,
                                     p_utente,
                                     d_ottica,
                                     assegnaatutti,
                                     d_clob);
      chiudi_tag ('</struttura>', d_clob);
      RETURN d_clob;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_ramo_unita: ' || SQLERRM);
   END;

   FUNCTION get_tree_smistamenti_utente (
      p_utente                   IN ad4_utenti.utente%TYPE,
      p_codice_amministrazione   IN VARCHAR2,
      p_codice_aoo               IN VARCHAR2,
      p_ricerca                  IN VARCHAR2 DEFAULT '')
      RETURN CLOB
   IS
      /******************************************************************************
       NOME:        get_tree_smistamenti_utente
       DESCRIZIONE: Dato utente, codice amministrazione, codice aoo, restituisce il ramo di tree view
                      delle unita dell'aoo in questione, alle quali p_utente puo' smistare.
                      Vengono elencati anche i componenti sotto le unita' per le quali p_utente
                      ha privilegio ASS, oppure se ha genericamente il privilegio ASSTOT.
                      L'utente smista a tutte le unita se ha privilegio SMISTATUTTI.
                      Se invece ha privilegio SMISTAAREA, smista solo all'interno
                      del ramo delle unita per le quali ha codesto privilegio.

       PARAMETRI:   p_utente   codice utente
                    p_Codice_Amministrazione codice dell'amministrazione per la quale p_utente lavora
                    p_codice_aoo codice dell'aoo per la quale p_utente lavora

       RITORNA:     clob    xml


       REVISIONI:
       Rev.  Data        Autore        Descrizione
       ----  ----------  -----------   ----------------------------------------------------
       0     25/07/2008  SN            Prima emissione.
             04/09/2008  SC            Gestione privilegi. A28345.2.0.
             29/10/2008  SN            Modificata la modalità di caricamento della struttura
                                       organizzativa. Gestito il caricamento delle sole
                                       unita' di primo livello per l'utente con privilegio
                                       SMISTATUTTI e di tutta l'area di appartenenza
                                       per l'utente con privilegio SMISTAAREA.
             15/12/2008  SN            30388.0.0 Aggiunta la dicitura UNITA SENZA COMPONENTI
                                       alla descrizione delle unita' che non hanno componenti.
             15/02/2010  SC            A34954.0.0.
       002   24/08/2011  MM            A45326.0.0: Per evitare che gli utenti smistino ad
                                       unita' che non hanno componenti abilitati all'utilizzo
                                       del sistema di protocollo sarebbe opportuno aggiungere
                                       un'indicazione in cui si specifica che l'unita' non
                                       ha componenti abilitati.
      ******************************************************************************/
      v_uo_elenco          afc.t_ref_cursor;

      TYPE v_uo_elenco_type IS RECORD
      (
         uo       so4_auor.codice_uo%TYPE,
         des_uo   so4_auor.descrizione%TYPE,
         dal      DATE,
         al       DATE
      );

      v_uo_elenco_row      v_uo_elenco_type;
      d_xml                VARCHAR2 (32000) := '';
      d_amount             BINARY_INTEGER := 32767;
      d_clob               CLOB := EMPTY_CLOB ();
      assegnaatutti        NUMBER;
      smistaatutti         NUMBER := 0;
      d_ottica             VARCHAR2 (18);
      v_unitasmistaarea    afc.t_ref_cursor;
      d_unitasmistaarea    VARCHAR2 (32000) := '';
      dep_codice_unita     so4_auor.codice_uo%TYPE;
      dep_dal_unita        DATE;
      dep_al_unita         DATE;
      d_data_riferimento   DATE := TRUNC (SYSDATE);
      d_unita_radice       VARCHAR2 (32000) := '';
      dep_expand_level     NUMBER := 0;
      d_comp               NUMBER := 0;
      dep_progressivo      NUMBER;
   BEGIN
      -- ottica da utilizzare dipende da utente e aoo
      d_ottica :=
         ag_utilities.get_ottica_utente (p_utente,
                                         p_codice_amministrazione,
                                         p_codice_aoo);
      -- verifica se l'utente smista a qualsiasi unita dell'ente
      smistaatutti :=
         ag_utilities.verifica_privilegio_utente (NULL,
                                                  'SMISTATUTTI',
                                                  p_utente,
                                                  TRUNC (SYSDATE));
      DBMS_OUTPUT.put_line ('smistaatutti ' || smistaatutti);
      assegnaatutti :=
         ag_utilities.verifica_privilegio_utente (NULL,
                                                  'ASSTOT',
                                                  p_utente,
                                                  TRUNC (SYSDATE));
      dep_expand_level :=
         ag_parametro.get_valore ('UNITA_EXPAND_LEVEL',
                                  p_codice_amministrazione,
                                  p_codice_aoo,
                                  0);

      -- Se sto cercando cerco in tutta la struttura
      IF (p_ricerca IS NOT NULL)
      THEN
         dep_expand_level := 20;
      END IF;

      DBMS_LOB.createtemporary (d_clob, TRUE, DBMS_LOB.CALL);
      d_xml := '<struttura>';
      d_amount := LENGTH (d_xml);
      DBMS_LOB.writeappend (d_clob, d_amount, d_xml);

      IF smistaatutti = 1
      THEN
         DBMS_OUTPUT.put_line (
            'CERCO get_all_unita_radici ' || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
         v_uo_elenco := so4_ags_pkg.get_all_unita_radici (d_ottica);
         DBMS_OUTPUT.put_line (
            'DOPO get_all_unita_radici ' || TO_CHAR (SYSDATE, 'HH24:MI:SS'));

         LOOP
            FETCH v_uo_elenco INTO v_uo_elenco_row;

            EXIT WHEN v_uo_elenco%NOTFOUND;

            dep_progressivo :=
               so4_ags_pkg.anuo_get_progr (
                  p_amministrazione   => p_codice_amministrazione,
                  p_codice_uo         => v_uo_elenco_row.uo,
                  p_data              => TRUNC (SYSDATE));

            IF     v_uo_elenco_row.uo IS NOT NULL
               AND is_unita_valida (dep_progressivo) = 1
            THEN
               DBMS_OUTPUT.put_line (
                     'CERCO is_unita_con_componenti '
                  || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
               d_comp :=
                  is_unita_con_componenti (v_uo_elenco_row.uo, d_ottica);
               DBMS_OUTPUT.put_line (
                     'DOPO is_unita_con_componenti '
                  || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
               d_xml := '<row componente = "0';

               IF d_comp = 0
               THEN
                  d_xml := d_xml || 'SC';
               ELSIF d_comp = -1
               THEN
                  d_xml := d_xml || 'SA';
               END IF;

               d_xml :=
                     d_xml
                  || '" ni="'
                  || v_uo_elenco_row.uo
                  || '" id_unita="'
                  || v_uo_elenco_row.uo
                  || '" note="'
                  || '" nome="'
                  || get_invalidcharescseq (
                        unita_get_descrizione (dep_progressivo));
               d_amount := LENGTH (d_xml);
               DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
               DBMS_OUTPUT.put_line (d_xml);

               IF dep_expand_level > 0
               THEN
                  IF    assegnaatutti = 1
                     OR verifica_privilegio_ass_utente (v_uo_elenco_row.uo,
                                                        p_utente) = 1
                  THEN
                     DBMS_OUTPUT.put_line (
                           'CERCO get_componenti_unita '
                        || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
                     get_componenti_unita (v_uo_elenco_row.uo,
                                           d_ottica,
                                           d_clob,
                                           d_comp);
                     DBMS_OUTPUT.put_line (
                           'DOPO get_componenti_unita '
                        || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
                  ELSE
                     IF d_comp <= 0
                     THEN
                        d_xml := ' (SENZA COMPONENTI';

                        IF d_comp < 0
                        THEN
                           d_xml := d_xml || ' ABILITATI';
                        END IF;

                        d_xml := d_xml || ')">';
                     ELSE
                        d_xml := '">';
                     END IF;

                     d_amount := LENGTH (d_xml);
                     DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
                  END IF;

                  DBMS_OUTPUT.put_line (
                        'CERCO get_unita_figlie_e_componenti '
                     || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
                  get_unita_figlie_e_componenti (v_uo_elenco_row.uo,
                                                 p_codice_amministrazione,
                                                 p_codice_aoo,
                                                 p_utente,
                                                 d_ottica,
                                                 assegnaatutti,
                                                 d_clob,
                                                 dep_expand_level);
                  DBMS_OUTPUT.put_line (
                        'DOPO get_unita_figlie_e_componenti '
                     || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
               ELSE
                  IF d_comp <= 0
                  THEN
                     d_xml := ' (SENZA COMPONENTI';

                     IF d_comp < 0
                     THEN
                        d_xml := d_xml || ' ABILITATI';
                     END IF;

                     d_xml := d_xml || ')">';
                  ELSE
                     d_xml := '">';
                  END IF;

                  d_amount := LENGTH (d_xml);
                  DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
               END IF;

               chiudi_tag ('</row>', d_clob);
            END IF;


            DBMS_OUTPUT.put_line (
                  'UNITA= '
               || v_uo_elenco_row.uo
               || ' '
               || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
         END LOOP;

         CLOSE v_uo_elenco;
      ELSIF smistaatutti = 0
      THEN
         FOR u
            IN (SELECT unita_radice_area
                  FROM ag_radici_area_utente_tmp
                 WHERE     utente = p_utente
                       AND privilegio = ag_utilities.privilegio_smistaarea)
         LOOP
            dep_progressivo :=
               so4_ags_pkg.anuo_get_progr (
                  p_amministrazione   => p_codice_amministrazione,
                  p_codice_uo         => u.unita_radice_area,
                  p_data              => TRUNC (SYSDATE));
            DBMS_OUTPUT.put_line (
                  'UNITA= '
               || u.unita_radice_area
               || ' PROGR ='
               || dep_progressivo);

            IF dep_progressivo IS NOT NULL
            THEN
               d_comp :=
                  is_unita_con_componenti (u.unita_radice_area, d_ottica);
               d_xml := '<row componente = "0';

               IF d_comp = 0
               THEN
                  d_xml := d_xml || 'SC';
               ELSIF d_comp = -1
               THEN
                  d_xml := d_xml || 'SA';
               END IF;


               d_xml :=
                     d_xml
                  || '" ni="'
                  || u.unita_radice_area
                  || '" id_unita="'
                  || u.unita_radice_area
                  || '" note="'
                  || '" nome="'
                  || get_invalidcharescseq (
                        unita_get_descrizione (dep_progressivo));
               d_amount := LENGTH (d_xml);
               DBMS_LOB.writeappend (d_clob, d_amount, d_xml);

               IF    assegnaatutti = 1
                  OR verifica_privilegio_ass_utente (u.unita_radice_area,
                                                     p_utente) = 1
               THEN
                  get_componenti_unita (u.unita_radice_area,
                                        d_ottica,
                                        d_clob,
                                        d_comp);
               ELSE
                  IF d_comp <= 0
                  THEN
                     d_xml := ' (SENZA COMPONENTI';

                     IF d_comp < 0
                     THEN
                        d_xml := d_xml || ' ABILITATI';
                     END IF;

                     d_xml := d_xml || ')">';
                  ELSE
                     d_xml := '">';
                  END IF;

                  chiudi_tag (d_xml, d_clob);
               END IF;

               get_unita_figlie_e_componenti (u.unita_radice_area,
                                              p_codice_amministrazione,
                                              p_codice_aoo,
                                              p_utente,
                                              d_ottica,
                                              assegnaatutti,
                                              d_clob);
               chiudi_tag ('</row>', d_clob);
            END IF;
         END LOOP;
      END IF;

      d_xml := '</struttura>';
      d_amount := LENGTH (d_xml);
      DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
      RETURN d_clob;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_tree_smistamenti_utente: ' || SQLERRM);
   END get_tree_smistamenti_utente;

   /******************************************************************************
   NOME:          get_ramo

   DESCRIZIONE:   compone un xml con l'elenco, opportunamente indentato, delle unita' figlie
                  ( e relativi componenti) dell'unita' p_unita passata come parametro.

   PARAMETRI:     p_unita  codice unita
                  p_codice_amministrazione codice dell'amministrazione cui p_utente appartiene
                  p_codice_aoo codice dell'aoo cui p_utente appartiene

   RITORNA:       clob    xml


   REVISIONI:
   Rev.  Data        Autore       Descrizione
   ----  ----------  -----------  ----------------------------------------------------
   0     19/12/2011  SD           Prima emissione.
  ******************************************************************************/
   FUNCTION get_ramo (p_unita                    IN VARCHAR2,
                      p_codice_amministrazione   IN VARCHAR2,
                      p_codice_aoo               IN VARCHAR2)
      RETURN CLOB
   IS
      d_xml           VARCHAR2 (32000) := '';
      d_amount        BINARY_INTEGER := 32767;
      d_clob          CLOB := EMPTY_CLOB ();
      d_ottica        VARCHAR2 (18);
      assegnaatutti   NUMBER := 0;
      d_comp          INTEGER := 0;
   BEGIN
      DBMS_LOB.createtemporary (d_clob, TRUE, DBMS_LOB.CALL);
      d_xml := '<struttura>';
      d_amount := LENGTH (d_xml);
      DBMS_LOB.writeappend (d_clob, d_amount, d_xml);
      d_ottica :=
         ag_utilities.get_ottica_aoo (
            ag_utilities.get_indice_aoo (p_codice_amministrazione,
                                         p_codice_aoo));
      get_unita_figlie (p_unita,
                        p_codice_amministrazione,
                        p_codice_aoo,
                        d_ottica,
                        d_clob);
      chiudi_tag ('</struttura>', d_clob);
      RETURN d_clob;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_unita_utility_flex.get_ramo: ' || SQLERRM);
   END;

   FUNCTION get_tree_responsabili_fasc (p_utente       IN ad4_utenti.utente%TYPE,
                                        p_codice_amm   IN VARCHAR2,
                                        p_codice_aoo   IN VARCHAR2)
      RETURN CLOB
   IS
      /*****************************************************************************
         NOME:        GET_TREE_RESPONSABILI_FASC
         DESCRIZIONE:
         RITORNO:
         Rev.  Data       Autore  Descrizione.
         00    04/06/2012  MMUR  Prima emissione.
      ********************************************************************************/
      d_result                   CLOB := EMPTY_CLOB ();
      d_xml                      VARCHAR2 (32000) := '';
      d_amount                   BINARY_INTEGER := 32767;
      d_unita                    afc.t_ref_cursor;
      prog_unita_organizzativa   NUMBER;
      codice_uo                  VARCHAR2 (200);
      descrizione_uo             VARCHAR2 (200);
      dal                        DATE;
      al                         DATE;
      d_ottica                   VARCHAR2 (1000);
   BEGIN
      d_ottica :=
         AG_PARAMETRO.GET_VALORE ('SO_OTTICA_PROT',
                                  p_codice_amm,
                                  p_codice_aoo,
                                  '');
      DBMS_LOB.createtemporary (d_result, TRUE, DBMS_LOB.CALL);
      d_xml :=
            '<?xml version=''1.0'' encoding=''ISO-8859-1'' ?><ROWSET>'
         || CHR (10)
         || CHR (13);
      DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
      d_unita := so4_ags_pkg.get_all_unita_radici (d_ottica);

      IF d_unita%ISOPEN
      THEN
         LOOP
            BEGIN
               FETCH d_unita
                  INTO codice_uo,
                       descrizione_uo,
                       dal,
                       al;

               EXIT WHEN d_unita%NOTFOUND;

               d_xml :=
                     '<ALBERO nome= "'
                  || codice_uo
                  || ' - '
                  || get_invalidcharescseq (descrizione_uo)
                  || '" ni='''
                  || codice_uo
                  || '''>';
               d_amount := LENGTH (d_xml);
               DBMS_LOB.writeappend (d_result, d_amount, d_xml);
               get_unita_figlie_e_componenti (codice_uo,
                                              p_codice_amm,
                                              p_codice_aoo,
                                              'no',
                                              d_ottica,
                                              1,
                                              d_result,
                                              NULL,
                                              0);
               d_xml := '</ALBERO>';
               DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
            END;
         END LOOP;
      END IF;

      d_xml := '</ROWSET>' || CHR (10) || CHR (13);
      DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_DOCUMENTO_UTILITY.GET_TREE_RESPONSABILI: '
            || SQLERRM
            || -' - ');
   END get_tree_responsabili_fasc;
END;
/
