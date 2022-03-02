--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_147_upd_as4_registro

DECLARE
   d_is_interpro   VARCHAR2 (1);
BEGIN
   BEGIN
      d_is_interpro :=
         ag_parametro.get_valore ('IS_ENTE_INTERPRO_1', '@agVar@', 'N');

      INSERT INTO as4_registro (CHIAVE,
                                STRINGA,
                                COMMENTO,
                                VALORE)
              VALUES (
                        'PRODUCTS/ANAGRAFICA',
                        'NOinserimentoRCEntiSO',
                        'Indica se impedire aggiunta di Recapiti o Contatti ai soggetti che sono enti di Struttura Organizzativa (Valori Possibili: null = NO, SI)',
                        'NO');
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE as4_registro
            SET valore =
                   (SELECT DECODE (d_is_interpro, 'Y', 'SI', 'NO')
                      FROM DUAL)
          WHERE     CHIAVE = 'PRODUCTS/ANAGRAFICA'
                AND STRINGA = 'NOinserimentoRCEntiSO';
   END;
END;
/