--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_SCHEMI_PROTOCOLLO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_SCHEMI_PROTOCOLLO_PKG
IS
   /******************************************************************************
    NOME:        AGP_SCHEMI_PROTOCOLLO_PKG
    DESCRIZIONE: Gestione tabella AGP_SCHEMI_PROTOCOLLO.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    30/06/2017    SC             Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION is_associato_flusso (p_id_schema_protocollo number default null, p_id_documento_esterno number default null)
      RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY AGP_SCHEMI_PROTOCOLLO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_SCHEMI_PROTOCOLLO_PKG
    DESCRIZIONEp_ Gestione tabella AGP_SCHEMI_PROTOCOLLO.
    ANNOTAZIONIp_ .
    REVISIONIp_   .
    Rev.  Data          Autore        Descrizione.
    000   30/06/2017    SC            Prima emissione.
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '000';

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

   FUNCTION is_associato_flusso (p_id_schema_protocollo    NUMBER,
                                 p_id_documento_esterno    NUMBER)
      RETURN NUMBER
   IS
      d_return                 NUMBER := 0;
      d_id_schema_protocollo   NUMBER;
   BEGIN
      IF p_id_schema_protocollo IS NULL AND p_id_documento_esterno IS NULL
      THEN
         raise_application_error (
            -20999,
            'Specificare identificativo o identificativo esterno dello schema di protocollo.');
      END IF;

      SELECT DISTINCT 1
        INTO d_return
        FROM agp_tipi_protocollo tipr
       WHERE tipr.id_schema_protocollo IN (SELECT id_schema_protocollo
                                             FROM agp_schemi_protocollo
                                            WHERE id_schema_protocollo =
                                                         p_id_schema_protocollo
                                           UNION
                                           SELECT id_schema_protocollo
                                             FROM agp_schemi_protocollo
                                            WHERE     p_id_schema_protocollo IS NULL
                                                  AND id_documento_esterno =
                                                         p_id_documento_esterno);

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;
END;
/
