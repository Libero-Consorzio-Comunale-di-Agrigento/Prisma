--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_FASCICOLO_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     ag_fascicolo_utility
IS
   /******************************************************************************
    NOME:        AG_FASCICOLO_UTILITY.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 FASCICOLO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   09/07/2009 MM     Creazione.
    01   16/05/2012 MM     Modifiche versione 2.1.
    02   21/05/2013 MM     Modifiche versione 2.2.
    03   27/10/2014 MM     Modifiche versione 2.3.
    04   12/02/2015 MM     Modificata GET_DATI_CLASSIFICA
    05   25/08/2015 MM     Creata GET_ID_CARTELLA
    06   16/09/2016 MM     Creata ELIMINA_SMISTAMENTI
    07   05/11/2018 MM     Aggiunto in get_fascicoli parametro id_fascicolo
    08   28/12/2018 MM     Aggiunto in get_classificazione parametro p_class_dal
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.08';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_wrksp (p_id_cartella IN VARCHAR2, p_tipo_oggetto IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_smistamenti (p_idrif IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_elenco_documenti (p_id_documento   IN NUMBER,
                                  p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION check_ubicazione_vs_fascicolo (
      p_idrif_fascicolo            VARCHAR2,
      p_id_documento_protocollo    NUMBER)
      RETURN NUMBER;

   FUNCTION get_unita_comp_attuale (p_idrif_fascicolo       VARCHAR2,
                                    p_check_assegnazione    NUMBER := 0,
                                    p_assegnatario          VARCHAR2 := NULL)
      RETURN VARCHAR2;

   FUNCTION get_ubicazione (p_id_cartella IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_select_ric_classificazioni (p_codice_amm    IN VARCHAR2,
                                          p_codice_aoo          IN VARCHAR2,
                                          p_stato_class         IN VARCHAR2,
                                          p_class_cod           IN VARCHAR2,
                                          p_class_descr         IN VARCHAR2,
                                          p_stato_fasc          IN VARCHAR2,
                                          p_solo_class          IN VARCHAR2,
                                          p_anno_fasc           IN VARCHAR2,
                                          p_numero_fasc         IN VARCHAR2,
                                          p_fasc_descr          IN VARCHAR2,
                                          p_class_prot          IN VARCHAR2,
                                          p_mostra_tutte        IN VARCHAR2,
                                          p_utente              IN VARCHAR2,
                                          p_sottoclassifiche   IN VARCHAR2)
    RETURN VARCHAR2;

   FUNCTION get_count_ric_classificazioni (p_codice_amm         IN VARCHAR2,
                                          p_codice_aoo          IN VARCHAR2,
                                          p_stato_class         IN VARCHAR2,
                                          p_class_cod           IN VARCHAR2,
                                          p_class_descr         IN VARCHAR2,
                                          p_stato_fasc          IN VARCHAR2,
                                          p_solo_class          IN VARCHAR2,
                                          p_anno_fasc           IN VARCHAR2,
                                          p_numero_fasc         IN VARCHAR2,
                                          p_fasc_descr          IN VARCHAR2,
                                          p_class_prot          IN VARCHAR2,
                                          p_mostra_tutte        IN VARCHAR2,
                                          p_utente              IN VARCHAR2,
                                          p_sottoclassifiche   IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_ricerche_classificazioni (p_codice_amm          IN VARCHAR2,
                                          p_codice_aoo          IN VARCHAR2,
                                          p_stato_class         IN VARCHAR2,
                                          p_class_cod           IN VARCHAR2,
                                          p_class_descr         IN VARCHAR2,
                                          p_stato_fasc          IN VARCHAR2,
                                          p_solo_class          IN VARCHAR2,
                                          p_anno_fasc           IN VARCHAR2,
                                          p_numero_fasc         IN VARCHAR2,
                                          p_fasc_descr          IN VARCHAR2,
                                          p_class_prot          IN VARCHAR2,
                                          p_mostra_tutte        IN VARCHAR2,
                                          p_utente              IN VARCHAR2,
                                          p_sottoclassifiche   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_ubicazione (p_class_cod          IN VARCHAR2,
                            p_class_dal             DATE,
                            p_fascicolo_anno        NUMBER,
                            p_fascicolo_numero      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_unita_classificazione (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_unita_classifica.class_cod%TYPE)
      RETURN afc.t_ref_cursor;

   FUNCTION get_numerazioni_fascicoli (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_numerazioni_classifica.class_cod%TYPE,
      p_class_dal    IN VARCHAR2,
      p_anno         IN NUMBER,
      p_id_padre     IN NUMBER,
      p_utente       IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_classificazione (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_classificazioni.class_cod%TYPE,
      p_class_dal    IN VARCHAR2 default null)
      RETURN afc.t_ref_cursor;

   FUNCTION get_classificazioni (
      p_codice_amm     IN VARCHAR2,
      p_codice_aoo     IN VARCHAR2,
      p_class_cod      IN seg_classificazioni.class_cod%TYPE,
      p_class_descr    IN seg_classificazioni.class_descr%TYPE,
      p_mostra_tutte   IN VARCHAR2,
      p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_fascicolo (
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2,
      p_class_cod          IN seg_classificazioni.class_cod%TYPE,
      p_fascicolo_anno     IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero   IN seg_fascicoli.fascicolo_numero%TYPE,
      p_utente             IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_fascicolo (p_id_documento IN NUMBER, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_select_fascicoli (
      p_codice_amm                     IN VARCHAR2,
      p_codice_aoo                     IN VARCHAR2,
      p_fascicolo_anno                 IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero               IN seg_fascicoli.fascicolo_numero%TYPE,
      p_class_cod                      IN seg_classificazioni.class_cod%TYPE,
      p_class_dal                      IN VARCHAR2,
      p_fascicolo_oggetto              IN seg_fascicoli.fascicolo_oggetto%TYPE,
      p_mostra_tutti                   IN VARCHAR2,
      p_utente                         IN VARCHAR2,
      p_fascicolo_note                 IN seg_fascicoli.note%TYPE,
      p_fascicolo_ufficio_competenza   IN seg_fascicoli.ufficio_competenza%TYPE,
      p_sottoclassifiche               IN VARCHAR2,
      p_id_fascicolo                   IN NUMBER,
      p_numerazione_automatica IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR;

   FUNCTION get_fascicoli (
      p_codice_amm                     IN VARCHAR2,
      p_codice_aoo                     IN VARCHAR2,
      p_fascicolo_anno                 IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero               IN seg_fascicoli.fascicolo_numero%TYPE,
      p_class_cod                      IN seg_classificazioni.class_cod%TYPE,
      p_class_dal                      IN VARCHAR2,
      p_fascicolo_oggetto              IN seg_fascicoli.fascicolo_oggetto%TYPE,
      p_mostra_tutti                   IN VARCHAR2,
      p_utente                         IN VARCHAR2,
      p_fascicolo_note                 IN seg_fascicoli.note%TYPE,
      p_fascicolo_ufficio_competenza   IN seg_fascicoli.ufficio_competenza%TYPE,
      p_sottoclassifiche               IN VARCHAR2,
      p_id_fascicolo                   IN NUMBER default null)
      RETURN afc.t_ref_cursor;

    FUNCTION get_count_fascicoli (
      p_codice_amm                     IN VARCHAR2,
      p_codice_aoo                     IN VARCHAR2,
      p_fascicolo_anno                 IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero               IN seg_fascicoli.fascicolo_numero%TYPE,
      p_class_cod                      IN seg_classificazioni.class_cod%TYPE,
      p_class_dal                      IN VARCHAR2,
      p_fascicolo_oggetto              IN seg_fascicoli.fascicolo_oggetto%TYPE,
      p_mostra_tutti                   IN VARCHAR2,
      p_utente                         IN VARCHAR2,
      p_fascicolo_note                 IN seg_fascicoli.note%TYPE,
      p_fascicolo_ufficio_competenza   IN seg_fascicoli.ufficio_competenza%TYPE,
      p_sottoclassifiche               IN VARCHAR2,
      p_id_fascicolo                   IN NUMBER default null)
      RETURN NUMBER;

   FUNCTION get_classificazioni_secondarie (p_id_documento   IN VARCHAR2,
                                            p_codice_amm     IN VARCHAR2,
                                            p_codice_aoo     IN VARCHAR2,
                                            p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_competenti_creazione (p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_competenti (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_numero_fasc_ord (p_numero IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_utente_creazione (p_id_documento       IN NUMBER,
                                  p_utente_creazione   IN VARCHAR2,
                                  p_utente             IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_desc_unita_creazione (p_id_documento IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_privilegi (p_id_documento IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_classifica (
      p_idcartproveninez   IN VARCHAR2,
      p_utente                VARCHAR2,
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2,
      p_class_cod          IN seg_classificazioni.class_cod%TYPE,
      p_class_dal          IN VARCHAR2,
      p_class_desc         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_fascicolo (p_id_documento_fascicolo   IN VARCHAR2,
                                p_utente                      VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE elimina_fascicolo (p_id_fascicolo NUMBER, p_utente VARCHAR2);

   FUNCTION get_relazioni_attive (p_id_cartella   IN VARCHAR2,
                                  p_utente        IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_relazioni_passive (p_id_cartella   IN VARCHAR2,
                                   p_utente        IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_relazioni (p_area IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_smistamenti_in_carico (p_idrif                     VARCHAR2,
                                       p_utente                    VARCHAR2,
                                       p_controlla_assegnatario    NUMBER,
                                       p_distingui_eseguiti        NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_smistamenti_da_ricevere (p_idrif                     VARCHAR2,
                                         p_utente                    VARCHAR2,
                                         p_controlla_assegnatario    NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_smistamenti_eseguiti (p_idrif                     VARCHAR2,
                                      p_utente                    VARCHAR2,
                                      p_controlla_assegnatario    NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION is_da_ricevere (p_idrif                     VARCHAR2,
                            p_utente                    VARCHAR2,
                            p_controlla_assegnatario    NUMBER)
      RETURN NUMBER;

   FUNCTION is_in_carico (p_idrif                     VARCHAR2,
                          p_utente                    VARCHAR2,
                          p_controlla_assegnatario    NUMBER,
                          p_distingui_eseguiti        NUMBER)
      RETURN NUMBER;

   FUNCTION is_in_carico_solo_per_ass (p_idrif                 VARCHAR2,
                                       p_utente                VARCHAR2,
                                       p_distingui_eseguiti    NUMBER)
      RETURN NUMBER;

   FUNCTION is_da_ricevere_solo_per_ass (p_idrif    VARCHAR2,
                                         p_utente   VARCHAR2)
      RETURN NUMBER;

   PROCEDURE ricongiungi_doc (p_id_cartella       NUMBER,
                              p_id_smistamento    NUMBER,
                              p_data_carico       DATE,
                              p_utente            VARCHAR2);

   FUNCTION get_smistamenti_attivi (p_id_cartella IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION restano_smistamenti_attivi (p_id_cartella IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION esistono_documenti_altrove (p_id_cartella   IN VARCHAR2,
                                        p_unita            VARCHAR2)
      RETURN NUMBER;

   FUNCTION esistono_documenti_altrove_idf (p_id_fascicolo   IN VARCHAR2,
                                            p_unita             VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_ubicazione_diversa (p_id_cartella      IN NUMBER,
                                   p_id_documento        NUMBER,
                                   p_solo_fasc_main      NUMBER := 1)
      RETURN NUMBER;

   FUNCTION check_inserimento_documenti (p_class_cod           VARCHAR2,
                                         p_class_dal           VARCHAR2,
                                         p_fascicolo_anno      VARCHAR2,
                                         p_fascicolo_numero    VARCHAR2,
                                         p_utente              VARCHAR2)
      RETURN NUMBER;

   FUNCTION check_inserimento_documenti (p_id_documento VARCHAR2,
                                         p_utente       VARCHAR2)
      RETURN NUMBER;

   PROCEDURE insert_storico_fasc_docu (p_id_cartella     NUMBER,
                                       p_id_documento    NUMBER,
                                       p_utente          VARCHAR2,
                                       p_azione          VARCHAR2,
                                       p_cod_amm         VARCHAR2,
                                       p_cod_aoo         VARCHAR2);

   FUNCTION is_fascicolo (p_id_cartella NUMBER)
      RETURN NUMBER;

   FUNCTION get_desc_ubicazione (p_class_cod          IN VARCHAR2,
                                 p_class_dal             VARCHAR2,
                                 p_fascicolo_anno        NUMBER,
                                 p_fascicolo_numero      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_url_fasc (p_class_cod           VARCHAR2,
                          p_class_dal           VARCHAR2,
                          p_fascicolo_anno      NUMBER,
                          p_fascicolo_numero    VARCHAR2,
                          p_codice_amm          VARCHAR2,
                          p_codice_aoo          VARCHAR2,
                          p_utente              VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_oggetto (p_id_fascicolo IN NUMBER, p_utente IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_oggetto (p_class_cod           VARCHAR2,
                         p_class_dal           VARCHAR2,
                         p_fascicolo_anno      NUMBER,
                         p_fascicolo_numero    VARCHAR2,
                         p_codice_amm          VARCHAR2,
                         p_codice_aoo          VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_report
      RETURN VARCHAR2;

   FUNCTION storicizza_smistamento (p_class_cod                 VARCHAR2,
                                    p_fascicolo_anno            NUMBER,
                                    p_fascicolo_numero          VARCHAR2,
                                    p_id_smistamento            NUMBER,
                                    p_utente                    VARCHAR2,
                                    p_unita_trasmissione        VARCHAR2,
                                    p_des_unita_trasmissione    VARCHAR2,
                                    p_unita_ricevente           VARCHAR2,
                                    p_des_unita_ricevente       VARCHAR2,
                                    p_unita_chiusa              NUMBER,
                                    p_smistamento_nuovo         NUMBER,
                                    p_controlla_assegnatari     NUMBER,
                                    p_idrif                     VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_desc_scarto (p_id_documento IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE proponi_scarto (p_id_cartella NUMBER);

   PROCEDURE conserva (p_id_cartella NUMBER);

   PROCEDURE attendi_approvazione (p_id_cartella NUMBER);

   PROCEDURE non_scartabile (p_id_cartella NUMBER);

   PROCEDURE scarta (p_id_cartella        NUMBER,
                     p_nulla_osta         VARCHAR2,
                     p_data_nulla_osta    VARCHAR2);

   PROCEDURE attesa_app_scarto (p_id_cartella     NUMBER,
                                p_descrizione     VARCHAR2,
                                p_osservazioni    VARCHAR2,
                                p_anno_minimo     NUMBER,
                                p_anno_massimo    NUMBER,
                                p_pezzi           VARCHAR2,
                                p_peso            NUMBER,
                                p_ubicazione      VARCHAR2);

   PROCEDURE attesa_app_scarto (p_utente IN VARCHAR2);

   FUNCTION get_min_anno_doc_in_fasc (p_id_cartella IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_max_anno_doc_in_fasc (p_id_cartella IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_scarti
      RETURN afc.t_ref_cursor;


   FUNCTION get_fascicoli_da_scartare (p_utente        IN VARCHAR2,
                                       p_stato         IN VARCHAR2,
                                       p_data_scarto   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE AGGIORNA_DATI_SCARTO (p_id_fascicolo    NUMBER,
                                   p_descrizione     VARCHAR2,
                                   p_osservazioni    VARCHAR2,
                                   p_anno_minimo     NUMBER,
                                   p_anno_massimo    NUMBER,
                                   p_pezzi           VARCHAR2,
                                   p_peso            NUMBER,
                                   p_ubicazione      VARCHAR2);

   FUNCTION get_id_anno_fasc (p_id_cartella IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_cr_fascicolo (
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2,
      p_class_cod          IN seg_classificazioni.class_cod%TYPE,
      p_class_dal          IN VARCHAR2,
      p_fascicolo_anno     IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero   IN seg_fascicoli.fascicolo_numero%TYPE)
      RETURN VARCHAR2;

   FUNCTION get_id_cartella (p_class_cod           VARCHAR2,
                             p_class_dal           DATE,
                             p_fascicolo_anno      NUMBER,
                             p_fascicolo_numero    VARCHAR2,
                             p_codice_amm          VARCHAR2,
                             p_codice_aoo          VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_id_cartella (p_class_cod           VARCHAR2,
                             p_class_dal           VARCHAR2,
                             p_fascicolo_anno      NUMBER,
                             p_fascicolo_numero    VARCHAR2,
                             p_codice_amm          VARCHAR2,
                             p_codice_aoo          VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_classificazioni_new_fasc (
      p_codice_amm    IN VARCHAR2,
      p_codice_aoo    IN VARCHAR2,
      p_class_cod     IN seg_classificazioni.class_cod%TYPE,
      p_class_descr   IN seg_classificazioni.class_descr%TYPE,
      p_utente        IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE elimina_smistamenti (p_id_fasc NUMBER);

   PROCEDURE get_unita_data_comp_attuale (
      p_idrif_fascicolo          VARCHAR2,
      p_check_assegnazione       NUMBER := 0,
      p_assegnatario             VARCHAR2 := NULL,
      p_unita_attuale        OUT VARCHAR2,
      p_data_attuale         OUT DATE);

   FUNCTION get_padre_fascicoli (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_classificazioni.class_cod%TYPE,
      p_class_dal    IN VARCHAR2,
      p_id_padre     IN NUMBER)
      RETURN afc.t_ref_cursor;
END ag_fascicolo_utility;
/
CREATE OR REPLACE PACKAGE BODY ag_fascicolo_utility
IS
   /******************************************************************************
    NOME:        AG_FASCICOLO_UTILITY
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 fascicolo.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:   Le rev > 100 sono quelle apportate in Versione 3.5 o successiva
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009 MM     Creazione.
    001  16/05/2012 MM     Modifiche versione 2.1.
    002  21/05/2013 MM     Modifiche versione 2.2.
    003  27/10/2014 MM     Modifiche versione 2.3.
    004  12/02/2015 MM     Modificata GET_DATI_CLASSIFICA
    005  06/07/2015 MM     Modificata get_ubicazione
    006  25/08/2015 MM     Creata GET_ID_CARTELLA
    007  16/09/2016 MM     Creata ELIMINA_SMISTAMENTI
    008  11/11/2016 MM     Modificata GET_CLASSIFICAZIONI_NEW_FASC
    009  07/03/2017 MM     Versione 2.7
         26/04/2017 SC     ALLINEATO ALLO STANDARD
    010  13/02/2018 MM     Modificata get_fascicoli
    011  09/04/2018 MM     Modificata get_unita_competenti_creazione
    012  06/06/2018 MM     Modificata get_fascicoli per correzione ricerca su note
    013  05/11/2018 MM     Modificata get_fascicoli per gestione id_fascicolo
    014  28/12/2018 MM     Aggiunto in get_classificazione parametro p_class_dal

    101  13/11/2018 MM     Modificata get_dati_fascicolo per gestione
                           id_cartella e id_documento
    102  12/02/2019 SC     #32591 PERSONALIZZAZIONE - Inserimento fascicoli del personale
    103  29/05/2019 MM     Modificata get_classificazione.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '103';

   CURSOR c_campi (p_modello VARCHAR2)
   IS
      SELECT nome
        FROM campi_documento
       WHERE id_tipodoc IN (SELECT id_tipodoc
                              FROM tipi_documento
                             WHERE nome = p_modello);

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

   FUNCTION get_wrksp (p_id_cartella IN VARCHAR2, p_tipo_oggetto IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
         NOME:        GET_WRKSP

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    03/01/2013  MMUR  Prima emissione.
      ********************************************************************************/
      d_wrksp   VARCHAR2 (16);
   BEGIN
      d_wrksp := f_wrksp (p_id_cartella, p_tipo_oggetto);
      RETURN d_wrksp;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_WRKSP: ' || SQLERRM);
   END get_wrksp;

   FUNCTION check_ubicazione_vs_fascicolo (
      p_idrif_fascicolo            VARCHAR2,
      p_id_documento_protocollo    NUMBER)
      RETURN NUMBER
   IS
      dep_ufficio_ricevente   seg_unita.unita%TYPE := NULL;
      dep_ubicato_altrove     NUMBER := 0;
   BEGIN
      dep_ufficio_ricevente := get_unita_comp_attuale (p_idrif_fascicolo);

      IF dep_ufficio_ricevente IS NOT NULL
      THEN
         BEGIN
            SELECT DISTINCT 1
              INTO dep_ubicato_altrove
              FROM seg_smistamenti smis, documenti docu, smistabile_view prot
             WHERE     prot.id_documento = p_id_documento_protocollo
                   AND prot.idrif = smis.idrif
                   AND smis.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND smis.tipo_smistamento != 'DUMMY'
                   AND smis.stato_smistamento != 'F'
                   AND smis.ufficio_smistamento != dep_ufficio_ricevente;
         EXCEPTION
            WHEN OTHERS
            THEN
               dep_ubicato_altrove := 0;
         END;

         IF dep_ubicato_altrove = 1
         THEN
            BEGIN
               SELECT DISTINCT 0
                 INTO dep_ubicato_altrove
                 FROM seg_smistamenti smis,
                      documenti docu,
                      smistabile_view prot
                WHERE     prot.id_documento = p_id_documento_protocollo
                      AND prot.idrif = smis.idrif
                      AND smis.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND smis.tipo_smistamento != 'DUMMY'
                      AND smis.stato_smistamento != 'F'
                      AND smis.ufficio_smistamento = dep_ufficio_ricevente;
            EXCEPTION
               WHEN OTHERS
               THEN
                  dep_ubicato_altrove := 1;
            END;
         END IF;
      END IF;

      RETURN dep_ubicato_altrove;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.CHECK_UBICAZIONE_VS_FASCICOLO: ' || SQLERRM);
   END check_ubicazione_vs_fascicolo;

   FUNCTION check_inserimento_documenti (p_class_cod           VARCHAR2,
                                         p_class_dal           VARCHAR2,
                                         p_fascicolo_anno      VARCHAR2,
                                         p_fascicolo_numero    VARCHAR2,
                                         p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      depret              NUMBER := 1;
      dep_id_viewcartella NUMBER;
   BEGIN
      begin
      SELECT 0
        INTO depret
        FROM seg_fascicoli fasc,
             seg_classificazioni clas,
             cartelle cclas,
             documenti dclas,
             documenti dfasc,
             cartelle cfasc
       WHERE     fasc.class_cod = p_class_cod
             AND fasc.fascicolo_anno = p_fascicolo_anno
             AND fasc.fascicolo_numero = p_fascicolo_numero
             AND fasc.class_dal = TO_DATE (p_class_dal, 'dd/mm/yyyy')
             AND fasc.id_documento = dfasc.id_documento
             AND dfasc.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND dfasc.id_documento = cfasc.id_documento_profilo
             AND NVL (cfasc.stato, 'BO') != 'CA'
             AND fasc.class_cod = clas.class_cod
             AND fasc.class_dal = clas.class_dal
             AND dclas.id_documento = cclas.id_documento_profilo
             AND NVL (cclas.stato, 'BO') != 'CA'
             AND clas.id_documento = dclas.id_documento
             AND dclas.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND NVL (clas.ins_doc_in_fasc_con_sub, 'Y') = 'N'
             AND INSTR (fasc.fascicolo_numero, '.') = 0
             AND EXISTS
                    (SELECT 1
                       FROM seg_fascicoli fsub, cartelle csub, documenti dsub
                      WHERE     fsub.class_cod = fasc.class_cod
                            AND fsub.class_dal = fasc.class_dal
                            AND fsub.fascicolo_anno = fasc.fascicolo_anno
                            AND INSTR (fsub.fascicolo_numero, '.') > 0
                            AND INSTR (fsub.fascicolo_numero,
                                       fasc.fascicolo_numero || '.') = 1
                            AND fsub.id_documento = dsub.id_documento
                            AND dsub.id_documento = csub.id_documento_profilo
                            AND NVL (csub.stato, 'BO') != 'CA'
                            AND dsub.stato_documento NOT IN ('CA', 'RE', 'PB'));
      exception
      when no_data_found then

        select id_viewcartella
          into dep_id_viewcartella
          from seg_fascicoli fasc,
               documenti dfasc,
               cartelle cfasc,
               view_cartella vcart
         where fasc.class_cod = p_class_cod
           and fasc.fascicolo_anno = p_fascicolo_anno
           and fasc.fascicolo_numero = p_fascicolo_numero
           and fasc.class_dal = to_date (p_class_dal, 'dd/mm/yyyy')
           and fasc.id_documento = dfasc.id_documento
           and dfasc.stato_documento not in ('CA', 'RE', 'PB')
           and dfasc.id_documento = cfasc.id_documento_profilo
           and nvl (cfasc.stato, 'BO') != 'CA'
           and cfasc.id_cartella = vcart.id_cartella;
         if ag_competenze_fascicolo.is_in_classifica_pers(dep_id_viewcartella) then
            depret := AG_UTILITIES.VERIFICA_PRIVILEGIO_UTENTE(
                                            p_unita  => null,
                                            p_privilegio    => 'CLASPERS',
                                            p_utente        =>  p_utente,
                                            p_data          => trunc(sysdate));
          end if;

      end;

      RETURN depret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END check_inserimento_documenti;

   FUNCTION check_inserimento_documenti (p_id_documento VARCHAR2,
                                         p_utente       VARCHAR2)
      RETURN NUMBER
   IS
      depret   NUMBER := 0;
   BEGIN
      SELECT check_inserimento_documenti (class_cod,
                                          TO_CHAR (class_dal, 'dd/mm/yyyy'),
                                          fascicolo_anno,
                                          fascicolo_numero,
                                          p_utente)
        INTO depret
        FROM seg_fascicoli fasc, documenti dfasc, cartelle cfasc
       WHERE     fasc.id_documento = p_id_documento
             AND fasc.id_documento = dfasc.id_documento
             AND dfasc.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND dfasc.id_documento = cfasc.id_documento_profilo
             AND NVL (cfasc.stato, 'BO') != 'CA';

      RETURN depret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END check_inserimento_documenti;

   FUNCTION get_unita_comp_attuale (p_idrif_fascicolo       VARCHAR2,
                                    p_check_assegnazione    NUMBER := 0,
                                    p_assegnatario          VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      dep_ufficio_ricevente   seg_unita.unita%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT ufficio_smistamento
           INTO dep_ufficio_ricevente
           FROM seg_smistamenti smis, documenti docu
          WHERE     smis.idrif = p_idrif_fascicolo
                AND smis.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.tipo_smistamento = 'COMPETENZA'
                AND smis.stato_smistamento != 'F'
                AND (   p_check_assegnazione = 0
                     OR (    p_check_assegnazione = 1
                         AND (   p_assegnatario IS NULL
                              OR NVL (codice_assegnatario, '*') =
                                    p_assegnatario)));
      EXCEPTION
         WHEN OTHERS
         THEN
            dep_ufficio_ricevente := NULL;
      END;

      RETURN dep_ufficio_ricevente;
   END get_unita_comp_attuale;

   PROCEDURE get_unita_data_comp_attuale (
      p_idrif_fascicolo          VARCHAR2,
      p_check_assegnazione       NUMBER := 0,
      p_assegnatario             VARCHAR2 := NULL,
      p_unita_attuale        OUT VARCHAR2,
      p_data_attuale         OUT DATE)
   IS
   BEGIN
      BEGIN
         SELECT ufficio_smistamento, smistamento_Dal
           INTO p_unita_attuale, p_data_attuale
           FROM seg_smistamenti smis, documenti docu
          WHERE     smis.idrif = p_idrif_fascicolo
                AND smis.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.tipo_smistamento = 'COMPETENZA'
                AND smis.stato_smistamento != 'F'
                AND (   p_check_assegnazione = 0
                     OR (    p_check_assegnazione = 1
                         AND (   p_assegnatario IS NULL
                              OR NVL (codice_assegnatario, '*') =
                                    p_assegnatario)));
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END get_unita_data_comp_attuale;

   FUNCTION get_elenco_documenti (p_id_documento   IN NUMBER,
                                  p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_ELENCO_DOCUMENTI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    14/09/2012  MMUR  Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT    'Protocollo '
                  || proto_view.anno
                  || '/ '
                  || proto_view.numero
                  || ' del '
                  || TO_CHAR (proto_view.DATA, 'dd/mm/yyyy hh:mm:ss')
                     AS titolo,
                  DECODE (proto_view.modalita,
                          'ARR', 'Arrivo',
                          'PAR', 'Partenza',
                          'INT', 'Interno')
                     AS modalita,
                  DECODE (
                     AG_COMPETENZE_DOCUMENTO.is_riservato (
                        proto_view.id_documento),
                     'Y', DECODE (gdm_competenza.gdm_verifica (
                                     'DOCUMENTI',
                                     TO_CHAR (documenti.id_documento),
                                     'L',
                                     p_utente,
                                     'GDM',
                                     TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                     'N'),
                                  1, proto_view.oggetto,
                                  0, 'RISERVATO'),
                     proto_view.oggetto)
                     AS oggetto,
                     proto_view.class_cod
                  || ' '
                  || proto_view.fascicolo_anno
                  || '/'
                  || proto_view.fascicolo_numero
                     AS classifica,
                  DECODE (
                        proto_view.class_cod
                     || ' '
                     || proto_view.fascicolo_anno
                     || '/'
                     || proto_view.fascicolo_numero,
                        seg_fascicoli.class_cod
                     || ' '
                     || seg_fascicoli.fascicolo_anno
                     || '/'
                     || seg_fascicoli.fascicolo_numero, 'Principale',
                     'Secondaria')
                     AS classificazione,
                  DECODE (
                     ag_parametro.get_valore (
                        'ITER_FASCICOLI_',
                        proto_view.codice_amministrazione,
                        proto_view.codice_aoo,
                        '',
                        '@agVar@'),
                     'Y', check_ubicazione_vs_fascicolo (
                             seg_fascicoli.idrif,
                             documenti.id_documento),
                     'N', '')
                     AS ubicazione,
                  tipi_documento.nome AS modello,
                  DECODE (
                     tipi_documento.nome,
                     'LETTERA_USCITA',    posizione_flusso
                                       || ' ('
                                       || key_iter_lettera
                                       || ') ',
                     '')
                     AS stato,
                  f_icona_warea (documenti.id_documento,
                                 tipi_documento.id_tipodoc,
                                 '0',
                                 'N',
                                 ' ',
                                 'S')
                     AS icona,
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     documenti.id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'W',
                                                     '',
                                                     '',
                                                     -5,
                                                     'N')
                     AS url_modifica,
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     documenti.id_documento,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'R',
                                                     '',
                                                     '',
                                                     -5,
                                                     'N')
                     AS url_lettura,
                  links.ordinamento
             FROM proto_view,
                  documenti,
                  seg_fascicoli,
                  cartelle,
                  links,
                  tipi_documento
            WHERE     seg_fascicoli.id_documento = p_id_documento
                  AND documenti.id_tipodoc = tipi_documento.id_tipodoc
                  --AND proto_view.stato_pr != 'DP'
                  AND proto_view.id_documento = documenti.id_documento
                  AND seg_fascicoli.id_documento =
                         cartelle.id_documento_profilo
                  AND NVL (cartelle.stato, 'BO') != 'CA'
                  AND cartelle.id_cartella = links.id_cartella
                  AND links.tipo_oggetto = 'D'
                  AND links.id_oggetto = documenti.id_documento
                  AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
         /* AND ag_utilities.verifica_categoria_documento
                                                 (proto_view.id_documento,
                                                  'ATTI'
                                                 ) = 0
          AND ag_utilities.verifica_categoria_documento
                                                 (proto_view.id_documento,
                                                  'DELI'
                                                 ) = 0
          AND ag_utilities.verifica_categoria_documento
                                                 (proto_view.id_documento,
                                                  'DETE'
                                                 ) = 0*/
         ORDER BY ordinamento ASC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_ELENCO_DOCUMENTI: ' || SQLERRM);
   END get_elenco_documenti;

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

   FUNCTION get_select_ric_classificazioni (p_codice_amm         IN VARCHAR2,
                                            p_codice_aoo         IN VARCHAR2,
                                            p_stato_class        IN VARCHAR2,
                                            p_class_cod          IN VARCHAR2,
                                            p_class_descr        IN VARCHAR2,
                                            p_stato_fasc         IN VARCHAR2,
                                            p_solo_class         IN VARCHAR2,
                                            p_anno_fasc          IN VARCHAR2,
                                            p_numero_fasc        IN VARCHAR2,
                                            p_fasc_descr         IN VARCHAR2,
                                            p_class_prot         IN VARCHAR2,
                                            p_mostra_tutte       IN VARCHAR2,
                                            p_utente             IN VARCHAR2,
                                            p_sottoclassifiche   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
         NOME:        GET_SELECT_RIC_CLASSIFICAZIONI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    06/06/2018  DS  Prima emissione.
      ********************************************************************************/
      d_select             VARCHAR2 (32767);
      d_mostra_tutte       VARCHAR2 (1);
      d_sottoclassifiche   VARCHAR2 (1);
   BEGIN
      d_mostra_tutte :=
         NVL (p_mostra_tutte,
              ag_parametro.get_valore ('CLASS_CERCA_TUTTE',
                                       p_codice_amm,
                                       p_codice_aoo,
                                       'Y'));

      d_sottoclassifiche := NVL (p_sottoclassifiche, 'Y');

      d_select :=
            'SELECT id_cartella,
                      codice,
                      descrizione descrizione,
                      tipo,
                      stato,
                      class_cod,
                      TO_CHAR (class_dal, ''dd/mm/yyyy'') class_dal,
                      fasc_anno,
                      fasc_numero_ord,
                      class_descr,
                      '''' fascicolo_oggetto,
                      fascicolo_numero
                 FROM (SELECT cart.id_cartella,
                              clas.class_cod AS codice,
                              class_dal,
                              clas.class_descr AS descrizione,
                              ''Classificazione'' AS tipo,
                              DECODE (clas.class_al, NULL, ''Aperta'', ''Chiusa'')
                                 AS stato,
                              clas.class_cod class_cod,
                              0 fasc_anno,
                              ''0000000'' fasc_numero_ord,
                              class_descr,
                              '''' AS fascicolo_oggetto,
                              ''0'' fascicolo_numero
                         FROM seg_classificazioni clas,
                              documenti docu,
                              cartelle cart
                        WHERE     (   '''
         || p_stato_class
         || ''' = ''Y'' AND nvl(class_al, trunc(sysdate)) >= trunc(sysdate)
                                   OR     '''
         || p_stato_class
         || ''' = ''N''
                                      AND class_al < trunc(sysdate))
                              AND (  '''
         || p_solo_class
         || ''' = ''Y''
                                   OR (  '''
         || p_anno_fasc
         || ''' IS NULL
                                       AND '''
         || p_numero_fasc
         || ''' IS NULL
                                       AND '''
         || p_fasc_descr
         || ''' IS NULL))
                              AND clas.codice_amministrazione = '''
         || p_codice_amm
         || '''
                              AND clas.codice_aoo = '''
         || p_codice_aoo
         || '''
                              AND (   class_cod <> '''
         || p_class_prot
         || '''
                                   OR '''
         || p_class_prot
         || ''' IS NULL)';

      IF d_sottoclassifiche = 'Y'
      THEN
         d_select :=
               d_select
            || ' AND clas.class_cod LIKE ('''
            || p_class_cod
            || '%'')';
      ELSE
         d_select :=
            d_select || ' AND clas.class_cod = ''' || p_class_cod || ''' ';
      END IF;

      d_select :=
            d_select
         || ' AND UPPER (clas.class_descr) LIKE
                                     (''%'' || UPPER ('''
         || p_class_descr
         || ''') || ''%'')
                              AND docu.id_documento = clas.id_documento
                              AND clas.id_documento = cart.id_documento_profilo
                              AND clas.contenitore_documenti = ''Y''
                              AND NVL (docu.stato_documento, ''BO'') NOT IN
                                     (''CA'', ''RE'', ''PB'')
                              AND TRUNC (SYSDATE) BETWEEN clas.class_dal
                                                      AND NVL (
                                                             clas.class_al,
                                                             TO_DATE (''01/01/2999'',
                                                                      ''dd/mm/yyyy''))
                       UNION
                       SELECT DECODE (fasc.fascicolo_anno,
                                      NULL, cart_clas.id_cartella,
                                      cart_fasc.id_cartella)
                                 id_cartella,
                                 clas.class_cod
                              || DECODE (
                                    fasc.fascicolo_anno,
                                    NULL, '''',
                                       '': ''
                                    || fasc.fascicolo_anno
                                    || ''\''
                                    || fasc.fascicolo_numero)
                                 AS codice,
                              clas.class_dal,
                              DECODE (fasc.fascicolo_anno,
                                      NULL, clas.class_descr,
                                      ag_fascicolo_utility.get_oggetto (fasc.id_documento, '''
         || p_utente
         || '''))
                                 AS descrizione,
                              DECODE (
                                 fasc.fascicolo_anno,
                                 NULL, ''Classificazione'',
                                 DECODE (
                                    ag_fascicolo_utility.esistono_documenti_altrove_idf (
                                       fasc.id_documento,
                                       NULL),
                                    0, DECODE (INSTR (fasc.fascicolo_numero, ''.''),
                                               0, ''SEGFASCICOLO'',
                                               ''SOTTOFASCICOLO''),
                                    DECODE (INSTR (fasc.fascicolo_numero,''.''),
                                            0, ''SEGFASCICOLOOUT'',
                                            ''SOTTOFASCICOLOOUT'')))
                                 AS tipo,
                              DECODE (
                                 fasc.class_al,
                                 NULL, DECODE (fasc.fascicolo_anno,
                                               NULL, ''Aperta'',
                                               ''Aperto''),
                                 ''Chiuso'')
                                 AS stato,
                              clas.class_cod,
                              NVL (fasc.fascicolo_anno, 0) fasc_anno,
                              ag_fascicolo_utility.get_numero_fasc_ord (fasc.fascicolo_numero)
                                 fasc_numero_ord,
                              clas.class_descr,
                              ag_fascicolo_utility.get_oggetto (fasc.id_documento, '''
         || p_utente
         || ''')
                                 fascicolo_oggetto,
                              fascicolo_numero
                         FROM seg_classificazioni clas,
                              seg_fascicoli fasc,
                              documenti docu_fasc,
                              cartelle cart_fasc,
                              documenti docu_clas,
                              cartelle cart_clas
                        WHERE     ( '''
         || p_stato_class
         || ''' = ''Y'' AND nvl(clas.class_al, trunc(sysdate)) >= trunc(sysdate)
                                   OR  '''
         || p_stato_class
         || ''' = ''N''
                                      AND nvl(clas.class_al, trunc(sysdate)) < trunc(sysdate))
                              AND (  '''
         || p_stato_fasc
         || ''' = ''Y''
                                      AND fasc.stato_fascicolo = 1
                                   OR  '''
         || p_stato_fasc
         || ''' = ''N''
                                      AND fasc.stato_fascicolo <> 1)
                              AND clas.codice_amministrazione = '''
         || p_codice_amm
         || '''
                              AND clas.codice_aoo = '''
         || p_codice_aoo
         || '''
                              AND fasc.codice_amministrazione = '''
         || p_codice_amm
         || '''
                              AND fasc.codice_aoo = '''
         || p_codice_aoo
         || '''
                              AND ( '''
         || p_solo_class
         || ''' = ''N''
                                   OR ( '''
         || p_anno_fasc
         || ''' IS NOT NULL
                                       OR '''
         || p_numero_fasc
         || ''' IS NOT NULL
                                       OR '''
         || p_fasc_descr
         || ''' IS NOT NULL))
                              AND fasc.class_dal(+) = clas.class_dal
                              AND fasc.class_cod(+) = clas.class_cod
                              AND (   (   fasc.class_cod
                                       || '': ''
                                       || fasc.fascicolo_anno
                                       || ''\''
                                       || fasc.fascicolo_numero) <> '''
         || p_class_prot
         || '''
                                   OR '''
         || p_class_prot
         || ''' IS NULL) ';

      IF d_sottoclassifiche = 'Y'
      THEN
         d_select :=
               d_select
            || ' AND clas.class_cod LIKE ('''
            || p_class_cod
            || '%'') ';
      ELSE
         d_select :=
            d_select || ' AND clas.class_cod = ''' || p_class_cod || ''' ';
      END IF;

      d_select :=
            d_select
         || ' AND UPPER (clas.class_descr) LIKE
                                     (''%'' || UPPER ('''
         || p_class_descr
         || ''') || ''%'')
                              AND fasc.fascicolo_anno(+) LIKE
                                     NVL ('''
         || p_anno_fasc
         || ''', ''%'')
                              AND fasc.fascicolo_numero(+) LIKE
                                     NVL ('''
         || p_numero_fasc
         || ''', ''%'')
                              AND (   UPPER (fasc.fascicolo_oggetto) LIKE
                                         (''%'' || UPPER ('''
         || p_fasc_descr
         || ''') || ''%'')
                                   OR '''
         || p_fasc_descr
         || ''' IS NULL)
                              AND docu_fasc.id_documento(+) = fasc.id_documento
                              AND docu_fasc.id_documento =
                                     cart_fasc.id_documento_profilo(+)
                              AND clas.contenitore_documenti(+) = ''Y''
                              AND NVL (docu_fasc.stato_documento, ''BO'') NOT IN
                                     (''CA'', ''RE'', ''PB'')
                              AND TRUNC (SYSDATE) BETWEEN NVL (fasc.class_dal,
                                                               TRUNC (SYSDATE))
                                                      AND NVL (
                                                             fasc.class_al,
                                                             TO_DATE (''01/01/2999'',
                                                                      ''dd/mm/yyyy''))
                              AND docu_clas.id_documento = clas.id_documento
                              AND docu_clas.codice_richiesta =
                                     cart_clas.id_cartella
                              AND NVL (docu_clas.stato_documento, ''BO'') NOT IN
                                     (''CA'', ''RE'', ''PB'')
                              AND (   '''
         || p_stato_class
         || ''' = ''N''
                                   OR TRUNC (SYSDATE) BETWEEN clas.class_dal
                                                          AND NVL (
                                                                 clas.class_al,
                                                                 TO_DATE (
                                                                    ''01/01/2999'',
                                                                    ''dd/mm/yyyy'')))) a
               HAVING DECODE ('''
         || d_mostra_tutte
         || ''',
                              ''Y'', 1,
                              gdm_competenza.gdm_verifica (
                                 ''DOCUMENTI'',
                                 TO_CHAR (a.id_cartella),
                                 ''L'',
                                 '''
         || p_utente
         || ''',
                                 ''GDM'',
                                 TO_CHAR (SYSDATE, ''DD/MM/YYYY''))) = ''1''
             GROUP BY a.id_cartella,
                      codice,
                      descrizione,
                      tipo,
                      stato,
                      class_cod,
                      class_dal,
                      fasc_anno,
                      fasc_numero_ord,
                      class_descr,
                      fascicolo_oggetto,
                      fascicolo_numero
             ORDER BY NLSSORT (class_cod, ''NLS_LANGUAGE=American''),
                      fasc_anno,
                      fasc_numero_ord';

      RETURN d_select;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_FASCICOLO_UTILITY.GET_SELECT_RIC_CLASSIFICAZIONI: '
            || SQLERRM);
   END get_select_ric_classificazioni;

   FUNCTION get_ricerche_classificazioni (p_codice_amm         IN VARCHAR2,
                                          p_codice_aoo         IN VARCHAR2,
                                          p_stato_class        IN VARCHAR2,
                                          p_class_cod          IN VARCHAR2,
                                          p_class_descr        IN VARCHAR2,
                                          p_stato_fasc         IN VARCHAR2,
                                          p_solo_class         IN VARCHAR2,
                                          p_anno_fasc          IN VARCHAR2,
                                          p_numero_fasc        IN VARCHAR2,
                                          p_fasc_descr         IN VARCHAR2,
                                          p_class_prot         IN VARCHAR2,
                                          p_mostra_tutte       IN VARCHAR2,
                                          p_utente             IN VARCHAR2,
                                          p_sottoclassifiche   IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_RICERCHE_CLASSIFICAZIONI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  MM  Prima emissione.
         01    07/06/2018  DS  modifica.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
      d_select   VARCHAR2 (32767);
   BEGIN
      d_select :=
         get_select_ric_classificazioni (P_CODICE_AMM,
                                         P_CODICE_AOO,
                                         P_STATO_CLASS,
                                         P_CLASS_COD,
                                         P_CLASS_DESCR,
                                         P_STATO_FASC,
                                         P_SOLO_CLASS,
                                         P_ANNO_FASC,
                                         P_NUMERO_FASC,
                                         P_FASC_DESCR,
                                         P_CLASS_PROT,
                                         P_MOSTRA_TUTTE,
                                         P_UTENTE,
                                         P_SOTTOCLASSIFICHE);

      DBMS_OUTPUT.put_line (d_select);
      integrityPackage.LOG (d_select);

      OPEN d_result FOR d_select;

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_RICERCHE_CLASSIFICAZIONI: ' || SQLERRM);
   END get_ricerche_classificazioni;

   FUNCTION get_count_ric_classificazioni (p_codice_amm         IN VARCHAR2,
                                           p_codice_aoo         IN VARCHAR2,
                                           p_stato_class        IN VARCHAR2,
                                           p_class_cod          IN VARCHAR2,
                                           p_class_descr        IN VARCHAR2,
                                           p_stato_fasc         IN VARCHAR2,
                                           p_solo_class         IN VARCHAR2,
                                           p_anno_fasc          IN VARCHAR2,
                                           p_numero_fasc        IN VARCHAR2,
                                           p_fasc_descr         IN VARCHAR2,
                                           p_class_prot         IN VARCHAR2,
                                           p_mostra_tutte       IN VARCHAR2,
                                           p_utente             IN VARCHAR2,
                                           p_sottoclassifiche   IN VARCHAR2)
      RETURN NUMBER
   IS
      /*****************************************************************************
         NOME:        GET_COUNT_RIC_CLASSIFICAZIONI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    06/06/2018  DS  Prima emissione.
      ********************************************************************************/
      n_count    NUMBER := 0;
      d_select   VARCHAR2 (32767);
   BEGIN
      d_select :=
         get_select_ric_classificazioni (P_CODICE_AMM,
                                         P_CODICE_AOO,
                                         P_STATO_CLASS,
                                         P_CLASS_COD,
                                         P_CLASS_DESCR,
                                         P_STATO_FASC,
                                         P_SOLO_CLASS,
                                         P_ANNO_FASC,
                                         P_NUMERO_FASC,
                                         P_FASC_DESCR,
                                         P_CLASS_PROT,
                                         P_MOSTRA_TUTTE,
                                         P_UTENTE,
                                         P_SOTTOCLASSIFICHE);

      DBMS_OUTPUT.put_line (d_select);
      integrityPackage.LOG (d_select);

      EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM (' || d_select || ')'
         INTO n_count;

      DBMS_OUTPUT.put_line ('Totale record. ' || n_count);

      RETURN n_count;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_COUNT_RIC_CLASSIFICAZIONI: ' || SQLERRM);
   END get_count_ric_classificazioni;

   FUNCTION get_unita_classificazione (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_unita_classifica.class_cod%TYPE)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_UNITA_CLASSIFICA

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  MM  Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT id_documento,
                  class_cod,
                  class_dal,
                  descrizione_unita_smistamento,
                  unita
             FROM seg_unita_classifica
            WHERE     class_cod = p_class_cod
                  AND codice_amministrazione = p_codice_amm
                  AND codice_aoo = p_codice_aoo
         ORDER BY unita;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_UNITA_CLASSIFICA: ' || SQLERRM);
   END get_unita_classificazione;

   FUNCTION get_numerazioni_fascicoli (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_numerazioni_classifica.class_cod%TYPE,
      p_class_dal    IN VARCHAR2,
      p_anno         IN NUMBER,
      p_id_padre     IN NUMBER,
      p_utente       IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_NUMERAZIONI_FASCICOLI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  MM  Prima emissione.
         01    05/04/2017  SC  Gestione date privilegi
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
      d_clas_pers VARCHAR2(1000);
   BEGIN
      d_clas_pers := AG_PARAMETRO.GET_VALORE(
                        p_codice         => 'CLAS_FASC_PERS_',
                        p_codice_amm     => p_codice_amm,
                        p_codice_aoo     => p_codice_aoo,
                        p_default        => '***');
      if d_clas_pers = p_class_cod AND AG_UTILITIES.VERIFICA_PRIVILEGIO_UTENTE(
                                            p_unita  => null,
                                            p_privilegio    => 'CLASPERS',
                                            p_utente        =>  p_utente,
                                            p_data          => trunc(sysdate)) = 0 then
         OPEN d_result FOR
         SELECT TO_NUMBER(NULL) fascicolo_anno,
                NULL ultimo_numero_sub,
                p_id_padre id_documento,
                TO_NUMBER(NULL) id_cartella
           FROM dual;
         RETURN d_result;
      end if;
      OPEN d_result FOR
         SELECT seg_fascicoli.fascicolo_anno,
                NULL ultimo_numero_sub,
                p_id_padre id_documento,
                cartelle.id_cartella
           FROM cartelle, seg_fascicoli
          WHERE     seg_fascicoli.id_documento = p_id_padre
                AND cartelle.id_documento_profilo =
                       seg_fascicoli.id_documento
                AND p_id_padre IS NOT NULL
         UNION
         SELECT p_anno,
                NULL ultimo_numero_sub,
                p_id_padre id_documento,
                cartelle.id_cartella
           FROM cartelle, seg_classificazioni
          WHERE     seg_classificazioni.id_documento = p_id_padre
                AND cartelle.id_documento_profilo =
                       seg_classificazioni.id_documento
                AND p_id_padre IS NOT NULL
         UNION
         SELECT seg_numerazioni_classifica.anno fascicolo_anno,
                seg_numerazioni_classifica.ultimo_numero_sub,
                seg_classificazioni.id_documento,
                cartelle.id_cartella
           FROM seg_numerazioni_classifica,
                documenti dnucl,
                seg_classificazioni,
                documenti dclas,
                cartelle
          WHERE     seg_numerazioni_classifica.class_cod = p_class_cod
                AND seg_numerazioni_classifica.codice_amministrazione =
                       p_codice_amm
                AND seg_numerazioni_classifica.codice_aoo = p_codice_aoo
                AND seg_numerazioni_classifica.class_dal =
                       TO_DATE (p_class_dal, 'dd/mm/yyyy')
                AND dnucl.id_documento =
                       seg_numerazioni_classifica.id_documento
                AND dnucl.stato_documento NOT IN ('CA', 'RE')
                AND seg_classificazioni.codice_amministrazione = p_codice_amm
                AND seg_classificazioni.codice_aoo = p_codice_aoo
                AND seg_classificazioni.class_cod =
                       seg_numerazioni_classifica.class_cod
                AND seg_classificazioni.class_dal =
                       seg_numerazioni_classifica.class_dal
                AND cartelle.id_documento_profilo = dclas.id_documento
                AND dclas.id_documento = seg_classificazioni.id_documento
                AND dclas.stato_documento NOT IN ('CA', 'RE')
                AND seg_numerazioni_classifica.anno =
                       TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
                AND p_id_padre IS NULL
         UNION
         SELECT seg_numerazioni_classifica.anno fascicolo_anno,
                seg_numerazioni_classifica.ultimo_numero_sub,
                seg_classificazioni.id_documento,
                cartelle.id_cartella
           FROM seg_numerazioni_classifica,
                seg_classificazioni,
                documenti dclas,
                cartelle,
                documenti dnucl,
                ag_priv_utente_tmp
          WHERE     seg_numerazioni_classifica.class_cod = p_class_cod
                AND seg_numerazioni_classifica.codice_amministrazione =
                       p_codice_amm
                AND seg_numerazioni_classifica.codice_aoo = p_codice_aoo
                AND seg_numerazioni_classifica.class_dal =
                       TO_DATE (p_class_dal, 'dd/mm/yyyy')
                AND seg_numerazioni_classifica.anno >
                       TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
                AND dnucl.id_documento =
                       seg_numerazioni_classifica.id_documento
                AND dnucl.stato_documento NOT IN ('CA', 'RE')
                AND seg_classificazioni.codice_amministrazione = p_codice_amm
                AND seg_classificazioni.codice_aoo = p_codice_aoo
                AND seg_classificazioni.class_cod =
                       seg_numerazioni_classifica.class_cod
                AND seg_classificazioni.class_dal =
                       seg_numerazioni_classifica.class_dal
                AND seg_classificazioni.num_illimitata = 'N'
                AND dclas.id_documento = seg_classificazioni.id_documento
                AND dclas.stato_documento NOT IN ('CA', 'RE')
                AND cartelle.id_documento_profilo = dclas.id_documento
                AND ag_priv_utente_tmp.utente = p_utente
                AND ag_priv_utente_tmp.privilegio = 'CFFUTURO'
                AND TRUNC (SYSDATE) <=
                       NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                AND p_id_padre IS NULL
         UNION
         SELECT seg_numerazioni_classifica.anno fascicolo_anno,
                seg_numerazioni_classifica.ultimo_numero_sub,
                seg_classificazioni.id_documento,
                cartelle.id_cartella
           FROM seg_numerazioni_classifica,
                ag_priv_utente_tmp,
                documenti dnucl,
                seg_classificazioni,
                documenti dclas,
                cartelle
          WHERE     seg_numerazioni_classifica.class_cod = p_class_cod
                AND seg_numerazioni_classifica.codice_amministrazione =
                       p_codice_amm
                AND seg_numerazioni_classifica.codice_aoo = p_codice_aoo
                AND seg_numerazioni_classifica.class_dal =
                       TO_DATE (p_class_dal, 'dd/mm/yyyy')
                AND dnucl.id_documento =
                       seg_numerazioni_classifica.id_documento
                AND dnucl.stato_documento NOT IN ('CA', 'RE')
                AND seg_classificazioni.codice_amministrazione = p_codice_amm
                AND seg_classificazioni.codice_aoo = p_codice_aoo
                AND seg_classificazioni.class_cod =
                       seg_numerazioni_classifica.class_cod
                AND seg_classificazioni.class_dal =
                       seg_numerazioni_classifica.class_dal
                AND seg_classificazioni.num_illimitata = 'N'
                AND dclas.id_documento = seg_classificazioni.id_documento
                AND dclas.stato_documento NOT IN ('CA', 'RE')
                AND cartelle.id_documento_profilo = dclas.id_documento
                AND ag_priv_utente_tmp.utente = p_utente
                AND ag_priv_utente_tmp.privilegio = 'CFANYY'
                AND TRUNC (SYSDATE) <=
                       NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                AND seg_numerazioni_classifica.anno <
                       TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
                AND p_id_padre IS NULL
         ORDER BY fascicolo_anno DESC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_NUMERAZIONI_FASCICOLI: ' || SQLERRM);
   END get_numerazioni_fascicoli;

   FUNCTION get_classificazione (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_classificazioni.class_cod%TYPE,
      p_class_dal    IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_CLASSIFICAZIONE

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  MM  Prima emissione.
      ********************************************************************************/
      d_result                  afc.t_ref_cursor;
      d_found                   NUMBER := 1;
      d_class_cod               seg_classificazioni.class_cod%TYPE;
      d_contenitore_documenti   seg_classificazioni.contenitore_documenti%TYPE;
   BEGIN
      BEGIN
         SELECT class_cod, contenitore_documenti
           INTO d_class_cod, d_contenitore_documenti
           FROM seg_classificazioni, documenti docu_clas, cartelle cart_clas
          WHERE     class_cod = p_class_cod
                AND codice_amministrazione = p_codice_amm
                AND codice_aoo = p_codice_aoo
                AND NVL (TO_DATE (p_class_dal, 'dd/mm/yyyy'),
                         TRUNC (SYSDATE)) BETWEEN class_dal
                                              AND NVL (
                                                     class_al,
                                                     TO_DATE ('01/01/2999',
                                                              'dd/mm/yyyy'))
                AND docu_clas.id_documento = seg_classificazioni.id_documento
                AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND cart_clas.id_documento_profilo = docu_clas.id_documento
                AND NVL (cart_clas.stato, 'BO') <> 'CA';

         IF d_contenitore_documenti = 'N'
         THEN
            d_found := 0;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_found := 0;
      END;

      IF d_found = 0
      THEN
         d_class_cod := p_class_cod || '%';
      END IF;

      OPEN d_result FOR
         SELECT class_cod,
                class_dal,
                class_descr,
                seg_classificazioni.id_documento,
                class_al
           FROM seg_classificazioni, documenti docu_clas, cartelle cart_clas
          WHERE     class_cod LIKE d_class_cod
                AND codice_amministrazione = p_codice_amm
                AND codice_aoo = p_codice_aoo
                AND NVL (TO_DATE (p_class_dal, 'dd/mm/yyyy'),
                         TRUNC (SYSDATE)) BETWEEN class_dal
                                              AND NVL (
                                                     class_al,
                                                     TO_DATE ('01/01/2999',
                                                              'dd/mm/yyyy'))
                AND docu_clas.id_documento = seg_classificazioni.id_documento
                AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND cart_clas.id_documento_profilo = docu_clas.id_documento
                AND NVL (cart_clas.stato, 'BO') <> 'CA';

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_CLASSIFICAZIONE: ' || SQLERRM);
   END get_classificazione;

   FUNCTION get_classificazioni (
      p_codice_amm     IN VARCHAR2,
      p_codice_aoo     IN VARCHAR2,
      p_class_cod      IN seg_classificazioni.class_cod%TYPE,
      p_class_descr    IN seg_classificazioni.class_descr%TYPE,
      p_mostra_tutte   IN VARCHAR2,
      p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_CLASSIFICAZIONI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  SN  Prima emissione.
      ********************************************************************************/
      d_result         afc.t_ref_cursor;
      d_mostra_tutte   VARCHAR2 (1);
   BEGIN
      d_mostra_tutte :=
         NVL (p_mostra_tutte,
              ag_parametro.get_valore ('CLASS_CERCA_TUTTE',
                                       p_codice_amm,
                                       p_codice_aoo,
                                       'Y'));

      OPEN d_result FOR
           SELECT anno,
                  class_cod,
                  class_dal,
                  class_descr,
                  id_documento,
                  class_al,
                  id_cartella
             FROM (SELECT anno,
                          class_cod,
                          class_dal,
                          class_descr,
                          seg_classificazioni.id_documento,
                          class_al,
                          cart_clas.id_cartella
                     FROM seg_classificazioni,
                          documenti docu_clas,
                          cartelle cart_clas
                    WHERE     class_cod LIKE p_class_cod || '%'
                          AND UPPER (class_descr) LIKE
                                 '%' || UPPER (p_class_descr) || '%'
                          AND codice_amministrazione = p_codice_amm
                          AND codice_aoo = p_codice_aoo
                          --             AND contenitore_documenti = 'Y'
                          AND TRUNC (SYSDATE) BETWEEN class_dal
                                                  AND NVL (
                                                         class_al,
                                                         TO_DATE ('01/01/2999',
                                                                  'dd/mm/yyyy'))
                          AND docu_clas.id_documento =
                                 seg_classificazioni.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                   UNION ALL
                   SELECT TO_NUMBER (NULL),
                          TO_CHAR (NULL),
                          TO_DATE (NULL),
                          TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_DATE (NULL),
                          TO_NUMBER (NULL)
                     FROM DUAL
                    WHERE d_mostra_tutte = 'N') a,
                  DUAL
           HAVING    DECODE (d_mostra_tutte,
                             'Y', 1,
                             gdm_competenza.gdm_verifica (
                                'DOCUMENTI',
                                TO_CHAR (a.id_documento),
                                'L',
                                p_utente,
                                'GDM',
                                TO_CHAR (SYSDATE, 'DD/MM/YYYY')))
                  || dummy = '1X'
         GROUP BY class_cod,
                  anno,
                  class_dal,
                  class_descr,
                  id_documento,
                  class_al,
                  id_cartella,
                  dummy
         ORDER BY NLSSORT (class_cod, 'NLS_LANGUAGE=American'),
                  anno,
                  class_dal,
                  class_descr;

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_CLASSIFICAZIONI: ' || SQLERRM);
   END get_classificazioni;

   FUNCTION get_classificazioni_new_fasc (
      p_codice_amm    IN VARCHAR2,
      p_codice_aoo    IN VARCHAR2,
      p_class_cod     IN seg_classificazioni.class_cod%TYPE,
      p_class_descr   IN seg_classificazioni.class_descr%TYPE,
      p_utente        IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_CLASSIFICAZIONI_NEW_FASC

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         000   05/12/2008  SN       Prima emissione.
         008   11/11/2016  MM       Introduzione controllo sulle competenze di
                                    inserimento nella classifica
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT anno,
                  class_cod,
                  class_dal,
                  class_descr,
                  seg_classificazioni.id_documento,
                  class_al,
                  cart_clas.id_cartella
             FROM seg_classificazioni,
                  documenti docu_clas,
                  cartelle cart_clas,
                  view_cartella
            WHERE     class_cod LIKE p_class_cod || '%'
                  AND UPPER (class_descr) LIKE
                         '%' || UPPER (p_class_descr) || '%'
                  AND codice_amministrazione = p_codice_amm
                  AND codice_aoo = p_codice_aoo
                  AND contenitore_documenti = 'Y'
                  AND docu_clas.id_documento = seg_classificazioni.id_documento
                  AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                    'RE',
                                                                    'PB')
                  AND cart_clas.id_documento_profilo = docu_clas.id_documento
                  AND NVL (cart_clas.stato, 'BO') <> 'CA'
                  AND view_cartella.id_cartella = cart_clas.id_cartella
                  AND AG_COMPETENZE_CLASSIFICAZIONE.INSERIMENTO (
                         view_cartella.id_viewcartella,
                         p_utente) = 1
         ORDER BY NLSSORT (class_cod, 'NLS_LANGUAGE=American'),
                  anno,
                  class_dal,
                  class_descr;

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_CLASSIFICAZIONI_NEW_FASC: ' || SQLERRM);
   END;

   FUNCTION get_oggetto (p_id_fascicolo IN NUMBER, p_utente IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
          NOME:        GET_OGGETTO
          DESCRIZIONE:

          RITORNO:

          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  SN  Prima emissione.
      ********************************************************************************/
      d_result   VARCHAR2 (4000);
   BEGIN
      SELECT DECODE (
                NVL (riservato, 'N'),
                'Y', DECODE (
                        ag_competenze_fascicolo.lettura (
                           vica_fasc.id_viewcartella,
                           p_utente),
                        '0', 'RISERVATO',
                        fasc.fascicolo_oggetto),
                fasc.fascicolo_oggetto)
                fascicolo_oggetto
        INTO d_result
        FROM seg_fascicoli fasc, cartelle cart_fasc, view_cartella vica_fasc
       WHERE     fasc.id_documento = p_id_fascicolo
             AND vica_fasc.id_cartella = cart_fasc.id_cartella
             AND cart_fasc.id_documento_profilo = fasc.id_documento;

      RETURN d_result;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         SELECT '' fascicolo_oggetto INTO d_result FROM DUAL;

         RETURN d_result;
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLI: ' || SQLERRM);
   END;

   FUNCTION get_oggetto (p_class_cod           VARCHAR2,
                         p_class_dal           VARCHAR2,
                         p_fascicolo_anno      NUMBER,
                         p_fascicolo_numero    VARCHAR2,
                         p_codice_amm          VARCHAR2,
                         p_codice_aoo          VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
            NOME:        GET_OGGETTO
            DESCRIZIONE: utilizzata per le query di conservazione

            RITORNO:

            Rev.  Data       Autore  Descrizione.
            00    14/08/2015  LT  Prima emissione.
        ********************************************************************************/
      d_result      VARCHAR2 (4000);
      d_class_dal   DATE := TO_DATE (p_class_dal, 'dd/mm/yyyy');
   BEGIN
      SELECT fascicolo_oggetto
        INTO d_result
        FROM seg_fascicoli fasc, cartelle cart_fasc
       WHERE     class_cod = p_class_cod
             AND class_dal = d_class_dal
             AND fascicolo_anno = p_fascicolo_anno
             AND fascicolo_numero = p_fascicolo_numero
             AND codice_amministrazione = p_codice_amm
             AND codice_aoo = p_codice_aoo
             AND cart_fasc.id_documento_profilo = fasc.id_documento
             AND NVL (cart_fasc.stato, 'BO') <> 'CA';

      RETURN d_result;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         SELECT '' fascicolo_oggetto INTO d_result FROM DUAL;

         RETURN d_result;
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLI: ' || SQLERRM);
   END;

   FUNCTION get_fascicolo (
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2,
      p_class_cod          IN seg_classificazioni.class_cod%TYPE,
      p_fascicolo_anno     IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero   IN seg_fascicoli.fascicolo_numero%TYPE,
      p_utente             IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_FASCICOLO

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  SN  Prima emissione.
         102   12/02/2019  SC  #32591 PERSONALIZZAZIONE - Inserimento fascicoli del personale
      ********************************************************************************/
      d_result             afc.t_ref_cursor;
      d_found              NUMBER := 1;
      d_class_cod          seg_fascicoli.class_cod%TYPE;
      d_fascicolo_numero   seg_fascicoli.fascicolo_numero%TYPE;
      d_clas_pers          parametri.valore%TYPE;
   BEGIN
      d_class_cod := p_class_cod;
      d_fascicolo_numero := p_fascicolo_numero;
      d_clas_pers := AG_PARAMETRO.GET_VALORE(
                        p_codice         => 'CLAS_FASC_PERS_',
                        p_codice_amm     => p_codice_amm,
                        p_codice_aoo     => p_codice_aoo,
                        p_default        => '***');

      BEGIN
         SELECT COUNT (1)
           INTO d_found
           FROM seg_fascicoli fasc,
                seg_classificazioni clas,
                documenti docu_clas,
                documenti docu_fasc,
                cartelle cart_clas,
                cartelle cart_fasc
          WHERE     fasc.codice_amministrazione = p_codice_amm
                AND fasc.codice_aoo = p_codice_aoo
                AND fasc.class_cod = clas.class_cod
                AND fasc.class_dal = clas.class_dal
                AND docu_clas.id_documento = clas.id_documento
                AND docu_fasc.id_documento = fasc.id_documento
                AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                                        AND NVL (
                                               fasc.class_al,
                                               TO_DATE ('01/01/2999',
                                                        'dd/mm/yyyy'))
                AND fasc.stato_fascicolo = 1
                AND clas.codice_amministrazione = fasc.codice_amministrazione
                AND clas.codice_aoo = fasc.codice_aoo
                AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND cart_clas.id_documento_profilo = docu_clas.id_documento
                AND NVL (cart_clas.stato, 'BO') <> 'CA'
                AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
                AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                AND fasc.class_cod = d_class_cod
                AND fasc.fascicolo_anno =
                       NVL (p_fascicolo_anno, fasc.fascicolo_anno)
                AND fasc.fascicolo_numero = d_fascicolo_numero;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_found := 0;
      END;

      IF d_found = 0
      THEN
         d_class_cod := p_class_cod || '%';
         d_fascicolo_numero := p_fascicolo_numero || '%';
      END IF;

      OPEN d_result FOR
         SELECT fasc.id_documento,
                fasc.class_cod,
                fasc.class_dal,
                fasc.fascicolo_anno,
                fasc.fascicolo_numero,
                get_oggetto (fasc.id_documento, p_utente) fascicolo_oggetto,
                clas.class_descr,
                   fasc.fascicolo_anno
                || DECODE (fasc.fascicolo_numero,
                           NULL, NULL,
                           '/' || fasc.fascicolo_numero)
                   dati_fascicolo,
                AG_FASCICOLO_UTILITY.get_desc_ubicazione (
                   fasc.class_cod,
                   TO_CHAR (fasc.class_dal, 'DD/MM/YYYY'),
                   fasc.fascicolo_anno,
                   fasc.fascicolo_numero)
                   ubicazione_fascicolo,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             TO_CHAR (fasc.id_documento),
                                             'L',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'))
                   lettura
           FROM seg_fascicoli fasc,
                seg_classificazioni clas,
                documenti docu_clas,
                documenti docu_fasc,
                cartelle cart_clas,
                cartelle cart_fasc
          WHERE     fasc.codice_amministrazione = p_codice_amm
                AND fasc.codice_aoo = p_codice_aoo
                AND fasc.class_cod = clas.class_cod
                AND fasc.class_dal = clas.class_dal
                AND docu_clas.id_documento = clas.id_documento
                AND docu_fasc.id_documento = fasc.id_documento
                AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                                        AND NVL (
                                               fasc.class_al,
                                               TO_DATE ('01/01/2999',
                                                        'dd/mm/yyyy'))
                AND fasc.stato_fascicolo = 1
                AND clas.codice_amministrazione = fasc.codice_amministrazione
                AND clas.codice_aoo = fasc.codice_aoo
                AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND cart_clas.id_documento_profilo = docu_clas.id_documento
                AND NVL (cart_clas.stato, 'BO') <> 'CA'
                AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
                AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                AND fasc.class_cod LIKE d_class_cod
                AND fasc.fascicolo_anno = p_fascicolo_anno
                AND fasc.fascicolo_numero LIKE d_fascicolo_numero
                AND decode(d_clas_pers, fasc.class_cod, gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             TO_CHAR (fasc.id_documento),
                                             'L',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY')) , 1 ) = 1;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLO: ' || SQLERRM);
   END get_fascicolo;

   FUNCTION get_fascicolo (p_id_documento IN NUMBER, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_FASCICOLO

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  SN  Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT clas.class_descr,
                get_oggetto (fasc.id_documento, p_utente) fascicolo_oggetto,
                fasc.*
           FROM seg_fascicoli fasc,
                seg_classificazioni clas,
                documenti docu_clas,
                documenti docu_fasc,
                cartelle cart_clas,
                cartelle cart_fasc
          WHERE     fasc.id_documento = p_id_documento
                AND fasc.class_cod = clas.class_cod
                AND fasc.class_dal = clas.class_dal
                AND docu_clas.id_documento = clas.id_documento
                AND docu_fasc.id_documento = fasc.id_documento
                AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                                        AND NVL (
                                               fasc.class_al,
                                               TO_DATE ('01/01/2999',
                                                        'dd/mm/yyyy'))
                AND clas.codice_amministrazione = fasc.codice_amministrazione
                AND clas.codice_aoo = fasc.codice_aoo
                AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                AND cart_clas.id_documento_profilo = docu_clas.id_documento
                AND NVL (cart_clas.stato, 'BO') <> 'CA'
                AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
                AND NVL (cart_fasc.stato, 'BO') <> 'CA';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLO: ' || SQLERRM);
   END get_fascicolo;


   FUNCTION get_select_fascicoli (
      p_codice_amm                     IN VARCHAR2,
      p_codice_aoo                     IN VARCHAR2,
      p_fascicolo_anno                 IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero               IN seg_fascicoli.fascicolo_numero%TYPE,
      p_class_cod                      IN seg_classificazioni.class_cod%TYPE,
      p_class_dal                      IN VARCHAR2,
      p_fascicolo_oggetto              IN seg_fascicoli.fascicolo_oggetto%TYPE,
      p_mostra_tutti                   IN VARCHAR2,
      p_utente                         IN VARCHAR2,
      p_fascicolo_note                 IN seg_fascicoli.note%TYPE,
      p_fascicolo_ufficio_competenza   IN seg_fascicoli.ufficio_competenza%TYPE,
      p_sottoclassifiche               IN VARCHAR2,
      p_id_fascicolo                   IN NUMBER,
      p_numerazione_automatica         IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR
   IS
      /*****************************************************************************
         NOME:        GET_SELECT_FASCICOLI

         DESCRIZIONE: Restituisce la select per utilizzarla per il calcolo del numero totale
         di record trovati e per la ricerca dei fascicoli

         RITORNO:

         Rev.  Data        Autore  Descrizione.
         000   06/06/2018  DS      Prima emissione.
         102  12/02/2019 SC     #32591 PERSONALIZZAZIONE - Inserimento fascicoli del personale
     ********************************************************************************/
      n_count              NUMBER := 0;
      d_mostra_tutti       VARCHAR2 (1);
      d_sottoclassifiche   VARCHAR2 (1);
      d_iter_fasc          VARCHAR2 (1);
      d_select             VARCHAR2 (32767);
      d_anno               VARCHAR2 (100) := TO_CHAR (p_fascicolo_anno);
      d_clas_pers          VARCHAR2 (100);
   BEGIN
      IF d_anno = -1
      THEN
         d_anno := '';
      END IF;

      d_clas_pers := AG_PARAMETRO.GET_VALORE(
                        p_codice         => 'CLAS_FASC_PERS_',
                        p_codice_amm     => p_codice_amm,
                        p_codice_aoo     => p_codice_aoo,
                        p_default        => '***');

      d_mostra_tutti :=
         NVL (p_mostra_tutti,
              ag_parametro.get_valore ('FASC_CERCA_TUTTI',
                                       p_codice_amm,
                                       p_codice_aoo,
                                       'Y'));

      d_sottoclassifiche := NVL (p_sottoclassifiche, 'Y');

      d_select :=
            ' FROM( SELECT docu_fasc.codice_richiesta,
                          fasc.id_documento,
                          fasc.anno_archiviazione,
                          fasc.anno_fascicolo_padre,
                          fasc.base_normativa,
                          fasc.calcola_nome,
                          fasc.class_al,
                          fasc.class_cod,
                          fasc.class_dal,
                          fasc.codice_amministrazione,
                          fasc.codice_aoo,
                          fasc.creata_cartella,
                          fasc.cr_padre,
                          fasc.data_apertura,
                          fasc.data_archiviazione,
                          fasc.data_chiusura,
                          TO_CHAR (fasc.data_creazione, ''dd/mm/yyyy'') data_creazione,
                          fasc.data_stato,
                          fasc.desc_procedimento,
                          fasc.fascicolo_anno,
                          fasc.fascicolo_numero,
                          AG_FASCICOLO_UTILITY.get_oggetto (fasc.id_documento, '''
         || p_utente
         || ''') fascicolo_oggetto,
                          fasc.nome,
                          fasc.note,
                          fasc.numero_fascicolo_padre,
                          fasc.procedimento,
                          fasc.responsabile,
                          fasc.riservato,
                          fasc.stato_fascicolo,
                          fasc.sub,
                          fasc.topografia,
                          fasc.ufficio_competenza,
                          fasc.uff_assegnatario,
                          fasc.ultimo_numero_sub,
                          fasc.utente_creazione,
                          fasc.utente_sessione,
                          NVL (fasc.descrizione_classifica, clas.class_descr) descrizione_classifica,
                          NVL (fasc.descrizione_classifica_visu, clas.class_descr) descrizione_classifica_visu,
                          fasc.ufficio_creazione,
                          SEG_UNITA_PKG.GET_NOME_BETWEEN ( fasc.ufficio_competenza,'''
         || p_codice_amm
         || ''', '''
         || p_codice_aoo
         || ''', fasc.data_creazione)  descrizione_ufficio_competenza,
                          cart_padre.id_documento_profilo id_fascicolo_padre,
                          cart_fasc.id_cartella,
                          vica_fasc.id_viewcartella,
                          fasc.idrif
                     FROM seg_fascicoli fasc,
                          seg_classificazioni clas,
                          documenti docu_clas,
                          documenti docu_fasc,
                          cartelle cart_clas,
                          cartelle cart_fasc,
                          links,
                          cartelle cart_padre,
                          view_cartella vica_fasc
                    WHERE fasc.codice_amministrazione = '''
         || p_codice_amm
         || '''
                          AND fasc.codice_aoo = '''
         || p_codice_aoo
         || '''
                          AND clas.class_dal =
                                 DECODE ('''
         || p_class_dal
         || ''',
                                         '''', clas.class_dal,
                                         TO_DATE ('''
         || p_class_dal
         || ''', ''dd/mm/yyyy''))
                          AND fasc.class_cod = clas.class_cod
                          AND fasc.class_dal = clas.class_dal
                          AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                                                  AND NVL (fasc.class_al, TO_DATE (''01/01/2999'', ''dd/mm/yyyy''))
                          AND fasc.stato_fascicolo = ''1''
                          AND clas.codice_amministrazione = fasc.codice_amministrazione
                          AND clas.codice_aoo = fasc.codice_aoo
                          AND docu_clas.id_documento = clas.id_documento
                          AND docu_fasc.id_documento = fasc.id_documento
                          AND NVL (docu_clas.stato_documento, ''BO'') NOT IN
                                 (''CA'', ''RE'', ''PB'')
                          AND NVL (docu_fasc.stato_documento, ''BO'') NOT IN
                                 (''CA'', ''RE'', ''PB'')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND vica_fasc.id_cartella = cart_fasc.id_cartella
                          AND NVL (cart_clas.stato, ''BO'') <> ''CA''
                          AND cart_fasc.id_documento_profilo =
                                 docu_fasc.id_documento
                          AND NVL (cart_fasc.stato, ''BO'') <> ''CA'' ';

      IF p_fascicolo_oggetto IS NOT NULL
      THEN
         d_select :=
               d_select
            || ' AND catsearch (fasc.fascicolo_oggetto, '''
            || replace(replace(p_fascicolo_oggetto, '(', ''), ')', '')
            || ''', NULL) > 0 ';
      END IF;

      IF p_fascicolo_note IS NOT NULL
      THEN
         IF p_fascicolo_oggetto IS NULL
         THEN
            d_select :=
                  d_select
               || ' AND catsearch (fasc.note, '''
               || replace(replace(p_fascicolo_note, '(', ''), ')', '')
               || ''', NULL) > 0 ';
         ELSE
            d_select :=
                  d_select
               || ' AND lower(fasc.note) like ''%'
               || LOWER (p_fascicolo_note)
               || '%'' ';
         END IF;
      END IF;

      IF p_fascicolo_ufficio_competenza IS NOT NULL
      THEN
         d_select :=
               d_select
            || ' AND fasc.ufficio_competenza = '''
            || p_fascicolo_ufficio_competenza
            || ''' ';
      END IF;

      IF d_sottoclassifiche = 'Y'
      THEN
         d_select :=
               d_select
            || ' AND NVL (fasc.class_cod, '' '') LIKE NVL ('''
            || p_class_cod
            || ''' || ''%'', ''%'')';
      ELSE
         d_select :=
               d_select
            || ' AND NVL (fasc.class_cod, '' '') = NVL ('''
            || p_class_cod
            || ''', '' '')';
      END IF;

      IF p_id_fascicolo IS NOT NULL
      THEN
         d_select :=
            d_select || ' AND fasc.id_documento = ' || p_id_fascicolo || ' ';
      END IF;

      IF p_numerazione_automatica IS NOT NULL
      THEN
         d_select :=
               d_select
            || ' AND fasc.NUMERAZIONE_AUTOMATICA = '
            || ''''
            || p_numerazione_automatica
            || ''''
            || ' ';
      END IF;

      d_select :=
            d_select
         || ' AND NVL(fasc.fascicolo_anno, -1) LIKE '''
         || d_anno
         || ''' || ''%''
                          AND NVL(fasc.fascicolo_numero, '' '') LIKE
                                 '''
         || p_fascicolo_numero
         || ''' || ''%''
                          AND links.id_oggetto = cart_fasc.id_cartella
                          AND links.tipo_oggetto = ''C''
                          AND cart_padre.id_cartella = links.id_cartella
                          AND decode(fasc.class_cod, '''||d_clas_pers||''',
                              decode('''||d_mostra_tutti||''', ''N'', 1,
                              gdm_competenza.gdm_verifica (
                                ''DOCUMENTI'',
                                TO_CHAR (fasc.id_documento),
                                ''L'',
                                '''
                                || p_utente
                                || ''',
                                ''GDM'',
                                TO_CHAR (SYSDATE, ''DD/MM/YYYY''))), 1) = 1
                   UNION ALL
                   SELECT TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_DATE (NULL),
                          TO_CHAR (NULL),
                          TO_DATE (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_DATE (NULL),
                          TO_DATE (NULL),
                          TO_DATE (NULL),
                          TO_CHAR (NULL),
                          TO_DATE (NULL),
                          TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_CHAR (NULL),
                          TO_NUMBER (NULL),
                          TO_NUMBER (NULL),
                          TO_NUMBER (NULL),
                          TO_CHAR (NULL)
                     FROM DUAL
                    WHERE '''
         || d_mostra_tutti
         || ''' = ''N'') fasc,
                  DUAL
           HAVING    DECODE ('''
         || d_mostra_tutti
         || ''',
                             ''Y'', 1,
                             gdm_competenza.gdm_verifica (
                                ''DOCUMENTI'',
                                TO_CHAR (fasc.id_documento),
                                ''L'',
                                '''
         || p_utente
         || ''',
                                ''GDM'',
                                TO_CHAR (SYSDATE, ''DD/MM/YYYY'')))
                  || dummy = ''1X''
         GROUP BY fasc.codice_richiesta,
                  fasc.id_documento,
                  fasc.anno_archiviazione,
                  fasc.anno_fascicolo_padre,
                  fasc.base_normativa,
                  fasc.calcola_nome,
                  fasc.class_al,
                  fasc.class_cod,
                  fasc.class_dal,
                  fasc.codice_amministrazione,
                  fasc.codice_aoo,
                  fasc.creata_cartella,
                  fasc.cr_padre,
                  fasc.data_apertura,
                  fasc.data_archiviazione,
                  fasc.data_chiusura,
                  fasc.data_creazione,
                  fasc.data_stato,
                  fasc.desc_procedimento,
                  fasc.fascicolo_anno,
                  fasc.fascicolo_numero,
                  fasc.fascicolo_oggetto,
                  fasc.nome,
                  fasc.note,
                  fasc.numero_fascicolo_padre,
                  fasc.procedimento,
                  fasc.responsabile,
                  fasc.riservato,
                  fasc.stato_fascicolo,
                  fasc.sub,
                  fasc.topografia,
                  fasc.ufficio_competenza,
                  fasc.uff_assegnatario,
                  fasc.ultimo_numero_sub,
                  fasc.utente_creazione,
                  fasc.utente_sessione,
                  fasc.descrizione_classifica,
                  fasc.descrizione_classifica_visu,
                  fasc.ufficio_creazione,
                  fasc.descrizione_ufficio_competenza,
                  fasc.id_fascicolo_padre,
                  fasc.id_cartella,
                  fasc.id_viewcartella,
                  fasc.idrif,
                  dummy
         ORDER BY NLSSORT (class_cod, ''NLS_LANGUAGE=American''),
                  fascicolo_anno,
                  1';

      RETURN d_select;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_SELECT_FASCICOLI: ' || SQLERRM);
   END;

   FUNCTION get_count_fascicoli (
      p_codice_amm                     IN VARCHAR2,
      p_codice_aoo                     IN VARCHAR2,
      p_fascicolo_anno                 IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero               IN seg_fascicoli.fascicolo_numero%TYPE,
      p_class_cod                      IN seg_classificazioni.class_cod%TYPE,
      p_class_dal                      IN VARCHAR2,
      p_fascicolo_oggetto              IN seg_fascicoli.fascicolo_oggetto%TYPE,
      p_mostra_tutti                   IN VARCHAR2,
      p_utente                         IN VARCHAR2,
      p_fascicolo_note                 IN seg_fascicoli.note%TYPE,
      p_fascicolo_ufficio_competenza   IN seg_fascicoli.ufficio_competenza%TYPE,
      p_sottoclassifiche               IN VARCHAR2,
      p_id_fascicolo                   IN NUMBER)
      RETURN NUMBER
   IS
      /*****************************************************************************
          NOME:        GET_COUNT_FASCICOLI

          DESCRIZIONE: Calcola il numero di record trovati dalla ricerca

          RITORNO:

          Rev.  Data        Autore  Descrizione.
          000   05/06/2018  DS      Prima emissione.
      ********************************************************************************/
      n_count    NUMBER := 0;
      d_select   VARCHAR2 (32767);
   BEGIN
      d_select :=
            'SELECT 1 '
         || get_select_fascicoli (P_CODICE_AMM,
                                  P_CODICE_AOO,
                                  P_FASCICOLO_ANNO,
                                  P_FASCICOLO_NUMERO,
                                  P_CLASS_COD,
                                  P_CLASS_DAL,
                                  P_FASCICOLO_OGGETTO,
                                  P_MOSTRA_TUTTI,
                                  P_UTENTE,
                                  P_FASCICOLO_NOTE,
                                  P_FASCICOLO_UFFICIO_COMPETENZA,
                                  P_SOTTOCLASSIFICHE,
                                  p_id_fascicolo,
                                  'N');

      DBMS_OUTPUT.put_line (d_select);
      integrityPackage.LOG (d_select);

      EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM (' || d_select || ')'
         INTO n_count;

      DBMS_OUTPUT.put_line ('Totale record. ' || n_count);

      RETURN (n_count);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_COUNT_FASCICOLI: ' || SQLERRM);
   END;

   FUNCTION get_fascicoli (
      p_codice_amm                     IN VARCHAR2,
      p_codice_aoo                     IN VARCHAR2,
      p_fascicolo_anno                 IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero               IN seg_fascicoli.fascicolo_numero%TYPE,
      p_class_cod                      IN seg_classificazioni.class_cod%TYPE,
      p_class_dal                      IN VARCHAR2,
      p_fascicolo_oggetto              IN seg_fascicoli.fascicolo_oggetto%TYPE,
      p_mostra_tutti                   IN VARCHAR2,
      p_utente                         IN VARCHAR2,
      p_fascicolo_note                 IN seg_fascicoli.note%TYPE,
      p_fascicolo_ufficio_competenza   IN seg_fascicoli.ufficio_competenza%TYPE,
      p_sottoclassifiche               IN VARCHAR2,
      p_id_fascicolo                   IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_FASCICOLI

          DESCRIZIONE: Effettua la ricerca dei fascicoli

          RITORNO:

          Rev.  Data        Autore  Descrizione.
          000   05/12/2008  SN      Prima emissione.
          010   13/02/2018  MM      Modificata get_fascicoli
          012   06/06/2018  MM      Modificata per correzione ricerca su note
      ********************************************************************************/
      d_result      afc.t_ref_cursor;
      d_iter_fasc   VARCHAR2 (1);
      d_select      VARCHAR2 (32767);
   BEGIN
      d_iter_fasc :=
         ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_codice_amm,
                                  p_codice_aoo,
                                  'N');

      d_select :=
            'SELECT AG_FASCICOLO_UTILITY.get_numero_fasc_ord (fascicolo_numero) numero_ord,
                          AG_FASCICOLO_UTILITY.get_utente_creazione (fasc.id_documento, fasc.utente_creazione, '''
         || p_utente
         || ''') den_utente_creazione,
                          AG_FASCICOLO_UTILITY.get_desc_unita_creazione (fasc.id_documento) desc_ufficio_creazione,
                          ag_competenze_fascicolo.lettura (fasc.id_viewcartella, '''
         || p_utente
         || ''') lettura,
                          ag_competenze_fascicolo.creazione ('''
         || p_utente
         || ''') creazione,
                          ag_competenze_fascicolo.modifica (fasc.id_viewcartella, '''
         || p_utente
         || ''') modifica,
                          ag_competenze_fascicolo.eliminazione (fasc.id_viewcartella, '''
         || p_utente
         || ''') eliminazione,
                          AG_FASCICOLO_UTILITY.get_ubicazione (fasc.id_cartella) fascicolo_ubicazione,
                          AG_FASCICOLO_UTILITY.get_desc_ubicazione (fasc.class_cod,TO_CHAR (fasc.class_dal, ''DD/MM/YYYY''),
                                     fasc.fascicolo_anno,fasc.fascicolo_numero) fascicolo_desc_ubicazione,
                          '''
         || d_iter_fasc
         || ''' iter_fasc,
                          fasc.* '
         || get_select_fascicoli (P_CODICE_AMM,
                                  P_CODICE_AOO,
                                  P_FASCICOLO_ANNO,
                                  P_FASCICOLO_NUMERO,
                                  P_CLASS_COD,
                                  P_CLASS_DAL,
                                  P_FASCICOLO_OGGETTO,
                                  P_MOSTRA_TUTTI,
                                  P_UTENTE,
                                  P_FASCICOLO_NOTE,
                                  P_FASCICOLO_UFFICIO_COMPETENZA,
                                  P_SOTTOCLASSIFICHE,
                                  p_id_fascicolo,
                                  'N');

      DBMS_OUTPUT.put_line (d_select);
      integrityPackage.LOG (d_select);

      OPEN d_result FOR d_select;

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLI: ' || SQLERRM);
   END;

   FUNCTION get_unita_competenti_creazione (p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_UNITA_COMPETENTI_CREAZIONE

          DESCRIZIONE:

          RITORNO:

          Rev.  Data       Autore  Descrizione.
          00    03/01/2011  MMur   Prima emissione.
          01    05/04/2017  SC     Gestione date privilegi
          011   09/04/2018 MM      Gestione uffici con privilegi diretti
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT DISTINCT ag.unita ufficio_creazione, uni.nome
             FROM ag_priv_utente_tmp ag, seg_unita uni
            WHERE     ag.utente = p_utente
                  AND ag.privilegio = 'CREF'
                  AND uni.unita = ag.unita
                  AND TRUNC (SYSDATE) BETWEEN uni.dal
                                          AND NVL (uni.al,
                                                   TO_DATE (3333333, 'j'))
                  AND TRUNC (SYSDATE) <= /*BETWEEN NVL (ag.dal, TRUNC (SYSDATE))
                                           AND*/
                                        NVL (ag.al, TRUNC (SYSDATE))
                  AND ag.appartenenza = 'D'
         ORDER BY 2;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_FASCICOLO_UTILITY.GET_UNITA_COMPETENTI_CREAZIONE: '
            || SQLERRM);
   END get_unita_competenti_creazione;

   FUNCTION get_unita_competenti (p_id_documento IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_UNITA_COMPETENTI

          DESCRIZIONE:

          RITORNO:

          Rev.  Data       Autore  Descrizione.
          00    03/01/2011  MMur Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT su.unita ufficio_competenza,
                su.nome,
                su.dal,
                su.al
           FROM seg_unita su
          WHERE SYSDATE BETWEEN su.dal
                            AND NVL (su.al, TO_DATE (3333333, 'J'))
         UNION
         SELECT unit.unita ufficio_competenza,
                unit.nome,
                unit.dal,
                unit.al
           FROM seg_unita unit, seg_fascicoli fasc
          WHERE     unit.unita = fasc.ufficio_competenza
                AND unit.dal = (SELECT MAX (dal)
                                  FROM seg_unita
                                 WHERE unita = unit.unita)
                AND unit.codice_amministrazione = fasc.codice_amministrazione
                AND fasc.id_documento = p_id_documento
                AND p_id_documento IS NOT NULL
         ORDER BY 2;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_FASCICOLO_UTILITY.GET_UNITA_COMPETENTI_CREAZIONE: '
            || SQLERRM);
   END get_unita_competenti;

   FUNCTION get_classificazioni_secondarie (p_id_documento   IN VARCHAR2,
                                            p_codice_amm     IN VARCHAR2,
                                            p_codice_aoo     IN VARCHAR2,
                                            p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_CLASSIFICAZIONI_SECONDARIE

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  SN  Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT *
             FROM (SELECT id_link,
                          clas.data_creazione,
                          clas.contenitore_documenti,
                          clas.num_illimitata,
                          clas.class_cod,
                          clas.class_descr,
                          clas.class_dal,
                          clas.class_al,
                          clas.note,
                          fasc.fascicolo_anno,
                          fasc.fascicolo_numero,
                          get_oggetto (fasc.id_documento, p_utente)
                             fascicolo_oggetto,
                             NVL (fasc.fascicolo_anno, '0000')
                          || get_numero_fasc_ord (fasc.fascicolo_numero)
                             ordinamento
                     FROM links,
                          seg_fascicoli fasc,
                          seg_classificazioni clas,
                          documenti docu_clas,
                          documenti docu_fasc,
                          cartelle cart_clas,
                          cartelle cart_fasc
                    WHERE     links.id_oggetto = p_id_documento
                          AND fasc.codice_amministrazione = p_codice_amm
                          AND fasc.codice_aoo = p_codice_aoo
                          AND tipo_oggetto = 'D'
                          AND cart_fasc.id_cartella = links.id_cartella
                          AND cart_fasc.id_documento_profilo =
                                 docu_fasc.id_documento
                          AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                          AND fasc.class_cod = clas.class_cod
                          AND fasc.class_dal = clas.class_dal
                          AND clas.codice_amministrazione =
                                 fasc.codice_amministrazione
                          AND clas.codice_aoo = fasc.codice_aoo
                          AND docu_clas.id_documento = clas.id_documento
                          AND docu_fasc.id_documento = fasc.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                          AND NOT EXISTS
                                 (SELECT 1
                                    FROM classificabile_view
                                   WHERE     id_documento = p_id_documento
                                         AND class_cod = fasc.class_cod
                                         AND class_dal = fasc.class_dal
                                         AND fascicolo_anno =
                                                fasc.fascicolo_anno
                                         AND fascicolo_numero =
                                                fasc.fascicolo_numero)
                   UNION
                   SELECT id_link,
                          clas.data_creazione,
                          clas.contenitore_documenti,
                          clas.num_illimitata,
                          clas.class_cod,
                          clas.class_descr,
                          clas.class_dal,
                          clas.class_al,
                          clas.note,
                          NULL,
                          '',
                          '',
                          '0000' || '0000000'
                     FROM links,
                          seg_classificazioni clas,
                          documenti docu_clas,
                          cartelle cart_clas
                    WHERE     links.id_oggetto = p_id_documento
                          AND clas.codice_amministrazione = p_codice_amm
                          AND clas.codice_aoo = p_codice_aoo
                          AND tipo_oggetto = 'D'
                          AND cart_clas.id_cartella = links.id_cartella
                          AND docu_clas.id_documento = clas.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                          AND NOT EXISTS
                                 (SELECT 1
                                    FROM classificabile_view
                                   WHERE     id_documento = p_id_documento
                                         AND class_cod = clas.class_cod
                                         AND class_dal = clas.class_dal))
         ORDER BY NLSSORT (class_cod, 'NLS_LANGUAGE=American'), ordinamento;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'AG_FASCICOLO_UTILITY.GET_CLASSIFICAZIONI_SECONDARIE: '
            || SQLERRM);
   END;

   FUNCTION get_utente_creazione (p_id_documento       IN NUMBER,
                                  p_utente_creazione   IN VARCHAR2,
                                  p_utente             IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
          NOME:        get_utente_creazione
          DESCRIZIONE:
          RITORNO:
          Rev.  Data          Autore      Descrizione.
          00    15/02/2012    MMalferrari Prima emissione.
      ********************************************************************************/
      d_result   VARCHAR2 (2000);
   BEGIN
      SELECT nome
        INTO d_result
        FROM (SELECT NVL (
                        ad4_soggetto.get_nome (
                           ad4_utente.get_soggetto (ad4_utenti.utente,
                                                    'Y',
                                                    0)),
                        ad4_utenti.utente)
                        nome
                FROM ad4_utenti
               WHERE utente =
                        DECODE (p_id_documento,
                                NULL, p_utente,
                                p_utente_creazione)
              UNION
              SELECT DECODE (p_id_documento,
                             NULL, p_utente,
                             p_utente_creazione)
                FROM DUAL
               WHERE NOT EXISTS
                        (SELECT 1
                           FROM ad4_utenti
                          WHERE utente =
                                   DECODE (p_id_documento,
                                           NULL, p_utente,
                                           p_utente_creazione)));

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_UTENTE_CREAZIONE: ' || SQLERRM);
   END;

   FUNCTION get_desc_unita_creazione (p_id_documento IN NUMBER)
      RETURN VARCHAR2
   IS
      d_result   VARCHAR2 (2000);
   BEGIN
      SELECT uni.nome
        INTO d_result
        FROM seg_fascicoli fasc, seg_unita uni
       WHERE     fasc.id_documento = p_id_documento
             AND uni.unita = fasc.ufficio_creazione
             AND uni.codice_amministrazione = fasc.codice_amministrazione
             AND NVL (fasc.data_creazione, fasc.data_apertura) BETWEEN uni.dal
                                                                   AND NVL (
                                                                          uni.al,
                                                                          TO_DATE (
                                                                             3333333,
                                                                             'j'))
      UNION
      SELECT fasc.ufficio_creazione
        FROM seg_fascicoli fasc
       WHERE     fasc.id_documento = p_id_documento
             AND NOT EXISTS
                    (SELECT 1
                       FROM seg_unita uni
                      WHERE     uni.unita = fasc.ufficio_creazione
                            AND uni.codice_amministrazione =
                                   fasc.codice_amministrazione
                            AND NVL (fasc.data_creazione, fasc.data_apertura) BETWEEN uni.dal
                                                                                  AND NVL (
                                                                                         uni.al,
                                                                                         TO_DATE (
                                                                                            3333333,
                                                                                            'j')));

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_DESC_UNITA_CREAZIONE: ' || SQLERRM);
   END;

   FUNCTION get_desc_scarto (p_id_documento IN NUMBER)
      RETURN VARCHAR2
   IS
      d_result   VARCHAR2 (32000);
   BEGIN
      SELECT    'Fascicolo '
             || LOWER (stsc.descrizione)
             || ' in data '
             || TO_CHAR (fasc.data_stato_scarto, 'dd/mm/yyyy')
             || '.'
             || DECODE (
                   fasc.numero_nulla_osta,
                   NULL, '',
                      CHR (10)
                   || 'Nulla osta nr. '
                   || fasc.numero_nulla_osta
                   || ' del '
                   || TO_CHAR (fasc.data_nulla_osta, 'dd/mm/yyyy')
                   || '.')
        INTO d_result
        FROM seg_fascicoli fasc,
             ag_stati_scarto stsc,
             documenti docu,
             cartelle cart
       WHERE     fasc.id_documento = p_id_documento
             AND docu.id_documento = fasc.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND cart.id_documento_profilo = docu.id_documento
             AND NVL (cart.stato, 'BO') != 'CA'
             AND fasc.stato_scarto = stsc.stato
             AND fasc.stato_scarto != '**';

      RETURN d_result;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN '';
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_DESC_SCARTO: ' || SQLERRM);
   END;

   FUNCTION get_privilegi (p_id_documento IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_PRIVILEGI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data        Autore   Descrizione.
         00    21/02/2012  MM       Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             p_id_documento,
                                             'L',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                             'N')
                   lettura,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             p_id_documento,
                                             'C',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                             'N')
                   creazione,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             p_id_documento,
                                             'U',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                             'N')
                   modifica,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             p_id_documento,
                                             'D',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                             'N')
                   eliminazione
           FROM DUAL;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_PRIVILEGI: ' || SQLERRM);
   END;

   FUNCTION get_dati_classifica (
      p_idcartproveninez   IN VARCHAR2,
      p_utente             IN VARCHAR2,
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2,
      p_class_cod          IN seg_classificazioni.class_cod%TYPE,
      p_class_dal          IN VARCHAR2,
      p_class_desc         IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_DATI_CLASSIFICA

          DESCRIZIONE:   utilizzata per ottenere informazioni sulla classifica in cui
                        inserire il nuovo fascicolo

          RITORNO: cursore con class_cod, clas_dal e class_descr

          Rev.  Data        Autore   Descrizione.
          000  09/05/2012   MMur     Prima emissione.
          004  12/02/2015   MM       Modificata GET_DATI_CLASSIFICA aggiungendo i par
                                     p_codice_amm, p_codice_aoo,p_class_cod, p_class_dal
                                     e p_class_desc per gestire nuovo,sub e duplica
                                     su fascicoli aperti da ricerca.
       ********************************************************************************/
      d_result         afc.t_ref_cursor;
      d_id_documento   NUMBER;
   BEGIN
      IF p_idcartproveninez IS NOT NULL
      THEN
         IF SUBSTR (p_idcartproveninez, 1, 1) = 'F'
         THEN
            d_id_documento := SUBSTR (p_idcartproveninez, 2);
         ELSE
            BEGIN
               SELECT id_documento_profilo
                 INTO d_id_documento
                 FROM cartelle
                WHERE id_cartella = p_idcartproveninez;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_id_documento := NULL;
            END;
         END IF;
      END IF;

      OPEN d_result FOR
         SELECT class_cod,
                class_dal,
                class_descr,
                TO_NUMBER (NULL) id_fascicolo,
                TO_NUMBER (NULL) fascicolo_anno,
                ag_competenze_fascicolo.creazione (p_utente) creazione
           FROM seg_classificazioni
          WHERE id_documento = d_id_documento
         UNION
         SELECT p_class_cod,
                TO_DATE (p_class_dal, 'dd/mm/yyyy'),
                class_descr,
                TO_NUMBER (NULL) id_fascicolo,
                TO_NUMBER (NULL) fascicolo_anno,
                ag_competenze_fascicolo.creazione (p_utente) creazione
           FROM seg_classificazioni
          WHERE     NOT EXISTS
                       (SELECT 1
                          FROM seg_classificazioni
                         WHERE id_documento = d_id_documento)
                AND class_cod = p_class_cod
                AND class_dal = TO_DATE (p_class_dal, 'dd/mm/yyyy')
                AND codice_amministrazione = p_codice_amm
                AND codice_aoo = p_codice_aoo
                AND SUBSTR (p_idcartproveninez, 1, 1) <> 'F'
         UNION
         SELECT cla.class_cod,
                cla.class_dal,
                cla.class_descr,
                fas.id_documento id_fascicolo,
                fas.fascicolo_anno,
                ag_competenze_fascicolo.creazione (p_utente) creazione
           FROM seg_fascicoli fas, seg_classificazioni cla
          WHERE     fas.id_documento = d_id_documento
                AND fas.class_cod = cla.class_cod
                AND fas.class_dal = cla.class_dal
         UNION
         SELECT '',
                TO_DATE (NULL),
                '',
                TO_NUMBER (NULL),
                TO_NUMBER (NULL),
                ag_competenze_fascicolo.creazione (p_utente) creazione
           FROM DUAL
          WHERE p_idcartproveninez IS NULL;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_DATI_CLASSIFICA: ' || SQLERRM);
   END;

   FUNCTION get_dati_fascicolo (p_id_documento_fascicolo   IN VARCHAR2,
                                p_utente                      VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_DATI_FASCICOLO

          DESCRIZIONE: utilizzata per ottenere informazioni sul fascicolo selezionato dal documentale

          RITORNO:

          Rev.  Data        Autore   Descrizione.
          00    14/05/2012  MMur       Prima emissione.
       ********************************************************************************/
      d_result                   afc.t_ref_cursor;
      d_id_documento_fascicolo   NUMBER;
   BEGIN
      BEGIN
         SELECT id_documento_profilo
           INTO d_id_documento_fascicolo
           FROM cartelle
          WHERE id_cartella = p_id_documento_fascicolo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT id_documento
              INTO d_id_documento_fascicolo
              FROM seg_fascicoli
             WHERE id_documento = p_id_documento_fascicolo;
      END;

      OPEN d_result FOR
         SELECT get_numero_fasc_ord (fascicolo_numero) numero_ord,
                get_utente_creazione (fasc.id_documento,
                                      fasc.utente_creazione,
                                      p_utente)
                   den_utente_creazione,
                get_desc_unita_creazione (fasc.id_documento)
                   desc_ufficio_creazione,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             TO_CHAR (fasc.id_documento),
                                             'L',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'))
                   lettura,
                ag_competenze_fascicolo.creazione (p_utente) creazione,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             fasc.id_documento,
                                             'U',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                             'N')
                   modifica,
                gdm_competenza.gdm_verifica ('DOCUMENTI',
                                             fasc.id_documento,
                                             'D',
                                             p_utente,
                                             'GDM',
                                             TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                             'N')
                   eliminazione,
                DECODE (
                   ag_parametro.get_valore ('ITER_FASCICOLI_',
                                            fasc.codice_amministrazione,
                                            fasc.codice_aoo,
                                            'N'),
                   'N', '',
                   DECODE (
                      esistono_documenti_altrove (fasc.id_cartella, NULL),
                      0, '',
                      '(SEMICOMPLETO)'))
                   semicompleto,
                fasc.*
           FROM (SELECT docu_fasc.codice_richiesta,
                        fasc.id_documento,
                        fasc.anno_archiviazione,
                        fasc.anno_fascicolo_padre,
                        fasc.base_normativa,
                        fasc.calcola_nome,
                        fasc.class_al,
                        fasc.class_cod,
                        fasc.class_dal,
                        fasc.codice_amministrazione,
                        fasc.codice_aoo,
                        fasc.creata_cartella,
                        fasc.cr_padre,
                        fasc.data_apertura,
                        fasc.data_archiviazione,
                        fasc.data_chiusura,
                        TO_CHAR (fasc.data_creazione, 'dd/mm/yyyy')
                           data_creazione,
                        fasc.data_stato,
                        fasc.desc_procedimento,
                        fasc.fascicolo_anno,
                        fasc.fascicolo_numero,
                        get_oggetto (fasc.id_documento, p_utente)
                           fascicolo_oggetto,
                        fasc.nome,
                        fasc.note,
                        fasc.numero_fascicolo_padre,
                        fasc.procedimento,
                        fasc.responsabile,
                        fasc.riservato,
                        fasc.stato_fascicolo,
                        fasc.sub,
                        fasc.topografia,
                        fasc.ufficio_competenza,
                        fasc.uff_assegnatario,
                        fasc.ultimo_numero_sub,
                        fasc.utente_creazione,
                        fasc.utente_sessione,
                        NVL (fasc.descrizione_classifica, clas.class_descr)
                           descrizione_classifica,
                        NVL (fasc.descrizione_classifica_visu,
                             clas.class_descr)
                           descrizione_classifica_visu,
                        fasc.ufficio_creazione,
                        fasc.descrizione_ufficio_competenza,
                        cart_padre.id_documento_profilo id_fascicolo_padre,
                        cart_fasc.id_cartella,
                        fasc.idrif,
                        fasc.dati_ripudio,
                        FASC.ARCHIVIO_DIGITALE,
                        fasc.numerazione_automatica
                   FROM seg_fascicoli fasc,
                        seg_classificazioni clas,
                        documenti docu_clas,
                        documenti docu_fasc,
                        cartelle cart_clas,
                        cartelle cart_fasc,
                        links,
                        cartelle cart_padre
                  WHERE     fasc.id_documento = d_id_documento_fascicolo
                        AND fasc.class_cod = clas.class_cod
                        AND fasc.class_dal = clas.class_dal
                        AND docu_clas.id_documento = clas.id_documento
                        AND docu_fasc.id_documento = fasc.id_documento
                        --            AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                        --                                    AND NVL (fasc.class_al,
                        --                                             TO_DATE ('01/01/2999',
                        --                                                      'dd/mm/yyyy'
                        --                                                     )
                        --                                            )
                        AND clas.codice_amministrazione =
                               fasc.codice_amministrazione
                        AND clas.codice_aoo = fasc.codice_aoo
                        AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                          'RE',
                                                                          'PB')
                        AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                          'RE',
                                                                          'PB')
                        AND cart_clas.id_documento_profilo =
                               docu_clas.id_documento
                        AND NVL (cart_clas.stato, 'BO') <> 'CA'
                        AND cart_fasc.id_documento_profilo =
                               docu_fasc.id_documento
                        AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                        AND links.id_oggetto = cart_fasc.id_cartella
                        AND links.tipo_oggetto = 'C'
                        AND cart_padre.id_cartella = links.id_cartella) fasc,
                DUAL;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_DATI_FASCICOLO: ' || SQLERRM);
   END;

   PROCEDURE elimina_fascicolo (p_id_fascicolo NUMBER, p_utente VARCHAR2)
   IS
      retval         NUMBER;
      d_idcartella   NUMBER;
   BEGIN
      BEGIN
         SELECT id_cartella
           INTO d_idcartella
           FROM cartelle
          WHERE id_documento_profilo = p_id_fascicolo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20999,
                  'Impossibile recuperare id_cartella per fascicolo con in '
               || p_id_fascicolo);
      END;

      retval :=
         f_elimina_cartella_lf (d_idcartella,
                                p_utente,
                                'S',
                                'L');
   END;

   FUNCTION get_relazioni_attive (p_id_cartella   IN VARCHAR2,
                                  p_utente        IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_RELAZIONI_ATTIVE

          DESCRIZIONE:

          RITORNO:  Restituisce la lista delle relzioni in cui il fascicolo ha il ruoto attivo

          Rev.  Data        Autore   Descrizione.
          00    12/06/2012  MMur       Prima emissione.
       ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT ag_competenze_fascicolo.lettura (vc.id_viewcartella,
                                                 p_utente)
                   lettura,
                tipi.descrizione,
                tipi.tipo_relazione,
                docu.codice_richiesta,
                fasc.id_documento,
                fasc.anno_archiviazione,
                fasc.anno_fascicolo_padre,
                fasc.base_normativa,
                fasc.calcola_nome,
                fasc.class_al,
                fasc.class_cod,
                fasc.class_dal,
                fasc.codice_amministrazione,
                fasc.codice_aoo,
                fasc.creata_cartella,
                fasc.cr_padre,
                fasc.data_apertura,
                fasc.data_archiviazione,
                fasc.data_chiusura,
                TO_CHAR (fasc.data_creazione, 'dd/mm/yyyy') data_creazione,
                fasc.data_stato,
                fasc.desc_procedimento,
                fasc.fascicolo_anno,
                fasc.fascicolo_numero,
                get_oggetto (fasc.id_documento, p_utente) fascicolo_oggetto,
                fasc.nome,
                fasc.note,
                fasc.numero_fascicolo_padre,
                fasc.procedimento,
                fasc.responsabile,
                fasc.riservato,
                fasc.stato_fascicolo,
                fasc.sub,
                fasc.topografia,
                fasc.ufficio_competenza,
                fasc.uff_assegnatario,
                fasc.ultimo_numero_sub,
                fasc.utente_creazione,
                fasc.utente_sessione,
                fasc.ufficio_creazione,
                fasc.descrizione_ufficio_competenza,
                cart.id_cartella,
                DECODE (
                   esistono_documenti_altrove_idf (fasc.id_documento, NULL),
                   0, DECODE (INSTR (fasc.fascicolo_numero, '.'),
                              0, 'segfascicolo',
                              'sottofascicolo'),
                   DECODE (INSTR (fasc.fascicolo_numero, '.'),
                           0, 'segfascicoloout',
                           'sottofascicoloout'))
                   icona
           FROM riferimenti rif,
                seg_fascicoli fasc,
                cartelle cart,
                view_cartella vc,
                documenti docu,
                tipi_relazione tipi
          WHERE     rif.id_documento = (SELECT id_documento_profilo
                                          FROM cartelle
                                         WHERE id_cartella = p_id_cartella)
                AND vc.id_cartella = cart.id_cartella
                AND fasc.id_documento = cart.id_documento_profilo
                AND fasc.id_documento = rif.id_documento_rif
                AND docu.id_documento = fasc.id_documento
                AND NVL (cart.stato, 'BO') <> 'CA'
                AND tipi.area = 'SEGRETERIA'
                AND rif.tipo_relazione LIKE 'PROT_FA%'
                AND tipi.tipo_relazione = rif.tipo_relazione;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_RELAZIONI_ATTIVE: ' || SQLERRM);
   END;

   FUNCTION get_smistamenti_attivi (p_id_cartella IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_SMISTAMENTI_ATTIVI

          DESCRIZIONE:

          RITORNO:  Restituisce la lista degli smistamenti per competenza in stato
          R, C o E.

          Rev.  Data        Autore   Descrizione.
          00    06/09/2012  SC       Prima emissione.
       ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT smis.id_documento
           FROM seg_fascicoli fasc,
                documenti docu,
                seg_smistamenti smis,
                cartelle cart
          WHERE     fasc.idrif = smis.idrif
                AND smis.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.stato_smistamento IN ('R', 'C', 'E')
                AND smis.tipo_smistamento = 'COMPETENZA'
                AND cart.id_cartella = p_id_cartella
                AND cart.id_documento_profilo = fasc.id_documento;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_SMISTAMENTI_ATTIVI: ' || SQLERRM);
   END;

   FUNCTION get_smistamenti (p_idrif IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_SMISTAMENTI_ATTIVI

          DESCRIZIONE:

          RITORNO:  Restituisce la lista degli smistamenti per competenza in stato
          R, C o E.

          Rev.  Data        Autore   Descrizione.
          00    06/09/2012  SC       Prima emissione.
       ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT smis.id_documento
           FROM seg_fascicoli fasc,
                documenti docu,
                seg_smistamenti smis,
                cartelle cart
          WHERE     fasc.idrif = p_idrif
                AND fasc.idrif = smis.idrif
                AND smis.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND cart.id_documento_profilo = fasc.id_documento;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_SMISTAMENTI: ' || SQLERRM);
   END;

   FUNCTION restano_smistamenti_attivi (p_id_cartella IN VARCHAR2)
      RETURN NUMBER
   IS
      /*****************************************************************************
          NOME:        RESTANO_SMISTAMENTI_ATTIVI

          DESCRIZIONE:

          RITORNO:  Restituisce 0 se nonrestano smistamenti attivi, 1 altrimenti

          Rev.  Data        Autore   Descrizione.
          00    06/09/2012  SC       Prima emissione.
       ********************************************************************************/
      d_smis          afc.t_ref_cursor;
      d_result        NUMBER := 0;
      d_smistamento   NUMBER;
   BEGIN
      d_smis := get_smistamenti_attivi (p_id_cartella);

      IF d_smis%ISOPEN
      THEN
         FETCH d_smis INTO d_smistamento;

         IF d_smis%FOUND
         THEN
            d_result := 1;
         END IF;
      END IF;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.RESTANO_SMISTAMENTI_ATTIVI: ' || SQLERRM);
   END;

   FUNCTION get_desc_ubicazione (p_class_cod          IN VARCHAR2,
                                 p_class_dal             VARCHAR2,
                                 p_fascicolo_anno        NUMBER,
                                 p_fascicolo_numero      VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
          NOME:        GET_DESC_UBICAZIONE

          DESCRIZIONE:Restituisce la descrizione dell'unita' di ubicazione per
                      competenza del fascicolo.

          RITORNO:

          Rev.  Data        Autore   Descrizione.
          00    21/03/2013  MM       Prima emissione.
      *****************************************************************************/
      d_return   VARCHAR2 (4000);
   BEGIN
      SELECT ag_unita_utility.get_descrizione (
                get_ubicazione (p_class_cod,
                                TO_DATE (p_class_dal, 'DD/MM/YYYY'),
                                p_fascicolo_anno,
                                p_fascicolo_numero),
                TRUNC (SYSDATE))
        INTO d_return
        FROM DUAL;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;

   FUNCTION get_ubicazione (p_class_cod          IN VARCHAR2,
                            p_class_dal             DATE,
                            p_fascicolo_anno        NUMBER,
                            p_fascicolo_numero      VARCHAR2)
      RETURN VARCHAR2
   IS
      /*******************************************************************************
        NOME:        GET_UBICAZIONE

        DESCRIZIONE:Restituisce l'unità di ubicazione per competenza del fascicolo.


        RITORNO:

        Rev.  Data        Autore   Descrizione.
        000   25/10/2012  SC       Prima emissione.
        005   06/07/2015  MM       Aggiunto controllo stato BO su cartelle e documenti.
      *******************************************************************************/
      dep_id_cartella   NUMBER;
   BEGIN
      BEGIN
         SELECT id_cartella
           INTO dep_id_cartella
           FROM seg_fascicoli fasc, cartelle cart, documenti docu
          WHERE     cart.id_documento_profilo = fasc.id_documento
                AND NVL (cart.stato, 'BO') = 'BO'
                AND docu.id_documento = fasc.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND fasc.class_cod = p_class_cod
                AND fasc.class_dal = p_class_dal
                AND fasc.fascicolo_anno = p_fascicolo_anno
                AND fasc.fascicolo_numero = p_fascicolo_numero;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      RETURN get_ubicazione (dep_id_cartella);
   END;

   FUNCTION get_ubicazione (p_id_cartella IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
          NOME:        GET_UBICAZIONE

          DESCRIZIONE:Restituisce l'unità di ubicazione per competenza del fascicolo.


          RITORNO:

          Rev.  Data        Autore   Descrizione.
          00    25/10/2012  SC       Prima emissione.
       ********************************************************************************/
      dep_ubicazione   seg_unita.unita%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT DISTINCT ufficio_smistamento
           INTO dep_ubicazione
           FROM seg_smistamenti smis,
                seg_fascicoli fasc,
                documenti docu,
                cartelle cart
          WHERE     smis.idrif = fasc.idrif
                AND smis.id_documento = docu.id_documento
                AND smis.tipo_smistamento = 'COMPETENZA'
                AND smis.stato_smistamento IN ('C', 'E', 'R')
                AND cart.id_cartella = p_id_cartella
                AND cart.id_documento_profilo = fasc.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      RETURN dep_ubicazione;
   END;

   FUNCTION esistono_documenti_altrove (p_id_cartella   IN VARCHAR2,
                                        p_unita            VARCHAR2)
      RETURN NUMBER
   IS
      /*****************************************************************************
          NOME:        ESISTONO_DOCUMENTI_ALTROVE

          DESCRIZIONE:Verifica se ci sono smistamenti per competenza per p_unita
          per cui è possibile p_azione, se ci sono li confronta con gli smistamenti
          per competenza dei documenti inseriti nel fascicolo.


          RITORNO:

          Rev.  Data        Autore   Descrizione.
          00    06/09/2012  SC       Prima emissione.
       ********************************************************************************/
      dep_ubicazione          seg_unita.unita%TYPE;
      tot_documenti_altrove   NUMBER := 0;
      dep_stati_smistamento   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT DISTINCT ufficio_smistamento
           INTO dep_ubicazione
           FROM seg_smistamenti smis,
                seg_fascicoli fasc,
                documenti docu,
                cartelle cart
          WHERE     smis.idrif = fasc.idrif
                AND smis.id_documento = docu.id_documento
                AND smis.tipo_smistamento = 'COMPETENZA'
                AND (smis.ufficio_smistamento = p_unita OR p_unita IS NULL)
                AND smis.stato_smistamento IN ('C', 'E', 'R')
                AND cart.id_cartella = p_id_cartella
                AND cart.id_documento_profilo = fasc.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF NVL (dep_ubicazione, '****') != '****'
      THEN
         FOR p
            IN (SELECT prot.class_cod,
                       prot.class_dal,
                       prot.fascicolo_anno,
                       prot.fascicolo_numero,
                       fasc.class_cod class_cod_fasc,
                       fasc.class_dal class_dal_fasc,
                       fasc.fascicolo_anno anno_fasc,
                       fasc.fascicolo_numero numero_fasc
                  FROM smistabile_view prot,
                       documenti docu,
                       links,
                       cartelle cart,
                       seg_fascicoli fasc
                 WHERE     cart.id_documento_profilo = fasc.id_documento
                       AND cart.id_cartella = p_id_cartella
                       AND cart.id_cartella = links.id_cartella
                       AND links.tipo_oggetto = 'D'
                       AND links.id_oggetto = docu.id_documento
                       AND prot.stato_pr NOT IN ('DP', 'AN')
                       AND docu.id_documento = prot.id_documento
                       AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND EXISTS
                              (SELECT 1
                                 FROM seg_smistamenti smis,
                                      documenti docu_smis
                                WHERE     smis.idrif = prot.idrif
                                      AND stato_smistamento IN ('R', 'C', 'E')
                                      AND tipo_smistamento = 'COMPETENZA'
                                      AND ufficio_smistamento !=
                                             dep_ubicazione
                                      AND docu_smis.id_documento =
                                             smis.id_documento
                                      AND docu_smis.stato_documento NOT IN ('CA',
                                                                            'RE',
                                                                            'PB'))
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM seg_smistamenti smis,
                                      documenti docu_smis
                                WHERE     smis.idrif = prot.idrif
                                      AND stato_smistamento IN ('R', 'C', 'E')
                                      AND tipo_smistamento = 'COMPETENZA'
                                      AND ufficio_smistamento =
                                             dep_ubicazione
                                      AND docu_smis.id_documento =
                                             smis.id_documento
                                      AND docu_smis.stato_documento NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')))
         LOOP
            IF (    p.class_cod = p.class_cod_fasc
                AND p.class_dal = p.class_dal_fasc
                AND p.fascicolo_anno = p.anno_fasc
                AND p.fascicolo_numero = p.numero_fasc)
            THEN
               tot_documenti_altrove := tot_documenti_altrove + 1;
               EXIT;
            END IF;
         END LOOP;
      END IF;

      RETURN tot_documenti_altrove;
   END;

   FUNCTION esistono_documenti_altrove_idf (p_id_fascicolo   IN VARCHAR2,
                                            p_unita             VARCHAR2)
      RETURN NUMBER
   IS
      /*****************************************************************************
          NOME:        ESISTONO_DOCUMENTI_ALTROVE

          DESCRIZIONE:Verifica se ci sono smistamenti per competenza per p_unita
          per cui è possibile p_azione, se ci sono li confronta con gli smistamenti
          per competenza dei documenti inseriti nel fascicolo.


          RITORNO:

          Rev.  Data        Autore   Descrizione.
          00    06/09/2012  SC       Prima emissione.
       ********************************************************************************/
      dep_id_cartella   NUMBER := 0;
   BEGIN
      SELECT id_cartella
        INTO dep_id_cartella
        FROM cartelle
       WHERE id_documento_profilo = p_id_fascicolo;

      RETURN esistono_documenti_altrove (p_id_cartella   => dep_id_cartella,
                                         p_unita         => p_unita);
   END;

   FUNCTION is_ubicazione_diversa (p_id_cartella      IN NUMBER,
                                   p_id_documento        NUMBER,
                                   p_solo_fasc_main      NUMBER := 1)
      RETURN NUMBER
   IS
      /*****************************************************************************
          NOME:        IS_UBICAZIONE_DIVERSA

          DESCRIZIONE:

          RITORNO:  Restituisce 0 se il documento è ubicato nella stessa
           unita del fascicolo, 1 altrimenti

          Rev.  Data        Autore   Descrizione.
          00    07/09/2012  SC       Prima emissione.
       ********************************************************************************/
      dep_ubicazione            seg_unita.unita%TYPE;
      tot_smistamenti_altrove   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT DISTINCT ufficio_smistamento
           INTO dep_ubicazione
           FROM seg_smistamenti smis,
                seg_fascicoli fasc,
                documenti docu,
                cartelle cart
          WHERE     smis.idrif = fasc.idrif
                AND smis.id_documento = docu.id_documento
                AND smis.tipo_smistamento = 'COMPETENZA'
                AND smis.stato_smistamento IN ('C', 'R', 'E')
                AND cart.id_cartella = p_id_cartella
                AND cart.id_documento_profilo = fasc.id_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      SELECT COUNT (*)
        INTO tot_smistamenti_altrove
        FROM classificabile_view prot,
             documenti docu,
             links,
             cartelle cart,
             seg_fascicoli fasc
       WHERE     links.id_cartella = cart.id_cartella
             AND cart.id_documento_profilo = fasc.id_documento
             AND p_id_cartella = links.id_cartella
             AND links.tipo_oggetto = 'D'
             AND links.id_oggetto = docu.id_documento
             --   AND prot.stato_pr NOT IN ('DP', 'AN')
             AND NOT EXISTS
                    (SELECT 1
                       FROM proto_view
                      WHERE     id_documento = prot.id_documento
                            AND stato_pr IN ('DP', 'AN'))
             AND docu.id_documento = prot.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND docu.id_documento = p_id_documento
             AND (   (    prot.class_cod = fasc.class_cod
                      AND prot.class_dal = fasc.class_dal
                      AND prot.fascicolo_anno = fasc.fascicolo_anno
                      AND prot.fascicolo_numero = fasc.fascicolo_numero)
                  OR p_solo_fasc_main = 0)
             AND EXISTS
                    (SELECT 1
                       FROM seg_smistamenti smis, documenti docu_smis
                      WHERE     smis.idrif = prot.idrif
                            AND stato_smistamento IN ('R', 'C', 'E')
                            AND tipo_smistamento = 'COMPETENZA'
                            AND ufficio_smistamento != dep_ubicazione
                            AND docu_smis.id_documento = smis.id_documento
                            AND docu_smis.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB'))
             AND NOT EXISTS
                    (SELECT 1
                       FROM seg_smistamenti smis, documenti docu_smis
                      WHERE     smis.idrif = prot.idrif
                            AND stato_smistamento IN ('R', 'C', 'E')
                            AND tipo_smistamento = 'COMPETENZA'
                            AND ufficio_smistamento = dep_ubicazione
                            AND docu_smis.id_documento = smis.id_documento
                            AND docu_smis.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB'));

      RETURN tot_smistamenti_altrove;
   END;

   FUNCTION get_relazioni_passive (p_id_cartella   IN VARCHAR2,
                                   p_utente        IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_RELAZIONI_PASSIVE

          DESCRIZIONE:

          RITORNO:  Restituisce la lista delle relzioni in cui il fascicolo ha il ruoto passivo

          Rev.  Data        Autore   Descrizione.
          00    13/06/2012  MMur       Prima emissione.
       ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT ag_competenze_fascicolo.lettura (vc.id_viewcartella,
                                                 p_utente)
                   lettura,
                tipi.descrizione,
                tipi.tipo_relazione,
                docu.codice_richiesta,
                fasc.id_documento,
                fasc.anno_archiviazione,
                fasc.anno_fascicolo_padre,
                fasc.base_normativa,
                fasc.calcola_nome,
                fasc.class_al,
                fasc.class_cod,
                fasc.class_dal,
                fasc.codice_amministrazione,
                fasc.codice_aoo,
                fasc.creata_cartella,
                fasc.cr_padre,
                fasc.data_apertura,
                fasc.data_archiviazione,
                fasc.data_chiusura,
                TO_CHAR (fasc.data_creazione, 'dd/mm/yyyy') data_creazione,
                fasc.data_stato,
                fasc.desc_procedimento,
                fasc.fascicolo_anno,
                fasc.fascicolo_numero,
                get_oggetto (fasc.id_documento, p_utente) fascicolo_oggetto,
                fasc.nome,
                fasc.note,
                fasc.numero_fascicolo_padre,
                fasc.procedimento,
                fasc.responsabile,
                fasc.riservato,
                fasc.stato_fascicolo,
                fasc.sub,
                fasc.topografia,
                fasc.ufficio_competenza,
                fasc.uff_assegnatario,
                fasc.ultimo_numero_sub,
                fasc.utente_creazione,
                fasc.utente_sessione,
                fasc.ufficio_creazione,
                fasc.descrizione_ufficio_competenza,
                cart.id_cartella,
                DECODE (
                   esistono_documenti_altrove_idf (fasc.id_documento, NULL),
                   0, DECODE (INSTR (fasc.fascicolo_numero, '.'),
                              0, 'segfascicolo',
                              'sottofascicolo'),
                   DECODE (INSTR (fasc.fascicolo_numero, '.'),
                           0, 'segfascicoloout',
                           'sottofascicoloout'))
                   icona
           FROM riferimenti rif,
                seg_fascicoli fasc,
                cartelle cart,
                view_cartella vc,
                documenti docu,
                tipi_relazione tipi
          WHERE     rif.id_documento_rif =
                       (SELECT id_documento_profilo
                          FROM cartelle
                         WHERE id_cartella = p_id_cartella)
                AND vc.id_cartella = cart.id_cartella
                AND fasc.id_documento = cart.id_documento_profilo
                AND fasc.id_documento = rif.id_documento
                AND docu.id_documento = fasc.id_documento
                AND NVL (cart.stato, 'BO') <> 'CA'
                AND tipi.area = 'SEGRETERIA'
                AND rif.tipo_relazione LIKE 'PROT_FAS%'
                AND tipi.tipo_relazione = rif.tipo_relazione;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_RELAZIONI_PASSIVE: ' || SQLERRM);
   END;

   FUNCTION get_tipi_relazioni (p_area IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
          NOME:        GET_TIPI_RELAZIONI

          DESCRIZIONE:

          RITORNO:  Restituisce la lista deIi tipi relazione presenti sulla tipi_relazione per l'area selezionata

          Rev.  Data        Autore   Descrizione.
          00    14/06/2012  MMur       Prima emissione.
       ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT *
           FROM tipi_relazione
          WHERE tipo_relazione LIKE 'PROT_FAS%' AND area = p_area;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_TIPI_RELAZIONI: ' || SQLERRM);
   END;

   FUNCTION get_smistamenti_da_ricevere (p_idrif                     VARCHAR2,
                                         p_utente                    VARCHAR2,
                                         p_controlla_assegnatario    NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        get_smistamenti_da_ricevere

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    18/07/2012  SC  Prima emissione.
         01    05/04/2017  SC  Gestione date privilegi
      ********************************************************************************/
      d_result         afc.t_ref_cursor;
      d_found          NUMBER := 1;
      d_data_rif       DATE;
      d_id_documento   NUMBER;
   BEGIN
      IF NVL (p_utente, '*') != '*'
      THEN
         d_id_documento := ag_utilities.get_fascicolo_per_idrif (p_idrif);
         d_data_rif := ag_utilities.get_Data_rif_privilegi (d_id_documento);

         OPEN d_result FOR
            SELECT smis.id_documento
              FROM seg_smistamenti smis, seg_fascicoli fasc, documenti docu
             WHERE     smis.idrif = p_idrif
                   AND smis.idrif = fasc.idrif
                   AND (   smis.codice_assegnatario IS NULL
                        OR p_controlla_assegnatario = 0)
                   AND smis.ufficio_smistamento IN (SELECT DISTINCT unita
                                                      FROM ag_priv_utente_tmp
                                                     WHERE     utente =
                                                                  p_utente
                                                           AND privilegio =
                                                                  'CARICO'
                                                           AND d_data_rif <=
                                                                  NVL (
                                                                     ag_priv_utente_tmp.al,
                                                                     TO_DATE (
                                                                        3333333,
                                                                        'j')))
                   AND (   (    smis.ufficio_smistamento IN (SELECT DISTINCT
                                                                    unita
                                                               FROM ag_priv_utente_tmp
                                                              WHERE     utente =
                                                                           p_utente
                                                                    AND privilegio =
                                                                           'VS'
                                                                    AND d_data_rif <=
                                                                           NVL (
                                                                              ag_priv_utente_tmp.al,
                                                                              TO_DATE (
                                                                                 3333333,
                                                                                 'j')))
                            AND NVL (fasc.riservato, 'N') = 'N')
                        OR (    smis.ufficio_smistamento IN (SELECT DISTINCT
                                                                    unita
                                                               FROM ag_priv_utente_tmp
                                                              WHERE     utente =
                                                                           p_utente
                                                                    AND privilegio =
                                                                           'VSR'
                                                                    AND d_data_rif <=
                                                                           NVL (
                                                                              ag_priv_utente_tmp.al,
                                                                              TO_DATE (
                                                                                 3333333,
                                                                                 'j')))
                            AND NVL (fasc.riservato, 'N') = 'Y'))
                   AND smis.stato_smistamento = 'R'
                   AND docu.id_documento = smis.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
            UNION
            SELECT smis.id_documento
              FROM seg_smistamenti smis, documenti docu
             WHERE     smis.idrif = p_idrif
                   AND smis.stato_smistamento = 'R'
                   AND smis.codice_assegnatario = p_utente
                   AND docu.id_documento = smis.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      ELSE
         OPEN d_result FOR
            SELECT smis.id_documento
              FROM seg_smistamenti smis, documenti docu
             WHERE     smis.idrif = p_idrif
                   AND smis.stato_smistamento = 'R'
                   AND docu.id_documento = smis.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      END IF;

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_SMISTAMENTI_DA_RICEVERE ' || SQLERRM);
   END get_smistamenti_da_ricevere;

   FUNCTION is_da_ricevere (p_idrif                     VARCHAR2,
                            p_utente                    VARCHAR2,
                            p_controlla_assegnatario    NUMBER)
      RETURN NUMBER
   IS
      n_smistamenti   afc.t_ref_cursor;
      retval          NUMBER := 0;
      dep_ele         NUMBER := 0;
   BEGIN
      n_smistamenti :=
         ag_fascicolo_utility.get_smistamenti_da_ricevere (
            p_idrif                    => p_idrif,
            p_utente                   => p_utente,
            p_controlla_assegnatario   => p_controlla_assegnatario);

      IF (n_smistamenti%ISOPEN)
      THEN
         FETCH n_smistamenti INTO dep_ele;

         IF (n_smistamenti%FOUND)
         THEN
            retval := 1;
         END IF;

         CLOSE n_smistamenti;
      END IF;

      RETURN retval;
   END;

   FUNCTION is_in_carico (p_idrif                     VARCHAR2,
                          p_utente                    VARCHAR2,
                          p_controlla_assegnatario    NUMBER,
                          p_distingui_eseguiti        NUMBER)
      RETURN NUMBER
   IS
      n_smistamenti   afc.t_ref_cursor;
      retval          NUMBER := 0;
      dep_ele         NUMBER := 0;
   BEGIN
      n_smistamenti :=
         ag_fascicolo_utility.get_smistamenti_in_carico (
            p_idrif                    => p_idrif,
            p_utente                   => p_utente,
            p_controlla_assegnatario   => p_controlla_assegnatario,
            p_distingui_eseguiti       => p_distingui_eseguiti);

      IF (n_smistamenti%ISOPEN)
      THEN
         FETCH n_smistamenti INTO dep_ele;

         IF (n_smistamenti%FOUND)
         THEN
            retval := 1;
         END IF;

         CLOSE n_smistamenti;
      END IF;

      RETURN retval;
   END;

   FUNCTION is_da_ricevere_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
      d_data_rif       DATE;
   BEGIN
      d_id_documento := ag_utilities.get_fascicolo_per_idrif (p_idrif);
      d_data_rif := ag_utilities.get_Data_rif_privilegi (d_id_documento);

      IF     is_da_ricevere (p_idrif                    => p_idrif,
                             p_utente                   => p_utente,
                             p_controlla_assegnatario   => 0) = 0
         AND is_da_ricevere (p_idrif                    => p_idrif,
                             p_utente                   => p_utente,
                             p_controlla_assegnatario   => 1) = 1
      THEN
         DECLARE
            retval   NUMBER;
         BEGIN
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM ag_priv_utente_tmp
                        WHERE     unita IN (SELECT ufficio_smistamento
                                              FROM seg_smistamenti
                                             WHERE     stato_smistamento =
                                                          'R'
                                                   AND idrif = p_idrif)
                              AND d_Data_rif <=
                                     NVL (al, TO_DATE (3333333, 'j'))
                              AND utente = p_utente);

            RETURN 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION is_in_carico_solo_per_ass (p_idrif                 VARCHAR2,
                                       p_utente                VARCHAR2,
                                       p_distingui_eseguiti    NUMBER)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
      d_data_rif       DATE;
   BEGIN
      d_id_documento := ag_utilities.get_fascicolo_per_idrif (p_idrif);
      d_data_rif := ag_utilities.get_Data_rif_privilegi (d_id_documento);

      IF     is_in_carico (p_idrif                    => p_idrif,
                           p_utente                   => p_utente,
                           p_controlla_assegnatario   => 0,
                           p_distingui_eseguiti       => p_distingui_eseguiti) =
                0
         AND is_in_carico (p_idrif                    => p_idrif,
                           p_utente                   => p_utente,
                           p_controlla_assegnatario   => 1,
                           p_distingui_eseguiti       => p_distingui_eseguiti) =
                1
      THEN
         DECLARE
            retval   NUMBER;
         BEGIN
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM ag_priv_utente_tmp
                        WHERE     unita IN (SELECT ufficio_smistamento
                                              FROM seg_smistamenti
                                             WHERE     stato_smistamento =
                                                          'C'
                                                   AND idrif = p_idrif)
                              AND d_data_rif <=
                                     NVL (al, TO_DATE (3333333, 'j'))
                              AND utente = p_utente);

            RETURN 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION get_smistamenti_in_carico (p_idrif                     VARCHAR2,
                                       p_utente                    VARCHAR2,
                                       p_controlla_assegnatario    NUMBER,
                                       p_distingui_eseguiti        NUMBER)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        get_smistamenti_da_ricevere

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    18/07/2012  SC  Prima emissione.
         01    05/04/2017  SC  Gestione date privilegi
      ********************************************************************************/
      d_result         afc.t_ref_cursor;
      d_found          NUMBER := 1;
      d_data_rif       DATE;
      d_id_documento   NUMBER;
   BEGIN
      IF NVL (p_utente, '*') != '*'
      THEN
         d_id_documento := ag_utilities.get_fascicolo_per_idrif (p_idrif);
         d_data_rif := ag_utilities.get_Data_rif_privilegi (d_id_documento);

         OPEN d_result FOR
            SELECT smis.id_documento
              FROM seg_smistamenti smis, seg_fascicoli fasc, documenti docu
             WHERE     smis.idrif = p_idrif
                   AND smis.idrif = fasc.idrif
                   AND (   smis.codice_assegnatario IS NULL
                        OR p_controlla_assegnatario = 0)
                   AND (   (    smis.ufficio_smistamento IN (SELECT DISTINCT
                                                                    unita
                                                               FROM ag_priv_utente_tmp
                                                              WHERE     utente =
                                                                           p_utente
                                                                    AND privilegio =
                                                                           'VS'
                                                                    AND d_data_rif <=
                                                                           NVL (
                                                                              al,
                                                                              TO_DATE (
                                                                                 3333333,
                                                                                 'j')))
                            AND NVL (fasc.riservato, 'N') = 'N')
                        OR (    smis.ufficio_smistamento IN (SELECT DISTINCT
                                                                    unita
                                                               FROM ag_priv_utente_tmp
                                                              WHERE     utente =
                                                                           p_utente
                                                                    AND privilegio =
                                                                           'VSR'
                                                                    AND d_data_rif <=
                                                                           NVL (
                                                                              al,
                                                                              TO_DATE (
                                                                                 3333333,
                                                                                 'j')))
                            AND NVL (fasc.riservato, 'N') = 'Y'))
                   AND (   smis.stato_smistamento = 'C'
                        OR (    smis.stato_smistamento = 'E'
                            AND p_distingui_eseguiti = 0))
                   AND docu.id_documento = smis.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
            UNION
            SELECT smis.id_documento
              FROM seg_smistamenti smis, documenti docu
             WHERE     smis.idrif = p_idrif
                   AND (   smis.stato_smistamento = 'C'
                        OR (    smis.stato_smistamento = 'E'
                            AND p_distingui_eseguiti = 0))
                   AND smis.codice_assegnatario = p_utente
                   AND docu.id_documento = smis.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      ELSE
         OPEN d_result FOR
            SELECT smis.id_documento
              FROM seg_smistamenti smis, documenti docu
             WHERE     smis.idrif = p_idrif
                   AND (   smis.stato_smistamento = 'C'
                        OR (    smis.stato_smistamento = 'E'
                            AND p_distingui_eseguiti = 0))
                   AND docu.id_documento = smis.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      END IF;

      RETURN (d_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_SMISTAMENTI_IN_CARICO ' || SQLERRM);
   END get_smistamenti_in_carico;

   /*****************************************************************************
      NOME:        get_smistamenti_eseguiti

      DESCRIZIONE:

      RITORNO:

      Rev.  Data       Autore  Descrizione.
      01    05/04/2017  SC     Inserito commento. Gestione date privilegi
   ********************************************************************************/
   FUNCTION get_smistamenti_eseguiti (p_idrif                     VARCHAR2,
                                      p_utente                    VARCHAR2,
                                      p_controlla_assegnatario    NUMBER)
      RETURN afc.t_ref_cursor
   IS
      d_result         afc.t_ref_cursor;
      continua         NUMBER;
      d_Data_rif       DATE;
      d_id_documento   NUMBER;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := ag_utilities.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         BEGIN
            d_id_documento := ag_utilities.get_fascicolo_per_idrif (p_idrif);
            d_data_rif := ag_utilities.get_Data_rif_privilegi (d_id_documento);

            OPEN d_result FOR
               SELECT seg_smistamenti.id_documento
                 FROM seg_smistamenti,
                      documenti docu,
                      ag_priv_utente_tmp,
                      seg_fascicoli
                WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                      AND docu.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = p_idrif
                      AND seg_smistamenti.ufficio_smistamento =
                             ag_priv_utente_tmp.unita
                      AND seg_smistamenti.stato_smistamento =
                             ag_utilities.smistamento_eseguito
                      AND (   seg_smistamenti.codice_assegnatario IS NULL
                           OR p_controlla_assegnatario = 0)
                      AND ag_priv_utente_tmp.utente = p_utente
                      AND seg_fascicoli.idrif = seg_smistamenti.idrif
                      AND d_data_rif <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND (   (    ag_priv_utente_tmp.privilegio = 'VS'
                               AND NVL (seg_fascicoli.riservato, 'N') = 'N')
                           OR (    ag_priv_utente_tmp.privilegio = 'VSR'
                               AND NVL (seg_fascicoli.riservato, 'N') = 'Y'))
               UNION
               SELECT seg_smistamenti.id_documento
                 FROM seg_smistamenti, documenti docu
                WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                      AND docu.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = p_idrif
                      AND seg_smistamenti.stato_smistamento =
                             ag_utilities.smistamento_eseguito
                      AND seg_smistamenti.codice_assegnatario = p_utente
                      AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_result := NULL;
         END;
      END IF;

      --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
      RETURN d_result;
   END get_smistamenti_eseguiti;

   PROCEDURE ricongiungi_doc (p_id_cartella       NUMBER,
                              p_id_smistamento    NUMBER,
                              p_data_carico       DATE,
                              p_utente            VARCHAR2)
   IS
   BEGIN
      FOR p
         IN (SELECT prot.idrif,
                    prot.class_cod,
                    prot.class_dal,
                    prot.fascicolo_anno,
                    prot.fascicolo_numero,
                    fasc.class_cod class_cod_fasc,
                    fasc.class_dal class_dal_fasc,
                    fasc.fascicolo_anno anno_fasc,
                    fasc.fascicolo_numero numero_fasc
               FROM links,
                    smistabile_view prot,
                    seg_fascicoli fasc,
                    cartelle cart
              WHERE     links.id_cartella = cart.id_cartella
                    AND fasc.id_documento = cart.id_documento_profilo
                    AND cart.id_cartella = p_id_cartella
                    AND links.tipo_oggetto = 'D'
                    AND links.id_oggetto = prot.id_documento
                    AND DECODE (
                           ag_utilities.verifica_categoria_documento (
                              prot.id_documento,
                              'PROTO'),
                           1, NVL (prot.stato_pr, 'DP'),
                           '*') NOT IN ('DP', 'AN'))
      LOOP
         IF (    p.class_cod = p.class_cod_fasc
             AND p.class_dal = p.class_dal_fasc
             AND p.fascicolo_anno = p.anno_fasc
             AND p.fascicolo_numero = p.numero_fasc)
         THEN
            FOR s
               IN (SELECT smis_prot.id_documento
                     FROM seg_smistamenti smis_fasc,
                          seg_smistamenti smis_prot
                    WHERE     smis_fasc.id_documento = p_id_smistamento
                          AND smis_prot.tipo_smistamento =
                                 smis_fasc.tipo_smistamento
                          AND smis_prot.stato_smistamento IN ('R', 'C', 'E')
                          AND smis_prot.ufficio_smistamento =
                                 smis_fasc.ufficio_smistamento
                          AND (NVL (smis_prot.codice_assegnatario, p_utente) =
                                  p_utente)
                          AND smis_prot.idrif = p.idrif)
            LOOP
               UPDATE seg_smistamenti
                  SET stato_smistamento = 'F',
                      note =
                            DECODE (note,
                                    NULL, '',
                                    note || CHR (10) || CHR (13))
                         || 'Smistamento storicizzato automaticamente in data '
                         || TO_CHAR (p_data_carico, 'dd/mm/yyyy hh24:mi:ss')
                         || ' per ricongiungimento a Fascicolo '
                         || p.class_cod
                         || ' - '
                         || p.fascicolo_anno
                         || '/'
                         || p.fascicolo_numero
                         || '.'
                WHERE id_documento = s.id_documento;

               ag_smistamento.delete_task_esterni (s.id_documento);
            END LOOP;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'Ricongiungimento documenti al fascicolo '
            || p_id_cartella
            || ' fallito per '
            || SQLERRM);
   END;

   FUNCTION storicizza_smistamento (p_class_cod                 VARCHAR2,
                                    p_fascicolo_anno            NUMBER,
                                    p_fascicolo_numero          VARCHAR2,
                                    p_id_smistamento            NUMBER,
                                    p_utente                    VARCHAR2,
                                    p_unita_trasmissione        VARCHAR2,
                                    p_des_unita_trasmissione    VARCHAR2,
                                    p_unita_ricevente           VARCHAR2,
                                    p_des_unita_ricevente       VARCHAR2,
                                    p_unita_chiusa              NUMBER,
                                    p_smistamento_nuovo         NUMBER,
                                    p_controlla_assegnatari     NUMBER,
                                    p_idrif                     VARCHAR2)
      RETURN NUMBER
   IS
      dep_nuovo_smistamento   NUMBER;
      dep_data                DATE := SYSDATE;
      dep_procedi             NUMBER := 0;
   BEGIN
      IF p_controlla_assegnatari = 0
      THEN
         dep_procedi := 1;
      END IF;

      IF dep_procedi = 0
      THEN
         BEGIN
            SELECT COUNT (*)
              INTO dep_procedi
              FROM seg_smistamenti, documenti
             WHERE     seg_smistamenti.id_documento = documenti.id_documento
                   AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND seg_smistamenti.idrif = p_idrif
                   AND seg_smistamenti.tipo_smistamento = 'COMPETENZA'
                   AND seg_smistamenti.stato_smistamento != 'F'
                   AND codice_assegnatario IS NULL;

            IF dep_procedi = 0
            THEN
               SELECT COUNT (*)
                 INTO dep_procedi
                 FROM seg_smistamenti, documenti
                WHERE     seg_smistamenti.id_documento =
                             documenti.id_documento
                      AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND seg_smistamenti.idrif = p_idrif
                      AND seg_smistamenti.tipo_smistamento = 'COMPETENZA'
                      AND seg_smistamenti.stato_smistamento != 'F'
                      AND codice_assegnatario = p_utente
                      AND p_controlla_assegnatari = 1
                      AND NOT EXISTS
                             (SELECT 1
                                FROM seg_smistamenti, documenti
                               WHERE     seg_smistamenti.id_documento =
                                            documenti.id_documento
                                     AND documenti.stato_documento NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                                     AND seg_smistamenti.idrif = p_idrif
                                     AND seg_smistamenti.tipo_smistamento =
                                            'COMPETENZA'
                                     AND seg_smistamenti.stato_smistamento !=
                                            'F'
                                     AND codice_assegnatario != p_utente);
            END IF;
         END;
      END IF;

      IF p_smistamento_nuovo IS NULL AND dep_procedi > 0
      THEN
         dep_nuovo_smistamento :=
            ag_utilities.duplica_documento (p_id_smistamento, p_utente);

         UPDATE seg_smistamenti
            SET note =
                      'Smistamento creato automaticamente in data '
                   || TO_CHAR (dep_data, 'dd/mm/yyyy hh24:mi:ss')
                   || ' per modifica dell''ufficio di competenza del fascicolo '
                   || p_class_cod
                   || ' - '
                   || p_fascicolo_anno
                   || '/'
                   || p_fascicolo_numero
                   || '.',
                codice_assegnatario = NULL,
                assegnazione_dal = NULL,
                des_assegnatario = NULL,
                des_ufficio_smistamento = p_des_unita_ricevente,
                des_ufficio_trasmissione = p_des_unita_trasmissione,
                note_utente = NULL,
                presa_in_carico_dal =
                   DECODE (p_unita_chiusa,
                           0, NULL,
                           DECODE (stato_smistamento, 'R', NULL, dep_data)),
                presa_in_carico_utente =
                   DECODE (p_unita_chiusa,
                           0, NULL,
                           DECODE (stato_smistamento, 'R', NULL, p_utente)),
                smistamento_dal = dep_data,
                ufficio_smistamento = p_unita_ricevente,
                ufficio_trasmissione = p_unita_trasmissione,
                utente_trasmissione = p_utente,
                data_esecuzione =
                   DECODE (p_unita_chiusa,
                           0, NULL,
                           DECODE (stato_smistamento, 'E', dep_data, NULL)),
                utente_esecuzione =
                   DECODE (p_unita_chiusa,
                           0, NULL,
                           DECODE (stato_smistamento, 'E', p_utente, NULL)),
                stato_smistamento =
                   DECODE (p_unita_chiusa, 0, 'R', stato_smistamento)
          WHERE id_documento = dep_nuovo_smistamento;
      END IF;

      UPDATE seg_smistamenti
         SET stato_smistamento = 'F',
             note =
                   DECODE (note, NULL, '', note || CHR (10) || CHR (13))
                || 'Smistamento storicizzato automaticamente in data '
                || TO_CHAR (dep_data, 'dd/mm/yyyy hh24:mi:ss')
                || ' per modifica dell''ufficio di competenza del fascicolo '
                || p_class_cod
                || ' - '
                || p_fascicolo_anno
                || '/'
                || p_fascicolo_numero
                || '.'
       WHERE     id_documento = p_id_smistamento
             AND (   (    p_controlla_assegnatari = 1
                      AND DECODE (codice_assegnatario,
                                  NULL, p_utente,
                                  codice_assegnatario) = p_utente)
                  OR p_controlla_assegnatari = 0);

      IF SQL%ROWCOUNT > 0
      THEN
         ag_smistamento.delete_task_esterni (p_id_smistamento);
      END IF;

      RETURN NVL (dep_nuovo_smistamento, p_smistamento_nuovo);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'Storicizzazione a seguito di modifica '
            || 'dell''ufficio di competenza del fascicolo '
            || p_class_cod
            || ' - '
            || p_fascicolo_anno
            || '/'
            || p_fascicolo_numero
            || ' fallita per '
            || SQLERRM);
   END;

   FUNCTION is_fascicolo (p_id_cartella NUMBER)
      RETURN NUMBER
   IS
      dep_is_fascicolo   NUMBER := 0;
   BEGIN
      SELECT 1
        INTO dep_is_fascicolo
        FROM seg_fascicoli, cartelle
       WHERE     cartelle.id_cartella = p_id_cartella
             AND cartelle.id_documento_profilo = seg_fascicoli.id_documento;

      RETURN dep_is_fascicolo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   PROCEDURE insert_storico_fasc_docu (p_id_cartella     NUMBER,
                                       p_id_documento    NUMBER,
                                       p_utente          VARCHAR2,
                                       p_azione          VARCHAR2,
                                       p_cod_amm         VARCHAR2,
                                       p_cod_aoo         VARCHAR2)
   IS
      p_data_inserimento   DATE;
   BEGIN
      IF     (   (    ag_utilities.verifica_categoria_documento (
                         p_id_documento,
                         'PROTO') = 1
                  AND ag_competenze_protocollo.f_valore_campo (
                         p_id_documento,
                         ag_utilities.campo_stato_protocollo) != 'DP')
              OR ag_utilities.verifica_categoria_documento (p_id_documento,
                                                            'CLASSIFICABILE') =
                    1)
         AND is_fascicolo (p_id_cartella) = 1
         AND ag_parametro.get_valore ('ITER_FASCICOLI_',
                                      p_cod_amm,
                                      p_cod_aoo,
                                      'N') = 'Y'
      THEN
         IF p_azione = 'D'
         THEN
            BEGIN
               SELECT dal
                 INTO p_data_inserimento
                 FROM ag_storico_fasc_documento sfdo1
                WHERE     id_documento = p_id_documento
                      AND id_cartella = p_id_cartella
                      AND al IS NULL
                      AND NOT EXISTS
                             (SELECT 1
                                FROM ag_storico_fasc_documento sfdo2
                               WHERE     id_documento = p_id_documento
                                     AND id_cartella = p_id_cartella
                                     AND sfdo2.dal > sfdo1.dal);

               UPDATE ag_storico_fasc_documento
                  SET al = SYSDATE, utente_aggiornamento = p_utente
                WHERE     dal = p_data_inserimento
                      AND id_documento = p_id_documento
                      AND id_cartella = p_id_cartella;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  INSERT
                    INTO ag_storico_fasc_documento (id_documento,
                                                    id_cartella,
                                                    dal,
                                                    al,
                                                    utente_aggiornamento)
                  VALUES (p_id_documento,
                          p_id_cartella,
                          TO_DATE ('01/01/1900', 'dd/mm/yyyy'),
                          SYSDATE,
                          p_utente);
            END;
         ELSE
            BEGIN
               INSERT INTO ag_storico_fasc_documento (id_documento,
                                                      id_cartella,
                                                      dal,
                                                      utente_aggiornamento)
                    VALUES (p_id_documento,
                            p_id_cartella,
                            SYSDATE,
                            p_utente);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
            END;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
               'ag_fascicolo_utility.insert_storico_fasc_docu::Fallita registrazione fascicoli storici - '
            || SQLERRM);
   END;

   FUNCTION get_url_fasc (p_class_cod           VARCHAR2,
                          p_class_dal           VARCHAR2,
                          p_fascicolo_anno      NUMBER,
                          p_fascicolo_numero    VARCHAR2,
                          p_codice_amm          VARCHAR2,
                          p_codice_aoo          VARCHAR2,
                          p_utente              VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return        VARCHAR2 (4000);
      d_id_cartella   NUMBER;
      d_rw            VARCHAR2 (1);
      d_class_dal     DATE := TO_DATE (p_class_dal, 'dd/mm/yyyy');
   BEGIN
      SELECT DECODE (
                ag_competenze_fascicolo.modifica (id_viewcartella, p_utente),
                1, 'W',
                DECODE (
                   ag_competenze_fascicolo.lettura (id_viewcartella,
                                                    p_utente),
                   1, 'R',
                   NULL)),
             cart_fasc.id_cartella
        INTO d_rw, d_id_cartella
        FROM seg_fascicoli fasc,
             seg_classificazioni clas,
             documenti docu_clas,
             documenti docu_fasc,
             cartelle cart_clas,
             cartelle cart_fasc,
             links,
             cartelle cart_padre,
             view_cartella vica_fasc
       WHERE     fasc.codice_amministrazione = p_codice_amm
             AND fasc.codice_aoo = p_codice_aoo
             AND clas.class_dal = d_class_dal
             AND fasc.class_cod = clas.class_cod
             AND fasc.class_dal = clas.class_dal
             AND clas.codice_amministrazione = fasc.codice_amministrazione
             AND clas.codice_aoo = fasc.codice_aoo
             AND docu_clas.id_documento = clas.id_documento
             AND docu_fasc.id_documento = fasc.id_documento
             AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                               'RE',
                                                               'PB')
             AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                               'RE',
                                                               'PB')
             AND cart_clas.id_documento_profilo = docu_clas.id_documento
             AND vica_fasc.id_cartella = cart_fasc.id_cartella
             AND NVL (cart_clas.stato, 'BO') <> 'CA'
             AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
             AND NVL (cart_fasc.stato, 'BO') <> 'CA'
             AND NVL (fasc.class_cod, ' ') = p_class_cod
             AND fasc.fascicolo_anno = p_fascicolo_anno
             AND fasc.fascicolo_numero = p_fascicolo_numero
             AND links.id_oggetto = cart_fasc.id_cartella
             AND links.tipo_oggetto = 'C'
             AND cart_padre.id_cartella = links.id_cartella;

      d_return :=
         REPLACE (gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     d_id_cartella,
                                                     'C',
                                                     '',
                                                     '',
                                                     '',
                                                     d_rw,
                                                     '',
                                                     '',
                                                     '5',
                                                     'N'),
                  '../../',
                  '../');
      RETURN d_return;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 'ERRORE: fascicolo non esistente o non visualizzabile';
      WHEN OTHERS
      THEN
         RETURN 'ERRORE: ' || SQLERRM;
   END;

   FUNCTION get_report
      RETURN VARCHAR2
   IS
      d_report   VARCHAR2 (100);
   BEGIN
      SELECT AG_PARAMETRO.GET_VALORE ('REPORT_FASCICOLO',
                                      '@agStrut@',
                                      'Fascicolo')
        INTO d_report
        FROM DUAL;

      RETURN d_report;
   END;


   FUNCTION get_id_profilo (p_id_cartella NUMBER)
      RETURN NUMBER
   IS
      dep_id_doc   NUMBER;
   BEGIN
      SELECT id_documento_profilo
        INTO dep_id_doc
        FROM cartelle
       WHERE id_cartella = p_id_cartella;

      RETURN dep_id_doc;
   END;

   PROCEDURE proponi_scarto (p_id_cartella NUMBER)
   IS
      dep_id_doc     NUMBER;
      dep_min_anno   NUMBER;
   BEGIN
      dep_id_doc := get_id_profilo (p_id_cartella);
      dep_min_anno := get_min_anno_doc_in_fasc (P_ID_CARTELLA);

      IF dep_min_anno IS NULL
      THEN
         raise_application_error (
            -20999,
            'Il fascicolo non ha documenti. Non verra'' proposto per lo scarto.');
      ELSE
         UPDATE seg_fascicoli
            SET stato_scarto = 'PS'
          WHERE     id_documento = dep_id_doc
                AND NVL (stato_scarto, '**') IN ('**', 'RR');
      END IF;
   END;

   PROCEDURE conserva (p_id_cartella NUMBER)
   IS
      dep_id_doc   NUMBER;
   BEGIN
      dep_id_doc := get_id_profilo (p_id_cartella);

      UPDATE seg_fascicoli
         SET stato_scarto = 'CO'
       WHERE     id_documento = dep_id_doc
             AND NVL (stato_scarto, '**') IN ('**', 'RR');
   END;

   PROCEDURE attendi_approvazione (p_id_cartella NUMBER)
   IS
      dep_id_doc   NUMBER;
   BEGIN
      dep_id_doc := get_id_profilo (p_id_cartella);

      UPDATE seg_fascicoli
         SET stato_scarto = 'AA'
       WHERE id_documento = dep_id_doc AND NVL (stato_scarto, '**') = 'PS';
   END;

   PROCEDURE non_scartabile (p_id_cartella NUMBER)
   IS
      dep_id_doc   NUMBER;
   BEGIN
      dep_id_doc := get_id_profilo (p_id_cartella);

      UPDATE seg_fascicoli
         SET stato_scarto = 'RR'
       WHERE id_documento = dep_id_doc AND NVL (stato_scarto, '**') = 'AA';
   END;

   PROCEDURE scarta (p_id_cartella        NUMBER,
                     p_nulla_osta         VARCHAR2,
                     p_data_nulla_osta    VARCHAR2)
   IS
      dep_id_doc   NUMBER;
   BEGIN
      dep_id_doc := get_id_profilo (p_id_cartella);

      UPDATE seg_fascicoli
         SET stato_scarto = 'SC',
             numero_nulla_osta = p_nulla_osta,
             data_nulla_osta = TO_DATE (p_data_nulla_osta, 'dd/mm/yyyy')
       WHERE id_documento = dep_id_doc AND NVL (stato_scarto, '**') = 'AA';
   END;

   PROCEDURE attesa_app_scarto (p_id_cartella     NUMBER,
                                p_descrizione     VARCHAR2,
                                p_osservazioni    VARCHAR2,
                                p_anno_minimo     NUMBER,
                                p_anno_massimo    NUMBER,
                                p_pezzi           VARCHAR2,
                                p_peso            NUMBER,
                                p_ubicazione      VARCHAR2)
   IS
      dep_id_doc   NUMBER := NULL;
   BEGIN
      dep_id_doc := get_id_profilo (p_id_cartella);

      UPDATE seg_fascicoli
         SET stato_scarto = 'AA',
             descrizione_scarto = p_descrizione,
             osservazioni_scarto = p_osservazioni,
             anno_minimo_scarto = p_anno_minimo,
             anno_massimo_scarto = p_anno_massimo,
             pezzi_scarto = p_pezzi,
             peso_scarto = p_peso,
             ubicazione_scarto = p_ubicazione,
             anno_richiesta_scarto = TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
       WHERE id_documento = dep_id_doc AND NVL (stato_scarto, '**') = 'PS';
   END;

   FUNCTION get_min_anno_doc_in_fasc (p_id_cartella IN VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      SELECT NVL (TO_CHAR (MIN (data), 'yyyy'),
                  TO_CHAR (MIN (stati_documento.data_aggiornamento), 'yyyy'))
                anno_minimo_scarto
        INTO d_return
        FROM classificabile_view,
             documenti,
             links,
             stati_documento
       WHERE     classificabile_view.id_documento = documenti.id_documento
             AND documenti.id_documento = stati_documento.id_documento
             AND links.id_cartella = p_id_cartella
             AND links.tipo_oggetto = 'D'
             AND links.id_oggetto = documenti.id_documento
             AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB');

      RETURN d_return;
   END;

   FUNCTION get_max_anno_doc_in_fasc (p_id_cartella IN VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      SELECT NVL (TO_CHAR (MAX (data), 'yyyy'),
                  TO_CHAR (MAX (stati_documento.data_aggiornamento), 'yyyy'))
                anno_massimo_scarto
        INTO d_return
        FROM classificabile_view,
             documenti,
             links,
             stati_documento
       WHERE     classificabile_view.id_documento = documenti.id_documento
             AND documenti.id_documento = stati_documento.id_documento
             AND links.id_cartella = p_id_cartella
             AND links.tipo_oggetto = 'D'
             AND links.id_oggetto = documenti.id_documento
             AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB');

      RETURN d_return;
   END;

   FUNCTION get_scarti
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_SCARTI
         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore Descrizione.
         00    24/02/2014 MM     Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT stato_scarto,
                  data_stato_scarto,
                  DECODE (
                     stato_scarto,
                     'PS', descrizione,
                        descrizione
                     || ' ('
                     || TO_CHAR (data_stato_scarto, 'dd/mm/yyyy')
                     || ')')
                     descrizione
             FROM (SELECT NVL (fasc.stato_scarto, '**') stato_scarto,
                          DECODE (fasc.stato_scarto,
                                  'AA', TRUNC (FASC.DATA_STATO_SCARTO),
                                  TRUNC (SYSDATE))
                             data_stato_scarto,
                          ag_stati_scarto.descrizione
                     FROM seg_fascicoli fasc,
                          documenti docu_fasc,
                          cartelle cart_fasc,
                          ag_stati_scarto
                    WHERE     AG_STATI_SCARTO.STATO =
                                 NVL (fasc.stato_scarto, '**')
                          AND docu_fasc.id_documento = fasc.id_documento
                          AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                                                  AND NVL (
                                                         fasc.class_al,
                                                         TO_DATE ('01/01/2999',
                                                                  'dd/mm/yyyy'))
                          AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_fasc.id_documento_profilo =
                                 docu_fasc.id_documento
                          AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                          AND NVL (fasc.stato_scarto, '**') IN ('PS', 'AA'))
         GROUP BY stato_scarto, descrizione, DATA_STATO_SCARTO
         ORDER BY 3, 2;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLI_DA_SCARTARE: ' || SQLERRM);
   END;

   FUNCTION get_fascicoli_da_scartare (p_utente        IN VARCHAR2,
                                       p_stato         IN VARCHAR2,
                                       p_data_scarto   IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_FASCICOLI_DA_SCARTARE
         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore Descrizione.
         00    24/02/2014 MM     Prima emissione.
      ********************************************************************************/
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
           SELECT cart_fasc.id_cartella,
                  fasc.id_documento id_fascicolo,
                  get_numero_fasc_ord (fascicolo_numero) numero_ord,
                  fasc.class_cod,
                  fasc.class_dal,
                  fasc.fascicolo_anno,
                  fasc.fascicolo_numero,
                  --get_oggetto (fasc.id_documento, p_utente) fascicolo_oggetto,
                  NVL (fasc.descrizione_scarto,
                       get_oggetto (fasc.id_documento, p_utente))
                     descrizione_scarto,
                  get_min_anno_doc_in_fasc (cart_fasc.id_cartella)
                     anno_minimo_scarto,
                  get_max_anno_doc_in_fasc (cart_fasc.id_cartella)
                     anno_massimo_scarto,
                  pezzi_scarto,
                  peso_scarto,
                  ubicazione_scarto,
                  osservazioni_scarto
             FROM seg_fascicoli fasc, documenti docu_fasc, cartelle cart_fasc
            WHERE     docu_fasc.id_documento = fasc.id_documento
                  AND TRUNC (SYSDATE) BETWEEN fasc.class_dal
                                          AND NVL (
                                                 fasc.class_al,
                                                 TO_DATE ('01/01/2999',
                                                          'dd/mm/yyyy'))
                  AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                    'RE',
                                                                    'PB')
                  AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
                  AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                  AND NVL (fasc.stato_scarto, '**') = p_stato
                  AND TRUNC (FASC.DATA_STATO_SCARTO) =
                         DECODE (p_stato,
                                 'PS', TRUNC (FASC.DATA_STATO_SCARTO),
                                 TO_DATE (p_data_scarto, 'dd/mm/yyyy'))
         ORDER BY NLSSORT (class_cod, 'NLS_LANGUAGE=American'),
                  class_dal,
                  fascicolo_anno,
                  1;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_FASCICOLI_DA_SCARTARE: ' || SQLERRM);
   END;

   PROCEDURE attesa_app_scarto (p_utente IN VARCHAR2)
   IS
   BEGIN
      UPDATE seg_fascicoli
         SET stato_scarto = 'AA'
       WHERE NVL (stato_scarto, '**') = 'PS';
   END;

   PROCEDURE AGGIORNA_DATI_SCARTO (p_id_fascicolo    NUMBER,
                                   p_descrizione     VARCHAR2,
                                   p_osservazioni    VARCHAR2,
                                   p_anno_minimo     NUMBER,
                                   p_anno_massimo    NUMBER,
                                   p_pezzi           VARCHAR2,
                                   p_peso            NUMBER,
                                   p_ubicazione      VARCHAR2)
   IS
   BEGIN
      UPDATE seg_fascicoli
         SET descrizione_scarto = p_descrizione,
             osservazioni_scarto = p_osservazioni,
             anno_minimo_scarto = p_anno_minimo,
             anno_massimo_scarto = p_anno_massimo,
             pezzi_scarto = p_pezzi,
             peso_scarto = p_peso,
             ubicazione_scarto = p_ubicazione,
             anno_richiesta_scarto = TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
       WHERE     id_documento = p_id_fascicolo
             AND NVL (stato_scarto, '**') = 'PS';
   END;

   FUNCTION get_id_anno_fasc (p_id_cartella IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      d_return   afc.t_ref_cursor;
   BEGIN
      OPEN d_return FOR
         SELECT id_documento, fascicolo_anno
           FROM cartelle cart, seg_fascicoli fasc
          WHERE     cart.id_cartella = p_id_cartella
                AND fasc.id_documento = cart.id_documento_profilo;

      RETURN d_return;
   END;

   FUNCTION get_cr_fascicolo (
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2,
      p_class_cod          IN seg_classificazioni.class_cod%TYPE,
      p_class_dal          IN VARCHAR2,
      p_fascicolo_anno     IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero   IN seg_fascicoli.fascicolo_numero%TYPE)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
         NOME:        GET_CR_FASCICOLO

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  SN  Prima emissione.
      ********************************************************************************/
      d_found        VARCHAR2 (100);
      d_codice_amm   VARCHAR2 (100);
      d_codice_aoo   VARCHAR2 (100);
   BEGIN
      d_codice_amm :=
         NVL (
            p_codice_amm,
            ag_parametro.get_valore (
               'CODICE_AMM_' || AG_UTILITIES.get_defaultaooindex,
               '@agVar@',
               NULL));
      d_codice_aoo :=
         NVL (
            p_codice_aoo,
            ag_parametro.get_valore (
               'CODICE_AOO_' || AG_UTILITIES.get_defaultaooindex,
               '@agVar@',
               NULL));

      SELECT MIN (docu_fasc.codice_richiesta)
        INTO d_found
        FROM seg_fascicoli fasc, documenti docu_fasc, cartelle cart_fasc
       WHERE     fasc.codice_amministrazione = d_codice_amm
             AND fasc.codice_aoo = d_codice_aoo
             AND docu_fasc.id_documento = fasc.id_documento
             AND fasc.class_dal = TO_DATE (p_class_dal, 'dd/mm/yyyy')
             AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                               'RE',
                                                               'PB')
             AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
             AND NVL (cart_fasc.stato, 'BO') <> 'CA'
             AND fasc.class_cod = p_class_cod
             AND fasc.fascicolo_anno = p_fascicolo_anno
             AND LTRIM (fasc.fascicolo_numero, '0') =
                    LTRIM (p_fascicolo_numero, '0');

      RETURN d_found;
   END;

   FUNCTION get_id_cartella (p_class_cod           VARCHAR2,
                             p_class_dal           DATE,
                             p_fascicolo_anno      NUMBER,
                             p_fascicolo_numero    VARCHAR2,
                             p_codice_amm          VARCHAR2,
                             p_codice_aoo          VARCHAR2)
      RETURN NUMBER
   IS
      /****************************************************************************
         NOME:        GET_ID_CARTELLA
         DESCRIZIONE: restituisce l'id della cartella corrispondente al fascicolo.

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         006   25/08/2015 MM      Prima emissione.
      ****************************************************************************/
      d_result   NUMBER;
   BEGIN
      SELECT cart_fasc.id_cartella
        INTO d_result
        FROM seg_fascicoli fasc, cartelle cart_fasc
       WHERE     class_cod = p_class_cod
             AND class_dal = p_class_dal
             AND fascicolo_anno = p_fascicolo_anno
             AND fascicolo_numero = p_fascicolo_numero
             AND codice_amministrazione = p_codice_amm
             AND codice_aoo = p_codice_aoo
             AND cart_fasc.id_documento_profilo = fasc.id_documento
             AND NVL (cart_fasc.stato, 'BO') <> 'CA';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.GET_ID_CARTELLA: ' || SQLERRM);
   END;

   FUNCTION get_id_cartella (p_class_cod           VARCHAR2,
                             p_class_dal           VARCHAR2,
                             p_fascicolo_anno      NUMBER,
                             p_fascicolo_numero    VARCHAR2,
                             p_codice_amm          VARCHAR2,
                             p_codice_aoo          VARCHAR2)
      RETURN NUMBER
   IS
      d_class_dal   DATE := TO_DATE (p_class_dal, 'dd/mm/yyyy');
   BEGIN
      RETURN get_id_cartella (p_class_cod,
                              d_class_dal,
                              p_fascicolo_anno,
                              p_fascicolo_numero,
                              p_codice_amm,
                              p_codice_aoo);
   END;

   PROCEDURE elimina_smistamenti (p_id_fasc NUMBER)
   IS
      d_idrif   VARCHAR2 (100);
   BEGIN
      SELECT idrif
        INTO d_idrif
        FROM seg_fascicoli
       WHERE id_documento = p_id_fasc;

      ag_smistamento.elimina_smistamenti (d_idrif);
   END;

   FUNCTION get_padre_fascicoli (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_classificazioni.class_cod%TYPE,
      p_class_dal    IN VARCHAR2,
      p_id_padre     IN NUMBER)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT p_id_padre id_documento, cartelle.id_cartella id_cartella
           FROM cartelle, seg_fascicoli
          WHERE     seg_fascicoli.id_documento = p_id_padre
                AND cartelle.id_documento_profilo =
                       seg_fascicoli.id_documento
                AND p_id_padre IS NOT NULL
         UNION
         SELECT p_id_padre id_documento, cartelle.id_cartella
           FROM cartelle, seg_classificazioni
          WHERE     seg_classificazioni.id_documento = p_id_padre
                AND cartelle.id_documento_profilo =
                       seg_classificazioni.id_documento
                AND p_id_padre IS NOT NULL
         UNION
         SELECT seg_classificazioni.id_documento, cartelle.id_cartella
           FROM seg_classificazioni, documenti dclas, cartelle
          WHERE     seg_classificazioni.codice_amministrazione = p_codice_amm
                AND seg_classificazioni.codice_aoo = p_codice_aoo
                AND seg_classificazioni.class_cod = p_class_cod
                AND seg_classificazioni.class_dal =
                       TO_DATE (p_class_dal, 'dd/mm/yyyy')
                AND cartelle.id_documento_profilo = dclas.id_documento
                AND dclas.id_documento = seg_classificazioni.id_documento
                AND dclas.stato_documento NOT IN ('CA', 'RE')
                AND p_id_padre IS NULL;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_FASCICOLO_UTILITY.get_padre_fascicoli: ' || SQLERRM);
   END;
END ag_fascicolo_utility;
/
