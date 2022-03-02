--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_PROTO_DATI_ACCESSO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE agp_proto_dati_accesso_pkg
IS
   /******************************************************************************
    NOME:        AGP_PROTO_DATI_ACCESSO_PKG.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 DATI_ACCESSO_CIVICO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   19/01/2018 MM     Creazione.
    01   25/02/2019 SC     Bug #33283 ACCESSO CIVICO: Da interoperabilità
                           non collega la domanda alla risposta. Se la risposta
                           non è ancora registrata in AGSPR, la crea.
    02   19/04/2019 MM     Create get_unita, get_unita_competente, get_unita_riesame
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.02';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_dati_accesso (p_id_esterno IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_accesso_by_domanda (p_id_esterno_domanda IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_accesso_by_risposta (p_id_esterno_risposta IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_accesso_civico
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_richiedente_accesso
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_esito_accesso
      RETURN afc.t_ref_cursor;

   FUNCTION ins_domanda (
      p_utente                         VARCHAR2,
      p_id_doc_esterno_domanda         NUMBER,
      p_id_tipo_accesso_civico         NUMBER DEFAULT NULL,
      p_id_tipo_richiedente_accesso    NUMBER DEFAULT NULL,
      p_data_presentazione             DATE DEFAULT NULL,
      p_oggetto                        VARCHAR2 DEFAULT NULL,
      p_unita_competente_progr         NUMBER DEFAULT NULL,
      p_unita_competente_dal           DATE DEFAULT NULL,
      p_unita_competente_ottica        VARCHAR2 DEFAULT NULL,
      p_pubblica_domanda               VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION ins (p_utente                         VARCHAR2,
                 p_id_protocollo_domanda          NUMBER,
                 p_id_tipo_accesso_civico         NUMBER,
                 p_id_tipo_richiedente_accesso    NUMBER,
                 p_data_presentazione             DATE,
                 p_oggetto                        VARCHAR2,
                 p_unita_competente_progr         NUMBER,
                 p_unita_competente_dal           DATE,
                 p_unita_competente_ottica        VARCHAR2,
                 p_pubblica_domanda               VARCHAR2,
                 p_id_protocollo_risposta         NUMBER DEFAULT NULL,
                 p_controinteressati              VARCHAR2 DEFAULT NULL,
                 p_id_tipo_esito                  NUMBER DEFAULT NULL,
                 p_data_provvedimento             DATE DEFAULT NULL,
                 p_motivo_rifiuto                 VARCHAR2 DEFAULT NULL,
                 p_unita_comp_riesame_progr       NUMBER DEFAULT NULL,
                 p_unita_comp_riesame_dal         DATE DEFAULT NULL,
                 p_unita_comp_riesame_ottica      VARCHAR2 DEFAULT NULL,
                 p_pubblica                       VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   PROCEDURE del_domanda (p_id_doc_esterno_domanda NUMBER);

   PROCEDURE del (p_id_dati_accesso NUMBER);

   PROCEDURE upd (p_utente                         VARCHAR2,
                  p_id_dati_accesso                NUMBER,
                  p_id_protocollo_domanda          NUMBER,
                  p_id_tipo_accesso_civico         NUMBER,
                  p_id_tipo_richiedente_accesso    NUMBER,
                  p_data_presentazione             DATE,
                  p_oggetto                        VARCHAR2,
                  p_unita_competente_progr         NUMBER,
                  p_unita_competente_dal           DATE,
                  p_unita_competente_ottica        VARCHAR2,
                  p_pubblica_domanda               VARCHAR2,
                  p_id_protocollo_risposta         NUMBER,
                  p_controinteressati              VARCHAR2,
                  p_id_tipo_esito                  NUMBER,
                  p_data_provvedimento             DATE,
                  p_motivo_rifiuto                 VARCHAR2,
                  p_unita_comp_riesame_progr       NUMBER,
                  p_unita_comp_riesame_dal         DATE,
                  p_unita_comp_riesame_ottica      VARCHAR2,
                  p_pubblica                       VARCHAR2);

   PROCEDURE upd_by_id_esterno (
      p_utente                         VARCHAR2,
      p_id_dati_accesso                NUMBER,
      p_id_esterno_domanda             NUMBER DEFAULT -1,
      p_id_esterno_risposta            NUMBER DEFAULT -1,
      p_id_tipo_accesso_civico         NUMBER DEFAULT -1,
      p_id_tipo_richiedente_accesso    NUMBER DEFAULT -1,
      p_data_presentazione             DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_oggetto                        VARCHAR2 DEFAULT 'no',
      p_unita_competente_progr         NUMBER DEFAULT -1,
      p_unita_competente_dal           DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_unita_competente_ottica        VARCHAR2 DEFAULT 'no',
      p_pubblica_domanda               VARCHAR2 DEFAULT 'no',
      p_controinteressati              VARCHAR2 DEFAULT 'no',
      p_id_tipo_esito                  NUMBER DEFAULT -1,
      p_data_provvedimento             DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_motivo_rifiuto                 VARCHAR2 DEFAULT 'no',
      p_unita_comp_riesame_progr       NUMBER DEFAULT -1,
      p_unita_comp_riesame_dal         DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_unita_comp_riesame_ottica      VARCHAR2 DEFAULT 'no',
      p_pubblica                       VARCHAR2 DEFAULT 'no');

   PROCEDURE set_risposta (p_utente                 VARCHAR2,
                           p_id_esterno_domanda     NUMBER,
                           p_id_esterno_risposta    NUMBER);

   FUNCTION get_unita (p_id_documento_esterno NUMBER, p_tipo VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_competente (p_id_documento_esterno NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_riesame (p_id_documento_esterno NUMBER)
      RETURN afc.t_ref_cursor;
END;
/
CREATE OR REPLACE PACKAGE BODY agp_proto_dati_accesso_pkg
IS
   /******************************************************************************
    NOME:        AGP_PROTO_DATI_ACCESSO_PKG
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 DATI_ACCESSO_CIVICO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  19/01/2018 MM     Creazione.
    001  25/02/2019 SC     Bug #33283 ACCESSO CIVICO: Da interoperabilità
                           non collega la domanda alla risposta. Se la risposta
                           non è ancora registrata in AGSPR, la crea.
    002  19/04/2019 MM     Create get_unita, get_unita_competente, get_unita_riesame
    003  13/10/2020 MM     Gestione campo controinteressati a N se nullo.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '003';

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

   FUNCTION get_dati_accesso_by_domanda (p_id_esterno_domanda IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        get_dati_accesso_by_domanda

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT daac.*
           FROM agp_protocolli_dati_accesso daac, gdo_documenti docu
          WHERE     docu.id_documento = daac.id_protocollo_domanda
                AND docu.id_documento_esterno = p_id_esterno_domanda;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_PROTO_DATI_ACCESSO_PKG.get_dati_accesso_civico: ' || SQLERRM);
   END;

   FUNCTION get_dati_accesso_by_risposta (p_id_esterno_risposta IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        get_dati_accesso_by_risposta

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT daac.*
           FROM agp_protocolli_dati_accesso daac, gdo_documenti docu
          WHERE     docu.id_documento = daac.id_protocollo_risposta
                AND docu.id_documento_esterno = p_id_esterno_risposta;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_PROTO_DATI_ACCESSO_PKG.get_dati_accesso_civico: ' || SQLERRM);
   END;

   FUNCTION get_dati_accesso (p_id_esterno IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
        NOME:        get_dati_accesso

        DESCRIZIONE:

        RITORNO:

        Rev.  Data       Autore    Descrizione.
        000   19/01/2018 MM        Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT 'DOMANDA' tipo,
                prot_doma.anno anno_domanda,
                prot_doma.numero numero_domanda,
                prot_doma.tipo_registro tipo_registro_domanda,
                prot_doma.data data_domanda,
                prot_risp.anno anno_risposta,
                prot_risp.numero numero_risposta,
                prot_risp.tipo_registro tipo_registro_risposta,
                prot_risp.data data_risposta,
                id_dati_accesso,
                id_protocollo_domanda,
                docu_doma.id_documento_esterno id_doc_esterno_domanda,
                id_tipo_accesso_civico,
                id_tipo_richiedente_accesso,
                data_presentazione,
                daac.oggetto,
                unita_competente_progr,
                unita_competente_dal,
                unita_competente_ottica,
                   LPAD (TO_CHAR (unita_competente_progr), 10, '0')
                || TO_CHAR (unita_competente_dal, 'dd/mm/yyyy')
                || unita_competente_ottica
                   unita_competente,
                pubblica_domanda,
                id_protocollo_risposta,
                docu_risp.id_documento_esterno id_doc_esterno_risposta,
                controinteressati,
                id_tipo_esito,
                data_provvedimento,
                motivo_rifiuto,
                unita_comp_riesame_progr,
                unita_comp_riesame_dal,
                unita_comp_riesame_ottica,
                   LPAD (TO_CHAR (unita_comp_riesame_progr), 10, '0')
                || TO_CHAR (unita_comp_riesame_dal, 'dd/mm/yyyy')
                || unita_comp_riesame_ottica
                   unita_comp_riesame,
                pubblica
           FROM agp_protocolli_dati_accesso daac,
                gdo_documenti docu_doma,
                agp_protocolli prot_doma,
                gdo_documenti docu_risp,
                agp_protocolli prot_risp
          WHERE     docu_doma.id_documento = daac.id_protocollo_domanda
                AND docu_doma.id_documento_esterno = p_id_esterno
                AND prot_doma.id_documento = docu_doma.id_documento
                AND prot_risp.id_documento(+) = daac.id_protocollo_risposta
                AND docu_risp.id_documento(+) = prot_risp.id_documento
         UNION
         SELECT 'RISPOSTA' tipo,
                prot_doma.anno anno_domanda,
                prot_doma.numero numero_domanda,
                prot_doma.tipo_registro tipo_registro_domanda,
                prot_doma.data data_domanda,
                prot_risp.anno anno_risposta,
                prot_risp.numero numero_risposta,
                prot_risp.tipo_registro tipo_registro_risposta,
                prot_risp.data data_risposta,
                id_dati_accesso,
                id_protocollo_domanda,
                docu_doma.id_documento_esterno id_doc_esterno_domanda,
                id_tipo_accesso_civico,
                id_tipo_richiedente_accesso,
                data_presentazione,
                daac.oggetto,
                unita_competente_progr,
                unita_competente_dal,
                unita_competente_ottica,
                   LPAD (TO_CHAR (unita_competente_progr), 10, '0')
                || TO_CHAR (unita_competente_dal, 'dd/mm/yyyy')
                || unita_competente_ottica
                   unita_competente,
                pubblica_domanda,
                id_protocollo_risposta,
                docu_risp.id_documento_esterno id_doc_esterno_risposta,
                controinteressati,
                id_tipo_esito,
                data_provvedimento,
                motivo_rifiuto,
                unita_comp_riesame_progr,
                unita_comp_riesame_dal,
                unita_comp_riesame_ottica,
                   LPAD (TO_CHAR (unita_comp_riesame_progr), 10, '0')
                || TO_CHAR (unita_comp_riesame_dal, 'dd/mm/yyyy')
                || unita_comp_riesame_ottica
                   unita_comp_riesame,
                pubblica
           FROM agp_protocolli_dati_accesso daac,
                gdo_documenti docu_doma,
                agp_protocolli prot_doma,
                gdo_documenti docu_risp,
                agp_protocolli prot_risp
          WHERE     docu_risp.id_documento = daac.id_protocollo_risposta
                AND docu_risp.id_documento_esterno = p_id_esterno
                AND prot_risp.id_documento = docu_risp.id_documento
                AND prot_doma.id_documento = daac.id_protocollo_domanda
                AND docu_doma.id_documento = prot_doma.id_documento;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_PROTO_DATI_ACCESSO_PKG.get_dati_accesso_civico: ' || SQLERRM);
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
      OPEN d_result FOR
           SELECT *
             FROM AGP_TIPI_ACCESSO_CIVICO
            WHERE valido = 'Y'
         ORDER BY DESCRIZIONE;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_PROTO_DATI_ACCESSO_PKG.GET_TIPI_ACCESSO_CIVICO: ' || SQLERRM);
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
      OPEN d_result FOR
           SELECT *
             FROM AGP_TIPI_RICHIEDENTE_ACCESSO
            WHERE valido = 'Y'
         ORDER BY DESCRIZIONE;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AGP_PROTO_DATI_ACCESSO_PKG.GET_TIPI_RICHIEDENTE_ACCESSO: '
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
      OPEN d_result FOR
           SELECT *
             FROM AGP_TIPI_ESITO_ACCESSO
            WHERE valido = 'Y'
         ORDER BY DESCRIZIONE;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_PROTO_DATI_ACCESSO_PKG.GET_TIPI_ESITO_ACCESSO: ' || SQLERRM);
   END;

   FUNCTION get_id_protocollo (p_id_doc_esterno NUMBER)
      RETURN NUMBER
   IS
      d_id_protocollo   NUMBER := NULL;
   BEGIN
      SELECT id_documento
        INTO d_id_protocollo
        FROM gdo_documenti
       WHERE id_documento_esterno = p_id_doc_esterno;

      RETURN d_id_protocollo;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION get_id_dati_accesso (p_id_protocollo_domanda NUMBER)
      RETURN NUMBER
   IS
      d_id_dati_accesso   NUMBER := NULL;
   BEGIN
      SELECT id_dati_accesso
        INTO d_id_dati_accesso
        FROM AGP_PROTOCOLLI_DATI_ACCESSO
       WHERE id_protocollo_domanda = p_id_protocollo_domanda;

      RETURN d_id_dati_accesso;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION ins_domanda (p_utente                         VARCHAR2,
                         p_id_doc_esterno_domanda         NUMBER,
                         p_id_tipo_accesso_civico         NUMBER,
                         p_id_tipo_richiedente_accesso    NUMBER,
                         p_data_presentazione             DATE,
                         p_oggetto                        VARCHAR2,
                         p_unita_competente_progr         NUMBER,
                         p_unita_competente_dal           DATE,
                         p_unita_competente_ottica        VARCHAR2,
                         p_pubblica_domanda               VARCHAR2)
      RETURN NUMBER
   IS
      d_id_protocollo_domanda   NUMBER := NULL;
      d_return                  NUMBER := NULL;
   BEGIN
      d_id_protocollo_domanda := get_id_protocollo (p_id_doc_esterno_domanda);

      IF d_id_protocollo_domanda IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO d_return
           FROM AGP_PROTOCOLLI_DATI_ACCESSO
          WHERE id_protocollo_domanda = d_id_protocollo_domanda;

         IF d_return > 0
         THEN
            d_return := d_id_protocollo_domanda;
         ELSE
            d_return :=
               ins (p_utente,
                    d_id_protocollo_domanda,
                    p_id_tipo_accesso_civico,
                    p_id_tipo_richiedente_accesso,
                    p_data_presentazione,
                    p_oggetto,
                    p_unita_competente_progr,
                    p_unita_competente_dal,
                    p_unita_competente_ottica,
                    p_pubblica_domanda);
         END IF;
      ELSE
         raise_application_error (
            -20999,
               'Impossibile recuperare protocollo AGSPR da id esterno ('
            || p_id_doc_esterno_domanda
            || ')');
      END IF;

      RETURN d_return;
   END;

   FUNCTION ins (p_utente                         VARCHAR2,
                 p_id_protocollo_domanda          NUMBER,
                 p_id_tipo_accesso_civico         NUMBER,
                 p_id_tipo_richiedente_accesso    NUMBER,
                 p_data_presentazione             DATE,
                 p_oggetto                        VARCHAR2,
                 p_unita_competente_progr         NUMBER,
                 p_unita_competente_dal           DATE,
                 p_unita_competente_ottica        VARCHAR2,
                 p_pubblica_domanda               VARCHAR2,
                 p_id_protocollo_risposta         NUMBER DEFAULT NULL,
                 p_controinteressati              VARCHAR2 DEFAULT NULL,
                 p_id_tipo_esito                  NUMBER DEFAULT NULL,
                 p_data_provvedimento             DATE DEFAULT NULL,
                 p_motivo_rifiuto                 VARCHAR2 DEFAULT NULL,
                 p_unita_comp_riesame_progr       NUMBER DEFAULT NULL,
                 p_unita_comp_riesame_dal         DATE DEFAULT NULL,
                 p_unita_comp_riesame_ottica      VARCHAR2 DEFAULT NULL,
                 p_pubblica                       VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      d_id                      NUMBER;
      d_id_protocollo_domanda   NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id FROM DUAL;

      INSERT INTO AGP_PROTOCOLLI_DATI_ACCESSO (ID_DATI_ACCESSO,
                                               ID_PROTOCOLLO_DOMANDA,
                                               ID_TIPO_ACCESSO_CIVICO,
                                               ID_TIPO_RICHIEDENTE_ACCESSO,
                                               DATA_PRESENTAZIONE,
                                               OGGETTO,
                                               UNITA_COMPETENTE_PROGR,
                                               UNITA_COMPETENTE_DAL,
                                               UNITA_COMPETENTE_OTTICA,
                                               PUBBLICA_DOMANDA,
                                               ID_PROTOCOLLO_RISPOSTA,
                                               CONTROINTERESSATI,
                                               ID_TIPO_ESITO,
                                               DATA_PROVVEDIMENTO,
                                               MOTIVO_RIFIUTO,
                                               UNITA_COMP_RIESAME_PROGR,
                                               UNITA_COMP_RIESAME_DAL,
                                               UNITA_COMP_RIESAME_OTTICA,
                                               PUBBLICA,
                                               VERSION,
                                               UTENTE_INS,
                                               DATA_INS,
                                               UTENTE_UPD,
                                               DATA_UPD)
           VALUES (d_id,
                   P_ID_PROTOCOLLO_DOMANDA,
                   P_ID_TIPO_ACCESSO_CIVICO,
                   P_ID_TIPO_RICHIEDENTE_ACCESSO,
                   P_DATA_PRESENTAZIONE,
                   P_OGGETTO,
                   P_UNITA_COMPETENTE_PROGR,
                   P_UNITA_COMPETENTE_DAL,
                   P_UNITA_COMPETENTE_OTTICA,
                   NVL (P_PUBBLICA_DOMANDA, 'N'),
                   P_ID_PROTOCOLLO_RISPOSTA,
                   NVL (P_CONTROINTERESSATI, 'N'),
                   P_ID_TIPO_ESITO,
                   P_DATA_PROVVEDIMENTO,
                   P_MOTIVO_RIFIUTO,
                   P_UNITA_COMP_RIESAME_PROGR,
                   P_UNITA_COMP_RIESAME_DAL,
                   P_UNITA_COMP_RIESAME_OTTICA,
                   NVL (P_PUBBLICA, 'N'),
                   0,
                   P_UTENTE,
                   SYSDATE,
                   NULL,
                   NULL);

      RETURN d_id;
   END;

   PROCEDURE del_domanda (p_id_doc_esterno_domanda NUMBER)
   IS
      d_id_protocollo_domanda   NUMBER := NULL;
      d_id_dati_accesso         NUMBER := NULL;
   BEGIN
      d_id_protocollo_domanda := get_id_protocollo (p_id_doc_esterno_domanda);
      d_id_dati_accesso := get_id_dati_accesso (d_id_protocollo_domanda);
      del (d_id_dati_accesso);
   END;

   PROCEDURE del (P_ID_DATI_ACCESSO NUMBER)
   IS
   BEGIN
      DELETE AGP_PROTOCOLLI_DATI_ACCESSO
       WHERE ID_DATI_ACCESSO = P_ID_DATI_ACCESSO;
   END;

   PROCEDURE set_risposta (p_utente                 VARCHAR2,
                           p_id_esterno_domanda     NUMBER,
                           p_id_esterno_risposta    NUMBER)
   IS
      d_id_dati_accesso               NUMBER := -1;
      d_id_protocollo_domanda         NUMBER := -1;
      d_id_protocollo_risposta        NUMBER := NULL;

      d_id_tipo_accesso_civico        NUMBER := -1;
      d_id_tipo_richiedente_accesso   NUMBER := -1;
      d_data_presentazione            DATE
         := TO_DATE ('01/01/1950', 'dd/mm/yyyy');
      d_oggetto                       VARCHAR2 (4000) := 'no';
      d_unita_competente_progr        NUMBER := -1;
      d_unita_competente_dal          DATE
         := TO_DATE ('01/01/1950', 'dd/mm/yyyy');
      d_unita_competente_ottica       VARCHAR2 (255) := 'no';
      d_pubblica_domanda              VARCHAR2 (255) := 'no';

      d_controinteressati             VARCHAR2 (255) := 'N';
      d_id_tipo_esito                 NUMBER := NULL;
      d_data_provvedimento            DATE := NULL;
      d_motivo_rifiuto                VARCHAR2 (255) := NULL;
      d_unita_comp_riesame_progr      NUMBER := NULL;
      d_unita_comp_riesame_dal        DATE := NULL;
      d_unita_comp_riesame_ottica     VARCHAR2 (255) := NULL;
      d_pubblica                      VARCHAR2 (255) := 'N';
      d_anno                          NUMBER;
      d_numero                        NUMBER;
      d_tipo_registro                 VARCHAR2 (1000);
      d_data                          DATE;
      dep_oggetto                     VARCHAR2 (4000);
      d_riservato                     VARCHAR2 (1);
      d_codice_amm                    VARCHAR2 (4000);
      d_codice_aoo                    VARCHAR2 (4000);
      d_codice_modello                VARCHAR2 (4000);
   BEGIN
      IF     NVL (p_id_esterno_domanda, -1) > -1
         AND NVL (p_id_esterno_risposta, -1) > -1
      THEN
         BEGIN
            INSERT INTO GDM_RIFERIMENTI (AREA,
                                         DATA_AGGIORNAMENTO,
                                         ID_DOCUMENTO,
                                         ID_DOCUMENTO_RIF,
                                         TIPO_RELAZIONE,
                                         UTENTE_AGGIORNAMENTO)
                 VALUES ('SEGRETERIA.PROTOCOLLO',
                         SYSDATE,
                         p_id_esterno_domanda,
                         p_id_esterno_risposta,
                         'PROT_DAAC',
                         p_utente);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
         END;
      END IF;

      IF NVL (p_id_esterno_domanda, -1) > -1
      THEN
         d_id_protocollo_domanda := get_id_protocollo (p_id_esterno_domanda);
      END IF;

      IF NVL (p_id_esterno_risposta, -1) > -1
      THEN
         d_id_protocollo_risposta := get_id_protocollo (p_id_esterno_risposta);

         /*    001  25/02/2019 SC     Bug #33283 ACCESSO CIVICO: Da interoperabilità
                                    non collega la domanda alla risposta. Se la risposta
                                    non è ancora registrata in AGSPR, la crea.
                                    */
         IF d_id_protocollo_risposta IS NULL
         THEN
            SELECT anno,
                   numero,
                   tipo_registro,
                   data,
                   oggetto,
                   riservato,
                   codice_amministrazione,
                   codice_aoo,
                   CODICE_MODELLO
              INTO d_anno,
                   d_numero,
                   d_tipo_registro,
                   d_data,
                   dep_oggetto,
                   d_riservato,
                   d_codice_amm,
                   d_codice_aoo,
                   d_codice_modello
              FROM agp_proto_view
             WHERE id_documento = p_id_esterno_risposta;

            d_id_protocollo_risposta :=
               agp_protocolli_pkg.ins_da_esterno (
                  p_utente                 => p_utente,
                  p_id_documento_esterno   => p_id_esterno_risposta,
                  p_anno                   => d_anno,
                  p_numero                 => d_numero,
                  p_tipo_registro          => d_tipo_registro,
                  p_data                   => d_data,
                  p_oggetto                => dep_oggetto,
                  p_riservato              => d_riservato,
                  p_codice_amm             => d_codice_amm,
                  p_codice_aoo             => d_codice_aoo,
                  p_modello                => d_codice_modello);
         END IF;
      END IF;

      d_id_dati_accesso := get_id_dati_accesso (d_id_protocollo_domanda);

      upd (p_utente,
           d_id_dati_accesso,
           d_id_protocollo_domanda,
           d_id_tipo_accesso_civico,
           d_id_tipo_richiedente_accesso,
           d_data_presentazione,
           d_oggetto,
           d_unita_competente_progr,
           d_unita_competente_dal,
           d_unita_competente_ottica,
           d_pubblica_domanda,
           d_id_protocollo_risposta,
           d_controinteressati,
           d_id_tipo_esito,
           d_data_provvedimento,
           d_motivo_rifiuto,
           d_unita_comp_riesame_progr,
           d_unita_comp_riesame_dal,
           d_unita_comp_riesame_ottica,
           d_pubblica);
   END;

   PROCEDURE upd_by_id_esterno (
      p_utente                         VARCHAR2,
      p_id_dati_accesso                NUMBER,
      p_id_esterno_domanda             NUMBER DEFAULT -1,
      p_id_esterno_risposta            NUMBER DEFAULT -1,
      p_id_tipo_accesso_civico         NUMBER DEFAULT -1,
      p_id_tipo_richiedente_accesso    NUMBER DEFAULT -1,
      p_data_presentazione             DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_oggetto                        VARCHAR2 DEFAULT 'no',
      p_unita_competente_progr         NUMBER DEFAULT -1,
      p_unita_competente_dal           DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_unita_competente_ottica        VARCHAR2 DEFAULT 'no',
      p_pubblica_domanda               VARCHAR2 DEFAULT 'no',
      p_controinteressati              VARCHAR2 DEFAULT 'no',
      p_id_tipo_esito                  NUMBER DEFAULT -1,
      p_data_provvedimento             DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_motivo_rifiuto                 VARCHAR2 DEFAULT 'no',
      p_unita_comp_riesame_progr       NUMBER DEFAULT -1,
      p_unita_comp_riesame_dal         DATE DEFAULT TO_DATE ('01/01/1950',
                                                             'dd/mm/yyyy'),
      p_unita_comp_riesame_ottica      VARCHAR2 DEFAULT 'no',
      p_pubblica                       VARCHAR2 DEFAULT 'no')
   IS
      d_id_protocollo_domanda    NUMBER := -1;
      d_id_protocollo_risposta   NUMBER := -1;
   BEGIN
      IF NVL (p_id_esterno_domanda, -1) > -1
      THEN
         d_id_protocollo_domanda := get_id_protocollo (p_id_esterno_domanda);
      END IF;

      IF NVL (p_id_esterno_risposta, -1) > -1
      THEN
         d_id_protocollo_risposta := get_id_protocollo (p_id_esterno_risposta);
      END IF;

      upd (p_utente,
           p_id_dati_accesso,
           d_id_protocollo_domanda,
           P_ID_TIPO_ACCESSO_CIVICO,
           P_ID_TIPO_RICHIEDENTE_ACCESSO,
           P_DATA_PRESENTAZIONE,
           P_OGGETTO,
           P_UNITA_COMPETENTE_PROGR,
           P_UNITA_COMPETENTE_DAL,
           P_UNITA_COMPETENTE_OTTICA,
           P_PUBBLICA_DOMANDA,
           d_id_protocollo_risposta,
           P_CONTROINTERESSATI,
           P_ID_TIPO_ESITO,
           P_DATA_PROVVEDIMENTO,
           P_MOTIVO_RIFIUTO,
           P_UNITA_COMP_RIESAME_PROGR,
           P_UNITA_COMP_RIESAME_DAL,
           P_UNITA_COMP_RIESAME_OTTICA,
           P_PUBBLICA);
   END;

   /*
      PROCEDURE upd_risposta (
         p_utente                       VARCHAR2,
         p_id_doc_esterno_domanda       NUMBER,
         p_id_doc_esterno_risposta      NUMBER,
         p_id_tipo_esito                NUMBER DEFAULT -1,
         p_data_provvedimento           DATE DEFAULT TO_DATE ('01/01/1950',
                                                              'dd/mm/yyyy'),
         p_motivo_rifiuto               VARCHAR2 DEFAULT 'no',
         p_unita_comp_riesame_progr     NUMBER DEFAULT -1,
         p_unita_comp_riesame_dal       DATE DEFAULT TO_DATE ('01/01/1950',
                                                              'dd/mm/yyyy'),
         p_unita_comp_riesame_ottica    VARCHAR2 DEFAULT 'no',
         p_controinteressati            VARCHAR2 DEFAULT 'no',
         p_pubblica                     VARCHAR2 DEFAULT 'no')
      IS
         d_id_protocollo_domanda    NUMBER;
         d_id_protocollo_risposta   NUMBER;
         d_id_dati_accesso          NUMBER := NULL;
      BEGIN
         d_id_protocollo_domanda := get_id_protocollo (p_id_doc_esterno_domanda);

         IF NVL (p_id_doc_esterno_risposta, -1) > -1
         THEN
            d_id_protocollo_risposta :=
               get_id_protocollo (p_id_doc_esterno_risposta);
         END IF;

         d_id_dati_accesso := get_id_dati_accesso (d_id_protocollo_domanda);

         upd (p_utente,
              d_id_dati_accesso,
              d_id_protocollo_domanda,
              -1,
              -1,
              TO_DATE ('01/01/1950', 'dd/mm/yyyy'),
              'no',
              -1,
              TO_DATE ('01/01/1950', 'dd/mm/yyyy'),
              'no',
              'no',
              d_id_protocollo_risposta,
              P_CONTROINTERESSATI,
              P_ID_TIPO_ESITO,
              P_DATA_PROVVEDIMENTO,
              P_MOTIVO_RIFIUTO,
              P_UNITA_COMP_RIESAME_PROGR,
              P_UNITA_COMP_RIESAME_DAL,
              P_UNITA_COMP_RIESAME_OTTICA,
              P_PUBBLICA);
      END;

      PROCEDURE upd_domanda (p_utente                         VARCHAR2,
                             p_id_doc_esterno_domanda         NUMBER,
                             p_id_tipo_accesso_civico         NUMBER,
                             p_id_tipo_richiedente_accesso    NUMBER,
                             p_data_presentazione             DATE,
                             p_oggetto                        VARCHAR2,
                             p_unita_competente_progr         NUMBER,
                             p_unita_competente_dal           DATE,
                             p_unita_competente_ottica        VARCHAR2,
                             p_pubblica_domanda               VARCHAR2)
      IS
         d_id_protocollo_domanda    NUMBER;
         d_id_protocollo_risposta   NUMBER;
         d_id_dati_accesso          NUMBER := NULL;
      BEGIN
         d_id_protocollo_domanda := get_id_protocollo (p_id_doc_esterno_domanda);
         d_id_dati_accesso := get_id_dati_accesso (d_id_protocollo_domanda);

         upd (p_utente,
              d_id_dati_accesso,
              d_id_protocollo_domanda,
              P_ID_TIPO_ACCESSO_CIVICO,
              P_ID_TIPO_RICHIEDENTE_ACCESSO,
              P_DATA_PRESENTAZIONE,
              P_OGGETTO,
              P_UNITA_COMPETENTE_PROGR,
              P_UNITA_COMPETENTE_DAL,
              P_UNITA_COMPETENTE_OTTICA,
              P_PUBBLICA_DOMANDA,
              -1,
              'no',
              -1,
              TO_DATE ('01/01/1950', 'dd/mm/yyyy'),
              'no',
              -1,
              TO_DATE ('01/01/1950', 'dd/mm/yyyy'),
              'no',
              'no');
      END;
   */
   PROCEDURE upd (p_utente                         VARCHAR2,
                  p_id_dati_accesso                NUMBER,
                  p_id_protocollo_domanda          NUMBER,
                  p_id_tipo_accesso_civico         NUMBER,
                  p_id_tipo_richiedente_accesso    NUMBER,
                  p_data_presentazione             DATE,
                  p_oggetto                        VARCHAR2,
                  p_unita_competente_progr         NUMBER,
                  p_unita_competente_dal           DATE,
                  p_unita_competente_ottica        VARCHAR2,
                  p_pubblica_domanda               VARCHAR2,
                  p_id_protocollo_risposta         NUMBER,
                  p_controinteressati              VARCHAR2,
                  p_id_tipo_esito                  NUMBER,
                  p_data_provvedimento             DATE,
                  p_motivo_rifiuto                 VARCHAR2,
                  p_unita_comp_riesame_progr       NUMBER,
                  p_unita_comp_riesame_dal         DATE,
                  p_unita_comp_riesame_ottica      VARCHAR2,
                  p_pubblica                       VARCHAR2)
   IS
      d_version   NUMBER;
   BEGIN
      SELECT NVL (MAX (version), 0) + 1
        INTO d_version
        FROM agp_protocolli_dati_accesso
       WHERE ID_DATI_ACCESSO = P_ID_DATI_ACCESSO;

      UPDATE AGP_PROTOCOLLI_DATI_ACCESSO
         SET ID_PROTOCOLLO_DOMANDA =
                DECODE (P_ID_PROTOCOLLO_DOMANDA,
                        -1, ID_PROTOCOLLO_DOMANDA,
                        P_ID_PROTOCOLLO_DOMANDA),
             ID_TIPO_ACCESSO_CIVICO =
                DECODE (P_ID_TIPO_ACCESSO_CIVICO,
                        -1, ID_TIPO_ACCESSO_CIVICO,
                        P_ID_TIPO_ACCESSO_CIVICO),
             ID_TIPO_RICHIEDENTE_ACCESSO =
                DECODE (P_ID_TIPO_RICHIEDENTE_ACCESSO,
                        -1, ID_TIPO_RICHIEDENTE_ACCESSO,
                        P_ID_TIPO_RICHIEDENTE_ACCESSO),
             DATA_PRESENTAZIONE =
                DECODE (
                   P_DATA_PRESENTAZIONE,
                   TO_DATE ('01/01/1950', 'dd/mm/yyyy'), DATA_PRESENTAZIONE,
                   P_DATA_PRESENTAZIONE),
             OGGETTO = DECODE (P_OGGETTO, 'no', OGGETTO, P_OGGETTO),
             UNITA_COMPETENTE_PROGR =
                DECODE (P_UNITA_COMPETENTE_PROGR,
                        -1, UNITA_COMPETENTE_PROGR,
                        P_UNITA_COMPETENTE_PROGR),
             UNITA_COMPETENTE_DAL =
                DECODE (
                   P_UNITA_COMPETENTE_DAL,
                   TO_DATE ('01/01/1950', 'dd/mm/yyyy'), UNITA_COMPETENTE_DAL,
                   P_UNITA_COMPETENTE_DAL),
             UNITA_COMPETENTE_OTTICA =
                DECODE (P_UNITA_COMPETENTE_OTTICA,
                        'no', UNITA_COMPETENTE_OTTICA,
                        P_UNITA_COMPETENTE_OTTICA),
             PUBBLICA_DOMANDA =
                DECODE (P_PUBBLICA_DOMANDA,
                        'no', PUBBLICA_DOMANDA,
                        P_PUBBLICA_DOMANDA),
             ID_PROTOCOLLO_RISPOSTA =
                DECODE (P_ID_PROTOCOLLO_RISPOSTA,
                        -1, ID_PROTOCOLLO_RISPOSTA,
                        P_ID_PROTOCOLLO_RISPOSTA),
             CONTROINTERESSATI =
                DECODE (P_CONTROINTERESSATI,
                        'no', CONTROINTERESSATI,
                        nvl(P_CONTROINTERESSATI, 'N')),
             ID_TIPO_ESITO =
                DECODE (P_ID_TIPO_ESITO, -1, ID_TIPO_ESITO, P_ID_TIPO_ESITO),
             DATA_PROVVEDIMENTO =
                DECODE (
                   P_DATA_PROVVEDIMENTO,
                   TO_DATE ('01/01/1950', 'dd/mm/yyyy'), DATA_PROVVEDIMENTO,
                   P_DATA_PROVVEDIMENTO),
             MOTIVO_RIFIUTO =
                DECODE (P_MOTIVO_RIFIUTO,
                        'no', MOTIVO_RIFIUTO,
                        P_MOTIVO_RIFIUTO),
             UNITA_COMP_RIESAME_PROGR =
                DECODE (P_UNITA_COMP_RIESAME_PROGR,
                        -1, UNITA_COMP_RIESAME_PROGR,
                        P_UNITA_COMP_RIESAME_PROGR),
             UNITA_COMP_RIESAME_DAL =
                DECODE (
                   P_UNITA_COMP_RIESAME_DAL,
                   TO_DATE ('01/01/1950', 'dd/mm/yyyy'), UNITA_COMP_RIESAME_DAL,
                   P_UNITA_COMP_RIESAME_DAL),
             UNITA_COMP_RIESAME_OTTICA =
                DECODE (P_UNITA_COMP_RIESAME_OTTICA,
                        'no', UNITA_COMP_RIESAME_OTTICA,
                        P_UNITA_COMP_RIESAME_OTTICA),
             PUBBLICA = DECODE (P_PUBBLICA, 'no', PUBBLICA, P_PUBBLICA),
             VERSION = d_version,
             UTENTE_UPD = P_UTENTE,
             DATA_UPD = SYSDATE
       WHERE ID_DATI_ACCESSO = P_ID_DATI_ACCESSO;
   END;

   FUNCTION get_unita (p_id_documento_esterno NUMBER, p_tipo VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT u.progr progr_unita_organizzativa,
                u.codice,
                u.dal,
                ottica,
                   LPAD (TO_CHAR (progr), 10, '0')
                || TO_CHAR (dal, 'dd/mm/yyyy')
                || ottica
                   unita,
                u.codice || ' - ' || u.descrizione nome
           FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB u
          WHERE     SYSDATE BETWEEN u.dal
                                AND NVL (al, TO_DATE (3333333, 'j'))
                AND ottica =
                       GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                          'SO_OTTICA_PROT',
                          1)
         UNION
         SELECT u.progr progr_unita_organizzativa,
                u.codice,
                u.dal,
                ottica,
                   LPAD (TO_CHAR (progr), 10, '0')
                || TO_CHAR (dal, 'dd/mm/yyyy')
                || ottica
                   unita,
                u.codice || ' - ' || u.descrizione nome
           FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB u,
                gdo_documenti d,
                agp_protocolli_dati_accesso da
          WHERE     d.id_documento_esterno = p_id_documento_esterno
                AND (   da.id_protocollo_domanda = d.id_documento
                     OR da.id_protocollo_risposta = d.id_documento)
                AND u.progr = da.unita_competente_progr
                AND u.dal = da.unita_competente_dal
                AND u.ottica = da.unita_competente_ottica
                AND p_tipo = 'UNITA_COMPETENTE'
         UNION
         SELECT u.progr progr_unita_organizzativa,
                u.codice,
                u.dal,
                ottica,
                   LPAD (TO_CHAR (progr), 10, '0')
                || TO_CHAR (dal, 'dd/mm/yyyy')
                || ottica
                   unita,
                u.codice || ' - ' || u.descrizione nome
           FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB u,
                gdo_documenti d,
                agp_protocolli_dati_accesso da
          WHERE     d.id_documento_esterno = p_id_documento_esterno
                AND (   da.id_protocollo_domanda = d.id_documento
                     OR da.id_protocollo_risposta = d.id_documento)
                AND u.progr = da.unita_comp_riesame_progr
                AND u.dal = da.unita_comp_riesame_dal
                AND u.ottica = da.unita_comp_riesame_ottica
                AND p_tipo = 'UNITA_COMPETENTE_RIESAME';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                  'get_unita_dati_accesso: ' || SQLERRM);
   END;

   FUNCTION get_unita_competente (p_id_documento_esterno NUMBER)
      RETURN afc.t_ref_cursor
   IS
   BEGIN
      RETURN get_unita(p_id_documento_esterno, 'UNITA_COMPETENTE');
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                  'get_unita_competente: ' || SQLERRM);
   END;

   FUNCTION get_unita_riesame (p_id_documento_esterno NUMBER)
      RETURN afc.t_ref_cursor
   IS
   BEGIN
      RETURN get_unita(p_id_documento_esterno, 'UNITA_COMPETENTE_RIESAME');
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                  'get_unita_riesame: ' || SQLERRM);
   END;
END;
/
