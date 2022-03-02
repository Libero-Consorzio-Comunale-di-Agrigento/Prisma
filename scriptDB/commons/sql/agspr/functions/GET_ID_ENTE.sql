--liquibase formatted sql
--changeset esasdelli:AGSPR_FUNCTION_GET_ID_ENTE runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION get_id_ente (p_codice_amministrazione    VARCHAR2,
                                        p_codice_aoo                VARCHAR2,
                                        p_ottica                    VARCHAR2)
   RETURN NUMBER
IS
   d_return   NUMBER;
BEGIN
   SELECT ID_ENTE
     INTO d_return
     FROM GDO_ENTI
    WHERE     amministrazione = p_codice_amministrazione
          AND aoo = p_codice_aoo
          AND ottica IN NVL (p_ottica,
                             (SELECT gdm_ag_parametro.get_valore (
                                        'SO_OTTICA_PROT',
                                        p_codice_amministrazione,
                                        p_codice_aoo,
                                        '')
                                FROM DUAL));

   RETURN d_return;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END;
/
