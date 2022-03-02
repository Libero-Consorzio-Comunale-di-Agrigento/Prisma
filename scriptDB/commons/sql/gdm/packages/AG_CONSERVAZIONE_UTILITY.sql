--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_CONSERVAZIONE_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_CONSERVAZIONE_UTILITY AS
/******************************************************************************
   NAME:       AG_CONSERVAZIONE_UTILITY
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/03/2012      MMurabito       1. Created this package.
******************************************************************************/

   s_revisione          CONSTANT VARCHAR2 (40) := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

  FUNCTION get_mittenti(
      p_idRIF IN   VARCHAR2
   )
      RETURN VARCHAR2;

  FUNCTION get_destinatari(
      p_idRIF IN   VARCHAR2
   )
      RETURN VARCHAR2;

END AG_CONSERVAZIONE_UTILITY;
/
CREATE OR REPLACE PACKAGE BODY AG_CONSERVAZIONE_UTILITY
AS
   /******************************************************************************
      NAME:       AG_CONSERVAZIONE_UTILITY
      PURPOSE:
      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/03/2012      MMurabito       1. Created this package.
      002        02/10/2019      SC              Feature #37260 Conservazione
                                              unimatica: stringa troppo lunga
                                              per i mitt/dest.
                                              Parametrizza la lunghezza max
                                              accettata.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '002';

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

   /******************************************************************************
      NAME:       get_corrispondenti
      PURPOSE:
      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      002        02/10/2019      SC              Feature #37260 Conservazione
                                              unimatica: stringa troppo lunga
                                              per i mitt/dest.
                                              Parametrizza la lunghezza max
                                              accettata.
   ******************************************************************************/
   FUNCTION get_corrispondenti (p_idrif VARCHAR2, p_tipo VARCHAR2)
      RETURN VARCHAR2
   IS
      retval           VARCHAR2 (4000);
      d_result         afc.t_ref_cursor;
      d_corrispondente VARCHAR2(2000);
      denominazione    VARCHAR2 (2000);
      cf               VARCHAR2 (100);
      pi               VARCHAR2 (100);
      d_max_length     NUMBER;
      d_puntini        VARCHAR2 (3);--SI VALORIZZA SOLO SE SERVE
   BEGIN
      OPEN d_result FOR
         SELECT distinct nvl(denominazione, email) denominazione, codice_fiscale, partita_iva
         ,
                        ag_parametro.get_valore('CONS_RAPP_MAX_CHAR',
                        codice_amministrazione,
                        codice_aoo,
                        '4000',
                        '@agVar@')
           FROM documenti docu,
                (/*SELECT id_documento,
                        cognome_per_segnatura|| decode(nome_per_segnatura, null, '',  '  ' || nome_per_segnatura)
                           AS DENOMINAZIONE,
                        cf_per_segnatura CODICE_FISCALE,
                        partita_iva AS PARTITA_IVA,
                        email as email
                   FROM seg_soggetti_protocollo
                  WHERE     tipo_soggetto IN (1,5,7,8,9)
                        AND idrif = p_idrif
                        AND tipo_rapporto = p_tipo
                 UNION
                 SELECT id_documento,
                        descrizione_amm || decode(descrizione_aoo, null, '', '  ' || descrizione_aoo)
                           AS DENOMINAZIONE,
                        cf_per_segnatura CODICE_FISCALE,
                        partita_iva AS PARTITA_IVA,
                        email as email
                   FROM seg_soggetti_protocollo
                  WHERE     tipo_soggetto = 2
                        AND idrif = p_idrif
                        AND tipo_rapporto = p_tipo
                 UNION*/
                 SELECT id_documento,
                        denominazione_per_segnatura AS DENOMINAZIONE,
                        cf_per_segnatura AS CODICE_FISCALE,
                        partita_iva AS PARTITA_IVA,
                        email as email,
                        codice_amministrazione,
                        codice_aoo
                   FROM seg_soggetti_protocollo
                  WHERE     idrif = p_idrif
                        AND tipo_rapporto = p_tipo) dest
          WHERE     docu.id_documento = dest.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
               ORDER BY 1,2,3;

      LOOP
         FETCH d_result
         INTO denominazione, cf, pi, d_max_length;

         EXIT WHEN d_result%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE ('entra ' || denominazione);

         denominazione := trim(denominazione);
         IF denominazione IS NOT NULL
         THEN
            d_corrispondente :=
                denominazione || '#' || cf || '#' || pi || ';';

            IF NVL (LENGTH (retval), 0) + NVL (LENGTH (d_corrispondente), 0) <=
               d_max_length - 3
            THEN
                retVal := retval || d_corrispondente;
            ELSE
                d_puntini := '...';
                EXIT;
            END IF;
         END IF;
      END LOOP;

      retVal := retVal || d_puntini;

      RETURN retval;
   END;

   FUNCTION get_mittenti (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      retval          VARCHAR2 (4000);
      d_result        afc.t_ref_cursor;
      denominazione   VARCHAR2 (2000);
      cf              VARCHAR2 (100);
      pi              VARCHAR2 (100);
   BEGIN
      RETURN get_corrispondenti(p_idrif, 'MITT');
   END;

   FUNCTION get_destinatari (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_corrispondenti(p_idrif, 'DEST');
   END;

END AG_CONSERVAZIONE_UTILITY;
/
