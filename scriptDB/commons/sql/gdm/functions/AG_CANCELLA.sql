--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_CANCELLA runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_cancella (p_documento   IN NUMBER,
                                        p_utente      IN VARCHAR2)
   RETURN NUMBER
AS
   d_stato varchar2(2) := 'CA';
BEGIN
   BEGIN
      INSERT INTO stati_documento (id_documento,
                                   stato,
                                   commento,
                                   data_aggiornamento,
                                   utente_aggiornamento)
           VALUES (p_documento,
                   d_stato,
                   'PLSQL',
                   SYSDATE,
                   p_utente);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            '-20997',
               'Impossibile modificare lo stato documento del documento:'
            || p_documento
            || ' - STATO: '
            || d_stato
            || SQLERRM);
   END;

   BEGIN
      UPDATE DOCUMENTI
         SET STATO_DOCUMENTO = d_stato
       WHERE ID_DOCUMENTO = p_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   RETURN 1;
END;
/
