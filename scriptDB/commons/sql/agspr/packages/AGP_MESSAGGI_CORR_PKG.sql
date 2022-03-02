--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_MESSAGGI_CORR_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_MESSAGGI_CORR_PKG
IS
   /******************************************************************************
    NOME:        AGP_PROTOCOLLI_PKG
    DESCRIZIONE: Gestione tabella AGP_PROTOCOLLI.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore        Descrizione.
    00    05/04/2017    mmalferrari   Prima emissione.
    01    20/03/2019    mmalferrari   Aggiunte set_ricevuta_conferma,
                                      set_ricevuta_eccezione,
                                      set_ricevuto_aggiornamento,
                                      set_ricevuto_annullamento.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.01';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE set_ricevuta_consegna (p_id_messaggio    VARCHAR2,
                                    p_email           VARCHAR2);

   PROCEDURE set_ricevuta_mancata_consegna (p_id_messaggio    VARCHAR2,
                                            p_email           VARCHAR2);

   PROCEDURE set_ricevuta_conferma (p_id_corrispondente    VARCHAR2,
                                    p_data                 DATE);

   PROCEDURE set_ricevuta_eccezione (p_id_corrispondente    VARCHAR2,
                                     p_data                 DATE);

   PROCEDURE set_ricevuto_aggiornamento (p_id_corrispondente    VARCHAR2,
                                         p_data                 DATE);

   PROCEDURE set_ricevuto_annullamento (p_id_corrispondente    VARCHAR2,
                                        p_data                 DATE);
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_MESSAGGI_CORR_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_MESSAGGI_CORR_PKG
    DESCRIZIONE Gestione tabella AGP_MESSAGGI_CORRISPONDENTI.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   16/02/2017    mmalferrari   Prima emissione.
    001   20/03/2019    mmalferrari   Aggiunte set_ricevuta_conferma,
                                      set_ricevuta_eccezione,
                                      set_ricevuto_aggiornamento,
                                      set_ricevuto_annullamento.
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
    NOTE:        Primo numero  p_ versione compatibilit¿ del Package.
                 Secondo numerop_ revisione del Package specification.
                 Terzo numero  p_ revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------

   PROCEDURE set_ricevuta_consegna (p_id_messaggio    VARCHAR2,
                                    p_email           VARCHAR2)
   IS
   BEGIN
      UPDATE AGP_MESSAGGI_CORRISPONDENTI
         SET registrata_consegna = 'Y'
       WHERE     id_messaggio IN (SELECT id_documento
                                    FROM AGP_MESSAGGI
                                   WHERE id_documento_esterno =
                                            p_id_messaggio)
             AND LOWER (email) = LOWER (p_email);
   END;

   PROCEDURE set_ricevuta_mancata_consegna (p_id_messaggio    VARCHAR2,
                                            p_email           VARCHAR2)
   IS
   BEGIN
      UPDATE AGP_MESSAGGI_CORRISPONDENTI
         SET ric_mancata_consegna = 'Y'
       WHERE     id_messaggio IN (SELECT id_documento
                                    FROM AGP_MESSAGGI
                                   WHERE id_documento_esterno =
                                            p_id_messaggio)
             AND LOWER (email) = LOWER (p_email);
   END;

   PROCEDURE set_ricevuta_conferma (p_id_corrispondente    VARCHAR2,
                                    p_data                 DATE)
   IS
   BEGIN
      UPDATE AGP_MESSAGGI_CORRISPONDENTI
         SET ricevuta_conferma = 'Y',
             data_ric_conferma = p_data
       WHERE id_protocollo_corrispondente IN (SELECT id_protocollo_corrispondente
                                                FROM agp_protocolli_corrispondenti
                                               WHERE id_documento_esterno =
                                                        p_id_corrispondente);
   END;

   PROCEDURE set_ricevuta_eccezione (p_id_corrispondente    VARCHAR2,
                                     p_data                 DATE)
   IS
   BEGIN
      UPDATE AGP_MESSAGGI_CORRISPONDENTI
         SET ricevuta_eccezione = 'Y',
             data_ric_eccezione = p_data
       WHERE id_protocollo_corrispondente IN (SELECT id_protocollo_corrispondente
                                                FROM agp_protocolli_corrispondenti
                                               WHERE id_documento_esterno =
                                                        p_id_corrispondente);
   END;

   PROCEDURE set_ricevuto_aggiornamento (p_id_corrispondente    VARCHAR2,
                                         p_data                 DATE)
   IS
   BEGIN
      UPDATE AGP_MESSAGGI_CORRISPONDENTI
         SET ricevuto_aggiornamento = 'Y',
             data_ric_aggiornamento = p_data
       WHERE id_protocollo_corrispondente IN (SELECT id_protocollo_corrispondente
                                                FROM agp_protocolli_corrispondenti
                                               WHERE id_documento_esterno =
                                                        p_id_corrispondente);
   END;

   PROCEDURE set_ricevuto_annullamento (p_id_corrispondente    VARCHAR2,
                                        p_data                 DATE)
   IS
   BEGIN
      UPDATE AGP_MESSAGGI_CORRISPONDENTI
         SET ricevuto_annullamento = 'Y',
             data_ric_annullamento = p_data
       WHERE id_protocollo_corrispondente IN (SELECT id_protocollo_corrispondente
                                                FROM agp_protocolli_corrispondenti
                                               WHERE id_documento_esterno =
                                                        p_id_corrispondente);
   END;
END;
/
