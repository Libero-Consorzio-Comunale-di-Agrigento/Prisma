--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_RIFERIMENTI_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_riferimenti_utility
IS
/******************************************************************************
 NOME:        AG_RIFERIMENTI_UTILITY
 DESCRIZIONE: Procedure e Funzioni di utility sulla tabella RIFERIMENTI.
 ANNOTAZIONI: Progetto AFFARI_GENERALI.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 00   16/05/2013 MM     Creazione.
******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_riferimenti (p_id_documento number, p_utente VARCHAR2 default null)
      RETURN afc.t_ref_cursor;

   FUNCTION get_oggetto_riferimento (p_id_documento number, p_utente VARCHAR2 default null)
      RETURN varchar2;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_RIFERIMENTI_UTILITY
IS
   /******************************************************************************
    NOME:        AG_RIFERIMENTI_UTILITY
    DESCRIZIONE: Procedure e Funzioni di utility sulla tabella RIFERIMENTI.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  16/05/2013 MM     Creazione.
    001  27/11/2011 MM     Mod. GET_OGGETTO_RIFERIMENTO
    002  16/07/2015 MM     Gestione riferimenti anche dei protocolli
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

   FUNCTION get_oggetto_riferimento (p_id_documento    NUMBER,
                                     p_utente          VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
         NOME:        GET_OGGETTO_RIFERIMENTO

         DESCRIZIONE: Ottiene l'oggetto del riferimento.

         RITORNO:    varchar2.

       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
       000  16/05/2013 MM     Creazione.
       001  27/11/2011 MM     Gestione registri in stato CA e in uso.
       002  16/07/2015 MM     Gestione riferimento albo
      ******************************************************************************/
      d_area       VARCHAR2 (100);
      d_modello    VARCHAR2 (100);
      d_tabella    VARCHAR2 (100);
      d_is_proto   NUMBER;
      is_proto     NUMBER := 0;
      is_mail      NUMBER := 0;
      d_retval     VARCHAR2 (4000);
   BEGIN
      SELECT tido.area_modello,
             tido.nome,
             UPPER (aree.acronimo || '_' || tido.alias_modello) tabella
        INTO d_area, d_modello, d_tabella
        FROM tipi_documento tido, documenti docu, aree
       WHERE     tido.id_tipodoc = docu.id_tipodoc
             AND docu.id_documento = p_id_documento
             AND aree.area = tido.area_modello;

      BEGIN
         SELECT 1
           INTO is_proto
           FROM categorie_modello camo
          WHERE     camo.area = d_area
                AND camo.codice_modello = d_modello
                AND camo.categoria = 'PROTO';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT 1
                 INTO is_mail
                 FROM categorie_modello camo
                WHERE     camo.area = d_area
                      AND camo.codice_modello = d_modello
                      AND camo.categoria = 'POSTA_ELETTRONICA';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
      END;

      IF is_proto = 1
      THEN
         SELECT    regi.descrizione_tipo_registro
                || ' - '
                || prot.anno
                || '/'
                || prot.numero
                || ' del '
                || TO_CHAR (prot.DATA, 'dd/mm/yyyy hh24:mi:ss')
                || CHR (13)
                || CHR (10)
                || DECODE (
                      p_utente,
                      NULL, oggetto,
                      DECODE (
                         NVL (gdm_competenza.gdm_verifica (
                                 'DOCUMENTI',
                                 prot.id_documento,
                                 'L',
                                 p_utente,
                                 'GDM'),
                              0),
                         0, 'Non si dispone dei diritti per visualizzare il documento',
                         oggetto))
           INTO d_retval
           FROM proto_view prot
              , (select anno_reg, tipo_registro, in_uso, descrizione_tipo_registro
                   from seg_registri
                      , documenti docu
                  where docu.id_documento = seg_registri.id_documento
                    and docu.stato_documento NOT IN ('CA', 'RE', 'PB')) regi
          WHERE     prot.id_documento = p_id_documento
                AND regi.tipo_registro(+) = prot.tipo_registro
                AND regi.anno_reg(+) = prot.anno
                AND regi.in_uso(+) = 'Y';
      ELSIF is_mail = 1
      THEN
         SELECT oggetto
           INTO d_retval
           FROM seg_memo_protocollo
          WHERE seg_memo_protocollo.id_documento = p_id_documento;
      ELSIF d_tabella = 'MES_ALBI'
      THEN
         DECLARE
            v_query_str   VARCHAR2 (1000);
         BEGIN
            v_query_str :=
                  'SELECT tipo_reg
                                  || '' - ''
                                  || anno_reg
                                  || ''/''
                                  || ultimo_numero_reg
                                  || '' del ''
                                  || TO_CHAR (a_data_registrazione, ''dd/mm/yyyy'')
                                  || CHR (13)
                                  || CHR (10)
                                  || decode('''
               || p_utente
               || ''', null, a_oggetto, decode(  nvl(gdm_competenza.gdm_verifica(''DOCUMENTI'', id_documento, ''L'', '''||p_utente||''', ''GDM''), 0), 0, ''Non si dispone dei diritti per visualizzare il documento'', a_oggetto))
                             FROM MES_ALBI
                             WHERE id_documento = :id_documento';

            EXECUTE IMMEDIATE v_query_str INTO d_retval USING p_id_documento;
         END;
      ELSIF d_tabella = 'SEG_STREAM_MEMO_PROTO'
      THEN
         SELECT DECODE (
                   p_utente,
                   NULL, subject,
                   DECODE (
                      NVL (gdm_competenza.gdm_verifica (
                              'DOCUMENTI',
                              id_documento,
                              'L',
                              p_utente,
                              'GDM'),
                           0),
                      0, 'Non si dispone dei diritti per visualizzare il documento',
                      subject))
           INTO d_retval
           FROM seg_stream_memo_proto
          WHERE id_documento = p_id_documento;
      ELSE
         d_retval := 'Documento con identificativo ' || p_id_documento;
      END IF;

      DBMS_OUTPUT.PUT_LINE ('d_retval' || d_retval);
      RETURN d_retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_riferimenti (p_id_documento    NUMBER,
                             p_utente          VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_RIFERIMENTI

         DESCRIZIONE: Ottiene la lista dei riferimenti del/al documento.

         RITORNO:    ref cursor.

       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
       000  16/05/2013 MM     Creazione.
       002  16/07/2015 MM     Gestione riferimenti anche dei protocolli
      ******************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT rife.id_documento,
                  rife.id_documento_rif,
                  rife.data_aggiornamento,
                  tire.descrizione desc_relazione,
                  gdc_utility_pkg.f_get_url_oggetto (
                     '',
                     '',
                     DECODE (p_id_documento,
                             rife.id_documento, id_documento_rif,
                             rife.id_documento),
                     'D',
                     '',
                     '',
                     '',
                     'R',
                     '',
                     '',
                     '5',
                     'N')
                     url,
                  DECODE (p_id_documento,
                          rife.id_documento, 'attivo',
                          'passivo')
                     tipo_riferimento,
                  get_oggetto_riferimento (
                     DECODE (p_id_documento,
                             rife.id_documento, id_documento_rif,
                             rife.id_documento),
                     p_utente)
                     oggetto
             FROM riferimenti rife,
                  tipi_relazione tire,
                  documenti docu,
                  documenti docu_rif
            WHERE     (   rife.id_documento = p_id_documento
                       OR id_documento_rif = p_id_documento)
                  AND tire.tipo_relazione = rife.tipo_relazione
                  AND tire.area = rife.area
                  AND docu.id_documento = rife.id_documento
                  AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
                  AND docu_rif.id_documento = rife.id_documento_rif
                  AND NVL (docu_rif.stato_documento, 'BO') NOT IN ('CA',
                                                                   'RE',
                                                                   'PB')
                  AND rife.tipo_relazione NOT IN ('PROT_ALLE',
                                                  'PROT_SMIS',
                                                  'PROT_SOGG',
                                                  'PROT_LISTA',
                                                  'PROT_FASC',
                                                  'PROT_FASPR')
         ORDER BY rife.data_aggiornamento;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_riferimenti_utility.get_riferimenti: ' || SQLERRM);
   END;
END;
/
