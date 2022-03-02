--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_PUBLIC_STORAGE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_PUBLIC_STORAGE
AS
/******************************************************************************
 NOME:        AG_PUBLIC_STORAGE
 DESCRIZIONE: PPackage di funzioni specifiche del progetto AFFARI_GENERALI per
              la gestione di file su storage esterno.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev. Data        Autore   Descrizione.
 00   03/07/2017  AM       Prima emissione.
******************************************************************************/
-- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION FILE_2_NAS (P_ID_DOCUMENTO    NUMBER,
                        P_PERCORSO        VARCHAR2,
                        P_NOMEFILE        VARCHAR2)
      RETURN NUMBER;

   FUNCTION GET_HASHFILE (P_ID_DOCUMENTO NUMBER, P_NOMEFILE VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION GETLENGTH_FILEDOCUMENTO (A_ID_DOCUMENTO    NUMBER,
                                     A_NOMEFILE        VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_PUBLIC_STORAGE
AS
   /******************************************************************************
    NOME:        AG_PUBLIC_STORAGE
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
              la gestione di file su storage esterno.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data       Autore Descrizione.
   000  03/07/2017 AM     Prima emissione.
   ******************************************************************************/
   TYPE ag_refcursor IS REF CURSOR;

   s_revisione_body   CONSTANT afc.t_revision := '000';

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

   FUNCTION FILE_2_NAS (P_ID_DOCUMENTO    NUMBER,
                        P_PERCORSO        VARCHAR2,
                        P_NOMEFILE        VARCHAR2)
      RETURN NUMBER
   IS
      l_pos               INTEGER := 1;
      l_blob_len          INTEGER;
      l_file              UTL_FILE.FILE_TYPE;
      l_buffer            RAW (32767);
      l_amount            BINARY_INTEGER := 32767;
      A_BLOB              BLOB;
      RESULT              NUMBER := 0;
      A_ID_OGGETTO_FILE   NUMBER;
   BEGIN
      SELECT id_oggetto_file
        INTO a_id_oggetto_file
        FROM oggetti_file
       WHERE     id_Documento = p_id_documento
             AND LOWER (filename) = LOWER (p_nomefile);

      A_BLOB := GDM_OGGETTI_FILE.DOWNLOADOGGETTOFILE (a_id_oggetto_file);

      BEGIN
         EXECUTE IMMEDIATE
               'create or replace directory TEMP_FILE as '''
            || P_PERCORSO
            || '''';
      EXCEPTION
         WHEN OTHERS
         THEN
            RESULT := -1;
            RAISE_APPLICATION_ERROR (
               -20999,
                  'Errore in creazione dir oracle temporanea per path '
               || P_PERCORSO
               || ': '
               || SQLERRM);
      END;

      l_blob_len := DBMS_LOB.GETLENGTH (A_BLOB);
      l_pos := 1;

      BEGIN
         l_file :=
            UTL_FILE.fopen ('TEMP_FILE',
                            P_NOMEFILE,
                            'wb',
                            32767);

         -- dbms_output.put_line(l_blob_len);
         WHILE l_pos <= l_blob_len
         LOOP
            DBMS_LOB.read (A_BLOB,
                           l_amount,
                           l_pos,
                           l_buffer);
            UTL_FILE.put_raw (l_file, l_buffer, TRUE);
            --dbms_output.put_line(l_amount);
            l_pos := l_pos + l_amount;
         --dbms_output.put_line(l_pos);
         END LOOP;

         UTL_FILE.fclose (l_file);
         result := 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            result := -1;
            RAISE_APPLICATION_ERROR (
               -20999,
                  'Errore in scrittura file '
               || P_PERCORSO
               || '/'
               || P_NOMEFILE
               || ': '
               || SQLERRM);
      END;

      RETURN result;
   END;

   FUNCTION GET_HASHFILE (P_ID_DOCUMENTO NUMBER, P_NOMEFILE VARCHAR2)
      RETURN VARCHAR2
   IS
      result   VARCHAR2 (128);
   BEGIN
      BEGIN
         SELECT HASHCODE
           INTO result
           FROM IMPRONTE_FILE
          WHERE id_documento = p_id_documento AND filename = p_nomefile;
      EXCEPTION
         WHEN OTHERS
         THEN
            RESULT := 'ERROR';
            RAISE_APPLICATION_ERROR (
               -20999,
                  'Errore in lettura del hash del file '
               || 'ID_DOC='
               || p_id_documento
               || ' NOMEFILE='
               || p_nomefile
               || ': '
               || SQLERRM);
      END;

      RETURN result;
   END;

   FUNCTION GETLENGTH_FILEDOCUMENTO (A_ID_DOCUMENTO    NUMBER,
                                     A_NOMEFILE        VARCHAR2)
      RETURN NUMBER
   IS
      tmpVar   NUMBER;
   BEGIN
      tmpVar := 0;

      SELECT DECODE (
                path_file,
                NULL, NVL (CEIL (DBMS_LOB.getlength (testoocr) / 1048576), 0),
                NVL (CEIL (DBMS_LOB.getlength ("FILE") / 1048576), 0))
        INTO tmpVar
        FROM oggetti_file
       WHERE     id_documento = A_ID_DOCUMENTO
             AND UPPER (filename) = UPPER (A_NOMEFILE)
             AND ROWNUM = 1;



      RETURN tmpVar;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         -- Consider logging the error and then re-raise
         RAISE;
   END;
END;
/
