--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_COMP_CREA_LETTERA runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_comp_crea_lettera (
   p_utente           VARCHAR2,
   p_codice_azione    VARCHAR2 DEFAULT NULL)
   RETURN NUMBER
IS
BEGIN
   RETURN ag_utilities.verifica_privilegio_utente (NULL,
                                                   'REDLET',
                                                   p_utente,
                                                   SYSDATE);
END;
/
