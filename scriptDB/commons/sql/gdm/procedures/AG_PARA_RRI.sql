--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_PARA_RRI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE AG_PARA_RRI(P_CODICE_INPUT VARCHAR2, P_TIPO_MODELLO_INPUT VARCHAR2, P_VALORE_INPUT VARCHAR2) AS
BEGIN
   IF P_CODICE_INPUT = 'TITOLI_ROMANI' AND P_TIPO_MODELLO_INPUT = '@agStrut@' AND nvl(P_VALORE_INPUT, 'N') = 'Y' THEN
       UPDATE PARAMETRI
          SET VALORE = 300
        WHERE CODICE = 'CLASSFASC_RICERCA_MAX_NUM'
          AND TIPO_MODELLO = '@agStrut@'
          AND NVL(VALORE, 9999) > 300
          AND P_VALORE_INPUT = 'Y';
    END IF;
    IF P_CODICE_INPUT = 'CLASSFASC_RICERCA_MAX_NUM' AND P_TIPO_MODELLO_INPUT  = '@agStrut@' THEN
        DECLARE
           dep_is_titoli_romani number := 0;
        begin
           select nvl(max(1), 0)
             into dep_is_titoli_romani
             from parametri
            where codice = 'TITOLI_ROMANI'
              and valore = 'Y'
              and tipo_modello = '@agStrut@';
           if dep_is_titoli_romani = 1 and to_number(nvl(P_VALORE_INPUT, '9999')) > 300 then
              raise_application_error(-20999, 'Il Parametro CLASSFASC_RICERCA_MAX_NUM non deve avere valore superiore a 300.');
           end if;
        end;
    END IF;
END;
/
