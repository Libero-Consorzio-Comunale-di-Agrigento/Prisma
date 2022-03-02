--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_REGISTRO_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_REGISTRO_UTILITY AS
/******************************************************************************
   NAME:       AG_REGISTRO_UTILITY
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2010             1. Created this package.
******************************************************************************/

FUNCTION get_preferenza_utente (
      p_modulo       IN   VARCHAR2,
      p_utente       IN   VARCHAR2,
      p_preferenza   IN   VARCHAR2,
      p_db_user      IN   VARCHAR2 default user
   )
      RETURN VARCHAR2;

END AG_REGISTRO_UTILITY;
/
CREATE OR REPLACE PACKAGE BODY AG_REGISTRO_UTILITY AS
/******************************************************************************
   NAME:       AG_REGISTRO_UTILITY
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2010             1. Created this package.
******************************************************************************/

 FUNCTION get_preferenza_utente (
      p_modulo       IN   VARCHAR2,
      p_utente       IN   VARCHAR2,
      p_preferenza   IN   VARCHAR2,
      p_db_user      IN   VARCHAR2 default user
   )
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2(2000);
   BEGIN
      SELECT AMVWEB.GET_PREFERENZA(stringa, p_modulo, p_utente) VALORE
        INTO d_return
        from REGISTRO
      where (   chiave = 'SI4_DB_USERS/'||p_utente||'|'||upper(p_db_user)||'/PRODUCTS/'||p_modulo
             or chiave = 'PRODUCTS/'||p_modulo)
        and UPPER(stringa) = UPPER(p_preferenza)
      group by stringa
      order by stringa
      ;
      RETURN d_return;
   END;

END AG_REGISTRO_UTILITY;
/
