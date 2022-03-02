--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_RIFE_TIU runOnChange:true stripComments:false

CREATE OR REPLACE TRIGGER AG_RIFE_TIU
   BEFORE INSERT OR UPDATE
   ON RIFERIMENTI
   FOR EACH ROW
DECLARE
   tmpvar                   NUMBER;
   des_fascicolo            VARCHAR2 (3999);
   des_fascicolo_riferito   VARCHAR2 (3999);
/******************************************************************************
   NAME:       AG_RIFE_TIU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/06/2012                    1. Created this trigger.
   1.1        12/09/2016  MM                Inserimento in tab AG_PROTO_MEMO_KEY
   1.2        31/01/2018  MM                Gestione domanda di accesso civico
   1.3        18/10/2018  SC                #30709 Il PROT_PREC non crea piu'
                                            effetti sul registri degli accessi.
******************************************************************************/
BEGIN
   IF INSERTING
   THEN
      BEGIN
         SELECT 1
           INTO tmpvar
           FROM riferimenti, documenti
          WHERE     documenti.id_documento = riferimenti.id_documento
                AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND riferimenti.id_documento_rif = :NEW.id_documento_rif
                AND tipo_relazione IN ('FAX', 'MAIL')
                AND :NEW.tipo_relazione = tipo_relazione
                AND ROWNUM = 1;

         raise_application_error (
            -20998,
               'Relazione attiva di tipo '
            || :NEW.tipo_relazione
            || ' già presente per il documento '
            || :NEW.id_documento_rif);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF :new.tipo_relazione IN ('FAX', 'MAIL')
      THEN
         BEGIN
            INSERT INTO ag_proto_memo_key (id_protocollo, id_memo)
                 VALUES (:new.id_documento, :new.id_documento_rif);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               raise_application_error (
                  -20999,
                     'Esiste gia'' un documento di protocollo corrispondente a '
                  || :NEW.tipo_relazione
                  || ' '
                  || :NEW.id_documento_rif);
         END;
      END IF;
   END IF;

   IF :NEW.tipo_relazione IN ('FAX', 'MAIL')
   THEN
      DECLARE
         d_id_iter       NUMBER;
         d_id_attivita   NUMBER;
      BEGIN
         SELECT key_iter_lettera
           INTO d_id_iter
           FROM spr_lettere_uscita
          WHERE     id_documento = :NEW.id_documento
                AND posizione_flusso = 'DAINVIARE';

         SELECT t.id_attivita
           INTO d_id_attivita
           FROM jwf_model_properties mp,
                jwf_nodi n,
                jwf_iter i,
                jwf_attivita a,
                jwf_task t
          WHERE     n.id_obj = mp.id_obj
                AND i.id_iter = n.id_iter
                AND n.id_versione_model = mp.id_versione_model
                AND n.id_iter_model = mp.id_iter_model
                AND n.id_iter = d_id_iter
                AND a.id_nodo = n.id_nodo
                AND a.id_attivita = t.id_attivita
                AND t.sync_exectype = 'VISIONE'
                AND t.sync_tipo_oggetto = 'DOCUMENTI';

         jwf_utility.p_sblocca_attivita (d_id_attivita);
      -- ret := jwf_utility.chiudi_iter_nocommit (id_iter);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END IF;

   IF (:NEW.tipo_relazione LIKE 'PROT_FAS%')
   THEN
      BEGIN
         SELECT 1,
                   seg_fascicoli.class_cod
                || ' - '
                || seg_fascicoli.fascicolo_anno
                || '/'
                || seg_fascicoli.fascicolo_numero
           INTO tmpvar, des_fascicolo
           FROM riferimenti, seg_fascicoli
          WHERE     riferimenti.id_documento = :NEW.id_documento
                AND tipo_relazione = :NEW.tipo_relazione
                AND :NEW.tipo_relazione = 'PROT_FASPR'
                AND riferimenti.id_documento = seg_fascicoli.id_documento
                AND ROWNUM = 1;

         raise_application_error (
            -20998,
               'Relazione attiva di tipo '
            || :NEW.tipo_relazione
            || ' già presente per il fascicolo '
            || des_fascicolo);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT 1,
                         seg_fascicoli.class_cod
                      || ' - '
                      || seg_fascicoli.fascicolo_anno
                      || '/'
                      || seg_fascicoli.fascicolo_numero
                 INTO tmpvar, des_fascicolo
                 FROM riferimenti, seg_fascicoli
                WHERE     riferimenti.id_documento_rif =
                             :NEW.id_documento_rif
                      AND tipo_relazione = :NEW.tipo_relazione
                      AND :NEW.tipo_relazione = 'PROT_FASPR'
                      AND riferimenti.id_documento_rif =
                             seg_fascicoli.id_documento
                      AND ROWNUM = 1;

               raise_application_error (
                  -20998,
                     'Relazione passiva di tipo '
                  || :NEW.tipo_relazione
                  || ' già presente per il fascicolo '
                  || des_fascicolo);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
      END;

      BEGIN
         SELECT 1,
                   f.class_cod
                || ' - '
                || f.fascicolo_anno
                || '/'
                || f.fascicolo_numero,
                   f_riferito.class_cod
                || ' - '
                || f_riferito.fascicolo_anno
                || '/'
                || f_riferito.fascicolo_numero
           INTO tmpvar, des_fascicolo, des_fascicolo_riferito
           FROM riferimenti, seg_fascicoli f, seg_fascicoli f_riferito
          WHERE     riferimenti.id_documento = :NEW.id_documento_rif
                AND riferimenti.id_documento_rif = :NEW.id_documento
                AND tipo_relazione = :NEW.tipo_relazione
                AND riferimenti.id_documento = f_riferito.id_documento
                AND riferimenti.id_documento_rif = f.id_documento;

         raise_application_error (
            -20997,
               'Relazione di tipo '
            || :NEW.tipo_relazione
            || ' già presente tra i fascicoli '
            || des_fascicolo
            || ' e '
            || des_fascicolo_riferito);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;

   IF     (:NEW.tipo_relazione LIKE 'PROT_ECC')
      AND ag_utilities.verifica_categoria_documento (
             :NEW.id_documento,
             ag_utilities.categoriaprotocollo) = 1
   THEN
      BEGIN
         UPDATE seg_memo_protocollo
            SET stato_memo = 'G'
          WHERE id_documento = :NEW.id_documento_rif;
      END;
   END IF;

   IF     (:NEW.tipo_relazione IN ('PROT_AGG', 'PROT_ANN', 'PROT_CONF'))
      AND ag_utilities.verifica_categoria_documento (
             :NEW.id_documento,
             ag_utilities.categoriaprotocollo) = 1
   THEN
      BEGIN
         UPDATE seg_memo_protocollo
            SET stato_memo = 'G'
          WHERE id_documento = :NEW.id_documento_rif;
      END;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_rife_tiu;
/
