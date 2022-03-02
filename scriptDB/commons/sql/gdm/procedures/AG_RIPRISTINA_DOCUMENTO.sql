--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_RIPRISTINA_DOCUMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_ripristina_documento (dep_id_documento NUMBER)
AS
   dep_data_stato      DATE;
   dep_utente          stati_documento.utente_aggiornamento%TYPE;
   dep_stato           stati_documento.stato%TYPE;
   dep_utente_delete   stati_documento.utente_aggiornamento%TYPE;
   dep_data_delete     DATE;
BEGIN
   BEGIN
      SELECT utente_aggiornamento, data_aggiornamento
        INTO dep_utente_delete, dep_data_delete
        FROM stati_documento
       WHERE id_documento = dep_id_documento AND stato = 'CA';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
   END;

   DELETE      stati_documento
         WHERE id_documento = dep_id_documento AND stato = 'CA';

   SELECT MAX (data_aggiornamento)
     INTO dep_data_stato
     FROM stati_documento
    WHERE id_documento = dep_id_documento;

   DBMS_OUTPUT.put_line (   'dep_data_stato '
                         || TO_CHAR (dep_data_stato, 'DD/MM/YYYY HH24:MI:SS')
                        );

   SELECT utente_aggiornamento, stato
     INTO dep_utente, dep_stato
     FROM stati_documento
    WHERE id_documento = dep_id_documento
      AND data_aggiornamento = dep_data_stato;

   DBMS_OUTPUT.put_line ('dep_utente ' || dep_utente);
   DBMS_OUTPUT.put_line ('dep_stato ' || dep_stato);

   UPDATE documenti
      SET data_aggiornamento = dep_data_stato,
          utente_aggiornamento = dep_utente,
          stato_documento = dep_stato
    WHERE id_documento = dep_id_documento;

   UPDATE stati_documento
      SET commento =
                'Per integrita'' dati di interoperabilita'', in data '
             || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
             || ' e'' stato ripristinato record cancellato da '
             || dep_utente_delete
             || ' il giorno '
             || TO_CHAR (dep_data_delete, 'dd/mm/yyyy hh24:mi:ss')
    WHERE id_documento = dep_id_documento
      AND data_aggiornamento = dep_data_stato;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
