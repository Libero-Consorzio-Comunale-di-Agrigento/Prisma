--liquibase formatted sql
--changeset mmalferrari:AGSPR_PACKAGE_REVINFO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE REVINFO_PKG
IS
   /******************************************************************************
    NOME:        REVINFO_PKG
    DESCRIZIONE: Gestione revisione envers.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    10/07/2020    mmalferrari    Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION crea_revinfo (p_data TIMESTAMP, p_rev NUMBER DEFAULT NULL)
      RETURN NUMBER;

   PROCEDURE del_revinfo (p_rev NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY REVINFO_PKG
IS
   /******************************************************************************
    NOME        REVINFO_PKG
    DESCRIZIONE Gestione revisione envers.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   10/07/2020    mmalferrari   Prima emissione.
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
    NOTE:        Primo numero  p_ versione compatibilità del Package.
                 Secondo numerop_ revisione del Package specification.
                 Terzo numero  p_ revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------

   FUNCTION crea_revinfo (p_data TIMESTAMP, p_rev NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      d_id_rev   NUMBER;
   BEGIN
      IF p_rev IS NULL
      THEN
         SELECT hibernate_sequence.NEXTVAL INTO d_id_rev FROM DUAL;
      --d_id_rev := hibernate_sequence.NEXTVAL;
      ELSE
         d_id_rev := p_rev;
      END IF;

      INSERT INTO REVINFO (REV, REVTSTMP)
           VALUES (d_id_rev, p_data);

      RETURN d_id_rev;
   END;

   PROCEDURE del_revinfo (p_rev NUMBER)
   IS
   BEGIN
      DELETE REVINFO
       WHERE rev = p_rev;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'Errore in cancellazione rev: ' || p_rev || '. ' || SQLERRM);
   END;
END;
/
