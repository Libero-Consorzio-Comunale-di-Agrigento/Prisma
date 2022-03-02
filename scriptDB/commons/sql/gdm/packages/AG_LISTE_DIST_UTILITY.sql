--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_LISTE_DIST_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_LISTE_DIST_UTILITY
IS
   /******************************************************************************
    NOME:        AG_LISTE_DIST_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_LISTE_DISTRIBUZIONE.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  05/04/2018 SC     Creazione.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_codice (p_id_lista NUMBER)
      RETURN VARCHAR2;

   FUNCTION crea (p_codice                    VARCHAR2,
                  p_descrizione               VARCHAR2,
                  p_codice_amministrazione    VARCHAR2,
                  p_codice_aoo                VARCHAR2,
                  p_utente                    VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_LISTE_DIST_UTILITY
IS
   /******************************************************************************
    NOME:        AG_LISTE_DIST_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_LISTE_DISTRIBUZIONE.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000   05/04/2018 SC     Creazione.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '000';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE; Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   FUNCTION get_codice (p_id_lista NUMBER)
      RETURN VARCHAR2
   AS
      ret   SEG_LISTE_DISTRIBUZIONE.CODICE_LISTA_DISTRIBUZIONE%TYPE;
   BEGIN
      SELECT CODICE_LISTA_DISTRIBUZIONE
        INTO ret
        FROM SEG_LISTE_DISTRIBUZIONE
       WHERE id_documento = p_id_lista;

      RETURN ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         ret := NULL;
         RETURN ret;
   END;

   FUNCTION crea (p_codice                    VARCHAR2,
                  p_descrizione               VARCHAR2,
                  p_codice_amministrazione    VARCHAR2,
                  p_codice_aoo                VARCHAR2,
                  p_utente                    VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_nuovo   NUMBER;
   BEGIN
      IF p_codice IS NULL OR p_descrizione IS NULL
      THEN
         raise_application_error (
            -20999,
            'Indicare almeno il codice (p_codice) e la descrizione (p_descrizione).');
      END IF;

      dep_id_nuovo :=
         gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                     p_modello                   => 'M_LISTA_DISTRIBUZIONE',
                                     p_cr                        => NULL,
                                     p_utente                    => p_utente,
                                     p_crea_record_orizzontale   => 1);


      UPDATE seg_liste_distribuzione
         SET CODICE_LISTA_DISTRIBUZIONE = p_codice,
             DES_LISTA_DISTRIBUZIONE = p_descrizione,
             codice_amministrazione = p_codice_amministrazione,
             codice_aoo = p_codice_aoo
       WHERE id_documento = dep_id_nuovo;

      RETURN dep_id_nuovo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;
END;
/
