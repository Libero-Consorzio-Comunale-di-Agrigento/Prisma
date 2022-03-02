--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_LINKS_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_LINKS_TIU
   BEFORE INSERT OR UPDATE
   ON LINKS
   FOR EACH ROW
DECLARE
   dep_class_cod          VARCHAR2 (32000);
   dep_fascicolo_anno     NUMBER;
   dep_fascicolo_numero   VARCHAR2 (32000);
BEGIN
   IF    INSERTING
      OR NVL (:NEW.id_cartella, 0) != NVL (:OLD.id_cartella, 0)
      OR NVL (:NEW.id_oggetto, 0) != NVL (:OLD.id_oggetto, 0)
   THEN
      BEGIN                                            -- CHECK DATA INTEGRITY
         SELECT fasc.class_cod, fasc.fascicolo_anno, fasc.fascicolo_numero
           INTO dep_class_cod, dep_fascicolo_anno, dep_fascicolo_numero
           FROM cartelle cfasc,
                seg_fascicoli fasc,
                seg_classificazioni clas,
                cartelle cclas,
                documenti dclas
          WHERE     cfasc.id_cartella = :NEW.id_cartella
                AND fasc.id_documento = cfasc.id_documento_profilo
                AND fasc.class_cod = clas.class_cod
                AND fasc.class_dal = clas.class_dal
                AND dclas.id_documento = cclas.id_documento_profilo
                AND NVL (cclas.stato, 'BO') != 'CA'
                AND clas.id_documento = dclas.id_documento
                AND dclas.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND NVL (clas.ins_doc_in_fasc_con_sub, 'Y') = 'N'
                AND INSTR (fasc.fascicolo_numero, '.') = 0
                AND :NEW.tipo_oggetto = 'D'
                AND EXISTS
                       (SELECT 1
                          FROM seg_fascicoli fsub,
                               cartelle csub,
                               documenti dsub
                         WHERE     fsub.class_cod = fasc.class_cod
                               AND fsub.class_dal = fasc.class_dal
                               AND fsub.fascicolo_anno = fasc.fascicolo_anno
                               AND INSTR (fsub.fascicolo_numero, '.') > 0
                               AND INSTR (fsub.fascicolo_numero,
                                          fasc.fascicolo_numero || '.') = 1
                               AND fsub.id_documento = dsub.id_documento
                               AND dsub.id_documento =
                                      csub.id_documento_profilo
                               AND NVL (csub.stato, 'BO') != 'CA'
                               AND dsub.stato_documento NOT IN ('CA',
                                                                'RE',
                                                                'PB'));

         raise_application_error (
            -20900,
               'Non è consentito inserire documenti nel fascicolo '
            || dep_class_cod
            || ' - '
            || dep_fascicolo_anno
            || '/'
            || dep_fascicolo_numero
            || '. Utilizzare i sottofascicoli.');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      DECLARE
         dep_consenti   NUMBER;
      BEGIN                                            -- CHECK DATA INTEGRITY
         SELECT fasc.class_cod,
                fasc.fascicolo_anno,
                fasc.fascicolo_numero,
                ag_utilities.verifica_privilegio_utente (
                   '',
                   'MFARC',
                   :NEW.utente_aggiornamento,
                   TRUNC (SYSDATE))
           INTO dep_class_cod,
                dep_fascicolo_anno,
                dep_fascicolo_numero,
                dep_consenti
           FROM cartelle cfasc, seg_fascicoli fasc
          WHERE     cfasc.id_cartella = :NEW.id_cartella
                AND fasc.id_documento = cfasc.id_documento_profilo
                AND :NEW.tipo_oggetto = 'D'
                AND fasc.stato_scarto != '**';

         IF dep_consenti = 0
         THEN
            raise_application_error (
               -20901,
                  'Non è consentito inserire documenti nel fascicolo '
               || dep_class_cod
               || ' - '
               || dep_fascicolo_anno
               || '/'
               || dep_fascicolo_numero
               || ' in quanto in fase di scarto.');
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      -- se sto inserendo un doc in un fascicolo
      -- devo notificarlo agli utenti che gestiscono il fascicolo
      DECLARE
         d_is_doc_in_fasc   NUMBER := 0;
         a_messaggio        VARCHAR2 (32000);
         a_istruzione       VARCHAR2 (32000);
      BEGIN
         SELECT 1
           INTO d_is_doc_in_fasc
           FROM seg_fascicoli, cartelle
          WHERE     cartelle.id_cartella = :NEW.id_cartella
                AND cartelle.id_documento_profilo =
                       seg_fascicoli.id_documento
                AND :NEW.tipo_oggetto = 'D';

         a_messaggio :=
               'FALLITA CREAZIONE ATTIVITA'' DI NOTIFICA DI INSERIMENTO DOCUMENTO IN FASCICOLO (ID_CARTELLA='
            || :NEW.id_cartella
            || ')';
         a_istruzione :=
               'Begin '
            || 'AG_UTILITIES_CRUSCOTTO.notifica_ins_doc_fasc ('''
            || :NEW.id_oggetto
            || ''','''
            || :NEW.id_cartella
            || '''); '
            || 'end; ';
         integritypackage.set_postevent (a_istruzione, a_messaggio);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;
END;
/
