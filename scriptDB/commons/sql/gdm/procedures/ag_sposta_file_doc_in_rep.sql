--liquibase formatted sql
--changeset mmalferrari:GDM_PROCEDURE_ag_sposta_file_doc_in_rep runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_sposta_file_doc_in_rep (
   p_id_doc_orig    NUMBER)
   RETURN NUMBER
IS
   d_id_doc            NUMBER;
   dep_is_fs_file      NUMBER;

   a_old_dir           VARCHAR2 (1000);
   a_old_path_dir_fs   VARCHAR2 (1000);
   a_old_path_file     VARCHAR2 (1000);

   dep_file BLOB := EMPTY_BLOB;
BEGIN
   d_id_doc :=
      gdm_profilo.crea_documento ('GDMSYS',
                                  'REPOSITORY',
                                  NULL,
                                  'RPI');

   FOR alle IN (SELECT id_oggetto_file, filename
                  FROM oggetti_file
                 WHERE id_documento = p_id_doc_orig)
   LOOP
      DBMS_OUTPUT.put_line ('filename ' || ALLE.filename);

      dep_is_fs_file := gdm_oggetti_file.IS_FS_FILE (alle.id_oggetto_file);

      IF dep_is_fs_file = 1
      THEN
         gdm_oggetti_file.GETPATH_FILE_FS (alle.id_oggetto_file,
                                           a_old_dir,
                                           a_old_path_dir_fs,
                                           a_old_path_file);

         dep_file :=
            gdm_oggetti_file.DOWNLOADOGGETTOFILE (alle.id_oggetto_file);
         DBMS_OUTPUT.put_line (
            'dep_file getlength ' || DBMS_LOB.getlength (dep_file));

         UPDATE oggetti_file
            SET path_file = NULL, testoocr = dep_file, "FILE" = NULL
          WHERE id_oggetto_file = alle.id_oggetto_file;
      END IF;


      UPDATE oggetti_file
         SET id_documento = d_id_doc
       WHERE id_oggetto_file = alle.id_oggetto_file;

      UPDATE impronte_file
         SET id_documento = d_id_doc
       WHERE id_documento = p_id_doc_orig AND filename = alle.filename;


      -- se il file è nel blob, non è necessario fare nulla, altrimenti
      -- bisogna spostare il file e aggiornare il puntatore ad esso
      IF dep_is_fs_file = 1
      THEN
         DBMS_OUTPUT.put_line ('bfile');

         DECLARE
            d_new_path      VARCHAR2 (2000);
            a_dir           VARCHAR2 (2000);
            a_path_dir_fs   VARCHAR2 (2000);
            a_path_file     VARCHAR2 (2000);
         BEGIN
            gdm_oggetti_file.GETPATH_FILE_FS (alle.id_oggetto_file,
                                              a_dir,
                                              a_path_dir_fs,
                                              a_path_file);
            d_new_path :=
               REPLACE (a_path_dir_fs || '/' || a_path_file,
                        '/' || alle.id_oggetto_file,
                        '');
            DBMS_OUTPUT.put_line ('d_new_path:' || d_new_path);

            GDM_UTILITY.MKDIR (d_new_path);

            DBMS_OUTPUT.put_line (
                  'gdm_oggetti_file.OGGETTO_FILE_TO_FS('
               || alle.id_oggetto_file
               || ', 1);');
            gdm_oggetti_file.OGGETTO_FILE_TO_FS_NOCOMMIT (
               alle.id_oggetto_file,
               -1,
               1);
            /*aggiunto per delete*/
            DBMS_BACKUP_RESTORE.DELETEFILE (
                  a_old_path_dir_fs
               || '/'
               || REPLACE (a_old_path_file, '$', '\$'));
         /*fine aggiunto per delete*/
         END;
      ELSE
         DBMS_OUTPUT.put_line ('blob');
      END IF;
   END LOOP;


   RETURN d_id_doc;
END;
/
