--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_SEG_UNITA_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE seg_unita_pkg
IS                                                           /* MASTER_LINK */
   /******************************************************************************
    NOME:        seg_unita_pkg
    DESCRIZIONE: Gestione tabella SEG_UNITA.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data        Autore       Descrizione.
    00    02/09/2009  MMalferrari  Prima emissione.
    01    17/05/2011  MMalferrari  Modifiche versione 2.1.
    02    07/12/2016  MMalferrari  Creata get_nome_between
   ******************************************************************************/
   -- Revisione del Package
   s_revisione    CONSTANT AFC.t_revision := 'V1.02';
   s_table_name   CONSTANT AFC.t_object_name := 'SEG_UNITA';

   SUBTYPE t_rowtype IS SEG_UNITA%ROWTYPE;

   -- Tipo del record primary key
   SUBTYPE t_progr_unita IS SEG_UNITA.progr_unita_organizzativa%TYPE;

   SUBTYPE t_dal IS SEG_UNITA.dal%TYPE;

   TYPE t_PK IS RECORD
   (
      progr_unita  t_progr_unita,
      dal          t_dal
   );

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   -- Costruttore di record chiave
   FUNCTION PK
               (p_progr_unita  IN SEG_UNITA.progr_unita_organizzativa%TYPE,
                p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN t_PK;

   -- Controllo integritý chiave
   FUNCTION can_handle
                       (
      p_progr_unita  IN SEG_UNITA.progr_unita_organizzativa%TYPE,
      p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (can_handle, WNDS);

   -- Controllo integritý chiave
   -- wrapper boolean
   FUNCTION canHandle
                      (
      p_progr_unita  IN SEG_UNITA.progr_unita_organizzativa%TYPE,
      p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN BOOLEAN;

   FUNCTION exists_id (
      p_progr_unita   IN   seg_unita.progr_unita_organizzativa%TYPE,
      p_dal          IN   seg_unita.dal%TYPE
   )
      RETURN NUMBER;

   -- Esistenza riga con chiave indicata
   FUNCTION exists_id
                      (
      p_codice_amm   IN SEG_UNITA.codice_amministrazione%TYPE,
      p_codice_aoo   IN SEG_UNITA.codice_aoo%TYPE,
      p_unita        IN SEG_UNITA.unita%TYPE,
      p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN NUMBER;



   -- Esistenza riga con chiave indicata
   -- wrapper boolean
   FUNCTION existsId
                     (
      p_codice_amm   IN SEG_UNITA.codice_amministrazione%TYPE,
      p_codice_aoo   IN SEG_UNITA.codice_aoo%TYPE,
      p_unita        IN SEG_UNITA.unita%TYPE,
      p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN BOOLEAN;



   -- Getter per attributo al di riga identificata da chiave
   FUNCTION get_al
                   (p_codice_amm   IN SEG_UNITA.codice_amministrazione%TYPE,
                    p_codice_aoo   IN SEG_UNITA.codice_aoo%TYPE,
                    p_unita        IN SEG_UNITA.unita%TYPE,
                    p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN SEG_UNITA.al%TYPE;



   -- Getter per attributo nome di riga identificata da chiave
   FUNCTION get_nome
                     (
      p_codice_amm   IN SEG_UNITA.codice_amministrazione%TYPE,
      p_codice_aoo   IN SEG_UNITA.codice_aoo%TYPE,
      p_unita        IN SEG_UNITA.unita%TYPE,
      p_dal          IN SEG_UNITA.dal%TYPE)
      RETURN SEG_UNITA.nome%TYPE;


   FUNCTION get_unita_between (p_unita IN VARCHAR2, p_data_rif VARCHAR2)
      RETURN AFC.t_ref_cursor;

   -- righe corrispondenti alla selezione indicata
   FUNCTION get_rows /*+ SOA  */

                     (p_QBE               IN NUMBER DEFAULT 0,
                      p_other_condition   IN VARCHAR2 DEFAULT NULL,
                      p_order_by          IN VARCHAR2 DEFAULT NULL,
                      p_extra_columns     IN VARCHAR2 DEFAULT NULL,
                      p_extra_condition   IN VARCHAR2 DEFAULT NULL,
                      p_codice_amm        IN VARCHAR2 DEFAULT NULL,
                      p_codice_aoo        IN VARCHAR2 DEFAULT NULL,
                      p_unita             IN VARCHAR2 DEFAULT NULL,
                      p_dal               IN VARCHAR2 DEFAULT NULL,
                      p_al                IN VARCHAR2 DEFAULT NULL,
                      p_nome              IN VARCHAR2 DEFAULT NULL,
                      p_progr_unita       IN NUMBER DEFAULT NULL)
      RETURN AFC.t_ref_cursor;

   -- Numero di righe corrispondente alla selezione indicata
   -- Almeno un attributo deve essere valido (non null)
   FUNCTION count_rows
                       (p_QBE               IN NUMBER DEFAULT 0,
                        p_other_condition   IN VARCHAR2 DEFAULT NULL,
                        p_codice_amm        IN VARCHAR2 DEFAULT NULL,
                        p_codice_aoo        IN VARCHAR2 DEFAULT NULL,
                        p_unita             IN VARCHAR2 DEFAULT NULL,
                        p_dal               IN VARCHAR2 DEFAULT NULL,
                        p_al                IN VARCHAR2 DEFAULT NULL,
                        p_nome              IN VARCHAR2 DEFAULT NULL,
                        p_progr_unita       IN NUMBER   DEFAULT NULL)
      RETURN INTEGER;

   FUNCTION get_email (p_unita VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_nome_so4 (p_unita VARCHAR2, p_data date default sysdate)
      RETURN VARCHAR2;

   FUNCTION get_tagmail (p_unita                     VARCHAR2,
                         p_codice_amministrazione    VARCHAR2,
                         p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************
    NOME:        get_classifiche_unita
    DESCRIZIONE: Dato unitý, codice amministrazione, codice aoo, restituisce la lista di
                 classificazioni associata alla relativa unitý.

    PARAMETRI:   p_unita                     codice unitý
                 p_codice_amm    codice dell'amministrazione per la quale p_utente lavora
                 p_codice_aoo                codice dell'aoo per la quale p_utente lavora

    RITORNA:     t_ref_cursor
   ******************************************************************************/
   FUNCTION get_classifiche_unita (
      p_unita        IN SEG_UNITA.unita%TYPE,
      p_codice_amm   IN SEG_UNITA.codice_amministrazione%TYPE,
      p_codice_aoo   IN SEG_UNITA.codice_aoo%TYPE)
      RETURN afc.t_ref_cursor;

   /*************************************************************************************************************************
    NOME:        elimina_classifiche_abilitate
    DESCRIZIONE: Elimina la lista di classifiche associate ad una unitý.
                 Viene settato lo stato del documento in CA.

    PARAMETRI:   p_lista                     lista di classifiche da eliminare (sequenza di id_docuemnto)
                 p_separatore                la stringa separatore per estrapolare la sequenza di id_docuemnto
                 p_utente                    utente che effettua l'operazione
                 p_use_commit_rollback       indica se effettuare il commit o rollback. Vale '1' o '0' di default '1'.
                                             Se vale '1' viene effettuato l'operazione di commit o rollback, '0' altrimenti.

   ***************************************************************************************************************************/
   PROCEDURE elimina_classifiche_abilitate (
      p_lista                    VARCHAR2,
      p_separatore               VARCHAR2,
      p_utente                IN ad4_utenti.utente%TYPE,
      p_use_commit_rollback      VARCHAR2 DEFAULT '1');

   FUNCTION get_nome_between (
      p_unita        IN VARCHAR2,
      p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
      p_codice_aoo   IN seg_unita.codice_aoo%TYPE,
      p_data_rif        DATE)
      RETURN VARCHAR2;
END seg_unita_pkg;
/
CREATE OR REPLACE PACKAGE BODY seg_unita_pkg
IS
   /******************************************************************************
    NOME:        seg_unita_pkg
    DESCRIZIONE: Gestione tabella SEG_UNITA.
    ANNOTAZIONI: .
    REVISIONI:   .
    Rev.  Data        Autore  Descrizione.
    000   02/09/2009  MMalferrari  Prima emissione.
    001   17/05/2011  MMalferrari  Modifiche versione 2.1.
    002   07/12/2016  MMalferrari  Creata get_nome_between
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '002';

   --------------------------------------------------------------------------------
   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilitý del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;                                     -- seg_unita_tpk.versione

   --------------------------------------------------------------------------------
   FUNCTION pk (p_progr_unita   IN seg_unita.progr_unita_organizzativa%TYPE,
                p_dal           IN seg_unita.dal%TYPE)
      RETURN t_pk
   IS
      /******************************************************************************
       NOME:        PK
       DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
      ******************************************************************************/
      d_result   t_pk;
   BEGIN
      d_result.progr_unita := p_progr_unita;
      d_result.dal := p_dal;
      RETURN d_result;
   END pk;                                                 -- seg_unita_tpk.PK

   --------------------------------------------------------------------------------
   FUNCTION can_handle (
      p_progr_unita   IN SEG_UNITA.progr_unita_organizzativa%TYPE,
      p_dal           IN seg_unita.dal%TYPE)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        can_handle
       DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
       PARAMETRI:   Attributi chiave.
       RITORNA:     number: 1 se la chiave ý manipolabile, 0 altrimenti.
       NOTE:        cfr. canHandle per ritorno valori boolean.
      ******************************************************************************/
      d_result   NUMBER;
   BEGIN
      d_result := 1;

      -- nelle chiavi primarie composte da piý attributi, ciascun attributo deve essere not null
      IF d_result = 1 AND (p_progr_unita IS NULL OR p_dal IS NULL)
      THEN
         d_result := 0;
      END IF;
   END can_handle;                                 -- seg_unita_tpk.can_handle

   --------------------------------------------------------------------------------
   FUNCTION canhandle (
      p_progr_unita   IN SEG_UNITA.progr_unita_organizzativa%TYPE,
      p_dal           IN seg_unita.dal%TYPE)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        canHandle
       DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
       PARAMETRI:   Attributi chiave.
       RITORNA:     number: true se la chiave ý manipolabile, false altrimenti.
       NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
      ******************************************************************************/
      d_result   CONSTANT BOOLEAN
         := afc.to_boolean (
               can_handle (p_progr_unita => p_progr_unita, p_dal => p_dal)) ;
   BEGIN
      RETURN d_result;
   END canhandle;                                   -- seg_unita_tpk.canHandle

   --------------------------------------------------------------------------------
   FUNCTION exists_id (
      p_progr_unita   IN seg_unita.progr_unita_organizzativa%TYPE,
      p_dal           IN seg_unita.dal%TYPE)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        exists_id
       DESCRIZIONE: Esistenza riga con chiave indicata.
       PARAMETRI:   Attributi chiave.
       RITORNA:     number: 1 se la riga esiste, 0 altrimenti.
       NOTE:        cfr. existsId per ritorno valori boolean.
      ******************************************************************************/
      d_result   NUMBER;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_result
           FROM seg_unita
          WHERE progr_unita_organizzativa = p_progr_unita AND dal = p_dal;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_result := 0;
      END;

      RETURN d_result;
   END exists_id;

   --------------------------------------------------------------------------------
   FUNCTION exists_id (
      p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
      p_codice_aoo   IN seg_unita.codice_aoo%TYPE,
      p_unita        IN seg_unita.unita%TYPE,
      p_dal          IN seg_unita.dal%TYPE)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        exists_id
       DESCRIZIONE: Esistenza riga con chiave indicata.
       PARAMETRI:   Attributi chiave.
       RITORNA:     number: 1 se la riga esiste, 0 altrimenti.
       NOTE:        cfr. existsId per ritorno valori boolean.
      ******************************************************************************/
      d_result   NUMBER;
   BEGIN
      RETURN exists_id (
                so4_ags_pkg.anuo_get_progr (
                   p_amministrazione   => p_codice_amm,
                   p_codice_uo         => p_unita,
                   p_data              => p_dal),
                p_dal);
   END exists_id;

   --------------------------------------------------------------------------------
   FUNCTION existsid (
      p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
      p_codice_aoo   IN seg_unita.codice_aoo%TYPE,
      p_unita        IN seg_unita.unita%TYPE,
      p_dal          IN seg_unita.dal%TYPE)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        existsId
       DESCRIZIONE: Esistenza riga con chiave indicata.
       NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
      ******************************************************************************/
      d_result   CONSTANT BOOLEAN
                             := afc.to_boolean (
                                   exists_id (p_codice_amm   => p_codice_amm,
                                              p_codice_aoo   => p_codice_aoo,
                                              p_unita        => p_unita,
                                              p_dal          => p_dal)) ;
   BEGIN
      RETURN d_result;
   END existsid;                                     -- seg_unita_tpk.existsId

   --------------------------------------------------------------------------------
   FUNCTION get_al (
      p_progr_unita   IN seg_unita.progr_unita_organizzativa%TYPE,
      p_dal           IN seg_unita.dal%TYPE)
      RETURN seg_unita.al%TYPE
   IS
      /******************************************************************************
       NOME:        get_al
       DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
       PARAMETRI:   Attributi chiave.
       RITORNA:     SEG_UNITA.al%type.
       NOTE:        La riga identificata deve essere presente.
      ******************************************************************************/
      d_result   seg_unita.al%TYPE;
   BEGIN
      SELECT al
        INTO d_result
        FROM seg_unita
       WHERE progr_unita_organizzativa = p_progr_unita AND dal = p_dal;

      RETURN d_result;
   END get_al;

   --------------------------------------------------------------------------------
   FUNCTION get_al (p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
                    p_codice_aoo   IN seg_unita.codice_aoo%TYPE,
                    p_unita        IN seg_unita.unita%TYPE,
                    p_dal          IN seg_unita.dal%TYPE)
      RETURN seg_unita.al%TYPE
   IS
      /******************************************************************************
       NOME:        get_al
       DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
       PARAMETRI:   Attributi chiave.
       RITORNA:     SEG_UNITA.al%type.
       NOTE:        La riga identificata deve essere presente.
      ******************************************************************************/
      d_result   seg_unita.al%TYPE;
   BEGIN
      RETURN get_al (
                so4_ags_pkg.anuo_get_progr (
                   p_amministrazione   => p_codice_amm,
                   p_codice_uo         => p_unita,
                   p_data              => p_dal),
                p_dal);
   END get_al;

   --------------------------------------------------------------------------------
   FUNCTION get_nome (
      p_progr_unita   IN seg_unita.progr_unita_organizzativa%TYPE,
      p_dal           IN seg_unita.dal%TYPE)
      RETURN seg_unita.nome%TYPE
   IS
      /******************************************************************************
       NOME:        get_al
       DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
       PARAMETRI:   Attributi chiave.
       RITORNA:     SEG_UNITA.al%type.
       NOTE:        La riga identificata deve essere presente.
      ******************************************************************************/
      d_result   seg_unita.nome%TYPE;
   BEGIN
      SELECT nome
        INTO d_result
        FROM seg_unita
       WHERE progr_unita_organizzativa = p_progr_unita AND dal = p_dal;

      RETURN d_result;
   END get_nome;                                     -- seg_unita_tpk.get_nome

   --------------------------------------------------------------------------------
   FUNCTION get_nome (
      p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
      p_codice_aoo   IN seg_unita.codice_aoo%TYPE,
      p_unita        IN seg_unita.unita%TYPE,
      p_dal          IN seg_unita.dal%TYPE)
      RETURN seg_unita.nome%TYPE
   IS
      /******************************************************************************
       NOME:        get_nome
       DESCRIZIONE: Getter per attributo nome di riga identificata dalla chiave.
       PARAMETRI:   Attributi chiave.
       RITORNA:     SEG_UNITA.nome%type.
       NOTE:        La riga identificata deve essere presente.
      ******************************************************************************/
      d_result   seg_unita.nome%TYPE;
   BEGIN
      RETURN get_nome (
                so4_ags_pkg.anuo_get_progr (
                   p_amministrazione   => p_codice_amm,
                   p_codice_uo         => p_unita,
                   p_data              => p_dal),
                p_dal);
   END get_nome;                                     -- seg_unita_tpk.get_nome

   --------------------------------------------------------------------------------
   FUNCTION where_condition (p_qbe               IN NUMBER DEFAULT 0,
                             p_other_condition   IN VARCHAR2 DEFAULT NULL,
                             p_codice_amm        IN VARCHAR2 DEFAULT NULL,
                             p_codice_aoo        IN VARCHAR2 DEFAULT NULL,
                             p_unita             IN VARCHAR2 DEFAULT NULL,
                             p_dal               IN VARCHAR2 DEFAULT NULL,
                             p_al                IN VARCHAR2 DEFAULT NULL,
                             p_nome              IN VARCHAR2 DEFAULT NULL,
                             p_progr_unita       IN NUMBER DEFAULT NULL)
      RETURN afc.t_statement
   IS
      /******************************************************************************
       NOME:        where_condition
       DESCRIZIONE: Ritorna la where_condition per lo statement di select di get_rows e count_rows.
       PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo ý presente
                             un operatore, altrimenti viene usato quello di default ('=')
                          1: viene utilizzato l'operatore specificato all'inizio di ogni
                             attributo.
                    p_other_condition: condizioni aggiuntive di base
                    Chiavi e attributi della table
       RITORNA:     AFC.t_statement.
       NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
                    l'operatore da utilizzare nella where-condition.
      ******************************************************************************/
      d_statement   afc.t_statement;
   BEGIN
      d_statement :=
            ' where ( 1 = 1 '
         || afc.get_field_condition (' and ( codice_amministrazione ',
                                     p_codice_amm,
                                     ' )',
                                     p_qbe,
                                     NULL)
         || afc.get_field_condition (' and ( codice_aoo ',
                                     p_codice_aoo,
                                     ' )',
                                     p_qbe,
                                     NULL)
         || afc.get_field_condition (' and ( unita ',
                                     p_unita,
                                     ' )',
                                     p_qbe,
                                     NULL)
         || afc.get_field_condition (' and ( dal ',
                                     p_dal,
                                     ' )',
                                     p_qbe,
                                     afc.DATE_FORMAT)
         || afc.get_field_condition (' and ( al ',
                                     p_al,
                                     ' )',
                                     p_qbe,
                                     afc.DATE_FORMAT)
         || afc.get_field_condition (' and ( nome ',
                                     p_nome,
                                     ' )',
                                     p_qbe,
                                     NULL)
         || afc.get_field_condition (' and ( progr_unita_organizzativa ',
                                     p_progr_unita,
                                     ' )',
                                     p_qbe,
                                     NULL)
         || ' ) '
         || p_other_condition;
      RETURN d_statement;
   END where_condition;                      --- seg_unita_tpk.where_condition

   --------------------------------------------------------------------------------
   FUNCTION get_unita_between (p_unita IN VARCHAR2, p_data_rif VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        get_unita_protocollante
       DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
       PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo ý presente
                             un operatore, altrimenti viene usato quello di default ('=')
                          1: viene utilizzato l'operatore specificato all'inizio di ogni
                             attributo.
                    p_other_condition: condizioni aggiuntive di base
                    p_order_by: condizioni di ordinamento
                    p_extra_columns: colonne da aggiungere alla select
                    p_extra_condition: condizioni aggiuntive
                    Chiavi e attributi della table
       RITORNA:     Un ref_cursor che punta al risultato della query.

      ******************************************************************************/
      d_statement    afc.t_statement;
      d_ref_cursor   afc.t_ref_cursor;
      d_count        NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO d_count
        FROM seg_unita
       WHERE     unita = p_unita
             AND TO_DATE (p_data_rif, 'dd/mm/yyyy hh24:mi:ss') BETWEEN dal
                                                                   AND NVL (
                                                                          al,
                                                                          TO_DATE (
                                                                             3333333,
                                                                             'j'));

      IF d_count > 0
      THEN
         d_statement :=
               ' select (SELECT so4_ags_pkg.unita_get_radice(progr_unita_organizzativa, null, to_date('''
            || p_data_rif
            || ''', ''dd/mm/yyyy hh24:mi:ss''), codice_amministrazione) from dual) as DIPARTIMENTO, AL, CODICE_AMMINISTRAZIONE, CODICE_AOO, DAL, NOME, UNITA '
            || ' from SEG_UNITA '
            || ' where unita = '''
            || p_unita
            || ''''
            || '   and to_date('''
            || p_data_rif
            || ''', ''dd/mm/yyyy hh24:mi:ss'') between dal and nvl(al,to_date(3333333, ''j''))';
      ELSE
         DECLARE
            d_dal   VARCHAR2 (10);
         BEGIN
            SELECT TO_CHAR (MAX (dal), 'dd/mm/yyyy')
              INTO d_dal
              FROM seg_unita
             WHERE unita = p_unita;

            d_statement :=
                  ' select (SELECT so4_ags_pkg.unita_get_radice(progr_unita_organizzativa, null, dal, codice_amministrazione) from dual) as DIPARTIMENTO, AL, CODICE_AMMINISTRAZIONE, CODICE_AOO, DAL, NOME, UNITA '
               || '   from SEG_UNITA '
               || '  where unita = '''
               || p_unita
               || ''' '
               || '    and dal = to_date('''
               || d_dal
               || ''', ''dd/mm/yyyy'')';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_statement :=
                     ' select (SELECT so4_ags_pkg.unita_get_radice('''
                  || p_unita
                  || ''') from dual) as DIPARTIMENTO, AL, CODICE_AMMINISTRAZIONE, CODICE_AOO, DAL, NOME, UNITA '
                  || '   from SEG_UNITA '
                  || '  where 1 = 2';
         END;
      END IF;

      DBMS_OUTPUT.put_line (d_statement);
      d_ref_cursor := afc_dml.get_ref_cursor (d_statement);
      RETURN d_ref_cursor;
   END;

   --------------------------------------------------------------------------------

   FUNCTION get_nome_between (
      p_unita        IN VARCHAR2,
      p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
      p_codice_aoo   IN seg_unita.codice_aoo%TYPE,
      p_data_rif        DATE)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        get_unita_protocollante
       DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
       PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo ý presente
                             un operatore, altrimenti viene usato quello di default ('=')
                          1: viene utilizzato l'operatore specificato all'inizio di ogni
                             attributo.
                    p_other_condition: condizioni aggiuntive di base
                    p_order_by: condizioni di ordinamento
                    p_extra_columns: colonne da aggiungere alla select
                    p_extra_condition: condizioni aggiuntive
                    Chiavi e attributi della table
       RITORNA:     Un ref_cursor che punta al risultato della query.

      ******************************************************************************/
      d_count   NUMBER;
      d_nome    VARCHAR2 (1000);
   BEGIN
      BEGIN
         SELECT nome
           INTO d_nome
           FROM seg_unita
          WHERE     unita = p_unita
                AND codice_amministrazione = p_codice_amm
                AND p_codice_aoo = p_codice_aoo
                AND p_data_rif BETWEEN dal
                                   AND NVL (al, TO_DATE (3333333, 'j'));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DECLARE
               d_dal   VARCHAR2 (10);
            BEGIN
               SELECT TO_CHAR (MAX (dal), 'dd/mm/yyyy')
                 INTO d_dal
                 FROM seg_unita
                WHERE unita = p_unita;

               SELECT NOME
                 INTO d_nome
                 FROM seg_unita
                WHERE     unita = p_unita
                      AND codice_amministrazione = p_codice_amm
                      AND p_codice_aoo = p_codice_aoo
                      AND dal = TO_DATE (d_dal, 'dd/mm/yyyy');
            END;
         WHEN OTHERS
         THEN
            d_nome := '';
      END;

      RETURN d_nome;
   END;

   FUNCTION get_rows (p_qbe               IN NUMBER DEFAULT 0,
                      p_other_condition   IN VARCHAR2 DEFAULT NULL,
                      p_order_by          IN VARCHAR2 DEFAULT NULL,
                      p_extra_columns     IN VARCHAR2 DEFAULT NULL,
                      p_extra_condition   IN VARCHAR2 DEFAULT NULL,
                      p_codice_amm        IN VARCHAR2 DEFAULT NULL,
                      p_codice_aoo        IN VARCHAR2 DEFAULT NULL,
                      p_unita             IN VARCHAR2 DEFAULT NULL,
                      p_dal               IN VARCHAR2 DEFAULT NULL,
                      p_al                IN VARCHAR2 DEFAULT NULL,
                      p_nome              IN VARCHAR2 DEFAULT NULL,
                      p_progr_unita       IN NUMBER DEFAULT NULL)
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        get_rows
       DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
       PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo ý presente
                             un operatore, altrimenti viene usato quello di default ('=')
                          1: viene utilizzato l'operatore specificato all'inizio di ogni
                             attributo.
                    p_other_condition: condizioni aggiuntive di base
                    p_order_by: condizioni di ordinamento
                    p_extra_columns: colonne da aggiungere alla select
                    p_extra_condition: condizioni aggiuntive
                    Chiavi e attributi della table
       RITORNA:     Un ref_cursor che punta al risultato della query.
       NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
                    l'operatore da utilizzare nella where-condition.
                    In p_extra_columns e p_order_by non devono essere passati anche la
                    virgola iniziale (per p_extra_columns) e la stringa 'order by' (per
                    p_order_by)
      ******************************************************************************/
      d_statement    afc.t_statement;
      d_ref_cursor   afc.t_ref_cursor;
   BEGIN
      d_statement :=
            ' select progr_unita_organizzativa, AL, CODICE_AMMINISTRAZIONE, CODICE_AOO, DAL, NOME, UNITA, DESC_ABBREVIATA, TAG_MAIL, INDIRIZZO_MAIL_IST '
         || afc.decode_value (p_extra_columns,
                              NULL,
                              NULL,
                              ' , ' || p_extra_columns)
         || ' from seg_UNITA '
         || where_condition (p_qbe               => p_qbe,
                             p_other_condition   => p_other_condition,
                             p_codice_amm        => p_codice_amm,
                             p_codice_aoo        => p_codice_aoo,
                             p_unita             => p_unita,
                             p_dal               => p_dal,
                             p_al                => p_al,
                             p_nome              => p_nome,
                             p_progr_unita       => p_progr_unita)
         || ' '
         || p_extra_condition
         || afc.decode_value (p_order_by,
                              NULL,
                              NULL,
                              ' order by ' || p_order_by);
      DBMS_OUTPUT.PUT_LINE (d_statement);
      d_ref_cursor := afc_dml.get_ref_cursor (d_statement);
      RETURN d_ref_cursor;
   END get_rows;                                     -- seg_unita_tpk.get_rows

   --------------------------------------------------------------------------------
   FUNCTION count_rows (p_qbe               IN NUMBER DEFAULT 0,
                        p_other_condition   IN VARCHAR2 DEFAULT NULL,
                        p_codice_amm        IN VARCHAR2 DEFAULT NULL,
                        p_codice_aoo        IN VARCHAR2 DEFAULT NULL,
                        p_unita             IN VARCHAR2 DEFAULT NULL,
                        p_dal               IN VARCHAR2 DEFAULT NULL,
                        p_al                IN VARCHAR2 DEFAULT NULL,
                        p_nome              IN VARCHAR2 DEFAULT NULL,
                        p_progr_unita       IN NUMBER DEFAULT NULL)
      RETURN INTEGER
   IS
      /******************************************************************************
       NOME:        count_rows
       DESCRIZIONE: Ritorna il numero di righe della tabella gli attributi delle quali
                    rispettano i valori indicati.
       PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo ý presente
                             un operatore, altrimenti viene usato quello di default ('=')
                          1: viene utilizzato l'operatore specificato all'inizio di ogni
                             attributo.
                    p_other_condition: condizioni aggiuntive di base
                    Chiavi e attributi della table
       RITORNA:     Numero di righe che rispettano la selezione indicata.
      ******************************************************************************/
      d_result      INTEGER;
      d_statement   afc.t_statement;
   BEGIN
      d_statement :=
            ' select count( 1 ) from SEG_UNITA '
         || where_condition (p_qbe               => p_qbe,
                             p_other_condition   => p_other_condition,
                             p_codice_amm        => p_codice_amm,
                             p_codice_aoo        => p_codice_aoo,
                             p_unita             => p_unita,
                             p_dal               => p_dal,
                             p_al                => p_al,
                             p_nome              => p_nome,
                             p_progr_unita       => p_progr_unita);
      d_result := afc.sql_execute (d_statement);
      RETURN d_result;
   END count_rows;                                 -- seg_unita_tpk.count_rows

   --------------------------------------------------------------------------------
   FUNCTION get_email (p_unita VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (1000);
   BEGIN
      SELECT indirizzo_mail_ist
        INTO d_return
        FROM seg_unita
       WHERE unita = p_unita AND al IS NULL;

      RETURN d_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_nome_so4 (p_unita VARCHAR2, p_data DATE DEFAULT SYSDATE)
      RETURN VARCHAR2
   IS
      d_return     VARCHAR2 (1000);
      d_progr_uo   NUMBER;
      d_dal_uo     DATE;
   BEGIN
      SELECT progr_unita_organizzativa
        INTO d_progr_uo
        FROM seg_unita
       WHERE     unita = p_unita
             AND p_data BETWEEN dal AND NVL (al, TO_DATE (3333333, 'J'));

      d_return := so4_ags_pkg.anuo_get_descrizione (d_progr_uo, SYSDATE);

      RETURN d_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION get_tagmail (p_unita                     VARCHAR2,
                         p_codice_amministrazione    VARCHAR2,
                         p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return        VARCHAR2 (100);
      d_progr_unita   NUMBER;
   BEGIN
      d_progr_unita :=
         so4_ags_pkg.anuo_get_progr (
            p_amministrazione   => p_codice_amministrazione,
            p_codice_uo         => p_unita,
            p_data              => SYSDATE);

      SELECT tag_mail
        INTO d_return
        FROM seg_unita s
       WHERE s.progr_unita_organizzativa = d_progr_unita AND s.al IS NULL;

      RETURN d_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   /******************************************************************************
    NOME:        get_classifiche_unita
    DESCRIZIONE: Dato unitý, codice amministrazione, codice aoo, restituisce la lista di
                 classificazioni associata alla relativa unitý.

    PARAMETRI:   p_unita                     codice unitý
                 p_Codice_Amministrazione    codice dell'amministrazione per la quale p_utente lavora
                 p_codice_aoo                codice dell'aoo per la quale p_utente lavora

    RITORNA:     t_ref_cursor
   ******************************************************************************/
   FUNCTION get_classifiche_unita (
      p_unita        IN seg_unita.unita%TYPE,
      p_codice_amm   IN seg_unita.codice_amministrazione%TYPE,
      p_codice_aoo   IN seg_unita.codice_aoo%TYPE)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT suc.class_cod selezione,
                  suc.class_cod codice,
                  du.id_documento id_documento,
                  sc.class_al al
             FROM documenti du,
                  seg_unita_classifica suc,
                  seg_classificazioni sc,
                  documenti dc,
                  cartelle c
            WHERE     suc.id_documento = du.id_documento
                  AND du.stato_documento NOT IN ('CA', 'RE', 'PB')
                  AND suc.unita = p_unita
                  AND suc.codice_amministrazione = p_codice_amm
                  AND suc.codice_aoo = p_codice_aoo
                  AND suc.class_cod = sc.class_cod
                  AND suc.class_dal = sc.class_dal
                  AND sc.codice_amministrazione = p_codice_amm
                  AND sc.codice_aoo = p_codice_aoo
                  AND dc.id_documento = sc.id_documento
                  AND NVL (dc.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
                  AND c.id_documento_profilo = dc.id_documento
                  AND NVL (c.stato, 'BO') <> 'CA'
         ORDER BY suc.class_cod ASC, du.data_aggiornamento DESC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                  'get_classifiche_unita: ' || SQLERRM);
   END;

   /*************************************************************************************************************************
    NOME:        elimina_classifiche_abilitate
    DESCRIZIONE: Elimina la lista di classifiche associate ad una unita'.
                 Viene settato lo stato del documento in CA.

    PARAMETRI:   p_lista                     lista di classifiche da eliminare (sequenza di id_docuemnto)
                 p_separatore                la stringa separatore per estrapolare la sequenza di id_docuemnto
                 p_utente                    utente che effettua l'operazione
                 p_use_commit_rollback       indica se effettuare il commit o rollback. Vale '1' o '0' di default '1'.
                                             Se vale '1' viene effettuato l'operazione di commit o rollback, '0' altrimenti.

   ***************************************************************************************************************************/
   PROCEDURE elimina_classifiche_abilitate (
      p_lista                    VARCHAR2,
      p_separatore               VARCHAR2,
      p_utente                IN ad4_utenti.utente%TYPE,
      p_use_commit_rollback      VARCHAR2 DEFAULT '1')
   AS
      id_documento   VARCHAR2 (200);
      lista          VARCHAR2 (32000);
      RESULT         NUMBER (1) := 0;
   BEGIN
      BEGIN
         lista := p_lista;

         --dbms_output.put_line(lista);
         WHILE (LENGTH (lista) > 0)
         LOOP
            IF INSTR (lista, p_separatore) = 0
            THEN
               raise_application_error (
                  -20998,
                  'SEPARATORE NON CORRETTO ' || SQLERRM);
            ELSE
               id_documento :=
                  SUBSTR (lista, 1, INSTR (lista, p_separatore) - 1);
               --dbms_output.put_line(id_documento);
               RESULT := gdm_profilo.cancella (id_documento, p_utente);
               RESULT := 1;

               IF (RESULT = 1)
               THEN
                  lista := SUBSTR (lista, INSTR (lista, p_separatore) + 1);
               END IF;
            END IF;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
                  'IMPOSSIBILE ELIMINARE LA LISTA DI CLASSIFICHE (P_LISTA,P_SEPARATORE,P_UTENTE):('
               || p_lista
               || ','
               || p_separatore
               || ','
               || p_utente
               || ') '
               || SQLERRM);

            IF p_use_commit_rollback = '1'
            THEN
               COMMIT;
            END IF;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_use_commit_rollback = '1'
         THEN
            ROLLBACK;
         END IF;

         RAISE;
   END;
END seg_unita_pkg;
/
