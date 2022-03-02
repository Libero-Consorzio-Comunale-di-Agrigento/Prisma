--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_GDO_IMPOSTAZIONI_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE gdo_impostazioni_pkg
AS
   /******************************************************************************
      NAME:       gdo_impostazioni_pkg
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.00       18/02/2014      esasdelli       1. Created this package.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   PROCEDURE add_impostazione (p_codice            IN VARCHAR2,
                               p_descrizione       IN VARCHAR2,
                               p_etichetta         IN VARCHAR2,
                               p_predefinito       IN VARCHAR2,
                               p_caratteristiche   IN VARCHAR2);

   FUNCTION get_impostazione (p_codice IN VARCHAR2, p_id_ente IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE set_impostazione (p_codice    IN VARCHAR2,
                               p_id_ente   IN NUMBER,
                               p_valore    IN VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY gdo_impostazioni_pkg
IS
   /******************************************************************************
    NOMEp_        GDO_IMPOSTAZIONI_PKG
    DESCRIZIONE: Gestione tabella GDO_IMPOSTAZIONI.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   18/02/2014    esasdelli     Prima emissione.
    001   09/11/2017    mmalferrari   Modificata get_impostazione
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '001';

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

   PROCEDURE add_impostazione (p_codice            IN VARCHAR2,
                               p_descrizione       IN VARCHAR2,
                               p_etichetta         IN VARCHAR2,
                               p_predefinito       IN VARCHAR2,
                               p_caratteristiche   IN VARCHAR2)
   /******************************************************************************
   NOME:        add_impostazione
   DESCRIZIONE: aggiunge una nuova impostazione se non gi¿ presente.
   PARAMETRI:
   ******************************************************************************/
   IS
   BEGIN
      FOR c IN (SELECT id_ente
                  FROM gdo_impostazioni
                 WHERE codice = 'OTTICA_SO4')
      LOOP
         MERGE INTO gdo_impostazioni A
              USING (SELECT p_codice AS CODICE,
                            c.id_ente AS ID_ENTE,
                            1 AS VERSION,
                            p_caratteristiche AS CARATTERISTICHE,
                            p_descrizione AS DESCRIZIONE,
                            p_etichetta AS ETICHETTA,
                            p_predefinito AS PREDEFINITO,
                            p_predefinito AS VALORE
                       FROM DUAL) B
                 ON (A.CODICE = B.CODICE AND A.ID_ENTE = B.ID_ENTE)
         WHEN NOT MATCHED
         THEN
            INSERT     (CODICE,
                        ID_ENTE,
                        VERSION,
                        CARATTERISTICHE,
                        DESCRIZIONE,
                        ETICHETTA,
                        PREDEFINITO,
                        VALORE)
                VALUES (B.CODICE,
                        B.ID_ENTE,
                        B.VERSION,
                        B.CARATTERISTICHE,
                        B.DESCRIZIONE,
                        B.ETICHETTA,
                        B.PREDEFINITO,
                        B.VALORE)
         WHEN MATCHED
         THEN
            UPDATE SET A.VERSION = B.VERSION,
                       A.CARATTERISTICHE = B.CARATTERISTICHE,
                       A.DESCRIZIONE = B.DESCRIZIONE,
                       A.ETICHETTA = B.ETICHETTA,
                       A.PREDEFINITO = B.PREDEFINITO;
      END LOOP;
   END;

   FUNCTION get_impostazione (p_codice IN VARCHAR2, p_id_ente IN NUMBER)
      RETURN VARCHAR2
   /******************************************************************************
   NOME:        get_impostazione
   DESCRIZIONE: restituisce il valore dell'impostazione per l'ente specificato.
   PARAMETRI:   --
   RITORNA:     STRINGA VARCHAR2 CONTENENTE VERSIONE E DATA.
   NOTE:        IL SECONDO NUMERO DELLA VERSIONE CORRISPONDE ALLA REVISIONE
   DEL PACKAGE.
   ******************************************************************************/
   IS
      d_valore_impostazione   gdo_impostazioni.VALORE%TYPE;
   BEGIN
      BEGIN
         SELECT valore
           INTO d_valore_impostazione
           FROM gdo_impostazioni i
          WHERE i.id_ente = p_id_ente AND i.codice = p_codice;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT valore
              INTO d_valore_impostazione
              FROM gdo_impostazioni i
             WHERE i.id_ente IS NULL AND i.codice = p_codice;
      END;

      RETURN d_valore_impostazione;
   END get_impostazione;

   PROCEDURE set_impostazione (p_codice    IN VARCHAR2,
                               p_id_ente   IN NUMBER,
                               p_valore    IN VARCHAR2)
   /******************************************************************************
   NOME:        set_impostazione
   DESCRIZIONE: imposta il valore dell'impostazione per l'ente specificato.
                se l'ente ha valore NULL, allora il valore dell'impostazione viene settato per tutti gli enti.
   PARAMETRI:   --
   RITORNA:     STRINGA VARCHAR2 CONTENENTE VERSIONE E DATA.
   NOTE:        IL SECONDO NUMERO DELLA VERSIONE CORRISPONDE ALLA REVISIONE
   DEL PACKAGE.
   ******************************************************************************/
   IS
   BEGIN
      FOR c
         IN (SELECT id_ente
               FROM gdo_impostazioni
              WHERE     codice = 'OTTICA_SO4'
                    AND (id_ente = p_id_ente OR p_id_ente IS NULL))
      LOOP
         UPDATE gdo_impostazioni
            SET valore = p_valore
          WHERE codice = p_codice AND id_ente = c.id_ente;
      END LOOP;
   END set_impostazione;
END;
/
