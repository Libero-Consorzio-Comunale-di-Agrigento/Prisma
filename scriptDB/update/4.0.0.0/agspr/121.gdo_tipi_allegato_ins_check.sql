--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200924_121.gdo_tipi_allegato_ins_check  failOnError:false

select to_number('x')
  from tab
 where tname = 'GDO_TIPI_DOCUMENTO'
   and tabtype = 'TABLE'
/

INSERT INTO gdo_tipi_documento_table
   SELECT -TIAL.id_documento ID_TIPO_DOCUMENTO,
          enti.id_ente ID_ENTE,
          TIAL.DESCRIZIONE_TIPO_ALLEGATO DESCRIZIONE,
          NULL COMMENTO,
          CAST ('Y' AS CHAR (1)) CONSERVAZIONE_SOSTITUTIVA,
          CAST (NULL AS NUMBER) PROGRESSIVO_CFG_ITER,
          CAST ('N' AS CHAR (1)) TESTO_OBBLIGATORIO,
          CAST (NULL AS NUMBER) ID_TIPOLOGIA_SOGGETTO,
          CAST (
             DECODE (NVL (docu.stato_documento, 'BO'), 'CA', 'N', 'Y') AS CHAR (1))
             VALIDO,
          sd.utente_aggiornamento utente_ins,
          sd.data_aggiornamento data_ins,
          docu.utente_aggiornamento UTENTE_UPD,
          docu.data_aggiornamento DATA_UPD,
          0 VERSION,
          'ALLEGATO' CODICE,
          TIPO_ALLEGATO ACRONIMO
     FROM GDM_SEG_TIPI_ALLEGATO TIAL,
          gdm_documenti docu,
          GDO_ENTI ENTI,
          gdm_stati_documento sd
    WHERE     docu.id_documento = TIAL.id_documento
          AND ENTI.AMMINISTRAZIONE = TIAL.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = TIAL.CODICE_AOO
          AND ENTI.OTTICA = GDM_AG_PARAMETRO.GET_VALORE (
                               'SO_OTTICA_PROT',
                               TIAL.CODICE_AMMINISTRAZIONE,
                               TIAL.CODICE_AOO,
                               '')
          AND TIPO_ALLEGATO IS NOT NULL
          AND sd.id_documento = tial.id_documento
          AND sd.id_stato IN (SELECT MIN (id_stato)
                                FROM gdm_stati_documento
                               WHERE id_documento = tial.id_documento)
          AND NOT EXISTS
                 (SELECT 1
                    FROM gdo_tipi_documento_table
                   WHERE acronimo = tial.tipo_allegato)
/

COMMIT
/


RENAME gdo_tipi_documento TO gdo_tipi_documento_view
/

RENAME gdo_tipi_documento_table TO gdo_tipi_documento
/


CREATE OR REPLACE TRIGGER GDO_TIPI_DOCUMENTO_TIU
   BEFORE DELETE OR INSERT OR UPDATE
   ON GDO_TIPI_DOCUMENTO
   FOR EACH ROW
BEGIN
   IF INSERTING
   THEN
      IF :NEW.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''inserimento di nuovi tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;

   IF UPDATING
   THEN
      IF :OLD.ID_TIPO_DOCUMENTO < 0 AND :OLD.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''aggiornamento dei tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;

   IF DELETING
   THEN
      IF :OLD.ID_TIPO_DOCUMENTO < 0 AND :OLD.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'La cancellazione dei tipi di allegato va effettuata dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;
END;
/
