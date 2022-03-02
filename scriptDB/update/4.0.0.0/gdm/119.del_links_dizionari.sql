--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_119.del_links_dizionari failOnError:false
DECLARE
   d_id_query   NUMBER;
   d_message    VARCHAR2 (32000);
BEGIN
   BEGIN
      SELECT id_query
        INTO d_id_query
        FROM query
       WHERE nome LIKE '%Ricevimento/Spedizione';

      DELETE links
       WHERE id_oggetto = d_id_query AND tipo_oggetto = 'Q';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         d_message := d_message || ' ' || 'Modalita'' Ricevimento/Spedizione';
   END;

   BEGIN
      SELECT id_query
        INTO d_id_query
        FROM query
       WHERE nome LIKE 'Movimenti';

      DELETE links
       WHERE id_oggetto = d_id_query AND tipo_oggetto = 'Q';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         d_message := d_message || ' ' || 'Movimenti';
   END;

   BEGIN
      SELECT id_query
        INTO d_id_query
        FROM query
       WHERE nome LIKE 'Procedimenti';

      DELETE links
       WHERE id_oggetto = d_id_query AND tipo_oggetto = 'Q';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         d_message := d_message || ' ' || 'Procedimenti';
   END;

   BEGIN
      SELECT id_query
        INTO d_id_query
        FROM query
       WHERE nome LIKE 'Tipi Frase%';

      DELETE links
       WHERE id_oggetto = d_id_query AND tipo_oggetto = 'Q';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         d_message := d_message || ' ' || 'Tipi Frase';
   END;

   COMMIT;

   IF d_message IS NOT NULL
   THEN
      raise_application_error (-20999,
                               'Query ' || d_message || 'non trovate');
   END IF;
END;
/