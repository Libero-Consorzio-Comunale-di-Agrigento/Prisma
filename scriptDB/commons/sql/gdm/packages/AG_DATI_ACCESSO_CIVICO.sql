--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_DATI_ACCESSO_CIVICO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_dati_accesso_civico
IS
   /******************************************************************************
    NOME:        AG_DATI_ACCESSO_CIVICO.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 DATI_ACCESSO_CIVICO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   19/01/2018 MM     Creazione.
    01   19/04/2019 MM     Create get_unita_competente e get_unita_riesame;
                           eliminata get_unita
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.01';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_dati_accesso_by_domanda (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_accesso_by_risposta (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_accesso (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_accesso_civico
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_richiedente_accesso
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_esito_accesso
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_competente (p_id_documento number)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_riesame (p_id_documento number)
      RETURN afc.t_ref_cursor;

   PROCEDURE upd (
      p_utente                         VARCHAR2,
      p_id_dati_accesso                NUMBER,
      p_id_domanda                     NUMBER DEFAULT -1,
      p_id_risposta                    NUMBER DEFAULT -1,
      p_id_tipo_accesso_civico         NUMBER DEFAULT -1,
      p_id_tipo_richiedente_accesso    NUMBER DEFAULT -1,
      p_data_presentazione             VARCHAR2 DEFAULT '01/01/1950',
      p_oggetto                        VARCHAR2 DEFAULT 'no',
      p_unita_competente               VARCHAR2 DEFAULT 'no',
      p_pubblica_domanda               VARCHAR2 DEFAULT 'no',
      p_controinteressati              VARCHAR2 DEFAULT 'no',
      p_id_tipo_esito                  NUMBER DEFAULT -1,
      p_data_provvedimento             VARCHAR2 DEFAULT '01/01/1950',
      p_motivo_rifiuto                 VARCHAR2 DEFAULT 'no',
      p_unita_competente_riesame       VARCHAR2 DEFAULT 'no',
      p_pubblica                       VARCHAR2 DEFAULT 'no');

   PROCEDURE set_risposta (p_utente         VARCHAR2,
                           p_id_domanda     NUMBER,
                           p_id_risposta    NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY ag_dati_accesso_civico
IS
   /******************************************************************************
    NOME:        AG_DATI_ACCESSO_CIVICO
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 DATI_ACCESSO_CIVICO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  19/01/2018 MM     Creazione.
    001  19/04/2019 MM     Create get_unita_competente e get_unita_riesame;
                           eliminata get_unita
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '001';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   FUNCTION get_dati_accesso_by_domanda (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_DATI_ACCESSO_BY_DOMANDA

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_dati_accesso_by_domanda (
                p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DATI_ACCESSO_CIVICO.GET_DATI_ACCESSO_BY_DOMANDA: ' || SQLERRM);
   END;

   FUNCTION get_dati_accesso_by_risposta (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_DATI_ACCESSO_BY_RISPOSTA

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_dati_accesso_by_risposta (
                p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_DATI_ACCESSO_CIVICO.GET_DATI_ACCESSO_BY_RISPOSTA: '
            || SQLERRM);
   END;

   FUNCTION get_dati_accesso (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_DATI_ACCESSO_BY_RISPOSTA

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_dati_accesso (p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DATI_ACCESSO_CIVICO.GET_DATI_ACCESSO: ' || SQLERRM);
   END;

   FUNCTION get_tipi_accesso_civico
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_TIPI_ACCESSO_CIVICO

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_tipi_accesso_civico;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DATI_ACCESSO_CIVICO.GET_TIPI_ACCESSO_CIVICO: ' || SQLERRM);
   END;

   FUNCTION get_tipi_richiedente_accesso
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_TIPI_RICHIEDENTE_ACCESSO

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_tipi_richiedente_accesso;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_DATI_ACCESSO_CIVICO.GET_TIPI_RICHIEDENTE_ACCESSO: '
            || SQLERRM);
   END;

   FUNCTION get_tipi_esito_accesso
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_TIPI_ESITO_ACCESSO

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_tipi_esito_accesso;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DATI_ACCESSO_CIVICO.GET_TIPI_ESITO_ACCESSO: ' || SQLERRM);
   END;

   FUNCTION get_unita_competente (p_id_documento number)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_UNITA_COMPETENTE

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_unita_competente(p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DATI_ACCESSO_CIVICO.get_unita_competente: ' || SQLERRM);
   END;

   FUNCTION get_unita_riesame (p_id_documento number)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        GET_UNITA_COMPETENTE

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      RETURN AGSPR_PROTO_DATI_ACCESSO_PKG.get_unita_riesame(p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DATI_ACCESSO_CIVICO.get_unita_riesame: ' || SQLERRM);
   END;

   PROCEDURE upd (
      p_utente                         VARCHAR2,
      p_id_dati_accesso                NUMBER,
      p_id_domanda                     NUMBER DEFAULT -1,
      p_id_risposta                    NUMBER DEFAULT -1,
      p_id_tipo_accesso_civico         NUMBER DEFAULT -1,
      p_id_tipo_richiedente_accesso    NUMBER DEFAULT -1,
      p_data_presentazione             VARCHAR2 DEFAULT '01/01/1950',
      p_oggetto                        VARCHAR2 DEFAULT 'no',
      p_unita_competente               VARCHAR2 DEFAULT 'no',
      p_pubblica_domanda               VARCHAR2 DEFAULT 'no',
      p_controinteressati              VARCHAR2 DEFAULT 'no',
      p_id_tipo_esito                  NUMBER DEFAULT -1,
      p_data_provvedimento             VARCHAR2 DEFAULT '01/01/1950',
      p_motivo_rifiuto                 VARCHAR2 DEFAULT 'no',
      p_unita_competente_riesame       VARCHAR2 DEFAULT 'no',
      p_pubblica                       VARCHAR2 DEFAULT 'no')
   IS
      d_data_presentazione          DATE
         := TO_DATE (p_data_presentazione, 'dd/mm/yyyy');
      d_unita_competente_progr      NUMBER;
      d_unita_competente_dal        DATE;
      d_unita_competente_ottica     VARCHAR2 (256);
      d_unita_comp_riesame_progr    NUMBER;
      d_unita_comp_riesame_dal      DATE;
      d_unita_comp_riesame_ottica   VARCHAR2 (256);
      d_data_provvedimento          DATE
         := TO_DATE (p_data_provvedimento, 'dd/mm/yyyy');
   BEGIN
      IF p_unita_competente IS NOT NULL
      THEN
         IF p_unita_competente = 'no'
         THEN
            d_unita_competente_progr := -1;
            d_unita_competente_dal := TO_DATE ('01/01/1950', 'dd/mm/yyyy');
            d_unita_competente_ottica := 'no';
         ELSE
            d_unita_competente_progr :=
               TO_NUMBER (SUBSTR (p_unita_competente, 1, 10));
            d_unita_competente_dal :=
               TO_DATE (SUBSTR (p_unita_competente, 11, 10), 'dd/mm/yyyy');
            d_unita_competente_ottica := SUBSTR (p_unita_competente, 21);
         END IF;
      END IF;

      IF p_unita_competente_riesame IS NOT NULL
      THEN
         IF p_unita_competente_riesame = 'no'
         THEN
            d_unita_comp_riesame_progr := -1;
            d_unita_comp_riesame_dal := TO_DATE ('01/01/1950', 'dd/mm/yyyy');
            d_unita_comp_riesame_ottica := 'no';
         ELSE
            d_unita_comp_riesame_progr :=
               TO_NUMBER (SUBSTR (p_unita_competente_riesame, 1, 10));
            d_unita_comp_riesame_dal :=
               TO_DATE (SUBSTR (p_unita_competente_riesame, 11, 10),
                        'dd/mm/yyyy');
            d_unita_comp_riesame_ottica :=
               SUBSTR (p_unita_competente_riesame, 21);
         END IF;
      END IF;

      AGSPR_PROTO_DATI_ACCESSO_PKG.UPD_BY_ID_ESTERNO (
         p_utente,
         p_id_dati_accesso,
         p_id_domanda,
         p_id_risposta,
         p_id_tipo_accesso_civico,
         p_id_tipo_richiedente_accesso,
         d_data_presentazione,
         p_oggetto,
         d_unita_competente_progr,
         d_unita_competente_dal,
         d_unita_competente_ottica,
         p_pubblica_domanda,
         p_controinteressati,
         p_id_tipo_esito,
         d_data_provvedimento,
         p_motivo_rifiuto,
         d_unita_comp_riesame_progr,
         d_unita_comp_riesame_dal,
         d_unita_comp_riesame_ottica,
         p_pubblica);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                  'AG_DATI_ACCESSO_CIVICO.UPD: ' || SQLERRM);
   END;

   PROCEDURE set_risposta (p_utente         VARCHAR2,
                           p_id_domanda     NUMBER,
                           p_id_risposta    NUMBER)
   IS
   BEGIN
      agspr_proto_dati_accesso_pkg.set_risposta (p_utente,
                                                 p_id_domanda,
                                                 p_id_risposta);
   END;
END;
/
