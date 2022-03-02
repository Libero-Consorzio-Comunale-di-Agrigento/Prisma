--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_163_upd_gdo_file_documento_dim

DECLARE
   d_dim   NUMBER;
BEGIN
   FOR fd IN (SELECT id_file_documento, testoocr, "FILE"
                FROM ${global.db.agspr.username}.gdo_file_documento, oggetti_file
               WHERE id_oggetto_file = id_file_esterno AND dimensione = 0)
   LOOP
      BEGIN
         d_dim :=
            NVL (
               NVL (DBMS_LOB.getlength (fd.testoocr),
                    DBMS_LOB.getlength (fd."FILE")),
               0);
      EXCEPTION
         WHEN OTHERS
         THEN
            d_dim := 0;
      END;

      UPDATE ${global.db.agspr.username}.gdo_file_documento
         SET dimensione = d_dim
       WHERE id_file_documento = fd.id_file_documento;
   END LOOP;
END;
/