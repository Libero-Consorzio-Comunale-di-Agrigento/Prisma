--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_AGGIORNAMENTI runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_UTILITIES_AGGIORNAMENTI"
AS
   /******************************************************************************
      NAME:       GDM.AG_UTILITIES_AGGIORNAMENTI
      PURPOSE:    Package di utilities per gli aggiornamenti del progetto di
                  AFFARI_GENERALI.
      REVISIONS:
      Ver         Date        Author            Description
      ---------   ----------  ---------------   ------------------------------------
      00          03/10/2006                    1. Created this package.
      01          17/05/2012  MMalferrari       Modifiche versione 2.1.
      02          15/07/2014  MMalferrari       Creata funzione SISTEMA_ORDINAMENTO_PROTOCOLLI
      03          18/02/2019  MMalferrari       creata gen_view_categoria e modificata
                                                gen_view_categoria_proto per gestione clob.
      04          23/05/2019  MMalferrari       esposta crea_index_proto
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.04';

   FUNCTION versione
      RETURN VARCHAR2;

   /*****************************************************************************
    NOME:        AGGIORNA_CODICE_AMM_AOO
    DESCRIZIONE: Cerca tutte le tabelle i cui modelli stanno in p_area e che hanno la coppia
    di campi codice_amministrazione e codice_aoo.
    Su tutte le righe di tali tabelle esegue l'update di codice_amministrazione e codice_aoo
    mettendoci i valori p_codice_amministrazione_new e p_codice_aoo_new se
    codice_amministrazione = p_codice_amministrazione_old e codice_aoo = p_codice_old.

   INPUT  p_area: area dei modelli di cui aggiornare le relative tabelle.
         p_codice_amministrazione_old varchar2: valore precedentemente registrato in
            codice_amministrazione.
         p_codice_aoo_old varchar2: valore precedentemente registrato in
            codice_aoo.
         p_codice_amministrazione_new varchar2: valore da registrare in
            codice_amministrazione.
         p_codice_aoo_new varchar2: valore da registrare in
            codice_aoo.

    Rev.  Data       Autore  Descrizione.
    00    15/10/2008  SC  Prima emissione Creazione installanti.
   ********************************************************************************/
   PROCEDURE aggiorna_codice_amm_aoo (
      p_area                          VARCHAR2,
      p_codice_amministrazione_old    VARCHAR2,
      p_codice_aoo_old                VARCHAR2,
      p_codice_amministrazione_new    VARCHAR2,
      p_codice_aoo_new                VARCHAR2,
      p_check_old                     NUMBER DEFAULT 1);

   /******************************************************************************
      NAME:       AG_GEN_VIEW_CATEGORIE
      PURPOSE:    Crea le viste delle categorie di affari generali

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/06/2008          1. Created this procedure.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_GEN_VIEW_CATEGORIE
         Sysdate:         27/06/2008
         Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   PROCEDURE ag_gen_view_categorie;

   /******************************************************************************
      NAME:       ATTIVA_MANUALI
      PURPOSE:    Attiva il manuale utente per le aree
                   Protocollo
                   Amministrazione
                   Posta Elettronica Certificata
                   Titolario.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/06/2008          1. Created this procedure.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_GEN_VIEW_CATEGORIE
         Sysdate:         27/06/2008
         Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   PROCEDURE attiva_manuali (p_path_manuali VARCHAR2);

   /******************************************************************************
    NAME:       ATTIVA_MANUALE_AREA
    PURPOSE:    Attiva il manuale utente per l'area di nome p_nome_area.

    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        27/06/2008          1. Created this procedure.

    NOTES:

    Automatically available Auto Replace Keywords:
       Object Name:     AG_GEN_VIEW_CATEGORIE
       Sysdate:         27/06/2008
       Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
       Username:         (set in TOAD Options, Procedure Editor)
       Table Name:       (set in the "New PL/SQL Object" dialog)

 ******************************************************************************/
   PROCEDURE attiva_manuale_area (p_nome_area       VARCHAR2,
                                  p_path_manuali    VARCHAR2);

   /******************************************************************************
      NAME:       AG_CREA_TRIGGER_PROTO
      PURPOSE: Crea i trigger per tutte le tabelle associate a modelli di categoria PROTO.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        01/12/2008          1. Created this procedure.
                 21/01/2009         SC  A30787.0.0  Modificata per
                                               eseguire anche l'update
                                               sulla data degli smsitamenti.
                 05/06/2009         SC         Setta id_documento_protocollo in
                                               inserting e updating, anziche solo update

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_CREA_TRIGGER_PROTO
         Sysdate:         01/12/2008
         Date and Time:   01/12/2008, 14.16.37, and 01/12/2008 14.16.37
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   PROCEDURE ag_crea_trigger_proto (p_categoria VARCHAR2);

   /******************************************************************************
      NAME:       CREA_UNIQUE_KEY_PROTO
      PURPOSE: Crea i le chiavi di unique key per tutte le tabelle
               associate a modelli di categoria PROTO.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        05/01/2010          SC  A35610.0.0

      NOTES:

   ******************************************************************************/
   PROCEDURE crea_unique_key_proto (p_categoria VARCHAR2);

   PROCEDURE add_col_lettera_uscita;

   PROCEDURE mod_tipo_col_lettera_uscita;

   PROCEDURE del_col_lettera_uscita;

   PROCEDURE add_col_tipo_registro_temp (p_categoria VARCHAR2);

   PROCEDURE add_col_utente_firma (p_categoria VARCHAR2);

   PROCEDURE add_col_data_verifica (p_categoria VARCHAR2);

   PROCEDURE add_col_m_provvedimento1;

   PROCEDURE mod_tipo_col_m_provvedimento1;

   PROCEDURE del_col_m_provvedimento1;

   PROCEDURE add_col_m_provvedimento2;

   PROCEDURE mod_tipo_col_m_provvedimento2;

   PROCEDURE del_col_m_provvedimento2;

   PROCEDURE crea_smistamenti_fascicoli;

   PROCEDURE add_col_verifica_firma (p_categoria VARCHAR2);

   PROCEDURE gen_view_categoria_proto (p_includi_clob number DEFAULT 0);

   FUNCTION genera_ordinamento_titolario (
      p_oggetto       IN links.id_oggetto%TYPE,
      p_modello       IN VARCHAR2,
      p_ordinamento   IN VARCHAR2 DEFAULT 'ANNO_DESC_DATA_ASC')
      RETURN VARCHAR2;

   PROCEDURE aggiorna_ordinamenti_cartella;

   PROCEDURE aggiorna_idrif_memo;

   PROCEDURE aggiorna_tipo_messaggio;

   PROCEDURE pulisci_riferimenti_mail;

   PROCEDURE sistema_precedenti;

   PROCEDURE aggiorna_segnatura_tido;

   PROCEDURE SISTEMA_ORDINAMENTO_PROTOCOLLI;

   PROCEDURE crea_index_proto (p_categoria VARCHAR2 DEFAULT 'PROTO');
