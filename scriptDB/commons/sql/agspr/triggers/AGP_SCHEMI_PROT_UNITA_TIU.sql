--liquibase formatted sql
--changeset mmalferrari:AGSPR_TRIGGER_AGP_SCHEMI_PROT_UNITA_TIU runOnChange:true stripComments:false

CREATE OR REPLACE TRIGGER agp_schemi_prot_unita_tiu
   BEFORE DELETE OR INSERT OR UPDATE
   ON agp_schemi_prot_unita
   FOR EACH ROW
DECLARE
   d_unita        VARCHAR2 (255);
   d_tipo_doc     VARCHAR2 (255);
   d_codice_amm   VARCHAR2 (100);
   d_codice_aoo   VARCHAR2 (100);
BEGIN
   IF INSERTING
   THEN
      SELECT amministrazione, aoo
        INTO d_codice_amm, d_codice_aoo
        FROM gdo_enti
       WHERE id_ente = :new.id_ente;


      IF NVL (:new.id_schema_protocollo, 0) = 0
      THEN
         d_tipo_doc := NULL;
      ELSE
         BEGIN
            SELECT codice
              INTO d_tipo_doc
              FROM agp_schemi_protocollo
             WHERE id_schema_protocollo = :new.id_schema_protocollo;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF NVL (:new.unita_progr, 0) = 0
      THEN
         d_unita := NULL;
      ELSE
         BEGIN
            SELECT codice
              INTO d_unita
              FROM so4_v_unita_organizzative_pubb
             WHERE     progr = :new.unita_progr
                   AND ottica = :new.unita_ottica
                   AND dal = :new.unita_dal;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      DECLARE
         retval   NUMBER;
      BEGIN
         retval :=
            gdm_tipi_documento_utility.crea_unita_competente (
               d_tipo_doc,
               d_unita,
               :new.unita_progr,
               d_codice_amm,
               d_codice_aoo,
               :new.utente_ins);
         :new.id_documento_esterno := retval;
      END;
   END IF;

   IF UPDATING
   THEN
      raise_application_error (
         -20999,
         'Aggiornamento non permesso. Eliminare il record e reinserirlo.');
   END IF;

   IF DELETING
   THEN
      DECLARE
         ret   NUMBER;
      BEGIN
         ret :=
            gdm_profilo.cancella (:old.id_documento_esterno, :old.utente_upd);
      END;
   END IF;
END;
/
