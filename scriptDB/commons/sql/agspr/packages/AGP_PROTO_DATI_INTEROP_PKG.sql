--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_PROTO_DATI_INTEROP_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_PROTO_DATI_INTEROP_PKG
IS
   /******************************************************************************
    NOME:        AGP_PROTO_DATI_INTEROP_PKG
    DESCRIZIONE: Gestione tabella AGP_PROTOCOLLI_DATI_INTEROP.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    30/11/2018    mmalferrari    Prima emissione.
    01    27/08/2020    mmalferrari    eliminata set_id_msg_conferma_ricezione
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.01';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE set_inviata_conferma_ricezione (
      p_id_documento_esterno    NUMBER,
      p_inviata                 VARCHAR2,
      p_utente                  VARCHAR2);

   PROCEDURE set_ric_accettazione_conferma (
      p_id_documento_esterno    NUMBER,
      p_ricevuta                VARCHAR2,
      p_utente                  VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY AGP_PROTO_DATI_INTEROP_PKG
IS
   /******************************************************************************
    NOME        AGP_PROTO_DATI_INTEROP_PKG
    DESCRIZIONE Gestione tabella AGP_PROTOCOLLI_DATI_INTEROP.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   30/11/2018    mmalferrari   Prima emissione.
    001   27/08/2020    mmalferrari    eliminata set_id_msg_conferma_ricezione
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '001';

   --------------------------------------------------------------------------------

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  p_ versione compatibilità del Package.
                 Secondo numerop_ revisione del Package specification.
                 Terzo numero  p_ revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------

   PROCEDURE set_inviata_conferma_ricezione (
      p_id_documento_esterno    NUMBER,
      p_inviata                 VARCHAR2,
      p_utente                  VARCHAR2)
   IS
      d_id   NUMBER;
   BEGIN
      d_id := AGP_PROTOCOLLI_PKG.get_id_documento (p_id_documento_esterno);

      UPDATE agp_protocolli_dati_interop
         SET inviata_conferma = p_inviata,
             utente_upd = p_utente,
             data_upd = SYSDATE
       WHERE id_protocollo_dati_interop IN (SELECT id_protocollo_dati_interop
                                              FROM agp_protocolli
                                             WHERE id_documento = d_id);
   END;

   --------------------------------------------------------------------------------

   PROCEDURE set_ric_accettazione_conferma (
      p_id_documento_esterno    NUMBER,
      p_ricevuta                VARCHAR2,
      p_utente                  VARCHAR2)
   IS
      d_id   NUMBER;
   BEGIN
      d_id := AGP_PROTOCOLLI_PKG.get_id_documento (p_id_documento_esterno);

      UPDATE agp_protocolli_dati_interop
         SET ricevuta_accettazione_conferma = p_ricevuta,
             utente_upd = p_utente,
             data_upd = SYSDATE
       WHERE id_protocollo_dati_interop IN (SELECT id_protocollo_dati_interop
                                              FROM agp_protocolli
                                             WHERE id_documento = d_id);
   END;

   --------------------------------------------------------------------------------

END;
/
