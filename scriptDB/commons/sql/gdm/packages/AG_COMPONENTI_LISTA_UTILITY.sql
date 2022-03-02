--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPONENTI_LISTA_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_COMPONENTI_LISTA_UTILITY
IS
/******************************************************************************
 NOME:        AG_LISTE_DIST_UTILITY
 DESCRIZIONE: Procedure e Funzioni della tabella SEG_COMPONENTI_LISTA.
 ANNOTAZIONI: Progetto AFFARI_GENERALI.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  05/04/2018 SC     Creazione.
******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   function crea (p_codice                      VARCHAR2,
                  p_cod_amm                     VARCHAR2,
                  p_cod_aoo                     VARCHAR2,
                  p_cod_uo                      VARCHAR2,
                  p_ni                          VARCHAR2,
                  p_id_recapito                 NUMBER,
                  p_id_contatto                 NUMBER,
                  p_cap_per_segnatura           VARCHAR2,
                  p_cf_per_segnatura            VARCHAR2,
                  p_denominazione               VARCHAR2,
                  p_cognome                     VARCHAR2,
                  p_nome                        VARCHAR2,
                  p_comune_per_segnatura        VARCHAR2,
                  p_email                       VARCHAR2,
                  p_fax                         VARCHAR2,
                  p_indirizzo_per_segnatura     VARCHAR2,
                  p_partita_iva                 VARCHAR2,
                  p_provincia_per_segnatura     VARCHAR2,
                  p_codice_amministrazione      VARCHAR2,
                  p_codice_aoo                  VARCHAR2,
                  p_utente                      VARCHAR2)
      return number;

END;
/
CREATE OR REPLACE PACKAGE BODY AG_COMPONENTI_LISTA_UTILITY
IS
   /******************************************************************************
    NOME:        AG_COMPONENTI_LISTA_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_COMPONENTI_LISTA.
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

   FUNCTION crea (p_codice                      VARCHAR2,
                  p_cod_amm                     VARCHAR2,
                  p_cod_aoo                     VARCHAR2,
                  p_cod_uo                      VARCHAR2,
                  p_ni                          VARCHAR2,
                  p_id_recapito                 NUMBER,
                  p_id_contatto                 NUMBER,
                  p_cap_per_segnatura           VARCHAR2,
                  p_cf_per_segnatura            VARCHAR2,
                  p_denominazione               VARCHAR2,
                  p_cognome                     VARCHAR2,
                  p_nome                        VARCHAR2,
                  p_comune_per_segnatura        VARCHAR2,
                  p_email                       VARCHAR2,
                  p_fax                         VARCHAR2,
                  p_indirizzo_per_segnatura     VARCHAR2,
                  p_partita_iva                 VARCHAR2,
                  p_provincia_per_segnatura     VARCHAR2,
                  p_codice_amministrazione      VARCHAR2,
                  p_codice_aoo                  VARCHAR2,
                  p_utente                      VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_nuovo           NUMBER;
   BEGIN
      IF p_codice IS NULL
      THEN
         raise_application_error (
            -20999,
            'Indicare il codice (p_codice) della lista.');
      END IF;

      IF p_cod_amm IS NULL
      AND p_ni IS NULL
      THEN
         raise_application_error (
            -20999,
            'Indicare almeno il codice amministrazione (p_cod_amm) o un indentificativo soggetto (p_ni).');
      END IF;

      dep_id_nuovo :=
         gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                     p_modello                   => 'M_COMPONENTE_LISTA_DISTRIBUZIONE',
                                     p_cr                        => NULL,
                                     p_utente                    => p_utente,
                                     p_crea_record_orizzontale   => 1);


      UPDATE seg_componenti_lista
         SET CODICE_LISTA_DISTRIBUZIONE = p_codice,
             COD_AMM                    = p_cod_amm                     ,
             COD_AOO                    = p_cod_aoo,
             COD_UO                     = p_cod_uo,
             NI                         = p_ni,
             ID_RECAPITO_AS4            = p_id_recapito,
             ID_CONTATTO_AS4            = p_id_contatto,
             codice_amministrazione     = p_codice_amministrazione,
             codice_aoo                 = p_codice_aoo,
             cap_per_segnatura          = p_cap_per_segnatura,
             cf_per_segnatura           = p_cf_per_segnatura,
             denominazione_soggetti     = p_denominazione,
             cognome_per_segnatura      = p_cognome,
             nome_per_segnatura         = p_nome,
             comune_per_segnatura       = p_comune_per_segnatura,
             email                      = p_email,
             fax                        = p_fax,
             indirizzo_per_segnatura    = p_indirizzo_per_segnatura,
             partita_iva                = p_partita_iva,
             provincia_per_segnatura    = p_provincia_per_segnatura
       WHERE id_documento = dep_id_nuovo;

      RETURN dep_id_nuovo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

END;
/
