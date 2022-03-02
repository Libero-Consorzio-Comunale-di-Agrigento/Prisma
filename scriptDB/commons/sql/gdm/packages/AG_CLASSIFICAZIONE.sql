--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_CLASSIFICAZIONE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_CLASSIFICAZIONE"
IS
   /******************************************************************************
    NOME:        AG_CLASSIFICAZIONE
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI
                 per la gestine delle classificazioni
    ANNOTAZIONI: Consente la gestione di eventuali personalizzazioni.
                 Creato per la provincia di Piacenza che codifica le classificazioni
                 utilizzando anche i numeri romani.
    REVISIONI:   .

    Rev.  Data       Autore  Descrizione.
    00    05/06/2008 SN      Prima emissione.
    01    25/08/2015 MM      Creata get_id_cartella
   ******************************************************************************/
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.01';

   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   FUNCTION converti_romano (p_numero_romano VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (converti_romano, WNDS);

   FUNCTION get_descrizione (p_class_cod     VARCHAR2,
                             p_class_dal     VARCHAR2,
                             p_codice_amm    VARCHAR2,
                             p_codice_aoo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION sottoclasse_con_fascicoli (p_class_cod     VARCHAR2,
                                       p_codice_amm    VARCHAR2,
                                       p_codice_aoo    VARCHAR2,
                                       p_separatore    VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_id_cartella (p_class_cod     VARCHAR2,
                             p_class_dal     DATE,
                             p_codice_amm    VARCHAR2,
                             p_codice_aoo    VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_id_cartella (p_class_cod     VARCHAR2,
                             p_class_dal     VARCHAR2,
                             p_codice_amm    VARCHAR2,
                             p_codice_aoo    VARCHAR2)
      RETURN NUMBER;
END ag_classificazione;
/
CREATE OR REPLACE PACKAGE BODY "AG_CLASSIFICAZIONE"
IS
   s_revisione_body   afc.t_revision := '001';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
   NOME:        versione
   DESCRIZIONE: Versione e revisione di distribuzione del package.
   RITORNA:     varchar2 stringa contenente versione e revisione.
   NOTE:        Primo numero  : versione compatibilità del Package.
                Secondo numero: revisione del Package specification.
                Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END;

   FUNCTION converti_romano (p_numero_romano VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NAME:       converti_romano
       PURPOSE:    Restituisce il numero arabo corrispondente al numero romano
                   passato come parametro.

       PARAMETER: p_numero_romano
                  numero romano da convertire

       NOTE:      Utilizzata nelle stampe personalizzate per la provincia di Piacenza.
                  Al momento converte i primi 20 numeri romani.

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        04/06/2008  SN               A26891.1.0

      ******************************************************************************/
      d_numero_arabo    VARCHAR2 (2000) := '';
      d_numero_romano   VARCHAR2 (2000) := '';
      i                 INTEGER := 1;
   BEGIN
      WHILE i <= 20
      LOOP
         SELECT TO_CHAR (i, 'RN') INTO d_numero_romano FROM DUAL;

         IF TRIM (UPPER (p_numero_romano)) = TRIM (UPPER (d_numero_romano))
         THEN
            d_numero_arabo := LPAD (TO_CHAR (i), 7, '0');
            EXIT;
         END IF;

         i := i + 1;
      END LOOP;

      RETURN d_numero_arabo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_descrizione (p_class_cod     VARCHAR2,
                             p_class_dal     VARCHAR2,
                             p_codice_amm    VARCHAR2,
                             p_codice_aoo    VARCHAR2)
      RETURN VARCHAR2
   IS
      /****************************************************************************
         NOME:        GET_DESCRIZIONE
         DESCRIZIONE: utilizzata per le query di conservazione

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         001   14/08/2015 LT      Prima emissione.
      ****************************************************************************/
      d_result      VARCHAR2 (4000);
      d_class_dal   DATE := TO_DATE (p_class_dal, 'dd/mm/yyyy');
   BEGIN
      SELECT clas.class_descr
        INTO d_result
        FROM seg_classificazioni clas, cartelle cart_clas
       WHERE     class_cod = p_class_cod
             AND class_dal = d_class_dal
             AND codice_amministrazione = p_codice_amm
             AND codice_aoo = p_codice_aoo
             AND cart_clas.id_documento_profilo = clas.id_documento
             AND NVL (cart_clas.stato, 'BO') <> 'CA';

      RETURN d_result;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN d_result;
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_CLASSIFICAZIONE.GET_DESCRIZIONE: ' || SQLERRM);
   END;

   FUNCTION get_id_cartella (p_class_cod     VARCHAR2,
                             p_class_dal     DATE,
                             p_codice_amm    VARCHAR2,
                             p_codice_aoo    VARCHAR2)
      RETURN NUMBER
   IS
      /****************************************************************************
         NOME:        GET_ID_CARTELLA
         DESCRIZIONE: restituisce l'id della cartella corrispondente alla classifica.

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         001   25/08/2015 MM      Prima emissione.
      ****************************************************************************/
      d_result   NUMBER;
   BEGIN
      SELECT cart_clas.id_cartella
        INTO d_result
        FROM seg_classificazioni clas, cartelle cart_clas
       WHERE     class_cod = p_class_cod
             AND class_dal = p_class_dal
             AND codice_amministrazione = p_codice_amm
             AND codice_aoo = p_codice_aoo
             AND cart_clas.id_documento_profilo = clas.id_documento
             AND NVL (cart_clas.stato, 'BO') <> 'CA';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_CLASSIFICAZIONE.GET_ID_CARTELLA: ' || SQLERRM);
   END;

   FUNCTION get_id_cartella (p_class_cod     VARCHAR2,
                             p_class_dal     VARCHAR2,
                             p_codice_amm    VARCHAR2,
                             p_codice_aoo    VARCHAR2)
      RETURN NUMBER
   IS
      d_class_dal   DATE := TO_DATE (p_class_dal, 'dd/mm/yyyy');
   BEGIN
      RETURN get_id_cartella (p_class_cod,
                              d_class_dal,
                              p_codice_amm,
                              p_codice_aoo);
   END;

   FUNCTION sottoclasse_con_fascicoli (p_class_cod     VARCHAR2,
                                       p_codice_amm    VARCHAR2,
                                       p_codice_aoo    VARCHAR2,
                                       p_separatore    VARCHAR2)
      RETURN NUMBER
   IS
      /******************************************************************************
       NAME:       sottoclasse_con_fascicoli
       PURPOSE:    Restituisce 1 se la sottoclasse contiene slmeno un fascicolo.

       PARAMETER:  Codice della classificazione, codice dell amministrazione,
                   codice dell aoo e separatore utilizzato nelle classificazioni

       NOTE:       Viene utilizzata nel report stampa_titolario_ppc personalizzato
                   per la provincia di piacenza. Il parametro p_separatore serve
                   per rendere la query più veloce. La ricerca viene effettuata sulle
                   sole classificazioni valide

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        10/06/2008  SN               A26891.1.0

      ******************************************************************************/
      esiste   INTEGER := 0;
   BEGIN
      SELECT 1
        INTO esiste
        FROM DUAL
       WHERE EXISTS
                (SELECT 1
                   FROM SEG_CLASSIFICAZIONI SECL
                  WHERE     NVL (class_al, TRUNC (SYSDATE)) >=
                               TRUNC (SYSDATE)
                        AND TRUNC (SYSDATE) BETWEEN secl.class_dal
                                                AND NVL (secl.class_al,
                                                         TRUNC (SYSDATE))
                        AND secl.class_cod LIKE
                               p_class_cod || p_separatore || '%'
                        AND secl.codice_amministrazione || '' = p_codice_amm
                        AND secl.codice_aoo || '' = p_codice_aoo);

      RETURN esiste;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;
END ag_classificazione;
/
