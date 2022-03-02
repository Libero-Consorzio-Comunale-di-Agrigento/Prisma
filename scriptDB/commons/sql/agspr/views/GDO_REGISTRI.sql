--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_GDO_REGISTRI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "GDO_REGISTRI" ("ID_REGISTRO", "ANNO", "TIPO_REGISTRO", "ULTIMO_NUMERO", "ULTIMA_DATA", "APERTO", "ID_ENTE", "UNITA_EMERGENZA_OTTICA", "UNITA_EMERGENZA_PROGR", "UNITA_EMERGENZA_DAL", "UTENTE_INS", "DATA_INS", "UTENTE_UPD", "DATA_UPD", "VALIDO", "VERSION") AS 
  SELECT -DOCU.ID_DOCUMENTO,
       ANNO_REG,
       TIPO_REGISTRO,
       ULTIMO_NUMERO_REG,
       ULTIMA_DATA_REG,
       CAST (IN_USO AS CHAR (1)),
       ENTI.ID_ENTE,
       U1.OTTICA,
       U1.progr_unita_organizzativa,
       U1.DAL,
       DOCU.UTENTE_AGGIORNAMENTO UTENTE_INS,
       DOCU.DATA_AGGIORNAMENTO DATA_INS,
       DOCU.UTENTE_AGGIORNAMENTO UTENTE_UPD,
       DOCU.DATA_AGGIORNAMENTO DATA_UPD,
       CAST (
          DECODE (NVL (docu.stato_documento, 'BO'), 'BO', 'Y', 'N') AS CHAR (1))
          VALIDO,
       0
  FROM GDM_SEG_REGISTRI REGI,
       GDM_DOCUMENTI DOCU,
       GDO_ENTI ENTI,
       (SELECT ottica,
               progr_unita_organizzativa,
               dal,
               al,
               codice_uo
          FROM so4_unita_organizzative_pubb unor1
         WHERE NOT EXISTS
                  (SELECT 1
                     FROM so4_unita_organizzative_pubb unor2
                    WHERE     unor2.ottica = unor1.ottica
                          AND unor2.progr_unita_organizzativa =
                                 unor1.progr_unita_organizzativa
                          AND NVL (unor2.al, TO_DATE (3333333, 'j')) >
                                 NVL (unor1.al, TO_DATE (3333333, 'j')))) u1
 WHERE     DOCU.ID_DOCUMENTO = REGI.ID_DOCUMENTO
       AND ENTI.AMMINISTRAZIONE = REGI.CODICE_AMMINISTRAZIONE
       AND ENTI.AOO = REGI.CODICE_AOO
       AND ENTI.OTTICA in (select GDM_AG_PARAMETRO.GET_VALORE (
                            'SO_OTTICA_PROT',
                            REGI.CODICE_AMMINISTRAZIONE,
                            REGI.CODICE_AOO,
                            '') from dual)
       AND NVL (U1.OTTICA, ENTI.OTTICA) = ENTI.OTTICA
       AND U1.CODICE_UO(+) = UNITA_EMERGENZA
/
