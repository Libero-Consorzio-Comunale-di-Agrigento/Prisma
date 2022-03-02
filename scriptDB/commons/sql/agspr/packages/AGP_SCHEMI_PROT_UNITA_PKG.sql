--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_SCHEMI_PROT_UNITA_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_SCHEMI_PROT_UNITA_PKG
IS
   /******************************************************************************
    NOME:        AGP_SCHEMI_PROT_UNITA_PKG
    DESCRIZIONE: Gestione tabella AGP_SCHEMI_PROT_UNITA.
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

   PROCEDURE upd (p_id_schema_prot_unita NUMBER, p_codice VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_SCHEMI_PROT_UNITA_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_SCHEMI_PROT_UNITA_PKG
    DESCRIZIONEp_ Gestione tabella AGP_SCHEMI_PROT_UNITA.
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

   PROCEDURE upd (p_id_schema_prot_unita NUMBER, p_codice VARCHAR2)
   IS
   BEGIN
      UPDATE gdm_unita_tipi_doc
         SET unita = p_codice
       WHERE id_documento = -p_id_schema_prot_unita;
   END;
END;
/
