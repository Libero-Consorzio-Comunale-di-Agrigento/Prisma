--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_TIPI_PROTOCOLLO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_TIPI_PROTOCOLLO_PKG
IS
   /******************************************************************************
    NOME:        AGP_TIPI_PROTOCOLLO_PKG
    DESCRIZIONE: Gestione tabella AGP_TIPI_PROTOCOLLO.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    01/06/2017    mmalferrari    Prima emissione.
    01    20/12/2017    RDestasio      Modificata ins.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.01';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION ins (p_id_ente                      NUMBER,
                 p_descrizione                  VARCHAR2,
                 p_commento                     VARCHAR2,
                 p_conservazione_sostitutiva    VARCHAR2,
                 p_progressivo_cfg_iter         NUMBER,
                 p_testo_obbligatorio           VARCHAR2,
                 p_id_tipologia_soggetto        NUMBER,
                 p_valido                       VARCHAR2,
                 p_utente_ins                   VARCHAR2,
                 p_data_ins                     DATE,
                 p_codice                       VARCHAR2,
                 p_acronimo                     VARCHAR2,
                 p_funz_obbligatorio            VARCHAR2,
                 p_id_tipo_registro             NUMBER,
                 p_categoria                    VARCHAR2,
                 p_unita_dest_progr             NUMBER,
                 p_unita_dest_dal               DATE,
                 p_unita_dest_ottica            VARCHAR2,
                 p_ruolo_unita_dest             VARCHAR2,
                 p_movimento                    VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_tipi_protocollo (p_id_ente NUMBER, p_categoria VARCHAR2)
      RETURN AFC.T_REF_CURSOR;

   FUNCTION get_tipi_protocollo (p_codice_amm    VARCHAR2,
                                 p_codice_aoo    VARCHAR2,
                                 p_categoria     VARCHAR2)
      RETURN AFC.T_REF_CURSOR;

   FUNCTION get_codice (p_id_tipo_protocollo NUMBER, p_id_ente NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_codice (p_id_tipo_protocollo    NUMBER,
                        p_codice_amm            VARCHAR2,
                        p_codice_aoo            VARCHAR2)
      RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_TIPI_PROTOCOLLO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_TIPI_PROTOCOLLO_PKG
    DESCRIZIONEp_ Gestione tabella AGP_TIPI_PROTOCOLLO.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   01/06/2017    mmalferrari   Prima emissione.
    001   20/12/2017    RDestasio     Modificata ins.
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

   FUNCTION ins (p_id_ente                      NUMBER,
                 p_descrizione                  VARCHAR2,
                 p_commento                     VARCHAR2,
                 p_conservazione_sostitutiva    VARCHAR2,
                 p_progressivo_cfg_iter         NUMBER,
                 p_testo_obbligatorio           VARCHAR2,
                 p_id_tipologia_soggetto        NUMBER,
                 p_valido                       VARCHAR2,
                 p_utente_ins                   VARCHAR2,
                 p_data_ins                     DATE,
                 p_codice                       VARCHAR2,
                 p_acronimo                     VARCHAR2,
                 p_funz_obbligatorio            VARCHAR2,
                 p_id_tipo_registro             NUMBER,
                 p_categoria                    VARCHAR2,
                 p_unita_dest_progr             NUMBER,
                 p_unita_dest_dal               DATE,
                 p_unita_dest_ottica            VARCHAR2,
                 p_ruolo_unita_dest             VARCHAR2,
                 p_movimento                    VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      SELECT HIBERNATE_SEQUENCE.NEXTVAL INTO d_return FROM DUAL;

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
                   P_ID_ENTE,
                   P_DESCRIZIONE,
                   P_COMMENTO,
                   P_CONSERVAZIONE_SOSTITUTIVA,
                   P_PROGRESSIVO_CFG_ITER,
                   P_TESTO_OBBLIGATORIO,
                   P_ID_TIPOLOGIA_SOGGETTO,
                   P_VALIDO,
                   P_UTENTE_INS,
                   NVL (P_DATA_INS, SYSDATE),
                   P_UTENTE_INS,
                   NVL (P_DATA_INS, SYSDATE),
                   0,
                   P_CODICE,
                   P_ACRONIMO);

      INSERT INTO AGP_TIPI_PROTOCOLLO (ID_TIPO_PROTOCOLLO,
                                       FUNZ_OBBLIGATORIO,
                                       ID_TIPO_REGISTRO,
                                       CATEGORIA,
                                       UNITA_DEST_PROGR,
                                       UNITA_DEST_DAL,
                                       UNITA_DEST_OTTICA,
                                       ruolo_unita_dest,
                                       MOVIMENTO)
           VALUES (d_return,
                   P_FUNZ_OBBLIGATORIO,
                   P_ID_TIPO_REGISTRO,
                   P_CATEGORIA,
                   p_unita_dest_progr,
                   p_unita_dest_dal,
                   p_unita_dest_ottica,
                   p_ruolo_unita_dest,
                   P_MOVIMENTO);

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_codice (p_id_tipo_protocollo NUMBER, p_id_ente NUMBER)
      RETURN VARCHAR2
   IS
      d_result   VARCHAR2 (255);
   BEGIN
      IF p_id_tipo_protocollo IS NOT NULL
      THEN
         SELECT gdo_tipi_documento.codice
           INTO d_result
           FROM agp_tipi_protocollo, gdo_tipi_documento
          WHERE     agp_tipi_protocollo.id_tipo_protocollo =
                       gdo_tipi_documento.id_tipo_documento
                AND gdo_tipi_documento.id_ente = p_id_ente
                --    AND gdo_tipi_documento.valido = 'Y'
                AND AGP_TIPI_PROTOCOLLO.ID_TIPO_PROTOCOLLO =
                       p_id_tipo_protocollo;
      END IF;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AGP_TIPI_PROTOCOLLO_PKG.get_codice: '
            || SQLERRM
            || ' id_tipo_protocollo '
            || p_id_tipo_protocollo
            || ' e id_ente '
            || p_id_ente);
   END;

   FUNCTION get_codice (p_id_tipo_protocollo    NUMBER,
                        p_codice_amm            VARCHAR2,
                        p_codice_aoo            VARCHAR2)
      RETURN VARCHAR2
   IS
      d_id_ente   NUMBER;
      d_return    VARCHAR2 (255);
   BEGIN
      IF p_id_tipo_protocollo IS NOT NULL
      THEN
         d_id_ente := agp_utility_pkg.get_id_ente (p_codice_amm, p_codice_aoo);
         d_return := get_codice (p_id_tipo_protocollo, d_id_ente);
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_tipi_protocollo (p_id_ente NUMBER, p_categoria VARCHAR2)
      RETURN AFC.T_REF_CURSOR
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT gdo_tipi_documento.id_tipo_documento,
                  gdo_tipi_documento.codice,
                  gdo_tipi_documento.descrizione
             FROM agp_tipi_protocollo,
                  gdo_tipi_documento,
                  agp_schemi_protocollo
            WHERE     agp_tipi_protocollo.id_tipo_protocollo =
                         gdo_tipi_documento.id_tipo_documento
                  AND gdo_tipi_documento.id_ente = p_id_ente
                  AND gdo_tipi_documento.valido = 'Y'
                  AND agp_tipi_protocollo.categoria = p_categoria
                  AND agp_schemi_protocollo.id_schema_protocollo(+) =
                         agp_tipi_protocollo.id_schema_protocollo
                  AND NVL (agp_schemi_protocollo.risposta, 'N') = 'N'
                  AND NVL (agp_tipi_protocollo.movimento, 'PARTENZA') =
                         DECODE (
                            p_categoria,
                            'LETTERA', 'PARTENZA',
                            NVL (agp_tipi_protocollo.movimento, 'PARTENZA'))
         ORDER BY gdo_tipi_documento.descrizione ASC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_TIPI_PROTOCOLLO_PKG.get_tipi_protocollo: ' || SQLERRM);
   END;

   FUNCTION get_tipi_protocollo (p_codice_amm    VARCHAR2,
                                 p_codice_aoo    VARCHAR2,
                                 p_categoria     VARCHAR2)
      RETURN AFC.T_REF_CURSOR
   IS
      d_result    afc.t_ref_cursor;
      d_id_ente   NUMBER;
   BEGIN
      d_id_ente := agp_utility_pkg.get_id_ente (p_codice_amm, p_codice_aoo);

      RETURN get_tipi_protocollo (d_id_ente, p_categoria);
   END;
END;
/
