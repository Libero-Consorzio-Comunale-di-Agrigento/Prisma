--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200717_180.parametri_file_ob_upd

Insert into PARAMETRI
   (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'FILE_OB_1', '@agVar@', 'N'
        FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE codice = 'FILE_OB_1')
/

UPDATE PARAMETRI
SET NOTE = 'Valori possibili N (mai),Y (sempre), PAR (solo in partenza), PAR_INT (solo in partenza e interno)'
WHERE CODICE = 'FILE_OB_1'
/
