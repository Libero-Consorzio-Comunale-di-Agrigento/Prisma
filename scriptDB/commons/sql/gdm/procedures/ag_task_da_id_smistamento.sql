--liquibase formatted sql
--changeset scaputo:ag_task_da_id_smistamento runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_task_da_id_smistamento (
   a_id_smistamento    NUMBER)
/*DA PROVARE E DA VERIFICARE LE DESCRIZIONI DELLE ATTIVITA E DEI TOOLTIP*/
AS
   RetVal                        VARCHAR2 (32767);
   P_AREA                        VARCHAR2 (32767);
   P_CODICE_MODELLO              VARCHAR2 (32767);
   P_CODICE_RICHIESTA            VARCHAR2 (32767);
   P_AREA_DOCPADRE               VARCHAR2 (32767);
   P_CODICE_MODELLO_DOCPADRE     VARCHAR2 (32767);
   P_CODICE_RICHIESTA_DOCPADRE   VARCHAR2 (32767);
   P_ID_RIFERIMENTO              VARCHAR2 (32767);
   P_CODICE_AMM                  VARCHAR2 (32767);
   P_CODICE_AOO                  VARCHAR2 (32767);
   P_URL_RIF                     VARCHAR2 (32767);
   P_URL_RIF_DESC                VARCHAR2 (32767);
   P_URL_EXEC                    VARCHAR2 (32767);
   P_TOOLTIP_URL_EXEC            VARCHAR2 (32767);
   P_STATO                       VARCHAR2 (32767);
   P_TIPOLOGIA                   VARCHAR2 (32767);
   P_DATIAPPLICATIVI1            VARCHAR2 (32767);
   P_DATIAPPLICATIVI2            VARCHAR2 (32767);
   P_DATIAPPLICATIVI3            VARCHAR2 (32767);
   P_PARAM_INIT_ITER             VARCHAR2 (32767);
   p_idrif                       VARCHAR2 (32767);
   p_ufficio_smistamento         VARCHAR2 (32767);
   p_smistamento_dal             DATE;
   p_assegnazione_dal            DATE;
   p_anno                        NUMBER;
   p_numero                      NUMBER;
   p_oggetto                     VARCHAR2 (32767);
   p_id_doc_padre                NUMBER;
   p_nome_unita                  VARCHAR2 (32767);
   P_STATO_SMISTAMENTO           VARCHAR2 (1);
   P_IDQUERY                     NUMBER;
   p_stato_task                  VARCHAR2 (1);
   p_stringa_query               VARCHAR2 (100);
   p_stringa_doc                 VARCHAR2 (4000);
   p_specifica_modello           VARCHAR2 (100);
   P_SERVER_URL                  VARCHAR2 (1000) := '..';
   P_CONTEXT_PATH                VARCHAR2 (1000);
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   SELECT VALORE
     INTO P_CONTEXT_PATH
     FROM PARAMETRI
    WHERE TIPO_MODELLO = '@ag@' AND CODICE = 'AG_CONTEXT_PATH';

   SELECT area, codice_richiesta
     INTO p_area, p_codice_richiesta
     FROM documenti
    WHERE id_documento = a_id_smistamento;

   DBMS_OUTPUT.put_line ('a_id_smistamento ' || a_id_smistamento);
   DBMS_OUTPUT.put_line ('p_area ' || p_area);
   DBMS_OUTPUT.put_line ('p_codice_richiesta ' || p_codice_richiesta);

   SELECT idrif,
          ufficio_smistamento,
          smistamento_dal,
          assegnazione_dal,
          codice_amministrazione,
          codice_aoo,
          stato_smistamento,
          DECODE (codice_assegnatario, NULL, stato_smistamento, 'A'),
          DECODE (
             stato_smistamento,
             'R', 'da ricevere',
             DECODE (codice_assegnatario, NULL, 'in carico', 'assegnati')),
          DECODE (
             stato_smistamento,
             'R', DECODE (tipo_smistamento,
                          'COMPETENZA', 'Prendi in carico',
                          'Presa visione'),
             'C', DECODE (
                     codice_assegnatario,
                     NULL, DECODE (tipo_smistamento,
                                   'COMPETENZA', 'In carico',
                                   'Presa visione'),
                     'In carico (assegnato)'))
     INTO p_idrif,
          p_ufficio_smistamento,
          p_smistamento_dal,
          p_assegnazione_dal,
          p_codice_amm,
          p_codice_aoo,
          P_STATO_SMISTAMENTO,
          p_stato_task,
          p_stringa_query,
          p_stringa_doc
     FROM seg_smistamenti, DOCUMENTI
    WHERE     seg_smistamenti.id_documento = a_id_smistamento
          AND stato_smistamento IN ('R', 'C')
          AND seg_smistamenti.ID_DOCUMENTO = DOCUMENTI.ID_DOCUMENTO
          AND DOCUMENTI.STATO_DOCUMENTO = 'BO';

   DBMS_OUTPUT.put_line ('p_idrif ' || p_idrif);

   BEGIN
      SELECT anno,
             numero,
             oggetto,
             tipi_documento.nome,
             documenti.area,
             documenti.codice_richiesta,
             documenti.id_documento,
             DECODE (tipi_documento.nome,
                     'M_PROTOCOLLO_INTEROPERABILITA', '- da PEC ',
                     '- ')
        INTO p_anno,
             p_numero,
             p_oggetto,
             P_CODICE_MODELLO_DOCPADRE,
             P_AREA_DOCPADRE,
             P_CODICE_RICHIESTA_DOCPADRE,
             p_id_doc_padre,
             p_specifica_modello
        FROM proto_view, DOCUMENTI, TIPI_DOCUMENTO
       WHERE     idrif = p_idrif
             AND proto_view.ID_DOCUMENTO = DOCUMENTI.ID_DOCUMENTO
             AND DOCUMENTI.STATO_DOCUMENTO = 'BO'
             AND TIPI_DOCUMENTO.ID_TIPODOC = DOCUMENTI.ID_TIPODOC;

      IF     p_specifica_modello LIKE '%PEC%'
         AND p_stringa_doc = 'In carico (assegnato)'
      THEN
         p_stringa_doc := 'In carico';
      END IF;

      p_stringa_doc :=
            p_stringa_doc
         || ' '
         || p_specifica_modello
         || 'PG '
         || p_anno
         || ' / '
         || p_numero
         || ': '
         || p_oggetto;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         SELECT smistabile_view.oggetto,
                tipi_documento.nome,
                documenti.area,
                documenti.codice_richiesta,
                documenti.id_documento,
                DECODE (tipi_documento.nome,
                        'M_PROTOCOLLO_INTEROPERABILITA', '- da PEC ',
                        '- '),
                DECODE (
                   stato_smistamento,
                   'R',    DECODE (tipo_smistamento,
                                   'COMPETENZA', 'Da ricevere ',
                                   'Presa visione ')
                        || DECODE (
                              tipi_documento.nome,
                              'MEMO_PROTOCOLLO',    'mail '
                                                 || smistabile_view.oggetto,
                                 'documento '
                              || smistabile_view.oggetto
                              || ' del '
                              || TO_CHAR (smistabile_view.data, 'dd/mm/yyyy')),
                   'C', DECODE (
                           codice_assegnatario,
                           NULL,    'In carico '
                                 || DECODE (
                                       tipi_documento.nome,
                                       'MEMO_PROTOCOLLO',    'mail '
                                                          || smistabile_view.oggetto,
                                          'documento '
                                       || smistabile_view.oggetto
                                       || ' del '
                                       || TO_CHAR (smistabile_view.data,
                                                   'dd/mm/yyyy')),
                           DECODE (
                              tipi_documento.nome,
                              'MEMO_PROTOCOLLO',    'Mail con oggetto '
                                                 || smistabile_view.OGGETTO
                                                 || ' assegnata',
                                 'Assegnato documento '
                              || smistabile_view.oggetto
                              || ' del '
                              || TO_CHAR (smistabile_view.data, 'dd/mm/yyyy'))))
           INTO p_oggetto,
                P_CODICE_MODELLO_DOCPADRE,
                P_AREA_DOCPADRE,
                P_CODICE_RICHIESTA_DOCPADRE,
                p_id_doc_padre,
                p_specifica_modello,
                p_stringa_doc
           FROM smistabile_view,
                DOCUMENTI,
                TIPI_DOCUMENTO,
                seg_smistamenti
          WHERE     seg_smistamenti.id_documento = a_id_smistamento
                AND smistabile_view.idrif = seg_smistamenti.idrif
                AND smistabile_view.ID_DOCUMENTO = DOCUMENTI.ID_DOCUMENTO
                AND DOCUMENTI.STATO_DOCUMENTO = 'BO'
                AND TIPI_DOCUMENTO.ID_TIPODOC = DOCUMENTI.ID_TIPODOC;
   END;

   DBMS_OUTPUT.put_line ('p_ufficio_smistamento ' || p_ufficio_smistamento);

   BEGIN
      SELECT nome
        INTO p_nome_unita
        FROM seg_unita
       WHERE     unita = p_ufficio_smistamento
             AND p_smistamento_dal BETWEEN dal
                                       AND NVL (al, p_smistamento_dal);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         SELECT nome
           INTO p_nome_unita
           FROM seg_unita u1
          WHERE     unita = p_ufficio_smistamento
                AND NOT EXISTS
                       (SELECT 1
                          FROM seg_unita u2
                         WHERE u2.unita = u1.unita AND u2.dal > u1.dal);
   END;

   DBMS_OUTPUT.put_line ('p_nome_unita ' || p_nome_unita);

   SELECT ID_QUERY
     INTO P_IDQUERY
     FROM QUERY
    WHERE CODICEADS =
             DECODE (P_STATO_SMISTAMENTO,
                     'R', 'SEGRETERIA.PROTOCOLLO#DOCUMENTI_DA_RICEVERE',
                     'SEGRETERIA.PROTOCOLLO#DOCUMENTI_IN_CARICO');

   DBMS_OUTPUT.put_line ('P_STATO_SMISTAMENTO ' || P_STATO_SMISTAMENTO);

   DBMS_OUTPUT.put_line ('P_IDQUERY ' || P_IDQUERY);

   -- P_AREA := 'SEGRETERIA';
   P_CODICE_MODELLO := 'M_SMISTAMENTO';
   --  P_CODICE_RICHIESTA := 'DMSERVER20893751';
   --  P_AREA_DOCPADRE := 'SEGRETERIA.PROTOCOLLO';
   -- P_CODICE_MODELLO_DOCPADRE := 'M_PROTOCOLLO';
   --  P_CODICE_RICHIESTA_DOCPADRE := 'SEGRETERIA.PROTOCOLLO-4234172-A';
   P_ID_RIFERIMENTO := TO_CHAR (a_id_smistamento);
   --  P_CODICE_AMM := 'C_D612';
   --  P_CODICE_AOO := 'AOO_CFI';
   P_URL_RIF :=
         '../jdms/common/WorkArea.do?WRKSP=-8&idQuery='
      || P_IDQUERY
      || '&PAR_AGSPR_UNITA='
      || p_ufficio_smistamento
      || '&PAR_AGSPR_TIPO_RICERCA=M_DA_RICEVERE';
   P_URL_RIF_DESC :=
         'Visualizza elenco documenti '
      || p_stringa_query
      || ' per '
      || p_nome_unita;
   P_TOOLTIP_URL_EXEC := p_stringa_doc;

   SELECT AG_UTILITIES.GET_URL_OGGETTO (
             P_SERVER_URL,
             P_CONTEXT_PATH,
             p_id_doc_padre,
             'D',
             '',
             '',
             '',
             DECODE (P_STATO_SMISTAMENTO, 'R', 'R', 'C'),
             NULL,
             NULL,
             '5',
             'N',
             'N',
             'S')
     INTO P_URL_EXEC
     FROM DUAL;

   /*P_URL_EXEC :=
          '../agspr/documento.html#idDoc='
       || p_id_doc_padre
       || '&rw=R&cm='
       || P_CODICE_MODELLO_DOCPADRE
       || '&area=SEGRETERIA.PROTOCOLLO&cr='
       || P_CODICE_RICHIESTA_DOCPADRE
       || '&idCartProveninez=&idQueryProveninez=&Provenienza=D&stato=BO&MVPG=ServletModulisticaDocumento&GDC_Link_NO=../common/ClosePageAndRefresh.do%3FidQueryProveninez%3D';*/

   P_STATO := p_stato_task;
   P_TIPOLOGIA := 'ATTIVA_ITER_DOCUMENTALE';
   P_DATIAPPLICATIVI1 := p_anno || '/' || LPAD (p_numero, 7, '0');
   P_DATIAPPLICATIVI2 :=
      TO_CHAR (NVL (p_assegnazione_dal, p_smistamento_dal),
               'dd/mm/yyyy hh24:mi:ss');
   P_DATIAPPLICATIVI3 := NULL;
   P_PARAM_INIT_ITER := p_nome_unita;

   RetVal :=
      AG_SMISTAMENTO.CREA_TASK_ESTERNI (P_AREA,
                                        P_CODICE_MODELLO,
                                        P_CODICE_RICHIESTA,
                                        P_AREA_DOCPADRE,
                                        P_CODICE_MODELLO_DOCPADRE,
                                        P_CODICE_RICHIESTA_DOCPADRE,
                                        P_ID_RIFERIMENTO,
                                        P_CODICE_AMM,
                                        P_CODICE_AOO,
                                        P_URL_RIF,
                                        P_URL_RIF_DESC,
                                        P_URL_EXEC,
                                        P_TOOLTIP_URL_EXEC,
                                        P_STATO,
                                        P_TIPOLOGIA,
                                        P_DATIAPPLICATIVI1,
                                        P_DATIAPPLICATIVI2,
                                        P_DATIAPPLICATIVI3,
                                        P_PARAM_INIT_ITER);
   DBMS_OUTPUT.put_line ('RetVal ' || RetVal);
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      RAISE;
END;
/
