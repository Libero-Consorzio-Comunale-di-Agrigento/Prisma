--liquibase formatted sql
--changeset mmalferrari:AGSPR_PACKAGE_AGP_SO4_UTILITY_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_SO4_UTILITY_PKG
AS
   /******************************************************************************
    NOME:        AGP_SO4_UTILITY_PKG
    DESCRIZIONE: 
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data        Autore Descrizione.
   000  07/04/2020  GM     Creazione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';
   
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;   

   FUNCTION get_indirizzi_aoo_uo (p_idente             NUMBER,
                                  p_filtro_aoo_uo      VARCHAR2 DEFAULT NULL,
                                  p_filtroIndirizzi    VARCHAR2 DEFAULT NULL,
                                  p_versoFiltro        VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_privilegio_utente (p_utente        NUMBER,
                                         p_privilegio    VARCHAR2)
      RETURN afc.t_ref_cursor;
END AGP_SO4_UTILITY_PKG;
/
CREATE OR REPLACE PACKAGE BODY AGP_SO4_UTILITY_PKG
AS
   /******************************************************************************
    NOME:        AGP_SO4_UTILITY_PKG
    DESCRIZIONE: 
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data        Autore Descrizione.
   000  07/04/2020  GM     Creazione.
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '000';
      
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
      RETURN afc.VERSION (s_revisione, NVL (s_revisione_body, '000'));
   END;   
   
   FUNCTION get_indirizzi_aoo_uo (p_idente             NUMBER,
                                  p_filtro_aoo_uo      VARCHAR2 DEFAULT NULL,
                                  p_filtroIndirizzi    VARCHAR2 DEFAULT NULL,
                                  p_versoFiltro        VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor
/*****************************************************************************
 NOME:        get_indirizzi_aoo_uo
 DESCRIZIONE: restituisce il cursore contenente tutti gli indirizzi e progressivi 
              di ao / uo per un ente e per i parametri scelti
 RITORNO:
 Rev.  Data       Autore Descrizione.
 000   07/04/2020 GDM     Creazione.
********************************************************************************/
   IS
      -- Revisione del Package baody
      s_revisione_body   CONSTANT afc.t_revision := '000';
      d_result                    afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT indir.indirizzo, 'AO', aoo.progr_aoo
           FROM gdo_enti, so4_v_aoo aoo, so4_v_indirizzi_telematici indir
          WHERE     id_ente = p_idente
                AND aoo.codice = gdo_enti.aoo
                AND aoo.amministrazione = gdo_enti.amministrazione
                AND aoo.al IS NULL
                AND indir.tipo_Indirizzo = 'I'
                AND indir.progr_aoo = aoo.progr_aoo
                AND indir.dal_aoo = aoo.dal
                AND tipo_entita = 'AO'
                AND (p_filtro_aoo_uo IS NULL OR p_filtro_aoo_uo = 'AO')
                AND (   (    p_filtroIndirizzi IS NOT NULL
                         AND INSTR (LOWER (p_filtroIndirizzi),
                                    LOWER (indir.indirizzo)) > 0
                         AND p_versoFiltro = '=')
                     OR (    p_filtroIndirizzi IS NOT NULL
                         AND INSTR (LOWER (p_filtroIndirizzi),
                                    LOWER (indir.indirizzo)) = 0
                         AND p_versoFiltro = '<>')
                     OR p_filtroIndirizzi IS NULL)
         UNION ALL
         SELECT indir.indirizzo, 'UO', u.progr
           FROM so4_v_indirizzi_telematici indir,
                so4_v_unita_organizzative_pubb u,
                gdo_enti
          WHERE     id_ente = p_idente
                AND indir.tipo_indirizzo <> 'F'
                AND u.amministrazione = gdo_enti.amministrazione
                AND u.codice_Aoo = gdo_enti.aoo
                AND tipo_entita = 'UO'
                AND SYSDATE BETWEEN dal
                                AND NVL (u.al, TO_DATE (3333333, 'j'))
                AND u.progr = indir.progr_uo
                AND u.ottica = indir.ottica_uo
                AND u.dal = indir.dal_uo
                AND (p_filtro_aoo_uo IS NULL OR p_filtro_aoo_uo = 'UO')
                AND (   (    p_filtroIndirizzi IS NOT NULL
                         AND INSTR (LOWER (p_filtroIndirizzi),
                                    LOWER (indir.indirizzo)) > 0
                         AND p_versoFiltro = '=')
                     OR (    p_filtroIndirizzi IS NOT NULL
                         AND INSTR (LOWER (p_filtroIndirizzi),
                                    LOWER (indir.indirizzo)) = 0
                         AND p_versoFiltro = '<>')
                     OR p_filtroIndirizzi IS NULL);

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_SO4_UTILITY_PKG.get_indirizzi_aoo_uo: ' || SQLERRM);
   END;

   FUNCTION get_unita_privilegio_utente (p_utente        NUMBER,
                                         p_privilegio    VARCHAR2)
      RETURN afc.t_ref_cursor
/*****************************************************************************
 NOME:        get_unita_privilegio_utente
 DESCRIZIONE: restituisce il cursore di tutte le unità valide ad oggi per utente
              e privilegio passati
 RITORNO:
 Rev.  Data       Autore Descrizione.
 000   07/04/2020 GDM     Creazione.
********************************************************************************/
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT u.*
           FROM so4_v_unita_organizzative_pubb u, ag_priv_utente_tmp p
          WHERE     p.utente = p_utente
                AND p.privilegio = p_privilegio
                AND p.progr_unita = u.progr
                AND (    p.dal <= TRUNC (SYSDATE)
                     AND NVL (p.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE))
                AND (    u.dal <= TRUNC (SYSDATE)
                     AND NVL (u.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE));

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_SO4_UTILITY_PKG.get_unita_privilegio_utente: ' || SQLERRM);
   END;
END AGP_SO4_UTILITY_PKG;
/
