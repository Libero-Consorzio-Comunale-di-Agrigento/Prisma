--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_TIPI_FRASE_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_TIPI_FRASE_UTILITY
IS
   /******************************************************************************
    NOME:        AG_TIPI_FRASE_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_TIPI_FRASE.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  25/10/2017 SC     Creazione.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_codice (p_id_tipo_frase NUMBER)
      RETURN VARCHAR2;

   FUNCTION crea (p_tipo_frase                VARCHAR2,
                  p_oggetto                   VARCHAR2,
                  p_codice_amministrazione    VARCHAR2,
                  p_codice_aoo                VARCHAR2,
                  p_utente                    VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_TIPI_FRASE_UTILITY
IS
   /******************************************************************************
    NOME:        AG_TIPI_FRASE_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_TIPI_FRASE.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000   25/10/2017 SC     Creazione.
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

   FUNCTION get_codice (p_id_tipo_frase number) return varchar2
   as
   ret SEG_TIPI_FRASE.TIPO_FRASE%TYPE;
   begin
        select tipo_frase
          into ret
          from seg_tipi_frase
         where id_documento = p_id_tipo_frase;
         return ret;
   exception
   when others then
        ret := null;
        return ret;
   end;

   FUNCTION crea (p_tipo_frase                 VARCHAR2,
                  p_oggetto                     VARCHAR2,
                  p_codice_amministrazione      VARCHAR2,
                  p_codice_aoo                  VARCHAR2,
                  p_utente                      VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_nuovo           NUMBER;
   BEGIN
      IF p_tipo_frase IS NULL OR p_oggetto IS NULL
      THEN
         raise_application_error (
            -20999,
            'Indicare almeno il codice (p_tipo_frase) e l''oggetto (p_oggetto).');
      END IF;

      dep_id_nuovo :=
         gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                     p_modello                   => 'DIZ_TIPI_FRASE',
                                     p_cr                        => NULL,
                                     p_utente                    => p_utente,
                                     p_crea_record_orizzontale   => 1);


      UPDATE seg_tipi_frase
         SET tipo_frase = p_tipo_frase,
             oggetto = p_oggetto,
             --dataval_dal = TRUNC (p_dataval_dal),
             --dataval_al = TRUNC (p_dataval_al),
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
