--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_OGGETTI_FILE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_OGGETTI_FILE
AS
   /******************************************************************************
      NAME:       AG_OGGETTI_FILE
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      00         19/05/2017  MM               1. Created this package.
      01         07/02/2020  MM               Creata get_len
      02         26/02/2020  MM               Creata get_len_storico
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.02';

   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE UPD_FILENAME (P_ID_OGGETTO_FILE NUMBER, P_FILENAME VARCHAR2);

   FUNCTION get_len (P_ID_OGGETTO_FILE NUMBER)
      RETURN NUMBER;

   FUNCTION get_len_storico (P_ID_OGGETTO_FILE NUMBER)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_OGGETTI_FILE
AS
   /******************************************************************************
      NAME:       AG_OGGETTI_FILE
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      000        19/05/2017  MM               1. Created this package.
      001        07/02/2020  MM               Creata get_len
      002        26/02/2020  MM               Creata get_len_storico
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '002';

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

   PROCEDURE upd_filename (P_ID_OGGETTO_FILE NUMBER, P_FILENAME VARCHAR2)
   IS
   BEGIN
      UPDATE OGGETTI_FILE
         SET FILENAME = P_FILENAME
       WHERE ID_OGGETTO_FILE = P_ID_OGGETTO_FILE;
   END;

   FUNCTION get_len (P_ID_OGGETTO_FILE NUMBER)
      RETURN NUMBER
   IS
      d_dimensione   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (
                   NVL (DBMS_LOB.getlength (testoocr),
                        DBMS_LOB.getlength ("FILE")),
                   0)
           INTO d_dimensione
           FROM oggetti_file
          WHERE id_oggetto_file = P_ID_OGGETTO_FILE;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_dimensione := 0;
      END;

      RETURN d_dimensione;
   END;

   FUNCTION get_len_storico (P_ID_OGGETTO_FILE NUMBER)
      RETURN NUMBER
   IS
      d_dimensione   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (
                   NVL (DBMS_LOB.getlength (testoocr),
                        DBMS_LOB.getlength ("FILE")),
                   0)
           INTO d_dimensione
           FROM oggetti_file_log
          WHERE id_oggetto_file = P_ID_OGGETTO_FILE;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_dimensione := 0;
      END;

      RETURN d_dimensione;
   END;
END;
/
