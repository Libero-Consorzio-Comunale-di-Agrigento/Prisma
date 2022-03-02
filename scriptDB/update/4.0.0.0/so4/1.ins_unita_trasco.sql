--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200924_1_ins_unita_trasco

/*
   creazione unità fittizia da utilizzare come unità protocollante / esibente/ ...
   in trascodifica quando non esiste più quella memorizzata nel record.
*/
ALTER TABLE ANAGRAFE_UNITA_ORGANIZZATIVE
   DISABLE ALL TRIGGERS
/

DECLARE
   d_ottica        VARCHAR2 (1000);
   d_cod_amm       VARCHAR2 (1000);
   d_progr_aoo     NUMBER;
   D_PROGR         NUMBER;
   D_DAL           DATE := TO_DATE ('01/01/1951', 'MM/DD/YYYY');
   d_aggiornamento NUMBER := 0;
BEGIN
   SELECT gdm_ag_parametro.get_valore ('SO_OTTICA_PROT_1', '@agVar@', '*')
     INTO d_ottica
     FROM DUAL;

   SELECT COUNT(1)
     INTO d_aggiornamento
    FROM REVISIONI_STRUTTURA
    WHERE OTTICA = d_ottica AND REVISIONE = 1
   ;

   if d_aggiornamento = 1 then
   SELECT gdm_ag_parametro.get_valore ('CODICE_AMM_1', '@agVar@', '*')
     INTO d_cod_amm
     FROM DUAL;

   SELECT progr_aoo
     INTO d_progr_aoo
     FROM aoo
    WHERE     codice_amministrazione = d_cod_amm
          AND codice_aoo =
                 (SELECT gdm_ag_parametro.get_valore ('CODICE_AOO_1',
                                                      '@agVar@',
                                                      '*')
                    FROM DUAL)
          AND SYSDATE BETWEEN dal AND NVL (al, SYSDATE);

   BEGIN
      SELECT DISTINCT PROGR_UNITA_ORGANIZZATIVA
        INTO D_PROGR
        FROM anagrafe_unita_organizzativE
       WHERE ottica = d_ottica AND CODICE_UO = 'TRASCO';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         SELECT anagrafe_unita_organizzativa.get_id_unita
           INTO D_PROGR
           FROM DUAL;
   END;

   INSERT INTO ANAGRAFE_UNITA_ORGANIZZATIVE (PROGR_UNITA_ORGANIZZATIVA,
                                             DAL,
                                             revisione_istituzione,
                                             CODICE_UO,
                                             DESCRIZIONE,
                                             DES_ABB,
                                             OTTICA,
                                             AMMINISTRAZIONE,
                                             PROGR_AOO,
                                             AL,
                                             UTENTE_AGGIORNAMENTO,
                                             DATA_AGGIORNAMENTO,
                                             DAL_PUBB,
                                             AL_PUBB)
      SELECT D_PROGR,
             D_DAL,
             1,
             'TRASCO',
             'UNITA'' PER TRASCODIFICHE',
             'TRASCO',
             d_ottica,
             d_cod_amm,
             d_progr_aoo,
             TRUNC (SYSDATE) - 1,
             'TRASCO',
             TRUNC (SYSDATE),
             D_DAL,
             TRUNC (SYSDATE) - 1
        FROM DUAL
       WHERE NOT EXISTS
                (SELECT 1
                   FROM ANAGRAFE_UNITA_ORGANIZZATIVE
                  WHERE ottica = d_ottica AND CODICE_UO = 'TRASCO');

   COMMIT;

   INSERT INTO UNITA_ORGANIZZATIVE (OTTICA,
                                    PROGR_UNITA_ORGANIZZATIVA,
                                    DAL,
                                    revisione,
                                    UTENTE_AGGIORNAMENTO,
                                    DATA_AGGIORNAMENTO,
                                    DAL_PUBB,
                                    AL,
                                    AL_PUBB)
      SELECT d_ottica,
             D_PROGR,
             D_DAL,
             1,
             'TRASCO',
             TRUNC (SYSDATE),
             D_DAL,
             TRUNC (SYSDATE) - 1,
             TRUNC (SYSDATE) - 1
        FROM DUAL
       WHERE NOT EXISTS
                (SELECT 1
                   FROM UNITA_ORGANIZZATIVE
                  WHERE     ottica = d_ottica
                        AND PROGR_UNITA_ORGANIZZATIVA = D_PROGR);

   COMMIT;
   end if;
END;
/

ALTER TABLE ANAGRAFE_UNITA_ORGANIZZATIVE
   ENABLE ALL TRIGGERS
/