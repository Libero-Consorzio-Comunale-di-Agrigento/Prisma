--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_PROTOCOLLI_ANN_AU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SPR_PROTOCOLLI_ANN_AU
   AFTER UPDATE
   ON SPR_PROTOCOLLI
   FOR EACH ROW
   DECLARE
   d_is_provvedimento_modulistica   NUMBER := 1;
BEGIN
   /*
      Gestione annullamento con provvedimento in zk
      che annulla protocolli flex
   */
   IF     :new.data_accettazione_ann IS NOT NULL
      AND :old.data_accettazione_ann IS NULL
   THEN
      BEGIN
         SELECT 0
           INTO d_is_provvedimento_modulistica
           FROM jdms_link
          WHERE     id_tipodoc IN (SELECT id_tipodoc
                                     FROM tipi_documento
                                    WHERE nome = 'M_PROVVEDIMENTO')
                AND INSTR (url, '/Protocollo/standalone.zul') > 0
                AND tag = 5;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_is_provvedimento_modulistica := 1;
      END;


      IF     AG_PARAMETRO.GET_VALORE ('ANN_DIRETTO',
                                      :new.codice_amministrazione,
                                      :new.codice_aoo,
                                      'Y') <> 'Y'
         AND d_is_provvedimento_modulistica = 0
      THEN
         agspr_agp_protocolli_pkg.accetta_richiesta_annullamento (
            :new.id_documento,
            :new.data_accettazione_ann);
      END IF;
   END IF;
END;
/