END ag_utilities_aggiornamenti;
/
CREATE OR REPLACE PACKAGE BODY AG_UTILITIES_AGGIORNAMENTI
AS
   /******************************************************************************
      NAME:       GDM.AG_UTILITIES_AGGIORNAMENTI
      PURPOSE:    Package di utilities per gli aggiornamenti del progetto di AFFARI_GENERALI.
      REVISIONS:
    Rev. Data        Autore         Descrizione
    ---- ----------  ------         ----------------------------------------------
    001  01/02/2011  MMalferrari    Gestione campo TIPO_REGISTRO per PROTO_VIEW se
                                    modello di area diversa da SEGRETERIA e
                                    SEGRETERIA.PROTOCOLLO
    002  17/05/2012  MMalferrari    Modifiche versione 2.1.
    003  29/03/2013  MMalferrari    Modicata procedure crea_unique_key_proto
    004  08/04/2012  MMalferrari    Modicata procedure crea_unique_key_proto
    005  23/04/2014  MMalferrari    Modicata funzione genera_ordinamento_titolario
    006  15/07/2014  MMalferrari    Creata funzione SISTEMA_ORDINAMENTO_PROTOCOLLI
    007  18/08/2015  MMalferrari    Modificata ag_crea_trigger_proto per lancio
                                    aggiornamento smistamenti in postevent.
    008  24/11/2015  MMalferrari    Modicata procedura ag_crea_trigger_proto e
                                    crea_unique_key_proto per gestire modello
                                    M_PROTOCOLLO_DOCESTERNI.
    009  25/06/2018  SC             Modificata procedura ag_crea_trigger_proto per
                                    reimpostare :new.modalità = :old.modalita
                                    se la :new è null.
    010  18/02/2019  MMalferrari    creata gen_view_categoria e modificata
                                    gen_view_categoria_proto per gestione clob.
    011  23/08/2019  MMalferrari    Modificata check_tipo_docuemnto_registro per
                                    svuotamento campo DESCRIZIONE_TIPO_DOCUMENTO
                                    se TIPO_DOCUMENTO e' nullo.
    012  06/09/2019  MMalferrari    gen_view_categoria per gestione DATA_SPEDIZIONE
                                    di SEG_MEMO_PROTOCOLLO che ha tipo varchar
                                    al contrario delle tabelle di protocollo che
                                    sono date.
    020  23/05/2019  MMalferrari    Creata crea_nonunique_index_proto
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '020';

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
       Rev. Data        Autore         Descrizione
       ---- ----------  ------         ---------------------------------------------
       000  15/10/2008  SC             Prima emissione Creazione installanti.
      ******************************************************************************/
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   /*****************************************************************************
    NOME:        AGGIORNA_CODICE_AMM_AOO
    DESCRIZIONE: Cerca tutte le tabelle i cui modelli stanno in p_area e che hanno la coppia
    di campi codice_amministrazione e codice_aoo.
    Su tutte le righe di tali tabelle esegue l'update di codice_amministrazione e codice_aoo
    mettendoci i valori p_codice_amministrazione_new e p_codice_aoo_new se
    codice_amministrazione = p_codice_amministrazione_old e codice_aoo = p_codice_old.

   INPUT  p_area: area dei modelli di cui aggiornare le relative tabelle.
         p_codice_amministrazione_old varchar2: valore precedentemente registrato in
            codice_amministrazione.
         p_codice_aoo_old varchar2: valore precedentemente registrato in
            codice_aoo.
         p_codice_amministrazione_new varchar2: valore da registrare in
            codice_amministrazione.
         p_codice_aoo_new varchar2: valore da registrare in
            codice_aoo.

    Rev.  Data       Autore  Descrizione.
    00    15/10/2008  SC  Prima emissione Creazione installanti.
   ********************************************************************************/
   PROCEDURE aggiorna_codice_amm_aoo (
      p_area                          VARCHAR2,
      p_codice_amministrazione_old    VARCHAR2,
      p_codice_aoo_old                VARCHAR2,
      p_codice_amministrazione_new    VARCHAR2,
      p_codice_aoo_new                VARCHAR2,
      p_check_old                     NUMBER)
   AS
      dep_esegui   NUMBER;
      dep_stmt     VARCHAR2 (32000);
   BEGIN
      FOR tabelle
         IN (SELECT aree.acronimo || '_' || tipi_documento.alias_modello nome
               FROM tipi_documento, aree
              WHERE     area_modello = aree.area
                    AND ishorizontal_model = 1
                    AND aree.area = p_area)
      LOOP
         dep_esegui := 0;

         SELECT COUNT (1)
           INTO dep_esegui
           FROM user_tab_columns, tab
          WHERE     user_tab_columns.table_name = tabelle.nome
                AND user_tab_columns.column_name = 'CODICE_AMMINISTRAZIONE'
                AND EXISTS
                       (SELECT 1
                          FROM user_tab_columns utco2
                         WHERE     user_tab_columns.table_name =
                                      utco2.table_name
                               AND utco2.column_name = 'CODICE_AOO')
                AND tab.tname = user_tab_columns.table_name
                AND tab.tabtype = 'TABLE';

         IF dep_esegui = 1
         THEN
            dep_stmt := '';
            dep_stmt :=
                  'update '
               || tabelle.nome
               || ' set codice_amministrazione = '''
               || UPPER (p_codice_amministrazione_new)
               || ''', '
               || ' codice_aoo = '''
               || UPPER (p_codice_aoo_new)
               || '''';

            IF p_check_old = 1
            THEN
               dep_stmt := dep_stmt || ' where codice_amministrazione ';

               IF p_codice_amministrazione_old IS NOT NULL
               THEN
                  dep_stmt :=
                        dep_stmt
                     || ' = '''
                     || p_codice_amministrazione_old
                     || '''';
               ELSE
                  dep_stmt := dep_stmt || 'is null ';
               END IF;

               dep_stmt := dep_stmt || ' and codice_aoo ';

               IF p_codice_aoo_old IS NOT NULL
               THEN
                  dep_stmt := dep_stmt || ' = ''' || p_codice_aoo_old || '''';
               ELSE
                  dep_stmt := dep_stmt || 'is null ';
               END IF;
            END IF;

            EXECUTE IMMEDIATE dep_stmt;

            COMMIT;
         END IF;
      END LOOP;
   END;

   PROCEDURE gen_view_categoria (
      P_CATEGORIA       CATEGORIE_MODELLO.CATEGORIA%TYPE,
      p_includi_clob    NUMBER DEFAULT 0)
   IS
      SUBTYPE st_stringa IS VARCHAR2 (256);

      TYPE t_col IS RECORD
      (
         col_name    afc.t_object_name,
         type_data   st_stringa,
         data_size   NUMBER
      );

      TYPE tb_col IS TABLE OF t_col
         INDEX BY BINARY_INTEGER;

      d_col         tb_col;
      d_c_ub        INTEGER := 0;
      d_body        DBMS_SQL.varchar2s;
      d_body_ub     INTEGER := 0;
      d_categoria   categorie_modello.categoria%TYPE := P_CATEGORIA;
      D_ESISTE      NUMBER (1) := 0;
      D_CURSOR      INTEGER;
      D_RET_VAL     INTEGER;

      CURSOR CAMPI
      IS
           SELECT UPPER (DM.DATO) DATO,
                  D.TIPO TIPO,
                  MAX (d.lunghezza) lunghezza
             FROM CATEGORIE_MODELLO CM, DATI_MODELLO DM, DATI D
            WHERE     CM.CATEGORIA = D_CATEGORIA
                  AND DM.AREA = CM.AREA
                  AND DM.CODICE_MODELLO = CM.CODICE_MODELLO
                  AND D.AREA = DM.AREA_DATO
                  AND D.DATO = DM.DATO
                  AND D.LUNGHEZZA <= 4000
                  AND DM.IN_USO = 'Y'
                  AND (   p_includi_clob = 1
                       OR dm.dato = 'MOTIVO_RICH_INTERVENTO'
                       OR SIGN (d.lunghezza - 4000) <= 0)
         GROUP BY DM.DATO, D.TIPO
         ORDER BY 1;
   BEGIN
      FOR C_CAMPI IN CAMPI
      LOOP
         D_COL (D_C_UB).COL_NAME := C_CAMPI.DATO;
         D_COL (D_C_UB).TYPE_DATA := C_CAMPI.TIPO;
         d_col (d_c_ub).data_size := c_campi.lunghezza;
         D_C_UB := D_C_UB + 1;
      END LOOP;

      D_BODY (D_BODY_UB) :=
         'create or replace force view ' || D_CATEGORIA || '_view ';
      D_BODY_UB := D_BODY_UB + 1;
      D_BODY (D_BODY_UB) := '( id_documento, ';
      D_BODY_UB := D_BODY_UB + 1;

      FOR J IN D_COL.FIRST .. D_COL.LAST
      LOOP
         D_BODY (D_BODY_UB) := D_COL (J).COL_NAME || ', ';
         D_BODY_UB := D_BODY_UB + 1;
      END LOOP;

      D_BODY (D_BODY.LAST) := RTRIM (D_BODY (D_BODY.LAST), ', ');
      D_BODY (D_BODY_UB) := ' ,FULL_TEXT) as';

      /* ESTRAGGO LE TABELLE DELLA STESSA CATEGORIA */
      FOR C_TAB
         IN (SELECT UPPER (A.ACRONIMO || '_' || ALIAS_MODELLO) NOME_TABELLA
               FROM CATEGORIE_MODELLO CM,
                    MODELLI M,
                    AREE A,
                    TIPI_DOCUMENTO TD,
                    USER_OBJECTS UO
              WHERE     CM.CATEGORIA = D_CATEGORIA
                    AND M.AREA = CM.AREA
                    AND M.AREA = A.AREA
                    AND M.CODICE_MODELLO = CM.CODICE_MODELLO
                    AND M.CODICE_MODELLO_PADRE IS NULL
                    AND M.ID_TIPODOC = TD.ID_TIPODOC
                    AND UO.OBJECT_NAME =
                           UPPER (A.ACRONIMO || '_' || ALIAS_MODELLO))
      LOOP
         D_BODY_UB := D_BODY_UB + 1;
         D_BODY (D_BODY_UB) := 'select id_documento, ';

         --        D_BODY_UB := D_BODY_UB + 1;
         /* LOOP SULLE COLONNE */
         FOR J IN D_COL.FIRST .. D_COL.LAST
         LOOP
            D_BODY_UB := D_BODY_UB + 1;

            SELECT NVL (MAX (1), 0)
              INTO D_ESISTE
              FROM USER_TAB_COLUMNS
             WHERE     TABLE_NAME = C_TAB.NOME_TABELLA
                   AND COLUMN_NAME = UPPER (D_COL (J).COL_NAME);

            IF d_esiste = 1
            THEN
               IF     d_col (j).col_name = 'DATA_SPEDIZIONE'
                  AND C_TAB.NOME_TABELLA = 'SEG_MEMO_PROTOCOLLO'
                  and d_categoria IN ('CLASSIFICABILE', 'SMISTABILE')

               THEN
                  d_body (d_body_ub) :=
                     'to_date(null) ' || D_COL (J).COL_NAME || ', ';
               ELSE
                  d_body (d_body_ub) := D_COL (J).COL_NAME || ', ';
               END IF;
            ELSE
               IF d_col (j).TYPE_DATA = 'S'
               THEN
                  IF d_col (j).data_size <= 4000
                  THEN
                     d_body (d_body_ub) :=
                        'to_char(null) ' || d_col (j).col_name || ', ';
                  ELSE
                     d_body (d_body_ub) :=
                        'to_clob(null) ' || d_col (j).col_name || ', ';
                  END IF;
               ELSIF D_COL (J).TYPE_DATA = 'N'
               THEN
                  D_BODY (D_BODY_UB) :=
                     'to_number(null) ' || D_COL (J).COL_NAME || ', ';
               ELSIF D_COL (J).TYPE_DATA = 'D'
               THEN
                  D_BODY (D_BODY_UB) :=
                     'to_date(null) ' || D_COL (J).COL_NAME || ', ';
               END IF;
            END IF;
         END LOOP;

         D_BODY_UB := D_BODY_UB + 1;
         D_BODY (D_BODY_UB) := 'FULL_TEXT ,';
         D_BODY (D_BODY.LAST) := RTRIM (D_BODY (D_BODY.LAST), ', ');
         D_BODY_UB := D_BODY_UB + 1;
         D_BODY (D_BODY_UB) := 'from ' || C_TAB.NOME_TABELLA;
         D_BODY_UB := D_BODY_UB + 1;
         D_BODY (D_BODY_UB) := 'union all';
      END LOOP;

      IF D_BODY (D_BODY_UB) = 'union all'
      THEN
         D_BODY.DELETE (D_BODY_UB);
      END IF;

      D_CURSOR := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (D_CURSOR,
                      D_BODY,
                      D_BODY.FIRST,
                      D_BODY.LAST,
                      TRUE,
                      DBMS_SQL.NATIVE);
      D_RET_VAL := DBMS_SQL.EXECUTE (D_CURSOR);
      DBMS_SQL.CLOSE_CURSOR (D_CURSOR);
      D_BODY.DELETE;
      D_BODY_UB := 0;
   END;

   PROCEDURE gen_view_categoria_proto (p_includi_clob NUMBER DEFAULT 0)
   IS
      SUBTYPE st_stringa IS VARCHAR2 (256);

      TYPE t_col IS RECORD
      (
         col_name    afc.t_object_name,
         data_type   st_stringa,
         data_size   NUMBER
      );

      TYPE tb_col IS TABLE OF t_col
         INDEX BY BINARY_INTEGER;

      d_col         tb_col;
      d_c_ub        INTEGER := 0;
      d_body        DBMS_SQL.varchar2s;
      d_body_ub     INTEGER := 0;
      d_categoria   categorie_modello.categoria%TYPE := 'PROTO';
      d_esiste      NUMBER (1) := 0;
      d_cursor      INTEGER;
      d_ret_val     INTEGER;
      d_col_type    VARCHAR2 (100);

      CURSOR campi
      IS
           SELECT UPPER (DM.DATO) DATO,
                  D.TIPO TIPO,
                  MAX (d.lunghezza) lunghezza
             FROM categorie_modello cm, dati_modello dm, dati d
            WHERE     cm.categoria = d_categoria
                  AND dm.area = cm.area
                  AND dm.codice_modello = cm.codice_modello
                  AND d.area = dm.area_dato
                  AND d.dato = dm.dato
                  AND dm.in_uso = 'Y'
                  AND cm.area IN ('SEGRETERIA', 'SEGRETERIA.PROTOCOLLO')
                  AND (   p_includi_clob = 1
                       OR dm.dato = 'MOTIVO_RICH_INTERVENTO'
                       OR SIGN (d.lunghezza - 4000) <= 0)
         GROUP BY DM.DATO, D.TIPO
         ORDER BY 1;
   BEGIN
      FOR c_campi IN campi
      LOOP
         d_col (d_c_ub).col_name := c_campi.dato;
         d_col (d_c_ub).data_type := c_campi.tipo;
         d_col (d_c_ub).data_size := c_campi.lunghezza;
         d_c_ub := d_c_ub + 1;
      END LOOP;

      d_body (d_body_ub) :=
         'create or replace force view ' || d_categoria || '_view ';
      d_body_ub := d_body_ub + 1;
      d_body (d_body_ub) := '( id_documento, ';
      d_body_ub := d_body_ub + 1;

      FOR j IN d_col.FIRST .. d_col.LAST
      LOOP
         d_body (d_body_ub) := d_col (j).col_name || ', ';
         d_body_ub := d_body_ub + 1;
      END LOOP;

      d_body (d_body.LAST) := RTRIM (d_body (d_body.LAST), ', ');
      d_body (d_body_ub) := ' ,FULL_TEXT) as';

      /* ESTRAGGO LE TABELLE DELLA STESSA CATEGORIA */
      FOR c_tab
         IN (SELECT UPPER (a.acronimo || '_' || alias_modello) nome_tabella,
                    m.area area
               FROM categorie_modello cm,
                    modelli m,
                    aree a,
                    tipi_documento td,
                    user_objects uo
              WHERE     cm.categoria = d_categoria
                    AND m.area = cm.area
                    AND m.area = a.area
                    AND m.codice_modello = cm.codice_modello
                    AND m.codice_modello_padre IS NULL
                    AND m.id_tipodoc = td.id_tipodoc
                    AND uo.object_name =
                           UPPER (a.acronimo || '_' || alias_modello))
      LOOP
         d_body_ub := d_body_ub + 1;
         d_body (d_body_ub) := 'select id_documento, ';

         /* LOOP SULLE COLONNE */
         FOR j IN d_col.FIRST .. d_col.LAST
         LOOP
            d_body_ub := d_body_ub + 1;

            BEGIN
               SELECT data_type
                 INTO d_col_type
                 FROM user_tab_columns
                WHERE     table_name = c_tab.nome_tabella
                      AND column_name = UPPER (d_col (j).col_name);

               d_esiste := 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_esiste := 0;
            END;

            IF d_esiste = 1
            THEN
               -- controllo che i tipi siano compatibili
               IF     d_col (j).data_type = 'S'
                  AND d_col_type NOT IN ('CHAR', 'VARCHAR2', 'CLOB')
               THEN
                  d_esiste := 0;
               ELSIF     d_col (j).data_type = 'N'
                     AND d_col_type NOT IN ('NUMBER')
               THEN
                  d_esiste := 0;
               ELSIF d_col (j).data_type = 'D' AND d_col_type NOT IN ('DATE')
               THEN
                  d_esiste := 0;
               END IF;
            END IF;

            IF d_esiste = 1
            THEN
               IF     d_col (j).col_name = 'TIPO_REGISTRO'
                  AND c_tab.area NOT IN ('SEGRETERIA',
                                         'SEGRETERIA.PROTOCOLLO',
                                         'SEGRETERIA.ATTI.2_0')
               THEN
                  d_body (d_body_ub) :=
                        ''''
                     || ag_parametro.get_valore ('TIPO_REGISTRO_1',
                                                 '@agVar@',
                                                 '')
                     || ''' '
                     || d_col (j).col_name
                     || ', ';
               ELSE
                  d_body (d_body_ub) := d_col (j).col_name || ', ';
               END IF;
            ELSE
               IF     d_col (j).col_name = 'MASTER'
                  AND c_tab.area NOT IN ('SEGRETERIA',
                                         'SEGRETERIA.PROTOCOLLO')
               THEN
                  d_body (d_body_ub) := '''Y'' ' || d_col (j).col_name || ', ';
               ELSE
                  IF d_col (j).data_type = 'S'
                  THEN
                     IF d_col (j).data_size <= 4000
                     THEN
                        d_body (d_body_ub) :=
                           'to_char(null) ' || d_col (j).col_name || ', ';
                     ELSE
                        d_body (d_body_ub) :=
                           'to_clob(null) ' || d_col (j).col_name || ', ';
                     END IF;
                  ELSIF d_col (j).data_type = 'N'
                  THEN
                     d_body (d_body_ub) :=
                        'to_number(null) ' || d_col (j).col_name || ', ';
                  ELSIF d_col (j).data_type = 'D'
                  THEN
                     d_body (d_body_ub) :=
                        'to_date(null) ' || d_col (j).col_name || ', ';
                  END IF;
               END IF;
            END IF;
         END LOOP;

         d_body_ub := d_body_ub + 1;
         d_body (d_body_ub) := 'FULL_TEXT ,';
         d_body (d_body.LAST) := RTRIM (d_body (d_body.LAST), ', ');
         d_body_ub := d_body_ub + 1;
         d_body (d_body_ub) := 'from ' || c_tab.nome_tabella;
         d_body_ub := d_body_ub + 1;
         d_body (d_body_ub) := 'union all';
      END LOOP;

      IF d_body (d_body_ub) = 'union all'
      THEN
         d_body.DELETE (d_body_ub);
      END IF;

      d_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (d_cursor,
                      d_body,
                      d_body.FIRST,
                      d_body.LAST,
                      TRUE,
                      DBMS_SQL.native);
      d_ret_val := DBMS_SQL.EXECUTE (d_cursor);
      DBMS_SQL.close_cursor (d_cursor);
      d_body.DELETE;
      d_body_ub := 0;
   END;

   PROCEDURE ag_gen_view_categorie
   IS
      tmpvar   NUMBER;
   /******************************************************************************
      NAME:       AG_GEN_VIEW_CATEGORIE
      PURPOSE:    Crea le viste delle categorie di affari generali

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/06/2008          1. Created this procedure.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_GEN_VIEW_CATEGORIE
         Sysdate:         27/06/2008
         Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   BEGIN
      FOR c_categorie
         IN (SELECT DISTINCT cate.categoria
               FROM categorie cate, categorie_modello camo
              WHERE     cate.categoria = camo.categoria
                    AND camo.area IN ('SEGRETERIA', 'SEGRETERIA.PROTOCOLLO'))
      LOOP
         DBMS_OUTPUT.put_line (
            '********** ag_gen_view_categorie ' || c_categorie.categoria);

         IF c_categorie.categoria = 'PROTO'
         THEN
            gen_view_categoria_proto ();
         ELSE
            gen_view_categoria (c_categorie.categoria);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END ag_gen_view_categorie;

   FUNCTION get_id_workarea (p_nome_workarea VARCHAR2)
      RETURN NUMBER
   IS
      tmpvar   NUMBER;
   /******************************************************************************
      NAME:       GET_ID_WORKAREA
      PURPOSE:    Dato il nome della workarea, restituisce l'id

      INPUT p_nome_workarea varchar2.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        23/09/2009          1.        A34074.0.0.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_GEN_VIEW_CATEGORIE
         Sysdate:         27/06/2008
         Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   BEGIN
      SELECT id_cartella
        INTO tmpvar
        FROM cartelle
       WHERE     nome = p_nome_workarea
             AND NVL (stato, 'BO') <> 'CA'
             AND id_cartella < 0;

      RETURN tmpvar;
   END get_id_workarea;

   PROCEDURE attiva_manuale_area (p_nome_area       VARCHAR2,
                                  p_path_manuali    VARCHAR2)
   IS
      idarea   NUMBER;
   /******************************************************************************
      NAME:       ATTIVA_MANUALE_AREA
      PURPOSE:    Attiva il manuale utente per l'area di nome p_nome_area.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/06/2008          1. Created this procedure.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_GEN_VIEW_CATEGORIE
         Sysdate:         27/06/2008
         Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   BEGIN
      idarea := get_id_workarea (p_nome_area);
      gdc_utility_pkg.f_jdmsmanuali_insert_update (
         idarea,
         p_path_manuali || '/agspr/index.htm');
   END attiva_manuale_area;

   PROCEDURE attiva_manuali (p_path_manuali VARCHAR2)
   IS
      d_nome_area   parametri.valore%TYPE;
   /******************************************************************************
      NAME:       ATTIVA_MANUALI
      PURPOSE:    Attiva il manuale utente per le aree
                   Protocollo
                   Amministrazione
                   Posta Elettronica Certificata
                   Titolario.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/06/2008          1. Created this procedure.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_GEN_VIEW_CATEGORIE
         Sysdate:         27/06/2008
         Date and Time:   27/06/2008, 11.18.20, and 27/06/2008 11.18.20
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   BEGIN
      d_nome_area :=
         ag_parametro.get_valore (
            'WKAREA_ADMIN_' || ag_utilities.get_indice_aoo (NULL, NULL),
            '@agVar@',
            'Amministrazione');
      DBMS_OUTPUT.put_line ('d_nome_area ' || d_nome_area);
      attiva_manuale_area (d_nome_area, p_path_manuali);
      d_nome_area :=
         ag_parametro.get_valore (
            'WKAREA_INTEROP_' || ag_utilities.get_indice_aoo (NULL, NULL),
            '@agVar@',
            'Posta Elettronica Certificata');
      attiva_manuale_area (d_nome_area, p_path_manuali);
      d_nome_area :=
         ag_parametro.get_valore (
            'WKAREA_PROT_' || ag_utilities.get_indice_aoo (NULL, NULL),
            '@agVar@',
            'Protocollo');
      attiva_manuale_area (d_nome_area, p_path_manuali);
      d_nome_area :=
         ag_parametro.get_valore (
            'WKAREA_TITOLARIO_' || ag_utilities.get_indice_aoo (NULL, NULL),
            '@agVar@',
            'Titolario');
      attiva_manuale_area (d_nome_area, p_path_manuali);
   END attiva_manuali;

   FUNCTION get_trigger_leus (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
   /******************************************************************************
      NAME:       get_trigger_leus
      PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/03/2010         1. AA36823.0.0

   ******************************************************************************/
   BEGIN
      IF p_nome_tabella = 'SPR_LETTERE_USCITA'
      THEN
         depstmt :=
               'IF NVL (:NEW.so4_dirigente, ''*'') != NVL (:OLD.so4_dirigente, ''*'')'
            || '   AND :NEW.so4_dirigente IS NOT NULL '
            || 'THEN'
            || '   DECLARE'
            || '   dep_nome      VARCHAR2 (32000);'
            || '   dep_cognome   VARCHAR2 (32000);'
            || '   BEGIN'
            || '      dep_nome :=ag_utilities_flusso_lettera.get_nome_utente (:NEW.so4_dirigente);'
            || '      dep_cognome :=ag_utilities_flusso_lettera.get_cognome_utente(:NEW.so4_dirigente);'
            || '      IF NVL (dep_nome, ''*'') != ''*'''
            || '      THEN'
            || '         :NEW.dirigente := dep_cognome || '' '' || dep_nome;'
            || '         :NEW.dirigente_nome_cognome := dep_nome || '' '' || dep_cognome;'
            || '      ELSE'
            || '         :NEW.dirigente := dep_cognome;'
            || '         :NEW.dirigente_nome_cognome := dep_cognome;'
            || '      END IF;'
            || '   END;'
            || 'END IF;';
      END IF;

      RETURN depstmt;
   END get_trigger_leus;

   FUNCTION get_trigger_prin (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
   /******************************************************************************
      NAME:       get_trigger_prin
      PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/03/2010         1. AA36823.0.0

   ******************************************************************************/
   BEGIN
      IF p_nome_tabella = 'SPR_PROTOCOLLI_INTERO'
      THEN
         depstmt :=
               ' IF     :NEW.anno IS NOT NULL '
            || 'AND :NEW.numero IS NOT NULL '
            || 'AND :NEW.numero <> NVL (:OLD.numero, 0) THEN '
            || 'DECLARE '
            || 'id_memo   NUMBER; '
            || ' BEGIN '
            || '  SELECT id_documento_rif '
            || '    INTO id_memo '
            || '    FROM riferimenti '
            || '   WHERE id_documento = :NEW.id_documento AND tipo_relazione in (''FAX'', ''MAIL''); '
            || ' UPDATE seg_memo_protocollo '
            || '    SET stato_memo = ''PR'' '
            || '  WHERE id_documento = id_memo; '
            || ' EXCEPTION '
            || '      WHEN OTHERS THEN '
            || '      NULL; '
            || ' END; '
            || 'END IF;'
            || 'IF :NEW.numero IS NULL THEN '
            || 'DECLARE '
            || 'id_memo          NUMBER; '
            || 'con_segnatura    NUMBER       := 0; '
            || 'dep_stato_memo   VARCHAR2 (3) := ''DPS''; '
            || ' BEGIN '
            || '   SELECT id_documento_rif '
            || '     INTO id_memo '
            || '     FROM riferimenti '
            || '    WHERE id_documento = :NEW.id_documento AND tipo_relazione in (''FAX'', ''MAIL''); '
            || ' BEGIN '
            || '   SELECT ''DP'' '
            || '     INTO dep_stato_memo '
            || '     FROM oggetti_file '
            || '    WHERE id_documento = id_memo '
            || '      AND UPPER (filename) IN '
            || '          (''SEGNATURA.XML'', ''SEGNATURA_CITTADINO.XML''); '
            || ' EXCEPTION '
            || '      WHEN OTHERS THEN '
            || '      NULL; '
            || ' END; '
            || ' UPDATE seg_memo_protocollo '
            || '    SET stato_memo = dep_stato_memo '
            || '  WHERE id_documento = id_memo; '
            || ' EXCEPTION '
            || ' WHEN OTHERS THEN '
            || ' NULL; '
            || ' END; '
            || 'END IF; ';
      END IF;

      RETURN depstmt;
   END get_trigger_prin;

   FUNCTION check_tipo_documento_registro (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
   BEGIN
      IF p_nome_tabella IN ('SPR_PROTOCOLLI',
                            'SPR_PROTOCOLLI_INTERO',
                            'SPR_PROTOCOLLI_EMERGENZA',
                            'SPR_LETTERE_USCITA')
      THEN
         depstmt :=
               '   IF :NEW.tipo_documento IS NULL and :NEW.DESCRIZIONE_TIPO_DOCUMENTO IS NOT NULL THEN'
            || '      :NEW.DESCRIZIONE_TIPO_DOCUMENTO := null;'
            || '   END IF;'
            || '   IF :NEW.tipo_documento IS NOT NULL and :NEW.numero IS NOT NULL and :OLD.numero IS NULL AND :NEW.utenti_firma <> ''@@TRASCO@@'' THEN'
            || '      declare'
            || '         d_tipo_reg_doc varchar2(100);'
            || '      begin'
            || '         select tipo_registro_documento'
            || '           into d_tipo_reg_doc'
            || '           from seg_tipi_documento tido, '
            || '                documenti docu_tido'
            || '          where tipo_documento = :NEW.tipo_documento'
            || '            AND docu_tido.id_documento = tido.id_documento'
            || '            AND docu_tido.stato_documento NOT IN (''CA'', ''RE'', ''PB'')'
            || '            AND nvl(tido.codice_amministrazione, :NEW.codice_amministrazione) = :NEW.codice_amministrazione'
            || '            AND nvl(tido.codice_aoo, :NEW.codice_aoo) = :NEW.codice_aoo'
            || '            AND NVL(:NEW.data, TRUNC (SYSDATE))'
            || '                    BETWEEN NVL (tido.dataval_dal, TO_DATE (2222222, ''j''))'
            || '                        AND NVL (tido.dataval_al, TO_DATE (3333333, ''j''))'
            || '         ;'
            || '         if nvl(d_tipo_reg_doc, :NEW.tipo_registro) <> :NEW.tipo_registro then'
            || '            raise_application_error(-20999,''Tipo documento ''''''||:NEW.tipo_documento||'''''' non valido per registro ''''''||:NEW.tipo_registro||''''''.'');'
            || '         end if;'
            || '      exception'
            || '         when no_data_found then'
            || '            raise_application_error(-20999,''Tipo documento ''''''||:NEW.tipo_documento||'''''' non esistente o non valido.'');'
            || '         when others then'
            || '            raise;'
            || '      end;'
            || '      if :NEW.utenti_firma = ''@@TRASCO@@'' then'
            || '         :NEW.utenti_firma := null;'
            || '      end if;'
            || '   END IF;';
      END IF;

      RETURN depstmt;
   END;

   FUNCTION get_trigger_prot_interop_er (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
   /******************************************************************************
      NAME:       get_trigger_leus
      PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/03/2010         1. AA36823.0.0

   ******************************************************************************/
   BEGIN
      IF p_nome_tabella IN ('SPR_PROTOCOLLI',
                            'SPR_PROTOCOLLI_INTERO',
                            'SPR_PROTOCOLLI_EMERGENZA')
      THEN
         depstmt :=
               'BEGIN '
            || 'BEGIN '
            || 'IF :OLD.stato_pr != ''DP'' THEN '
            || 'a_messaggio := ''Fascicolo gia'''' presente ''; '
            || 'a_istruzione := ''Begin ag_utilities_protocollo.check_titolario(:NEW.id_documento, '''':OLD.class_cod'''', TO_DATE(TO_CHAR (:OLD.class_dal, ''''DD/MM/YYYY''''), ''''DD/MM/YYYY''''), :OLD.fascicolo_anno, '''':OLD.fascicolo_numero'''', '''':NEW.class_cod'''', TO_DATE(TO_CHAR (:NEW.class_dal, ''''DD/MM/YYYY''''), ''''DD/MM/YYYY''''), :NEW.fascicolo_anno, '''':NEW.fascicolo_numero'''', ''''si4.utente'''', 1,:OLD.anno, :OLD.numero, '''':OLD.tipo_registro'''', TO_DATE(TO_CHAR (:NEW.DATA, ''''DD/MM/YYYY HH24:MI:SS''''), ''''DD/MM/YYYY HH24:MI:SS'''')); end; ''; '
            || 'integritypackage.set_postevent (a_istruzione, a_messaggio); '
            || 'END IF; '
            || 'END; '
            || 'BEGIN '
            || 'IF integritypackage.getnestlevel = 0 '
            || 'THEN '
            || 'integritypackage.nextnestlevel; '
            || 'integritypackage.previousnestlevel; '
            || 'END IF; '
            || 'integritypackage.nextnestlevel; '
            || 'integritypackage.previousnestlevel; '
            || 'END; '
            || 'EXCEPTION '
            || 'WHEN integrity_error '
            || 'THEN '
            || 'integritypackage.initnestlevel; '
            || 'raise_application_error (errno, errmsg); '
            || 'WHEN OTHERS '
            || 'THEN '
            || 'integritypackage.initnestlevel; '
            || 'RAISE; '
            || 'END;';
      END IF;

      RETURN depstmt;
   END get_trigger_prot_interop_er;

   PROCEDURE crea_trigger_proto_tb_tc (p_nome_tabella VARCHAR2)
   IS
      depstmt   VARCHAR2 (32000) := '';
   /******************************************************************************
      NAME:       get_trigger_leus
      PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        11/03/2010         1. AA36823.0.0

   ******************************************************************************/
   BEGIN
      DBMS_OUTPUT.put_line ('1');
      DBMS_OUTPUT.put_line ('2');
      depstmt :=
            'CREATE OR REPLACE TRIGGER AG_'
         || p_nome_tabella
         || '_TB '
         || 'BEFORE INSERT OR UPDATE OR DELETE ON '
         || p_nome_tabella
         || ' '
         || 'BEGIN '
         || 'IF INTEGRITYPACKAGE.GETNESTLEVEL = 0 THEN '
         || 'INTEGRITYPACKAGE.INITNESTLEVEL; '
         || 'END IF; '
         || 'END;';
      DBMS_OUTPUT.put_line (depstmt);

      EXECUTE IMMEDIATE depstmt;

      DBMS_OUTPUT.put_line ('4');
      depstmt :=
            'CREATE OR REPLACE TRIGGER AG_'
         || p_nome_tabella
         || '_TC '
         || 'AFTER INSERT OR UPDATE OR DELETE ON '
         || p_nome_tabella
         || ' '
         || 'BEGIN '
         || 'INTEGRITYPACKAGE.EXEC_POSTEVENT; '
         || 'END;';
      DBMS_OUTPUT.put_line ('5');

      EXECUTE IMMEDIATE depstmt;

      DBMS_OUTPUT.put_line ('6');
   END crea_trigger_proto_tb_tc;

   FUNCTION get_acronimo_tabella (p_area VARCHAR2, p_codice_modello VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   tipi_documento.acronimo_modello%TYPE;
   BEGIN
      BEGIN
         SELECT UPPER (t.acronimo_modello)
           INTO retval
           FROM aree a, tipi_documento t
          WHERE     a.area = t.area_modello
                AND a.acronimo IS NOT NULL
                AND t.alias_modello IS NOT NULL
                AND t.area_modello = p_area
                AND t.nome = p_codice_modello;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := '';
      END;

      RETURN retval;
   END get_acronimo_tabella;

   PROCEDURE ag_crea_trigger_proto (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (32000);
      depacronimotabella   VARCHAR2 (30);
      depregistro          VARCHAR2 (100);
      deptriggername       VARCHAR2 (100);
   /******************************************************************************
      NAME:       AG_CREA_TRIGGER_PROTO
      PURPOSE: Crea i trigger per tutte le tabelle associate a modelli di categoria PROTO.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        01/12/2008          1. Created this procedure.
                 21/01/2009         SC  A30787.0.0  Modificata per
                                               eseguire anche l'update
                                               sulla data degli smsitamenti.
                 05/06/2009         SC         Setta id_documento_protocollo in
                                               inserting e updating, anziche solo update
                 23/02/2010         SC    A36371.3.0.
                 21/06/2018         SC    Se :new.modalita null, ci mette la :old.
    009          25/06/2018        SC     Modificata procedura ag_crea_trigger_proto per
                                    reimpostare :new.modalità = :old.modalita
                                    se la :new è null.
      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     AG_CREA_TRIGGER_PROTO
         Sysdate:         01/12/2008
         Date and Time:   01/12/2008, 14.16.37, and 01/12/2008 14.16.37
         Username:         (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   BEGIN
      IF p_categoria = 'PROTO'
      THEN
         FOR c_categorie IN (SELECT area, codice_modello
                               FROM categorie_modello
                              WHERE categoria = p_categoria)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  get_acronimo_tabella (c_categorie.area,
                                        c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

            IF depnometabella IS NOT NULL
            THEN
               BEGIN
                  IF    INSTR (c_categorie.area, 'SEGRETERIA.ATTI') > 0
                     OR INSTR (c_categorie.area, 'SEGRETERIA') = 0
                  THEN
                     depregistro := 'null';
                  ELSE
                     depregistro := ':NEW.tipo_registro';
                  END IF;

                  deptriggername :=
                     'ag_' || SUBSTR (depnometabella, 1, 23) || '_tiu ';
                  DBMS_OUTPUT.put_line ('1 ' || deptriggername);

                  -- creazione trigger per valorizzara id_documento_protocollo
                  BEGIN
                     depstmt := 'DROP TRIGGER ' || deptriggername;

                     EXECUTE IMMEDIATE depstmt;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;

                  depstmt :=
                        'CREATE TRIGGER '
                     || deptriggername
                     || ' BEFORE INSERT or UPDATE ON '
                     || depnometabella
                     || ' FOR EACH ROW '
                     || ' BEGIN '
                     || ' if :new.numero is not null and (:new.anno is null or :new.tipo_registro is null ';

                  DECLARE
                     d_exists_campo   NUMBER := 0;
                  BEGIN
                     EXECUTE IMMEDIATE
                           'select count(1) from user_tab_columns where table_name = '''
                        || depnometabella
                        || ''' and column_name = ''STATO_PR'''
                        INTO d_exists_campo;

                     IF d_exists_campo = 1
                     THEN
                        depstmt := depstmt || 'or :new.stato_pr = ''DP''';
                     END IF;
                  END;

                  depstmt :=
                        depstmt
                     || ') then'
                     || ' :new.numero := null;'
                     || ' end if;'
                     || ' IF :NEW.anno IS NOT NULL AND :NEW.numero IS NOT NULL AND :NEW.numero <>  nvl(:OLD.numero, 0) THEN'
                     || ' ag_utilities_protocollo.check_unicita('''
                     || depnometabella
                     || ''', :NEW.anno, '
                     || depregistro
                     || ', :NEW.numero, :NEW.id_documento);'
                     || ' ag_utilities_protocollo.ins_proto_key(:NEW.anno, '
                     || depregistro
                     || ', :NEW.numero);'
                     || ' END IF;';

                  DECLARE
                     d_exists_campo   NUMBER := 0;
                  BEGIN
                     EXECUTE IMMEDIATE
                           'select count(1) from user_tab_columns where table_name = '''
                        || depnometabella
                        || ''' and column_name = ''STATO_SCARTO'''
                        INTO d_exists_campo;

                     IF d_exists_campo = 1
                     THEN
                        depstmt :=
                              depstmt
                           || ' if nvl(:new.stato_scarto,''**'') <> nvl(:old.stato_scarto,''**'') then'
                           || ' :new.data_stato_scarto := sysdate;'
                           || ' end if;';
                     END IF;

                     depstmt :=
                           depstmt
                        || 'if :new.modalita is null and :old.modalita is not null then '
                        || '   :new.modalita := :old.modalita;'
                        || 'end if;';

                     EXECUTE IMMEDIATE
                           'select count(1) from user_tab_columns where table_name = '''
                        || depnometabella
                        || ''' and column_name = ''UNITA_ESIBENTE'''
                        INTO d_exists_campo;

                     IF d_exists_campo = 1
                     THEN
                        depstmt :=
                              depstmt
                           || ' IF :new.modalita = ''ARR''  and nvl(:new.modalita, ''x'') != nvl(:old.modalita, ''x'') THEN '
                           || ' :new.unita_esibente := null; '
                           || ' END IF; ';
                     END IF;

                     EXECUTE IMMEDIATE
                           'select count(1) from user_tab_columns where table_name = '''
                        || depnometabella
                        || ''' and column_name = ''DATA_ARRIVO'''
                        INTO d_exists_campo;

                     IF d_exists_campo = 1
                     THEN
                        depstmt :=
                              depstmt
                           || ' IF :new.modalita <> ''ARR''  and nvl(:new.modalita, ''x'') != nvl(:old.modalita, ''x'') THEN '
                           || ' :new.data_arrivo := null; ';

                        EXECUTE IMMEDIATE
                              'select count(1) from user_tab_columns where table_name = '''
                           || depnometabella
                           || ''' and column_name = ''RACCOMANDATA_NUMERO'''
                           INTO d_exists_campo;

                        IF d_exists_campo = 1
                        THEN
                           depstmt :=
                                 depstmt
                              || ' :new.raccomandata_numero := null; ';
                        END IF;

                        depstmt := depstmt || ' END IF; ';
                     END IF;
                  END;

                  IF     INSTR (c_categorie.area, 'SEGRETERIA.ATTI') = 0
                     AND INSTR (c_categorie.area, 'SEGRETERIA') > 0
                     AND c_categorie.codice_modello <>
                            'M_PROTOCOLLO_DOCESTERNI'
                  THEN
                     depstmt :=
                           depstmt
                        || ' IF (:NEW.id_documento_protocollo IS NULL) THEN '
                        || ' :NEW.id_documento_protocollo := :NEW.id_documento; '
                        || ' END IF; '
                        || ' IF (:NEW.numero IS NOT NULL AND :OLD.numero IS NULL) THEN '
                        || ' BEGIN '
                        || ' DECLARE '
                        || ' a_messaggio    VARCHAR2 (32000); '
                        || ' a_istruzione   VARCHAR2 (32000); '
                        || ' BEGIN '
                        || ' a_messaggio := '
                        || ' ''Errore in aggiornamento smistamenti associati a documento '' '
                        || ' || :NEW.id_documento '
                        || ' || ''.''; '
                        || ' a_istruzione := '
                        || ' ''begin upd_data_attivazione('''''' '
                        || ' || :NEW.idrif '
                        || ' || '''''', '''''' '
                        || ' || TO_CHAR (:NEW.data, ''dd/mm/yyyy hh24:mi:ss'') '
                        || ' || ''''''); end; ''; '
                        || ' integritypackage.set_postevent (a_istruzione, a_messaggio); '
                        || ' END; '
                        || ' EXCEPTION '
                        || ' WHEN OTHERS '
                        || ' THEN '
                        || ' raise_application_error (-20999, '
                        || ' ''Fallito aggiornamento:'' || SQLERRM); '
                        || ' END; '
                        || ' END IF; '
                        || '  IF NVL (:old.numero , 0) > 0 AND :OLD.DATA is not null '
                        || '  THEN '
                        || '     IF NVL (:NEW.DATA, TO_DATE (''01/01/1900'', ''dd/mm/yyyy'')) != '
                        || '        NVL (:OLD.DATA, TO_DATE (''01/01/1900'', ''dd/mm/yyyy'')) THEN '
                        || '            raise_application_error(-20999, ''Non e'''' consentito modificare la data di protocollo.'');'
                        || '     END IF;'
                        || '     IF NVL (:NEW.numero, 0) != NVL (:OLD.numero, 0) THEN '
                        || '            raise_application_error(-20999, ''Non e'''' consentito modificare il numero di protocollo.'');'
                        || '     END IF; '
                        || '     IF NVL (:NEW.anno, 0) != NVL (:OLD.anno, 0) THEN '
                        || '            raise_application_error(-20999, ''Non e'''' consentito modificare l''''anno di protocollo.'');'
                        || '     END IF; '
                        || '     IF NVL (:NEW.tipo_registro, '' '') != NVL (:OLD.tipo_registro, '' '') THEN '
                        || '            raise_application_error(-20999, ''Non e'''' consentito modificare il registro di protocollo.'');'
                        || '     END IF;'
                        || '     IF NVL (:NEW.unita_protocollante, '' '') != NVL (:OLD.unita_protocollante, '' '') THEN '
                        || '            raise_application_error(-20999, ''Non e'''' consentito modificare l''''unita'''' protocollante.'');'
                        || '     END IF;'
                        || '     IF NVL (:NEW.utente_protocollante, '' '') != NVL (:OLD.utente_protocollante, '' '') THEN '
                        || '            raise_application_error(-20999, ''Non e'''' consentito modificare l''''utente protocollante.'');'
                        || '     END IF;'
                        || '  END IF;'
                        || '  IF NVL (:OLD.modalita, ''x'') != NVL (:NEW.modalita, ''x'')'
                        || '  THEN '
                        || '  DECLARE '
                        || '  movimento_utilizzabile     NUMBER; '
                        || '  dep_utente_aggiornamento   ad4_utenti.utente%TYPE; '
                        || '  des_movimento              seg_movimenti.movimento%TYPE; '
                        || '  BEGIN '
                        || '     BEGIN '
                        || '        SELECT utente_aggiornamento '
                        || '          INTO dep_utente_aggiornamento '
                        || '          FROM documenti '
                        || '         WHERE id_documento = :NEW.id_documento; '
                        || '       BEGIN '
                        || '          SELECT 1 '
                        || '            INTO movimento_utilizzabile '
                        || '            FROM seg_movimenti '
                        || '           WHERE tipo_movimento = NVL (:NEW.modalita, ''x'') '
                        || '             AND gdm_competenza.gdm_verifica (''DOCUMENTI'', '
                        || '                                              seg_movimenti.id_documento, '
                        || '                                              ''L'', '
                        || '                                              dep_utente_aggiornamento, '
                        || '                                              ''GDM'' '
                        || '                                              ) = 1; '
                        || '       EXCEPTION '
                        || '       WHEN NO_DATA_FOUND '
                        || '       THEN '
                        || '          BEGIN '
                        || '             SELECT MIN (movimento) '
                        || '               INTO des_movimento '
                        || '               FROM seg_movimenti '
                        || '              WHERE tipo_movimento = NVL (:NEW.modalita, ''x''); '
                        || '          EXCEPTION '
                        || '          WHEN OTHERS '
                        || '          THEN '
                        || '             des_movimento := NVL (:NEW.modalita, ''x''); '
                        || '          END; '
                        || '          raise_application_error '
                        || '          (-20999, '
                        || '          ''L''''utente '' '
                        || '          || dep_utente_aggiornamento '
                        || '          || '' non e'''' abilitato ad utilizzare il  movimento '' '
                        || '          || des_movimento '
                        || '          ); '
                        || '       END; '
                        || '     EXCEPTION '
                        || '     WHEN NO_DATA_FOUND '
                        || '     THEN '
                        || '     NULL; '
                        || '     END; '
                        || '  END; '
                        || '  END IF;'
                        || '  IF (:NEW.stato_pr = ''DP'' and :NEW.tipo_registro is not null)'
                        || '   THEN'
                        || '     :NEW.tipo_registro_temp := :NEW.tipo_registro;'
                        || '    :NEW.tipo_registro := NULL;'
                        || '   END IF;'
                        || '   IF (:NEW.stato_pr != ''DP'' AND nvl(:NEW.tipo_stato, ''--'') != nvl(:OLD.tipo_stato, ''--''))'
                        || '   THEN'
                        || '     :NEW.data_stato := trunc(sysdate);'
                        || '    END IF;'
                        || '  IF (    :NEW.stato_pr != ''DP'''
                        || '   AND NVL (:NEW.tipo_stato, ''--'') != ''--'''
                        || '   AND :NEW.data_stato IS NULL '
                        || '   )'
                        || '   THEN'
                        || '     :NEW.data_stato := NVL (:OLD.data_stato, TRUNC (SYSDATE));'
                        || '  END IF;'
                        || '  IF (    :NEW.stato_pr != ''DP'''
                        || '   AND NVL (:NEW.tipo_stato, ''--'') = ''--'''
                        || '   AND :NEW.data_stato IS not NULL'
                        || '   )'
                        || '   THEN'
                        || '     :NEW.data_stato := null;'
                        || '   END IF; '
                        || 'IF     :OLD.CLASS_COD IS NOT NULL '
                        || 'AND :OLD.CLASS_DAL IS NOT NULL '
                        || 'AND (   NVL (:NEW.CLASS_COD, '' '') <> :OLD.CLASS_COD '
                        || '   OR NVL (:NEW.CLASS_DAL, TO_DATE (3333333, ''j'')) <> :OLD.CLASS_DAL '
                        || '   OR NVL (:NEW.FASCICOLO_ANNO, 0) <> NVL (:OLD.FASCICOLO_ANNO, 0) '
                        || '   OR NVL (:NEW.FASCICOLO_NUMERO, '' '') <> '
                        || '       NVL (:OLD.FASCICOLO_NUMERO, '' '')) '
                        || 'THEN '
                        || '   BEGIN '
                        || '      DECLARE '
                        || '         a_messaggio    VARCHAR2 (32000); '
                        || '         a_istruzione   VARCHAR2 (32000); '
                        || '      BEGIN '
                        || '         a_messaggio := '
                        || '               ''Errore in aggiornamento link del documento '' '
                        || '            || :OLD.id_documento '
                        || '            || ''.''; '
                        || '         a_istruzione := '
                        || '               ''begin delete_from_titolario('' '
                        || '            || :OLD.id_documento '
                        || '            || '', '''''' '
                        || '            || :OLD.class_cod '
                        || '            || '''''', '''''' '
                        || '            || TO_CHAR (:OLD.class_dal, ''dd/mm/yyyy'') '
                        || '            || '''''', '' '
                        || '            || nvl(:OLD.fascicolo_anno, ''0'') '
                        || '            || '', '''''' '
                        || '            || :OLD.fascicolo_numero '
                        || '            || '''''', '''''' '
                        || '            || :OLD.codice_amministrazione '
                        || '            || '''''', '''''' '
                        || '            || :OLD.codice_aoo '
                        || '            || ''''''); end; ''; '
                        || '         integritypackage.set_postevent (a_istruzione, a_messaggio); '
                        || '      END; '
                        || '   EXCEPTION '
                        || '      WHEN OTHERS '
                        || '      THEN '
                        || '         raise_application_error (-20999, '
                        || '                                  ''Fallito aggiornamento:'' || SQLERRM); '
                        || '   END; '
                        || 'END IF; '
                        || check_tipo_documento_registro (depnometabella)
                        || get_trigger_leus (depnometabella)
                        || get_trigger_prin (depnometabella) --  || get_trigger_prot_interop_er (depnometabella)
                                                            ;
                  END IF;

                  depstmt :=
                        depstmt
                     || ' EXCEPTION '
                     || ' WHEN OTHERS '
                     || ' THEN '
                     || ' RAISE; '
                     || ' END; ';

                  EXECUTE IMMEDIATE depstmt;

                  crea_trigger_proto_tb_tc (depnometabella);

                  --GM 24/06/2011 Aggiunto trigger per allineare oggetto del protocollo con tutti i task esterni
                  --              legati agli smistamenti
                  IF     INSTR (c_categorie.area, 'SEGRETERIA.ATTI') = 0
                     AND INSTR (c_categorie.area, 'SEGRETERIA') > 0
                     AND c_categorie.codice_modello <>
                            'M_PROTOCOLLO_DOCESTERNI'
                  THEN
                     deptriggername :=
                        'ag_' || SUBSTR (depnometabella, 1, 23) || '_au ';

                     -- creazione trigger per valorizzara id_documento_protocollo
                     BEGIN
                        depstmt := 'DROP TRIGGER ' || deptriggername;

                        EXECUTE IMMEDIATE depstmt;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     depstmt :=
                           'CREATE TRIGGER '
                        || deptriggername
                        || ' AFTER UPDATE ON '
                        || depnometabella
                        || ' REFERENCING NEW AS New OLD AS Old '
                        || ' FOR EACH ROW '
                        || ' BEGIN '
                        || '   IF NVL (:OLD.stato_pr, ''DP'') != NVL (:NEW.stato_pr, ''DP'') AND NVL (:NEW.stato_pr, ''DP'') = ''PR'' THEN '
                        || '      AG_MEMO_UTILITY.SET_STATO_FROM_PROT(:NEW.id_documento, ''PR''); '
                        || '      DECLARE '
                        || '      a_messaggio    VARCHAR2 (32000); '
                        || '      a_istruzione   VARCHAR2 (32000); '
                        || '      BEGIN '
                        || '      a_messaggio := '
                        || '      ''Fallita notifica di inserimento in fascicolo del protocollo identificato da '''
                        || '      || :NEW.id_documento; '
                        || '      a_istruzione := '
                        || '      ''begin ag_documento_utility.notifica_ins_fasc ('''
                        || '      || :NEW.id_documento '
                        || '      || ''); end ;'';'
                        || '      integritypackage.set_postevent (a_istruzione, a_messaggio);'
                        || '      END; '
                        || '   END IF; '
                        || '   IF nvl(:NEW.OGGETTO,'''') <> nvl(:OLD.OGGETTO,'''') THEN '
                        || '      AG_UTILITIES_CRUSCOTTO.UPD_OGG_TASK_EST_COMMIT (:NEW.IDRIF,nvl(:NEW.OGGETTO,''''),nvl(:OLD.OGGETTO,''''),:NEW.ANNO,:NEW.NUMERO);'
                        || '   END IF;'
                        || '   EXCEPTION WHEN OTHERS THEN'
                        || '      RAISE_APPLICATION_ERROR(-20999,''Errore in aggiornamento oggetto dei task esterni. Errore: ''||sqlerrm);'
                        || ' END;';

                     EXECUTE IMMEDIATE depstmt;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END LOOP;
      END IF;
   END ag_crea_trigger_proto;


   PROCEDURE crea_nonunique_index_proto (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (4000);
      depacronimotabella   VARCHAR2 (30);
      d_esiste             NUMBER;
      d_index_name         VARCHAR2 (30);
   /******************************************************************************
      NAME:       CREA_NONUNIQUE_INDEX_PROTO
      PURPOSE: Crea gli indici non univoci per tutte le tabelle
               associate a modelli di categoria PROTO.

      REVISIONS:
      Ver      Date        Author             Description
      ------   ----------  ---------------   ------------------------------------
      011      23/05/2019  MMalferrari       Creazione.
   ******************************************************************************/
   BEGIN

      IF p_categoria = 'PROTO'
      THEN
         FOR c_categorie
            IN (SELECT camo.area, camo.codice_modello, aree.acronimo
                  FROM categorie_modello camo, aree
                 WHERE camo.categoria = p_categoria AND aree.area = camo.area)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  get_acronimo_tabella (c_categorie.area,
                                        c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);
            DBMS_OUTPUT.PUT_LINE (depnometabella);

            IF depnometabella IS NOT NULL
            THEN
               /*
                     crea INDICE su DATA
               */
               DECLARE
                  d_esiste           NUMBER;
                  d_old_index_name   VARCHAR2 (100);
               BEGIN
                  d_index_name :=
                        c_categorie.acronimo
                     || '_'
                     || depacronimotabella
                     || '_DATA_IK';

                  SELECT DISTINCT 1
                    INTO d_esiste
                    FROM user_ind_columns uic
                   WHERE column_name = 'DATA' AND table_name = depnometabella;

                  DBMS_OUTPUT.PUT_LINE (
                     'esiste indice su data? ' || d_esiste);

                  BEGIN
                     SELECT uic.index_name
                       INTO d_old_index_name
                       FROM user_ind_columns uic, user_indexes i
                      WHERE     i.index_name = uic.index_name
                            AND column_name = 'DATA'
                            AND uic.table_name = depnometabella
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM user_ind_columns
                                     WHERE     column_name <> 'DATA'
                                           AND table_name = uic.table_name
                                           AND index_name = uic.index_name);

                     DBMS_OUTPUT.PUT_LINE ('d_index_name: ' || d_index_name);


                     IF d_index_name <> d_old_index_name
                     THEN
                        depstmt :=
                              'alter index '
                           || d_old_index_name
                           || ' rename to  '
                           || d_index_name;

                        DBMS_OUTPUT.PUT_LINE (depstmt);

                        EXECUTE IMMEDIATE depstmt;
                     END IF;
                  END;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     depstmt :=
                           'create index '
                        || d_index_name
                        || ' on '
                        || depnometabella
                        || ' (DATA)';

                     DBMS_OUTPUT.PUT_LINE (depstmt);

                     EXECUTE IMMEDIATE depstmt;
               END;

               /*
                     crea INDICE su NOTE
               */
               DECLARE
                  d_esiste           NUMBER;
                  d_old_index_name   VARCHAR2 (100);
                  d_crea             BOOLEAN := FALSE;
               BEGIN
                  d_index_name :=
                        c_categorie.acronimo
                     || '_'
                     || depacronimotabella
                     || '_NOTE_CTX';

                  BEGIN
                     SELECT DISTINCT 1
                       INTO d_esiste
                       FROM user_ind_columns uic
                      WHERE     column_name = 'NOTE'
                            AND table_name = depnometabella;

                     DBMS_OUTPUT.PUT_LINE (
                        'esiste indice su NOTE? ' || d_esiste);

                     BEGIN
                        SELECT uic.index_name
                          INTO d_old_index_name
                          FROM user_ind_columns uic, user_indexes i
                         WHERE     i.index_name = uic.index_name
                               AND column_name = 'NOTE'
                               AND uic.table_name = depnometabella
                               AND NOT EXISTS
                                      (SELECT 1
                                         FROM user_ind_columns
                                        WHERE     column_name <> 'NOTE'
                                              AND table_name = uic.table_name
                                              AND index_name = uic.index_name);

                        DBMS_OUTPUT.PUT_LINE (
                           'd_index_name: ' || d_index_name);


                        IF d_index_name <> d_old_index_name
                        THEN
                           d_crea := TRUE;
                           depstmt := 'drop index ' || d_old_index_name;

                           DBMS_OUTPUT.PUT_LINE (depstmt);

                           EXECUTE IMMEDIATE depstmt;
                        END IF;
                     END;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        d_crea := TRUE;
                  END;

                  IF d_crea
                  THEN
                     depstmt :=
                           'create index '
                        || d_index_name
                        || ' on '
                        || depnometabella
                        || ' (NOTE) INDEXTYPE IS CTXSYS.CTXCAT PARAMETERS(''lexer italian_lexer wordlist italian_wordlist stoplist italian_stoplist memory 10M'')';

                     DBMS_OUTPUT.PUT_LINE (depstmt);

                     EXECUTE IMMEDIATE depstmt;
                  END IF;
               END;

               /*
                     crea INDICE su OGGETTO
               */
               DECLARE
                  d_esiste           NUMBER;
                  d_old_index_name   VARCHAR2 (100);
                  d_crea             BOOLEAN := FALSE;
               BEGIN
                  d_index_name :=
                        c_categorie.acronimo
                     || '_'
                     || depacronimotabella
                     || '_OGGE_CTX';

                  BEGIN
                     SELECT DISTINCT 1
                       INTO d_esiste
                       FROM user_ind_columns uic
                      WHERE     column_name = 'OGGETTO'
                            AND table_name = depnometabella;

                     DBMS_OUTPUT.PUT_LINE (
                        'esiste indice su OGGETTO? ' || d_esiste);

                     BEGIN
                        SELECT uic.index_name
                          INTO d_old_index_name
                          FROM user_ind_columns uic, user_indexes i
                         WHERE     i.index_name = uic.index_name
                               AND column_name = 'OGGETTO'
                               AND uic.table_name = depnometabella
                               AND NOT EXISTS
                                      (SELECT 1
                                         FROM user_ind_columns
                                        WHERE     column_name <> 'OGGETTO'
                                              AND table_name = uic.table_name
                                              AND index_name = uic.index_name);

                        DBMS_OUTPUT.PUT_LINE (
                           'd_index_name: ' || d_index_name);


                        IF d_index_name <> d_old_index_name
                        THEN
                           d_crea := TRUE;
                           depstmt := 'drop index ' || d_old_index_name;

                           DBMS_OUTPUT.PUT_LINE (depstmt);

                           EXECUTE IMMEDIATE depstmt;
                        END IF;
                     END;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        d_crea := TRUE;
                  END;

                  IF d_crea
                  THEN
                     depstmt :=
                           'create index '
                        || d_index_name
                        || ' on '
                        || depnometabella
                        || ' (OGGETTO) INDEXTYPE IS CTXSYS.CTXCAT PARAMETERS(''lexer italian_lexer wordlist italian_wordlist stoplist italian_stoplist memory 10M'')';

                     DBMS_OUTPUT.PUT_LINE (depstmt);

                     EXECUTE IMMEDIATE depstmt;
                  END IF;
               END;
            END IF;
         END LOOP;
      END IF;
   END;

   PROCEDURE crea_unique_key_proto (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (4000);
      depacronimotabella   VARCHAR2 (30);
      d_esiste             NUMBER;
      d_index_name         VARCHAR2 (30);
   /******************************************************************************
      NAME:       CREA_UNIQUE_KEY_PROTO
      PURPOSE: Crea le chiavi di unique key per tutte le tabelle
               associate a modelli di categoria PROTO.

      REVISIONS:
      Ver      Date        Author             Description
      ------   ----------  ---------------   ------------------------------------
      004      08/04/2012  MMalferrari       Gestione acronimo d'area nei nomi
                                             degli indici per evitare desse errore
                                             dove ci sono sia le tabelle di AGSDE
                                             (SAT_) che quelle di SFERA (GAT_).
   ******************************************************************************/
   BEGIN
      IF p_categoria = 'PROTO'
      THEN
         FOR c_categorie
            IN (SELECT camo.area, camo.codice_modello, aree.acronimo
                  FROM categorie_modello camo, aree
                 WHERE camo.categoria = p_categoria AND aree.area = camo.area)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  get_acronimo_tabella (c_categorie.area,
                                        c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);
            DBMS_OUTPUT.PUT_LINE (depnometabella);

            IF depnometabella IS NOT NULL
            THEN
               SELECT COUNT (1)
                 INTO d_esiste
                 FROM user_constraints
                WHERE constraint_name = 'AG_' || depacronimotabella || '_UK';

               --DBMS_OUTPUT.PUT_LINE('esiste '||'AG_' || depacronimotabella || '_UK? '||d_esiste);
               IF d_esiste > 0
               THEN
                  depstmt :=
                        'ALTER TABLE '
                     || depnometabella
                     || ' rename CONSTRAINT AG_'
                     || depacronimotabella
                     || '_UK to '
                     || c_categorie.acronimo
                     || '_'
                     || depacronimotabella
                     || '_UK';

                  --DBMS_OUTPUT.PUT_LINE(depstmt);
                  EXECUTE IMMEDIATE depstmt;
               ELSE
                  SELECT COUNT (1)
                    INTO d_esiste
                    FROM user_constraints
                   WHERE constraint_name =
                               c_categorie.acronimo
                            || '_'
                            || depacronimotabella
                            || '_UK';

                  --DBMS_OUTPUT.PUT_LINE('esiste '||c_categorie.acronimo|| '_' || depacronimotabella || '_UK? '||d_esiste);
                  IF d_esiste = 0
                  THEN
                     depstmt :=
                           'ALTER TABLE '
                        || depnometabella
                        || ' ADD CONSTRAINT '
                        || c_categorie.acronimo
                        || '_'
                        || depacronimotabella
                        || '_UK';

                     IF depacronimotabella NOT IN ('DELI', 'DETE')
                     THEN
                        depstmt :=
                           depstmt || ' UNIQUE (ANNO, TIPO_REGISTRO, NUMERO)';
                     ELSE
                        depstmt := depstmt || ' UNIQUE (ANNO, NUMERO)';
                     END IF;

                     --DBMS_OUTPUT.PUT_LINE(depstmt);
                     EXECUTE IMMEDIATE depstmt;
                  END IF;
               END IF;

               /*
                     crea INDICE UNICO su IDRIF
               */
               DECLARE
                  d_esiste           NUMBER;
                  d_old_index_name   VARCHAR2 (100);
                  d_old_uniqueness   VARCHAR2 (100);
               BEGIN
                  d_index_name :=
                        c_categorie.acronimo
                     || '_'
                     || depacronimotabella
                     || '_IDRIF_UK';

                  SELECT DISTINCT 1
                    INTO d_esiste
                    FROM user_ind_columns uic
                   WHERE     column_name = 'IDRIF'
                         AND table_name = depnometabella;

                  --DBMS_OUTPUT.PUT_LINE('esiste indice su idrif? '||d_esiste);
                  BEGIN
                     SELECT uic.index_name, i.uniqueness
                       INTO d_old_index_name, d_old_uniqueness
                       FROM user_ind_columns uic, user_indexes i
                      WHERE     i.index_name = uic.index_name
                            AND column_name = 'IDRIF'
                            AND uic.table_name = depnometabella
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM user_ind_columns
                                     WHERE     column_name <> 'IDRIF'
                                           AND table_name = uic.table_name
                                           AND index_name = uic.index_name);

                     DBMS_OUTPUT.PUT_LINE ('d_index_name: ' || d_index_name);

                     IF d_old_uniqueness <> 'UNIQUE'
                     THEN
                        depstmt := 'drop index ' || d_old_index_name;

                        EXECUTE IMMEDIATE depstmt;

                        depstmt :=
                              'create unique index '
                           || d_index_name
                           || ' on '
                           || depnometabella
                           || ' (IDRIF)';

                        DBMS_OUTPUT.PUT_LINE (depstmt);

                        EXECUTE IMMEDIATE depstmt;
                     ELSE
                        IF d_index_name <> d_old_index_name
                        THEN
                           depstmt :=
                                 'alter index '
                              || d_old_index_name
                              || ' rename to  '
                              || d_index_name;

                           DBMS_OUTPUT.PUT_LINE (depstmt);

                           EXECUTE IMMEDIATE depstmt;
                        END IF;
                     END IF;
                  END;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     depstmt :=
                           'create unique index '
                        || d_index_name
                        || ' on '
                        || depnometabella
                        || ' (IDRIF)';

                     DBMS_OUTPUT.PUT_LINE (depstmt);

                     EXECUTE IMMEDIATE depstmt;
               END;
            END IF;
         END LOOP;
      END IF;
      crea_nonunique_index_proto (p_categoria);
   END crea_unique_key_proto;

   PROCEDURE crea_index_proto (p_categoria VARCHAR2 DEFAULT 'PROTO')
   IS
   BEGIN
      crea_unique_key_proto (p_categoria);
      crea_nonunique_index_proto (p_categoria);
   END;

   PROCEDURE add_col_tipo_registro_temp (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (4000);
      depacronimotabella   VARCHAR2 (30);
   /******************************************************************************
      NAME:       ADD_COL_TIPO_REGISTRO_TEMP
      PURPOSE: Aggiunge la colonna TIPO_REGISTRO_TEMP in tutti i modelli di categoria p_categoria.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        26/04/2010          SC        A36463.0.0

      NOTES:

   ******************************************************************************/
   BEGIN
      IF p_categoria = ag_utilities.categoriaprotocollo
      THEN
         FOR c_categorie IN (SELECT area, codice_modello
                               FROM categorie_modello
                              WHERE categoria = p_categoria)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  ag_utilities.get_acronimo_tabella (
                     c_categorie.area,
                     c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

            IF depnometabella IS NOT NULL
            THEN
               DECLARE
                  dep_esiste_colonna   NUMBER := 0;
               BEGIN
                  SELECT 1
                    INTO dep_esiste_colonna
                    FROM user_tab_columns
                   WHERE     UPPER (table_name) = UPPER (depnometabella)
                         AND UPPER (column_name) = 'TIPO_REGISTRO_TEMP';
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- creazione COLONNA
                     depstmt :=
                           'ALTER TABLE '
                        || depnometabella
                        || ' ADD (tipo_registro_temp  VARCHAR2(8))';

                     EXECUTE IMMEDIATE depstmt;
               END;
            END IF;
         END LOOP;
      END IF;
   END add_col_tipo_registro_temp;

   PROCEDURE add_col_utente_firma (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (4000);
      depacronimotabella   VARCHAR2 (30);
   /******************************************************************************
      NAME:       ADD_COL_UTENTE_FIRMA
      PURPOSE: Aggiunge la colonna UTENTE_FIRMA in tutti i modelli di categoria p_categoria.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/10/2011          MMUR

      NOTES:

   ******************************************************************************/
   BEGIN
      IF p_categoria = ag_utilities.categoriaprotocollo
      THEN
         FOR c_categorie IN (SELECT area, codice_modello
                               FROM categorie_modello
                              WHERE categoria = p_categoria)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  ag_utilities.get_acronimo_tabella (
                     c_categorie.area,
                     c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

            IF depnometabella IS NOT NULL
            THEN
               DECLARE
                  dep_esiste_colonna   NUMBER := 0;
               BEGIN
                  SELECT 1
                    INTO dep_esiste_colonna
                    FROM user_tab_columns
                   WHERE     UPPER (table_name) = UPPER (depnometabella)
                         AND UPPER (column_name) = 'UTENTE_FIRMA';
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- creazione COLONNA
                     depstmt :=
                           'ALTER TABLE '
                        || depnometabella
                        || ' ADD (UTENTE_FIRMA  VARCHAR2(8))';

                     EXECUTE IMMEDIATE depstmt;
               END;
            END IF;
         END LOOP;
      END IF;
   END add_col_utente_firma;

   PROCEDURE crea_smistamenti_fascicoli
   IS
      dep_idrif            NUMBER;
      dep_id_smistamento   NUMBER;
   BEGIN
      FOR f
         IN (SELECT fasc.id_documento,
                    fasc.idrif,
                    fasc.codice_amministrazione,
                    fasc.codice_aoo,
                    unit.unita,
                    unit.nome
               FROM seg_fascicoli fasc,
                    cartelle cart,
                    documenti docu,
                    seg_unita unit
              WHERE     fasc.id_documento = cart.id_documento_profilo
                    AND cart.id_documento_profilo = docu.id_documento
                    AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                    AND NVL (cart.stato, 'BO') = 'BO'
                    AND stato_fascicolo = 1
                    AND unit.unita = fasc.ufficio_competenza
                    AND unit.codice_amministrazione =
                           fasc.codice_amministrazione
                    AND unit.al IS NULL
                    AND NOT EXISTS
                           (SELECT 1
                              FROM seg_smistamenti smis, documenti dosm
                             WHERE     smis.id_documento = dosm.id_documento
                                   AND dosm.stato_documento NOT IN ('CA',
                                                                    'RE',
                                                                    'PB')
                                   AND smis.idrif = NVL (fasc.idrif, '0')))
      LOOP
         DBMS_OUTPUT.put_line ('f.id_documento ' || f.id_documento);

         IF f.idrif IS NULL
         THEN
            SELECT seq_idrif.NEXTVAL INTO dep_idrif FROM DUAL;

            UPDATE seg_fascicoli
               SET idrif = dep_idrif
             WHERE id_documento = f.id_documento;
         ELSE
            dep_idrif := f.idrif;
         END IF;

         dep_id_smistamento :=
            gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                        p_modello                   => 'M_SMISTAMENTO',
                                        p_cr                        => TO_CHAR (NULL),
                                        p_utente                    => 'RPI',
                                        p_crea_record_orizzontale   => 1);

         UPDATE seg_smistamenti
            SET idrif = dep_idrif,
                ufficio_smistamento = f.unita,
                ufficio_trasmissione = f.unita,
                des_ufficio_smistamento = f.nome,
                des_ufficio_trasmissione = f.nome,
                smistamento_dal = SYSDATE,
                presa_in_carico_dal = SYSDATE,
                presa_in_carico_utente = 'RPI',
                utente_trasmissione = 'RPI',
                tipo_smistamento = 'COMPETENZA',
                codice_amministrazione = f.codice_amministrazione,
                codice_aoo = f.codice_aoo,
                note =
                   'Smistamento creato automaticamente per attivazione iter dei fascicoli',
                stato_smistamento = 'E'
          WHERE id_documento = dep_id_smistamento;

         COMMIT;
      END LOOP;
   END;

   PROCEDURE add_col_data_verifica (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (4000);
      depacronimotabella   VARCHAR2 (30);
   /******************************************************************************
      NAME:       ADD_COL_DATA_VERIFICA
      PURPOSE: Aggiunge la colonna DATA_VERIFICA in tutti i modelli di categoria p_categoria.

      REVISIONS:
      Ver        Date              Author           Description
      ---------  ----------       ---------------  ------------------------------------
      1.0        01/03/2012    MMUR

      NOTES:

   ******************************************************************************/
   BEGIN
      IF p_categoria = ag_utilities.categoriaprotocollo
      THEN
         FOR c_categorie IN (SELECT area, codice_modello
                               FROM categorie_modello
                              WHERE categoria = p_categoria)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  ag_utilities.get_acronimo_tabella (
                     c_categorie.area,
                     c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

            IF depnometabella IS NOT NULL
            THEN
               DECLARE
                  dep_esiste_colonna   NUMBER := 0;
               BEGIN
                  SELECT 1
                    INTO dep_esiste_colonna
                    FROM user_tab_columns
                   WHERE     UPPER (table_name) = UPPER (depnometabella)
                         AND UPPER (column_name) = 'DATA_VERIFICA';
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- creazione COLONNA
                     depstmt :=
                           'ALTER TABLE '
                        || depnometabella
                        || ' ADD (DATA_VERIFICA DATE)';

                     EXECUTE IMMEDIATE depstmt;
               END;
            END IF;
         END LOOP;
      END IF;
   END add_col_data_verifica;

   PROCEDURE add_col_lettera_uscita
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_lettere_uscita ADD (soggetti_denominazione_temp  CLOB)';

      EXECUTE IMMEDIATE stmt;

      stmt :=
         'COMMENT ON COLUMN spr_lettere_uscita.soggetti_denominazione_temp IS ''Colonna in appoggio per modificare il tipo della colonna SOGGETTI_DENOMINAZIONE da VARCAHR2 a CLOB '' ';

      EXECUTE IMMEDIATE stmt;
   END add_col_lettera_uscita;

   PROCEDURE mod_tipo_col_lettera_uscita
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_lettere_uscita DROP COLUMN SOGGETTI_DENOMINAZIONE';

      EXECUTE IMMEDIATE stmt;

      stmt :=
         'ALTER TABLE spr_lettere_uscita ADD(soggetti_denominazione CLOB)';

      EXECUTE IMMEDIATE stmt;
   END mod_tipo_col_lettera_uscita;

   PROCEDURE del_col_lettera_uscita
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_lettere_uscita DROP COLUMN SOGGETTI_DENOMINAZIONE_TEMP';

      EXECUTE IMMEDIATE stmt;
   END del_col_lettera_uscita;

   PROCEDURE add_col_m_provvedimento1
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_provvedimenti ADD (elenco_annullandi_temp  CLOB)';

      EXECUTE IMMEDIATE stmt;

      stmt :=
         'COMMENT ON COLUMN spr_provvedimenti.elenco_annullandi_temp IS ''Colonna in appoggio per modificare il tipo della colonna elenco_annullandi da VARCAHR2 a CLOB '' ';

      EXECUTE IMMEDIATE stmt;
   END add_col_m_provvedimento1;

   PROCEDURE mod_tipo_col_m_provvedimento1
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt := 'ALTER TABLE spr_provvedimenti DROP COLUMN ELENCO_ANNULLANDI';

      EXECUTE IMMEDIATE stmt;

      stmt := 'ALTER TABLE spr_provvedimenti ADD(ELENCO_ANNULLANDI CLOB)';

      EXECUTE IMMEDIATE stmt;
   END mod_tipo_col_m_provvedimento1;

   PROCEDURE del_col_m_provvedimento1
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_provvedimenti DROP COLUMN ELENCO_ANNULLANDI_TEMP';

      EXECUTE IMMEDIATE stmt;
   END del_col_m_provvedimento1;

   PROCEDURE add_col_m_provvedimento2
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_provvedimenti ADD (elenco_annullati_temp  CLOB)';

      EXECUTE IMMEDIATE stmt;

      stmt :=
         'COMMENT ON COLUMN spr_provvedimenti.elenco_annullati_temp IS ''Colonna in appoggio per modificare il tipo della colonna elenco_annullati da VARCAHR2 a CLOB '' ';

      EXECUTE IMMEDIATE stmt;
   END add_col_m_provvedimento2;

   PROCEDURE mod_tipo_col_m_provvedimento2
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt := 'ALTER TABLE spr_provvedimenti DROP COLUMN ELENCO_annullati';

      EXECUTE IMMEDIATE stmt;

      stmt := 'ALTER TABLE spr_provvedimenti ADD(ELENCO_annullati CLOB)';

      EXECUTE IMMEDIATE stmt;
   END mod_tipo_col_m_provvedimento2;

   PROCEDURE del_col_m_provvedimento2
   IS
      stmt   VARCHAR2 (3000);
   BEGIN
      stmt :=
         'ALTER TABLE spr_provvedimenti DROP COLUMN ELENCO_annullati_TEMP';

      EXECUTE IMMEDIATE stmt;
   END del_col_m_provvedimento2;

   PROCEDURE add_col_verifica_firma (p_categoria VARCHAR2)
   IS
      depnometabella       VARCHAR2 (30);
      depstmt              VARCHAR2 (4000);
      depacronimotabella   VARCHAR2 (30);
   /******************************************************************************
      NAME:       ADD_COL_TIPO_REGISTRO_TEMP
      PURPOSE: Aggiunge la colonna TIPO_REGISTRO_TEMP in tutti i modelli di categoria p_categoria.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        26/04/2010          SC        A36463.0.0

      NOTES:

   ******************************************************************************/
   BEGIN
      IF p_categoria = ag_utilities.categoriaprotocollo
      THEN
         FOR c_categorie IN (SELECT area, codice_modello
                               FROM categorie_modello
                              WHERE categoria = p_categoria)
         LOOP
            depacronimotabella :=
               SUBSTR (
                  ag_utilities.get_acronimo_tabella (
                     c_categorie.area,
                     c_categorie.codice_modello),
                  2);
            depnometabella :=
               f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

            IF depnometabella IS NOT NULL
            THEN
               DECLARE
                  dep_esiste_colonna   NUMBER := 0;
               BEGIN
                  SELECT 1
                    INTO dep_esiste_colonna
                    FROM user_tab_columns
                   WHERE     UPPER (table_name) = UPPER (depnometabella)
                         AND UPPER (column_name) = 'VERIFICA_FIRMA';
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- creazione COLONNA
                     depstmt :=
                           'ALTER TABLE '
                        || depnometabella
                        || ' ADD (verifica_firma  VARCHAR2(1))';

                     EXECUTE IMMEDIATE depstmt;
               END;
            END IF;
         END LOOP;
      END IF;
   END add_col_verifica_firma;

   FUNCTION genera_ordinamento_titolario (
      p_oggetto       IN links.id_oggetto%TYPE,
      p_modello       IN VARCHAR2,
      p_ordinamento   IN VARCHAR2 DEFAULT 'ANNO_DESC_DATA_ASC')
      /******************************************************************************
       NOME:        GENERA_ORDINAMENTO_TITOLARIO
       DESCRIZIONE: Restituisce l'ordinamento del documento nel fascicolo a seconda
                    della scelta del singolo ente tra le seguenti possibilita':
                    1. ANNO_DESC_DATA_ASC - attuale
                        year(data_riferimento) DESC ||trunc(data_riferimento) ASC
                        ||progressivo ASC|| tipo_registro ASC |NUMERO ASC
                    2. ANNO_DATA_ASC
                        year(data_riferimento) ASC||trunc(data_riferimento) ASC
                        ||progressivo ASC|| tipo_registro ASC |NUMERO ASC
                    3. ANNO_DATA_DESC
                        year(data_riferimento) DESC ||trunc(data_riferimento) DESC
                        ||progressivo ASC|| tipo_registro ASC |NUMERO DESC
       PARAMETRI:   p_oggetto       id del documento di cui calcolare l'ordinamento.
                    p_modello       nome modello di appartenenaza del documento
                    p_ordinamento   ordinamento da applicare.
                                    Possibili:  ANNO_DESC_DATA_ASC
                                                ANNO_DATA_ASC
                                                ANNO_DATA_DESC
                                    Default:    ANNO_DESC_DATA_ASC
       RITORNA:     stringa varchar2 contenente l'ordinamento per il doc passato.
       ECCEZIONI:   --
       REVISIONI:
       Rev. Data        Autore         Descrizione
       ---- ----------  ------         ---------------------------------------------
       005  23/04/2014  MM             Prima emissione.
      ******************************************************************************/
      RETURN VARCHAR2
   IS
      d_ordinamento   links.ordinamento%TYPE;
   BEGIN
      IF p_modello = 'M_PROTOCOLLO'
      THEN
         SELECT    9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                || TO_CHAR (
                      TRUNC (NVL (DATA, TO_DATE ('19000101', 'yyyymmdd'))),
                      'yyyymmdd')
                || '001'
                || LPAD (NVL (tipo_registro, 'z'), 4, 'z')
                || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)
           INTO d_ordinamento
           FROM spr_protocolli
          WHERE id_documento = p_oggetto;
      ELSIF p_modello = 'M_PROTOCOLLO_INTEROPERABILITA'
      THEN
         SELECT    9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                || TO_CHAR (
                      TRUNC (NVL (DATA, TO_DATE ('19000101', 'yyyymmdd'))),
                      'yyyymmdd')
                || '001'
                || LPAD (NVL (tipo_registro, 'z'), 4, 'z')
                || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)
           INTO d_ordinamento
           FROM spr_protocolli_intero
          WHERE id_documento = p_oggetto;
      ELSIF p_modello = 'M_PROTOCOLLO_EMERGENZA'
      THEN
         SELECT    9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                || TO_CHAR (
                      TRUNC (NVL (DATA, TO_DATE ('19000101', 'yyyymmdd'))),
                      'yyyymmdd')
                || '001'
                || LPAD (NVL (tipo_registro, 'z'), 4, 'z')
                || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)
           INTO d_ordinamento
           FROM spr_protocolli_emergenza
          WHERE id_documento = p_oggetto;
      ELSIF p_modello = 'M_PROVVEDIMENTO'
      THEN
         SELECT    9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                || TO_CHAR (
                      TRUNC (NVL (DATA, TO_DATE ('19000101', 'yyyymmdd'))),
                      'yyyymmdd')
                || '001'
                || LPAD (NVL (tipo_registro, 'z'), 4, 'z')
                || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)
           INTO d_ordinamento
           FROM spr_provvedimenti
          WHERE id_documento = p_oggetto;
      ELSIF p_modello = 'LETTERA_USCITA'
      THEN
         SELECT    9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                || TO_CHAR (
                      TRUNC (NVL (DATA, TO_DATE ('19000101', 'yyyymmdd'))),
                      'yyyymmdd')
                || '001'
                || LPAD (NVL (tipo_registro, 'z'), 4, 'z')
                || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)
           INTO d_ordinamento
           FROM spr_lettere_uscita
          WHERE id_documento = p_oggetto;
      ELSIF p_modello IN ('VERBALE_DELIBERA',
                          'DELIBERA_GS4',
                          'DELIBERA',
                          'DETERMINA',
                          'DETERMINA',
                          'DELIBERA',
                          'PROPOSTA_DELIBERA')
      THEN
         d_ordinamento :=
            ag_utilities_ricerca.ordinamento_in_titolario (p_oggetto);
      END IF;

      IF d_ordinamento IS NULL
      THEN
         SELECT '999919000101999zzzz' || LPAD (0, 20, 0)
           INTO d_ordinamento
           FROM documenti
          WHERE id_documento = p_oggetto;
      END IF;

      RETURN d_ordinamento;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   --      raise_application_error (-20999,
   --                               'Oggetto: ' || p_oggetto || ' - ' || SQLERRM
   --                              );
   END;

   PROCEDURE aggiorna_ordinamenti_cartella
   AS
      d_id_tipodoc_fascicolo    NUMBER;
      d_id_tipodoc_classifica   NUMBER;
   BEGIN
      SELECT id_tipodoc
        INTO d_id_tipodoc_fascicolo
        FROM tipi_documento
       WHERE     tipi_documento.area_modello = 'SEGRETERIA'
             AND nome = 'FASCICOLO';

      SELECT id_tipodoc
        INTO d_id_tipodoc_classifica
        FROM tipi_documento
       WHERE     tipi_documento.area_modello = 'SEGRETERIA'
             AND nome = 'DIZ_CLASSIFICAZIONE';

      DELETE ordinamenti_cartella
       WHERE     id_tipodoc IN (d_id_tipodoc_classifica,
                                d_id_tipodoc_fascicolo)
             AND tipo_obj = 'D';

      INSERT INTO ordinamenti_cartella (id_ordinamentocartella,
                                        id_tipodoc,
                                        seq,
                                        tipo_obj,
                                        criterio,
                                        data_aggiornamento,
                                        utente_aggiornamento,
                                        tipo_ordinamento,
                                        tipo_criterio,
                                        lunghezza_criterio)
         SELECT orca_sq.NEXTVAL,
                d_id_tipodoc_fascicolo,
                4,
                'D',
                'AG_UTILITIES_RICERCA.ORDINAMENTO_IN_TITOLARIO(:ID_DOCUMENTO)',
                SYSDATE,
                'RPI',
                'ASC',
                'S',
                39
           FROM DUAL;

      INSERT INTO ordinamenti_cartella (id_ordinamentocartella,
                                        id_tipodoc,
                                        seq,
                                        tipo_obj,
                                        criterio,
                                        data_aggiornamento,
                                        utente_aggiornamento,
                                        tipo_ordinamento,
                                        tipo_criterio,
                                        lunghezza_criterio)
         SELECT orca_sq.NEXTVAL,
                d_id_tipodoc_classifica,
                4,
                'D',
                'AG_UTILITIES_RICERCA.ORDINAMENTO_IN_TITOLARIO(:ID_DOCUMENTO)',
                SYSDATE,
                'RPI',
                'ASC',
                'S',
                39
           FROM DUAL;
   END;


   PROCEDURE aggiorna_tipo_messaggio
   AS
      dep_idrif        NUMBER;

      CURSOR memo (
         id_min    NUMBER,
         id_max    NUMBER)
      IS
         (SELECT seg_memo_protocollo.id_documento,
                 DECODE (SUBSTR (UPPER (NVL (oggetto, ' ')), 1, 8),
                         'ANOMALIA', 'NONPEC',
                         'PEC')
                    tipo_messaggio
            FROM seg_memo_protocollo, documenti
           WHERE     tipo_messaggio IS NULL
                 AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                 AND documenti.id_documento =
                        seg_memo_protocollo.id_documento
                 AND memo_in_partenza = 'N'
                 AND documenti.id_documento BETWEEN id_min AND id_max);

      dep_id_minimo    NUMBER;
      dep_id_massimo   NUMBER;
      dep_id_da        NUMBER := 0;
      dep_id_a         NUMBER := 0;
      conta            NUMBER := 0;
   BEGIN
      SELECT MIN (documenti.id_documento), MAX (documenti.id_documento)
        INTO dep_id_minimo, dep_id_massimo
        FROM seg_memo_protocollo, documenti
       WHERE     tipo_messaggio IS NULL
             AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND documenti.id_documento = seg_memo_protocollo.id_documento
             AND memo_in_partenza = 'N';

      WHILE dep_id_a <= dep_id_massimo
      LOOP
         dep_id_da := dep_id_minimo + 100 * conta;
         conta := conta + 1;
         dep_id_a := dep_id_da + 100;

         FOR m IN memo (dep_id_da, dep_id_a)
         LOOP
            UPDATE seg_memo_protocollo
               SET tipo_messaggio = m.tipo_messaggio
             WHERE     id_documento = m.id_documento
                   AND seg_memo_protocollo.memo_in_partenza = 'N'
                   AND NOT EXISTS
                          (SELECT 1
                             FROM riferimenti
                            WHERE     riferimenti.id_documento_rif =
                                         seg_memo_protocollo.id_documento
                                  AND riferimenti.tipo_relazione =
                                         'PRINCIPALE');

            UPDATE seg_memo_protocollo
               SET tipo_messaggio = m.tipo_messaggio
             WHERE     id_documento IN (SELECT id_documento_rif
                                          FROM riferimenti
                                         WHERE     riferimenti.id_documento =
                                                      m.id_documento
                                               AND riferimenti.tipo_relazione =
                                                      'PRINCIPALE')
                   AND seg_memo_protocollo.memo_in_partenza = 'N'
                   AND tipo_messaggio IS NULL;

            UPDATE spr_protocolli_intero
               SET tipo_messaggio = m.tipo_messaggio
             WHERE     id_documento IN (SELECT id_documento
                                          FROM riferimenti
                                         WHERE     riferimenti.id_documento_rif =
                                                      m.id_documento
                                               AND riferimenti.tipo_relazione =
                                                      'MAIL'
                                        UNION
                                        SELECT r1.id_documento
                                          FROM riferimenti r1, riferimenti r2
                                         WHERE     r1.tipo_relazione = 'MAIL'
                                               AND r1.id_documento_rif =
                                                      r2.id_documento_rif
                                               AND r2.tipo_relazione =
                                                      'PRINCIPALE'
                                               AND r2.id_documento =
                                                      m.id_documento)
                   AND spr_protocolli_intero.modalita = 'ARR'
                   AND tipo_messaggio IS NULL;
         END LOOP;

         COMMIT;
      END LOOP;

      COMMIT;

      UPDATE seg_memo_protocollo
         SET tipo_messaggio = 'PEC'
       WHERE memo_in_partenza = 'Y';

      COMMIT;
   END;

   PROCEDURE aggiorna_idrif_memo
   AS
      dep_idrif        NUMBER;

      CURSOR memo (
         id_min    NUMBER,
         id_max    NUMBER)
      IS
         (SELECT seg_memo_protocollo.id_documento
            FROM seg_memo_protocollo, documenti
           WHERE     idrif IS NULL
                 AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                 AND documenti.id_documento =
                        seg_memo_protocollo.id_documento
                 AND documenti.id_documento BETWEEN id_min AND id_max);

      dep_id_minimo    NUMBER;
      dep_id_massimo   NUMBER;
      dep_id_da        NUMBER := 0;
      dep_id_a         NUMBER := 0;
      conta            NUMBER := 0;
   BEGIN
      SELECT MIN (documenti.id_documento), MAX (documenti.id_documento)
        INTO dep_id_minimo, dep_id_massimo
        FROM seg_memo_protocollo, documenti
       WHERE     idrif IS NULL
             AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND documenti.id_documento = seg_memo_protocollo.id_documento;

      WHILE dep_id_a <= dep_id_massimo
      LOOP
         dep_id_da := dep_id_minimo + 100 * conta;
         conta := conta + 1;
         dep_id_a := dep_id_minimo + 100 * conta;

         FOR m IN memo (dep_id_da, dep_id_a)
         LOOP
            SELECT seq_idrif.NEXTVAL INTO dep_idrif FROM DUAL;

            UPDATE seg_memo_protocollo
               SET idrif = dep_idrif
             WHERE id_documento = m.id_documento;
         END LOOP;

         COMMIT;
      END LOOP;

      COMMIT;
   END;

   PROCEDURE pulisci_riferimenti_mail
   IS
   BEGIN
      FOR p
         IN (SELECT prin.id_documento
               FROM spr_protocolli_intero prin, documenti docu
              WHERE     prin.id_documento = docu.id_documento
                    AND docu.stato_documento = 'CA')
      LOOP
         FOR m
            IN (SELECT id_documento_rif
                  FROM riferimenti
                 WHERE     tipo_relazione IN ('MAIL', 'FAX')
                       AND id_documento = p.id_documento)
         LOOP
            DECLARE
               esistono_prot   NUMBER := 0;
            BEGIN
               SELECT COUNT (*)
                 INTO esistono_prot
                 FROM riferimenti
                WHERE     tipo_relazione IN ('MAIL', 'FAX')
                      AND id_documento != p.id_documento
                      AND id_documento_rif = m.id_documento_rif;

               IF esistono_prot > 0
               THEN
                  DELETE riferimenti
                   WHERE     id_documento = p.id_documento
                         AND id_documento_rif = m.id_documento_rif
                         AND tipo_relazione IN ('MAIL', 'FAX');
               END IF;
            END;
         END LOOP;
      END LOOP;

      COMMIT;
   END;

   PROCEDURE sistema_precedenti
   IS
      min_anno        NUMBER;
      max_anno        NUMBER;
      registro        seg_registri.tipo_registro%TYPE;
      relazione       VARCHAR2 (100) := 'PROT_PREC';
      area            VARCHAR2 (100) := 'SEGRETERIA.PROTOCOLLO';
      anno_corrente   NUMBER := 0;
      conta           NUMBER := 0;
      precedente      NUMBER;
   BEGIN
      registro := ag_parametro.get_valore ('TIPO_REGISTRO_1', '@agVar@', '*');
      DBMS_OUTPUT.put_line ('registro ' || registro);

      SELECT MIN (anno) INTO min_anno FROM spr_protocolli;

      SELECT MAX (anno) INTO max_anno FROM spr_protocolli;

      anno_corrente := min_anno;

      WHILE anno_corrente <= max_anno
      LOOP
         DBMS_OUTPUT.put_line ('anno ' || anno_corrente);

         FOR p
            IN (SELECT id_documento, anno_prot_prec_succ, prot_prec_succ
                  FROM spr_protocolli
                 WHERE     anno = anno_corrente
                       AND anno_prot_prec_succ IS NOT NULL
                       AND prot_prec_succ IS NOT NULL
                       AND stato_pr != 'DP'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM riferimenti
                                WHERE     id_documento_rif =
                                             spr_protocolli.id_documento
                                      AND tipo_relazione = relazione))
         LOOP
            BEGIN
               EXECUTE IMMEDIATE
                     'SELECT id_documento FROM proto_view WHERE anno = '
                  || p.anno_prot_prec_succ
                  || ' AND numero = '
                  || p.prot_prec_succ
                  || ' AND tipo_registro = '''
                  || registro
                  || ''''
                  INTO precedente;

               conta := conta + 1;

               INSERT INTO riferimenti (id_documento,
                                        id_documento_rif,
                                        libreria_remota,
                                        area,
                                        tipo_relazione,
                                        data_aggiornamento,
                                        utente_aggiornamento)
                    VALUES (precedente,
                            p.id_documento,
                            NULL,
                            area,
                            relazione,
                            SYSDATE,
                            'RPI');

               IF conta >= 100
               THEN
                  COMMIT;
                  conta := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (
                        'ERRORE IN GESTIONE PROTOCOLLO CON ID '
                     || p.id_documento
                     || ' ANNO PREC '
                     || p.anno_prot_prec_succ
                     || ' NUMERO PREC '
                     || p.prot_prec_succ
                     || ': '
                     || SQLERRM);
            END;
         END LOOP;

         anno_corrente := anno_corrente + 1;
         COMMIT;
         conta := 0;
      END LOOP;

      SELECT MIN (anno) INTO min_anno FROM spr_lettere_uscita;

      SELECT MAX (anno) INTO max_anno FROM spr_lettere_uscita;

      anno_corrente := min_anno;

      WHILE anno_corrente <= max_anno
      LOOP
         DBMS_OUTPUT.put_line ('anno ' || anno_corrente);

         FOR p
            IN (SELECT id_documento, anno_prot_prec_succ, prot_prec_succ
                  FROM spr_lettere_uscita
                 WHERE     anno = anno_corrente
                       AND anno_prot_prec_succ IS NOT NULL
                       AND prot_prec_succ IS NOT NULL
                       AND stato_pr != 'DP'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM riferimenti
                                WHERE     id_documento_rif =
                                             spr_lettere_uscita.id_documento
                                      AND tipo_relazione = relazione))
         LOOP
            BEGIN
               EXECUTE IMMEDIATE
                     'SELECT id_documento FROM proto_view WHERE anno = '
                  || p.anno_prot_prec_succ
                  || ' AND numero = '
                  || p.prot_prec_succ
                  || ' AND tipo_registro = '''
                  || registro
                  || ''''
                  INTO precedente;

               conta := conta + 1;

               INSERT INTO riferimenti (id_documento,
                                        id_documento_rif,
                                        libreria_remota,
                                        area,
                                        tipo_relazione,
                                        data_aggiornamento,
                                        utente_aggiornamento)
                    VALUES (precedente,
                            p.id_documento,
                            NULL,
                            area,
                            relazione,
                            SYSDATE,
                            'RPI');

               IF conta >= 100
               THEN
                  COMMIT;
                  conta := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (
                        'ERRORE IN GESTIONE PROTOCOLLO CON ID '
                     || p.id_documento
                     || ' ANNO PREC '
                     || p.anno_prot_prec_succ
                     || ' NUMERO PREC '
                     || p.prot_prec_succ
                     || ': '
                     || SQLERRM);
            END;
         END LOOP;

         anno_corrente := anno_corrente + 1;
         COMMIT;
         conta := 0;
      END LOOP;

      SELECT MIN (anno) INTO min_anno FROM spr_protocolli_intero;

      SELECT MAX (anno) INTO max_anno FROM spr_protocolli_intero;

      anno_corrente := min_anno;

      WHILE anno_corrente <= max_anno
      LOOP
         DBMS_OUTPUT.put_line ('anno ' || anno_corrente);

         FOR p
            IN (SELECT id_documento, anno_prot_prec_succ, prot_prec_succ
                  FROM spr_protocolli_intero
                 WHERE     anno = anno_corrente
                       AND anno_prot_prec_succ IS NOT NULL
                       AND prot_prec_succ IS NOT NULL
                       AND stato_pr != 'DP'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM riferimenti
                                WHERE     id_documento_rif =
                                             spr_protocolli_intero.id_documento
                                      AND tipo_relazione = relazione))
         LOOP
            BEGIN
               EXECUTE IMMEDIATE
                     'SELECT id_documento FROM proto_view WHERE anno = '
                  || p.anno_prot_prec_succ
                  || ' AND numero = '
                  || p.prot_prec_succ
                  || ' AND tipo_registro = '''
                  || registro
                  || ''''
                  INTO precedente;

               conta := conta + 1;

               INSERT INTO riferimenti (id_documento,
                                        id_documento_rif,
                                        libreria_remota,
                                        area,
                                        tipo_relazione,
                                        data_aggiornamento,
                                        utente_aggiornamento)
                    VALUES (precedente,
                            p.id_documento,
                            NULL,
                            area,
                            relazione,
                            SYSDATE,
                            'RPI');

               IF conta >= 100
               THEN
                  COMMIT;
                  conta := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (
                        'ERRORE IN GESTIONE PROTOCOLLO CON ID '
                     || p.id_documento
                     || ' ANNO PREC '
                     || p.anno_prot_prec_succ
                     || ' NUMERO PREC '
                     || p.prot_prec_succ
                     || ': '
                     || SQLERRM);
            END;
         END LOOP;

         anno_corrente := anno_corrente + 1;
         COMMIT;
         conta := 0;
      END LOOP;

      SELECT MIN (anno) INTO min_anno FROM spr_protocolli_emergenza;

      SELECT MAX (anno) INTO max_anno FROM spr_protocolli_emergenza;

      anno_corrente := min_anno;

      WHILE anno_corrente <= max_anno
      LOOP
         DBMS_OUTPUT.put_line ('anno ' || anno_corrente);

         FOR p
            IN (SELECT id_documento, anno_prot_prec_succ, prot_prec_succ
                  FROM spr_protocolli_emergenza
                 WHERE     anno = anno_corrente
                       AND anno_prot_prec_succ IS NOT NULL
                       AND prot_prec_succ IS NOT NULL
                       AND stato_pr != 'DP'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM riferimenti
                                WHERE     id_documento_rif =
                                             spr_protocolli_emergenza.id_documento
                                      AND tipo_relazione = relazione))
         LOOP
            BEGIN
               EXECUTE IMMEDIATE
                     'SELECT id_documento FROM proto_view WHERE anno = '
                  || p.anno_prot_prec_succ
                  || ' AND numero = '
                  || p.prot_prec_succ
                  || ' AND tipo_registro = '''
                  || registro
                  || ''''
                  INTO precedente;

               conta := conta + 1;

               INSERT INTO riferimenti (id_documento,
                                        id_documento_rif,
                                        libreria_remota,
                                        area,
                                        tipo_relazione,
                                        data_aggiornamento,
                                        utente_aggiornamento)
                    VALUES (precedente,
                            p.id_documento,
                            NULL,
                            area,
                            relazione,
                            SYSDATE,
                            'RPI');

               IF conta >= 100
               THEN
                  COMMIT;
                  conta := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (
                        'ERRORE IN GESTIONE PROTOCOLLO CON ID '
                     || p.id_documento
                     || ' ANNO PREC '
                     || p.anno_prot_prec_succ
                     || ' NUMERO PREC '
                     || p.prot_prec_succ
                     || ': '
                     || SQLERRM);
            END;
         END LOOP;

         anno_corrente := anno_corrente + 1;
         COMMIT;
         conta := 0;
      END LOOP;
   END sistema_precedenti;

   PROCEDURE aggiorna_segnatura_tido
   AS
   BEGIN
      UPDATE seg_tipi_documento
         SET segnatura = 'Y';

      COMMIT;
   END aggiorna_segnatura_tido;

   PROCEDURE SISTEMA_ORDINAMENTO_PROTOCOLLI
   IS
      conta           NUMBER := 0;

      PRAGMA AUTONOMOUS_TRANSACTION;
      prot            afc.t_ref_cursor;
      d_ordinamento   VARCHAR2 (4000);
      d_id_link       NUMBER;
      d_id_oggetto    NUMBER;
   BEGIN
      OPEN prot FOR
         'SELECT ag_utilities_ricerca.ordinamento_in_titolario(id_oggetto) ordinamento, id_link, id_oggetto
               FROM links,
                    proto_view spr_protocolli,
                    seg_fascicoli,
                    cartelle,
                    documenti
              WHERE links.id_oggetto = spr_protocolli.id_documento
                AND links.tipo_oggetto = ''D''
                AND links.id_cartella = cartelle.id_cartella
                AND NVL (cartelle.stato, ''BO'') = ''BO''
                AND cartelle.id_documento_profilo =
                                                 seg_fascicoli.id_documento
                AND documenti.id_documento = spr_protocolli.id_documento
                AND documenti.stato_documento NOT IN (''CA'', ''RE'', ''PB'')';

      LOOP
         FETCH prot INTO d_ordinamento, d_id_link, d_id_oggetto;

         EXIT WHEN prot%NOTFOUND;

         conta := conta + 1;

         UPDATE links
            SET ordinamento = d_ordinamento
          WHERE id_link = d_id_link;

         IF conta = 100
         THEN
            COMMIT;
            conta := 0;
         END IF;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   END;
END ag_utilities_aggiornamenti;
/
