--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_UNIT_INSTEAD_TU runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_unit_instead_tu (
   old_codice_uo        VARCHAR2,
   new_codice_uo        VARCHAR2,
   old_descrizione_uo   VARCHAR2,
   new_descrizione_uo   VARCHAR2,
   old_dal              DATE,
   new_dal              DATE,
   new_al               DATE
)
IS
BEGIN
   IF     old_codice_uo = new_codice_uo
      AND old_dal = new_dal
      AND new_descrizione_uo != NVL (old_descrizione_uo, '####')
   THEN
      UPDATE seg_regole_numerazione_unita
         SET descrizione_unita = new_descrizione_uo
       WHERE id_documento IN (
                SELECT renu.id_documento
                  FROM seg_regole_numerazione_unita renu, documenti docu
                 WHERE renu.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE')
                   AND renu.unita = new_codice_uo);

      UPDATE seg_smistamenti
         SET des_ufficio_smistamento = new_descrizione_uo
       WHERE id_documento IN (
                SELECT smis.id_documento
                  FROM seg_smistamenti smis, documenti docu
                 WHERE smis.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE')
                   AND smis.ufficio_smistamento = new_codice_uo
                   AND smis.smistamento_dal BETWEEN new_dal
                                                AND NVL
                                                       (new_al,
                                                        TO_DATE ('31/12/2999',
                                                                 'dd/mm/yyyy'
                                                                )
                                                       ));

      UPDATE seg_smistamenti
         SET des_ufficio_trasmissione = new_descrizione_uo
       WHERE id_documento IN (
                SELECT smis.id_documento
                  FROM seg_smistamenti smis, documenti docu
                 WHERE smis.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE')
                   AND smis.ufficio_trasmissione = new_codice_uo
                   AND smis.smistamento_dal BETWEEN new_dal
                                                AND NVL
                                                       (new_al,
                                                        TO_DATE ('31/12/2999',
                                                                 'dd/mm/yyyy'
                                                                )
                                                       ));

      UPDATE seg_smistamenti_tipi_documento
         SET des_ufficio_smistamento = new_descrizione_uo
       WHERE id_documento IN (
                SELECT smtd.id_documento
                  FROM seg_smistamenti_tipi_documento smtd, documenti docu
                 WHERE smtd.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE')
                   AND smtd.ufficio_smistamento = new_codice_uo);

      UPDATE seg_unita_classifica
         SET descrizione_unita_smistamento = new_descrizione_uo
       WHERE id_documento IN (
                SELECT uncl.id_documento
                  FROM seg_unita_classifica uncl, documenti docu
                 WHERE uncl.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE')
                   AND uncl.unita = new_codice_uo);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
