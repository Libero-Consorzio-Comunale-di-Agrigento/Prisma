--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_SPEC_AGP_DOCUMENTI_TITOLARIO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_DOCUMENTI_TITOLARIO_PKG
IS
   /******************************************************************************
    NOME:        AGP_DOCUMENTI_TITOLARIO_PKG
    DESCRIZIONE: Gestione TABELLA AGP_DOCUMENTI_TITOLARIO.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    24/04/2017    mmalferrari    Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   PROCEDURE inserisci (p_id_documento_esterno    NUMBER,
                        p_class_cod               VARCHAR2,
                        p_class_dal               DATE,
                        p_fascicolo_anno          NUMBER,
                        p_fascicolo_numero        VARCHAR2,
                        p_utente_ins              VARCHAR2);

   PROCEDURE elimina (p_id_documento_esterno    NUMBER,
                      p_class_cod               VARCHAR2,
                      p_class_dal               DATE,
                      p_fascicolo_anno          NUMBER,
                      p_fascicolo_numero        VARCHAR2,
                      p_utente_upd              VARCHAR2);
END;
/
