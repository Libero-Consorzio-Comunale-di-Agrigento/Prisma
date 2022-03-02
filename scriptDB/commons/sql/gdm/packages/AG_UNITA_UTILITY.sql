--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UNITA_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_UNITA_UTILITY"
IS
/******************************************************************************
 NOME:        AG_UNITA_UTILITY
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
           accedere ai dati dei documenti UNITA.
 ANNOTAZIONI: .
 REVISIONI:   .

 Rev.  Data       Autore  Descrizione.
 00    11/09/2009  SC  Prima emissione.

******************************************************************************/

   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

/******************************************************************************
 NOME:        get_descrizione
 DESCRIZIONE:  Cerca la descrizione valida alla data p_data, se non c'è,
                cerca la descrizione valida più vicina.
 RITORNA:     varchar2 stringa contenente descrizione di p_unita
                valida in p_data o il più vicino possibile.
 NOTE:
******************************************************************************/
   FUNCTION get_descrizione (p_unita VARCHAR2, p_data DATE)
      RETURN VARCHAR2;

FUNCTION get_radice_area (
      p_codice_unita       VARCHAR2,
      p_data_riferimento   DATE,
      p_codice_amm         VARCHAR2,
      p_codice_aoo         VARCHAR2
   )
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_descrizione, WNDS);
END ag_unita_utility;
/
CREATE OR REPLACE PACKAGE BODY "AG_UNITA_UTILITY"
IS
/******************************************************************************
 NOME:        AG_UNITA_UTILITY
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
           accedere ai dati dei documenti UNITA.
 ANNOTAZIONI: .
 REVISIONI:   .

 Rev. Data        Autore   Descrizione.
 000  11/09/2009  SC       Prima emissione.
 001  16/05/2012  MM       Modifiche versione 2.1.
******************************************************************************/
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

   FUNCTION get_descrizione (p_unita VARCHAR2, p_data DATE)
      RETURN VARCHAR2
   IS
/******************************************************************************
 NOME:        get_descrizione
 DESCRIZIONE:  Cerca la descrizione valida alla data p_data, se non c'è,
                cerca la descrizione valida più vicina.
 RITORNA:     varchar2 stringa contenente descrizione di p_unita
                valida in p_data o il più vicino possibile.
 NOTE:
******************************************************************************/
      d_descrizione   seg_unita.nome%TYPE;
      d_data_prec     DATE;
   BEGIN
      BEGIN
         --cerca la descrizione valida alla data p_data
         SELECT seg_unita.nome
           INTO d_descrizione
           FROM seg_unita
          WHERE seg_unita.unita = p_unita
            AND p_data BETWEEN seg_unita.dal
                           AND NVL (seg_unita.al,
                                    TO_DATE ('31/12/2999', 'dd/mm/yyyy')
                                   );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- non ha trovato descrizioni valide in p_data,
            -- SE P_DATA è MINORE DEL MINIMO seg_unita.dal prende la descrizione più vecchia
            -- SE P_DATA è MAGGIORE DEl MASSIMO seg_unita.dal prende la più recente
            BEGIN
               SELECT nome
                 INTO d_descrizione
                 FROM seg_unita u1
                WHERE u1.unita = p_unita
                  AND dal = (SELECT MIN (dal)
                               FROM seg_unita u2
                              WHERE u2.unita = u1.unita)
                  AND p_data < dal;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT nome
                    INTO d_descrizione
                    FROM seg_unita u1
                   WHERE u1.unita = p_unita
                     AND dal = (SELECT MAX (dal)
                                  FROM seg_unita u2
                                 WHERE u2.unita = u1.unita)
                     AND p_data > dal;
            END;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN d_descrizione;
   END get_descrizione;

   FUNCTION get_radice_area (
      p_codice_unita       VARCHAR2,
      p_data_riferimento   DATE,
      p_codice_amm         VARCHAR2,
      p_codice_aoo         VARCHAR2
   )
      RETURN VARCHAR2
   IS
      cascendenti              afc.t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
      suddivisione_presente    NUMBER                 := 0;
      dep_suddivisione         NUMBER;
      dep_ottica               VARCHAR2 (100);
      dep_indice_aoo           NUMBER;
   BEGIN
      dep_indice_aoo :=
                     ag_utilities.get_indice_aoo (p_codice_amm, p_codice_aoo);
      dep_ottica := ag_utilities.get_ottica_aoo (dep_indice_aoo);
      cascendenti :=
         so4_ags_pkg.unita_get_ascendenti_sudd (p_codice_unita,
                                             p_data_riferimento,
                                             dep_ottica
                                            );

      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
             INTO depprogr, dep_codice_unita_padre, depdescrizioneunita,
                  dep_dal_padre, dep_al_padre, dep_suddivisione;

            BEGIN
               SELECT 1
                 INTO suddivisione_presente
                 FROM ag_suddivisioni
                WHERE dep_suddivisione = id_suddivisione
                  AND indice_aoo = ag_utilities.get_indice_aoo (NULL, NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            EXIT WHEN cascendenti%NOTFOUND OR suddivisione_presente = 1;
--dbms_output.put_line(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
  --                p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

      RETURN dep_codice_unita_padre;
   END get_radice_area;
END ag_unita_utility;
/
