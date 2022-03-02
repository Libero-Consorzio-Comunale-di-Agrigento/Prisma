--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_COMP_CREA_PROTOCOLLO runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_comp_crea_protocollo (
   p_utente           VARCHAR2,
   p_codice_azione    VARCHAR2 DEFAULT NULL)
   RETURN NUMBER
IS
BEGIN
   return ag_verifica_privilegi_utente(p_utente, p_codice_azione);
END;
/

