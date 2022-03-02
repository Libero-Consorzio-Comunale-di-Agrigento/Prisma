--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UNZIP_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_unzip_utility
IS
/******************************************************************************
 NOME:        AG_UNZIP_UTILITY.
 DESCRIZIONE: Procedure e Funzioni di utility in fase di unzip documento.
 ANNOTAZIONI: Progetto AFFARI_GENERALI.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 00   27/01/2015 MM     Creazione.
******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;


END;
/
CREATE OR REPLACE PACKAGE BODY ag_unzip_utility
IS
/******************************************************************************
 NOME:        AG_UNZIP_UTILITY.
 DESCRIZIONE: Procedure e Funzioni di utility in fase di unzip documento.
 ANNOTAZIONI: Progetto AFFARI_GENERALI.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 00   27/01/2015 MM     Creazione.
******************************************************************************/
   s_revisione_body   afc.t_revision := '000';

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

   FUNCTION insert_oggetti_file
   ( p_id_documento number
   , p_idrif varchar2
   , p_is_principale number
   , p_nomefile varchar2)
   return number
   IS
   BEGIN
      null;
   END;
END;
/
