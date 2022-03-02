--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGS_FASCICOLI_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGS_FASCICOLI_PKG
IS
   /******************************************************************************
    NOME:        AGS_FASCICOLI_PKG
    DESCRIZIONE: Gestione tabella AGS_FASCICOLI.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    23/03/2017    mmalferrari    Prima emissione.
    01    15/01/2020    mmalferrari    create get_anno, get_numero, get_oggetto.
    02    22/06/2020    mfrancesconi   Modificato ritorno di get_numero
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.02';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_numero_fasc_ord (p_numero IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_ubicazione_fascicolo (p_id_fascicolo NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_anno (p_id_fascicolo NUMBER)
      RETURN NUMBER;

   FUNCTION get_numero (p_id_fascicolo NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_oggetto (p_id_fascicolo NUMBER)
      RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY AGS_FASCICOLI_PKG
IS
   /******************************************************************************
    NOMEp_        AGS_FASCICOLI_PKG
    DESCRIZIONEp_ Gestione tabella AGS_FASCICOLI.
    ANNOTAZIONIp_ .
    REVISIONIp_   .
    Rev.  Data          Autore        Descrizione.
    000   16/02/2017    mmalferrari   Prima emissione.
    001   15/01/2020    mmalferrari   create get_anno, get_numero, get_oggetto.
    002   11/08/2020    mmalferrari   Gestione tabella AGS_FASCICOLI (sostituita alla vista)
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '002';

   --------------------------------------------------------------------------------

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  p_ versione compatibilità del Package.
                 Secondo numerop_ revisione del Package specification.
                 Terzo numero  p_ revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------
   FUNCTION get_numero_fasc_ord (p_numero IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return         VARCHAR2 (32767);
      d_numero_punti   NUMBER;
      d_loop           NUMBER := 0;
      d_numero         VARCHAR2 (32767) := NVL (p_numero, '0');
   BEGIN
      d_numero_punti := afc.countoccurrenceof (d_numero, '.');

      WHILE d_loop <= d_numero_punti
      LOOP
         d_return := d_return || LPAD (afc.get_substr (d_numero, '.'), 7, '0');
         d_loop := d_loop + 1;
      END LOOP;

      RETURN d_return;
   END;

   FUNCTION get_ubicazione_fascicolo (p_id_fascicolo NUMBER)
      RETURN VARCHAR2
   IS
      d_class         VARCHAR2 (100);
      d_class_dal     VARCHAR2 (100);
      d_fasc_anno     NUMBER;
      d_fasc_numero   VARCHAR2 (100);
   BEGIN
      SELECT classificazione,
             TO_CHAR (classificazione_dal, 'dd/mm/yyyy'),
             anno,
             numero
        INTO d_class,
             d_class_dal,
             d_fasc_anno,
             d_fasc_numero
        FROM ags_fascicoli f, ags_classificazioni c
       WHERE     id_documento = p_id_fascicolo
             AND c.id_classificazione = f.id_classificazione;

      RETURN gdm_ag_fascicolo_utility.get_desc_ubicazione (d_class,
                                                           d_class_dal,
                                                           d_fasc_anno,
                                                           d_fasc_numero);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;

   FUNCTION get_anno (p_id_fascicolo NUMBER)
      RETURN number
   IS
      d_anno         number;
   BEGIN
      SELECT anno
        INTO d_anno
        FROM ags_fascicoli f
       WHERE     id_documento = p_id_fascicolo;

      RETURN d_anno;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN null;
   END;

    FUNCTION get_numero(p_id_fascicolo NUMBER)
      RETURN varchar2
   IS
      d_numero         varchar2(255);
   BEGIN
      SELECT numero
        INTO d_numero
        FROM ags_fascicoli f
       WHERE     id_documento = p_id_fascicolo;

      RETURN d_numero;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN null;
   END;


   FUNCTION get_oggetto (p_id_fascicolo NUMBER)
      RETURN VARCHAR2
   IS
      d_oggetto         VARCHAR2 (4000);
   BEGIN
      SELECT oggetto
        INTO d_oggetto
        FROM ags_fascicoli f
       WHERE     id_documento = p_id_fascicolo;

      RETURN d_oggetto;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;
END;
/
