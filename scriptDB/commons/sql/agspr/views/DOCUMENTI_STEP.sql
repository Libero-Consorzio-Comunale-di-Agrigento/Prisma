--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_DOCUMENTI_STEP runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW DOCUMENTI_STEP
(
   TIPO_OGGETTO,
   ID_DOCUMENTO,
   ID_PROTOCOLLO,
   ID_TIPOLOGIA,
   TITOLO_TIPOLOGIA,
   DESCRIZIONE_TIPOLOGIA,
   ANNO,
   NUMERO,
   OGGETTO,
   STATO,
   STATO_FIRMA,
   STATO_CONSERVAZIONE,
   ID_STEP,
   STEP_UTENTE,
   STEP_UNITA_PROGR,
   STEP_UNITA_DAL,
   STEP_UNITA_OTTICA,
   STEP_RUOLO,
   STEP_NOME,
   STEP_DESCRIZIONE,
   STEP_TITOLO,
   UNITA_PROGR,
   UNITA_OTTICA,
   UNITA_DAL,
   RISERVATO,
   TIPO_REGISTRO,
   LAST_UPDATED,
   ID_ENTE,
   ID_DOCUMENTO_MSG_RICEVUTO
)
AS
   SELECT DISTINCT
          tipo_protocollo.categoria,
          doc.id_documento,
          prot.id_documento,
          tipo.id_tipo_documento,
          tipo.descrizione,
          tipo.commento,
          prot.anno,
          prot.numero,
          prot.oggetto,
          doc.stato,
          doc.stato_firma,
          doc.stato_conservazione,
          step.id_engine_step,
          a_step.utente,
          a_step.unita_progr,
          a_step.unita_dal,
          a_step.unita_ottica,
          a_step.ruolo,
          cfg_step.nome,
          cfg_step.descrizione,
          cfg_step.titolo,
          soggettiUoProtocollante.unita_progr,
          soggettiUoProtocollante.unita_ottica,
          soggettiUoProtocollante.unita_dal,
          doc.riservato,
          prot.tipo_registro,
          doc.data_upd,
          doc.id_ente,
          (SELECT MAX (GDO_DOCUMENTI_COLLEGATI.id_documento)
             FROM GDO_DOCUMENTI_COLLEGATI, GDO_TIPI_COLLEGAMENTO
            WHERE     id_collegato = doc.id_documento
                  AND GDO_DOCUMENTI_COLLEGATI.ID_TIPO_COLLEGAMENTO =
                         GDO_TIPI_COLLEGAMENTO.ID_TIPO_COLLEGAMENTO
                  AND GDO_TIPI_COLLEGAMENTO.TIPO_COLLEGAMENTO = 'MAIL')
             id_documento_msg_ricevuto
     FROM agp_protocolli prot,
          gdo_documenti doc,
          GDO_TIPI_DOCUMENTO TIDO,
          wkf_engine_step step,
          wkf_engine_step_attori a_step,
          wkf_cfg_step cfg_step,
          gdo_tipi_documento tipo,
          agp_tipi_protocollo tipo_protocollo,
          wkf_engine_iter iter,
          WKF_CFG_ITER CFG_ITER,
          (SELECT unita_progr,
                  unita_ottica,
                  unita_dal,
                  id_documento
             FROM gdo_documenti_soggetti
            WHERE tipo_soggetto = 'UO_PROTOCOLLANTE') soggettiUoProtocollante
    WHERE     doc.id_engine_iter = iter.id_engine_iter
          AND step.id_engine_step = iter.id_step_corrente
          AND doc.id_documento = prot.id_documento
          AND cfg_step.id_cfg_step = step.id_cfg_step
          AND step.id_engine_step = a_step.id_engine_step(+)
          -- AND iter.data_fine IS NULL
          -- AND step.data_fine IS NULL
          AND doc.valido = 'Y'
          AND TIPO.ID_TIPO_DOCUMENTO = tipo_protocollo.ID_TIPO_PROTOCOLLO
          AND TIDO.PROGRESSIVO_CFG_ITER = CFG_ITER.PROGRESSIVO
          AND CFG_ITER.ID_CFG_ITER = ITER.ID_CFG_ITER
          AND ITER.ID_ENGINE_ITER = DOC.ID_ENGINE_ITER
          AND DOC.TIPO_OGGETTO = 'PROTOCOLLO'
          AND tipo.id_tipo_documento = PROT.ID_TIPO_PROTOCOLLO
          AND doc.id_documento = soggettiUoProtocollante.id_documento(+)
/
