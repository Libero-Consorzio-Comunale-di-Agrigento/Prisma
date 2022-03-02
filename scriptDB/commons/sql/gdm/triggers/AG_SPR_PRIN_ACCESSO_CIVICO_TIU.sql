--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_PRIN_ACCESSO_CIVICO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SPR_PRIN_ACCESSO_CIVICO_TIU
   BEFORE INSERT OR UPDATE
   ON SPR_PROTOCOLLI_INTERO
   FOR EACH ROW
DECLARE
   d_utente_agg   VARCHAR2 (100);
BEGIN
   IF NVL (:new.KEY_ITER_PROTOCOLLO, 0) <> -1
   THEN
      BEGIN
         SELECT utente_aggiornamento
           INTO d_utente_agg
           FROM documenti
          WHERE id_documento = :new.id_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_utente_agg := 'RPI';
      END;

      IF     :old.tipo_documento IS NOT NULL
         AND NVL (:new.tipo_documento, ' ') <> :old.tipo_documento
         AND AG_TIPI_DOCUMENTO_UTILITY.IS_DOMANDA_ACCESSO_CIVICO (
                :old.tipo_documento) > 0
         AND AG_TIPI_DOCUMENTO_UTILITY.IS_DOMANDA_ACCESSO_CIVICO (
                :new.tipo_documento) = 0
      THEN
         -- del
         agspr_proto_dati_accesso_pkg.del_domanda (:old.id_documento);
      END IF;

      /*
           GESTIONE DOMANDA DI ACCESSO CIVICO
      */
      IF     :new.tipo_documento IS NOT NULL
         AND AG_TIPI_DOCUMENTO_UTILITY.IS_DOMANDA_ACCESSO_CIVICO (
                :new.tipo_documento) > 0
      THEN
         -- ins
         DECLARE
            d_id              NUMBER;
            d_id_domanda      NUMBER;
            d_anno            NUMBER := :new.anno;
            d_numero          NUMBER := :new.numero;
            d_tipo_registro   VARCHAR2 (255) := :new.tipo_registro;
         BEGIN
            IF    :new.anno IS NULL
               OR :new.numero IS NULL
               OR :new.tipo_registro IS NULL
            THEN
               d_anno := NULL;
               d_numero := NULL;
               d_tipo_registro := NULL;
            END IF;

            d_id_domanda :=
               AGSPR_AGP_PROTOCOLLI_PKG.ins_da_esterno (
                  d_utente_agg,
                  :new.id_documento,
                  d_anno,
                  d_numero,
                  d_tipo_registro,
                  :new.data,
                  :new.oggetto,
                  :new.riservato,
                  :new.codice_amministrazione,
                  :new.codice_aoo,
                  'M_PROTOCOLLO_INTEROPERABILITA');
            d_id :=
               agspr_proto_dati_accesso_pkg.ins_domanda (d_utente_agg,
                                                         :new.id_documento);
         END;
      END IF;


      /*
           AGGIORNAMENTO DATI SE PRESENTI IN AGSPR
      */

      IF    NVL (:new.anno, -1) <> NVL (:old.anno, -1)
         OR NVL (:new.numero, -1) <> NVL (:old.numero, -1)
         OR NVL (:new.tipo_registro, ' ') <> NVL (:old.tipo_registro, ' ')
         OR NVL (:new.data, TO_DATE ('01/01/1950', 'dd/mm/yyyy')) <>
               NVL (:old.data, TO_DATE ('01/01/1950', 'dd/mm/yyyy'))
         OR NVL (:new.oggetto, ' ') <> NVL (:old.oggetto, ' ')
         OR NVL (:new.riservato, ' ') <> NVL (:old.riservato, ' ')
      THEN
         AGSPR_AGP_PROTOCOLLI_PKG.upd_da_esterno (d_utente_agg,
                                                  :new.id_documento,
                                                  :new.anno,
                                                  :new.numero,
                                                  :new.tipo_registro,
                                                  :new.data,
                                                  :new.oggetto,
                                                  :new.riservato);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
