--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_GET_UNITA_PROTOCOLLANTI runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION AG_GET_UNITA_PROTOCOLLANTI (
   p_utente      IN VARCHAR2,
   p_utente_pr   IN VARCHAR2,
   p_data_pr     IN VARCHAR2,
   p_stato_pr    IN VARCHAR2,
   p_cache_vuotata in varchar2)
   RETURN afc.t_ref_cursor
IS
BEGIN
   RETURN AG_DOCUMENTO_UTILITY.GET_UNITA_PROTOCOLLANTI (p_utente,
                                                        p_utente_pr,
                                                        p_data_pr,
                                                        p_stato_pr);
END;
/
