--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_GDO_TIPI_ALLEGATO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE GDO_TIPI_ALLEGATO_PKG
IS
   /******************************************************************************
    NOME:        GDO_TIPI_ALLEGATO_PKG
    DESCRIZIONE: Gestione tabella GDO_TIPI_ALLEGATO.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    26/11/2018    mmalferrari   Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION ins (p_id_tipo_documento    NUMBER,
                 p_cod_amm              VARCHAR2,
                 p_cod_aoo              VARCHAR2,
                 p_descrizione          VARCHAR2,
                 p_commento             VARCHAR2,
                 p_acronimo             VARCHAR2,
                 p_stampa_unica         VARCHAR2,
                 p_valido               VARCHAR2,
                 p_utente_ins           VARCHAR2,
                 p_data_ins             DATE)
      RETURN NUMBER;

   PROCEDURE upd (p_id_tipo_documento    NUMBER,
                  p_acronimo             VARCHAR2,
                  p_descrizione          VARCHAR2,
                  p_commento             VARCHAR2,
                  p_stampa_unica         VARCHAR2,
                  p_valido               VARCHAR2,
                  p_utente_upd           VARCHAR2,
                  p_data_upd             DATE DEFAULT SYSDATE);

   PROCEDURE del (p_id_tipo_documento NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY GDO_TIPI_ALLEGATO_PKG
IS
   /******************************************************************************
    NOMEp_        GDO_TIPI_ALLEGATO_PKG
    DESCRIZIONE Gestione tabella GDO_TIPI_ALLEGATO.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   26/11/2018    mmalferrari   Prima emissione.
    001   19/11/2019    mmalferrari   Modificata get_id_ente
    002   09/01/2020    mmalferrari   Eliminata get_id_ente per utilizzare quella
                                      di agp_utility_pkg
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '002';

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

   FUNCTION ins (p_id_tipo_documento    NUMBER,
                 p_cod_amm              VARCHAR2,
                 p_cod_aoo              VARCHAR2,
                 p_descrizione          VARCHAR2,
                 p_commento             VARCHAR2,
                 p_acronimo             VARCHAR2,
                 p_stampa_unica         VARCHAR2,
                 p_valido               VARCHAR2,
                 p_utente_ins           VARCHAR2,
                 p_data_ins             DATE)
      RETURN NUMBER
   IS
      d_id_ente   NUMBER;
      d_return    NUMBER := p_id_tipo_documento;
   BEGIN
      IF d_return IS NULL
      THEN
         SELECT HIBERNATE_SEQUENCE.NEXTVAL INTO d_return FROM DUAL;
      END IF;

      d_id_ente := agp_utility_pkg.get_id_ente (p_cod_amm, p_cod_aoo);

      INSERT INTO GDO_TIPI_DOCUMENTO (ID_TIPO_DOCUMENTO,
                                      ID_ENTE,
                                      DESCRIZIONE,
                                      COMMENTO,
                                      CONSERVAZIONE_SOSTITUTIVA,
                                      PROGRESSIVO_CFG_ITER,
                                      TESTO_OBBLIGATORIO,
                                      ID_TIPOLOGIA_SOGGETTO,
                                      VALIDO,
                                      UTENTE_INS,
                                      DATA_INS,
                                      UTENTE_UPD,
                                      DATA_UPD,
                                      VERSION,
                                      CODICE,
                                      ACRONIMO)
           VALUES (d_return,
                   d_ID_ENTE,
                   P_DESCRIZIONE,
                   P_COMMENTO,
                   'Y',
                   NULL,
                   'N',
                   NULL,
                   P_VALIDO,
                   P_UTENTE_INS,
                   NVL (P_DATA_INS, SYSDATE),
                   P_UTENTE_INS,
                   NVL (P_DATA_INS, SYSDATE),
                   0,
                   'ALLEGATO',
                   P_ACRONIMO);

      INSERT INTO GDO_TIPI_ALLEGATO (ID_TIPO_DOCUMENTO, STAMPA_UNICA)
           VALUES (d_return, p_stampa_unica);

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE upd (p_id_tipo_documento    NUMBER,
                  p_acronimo             VARCHAR2,
                  p_descrizione          VARCHAR2,
                  p_commento             VARCHAR2,
                  p_stampa_unica         VARCHAR2,
                  p_valido               VARCHAR2,
                  p_utente_upd           VARCHAR2,
                  p_data_upd             DATE DEFAULT SYSDATE)
   IS
   BEGIN
      UPDATE GDO_TIPI_DOCUMENTO
         SET ACRONIMO = decode(p_acronimo, null, acronimo, p_acronimo),
             COMMENTO = decode(p_commento, null, commento, p_commento),
             DESCRIZIONE = decode(p_descrizione, null, descrizione, p_descrizione),
             VALIDO = decode(p_valido, null, valido, p_valido),
             DATA_UPD = p_data_upd,
             UTENTE_UPD = p_utente_upd
       WHERE ID_TIPO_DOCUMENTO = p_id_tipo_documento;

      UPDATE GDO_TIPI_ALLEGATO
         SET STAMPA_UNICA = decode(p_stampa_unica, null, stampa_unica, p_stampa_unica)
       WHERE ID_TIPO_DOCUMENTO = p_id_tipo_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE del (p_id_tipo_documento NUMBER)
   IS
   BEGIN
      delete GDO_TIPI_DOCUMENTO
       WHERE ID_TIPO_DOCUMENTO = p_id_tipo_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;
END;
/
