--liquibase formatted sql
--changeset esasdelli:AGSPR_FUNCTION_GET_NUMBER_FROM_STRING runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION get_number_from_string (p_stringa VARCHAR2)
   RETURN NUMBER
IS
   d_return   NUMBER;
BEGIN
   SELECT ORA_HASH (p_stringa) INTO d_return FROM DUAL;

   RETURN d_return;
END;
/
