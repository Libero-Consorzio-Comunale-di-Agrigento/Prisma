--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_UNITA runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_UNITA" ("UNITA", "CODICE_AMMINISTRAZIONE", "NOME", "PROGR_UNITA_ORGANIZZATIVA", "DAL", "AL", "CODICE_AOO", "DESC_ABBREVIATA", "TAG_MAIL", "INDIRIZZO_MAIL_IST", "FAX", "MAILFAX") AS 
  (SELECT codice_uo
                unita,
            amministrazione
                codice_amministrazione,
            descrizione
                nome,
            progr_unita_organizzativa,
            dal,
            DECODE (SIGN (NVL (al, TRUNC (SYSDATE)) - TRUNC (SYSDATE)),
                    -1, al,
                    NULL),
            aoo,
            etichetta,
            tag_mail,
            indirizzo,
            fax,
            mailfax
       FROM so4_vpun
      WHERE     ottica =
                (select ag_parametro.get_valore ('SO_OTTICA_PROT_1', '@agVar@', '*') from dual)
            AND amministrazione =
                (select ag_parametro.get_valore ('CODICE_AMM_1', '@agVar@', '*') from dual)
            AND aoo =
                (select ag_parametro.get_valore ('CODICE_AOO_1', '@agVar@', '*') from dual)
            AND dal <= TRUNC (SYSDATE))

/
