--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_GEST_SMIST_MANUALI_SCADUTI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE     ag_gest_smist_manuali_scaduti (
   p_data_riferimento   DATE
)
IS
   c_defammaoo   afc.t_ref_cursor;
   p_aoo         VARCHAR2 (100);
   p_amm         VARCHAR2 (100);
   p_datanotifica VARCHAR2 (100);
   p_indiceaoo   NUMBER;
   retval        NUMBER;

   CURSOR c_listasmistamenti (
      r_timeout     NUMBER,
      c_timeout     NUMBER,
      p_indiceaoo   NUMBER
   )
   IS
      SELECT seg_smistamenti.id_documento idsmistamento,
             spr_protocolli.id_documento idprotocollo, key_iter_smistamento,
             ufficio_trasmissione, documenti.area, tipi_documento.nome cm,
             documenti.codice_richiesta, seg_smistamenti.stato_smistamento
        FROM seg_smistamenti,
             documenti,
             smistabile_view spr_protocolli,
             tipi_documento
       WHERE stato_smistamento IN ('C', 'R')
         AND key_iter_smistamento = -1
         AND tipo_smistamento IN ('COMPETENZA', 'CONOSCENZA')
         AND documenti.id_documento = seg_smistamenti.id_documento
         AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA', 'RE')
         AND DECODE (stato_smistamento,
                     'R', p_data_riferimento
                      - (TRUNC (smistamento_dal) + r_timeout),
                     'C', p_data_riferimento
                      - (TRUNC (presa_in_carico_dal) + c_timeout)
                    ) >= 0
         AND spr_protocolli.idrif = seg_smistamenti.idrif
         AND 0 =
                (SELECT COUNT (*)
                   FROM ag_smistamenti_scaduti
                  WHERE ag_smistamenti_scaduti.id_smistamento =
                                                  seg_smistamenti.id_documento
                    AND indice_aoo = p_indiceaoo)
         AND documenti.id_tipodoc = tipi_documento.id_tipodoc
      UNION
      SELECT seg_smistamenti.id_documento idsmistamento,
             seg_fascicoli.id_documento idfascicolo, key_iter_smistamento,
             ufficio_trasmissione, documenti.area, tipi_documento.nome cm,
             documenti.codice_richiesta, seg_smistamenti.stato_smistamento
        FROM seg_smistamenti, documenti, seg_fascicoli, tipi_documento
       WHERE stato_smistamento IN ('C', 'R')
         AND key_iter_smistamento = -1
         AND tipo_smistamento IN ('COMPETENZA', 'CONOSCENZA')
         AND documenti.id_documento = seg_smistamenti.id_documento
         AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA', 'RE')
         AND DECODE (stato_smistamento,
                     'R', p_data_riferimento
                      - (TRUNC (smistamento_dal) + r_timeout),
                     'C', p_data_riferimento
                      - (TRUNC (presa_in_carico_dal) + c_timeout)
                    ) >= 0
         AND seg_fascicoli.idrif = seg_smistamenti.idrif
         AND 0 =
                (SELECT COUNT (*)
                   FROM ag_smistamenti_scaduti
                  WHERE ag_smistamenti_scaduti.id_smistamento =
                                                  seg_smistamenti.id_documento
                    AND indice_aoo = p_indiceaoo)
         AND documenti.id_tipodoc = tipi_documento.id_tipodoc;
BEGIN
   --dbms_output.put_line('aaa');
   c_defammaoo := ag_utilities.get_default_ammaoo ();

   IF c_defammaoo%ISOPEN
   THEN
      LOOP
         FETCH c_defammaoo
          INTO p_amm, p_aoo;

         EXIT WHEN c_defammaoo%NOTFOUND;
      END LOOP;
   END IF;

   IF NVL (p_amm, '') = '' OR NVL (p_aoo, '') = ''
   THEN
      raise_application_error
                     (-20999,
                      'Non riesco a valorizzare codAmm e/o codAoo di default'
                     );
   END IF;

   SELECT TO_CHAR (SYSDATE, 'DD/MM/YYYY')
     INTO p_datanotifica
     FROM DUAL;

   p_indiceaoo := ag_utilities.get_indice_aoo (p_amm, p_aoo);

   FOR clistasmistamenti IN
      c_listasmistamenti (ag_parametro.get_valore ('SMIST_R_TIMEOUT_',
                                                   p_amm,
                                                   p_aoo,
                                                   'N'
                                                  ),
                          ag_parametro.get_valore ('SMIST_C_TIMEOUT_',
                                                   p_amm,
                                                   p_aoo,
                                                   'N'
                                                  ),
                          p_indiceaoo
                         )
   LOOP
      --dbms_output.put_line('idSmistamento-->'||clistaSmistamenti.idSmistamento);
      BEGIN
         BEGIN
            --Storicizzo lo smistamento
            UPDATE seg_smistamenti
               SET stato_smistamento =
                                DECODE (stato_smistamento,
                                        'R', 'F',
                                        'C', 'E'
                                       ),
                   note =
                         DECODE (NVL (note, ' '), ' ', '', note || ' ')
                      || 'Smistamento sbloccato automaticamente per raggiunti termini di scadenza in data '
                      || p_datanotifica
             WHERE id_documento = clistasmistamenti.idsmistamento;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                        (-20999,
                            'Errore in storicizzazione smistamento con id = '
                         || clistasmistamenti.idsmistamento
                         || '.Errore: '
                         || SQLERRM
                        );
         END;

         BEGIN
            jwf_utility.p_elimina_task_esterno
                                            (NULL,
                                             clistasmistamenti.idsmistamento,
                                             NULL
                                            );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20999,
                      'Errore chiusura TASK ITER SCRIVANIA relativi allo smistamento con id = '
                   || clistasmistamenti.idsmistamento
                   || '.Errore: '
                   || SQLERRM
                  );
         END;

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            ag_utilities_protocollo.crea_log (SQLERRM);
      END;
   END LOOP;
END;
/
