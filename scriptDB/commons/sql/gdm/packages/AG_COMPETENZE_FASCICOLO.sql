--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_FASCICOLO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_COMPETENZE_FASCICOLO"
IS
   /******************************************************************************
    NOME:        Ag_Competenze_FASCICOLO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti FASCICOLO.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    02    20/06/2018  SC  #28754 Nuovo privilegio per modificare i dati di un fascicolo
                          chiuso da parte degli utenti di competenza
    03    16/12/2019  MM  Creata lettura_by_id_doc
    </CODE>
   ******************************************************************************/

   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.03';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   /*****************************************************************************
    NOME:        CREAZIONE.
    DESCRIZIONE: Un utente ha i diritti in creazione su un FASCICOLO se il suo ruolo
    ha privilegio CREF.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare un FASCICOLO se il suo ruolo
    ha privilegio EF.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        CHECK_ELIMINA_FASCICOLO
    DESCRIZIONE: Un Fascicolo e' eliminabile se non ha sottofascicoli e
    non e' ultimo e non e' vuoto

   INPUT  p_id_cartella varchar2: chiave identificativa del documento.
   RITORNO:  1 se il fascicolo e' eliminabile, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    04/12/2008  AM  Prima emissione.
   ********************************************************************************/
   FUNCTION check_elimina_fascicolo (p_id_cartella VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        GESTIONE_COMPETENZE.
    DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un FASCICOLO se almeno uno dei suoi ruoli
    ha privilegio MANF.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION gestione_competenze (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere una FASCICOLO se il suo ruolo
    ha privilegio VF.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_by_id_doc (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare un FASCICOLO se il suo ruolo
    ha privilegio MF.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        INSERIMENTO.
    DESCRIZIONE: Un utente ha i diritti di inserire documenti o cartelle in
    un FASCICOLO se il suo ruolo
    ha privilegio IF.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION inserimento (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
   NOME:        GET_UFFICIO_CREAZIONE.
   DESCRIZIONE: Restitusice il codice dell'ufficio creazione sul fascicolo
                identificato da p_id_viewcartella.

  INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
  RITORNO: valore del campo riservato

   Rev.  Data       Autore  Descrizione.
   00    25/08/2008  AM  Prima emissione.
  ********************************************************************************/
   FUNCTION get_ufficio_creazione (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION abilita_azione_smistamento (
      p_id_documento         NUMBER,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER;

   FUNCTION abilita_azione_smistamento (
      p_idrif                VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER;

   FUNCTION get_componenti_unita_azione (p_id_documento    NUMBER,
                                         p_codice_unita    VARCHAR2,
                                         p_azione          VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR;

   FUNCTION lettura_riservati (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_per_smistamento (p_id_documento    VARCHAR2,
                                     p_utente          VARCHAR2,
                                     is_riservato      NUMBER)
      RETURN NUMBER;

   FUNCTION get_utenti_cref_uff_competenza (p_codice_unita VARCHAR2)
      RETURN VARCHAR;

   FUNCTION modifica_by_id_profilo (p_id_profilo VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION enable_delete_in_object (p_utente_aggiornamento    VARCHAR2,
                                     p_id_cartella             NUMBER,
                                     p_tipo_oggetto            VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_data_chiusura (p_id_documento    VARCHAR2,
                                    p_utente          VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_archivio_digitale (p_id_documento    VARCHAR2,
                                        p_utente          VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_in_classifica_pers (p_id_viewcartella VARCHAR2)
      RETURN BOOLEAN;
END ag_competenze_fascicolo;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_FASCICOLO"
IS
   /******************************************************************************
    NOME:        Ag_Competenze_FASCICOLO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti M_FASCICOLO.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          27/04/2017  SC  ALLINEATO ALLO STANDARD
          29/05/2018  SC  Gestione abilitazione inoltra da smistamento assegnato.
    02    20/06/2018  SC  #28754 Nuovo privilegio per modificare i dati di un fascicolo
                          chiuso da parte degli utenti di competenza
    003   31/07/2018  MM  Modificate lettura_non_riservati e lettura_chiusi_non_riservati
    004   12/02/2019  SC  #32591 PERSONALIZZAZIONE - Inserimento fascicoli del personale
    005   16/12/2019  MM  Creata lettura_by_id_doc
   ******************************************************************************/

   s_revisione_body   CONSTANT afc.t_revision := '005';

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
   /*****************************************************************************
    NOME:        GET_ID_VIEW_CLASSIFICA.
    DESCRIZIONE: Individua l'id della cartella classificazione di cui il fascicolo
    fa parte, da esso trova il corrispondente id_view_cartella e lo restituisce.

   INPUT  p_id_documento varchar2: chiave identificativa del fascicolo in VIEW_CARTELLA.
   RITORNO: IDENTIFICATIVO DELLA CLASS DI CUI IL FASCICOLO FA PARTE IN VIEW_CARTELLA

    Rev.  Data       Autore  Descrizione.
    00    04/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_id_view_classifica (p_id_viewcartella VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   NUMBER;
      idviewclas    NUMBER;
      classcod      VARCHAR2 (100);
      classdal      DATE;
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      classcod := f_valore_campo (iddocumento, 'CLASS_COD');
      classdal :=
         TO_DATE (f_valore_campo (iddocumento, 'CLASS_DAL'), 'dd/mm/yyyy');
      idviewclas :=
         ag_utilities.get_id_view_classifica (p_class_cod   => classcod,
                                              p_class_dal   => classdal);
      RETURN idviewclas;
   END get_id_view_classifica;

   /*****************************************************************************
    NOME:        IS_RISERVATO.
    DESCRIZIONE: Verifica se il fascicolo identificato da p_id_documento è riservato.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION is_riservato (p_id_viewcartella VARCHAR2)
      RETURN BOOLEAN
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1) := 'N';
   BEGIN
      SELECT NVL (riservato, 'N')
        INTO retval
        FROM view_cartella vica, cartelle cart, seg_fascicoli fasc
       WHERE     vica.id_viewcartella = p_id_viewcartella
             AND vica.id_cartella = cart.id_cartella
             AND cart.id_documento_profilo = fasc.id_documento;

      RETURN retval = 'Y';
   END is_riservato;

   /*****************************************************************************
    NOME:        is_in_classifica_pers.
    DESCRIZIONE: Verifica se il fascicolo è nella clas dei fascicoli del personale.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
   RITORNO: boolean

    Rev.  Data       Autore  Descrizione.
    004   12/02/2019  SC  #32591 PERSONALIZZAZIONE - Inserimento fascicoli del personale
   ********************************************************************************/
   FUNCTION is_in_classifica_pers (p_id_viewcartella VARCHAR2)
      RETURN BOOLEAN
   IS
      retval           VARCHAR2 (1) := 'N';
      dep_class_cod    seg_classificazioni.class_cod%TYPE;
      dep_cod_amm      parametri.valore%TYPE;
      dep_cod_aoo      parametri.valore%TYPE;
      dep_class_pers   seg_classificazioni.class_cod%TYPE;
   BEGIN
      SELECT class_cod, codice_amministrazione, codice_aoo
        INTO dep_class_cod, dep_cod_amm, dep_cod_aoo
        FROM view_cartella vica, cartelle cart, seg_fascicoli fasc
       WHERE     vica.id_viewcartella = p_id_viewcartella
             AND vica.id_cartella = cart.id_cartella
             AND cart.id_documento_profilo = fasc.id_documento;

      dep_class_pers :=
         AG_PARAMETRO.GET_VALORE (p_codice       => 'CLAS_FASC_PERS_',
                                  p_codice_amm   => dep_cod_amm,
                                  p_codice_aoo   => dep_cod_aoo,
                                  p_default      => '***');

      IF dep_class_pers = dep_class_cod
      THEN
         retval := 'Y';
      END IF;

      RETURN retval = 'Y';
   END is_in_classifica_pers;

   --------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        IS_CHIUSO.
    DESCRIZIONE: Verifica se il fascicolo identificato da p_id_documento è chiuso.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION is_chiuso (p_id_viewcartella VARCHAR2)
      RETURN BOOLEAN
   IS
      iddocumento   NUMBER;
      retval        DATE;
   BEGIN
      SELECT data_chiusura
        INTO retval
        FROM view_cartella vica, cartelle cart, seg_fascicoli fasc
       WHERE     vica.id_viewcartella = p_id_viewcartella
             AND vica.id_cartella = cart.id_cartella
             AND cart.id_documento_profilo = fasc.id_documento;

      RETURN retval IS NOT NULL;
   END is_chiuso;

   /*****************************************************************************
    NOME:        GET_UFFICIO_COMPETENZA.
    DESCRIZIONE: Restitusice il codice dell'ufficio competenze sul fascicolo
                 identificato da p_id_viewcartella.

   INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_ufficio_competenza (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1000);
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'UFFICIO_COMPETENZA');
      RETURN retval;
   END get_ufficio_competenza;

   FUNCTION get_idrif (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (4000);
   BEGIN
      SELECT idrif
        INTO retval
        FROM view_cartella vica, cartelle cart, seg_fascicoli fasc
       WHERE     vica.id_viewcartella = p_id_viewcartella
             AND vica.id_cartella = cart.id_cartella
             AND cart.id_documento_profilo = fasc.id_documento;

      RETURN retval;
   END get_idrif;

   /*  01  06/04/2017   SC  Gestione date per privilegi*/
   FUNCTION lettura_per_smistamento (p_id_documento    VARCHAR2,
                                     p_utente          VARCHAR2,
                                     is_riservato      NUMBER)
      RETURN NUMBER
   IS
      aprivilegio          ag_privilegi.privilegio%TYPE := 'VS';
      retval               NUMBER := 0;
      dep_idrif            VARCHAR2 (4000);
      suffissoprivilegio   VARCHAR2 (1) := '';
      dep_iter_fasc        parametri.valore%TYPE;
      dep_data_rif         DATE;
      d_id_viewcartella    NUMBER := p_id_documento;
   BEGIN
      dep_data_rif := ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);

      IF ag_parametro.get_valore (
            'ITER_FASCICOLI_' || ag_utilities.indiceaoo,
            '@agVar@',
            'N') = 'Y'
      THEN
         SELECT idrif
           INTO dep_idrif
           FROM view_cartella vica, cartelle cart, seg_fascicoli fasc
          WHERE     vica.id_viewcartella = d_id_viewcartella
                AND vica.id_cartella = cart.id_cartella
                AND cart.id_documento_profilo = fasc.id_documento;

         --dep_idrif := get_idrif (p_id_documento);
         IF is_riservato = 1
         THEN
            suffissoprivilegio := 'R';
         END IF;

         SELECT NVL (MIN (1), 0)
           INTO retval
           FROM (SELECT 1
                   FROM seg_smistamenti, documenti docu
                  WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                        AND docu.id_documento = seg_smistamenti.id_documento
                        AND seg_smistamenti.idrif = dep_idrif
                        AND seg_smistamenti.codice_assegnatario = p_utente
                        AND seg_smistamenti.stato_smistamento IN ('R', 'C')
                 UNION ALL
                 SELECT 1
                   FROM seg_smistamenti,
                        documenti docu,
                        ag_priv_utente_tmp priv_vs,
                        ag_privilegi_smistamento
                  WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                        AND docu.id_documento = seg_smistamenti.id_documento
                        AND seg_smistamenti.idrif = dep_idrif
                        AND seg_smistamenti.tipo_smistamento =
                               ag_privilegi_smistamento.tipo_smistamento
                        AND priv_vs.utente = p_utente
                        AND priv_vs.privilegio IN (   'VDDR'
                                                   || suffissoprivilegio,
                                                   'VS' || suffissoprivilegio)
                        AND ag_privilegi_smistamento.privilegio =
                               priv_vs.privilegio
                        AND seg_smistamenti.ufficio_smistamento =
                               priv_vs.unita
                        AND dep_data_rif <=
                               NVL (priv_vs.al, TO_DATE (3333333, 'j'))
                        AND ag_privilegi_smistamento.aoo =
                               ag_utilities.indiceaoo);
      END IF;

      RETURN retval;
   END lettura_per_smistamento;

   /*****************************************************************************
    NOME:        CREAZIONE.
    DESCRIZIONE: Un utente ha i diritti in creazione su un FASCICOLO se il suo ruolo
    ha privilegio CREF.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/4/2017   SC  Gestione date per privilegi
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'CREF';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END creazione;

   /*****************************************************************************
    NOME:        GESTIONE_COMPETENZE.
    DESCRIZIONE: Un utente ha i diritti di gestire le competenze di un FASCICOLO se almeno uno dei suoi ruoli
    ha privilegio MANF.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/4/2017   SC  Gestione date per privilegi
   ********************************************************************************/
   FUNCTION gestione_competenze (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MANF';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END gestione_competenze;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un Fascicolo e' eliminabile solo se non ha sottofascicoli e'
                 l'ultimo ed e' vuoto. Un utente ha i diritti di cancellare un
                 FASCICOLO aperto se ha privilegio EF; ha i diritti di cancellare
                 un FASCICOLO chiuso se ha privilegio EFC.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    04/12/2008  AM  A25616.0.0. Chiama check_elimina_fascicolo.
    01    06/4/2017   SC  Gestione date per privilegi
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'EF';
      retval        NUMBER := 0;
      p_id_doc      VARCHAR2 (20) := '';
      p_check       NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      p_id_doc := ag_utilities.get_id_profilo (p_id_documento);

      SELECT COUNT (1)
        INTO p_check
        FROM seg_fascicoli fasc
       WHERE     fasc.id_documento = p_id_doc
             AND fasc.fascicolo_anno IS NOT NULL
             AND fasc.fascicolo_numero IS NOT NULL
             AND fasc.class_cod IS NOT NULL;

      IF (p_check = 0)
      THEN
         RETURN 1;
      END IF;

      IF is_chiuso (p_id_documento)
      THEN
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'EFC',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      ELSE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => aprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      --AM  A25616.0.0.
      IF (retval = 1)
      THEN
         retval := check_elimina_fascicolo (p_id_documento);
      END IF;

      RETURN retval;
   END eliminazione;

   /*****************************************************************************
    NOME:        CHECK_ELIMINA_FASCICOLO
    DESCRIZIONE: Un Fascicolo e' eliminabile se non ha sottofascicoli, e' ultimo
                 ed e' vuoto

   INPUT  p_id_cartella varchar2: chiave identificativa del documento.
   RITORNO:  1 se il fascicolo e' eliminabile, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    04/12/2008  AM  Prima emissione. A25616.0.0.
   ********************************************************************************/
   FUNCTION check_elimina_fascicolo (p_id_cartella VARCHAR2)
      RETURN NUMBER
   IS
      p_id_doc                   VARCHAR2 (20) := '';
      d_numero                   VARCHAR2 (100) := '';
      d_prev_fasc                VARCHAR2 (20) := '';
      d_last_fasc                VARCHAR2 (10) := '';
      d_pos                      NUMBER := 0;
      d_ret                      NUMBER := 0;
      d_qt                       NUMBER := 0;
      d_sub                      NUMBER := -1;
      d_esiste                   NUMBER := 0;
      d_class_cod                VARCHAR2 (1000);
      d_class_dal                DATE;
      d_numerazione_illimitata   VARCHAR2 (1);
      d_max_anno_numerazione     NUMBER;
   BEGIN
      p_id_doc := ag_utilities.get_id_profilo (p_id_cartella);

      SELECT fascicolo_numero,
             ultimo_numero_sub,
             class_cod,
             class_dal
        INTO d_numero,
             d_sub,
             d_class_cod,
             d_class_dal
        FROM seg_fascicoli fas
       WHERE id_documento = p_id_doc;

      --Se non ha sottofascicoli
      IF (NVL (d_sub, 0) = 0)
      THEN
         DBMS_OUTPUT.put_line ('non ha sottofascicoli');
         --Se D_numero contiene il '.' e' un subfascicolo e devo andare a vedere chi e' il padre...
         d_pos := INSTR (d_numero, '.', -1);        -- ultima occorrenza del .

         IF (d_pos > 0)                               -- se e' un subfascicolo
         THEN
            DBMS_OUTPUT.put_line ('esso stesso è un sottofascicolo');
            d_prev_fasc := SUBSTR (d_numero, 1, d_pos - 1);
            d_numero := SUBSTR (d_numero, d_pos + 1);

            -- controllo il fascicolo padre
            -- e metti in d_last_fasc l'ultimo numero sub
            SELECT f2.ultimo_numero_sub
              INTO d_last_fasc
              FROM seg_fascicoli f1, seg_fascicoli f2, cartelle ca
             WHERE     f1.id_documento = p_id_doc
                   AND f2.class_cod = f1.class_cod
                   AND f2.class_dal = f1.class_dal
                   AND f2.fascicolo_numero = d_prev_fasc
                   AND f2.fascicolo_anno = f1.fascicolo_anno
                   AND ca.id_documento_profilo = f2.id_documento
                   AND NVL (ca.stato, ' ') <> 'CA';

            DBMS_OUTPUT.put_line ('d_last_fasc ' || d_last_fasc);
         ELSE
            -- altrimenti controllo su seg_numerazioni_classifica
            -- quale sia l'ultimo numero sub e lo metto in d_last_fasc
            -- SC A33729.0.0 se la class ha numerazione illimitata,
            -- il fascicoloo è eliminabile se è l'ultimo dell'ultimo anno numerato.
            -- se la class è limitata, il fascicolo è eliminabile se è l'ultimo
            --per il proprio anno.
            SELECT num_illimitata
              INTO d_numerazione_illimitata
              FROM seg_classificazioni clas, cartelle cart
             WHERE     clas.class_cod = d_class_cod
                   AND class_dal = d_class_dal
                   AND cart.id_documento_profilo = clas.id_documento
                   AND NVL (cart.stato, 'BO') = 'BO';

            IF d_numerazione_illimitata = 'Y'
            THEN
               SELECT MAX (anno)
                 INTO d_max_anno_numerazione
                 FROM seg_numerazioni_classifica nucl, documenti docu
                WHERE     nucl.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE')
                      AND nucl.class_cod = d_class_cod
                      AND class_dal = d_class_dal;
            END IF;

            SELECT nucl.ultimo_numero_sub
              INTO d_last_fasc
              FROM seg_classificazioni clas,
                   seg_fascicoli fasc,
                   cartelle cart,
                   seg_numerazioni_classifica nucl,
                   documenti docu_nucl,
                   documenti docu_clas
             WHERE     fasc.id_documento = p_id_doc
                   AND clas.class_cod = fasc.class_cod
                   AND clas.class_dal = fasc.class_dal
                   AND cart.id_documento_profilo = clas.id_documento
                   AND NVL (cart.stato, ' ') <> 'CA'
                   AND docu_clas.id_documento = clas.id_documento
                   AND docu_clas.stato_documento NOT IN ('CA', 'RE')
                   AND docu_nucl.id_documento = nucl.id_documento
                   AND docu_nucl.stato_documento NOT IN ('CA', 'RE')
                   AND clas.class_cod = nucl.class_cod
                   AND clas.class_dal = nucl.class_dal
                   AND nucl.anno =
                          DECODE (d_numerazione_illimitata,
                                  'Y', d_max_anno_numerazione,
                                  fasc.fascicolo_anno);
         END IF;

         -- Se e' l'ultimo fascicolo
         IF (d_numero = d_last_fasc)
         THEN
            BEGIN
               -- se la cartella e' vuota
               SELECT 1
                 INTO d_esiste
                 FROM DUAL
                WHERE EXISTS
                         (SELECT l.id_oggetto
                            FROM cartelle ca, links l, documenti doc
                           WHERE     ca.id_documento_profilo = p_id_doc
                                 AND l.id_cartella = ca.id_cartella
                                 AND l.tipo_oggetto = 'D'
                                 AND doc.stato_documento <> 'CA'
                                 AND l.id_oggetto = doc.id_documento);
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_ret := 1;
            END;
         END IF;
      END IF;

      RETURN d_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END check_elimina_fascicolo;

   /********************************************/
   /*****************************************************************************
    NOME:        MODIFICA_RISERVATI.
    DESCRIZIONE: Un utente ha i diritti di modificare qualsiasi FASCICOLO riservato se il suo ruolo
    ha privilegio MFR.
    Un utente ha i diritti di modificare un FASCICOLO riservato appartenente alla propria unita
    se il suo ruolo ha privilegio MFRU all'interno dell'unita di competenza del fascicolo.
    Altrimenti lo vede se ha MFRUCRE e fa parte dell'ufficio di creazione del fascicolo.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/4/2017   SC  Gestione date per privilegi
   ********************************************************************************/
   FUNCTION modifica_riservati (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aooindex            NUMBER := 1;
      aruolo              ad4_ruoli.ruolo%TYPE;
      aprivilegio         ag_privilegi.privilegio%TYPE := 'MFR';
      retval              NUMBER := 0;
      ufficiocompetenza   seg_unita.unita%TYPE;
      ufficiocreazione    seg_unita.unita%TYPE;
      dep_data_rif        DATE;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di competenza
         ufficiocompetenza := get_ufficio_competenza (p_id_documento);
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

         --verificare se l'utente appartiene a tale unita con privilegio MFRU
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocompetenza,
                  p_privilegio   => 'MFRU',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (p_id_documento);

         --verificare se l'utente appartiene a tale unita con privilegio MFRUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => 'MFRUCRE',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END modifica_riservati;

   /*****************************************************************************
    NOME:        MODIFICA_DATA_CHIUSURA.
    DESCRIZIONE: Hanno diritto a modificare la data di chiusura
    gli utenti MFARC e quelli appartenenti all'ufficio di competenza.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
          p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    14/09/2017  SC  Prima emissione. Feature #23171
   ********************************************************************************/
   FUNCTION modifica_data_chiusura (p_id_documento    VARCHAR2,
                                    p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      aooindex            NUMBER := 1;
      aprivilegio         ag_privilegi.privilegio%TYPE := 'MFARC';
      retval              NUMBER := 0;
      ufficiocompetenza   seg_unita.unita%TYPE;
      dep_data_rif        DATE;
      dep_idrif           seg_fascicoli.idrif%TYPE;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di competenza
         dep_idrif := f_valore_campo (p_id_documento, 'IDRIF');
         ufficiocompetenza :=
            f_valore_campo (p_id_documento, 'UFFICIO_COMPETENZA');
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp
             WHERE     utente = p_utente
                   AND appartenenza = 'D'
                   AND ag_priv_utente_tmp.unita IN (SELECT ufficio_smistamento
                                                      FROM seg_smistamenti,
                                                           documenti
                                                     WHERE     idrif =
                                                                  dep_idrif
                                                           AND stato_smistamento IN ('C',
                                                                                     'R')
                                                           AND documenti.id_documento =
                                                                  seg_smistamenti.id_documento
                                                           AND documenti.stato_documento NOT IN ('CA',
                                                                                                 'RE',
                                                                                                 'PB')
                                                    UNION
                                                    SELECT ufficiocompetenza
                                                      FROM DUAL)
                   AND dep_data_rif <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := 0;
            WHEN TOO_MANY_ROWS
            THEN
               retval := 1;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;

      RETURN retval;
   END modifica_data_chiusura;

   /*****************************************************************************
    NOME:        MODIFICA_ARCHIVIO_DIGITALE.
    DESCRIZIONE: Hanno diritto a modificare il campo ARCHIVIO_DIGITALE
    gli utenti MFARC e quelli appartenenti all'ufficio di competenza.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
          p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    14/09/2017  SC  Prima emissione. Feature #23171
   ********************************************************************************/
   FUNCTION modifica_archivio_digitale (p_id_documento    VARCHAR2,
                                        p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio         ag_privilegi.privilegio%TYPE := 'MFARC';
      retval              NUMBER := 0;
      ufficiocompetenza   seg_unita.unita%TYPE;
      dep_data_rif        DATE;
      dep_idrif           seg_fascicoli.idrif%TYPE;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di competenza
         dep_idrif := f_valore_campo (p_id_documento, 'IDRIF');
         ufficiocompetenza :=
            f_valore_campo (p_id_documento, 'UFFICIO_COMPETENZA');
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp
             WHERE     utente = p_utente
                   AND appartenenza = 'D'
                   AND ag_priv_utente_tmp.unita IN (SELECT ufficio_smistamento
                                                      FROM seg_smistamenti,
                                                           documenti
                                                     WHERE     idrif =
                                                                  dep_idrif
                                                           AND stato_smistamento IN ('C',
                                                                                     'R')
                                                           AND documenti.id_documento =
                                                                  seg_smistamenti.id_documento
                                                           AND documenti.stato_documento NOT IN ('CA',
                                                                                                 'RE',
                                                                                                 'PB')
                                                    UNION
                                                    SELECT ufficiocompetenza
                                                      FROM DUAL)
                   AND dep_data_rif <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := 0;
            WHEN TOO_MANY_ROWS
            THEN
               retval := 1;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;


      RETURN retval;
   END modifica_archivio_digitale;

   /*****************************************************************************
    NOME:        LETTURA_RISERVATI.
    DESCRIZIONE: Un utente ha i diritti di vedere qualsiasi FASCICOLO riservato se il suo ruolo
    ha privilegio VFR.
    Un utente ha i diritti di vedere un FASCICOLO riservato appartenente alla propria unita
    se il suo ruolo ha privilegio VFRU all'interno dell'unita di competenza del fascicolo.
    Altrimenti lo vede se ha VFRUCRE e fa parte dell'ufficio di creazione del fascicolo.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
   ********************************************************************************/
   FUNCTION lettura_riservati (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio         ag_privilegi.privilegio%TYPE := 'VFR';
      retval              NUMBER := 0;
      ufficiocompetenza   seg_unita.unita%TYPE;
      ufficiocreazione    seg_unita.unita%TYPE;
      dep_data_rif        DATE;
      d_id_viewcartella   NUMBER := p_id_documento;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         retval := lettura_per_smistamento (d_id_viewcartella, p_utente, 1);
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di competenza
         ufficiocompetenza := get_ufficio_competenza (d_id_viewcartella);
         dep_data_rif :=
            ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);

         --verificare se l'utente appartiene a tale unita con privilegio MFRU
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocompetenza,
                  p_privilegio   => 'VFRU',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (d_id_viewcartella);

         --verificare se l'utente appartiene a tale unita con privilegio VFRUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => 'VFRUCRE',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END lettura_riservati;

   /*****************************************************************************
    NOME:        MODIFICA_NON_RISERVATI.
    DESCRIZIONE: Un utente ha i diritti di modificare qualsiasi FASCICOLO non riservato se il suo ruolo
    ha privilegio MFR.
    Un utente ha i diritti di modificare un FASCICOLO non riservato appartenente alla propria unita
    se il suo ruolo ha privilegio MFRU all'interno dell'unita di competenza del fascicolo.
    Altrimenti lo vede se ha MFRUCRE e fa parte dell'ufficio di creazione del fascicolo.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
   ********************************************************************************/
   FUNCTION modifica_non_riservati (p_id_documento    VARCHAR2,
                                    p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      aooindex            NUMBER := 1;
      aprivilegio         ag_privilegi.privilegio%TYPE := 'MF';
      retval              NUMBER := 0;
      ufficiocompetenza   seg_unita.unita%TYPE;
      ufficiocreazione    seg_unita.unita%TYPE;
      dep_data_rif        DATE;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di competenza
         ufficiocompetenza := get_ufficio_competenza (p_id_documento);
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);


         --verificare se l'utente appartiene a tale unita con privilegio MFRU
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocompetenza,
                  p_privilegio   => 'MFU',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (p_id_documento);

         --verificare se l'utente appartiene a tale unita con privilegio MFUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => 'MFUCRE',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END modifica_non_riservati;

   /*****************************************************************************
    NOME:        MODIFICA_CHIUSI.
    DESCRIZIONE: Un utente ha i diritti di modificare qualsiasi FASCICOLO chiuso se il suo ruolo
    ha privilegio MFC.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
    02    20/06/2018  SC  #28754 Nuovo privilegio per modificare i dati di un fascicolo
                          chiuso da parte degli utenti di competenza
   ********************************************************************************/
   FUNCTION modifica_chiusi (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio         ag_privilegi.privilegio%TYPE := 'MFC';
      retval              NUMBER := 0;
      ufficiocreazione    seg_unita.unita%TYPE;
      ufficiocompetenza   seg_unita.unita%TYPE;
      dep_data_rif        DATE;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;



      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di competenza
         ufficiocompetenza := get_ufficio_competenza (p_id_documento);
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

         IF is_riservato (p_id_documento)
         THEN
            aprivilegio := aprivilegio || 'R';
         END IF;

         aprivilegio := aprivilegio || 'U';

         --verificare se l'utente appartiene a tale unita con privilegio MFCU o MFCRU
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocompetenza,
                  p_privilegio   => aprivilegio,                --MFCU o MFCRU
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0
      THEN
         aprivilegio := 'MFC';

         IF is_riservato (p_id_documento)
         THEN
            aprivilegio := aprivilegio || 'R';
         END IF;

         aprivilegio := aprivilegio || 'UCRE';
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (p_id_documento);

         --verificare se l'utente appartiene a tale unita con privilegio MFUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => aprivilegio,         -- MFCUCRE o MFCRUCRE
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END modifica_chiusi;

   /*****************************************************************************
    NOME:        LETTURA_NON_RISERVATI.
    DESCRIZIONE: Un utente ha i diritti di vedere qualsiasi FASCICOLO non riservato se il suo ruolo
    ha privilegio VF.
    Un utente ha i diritti di vedere un FASCICOLO non riservato se puo' vedere la class cui il fascicolo appartiene
    ed ha privilegio VFU.
    Altrimenti lo vede se ha VFUCRE e fa parte dell'ufficio di creazione del fascicolo.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
    003   31/07/2018  MM  Gestione competenza su ufficio di competenza indipendente
                          da VCLA_ABILITA_VF
   ********************************************************************************/
   FUNCTION lettura_non_riservati (p_id_documento    VARCHAR2,
                                   p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio          ag_privilegi.privilegio%TYPE := 'VF';
      retval               NUMBER := 0;
      idviewcartellaclas   NUMBER;
      ufficiocreazione     seg_unita.unita%TYPE;
      ufficiocompetenza    seg_unita.unita%TYPE;
      d_id_viewcartella    NUMBER := p_id_documento;
      dep_data_rif         DATE;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         retval := lettura_per_smistamento (d_id_viewcartella, p_utente, 0);
      END IF;

      IF retval = 0
      THEN
         IF ag_parametro.get_valore (
               'VCLA_ABILITA_VF_' || ag_utilities.indiceaoo,
               '@agVar@',
               'Y') = 'Y'
         THEN
            IF ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'VFU',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE)) = 1
            THEN
               idviewcartellaclas :=
                  get_id_view_classifica (d_id_viewcartella);
               retval :=
                  ag_competenze_classificazione.lettura (idviewcartellaclas,
                                                         p_utente);
            END IF;
         END IF;
      END IF;

      IF retval = 0
      THEN
         ufficiocompetenza := get_ufficio_competenza (d_id_viewcartella);
         dep_data_rif :=
            ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);

         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocompetenza,
                  p_privilegio   => 'VFU',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (d_id_viewcartella);
         dep_data_rif :=
            ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);

         --verificare se l'utente appartiene a tale unita con privilegio VFUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => 'VFUCRE',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END lettura_non_riservati;

   /*****************************************************************************
    NOME:        LETTURA_CHIUSI_NON_RISERVATI.
    DESCRIZIONE: Un utente ha i diritti di vedere qualsiasi FASCICOLO non riservato se il suo ruolo
    ha privilegio VFC.
    Altrimenti lo vede se ha VFCU: cioè se vede la classificazione di cui il fascicolo fa parte.
    Altrimenti lo vede se ha VFCUCRE e fa parte dell'ufficio di creazione del fascicolo.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
    003   31/07/2018  MM  Gestione competenza su ufficio di competenza indipendente
                          da VCLA_ABILITA_VF
   ********************************************************************************/
   FUNCTION lettura_chiusi_non_riservati (p_id_documento    VARCHAR2,
                                          p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio          ag_privilegi.privilegio%TYPE := 'VFC';
      retval               NUMBER := 0;
      idviewcartellaclas   NUMBER;
      ufficiocreazione     seg_unita.unita%TYPE;
      ufficiocompetenza    seg_unita.unita%TYPE;
      dep_data_rif         DATE;
      -- identificativo VIEW_CARTELLA della class di cui il fascicolo fa parte
      d_id_viewcartella    NUMBER := p_id_documento;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         retval := lettura_per_smistamento (d_id_viewcartella, p_utente, 0);
      END IF;

      IF retval = 0
      THEN
         IF ag_parametro.get_valore (
               'VCLA_ABILITA_VF_' || ag_utilities.indiceaoo,
               '@agVar@',
               'Y') = 'Y'
         THEN
            IF ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'VFCU',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE)) = 1
            THEN
               idviewcartellaclas :=
                  get_id_view_classifica (d_id_viewcartella);
               retval :=
                  ag_competenze_classificazione.lettura (idviewcartellaclas,
                                                         p_utente);
            END IF;
         END IF;
      END IF;

      IF retval = 0
      THEN
         ufficiocompetenza := get_ufficio_competenza (d_id_viewcartella);
         dep_data_rif :=
            ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);


         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocompetenza,
                  p_privilegio   => 'VFCU',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (d_id_viewcartella);
         dep_data_rif :=
            ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);

         --verificare se l'utente appartiene a tale unita con privilegio VFRCUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => 'VFCUCRE',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END lettura_chiusi_non_riservati;

   /*****************************************************************************
    NOME:        LETTURA_CHIUSI_RISERVATI.
    DESCRIZIONE: Un utente ha i diritti di vedere qualsiasi FASCICOLO riservato se il suo ruolo
    ha privilegio VFRC.
    Altrimenti lo vede se ha VFRCU e fa parte dell'ufficio di competenza del fascicolo.
    Altrimenti lo vede se ha VFRCUCRE e fa parte dell'ufficio di creazione del fascicolo.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
   ********************************************************************************/
   FUNCTION lettura_chiusi_riservati (p_id_documento    VARCHAR2,
                                      p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio          ag_privilegi.privilegio%TYPE := 'VFRC';
      retval               NUMBER := 0;
      idviewcartellaclas   NUMBER;
      ufficiocreazione     seg_unita.unita%TYPE;
      dep_data_rif         DATE;
      -- identificativo VIEW_CARTELLA della class di cui il fascicolo fa parte
      d_id_viewcartella    NUMBER := p_id_documento;
   BEGIN
      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      IF retval = 0
      THEN
         retval := lettura_per_smistamento (d_id_viewcartella, p_utente, 1);
      END IF;

      IF retval = 0
      THEN
         dep_data_rif :=
            ag_utilities.get_Data_rif_privilegi (d_id_viewcartella);
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => f_valore_campo (
                                   ag_utilities.get_id_profilo (d_id_viewcartella),
                                   'UFFICIO_COMPETENZA'),
               p_privilegio   => 'VFRCU',
               p_utente       => p_utente,
               p_data         => dep_data_rif);
      END IF;

      IF retval = 0
      THEN
         --devo calcolare il valore dell'unita' di creazione
         ufficiocreazione := get_ufficio_creazione (d_id_viewcartella);

         --verificare se l'utente appartiene a tale unita con privilegio VFRCUCRE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => ufficiocreazione,
                  p_privilegio   => 'VFRCUCRE',
                  p_utente       => p_utente,
                  p_data         => dep_data_rif);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END lettura_chiusi_riservati;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare qualsiasi FASCICOLO aperto non riservato se il suo ruolo
    ha privilegio MF.
    Un utente ha i diritti di modificare un FASCICOLO aperto non riservato appartenente alla propria unita
    se il suo ruolo ha privilegio MFU all'interno dell'unita di competenza del fascicolo.
    Un utente ha i diritti di modificare qualsiasi FASCICOLO aperto riservato se il suo ruolo
    ha privilegio MFR.
    Un utente ha i diritti di modificare un FASCICOLO aperto riservato appartenente alla propria unita
    se il suo ruolo ha privilegio MFRU all'interno dell'unita di competenza del fascicolo.
   Un utente ha i diritti di modificare un fascicolo chiuso
        se il suo ruolo ha privilegio MFC.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF is_chiuso (p_id_documento)
      THEN
         retval := modifica_chiusi (p_id_documento, p_utente);
      ELSIF is_riservato (p_id_documento)
      THEN
         retval := modifica_riservati (p_id_documento, p_utente);
      ELSE
         retval := modifica_non_riservati (p_id_documento, p_utente);
      END IF;

      RETURN retval;
   END modifica;

   FUNCTION modifica_by_id_profilo (p_id_profilo VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := 0;
      dep_id_view_cartella   NUMBER;
   BEGIN
      dep_id_view_cartella := ag_utilities.get_id_viewcartella (p_id_profilo);
      RETURN modifica (dep_id_view_cartella, p_utente);
   END modifica_by_id_profilo;

   /*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere un FASCICOLO
    nei seguenti casi:
    se il fascicolo è aperto e non e' riservato
        se il suo ruolo ha privilegio VF, oppure VFU e il fascicoli e' di competenza
                                              di un'unita' di p_utente
    se il fascicolo è aperto ed e' riservato
        se il suo ruolo ha privilegio VFR, oppure VFRU e il fascicoli e' di competenza
                                              di un'unita' di p_utente.
    se il fascicolo è chiuso
        se il suo ruolo ha privilegio VFC.

   INPUT  p_id_documento varchar2: id_viewcartella della cartella associata al fascicolo.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    004   12/02/2019  SC  #32591 PERSONALIZZAZIONE - Inserimento fascicoli del personale
   ********************************************************************************/
   FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval              NUMBER := 0;
      d_id_viewcartella   NUMBER := p_id_documento;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF is_in_classifica_pers (d_id_viewcartella)
      THEN
         RETURN AG_UTILITIES.VERIFICA_PRIVILEGIO_UTENTE (
                   p_unita        => NULL,
                   p_privilegio   => 'CLASPERS',
                   p_utente       => p_utente,
                   p_data         => TRUNC (SYSDATE));
      END IF;

      IF is_chiuso (d_id_viewcartella)
      THEN
         IF is_riservato (d_id_viewcartella)
         THEN
            retval := lettura_chiusi_riservati (d_id_viewcartella, p_utente);
         ELSE
            retval :=
               lettura_chiusi_non_riservati (d_id_viewcartella, p_utente);
         END IF;
      ELSIF is_riservato (d_id_viewcartella)
      THEN
         retval := lettura_riservati (d_id_viewcartella, p_utente);
      ELSE
         retval := lettura_non_riservati (d_id_viewcartella, p_utente);
      END IF;

      RETURN retval;
   END lettura;

   FUNCTION lettura_by_id_doc (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_id_viewcartella   NUMBER;
   BEGIN
      SELECT view_cart.id_viewcartella
        INTO d_id_viewcartella
        FROM seg_fascicoli, cartelle cart_fasc, view_cartella view_cart
       WHERE     cart_fasc.id_documento_profilo = seg_fascicoli.id_documento
             AND view_cart.id_cartella = cart_fasc.id_cartella
             and seg_fascicoli.id_documento = p_id_documento;

      RETURN lettura (d_id_viewcartella, p_utente);
   END;

   /*****************************************************************************
    NOME:        INSERIMENTO.
    DESCRIZIONE: Un utente ha i diritti di inserire documenti o cartelle in
    un FASCICOLO aperto se il suo ruolo ha privilegio IF.
    Un utente ha i diritti di inserire documenti o cartelle in
    un FASCICOLO chiuso se il suo ruolo ha privilegio IFC.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    06/04/2017  SC  Gestione date privilegi.
   ********************************************************************************/
   FUNCTION inserimento (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'IF';
      retval        NUMBER := 0;
   BEGIN
      IF ag_fascicolo_utility.check_inserimento_documenti (
            ag_utilities.get_id_profilo (p_id_documento),
            p_utente) = 0
      THEN
         RETURN 0;
      END IF;

      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF is_chiuso (p_id_documento)
      THEN
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'IFC',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      ELSE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => aprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END inserimento;

   /*****************************************************************************
 NOME:        GET_UFFICIO_CREAZIONE.
 DESCRIZIONE: Restitusice il codice dell'ufficio creazione sul fascicolo
              identificato da p_id_viewcartella.

INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
RITORNO: valore del campo riservato

 Rev.  Data       Autore  Descrizione.
 00    25/08/2008  AM  Prima emissione.
********************************************************************************/
   FUNCTION get_ufficio_creazione (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        seg_unita.unita%TYPE;
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'UFFICIO_CREAZIONE');
      RETURN retval;
   END get_ufficio_creazione;


   /* 01    06/04/2017  SC  Gestione date privilegi.*/
   /* 02    19/04/2017  SC  Il privilegio ASS viene verificato sempre in data odierna
                            perchè il package che costruisce l'interfaccia fa vedere
                            i componenti cui assegnare solo se privilegio ASS è valido OGGI.
            29/05/2018  SC  Gestione abilitazione inoltra da smistamento assegnato.*/
   FUNCTION abilita_azione_smistamento (
      p_idrif                VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER
   IS
      retval                   NUMBER := 0;
      unita_protocollante      seg_unita.unita%TYPE;
      unita_esibente           seg_unita.unita%TYPE;
      p_privilegio             VARCHAR2 (100) := 'ISMI';
      utenteinstruttura        NUMBER := 0;
      dep_utente_creazione     seg_fascicoli.utente_creazione%TYPE;
      dep_ufficio_creazione    seg_fascicoli.ufficio_creazione%TYPE;
      dep_ufficio_competenza   seg_fascicoli.ufficio_competenza%TYPE;
      dep_id_fascicolo         NUMBER;
      dep_data_rif             DATE;
   BEGIN
      BEGIN
         SELECT utente_creazione,
                ufficio_creazione,
                ufficio_competenza,
                id_documento
           INTO dep_utente_creazione,
                dep_ufficio_creazione,
                dep_ufficio_competenza,
                dep_id_fascicolo
           FROM seg_fascicoli
          WHERE idrif = p_idrif;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      dep_data_rif := ag_utilities.get_Data_rif_privilegi (dep_id_fascicolo);

      utenteinstruttura :=
         ag_utilities.inizializza_utente (p_utente => p_utente);

      IF utenteinstruttura = 1 AND p_azione = 'SMISTA'
      THEN
         IF p_utente = dep_utente_creazione
         THEN
            retval := 1;
         END IF;

         IF retval = 0
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM ag_priv_utente_tmp
                WHERE     utente = p_utente
                      AND privilegio = p_privilegio
                      AND ag_priv_utente_tmp.unita IN (SELECT ufficio_smistamento
                                                         FROM seg_smistamenti,
                                                              documenti
                                                        WHERE     idrif =
                                                                     p_idrif
                                                              AND stato_smistamento IN ('C',
                                                                                        'R')
                                                              AND documenti.id_documento =
                                                                     seg_smistamenti.id_documento
                                                              AND documenti.stato_documento NOT IN ('CA',
                                                                                                    'RE',
                                                                                                    'PB')
                                                       UNION
                                                       SELECT dep_ufficio_competenza
                                                         FROM DUAL
                                                       UNION
                                                       SELECT dep_ufficio_creazione
                                                         FROM DUAL)
                      AND dep_data_rif <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
               WHEN TOO_MANY_ROWS
               THEN
                  retval := 1;
               WHEN OTHERS
               THEN
                  RAISE;
            END;
         END IF;

         IF retval = 0
         THEN
            -- se non c'è l'unita protocollante il documento non è mai stato salvato quindi basta verifica se l'utente
            -- puo' smistare
            retval :=
               ag_utilities.verifica_privilegio_utente (NULL,
                                                        'ISMITOT',
                                                        p_utente,
                                                        TRUNC (SYSDATE));
         END IF;
      END IF;

      IF utenteinstruttura = 1 AND retval = 0
      THEN
         IF p_azione = 'CARICO'
         THEN
            p_privilegio := 'CARICO';
         END IF;

         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp,
                   ag_abilitazioni_smistamento,
                   seg_smistamenti,
                   documenti dosm,
                   seg_unita
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = p_idrif
                   AND seg_smistamenti.ufficio_smistamento =
                          ag_priv_utente_tmp.unita
                   AND DECODE (p_stato_smistamento,
                               NULL, seg_smistamenti.stato_smistamento,
                               p_stato_smistamento) =
                          seg_smistamenti.stato_smistamento
                   AND seg_smistamenti.stato_smistamento =
                          ag_abilitazioni_smistamento.stato_smistamento
                   AND seg_smistamenti.tipo_smistamento =
                          ag_abilitazioni_smistamento.tipo_smistamento
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND (   ag_priv_utente_tmp.privilegio = p_privilegio
                        OR NVL (seg_smistamenti.codice_assegnatario, '*') =
                              p_utente)
                   AND ag_abilitazioni_smistamento.azione = p_azione
                   AND ag_abilitazioni_smistamento.aoo =
                          ag_utilities.indiceaoo
                   AND seg_unita.unita = seg_smistamenti.ufficio_smistamento
                   AND seg_unita.codice_amministrazione =
                          seg_smistamenti.codice_amministrazione
                   AND DECODE (ag_abilitazioni_smistamento.azione,
                               'ASSEGNA', seg_unita.al,
                               NULL)
                          IS NULL
                   /*AND DECODE (ag_abilitazioni_smistamento.azione,
                               'ESEGUI', NULL,
                               DECODE (seg_smistamenti.codice_assegnatario,

                                       NULL, NULL,
                                       ag_priv_utente_tmp.al


                                      )
                              ) IS NULL*/
                   AND dep_data_rif <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND DECODE (ag_abilitazioni_smistamento.azione,
                               'ASSEGNA',   ag_utilities.verifica_privilegio_utente (
                                               seg_smistamenti.ufficio_smistamento,
                                               'ASS',
                                               p_utente,
                                               TRUNC (SYSDATE))
                                          + ag_utilities.verifica_privilegio_utente (
                                               NULL,
                                               'ASSTOT',
                                               p_utente,
                                               TRUNC (SYSDATE)),
                               1) > 0
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF retval = 0 AND p_azione = 'ESEGUI'
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM seg_smistamenti, documenti dosm
                WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                      AND dosm.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = p_idrif
                      AND seg_smistamenti.stato_smistamento IN ('R', 'C')
                      AND NVL (seg_smistamenti.codice_assegnatario, '*') =
                             p_utente
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      --se l'azione è SMISTA e il documento è assegnato a p_utente,
      -- in carico
      -- consento l'abilitazione.
      IF retval = 0 AND p_azione = 'SMISTA'
      THEN
         BEGIN
            SELECT 1
              INTO retval
              FROM seg_smistamenti, documenti dosm
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = p_idrif
                   AND seg_smistamenti.stato_smistamento = 'C'
                   AND NVL (seg_smistamenti.codice_assegnatario, '*') =
                          p_utente
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := 0;
         END;
      END IF;

      IF retval = 0 AND p_azione = 'INOLTRA'
      THEN
         BEGIN
            SELECT 1
              INTO retval
              FROM seg_smistamenti, documenti dosm
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = p_idrif
                   AND seg_smistamenti.stato_smistamento IN ('C', 'E')
                   AND NVL (seg_smistamenti.codice_assegnatario, '*') =
                          p_utente
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END abilita_azione_smistamento;

   FUNCTION abilita_azione_smistamento (
      p_id_documento         NUMBER,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER
   IS
      retval                NUMBER := 0;
      idriffascicolo        VARCHAR2 (100);
      unita_protocollante   seg_unita.unita%TYPE;
      unita_esibente        seg_unita.unita%TYPE;
      p_privilegio          VARCHAR2 (100) := 'ISMI';
      utenteinstruttura     NUMBER := 0;
      dep_data_rif          DATE;
   BEGIN
      BEGIN
         SELECT idrif
           INTO idriffascicolo
           FROM seg_fascicoli
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      RETURN abilita_azione_smistamento (
                p_idrif               => idriffascicolo,
                p_utente              => p_utente,
                p_azione              => p_azione,
                p_stato_smistamento   => p_stato_smistamento);
   END abilita_azione_smistamento;

   FUNCTION get_componenti_unita_azione (p_id_documento    NUMBER,
                                         p_codice_unita    VARCHAR2,
                                         p_azione          VARCHAR2)
      RETURN VARCHAR2
   IS
      componentiunita   afc.t_ref_cursor;
      retval            NUMBER := 0;
      d_componenti      VARCHAR2 (4000) := '@';
      d_ni              NUMBER;
      d_descr           VARCHAR2 (50);
      d_utente          ag_priv_utente_tmp.utente%TYPE;
      dep_aoo_index     NUMBER;
      dep_ottica        VARCHAR2 (1000);
      d_id_documento    NUMBER;
   BEGIN
      dep_aoo_index := ag_utilities.get_defaultaooindex ();
      dep_ottica := ag_utilities.get_ottica_aoo (dep_aoo_index);
      componentiunita :=
         so4_ags_pkg.unita_get_componenti_ord (
            p_codice_uo   => p_codice_unita,
            p_ottica      => dep_ottica);

      IF componentiunita%ISOPEN
      THEN
         LOOP
            FETCH componentiunita INTO d_ni, d_descr, d_utente;

            EXIT WHEN componentiunita%NOTFOUND;
            retval :=
               abilita_azione_smistamento (p_id_documento   => p_id_documento,
                                           p_utente         => d_utente,
                                           p_azione         => p_azione);

            IF (retval = 1)
            THEN
               d_componenti := d_componenti || d_utente || '@';
            END IF;
         END LOOP;

         CLOSE componentiunita;
      END IF;

      RETURN d_componenti;
   END get_componenti_unita_azione;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR
   IS
      d_componenti         VARCHAR2 (4000) := '@';
      dep_id_smistamenti   VARCHAR2 (32000);
      dep_id_smistamento   NUMBER;
      d_id_documento       NUMBER;
      dep_utente           ad4_utenti.utente%TYPE;
   BEGIN
      d_id_documento :=
         gdm_profilo.getdocumento (p_codice_modello,
                                   p_area,
                                   p_codice_richiesta);
      d_componenti :=
         get_componenti_unita_azione (d_id_documento,
                                      p_codice_unita,
                                      p_azione);
      dep_id_smistamenti := id_smistamenti;

      --id_smistamenti: lista id_doc smistamenti separati da virgola
      WHILE NVL (dep_id_smistamenti, ',') <> ','
      LOOP
         dep_id_smistamento :=
            TO_NUMBER (afc.get_substr (dep_id_smistamenti, ','));

         IF NVL (dep_id_smistamento, 0) != 0
         THEN
            dep_utente :=
               f_valore_campo (dep_id_smistamento, 'UTENTE_TRASMISSIONE');

            IF INSTR (d_componenti, '@' || dep_utente || '@') = 0
            THEN
               d_componenti := d_componenti || dep_utente || '@';

               --DEVO RIABILITARE LO SMISTAMENTO PER CONSENTIRE DI SMISTARE NUOVAMENTE
               DECLARE
                  dep_da_riesumare        NUMBER;
                  dep_dal                 DATE;
                  dep_idrif               VARCHAR2 (32000);
                  dep_descrizione_unita   seg_unita.nome%TYPE;
               BEGIN
                  SELECT smistamento_dal, idrif, des_ufficio_smistamento
                    INTO dep_dal, dep_idrif, dep_descrizione_unita
                    FROM seg_smistamenti
                   WHERE id_documento = dep_id_smistamento;

                  SELECT MAX (id_documento)
                    INTO dep_da_riesumare
                    FROM seg_smistamenti s1
                   WHERE     ufficio_smistamento = p_codice_unita
                         AND stato_smistamento = 'F'
                         AND idrif = dep_idrif
                         AND smistamento_dal < dep_dal
                         AND NOT EXISTS
                                (SELECT 1
                                   FROM seg_smistamenti s2
                                  WHERE     s2.ufficio_trasmissione =
                                               s1.ufficio_smistamento
                                        AND s2.stato_smistamento =
                                               s1.stato_smistamento
                                        AND s1.smistamento_dal >
                                               s2.smistamento_dal
                                        AND s1.idrif = s2.idrif
                                        AND s2.smistamento_dal < dep_dal);

                  UPDATE seg_smistamenti
                     SET stato_smistamento = 'E',
                         note =
                               DECODE (note, NULL, '', note || CHR (10))
                            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                            || ' Smistamento riattivato automaticamente per gestione rifiuto da parte di '
                            || dep_descrizione_unita
                   WHERE id_documento = dep_da_riesumare;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END IF;
      END LOOP;

      RETURN d_componenti;
   END get_utenti_notifica_ripudio;


   /*01    06/04/2017  SC  Gestione date privilegi.*/
   FUNCTION get_utenti_cref_uff_competenza (p_codice_unita VARCHAR2)
      RETURN VARCHAR
   IS
      d_componenti      VARCHAR2 (4000) := '@';
      dep_utente        ad4_utenti.utente%TYPE;
      dep_aoo_index     NUMBER;
      dep_ottica        VARCHAR2 (1000);
      componentiunita   afc.t_ref_cursor;
      d_ni              NUMBER;
      d_descr           VARCHAR2 (32000);
      d_utente          ad4_utenti.utente%TYPE;
   BEGIN
      dep_aoo_index := ag_utilities.get_defaultaooindex ();
      dep_ottica := ag_utilities.get_ottica_aoo (dep_aoo_index);
      componentiunita :=
         so4_ags_pkg.unita_get_componenti_ord (
            p_codice_uo   => p_codice_unita,
            p_ottica      => dep_ottica);

      IF componentiunita%ISOPEN
      THEN
         LOOP
            FETCH componentiunita INTO d_ni, d_descr, d_utente;

            EXIT WHEN componentiunita%NOTFOUND;

            DECLARE
               dep_aggiungi   NUMBER := 0;
            BEGIN
               DBMS_OUTPUT.put_line (
                     'AG_COMPETENZE_FASCICOLO.get_utenti_cref_uff_competenza d_utente '
                  || d_utente);

               -- Ora viene fatto al login non serve farlo ad ogni smistamento
               --ag_utilities.inizializza_ag_priv_utente_tmp (d_utente);

               SELECT 1
                 INTO dep_aggiungi
                 FROM ag_priv_utente_tmp
                WHERE     utente = d_utente
                      AND unita = p_codice_unita
                      AND privilegio = 'CREF'
                      AND TRUNC (SYSDATE) <=               /*BETWEEN dal AND*/
                                            NVL (al, TO_DATE (3333333, 'j'))
                      AND ROWNUM = 1;

               d_componenti := d_componenti || d_utente || '@';
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END LOOP;

         CLOSE componentiunita;
      END IF;

      DBMS_OUTPUT.put_line (
            'AG_COMPETENZE_FASCICOLO.get_utenti_cref_uff_competenza UTENTI CON CREF '
         || d_componenti);
      RETURN d_componenti;
   END get_utenti_cref_uff_competenza;

   /*01    06/04/2017  SC  Gestione date privilegi.*/
   FUNCTION enable_delete_in_object (p_utente_aggiornamento    VARCHAR2,
                                     p_id_cartella             NUMBER,
                                     p_tipo_oggetto            VARCHAR2)
      RETURN NUMBER
   IS
      dep_consenti           NUMBER;
      dep_class_cod          VARCHAR2 (32000);
      dep_fascicolo_anno     NUMBER;
      dep_fascicolo_numero   VARCHAR2 (32000);
   BEGIN                                               -- CHECK DATA INTEGRITY
      SELECT fasc.class_cod,
             fasc.fascicolo_anno,
             fasc.fascicolo_numero,
             ag_utilities.verifica_privilegio_utente ('',
                                                      'MFARC',
                                                      p_utente_aggiornamento,
                                                      TRUNC (SYSDATE))
        INTO dep_class_cod,
             dep_fascicolo_anno,
             dep_fascicolo_numero,
             dep_consenti
        FROM cartelle cfasc, seg_fascicoli fasc
       WHERE     cfasc.id_cartella = p_id_cartella
             AND fasc.id_documento = cfasc.id_documento_profilo
             AND p_tipo_oggetto = 'D'
             AND fasc.stato_scarto NOT IN ('RR', '**');

      RETURN dep_consenti;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 1;
   END enable_delete_in_object;
END ag_competenze_fascicolo;
/
