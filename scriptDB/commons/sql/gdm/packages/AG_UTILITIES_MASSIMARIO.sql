--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_MASSIMARIO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_utilities_massimario
AS
/******************************************************************************
   NAME:       AG_UTILITIES
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver       Date        Author          Description
   ----  ----------  ------------ --------------------------------------------
   00    19/11/2013               Created this package.

******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE proponi_scarto (p_id_documento NUMBER);

   PROCEDURE conserva (p_id_documento NUMBER);

   PROCEDURE attendi_approvazione (p_id_documento NUMBER);

   PROCEDURE non_scartabile (p_id_documento NUMBER);

   PROCEDURE scarta (
      p_id_documento      NUMBER,
      p_nulla_osta        VARCHAR2,
      p_data_nulla_osta   VARCHAR2
   );
END ag_utilities_massimario;
/
CREATE OR REPLACE PACKAGE BODY ag_utilities_massimario
AS
/******************************************************************************
   NAME:       AG_UTILITIES
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver        Date        Author          Description
   ---------  ----------  --------------- ------------------------------------
   00    19/11/2013               Created this package.

******************************************************************************/
   s_revisione_body   afc.t_revision := '000';

/********************************************************
VARIABILI GLOBALI
*********************************************************/
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

   FUNCTION get_tabella (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_tabella   VARCHAR2 (40);
   BEGIN
      SELECT UPPER (aree.acronimo || '_' || tido.alias_modello) tabella
        INTO dep_tabella
        FROM tipi_documento tido, documenti docu, aree
       WHERE tido.id_tipodoc = docu.id_tipodoc
         AND docu.id_documento = p_id_documento
         AND aree.area = tido.area_modello;

      RETURN dep_tabella;
   END;

   PROCEDURE proponi_scarto (p_id_documento NUMBER)
   IS
      dep_stmt         VARCHAR2 (32000);
      dep_table_name   VARCHAR2 (40);
   BEGIN
      dep_table_name := get_tabella (p_id_documento);
      dep_stmt :=
            'UPDATE '
         || dep_table_name
         || ' SET STATO_SCARTO = ''PS'''
         || ' WHERE STATO_SCARTO IN (''**'', ''RR'')'
         || ' and id_documento = '
         || p_id_documento;
      dbms_output.put_line(dep_stmt);

      EXECUTE IMMEDIATE (dep_stmt);
   END;

   PROCEDURE conserva (p_id_documento NUMBER)
   IS
      dep_stmt         VARCHAR2 (32000);
      dep_table_name   VARCHAR2 (40);
   BEGIN
      dep_table_name := get_tabella (p_id_documento);
      dep_stmt :=
            'UPDATE '
         || dep_table_name
         || ' SET STATO_SCARTO = ''CO'''
         || ' WHERE STATO_SCARTO IN (''**'', ''RR'')'
         || ' and id_documento = '
         || p_id_documento;

      EXECUTE IMMEDIATE (dep_stmt);
   END;

   PROCEDURE attendi_approvazione (p_id_documento NUMBER)
   IS
      dep_stmt         VARCHAR2 (32000);
      dep_table_name   VARCHAR2 (40);
   BEGIN
      dep_table_name := get_tabella (p_id_documento);
      dep_stmt :=
            'UPDATE '
         || dep_table_name
         || ' SET STATO_SCARTO = ''AA'''
         || ' WHERE STATO_SCARTO IN (''PS'')'
         || ' and id_documento = '
         || p_id_documento;

      EXECUTE IMMEDIATE (dep_stmt);
   END;

   PROCEDURE non_scartabile (p_id_documento NUMBER)
   IS
      dep_stmt         VARCHAR2 (32000);
      dep_table_name   VARCHAR2 (40);
   BEGIN
      dep_table_name := get_tabella (p_id_documento);
      dep_stmt :=
            'UPDATE '
         || dep_table_name
         || ' SET STATO_SCARTO = ''RR'''
         || ' WHERE STATO_SCARTO IN (''AA'')'
         || ' and id_documento = '
         || p_id_documento;

      EXECUTE IMMEDIATE (dep_stmt);
   END;

   PROCEDURE scarta (
      p_id_documento      NUMBER,
      p_nulla_osta        VARCHAR2,
      p_data_nulla_osta   VARCHAR2
   )
   IS
      dep_stmt         VARCHAR2 (32000);
      dep_table_name   VARCHAR2 (40);
   BEGIN
      dep_table_name := get_tabella (p_id_documento);
      dep_stmt :=
            'UPDATE '
         || dep_table_name
         || ' SET STATO_SCARTO = ''SC'','
         || ' NUMERO_NULLA_OSTA = '''
         || p_nulla_osta
         || ''','
         || ' DATA_NULLA_OSTA = TO_DATE('''
         || p_data_nulla_osta
         || ''',''DD/MM/YYYY'')'
         || ' WHERE STATO_SCARTO IN (''AA'')'
         || ' and id_documento = '
         || p_id_documento;

      EXECUTE IMMEDIATE (dep_stmt);
   END;
----------------
END ag_utilities_massimario;
/
