--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SOPR_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SOPR_TIU
   BEFORE UPDATE OR INSERT
   ON SEG_SOGGETTI_PROTOCOLLO
   FOR EACH ROW
DECLARE
   a_messaggio       VARCHAR2 (32000);
   a_istruzione      VARCHAR2 (32000);
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            VARCHAR2 (200);
BEGIN
   IF     :new.email IS NOT NULL
      AND NVL (:new.email, '***') != NVL (:old.email, '***')
   THEN
      :new.email := UPPER (TRIM (:new.email));
   END IF;

   IF     (   (    :new.cognome_per_segnatura IS NOT NULL
               AND :new.cognome IS NULL)
           OR (    :new.denominazione_per_segnatura IS NOT NULL
               AND :new.cognome_per_segnatura IS NULL
               AND :new.cognome IS NULL))
      AND :new.cod_amm IS NULL
   THEN
      :new.cognome :=
         NVL (:new.cognome_per_segnatura, :new.denominazione_per_segnatura);
      :new.cognome_per_segnatura :=
         NVL (:new.cognome_per_segnatura, :new.denominazione_per_segnatura);
   END IF;

   IF LENGTH (:new.cognome_per_segnatura) > 240
   THEN
      :new.cognome_per_segnatura :=
         SUBSTR (:new.cognome_per_segnatura, 1, 240);
   END IF;

   IF (:new.nome_per_segnatura IS NOT NULL AND :new.nome IS NULL)
   THEN
      :new.nome := :new.nome_per_segnatura;
   END IF;

   IF (    :new.indirizzo_per_segnatura IS NOT NULL
       AND :new.indirizzo_res IS NULL)
   THEN
      :new.indirizzo_res := :new.indirizzo_per_segnatura;
   END IF;

   IF (:new.cap_per_segnatura IS NOT NULL AND :new.cap_res IS NULL)
   THEN
      :new.cap_res := :new.cap_per_segnatura;
   END IF;

   IF (:new.comune_per_segnatura IS NOT NULL AND :new.comune_res IS NULL)
   THEN
      :new.comune_res := :new.comune_per_segnatura;
   END IF;

   IF (    :new.provincia_per_segnatura IS NOT NULL
       AND :new.provincia_res IS NULL)
   THEN
      :new.provincia_res := :new.provincia_per_segnatura;
   END IF;

   IF (:new.cod_amm = 'REGIONETOSCANA')
   THEN
      :new.cod_amm := 'RegioneToscana';
   END IF;

   :new.conoscenza := NVL (:new.conoscenza, 'N');

   IF NVL (INSTR (:new.insegna_Extra, '.', -1), 0) = 0
   THEN
      :new.insegna_Extra := :new.insegna_extra || '.';
   END IF;

   IF (:new.denominazione_per_segnatura IS NULL)
   THEN
      IF :new.descrizione_amm IS NOT NULL
      THEN
         :new.denominazione_per_segnatura := :new.descrizione_amm;

         IF :new.descrizione_aoo IS NOT NULL
         THEN
            :new.denominazione_per_segnatura :=
                  :new.denominazione_per_segnatura
               || ':AOO:'
               || :new.descrizione_aoo;
         END IF;


         IF :new.descrizione_uo IS NOT NULL
         THEN
            :new.denominazione_per_segnatura :=
                  :new.denominazione_per_segnatura
               || ':UO:'
               || :new.descrizione_uo;
         END IF;
      ELSE
         IF :new.cognome_per_segnatura IS NOT NULL
         THEN
            :new.denominazione_per_segnatura := :new.cognome_per_segnatura;

            IF :new.nome_per_segnatura IS NOT NULL
            THEN
               :new.denominazione_per_segnatura :=
                     :new.denominazione_per_segnatura
                  || ' '
                  || :new.nome_per_segnatura;
            END IF;
         END IF;
      END IF;
   ELSE
      IF :new.nome_per_segnatura IS NOT NULL
      THEN
         :new.denominazione_per_segnatura :=
            :new.cognome_per_segnatura || ' ' || :new.nome_per_segnatura;
      END IF;
   END IF;

   IF :old.idrif IS NOT NULL AND :old.idrif <> NVL (:new.idrif, ' ')
   THEN
      raise_application_error (
         -20999,
         'Impossibile modificare il campo IDRIF del soggetto.');
   END IF;

   DECLARE
      d_modalita   VARCHAR2 (10);
   BEGIN
      IF (:NEW.tipo_rapporto IS NULL)
      THEN
         BEGIN
            SELECT NVL (modalita, 'INT')
              INTO d_modalita
              FROM proto_view
             WHERE idrif = :NEW.idrif;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_modalita := 'INT';
         END;

         IF (d_modalita = 'PAR')
         THEN
            :NEW.tipo_rapporto := 'DEST';
         ELSE
            :NEW.tipo_rapporto := 'MITT';
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;

   --raise_application_error(-20999, :new.idrif);
   --sembra che idrif venga settato dopo la insert
   IF :new.TIPO_RAPPORTO <> 'DUMMY'
   THEN
      IF    INSERTING
         OR (NVL (:new.conoscenza, 'N') <> NVL (:old.conoscenza, 'N'))
         OR (:old.idrif IS NULL AND :new.idrif IS NOT NULL)
         OR (NVL (:new.denominazione_per_segnatura, ' ') <>
                NVL (:old.denominazione_per_segnatura, ' '))
         OR (NVL (:new.cognome_per_segnatura, ' ') <>
                NVL (:old.cognome_per_segnatura, ' '))
         OR (NVL (:new.nome_per_segnatura, ' ') <>
                NVL (:old.nome_per_segnatura, ' '))
         OR (NVL (:new.descrizione_amm, ' ') <>
                NVL (:old.descrizione_amm, ' '))
         OR (NVL (:new.descrizione_aoo, ' ') <>
                NVL (:old.descrizione_aoo, ' '))
      THEN
         BEGIN
            a_messaggio :=
               'Errore in aggiornamento dei dettagli in Scrivania.';

            a_istruzione :=
                  'Begin '
               || '   AG_UTILITIES_CRUSCOTTO.UPD_DETT_TASK_EST('
               || ' p_idrif => '''
               || :new.idrif
               || '''); '
               || 'end; ';
            integritypackage.set_postevent (a_istruzione, a_messaggio);
         END;
      END IF;
   END IF;

   BEGIN
      IF integritypackage.getnestlevel = 0
      THEN
         integritypackage.nextnestlevel;

         BEGIN
            /* NONE */
            NULL;
         END;

         integritypackage.previousnestlevel;
      END IF;

      integritypackage.nextnestlevel;

      BEGIN
         /* NONE */
         NULL;
      END;

      integritypackage.previousnestlevel;
   END;
EXCEPTION
   WHEN integrity_error
   THEN
      integritypackage.initnestlevel;
      raise_application_error (errno, errmsg);
   WHEN OTHERS
   THEN
      integritypackage.initnestlevel;
      RAISE;
END;
/
