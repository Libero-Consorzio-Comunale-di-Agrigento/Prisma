--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_CANCELLA_MEMO runOnChange:true stripComments:false

CREATE OR REPLACE procedure ag_cancella_memo (p_message_id   IN VARCHAR2)
AS
   d_id_documento number;
   d_stato varchar2(2) := 'CA';
   pragma autonomous_transaction;
BEGIN
   begin
      select m.id_documento
        into d_id_documento
        from seg_memo_protocollo m, documenti d
       where message_id = p_message_id
         and d.id_documento = m.id_documento
         and d.stato_documento not in ('CA')
      --   and m.id_documento > 19808232
      ;
   exception
      when others then
         rollback;
         raise;
   end;
   BEGIN
      INSERT INTO stati_documento (id_documento,
                                   stato,
                                   commento,
                                   data_aggiornamento,
                                   utente_aggiornamento)
           VALUES (d_id_documento,
                   d_stato,
                   'PLSQL',
                   SYSDATE,
                   'GDM');
   EXCEPTION
      WHEN OTHERS
      THEN
         rollback;
         raise_application_error (
            '-20997',
               'Impossibile modificare lo stato documento del documento:'
            || d_id_documento
            || ' - STATO: '
            || d_stato
            || SQLERRM);
   END;

   BEGIN
      UPDATE DOCUMENTI
         SET STATO_DOCUMENTO = d_stato
       WHERE ID_DOCUMENTO = d_id_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         rollback;
         RAISE;
   END;

   commit;

END;
/
