--liquibase formatted sql
--changeset esasdelli:AGSPR_FUNCTION_GET_UNITA_MAX_DAL runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION get_unita_max_dal (p_progr NUMBER, p_ottica VARCHAR2)
   RETURN DATE
IS
   d_dal   DATE;
BEGIN
   SELECT dal
     INTO d_dal
     FROM so4_unita_organizzative_pubb unor1
    WHERE     unor1.progr_unita_organizzativa = p_progr
          AND unor1.ottica = p_ottica
          AND NOT EXISTS
                 (SELECT 1
                    FROM so4_unita_organizzative_pubb unor2
                   WHERE     unor2.ottica = unor1.ottica
                         AND unor2.progr_unita_organizzativa =
                                unor1.progr_unita_organizzativa
                         AND NVL (unor2.al, TO_DATE (3333333, 'j')) >
                                NVL (unor1.al, TO_DATE (3333333, 'j')));

   RETURN d_dal;
END;
/
