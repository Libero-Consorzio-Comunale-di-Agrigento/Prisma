--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_GET_IDRIF runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_get_idrif
   RETURN VARCHAR2
IS
   d_idrif   VARCHAR2 (100);
BEGIN
   SELECT TO_CHAR (seq_idrif.NEXTVAL) INTO d_idrif FROM DUAL;

   RETURN d_idrif;
END;
/
