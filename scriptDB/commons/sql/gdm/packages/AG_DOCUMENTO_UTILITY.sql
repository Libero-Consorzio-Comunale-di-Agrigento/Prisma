--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_DOCUMENTO_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_documento_utility
IS
   /******************************************************************************
    NOME:        AG_DOCUMENTO_UTILITY.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento documento.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI: Le rev > 50 sono quelle apportate in Versione 3.5 o successiva
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   09/07/2009 MM     Creazione.
    01   16/05/2012 MM     Modifiche versione 2.1.
    02   03/10/2013 MM     Modifiche versione 2.2.
    03   14/08/2015 MM     Aggiunti p_codice_amm e p_codice_aoo a get_url.
                           Creata delete_from_titolario
    04   16/11/2016 MM     Create separa_gli_allegati e count_oggetti_file
    05   07/12/2016 MM     Create crea_smistamento, crea_smistamento_e_termina,
                           crea_rapporto e crea_rapporto_e_termina.
    06   07/03/2017 MM     V2.7
    07   25/10/2017 MM     Modificate aggiorna_mittente, aggiorna_mittente_commit
                           e creata get_file_protocollo.
    08   25/10/2017 MM     Modificata get_tipi_documento e creata exists_risposta_successiva
    09   26/10/2017 SC     Creata get_tipi_consegna
    10   14/12/2017 MM     Creata GET_URL_ANAGRAFICA
    11   01/02/2018 MM     Modificata get_tipi_documento
    51   12/11/2018 MM     Creata crea_protocollo_agspr
    52   06/02/2020 SC     Modificata is_rapp_duplicato.
    53   11/08/2020 SV     Creata crea_doc_titolario_agspr
    54   14/09/2020 MM     creata IS_PROTOCOLLATO.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.54';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_registri_emergenza
      RETURN afc.t_ref_cursor;

   FUNCTION elimina_class_secondaria (p_id_link IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_unita_assegnatari (p_unita     IN VARCHAR2,
                                   p_ricerca   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_lista_utenti (p_lista_utenti VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION is_jdms_link_attivo (p_utente   IN VARCHAR2,
                                 p_cm       IN VARCHAR2,
                                 p_area     IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION check_permessi_accesso (p_id_documento   IN VARCHAR2,
                                    p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_gestione_smistamenti (p_area         IN VARCHAR2,
                                      p_cm           IN VARCHAR2,
                                      p_cr           IN VARCHAR2,
                                      p_utente       IN VARCHAR2,
                                      p_codice_amm   IN VARCHAR2,
                                      p_codice_aoo   IN VARCHAR2,
                                      p_rw           IN VARCHAR2,
                                      p_stato_pr     IN VARCHAR2,
                                      p_modalita     IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dettagli_pec (p_id_rif IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_rapporti (p_id_rif IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_annullamento (p_utente       IN VARCHAR2,
                                    p_codice_amm   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_liste_distribuzione (p_descrizione IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_ultima_modifica (p_id_documento IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION istanzia_iter (id_richiesta             IN NUMBER DEFAULT NULL,
                           nome_iter                IN VARCHAR2,
                           parametri                IN VARCHAR2 DEFAULT NULL,
                           data_minima_esecuzione      DATE DEFAULT NULL,
                           utente                      VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_provenienza_documento (p_id_cart_provenienza   IN VARCHAR2,
                                       p_utente                IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_default_protocollo (p_utente   IN VARCHAR2,
                                    p_modulo   IN VARCHAR2 DEFAULT 'AGSPR')
      RETURN afc.t_ref_cursor;

   FUNCTION get_privilegi (p_id_documento   IN VARCHAR2,
                           p_privilegio     IN VARCHAR2,
                           p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_privilegi_rapporti (p_id_documento   IN VARCHAR2,
                                    p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_privilegi_modifica (p_id_documento   IN VARCHAR2,
                                    p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_privilegi_allegati (p_id_documento   IN VARCHAR2,
                                    p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_privilegi_utente (p_utente         IN VARCHAR2,
                                  p_unita          IN VARCHAR2,
                                  p_id_documento   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_protocollanti (p_utente        IN VARCHAR2,
                                     p_utente_prot   IN VARCHAR2,
                                     p_data          IN VARCHAR2,
                                     p_stato_pr      IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_new_cr
      RETURN afc.t_ref_cursor;

   FUNCTION get_info_allegato (p_id_documento IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE ins_upd_oggetti_file (p_id_documento      IN NUMBER,
                                   p_id_oggetto_file   IN NUMBER,
                                   p_filename          IN VARCHAR2,
                                   p_utente            IN VARCHAR);

   PROCEDURE upd_oggetti_file (p_id_documento      IN NUMBER,
                               p_id_oggetto_file   IN NUMBER,
                               p_utente            IN VARCHAR);

   PROCEDURE ins_oggetti_file (p_id_documento   IN NUMBER,
                               p_filename       IN VARCHAR2,
                               p_utente         IN VARCHAR);

   FUNCTION get_allegati_mail (p_id_documento   IN NUMBER,
                               p_codice_amm     IN VARCHAR2,
                               p_codice_aoo     IN VARCHAR2,
                               p_idrif          IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_dati_oggetto_file (p_id_oggetto_file IN NUMBER)
      RETURN afc.t_ref_cursor;

   FUNCTION get_allegati (p_codice_amm   IN VARCHAR2,
                          p_codice_aoo   IN VARCHAR2,
                          p_idrif        IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_allegati_xml (p_codice_amm   IN VARCHAR2,
                              p_codice_aoo   IN VARCHAR2,
                              p_idrif        IN VARCHAR2)
      RETURN CLOB;

   FUNCTION get_tipi_allegati (p_codice_amm   IN VARCHAR2,
                               p_codice_aoo   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_unita_classificazione (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_class_cod    IN seg_unita_classifica.class_cod%TYPE)
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

   FUNCTION get_modalita_ricevimento (
      p_codice_amm                    IN VARCHAR2,
      p_codice_aoo                    IN VARCHAR2,
      p_id_documento                  IN VARCHAR2,
      p_documento_tramite             IN VARCHAR2,
      p_descrizione_mod_ricevimento   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_smistamenti_tipo_docu (
      p_codice_amm       IN VARCHAR2,
      p_codice_aoo       IN VARCHAR2,
      p_tipo_documento   IN seg_tipi_documento.tipo_documento%TYPE)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_documento (
      p_codice_amm                   IN VARCHAR2,
      p_codice_aoo                   IN VARCHAR2,
      p_descrizione_tipo_documento   IN seg_tipi_documento.descrizione_tipo_documento%TYPE,
      p_oggetto                      IN seg_tipi_documento.oggetto%TYPE,
      p_class_cod                    IN seg_classificazioni.class_cod%TYPE,
      p_fascicolo_anno               IN seg_fascicoli.fascicolo_anno%TYPE,
      p_fascicolo_numero             IN seg_fascicoli.fascicolo_numero%TYPE,
      p_utente                       IN VARCHAR2,
      p_id_documento                 IN VARCHAR2,
      p_tipo_registro                IN VARCHAR2,
      p_tipo_documento               IN VARCHAR2,
      p_modalita                     IN VARCHAR2,
      p_rispondi                     IN NUMBER DEFAULT 0,
      p_search_only_by_codice        IN NUMBER DEFAULT 0)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_frase (
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2,
      p_oggetto      IN seg_tipi_documento.oggetto%TYPE)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_movimento (p_codice_amm   IN VARCHAR2,
                                p_codice_aoo   IN VARCHAR2,
                                p_stato_pr     IN VARCHAR2,
                                p_utente       IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_tipi_registro (p_codice_amm      IN VARCHAR2,
                               p_codice_aoo      IN VARCHAR2,
                               p_tipo_registro   IN VARCHAR2 DEFAULT '%',
                               p_anno_reg        IN NUMBER DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION get_uffici_esibenti (p_data         IN VARCHAR2,
                                 p_stato_pr     IN VARCHAR2,
                                 p_codice_amm   IN VARCHAR2,
                                 p_codice_aoo   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_uffici_esibenti_tree (p_utente       IN ad4_utenti.utente%TYPE,
                                      p_codice_amm   IN VARCHAR2,
                                      p_codice_aoo   IN VARCHAR2)
      RETURN CLOB;

   FUNCTION check_protocollo_precedente (
      p_codice_amm      IN VARCHAR2,
      p_codice_aoo      IN VARCHAR2,
      p_prot_anno       IN proto_view.anno%TYPE,
      p_prot_numero     IN proto_view.numero%TYPE,
      p_tipo_registro   IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_rapporti_doc (p_id_documento    IN VARCHAR2,
                              p_tipo_rapporto   IN VARCHAR2 DEFAULT '%')
      RETURN CLOB;

   FUNCTION check_estremi_documento (
      p_data_documento     IN VARCHAR2,
      p_numero_documento   IN proto_view.numero_documento%TYPE,
      p_codice_amm         IN VARCHAR2,
      p_codice_aoo         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_rich_ann_rifiutate (
      p_codice_amm             IN VARCHAR2,
      p_codice_aoo             IN VARCHAR2,
      p_idrif                  IN seg_note.idrif%TYPE,
      p_data_rich_ann          IN VARCHAR2,
      p_nome_utente_rich_ann   IN seg_note.utente_richiesta_ann%TYPE,
      p_motivo_ann             IN seg_note.motivo_ann%TYPE,
      p_note                   IN seg_note.note%TYPE)
      RETURN afc.t_ref_cursor;

   FUNCTION exists_rich_ann_rif (p_codice_amm   IN VARCHAR2,
                                 p_codice_aoo   IN VARCHAR2,
                                 p_idrif        IN seg_note.idrif%TYPE)
      RETURN NUMBER;

   FUNCTION get_smistamenti (
      p_codice_amm                IN VARCHAR2,
      p_codice_aoo                IN VARCHAR2,
      p_idrif                     IN VARCHAR2,
      p_storici                   IN VARCHAR2,
      p_utente                    IN VARCHAR2,
      p_tipo_smistamento          IN ag_tipi_smistamento.tipo_smistamento%TYPE,
      p_des_uff_trasmissione      IN SEG_SMISTAMENTI.DES_UFFICIO_TRASMISSIONE%TYPE,
      p_den_utente_trasmissione   IN as4_anagrafe_soggetti.denominazione%TYPE,
      p_smistamento_dal           IN VARCHAR2,
      p_des_uff_smistamento       IN SEG_SMISTAMENTI.DES_UFFICIO_SMISTAMENTO%TYPE,
      p_den_utente_carico         IN as4_anagrafe_soggetti.denominazione%TYPE,
      p_presa_in_carico_dal       IN VARCHAR2,
      p_den_utente_assegnatario   IN as4_anagrafe_soggetti.denominazione%TYPE,
      p_assegnazione_dal          IN VARCHAR2,
      p_den_utente_esecuzione     IN as4_anagrafe_soggetti.denominazione%TYPE,
      p_data_esecuzione           IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_classificazioni_secondarie (p_id_documento   IN VARCHAR2,
                                            p_codice_amm     IN VARCHAR2,
                                            p_codice_aoo     IN VARCHAR2,
                                            p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_area_cm_cr (p_id_documento IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_documento (p_id_documento IN VARCHAR2, p_utente IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_empty_row (
      p_area      IN VARCHAR2 DEFAULT 'SEGRETERIA.PROTOCOLLO',
      p_modello   IN VARCHAR2 DEFAULT 'M_PROTOCOLLO',
      p_rowtag    IN VARCHAR2 DEFAULT 'ROW',
      p_table     IN VARCHAR2 DEFAULT 'PROTO_VIEW')
      RETURN CLOB;

   FUNCTION get_anagrafici (p_denominazione   IN VARCHAR2,
                            p_indirizzo       IN VARCHAR2 DEFAULT NULL,
                            p_cf              IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION get_anagrafici (
      p_qbe                           IN NUMBER DEFAULT 0,
      p_other_condition               IN VARCHAR2 DEFAULT NULL,
      p_order_by                      IN VARCHAR2 DEFAULT NULL,
      p_extra_columns                 IN VARCHAR2 DEFAULT NULL,
      p_extra_condition               IN VARCHAR2 DEFAULT NULL,
      p_denominazione                 IN VARCHAR2 DEFAULT NULL,
      p_email                         IN VARCHAR2 DEFAULT NULL,
      p_partita_iva                   IN VARCHAR2 DEFAULT NULL,
      p_cf                            IN VARCHAR2 DEFAULT NULL,
      p_pi                            IN VARCHAR2 DEFAULT NULL,
      p_indirizzo                     IN VARCHAR2 DEFAULT NULL,
      p_denominazione_per_segnatura   IN VARCHAR2 DEFAULT NULL,
      p_cognome_per_segnatura         IN VARCHAR2 DEFAULT NULL,
      p_nome_per_segnatura            IN VARCHAR2 DEFAULT NULL,
      p_indirizzo_per_segnatura       IN VARCHAR2 DEFAULT NULL,
      p_comune_per_segnatura          IN VARCHAR2 DEFAULT NULL,
      p_cap_per_segnatura             IN VARCHAR2 DEFAULT NULL,
      p_provincia_per_segnatura       IN VARCHAR2 DEFAULT NULL,
      p_cf_per_segnatura              IN VARCHAR2 DEFAULT NULL,
      p_ni_persona                    IN VARCHAR2 DEFAULT NULL,
      p_dal_persona                   IN VARCHAR2 DEFAULT NULL,
      p_ni                            IN VARCHAR2 DEFAULT NULL,
      p_cognome                       IN VARCHAR2 DEFAULT NULL,
      p_nome                          IN VARCHAR2 DEFAULT NULL,
      p_indirizzo_res                 IN VARCHAR2 DEFAULT NULL,
      p_cap_res                       IN VARCHAR2 DEFAULT NULL,
      p_comune_res                    IN VARCHAR2 DEFAULT NULL,
      p_provincia_res                 IN VARCHAR2 DEFAULT NULL,
      p_codice_fiscale                IN VARCHAR2 DEFAULT NULL,
      p_indirizzo_dom                 IN VARCHAR2 DEFAULT NULL,
      p_comune_dom                    IN VARCHAR2 DEFAULT NULL,
      p_cap_dom                       IN VARCHAR2 DEFAULT NULL,
      p_provincia_dom                 IN VARCHAR2 DEFAULT NULL,
      p_mail_persona                  IN VARCHAR2 DEFAULT NULL,
      p_tel_res                       IN VARCHAR2 DEFAULT NULL,
      p_fax_res                       IN VARCHAR2 DEFAULT NULL,
      p_sesso                         IN VARCHAR2 DEFAULT NULL,
      p_comune_nascita                IN VARCHAR2 DEFAULT NULL,
      p_data_nascita                  IN VARCHAR2 DEFAULT NULL,
      p_tel_dom                       IN VARCHAR2 DEFAULT NULL,
      p_fax_dom                       IN VARCHAR2 DEFAULT NULL,
      p_cf_nullable                   IN VARCHAR2 DEFAULT NULL,
      p_ammin                         IN VARCHAR2 DEFAULT NULL,
      p_descrizione_amm               IN VARCHAR2 DEFAULT NULL,
      p_aoo                           IN VARCHAR2 DEFAULT NULL,
      p_descrizione_aoo               IN VARCHAR2 DEFAULT NULL,
      p_cod_amm                       IN VARCHAR2 DEFAULT NULL,
      p_cod_aoo                       IN VARCHAR2 DEFAULT NULL,
      p_dati_amm                      IN VARCHAR2 DEFAULT NULL,
      p_dati_aoo                      IN VARCHAR2 DEFAULT NULL,
      p_ni_amm                        IN VARCHAR2 DEFAULT NULL,
      p_dal_amm                       IN VARCHAR2 DEFAULT NULL,
      p_tipo                          IN VARCHAR2 DEFAULT NULL,
      p_indirizzo_amm                 IN VARCHAR2 DEFAULT NULL,
      p_cap_amm                       IN VARCHAR2 DEFAULT NULL,
      p_comune_amm                    IN VARCHAR2 DEFAULT NULL,
      p_sigla_prov_amm                IN VARCHAR2 DEFAULT NULL,
      p_mail_amm                      IN VARCHAR2 DEFAULT NULL,
      p_indirizzo_aoo                 IN VARCHAR2 DEFAULT NULL,
      p_cap_aoo                       IN VARCHAR2 DEFAULT NULL,
      p_comune_aoo                    IN VARCHAR2 DEFAULT NULL,
      p_sigla_prov_aoo                IN VARCHAR2 DEFAULT NULL,
      p_mail_aoo                      IN VARCHAR2 DEFAULT NULL,
      p_cf_beneficiario               IN VARCHAR2 DEFAULT NULL,
      p_denominazione_beneficiario    IN VARCHAR2 DEFAULT NULL,
      p_pi_beneficiario               IN VARCHAR2 DEFAULT NULL,
      p_comune_beneficiario           IN VARCHAR2 DEFAULT NULL,
      p_indirizzo_beneficiario        IN VARCHAR2 DEFAULT NULL,
      p_cap_beneficiario              IN VARCHAR2 DEFAULT NULL,
      p_data_nascita_beneficiario     IN VARCHAR2 DEFAULT NULL,
      p_provincia_beneficiario        IN VARCHAR2 DEFAULT NULL,
      p_vis_indirizzo                 IN VARCHAR2 DEFAULT NULL,
      p_ni_impresa                    IN VARCHAR2 DEFAULT NULL,
      p_impresa                       IN VARCHAR2 DEFAULT NULL,
      p_denominazione_sede            IN VARCHAR2 DEFAULT NULL,
      p_natura_giuridica              IN VARCHAR2 DEFAULT NULL,
      p_insegna                       IN VARCHAR2 DEFAULT NULL,
      p_c_fiscale_impresa             IN VARCHAR2 DEFAULT NULL,
      p_partita_iva_impresa           IN VARCHAR2 DEFAULT NULL,
      p_tipo_localizzazione           IN VARCHAR2 DEFAULT NULL,
      p_comune                        IN VARCHAR2 DEFAULT NULL,
      p_c_via_impresa                 IN VARCHAR2 DEFAULT NULL,
      p_via_impresa                   IN VARCHAR2 DEFAULT NULL,
      p_n_civico_impresa              IN VARCHAR2 DEFAULT NULL,
      p_comune_impresa                IN VARCHAR2 DEFAULT NULL,
      p_cap_impresa                   IN VARCHAR2 DEFAULT NULL,
      p_com_nascita                   IN VARCHAR2 DEFAULT NULL,
      p_cf_persona                    IN VARCHAR2 DEFAULT NULL,
      p_cognome_impresa               IN VARCHAR2 DEFAULT NULL,
      p_nome_impresa                  IN VARCHAR2 DEFAULT NULL,
      p_cfp                           IN VARCHAR2 DEFAULT NULL,
      p_anagrafica                    IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION get_preferenze_standard (p_modulo   IN VARCHAR2,
                                     p_utente   IN VARCHAR2,
                                     p_area     IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_preferenza_utente (p_modulo       IN VARCHAR2,
                                   p_utente       IN VARCHAR2,
                                   p_preferenza   IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_preferenze_utente (p_codice_amm   IN VARCHAR2,
                                   p_codice_aoo   IN VARCHAR2,
                                   p_modulo       IN VARCHAR2,
                                   p_utente       IN VARCHAR2,
                                   p_preferenza   IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION get_valori_preferenza_utente (p_codice_amm   IN VARCHAR2,
                                          p_codice_aoo   IN VARCHAR2,
                                          p_modulo       IN VARCHAR2,
                                          p_utente       IN VARCHAR2,
                                          p_preferenza   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_log_nome_campo
      RETURN afc.t_ref_cursor;

   FUNCTION ricerca_soggetti (
      p_ricerca         IN VARCHAR2,
      p_isquery         IN VARCHAR2,
      p_denominazione   IN VARCHAR2,
      p_indirizzo       IN VARCHAR2,
      p_cf              IN VARCHAR2,
      p_pi              IN VARCHAR2,
      p_email           IN VARCHAR2,
      p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto   IN NUMBER DEFAULT -1)
      RETURN afc.t_ref_cursor;

   FUNCTION check_firma_doc_princ (p_codice_amm     IN VARCHAR2,
                                   p_codice_aoo     IN VARCHAR2,
                                   p_id_documento   IN NUMBER)
      RETURN NUMBER;

   FUNCTION check_change_firma (
      p_codice_amm           IN VARCHAR2,
      p_codice_aoo           IN VARCHAR2,
      p_modalita             IN VARCHAR2,
      p_id_documento         IN NUMBER,
      p_in_protocollazione   IN NUMBER DEFAULT 0,
      p_filename             IN VARCHAR2 DEFAULT '',
      p_id_allegato          IN NUMBER DEFAULT '')
      RETURN NUMBER;

   FUNCTION check_doc_da_firmare (p_codice_amm           IN VARCHAR2,
                                  p_codice_aoo           IN VARCHAR2,
                                  p_id_documento         IN NUMBER,
                                  p_modalita             IN VARCHAR2,
                                  p_stato_pr             IN VARCHAR2,
                                  p_in_protocollazione   IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION delete_oggetto_file (p_codice_amm           IN VARCHAR2,
                                 p_codice_aoo           IN VARCHAR2,
                                 p_utente               IN VARCHAR2,
                                 p_data_aggiornamento   IN VARCHAR2,
                                 p_id_documento         IN NUMBER,
                                 p_id_oggetto_file      IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE aggiorna_ultima_modifica (p_id_documento   IN VARCHAR2,
                                       p_utente         IN VARCHAR2);

   FUNCTION insert_allegati_file (p_area                 IN VARCHAR2,
                                  p_cm                   IN VARCHAR2,
                                  p_cr                   IN VARCHAR2,
                                  p_filename             IN VARCHAR2,
                                  p_data_aggiornamento      VARCHAR2,
                                  p_id_documento         IN NUMBER,
                                  p_id_allegato          IN NUMBER,
                                  p_utente                  VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION delete_allegati_file (p_area                 IN VARCHAR2,
                                  p_cm                   IN VARCHAR2,
                                  p_cr                   IN VARCHAR2,
                                  p_filename             IN VARCHAR2,
                                  p_data_aggiornamento      VARCHAR2,
                                  p_id_documento         IN NUMBER,
                                  p_id_allegato          IN NUMBER,
                                  p_utente                  VARCHAR2,
                                  p_id_oggetto_file      IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_allegati_temp (p_area     IN VARCHAR2,
                               p_cm       IN VARCHAR2,
                               p_cr       IN VARCHAR2,
                               p_utente   IN VARCHAR)
      RETURN afc.t_ref_cursor;

   FUNCTION get_allegati_maxfilesize (p_area      IN VARCHAR2,
                                      p_modello   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_allegati (p_id_documento   IN VARCHAR2,
                          p_area           IN VARCHAR2,
                          p_cm             IN VARCHAR2,
                          p_cr             IN VARCHAR2,
                          p_estrai_temp    IN NUMBER,
                          p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE copia_allegati_temp (p_area          IN VARCHAR2,
                                  p_cm            IN VARCHAR2,
                                  p_cr            IN VARCHAR2,
                                  p_utente        IN VARCHAR2,
                                  p_id_allegato   IN VARCHAR2);

   PROCEDURE update_allegati_file (p_area                 IN VARCHAR2,
                                   p_cm                   IN VARCHAR2,
                                   p_cr                   IN VARCHAR2,
                                   p_filename             IN VARCHAR2,
                                   p_filename_old         IN VARCHAR2,
                                   p_data_aggiornamento      VARCHAR2,
                                   p_id_documento         IN NUMBER,
                                   p_id_allegato          IN NUMBER);

   FUNCTION get_id_oggetto_file (p_id_documento IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_tag_mail (p_codice_amm     IN VARCHAR2,
                          p_codice_aoo     IN VARCHAR2,
                          p_id_documento   IN NUMBER,
                          p_utente         IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_tag_email_mittente (p_codice_amm     IN VARCHAR2,
                                    p_codice_aoo     IN VARCHAR2,
                                    p_id_documento   IN NUMBER,
                                    p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   PROCEDURE aggiorna_mittente (p_codice_amm     IN VARCHAR2,
                                p_codice_aoo     IN VARCHAR2,
                                p_id_documento   IN NUMBER,
                                p_utente         IN VARCHAR2,
                                p_tag_mail       IN VARCHAR2,
                                p_email          IN VARCHAR2,
                                p_tipo           IN VARCHAR2);

   PROCEDURE aggiorna_mittente_commit (p_codice_amm     IN VARCHAR2,
                                       p_codice_aoo     IN VARCHAR2,
                                       p_id_documento   IN NUMBER,
                                       p_utente         IN VARCHAR2,
                                       p_tag_mail       IN VARCHAR2,
                                       p_email          IN VARCHAR2,
                                       p_tipo           IN VARCHAR2);

   PROCEDURE aggiorna_mittente (p_codice_amm     IN VARCHAR2,
                                p_codice_aoo     IN VARCHAR2,
                                p_id_documento   IN NUMBER,
                                p_utente         IN VARCHAR2,
                                p_tipo           IN VARCHAR2,
                                p_email          IN VARCHAR2 DEFAULT NULL);

   PROCEDURE aggiorna_mittente_commit (
      p_codice_amm     IN VARCHAR2,
      p_codice_aoo     IN VARCHAR2,
      p_id_documento   IN NUMBER,
      p_utente         IN VARCHAR2,
      p_tipo           IN VARCHAR2,
      p_email          IN VARCHAR2 DEFAULT NULL);

   FUNCTION get_tagmail_indirizzo (p_id_documento   IN NUMBER,
                                   p_utente         IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE insert_allegati_temp (p_area       IN VARCHAR2,
                                   p_cm         IN VARCHAR2,
                                   p_cr         IN VARCHAR2,
                                   p_filename   IN VARCHAR2,
                                   p_utente        VARCHAR2);

   PROCEDURE upd_ver_firma (p_id_documento    VARCHAR2,
                            p_esito           VARCHAR2,
                            p_data            VARCHAR2);

   FUNCTION get_tipi_soggetto
      RETURN afc.t_ref_cursor;

   FUNCTION get_tag_fax_mittente (p_codice_amm     IN VARCHAR2,
                                  p_codice_aoo     IN VARCHAR2,
                                  p_id_documento   IN NUMBER,
                                  p_utente         IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION ricongiungi_a_fascicolo (p_area      VARCHAR2,
                                     p_cm        VARCHAR2,
                                     p_cr        VARCHAR2,
                                     p_utente    VARCHAR2,
                                     p_unita     VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE set_stato_firma (p_id_documento NUMBER, p_stato_firma VARCHAR2);

   PROCEDURE notifica_ins_fasc (p_id_documento VARCHAR2);

   FUNCTION calcola_icona (p_idrif_documento    VARCHAR2,
                           p_id_cartella        NUMBER,
                           p_icona_default      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION exists_mancata_consegna (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION exists_consegna (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION exists_conferma (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION exists_eccezione (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION exists_annullamento (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION is_in_fasc_riservato (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION is_dest_messaggio (p_tipo_messaggio    VARCHAR2,
                               p_id_documento      NUMBER,
                               p_recapito          VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION check_modificati_dettagli (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION has_smistamenti_attivi_fasc (p_codice_amm         IN VARCHAR2,
                                         p_codice_aoo         IN VARCHAR2,
                                         p_class_cod          IN VARCHAR2,
                                         p_class_dal          IN VARCHAR2,
                                         p_fascicolo_anno     IN VARCHAR2,
                                         p_fascicolo_numero   IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_messaggio_inviato (p_tipo_messaggio    VARCHAR2,
                                  p_id_documento      NUMBER)
      RETURN VARCHAR2;

   FUNCTION check_prendi_in_carico_barcode (p_bc       IN VARCHAR2,
                                            p_utente   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_url (p_id_documento NUMBER, p_read_write VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_url (p_anno               NUMBER,
                     p_tipo_registro      VARCHAR2,
                     p_numero             NUMBER,
                     p_codice_amm      IN VARCHAR2,
                     p_codice_aoo      IN VARCHAR2,
                     p_read_write         VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE delete_from_titolario (p_id_documento        NUMBER,
                                    p_class_cod           VARCHAR2,
                                    p_class_dal           VARCHAR2,
                                    p_fascicolo_anno      NUMBER,
                                    p_fascicolo_numero    VARCHAR2,
                                    p_codice_amm          VARCHAR2,
                                    p_codice_aoo          VARCHAR2);

   FUNCTION count_oggetti_file (p_id_documento NUMBER)
      RETURN NUMBER;

   PROCEDURE separa_gli_allegati (p_id_documento       NUMBER,
                                  p_nome_file_princ    VARCHAR2,
                                  p_utente             VARCHAR2);

   FUNCTION crea_rapporto (p_id_padre                       NUMBER,
                           P_ANNO                           NUMBER,
                           P_CAP_AMM                        VARCHAR2,
                           P_CAP_AOO                        VARCHAR2,
                           P_CAP_DOM                        VARCHAR2,
                           P_CAP_DOM_DIPENDENTE             VARCHAR2,
                           P_CAP_IMPRESA                    VARCHAR2,
                           P_CAP_IMPRESA_EXTRA              VARCHAR2,
                           P_CAP_PER_SEGNATURA              VARCHAR2,
                           P_CAP_RES                        VARCHAR2,
                           P_CAP_RES_DIPENDENTE             VARCHAR2,
                           P_CFP_EXTRA                      VARCHAR2,
                           P_CF_PER_SEGNATURA               VARCHAR2,
                           P_CODICE_AMM                     VARCHAR2,
                           P_CODICE_AOO                     VARCHAR2,
                           P_CODICE_FISCALE                 VARCHAR2,
                           P_CODICE_FISCALE_DIPENDENTE      VARCHAR2,
                           P_COD_AMM                        VARCHAR2,
                           P_COD_AOO                        VARCHAR2,
                           P_COD_UO                         VARCHAR2,
                           P_COGNOME                        VARCHAR2,
                           P_COGNOME_DIPENDENTE             VARCHAR2,
                           P_COGNOME_IMPRESA_EXTRA          VARCHAR2,
                           P_COGNOME_PER_SEGNATURA          VARCHAR2,
                           P_COMUNE_AMM                     VARCHAR2,
                           P_COMUNE_AOO                     VARCHAR2,
                           P_COMUNE_DOM                     VARCHAR2,
                           P_COMUNE_DOM_DIPENDENTE          VARCHAR2,
                           P_COMUNE_IMPRESA                 VARCHAR2,
                           P_COMUNE_IMPRESA_EXTRA           VARCHAR2,
                           P_COMUNE_NASCITA                 VARCHAR2,
                           P_COMUNE_NASCITA_EXTRA           VARCHAR2,
                           P_COMUNE_PER_SEGNATURA           VARCHAR2,
                           P_COMUNE_RES                     VARCHAR2,
                           P_COMUNE_RES_DIPENDENTE          VARCHAR2,
                           P_C_FISCALE_IMPRESA              VARCHAR2,
                           P_C_FISCALE_IMPRESA_EXTRA        VARCHAR2,
                           P_C_VIA_IMPRESA                  VARCHAR2,
                           P_C_VIA_IMPRESA_EXTRA            VARCHAR2,
                           P_DAL                            VARCHAR2,
                           P_DAL_AMM                        VARCHAR2,
                           P_DAL_DIPENDENTE                 VARCHAR2,
                           P_DAL_PERSONA                    VARCHAR2,
                           P_DATA_NASCITA                   VARCHAR2,
                           P_DATA_NASCITA_EXTRA             VARCHAR2,
                           P_DENOMINAZIONE_PER_SEGNATURA    VARCHAR2,
                           P_DENOMINAZIONE_SEDE             VARCHAR2,
                           P_DENOMINAZIONE_SEDE_EXTRA       VARCHAR2,
                           P_DESCRIZIONE_AMM                VARCHAR2,
                           P_DESCRIZIONE_AOO                VARCHAR2,
                           P_DESCRIZIONE_INCARICO           VARCHAR2,
                           P_DESCRIZIONE_UO                 VARCHAR2,
                           P_DESC_TIPO_RAPPORTO             VARCHAR2,
                           P_EMAIL                          VARCHAR2,
                           P_FAX_DOM                        VARCHAR2,
                           P_FAX_RES                        VARCHAR2,
                           P_IDRIF                          VARCHAR2,
                           P_INDIRIZZO_AMM                  VARCHAR2,
                           P_INDIRIZZO_AOO                  VARCHAR2,
                           P_INDIRIZZO_DOM                  VARCHAR2,
                           P_INDIRIZZO_DOM_DIPENDENTE       VARCHAR2,
                           P_INDIRIZZO_PER_SEGNATURA        VARCHAR2,
                           P_INDIRIZZO_RES                  VARCHAR2,
                           P_INDIRIZZO_RES_DIPENDENTE       VARCHAR2,
                           P_INSEGNA                        VARCHAR2,
                           P_INSEGNA_EXTRA                  VARCHAR2,
                           P_MAIL_AMM                       VARCHAR2,
                           P_MAIL_AOO                       VARCHAR2,
                           P_MAIL_DIPENDENTE                VARCHAR2,
                           P_MAIL_PERSONA                   VARCHAR2,
                           P_NATURA_GIURIDICA               VARCHAR2,
                           P_NATURA_GIURIDICA_EXTRA         VARCHAR2,
                           P_NI                             VARCHAR2,
                           P_NI_AMM                         VARCHAR2,
                           P_NI_DIPENDENTE                  VARCHAR2,
                           P_NI_IMPRESA                     VARCHAR2,
                           P_NI_IMPRESA_EXTRA               VARCHAR2,
                           P_NI_PERSONA                     VARCHAR2,
                           P_NOME                           VARCHAR2,
                           P_NOME_DIPENDENTE                VARCHAR2,
                           P_NOME_IMPRESA_EXTRA             VARCHAR2,
                           P_NOME_PER_SEGNATURA             VARCHAR2,
                           P_NOMINATIVO_COMPONENTE          VARCHAR2,
                           P_NUMERO                         NUMBER,
                           P_N_CIVICO_IMPRESA               VARCHAR2,
                           P_N_CIVICO_IMPRESA_EXTRA         VARCHAR2,
                           P_PARENT_URL                     CLOB,
                           P_PARTITA_IVA_IMPRESA            VARCHAR2,
                           P_PARTITA_IVA_IMPRESA_EXTRA      VARCHAR2,
                           P_PROVINCIA_DOM                  VARCHAR2,
                           P_PROVINCIA_DOM_DIPENDENTE       VARCHAR2,
                           P_PROVINCIA_PER_SEGNATURA        VARCHAR2,
                           P_PROVINCIA_RES                  VARCHAR2,
                           P_PROVINCIA_RES_DIPENDENTE       VARCHAR2,
                           P_SESSO                          VARCHAR2,
                           P_SIGLA_PROV_AMM                 VARCHAR2,
                           P_SIGLA_PROV_AOO                 VARCHAR2,
                           P_TEL_DOM                        VARCHAR2,
                           P_TEL_RES                        VARCHAR2,
                           P_TIPO                           VARCHAR2,
                           P_TIPO_LOCALIZZAZIONE            VARCHAR2,
                           P_TIPO_LOCALIZZAZIONE_EXTRA      VARCHAR2,
                           P_TIPO_RAPPORTO                  VARCHAR2,
                           P_TIPO_REGISTRO                  VARCHAR2,
                           P_TIPO_SOGGETTO                  VARCHAR2,
                           P_VIA_IMPRESA                    VARCHAR2,
                           P_VIA_IMPRESA_EXTRA              VARCHAR2,
                           P_FULL_TEXT                      CLOB,
                           P_TXT                            VARCHAR2,
                           P_MODINVIO                       VARCHAR2,
                           P_PARTITA_IVA                    VARCHAR2,
                           P_CFP                            VARCHAR2,
                           P_COGNOME_IMPRESA                VARCHAR2,
                           P_NOME_IMPRESA                   VARCHAR2,
                           P_DESCRIZIONE                    VARCHAR2,
                           P_DOCUMENTO_TRAMITE              VARCHAR2,
                           P_ID_LISTA_DISTRIBUZIONE         VARCHAR2,
                           P_MODALITA                       VARCHAR2,
                           P_STATO_PR                       VARCHAR2,
                           P_CF_NULLABLE                    VARCHAR2,
                           P_RACCOMANDATA_NUMERO            VARCHAR2,
                           P_CAP_BENEFICIARIO               VARCHAR2,
                           P_CF_BENEFICIARIO                VARCHAR2,
                           P_COMUNE_BENEFICIARIO            VARCHAR2,
                           P_DATA_NASCITA_BENEFICIARIO      VARCHAR2,
                           P_DENOMINAZIONE_BENEFICIARIO     VARCHAR2,
                           P_INDIRIZZO_BENEFICIARIO         VARCHAR2,
                           P_PI_BENEFICIARIO                VARCHAR2,
                           P_PROVINCIA_BENEFICIARIO         VARCHAR2,
                           P_MAIL_IMPRESA                   VARCHAR2,
                           P_CAP_UO                         VARCHAR2,
                           P_COMUNE_UO                      VARCHAR2,
                           P_FAX_UO                         VARCHAR2,
                           P_INDIRIZZO_UO                   VARCHAR2,
                           P_MAIL_UO                        VARCHAR2,
                           P_SIGLA_PROV_UO                  VARCHAR2,
                           P_TEL_UO                         VARCHAR2,
                           P_DATA_SPED                      VARCHAR2,
                           P_DOCUMENTO_TRAMITE_FORM         VARCHAR2,
                           P_FAX                            VARCHAR2,
                           P_FAX_AMM                        VARCHAR2,
                           P_FAX_AOO                        VARCHAR2,
                           P_FAX_BENEFICIARIO               VARCHAR2,
                           P_MAIL_BENEFICIARIO              VARCHAR2,
                           P_QUANTITA                       NUMBER,
                           P_BC_SPEDIZIONE                  VARCHAR2,
                           P_CONOSCENZA                     VARCHAR2,
                           p_utente                         VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_rapp_duplicato (p_idrif                          VARCHAR2,
                               p_tipo_soggetto                  NUMBER,
                               p_denominazione_per_segnatura    VARCHAR2,
                               p_cognome                        VARCHAR2,
                               p_nome                           VARCHAR2,
                               p_codice_fiscale                 VARCHAR2,
                               p_partita_iva                    VARCHAR2,
                               p_partita_iva_impresa            VARCHAR2,
                               p_cod_amm                        VARCHAR2,
                               p_cod_aoo                        VARCHAR2,
                               p_cod_uo                         VARCHAR2,
                               p_ni                             NUMBER,
                               p_indirizzo_per_segnatura        VARCHAR2,
                               p_cap_per_segnatura              VARCHAR2,
                               p_comune_per_segnatura           VARCHAR2,
                               p_provincia_per_segnatura        VARCHAR2,
                               p_email                          VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION crea_rapporto_e_termina (
      P_ID_PADRE                       NUMBER,
      P_ANNO                           NUMBER,
      P_CAP_AMM                        VARCHAR2,
      P_CAP_AOO                        VARCHAR2,
      P_CAP_DOM                        VARCHAR2,
      P_CAP_DOM_DIPENDENTE             VARCHAR2,
      P_CAP_IMPRESA                    VARCHAR2,
      P_CAP_IMPRESA_EXTRA              VARCHAR2,
      P_CAP_PER_SEGNATURA              VARCHAR2,
      P_CAP_RES                        VARCHAR2,
      P_CAP_RES_DIPENDENTE             VARCHAR2,
      P_CFP_EXTRA                      VARCHAR2,
      P_CF_PER_SEGNATURA               VARCHAR2,
      P_CODICE_AMM                     VARCHAR2,
      P_CODICE_AOO                     VARCHAR2,
      P_CODICE_FISCALE                 VARCHAR2,
      P_CODICE_FISCALE_DIPENDENTE      VARCHAR2,
      P_COD_AMM                        VARCHAR2,
      P_COD_AOO                        VARCHAR2,
      P_COD_UO                         VARCHAR2,
      P_COGNOME                        VARCHAR2,
      P_COGNOME_DIPENDENTE             VARCHAR2,
      P_COGNOME_IMPRESA_EXTRA          VARCHAR2,
      P_COGNOME_PER_SEGNATURA          VARCHAR2,
      P_COMUNE_AMM                     VARCHAR2,
      P_COMUNE_AOO                     VARCHAR2,
      P_COMUNE_DOM                     VARCHAR2,
      P_COMUNE_DOM_DIPENDENTE          VARCHAR2,
      P_COMUNE_IMPRESA                 VARCHAR2,
      P_COMUNE_IMPRESA_EXTRA           VARCHAR2,
      P_COMUNE_NASCITA                 VARCHAR2,
      P_COMUNE_NASCITA_EXTRA           VARCHAR2,
      P_COMUNE_PER_SEGNATURA           VARCHAR2,
      P_COMUNE_RES                     VARCHAR2,
      P_COMUNE_RES_DIPENDENTE          VARCHAR2,
      P_C_FISCALE_IMPRESA              VARCHAR2,
      P_C_FISCALE_IMPRESA_EXTRA        VARCHAR2,
      P_C_VIA_IMPRESA                  VARCHAR2,
      P_C_VIA_IMPRESA_EXTRA            VARCHAR2,
      P_DAL                            VARCHAR2,
      P_DAL_AMM                        VARCHAR2,
      P_DAL_DIPENDENTE                 VARCHAR2,
      P_DAL_PERSONA                    VARCHAR2,
      P_DATA_NASCITA                   VARCHAR2,
      P_DATA_NASCITA_EXTRA             VARCHAR2,
      P_DENOMINAZIONE_PER_SEGNATURA    VARCHAR2,
      P_DENOMINAZIONE_SEDE             VARCHAR2,
      P_DENOMINAZIONE_SEDE_EXTRA       VARCHAR2,
      P_DESCRIZIONE_AMM                VARCHAR2,
      P_DESCRIZIONE_AOO                VARCHAR2,
      P_DESCRIZIONE_INCARICO           VARCHAR2,
      P_DESCRIZIONE_UO                 VARCHAR2,
      P_DESC_TIPO_RAPPORTO             VARCHAR2,
      P_EMAIL                          VARCHAR2,
      P_FAX_DOM                        VARCHAR2,
      P_FAX_RES                        VARCHAR2,
      P_IDRIF                          VARCHAR2,
      P_INDIRIZZO_AMM                  VARCHAR2,
      P_INDIRIZZO_AOO                  VARCHAR2,
      P_INDIRIZZO_DOM                  VARCHAR2,
      P_INDIRIZZO_DOM_DIPENDENTE       VARCHAR2,
      P_INDIRIZZO_PER_SEGNATURA        VARCHAR2,
      P_INDIRIZZO_RES                  VARCHAR2,
      P_INDIRIZZO_RES_DIPENDENTE       VARCHAR2,
      P_INSEGNA                        VARCHAR2,
      P_INSEGNA_EXTRA                  VARCHAR2,
      P_MAIL_AMM                       VARCHAR2,
      P_MAIL_AOO                       VARCHAR2,
      P_MAIL_DIPENDENTE                VARCHAR2,
      P_MAIL_PERSONA                   VARCHAR2,
      P_NATURA_GIURIDICA               VARCHAR2,
      P_NATURA_GIURIDICA_EXTRA         VARCHAR2,
      P_NI                             VARCHAR2,
      P_NI_AMM                         VARCHAR2,
      P_NI_DIPENDENTE                  VARCHAR2,
      P_NI_IMPRESA                     VARCHAR2,
      P_NI_IMPRESA_EXTRA               VARCHAR2,
      P_NI_PERSONA                     VARCHAR2,
      P_NOME                           VARCHAR2,
      P_NOME_DIPENDENTE                VARCHAR2,
      P_NOME_IMPRESA_EXTRA             VARCHAR2,
      P_NOME_PER_SEGNATURA             VARCHAR2,
      P_NOMINATIVO_COMPONENTE          VARCHAR2,
      P_NUMERO                         NUMBER,
      P_N_CIVICO_IMPRESA               VARCHAR2,
      P_N_CIVICO_IMPRESA_EXTRA         VARCHAR2,
      P_PARENT_URL                     CLOB,
      P_PARTITA_IVA_IMPRESA            VARCHAR2,
      P_PARTITA_IVA_IMPRESA_EXTRA      VARCHAR2,
      P_PROVINCIA_DOM                  VARCHAR2,
      P_PROVINCIA_DOM_DIPENDENTE       VARCHAR2,
      P_PROVINCIA_PER_SEGNATURA        VARCHAR2,
      P_PROVINCIA_RES                  VARCHAR2,
      P_PROVINCIA_RES_DIPENDENTE       VARCHAR2,
      P_SESSO                          VARCHAR2,
      P_SIGLA_PROV_AMM                 VARCHAR2,
      P_SIGLA_PROV_AOO                 VARCHAR2,
      P_TEL_DOM                        VARCHAR2,
      P_TEL_RES                        VARCHAR2,
      P_TIPO                           VARCHAR2,
      P_TIPO_LOCALIZZAZIONE            VARCHAR2,
      P_TIPO_LOCALIZZAZIONE_EXTRA      VARCHAR2,
      P_TIPO_RAPPORTO                  VARCHAR2,
      P_TIPO_REGISTRO                  VARCHAR2,
      P_TIPO_SOGGETTO                  VARCHAR2,
      P_VIA_IMPRESA                    VARCHAR2,
      P_VIA_IMPRESA_EXTRA              VARCHAR2,
      P_FULL_TEXT                      CLOB,
      P_TXT                            VARCHAR2,
      P_MODINVIO                       VARCHAR2,
      P_PARTITA_IVA                    VARCHAR2,
      P_CFP                            VARCHAR2,
      P_COGNOME_IMPRESA                VARCHAR2,
      P_NOME_IMPRESA                   VARCHAR2,
      P_DESCRIZIONE                    VARCHAR2,
      P_DOCUMENTO_TRAMITE              VARCHAR2,
      P_ID_LISTA_DISTRIBUZIONE         VARCHAR2,
      P_MODALITA                       VARCHAR2,
      P_STATO_PR                       VARCHAR2,
      P_CF_NULLABLE                    VARCHAR2,
      P_RACCOMANDATA_NUMERO            VARCHAR2,
      P_CAP_BENEFICIARIO               VARCHAR2,
      P_CF_BENEFICIARIO                VARCHAR2,
      P_COMUNE_BENEFICIARIO            VARCHAR2,
      P_DATA_NASCITA_BENEFICIARIO      VARCHAR2,
      P_DENOMINAZIONE_BENEFICIARIO     VARCHAR2,
      P_INDIRIZZO_BENEFICIARIO         VARCHAR2,
      P_PI_BENEFICIARIO                VARCHAR2,
      P_PROVINCIA_BENEFICIARIO         VARCHAR2,
      P_MAIL_IMPRESA                   VARCHAR2,
      P_CAP_UO                         VARCHAR2,
      P_COMUNE_UO                      VARCHAR2,
      P_FAX_UO                         VARCHAR2,
      P_INDIRIZZO_UO                   VARCHAR2,
      P_MAIL_UO                        VARCHAR2,
      P_SIGLA_PROV_UO                  VARCHAR2,
      P_TEL_UO                         VARCHAR2,
      P_DATA_SPED                      VARCHAR2,
      P_DOCUMENTO_TRAMITE_FORM         VARCHAR2,
      P_FAX                            VARCHAR2,
      P_FAX_AMM                        VARCHAR2,
      P_FAX_AOO                        VARCHAR2,
      P_FAX_BENEFICIARIO               VARCHAR2,
      P_MAIL_BENEFICIARIO              VARCHAR2,
      P_QUANTITA                       NUMBER,
      P_BC_SPEDIZIONE                  VARCHAR2,
      P_CONOSCENZA                     VARCHAR2,
      p_utente                         VARCHAR2)
      RETURN VARCHAR2;


   FUNCTION crea_smistamento_e_termina (p_id_padre                  NUMBER,
                                        p_idrif                     VARCHAR2,
                                        p_smistamento_dal           VARCHAR2,
                                        p_tree_unita_assegnatari    VARCHAR2,
                                        p_ufficio_trasmissione      VARCHAR2,
                                        p_unita_protocollante       VARCHAR2,
                                        p_stato_pr                  VARCHAR2,
                                        p_tipo_smistamento          VARCHAR2,
                                        p_codice_amm                VARCHAR2,
                                        p_codice_aoo                VARCHAR2,
                                        p_utente                    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION crea_smistamento (p_id_padre                  NUMBER,
                              p_idrif                     VARCHAR2,
                              p_smistamento_dal           DATE,
                              p_ufficio_smistamento       VARCHAR2,
                              p_ufficio_trasmissione      VARCHAR2,
                              p_assegnatario              VARCHAR2,
                              p_assegnazione_dal          DATE,
                              p_tipo_smistamento          VARCHAR2,
                              p_note                      VARCHAR2,
                              p_stato_smistamento         VARCHAR2,
                              p_codice_amministrazione    VARCHAR2,
                              p_codice_aoo                VARCHAR2,
                              p_utente                    VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_stream_memo_protocollo (p_id_documento IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_file_protocollo (p_id_documento   IN VARCHAR2,
                                 p_codice_amm     IN VARCHAR2,
                                 p_codice_aoo     IN VARCHAR2,
                                 p_idrif          IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION exists_risposta_successiva (p_id_documento IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_tipi_consegna (p_codice_amm   IN VARCHAR2,
                               p_codice_aoo   IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION GET_URL_ANAGRAFICA
      RETURN afc.t_ref_cursor;

   FUNCTION is_risposta_accesso_civico (p_id_documento IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION verifica_gestione_anagrafica (
      p_utente       IN ad4_utenti.utente%TYPE,
      p_codice_amm   IN VARCHAR2,
      p_codice_aoo   IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_protocollo_agspr (p_id_documento          VARCHAR2,
                                   p_utente                VARCHAR2,
                                   p_id_tipo_protocollo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION IS_PROTOCOLLATO (p_id_documento NUMBER)
      RETURN NUMBER;

       FUNCTION crea_doc_titolario_agspr (p_id_documento          VARCHAR2,
                                                                   p_id_documento_titolario          VARCHAR2,
                                                                   p_tipo_fascicolo          VARCHAR2,
                                   p_utente                VARCHAR2)
      RETURN VARCHAR2;

END ag_documento_utility;
/
CREATE OR REPLACE PACKAGE BODY ag_documento_utility
 IS
    /******************************************************************************
     NOME:        AG_DOCUMENTO_UTILITY
     DESCRIZIONE: Procedure e Funzioni di utility in fase di
                  inserimento/aggiornamento documento.
     ANNOTAZIONI: Progetto AFFARI_GENERALI.
     REVISIONI: Le rev > 100 sono quelle apportate in Versione 3.5 o successiva
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  09/07/2009  MM     Creazione.
    001  24/01/2012  MM     ricerca_soggetti: Gestione carattere % all'inizio della
                            stringa di ricerca.
    002  16/05/2012  MM     Modifiche versione 2.1.
    003  03/10/2013  MM     Modifiche versione 2.2.
    004  26/03/2014  MM     Modificata get_tag_email_mittente.
    005  18/11/2014  MM     Modificata get_uni_iter_select
    006  14/08/2015  MM     Modificate check_protocollo_precedente e get_url per
                            gestione tipo registro di default.
         20/08/2015  MM     Modificata check_permessi_accesso per gestione
                            allegati riservati.
         25/08/2015  MM     Creata delete_from_titolario
    007  01/03/2016  MM     Modificata check_permessi_accesso per gestione da dettaglio
    008  07/10/2016  MM     Modificata get_tipi_documento per escludere il tipo di
                            documento associata alla stampa giornaliera del registro.
    009  16/11/2016  MM     Create separa_gli_allegati e count_oggetti_file
    010  07/12/2016  MM     Create crea_smistamento, crea_smistamento_e_termina,
                            crea_smistamenti, scomponi_unita_ricevente,
                            is_rapp_duplicato, crea_rapporto e crea_rapporto_e_termina.
    011  07/03/2017  MM     V2.7
         26/04/2017  SC     ALLINEATO ALLO STANDARD
    012  25/09/2017  MM     Modificate aggiorna_mittente, aggiorna_mittente_commit
                            e creata get_file_protocollo.
    013  07/04/2017  SC     Modificate CHECK_PERMESSI_ACCESSO, GET_UNITA_ANNULLAMENTI
                            GET_PROVENIENZA_DOCUMENTO, GET_PRIVILEGI_UTENTE,
                            get_uni_prot_select, GET_TAG_EMAIL_MITTENTE, get_tagmail_indirizzo
    014  29/09/2017  MM     Modificata get_tipi_documento e creata exists_risposta_successiva
    014a 17/10/2017  MM     Modificate crea_smistamento e crea_smistamenti per
                            eliminare dal check gli smistamenti cancellati.
    014b 25/10/2017  MM     Modificata separa_gli_allegati per errore in salvataggio
                            su fs.
    015  25/10/2017  MM     Modificata GET_SMISTAMENTI_TIPO_DOCU
    016  26/10/2017  SC     Modificata GET_TAG_EMAIL_MITTENTE, creta get_tipi_consegna
    017  14/12/2017  MM     Creata GET_URL_ANAGRAFICA
    018  18/12/2017  MM     Modificata get_tipi_documento
    019  08/01/2018  MM     Modificata get_tipi_documento per gestione parametro
                            TIPO_DOC_SEARCH_BY_CODICE
    020  23/01/2018  MM     Modificata get_tipi_documento, get_documento e get_empty_row
                            per gesione domande di accesso
    021  02/02/2018  MM     Modificata get_tipi_documento
    022  06/02/2019  MM     Modificata separa_gli_allegati per errore cancellazione

    101  12/11/2018  MM     Creata crea_protocollo_agspr
    102  25/02/2019  MM     Gestione campo has_allegati del tipo documento
    103  09/04/2019  MM     Modificata GET_TAG_EMAIL_MITTENTE in modo da passare
                            N come default del flag segnatura_completa quando
                            IS_ENTE_INTERPRO vale Y.
                            Modificata GET_TIPI_DOCUMENTO: aggiunto upper sulla colonna
                            tipo_documento perhè il parametro arriva upper da flex e,
                            se il codice è minuscolo (3del), non lo trova.
     104 05/08/2019 MM      Modificata get_tag_email_mittente per gestione _rownum
                            in caso di più mail dello stesso tipo (in analogia con
                            la lettera dove, con la stessa descrizione, non sentiva
                            il cambio di record).
     105 25/10/2019 MM      Modificata funzione lettura per gestione
                            competenze agspr.
     106 05/02/2020 SC      #39727 Ricerca Corrispondenti: elencare tutti i
                            recapiti delle anagrafiche di tipo amministrativo
                            Consideriamo un corrispondente come doppio solo se la terna
                            denominazione, indirizzo postale e email.
     107 06/10/2020 MM      Creata is_protocollato.
     108 11/08/2020 SV      Creata crea_doc_titolario_agspr
    ******************************************************************************/
    s_revisione_body   afc.t_revision := '108';

    CURSOR c_campi (p_area VARCHAR2, p_modello VARCHAR2)
    IS
       SELECT dato nome
         FROM dati_modello
        WHERE codice_modello = p_modello
          and area = p_area;

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

    FUNCTION get_registri_emergenza
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
             NOME:        GET_REGISTRI_EMERGENZA
             DESCRIZIONE: OTTIENE LA LISTA DEI REGISTRI DI EMERGENZA
             RITORNO:
             Rev.  Data             Autore      Descrizione.
             00    13/04/2011   MMUR     Prima emissione.
            ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT *
              FROM seg_registri
          ORDER BY tipo_registro;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_REGISTRI_EMERGENZA: ' || SQLERRM);
    END get_registri_emergenza;

    FUNCTION elimina_class_secondaria (p_id_link IN VARCHAR2)
       RETURN NUMBER
    IS
    BEGIN
       DELETE FROM links
             WHERE id_link = p_id_link;

       RETURN 1;
    EXCEPTION
       WHEN OTHERS
       THEN
          RETURN 0;
    END elimina_class_secondaria;

    FUNCTION get_unita_assegnatari (p_unita     IN VARCHAR2,
                                    p_ricerca   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
      NOME:        GET_UNITA_ASSEGNATARI
      DESCRIZIONE: OTTIENE LA LISTA DEGLI UTENTI DI UN UNITA CHE POSSO ESSERE DESTINATARI  DI UN'ASSEGNAZIONE
      RITORNO:
      Rev.  Data             Autore      Descrizione.
      00    23/09/2010   MMUR     Prima emissione.
     ********************************************************************************/
       d_stringone           VARCHAR2 (30000);
       d_result              afc.t_ref_cursor;
       d_cursore             afc.t_ref_cursor;
       d_cursore_ni          afc.t_ref_cursor;
       d_cursore_privilegi   afc.t_ref_cursor;
       d_nome_delegato       VARCHAR2 (1000);
       d_ni                  VARCHAR2 (400);
       d_nome                VARCHAR2 (400);
       d_codice              VARCHAR2 (400);
       d_ruolo               VARCHAR2 (400);
       d_descrizione         VARCHAR2 (400);
       d_elementi            INT (10);
       d_cod_amm             VARCHAR2 (100);
    BEGIN
       d_stringone :=
          'select null ni, null nome, null codice from dual where 1=2 union';

       BEGIN
          IF p_unita IS NOT NULL
          THEN
             SELECT DISTINCT codice_amministrazione
               INTO d_cod_amm
               FROM seg_unita
              WHERE unita = p_unita;

             DBMS_OUTPUT.put_line ('cod_amm ' || d_cod_amm);
             d_cursore :=
                so4_ags_pkg.unita_get_componenti_ord (p_unita,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      d_cod_amm);

             LOOP
                d_elementi := 0;

                FETCH d_cursore INTO d_ni, d_nome, d_codice;

                EXIT WHEN d_cursore%NOTFOUND;
                d_cursore_ni :=
                   so4_ags_pkg.comp_get_ruoli (d_ni,
                                               p_unita,
                                               NULL,
                                               NULL,
                                               d_cod_amm);

                LOOP
                   FETCH d_cursore_ni INTO d_ruolo, d_descrizione;

                   DBMS_OUTPUT.put_line (
                      'entra nel loop per ni ' || d_ni || ' ' || d_nome);
                   DBMS_OUTPUT.put_line ('    ruolo ' || d_ruolo);
                   EXIT WHEN d_cursore_ni%NOTFOUND;

                   IF d_ruolo LIKE 'AGP%'
                   THEN
                      d_elementi := d_elementi + 1;
                   END IF;

                   EXIT WHEN (d_elementi > 0);
                END LOOP;

                d_stringone :=
                      d_stringone
                   || ' select '''
                   || d_ni
                   || ''' as NI  , '''
                   || REPLACE (d_nome, '''', '''''');

                IF (d_elementi = 0)
                THEN
                   d_stringone := d_stringone || ' (NON ABILITATO)';
                END IF;

                d_stringone :=
                      d_stringone
                   || ''' as NOME , '''
                   || REPLACE (d_codice, '''', '''''')
                   || ''' as CODICE from dual ';

                IF p_ricerca IS NOT NULL
                THEN
                   d_stringone :=
                         d_stringone
                      || ' where '''
                      || REPLACE (d_nome, '''', '''''')
                      || ''' like ''%'
                      || p_ricerca
                      || '%''';
                END IF;

                d_stringone := d_stringone || ' union';

                CLOSE d_cursore_ni;
             END LOOP;

             CLOSE d_cursore;
          END IF;

          d_stringone := SUBSTR (d_stringone, 0, LENGTH (d_stringone) - 5);
          DBMS_OUTPUT.put_line ('stringone ' || d_stringone);
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             NULL;
          WHEN OTHERS
          THEN
             RAISE;
       END;

       d_stringone := d_stringone || ' order by 2';

       OPEN d_result FOR d_stringone;

       RETURN d_result;
    END get_unita_assegnatari;

    FUNCTION get_lista_utenti (p_lista_utenti VARCHAR2 DEFAULT NULL)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_LISTA_UTENTI
          DESCRIZIONE: restituisce la lista degli utenti di ad4
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    08/10/2010  MMur  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
       d_sql      VARCHAR2 (1000);
    BEGIN
       IF UPPER (p_lista_utenti) IS NULL
       THEN
          d_sql :=
             'select nominativo, utente AS UTENTE_AGGIORNAMENTO, ag_soggetto.get_denominazione(utente) AS DENOMINAZIONE from Ad4_utenti where Tipo_Utente=''U'' order by DENOMINAZIONE';
       ELSE
          d_sql :=
                'select nominativo, utente AS UTENTE_AGGIORNAMENTO, ag_soggetto.get_denominazione(utente) AS DENOMINAZIONE from Ad4_utenti where Tipo_Utente=''U'' and utente in ('
             || p_lista_utenti
             || ') order by DENOMINAZIONE';
       END IF;

       DBMS_OUTPUT.put_line (d_sql);

       OPEN d_result FOR d_sql;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_LISTA_UTENTI: ' || SQLERRM);
    END get_lista_utenti;

    FUNCTION is_jdms_link_attivo (p_utente   IN VARCHAR2,
                                  p_cm       IN VARCHAR2,
                                  p_area     IN VARCHAR2)
       RETURN NUMBER
    IS
       d_gruppo    VARCHAR2 (100);
       d_tipodoc   NUMBER;
       d_return    NUMBER := 0;
    BEGIN
       BEGIN
          SELECT id_tipodoc
            INTO d_tipodoc
            FROM tipi_documento
           WHERE nome = p_cm AND area_modello = p_area;

          SELECT NVL (MIN (1), 0)
            INTO d_return
            FROM jdms_link
           WHERE id_tipodoc = d_tipodoc AND INSTR (url, '.html') > 0;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             d_return := 0;
       END;

       IF d_return > 0 AND p_cm = 'M_PROTOCOLLO'
       THEN
          BEGIN
             SELECT utente
               INTO d_gruppo
               FROM ad4_utenti
              WHERE gruppo_lavoro = 'AGPPRMDL' AND tipo_utente = 'O';
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                d_return := 0;
          END;

          IF d_return > 0
          THEN
             IF ad4_utente_gruppo.existsid (p_utente, d_gruppo)
             THEN
                d_return := 0;
             ELSE
                d_return := 1;
             END IF;
          END IF;
       END IF;

       RETURN d_return;
    END;

    FUNCTION check_permessi_accesso (p_id_documento   IN VARCHAR2,
                                     p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        CHECK_PERMESSI_ACCESSO
          DESCRIZIONE: VERIDICA SE L'UTENTE PUO' LEGGERE E MODIFICARE UN PROTOCOLLO
          RITORNO:
          Rev.  Data        Autore   Descrizione.
          000   19/03/2010  MM       Prima emissione.
          007   01/03/2016  MM       Gestione ag_competenze_protocollo.lettura con
                                     check completo.
          013   07/04/2017  SC       Gestione date privilegi
       ********************************************************************************/
       d_result    afc.t_ref_cursor;
       d_is_prot   NUMBER := 0;
       d_lettura   NUMBER := NULL;
    BEGIN
       SELECT COUNT (1)
         INTO d_is_prot
         FROM documenti d
        WHERE     id_documento = p_id_documento
              AND id_tipodoc IN (SELECT t.id_tipodoc
                                   FROM tipi_documento t, categorie_modello c
                                  WHERE     c.area = 'SEGRETERIA.PROTOCOLLO'
                                        AND c.categoria = 'PROTO'
                                        AND c.codice_modello = t.nome
                                        AND t.area_modello = c.area);

       IF d_is_prot = 1
       THEN
          d_lettura :=
             agspr_competenze_protocollo.lettura_gdm (p_id_documento, p_utente);
       END IF;

       OPEN d_result FOR
          SELECT gdm_competenza.gdm_verifica ('DOCUMENTI',
                                              TO_CHAR (p_id_documento),
                                              'U',
                                              p_utente,
                                              'GDM',
                                              TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                              'N')
                    AS modifica,
                 DECODE (d_lettura,
                         NULL, gdm_competenza.gdm_verifica (
                                  'DOCUMENTI',
                                  TO_CHAR (p_id_documento),
                                  'L',
                                  p_utente,
                                  'GDM',
                                  TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                  'N'),
                         d_lettura)
                    AS lettura,
                 ag_utilities.verifica_privilegio_utente (NULL,
                                                          'CPROT',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS accesso
            FROM DUAL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.CHECK_PERMESSI_ACCESSO: ' || SQLERRM);
    END check_permessi_accesso;

    FUNCTION get_gestione_smistamenti (p_area         IN VARCHAR2,
                                       p_cm           IN VARCHAR2,
                                       p_cr           IN VARCHAR2,
                                       p_utente       IN VARCHAR2,
                                       p_codice_amm   IN VARCHAR2,
                                       p_codice_aoo   IN VARCHAR2,
                                       p_rw           IN VARCHAR2,
                                       p_stato_pr     IN VARCHAR2,
                                       p_modalita     IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_GESTIONE_SMISTAMENTI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       d_result :=
          ag_smistabile_utility.get_gestione_smistamenti (p_area,
                                                          p_cm,
                                                          p_cr,
                                                          p_utente,
                                                          p_codice_amm,
                                                          p_codice_aoo,
                                                          p_rw,
                                                          p_stato_pr,
                                                          p_modalita);
       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_GESTIONE_SMISTEMENTI: ' || SQLERRM);
    END get_gestione_smistamenti;

    FUNCTION get_ultima_modifica (p_id_documento IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_ULTIMA_MODIFICA
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT TO_CHAR (data_aggiornamento, 'YYYYMMDDHH24miSS') AS ua
            FROM documenti
           WHERE id_documento = p_id_documento;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_ULTIMA_MODIFICA: ' || SQLERRM);
    END get_ultima_modifica;

    FUNCTION get_liste_distribuzione (p_descrizione IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_LISTE_DISTRIBUZIONE
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT codice_lista_distribuzione,
                   des_lista_distribuzione,
                   docu.codice_richiesta,
                   docu.id_documento,
                   'false' AS selected
              FROM seg_liste_distribuzione lidi, documenti docu
             WHERE     lidi.id_documento = docu.id_documento
                   AND UPPER (des_lista_distribuzione) LIKE
                          ('%' || UPPER (p_descrizione) || '%')
                   AND docu.STATO_DOCUMENTO NOT IN ('CA', 'RE')
          ORDER BY des_lista_distribuzione ASC;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_LISTA_DISTRIBUZIONE: ' || SQLERRM);
    END get_liste_distribuzione;

    FUNCTION get_unita_annullamento (p_utente       IN VARCHAR2,
                                     p_codice_amm   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_UNITA_ANNULLAMENTI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          000   05/12/2008  MM  Prima emissione.
          013    07/04/2017  SC  Gestione date privilegi
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT DISTINCT seg_unita.unita, seg_unita.nome descrizione


            FROM ag_priv_utente_tmp
               , seg_unita
           WHERE     utente = p_utente
                 AND appartenenza = 'D'
                 AND seg_unita.unita = ag_priv_utente_tmp.unita
                 AND seg_unita.codice_amministrazione = p_codice_amm
                 AND seg_unita.al IS NULL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_UNITA_ANNULLAMENTI: ' || SQLERRM);
    END get_unita_annullamento;

    FUNCTION istanzia_iter (id_richiesta             IN NUMBER DEFAULT NULL,
                            nome_iter                IN VARCHAR2,
                            parametri                IN VARCHAR2 DEFAULT NULL,
                            data_minima_esecuzione      DATE DEFAULT NULL,
                            utente                      VARCHAR2)
       RETURN NUMBER
    IS
    /*****************************************************************************
       NOME:        ISTANZIA_ITER
       DESCRIZIONE: Chiama la funzione del packege jwf_utility per istanziare un iter
       RITORNO:     0    non ok
                          1    ok
       Rev.  Data           Autore   Descrizione.
       00    25/08/2010  MMura  Prima emissione.
  ********************************************************************************/
    BEGIN
       RETURN jwf_utility.istanzia_iter (id_richiesta,
                                         nome_iter,
                                         parametri,
                                         data_minima_esecuzione,
                                         utente);
    END istanzia_iter;

    FUNCTION get_dettagli_pec (p_id_rif IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_DETTAGLI_PEC
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    06/07/2010  MMUR  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT DECODE (
                    gdm_m_soggetto.cognome_per_segnatura,
                    NULL, DECODE (
                             gdm_m_soggetto.denominazione_per_segnatura,
                             NULL, DECODE (
                                      gdm_m_soggetto.descrizione_aoo,
                                      NULL, DECODE (
                                               gdm_m_soggetto.descrizione_amm,
                                               NULL, NULL,
                                               gdm_m_soggetto.descrizione_amm),
                                      gdm_m_soggetto.descrizione_aoo),
                             gdm_m_soggetto.denominazione_per_segnatura),
                    DECODE (
                       gdm_m_soggetto.nome_per_segnatura,
                       NULL, gdm_m_soggetto.cognome_per_segnatura,
                          gdm_m_soggetto.cognome_per_segnatura
                       || ' '
                       || gdm_m_soggetto.nome_per_segnatura))
                    denominazione_vis,
                 gdm_m_soggetto.*
            FROM gdm_m_soggetto
           WHERE     gdm_m_soggetto.idrif = p_id_rif
                 AND gdm_m_soggetto.tipo_rapporto <> 'DUMMY'
                 AND (   gdm_m_soggetto.documento_tramite LIKE 'PEC%'
                      OR gdm_m_soggetto.registrata_consegna = 'Y'
                      OR gdm_m_soggetto.ric_mancata_consegna = 'Y')
                 AND stato NOT IN ('CA', 'RE', 'PB');

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_DETTAGLI_PEC: ' || SQLERRM);
    END get_dettagli_pec;

    FUNCTION is_dest_messaggio (p_tipo_messaggio    VARCHAR2,
                                p_id_documento      NUMBER,
                                p_recapito          VARCHAR2)
       RETURN VARCHAR2
    IS
       d_return   VARCHAR2 (1) := 'N';
    BEGIN
       IF p_recapito IS NOT NULL
       THEN
          FOR messaggi
             IN (SELECT NVL (LOWER (m.destinatari),
                             LOWER (m.destinatari_conoscenza))
                           AS destinatari
                   FROM seg_memo_protocollo m, riferimenti r
                  WHERE     m.id_documento = r.id_documento_rif
                        AND r.id_documento = p_id_documento
                        AND r.tipo_relazione = p_tipo_messaggio --('FAX', 'MAIL')
                                                               )
          LOOP
             IF INSTR (';' || messaggi.destinatari || ';',
                       ';' || LOWER (p_recapito) || ';') > 0
             THEN
                d_return := 'Y';
                EXIT;
             END IF;
          END LOOP;
       END IF;

       RETURN d_return;
    END;

    FUNCTION get_rapporti (p_id_rif IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_RAPPORTI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT sogg.*,
                   'POR' modinviotemp,
                   'POR' modinviotempfax,
                   is_dest_messaggio ('MAIL', prot.id_documento, sogg.email)
                      inviata_pec,
                   is_dest_messaggio ('FAX', prot.id_documento, sogg.fax)
                      inviato_fax
              FROM seg_soggetti_protocollo_view sogg, proto_view prot
             WHERE sogg.idrif = p_id_rif AND prot.idrif(+) = sogg.idrif
          ORDER BY sogg.id_documento;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_RAPPORTI: ' || SQLERRM);
    END get_rapporti;

    FUNCTION get_provenienza_documento (p_id_cart_provenienza   IN VARCHAR2,
                                        p_utente                IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_PROVENIENZA_DOCUMENTO
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          000    05/12/2008  MM  Prima emissione.
                13/06/2012  SC  Select per Unita protocollante deve restituire un solo valore
                                 e tenere conto delle preferenze utente
          013    07/04/2017  SC  Gestione date privilegi
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       IF p_id_cart_provenienza <> 'Cnull'
       THEN
          OPEN d_result FOR
             SELECT (SELECT seg_classificazioni.class_cod
                       FROM cartelle, seg_classificazioni
                      WHERE     cartelle.id_cartella =
                                   DECODE (
                                      SUBSTR (p_id_cart_provenienza, 1, 1),
                                      'C', SUBSTR (p_id_cart_provenienza, 2),
                                      p_id_cart_provenienza)
                            AND cartelle.id_documento_profilo =
                                   seg_classificazioni.id_documento
                            AND seg_classificazioni.contenitore_documenti =
                                   'Y')
                       AS classificazione_class_cod,
                    (SELECT TO_CHAR (seg_classificazioni.class_dal,
                                     'dd/mm/yyyy')
                       FROM cartelle, seg_classificazioni
                      WHERE     cartelle.id_cartella =
                                   DECODE (
                                      SUBSTR (p_id_cart_provenienza, 1, 1),
                                      'C', SUBSTR (p_id_cart_provenienza, 2),
                                      p_id_cart_provenienza)
                            AND cartelle.id_documento_profilo =
                                   seg_classificazioni.id_documento
                            AND seg_classificazioni.contenitore_documenti =
                                   'Y')
                       AS classificazione_class_dal,
                    (SELECT seg_classificazioni.class_descr
                       FROM cartelle, seg_classificazioni
                      WHERE     cartelle.id_cartella =
                                   DECODE (
                                      SUBSTR (p_id_cart_provenienza, 1, 1),
                                      'C', SUBSTR (p_id_cart_provenienza, 2),
                                      p_id_cart_provenienza)
                            AND cartelle.id_documento_profilo =
                                   seg_classificazioni.id_documento
                            AND seg_classificazioni.contenitore_documenti =
                                   'Y')
                       AS classificazione_class_descr,
                    seg_fascicoli.class_cod AS fascicolo_class_cod,
                    TO_CHAR (seg_fascicoli.class_dal, 'dd/mm/yyyy')
                       AS fascicolo_class_dal,
                    seg_classificazioni.class_descr AS fascicolo_class_descr,
                    seg_fascicoli.fascicolo_anno AS fascicolo_anno,
                    seg_fascicoli.fascicolo_numero AS fascicolo_numero,
                    seg_fascicoli.fascicolo_oggetto AS fascicolo_oggetto,
                    (SELECT DISTINCT seg_unita.unita
                       FROM seg_unita, ag_priv_utente_tmp
                      WHERE     ag_priv_utente_tmp.utente = p_utente
                            AND ag_priv_utente_tmp.unita = seg_unita.unita
                            AND ag_priv_utente_tmp.unita =
                                   ag_registro_utility.get_preferenza_utente (
                                      'AGSPR',
                                      p_utente,
                                      'UnitaProtocollante')
                            AND ag_priv_utente_tmp.privilegio = 'CPROT'
                            AND trunc(sysdate) <= nvl(ag_priv_utente_tmp.al, to_date(3333333,'j')))
                       AS unita_protocollante
               FROM cartelle, seg_fascicoli, seg_classificazioni
              WHERE     cartelle.id_cartella =
                           DECODE (SUBSTR (p_id_cart_provenienza, 1, 1),
                                   'C', SUBSTR (p_id_cart_provenienza, 2),
                                   p_id_cart_provenienza)
                    AND cartelle.id_documento_profilo =
                           seg_fascicoli.id_documento
                    AND seg_classificazioni.class_cod =
                           seg_fascicoli.class_cod
                    AND seg_classificazioni.class_dal =
                           seg_fascicoli.class_dal
             UNION
             SELECT (SELECT seg_classificazioni.class_cod
                       FROM cartelle, seg_classificazioni
                      WHERE     cartelle.id_cartella =
                                   DECODE (
                                      SUBSTR (p_id_cart_provenienza, 1, 1),
                                      'C', SUBSTR (p_id_cart_provenienza, 2),
                                      p_id_cart_provenienza)
                            AND cartelle.id_documento_profilo =
                                   seg_classificazioni.id_documento
                            AND seg_classificazioni.contenitore_documenti =
                                   'Y')
                       AS classificazione_class_cod,
                    (SELECT TO_CHAR (seg_classificazioni.class_dal,
                                     'dd/mm/yyyy')
                       FROM cartelle, seg_classificazioni
                      WHERE     cartelle.id_cartella =
                                   DECODE (
                                      SUBSTR (p_id_cart_provenienza, 1, 1),
                                      'C', SUBSTR (p_id_cart_provenienza, 2),
                                      p_id_cart_provenienza)
                            AND cartelle.id_documento_profilo =
                                   seg_classificazioni.id_documento
                            AND seg_classificazioni.contenitore_documenti =
                                   'Y')
                       AS classificazione_class_dal,
                    (SELECT seg_classificazioni.class_descr
                       FROM cartelle, seg_classificazioni
                      WHERE     cartelle.id_cartella =
                                   DECODE (
                                      SUBSTR (p_id_cart_provenienza, 1, 1),
                                      'C', SUBSTR (p_id_cart_provenienza, 2),
                                      p_id_cart_provenienza)
                            AND cartelle.id_documento_profilo =
                                   seg_classificazioni.id_documento
                            AND seg_classificazioni.contenitore_documenti =
                                   'Y')
                       AS classificazione_class_descr,
                    NULL AS fascicolo_class_cod,
                    NULL AS fascicolo_class_dal,
                    NULL AS fascicolo_class_descr,
                    NULL AS fascicolo_anno,
                    NULL AS fascicolo_numero,
                    NULL AS fascicolo_oggetto,
                    (SELECT DISTINCT seg_unita.unita
                       FROM seg_unita, ag_priv_utente_tmp
                      WHERE     ag_priv_utente_tmp.utente = p_utente
                            AND ag_priv_utente_tmp.unita = seg_unita.unita
                            AND ag_priv_utente_tmp.unita =
                                   ag_registro_utility.get_preferenza_utente (
                                      'AGSPR',
                                      p_utente,
                                      'UnitaProtocollante')
                            AND ag_priv_utente_tmp.privilegio = 'CPROT'
                            AND trunc(sysdate) <= nvl(ag_priv_utente_tmp.al, to_date(3333333,'j'))                            )
                       AS unita_protocollante
               FROM cartelle, seg_classificazioni
              WHERE     cartelle.id_cartella =
                           DECODE (SUBSTR (p_id_cart_provenienza, 1, 1),
                                   'C', SUBSTR (p_id_cart_provenienza, 2),
                                   p_id_cart_provenienza)
                    AND cartelle.id_documento_profilo =
                           seg_classificazioni.id_documento;
       ELSE
          OPEN d_result FOR
             SELECT NULL
               FROM DUAL;
       END IF;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_PROVENIENZA_DOCUMENTO: ' || SQLERRM);
    END get_provenienza_documento;

    FUNCTION get_default_protocollo (p_utente   IN VARCHAR2,
                                     p_modulo   IN VARCHAR2 DEFAULT 'AGSPR')
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_DEFAULT_PROTOCOLLO
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT 'Y' AS MASTER,
                 seg_movimenti.tipo_movimento AS modalita,
                 'Y' AS da_fascicolare,
                 'Y' AS visualizza_timbro,
                 p_utente AS utente_protocollante,
                 seq_idrif.NEXTVAL AS idrif,
                 'DP' AS stato_pr,
                 'Y' AS carico_inoltro,
                 'N' AS controlla_estremi_protocollo,
                 'X' AS accettazione_annullamento,
                 'N' AS blocco_modifiche
            FROM (  SELECT tipo_movimento, id_documento
                      FROM seg_movimenti,
                           (SELECT amvweb.get_preferenza ('MODALITA',
                                                          p_modulo,
                                                          p_utente)
                                      valore
                              FROM DUAL) pref_modalita
                     WHERE tipo_movimento LIKE NVL (pref_modalita.valore, '%')
                  ORDER BY DECODE (tipo_movimento,
                                   'ARR', 1,
                                   'PAR', 2,
                                   'INT', 3)) seg_movimenti
           WHERE     gdm_competenza.gdm_verifica ('DOCUMENTI',
                                                  seg_movimenti.id_documento,
                                                  'L',
                                                  p_utente,
                                                  'GDM') = 1
                 AND ROWNUM = 1;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_DEFAULT_PROTOCOLLO: ' || SQLERRM);
    END get_default_protocollo;

    FUNCTION get_privilegi (p_id_documento   IN VARCHAR2,
                            p_privilegio     IN VARCHAR2,
                            p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_PRIVILEGI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    06/04/2010  MarcoM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT NVL (
                    ag_competenze_protocollo.verifica_privilegio_protocollo (
                       p_id_documento,
                       p_privilegio,
                       p_utente),
                    0)
                    abilitazione
            FROM DUAL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_PRIVILEGI: ' || SQLERRM);
    END get_privilegi;

    FUNCTION get_privilegi_rapporti (p_id_documento   IN VARCHAR2,
                                     p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_PRIVILEGI_RAPPORTI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    03/04/2010  MarcoM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT gdm_competenza.gdm_verifica ('DOCUMENTI',
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
             'AG_DOCUMENTO_UTILITY.GET_PRIVILEGI_RAPPORTI: ' || SQLERRM);
    END get_privilegi_rapporti;

    FUNCTION get_privilegi_modifica (p_id_documento   IN VARCHAR2,
                                     p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_PRIVILEGI_MODIFICA
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT NVL (
                    agspr_competenze_protocollo.modifica_gdm (p_id_documento,
                                                       p_utente),
                    0)
                    modifica
            FROM DUAL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_PRIVILEGI_MODIFICA: ' || SQLERRM);
    END get_privilegi_modifica;

    FUNCTION get_privilegi_allegati (p_id_documento   IN VARCHAR2,
                                     p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_PRIVILEGI_ALLEGATI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    08/01/2010  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT ag_competenze_allegato.creazione (p_utente) AS creazione,
                 gdm_competenza.gdm_verifica ('DOCUMENTI',
                                              p_id_documento,
                                              'L',
                                              p_utente,
                                              'GDM',
                                              TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                              'N')
                    lettura,
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
             'AG_DOCUMENTO_UTILITY.GET_PRIVILEGI_ALLEGATI: ' || SQLERRM);
    END get_privilegi_allegati;

    FUNCTION get_privilegi_utente (p_utente         IN VARCHAR2,
                                   p_unita          IN VARCHAR2,
                                   p_id_documento   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_PRIVILEGI_UTENTE
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          000    05/12/2008  MM    Prima emissione.
          001    30/01/2012  MMur  Aggiunti/modificati controlli privilegi post blocco
          013    07/04/2017  SC    Gestione date privilegi.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT gdm_competenza.gdm_verifica ('DOCUMENTI',
                                              p_id_documento,
                                              'C',
                                              p_utente,
                                              'GDM',
                                              TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                              'N')
                    creazione,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'IRAP',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS irap,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'ERAP',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS erap,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MRAP',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mrap,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MFD',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mfd,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MO',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mo,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MD',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS md,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'IFC',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS ifc,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'ICLA',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS icla,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'IF',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS IF,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'ICLATOT',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS iclatot,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'EFC',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS efc,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'ECLA',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS ecla,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'EF',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS ef,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'ECLATOT',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS eclatot,
                 ag_utilities.verifica_privilegio_utente ('',
                                                          'ANNPROT',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS annulla,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'IRAPBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS irapblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MRAPBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mrapblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'ERAPBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS erapblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'IALL',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS iall,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MALL',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mall,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'EALL',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS eall,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'IALLBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS iallblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MALLBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mallblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'EALLBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS eallblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MOBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS moblc,
                 ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'MDBLC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS mdblc,
                 ag_utilities.verifica_privilegio_utente (NULL,
                                                          'FIRMA',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS FIRMA,
                    ag_utilities.verifica_privilegio_utente (NULL,
                                                          'MFARC',


                                                          p_utente,
                                                          trunc(sysdate))
                    AS MFARC,
                    ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'ARR',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS MARR,
                    ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'INT',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS MINT,
                    ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'PAR',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS MPAR,
                    ag_competenze_rapporto.verifica_creazione (p_id_documento,
                                                            p_utente,
                                                            p_unita)
                    AS creazione_rapporti,
                    ag_competenze_allegato.verifica_creazione (p_id_documento,
                                                            p_utente)
                    AS creazione_allegati,
                    ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'CFFUTURO',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS CFFUTURO,
                    ag_utilities.verifica_privilegio_utente (p_unita,
                                                          'CFANYY',
                                                          p_utente,
                                                          trunc(sysdate))
                    AS CFANYY

            FROM DUAL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_PRIVILEGI_UTENTE: ' || SQLERRM);
    END get_privilegi_utente;

/*  013  07/04/2017 SC Gestione date privilegi */
    FUNCTION get_uni_prot_select (p_utente        IN VARCHAR2,
                                  p_utente_prot   IN VARCHAR2,
                                  p_data          IN VARCHAR2,
                                  p_stato_pr      IN VARCHAR2)
       RETURN VARCHAR2
    IS
    BEGIN
       RETURN    'SELECT distinct seg_unita.unita, seg_unita.nome
                  FROM seg_unita, ag_priv_utente_tmp
                 WHERE '''
              || p_stato_pr
              || ''' = ''DP''
                   AND TRUNC (SYSDATE) BETWEEN SEG_UNITA.DAL AND NVL(seg_unita.al, TRUNC (SYSDATE))
                   AND ag_priv_utente_tmp.utente = NVL ('''
              || p_utente_prot
              || ''', '''
              || p_utente
              || ''')
                   AND ag_priv_utente_tmp.privilegio = ''CPROT''
                   AND seg_unita.unita = ag_priv_utente_tmp.unita






                   AND TRUNC (SYSDATE) <= NVL (ag_priv_utente_tmp.al,


                                                    to_date(3333333,''j'')
                                                   )
          AND EXISTS
                 (SELECT 1
                    FROM seg_unita uni_d, ag_priv_utente_tmp priv_d
                   WHERE     TRUNC (SYSDATE) BETWEEN uni_d.DAL
                                                 AND NVL (uni_d.al,
                                                          TRUNC (SYSDATE))
                         AND priv_d.appartenenza = ''D''
                         AND uni_d.unita = priv_d.unita








                         AND TRUNC (SYSDATE) <= NVL (priv_d.al,
                                                          to_date(3333333,''j''))
                         AND priv_d.utente = ag_priv_utente_tmp.utente
                         AND priv_d.privilegio = ag_priv_utente_tmp.privilegio
                         AND AG_UTILITIES.GET_UNITA_RADICE_AREA (
                                uni_d.unita,
                                TRUNC (SYSDATE),
                                ag_parametro.get_valore (''SO_OTTICA_PROT_1'',
                                                         ''@agVar@'',
                                                         ''*''),
                                uni_d.CODICE_AMMINISTRAZIONE,
                                uni_d.CODICE_AOO) = AG_UTILITIES.GET_UNITA_RADICE_AREA (
                                                       seg_unita.unita,
                                                       TRUNC (SYSDATE),
                                                       ag_parametro.get_valore (
                                                          ''SO_OTTICA_PROT_1'',
                                                          ''@agVar@'',
                                                          ''*''),
                                                       SEG_UNITA.CODICE_AMMINISTRAZIONE,
                                                       SEG_UNITA.CODICE_AOO))
 ORDER BY 2';
    END;

    FUNCTION get_uni_iter_select (p_utente IN VARCHAR2)
       RETURN VARCHAR2
    IS
    /*****************************************************************************
       NOME:        GET_UNI_ITER_SELECT
       DESCRIZIONE:
       RITORNO:
       Rev.  Data       Autore Descrizione.
       000   05/12/2008 MM     Prima emissione.
       005   18/11/2014 MM     Modificata get_uni_iter_select
       006   07/04/2017 SC     Gestione date privilegi
    ********************************************************************************/
    BEGIN
       RETURN    'SELECT seg_unita.unita, seg_unita.nome
                  FROM seg_unita
                 WHERE seg_unita.al IS NULL
                   AND seg_unita.unita IN (SELECT unita
                                         FROM ag_priv_utente_tmp
                                       WHERE ag_priv_utente_tmp.utente = '''
              || p_utente
              || '''
                                         AND ag_priv_utente_tmp.appartenenza = ''D''
                                         AND seg_unita.unita = ag_priv_utente_tmp.unita




                                         AND TRUNC (SYSDATE)  <= NVL (ag_priv_utente_tmp.al,to_date(3333333,''j'')))
                   UNION
                  SELECT seg_unita.unita, seg_unita.nome||decode(seg_unita.al, null, '''', '' chiusa il ''||to_char(seg_unita.al, ''dd/mm/yyyy''))
                    FROM seg_unita
                   WHERE seg_unita.unita  = ag_registro_utility.get_preferenza_utente (''AGSPR'','''
              || p_utente
              || ''',''UnitaIter'')
                     AND seg_unita.dal = (select max(dal) from seg_unita u where u.unita = seg_unita.unita)';
    END;

    FUNCTION get_unita_protocollanti (p_utente        IN VARCHAR2,
                                      p_utente_prot   IN VARCHAR2,
                                      p_data          IN VARCHAR2,
                                      p_stato_pr      IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_UNITA_PROTOCOLLANTI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          get_uni_prot_select (p_utente,
                               p_utente_prot,
                               p_data,
                               p_stato_pr);

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_UNITA_PROTOCOLLANTI: ' || SQLERRM);
    END get_unita_protocollanti;

    FUNCTION get_new_cr
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_NEW_CR
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR SELECT rich_sq.NEXTVAL FROM DUAL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_NEW_CR: ' || SQLERRM);
    END get_new_cr;

    FUNCTION get_info_allegato (p_id_documento IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_INFO_ALLEGATO
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT alle.id_documento,
                 anno,
                 alle.codice_amministrazione,
                 alle.codice_aoo,
                 data_modifica,
                 descrizione,
                 tial.descrizione_tipo_allegato desc_tipo_allegato,
                 desc_utente file_allegato,
                 firmato,
                 idrif,
                 modalita,
                 numero,
                 numero_pag,
                 pr_codice_amministrazione,
                 pr_codice_aoo,
                 pr_data,
                 pr_numero,
                 quantita,
                 stato_firma,
                 alle.tipo_allegato,
                 tipo_registro,
                 titolo_documento,
                 utente,
                 validita,
                 verifica_firma,
                 visualizza_timbro,
                 utente_firma,
                 id_documento_allegato,
                 riservato,
                 applicativo,
                 al,
                 dal,
                 log_protocollo,
                 id_libreria,
                 id_tipodoc,
                 codice_richiesta,
                 area,
                 data_aggiornamento,
                 utente_aggiornamento,
                 id_documento_padre,
                 stato_documento,
                 conservazione,
                 archiviazione
            FROM seg_allegati_protocollo alle,
                 documenti doc,
                 (SELECT tipo_allegato, descrizione_tipo_allegato
                    FROM seg_tipi_allegato
                  UNION
                  SELECT '0', 'ALLEGATO' FROM DUAL) tial
           WHERE     doc.id_documento = alle.id_documento
                 AND alle.id_documento = p_id_documento
                 AND tial.tipo_allegato(+) = alle.tipo_allegato;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_INFO_ALLEGATO: ' || SQLERRM);
    END get_info_allegato;

    PROCEDURE ins_upd_oggetti_file (p_id_documento      IN NUMBER,
                                    p_id_oggetto_file   IN NUMBER,
                                    p_filename          IN VARCHAR2,
                                    p_utente            IN VARCHAR)
    IS
    BEGIN
       IF p_id_oggetto_file IS NOT NULL
       THEN
          upd_oggetti_file (p_id_documento, p_id_oggetto_file, p_utente);
       ELSE
          IF p_filename IS NOT NULL
          THEN
             ins_oggetti_file (p_id_documento, p_filename, p_utente);
          ELSE
             raise_application_error (
                -20999,
                'I parametri p_id_oggetto_file e p_filename non possono essere entrambi nulli.');
          END IF;
       END IF;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.ins_upd_oggetti_file: ' || SQLERRM);
    END;

    PROCEDURE upd_oggetti_file (p_id_documento      IN NUMBER,
                                p_id_oggetto_file   IN NUMBER,
                                p_utente            IN VARCHAR)
    IS
       filename   OGGETTI_FILE.FILENAME%TYPE;
       nome       FORMATI_FILE.NOME%TYPE;
       testoocr   BLOB;
    BEGIN
       SELECT filename, nome, testoocr
         INTO filename, nome, testoocr
         FROM oggetti_file, formati_file
        WHERE     id_oggetto_file = p_id_oggetto_file
              AND oggetti_file.id_formato = formati_file.id_formato;

       gdm_profilo.insert_update_allegato (p_id_documento,
                                           filename,
                                           nome,
                                           testoocr,
                                           p_utente);
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.INSERT_ALLEGATI_MAIL: ' || SQLERRM);
    END;

    PROCEDURE ins_oggetti_file (p_id_documento   IN NUMBER,
                                p_filename       IN VARCHAR2,
                                p_utente         IN VARCHAR)
    IS
       d_nome       FORMATI_FILE.NOME%TYPE;
       d_filename   VARCHAR2 (1000) := p_filename;
    BEGIN
       --d_filename := replace(replace(d_filename, '/', '_'), '\', '_');

       IF INSTR (d_filename, '.', -1) > 0
       THEN
          d_nome :=
             UPPER (SUBSTR (d_filename, INSTR (d_filename, '.', -1) + 1));
       END IF;

       gdm_profilo.insert_update_allegato (p_id_documento,
                                           d_filename,
                                           d_nome,
                                           NULL,
                                           p_utente);
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.INSERT_ALLEGATI_MAIL: ' || SQLERRM);
    END;

    FUNCTION get_allegati_mail (p_id_documento   IN NUMBER,
                                p_codice_amm     IN VARCHAR2,
                                p_codice_aoo     IN VARCHAR2,
                                p_idrif          IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT id_oggetto_file,
                   oggetti_file.id_formato,
                   filename,
                   allegato,
                   id_oggetto_file_padre,
                   oggetti_file.id_documento
              FROM oggetti_file, riferimenti
             WHERE     oggetti_file.id_documento = riferimenti.id_documento_rif
                   AND riferimenti.id_documento = p_id_documento
                   AND filename IN (SELECT filename
                                      FROM oggetti_file,
                                           riferimenti,
                                           spr_protocolli_intero
                                     WHERE     oggetti_file.id_documento =
                                                  riferimenti.id_documento_rif
                                           AND RIFERIMENTI.ID_DOCUMENTO =
                                                  spr_protocolli_intero.id_documento
                                           AND riferimenti.id_documento =
                                                  p_id_documento
                                           AND riferimenti.tipo_relazione =
                                                  'MAIL'
                                    MINUS
                                    (SELECT filename
                                       FROM oggetti_file
                                      WHERE id_documento = p_id_documento
                                     UNION
                                     SELECT filename
                                       FROM seg_allegati_protocollo alle,
                                            documenti doc,
                                            oggetti_file ogfi
                                      WHERE     alle.idrif = p_idrif
                                            AND doc.id_documento =
                                                   alle.id_documento
                                            AND NVL (doc.stato_documento, 'BO') NOT IN ('CA',
                                                                                        'RE',
                                                                                        'PB')
                                            AND codice_amministrazione =
                                                   p_codice_amm
                                            AND codice_aoo = p_codice_aoo
                                            AND ogfi.id_documento(+) =
                                                   alle.id_documento))
          ORDER BY filename;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_ALLEGATI_MAIL: ' || SQLERRM);
    END get_allegati_mail;

    FUNCTION get_dati_oggetto_file (p_id_oggetto_file IN NUMBER)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT id_oggetto_file,
                 id_formato,
                 filename,
                 allegato,
                 id_oggetto_file_padre,
                 id_documento
            FROM oggetti_file
           WHERE id_oggetto_file = p_id_oggetto_file;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_DATI_OGGETTO_FILE: ' || SQLERRM);
    END get_dati_oggetto_file;

    FUNCTION get_allegati_xml (p_codice_amm   IN VARCHAR2,
                               p_codice_aoo   IN VARCHAR2,
                               p_idrif        IN VARCHAR2)
       RETURN CLOB
    IS
       d_result   CLOB := EMPTY_CLOB ();
       d_xml      VARCHAR2 (32767);
       i          NUMBER := 1;
       j          NUMBER := 1;
    BEGIN
       DBMS_LOB.createtemporary (d_result, TRUE, DBMS_LOB.CALL);
       d_xml := '<ROWSET>' || CHR (10) || CHR (13);
       DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
       i := 1;

       FOR cur_allegati
          IN (  SELECT alle.id_documento,
                       anno,
                       alle.codice_amministrazione,
                       alle.codice_aoo,
                       data_modifica,
                       descrizione,
                       tial.descrizione_tipo_allegato desc_tipo_allegato,
                       desc_utente file_allegato,
                       firmato,
                       idrif,
                       modalita,
                       numero,
                       numero_pag,
                       pr_codice_amministrazione,
                       pr_codice_aoo,
                       pr_data,
                       pr_numero,
                       quantita,
                       stato_firma,
                       alle.tipo_allegato,
                       tipo_registro,
                       titolo_documento,
                       utente,
                       validita,
                       verifica_firma,
                       visualizza_timbro,
                       utente_firma,
                       id_documento_allegato,
                       riservato,
                       applicativo,
                       al,
                       dal,
                       id_libreria,
                       id_tipodoc,
                       codice_richiesta,
                       area,
                       doc.data_aggiornamento,
                       doc.utente_aggiornamento,
                       id_documento_padre,
                       stato_documento,
                       conservazione,
                       archiviazione
                  FROM seg_allegati_protocollo alle,
                       documenti doc,
                       oggetti_file ogfi,
                       (SELECT tipo_allegato, descrizione_tipo_allegato
                          FROM seg_tipi_allegato
                        UNION
                        SELECT '0', 'ALLEGATO' FROM DUAL) tial
                 WHERE     alle.idrif = p_idrif
                       AND doc.id_documento = alle.id_documento
                       AND NVL (doc.stato_documento, 'BO') NOT IN ('CA',
                                                                   'RE',
                                                                   'PB')
                       AND alle.codice_amministrazione = p_codice_amm
                       AND alle.codice_aoo = p_codice_aoo
                       AND ogfi.id_documento(+) = alle.id_documento
                       AND tial.tipo_allegato(+) = alle.tipo_allegato
              GROUP BY alle.id_documento,
                       anno,
                       alle.codice_amministrazione,
                       alle.codice_aoo,
                       data_modifica,
                       descrizione,
                       tial.descrizione_tipo_allegato,
                       desc_utente,
                       firmato,
                       idrif,
                       modalita,
                       numero,
                       numero_pag,
                       pr_codice_amministrazione,
                       pr_codice_aoo,
                       pr_data,
                       pr_numero,
                       quantita,
                       stato_firma,
                       alle.tipo_allegato,
                       tipo_registro,
                       titolo_documento,
                       utente,
                       validita,
                       verifica_firma,
                       visualizza_timbro,
                       utente_firma,
                       id_documento_allegato,
                       riservato,
                       applicativo,
                       al,
                       dal,
                       id_libreria,
                       id_tipodoc,
                       codice_richiesta,
                       area,
                       doc.data_aggiornamento,
                       doc.utente_aggiornamento,
                       id_documento_padre,
                       stato_documento,
                       conservazione,
                       archiviazione
              ORDER BY descrizione)
       LOOP
          BEGIN
             d_xml :=
                   '<ROW num="'
                || i
                || '">'
                || CHR (10)
                || CHR (13)
                || '<ID_DOCUMENTO>'
                || cur_allegati.id_documento
                || '</ID_DOCUMENTO>'
                || CHR (10)
                || CHR (13)
                || '<DESCRIZIONE>'
                || cur_allegati.descrizione
                || '</DESCRIZIONE>'
                || CHR (10)
                || CHR (13)
                || '<DESC_TIPO_ALLEGATO>'
                || cur_allegati.desc_tipo_allegato
                || '</DESC_TIPO_ALLEGATO>'
                || CHR (10)
                || CHR (13)
                || '<FILE_ALLEGATO>'
                || cur_allegati.file_allegato
                || '</FILE_ALLEGATO>'
                || CHR (10)
                || CHR (13)
                || '<CODICE_AMMINISTRAZIONE>'
                || cur_allegati.codice_amministrazione
                || '</CODICE_AMMINISTRAZIONE>'
                || CHR (10)
                || CHR (13)
                || '<CODICE_AOO>'
                || cur_allegati.codice_aoo
                || '</CODICE_AOO>'
                || CHR (10)
                || CHR (13)
                || '<ANNO>'
                || cur_allegati.anno
                || '</ANNO>'
                || CHR (10)
                || CHR (13)
                || '<DATA_MODIFICA>'
                || cur_allegati.data_modifica
                || '</DATA_MODIFICA>'
                || CHR (10)
                || CHR (13)
                || '<FIRMATO>'
                || cur_allegati.firmato
                || '</FIRMATO>'
                || CHR (10)
                || CHR (13)
                || '<IDRIF>'
                || cur_allegati.idrif
                || '</IDRIF>'
                || CHR (10)
                || CHR (13)
                || '<MODALITA>'
                || cur_allegati.modalita
                || '</MODALITA>'
                || CHR (10)
                || CHR (13)
                || '<NUMERO>'
                || cur_allegati.numero
                || '</NUMERO>'
                || CHR (10)
                || CHR (13)
                || '<NUMERO_PAG>'
                || cur_allegati.numero_pag
                || '</NUMERO_PAG>'
                || CHR (10)
                || CHR (13)
                || '<PR_CODICE_AMMINISTRAZIONE>'
                || cur_allegati.pr_codice_amministrazione
                || '</PR_CODICE_AMMINISTRAZIONE>'
                || CHR (10)
                || CHR (13)
                || '<PR_CODICE_AOO>'
                || cur_allegati.pr_codice_aoo
                || '</PR_CODICE_AOO>'
                || CHR (10)
                || CHR (13)
                || '<PR_DATA>'
                || cur_allegati.pr_data
                || '</PR_DATA>'
                || CHR (10)
                || CHR (13)
                || '<PR_NUMERO>'
                || cur_allegati.pr_numero
                || '</PR_NUMERO>'
                || CHR (10)
                || CHR (13)
                || '<QUANTITA>'
                || cur_allegati.quantita
                || '</QUANTITA>'
                || CHR (10)
                || CHR (13)
                || '<STATO_FIRMA>'
                || cur_allegati.stato_firma
                || '</STATO_FIRMA>'
                || CHR (10)
                || CHR (13)
                || '<TIPO_ALLEGATO>'
                || cur_allegati.tipo_allegato
                || '</TIPO_ALLEGATO>'
                || CHR (10)
                || CHR (13)
                || '<TIPO_REGISTRO>'
                || cur_allegati.tipo_registro
                || '</TIPO_REGISTRO>'
                || CHR (10)
                || CHR (13)
                || '<TITOLO_DOCUMENTO>'
                || cur_allegati.titolo_documento
                || '</TITOLO_DOCUMENTO>'
                || CHR (10)
                || CHR (13)
                || '<UTENTE>'
                || cur_allegati.utente
                || '</UTENTE>'
                || CHR (10)
                || CHR (13)
                || '<VALIDITA>'
                || cur_allegati.validita
                || '</VALIDITA>'
                || CHR (10)
                || CHR (13)
                || '<VERIFICA_FIRMA>'
                || cur_allegati.verifica_firma
                || '</VERIFICA_FIRMA>'
                || CHR (10)
                || CHR (13)
                || '<VISUALIZZA_TIMBRO>'
                || cur_allegati.visualizza_timbro
                || '</VISUALIZZA_TIMBRO>'
                || CHR (10)
                || CHR (13)
                || '<UTENTE_FIRMA>'
                || cur_allegati.utente_firma
                || '</UTENTE_FIRMA>'
                || CHR (10)
                || CHR (13)
                || '<ID_DOCUMENTO_ALLEGATO>'
                || cur_allegati.id_documento_allegato
                || '</ID_DOCUMENTO_ALLEGATO>'
                || CHR (10)
                || CHR (13)
                || '<RISERVATO>'
                || cur_allegati.riservato
                || '</RISERVATO>'
                || CHR (10)
                || CHR (13)
                || '<APPLICATIVO>'
                || cur_allegati.applicativo
                || '</APPLICATIVO>'
                || CHR (10)
                || CHR (13)
                || '<AL>'
                || cur_allegati.al
                || '</AL>'
                || CHR (10)
                || CHR (13)
                || '<DAL>'
                || cur_allegati.dal
                || '</DAL>'
                || CHR (10)
                || CHR (13)
                || '<ID_LIBRERIA>'
                || cur_allegati.id_libreria
                || '</ID_LIBRERIA>'
                || CHR (10)
                || CHR (13)
                || '<ID_TIPODOC>'
                || cur_allegati.id_tipodoc
                || '</ID_TIPODOC>'
                || CHR (10)
                || CHR (13)
                || '<CODICE_RICHIESTA>'
                || cur_allegati.codice_richiesta
                || '</CODICE_RICHIESTA>'
                || CHR (10)
                || CHR (13)
                || '<AREA>'
                || cur_allegati.area
                || '</AREA>'
                || CHR (10)
                || CHR (13)
                || '<DATA_AGGIORNAMENTO>'
                || cur_allegati.data_aggiornamento
                || '</DATA_AGGIORNAMENTO>'
                || CHR (10)
                || CHR (13)
                || '<UTENTE_AGGIORNAMENTO>'
                || cur_allegati.utente_aggiornamento
                || '</UTENTE_AGGIORNAMENTO>'
                || CHR (10)
                || CHR (13)
                || '<ID_DOCUMENTO_PADRE>'
                || cur_allegati.id_documento_padre
                || '</ID_DOCUMENTO_PADRE>'
                || CHR (10)
                || CHR (13)
                || '<STATO_DOCUMENTO>'
                || cur_allegati.stato_documento
                || '</STATO_DOCUMENTO>'
                || CHR (10)
                || CHR (13)
                || '<CONSERVAZIONE>'
                || cur_allegati.conservazione
                || '</CONSERVAZIONE>'
                || CHR (10)
                || CHR (13)
                || '<ARCHIVIAZIONE>'
                || cur_allegati.archiviazione
                || '</ARCHIVIAZIONE>'
                || CHR (10)
                || CHR (13)
                || '<RADICE>SI</RADICE>'
                || CHR (10)
                || CHR (13);
             DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
             d_xml := '<ROWSET>' || CHR (10) || CHR (13);
             DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
             j := 1;

             FOR cur_allegati_det
                IN (  SELECT alle.id_documento,
                             anno,
                             codice_amministrazione,
                             codice_aoo,
                             data_modifica,
                             descrizione,
                             desc_tipo_allegato,
                             desc_utente file_allegato,
                             firmato,
                             idrif,
                             modalita,
                             numero,
                             numero_pag,
                             pr_codice_amministrazione,
                             pr_codice_aoo,
                             pr_data,
                             pr_numero,
                             quantita,
                             stato_firma,
                             tipo_allegato,
                             tipo_registro,
                             titolo_documento,
                             utente,
                             validita,
                             verifica_firma,
                             visualizza_timbro,
                             utente_firma,
                             id_documento_allegato,
                             riservato,
                             applicativo,
                             al,
                             dal,
                             log_protocollo,
                             id_libreria,
                             id_tipodoc,
                             codice_richiesta,
                             area,
                             doc.data_aggiornamento,
                             doc.utente_aggiornamento,
                             id_documento_padre,
                             stato_documento,
                             conservazione,
                             archiviazione,
                             id_oggetto_file,
                             filename
                        FROM seg_allegati_protocollo alle,
                             documenti doc,
                             oggetti_file ogfi
                       WHERE     alle.idrif = p_idrif
                             AND doc.id_documento = cur_allegati.id_documento
                             AND doc.id_documento = alle.id_documento
                             AND NVL (doc.stato_documento, 'BO') NOT IN ('CA',
                                                                         'RE',
                                                                         'PB')
                             AND codice_amministrazione = p_codice_amm
                             AND codice_aoo = p_codice_aoo
                             AND ogfi.id_documento(+) = alle.id_documento
                    ORDER BY descrizione)
             LOOP
                BEGIN
                   d_xml :=
                         '<ROW num="'
                      || j
                      || '">'
                      || CHR (10)
                      || CHR (13)
                      || '<ID_DOCUMENTO>'
                      || cur_allegati_det.id_documento
                      || '</ID_DOCUMENTO>'
                      || CHR (10)
                      || CHR (13)
                      || '<RADICE>NO</RADICE>'
                      || CHR (10)
                      || CHR (13)
                      || '<DESCRIZIONE>'
                      || cur_allegati_det.descrizione
                      || '</DESCRIZIONE>'
                      || CHR (10)
                      || CHR (13)
                      || '<DESC_TIPO_ALLEGATO>'
                      || cur_allegati_det.desc_tipo_allegato
                      || '</DESC_TIPO_ALLEGATO>'
                      || CHR (10)
                      || CHR (13)
                      || '<FILE_ALLEGATO>'
                      || cur_allegati_det.file_allegato
                      || '</FILE_ALLEGATO>'
                      || CHR (10)
                      || CHR (13)
                      || '<CODICE_AMMINISTRAZIONE>'
                      || cur_allegati_det.codice_amministrazione
                      || '</CODICE_AMMINISTRAZIONE>'
                      || CHR (10)
                      || CHR (13)
                      || '<CODICE_AOO>'
                      || cur_allegati_det.codice_aoo
                      || '</CODICE_AOO>'
                      || CHR (10)
                      || CHR (13)
                      || '<ANNO>'
                      || cur_allegati_det.anno
                      || '</ANNO>'
                      || CHR (10)
                      || CHR (13)
                      || '<DATA_MODIFICA>'
                      || cur_allegati_det.data_modifica
                      || '</DATA_MODIFICA>'
                      || CHR (10)
                      || CHR (13)
                      || '<FIRMATO>'
                      || cur_allegati_det.firmato
                      || '</FIRMATO>'
                      || CHR (10)
                      || CHR (13)
                      || '<IDRIF>'
                      || cur_allegati_det.idrif
                      || '</IDRIF>'
                      || CHR (10)
                      || CHR (13)
                      || '<MODALITA>'
                      || cur_allegati_det.modalita
                      || '</MODALITA>'
                      || CHR (10)
                      || CHR (13)
                      || '<NUMERO>'
                      || cur_allegati_det.numero
                      || '</NUMERO>'
                      || CHR (10)
                      || CHR (13)
                      || '<NUMERO_PAG>'
                      || cur_allegati_det.numero_pag
                      || '</NUMERO_PAG>'
                      || CHR (10)
                      || CHR (13)
                      || '<PR_CODICE_AMMINISTRAZIONE>'
                      || cur_allegati_det.pr_codice_amministrazione
                      || '</PR_CODICE_AMMINISTRAZIONE>'
                      || CHR (10)
                      || CHR (13)
                      || '<PR_CODICE_AOO>'
                      || cur_allegati_det.pr_codice_aoo
                      || '</PR_CODICE_AOO>'
                      || CHR (10)
                      || CHR (13)
                      || '<PR_DATA>'
                      || cur_allegati_det.pr_data
                      || '</PR_DATA>'
                      || CHR (10)
                      || CHR (13)
                      || '<PR_NUMERO>'
                      || cur_allegati_det.pr_numero
                      || '</PR_NUMERO>'
                      || CHR (10)
                      || CHR (13)
                      || '<QUANTITA>'
                      || cur_allegati_det.quantita
                      || '</QUANTITA>'
                      || CHR (10)
                      || CHR (13)
                      || '<STATO_FIRMA>'
                      || cur_allegati_det.stato_firma
                      || '</STATO_FIRMA>'
                      || CHR (10)
                      || CHR (13)
                      || '<TIPO_ALLEGATO>'
                      || cur_allegati_det.tipo_allegato
                      || '</TIPO_ALLEGATO>'
                      || CHR (10)
                      || CHR (13)
                      || '<TIPO_REGISTRO>'
                      || cur_allegati_det.tipo_registro
                      || '</TIPO_REGISTRO>'
                      || CHR (10)
                      || CHR (13)
                      || '<TITOLO_DOCUMENTO>'
                      || cur_allegati_det.titolo_documento
                      || '</TITOLO_DOCUMENTO>'
                      || CHR (10)
                      || CHR (13)
                      || '<UTENTE>'
                      || cur_allegati_det.utente
                      || '</UTENTE>'
                      || CHR (10)
                      || CHR (13)
                      || '<VALIDITA>'
                      || cur_allegati_det.validita
                      || '</VALIDITA>'
                      || CHR (10)
                      || CHR (13)
                      || '<VERIFICA_FIRMA>'
                      || cur_allegati_det.verifica_firma
                      || '</VERIFICA_FIRMA>'
                      || CHR (10)
                      || CHR (13)
                      || '<VISUALIZZA_TIMBRO>'
                      || cur_allegati_det.visualizza_timbro
                      || '</VISUALIZZA_TIMBRO>'
                      || CHR (10)
                      || CHR (13)
                      || '<UTENTE_FIRMA>'
                      || cur_allegati_det.utente_firma
                      || '</UTENTE_FIRMA>'
                      || CHR (10)
                      || CHR (13)
                      || '<ID_DOCUMENTO_ALLEGATO>'
                      || cur_allegati_det.id_documento_allegato
                      || '</ID_DOCUMENTO_ALLEGATO>'
                      || CHR (10)
                      || CHR (13)
                      || '<RISERVATO>'
                      || cur_allegati_det.riservato
                      || '</RISERVATO>'
                      || CHR (10)
                      || CHR (13)
                      || '<APPLICATIVO>'
                      || cur_allegati_det.applicativo
                      || '</APPLICATIVO>'
                      || CHR (10)
                      || CHR (13)
                      || '<AL>'
                      || cur_allegati_det.al
                      || '</AL>'
                      || CHR (10)
                      || CHR (13)
                      || '<DAL>'
                      || cur_allegati_det.dal
                      || '</DAL>'
                      || CHR (10)
                      || CHR (13)
                      || '<LOG_PROTOCOLLO>'
                      || cur_allegati_det.log_protocollo
                      || '</LOG_PROTOCOLLO>'
                      || CHR (10)
                      || CHR (13)
                      || '<ID_LIBRERIA>'
                      || cur_allegati_det.id_libreria
                      || '</ID_LIBRERIA>'
                      || CHR (10)
                      || CHR (13)
                      || '<ID_TIPODOC>'
                      || cur_allegati_det.id_tipodoc
                      || '</ID_TIPODOC>'
                      || CHR (10)
                      || CHR (13)
                      || '<CODICE_RICHIESTA>'
                      || cur_allegati_det.codice_richiesta
                      || '</CODICE_RICHIESTA>'
                      || CHR (10)
                      || CHR (13)
                      || '<AREA>'
                      || cur_allegati_det.area
                      || '</AREA>'
                      || CHR (10)
                      || CHR (13)
                      || '<DATA_AGGIORNAMENTO>'
                      || cur_allegati_det.data_aggiornamento
                      || '</DATA_AGGIORNAMENTO>'
                      || CHR (10)
                      || CHR (13)
                      || '<UTENTE_AGGIORNAMENTO>'
                      || cur_allegati_det.utente_aggiornamento
                      || '</UTENTE_AGGIORNAMENTO>'
                      || CHR (10)
                      || CHR (13)
                      || '<ID_DOCUMENTO_PADRE>'
                      || cur_allegati_det.id_documento_padre
                      || '</ID_DOCUMENTO_PADRE>'
                      || CHR (10)
                      || CHR (13)
                      || '<STATO_DOCUMENTO>'
                      || cur_allegati_det.stato_documento
                      || '</STATO_DOCUMENTO>'
                      || CHR (10)
                      || CHR (13)
                      || '<CONSERVAZIONE>'
                      || cur_allegati_det.conservazione
                      || '</CONSERVAZIONE>'
                      || CHR (10)
                      || CHR (13)
                      || '<ARCHIVIAZIONE>'
                      || cur_allegati_det.archiviazione
                      || '</ARCHIVIAZIONE>'
                      || CHR (10)
                      || CHR (13)
                      || '<ID_OGGETTO_FILE>'
                      || cur_allegati_det.id_oggetto_file
                      || '</ID_OGGETTO_FILE>'
                      || CHR (10)
                      || CHR (13)
                      || '<FILENAME>'
                      || cur_allegati_det.filename
                      || '</FILENAME>'
                      || CHR (10)
                      || CHR (13);
                   DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
                   d_xml := '</ROW>' || CHR (10) || CHR (13);
                   DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
                   j := j + 1;
                END;
             END LOOP;

             d_xml := '</ROWSET>' || CHR (10) || CHR (13);
             DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
             d_xml := '</ROW>' || CHR (10) || CHR (13);
             DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
             i := i + 1;
          END;
       END LOOP;

       d_xml := '</ROWSET>' || CHR (10) || CHR (13);
       DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
       RETURN d_result;
    END;

    /*****************************************************************************
             NOME:        GET_ALLEGATI_MAXFILESIZE
             DESCRIZIONE: Controlla il valore, se presente, della massima dimensione di un file allegato, per l'area e per il codice modello
             RITORNO:   restituisce la dimensione massima di un alllegato espressa in byte
             Rev.  Data       Autore  Descrizione.
             00    12/01/2012  MMur  Prima emissione.
          ********************************************************************************/
    FUNCTION get_allegati_maxfilesize (p_area      IN VARCHAR2,
                                       p_modello   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_ref_cursor   afc.t_ref_cursor;
       valore         VARCHAR2 (400);
    BEGIN
       valore := f_get_maxdim_attach (p_area, p_modello);

       OPEN d_ref_cursor FOR
          SELECT SUBSTR (valore, 1, INSTR (valore, '@') - 1) AS maxfilesize,
                 SUBSTR (valore, INSTR (valore, '@') + 1, LENGTH (valore))
                    AS bloccante
            FROM DUAL;

       RETURN d_ref_cursor;
    END;

    FUNCTION get_allegati (p_codice_amm   IN VARCHAR2,
                           p_codice_aoo   IN VARCHAR2,
                           p_idrif        IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_ALLEGATI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT alle.id_documento,
                   anno,
                   codice_amministrazione,
                   codice_aoo,
                   data_modifica,
                   descrizione,
                   desc_tipo_allegato,
                   desc_utente file_allegato,
                   firmato,
                   idrif,
                   modalita,
                   numero,
                   numero_pag,
                   pr_codice_amministrazione,
                   pr_codice_aoo,
                   pr_data,
                   pr_numero,
                   quantita,
                   stato_firma,
                   tipo_allegato,
                   tipo_registro,
                   titolo_documento,
                   utente,
                   validita,
                   verifica_firma,
                   visualizza_timbro,
                   utente_firma,
                   id_documento_allegato,
                   riservato,
                   applicativo,
                   al,
                   dal,
                   log_protocollo,
                   id_libreria,
                   id_tipodoc,
                   codice_richiesta,
                   area,
                   doc.data_aggiornamento,
                   doc.utente_aggiornamento,
                   id_documento_padre,
                   stato_documento,
                   conservazione,
                   archiviazione,
                   id_oggetto_file,
                   filename
              FROM seg_allegati_protocollo alle,
                   documenti doc,
                   oggetti_file ogfi
             WHERE     alle.idrif = p_idrif
                   AND doc.id_documento = alle.id_documento
                   AND NVL (doc.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
                   AND codice_amministrazione = p_codice_amm
                   AND codice_aoo = p_codice_aoo
                   AND ogfi.id_documento(+) = alle.id_documento
          ORDER BY descrizione;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_ALLEGATI: ' || SQLERRM);
    END get_allegati;

    FUNCTION get_tipi_allegati (p_codice_amm   IN VARCHAR2,
                                p_codice_aoo   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_TIPI_ALLEGATI
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  MM  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT tipo_allegato, descrizione_tipo_allegato
              FROM gdm_diz_tipi_allegato
             WHERE     codice_amministrazione = p_codice_amm
                   AND codice_aoo = p_codice_aoo
                   AND stato NOT IN ('CA', 'RE', 'PB')
          ORDER BY 2;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_TIPI_ALLEGATI: ' || SQLERRM);
    END get_tipi_allegati;

    FUNCTION get_unita_classificazione (
       p_codice_amm   IN VARCHAR2,
       p_codice_aoo   IN VARCHAR2,
       p_class_cod    IN seg_unita_classifica.class_cod%TYPE)
       RETURN afc.t_ref_cursor
    IS
    BEGIN
       RETURN ag_fascicolo_utility.get_unita_classificazione (p_codice_amm,
                                                              p_codice_aoo,
                                                              p_class_cod);
    END get_unita_classificazione;

    FUNCTION get_classificazioni (
       p_codice_amm     IN VARCHAR2,
       p_codice_aoo     IN VARCHAR2,
       p_class_cod      IN seg_classificazioni.class_cod%TYPE,
       p_class_descr    IN seg_classificazioni.class_descr%TYPE,
       p_mostra_tutte   IN VARCHAR2,
       p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
    BEGIN
       RETURN ag_fascicolo_utility.get_classificazioni (p_codice_amm,
                                                        p_codice_aoo,
                                                        p_class_cod,
                                                        p_class_descr,
                                                        p_mostra_tutte,
                                                        p_utente);
    END get_classificazioni;

    FUNCTION get_fascicolo (
       p_codice_amm         IN VARCHAR2,
       p_codice_aoo         IN VARCHAR2,
       p_class_cod          IN seg_classificazioni.class_cod%TYPE,
       p_fascicolo_anno     IN seg_fascicoli.fascicolo_anno%TYPE,
       p_fascicolo_numero   IN seg_fascicoli.fascicolo_numero%TYPE,
       p_utente             IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
    BEGIN
       RETURN ag_fascicolo_utility.get_fascicolo (p_codice_amm,
                                                  p_codice_aoo,
                                                  p_class_cod,
                                                  p_fascicolo_anno,
                                                  p_fascicolo_numero,
                                                  p_utente);
    END get_fascicolo;

    FUNCTION get_modalita_ricevimento (
       p_codice_amm                    IN VARCHAR2,
       p_codice_aoo                    IN VARCHAR2,
       p_id_documento                  IN VARCHAR2,
       p_documento_tramite             IN VARCHAR2,
       p_descrizione_mod_ricevimento   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_refcursor   afc.t_ref_cursor;
    BEGIN
       OPEN d_refcursor FOR
          SELECT mod_ricevimento AS documento_tramite,
                 seg_modalita_ricevimento.descrizione_mod_ricevimento,
                 stato_pr,
                 data,
                 costo_euro,
                 seg_modalita_ricevimento.tipo_spedizione,
                 barcode_italia,
                 barcode_estero
            FROM seg_modalita_ricevimento,
                 documenti,
                 proto_view,
                 seg_tipi_spedizione
           WHERE     seg_modalita_ricevimento.codice_amministrazione =
                        p_codice_amm
                 AND SEG_TIPI_SPEDIZIONE.TIPO_SPEDIZIONE(+) =
                        seg_modalita_ricevimento.TIPO_SPEDIZIONE
                 AND seg_modalita_ricevimento.codice_aoo = p_codice_aoo
                 AND documenti.id_documento =
                        seg_modalita_ricevimento.id_documento
                 AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                 AND proto_view.id_documento = p_id_documento
                 AND (   (    stato_pr = 'DP'
                          AND TRUNC (SYSDATE) BETWEEN NVL (
                                                         seg_modalita_ricevimento.dataval_dal,
                                                         TO_DATE (2222222,
                                                                  'j'))
                                                  AND NVL (
                                                         seg_modalita_ricevimento.dataval_al,
                                                         TO_DATE (3333333,
                                                                  'j')))
                      OR (    stato_pr <> 'DP'
                          AND TRUNC (data) BETWEEN NVL (
                                                      seg_modalita_ricevimento.dataval_dal,
                                                      TO_DATE (2222222, 'j'))
                                               AND NVL (
                                                      seg_modalita_ricevimento.dataval_al,
                                                      TO_DATE (3333333, 'j'))))
                 AND p_id_documento IS NOT NULL
                 AND LOWER (seg_modalita_ricevimento.mod_ricevimento) LIKE
                        '%' || LOWER (P_DOCUMENTO_TRAMITE) || '%'
                 AND LOWER (
                        seg_modalita_ricevimento.descrizione_mod_ricevimento) LIKE
                        '%' || LOWER (P_DESCRIZIONE_MOD_RICEVIMENTO) || '%'
          UNION
          SELECT mod_ricevimento AS documento_tramite,
                 seg_modalita_ricevimento.descrizione_mod_ricevimento,
                 'DP',
                 NULL,
                 costo_euro,
                 seg_modalita_ricevimento.tipo_spedizione,
                 barcode_italia,
                 barcode_estero
            FROM seg_modalita_ricevimento, documenti, SEG_TIPI_SPEDIZIONE
           WHERE     seg_modalita_ricevimento.codice_amministrazione =
                        p_codice_amm
                 AND SEG_TIPI_SPEDIZIONE.TIPO_SPEDIZIONE(+) =
                        seg_modalita_ricevimento.TIPO_SPEDIZIONE
                 AND seg_modalita_ricevimento.codice_aoo = p_codice_aoo
                 AND documenti.id_documento =
                        seg_modalita_ricevimento.id_documento
                 AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                 AND TRUNC (SYSDATE) BETWEEN NVL (
                                                seg_modalita_ricevimento.dataval_dal,
                                                TO_DATE (2222222, 'j'))
                                         AND NVL (
                                                seg_modalita_ricevimento.dataval_al,
                                                TO_DATE (3333333, 'j'))
                 AND p_id_documento IS NULL
                 AND LOWER (seg_modalita_ricevimento.mod_ricevimento) LIKE
                        '%' || LOWER (P_DOCUMENTO_TRAMITE) || '%'
                 AND LOWER (
                        seg_modalita_ricevimento.descrizione_mod_ricevimento) LIKE
                        '%' || LOWER (P_DESCRIZIONE_MOD_RICEVIMENTO) || '%'
          ORDER BY 2;

       RETURN d_refcursor;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_MODALITA_RICEVIMENTO: ' || SQLERRM);
    END;

    FUNCTION get_smistamenti_tipo_docu (
       p_codice_amm       IN VARCHAR2,
       p_codice_aoo       IN VARCHAR2,
       p_tipo_documento   IN seg_tipi_documento.tipo_documento%TYPE)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
           NOME:        GET_SMISTAMENTI_TIPO_DOCU
           DESCRIZIONE:
           RITORNO:
           Rev.  Data       Autore  Descrizione.
           000   05/12/2008 SN      Prima emissione.
           015   25/10/2017 MM      Gestione sequenza
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
       d_has_sequenza_smistamenti number:=0;
    BEGIN
       d_has_sequenza_smistamenti := ag_tipi_documento_utility.has_sequenza_smistamenti(p_tipo_documento);

       if d_has_sequenza_smistamenti = 0 then
           OPEN d_result FOR
                SELECT tipo_smistamento,
                       seg_unita.nome des_ufficio_smistamento,
                       ufficio_smistamento
                  FROM seg_smistamenti_tipi_documento, seg_unita, documenti d
                 WHERE     d.id_documento =
                              seg_smistamenti_tipi_documento.id_documento
                       AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND seg_smistamenti_tipi_documento.codice_amministrazione =
                              p_codice_amm
                       AND seg_smistamenti_tipi_documento.codice_aoo = p_codice_aoo
                       AND seg_smistamenti_tipi_documento.tipo_documento =
                              p_tipo_documento
                       AND seg_smistamenti_tipi_documento.ufficio_smistamento =
                              seg_unita.unita
                       AND seg_unita.codice_amministrazione =
                              seg_smistamenti_tipi_documento.codice_amministrazione
                       AND seg_unita.codice_aoo =
                              seg_smistamenti_tipi_documento.codice_aoo
                       AND TRUNC (SYSDATE) BETWEEN seg_unita.dal
                                               AND NVL (
                                                      seg_unita.al,
                                                      TO_DATE ('31/12/2999',
                                                               'DD/MM/YYYY'))
              ORDER BY tipo_smistamento, des_ufficio_smistamento;
       else
          OPEN d_result FOR
            SELECT tipo_smistamento,
                   seg_unita.nome des_ufficio_smistamento,
                   ufficio_smistamento
              FROM seg_smistamenti_tipi_documento, documenti d, seg_unita
             WHERE     D.ID_DOCUMENTO = seg_smistamenti_tipi_documento.ID_DOCUMENTO
                   AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND NVL (sequenza, -1) > 0
                   AND tipo_smistamento = 'COMPETENZA'
                   AND seg_smistamenti_tipi_documento.codice_amministrazione =
                          p_codice_amm
                   AND seg_smistamenti_tipi_documento.codice_aoo = p_codice_aoo
                   AND seg_smistamenti_tipi_documento.tipo_documento = p_tipo_documento
                   AND seg_smistamenti_tipi_documento.ufficio_smistamento =
                          seg_unita.unita
                   AND seg_unita.codice_amministrazione =
                          seg_smistamenti_tipi_documento.codice_amministrazione
                   AND seg_unita.codice_aoo =seg_smistamenti_tipi_documento.codice_aoo
                   AND TRUNC (SYSDATE) BETWEEN seg_unita.dal
                                           AND NVL (seg_unita.al,
                                                    TO_DATE ('31/12/2999', 'DD/MM/YYYY'))
                   AND SEQUENZA IN
                          (SELECT MIN (SEQUENZA)
                             FROM seg_smistamenti_tipi_documento s,
                                  documenti d,
                                  seg_unita
                            WHERE     D.ID_DOCUMENTO = S.ID_DOCUMENTO
                                  AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                                  AND NVL (sequenza, -1) > 0
                                  AND tipo_smistamento = 'COMPETENZA'
                                  AND s.codice_amministrazione =
                                         p_codice_amm
                                  AND s.codice_aoo =
                                         p_codice_aoo
                                  AND s.tipo_documento =
                                         p_tipo_documento
                                  AND s.ufficio_smistamento =
                                         seg_unita.unita
                                  AND seg_unita.codice_amministrazione =
                                         s.codice_amministrazione
                                  AND seg_unita.codice_aoo =
                                         s.codice_aoo
                                  AND TRUNC (SYSDATE) BETWEEN seg_unita.dal
                                                          AND NVL (
                                                                 seg_unita.al,
                                                                 TO_DATE ('31/12/2999',
                                                                          'DD/MM/YYYY')))
            UNION
            SELECT tipo_smistamento,
                   seg_unita.nome des_ufficio_smistamento,
                   ufficio_smistamento
              FROM seg_smistamenti_tipi_documento, seg_unita, documenti d
             WHERE     d.id_documento = seg_smistamenti_tipi_documento.id_documento
                   AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND seg_smistamenti_tipi_documento.codice_amministrazione =
                          p_codice_amm
                   AND seg_smistamenti_tipi_documento.codice_aoo = p_codice_aoo
                   AND seg_smistamenti_tipi_documento.tipo_documento = p_tipo_documento
                   AND seg_smistamenti_tipi_documento.ufficio_smistamento =
                          seg_unita.unita
                   AND seg_unita.codice_amministrazione =
                          seg_smistamenti_tipi_documento.codice_amministrazione
                   AND seg_unita.codice_aoo = seg_smistamenti_tipi_documento.codice_aoo
                   AND TRUNC (SYSDATE) BETWEEN seg_unita.dal
                                           AND NVL (seg_unita.al,
                                                    TO_DATE ('31/12/2999', 'DD/MM/YYYY'))
                   AND tipo_smistamento = 'CONOSCENZA'
            ORDER BY tipo_smistamento, des_ufficio_smistamento;
       end if;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_SMISTAMENTI_TIPO_DOCU: ' || SQLERRM);
    END get_smistamenti_tipo_docu;

    FUNCTION get_smistamenti (
       p_codice_amm                IN VARCHAR2,
       p_codice_aoo                IN VARCHAR2,
       p_idrif                     IN VARCHAR2,
       p_storici                   IN VARCHAR2,
       p_utente                    IN VARCHAR2,
       p_tipo_smistamento          IN ag_tipi_smistamento.tipo_smistamento%TYPE,
       p_des_uff_trasmissione      IN SEG_SMISTAMENTI.DES_UFFICIO_TRASMISSIONE%TYPE,
       p_den_utente_trasmissione   IN as4_anagrafe_soggetti.denominazione%TYPE,
       p_smistamento_dal           IN VARCHAR2,
       p_des_uff_smistamento       IN SEG_SMISTAMENTI.DES_UFFICIO_SMISTAMENTO%TYPE,
       p_den_utente_carico         IN as4_anagrafe_soggetti.denominazione%TYPE,
       p_presa_in_carico_dal       IN VARCHAR2,
       p_den_utente_assegnatario   IN as4_anagrafe_soggetti.denominazione%TYPE,
       p_assegnazione_dal          IN VARCHAR2,
       p_den_utente_esecuzione     IN as4_anagrafe_soggetti.denominazione%TYPE,
       p_data_esecuzione           IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
       d_select   VARCHAR2 (32767);
    BEGIN
       d_select :=
             'SELECT smis.id_documento,
                   smis.idrif,
                   smis.DATA,
                   smis.codice_amministrazione,
                   smis.codice_aoo,
                   smis.tipo_smistamento,
                   tism.descrizione des_tipo_smistamento,
                   TO_CHAR (smistamento_dal,''dd/mm/yyyy hh24:mi:ss'')  AS smistamento_dal,
                   stato_smistamento,
                   DECODE (stato_smistamento,''C'', ''In carico'',''R'', ''Da ricevere'',''E'',''Eseguito'',''F'',''Storico'', stato_smistamento) des_stato,
                   ufficio_smistamento,
                   des_ufficio_smistamento des_uff_smistamento,
                   TO_CHAR (assegnazione_dal, ''dd/mm/yyyy hh24:mi:ss'')  AS assegnazione_dal,
                   codice_assegnatario,
                   ag_soggetto.get_denominazione (smis.codice_assegnatario)
                   den_utente_assegnatario,
                   TO_CHAR (presa_in_carico_dal, ''dd/mm/yyyy hh24:mi:ss'') AS presa_in_carico_dal,
                   presa_in_carico_utente,
                   ag_soggetto.get_denominazione (smis.presa_in_carico_utente)
                   den_utente_carico,
                   ufficio_trasmissione,
                   utente_trasmissione,
                   des_ufficio_trasmissione des_uff_trasmissione,
                   ag_soggetto.get_denominazione (smis.utente_trasmissione)
                      den_utente_trasmissione,
                   TO_CHAR (data_esecuzione,''dd/mm/yyyy hh24:mi:ss'')  AS data_esecuzione,
                   utente_esecuzione,
                   ag_soggetto.get_denominazione (smis.utente_esecuzione)  den_utente_esecuzione,
                   note,
                   DECODE (
                      utente_trasmissione,
                      '''
          || p_utente
          || ''', 1,
                      DECODE (
                         codice_assegnatario,
                         '''
          || p_utente
          || ''', 1,
                         DECODE (
                            ag_utilities.verifica_privilegio_utente (
                               ufficio_trasmissione,
                               ''VSMINOTE'',
                               '''
          || p_utente
          || '''),
                            1, 1,
                            DECODE (
                               NVL (codice_assegnatario, '' ''),
                               '' '', DECODE (
                                       ag_utilities.verifica_privilegio_utente (
                                          ufficio_smistamento,
                                          ''VS'',
                                          '''
          || p_utente
          || '''),
                                       1, 1,
                                       0),
                               DECODE (
                                  ag_utilities.verifica_privilegio_utente (
                                     ufficio_smistamento,
                                     ''VSMINOTE'',
                                     '''
          || p_utente
          || '''),
                                  1, 1,
                                  0)))))
                      note_visible
              FROM seg_smistamenti smis,
                   documenti docu_smis,
                   ag_tipi_smistamento tism
             WHERE smis.idrif = '''
          || p_idrif
          || '''
                   AND smis.codice_amministrazione ='''
          || p_codice_amm
          || '''
                   AND smis.codice_aoo = '''
          || p_codice_aoo
          || '''
                   AND smis.tipo_smistamento <>''DUMMY''
                   AND (   (smis.stato_smistamento = ''F'' AND  '
          || p_storici
          || ' = 1) OR (smis.stato_smistamento <> ''F'' AND  '
          || p_storici
          || ' = 0) OR NVL ( '
          || p_storici
          || ', -1) = -1)
                   AND docu_smis.id_documento = smis.id_documento
                   AND docu_smis.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
                   AND tism.tipo_smistamento = smis.tipo_smistamento';

       IF P_TIPO_SMISTAMENTO IS NOT NULL
       THEN
          d_select :=
                d_select
             || '  AND UPPER(tism.tipo_smistamento) LIKE UPPER(''%'
             || P_TIPO_SMISTAMENTO
             || '%'') ';
       END IF;

       IF P_DES_UFF_TRASMISSIONE IS NOT NULL
       THEN
          d_select :=
                d_select
             || '  AND upper(des_ufficio_trasmissione) LIKE upper(''%'
             || P_DES_UFF_TRASMISSIONE
             || '%'') ';
       END IF;

       IF P_DEN_UTENTE_TRASMISSIONE IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND upper(nvl(ag_soggetto.get_denominazione (smis.utente_trasmissione),''*'')) LIKE  upper(''%''||NVL('''
             || P_DEN_UTENTE_TRASMISSIONE
             || ''',''*'')||''%'') ';
       END IF;

       IF P_SMISTAMENTO_DAL IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND trunc(smis.smistamento_dal) =TO_DATE ('''
             || P_SMISTAMENTO_DAL
             || ''',''dd/mm/yyyy'') ';
       END IF;

       IF P_DES_UFF_SMISTAMENTO IS NOT NULL
       THEN
          d_select :=
                d_select
             || '  AND upper(des_ufficio_smistamento) LIKE upper(''%'
             || P_DES_UFF_SMISTAMENTO
             || '%'') ';
       END IF;

       IF P_DEN_UTENTE_CARICO IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND upper(nvl(ag_soggetto.get_denominazione (smis.presa_in_carico_utente),''*'')) LIKE  upper(''%''||NVL('''
             || P_DEN_UTENTE_CARICO
             || ''',''*'')||''%'') ';
       END IF;

       IF P_PRESA_IN_CARICO_DAL IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND trunc(presa_in_carico_dal) =TO_DATE ('''
             || P_PRESA_IN_CARICO_DAL
             || ''',''dd/mm/yyyy'') ';
       END IF;

       IF P_DEN_UTENTE_ASSEGNATARIO IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND upper(nvl(ag_soggetto.get_denominazione (smis.codice_assegnatario),''*'')) LIKE upper( ''%''||NVL('''
             || P_DEN_UTENTE_ASSEGNATARIO
             || ''',''*'')||''%'') ';
       END IF;

       IF P_ASSEGNAZIONE_DAL IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND trunc(assegnazione_dal) =TO_DATE ('''
             || P_ASSEGNAZIONE_DAL
             || ''',''dd/mm/yyyy'') ';
       END IF;

       IF P_DEN_UTENTE_ESECUZIONE IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND upper(nvl(ag_soggetto.get_denominazione (smis.utente_esecuzione),''*'')) LIKE upper( ''%''||NVL('''
             || P_DEN_UTENTE_ESECUZIONE
             || ''',''*'')||''%'') ';
       END IF;

       IF P_DATA_ESECUZIONE IS NOT NULL
       THEN
          d_select :=
                d_select
             || ' AND trunc(data_esecuzione) =TO_DATE ('''
             || P_DATA_ESECUZIONE
             || ''',''dd/mm/yyyy'') ';
       END IF;

       d_select :=
             d_select
          || ' ORDER BY smis.smistamento_dal DESC, smis.tipo_smistamento,des_uff_trasmissione,des_uff_smistamento,des_assegnatario';

       DBMS_OUTPUT.put_line (d_select);
       integrityPackage.LOG (d_select);

       OPEN d_result FOR d_select;

       RETURN (d_result);
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_SMISTAMENTI: ' || SQLERRM);
    END get_smistamenti;

    FUNCTION exists_risposta_successiva (
        p_id_documento IN VARCHAR2)
    RETURN number
    IS
       d_return number := 0;
    BEGIN
       select NVL(min(1),0)
         into d_return
         from riferimenti r, proto_view p, seg_tipi_documento t, documenti d
        where r.id_documento = p_id_documento
          and r.tipo_relazione = 'PROT_PREC'
          and p.id_documento = r.id_documento_rif
          and t.tipo_documento = p.tipo_documento
          and nvl(t.risposta, 'N') = 'Y'
          and d.id_documento = r.id_documento_rif
          and d.stato_documento not in ('CA', 'RE', 'PB')
       ;
       RETURN d_return;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;
    END;

    FUNCTION is_risposta_accesso_civico (
        p_id_documento IN VARCHAR2)
    RETURN number
    IS
       d_return number := 0;
    BEGIN
       select NVL(min(1),0)
         into d_return
         from riferimenti r, proto_view p, seg_tipi_documento t
        where r.id_documento_rif = p_id_documento
          and r.tipo_relazione = 'PROT_DAAC'
          and p.id_documento = r.id_documento
          and t.tipo_documento = p.tipo_documento
          and nvl(t.domanda_accesso, 'N') = 'Y'
       ;
       RETURN d_return;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;
    END;

    FUNCTION get_tipi_documento (
       p_codice_amm                   IN VARCHAR2,
       p_codice_aoo                   IN VARCHAR2,
       p_descrizione_tipo_documento   IN seg_tipi_documento.descrizione_tipo_documento%TYPE,
       p_oggetto                      IN seg_tipi_documento.oggetto%TYPE,
       p_class_cod                    IN seg_classificazioni.class_cod%TYPE,
       p_fascicolo_anno               IN seg_fascicoli.fascicolo_anno%TYPE,
       p_fascicolo_numero             IN seg_fascicoli.fascicolo_numero%TYPE,
       p_utente                       IN VARCHAR2,
       p_id_documento                 IN VARCHAR2,
       p_tipo_registro                IN VARCHAR2,
       p_tipo_documento               IN VARCHAR2,
       p_modalita                     IN VARCHAR2,
       p_rispondi                     IN NUMBER default 0,
       p_search_only_by_codice        IN NUMBER default 0)

       RETURN afc.t_ref_cursor
    IS
    /*************************************************************************************
      NOME:        GET_TIPI_DOCUMENTO
      DESCRIZIONE: Reastituisce
      RITORNO:
      Rev.  Data       Autore  Descrizione.
      000   05/12/2008 SN      Prima emissione.
      008   07/10/2016 MM      Esclusione del tipo di documento associata alla
                               stampa giornaliera del registro.
      014  20/09/2017  MM      Aggiunti campi per gestione tipo documento di risposta.
      018  18/12/2017  MM      Esclusione del tipo di documento associato ad un flusso
                               di lettera.
      019  08/01/2018  MM      Modificata per gestione parametro TIPO_DOC_SEARCH_BY_CODICE
      020  23/01/2018  MM      Modificata per gestione domanda di accesso
      021  02/02/2018  MM      Modificata per gestione risposta
           19/10/2018  SC      Non consente di selezionare tipo documento risposta accesso civico
                               se il protocollo NON è una risposta di accesso civico
      102  25/02/2019  MM      Gestione campo has_allegati del tipo documento
      103  09/04/2019  MM      Aggiunto upper sulla colonna tipo_documento perhè il parametro
                               arriva upper da flex e, se il codice è minuscolo (3del), non
                               lo trova.
    ****************************************************************************************/
       d_result          afc.t_ref_cursor;
       d_stato_pr        VARCHAR2 (10) := 'DP';
       d_data_pr         DATE;
       d_tipo_registro   VARCHAR2 (10);
       d_tipo_documento  VARCHAR2 (255) := p_tipo_documento;
       d_exists_risposta_successiva number;
       d_is_proto        number:=1;
       d_modalita        varchar2(100) := p_modalita;
       d_is_tipoDoc_search_by_codice number:=p_search_only_by_codice;
       d_is_risposta_accesso_civico number := 0;
       d_rispondi_o_select          NUMBER := p_rispondi;
       d_has_allegati               number := 0;
    BEGIN
       if d_is_tipoDoc_search_by_codice = 0 then
          if AG_PARAMETRO.GET_VALORE('TIPO_DOC_SEARCH_BY_CODICE',  p_codice_amm, p_codice_aoo, 'N') = 'Y' then
             d_is_tipoDoc_search_by_codice := 1;
          end if;
       end if;

       IF p_id_documento IS NOT NULL
       THEN
          BEGIN
             SELECT stato_pr, DATA, tipo_registro, NVL(d_tipo_documento, tipo_documento), modalita, decode(tipo_documento, d_tipo_documento, 1, d_rispondi_o_select), AG_TIPI_DOCUMENTO_UTILITY.HAS_ALLEGATI(NVL(d_tipo_documento, tipo_documento))
               INTO d_stato_pr, d_data_pr, d_tipo_registro, d_tipo_documento, d_modalita, d_rispondi_o_select, d_has_allegati
               FROM proto_view
              WHERE id_documento = p_id_documento;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                -- non è un protocollo, quindi non gestiamo i tipi di documento
                -- con sequenza di smistamenti
                d_is_proto := 0;
          END;
       END IF;

       IF d_tipo_registro IS NULL THEN
          d_tipo_registro := AG_PARAMETRO.GET_VALORE('TIPO_REGISTRO',  p_codice_amm, p_codice_aoo, '');
       END IF;

       IF nvl(d_stato_pr, 'DP') = 'PR' AND d_modalita = 'PAR' then
          d_is_risposta_accesso_civico := AG_DOCUMENTO_UTILITY.is_risposta_accesso_civico(p_id_documento);
       ELSE
          d_is_risposta_accesso_civico := 0;
       END IF;

       d_exists_risposta_successiva := AG_DOCUMENTO_UTILITY.exists_risposta_successiva(p_id_documento);

       OPEN d_result FOR
          SELECT *
            FROM (SELECT tido.tipo_documento,
                         tido.dataval_al,
                         tido.dataval_dal,
                         tido.descrizione_tipo_documento,
                         tido.oggetto,
                         tido.note,
                         tido.anni_conservazione,
                         tido.conservazione_illimitata,
                         regi.tipo_registro tipo_registro_documento,
                         regi.descrizione_tipo_registro,
                         NVL (d_modalita, tido.modalita) MODALITA,
                         tido.class_cod,
                         TO_CHAR (tido.class_dal, 'DD/MM/YYYY') class_dal,
                         clas.class_descr,
                         TO_CHAR (tido.fascicolo_anno) fascicolo_anno,
                         tido.fascicolo_numero,
                         fasc.fascicolo_oggetto,
                         docu_tido.codice_richiesta,
                         docu_tido.id_documento,
                         NVL (tido.segnatura_completa, 'Y') segnatura_completa,
                         NVL (tido.segnatura, 'Y') segnatura,
                         NVL (tido.risposta, 'N') risposta,
                         DECODE (tido.tipo_doc_risposta,
                                 '--', NULL,
                                 tido.tipo_doc_risposta)
                            tipo_doc_risposta,
                         agspr_tipi_protocollo_pkg.get_codice (
                            tido_risposta.id_tipo_protocollo,
                            tido_risposta.codice_amministrazione,
                            tido_risposta.codice_aoo)
                            tipo_protocollo_risposta,
                         tido.unita_esibente,
                         AG_TIPI_DOCUMENTO_UTILITY.HAS_SEQUENZA_SMISTAMENTI (
                            tido.tipo_documento)
                            has_sequenza_smistamenti,
                         d_exists_risposta_successiva exists_risposta_successiva,
                         tido.domanda_accesso domanda_accesso_civico,
                         DECODE (
                            NVL (d_stato_pr, 'DP'),
                            'PR', d_is_risposta_accesso_civico,
                            AG_TIPI_DOCUMENTO_UTILITY.IS_RISPOSTA_ACCESSO_CIVICO (
                               tido.tipo_documento))
                            is_risposta_accesso_civico,
                            AG_TIPI_DOCUMENTO_UTILITY.HAS_ALLEGATI(tido.tipo_documento) has_allegati
                    FROM seg_tipi_documento tido,
                         seg_classificazioni clas,
                         seg_fascicoli fasc,
                         seg_registri regi,
                         documenti docu_tido,
                         documenti docu_clas,
                         documenti docu_fasc,
                         documenti docu_regi,
                         cartelle cart_clas,
                         cartelle cart_fasc,
                         seg_tipi_documento tido_risposta
                   WHERE     tido_risposta.tipo_documento(+) = tido.tipo_doc_risposta
                         AND docu_tido.id_documento = tido.id_documento
                         AND docu_tido.stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND (   NVL (tido.risposta, 'N') = 'N'
                              OR (    d_rispondi_o_select = 1
                                  AND upper(tido.tipo_documento) LIKE
                                         UPPER (NVL (d_tipo_documento, '%'))))
                         AND ag_tipi_documento_utility.is_associato_flusso (
                                tido.tipo_documento) = 0
                         AND tido.class_cod = clas.class_cod(+)
                         AND tido.class_dal = clas.class_dal(+)
                         AND docu_clas.id_documento(+) = clas.id_documento
                         AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                         AND cart_clas.id_documento_profilo(+) = docu_clas.id_documento

                         AND NVL (cart_clas.stato, 'BO') <> 'CA'
                         AND fasc.class_cod(+) = tido.class_cod
                         AND fasc.class_dal(+) = tido.class_dal
                         AND tido.fascicolo_anno = fasc.fascicolo_anno(+)
                         AND tido.fascicolo_numero = fasc.fascicolo_numero(+)
                         AND docu_fasc.id_documento(+) = fasc.id_documento
                         AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                         AND cart_fasc.id_documento_profilo(+) = docu_fasc.id_documento

                         AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                         AND NVL (tido.tipo_registro_documento, d_tipo_registro) =
                                NVL (
                                   p_tipo_registro,
                                   NVL (tido.tipo_registro_documento, d_tipo_registro))
                         AND NVL (tido.tipo_registro_documento, d_tipo_registro) =
                                regi.tipo_registro(+)
                         AND docu_regi.id_documento(+) = regi.id_documento
                         AND NVL (docu_regi.stato_documento, 'BO') NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                         AND NVL (regi.anno_reg, TO_CHAR (SYSDATE, 'YYYY')) =
                                (SELECT NVL (MAX (regi2.anno_reg),
                                             TO_CHAR (SYSDATE, 'YYYY'))
                                   FROM seg_registri regi2, documenti docu_regi2
                                  WHERE     NVL (tido.tipo_registro_documento,
                                                 d_tipo_registro) = regi2.tipo_registro

                                        AND docu_regi2.id_documento =
                                               regi2.id_documento
                                        AND docu_regi2.stato_documento NOT IN ('CA',
                                                                               'RE',
                                                                               'PB'))
                         AND tido.codice_amministrazione = p_codice_amm
                         AND tido.codice_aoo = p_codice_aoo
                         AND UPPER (tido.descrizione_tipo_documento) LIKE
                                UPPER (p_descrizione_tipo_documento) || '%'
                         AND NVL (UPPER (tido.oggetto), ' ') LIKE
                                UPPER (p_oggetto) || '%'
                         AND (   (    (   tido.fascicolo_anno = p_fascicolo_anno
                                       OR p_fascicolo_anno IS NULL)
                                  AND (   tido.fascicolo_numero = p_fascicolo_numero
                                       OR p_fascicolo_numero IS NULL)
                                  AND (   tido.class_cod = p_class_cod
                                       OR p_class_cod IS NULL))
                              OR (    tido.fascicolo_anno IS NULL
                                  AND tido.fascicolo_numero IS NULL
                                  AND tido.class_cod IS NULL))
                         AND tido.tipo_documento IS NOT NULL
                         AND (   (    d_stato_pr = 'DP'
                                  AND TRUNC (SYSDATE) BETWEEN NVL (
                                                                 tido.dataval_dal,
                                                                 TO_DATE (2222222, 'j'))


                                                          AND NVL (
                                                                 tido.dataval_al,
                                                                 TO_DATE (3333333, 'j')))


                              OR (    d_stato_pr <> 'DP'
                                  AND TRUNC (d_data_pr) BETWEEN NVL (
                                                                   tido.dataval_dal,
                                                                   TO_DATE (2222222,

                                                                            'j'))
                                                            AND NVL (
                                                                   tido.dataval_al,
                                                                   TO_DATE (3333333,

                                                                            'j'))))
                         AND upper(tido.tipo_documento) LIKE
                                    DECODE (d_is_tipoDoc_search_by_codice, 1, UPPER (NVL (d_tipo_documento, '%'))
                                , '%')
                         AND tido.tipo_documento <> ag_parametro.get_valore (
                                                       'TIPO_DOC_REG_PROT',
                                                       p_codice_amm,
                                                       p_codice_aoo,
                                                       ' ')
                         AND ag_competenze_tipo_documento.utilizzo_in_prot (
                                tido.id_Documento,
                                p_utente) = 1
                         AND (   ag_tipi_documento_utility.has_sequenza_smistamenti (
                                    tido.tipo_documento) = 0
                              OR (d_stato_pr = 'DP' AND d_is_proto = 1))
                         AND NVL (tido.modalita, NVL (d_modalita, ' ')) =
                                NVL (NVL (d_modalita, tido.modalita), ' ')
                  UNION
                  SELECT tido.tipo_documento,
                         tido.dataval_al,
                         tido.dataval_dal,
                         tido.descrizione_tipo_documento desc_docu,
                         tido.oggetto,
                         tido.note,
                         tido.anni_conservazione,
                         tido.conservazione_illimitata,
                         regi.tipo_registro tipo_registro_documento,
                         regi.descrizione_tipo_registro,
                         d_modalita,
                         tido.class_cod,
                         TO_CHAR (tido.class_dal, 'DD/MM/YYYY') class_dal,
                         clas.class_descr,
                         TO_CHAR (tido.fascicolo_anno) fascicolo_anno,
                         tido.fascicolo_numero,
                         fasc.fascicolo_oggetto,
                         docu_tido.codice_richiesta,
                         docu_tido.id_documento,
                         NVL (tido.segnatura_completa, 'Y') segnatura_completa,
                         NVL (tido.segnatura, 'Y') segnatura,
                         NVL (tido.risposta, 'N') risposta,
                         DECODE (tido.tipo_doc_risposta,
                                 '--', NULL,
                                 tido.tipo_doc_risposta)
                            tipo_doc_risposta,
                         agspr_tipi_protocollo_pkg.get_codice (
                            tido_risposta.id_tipo_protocollo,
                            tido_risposta.codice_amministrazione,
                            tido_risposta.codice_aoo)
                            tipo_protocollo_risposta,
                         tido.unita_esibente,
                         ag_tipi_documento_utility.has_sequenza_smistamenti (
                            tido.tipo_documento)
                            has_sequenza_smistamenti,
                         d_exists_risposta_successiva exists_risposta_successiva,
                         tido.domanda_accesso,
                         d_is_risposta_accesso_civico is_risposta_accesso_civico,
                         d_has_allegati
                    FROM seg_tipi_documento tido,
                         seg_classificazioni clas,
                         seg_fascicoli fasc,
                         seg_registri regi,
                         documenti docu_tido,
                         documenti docu_clas,
                         documenti docu_fasc,
                         documenti docu_regi,
                         cartelle cart_clas,
                         cartelle cart_fasc,
                         seg_tipi_documento tido_risposta
                   WHERE     tido_risposta.tipo_documento(+) = tido.tipo_doc_risposta
                         AND docu_tido.id_documento = tido.id_documento
                         AND docu_tido.stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND tido.class_cod = clas.class_cod(+)
                         AND tido.class_dal = clas.class_dal(+)
                         AND docu_clas.id_documento(+) = clas.id_documento
                         AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                         AND cart_clas.id_documento_profilo(+) = docu_clas.id_documento
                         AND NVL (cart_clas.stato, 'BO') <> 'CA'
                         AND fasc.class_cod(+) = tido.class_cod
                         AND fasc.class_dal(+) = tido.class_dal
                         AND tido.fascicolo_anno = fasc.fascicolo_anno(+)
                         AND tido.fascicolo_numero = fasc.fascicolo_numero(+)
                         AND docu_fasc.id_documento(+) = fasc.id_documento
                         AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                         AND cart_fasc.id_documento_profilo(+) = docu_fasc.id_documento
                         AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                         AND d_tipo_registro = regi.tipo_registro(+)
                         AND docu_regi.id_documento(+) = regi.id_documento
                         AND REGI.ANNO_REG = TO_CHAR (d_data_pr, 'YYYY')
                         AND NVL (docu_regi.stato_documento, 'BO') NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                         AND tido.codice_amministrazione = p_codice_amm
                         AND tido.codice_aoo = p_codice_aoo
                         AND d_stato_pr <> 'DP'
                         AND TRUNC (d_data_pr) BETWEEN NVL (tido.dataval_dal,

                                                            TO_DATE (2222222, 'j'))
                                                   AND NVL (tido.dataval_al,

                                                            TO_DATE (3333333, 'j'))
                         AND upper(tido.tipo_documento) = upper(d_tipo_documento)
                         AND DECODE (
                                ag_tipi_documento_utility.is_risposta_accesso_civico (
                                   d_tipo_documento),
                                1, d_is_risposta_accesso_civico,
                                1) = 1
                  UNION
                  SELECT TO_CHAR (NULL),
                         TO_DATE (NULL),
                         TO_DATE (NULL),
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
                         TO_CHAR (NULL),
                         TO_CHAR (NULL),
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
                         TO_CHAR (NULL),
                         TO_NUMBER (NULL),
                         TO_NUMBER (NULL)
                    FROM DUAL) a,
                 DUAL
           WHERE    gdm_competenza.gdm_verifica ('DOCUMENTI',
                                                 TO_CHAR (a.id_documento),
                                                 'L',
                                                 p_utente,
                                                 'GDM')
                 || dummy = '1X'
        ORDER BY 4;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_TIPI_DOCUMENTO: ' || SQLERRM);
    END get_tipi_documento;

    FUNCTION get_tipi_frase (
       p_codice_amm   IN VARCHAR2,
       p_codice_aoo   IN VARCHAR2,
       p_oggetto      IN seg_tipi_documento.oggetto%TYPE)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_TIPI_DOCUMENTO
          DESCRIZIONE: Reastituisce
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  SN  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT seg_tipi_frase.*
              FROM seg_tipi_frase, documenti
             WHERE     oggetto LIKE ('%' || UPPER (p_oggetto) || '%')
                   AND codice_amministrazione = p_codice_amm
                   AND codice_aoo = p_codice_aoo
                   AND documenti.id_documento = seg_tipi_frase.id_documento
                   AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
          ORDER BY oggetto;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_TIPI_FRASE: ' || SQLERRM);
    END get_tipi_frase;

    FUNCTION get_tipi_movimento_select (p_codice_amm   IN VARCHAR2,
                                        p_codice_aoo   IN VARCHAR2,
                                        p_stato_pr     IN VARCHAR2,
                                        p_utente       IN VARCHAR2)
       RETURN VARCHAR2
    IS
       d_result   VARCHAR2 (32767);
    BEGIN
       d_result :=
             'SELECT INITCAP (movimento) movimento, tipo_movimento AS modalita
            FROM seg_movimenti, documenti
           WHERE codice_amministrazione = '''
          || p_codice_amm
          || '''
             AND codice_aoo = '''
          || p_codice_aoo
          || '''
             AND (   gdm_competenza.gdm_verifica (''DOCUMENTI'',
                                                  seg_movimenti.id_documento,
                                                  ''L'',
                                                  '''
          || p_utente
          || ''',
                                                  ''GDM''
                                                 ) = 1
                  OR '''
          || p_stato_pr
          || ''' <> ''DP''
                 )
             AND documenti.id_documento = seg_movimenti.id_documento
             AND documenti.stato_documento NOT IN (''CA'', ''RE'', ''PB'')
             order by 1';
       RETURN d_result;
    END;


    FUNCTION get_tipi_consegna (p_codice_amm   IN VARCHAR2,
                                p_codice_aoo   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_ref_cursor   afc.t_ref_cursor;
       d_default      varchar2(100);
    BEGIN
       d_default := upper(ag_parametro.get_valore ('TIPO_CONSEGNA_',
                                                  p_codice_amm,
                                                  p_codice_aoo,
                                                  'COMPLETA'));
       OPEN d_ref_cursor FOR
            SELECT 'COMPLETA' tipo_consegna, 'Completa' descrizione, decode(d_default, 'COMPLETA', 1, 99) ordine
              FROM DUAL
             WHERE INSTR(ag_parametro.get_valore ('TIPI_CONSEGNA_',
                                                  p_codice_amm,
                                                  p_codice_aoo,
                                                  'BREVE#COMPLETA#SINTETICA'),
                         'COMPLETA') > 0
            UNION
            SELECT 'BREVE', 'Breve', decode(d_default, 'BREVE', 1, 99)
              FROM DUAL
             WHERE INSTR(ag_parametro.get_valore ('TIPI_CONSEGNA_',
                                                  p_codice_amm,
                                                  p_codice_aoo,
                                                  'BREVE#COMPLETA#SINTETICA'),
                         'BREVE') > 0
            UNION
            SELECT 'SINTETICA', 'Sintetica', decode(d_default, 'SINTETICA', 1, 99)
              FROM DUAL
             WHERE INSTR(ag_parametro.get_valore ('TIPI_CONSEGNA_',
                                                  p_codice_amm,
                                                  p_codice_aoo,
                                                  'BREVE#COMPLETA#SINTETICA'),
                         'SINTETICA') > 0
          order by 3, 2;
       return d_ref_cursor;
    END;

    FUNCTION get_tipi_movimento (p_codice_amm   IN VARCHAR2,
                                 p_codice_aoo   IN VARCHAR2,
                                 p_stato_pr     IN VARCHAR2,
                                 p_utente       IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
           NOME:        GET_TIPI_MOVIMENTO
           DESCRIZIONE: Restituisce un cursore con movimenti e codici della
                        tabella SEG_MOVIMENTI.
           RITORNO:
           ANNOTAZIONI:
           Rev.  Data       Autore  Descrizione.
           00    05/12/2008  SN  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          get_tipi_movimento_select (p_codice_amm,
                                     p_codice_aoo,
                                     p_stato_pr,
                                     p_utente);

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_TIPI_MOVIMENTO: ' || SQLERRM);
    END;

    FUNCTION get_tipi_registro (p_codice_amm      IN VARCHAR2,
                                p_codice_aoo      IN VARCHAR2,
                                p_tipo_registro   IN VARCHAR2 DEFAULT '%',
                                p_anno_reg        IN NUMBER DEFAULT NULL)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_TIPI_REGISTRO
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  SN  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
            SELECT tipo_registro, descrizione_tipo_registro
              FROM seg_registri, documenti
             WHERE     codice_amministrazione = p_codice_amm
                   AND codice_aoo = p_codice_aoo
                   AND documenti.id_documento = seg_registri.id_documento
                   AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                   AND tipo_registro LIKE p_tipo_registro
                   AND anno_reg = NVL (p_anno_reg, anno_reg)
          ORDER BY descrizione_tipo_registro;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_TIPI_REGISTRO: ' || SQLERRM);
    END get_tipi_registro;

    FUNCTION get_uffici_esibenti (p_data         IN VARCHAR2,
                                  p_stato_pr     IN VARCHAR2,
                                  p_codice_amm   IN VARCHAR2,
                                  p_codice_aoo   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        GET_UFFICI_ESIBENTI
          DESCRIZIONE: lista delgi ufficii che possono produrre il documento. E' visibile solo per documenti interni o in partenza
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  SN  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT seg_unita.unita AS unita_esibente, seg_unita.nome
            FROM seg_unita
           WHERE     NVL (p_stato_pr, 'DP') = 'DP'
                 AND seg_unita.codice_amministrazione = p_codice_amm
                 AND seg_unita.codice_aoo = p_codice_aoo
                 AND al IS NULL
          UNION
          SELECT seg_unita.unita, seg_unita.nome
            FROM seg_unita
           WHERE     NVL (p_stato_pr, 'DP') <> 'DP'
                 AND seg_unita.codice_amministrazione = p_codice_amm
                 AND seg_unita.codice_aoo = p_codice_aoo
                 AND seg_unita.dal <=
                        TO_DATE (NVL (p_data, SYSDATE), 'dd/mm/yyyy')
                 AND (   seg_unita.al >=
                            TO_DATE (NVL (p_data, SYSDATE), 'dd/mm/yyyy')
                      OR seg_unita.al IS NULL)
          ORDER BY 2;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_UFFICI_ESIBENTI: ' || SQLERRM);
    END get_uffici_esibenti;

    FUNCTION get_uffici_esibenti_tree (p_utente       IN ad4_utenti.utente%TYPE,
                                       p_codice_amm   IN VARCHAR2,
                                       p_codice_aoo   IN VARCHAR2)
       RETURN CLOB
    IS
       /*****************************************************************************
          NOME:        GET_UFFICI_ESIBENTI_TREE
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    15/02/2011  MMUR  Prima emissione.
       ********************************************************************************/
       d_result                   CLOB := EMPTY_CLOB ();
       d_xml                      VARCHAR2 (32000) := '';
       d_amount                   BINARY_INTEGER := 32767;
       d_unita                    afc.t_ref_cursor;
       prog_unita_organizzativa   NUMBER;
       codice_uo                  VARCHAR2 (200);
       descrizione                VARCHAR2 (200);
       radice                     VARCHAR2 (400);
       progr_radice               VARCHAR2 (200);
       cod_radice                 VARCHAR2 (200);
       descr_radice               VARCHAR2 (200);
       radici                     VARCHAR2 (1000) := ' ';
       d_ottica                   VARCHAR2 (1000);
    BEGIN
       d_ottica :=
          ag_parametro.get_valore ('SO_OTTICA_PROT',
                                   p_codice_amm,
                                   p_codice_aoo,
                                   '');
       DBMS_LOB.createtemporary (d_result, TRUE, DBMS_LOB.CALL);
       d_xml := '<ROWSET>' || CHR (10) || CHR (13);
       DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
       d_unita :=
          so4_ags_pkg.ad4_utente_get_unita (p_utente,
                                            NULL,
                                            d_ottica,
                                            SYSDATE,
                                            'SI',
                                            NULL);

       IF d_unita%ISOPEN
       THEN
          LOOP
             BEGIN
                FETCH d_unita
                   INTO prog_unita_organizzativa, codice_uo, descrizione;

                EXIT WHEN d_unita%NOTFOUND;
                radice :=
                   so4_ags_pkg.unita_get_radice (prog_unita_organizzativa,
                                                 d_ottica);
                progr_radice := SUBSTR (radice, 0, INSTR (radice, '#') - 1);
                radice :=
                   SUBSTR (radice, INSTR (radice, '#') + 1, LENGTH (radice));
                cod_radice := SUBSTR (radice, 0, INSTR (radice, '#') - 1);

                --descr_radice := SUBSTR (radice,  INSTR (radice, '#')+1, LENGTH (radice));
                BEGIN
                   SELECT nome
                     INTO descr_radice
                     FROM seg_unita
                    WHERE unita = cod_radice AND al IS NULL;
                EXCEPTION
                   WHEN OTHERS
                   THEN
                      descr_radice :=
                         SUBSTR (radice,
                                 INSTR (radice, '#') + 1,
                                 LENGTH (radice));
                END;

                IF INSTR (radici, '<radice>' || radice || '<radice>') = 0
                THEN
                   d_xml :=
                         '<ALBERO nome= "'
                      || descr_radice
                      || '" ni='''
                      || cod_radice
                      || '''>';
                   d_amount := LENGTH (d_xml);
                   DBMS_LOB.writeappend (d_result, d_amount, d_xml);
                   ag_unita_utility_flex.get_unita_figlie_e_componenti (
                      cod_radice,
                      p_codice_amm,
                      p_codice_aoo,
                      'no',
                      d_ottica,
                      0,
                      d_result,
                      NULL,
                      0,
                      0);
                   d_xml := '</ALBERO>';
                   DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
                   radici := radici || '<radice>' || radice || '<radice>';
                END IF;
             END;
          END LOOP;
       END IF;

       d_xml := '</ROWSET>' || CHR (10) || CHR (13);
       DBMS_LOB.writeappend (d_result, LENGTH (d_xml), d_xml);
       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
                'AG_DOCUMENTO_UTILITY.GET_UFFICI_ESIBENTI_TREE: '
             || SQLERRM
             || -' - ');
    END get_uffici_esibenti_tree;

    FUNCTION exists_rich_ann_rif (p_codice_amm   IN VARCHAR2,
                                  p_codice_aoo   IN VARCHAR2,
                                  p_idrif        IN seg_note.idrif%TYPE)
       RETURN NUMBER
    IS
       d_is_gestito   NUMBER := 0;
    BEGIN
       SELECT COUNT (1)
         INTO d_is_gestito
         FROM seg_note, documenti
        WHERE     codice_amministrazione = p_codice_amm
              AND codice_aoo = p_codice_aoo
              AND idrif = p_idrif
              AND documenti.id_documento = seg_note.id_documento
              AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB');

       IF d_is_gestito > 0
       THEN
          d_is_gestito := 1;
       END IF;

       RETURN d_is_gestito;
    END;

    FUNCTION get_rich_ann_rifiutate (
       p_codice_amm             IN VARCHAR2,
       p_codice_aoo             IN VARCHAR2,
       p_idrif                  IN seg_note.idrif%TYPE,
       p_data_rich_ann          IN VARCHAR2,
       p_nome_utente_rich_ann   IN seg_note.utente_richiesta_ann%TYPE,
       p_motivo_ann             IN seg_note.motivo_ann%TYPE,
       p_note                   IN seg_note.note%TYPE)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT seg_note.*,
                 DECODE (utente_richiesta_ann,
                         '', '',
                         ag_soggetto.get_denominazione (utente_richiesta_ann))
                    nome_utente_rich_ann
            FROM seg_note, documenti
           WHERE     codice_amministrazione = p_codice_amm
                 AND codice_aoo = p_codice_aoo
                 AND idrif = p_idrif
                 AND documenti.id_documento = seg_note.id_documento
                 AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                 AND NVL (TO_CHAR (data_richiesta_ann, 'dd/mm/yyyy'), ' ') LIKE
                        NVL (p_data_rich_ann, '%')
                 AND NVL (
                        UPPER (
                           ag_soggetto.get_denominazione (
                              utente_richiesta_ann)),
                        ' ') LIKE
                        (UPPER ('%' || p_nome_utente_rich_ann || '%'))
                 AND NVL (UPPER (motivo_ann), ' ') LIKE
                        (UPPER ('%' || p_motivo_ann || '%'))
                 AND NVL (UPPER (note), ' ') LIKE
                        (UPPER ('%' || p_note || '%'));

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_RICH_ANN_RIFIUTATE: ' || SQLERRM);
    END;

    FUNCTION check_protocollo_precedente (
       p_codice_amm      IN VARCHAR2,
       p_codice_aoo      IN VARCHAR2,
       p_prot_anno       IN proto_view.anno%TYPE,
       p_prot_numero     IN proto_view.numero%TYPE,
       p_tipo_registro   IN VARCHAR2)
       RETURN NUMBER
    IS
       /*****************************************************************************
          NOME:        CHECK_PROTOCOLLO_PRECEDENTE
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          000   05/12/2008 SN  Prima emissione.
          006   14/08/2015 MM  Gestione tipo registro di default.
       ********************************************************************************/
       d_result          NUMBER;
       d_tipo_registro   VARCHAR2 (100)
                            := NVL (p_tipo_registro,
                                    AG_PARAMETRO.GET_VALORE ('TIPO_REGISTRO',
                                                             p_codice_Amm,
                                                             p_codice_aoo,
                                                             ''));
    BEGIN
       SELECT COUNT (id_documento) prot
         INTO d_result
         FROM proto_view
        WHERE     anno = p_prot_anno
              AND numero = p_prot_numero
              AND tipo_registro = d_tipo_registro
              AND codice_amministrazione = p_codice_amm
              AND codice_aoo = p_codice_aoo
              AND stato_pr = 'PR';

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.CHECK_PROTOCOLLO_PRECEDENTE: ' || SQLERRM);
    END check_protocollo_precedente;

    FUNCTION get_rapporti_doc (p_id_documento    IN VARCHAR2,
                               p_tipo_rapporto   IN VARCHAR2)
       RETURN CLOB
    IS
       d_return   CLOB;
       d_loop     INTEGER := 0;
    BEGIN
       FOR c_rapp
          IN (  SELECT    DECODE (
                             sogg.ni_persona,
                             NULL, DECODE (
                                      sogg.ni_amm,
                                      NULL, DECODE (
                                               sogg.ni_impresa,
                                               NULL, sogg.cognome_per_segnatura,
                                               sogg.denominazione_per_segnatura),
                                      DECODE (sogg.tipo,
                                              'AMM', sogg.descrizione_amm,
                                              sogg.descrizione_aoo)),
                                sogg.cognome_per_segnatura
                             || ' '
                             || sogg.nome_per_segnatura)
                       || ' '
                       || sogg.indirizzo_per_segnatura
                       || ' '
                       || sogg.cap_per_segnatura
                       || ' '
                       || sogg.comune_per_segnatura
                       || ' '
                       || DECODE (sogg.provincia_per_segnatura,
                                  NULL, '',
                                  '(' || sogg.provincia_per_segnatura || ')')
                          dati
                  FROM proto_view prot, seg_soggetti_protocollo sogg, documenti
                 WHERE     prot.id_documento = p_id_documento
                       AND sogg.idrif = prot.idrif
                       AND documenti.id_documento = sogg.id_documento
                       AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA',
                                                                         'RE',
                                                                         'PB')
                       AND sogg.tipo_rapporto <> 'DUMMY'
                       AND sogg.tipo_rapporto LIKE p_tipo_rapporto
              ORDER BY sogg.id_documento)
       LOOP
          d_loop := d_loop + 1;

          IF d_loop > 1
          THEN
             d_return := d_return || TO_CLOB (CHR (10));
          END IF;

          d_return := d_return || TO_CLOB (c_rapp.dati);
       END LOOP;

       RETURN d_return;
    END;

    FUNCTION check_estremi_documento (
       p_data_documento     IN VARCHAR2,
       p_numero_documento   IN proto_view.numero_documento%TYPE,
       p_codice_amm         IN VARCHAR2,
       p_codice_aoo         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
          NOME:        CHECK_ESTREMI_DOCUMENTO
          DESCRIZIONE:
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          00    05/12/2008  SN  Prima emissione.
       ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT get_rapporti_doc (prot.id_documento) dati,
                 prot.anno,
                 prot.numero,
                 prot.DATA
            FROM proto_view prot, documenti
           WHERE     prot.numero_documento = p_numero_documento
                 AND prot.data_documento =
                        TO_DATE (p_data_documento, 'dd/mm/yyyy')
                 AND documenti.id_documento = prot.id_documento
                 AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA',
                                                                   'RE',
                                                                   'PB')
                 AND prot.codice_amministrazione = p_codice_amm
                 AND prot.codice_aoo = p_codice_aoo
                 AND prot.stato_pr = 'PR';

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.CHECK_ESTREMI_DOCUMENTO: ' || SQLERRM);
    END check_estremi_documento;

    FUNCTION get_classificazioni_secondarie (p_id_documento   IN VARCHAR2,
                                             p_codice_amm     IN VARCHAR2,
                                             p_codice_aoo     IN VARCHAR2,
                                             p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
    BEGIN
       RETURN ag_fascicolo_utility.get_classificazioni_secondarie (
                 p_id_documento,
                 p_codice_amm,
                 p_codice_aoo,
                 p_utente);
    END;

    FUNCTION get_area_cm_cr (p_id_documento IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_ref_cursor   afc.t_ref_cursor;
    BEGIN
       OPEN d_ref_cursor FOR
          SELECT docu.area area,
                 docu.codice_richiesta codice_richiesta,
                 tido.nome codice_modello
            FROM documenti docu, tipi_documento tido
           WHERE     docu.id_documento = p_id_documento
                 AND tido.id_libreria = docu.id_libreria
                 AND tido.id_tipodoc = docu.id_tipodoc;

       RETURN d_ref_cursor;
    END;

    FUNCTION get_documento (p_id_documento IN VARCHAR2, p_utente IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /******************************************************************************
        NOME:        get_rows
        DESCRIZIONE: Ritorna il risultato di una query su PROTO_VIEW.
        PARAMETRI:   Chiavi e attributi della table
        RITORNA:     Un ref_cursor che punta al risultato della query.
        NOTE:        .
       ******************************************************************************/
       d_ref_cursor   afc.t_ref_cursor;
       d_stringa      VARCHAR2 (32767);
       d_campo        VARCHAR2 (100);
       d_tipo         VARCHAR2 (100);
       d_modello      VARCHAR2 (1000);
       d_area         VARCHAR2 (1000);
    BEGIN
       -- prende tutti e soli i campi presenti in M_PROTOCOLLO.
       SELECT nome, area_modello
         INTO d_modello, d_area
         FROM tipi_documento
        WHERE id_tipodoc IN (SELECT id_tipodoc
                               FROM documenti
                              WHERE id_documento = p_id_documento);

       IF c_campi%ISOPEN
       THEN
          CLOSE c_campi;
       END IF;

       OPEN c_campi (d_area, d_modello);

       FETCH c_campi INTO d_campo;

       WHILE c_campi%FOUND
       LOOP
          BEGIN
             SELECT column_name, data_type
               INTO d_campo, d_tipo
               FROM user_tab_columns
              WHERE     table_name = 'PROTO_VIEW'
                    AND column_name = d_campo
                    AND column_name NOT IN ('MASTER',
                                            'DESCRIZIONE_CLASSIFICA',
                                            'DESCRIZIONE_CLASSIFICA_VISU',
                                            'DESCRIZIONE_FASCICOLO',
                                            'DESCRIZIONE_FASCICOLO_VISU',
                                            'UBICAZIONE_FASCICOLO',
                                            'STATO_SCARTO');

             d_campo := 'proto_view.' || d_campo;
             d_stringa := d_stringa || d_campo || ', ';
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                NULL;
          END;

          FETCH c_campi INTO d_campo;
       END LOOP;

       CLOSE c_campi;

       --, nvl(seg_fascicoli.stato_scarto, ''**'') fasc_stato_scarto
       d_stringa :=
             'SELECT '
          || d_stringa
          || '   nvl(proto_view.stato_scarto,''**'') stato_scarto,
                 ''Y'' MASTER,
                 seg_classificazioni.class_descr descrizione_classifica,
                 decode(seg_fascicoli.fascicolo_numero, null, '''', decode(seg_fascicoli.riservato, ''Y'', DECODE(GDM_COMPETENZA.GDM_VERIFICA (''VIEW_CARTELLA'',
                                                     TO_CHAR (seg_fascicoli.ID_VIEWCARTELLA),
                                                     ''L'',
                                                     '''
          || p_utente
          || ''',
                                                     ''GDM'',
                                                     TO_CHAR (SYSDATE, ''DD/MM/YYYY''),
                                                     ''N'')
                       , 1
                       , seg_fascicoli.fascicolo_oggetto
                       , ''RISERVATO''), seg_fascicoli.fascicolo_oggetto)) descrizione_fascicolo,
                 seg_classificazioni.class_descr descrizione_classifica_visu,
                 decode(seg_fascicoli.fascicolo_numero, null, '''', decode(seg_fascicoli.riservato, ''Y'', DECODE(GDM_COMPETENZA.GDM_VERIFICA (''VIEW_CARTELLA'',
                                                     TO_CHAR (seg_fascicoli.ID_VIEWCARTELLA),
                                                     ''L'',
                                                     '''
          || p_utente
          || ''',
                                                     ''GDM'',
                                                     TO_CHAR (SYSDATE, ''DD/MM/YYYY''),
                                                     ''N'')
                       , 1
                       , seg_fascicoli.fascicolo_oggetto
                       , ''RISERVATO''), seg_fascicoli.fascicolo_oggetto)) descrizione_fascicolo_visu,
                 ag_fascicolo_utility.get_desc_ubicazione(proto_view.class_cod,
                                                          to_char(proto_view.class_dal,''dd/mm/yyyy''),
                                                          proto_view.fascicolo_anno,
                                                          proto_view.fascicolo_numero) ubicazione_fascicolo,


                           AG_TIPI_DOCUMENTO_UTILITY.HAS_SEQUENZA_SMISTAMENTI(proto_view.tipo_documento) has_sequenza_smistamenti,
                           AG_DOCUMENTO_UTILITY.exists_risposta_successiva(proto_view.ID_DOCUMENTO) exists_risposta_successiva,
                           AG_TIPI_DOCUMENTO_UTILITY.get_domanda_accesso_civico(proto_view.tipo_documento) domanda_accesso_civico,
                           AG_DOCUMENTO_UTILITY.is_risposta_accesso_civico(proto_view.ID_DOCUMENTO) is_risposta_accesso_civico,
                           AG_TIPI_DOCUMENTO_UTILITY.get_tipo_protocollo_risposta(proto_view.tipo_documento, proto_view.codice_amministrazione, proto_view.codice_aoo, decode(data,null,sysdate,data)) tipo_protocollo_risposta,
                           AG_TIPI_DOCUMENTO_UTILITY.get_tipo_doc_risposta (proto_view.tipo_documento) tipo_doc_risposta,
                           AG_TIPI_DOCUMENTO_UTILITY.get_risposta (proto_view.tipo_documento) risposta

            FROM proto_view, documenti, tipi_documento
               , (select seg_classificazioni.*
                    from seg_classificazioni, documenti docu_clas, cartelle cart_clas
                   where docu_clas.id_documento = seg_classificazioni.id_documento
                     and docu_clas.stato_documento not in (''CA'',''RE'',''PB'')
                     and cart_clas.id_documento_profilo = seg_classificazioni.id_documento
                     and nvl(cart_clas.stato, ''BO'') <> ''CA''
                 ) seg_classificazioni
               , (select seg_fascicoli.*, view_cart.id_viewcartella
                    from seg_fascicoli, documenti docu_fasc, cartelle cart_fasc
                       , view_cartella view_cart
                   where docu_fasc.id_documento = seg_fascicoli.id_documento
                     and docu_fasc.stato_documento not in (''CA'',''RE'',''PB'')
                     and cart_fasc.id_documento_profilo = seg_fascicoli.id_documento
                     and nvl(cart_fasc.stato, ''BO'') <> ''CA''
                     and view_cart.id_cartella = cart_fasc.id_cartella
                 ) seg_fascicoli
           WHERE seg_fascicoli.codice_amministrazione(+) = proto_view.codice_amministrazione
             AND seg_fascicoli.codice_aoo(+) = proto_view.codice_aoo
             AND seg_fascicoli.class_cod(+) = proto_view.class_cod
             AND seg_fascicoli.class_dal(+) = proto_view.class_dal
             AND seg_fascicoli.fascicolo_anno(+) = proto_view.fascicolo_anno
             AND seg_fascicoli.fascicolo_numero(+) = proto_view.fascicolo_numero
             AND seg_classificazioni.codice_amministrazione(+) = proto_view.codice_amministrazione
             AND seg_classificazioni.codice_aoo(+) = proto_view.codice_aoo
             AND seg_classificazioni.class_cod(+) = proto_view.class_cod
             AND seg_classificazioni.class_dal(+) = proto_view.class_dal
             AND documenti.id_documento = proto_view.id_documento
             AND documenti.id_tipodoc = tipi_documento.id_tipodoc
             AND tipi_documento.nome in (''M_PROTOCOLLO'', ''M_PROTOCOLLO_INTEROPERABILITA'')
             AND tipi_documento.area_modello = ''SEGRETERIA.PROTOCOLLO''
             AND proto_view.id_documento = '
          || p_id_documento;


       OPEN d_ref_cursor FOR d_stringa;

       RETURN d_ref_cursor;
    END;

    FUNCTION get_empty_row (
       p_area      IN VARCHAR2 DEFAULT 'SEGRETERIA.PROTOCOLLO',
       p_modello   IN VARCHAR2 DEFAULT 'M_PROTOCOLLO',
       p_rowtag    IN VARCHAR2 DEFAULT 'ROW',
       p_table     IN VARCHAR2 DEFAULT 'PROTO_VIEW')
       RETURN CLOB
    IS
       retval      CLOB;
       d_campo     VARCHAR2 (100);
       d_valore    VARCHAR2 (100);
       d_stringa   VARCHAR2 (32767) := '<' || NVL (p_rowtag, 'ROW') || '>';
    BEGIN
       -- prende tutti e soli i campi presenti in M_PROTOCOLLO.
       IF c_campi%ISOPEN
       THEN
          CLOSE c_campi;
       END IF;

       OPEN c_campi (NVL (p_area, 'SEGRETERIA.PROTOCOLLO'),
                     NVL (p_modello, 'M_PROTOCOLLO'));

       FETCH c_campi INTO d_campo;

       WHILE c_campi%FOUND
       LOOP
          BEGIN
             SELECT column_name, ''
               INTO d_campo, d_valore
               FROM user_tab_columns
              WHERE     table_name = NVL (p_table, 'PROTO_VIEW')
                    AND column_name = d_campo
                    AND column_name NOT IN ('STATO_SCARTO');

             d_stringa := d_stringa || '<' || d_campo || '/>' || CHR (10);
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                NULL;
          END;

          FETCH c_campi INTO d_campo;
       END LOOP;

       CLOSE c_campi;

       d_stringa := d_stringa || '<STATO_SCARTO>**</STATO_SCARTO>' || CHR (10);
       --d_stringa := d_stringa || '<FASC_STATO_SCARTO>**</FASC_STATO_SCARTO>' || CHR (10);

       d_stringa := d_stringa || '</' || NVL (p_rowtag, 'ROW') || '>';
       --integritypackage.LOG (d_stringa);
       retval := TO_CLOB (d_stringa);
       RETURN retval;
    END;


    FUNCTION get_anagrafici (p_denominazione   IN VARCHAR2,
                             p_indirizzo       IN VARCHAR2 DEFAULT NULL,
                             p_cf              IN VARCHAR2 DEFAULT NULL)
       RETURN afc.t_ref_cursor
    IS
       d_ref_cursor   afc.t_ref_cursor;
    BEGIN
       IF p_denominazione IS NULL
       THEN
          raise_application_error (-20999,
                                   'Inserire parte della denominazione!');
       END IF;

       OPEN d_ref_cursor FOR
            SELECT *
              FROM seg_anagrafici
             WHERE     catsearch (denominazione,
                                  REPLACE (p_denominazione, '%', '*'),
                                  NULL) > 0
                   AND cf LIKE NVL (p_cf, cf)
                   AND indirizzo LIKE NVL (p_indirizzo, indirizzo)
          ORDER BY denominazione;

       RETURN d_ref_cursor;
    END;

    FUNCTION get_anagrafici (
       p_qbe                           IN NUMBER DEFAULT 0,
       p_other_condition               IN VARCHAR2 DEFAULT NULL,
       p_order_by                      IN VARCHAR2 DEFAULT NULL,
       p_extra_columns                 IN VARCHAR2 DEFAULT NULL,
       p_extra_condition               IN VARCHAR2 DEFAULT NULL,
       p_denominazione                 IN VARCHAR2 DEFAULT NULL,
       p_email                         IN VARCHAR2 DEFAULT NULL,
       p_partita_iva                   IN VARCHAR2 DEFAULT NULL,
       p_cf                            IN VARCHAR2 DEFAULT NULL,
       p_pi                            IN VARCHAR2 DEFAULT NULL,
       p_indirizzo                     IN VARCHAR2 DEFAULT NULL,
       p_denominazione_per_segnatura   IN VARCHAR2 DEFAULT NULL,
       p_cognome_per_segnatura         IN VARCHAR2 DEFAULT NULL,
       p_nome_per_segnatura            IN VARCHAR2 DEFAULT NULL,
       p_indirizzo_per_segnatura       IN VARCHAR2 DEFAULT NULL,
       p_comune_per_segnatura          IN VARCHAR2 DEFAULT NULL,
       p_cap_per_segnatura             IN VARCHAR2 DEFAULT NULL,
       p_provincia_per_segnatura       IN VARCHAR2 DEFAULT NULL,
       p_cf_per_segnatura              IN VARCHAR2 DEFAULT NULL,
       p_ni_persona                    IN VARCHAR2 DEFAULT NULL,
       p_dal_persona                   IN VARCHAR2 DEFAULT NULL,
       p_ni                            IN VARCHAR2 DEFAULT NULL,
       p_cognome                       IN VARCHAR2 DEFAULT NULL,
       p_nome                          IN VARCHAR2 DEFAULT NULL,
       p_indirizzo_res                 IN VARCHAR2 DEFAULT NULL,
       p_cap_res                       IN VARCHAR2 DEFAULT NULL,
       p_comune_res                    IN VARCHAR2 DEFAULT NULL,
       p_provincia_res                 IN VARCHAR2 DEFAULT NULL,
       p_codice_fiscale                IN VARCHAR2 DEFAULT NULL,
       p_indirizzo_dom                 IN VARCHAR2 DEFAULT NULL,
       p_comune_dom                    IN VARCHAR2 DEFAULT NULL,
       p_cap_dom                       IN VARCHAR2 DEFAULT NULL,
       p_provincia_dom                 IN VARCHAR2 DEFAULT NULL,
       p_mail_persona                  IN VARCHAR2 DEFAULT NULL,
       p_tel_res                       IN VARCHAR2 DEFAULT NULL,
       p_fax_res                       IN VARCHAR2 DEFAULT NULL,
       p_sesso                         IN VARCHAR2 DEFAULT NULL,
       p_comune_nascita                IN VARCHAR2 DEFAULT NULL,
       p_data_nascita                  IN VARCHAR2 DEFAULT NULL,
       p_tel_dom                       IN VARCHAR2 DEFAULT NULL,
       p_fax_dom                       IN VARCHAR2 DEFAULT NULL,
       p_cf_nullable                   IN VARCHAR2 DEFAULT NULL,
       p_ammin                         IN VARCHAR2 DEFAULT NULL,
       p_descrizione_amm               IN VARCHAR2 DEFAULT NULL,
       p_aoo                           IN VARCHAR2 DEFAULT NULL,
       p_descrizione_aoo               IN VARCHAR2 DEFAULT NULL,
       p_cod_amm                       IN VARCHAR2 DEFAULT NULL,
       p_cod_aoo                       IN VARCHAR2 DEFAULT NULL,
       p_dati_amm                      IN VARCHAR2 DEFAULT NULL,
       p_dati_aoo                      IN VARCHAR2 DEFAULT NULL,
       p_ni_amm                        IN VARCHAR2 DEFAULT NULL,
       p_dal_amm                       IN VARCHAR2 DEFAULT NULL,
       p_tipo                          IN VARCHAR2 DEFAULT NULL,
       p_indirizzo_amm                 IN VARCHAR2 DEFAULT NULL,
       p_cap_amm                       IN VARCHAR2 DEFAULT NULL,
       p_comune_amm                    IN VARCHAR2 DEFAULT NULL,
       p_sigla_prov_amm                IN VARCHAR2 DEFAULT NULL,
       p_mail_amm                      IN VARCHAR2 DEFAULT NULL,
       p_indirizzo_aoo                 IN VARCHAR2 DEFAULT NULL,
       p_cap_aoo                       IN VARCHAR2 DEFAULT NULL,
       p_comune_aoo                    IN VARCHAR2 DEFAULT NULL,
       p_sigla_prov_aoo                IN VARCHAR2 DEFAULT NULL,
       p_mail_aoo                      IN VARCHAR2 DEFAULT NULL,
       p_cf_beneficiario               IN VARCHAR2 DEFAULT NULL,
       p_denominazione_beneficiario    IN VARCHAR2 DEFAULT NULL,
       p_pi_beneficiario               IN VARCHAR2 DEFAULT NULL,
       p_comune_beneficiario           IN VARCHAR2 DEFAULT NULL,
       p_indirizzo_beneficiario        IN VARCHAR2 DEFAULT NULL,
       p_cap_beneficiario              IN VARCHAR2 DEFAULT NULL,
       p_data_nascita_beneficiario     IN VARCHAR2 DEFAULT NULL,
       p_provincia_beneficiario        IN VARCHAR2 DEFAULT NULL,
       p_vis_indirizzo                 IN VARCHAR2 DEFAULT NULL,
       p_ni_impresa                    IN VARCHAR2 DEFAULT NULL,
       p_impresa                       IN VARCHAR2 DEFAULT NULL,
       p_denominazione_sede            IN VARCHAR2 DEFAULT NULL,
       p_natura_giuridica              IN VARCHAR2 DEFAULT NULL,
       p_insegna                       IN VARCHAR2 DEFAULT NULL,
       p_c_fiscale_impresa             IN VARCHAR2 DEFAULT NULL,
       p_partita_iva_impresa           IN VARCHAR2 DEFAULT NULL,
       p_tipo_localizzazione           IN VARCHAR2 DEFAULT NULL,
       p_comune                        IN VARCHAR2 DEFAULT NULL,
       p_c_via_impresa                 IN VARCHAR2 DEFAULT NULL,
       p_via_impresa                   IN VARCHAR2 DEFAULT NULL,
       p_n_civico_impresa              IN VARCHAR2 DEFAULT NULL,
       p_comune_impresa                IN VARCHAR2 DEFAULT NULL,
       p_cap_impresa                   IN VARCHAR2 DEFAULT NULL,
       p_com_nascita                   IN VARCHAR2 DEFAULT NULL,
       p_cf_persona                    IN VARCHAR2 DEFAULT NULL,
       p_cognome_impresa               IN VARCHAR2 DEFAULT NULL,
       p_nome_impresa                  IN VARCHAR2 DEFAULT NULL,
       p_cfp                           IN VARCHAR2 DEFAULT NULL,
       p_anagrafica                    IN VARCHAR2 DEFAULT NULL)
       RETURN afc.t_ref_cursor
    IS
       /******************************************************************************
        NOME:        anagrafica_get_rows
        DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
        PARAMETRI:
        RITORNA:     Un ref_cursor che punta al risultato della query.
        NOTE:
       ******************************************************************************/
       d_statement       afc.t_statement;
       d_ref_cursor      afc.t_ref_cursor;
       d_denominazione   VARCHAR2 (4000)
                            := REPLACE (p_denominazione, ' ', '%') || '%';

       FUNCTION where_condition                                /* SLAVE_COPY */
                                (
          p_qbe                           IN NUMBER DEFAULT 0,
          p_other_condition               IN VARCHAR2 DEFAULT NULL,
          p_denominazione                 IN VARCHAR2 DEFAULT NULL,
          p_email                         IN VARCHAR2 DEFAULT NULL,
          p_partita_iva                   IN VARCHAR2 DEFAULT NULL,
          p_cf                            IN VARCHAR2 DEFAULT NULL,
          p_pi                            IN VARCHAR2 DEFAULT NULL,
          p_indirizzo                     IN VARCHAR2 DEFAULT NULL,
          p_denominazione_per_segnatura   IN VARCHAR2 DEFAULT NULL,
          p_cognome_per_segnatura         IN VARCHAR2 DEFAULT NULL,
          p_nome_per_segnatura            IN VARCHAR2 DEFAULT NULL,
          p_indirizzo_per_segnatura       IN VARCHAR2 DEFAULT NULL,
          p_comune_per_segnatura          IN VARCHAR2 DEFAULT NULL,
          p_cap_per_segnatura             IN VARCHAR2 DEFAULT NULL,
          p_provincia_per_segnatura       IN VARCHAR2 DEFAULT NULL,
          p_cf_per_segnatura              IN VARCHAR2 DEFAULT NULL,
          p_ni_persona                    IN VARCHAR2 DEFAULT NULL,
          p_dal_persona                   IN VARCHAR2 DEFAULT NULL,
          p_ni                            IN VARCHAR2 DEFAULT NULL,
          p_cognome                       IN VARCHAR2 DEFAULT NULL,
          p_nome                          IN VARCHAR2 DEFAULT NULL,
          p_indirizzo_res                 IN VARCHAR2 DEFAULT NULL,
          p_cap_res                       IN VARCHAR2 DEFAULT NULL,
          p_comune_res                    IN VARCHAR2 DEFAULT NULL,
          p_provincia_res                 IN VARCHAR2 DEFAULT NULL,
          p_codice_fiscale                IN VARCHAR2 DEFAULT NULL,
          p_indirizzo_dom                 IN VARCHAR2 DEFAULT NULL,
          p_comune_dom                    IN VARCHAR2 DEFAULT NULL,
          p_cap_dom                       IN VARCHAR2 DEFAULT NULL,
          p_provincia_dom                 IN VARCHAR2 DEFAULT NULL,
          p_mail_persona                  IN VARCHAR2 DEFAULT NULL,
          p_tel_res                       IN VARCHAR2 DEFAULT NULL,
          p_fax_res                       IN VARCHAR2 DEFAULT NULL,
          p_sesso                         IN VARCHAR2 DEFAULT NULL,
          p_comune_nascita                IN VARCHAR2 DEFAULT NULL,
          p_data_nascita                  IN VARCHAR2 DEFAULT NULL,
          p_tel_dom                       IN VARCHAR2 DEFAULT NULL,
          p_fax_dom                       IN VARCHAR2 DEFAULT NULL,
          p_cf_nullable                   IN VARCHAR2 DEFAULT NULL,
          p_ammin                         IN VARCHAR2 DEFAULT NULL,
          p_descrizione_amm               IN VARCHAR2 DEFAULT NULL,
          p_aoo                           IN VARCHAR2 DEFAULT NULL,
          p_descrizione_aoo               IN VARCHAR2 DEFAULT NULL,
          p_cod_amm                       IN VARCHAR2 DEFAULT NULL,
          p_cod_aoo                       IN VARCHAR2 DEFAULT NULL,
          p_dati_amm                      IN VARCHAR2 DEFAULT NULL,
          p_dati_aoo                      IN VARCHAR2 DEFAULT NULL,
          p_ni_amm                        IN VARCHAR2 DEFAULT NULL,
          p_dal_amm                       IN VARCHAR2 DEFAULT NULL,
          p_tipo                          IN VARCHAR2 DEFAULT NULL,
          p_indirizzo_amm                 IN VARCHAR2 DEFAULT NULL,
          p_cap_amm                       IN VARCHAR2 DEFAULT NULL,
          p_comune_amm                    IN VARCHAR2 DEFAULT NULL,
          p_sigla_prov_amm                IN VARCHAR2 DEFAULT NULL,
          p_mail_amm                      IN VARCHAR2 DEFAULT NULL,
          p_indirizzo_aoo                 IN VARCHAR2 DEFAULT NULL,
          p_cap_aoo                       IN VARCHAR2 DEFAULT NULL,
          p_comune_aoo                    IN VARCHAR2 DEFAULT NULL,
          p_sigla_prov_aoo                IN VARCHAR2 DEFAULT NULL,
          p_mail_aoo                      IN VARCHAR2 DEFAULT NULL,
          p_cf_beneficiario               IN VARCHAR2 DEFAULT NULL,
          p_denominazione_beneficiario    IN VARCHAR2 DEFAULT NULL,
          p_pi_beneficiario               IN VARCHAR2 DEFAULT NULL,
          p_comune_beneficiario           IN VARCHAR2 DEFAULT NULL,
          p_indirizzo_beneficiario        IN VARCHAR2 DEFAULT NULL,
          p_cap_beneficiario              IN VARCHAR2 DEFAULT NULL,
          p_data_nascita_beneficiario     IN VARCHAR2 DEFAULT NULL,
          p_provincia_beneficiario        IN VARCHAR2 DEFAULT NULL,
          p_vis_indirizzo                 IN VARCHAR2 DEFAULT NULL,
          p_ni_impresa                    IN VARCHAR2 DEFAULT NULL,
          p_impresa                       IN VARCHAR2 DEFAULT NULL,
          p_denominazione_sede            IN VARCHAR2 DEFAULT NULL,
          p_natura_giuridica              IN VARCHAR2 DEFAULT NULL,
          p_insegna                       IN VARCHAR2 DEFAULT NULL,
          p_c_fiscale_impresa             IN VARCHAR2 DEFAULT NULL,
          p_partita_iva_impresa           IN VARCHAR2 DEFAULT NULL,
          p_tipo_localizzazione           IN VARCHAR2 DEFAULT NULL,
          p_comune                        IN VARCHAR2 DEFAULT NULL,
          p_c_via_impresa                 IN VARCHAR2 DEFAULT NULL,
          p_via_impresa                   IN VARCHAR2 DEFAULT NULL,
          p_n_civico_impresa              IN VARCHAR2 DEFAULT NULL,
          p_comune_impresa                IN VARCHAR2 DEFAULT NULL,
          p_cap_impresa                   IN VARCHAR2 DEFAULT NULL,
          p_com_nascita                   IN VARCHAR2 DEFAULT NULL,
          p_cf_persona                    IN VARCHAR2 DEFAULT NULL,
          p_cognome_impresa               IN VARCHAR2 DEFAULT NULL,
          p_nome_impresa                  IN VARCHAR2 DEFAULT NULL,
          p_cfp                           IN VARCHAR2 DEFAULT NULL,
          p_anagrafica                    IN VARCHAR2 DEFAULT NULL)
          RETURN afc.t_statement
       IS
          /* SLAVE_COPY */
          /******************************************************************************
           NOME:        where_condition
           DESCRIZIONE: Ritorna la where_condition per lo statement di select di get_rows e count_rows.
           PARAMETRI:   p_QBE 0: viene controllato se all'inizio di ogni attributo ¿ presente
                                 un operatore, altrimenti viene usato quello di default ('=')
                              1: viene utilizzato l'operatore specificato all'inizio di ogni
                                 attributo.
                        p_other_condition: condizioni aggiuntive di base
                        Chiavi e attributi della table
           RITORNA:     AFC.t_statement.
           NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
                        l'operatore da utilizzare nella where-condition.
          ******************************************************************************/
          d_statement   afc.t_statement;
       BEGIN
          d_statement :=
                ' where ( 1 = 1 '
             || afc.get_field_condition (' and ( denominazione ',
                                         d_denominazione,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( email ',
                                         p_email,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( partita_iva ',
                                         p_partita_iva,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cf ',
                                         p_cf,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( pi ',
                                         p_pi,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo ',
                                         p_indirizzo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (
                   ' and ( denominazione_per_segnatura ',
                   p_denominazione_per_segnatura,
                   ' )',
                   p_qbe,
                   NULL)
             || afc.get_field_condition (' and ( cognome_per_segnatura ',
                                         p_cognome_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( nome_per_segnatura ',
                                         p_nome_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo_per_segnatura ',
                                         p_indirizzo_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_per_segnatura ',
                                         p_comune_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_per_segnatura ',
                                         p_cap_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( provincia_per_segnatura ',
                                         p_provincia_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cf_per_segnatura ',
                                         p_cf_per_segnatura,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( ni_persona ',
                                         p_ni_persona,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( dal_persona ',
                                         p_dal_persona,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( ni ',
                                         p_ni,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cognome ',
                                         p_cognome,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( nome ',
                                         p_nome,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo_res ',
                                         p_indirizzo_res,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_res ',
                                         p_cap_res,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_res ',
                                         p_comune_res,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( provincia_res ',
                                         p_provincia_res,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( codice_fiscale ',
                                         p_codice_fiscale,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo_dom ',
                                         p_indirizzo_dom,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_dom ',
                                         p_comune_dom,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_dom ',
                                         p_cap_dom,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( provincia_dom ',
                                         p_provincia_dom,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( mail_persona ',
                                         p_mail_persona,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( tel_res ',
                                         p_tel_res,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( fax_res ',
                                         p_fax_res,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( sesso ',
                                         p_sesso,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_nascita ',
                                         p_comune_nascita,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( data_nascita ',
                                         p_data_nascita,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( tel_dom ',
                                         p_tel_dom,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( fax_dom ',
                                         p_fax_dom,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cf_nullable ',
                                         p_cf_nullable,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( ammin ',
                                         p_ammin,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( descrizione_amm ',
                                         p_descrizione_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( aoo ',
                                         p_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( descrizione_aoo ',
                                         p_descrizione_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cod_amm ',
                                         p_cod_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cod_aoo ',
                                         p_cod_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( dati_amm ',
                                         p_dati_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( dati_aoo ',
                                         p_dati_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( ni_amm ',
                                         p_ni_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( dal_amm ',
                                         p_dal_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( tipo ',
                                         p_tipo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo_amm ',
                                         p_indirizzo_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_amm ',
                                         p_cap_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_amm ',
                                         p_comune_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( sigla_prov_amm ',
                                         p_sigla_prov_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( mail_amm ',
                                         p_mail_amm,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo_aoo ',
                                         p_indirizzo_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_aoo ',
                                         p_cap_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_aoo ',
                                         p_comune_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( sigla_prov_aoo ',
                                         p_sigla_prov_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( mail_aoo ',
                                         p_mail_aoo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cf_beneficiario ',
                                         p_cf_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( denominazione_beneficiario ',
                                         p_denominazione_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( pi_beneficiario ',
                                         p_pi_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_beneficiario ',
                                         p_comune_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( indirizzo_beneficiario ',
                                         p_indirizzo_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_beneficiario ',
                                         p_cap_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( data_nascita_beneficiario ',
                                         p_data_nascita_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( provincia_beneficiario ',
                                         p_provincia_beneficiario,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( vis_indirizzo ',
                                         p_vis_indirizzo,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( ni_impresa ',
                                         p_ni_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( impresa ',
                                         p_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( denominazione_sede ',
                                         p_denominazione_sede,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( natura_giuridica ',
                                         p_natura_giuridica,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( insegna ',
                                         p_insegna,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( c_fiscale_impresa ',
                                         p_c_fiscale_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( partita_iva_impresa ',
                                         p_partita_iva_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( tipo_localizzazione ',
                                         p_tipo_localizzazione,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune ',
                                         p_comune,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( c_via_impresa ',
                                         p_c_via_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( via_impresa ',
                                         p_via_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( n_civico_impresa ',
                                         p_n_civico_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( comune_impresa ',
                                         p_comune_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cap_impresa ',
                                         p_cap_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( com_nascita ',
                                         p_com_nascita,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cf_persona ',
                                         p_cf_persona,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cognome_impresa ',
                                         p_cognome_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( nome_impresa ',
                                         p_nome_impresa,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( cfp ',
                                         p_cfp,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || afc.get_field_condition (' and ( anagrafica ',
                                         p_anagrafica,
                                         ' )',
                                         p_qbe,
                                         NULL)
             || ' ) '
             || p_other_condition;
          RETURN d_statement;
       END where_condition;
    BEGIN
       d_statement :=
             ' select SEG_ANAGRAFICI.* '
          || afc.decode_value (p_extra_columns,
                               NULL,
                               NULL,
                               ' , ' || p_extra_columns)
          || ' from SEG_ANAGRAFICI '
          || where_condition (
                p_qbe                           => p_qbe,
                p_other_condition               => p_other_condition,
                p_denominazione                 => p_denominazione,
                p_email                         => p_email,
                p_partita_iva                   => p_partita_iva,
                p_cf                            => p_cf,
                p_pi                            => p_pi,
                p_indirizzo                     => p_indirizzo,
                p_denominazione_per_segnatura   => p_denominazione_per_segnatura,
                p_cognome_per_segnatura         => p_cognome_per_segnatura,
                p_nome_per_segnatura            => p_nome_per_segnatura,
                p_indirizzo_per_segnatura       => p_indirizzo_per_segnatura,
                p_comune_per_segnatura          => p_comune_per_segnatura,
                p_cap_per_segnatura             => p_cap_per_segnatura,
                p_provincia_per_segnatura       => p_provincia_per_segnatura,
                p_cf_per_segnatura              => p_cf_per_segnatura,
                p_ni_persona                    => p_ni_persona,
                p_dal_persona                   => p_dal_persona,
                p_ni                            => p_ni,
                p_cognome                       => p_cognome,
                p_nome                          => p_nome,
                p_indirizzo_res                 => p_indirizzo_res,
                p_cap_res                       => p_cap_res,
                p_comune_res                    => p_comune_res,
                p_provincia_res                 => p_provincia_res,
                p_codice_fiscale                => p_codice_fiscale,
                p_indirizzo_dom                 => p_indirizzo_dom,
                p_comune_dom                    => p_comune_dom,
                p_cap_dom                       => p_cap_dom,
                p_provincia_dom                 => p_provincia_dom,
                p_mail_persona                  => p_mail_persona,
                p_tel_res                       => p_tel_res,
                p_fax_res                       => p_fax_res,
                p_sesso                         => p_sesso,
                p_comune_nascita                => p_comune_nascita,
                p_data_nascita                  => p_data_nascita,
                p_tel_dom                       => p_tel_dom,
                p_fax_dom                       => p_fax_dom,
                p_cf_nullable                   => p_cf_nullable,
                p_ammin                         => p_ammin,
                p_descrizione_amm               => p_descrizione_amm,
                p_aoo                           => p_aoo,
                p_descrizione_aoo               => p_descrizione_aoo,
                p_cod_amm                       => p_cod_amm,
                p_cod_aoo                       => p_cod_aoo,
                p_dati_amm                      => p_dati_amm,
                p_dati_aoo                      => p_dati_aoo,
                p_ni_amm                        => p_ni_amm,
                p_dal_amm                       => p_dal_amm,
                p_tipo                          => p_tipo,
                p_indirizzo_amm                 => p_indirizzo_amm,
                p_cap_amm                       => p_cap_amm,
                p_comune_amm                    => p_comune_amm,
                p_sigla_prov_amm                => p_sigla_prov_amm,
                p_mail_amm                      => p_mail_amm,
                p_indirizzo_aoo                 => p_indirizzo_aoo,
                p_cap_aoo                       => p_cap_aoo,
                p_comune_aoo                    => p_comune_aoo,
                p_sigla_prov_aoo                => p_sigla_prov_aoo,
                p_mail_aoo                      => p_mail_aoo,
                p_cf_beneficiario               => p_cf_beneficiario,
                p_denominazione_beneficiario    => p_denominazione_beneficiario,
                p_pi_beneficiario               => p_pi_beneficiario,
                p_comune_beneficiario           => p_comune_beneficiario,
                p_indirizzo_beneficiario        => p_indirizzo_beneficiario,
                p_cap_beneficiario              => p_cap_beneficiario,
                p_data_nascita_beneficiario     => p_data_nascita_beneficiario,
                p_provincia_beneficiario        => p_provincia_beneficiario,
                p_vis_indirizzo                 => p_vis_indirizzo,
                p_ni_impresa                    => p_ni_impresa,
                p_impresa                       => p_impresa,
                p_denominazione_sede            => p_denominazione_sede,
                p_natura_giuridica              => p_natura_giuridica,
                p_insegna                       => p_insegna,
                p_c_fiscale_impresa             => p_c_fiscale_impresa,
                p_partita_iva_impresa           => p_partita_iva_impresa,
                p_tipo_localizzazione           => p_tipo_localizzazione,
                p_comune                        => p_comune,
                p_c_via_impresa                 => p_c_via_impresa,
                p_via_impresa                   => p_via_impresa,
                p_n_civico_impresa              => p_n_civico_impresa,
                p_comune_impresa                => p_comune_impresa,
                p_cap_impresa                   => p_cap_impresa,
                p_com_nascita                   => p_com_nascita,
                p_cf_persona                    => p_cf_persona,
                p_cognome_impresa               => p_cognome_impresa,
                p_nome_impresa                  => p_nome_impresa,
                p_cfp                           => p_cfp,
                p_anagrafica                    => p_anagrafica)
          || ' '
          || p_extra_condition
          || afc.decode_value (p_order_by,
                               NULL,
                               NULL,
                               ' order by ' || p_order_by);
       d_ref_cursor := afc_dml.get_ref_cursor (d_statement);
       RETURN d_ref_cursor;
    END get_anagrafici;

    FUNCTION get_si_no_select (p_modulo IN VARCHAR2)
       RETURN VARCHAR2
    IS
       d_result   VARCHAR2 (32767);
    BEGIN
       d_result :=
             'SELECT codice, descrizione, UPPER (stringa) preferenza
               FROM registro,
                      (SELECT ''Si'' descrizione, ''Y'' codice
                         FROM DUAL
                       UNION
                       SELECT ''No'', ''N''
                         FROM DUAL) si_no
              WHERE chiave = ''PRODUCTS/'
          || p_modulo
          || '''
                AND stringa IN (''AbilitaStampaBCDiretta'', ''AbilitaStampaRicDiretta'', ''DuplicaRapportiCopia'', ''DuplicaRapportiRisposta'' ,''DuplicaSmistCopia'', ''DuplicaSmistRisposta'', ''DuplicaFasc'', ''ScanRichiediFilename'', ''ScanAbilitaImpostazioni'', ''ApriSoggettoUnivoco'')
              GROUP BY stringa, codice, descrizione
              ORDER BY stringa';
       RETURN d_result;
    END;

    FUNCTION get_valori_select (p_codice_amm   IN VARCHAR2,
                                p_codice_aoo   IN VARCHAR2,
                                p_modulo       IN VARCHAR2,
                                p_utente       IN VARCHAR2)
       RETURN VARCHAR2
    IS
       d_return   VARCHAR2 (32767);
    BEGIN
       IF p_modulo = 'AGSPR'
       THEN
          d_return :=
                'SELECT modalita CODICE,  movimento DESCRIZIONE, ''MODALITA'' preferenza
                 FROM ('
             || get_tipi_movimento_select (p_codice_amm,
                                           p_codice_aoo,
                                           'DP',
                                           p_utente)
             || ')
               UNION '
             || 'SELECT UNPR.UNITA CODICE, UNPR.NOME DESCRIZIONE, ''UNITAPROTOCOLLANTE''
                FROM ( '
             || get_uni_prot_select (p_utente,
                                     p_utente,
                                     TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                     'DP')
             || ') UNPR
               UNION '
             || 'SELECT UNSM.UNITA CODICE, UNSM.NOME DESCRIZIONE, ''UNITAITER''
                FROM ( '
             || get_uni_iter_select (p_utente)
             || ') UNSM
               UNION '
             || 'SELECT si_no.CODICE, si_no.DESCRIZIONE, si_no.preferenza
                FROM ( '
             || get_si_no_select (p_modulo)
             || ') si_no'
             || ' UNION '
             || 'select report, descrizione, ''REPORTTIMBRO''
                   from (select ''timbro'' report, ''Timbro senza bc'' descrizione FROM DUAL)';
          INTEGRITYPACKAGE.LOG (d_return);
       END IF;

       RETURN d_return;
    END;

    /*****************************************************************************
       NOME:        GET_PREFERENZE_STANDARD
       DESCRIZIONE: CARICA LE PREFERENZE UTENTE PER L'APPLICAZIONE
       RITORNO:
       Rev.  Data             Autore        Descrizione.
       00    29/06/2010  MMurabito  Prima emissione.
    ********************************************************************************/
    FUNCTION get_preferenze_standard (p_modulo   IN VARCHAR2,
                                      p_utente   IN VARCHAR2,
                                      p_area     IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_ref_cursor   afc.t_ref_cursor;
    BEGIN
       OPEN d_ref_cursor FOR
          SELECT ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'UnitaProtocollante')
                    AS unitaprotocollante,
                 ag_registro_utility.get_preferenza_utente (p_modulo,
                                                            p_utente,
                                                            'Modalita')
                    AS modalita,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'DuplicaRapportiCopia')
                    AS duplicarapporticopia,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'DuplicaRapportiRisposta')
                    AS duplicarapportirisposta,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'DuplicaSmistCopia')
                    AS duplicasmistcopia,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'DuplicaSmistRisposta')
                    AS duplicasmistrisposta,
                 ag_registro_utility.get_preferenza_utente (p_modulo,
                                                            p_utente,
                                                            'DuplicaFasc')
                    AS duplicafasc,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'AbilitaStampaBCDiretta')
                    AS abilitastampabcdiretta,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'AbilitaStampaRicDiretta')
                    AS abilitastamparicdiretta,
                 (SELECT DECODE (
                            path_file,
                            '', 'DB',
                            DECODE (force_file_on_blob,
                                    1, 'DB',
                                    0, path_file || '###' || path_file_oracle))
                    FROM aree
                   WHERE area =
                            DECODE (p_area,
                                    '', 'SEGRETERIA.PROTOCOLLO',
                                    p_area))
                    AS doc_principale,
                 (SELECT valore
                    FROM registro
                   WHERE     (chiave = 'PRODUCT/AGS/AGSpr/SPED')
                         AND stringa = 'MOD_SPED_ATTIVO')
                    AS spedizione_attivo,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'ScanRichiediFilename')
                    AS ScanRichiediFilename,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'ScanAbilitaImpostazioni')
                    AS ScanAbilitaImpostazioni,
                 ag_registro_utility.get_preferenza_utente (p_modulo,
                                                            p_utente,
                                                            'ReportTimbro')
                    AS ReportTimbro,
                 ag_registro_utility.get_preferenza_utente (
                    p_modulo,
                    p_utente,
                    'ApriSoggettoUnivoco')
                    AS ApriSoggettoUnivoco
            FROM DUAL;

       RETURN d_ref_cursor;
    END;

    FUNCTION get_preferenza_utente (p_modulo       IN VARCHAR2,
                                    p_utente       IN VARCHAR2,
                                    p_preferenza   IN VARCHAR2)
       RETURN VARCHAR2
    IS
       d_return   VARCHAR2 (2000);
    BEGIN
       d_return :=
          ag_registro_utility.get_preferenza_utente (p_modulo,
                                                     p_utente,
                                                     p_preferenza);
       RETURN d_return;
    END;

    FUNCTION get_preferenze_utente (p_codice_amm   IN VARCHAR2,
                                    p_codice_aoo   IN VARCHAR2,
                                    p_modulo       IN VARCHAR2,
                                    p_utente       IN VARCHAR2,
                                    p_preferenza   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_return      afc.t_ref_cursor;
       d_statement   VARCHAR2 (32767);
    BEGIN
       d_statement :=
             'SELECT   stringa,
                   amvweb.get_preferenza (stringa,'''
          || p_modulo
          || ''', '''
          || p_utente
          || ''') valore,
                   MAX(valori.descrizione) descrizione,
                   MAX (commento) commento,
                   amvweb.is_preferenza (stringa, '''
          || p_modulo
          || ''', '''
          || p_utente
          || ''') impostata
              FROM registro
                 , ('
          || get_valori_select (p_codice_amm,
                                p_codice_aoo,
                                p_modulo,
                                p_utente)
          || ') valori
             WHERE (   chiave =
                             ''SI4_DB_USERS/''
                         ||'''
          || p_utente
          || '''
                          || ''|''
                          || UPPER (USER)
                          || ''/PRODUCTS/''
                          || '''
          || p_modulo
          || '''
                    or chiave = ''PRODUCTS/''||'''
          || p_modulo
          || '''
                   )
               AND stringa != ''(Predefinito)''
               AND upper(stringa) like nvl(upper('''
          || p_preferenza
          || '''), ''%'')
               AND valori.codice (+) = amvweb.get_preferenza (stringa,'''
          || p_modulo
          || ''', '''
          || p_utente
          || ''')
               AND upper(stringa) = valori.preferenza (+)
          GROUP BY stringa
          ORDER BY stringa';
       integritypackage.LOG (d_statement);

       OPEN d_return FOR d_statement;

       RETURN d_return;
    END;

    FUNCTION get_valori_preferenza_utente (p_codice_amm   IN VARCHAR2,
                                           p_codice_aoo   IN VARCHAR2,
                                           p_modulo       IN VARCHAR2,
                                           p_utente       IN VARCHAR2,
                                           p_preferenza   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_return      afc.t_ref_cursor;
       d_statement   VARCHAR2 (32767);
    BEGIN
       IF p_modulo = 'AGSPR'
       THEN
          d_statement :=
                'select codice, descrizione
                from ('
             || get_valori_select (p_codice_amm,
                                   p_codice_aoo,
                                   p_modulo,
                                   p_utente)
             || ') valori
               where upper('''
             || p_preferenza
             || ''') = valori.preferenza';

          OPEN d_return FOR d_statement;
       END IF;

       integritypackage.LOG (d_statement);
       RETURN d_return;
    END;

    FUNCTION get_log_nome_campo
       RETURN afc.t_ref_cursor
    IS
       d_return   afc.t_ref_cursor;
    BEGIN
       OPEN d_return FOR
          SELECT '' campi, ' --' gruppo FROM DUAL
          UNION
          SELECT 'OGGETTO@MODALITA@NOTE', 'Dati Protocollo' FROM DUAL
          UNION
          SELECT 'CLASS_COD@CLASS_DAL@FASCICOLO_ANNO@FASCICOLO_NUMERO',
                 'Cartella di Titolario'
            FROM DUAL
          UNION
          SELECT 'DENOMINAZIONE_PER_SEGNATURA@COGNOME_PER_SEGNATURA@NOME_PER_SEGNATURA@DESCRIZIONE_AMM@DESCRIZIONE_AOO',
                 'Mittenti/Destinatari'
            FROM DUAL
          UNION
          SELECT 'NUMERO_DOCUMENTO@DATA_DOCUMENTO',
                 'Estremi Protocollo Esterno'
            FROM DUAL
          UNION
          SELECT 'FILE', 'Doc Principale' FROM DUAL
          UNION
          SELECT 'TIPO_AZIONE', 'Allegati' FROM DUAL
          ORDER BY 2;

       RETURN d_return;
    END;

    FUNCTION ricerca_soggetti (
       p_ricerca         IN VARCHAR2,
       p_isquery         IN VARCHAR2,
       p_denominazione   IN VARCHAR2,
       p_indirizzo       IN VARCHAR2,
       p_cf              IN VARCHAR2,
       p_pi              IN VARCHAR2,
       p_email           IN VARCHAR2,
       p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
       p_tipo_soggetto   IN NUMBER DEFAULT -1)
       RETURN afc.t_ref_cursor
    IS
    /******************************************************************************
     NOME:        RICERCA_SOGGETTI.
     DESCRIZIONE: Ricerca in SEG_ANAGRAFICI col seguente criterio:
                   se e' un numero
                      se e' lungo 11: ricerca per partita iva prima nel campo PI poi
                                      nel campo CF;
                      altrimenti: ricerca per numero individuale (NI)
                   altrimenti: ricerca per denominazione con catsearch.
     ARGOMENTI:   p_ricerca    Stringa contenente CF/PI/Denominazione da ricercare.
                  p_dal        Data di utilizzo soggetto (formato dd/mm/yyyy).
     ECCEZIONI:   - 20999 Soggetto non Disponibile.
     ANNOTAZIONI: -
     REVISIONI:
     Rev. Data       Autore       Descrizione
     ---- ---------- ------------ -------------------------------------------------
     0    08/02/2010 MMalferrari  Creazione.
     1    24/01/2012 MMalferrari  Gestione carattere % all'inizio della stringa di
                                  ricerca
    ******************************************************************************/
    BEGIN
       RETURN seg_anagrafici_pkg.ricerca (p_ricerca,
                                          p_isquery,
                                          p_denominazione,
                                          p_indirizzo,
                                          p_cf,
                                          p_pi,
                                          p_email,
                                          p_dal,
                                          p_tipo_soggetto);
    END;

    --   PROCEDURE aggiorna_log (
    --      p_id_documento   IN   VARCHAR2,
    --      p_utente         IN   VARCHAR2,
    --      p_filename       IN   VARCHAR2,
    --      p_operazione     IN   VARCHAR2,
    --      p_id_oggetto     IN   NUMBER,
    --      p_allegato       IN   BLOB
    --   )
    --   IS
    --      d_id_act_log   NUMBER;
    --      d_id_log       NUMBER;
    --   BEGIN
    --      SELECT aclo_sq.NEXTVAL
    --        INTO d_id_act_log
    --        FROM DUAL;
    --
    --      INSERT INTO activity_log
    --                  (id_log, id_documento, tipo_azione, data_aggiornamento,
    --                   utente_aggiornamento
    --                  )
    --           VALUES (d_id_act_log, p_id_documento, p_operazione, SYSDATE,
    --                   p_utente
    --                  );
    --
    --      SELECT ogfi_log_sq.NEXTVAL
    --        INTO d_id_log
    --        FROM DUAL;
    --
    --      IF p_allegato IS NULL
    --      THEN
    --         INSERT INTO oggetti_file_log
    --                     (id_oggetto_file_log, id_log, id_oggetto_file,
    --                      filename, nome_formato, allegato, data_aggiornamento,
    --                      utente_aggiornamento, data_operazione,
    --                      utente_operazione, tipo_operazione
    --                     )
    --              VALUES (d_id_log, d_id_act_log, p_id_oggetto,
    --                      p_filename, NULL, 'N', SYSDATE,
    --                      p_utente, SYSDATE,
    --                      p_utente, p_operazione
    --                     );
    --      ELSE
    --         INSERT INTO oggetti_file_log
    --                     (id_oggetto_file_log, id_log, id_oggetto_file,
    --                      filename, nome_formato, testoocr, allegato,
    --                      data_aggiornamento, utente_aggiornamento,
    --                      data_operazione, utente_operazione, tipo_operazione
    --                     )
    --              VALUES (d_id_log, d_id_act_log, p_id_oggetto,
    --                      p_filename, NULL, p_allegato, 'N',
    --                      SYSDATE, p_utente,
    --                      SYSDATE, p_utente, p_operazione
    --                     );
    --      END IF;
    --   END;
    --   FUNCTION insert_oggetto_file (
    --      p_data_aggiornamento        VARCHAR2,
    --      p_id_documento         IN   NUMBER,
    --      p_filename             IN   VARCHAR2,
    --      p_utente                    VARCHAR2
    --   )
    --      RETURN NUMBER
    --   IS
    --      d_data   DATE;
    --      d_id     NUMBER;
    --   BEGIN
    --      SELECT data_aggiornamento
    --        INTO d_data
    --        FROM documenti
    --       WHERE id_documento = p_id_documento;
    --
    --      -- verifico che non esista gia' un allegato principale.
    --      BEGIN
    --         SELECT id_oggetto_file
    --           INTO d_id
    --           FROM oggetti_file
    --          WHERE id_documento = p_id_documento
    --            AND EXISTS (SELECT 1
    --                          FROM proto_view
    --                         WHERE id_documento = p_id_documento);
    --      EXCEPTION
    --         WHEN NO_DATA_FOUND
    --         THEN
    --            d_id := 0;
    --      END;
    --
    --      IF p_data_aggiornamento = TO_CHAR (d_data, 'dd/mm/yyyy hh24:mi:ss')
    --      THEN
    --         IF d_id = 0
    --         THEN
    --            SELECT ogg_file_sq.NEXTVAL
    --              INTO d_id
    --              FROM DUAL;
    --
    --            INSERT INTO oggetti_file
    --                        (id_oggetto_file, id_documento,
    --                         id_oggetto_file_padre, id_formato, filename,
    --                         allegato, data_aggiornamento, utente_aggiornamento
    --                        )
    --                 VALUES (d_id, p_id_documento,
    --                         NULL, 0, p_filename,
    --                         'N', SYSDATE, p_utente
    --                        );
    --         ELSE
    --            UPDATE oggetti_file
    --               SET filename = p_filename,
    --                   data_aggiornamento = SYSDATE,
    --                   utente_aggiornamento = p_utente
    --             WHERE id_oggetto_file = d_id;
    --         END IF;
    --
    --         aggiorna_log (p_id_documento, p_utente, p_filename, 'C', d_id, NULL);
    --      ELSE
    --         d_id := 0;
    --      END IF;
    --
    --      RETURN d_id;
    --   END;
    --   PROCEDURE aggiorna_log_documento (p_id_documento IN VARCHAR2)
    --   IS
    --      d_allegato   BLOB;
    --      d_id_log     NUMBER;
    --   BEGIN
    --      SELECT ogg.testoocr, id_log
    --        INTO d_allegato, d_id_log
    --        FROM oggetti_file ogg, oggetti_file_log oflo
    --       WHERE id_documento = p_id_documento
    --         AND ogg.id_oggetto_file = oflo.id_oggetto_file(+)
    --         AND tipo_operazione(+) = 'C';
    --
    --      IF d_id_log IS NOT NULL
    --      THEN
    --         UPDATE oggetti_file_log
    --            SET testoocr = d_allegato
    --          WHERE id_log = d_id_log;
    --      END IF;
    --   END;

    FUNCTION check_firma_doc_princ (p_codice_amm     IN VARCHAR2,
                                    p_codice_aoo     IN VARCHAR2,
                                    p_id_documento   IN NUMBER)
       RETURN NUMBER
    IS
    BEGIN
       RETURN check_doc_da_firmare (p_codice_amm,
                                    p_codice_aoo,
                                    p_id_documento,
                                    '',
                                    '',
                                    0);
    END;

    FUNCTION check_change_firma (p_codice_amm           IN VARCHAR2,
                                 p_codice_aoo           IN VARCHAR2,
                                 p_modalita             IN VARCHAR2,
                                 p_id_documento         IN NUMBER,
                                 p_in_protocollazione   IN NUMBER,
                                 p_filename             IN VARCHAR2,
                                 p_id_allegato          IN NUMBER)
       RETURN NUMBER
    IS
       ret              NUMBER := 0;
       d_filename_old   VARCHAR2 (4000);
       d_stato          VARCHAR2 (10);
       d_prot_interop   NUMBER := 0;
    BEGIN
       BEGIN
          SELECT filename
            INTO d_filename_old
            FROM oggetti_file
           WHERE     id_documento = p_id_documento
                 AND id_oggetto_file = NVL (p_id_allegato, id_oggetto_file);
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             d_filename_old := '';
          WHEN TOO_MANY_ROWS
          THEN
             BEGIN
                SELECT allegato_principale
                  INTO d_filename_old
                  FROM proto_view
                 WHERE id_documento = p_id_documento;
             EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                   d_filename_old := '';
                WHEN OTHERS
                THEN
                   RAISE;
             END;
          WHEN OTHERS
          THEN
             RAISE;
       END;

       IF NVL (UPPER (d_filename_old), ' ') <> NVL (UPPER (p_filename), ' ')
       THEN
          ret :=
             check_doc_da_firmare (p_codice_amm,
                                   p_codice_aoo,
                                   p_id_documento,
                                   p_modalita,
                                   '',
                                   NVL (p_in_protocollazione, 0));
       END IF;

       RETURN ret;
    END;

    FUNCTION check_doc_da_firmare (p_codice_amm           IN VARCHAR2,
                                   p_codice_aoo           IN VARCHAR2,
                                   p_id_documento         IN NUMBER,
                                   p_modalita             IN VARCHAR2,
                                   p_stato_pr             IN VARCHAR2,
                                   p_in_protocollazione   IN NUMBER)
       RETURN NUMBER
    IS
       d_stato        VARCHAR2 (10);
       d_ver_firma    VARCHAR2 (10);
       d_firma_sogg   VARCHAR2 (1);
       d_firma_amm    VARCHAR2 (1);
       d_idrif        VARCHAR2 (100);
       d_return       NUMBER := 0;
       d_modalita     VARCHAR2 (3);
       d_stato_pr     VARCHAR2 (10);
    BEGIN
       IF p_id_documento IS NOT NULL
       THEN
          d_ver_firma :=
             ag_parametro.get_valore ('VER_FIRMA_PAR_',
                                      p_codice_amm,
                                      p_codice_aoo,
                                      '');
          d_firma_sogg :=
             NVL (ag_parametro.get_valore ('FIRMA_INVIO_SOG_',
                                           p_codice_amm,
                                           p_codice_aoo,
                                           ''),
                  'Y');
          d_firma_amm :=
             NVL (ag_parametro.get_valore ('FIRMA_INVIO_AMM_',
                                           p_codice_amm,
                                           p_codice_aoo,
                                           ''),
                  'Y');

          SELECT DECODE (p_in_protocollazione, 1, 'PR', stato_pr),
                 idrif,
                 modalita
            INTO d_stato, d_idrif, d_modalita
            FROM proto_view
           WHERE id_documento = p_id_documento;

          d_modalita := NVL (p_modalita, d_modalita);
          d_stato_pr := NVL (p_stato_pr, 'PR');

          IF     d_stato = d_stato_pr
             AND d_modalita = 'PAR'
             AND d_ver_firma = 'PROT'
             AND (d_firma_sogg = 'Y' OR d_firma_amm = 'Y')
          THEN
             -- devo verificare i destinatari
             BEGIN
                SELECT NVL (MIN (1), 0)
                  INTO d_return
                  FROM seg_soggetti_protocollo s, documenti d
                 WHERE     idrif = d_idrif
                       AND (   (tipo_soggetto = '1' AND d_firma_sogg = 'Y')
                            OR (tipo_soggetto <> '1' AND d_firma_amm = 'Y'))
                       AND d.id_documento = s.id_documento
                       AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND tipo_rapporto <> 'DUMMY';
             EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                   NULL;
             END;
          END IF;
       END IF;

       RETURN d_return;
    END;

    PROCEDURE delete_copia_conforme (p_codice_amm        IN VARCHAR2,
                                     p_codice_aoo        IN VARCHAR2,
                                     p_id_documento      IN NUMBER,
                                     p_id_oggetto_file   IN NUMBER)
    IS
       d_gestione_cc      VARCHAR2 (1);
       d_is_pec_or_prot   VARCHAR2 (1) := 'N';
       d_id_allegato_cc   NUMBER;
       d_idrif            SPR_PROTOCOLLI.IDRIF%TYPE;
       d_nome_file        OGGETTI_FILE.FILENAME%TYPE;
       d_numero           SPR_PROTOCOLLI.NUMERO%TYPE;
       d_elimina          NUMBER;
    BEGIN
       d_gestione_cc :=
          ag_parametro.get_valore ('TIMBRA_PDF_FIRMATI_',
                                   p_codice_amm,
                                   p_codice_aoo,
                                   'N');

       BEGIN
          SELECT 'Y',
                 idrif,
                 NVL (SUBSTR (filename, 0, INSTR (filename, '.p7m') - 1),
                      filename),
                 numero
            INTO d_is_pec_or_prot,
                 d_idrif,
                 d_nome_file,
                 d_numero
            FROM spr_protocolli prot, oggetti_file ogfi
           WHERE     prot.id_documento = p_id_documento
                 AND prot.id_documento = ogfi.id_documento
                 AND da_cancellare = 'S'
          UNION
          SELECT 'Y',
                 idrif,
                 NVL (SUBSTR (filename, 0, INSTR (filename, '.p7m') - 1),
                      filename),
                 numero
            FROM spr_protocolli_intero prin, oggetti_file ogfi
           WHERE     prin.id_documento = p_id_documento
                 AND prin.id_documento = ogfi.id_documento
                 AND da_cancellare = 'S';
       EXCEPTION
          WHEN OTHERS
          THEN
             d_is_pec_or_prot := 'N';
       END;

       IF d_gestione_cc = 'Y' AND d_is_pec_or_prot = 'Y'
       THEN
          BEGIN
             SELECT alpr.id_documento
               INTO d_id_allegato_cc
               FROM seg_allegati_protocollo alpr,
                    oggetti_file ogfi,
                    documenti docu
              WHERE     idrif = d_idrif
                    AND TIPO_ALLEGATO = 'CC'
                    AND ogfi.id_documento = alpr.id_documento
                    AND UPPER (ogfi.filename) =
                           UPPER ('CC_' || d_numero || '_' || d_nome_file)
                    AND docu.id_documento = alpr.id_documento
                    AND docu.STATO_DOCUMENTO NOT IN ('CA', 'RE');

             d_elimina := f_elimina_documento (d_id_allegato_cc, 1, 1);
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                NULL;
          END;
       END IF;
    END;

    FUNCTION check_file_obbligatorio (p_codice_amm     IN VARCHAR2,
                                      p_codice_aoo     IN VARCHAR2,
                                      p_id_documento   IN NUMBER)
       RETURN NUMBER
    IS
    dep_fileOb VARCHAR2(10);
    dep_movimento VARCHAR2(10);
    BEGIN
       dep_fileOb := ag_parametro.get_valore ('FILE_OB_',
                                      p_codice_amm,
                                      p_codice_aoo,
                                      'N');
       if dep_fileOb = 'N' then
          return 0;
       else
          if p_id_documento is not null then
             begin
                 select modalita
                   into dep_movimento
                   from proto_view
                  where id_documento = p_id_documento
                    and stato_pr != 'DP'
                    and modalita = dep_fileOb
                 ;
                 return 1;
             exception
             when no_data_found then
                if dep_fileOb = 'Y' then
                   return 1;
                else
                   return 0;
                end if;
             when others then
                return 1;
             end;
          else
             return 1;
          end if;
       end if;
    END;

    FUNCTION delete_oggetto_file (p_codice_amm           IN VARCHAR2,
                                  p_codice_aoo           IN VARCHAR2,
                                  p_utente               IN VARCHAR2,
                                  p_data_aggiornamento   IN VARCHAR2,
                                  p_id_documento         IN NUMBER,
                                  p_id_oggetto_file      IN NUMBER)
       RETURN VARCHAR2
    IS
       d_message   VARCHAR2 (1000);
    BEGIN
       IF     p_id_oggetto_file IS NULL
          AND (check_firma_doc_princ (p_codice_amm,
                                     p_codice_aoo,
                                     p_id_documento) = 1
           or check_file_obbligatorio(p_codice_amm,
                                     p_codice_aoo,
                                     p_id_documento) = 1)
       THEN
          d_message :=
             'Impossibile eliminare il documento!! Sostituirlo con un altro.';
       ELSE
          UPDATE oggetti_file
             SET da_cancellare = 'S'
           WHERE     id_documento = p_id_documento
                 AND id_oggetto_file =
                        NVL (p_id_oggetto_file, id_oggetto_file)
                 AND TO_DATE (p_data_aggiornamento, 'dd/mm/yyyy hh24:mi:ss') =
                        (SELECT data_aggiornamento
                           FROM documenti
                          WHERE id_documento = p_id_documento);

          IF SQL%ROWCOUNT > 0
          THEN
             d_message := 'Ok';
             delete_copia_conforme (p_codice_amm,
                                    p_codice_aoo,
                                    p_id_documento,
                                    p_id_oggetto_file);
          ELSE
             d_message :=
                'Impossibile eliminare il documento!! Protocollo modificato da un altro utente.';
          END IF;
       END IF;

       RETURN d_message;
    END;

    PROCEDURE aggiorna_ultima_modifica (p_id_documento   IN VARCHAR2,
                                        p_utente         IN VARCHAR2)
    IS
    BEGIN
       UPDATE documenti
          SET data_aggiornamento = SYSDATE, utente_aggiornamento = p_utente
        WHERE id_documento = p_id_documento;
    END;

    PROCEDURE insert_allegati_temp (p_area       IN VARCHAR2,
                                    p_cm         IN VARCHAR2,
                                    p_cr         IN VARCHAR2,
                                    p_filename   IN VARCHAR2,
                                    p_utente        VARCHAR2)
    IS
    BEGIN
       IF p_filename IS NULL
       THEN
          raise_application_error (-20999,
                                   'Impossibile settare il nomefile nullo.');
       END IF;

       DELETE allegati_temp
        WHERE     area = p_area
              AND codice_modello = p_cm
              AND codice_richiesta = p_cr
              AND nomefile = p_filename;

       -- Serve per l'acquisizione tramite scan
       INSERT INTO allegati_temp (area,
                                  codice_modello,
                                  codice_richiesta,
                                  nomefile,
                                  stato,
                                  utente_aggiornamento,
                                  data_aggiornamento)
            VALUES (p_area,
                    p_cm,
                    p_cr,
                    p_filename,
                    'I',
                    p_utente,
                    SYSDATE);
    END;

    FUNCTION insert_allegati_file (p_area                 IN VARCHAR2,
                                   p_cm                   IN VARCHAR2,
                                   p_cr                   IN VARCHAR2,
                                   p_filename             IN VARCHAR2,
                                   p_data_aggiornamento      VARCHAR2,
                                   p_id_documento         IN NUMBER,
                                   p_id_allegato          IN NUMBER,
                                   p_utente                  VARCHAR2)
       RETURN VARCHAR2
    IS
       d_data   DATE;
       d_cr     VARCHAR (2000) := NVL (p_cr, '0');
    BEGIN
       IF p_filename IS NULL
       THEN
          raise_application_error (-20999,
                                   'Impossibile settare il nomefile nullo.');
       END IF;

       IF p_id_documento IS NOT NULL
       THEN
          SELECT data_aggiornamento
            INTO d_data
            FROM documenti
           WHERE id_documento = p_id_documento;

          IF p_data_aggiornamento <> TO_CHAR (d_data, 'dd/mm/yyyy hh24:mi:ss')
          THEN
             d_cr := '0';
          END IF;
       END IF;

       IF p_id_allegato IS NOT NULL
       THEN
          SELECT codice_richiesta
            INTO d_cr
            FROM documenti
           WHERE id_documento = p_id_allegato;
       END IF;

       /*
             IF d_cr <> '0'
             THEN
                INSERT INTO allegati_temp (area,
                                           codice_modello,
                                           codice_richiesta,
                                           nomefile,
                                           stato,
                                           utente_aggiornamento,
                                           data_aggiornamento)
                     VALUES (p_area,
                             p_cm,
                             d_cr,
                             p_filename,
                             'I',
                             p_utente,
                             SYSDATE);
             END IF;
       */
       RETURN d_cr;
    END;

    FUNCTION delete_allegati_file (p_area                 IN VARCHAR2,
                                   p_cm                   IN VARCHAR2,
                                   p_cr                   IN VARCHAR2,
                                   p_filename             IN VARCHAR2,
                                   p_data_aggiornamento      VARCHAR2,
                                   p_id_documento         IN NUMBER,
                                   p_id_allegato          IN NUMBER,
                                   p_utente                  VARCHAR2,
                                   p_id_oggetto_file      IN NUMBER)
       RETURN VARCHAR2
    IS
       d_message   VARCHAR2 (100);
    BEGIN
       IF p_id_allegato IS NULL
       THEN
          DELETE allegati_temp
           WHERE     area = p_area
                 AND codice_modello = p_cm
                 AND codice_richiesta = p_cr
                 AND nomefile = NVL (p_filename, nomefile)
                 AND utente_aggiornamento = p_utente;

          d_message := 'Ok';
       ELSE
          UPDATE oggetti_file
             SET da_cancellare = 'S'
           WHERE     id_documento = p_id_allegato
                 AND id_oggetto_file =
                        NVL (p_id_oggetto_file, id_oggetto_file);

          IF SQL%ROWCOUNT > 0
          THEN
             d_message := 'Ok';
          ELSE
             d_message :=
                'Impossibile eliminare il documento!!. Protocollo modificato da un altro utente.';
          END IF;
       END IF;

       RETURN d_message;
    END;

    FUNCTION get_allegati_temp (p_area     IN VARCHAR2,
                                p_cm       IN VARCHAR2,
                                p_cr       IN VARCHAR2,
                                p_utente   IN VARCHAR)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT nomefile nomefile, NULL id_oggetto_file, NULL id_documento
            FROM allegati_temp
           WHERE     area = p_area
                 AND codice_modello = p_cm
                 AND codice_richiesta = p_cr
          UNION
          SELECT filename nomefile, id_oggetto_file, f.id_documento
            FROM oggetti_file f, documenti d, tipi_documento td
           WHERE     f.id_documento = d.id_documento
                 AND d.id_tipodoc = td.id_tipodoc
                 AND d.area = td.area_modello
                 AND td.nome = p_cm
                 AND td.area_modello = p_area
                 AND d.codice_richiesta = p_cr
                 AND NVL (f.da_cancellare, 'N') <> 'S';

       RETURN d_result;
    END get_allegati_temp;

    FUNCTION get_allegati (p_id_documento   IN VARCHAR2,
                           p_area           IN VARCHAR2,
                           p_cm             IN VARCHAR2,
                           p_cr             IN VARCHAR2,
                           p_estrai_temp    IN NUMBER,
                           p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT allegato,
                 da_cancellare,
                 data_aggiornamento,
                 filename,
                 id_documento,
                 id_formato,
                 id_oggetto_file,
                 id_oggetto_file_padre,
                 utente_aggiornamento,
                 NVL (p_estrai_temp, 0) estrai_temp
            FROM oggetti_file
           WHERE id_documento = p_id_documento
          UNION
          SELECT 'N',
                 'N',
                 data_aggiornamento,
                 nomefile,
                 TO_NUMBER (NULL),
                 TO_NUMBER (NULL),
                 TO_NUMBER (NULL),
                 TO_NUMBER (NULL),
                 utente_aggiornamento,
                 NVL (p_estrai_temp, 0)
            FROM allegati_temp
           WHERE     area = p_area
                 AND codice_modello = p_cm
                 AND codice_richiesta = p_cr
                 AND utente_aggiornamento = p_utente
                 AND p_estrai_temp = 1;

       RETURN d_result;
    END get_allegati;

    FUNCTION get_allegati (p_id_documento IN VARCHAR2, p_utente VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT id_documento, id_oggetto_file, filename
            FROM oggetti_file
           WHERE id_documento = p_id_documento
          UNION
          SELECT ogfi.id_documento, ogfi.id_oggetto_file, alte.nomefile
            FROM oggetti_file ogfi, allegati_temp alte, documenti docu
           WHERE     ogfi.id_documento = p_id_documento
                 AND docu.id_documento = ogfi.id_documento
                 AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                 AND docu.codice_richiesta = alte.codice_richiesta(+)
                 AND alte.codice_modello(+) = 'M_ALLEGATO_PROTOCOLLO'
                 AND alte.area(+) = 'SEGRETERIA'
                 AND alte.utente_aggiornamento = p_utente;

       RETURN d_result;
    END get_allegati;

    PROCEDURE copia_allegati_temp (p_area          IN VARCHAR2,
                                   p_cm            IN VARCHAR2,
                                   p_cr            IN VARCHAR2,
                                   p_utente        IN VARCHAR2,
                                   p_id_allegato   IN VARCHAR2)
    IS
       d_result   afc.t_ref_cursor;
       nomefile   VARCHAR2 (100);
       allegato   BLOB;
       d_id       NUMBER;
    BEGIN
       OPEN d_result FOR
          SELECT nomefile, allegato
            FROM allegati_temp
           WHERE     area = p_area
                 AND codice_modello = p_cm
                 AND codice_richiesta = p_cr
                 AND utente_aggiornamento = p_utente;

       LOOP
          FETCH d_result INTO nomefile, allegato;

          EXIT WHEN d_result%NOTFOUND;

          SELECT ogg_file_sq.NEXTVAL INTO d_id FROM DUAL;

          INSERT INTO oggetti_file (id_oggetto_file,
                                    id_documento,
                                    id_oggetto_file_padre,
                                    id_formato,
                                    filename,
                                    testoocr,
                                    allegato,
                                    data_aggiornamento,
                                    utente_aggiornamento)
               VALUES (d_id,
                       p_id_allegato,
                       NULL,
                       0,
                       nomefile,
                       allegato,
                       'N',
                       SYSDATE,
                       p_utente);
       END LOOP;
    END copia_allegati_temp;

    PROCEDURE update_allegati_file (p_area                 IN VARCHAR2,
                                    p_cm                   IN VARCHAR2,
                                    p_cr                   IN VARCHAR2,
                                    p_filename             IN VARCHAR2,
                                    p_filename_old         IN VARCHAR2,
                                    p_data_aggiornamento      VARCHAR2,
                                    p_id_documento         IN NUMBER,
                                    p_id_allegato          IN NUMBER)
    IS
       d_data   DATE;
       d_id     NUMBER;
    BEGIN
       IF p_filename IS NULL
       THEN
          raise_application_error (-20999,
                                   'Impossibile settare il nomefile nullo.');
       END IF;

       IF p_id_documento IS NULL
       THEN
          UPDATE allegati_temp
             SET nomefile = p_filename
           WHERE     area = p_area
                 AND codice_modello = p_cm
                 AND codice_richiesta = p_cr
                 AND nomefile = p_filename_old;
       ELSE
          SELECT data_aggiornamento
            INTO d_data
            FROM documenti
           WHERE id_documento = p_id_documento;

          IF p_data_aggiornamento = TO_CHAR (d_data, 'dd/mm/yyyy hh24:mi:ss')
          THEN
             IF p_id_allegato IS NULL
             THEN
                UPDATE allegati_temp
                   SET nomefile = p_filename
                 WHERE     area = p_area
                       AND codice_modello = p_cm
                       AND codice_richiesta = p_cr
                       AND nomefile = p_filename_old;
             ELSE
                UPDATE oggetti_file
                   SET filename = p_filename
                 WHERE id_oggetto_file = p_id_allegato;
             END IF;
          END IF;
       END IF;
    END;

    FUNCTION get_id_oggetto_file (p_id_documento IN NUMBER)
       RETURN NUMBER
    IS
       d_return   NUMBER;
    BEGIN
       SELECT id_oggetto_file
         INTO d_return
         FROM oggetti_file
        WHERE id_documento = p_id_documento;

       RETURN d_return;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN NULL;
       WHEN TOO_MANY_ROWS
       THEN
          RETURN NULL;
    END;

    FUNCTION get_tag_mail (p_codice_amm     IN VARCHAR2,
                           p_codice_aoo     IN VARCHAR2,
                           p_id_documento   IN NUMBER,
                           p_utente         IN VARCHAR2)
       RETURN VARCHAR2
    IS
       d_return   VARCHAR2 (100);
    BEGIN
       SELECT NVL (
                 s.tag_mail,
                 DECODE (
                    ag_utilities.verifica_privilegio_utente (NULL,
                                                             'PINVIOI',
                                                             p_utente,
                                                             trunc(sysdate)),
                    1, ag_parametro.get_valore ('TAG_MAIL_ESTERNO_',
                                                p_codice_amm,
                                                p_codice_aoo,
                                                ''),
                    ''))
         INTO d_return
         FROM seg_unita s, proto_view p
        WHERE     p.id_documento = p_id_documento
              AND unita =
                     NVL (DECODE (unita_esibente, '--', ''),
                          unita_protocollante)
              AND s.codice_amministrazione = p_codice_amm;

       RETURN d_return;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN NULL;
    END;

    FUNCTION get_tag_email_mittente (p_codice_amm     IN VARCHAR2,
                                     p_codice_aoo     IN VARCHAR2,
                                     p_id_documento   IN NUMBER,
                                     p_utente         IN VARCHAR2)
       /*****************************************************************************
        NOME:        GET_TAG_EMAIL_MITTENTE
        DESCRIZIONE:
        RITORNO:
        Rev.  Data       Autore Descrizione.
        004   26/03/2014 MM     Modificata perche' falliva se non c'era tipo documento
                                associato al pg o se non aveva dataval_dal valorizzato.
        013   07/04/2017 SC     Gestione date privilegi
        016  26/10/2017  SC     Indirizzi multipli unita
        103  09/04/2019  MM     Modificata GET_TAG_EMAIL_MITTENTE in modo da passare
                                N come default del flag segnatura_completa quando
                                IS_ENTE_INTERPRO vale Y.
       ********************************************************************************/
       RETURN afc.t_ref_cursor
    IS
       d_segnatura            VARCHAR2 (1);
       d_segnatura_completa   VARCHAR2 (1);
       d_unita_comp           VARCHAR2 (50);
       d_result               afc.t_ref_cursor;
    BEGIN
       BEGIN
          SELECT NVL (segnatura_completa, decode(AG_PARAMETRO.GET_VALORE('IS_ENTE_INTERPRO', '@agStrut@', 'N'), 'Y','N','Y')),
                 NVL (segnatura, 'Y'),
                 NVL (DECODE (p.unita_esibente, '--', '', p.unita_esibente),
                      unita_protocollante)
            INTO d_segnatura_completa, d_segnatura, d_unita_comp
            FROM seg_tipi_documento tido, proto_view p, documenti docu
           WHERE     p.id_documento = p_id_documento
                 AND tido.tipo_documento(+) = p.tipo_documento
                 AND docu.id_documento(+) = tido.id_documento
                 AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
                 AND TRUNC (p.data) BETWEEN NVL (TIDO.DATAVAL_DAL(+),
                                                 TRUNC (p.data))
                                        AND NVL (TIDO.DATAVAL_AL(+),
                                                 TRUNC (p.data));
       EXCEPTION
          WHEN OTHERS
          THEN
             d_segnatura_completa := 'Y';
             d_segnatura := 'Y';
       END;

       OPEN d_result FOR
          SELECT nome,
                 tag_mail,
                 email,
                 tipo,
                 d_segnatura_completa segnatura_completa,
                 d_segnatura segnatura,
                 ordinamento
            FROM (SELECT 'UO' tipo,
                             DECODE (
                                inte.tipo_indirizzo,
                                'I', '(DEF) ',
                                'P',    '(PEC'
                                     || DECODE (ROWNUM,
                                                1, ') ','_'||
                                                ROWNUM || ') '),
                                '(' || ROWNUM || ')')
                          || s.nome
                             nome,
                         inte.tag_mail,
                         inte.indirizzo email,
                         decode (inte.tipo_indirizzo, 'I',1,'P',2,3) ordinamento
                    FROM seg_unita s, so4_indirizzi_telematici inte
                   WHERE     unita = d_unita_comp
                         AND s.codice_amministrazione = p_codice_amm
                         AND SYSDATE BETWEEN s.dal
                                         AND NVL (s.al,
                                                  TO_DATE (3333333, 'j'))
                         AND inte.id_unita_organizzativa = s.progr_unita_organizzativa

                         AND inte.tipo_indirizzo not in ('R', 'M', 'F')
                  UNION
                  SELECT 'AOO',
                         aoo.denominazione,
                         ag_parametro.get_valore ('TAG_MAIL_ESTERNO_',
                                                  p_codice_amm,
                                                  p_codice_aoo,
                                                  '')
                            tag_mail,
                         indirizzo_istituzionale email,
                         99 ordinamento
                    FROM so4_aoo_view aoo
                   WHERE     ag_utilities.verifica_privilegio_utente (
                                NULL,
                                'PINVIOI',


                                p_utente,
                                trunc(sysdate)) = 1
                         AND codice_amministrazione = p_codice_amm
                         AND codice_aoo = p_codice_aoo
                         AND SYSDATE BETWEEN aoo.dal
                                         AND NVL (aoo.al,
                                                  TO_DATE (3333333, 'j'))
                  ORDER BY ordinamento)
           WHERE tag_mail IS NOT NULL AND email IS NOT NULL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_UNITA_ANNULLAMENTI: ' || SQLERRM);
    END;

    FUNCTION get_tag_fax_mittente (p_codice_amm     IN VARCHAR2,
                                   p_codice_aoo     IN VARCHAR2,
                                   p_id_documento   IN NUMBER,
                                   p_utente         IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT nome,
                 tag_fax,
                 fax,
                 tipo
            FROM ( --                 SELECT   'UO' tipo, s.nome nome, s.tag_fax,
                    --                          '' fax
                    --                     FROM seg_unita s
                    --                    WHERE unita = d_unita_comp
                    --                      AND SYSDATE BETWEEN s.dal
                    --                                      AND NVL (s.al, TO_DATE (3333333, 'j'))
                    --                 UNION
                    SELECT 'AOO' tipo,
                           aoo.descrizione nome,
                           ag_parametro.get_valore ('TAG_INVIO_FAX_',
                                                    p_codice_amm,
                                                    p_codice_aoo,
                                                    '')
                              tag_fax,
                           fax fax
                      FROM so4_aoo aoo
                     WHERE     ag_utilities.verifica_privilegio_utente (
                                  NULL,
                                  'PINVIOI',


                                  p_utente,
                                  trunc(sysdate)) = 1
                           AND codice_amministrazione = p_codice_amm
                           AND codice_aoo = p_codice_aoo
                           AND SYSDATE BETWEEN aoo.dal
                                           AND NVL (aoo.al,
                                                    TO_DATE (3333333, 'j'))
                  ORDER BY 1 DESC)
           WHERE tag_fax IS NOT NULL AND fax IS NOT NULL;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_UNITA_ANNULLAMENTI: ' || SQLERRM);
    END;

    PROCEDURE aggiorna_mittente_commit (p_codice_amm     IN VARCHAR2,
                                        p_codice_aoo     IN VARCHAR2,
                                        p_id_documento   IN NUMBER,
                                        p_utente         IN VARCHAR2,
                                        p_tag_mail       IN VARCHAR2,
                                        p_email          IN VARCHAR2,
                                        p_tipo           IN VARCHAR2)
    IS
       PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
       aggiorna_mittente (p_codice_amm => p_codice_amm,
                          p_codice_aoo => p_codice_aoo,
                          p_id_documento => p_id_documento,
                          p_utente => p_utente,
                          p_tipo => p_tipo,
                          p_email => p_email);
       COMMIT;
    EXCEPTION
       WHEN OTHERS
       THEN
          ROLLBACK;
          RAISE;
    END;

    PROCEDURE aggiorna_mittente_commit (p_codice_amm     IN VARCHAR2,
                                        p_codice_aoo     IN VARCHAR2,
                                        p_id_documento   IN NUMBER,
                                        p_utente         IN VARCHAR2,
                                        p_tipo           IN VARCHAR2,


                                        p_email          IN VARCHAR2 default null)
    IS
       PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
       aggiorna_mittente (p_codice_amm => p_codice_amm,
                          p_codice_aoo => p_codice_aoo,
                          p_id_documento => p_id_documento,
                          p_utente => p_utente,
                          p_tipo => p_tipo,
                          p_email => p_email);
       COMMIT;
    EXCEPTION
       WHEN OTHERS
       THEN
          ROLLBACK;
          RAISE;
    END;

    PROCEDURE aggiorna_mittente (p_codice_amm     IN VARCHAR2,
                                 p_codice_aoo     IN VARCHAR2,
                                 p_id_documento   IN NUMBER,
                                 p_utente         IN VARCHAR2,
                                 p_tag_mail       IN VARCHAR2,
                                 p_email          IN VARCHAR2,
                                 p_tipo           IN VARCHAR2)
    IS
    BEGIN
       aggiorna_mittente (p_codice_amm,
                          p_codice_aoo,
                          p_id_documento,
                          p_utente,
                          p_tipo,
                          p_email);
    END;

    PROCEDURE aggiorna_mittente (p_codice_amm     IN VARCHAR2,
                                 p_codice_aoo     IN VARCHAR2,
                                 p_id_documento   IN NUMBER,
                                 p_utente         IN VARCHAR2,
                                 p_tipo           IN VARCHAR2,
                                 p_email          IN VARCHAR2 DEFAULT NULL)
    IS
       d_unita   VARCHAR2 (100);
       d_idrif   VARCHAR2 (100);
       d_desc    VARCHAR2 (1000);
    BEGIN
       BEGIN
          SELECT idrif,
                 NVL (DECODE (unita_esibente, '--', '', unita_esibente),
                      unita_protocollante),
                 seg_unita_pkg.get_nome_so4 (
                    NVL (DECODE (unita_esibente, '--', '', unita_esibente),
                         unita_protocollante))
            INTO d_idrif, d_unita, d_desc
            FROM proto_view p
           WHERE p.id_documento = p_id_documento;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             raise_application_error (
                -20999,
                'Documento con id ' || p_id_documento || ' non trovato');
          WHEN OTHERS
          THEN
             RAISE;
       END;

       IF p_tipo = 'AOO'
       THEN
          BEGIN
             SELECT denominazione
               INTO d_desc
               FROM so4_aoo_view
              WHERE     codice_amministrazione = p_codice_amm
                    AND codice_aoo = p_codice_aoo
                    AND al IS NULL;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                raise_application_error (
                   -20999,
                      'Aoo '''
                   || p_codice_aoo
                   || ''' per amministrazione '''
                   || p_codice_amm
                   || ''' non trovata');
             WHEN OTHERS
             THEN
                RAISE;
          END;
       END IF;

       BEGIN
          SELECT    denominazione
                 || DECODE (
                       d_desc,
                       NULL, '',
                          DECODE (p_tipo, 'AOO', ':AOO:', ':UO:')
                       || TRIM (d_desc))
            INTO d_desc
            FROM so4_amministrazioni_view
           WHERE codice = p_codice_amm AND al IS NULL;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             raise_application_error (
                -20999,
                'Amministrazione ''' || p_codice_amm || ''' non trovata');
          WHEN OTHERS
          THEN
             RAISE;
       END;

       DECLARE
          d_count          INTEGER;
          d_precisazione   VARCHAR2 (1000);
       BEGIN
          d_precisazione :=
             ' (amm: ' || p_codice_amm || ' aoo: ' || p_codice_aoo;

          IF p_tipo = 'UO'
          THEN
             d_precisazione := d_precisazione || ' unita'': ' || d_unita;
          END IF;

          d_precisazione := d_precisazione || ' - ' || d_desc || ').';

          BEGIN
             SELECT COUNT (1)
               INTO d_count
               FROM seg_anagrafici
              WHERE     denominazione = d_desc
                    AND anagrafica = 'S'
                    AND cod_amm = p_codice_amm
                    AND cod_aoo = p_codice_aoo
                    AND NVL (cod_uo, ' ') =
                           DECODE (p_tipo, 'UO', d_unita, NVL (cod_uo, ' '))
                    AND al IS NULL
                    AND EMAIL = DECODE(p_email, NULL, EMAIL, p_email);
          EXCEPTION
             WHEN OTHERS
             THEN
                raise_application_error (
                   -20999,
                      'Errore in identificazione mittente'
                   || d_precisazione
                   || SQLERRM);
          END;

          d_precisazione :=
             d_precisazione || ' Impossibile determinare il mittente.';

          IF d_count = 0
          THEN
             raise_application_error (
                -20999,
                'Soggetto non trovato' || d_precisazione);
          ELSIF d_count > 1
          THEN
             raise_application_error (
                -20999,
                   'Troppi soggetti corrispondono ai parametri passati'
                || d_precisazione);
          END IF;
       EXCEPTION
          WHEN OTHERS
          THEN
             RAISE;
       END;

       BEGIN
          DECLARE
             d_esiste_dummy   NUMBER;
             d_id_doc         NUMBER;
          BEGIN
             -- verifica se esiste rapporto DUMMY
             SELECT COUNT (1)
               INTO d_esiste_dummy
               FROM seg_soggetti_protocollo
              WHERE idrif = d_idrif AND tipo_rapporto = 'DUMMY';

             IF d_esiste_dummy = 0
             THEN
                -- non esiste, quindi lo creiamo duplicandone un altro
                SELECT MIN (id_documento)
                  INTO d_id_doc
                  FROM seg_soggetti_protocollo
                 WHERE idrif = d_idrif AND tipo_rapporto = 'DEST';

                d_id_doc :=
                   ag_utilities.duplica_documento (d_id_doc,
                                                   p_utente,
                                                   0,
                                                   1);

                UPDATE seg_soggetti_protocollo
                   SET idrif = d_idrif, tipo_rapporto = 'DUMMY'
                 WHERE id_documento = d_id_doc;
             END IF;
          EXCEPTION
             WHEN OTHERS
             THEN
                raise_application_error (
                   -20999,
                      'Record identificato da idrif '
                   || d_idrif
                   || ' e tipo_rapporto ''DUMMY'' NON PRESENTE. '
                   || SQLERRM);
          END;

          FOR mitt
             IN (SELECT *
                   FROM seg_anagrafici
                  WHERE     denominazione = d_desc
                        AND anagrafica = 'S'
                        AND cod_amm = p_codice_amm
                        AND cod_aoo = p_codice_aoo
                        AND NVL (cod_uo, ' ') =
                               DECODE (p_tipo,
                                       'UO', d_unita,
                                       NVL (cod_uo, ' '))
                        AND al IS NULL
                        AND EMAIL = DECODE(p_email, NULL, EMAIL, p_email))
          LOOP
             BEGIN
                UPDATE seg_soggetti_protocollo
                   SET cap_amm = mitt.cap_amm,
                       cap_aoo = mitt.cap_aoo,
                       cap_per_segnatura = mitt.cap_per_segnatura,
                       cap_res = mitt.cap_res,
                       codice_amministrazione = mitt.cod_amm,
                       codice_aoo = mitt.cod_aoo,
                       cod_amm = mitt.cod_amm,
                       cod_aoo = mitt.cod_aoo,
                       cod_uo = mitt.cod_uo,
                       comune_amm = mitt.comune_amm,
                       comune_aoo = mitt.comune_aoo,
                       comune_per_segnatura = mitt.comune_per_segnatura,
                       comune_res = mitt.comune_res,
                       dal = mitt.dal,
                       dal_amm = TO_DATE (mitt.dal_amm, 'dd/mm/yyyy'),
                       denominazione_per_segnatura =
                          mitt.denominazione_per_segnatura,
                       descrizione_amm = mitt.descrizione_amm,
                       descrizione_aoo = mitt.descrizione_aoo,
                       descrizione_uo = mitt.descrizione_uo,
                       email = mitt.email,
                       fax = mitt.fax,
                       indirizzo_amm = mitt.indirizzo_amm,
                       indirizzo_aoo = mitt.indirizzo_aoo,
                       indirizzo_per_segnatura = mitt.indirizzo_per_segnatura,
                       mail_amm = mitt.mail_amm,
                       fax_amm = mitt.fax_amm,
                       mail_aoo = mitt.mail_aoo,
                       fax_aoo = mitt.fax_aoo,
                       ni = mitt.ni,
                       ni_amm = mitt.ni_amm,
                       provincia_per_segnatura = mitt.provincia_per_segnatura,
                       sigla_prov_amm = mitt.sigla_prov_amm,
                       sigla_prov_aoo = mitt.sigla_prov_aoo,
                       tipo = mitt.tipo,
                       tipo_soggetto = mitt.tipo_soggetto,
                       cap_uo = mitt.cap_uo,
                       comune_uo = mitt.comune_uo,
                       fax_uo = mitt.fax_uo,
                       indirizzo_uo = mitt.indirizzo_uo,
                       mail_uo = mitt.mail_uo,
                       sigla_prov_uo = mitt.sigla_prov_uo,
                       tel_uo = mitt.tel_uo
                 WHERE idrif = d_idrif AND tipo_rapporto = 'DUMMY';
             EXCEPTION
                WHEN OTHERS
                THEN
                   raise_application_error (
                      -20999,
                      'Errore in aggiornamento mittente. ' || SQLERRM);
             END;

             IF SQL%ROWCOUNT = 0
             THEN
                raise_application_error (
                   -20999,
                      'Fallito aggiornamento mittente. Record identificato da idrif '
                   || d_idrif
                   || ' e tipo_rapporto ''DUMMY''.');
             END IF;
          END LOOP;
       EXCEPTION
          WHEN OTHERS
          THEN
             RAISE;
       END;
    END;

    FUNCTION get_tagmail_indirizzo (p_id_documento   IN NUMBER,
                                    p_utente         IN VARCHAR2)
       RETURN VARCHAR2
    IS
       d_return                    VARCHAR2 (100);
       d_unita_esibente            VARCHAR2 (50);
       d_unita_protocollante       VARCHAR2 (50);
       d_codice_aoo                VARCHAR2 (100);
       d_codice_amministrazione    VARCHAR2 (100);
       d_destinatari               VARCHAR2 (32767);
       d_indirizzo_istituzionale   VARCHAR2 (100);
       d_indirizzo                 VARCHAR2 (100);
       d_tag                       VARCHAR2 (100);
       d_destinatario              VARCHAR2 (100);
       d_id_indirizzo              so4_indirizzi_telematici.id_indirizzo%TYPE;
       d_unor                      so4_indirizzi_telematici.id_unita_organizzativa%TYPE;
       d_codice_uo                 so4_auor.codice_uo%TYPE;
    BEGIN
       -- unita esibente e protocollante + codice aoo e codice amm
       BEGIN
          SELECT unita_esibente,
                 unita_protocollante,
                 codice_amministrazione,
                 codice_aoo
            INTO d_unita_esibente,
                 d_unita_protocollante,
                 d_codice_amministrazione,
                 d_codice_aoo
            FROM proto_view
           WHERE id_documento = p_id_documento;
       EXCEPTION
          WHEN OTHERS
          THEN
             RAISE;
       END;

       DBMS_OUTPUT.put_line (d_codice_amministrazione || ' ' || d_codice_aoo);

       -- indirizzo istituzionale
       SELECT indirizzo_istituzionale
         INTO d_indirizzo_istituzionale
         FROM so4_aoo_view aoo
        WHERE     codice_amministrazione = d_codice_amministrazione
              AND codice_aoo = d_codice_aoo
              AND al IS NULL;

       -- destinatari
       SELECT destinatari
         INTO d_destinatari
         FROM seg_memo_protocollo smp, riferimenti r
        WHERE     smp.id_documento = r.id_documento_rif
              AND r.id_documento = p_id_documento
              AND r.tipo_relazione = 'MAIL';

       DBMS_OUTPUT.put_line (d_destinatari);

       -- se c'¿ unita esibente e il suo indirizzo ¿ tra i destinatari allora si ritorna tagmail e indirizzo della esibente
       IF (d_unita_esibente IS NOT NULL)
       THEN
          d_indirizzo := seg_unita_pkg.get_email (d_unita_esibente);

          IF (INSTR (UPPER (d_destinatari), UPPER (d_indirizzo)) > 0)
          THEN
             d_tag :=
                seg_unita_pkg.get_tagmail (d_unita_esibente,
                                           d_codice_amministrazione,
                                           d_codice_aoo);
             d_return := d_tag || '##' || d_indirizzo;
          END IF;
       -- se c'¿ unita protocollante e il suo indirizzo ¿ tra i destinatari allora si ritorna tagmail e indirizzo della protocollante
       ELSIF (d_unita_protocollante IS NOT NULL)
       THEN
          d_indirizzo := seg_unita_pkg.get_email (d_unita_protocollante);
          DBMS_OUTPUT.put_line (
             'indirizzo_unita_protocollante = ' || d_indirizzo);

          IF (INSTR (UPPER (d_destinatari), UPPER (d_indirizzo)) > 0)
          THEN
             d_tag :=
                seg_unita_pkg.get_tagmail (d_unita_protocollante,
                                           d_codice_amministrazione,
                                           d_codice_aoo);
             d_return := d_tag || '##' || d_indirizzo;
          END IF;
       END IF;
       IF d_return IS NOT NULL AND SUBSTR(d_return, 1, 2) = '##' THEN
          d_return := NULL;
       END IF;
       IF (d_return IS NULL)
       THEN
          -- controllo dei privilegi utente
          IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                       'PMAILT',


                                                       p_utente,
                                                       trunc(sysdate)) = 1)
          THEN
             -- se PMALT e indirizzo ist ¿ tra i destinatari si ritorna tagmail e indirizzo della casella istituzionale
             IF (INSTR (UPPER (d_destinatari),
                        UPPER (d_indirizzo_istituzionale)) > 0)
             THEN
                d_return :=
                      ag_parametro.get_valore ('TAG_MAIL_ESTERNO_',
                                               d_codice_amministrazione,
                                               d_codice_aoo,
                                               '')
                   || '##'
                   || d_indirizzo_istituzionale;
             ELSE
                -- se PMAILT e no indirizzo istituzionale, allora si cerca tra i destinatari quello corrispondente ad una unita organizzativa che abbia un tagmail con cui inviare
                WHILE (d_destinatari IS NOT NULL)
                LOOP
                   d_destinatario := afc.get_substr (d_destinatari, ',');

                   FOR c IN (SELECT id_indirizzo
                               FROM so4_indirizzi_telematici
                              WHERE indirizzo = d_destinatario)
                   LOOP
                      d_unor :=
                         so4_inte_pkg.get_id_unita_organizzativa (
                            c.id_indirizzo);
                      d_codice_uo :=
                         so4_ags_pkg.unita_get_codice_valido (d_unor);
                      d_tag :=
                         seg_unita_pkg.get_tagmail (d_codice_uo,
                                                    d_codice_amministrazione,
                                                    d_codice_aoo);

                      IF (d_tag IS NOT NULL)
                      THEN
                         d_return := d_tag || '##' || d_destinatario;
                         EXIT;
                      END IF;
                   END LOOP;
                END LOOP;
             END IF;
          ELSIF (ag_utilities.verifica_privilegio_utente (NULL,
                                                          'PMAILI',


                                                          p_utente,
                                                          trunc(sysdate)) = 1)
          THEN
             -- se PMALI e indirizzo istituzionale ¿ tra i destinatari si ritorna tagmail e indirizzo della casella istituzionale
             IF (INSTR (UPPER (d_destinatari),
                        UPPER (d_indirizzo_istituzionale)) > 0)
             THEN
                d_return :=
                      ag_parametro.get_valore ('TAG_MAIL_ESTERNO_',
                                               d_codice_amministrazione,
                                               d_codice_aoo,
                                               '')
                   || '##'
                   || d_indirizzo_istituzionale;
             END IF;
          ELSIF (ag_utilities.verifica_privilegio_utente (NULL,
                                                          'PMAILU',


                                                          p_utente,
                                                          trunc(sysdate)) = 1)
          THEN
             -- se PMAILU allora si cerca tra i destinatari quello corrispondente ad una unita organizzativa che abbia un tagmail con cui inviare
             WHILE (d_destinatari IS NOT NULL)
             LOOP
                d_destinatario := afc.get_substr (d_destinatari, ',');

                FOR c IN (SELECT id_indirizzo
                            FROM so4_indirizzi_telematici
                           WHERE indirizzo = d_destinatario)
                LOOP
                   d_unor :=
                      so4_inte_pkg.get_id_unita_organizzativa (c.id_indirizzo);
                   d_codice_uo := so4_ags_pkg.unita_get_codice_valido (d_unor);
                   d_tag :=
                      seg_unita_pkg.get_tagmail (d_codice_uo,
                                                 d_codice_amministrazione,
                                                 d_codice_aoo);

                   IF (d_tag IS NOT NULL)
                   THEN
                      d_return := d_tag || '##' || d_destinatario;
                      EXIT;
                   END IF;
                END LOOP;
             END LOOP;
          END IF;
       END IF;
       IF d_return IS NOT NULL AND SUBSTR(d_return, 1, 2) = '##' THEN
          d_return := NULL;
       END IF;
       -- se non e' stato trovato alcun risultato si ritorna tagmail e indirizzo della casella istituzionale
       IF (d_return IS NULL)
       THEN
          d_return :=
                ag_parametro.get_valore ('TAG_MAIL_ESTERNO_',
                                         d_codice_amministrazione,
                                         d_codice_aoo,
                                         '')
             || '##'
             || d_indirizzo_istituzionale;
       END IF;

       RETURN d_return;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RAISE;                                                 --return NULL;
    END;

    PROCEDURE upd_ver_firma (p_id_documento    VARCHAR2,
                             p_esito           VARCHAR2,
                             p_data            VARCHAR2)
    IS
    BEGIN
       --raise_application_error(-20999, p_id_documento ||' '||p_data);
       UPDATE spr_protocolli
          SET verifica_firma = p_esito,
              data_verifica =
                 DECODE (p_data,
                         'NO', data_verifica,
                         TO_DATE (p_data, 'dd/mm/yyyy hh24:mi:ss'))
        WHERE id_documento = p_id_documento;

       NULL;
    END;

    FUNCTION get_tipi_soggetto
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT tipo_soggetto, descrizione, sequenza FROM ag_tipi_soggetto
          UNION
          SELECT -1, 'Tutti', 0
            FROM DUAL
          ORDER BY sequenza;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_TIPI_SOGGETTO: ' || SQLERRM);
    END;

    FUNCTION check_ubicazione_vs_fascicolo (
       p_idrif_fascicolo            VARCHAR2,
       p_id_documento_protocollo    NUMBER)
       RETURN NUMBER
    IS
       dep_ufficio_ricevente   seg_unita.unita%TYPE := NULL;
       dep_ubicato_altrove     NUMBER := 0;
    BEGIN
       RETURN ag_fascicolo_utility.check_ubicazione_vs_fascicolo (
                 p_idrif_fascicolo,
                 p_id_documento_protocollo);
    END check_ubicazione_vs_fascicolo;

    FUNCTION ricongiungi_a_fascicolo (p_area      VARCHAR2,
                                      p_cm        VARCHAR2,
                                      p_cr        VARCHAR2,
                                      p_utente    VARCHAR2,
                                      p_unita     VARCHAR2)
       RETURN VARCHAR2
    IS
    BEGIN
       RETURN ag_smistabile_utility.ricongiungi_a_fascicolo (p_area,
                                                             p_cm,
                                                             p_cr,
                                                             p_utente,
                                                             p_unita);
    END;

    PROCEDURE set_stato_firma (p_id_documento NUMBER, p_stato_firma VARCHAR2)
    IS
    BEGIN
       UPDATE spr_protocolli
          SET stato_firma = p_stato_firma
        WHERE id_documento = p_id_documento;
    END;

    PROCEDURE notifica_ins_fasc (p_id_documento VARCHAR2)
    IS
    BEGIN
       IF ag_utilities.verifica_categoria_documento (p_id_documento, 'ATTI') =
             0
       THEN
          FOR f
             IN (SELECT cartelle.id_cartella
                   FROM links,
                        cartelle,
                        seg_fascicoli,
                        documenti
                  WHERE     links.id_oggetto = p_id_documento
                        AND links.tipo_oggetto = 'D'
                        AND links.id_cartella = cartelle.id_cartella
                        AND cartelle.id_documento_profilo =
                               seg_fascicoli.id_documento
                        AND NVL (cartelle.stato, 'BO') = 'BO'
                        AND seg_fascicoli.id_documento =
                               documenti.id_documento
                        AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB'))
          LOOP
             ag_utilities_cruscotto.notifica_ins_doc_fasc (p_id_documento,
                                                           f.id_cartella);
          END LOOP;
       END IF;
    END;

    FUNCTION calcola_icona (p_idrif_documento    VARCHAR2,
                            p_id_cartella        NUMBER,
                            p_icona_default      VARCHAR2)
       RETURN VARCHAR2
    IS
    BEGIN
       RETURN ag_smistabile_utility.calcola_icona (p_idrif_documento,
                                                   p_id_cartella,
                                                   p_icona_default);
    END;

    FUNCTION exists_mancata_consegna (p_idrif VARCHAR2)
       RETURN VARCHAR2
    IS
       ret   VARCHAR2 (1) := 'N';
    BEGIN
       SELECT 'Y'
         INTO ret
         FROM DUAL
        WHERE EXISTS
                 (SELECT 1
                    FROM seg_soggetti_protocollo
                   WHERE     idrif = p_idrif
                         AND tipo_rapporto = 'DEST'
                         AND NVL (ric_mancata_consegna, 'N') = 'Y');

       RETURN ret;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN 'N';
    END;

    FUNCTION exists_consegna (p_idrif VARCHAR2)
       RETURN VARCHAR2
    IS
       ret   VARCHAR2 (1) := 'N';
    BEGIN
       SELECT 'Y'
         INTO ret
         FROM DUAL
        WHERE EXISTS
                 (SELECT 1
                    FROM seg_soggetti_protocollo
                   WHERE     idrif = p_idrif
                         AND tipo_rapporto = 'DEST'
                         AND NVL (registrata_consegna, 'N') = 'Y');

       RETURN ret;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN 'N';
    END;

    FUNCTION exists_conferma (p_idrif VARCHAR2)
       RETURN VARCHAR2
    IS
       ret   VARCHAR2 (1) := 'N';
    BEGIN
       SELECT 'Y'
         INTO ret
         FROM DUAL
        WHERE EXISTS
                 (SELECT 1
                    FROM seg_soggetti_protocollo
                   WHERE     idrif = p_idrif
                         AND tipo_rapporto = 'DEST'
                         AND NVL (ricevuta_conferma, 'N') = 'Y');

       RETURN ret;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN 'N';
    END;

    FUNCTION exists_eccezione (p_idrif VARCHAR2)
       RETURN VARCHAR2
    IS
       ret   VARCHAR2 (1) := 'N';
    BEGIN
       SELECT 'Y'
         INTO ret
         FROM DUAL
        WHERE EXISTS
                 (SELECT 1
                    FROM seg_soggetti_protocollo
                   WHERE     idrif = p_idrif
                         AND tipo_rapporto = 'DEST'
                         AND NVL (ricevuta_eccezione, 'N') = 'Y');

       RETURN ret;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN 'N';
    END;

    FUNCTION exists_annullamento (p_idrif VARCHAR2)
       RETURN VARCHAR2
    IS
       ret   VARCHAR2 (1) := 'N';
    BEGIN
       SELECT 'Y'
         INTO ret
         FROM DUAL
        WHERE EXISTS
                 (SELECT 1
                    FROM seg_soggetti_protocollo
                   WHERE     idrif = p_idrif
                         AND tipo_rapporto = 'DEST'
                         AND NVL (ricevuto_annullamento, 'N') = 'Y');

       RETURN ret;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN 'N';
    END;

    FUNCTION is_in_fasc_riservato (p_id_documento NUMBER)
       RETURN NUMBER
    IS
    BEGIN
       RETURN ag_classificabile_utility.is_in_fasc_riservato (p_id_documento);
    END;

    FUNCTION check_modificati_dettagli (p_id_documento NUMBER)
       RETURN NUMBER
    IS
       ret          NUMBER := 0;
       /******************************************************************************
          NAME:       CHECK_MOD_PROTO_X_ALBO
          PURPOSE:
          REVISIONS:
          Ver        Date        Author           Description
          ---------  ----------  ---------------  ------------------------------------
          1.0        29/05/2013          1. Created this function.
          NOTES:
          Automatically available Auto Replace Keywords:
             Object Name:     CHECK_MOD_PROTO_X_ALBO
             Sysdate:         29/05/2013
             Date and Time:   29/05/2013, 10:54:35, and 29/05/2013 10:54:35
             Username:         (set in TOAD Options, Procedure Editor)
             Table Name:       (set in the "New PL/SQL Object" dialog)
       ******************************************************************************/
       d_data_agg   DATE;
       d_conta      NUMBER := 0;
    BEGIN
       SELECT data_aggiornamento
         INTO d_data_agg
         FROM documenti
        WHERE id_documento = p_id_documento;

       SELECT COUNT (1)
         INTO d_conta
         FROM (SELECT aclo.data_aggiornamento, 'FILE_PRINCIPALE'
                 FROM activity_log aclo, oggetti_file_log ogfi
                WHERE     aclo.id_log = ogfi.id_log
                      AND aclo.id_documento = p_id_documento
                      AND aclo.data_aggiornamento > d_data_agg
               UNION
               SELECT aclo.data_aggiornamento, valo.colonna
                 FROM activity_log aclo, valori_log valo
                WHERE     aclo.id_log = valo.id_log
                      AND aclo.id_documento IN (SELECT id_documento
                                                  FROM seg_allegati_protocollo
                                                 WHERE idrif IN (SELECT idrif
                                                                   FROM proto_view
                                                                  WHERE id_documento =
                                                                           p_id_documento))
                      AND aclo.data_aggiornamento > d_data_agg
               UNION
               SELECT aclo.data_aggiornamento, 'ALLEGATO'
                 FROM activity_log aclo, oggetti_file_log ogfi
                WHERE     aclo.id_log = ogfi.id_log
                      AND aclo.id_documento IN (SELECT id_documento
                                                  FROM seg_allegati_protocollo
                                                 WHERE idrif IN (SELECT idrif
                                                                   FROM proto_view
                                                                  WHERE id_documento =
                                                                           p_id_documento))
                      AND aclo.data_aggiornamento > d_data_agg
               UNION
               SELECT aclo.data_aggiornamento, valo.colonna
                 FROM activity_log aclo, valori_log valo
                WHERE     aclo.id_log = valo.id_log
                      AND aclo.id_documento IN (SELECT id_documento
                                                  FROM seg_soggetti_protocollo
                                                 WHERE idrif IN (SELECT idrif
                                                                   FROM proto_view
                                                                  WHERE id_documento =
                                                                           p_id_documento))
                      AND aclo.data_aggiornamento > d_data_agg);

       IF d_conta > 0
       THEN
          ret := 1;
       END IF;

       RETURN ret;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN ret;
       WHEN OTHERS
       THEN
          RETURN ret;
          RAISE;
    END check_modificati_dettagli;

    FUNCTION has_smistamenti_attivi_fasc (p_codice_amm         IN VARCHAR2,
                                          p_codice_aoo         IN VARCHAR2,
                                          p_class_cod          IN VARCHAR2,
                                          p_class_dal          IN VARCHAR2,
                                          p_fascicolo_anno     IN VARCHAR2,
                                          p_fascicolo_numero   IN VARCHAR2)
       RETURN NUMBER
    IS
       d_id_cartella   NUMBER;
    BEGIN
       SELECT cart_fasc.id_cartella
         INTO d_id_cartella
         FROM seg_fascicoli fasc, documenti docu_fasc, cartelle cart_fasc
        WHERE     fasc.codice_amministrazione = p_codice_amm
              AND fasc.codice_aoo = p_codice_aoo
              AND fasc.class_cod = p_class_cod
              AND fasc.class_dal = TO_DATE (p_class_dal, 'dd/mm/yyyy')
              AND docu_fasc.id_documento = fasc.id_documento
              AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                'RE',
                                                                'PB')
              AND cart_fasc.id_documento_profilo = docu_fasc.id_documento
              AND NVL (cart_fasc.stato, 'BO') <> 'CA'
              AND fasc.fascicolo_anno = p_fascicolo_anno
              AND fasc.fascicolo_numero = p_fascicolo_numero;

       RETURN ag_fascicolo_utility.restano_smistamenti_attivi (d_id_cartella);
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          RETURN 0;
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.HAS_SMISTAMENTI_ATTIVI_FASC: ' || SQLERRM);
    END;

    FUNCTION is_messaggio_inviato (p_tipo_messaggio    VARCHAR2,
                                   p_id_documento      NUMBER)
       RETURN VARCHAR2
    IS
       d_return   VARCHAR2 (1) := 'N';
    BEGIN
       SELECT NVL (MIN ('Y'), 'N')
         INTO d_return
         FROM seg_memo_protocollo m, riferimenti r
        WHERE     m.id_documento = r.id_documento_rif
              AND r.id_documento = p_id_documento
              AND r.tipo_relazione = UPPER (p_tipo_messaggio) --('FAX', 'MAIL')
                                                             ;

       RETURN d_return;
    END;

    FUNCTION check_prendi_in_carico_barcode (p_bc       IN VARCHAR2,
                                             p_utente   IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       /*****************************************************************************
         NOME:        CHECK_PRENDI_INCARICO_BARCODE

         DESCRIZIONE:  VERIFIFICA SE LO SMISTAMENTO RELATIVO AL BARCODE  PUO ESSERE PRESO IN CARICO

         RITORNO:

         Rev.  Data             Autore      Descrizione.
         00    04/11/2014   MMUR     Prima emissione.
        ********************************************************************************/
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
          SELECT PROTO_VIEW.idrif,
                 ag_competenze_documento.da_ricevere (PROTO_VIEW.ID_DOCUMENTO,
                                                      p_utente)
                    AS DA_RICEVERE,
                 PROTO_VIEW.ID_DOCUMENTO_PROTOCOLLO,
                 (SELECT NOME
                    FROM DOCUMENTI D, TIPI_DOCUMENTO TP
                   WHERE     D.ID_TIPODOC = TP.ID_TIPODOC
                         AND D.ID_DOCUMENTO = proto_view.id_documento)
                    AS codice_modello,
                 area,
                 codice_richiesta
            FROM PROTO_VIEW, documenti
           WHERE     PROTO_VIEW.id_documento = TO_NUMBER (p_bc)
                 AND documenti.id_documento = PROTO_VIEW.id_documento;

       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.CHECK_PRENDI_INCARICO_BARCODE: ' || SQLERRM);
    END check_prendi_in_carico_barcode;

    FUNCTION get_url (p_anno               NUMBER,
                      p_tipo_registro      VARCHAR2,
                      p_numero             NUMBER,
                      p_codice_amm      IN VARCHAR2,
                      p_codice_aoo      IN VARCHAR2,
                      p_read_write         VARCHAR2)
       RETURN VARCHAR2
    IS
       /*****************************************************************************
          NOME:        GET_URL
          DESCRIZIONE: ritorna l'url al protocollo identificato da p_anno,
                       p_tipo_registro e p_numero
          RITORNO:
          Rev.  Data       Autore  Descrizione.
          006   14/08/2015 MM  Gestione tipo registro di default.
       ********************************************************************************/
       d_id_documento    NUMBER;
       d_tipo_registro   VARCHAR2 (100) := p_tipo_registro;
    BEGIN
       IF d_tipo_registro IS NULL
       THEN
          IF p_codice_amm IS NOT NULL AND p_codice_aoo IS NOT NULL
          THEN
             d_tipo_registro :=
                AG_PARAMETRO.GET_VALORE ('TIPO_REGISTRO',
                                         p_codice_Amm,
                                         p_codice_aoo,
                                         '');
          ELSE
             d_tipo_registro :=
                AG_PARAMETRO.GET_VALORE ('TIPO_REGISTRO_1', '@agVar@', '');
          END IF;
       END IF;

       SELECT id_documento
         INTO d_id_documento
         FROM proto_view
        WHERE     anno = p_anno
              AND tipo_registro = d_tipo_registro
              AND numero = p_numero;

       RETURN get_url (d_id_documento, NVL (p_read_write, 'r'));
    EXCEPTION
       WHEN OTHERS
       THEN
          RETURN '';
    END;

    FUNCTION get_url (p_id_documento NUMBER, p_read_write VARCHAR2)
       RETURN VARCHAR2
    IS
    BEGIN
       RETURN gdc_utility_pkg.f_get_url_oggetto ('',
                                                 '',
                                                 p_id_documento,
                                                 'D',
                                                 '',
                                                 '',
                                                 '',
                                                 UPPER (p_read_write),
                                                 '',
                                                 '',
                                                 '5',
                                                 'N');
    END;

    PROCEDURE delete_from_titolario (p_id_documento        NUMBER,
                                     p_class_cod           VARCHAR2,
                                     p_class_dal           DATE,
                                     p_fascicolo_anno      NUMBER,
                                     p_fascicolo_numero    VARCHAR2,
                                     p_codice_amm          VARCHAR2,
                                     p_codice_aoo          VARCHAR2)
    IS
       d_id_cartella   NUMBER;
    BEGIN
       IF p_class_cod IS NOT NULL AND p_class_dal IS NOT NULL
       THEN
          IF p_fascicolo_anno IS NOT NULL AND p_fascicolo_numero IS NOT NULL
          THEN
             d_id_cartella :=
                ag_fascicolo_utility.get_id_cartella (p_class_cod,
                                                      p_class_dal,
                                                      p_fascicolo_anno,
                                                      p_fascicolo_numero,
                                                      p_codice_amm,
                                                      p_codice_aoo);
          ELSE
             d_id_cartella :=
                ag_classificazione.get_id_cartella (p_class_cod,
                                                    p_class_dal,
                                                    p_codice_amm,
                                                    p_codice_aoo);
          END IF;

          DELETE links
           WHERE     id_oggetto = p_id_documento
                 AND id_cartella = d_id_cartella
                 AND tipo_oggetto = 'D';
       END IF;
    EXCEPTION
       WHEN OTHERS
       THEN
          RAISE_APPLICATION_ERROR (
             -20999,
                'Problemi in eliminazione documento dalla cartella. verificare le classifiche secondarie.'
             || SQLERRM);
    END;

    PROCEDURE delete_from_titolario (p_id_documento        NUMBER,
                                     p_class_cod           VARCHAR2,
                                     p_class_dal           VARCHAR2,
                                     p_fascicolo_anno      NUMBER,
                                     p_fascicolo_numero    VARCHAR2,
                                     p_codice_amm          VARCHAR2,
                                     p_codice_aoo          VARCHAR2)
    IS
       d_class_dal   DATE := TO_DATE (p_class_dal, 'dd/mm/yyyy');
       d_anno        NUMBER := p_fascicolo_anno;
    BEGIN
       IF d_anno <= 0
       THEN
          d_anno := NULL;
       END IF;

       delete_from_titolario (p_id_documento,
                              p_class_cod,
                              d_class_dal,
                              d_anno,
                              p_fascicolo_numero,
                              p_codice_amm,
                              p_codice_aoo);
    END;

    FUNCTION count_oggetti_file (p_id_documento NUMBER)
       RETURN NUMBER
    IS
       d_ret   NUMBER;
    BEGIN
       SELECT COUNT (1)
         INTO d_ret
         FROM oggetti_file
        WHERE     id_documento = p_id_documento
              AND filename <> 'LETTERAUNIONE.RTFHIDDEN';

       RETURN d_ret;
    EXCEPTION
       WHEN OTHERS
       THEN
          RETURN 0;
    END;

    FUNCTION crea_allegato (p_id_padre                  NUMBER,
                            p_idrif                     VARCHAR2,
                            p_descrizione               VARCHAR2,
                            p_tipo_allegato             VARCHAR2,
                            p_codice_amministrazione    VARCHAR2,
                            p_codice_aoo                VARCHAR2,
                            p_utente                    VARCHAR2)
       RETURN NUMBER
    IS
       dep_id_nuovo_alle      NUMBER;
       dep_cod_rif_allegato   VARCHAR2 (100);
    BEGIN
       dep_id_nuovo_alle :=
          gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                      p_modello                   => 'M_ALLEGATO_PROTOCOLLO',
                                      p_cr                        => NULL,
                                      p_utente                    => p_utente,
                                      p_crea_record_orizzontale   => 1);

       UPDATE DOCUMENTI
          SET ID_DOCUMENTO_PADRE = p_id_padre
        WHERE id_documento = dep_id_nuovo_alle;

       UPDATE seg_allegati_protocollo
          SET codice_amministrazione = p_codice_amministrazione,
              codice_aoo = p_codice_aoo,
              idrif = p_idrif,
              descrizione = p_descrizione,
              tipo_allegato = p_tipo_allegato
        WHERE id_documento = dep_id_nuovo_alle;

       DECLARE
          d_id_log   NUMBER;
       BEGIN
          SELECT id_log
            INTO d_id_log
            FROM activity_log
           WHERE id_documento = dep_id_nuovo_alle AND tipo_azione = 'C';

          INSERT INTO VALORI_LOG (ID_VALORE_LOG,
                                  ID_LOG,
                                  VALORE_CLOB,
                                  COLONNA)
             SELECT VALOG_SQ.NEXTVAL,
                    d_id_log,
                    P_TIPO_ALLEGATO,
                    'TIPO_ALLEGATO'
               FROM DUAL;

          INSERT INTO VALORI_LOG (ID_VALORE_LOG,
                                  ID_LOG,
                                  VALORE_CLOB,
                                  COLONNA)
             SELECT VALOG_SQ.NEXTVAL,
                    d_id_log,
                    P_DESCRIZIONE,
                    'DESCRIZIONE'
               FROM DUAL;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             raise_application_error (
                -20999,
                   'Impossibile recuperare id_log per documento '
                || dep_id_nuovo_alle);
       END;

       dep_cod_rif_allegato :=
          AG_PARAMETRO.GET_VALORE ('COD_RIF_ALLEGATO',
                                   p_codice_amministrazione,
                                   p_codice_aoo,
                                   'PROT_ALLE');

       INSERT INTO RIFERIMENTI (AREA,
                                DATA_AGGIORNAMENTO,
                                ID_DOCUMENTO,
                                ID_DOCUMENTO_RIF,
                                LIBRERIA_REMOTA,
                                TIPO_RELAZIONE,
                                UTENTE_AGGIORNAMENTO)
            VALUES ('SEGRETERIA',
                    SYSDATE,
                    dep_id_nuovo_alle,
                    p_id_padre,
                    NULL,
                    dep_cod_rif_allegato,
                    p_utente);

       RETURN dep_id_nuovo_alle;
    EXCEPTION
       WHEN OTHERS
       THEN
          RAISE;
    END;

    FUNCTION get_fs_path /******************************************************************************
                          NOME:        GET_FS_PATH
                          DESCRIZIONE: Restituisce il nome del file su disco completo di percorso.
                          PARAMETRI:   p_id_evento   identificativo numerico dell'evento.
                          RITORNA:     varchar2.
                          NOTE:        --
                          REVISIONI:
                          Rev. Data       Autore Descrizione
                          ---- ---------- ------ ------------------------------------------------------
                          0    07/12/2005 MM     Prima emissione.
                          ******************************************************************************/
                         (p_file IN BFILE)
       RETURN VARCHAR2
    IS
       d_return      VARCHAR2 (4000);
       d_directory   VARCHAR2 (4000);
       d_nomefile    VARCHAR2 (4000);

       FUNCTION get_dirpath (p_dirname IN VARCHAR2)
          RETURN VARCHAR2
       IS
          d_alias   VARCHAR2 (2000);
          d_path    VARCHAR2 (4000);

          FUNCTION get_dirname (p_dirpath   IN VARCHAR2,
                                p_prefix    IN VARCHAR2 DEFAULT '')
             RETURN VARCHAR2
          IS
             d_name   VARCHAR2 (4000);
          BEGIN
             IF INSTR (p_dirpath, '/') = 0 AND INSTR (p_dirpath, '\') = 0
             THEN
                -- conytrollo esistenza nome interno della Directory
                SELECT directory_name
                  INTO d_name
                  FROM all_directories
                 WHERE directory_name = p_dirpath;
             ELSE
                -- ottiene il nome interno del percorso fisico
                SELECT MIN (directory_name)
                  INTO d_name
                  FROM all_directories
                 WHERE     directory_path = p_dirpath
                       AND directory_name LIKE p_prefix || '%';
             END IF;

             RETURN d_name;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                RETURN '';
          END get_dirname;
       BEGIN
          IF INSTR (p_dirname, '/') = 0 AND INSTR (p_dirname, '\') = 0
          THEN
             d_alias := p_dirname;
          ELSE
             d_alias := get_dirname (p_dirname);
          END IF;

          -- ottiene il percorso fisico dal nome interno della directory
          SELECT directory_path
            INTO d_path
            FROM all_directories
           WHERE directory_name = d_alias;

          RETURN d_path;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             RETURN '';
       END get_dirpath;
    BEGIN
       DBMS_LOB.filegetname (p_file, d_directory, d_nomefile);
       d_return := get_dirPath (d_directory) || '/' || d_nomefile;
       RETURN d_return;
    EXCEPTION
       WHEN OTHERS
       THEN
          RETURN '';
    END;

    PROCEDURE mvfile (a_from VARCHAR2, a_to VARCHAR2)
    AS
       A_CMD      VARCHAR2 (1000);
       A_RESULT   NUMBER;
    BEGIN
       A_CMD := 'mv ' || a_from || ' ' || a_to;
       A_CMD := 'call os_command.exec(''' || A_CMD || ''') into :A_RESULT ';
       DBMS_OUTPUT.put_line (A_CMD);

       EXECUTE IMMEDIATE A_CMD USING OUT A_RESULT;

       IF A_RESULT <> 0
       THEN
          RAISE_APPLICATION_ERROR (
             -20999,
             'Errore in mvfile (' || a_from || ', ' || a_to || ')');
       END IF;
    EXCEPTION
       WHEN OTHERS
       THEN
          RAISE_APPLICATION_ERROR (
             -20999,
             'Errore in mvfile(' || a_from || ', ' || a_to || '): ' || SQLERRM);
    END;

   PROCEDURE separa_gli_allegati (p_id_documento       NUMBER,
                                  p_nome_file_princ    VARCHAR2,
                                  p_utente             VARCHAR2)
   IS
      dep_id_nuovo_alle            NUMBER;
      dep_idrif                    VARCHAR2 (100);
      dep_codice_amministrazione   VARCHAR2 (100);
      dep_codice_aoo               VARCHAR2 (100);
      dep_file                     BLOB := EMPTY_BLOB;
      dep_is_fs_file               NUMBER;

        /*aggiunto per delete*/
        a_old_dir VARCHAR2(1000);
        a_old_path_dir_fs VARCHAR2(1000);
        a_old_path_file VARCHAR2(1000);
        /*fine aggiunto per delete*/
   BEGIN
      DBMS_OUTPUT.put_line ('separa_gli_allegati ' || p_id_documento);

      IF count_oggetti_file (p_id_documento) > 1
      THEN
         IF p_nome_file_princ IS NULL
         THEN
            raise_application_error (-20999,
                                     'Selezionare un file principale.');
         ELSE
            DBMS_OUTPUT.put_line ('else ');

            SELECT idrif, codice_amministrazione, codice_aoo
              INTO dep_idrif, dep_codice_amministrazione, dep_codice_aoo
              FROM proto_view
             WHERE id_documento = p_id_documento;

            FOR alle
               IN (SELECT id_oggetto_file,
                          filename,
                          testoocr,
                          "FILE" testo
                     FROM oggetti_file
                    WHERE     id_documento = p_id_documento
                          AND filename NOT IN ('LETTERAUNIONE.RTFHIDDEN',
                                               p_nome_file_princ))
            LOOP
               DBMS_OUTPUT.put_line ('filename ' || ALLE.filename);

               dep_is_fs_file :=
                  gdm_oggetti_file.IS_FS_FILE (alle.id_oggetto_file);

               IF dep_is_fs_file = 1
               THEN
                /*aggiunto per delete*/
                  gdm_oggetti_file.GETPATH_FILE_FS( alle.id_oggetto_file, a_old_dir, a_old_path_dir_fs , a_old_path_file);
                /*fine aggiunto per delete*/

                  dep_file :=
                     gdm_oggetti_file.DOWNLOADOGGETTOFILE (
                        alle.id_oggetto_file);
                  DBMS_OUTPUT.put_line (
                     'dep_file getlength ' || DBMS_LOB.getlength (dep_file));

                  UPDATE oggetti_file
                     SET path_file = NULL,
                         testoocr = dep_file,
                         "FILE" = NULL
                   WHERE id_oggetto_file = alle.id_oggetto_file;
               END IF;

               dep_id_nuovo_alle :=
                  crea_allegato (p_id_documento,
                                 dep_idrif,
                                 alle.filename,
                                 NULL,
                                 dep_codice_amministrazione,
                                 dep_codice_aoo,
                                 p_utente);

               UPDATE oggetti_file
                  SET id_documento = dep_id_nuovo_alle
                WHERE id_oggetto_file = alle.id_oggetto_file;

               UPDATE impronte_file
                  SET id_documento = dep_id_nuovo_alle
                WHERE id_documento = p_id_documento
                  AND filename = alle.filename;


               -- se il file è nel blob, non è necessario fare nulla, altrimenti
               -- bisogna spostare il file e aggiornare il puntatore ad esso
               IF dep_is_fs_file = 1
               THEN
                  DBMS_OUTPUT.put_line ('bfile');

                  DECLARE
                     d_new_path      VARCHAR2 (2000);
                     a_dir           VARCHAR2 (2000);
                     a_path_dir_fs   VARCHAR2 (2000);
                     a_path_file     VARCHAR2 (2000);
                  BEGIN
                     gdm_oggetti_file.GETPATH_FILE_FS (alle.id_oggetto_file,
                                                       a_dir,
                                                       a_path_dir_fs,
                                                       a_path_file);
                     d_new_path :=
                        REPLACE (a_path_dir_fs || '/' || a_path_file,
                                 '/' || alle.id_oggetto_file,
                                 '');
                     DBMS_OUTPUT.put_line ('d_new_path:' || d_new_path);

                     GDM_UTILITY.MKDIR (d_new_path);

                     DBMS_OUTPUT.put_line (
                           'gdm_oggetti_file.OGGETTO_FILE_TO_FS('
                        || alle.id_oggetto_file
                        || ', 1);');
                     gdm_oggetti_file.OGGETTO_FILE_TO_FS_NOCOMMIT (
                        alle.id_oggetto_file,
                        -1,
                        1);
                    /*aggiunto per delete*/
                      DBMS_BACKUP_RESTORE.DELETEFILE(a_old_path_dir_fs||'/'||replace(a_old_path_file,'$','\$'));
                    /*fine aggiunto per delete*/
                  END;
               ELSE
                  DBMS_OUTPUT.put_line ('blob');
               END IF;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

    FUNCTION crea_rapporto (p_id_padre                       NUMBER,
                            P_ANNO                           NUMBER,
                            P_CAP_AMM                        VARCHAR2,
                            P_CAP_AOO                        VARCHAR2,
                            P_CAP_DOM                        VARCHAR2,
                            P_CAP_DOM_DIPENDENTE             VARCHAR2,
                            P_CAP_IMPRESA                    VARCHAR2,
                            P_CAP_IMPRESA_EXTRA              VARCHAR2,
                            P_CAP_PER_SEGNATURA              VARCHAR2,
                            P_CAP_RES                        VARCHAR2,
                            P_CAP_RES_DIPENDENTE             VARCHAR2,
                            P_CFP_EXTRA                      VARCHAR2,
                            P_CF_PER_SEGNATURA               VARCHAR2,
                            P_CODICE_AMM                     VARCHAR2,
                            P_CODICE_AOO                     VARCHAR2,
                            P_CODICE_FISCALE                 VARCHAR2,
                            P_CODICE_FISCALE_DIPENDENTE      VARCHAR2,
                            P_COD_AMM                        VARCHAR2,
                            P_COD_AOO                        VARCHAR2,
                            P_COD_UO                         VARCHAR2,
                            P_COGNOME                        VARCHAR2,
                            P_COGNOME_DIPENDENTE             VARCHAR2,
                            P_COGNOME_IMPRESA_EXTRA          VARCHAR2,
                            P_COGNOME_PER_SEGNATURA          VARCHAR2,
                            P_COMUNE_AMM                     VARCHAR2,
                            P_COMUNE_AOO                     VARCHAR2,
                            P_COMUNE_DOM                     VARCHAR2,
                            P_COMUNE_DOM_DIPENDENTE          VARCHAR2,
                            P_COMUNE_IMPRESA                 VARCHAR2,
                            P_COMUNE_IMPRESA_EXTRA           VARCHAR2,
                            P_COMUNE_NASCITA                 VARCHAR2,
                            P_COMUNE_NASCITA_EXTRA           VARCHAR2,
                            P_COMUNE_PER_SEGNATURA           VARCHAR2,
                            P_COMUNE_RES                     VARCHAR2,
                            P_COMUNE_RES_DIPENDENTE          VARCHAR2,
                            P_C_FISCALE_IMPRESA              VARCHAR2,
                            P_C_FISCALE_IMPRESA_EXTRA        VARCHAR2,
                            P_C_VIA_IMPRESA                  VARCHAR2,
                            P_C_VIA_IMPRESA_EXTRA            VARCHAR2,
                            P_DAL                            VARCHAR2,
                            P_DAL_AMM                        VARCHAR2,
                            P_DAL_DIPENDENTE                 VARCHAR2,
                            P_DAL_PERSONA                    VARCHAR2,
                            P_DATA_NASCITA                   VARCHAR2,
                            P_DATA_NASCITA_EXTRA             VARCHAR2,
                            P_DENOMINAZIONE_PER_SEGNATURA    VARCHAR2,
                            P_DENOMINAZIONE_SEDE             VARCHAR2,
                            P_DENOMINAZIONE_SEDE_EXTRA       VARCHAR2,
                            P_DESCRIZIONE_AMM                VARCHAR2,
                            P_DESCRIZIONE_AOO                VARCHAR2,
                            P_DESCRIZIONE_INCARICO           VARCHAR2,
                            P_DESCRIZIONE_UO                 VARCHAR2,
                            P_DESC_TIPO_RAPPORTO             VARCHAR2,
                            P_EMAIL                          VARCHAR2,
                            P_FAX_DOM                        VARCHAR2,
                            P_FAX_RES                        VARCHAR2,
                            P_IDRIF                          VARCHAR2,
                            P_INDIRIZZO_AMM                  VARCHAR2,
                            P_INDIRIZZO_AOO                  VARCHAR2,
                            P_INDIRIZZO_DOM                  VARCHAR2,
                            P_INDIRIZZO_DOM_DIPENDENTE       VARCHAR2,
                            P_INDIRIZZO_PER_SEGNATURA        VARCHAR2,
                            P_INDIRIZZO_RES                  VARCHAR2,
                            P_INDIRIZZO_RES_DIPENDENTE       VARCHAR2,
                            P_INSEGNA                        VARCHAR2,
                            P_INSEGNA_EXTRA                  VARCHAR2,
                            P_MAIL_AMM                       VARCHAR2,
                            P_MAIL_AOO                       VARCHAR2,
                            P_MAIL_DIPENDENTE                VARCHAR2,
                            P_MAIL_PERSONA                   VARCHAR2,
                            P_NATURA_GIURIDICA               VARCHAR2,
                            P_NATURA_GIURIDICA_EXTRA         VARCHAR2,
                            P_NI                             VARCHAR2,
                            P_NI_AMM                         VARCHAR2,
                            P_NI_DIPENDENTE                  VARCHAR2,
                            P_NI_IMPRESA                     VARCHAR2,
                            P_NI_IMPRESA_EXTRA               VARCHAR2,
                            P_NI_PERSONA                     VARCHAR2,
                            P_NOME                           VARCHAR2,
                            P_NOME_DIPENDENTE                VARCHAR2,
                            P_NOME_IMPRESA_EXTRA             VARCHAR2,
                            P_NOME_PER_SEGNATURA             VARCHAR2,
                            P_NOMINATIVO_COMPONENTE          VARCHAR2,
                            P_NUMERO                         NUMBER,
                            P_N_CIVICO_IMPRESA               VARCHAR2,
                            P_N_CIVICO_IMPRESA_EXTRA         VARCHAR2,
                            P_PARENT_URL                     CLOB,
                            P_PARTITA_IVA_IMPRESA            VARCHAR2,
                            P_PARTITA_IVA_IMPRESA_EXTRA      VARCHAR2,
                            P_PROVINCIA_DOM                  VARCHAR2,
                            P_PROVINCIA_DOM_DIPENDENTE       VARCHAR2,
                            P_PROVINCIA_PER_SEGNATURA        VARCHAR2,
                            P_PROVINCIA_RES                  VARCHAR2,
                            P_PROVINCIA_RES_DIPENDENTE       VARCHAR2,
                            P_SESSO                          VARCHAR2,
                            P_SIGLA_PROV_AMM                 VARCHAR2,
                            P_SIGLA_PROV_AOO                 VARCHAR2,
                            P_TEL_DOM                        VARCHAR2,
                            P_TEL_RES                        VARCHAR2,
                            P_TIPO                           VARCHAR2,
                            P_TIPO_LOCALIZZAZIONE            VARCHAR2,
                            P_TIPO_LOCALIZZAZIONE_EXTRA      VARCHAR2,
                            P_TIPO_RAPPORTO                  VARCHAR2,
                            P_TIPO_REGISTRO                  VARCHAR2,
                            P_TIPO_SOGGETTO                  VARCHAR2,
                            P_VIA_IMPRESA                    VARCHAR2,
                            P_VIA_IMPRESA_EXTRA              VARCHAR2,
                            P_FULL_TEXT                      CLOB,
                            P_TXT                            VARCHAR2,
                            P_MODINVIO                       VARCHAR2,
                            P_PARTITA_IVA                    VARCHAR2,
                            P_CFP                            VARCHAR2,
                            P_COGNOME_IMPRESA                VARCHAR2,
                            P_NOME_IMPRESA                   VARCHAR2,
                            P_DESCRIZIONE                    VARCHAR2,
                            P_DOCUMENTO_TRAMITE              VARCHAR2,
                            P_ID_LISTA_DISTRIBUZIONE         VARCHAR2,
                            P_MODALITA                       VARCHAR2,
                            P_STATO_PR                       VARCHAR2,
                            P_CF_NULLABLE                    VARCHAR2,
                            P_RACCOMANDATA_NUMERO            VARCHAR2,
                            P_CAP_BENEFICIARIO               VARCHAR2,
                            P_CF_BENEFICIARIO                VARCHAR2,
                            P_COMUNE_BENEFICIARIO            VARCHAR2,
                            P_DATA_NASCITA_BENEFICIARIO      VARCHAR2,
                            P_DENOMINAZIONE_BENEFICIARIO     VARCHAR2,
                            P_INDIRIZZO_BENEFICIARIO         VARCHAR2,
                            P_PI_BENEFICIARIO                VARCHAR2,
                            P_PROVINCIA_BENEFICIARIO         VARCHAR2,
                            P_MAIL_IMPRESA                   VARCHAR2,
                            P_CAP_UO                         VARCHAR2,
                            P_COMUNE_UO                      VARCHAR2,
                            P_FAX_UO                         VARCHAR2,
                            P_INDIRIZZO_UO                   VARCHAR2,
                            P_MAIL_UO                        VARCHAR2,
                            P_SIGLA_PROV_UO                  VARCHAR2,
                            P_TEL_UO                         VARCHAR2,
                            P_DATA_SPED                      VARCHAR2,
                            P_DOCUMENTO_TRAMITE_FORM         VARCHAR2,
                            P_FAX                            VARCHAR2,
                            P_FAX_AMM                        VARCHAR2,
                            P_FAX_AOO                        VARCHAR2,
                            P_FAX_BENEFICIARIO               VARCHAR2,
                            P_MAIL_BENEFICIARIO              VARCHAR2,
                            P_QUANTITA                       NUMBER,
                            P_BC_SPEDIZIONE                  VARCHAR2,
                            P_CONOSCENZA                     VARCHAR2,
                            p_utente                         VARCHAR2)
       RETURN NUMBER
    IS
       dep_id_nuovo_rapporto         NUMBER;

       d_DAL                         DATE
                                        := TO_DATE (P_DAL, 'dd/mm/yyyy hh24:mi:ss');
       d_DAL_AMM                     DATE
          := TO_DATE (P_DAL_AMM, 'dd/mm/yyyy hh24:mi:ss');
       d_DAL_DIPENDENTE              DATE
          := TO_DATE (P_DAL_DIPENDENTE, 'dd/mm/yyyy hh24:mi:ss');
       d_DAL_PERSONA                 DATE
          := TO_DATE (P_DAL_PERSONA, 'dd/mm/yyyy hh24:mi:ss');
       d_DATA_NASCITA                DATE
          := TO_DATE (P_DATA_NASCITA, 'dd/mm/yyyy hh24:mi:ss');
       d_DATA_NASCITA_EXTRA          DATE
          := TO_DATE (P_DATA_NASCITA_EXTRA, 'dd/mm/yyyy hh24:mi:ss');
       d_DATA_NASCITA_BENEFICIARIO   DATE
          := TO_DATE (P_DATA_NASCITA_BENEFICIARIO, 'dd/mm/yyyy hh24:mi:ss');
       d_DATA_SPED                   DATE
                                        := TO_DATE (P_DATA_SPED, 'dd/mm/yyyy');
    BEGIN
       dep_id_nuovo_rapporto :=
          gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                      p_modello                   => 'M_SOGGETTO',
                                      p_cr                        => NULL,
                                      p_utente                    => p_utente,
                                      p_crea_record_orizzontale   => 1);

       IF (p_id_padre IS NOT NULL)
       THEN
          UPDATE DOCUMENTI
             SET ID_DOCUMENTO_PADRE = p_id_padre
           WHERE id_documento = dep_id_nuovo_rapporto;
       END IF;

       UPDATE SEG_SOGGETTI_PROTOCOLLO
          SET ANNO = P_ANNO,
              BC_SPEDIZIONE = P_BC_SPEDIZIONE,
              C_FISCALE_IMPRESA = P_C_FISCALE_IMPRESA,
              C_FISCALE_IMPRESA_EXTRA = P_C_FISCALE_IMPRESA_EXTRA,
              C_VIA_IMPRESA = P_C_VIA_IMPRESA,
              C_VIA_IMPRESA_EXTRA = P_C_VIA_IMPRESA_EXTRA,
              CAP_AMM = P_CAP_AMM,
              CAP_AOO = P_CAP_AOO,
              CAP_BENEFICIARIO = P_CAP_BENEFICIARIO,
              CAP_DOM = P_CAP_DOM,
              CAP_DOM_DIPENDENTE = P_CAP_DOM_DIPENDENTE,
              CAP_IMPRESA = P_CAP_IMPRESA,
              CAP_IMPRESA_EXTRA = P_CAP_IMPRESA_EXTRA,
              CAP_PER_SEGNATURA = P_CAP_PER_SEGNATURA,
              CAP_RES = P_CAP_RES,
              CAP_RES_DIPENDENTE = P_CAP_RES_DIPENDENTE,
              CAP_UO = P_CAP_UO,
              CF_BENEFICIARIO = P_CF_BENEFICIARIO,
              CF_NULLABLE = P_CF_NULLABLE,
              CF_PER_SEGNATURA = P_CF_PER_SEGNATURA,
              --CFP = P_CFP,
              CFP_EXTRA = P_CFP_EXTRA,
              COD_AMM = P_COD_AMM,
              COD_AOO = P_COD_AOO,
              COD_UO = P_COD_UO,
              CODICE_AMMINISTRAZIONE = P_CODICE_AMM,
              CODICE_AOO = P_CODICE_AOO,
              CODICE_FISCALE = P_CODICE_FISCALE,
              CODICE_FISCALE_DIPENDENTE = P_CODICE_FISCALE_DIPENDENTE,
              COGNOME = P_COGNOME,
              COGNOME_DIPENDENTE = P_COGNOME_DIPENDENTE,
              --COGNOME_IMPRESA = P_COGNOME_IMPRESA,
              COGNOME_IMPRESA_EXTRA = P_COGNOME_IMPRESA_EXTRA,
              COGNOME_PER_SEGNATURA = P_COGNOME_PER_SEGNATURA,
              COMUNE_AMM = P_COMUNE_AMM,
              COMUNE_AOO = P_COMUNE_AOO,
              COMUNE_BENEFICIARIO = P_COMUNE_BENEFICIARIO,
              COMUNE_DOM = P_COMUNE_DOM,
              COMUNE_DOM_DIPENDENTE = P_COMUNE_DOM_DIPENDENTE,
              COMUNE_IMPRESA = P_COMUNE_IMPRESA,
              COMUNE_IMPRESA_EXTRA = P_COMUNE_IMPRESA_EXTRA,
              COMUNE_NASCITA = P_COMUNE_NASCITA,
              COMUNE_NASCITA_EXTRA = P_COMUNE_NASCITA_EXTRA,
              COMUNE_PER_SEGNATURA = P_COMUNE_PER_SEGNATURA,
              COMUNE_RES = P_COMUNE_RES,
              COMUNE_RES_DIPENDENTE = P_COMUNE_RES_DIPENDENTE,
              COMUNE_UO = P_COMUNE_UO,
              CONOSCENZA = P_CONOSCENZA,
              DAL = d_DAL,
              DAL_AMM = d_DAL_AMM,
              DAL_DIPENDENTE = d_DAL_DIPENDENTE,
              DAL_PERSONA = d_DAL_PERSONA,
              DATA_NASCITA = d_DATA_NASCITA,
              DATA_NASCITA_BENEFICIARIO = d_DATA_NASCITA_BENEFICIARIO,
              DATA_NASCITA_EXTRA = d_DATA_NASCITA_EXTRA,
              DATA_SPED = d_DATA_SPED,
              DENOMINAZIONE_BENEFICIARIO = P_DENOMINAZIONE_BENEFICIARIO,
              DENOMINAZIONE_PER_SEGNATURA = P_DENOMINAZIONE_PER_SEGNATURA,
              DENOMINAZIONE_SEDE = P_DENOMINAZIONE_SEDE,
              DENOMINAZIONE_SEDE_EXTRA = P_DENOMINAZIONE_SEDE_EXTRA,
              DESC_TIPO_RAPPORTO = P_DESC_TIPO_RAPPORTO,
              DESCRIZIONE = P_DESCRIZIONE,
              DESCRIZIONE_AMM = P_DESCRIZIONE_AMM,
              DESCRIZIONE_AOO = P_DESCRIZIONE_AOO,
              DESCRIZIONE_INCARICO = P_DESCRIZIONE_INCARICO,
              DESCRIZIONE_UO = P_DESCRIZIONE_UO,
              DOCUMENTO_TRAMITE = P_DOCUMENTO_TRAMITE,
              DOCUMENTO_TRAMITE_FORM = P_DOCUMENTO_TRAMITE_FORM,
              EMAIL = P_EMAIL,
              FAX = P_FAX,
              FAX_AMM = P_FAX_AMM,
              FAX_AOO = P_FAX_AOO,
              FAX_BENEFICIARIO = P_FAX_BENEFICIARIO,
              FAX_DOM = P_FAX_DOM,
              FAX_RES = P_FAX_RES,
              FAX_UO = P_FAX_UO,
              ID_LISTA_DISTRIBUZIONE = P_ID_LISTA_DISTRIBUZIONE,
              IDRIF = P_IDRIF,
              INDIRIZZO_AMM = P_INDIRIZZO_AMM,
              INDIRIZZO_AOO = P_INDIRIZZO_AOO,
              INDIRIZZO_BENEFICIARIO = P_INDIRIZZO_BENEFICIARIO,
              INDIRIZZO_DOM = P_INDIRIZZO_DOM,
              INDIRIZZO_DOM_DIPENDENTE = P_INDIRIZZO_DOM_DIPENDENTE,
              INDIRIZZO_PER_SEGNATURA = P_INDIRIZZO_PER_SEGNATURA,
              INDIRIZZO_RES = P_INDIRIZZO_RES,
              INDIRIZZO_RES_DIPENDENTE = P_INDIRIZZO_RES_DIPENDENTE,
              INDIRIZZO_UO = P_INDIRIZZO_UO,
              INSEGNA = P_INSEGNA,
              INSEGNA_EXTRA = P_INSEGNA_EXTRA,
              MAIL_AMM = P_MAIL_AMM,
              MAIL_AOO = P_MAIL_AOO,
              MAIL_BENEFICIARIO = P_MAIL_BENEFICIARIO,
              MAIL_DIPENDENTE = P_MAIL_DIPENDENTE,
              MAIL_IMPRESA = P_MAIL_IMPRESA,
              MAIL_PERSONA = P_MAIL_PERSONA,
              MAIL_UO = P_MAIL_UO,
              MODALITA = P_MODALITA,
              --MODINVIO = P_MODINVIO,
              N_CIVICO_IMPRESA = P_N_CIVICO_IMPRESA,
              N_CIVICO_IMPRESA_EXTRA = P_N_CIVICO_IMPRESA_EXTRA,
              NATURA_GIURIDICA = P_NATURA_GIURIDICA,
              NATURA_GIURIDICA_EXTRA = P_NATURA_GIURIDICA_EXTRA,
              NI = P_NI,
              NI_AMM = P_NI_AMM,
              NI_DIPENDENTE = P_NI_DIPENDENTE,
              NI_IMPRESA = P_NI_IMPRESA,
              NI_IMPRESA_EXTRA = P_NI_IMPRESA_EXTRA,
              NI_PERSONA = P_NI_PERSONA,
              NOME = P_NOME,
              NOME_DIPENDENTE = P_NOME_DIPENDENTE,
              --NOME_IMPRESA = P_NOME_IMPRESA,
              NOME_IMPRESA_EXTRA = P_NOME_IMPRESA_EXTRA,
              NOME_PER_SEGNATURA = P_NOME_PER_SEGNATURA,
              NOMINATIVO_COMPONENTE = P_NOMINATIVO_COMPONENTE,
              NUMERO = P_NUMERO,
              PARENT_URL = P_PARENT_URL,
              PARTITA_IVA = P_PARTITA_IVA,
              PARTITA_IVA_IMPRESA = P_PARTITA_IVA_IMPRESA,
              PARTITA_IVA_IMPRESA_EXTRA = P_PARTITA_IVA_IMPRESA_EXTRA,
              PI_BENEFICIARIO = P_PI_BENEFICIARIO,
              PROVINCIA_BENEFICIARIO = P_PROVINCIA_BENEFICIARIO,
              PROVINCIA_DOM = P_PROVINCIA_DOM,
              PROVINCIA_DOM_DIPENDENTE = P_PROVINCIA_DOM_DIPENDENTE,
              PROVINCIA_PER_SEGNATURA = P_PROVINCIA_PER_SEGNATURA,
              PROVINCIA_RES = P_PROVINCIA_RES,
              PROVINCIA_RES_DIPENDENTE = P_PROVINCIA_RES_DIPENDENTE,
              QUANTITA = P_QUANTITA,
              RACCOMANDATA_NUMERO = P_RACCOMANDATA_NUMERO,
              SESSO = P_SESSO,
              SIGLA_PROV_AMM = P_SIGLA_PROV_AMM,
              SIGLA_PROV_AOO = P_SIGLA_PROV_AOO,
              SIGLA_PROV_UO = P_SIGLA_PROV_UO,
              STATO_PR = P_STATO_PR,
              TEL_DOM = P_TEL_DOM,
              TEL_RES = P_TEL_RES,
              TEL_UO = P_TEL_UO,
              TIPO = P_TIPO,
              TIPO_LOCALIZZAZIONE = P_TIPO_LOCALIZZAZIONE,
              TIPO_LOCALIZZAZIONE_EXTRA = P_TIPO_LOCALIZZAZIONE_EXTRA,
              TIPO_RAPPORTO = P_TIPO_RAPPORTO,
              TIPO_REGISTRO = P_TIPO_REGISTRO,
              TIPO_SOGGETTO = P_TIPO_SOGGETTO,
              VIA_IMPRESA = P_VIA_IMPRESA,
              VIA_IMPRESA_EXTRA = P_VIA_IMPRESA_EXTRA
        WHERE id_documento = dep_id_nuovo_rapporto;


       DECLARE
          d_id_log   NUMBER;
       BEGIN
          SELECT id_log
            INTO d_id_log
            FROM activity_log
           WHERE id_documento = dep_id_nuovo_rapporto AND tipo_azione = 'C';

          INSERT INTO VALORI_LOG (ID_VALORE_LOG,
                                  ID_LOG,
                                  VALORE_CLOB,
                                  COLONNA)
             SELECT VALOG_SQ.NEXTVAL,
                    d_id_log,
                    P_DENOMINAZIONE_PER_SEGNATURA,
                    'DENOMINAZIONE_PER_SEGNATURA'
               FROM DUAL;

          INSERT INTO VALORI_LOG (ID_VALORE_LOG,
                                  ID_LOG,
                                  VALORE_CLOB,
                                  COLONNA)
             SELECT VALOG_SQ.NEXTVAL,
                    d_id_log,
                    P_COGNOME_PER_SEGNATURA,
                    'COGNOME_PER_SEGNATURA'
               FROM DUAL;

          INSERT INTO VALORI_LOG (ID_VALORE_LOG,
                                  ID_LOG,
                                  VALORE_CLOB,
                                  COLONNA)
             SELECT VALOG_SQ.NEXTVAL,
                    d_id_log,
                    P_NOME_PER_SEGNATURA,
                    'NOME_PER_SEGNATURA'
               FROM DUAL;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             raise_application_error (
                -20999,
                   'Impossibile recuperare id_log per documento '
                || dep_id_nuovo_rapporto);
       END;


       RETURN dep_id_nuovo_rapporto;
    EXCEPTION
       WHEN OTHERS
       THEN
          RAISE;
    END;

    FUNCTION is_rapp_duplicato (p_idrif                     VARCHAR2,
                                p_tipo_soggetto             NUMBER,
                                p_denominazione_per_segnatura   VARCHAR2,
                                p_cognome                   VARCHAR2,
                                p_nome                      VARCHAR2,
                                p_codice_fiscale            VARCHAR2,
                                p_partita_iva               VARCHAR2,
                                p_partita_iva_impresa       VARCHAR2,
                                p_cod_amm                   VARCHAR2,
                                p_cod_aoo                   VARCHAR2,
                                p_cod_uo                    VARCHAR2,
                                p_ni                        NUMBER,
                                p_indirizzo_per_segnatura   VARCHAR2,
                                p_cap_per_segnatura         VARCHAR2,
                                p_comune_per_segnatura      VARCHAR2,
                                p_provincia_per_segnatura   VARCHAR2,
                                p_email                     VARCHAR2)
       RETURN BOOLEAN
    IS
       d_ret                       BOOLEAN := FALSE;
       d_tipo_soggetto             NUMBER;
       d_cognome                   VARCHAR2 (1000);
       d_nome                      VARCHAR2 (1000);
       d_codice_fiscale            VARCHAR2 (100);
       d_partita_iva               VARCHAR2 (100);
       d_partita_iva_impresa       VARCHAR2 (100);
       d_cod_amm                   VARCHAR2 (100);
       d_cod_aoo                   VARCHAR2 (100);
       d_cod_uo                    VARCHAR2 (100);
       d_ni                        NUMBER;
       d_tipo_sogg_as4_corrente    VARCHAR2 (100);
       d_tipo_sogg_as4_esistente   VARCHAR2 (100);
       d_indirizzo_per_segnatura   VARCHAR2 (100);
       d_cap_per_segnatura         VARCHAR2 (100);
       d_comune_per_segnatura      VARCHAR2 (100);
       d_provincia_per_segnatura   VARCHAR2 (100);
       d_email                     VARCHAR2 (100);
       d_inrizzo_senza_spazi       VARCHAR2 (32000);
       d_inrizzo_input_senza_spazi      VARCHAR2 (32000);
       d_denominazione_per_segnatura    VARCHAR2 (1000);
    BEGIN
       d_inrizzo_input_senza_spazi := replace(p_indirizzo_per_segnatura||p_cap_per_segnatura||p_comune_per_segnatura||p_provincia_per_segnatura, ' ', '');
       FOR sogg
          IN (SELECT tipo_soggetto,
                     denominazione_per_segnatura,
                     cognome_per_segnatura,
                     nome_per_segnatura,
                     cf_per_segnatura,
                     partita_iva,
                     partita_iva_impresa,
                     cod_amm,
                     cod_aoo,
                     cod_uo,
                     ni,
                     indirizzo_per_segnatura,
                     cap_per_segnatura,
                     comune_per_segnatura,
                     provincia_per_segnatura,
                     email
                FROM seg_soggetti_protocollo sogg, documenti docu
               WHERE     sogg.id_documento = docu.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                     AND sogg.idrif = p_idrif
                     AND tipo_rapporto <> 'DUMMY'
                     AND NVL (CF_PER_SEGNATURA, ' ') =
                            DECODE (
                               p_tipo_soggetto,
                               1, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               3, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               4, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               5, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               7, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               8, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               9, DECODE (p_codice_fiscale,
                                          NULL, NVL (CF_PER_SEGNATURA, ' '),
                                          p_codice_fiscale),
                               NVL (CF_PER_SEGNATURA, ' '))
                     AND NVL (PARTITA_IVA_IMPRESA, ' ') =
                            DECODE (
                               p_tipo_soggetto,
                               3, DECODE (
                                     p_partita_iva,
                                     NULL, NVL (PARTITA_IVA_IMPRESA, ' '),
                                     p_partita_iva),
                               4, DECODE (
                                     p_partita_iva,
                                     NULL, NVL (PARTITA_IVA_IMPRESA, ' '),
                                     p_partita_iva),
                               NVL (PARTITA_IVA_IMPRESA, ' '))
                     AND NVL (PARTITA_IVA, ' ') =
                            DECODE (
                               p_tipo_soggetto,
                               7, DECODE (p_partita_iva,
                                          NULL, NVL (PARTITA_IVA, ' '),
                                          p_partita_iva),
                               8, DECODE (p_partita_iva,
                                          NULL, NVL (PARTITA_IVA, ' '),
                                          p_partita_iva),
                               NVL (PARTITA_IVA, ' '))
                     AND NVL (COD_AMM, ' ') =
                            DECODE (p_tipo_soggetto,
                                    2, p_cod_amm,
                                    NVL (COD_AMM, ' '))
                     AND NVL (COD_AOO, ' ') =
                            DECODE (
                               p_tipo_soggetto,
                               2, DECODE (p_cod_aoo,
                                          NULL, NVL (COD_AOO, ' '),
                                          p_cod_aoo),
                               NVL (COD_AOO, ' '))
                     AND NVL (COD_UO, ' ') =
                            DECODE (
                               p_tipo_soggetto,
                               2, DECODE (p_cod_uo,
                                          NULL, NVL (COD_UO, ' '),
                                          p_cod_uo),
                               NVL (COD_UO, ' ')))
       LOOP
          d_tipo_soggetto := sogg.tipo_soggetto;
          d_cognome := sogg.cognome_per_segnatura;
          d_nome := sogg.nome_per_segnatura;
          d_codice_fiscale := sogg.cf_per_segnatura;
          d_partita_iva := sogg.partita_iva;
          d_partita_iva_impresa := sogg.partita_iva_impresa;
          d_cod_amm := sogg.cod_amm;
          d_cod_aoo := sogg.cod_aoo;
          d_cod_uo := sogg.cod_uo;
          d_ni := sogg.ni;
          d_denominazione_per_segnatura := sogg.denominazione_per_segnatura;
          d_indirizzo_per_segnatura := NVL(sogg.indirizzo_per_segnatura,'*');
          d_cap_per_segnatura := NVL(sogg.cap_per_segnatura,'*');
          d_comune_per_segnatura := NVL(sogg.comune_per_segnatura,'*');
          d_provincia_per_segnatura := NVL(sogg.provincia_per_segnatura,'*');
          d_email := NVL(sogg.email,'*');
          d_inrizzo_senza_spazi := replace(d_indirizzo_per_segnatura||d_cap_per_segnatura||d_comune_per_segnatura||d_provincia_per_segnatura, ' ', '');

          IF p_tipo_soggetto = 1                       -- TIPO_SOGGETTO_PERSONA
          THEN
            IF (p_codice_fiscale IS NOT NULL AND d_codice_fiscale IS NOT NULL)
             THEN
                IF p_codice_fiscale = d_codice_fiscale
                THEN
                   -- se i rapporti a confronto riguardano entrambi anagrafiche di as4
                   -- si consente di inserire lo stesso cf se il tipo_soggetto in as4 è diverso
                   -- (tipo_soggetto null si considera uguale a null)
                   -- se i rapporti a confronto riguardano anagrafiche diverse tra loro
                   -- non si consente di inserire due cf uguali
                   IF d_ni IS NOT NULL AND p_ni IS NOT NULL
                   THEN
                      BEGIN
                         SELECT NVL (tipo_soggetto, '*')
                           INTO d_tipo_sogg_as4_corrente
                           FROM as4_soggetti
                          WHERE ni = p_ni;
                      EXCEPTION
                         WHEN OTHERS
                         THEN
                            d_tipo_sogg_as4_corrente := 'I';
                      END;

                      BEGIN
                         SELECT NVL (tipo_soggetto, '*')
                           INTO d_tipo_sogg_as4_esistente
                           FROM as4_soggetti
                          WHERE ni = d_ni;
                      EXCEPTION
                         WHEN OTHERS
                         THEN
                            d_tipo_sogg_as4_esistente := 'I';
                      END;

                      d_ret := d_tipo_sogg_as4_esistente = d_tipo_sogg_as4_corrente;

                     /* Se hanno lo stesso cf e stesso tipo_soggetto in as4, controllo
                      * se hanno lo stesso indirizzo e mail
                      */
                      IF  d_tipo_sogg_as4_esistente = d_tipo_sogg_as4_corrente THEN
                        IF ( (upper(d_indirizzo_per_segnatura) = upper(nvl(p_indirizzo_per_segnatura,'*'))) AND
                             (upper(d_cap_per_segnatura) = upper(nvl(p_cap_per_segnatura,'*'))) AND
                             (upper(d_comune_per_segnatura) = upper(nvl(p_comune_per_segnatura,'*'))) AND
                             (upper(d_provincia_per_segnatura) = upper(nvl(p_provincia_per_segnatura,'*'))) AND
                             (upper(d_email) = upper(nvl(p_email,'*'))) ) THEN
                           d_ret := TRUE;
                        ELSE
                           d_ret := FALSE;
                        END IF;
                      END IF;

                   ELSE
                      d_ret := TRUE;
                   END IF;
                END IF;
             END IF;
          END IF;


          IF p_tipo_soggetto = 5                     --TIPO_SOGGETTO_DIPENDENTE
          THEN
             IF (p_codice_fiscale IS NOT NULL AND d_codice_fiscale IS NOT NULL)
             THEN
                d_ret := p_codice_fiscale = d_codice_fiscale;
             END IF;
          END IF;

          IF p_tipo_soggetto IN (3, 4) AND d_tipo_soggetto != 1 -- TIPO_SOGGETTO_IMPRESA_IN_PROVINCIA || TIPO_SOGGETTO_IMPRESA_FUORI_PROVINCIA
          THEN
             IF (p_codice_fiscale IS NOT NULL AND d_codice_fiscale IS NOT NULL)
             THEN
                d_ret := p_codice_fiscale = d_codice_fiscale;
             END IF;

             IF NOT d_ret
             THEN
                IF (    p_partita_iva_impresa IS NOT NULL
                    AND d_partita_iva_impresa IS NOT NULL)
                THEN
                   d_ret := p_partita_iva_impresa = d_partita_iva_impresa;
                END IF;
             END IF;
          END IF;

          IF p_tipo_soggetto IN (7, 8) -- TIPO_SOGGETTO_BENEFICIARIO || TIPO_SOGGETTO_CE4
          THEN
             IF (p_codice_fiscale IS NOT NULL AND d_codice_fiscale IS NOT NULL)
             THEN
                d_ret := p_codice_fiscale = d_codice_fiscale;
             END IF;

             IF NOT d_ret
             THEN
                IF (p_partita_iva IS NOT NULL AND d_partita_iva IS NOT NULL)
                THEN
                   d_ret := p_partita_iva = d_partita_iva;
                END IF;
             END IF;
          END IF;

 --106 05/02/2020 SC      #39727
          IF p_tipo_soggetto IN (2)             -- TIPO_SOGGETTO_AMMINISTRATIVO
          THEN
 DBMS_OUTPUT.PUT_LINE('p_cod_amm '||p_cod_amm);
 DBMS_OUTPUT.PUT_LINE('d_cod_amm '||d_cod_amm);
 DBMS_OUTPUT.PUT_LINE('p_cod_aoo '||p_cod_aoo);
 DBMS_OUTPUT.PUT_LINE('d_cod_aoo '||d_cod_aoo);
 DBMS_OUTPUT.PUT_LINE('p_cod_uo '||p_cod_uo);
 DBMS_OUTPUT.PUT_LINE('d_cod_uo '||d_cod_uo);
              DBMS_OUTPUT.PUT_LINE('d_email '||d_email);
              DBMS_OUTPUT.PUT_LINE('p_email '||p_email);
              DBMS_OUTPUT.PUT_LINE('d_inrizzo_input_senza_spazi '||d_inrizzo_input_senza_spazi);
              DBMS_OUTPUT.PUT_LINE('d_inrizzo_senza_spazi '||d_inrizzo_senza_spazi);
              DBMS_OUTPUT.PUT_LINE('p_denominazione_per_segnatura '||p_denominazione_per_segnatura);
              DBMS_OUTPUT.PUT_LINE('d_denominazione_per_segnatura '||d_denominazione_per_segnatura);

             d_ret := p_cod_amm = d_cod_amm;
           if d_ret then
 DBMS_OUTPUT.PUT_LINE('d_ret amm uguali');
 else
  DBMS_OUTPUT.PUT_LINE('d_ret amm diversi');
 end if;
             IF d_ret
             THEN
                IF (p_cod_aoo IS NOT NULL AND d_cod_aoo IS NOT NULL)
                THEN
                   d_ret := p_cod_aoo = d_cod_aoo;
                END IF;
          if d_ret then
 DBMS_OUTPUT.PUT_LINE('d_ret aoo uguali');
 else
  DBMS_OUTPUT.PUT_LINE('d_ret aoo diversi');
 end if;

             END IF;

             IF d_ret
             THEN

                   d_ret := nvl(p_cod_uo, '*') = nvl(d_cod_uo, '*');

          if d_ret then
 DBMS_OUTPUT.PUT_LINE('d_ret uo uguali');
 else
  DBMS_OUTPUT.PUT_LINE('d_ret uo diversi');
 end if;

                    if d_ret then
                        d_ret := upper(d_email) = upper(nvl(p_email,'*')) and
                            upper(d_inrizzo_input_senza_spazi) = upper(d_inrizzo_senza_spazi);

          if d_ret then
 DBMS_OUTPUT.PUT_LINE('d_ret mail e indirizzo uguali');
 else
  DBMS_OUTPUT.PUT_LINE('d_ret mail e indirizzo  diversi');
 end if;

                    end if;

             END IF;
          END IF;
          if d_ret then
 DBMS_OUTPUT.PUT_LINE('d_ret uguali');
 else
  DBMS_OUTPUT.PUT_LINE('d_ret diversi');
 end if;

          IF p_tipo_soggetto IN (9)                        -- TIPO_SOGGETTO_GSD
          THEN
             IF (p_codice_fiscale IS NOT NULL AND d_codice_fiscale IS NOT NULL)
             THEN
                d_ret := p_codice_fiscale = d_codice_fiscale;
             ELSE
                IF (p_cognome IS NOT NULL AND d_cognome IS NOT NULL)
                THEN
                   d_ret := p_cognome = d_cognome;
                END IF;

                IF d_ret
                THEN
                   IF (p_nome IS NOT NULL AND d_nome IS NOT NULL)
                   THEN
                      d_ret := p_nome = d_nome;
                   END IF;
                END IF;
             END IF;
          END IF;

          IF d_ret
          THEN
             EXIT;
          END IF;
       END LOOP;

       RETURN d_ret;
    END;

    FUNCTION crea_rapporto_e_termina (
       p_id_padre                       NUMBER,
       P_ANNO                           NUMBER,
       P_CAP_AMM                        VARCHAR2,
       P_CAP_AOO                        VARCHAR2,
       P_CAP_DOM                        VARCHAR2,
       P_CAP_DOM_DIPENDENTE             VARCHAR2,
       P_CAP_IMPRESA                    VARCHAR2,
       P_CAP_IMPRESA_EXTRA              VARCHAR2,
       P_CAP_PER_SEGNATURA              VARCHAR2,
       P_CAP_RES                        VARCHAR2,
       P_CAP_RES_DIPENDENTE             VARCHAR2,
       P_CFP_EXTRA                      VARCHAR2,
       P_CF_PER_SEGNATURA               VARCHAR2,
       P_CODICE_AMM                     VARCHAR2,
       P_CODICE_AOO                     VARCHAR2,
       P_CODICE_FISCALE                 VARCHAR2,
       P_CODICE_FISCALE_DIPENDENTE      VARCHAR2,
       P_COD_AMM                        VARCHAR2,
       P_COD_AOO                        VARCHAR2,
       P_COD_UO                         VARCHAR2,
       P_COGNOME                        VARCHAR2,
       P_COGNOME_DIPENDENTE             VARCHAR2,
       P_COGNOME_IMPRESA_EXTRA          VARCHAR2,
       P_COGNOME_PER_SEGNATURA          VARCHAR2,
       P_COMUNE_AMM                     VARCHAR2,
       P_COMUNE_AOO                     VARCHAR2,
       P_COMUNE_DOM                     VARCHAR2,
       P_COMUNE_DOM_DIPENDENTE          VARCHAR2,
       P_COMUNE_IMPRESA                 VARCHAR2,
       P_COMUNE_IMPRESA_EXTRA           VARCHAR2,
       P_COMUNE_NASCITA                 VARCHAR2,
       P_COMUNE_NASCITA_EXTRA           VARCHAR2,
       P_COMUNE_PER_SEGNATURA           VARCHAR2,
       P_COMUNE_RES                     VARCHAR2,
       P_COMUNE_RES_DIPENDENTE          VARCHAR2,
       P_C_FISCALE_IMPRESA              VARCHAR2,
       P_C_FISCALE_IMPRESA_EXTRA        VARCHAR2,
       P_C_VIA_IMPRESA                  VARCHAR2,
       P_C_VIA_IMPRESA_EXTRA            VARCHAR2,
       P_DAL                            VARCHAR2,
       P_DAL_AMM                        VARCHAR2,
       P_DAL_DIPENDENTE                 VARCHAR2,
       P_DAL_PERSONA                    VARCHAR2,
       P_DATA_NASCITA                   VARCHAR2,
       P_DATA_NASCITA_EXTRA             VARCHAR2,
       P_DENOMINAZIONE_PER_SEGNATURA    VARCHAR2,
       P_DENOMINAZIONE_SEDE             VARCHAR2,
       P_DENOMINAZIONE_SEDE_EXTRA       VARCHAR2,
       P_DESCRIZIONE_AMM                VARCHAR2,
       P_DESCRIZIONE_AOO                VARCHAR2,
       P_DESCRIZIONE_INCARICO           VARCHAR2,
       P_DESCRIZIONE_UO                 VARCHAR2,
       P_DESC_TIPO_RAPPORTO             VARCHAR2,
       P_EMAIL                          VARCHAR2,
       P_FAX_DOM                        VARCHAR2,
       P_FAX_RES                        VARCHAR2,
       P_IDRIF                          VARCHAR2,
       P_INDIRIZZO_AMM                  VARCHAR2,
       P_INDIRIZZO_AOO                  VARCHAR2,
       P_INDIRIZZO_DOM                  VARCHAR2,
       P_INDIRIZZO_DOM_DIPENDENTE       VARCHAR2,
       P_INDIRIZZO_PER_SEGNATURA        VARCHAR2,
       P_INDIRIZZO_RES                  VARCHAR2,
       P_INDIRIZZO_RES_DIPENDENTE       VARCHAR2,
       P_INSEGNA                        VARCHAR2,
       P_INSEGNA_EXTRA                  VARCHAR2,
       P_MAIL_AMM                       VARCHAR2,
       P_MAIL_AOO                       VARCHAR2,
       P_MAIL_DIPENDENTE                VARCHAR2,
       P_MAIL_PERSONA                   VARCHAR2,
       P_NATURA_GIURIDICA               VARCHAR2,
       P_NATURA_GIURIDICA_EXTRA         VARCHAR2,
       P_NI                             VARCHAR2,
       P_NI_AMM                         VARCHAR2,
       P_NI_DIPENDENTE                  VARCHAR2,
       P_NI_IMPRESA                     VARCHAR2,
       P_NI_IMPRESA_EXTRA               VARCHAR2,
       P_NI_PERSONA                     VARCHAR2,
       P_NOME                           VARCHAR2,
       P_NOME_DIPENDENTE                VARCHAR2,
       P_NOME_IMPRESA_EXTRA             VARCHAR2,
       P_NOME_PER_SEGNATURA             VARCHAR2,
       P_NOMINATIVO_COMPONENTE          VARCHAR2,
       P_NUMERO                         NUMBER,
       P_N_CIVICO_IMPRESA               VARCHAR2,
       P_N_CIVICO_IMPRESA_EXTRA         VARCHAR2,
       P_PARENT_URL                     CLOB,
       P_PARTITA_IVA_IMPRESA            VARCHAR2,
       P_PARTITA_IVA_IMPRESA_EXTRA      VARCHAR2,
       P_PROVINCIA_DOM                  VARCHAR2,
       P_PROVINCIA_DOM_DIPENDENTE       VARCHAR2,
       P_PROVINCIA_PER_SEGNATURA        VARCHAR2,
       P_PROVINCIA_RES                  VARCHAR2,
       P_PROVINCIA_RES_DIPENDENTE       VARCHAR2,
       P_SESSO                          VARCHAR2,
       P_SIGLA_PROV_AMM                 VARCHAR2,
       P_SIGLA_PROV_AOO                 VARCHAR2,
       P_TEL_DOM                        VARCHAR2,
       P_TEL_RES                        VARCHAR2,
       P_TIPO                           VARCHAR2,
       P_TIPO_LOCALIZZAZIONE            VARCHAR2,
       P_TIPO_LOCALIZZAZIONE_EXTRA      VARCHAR2,
       P_TIPO_RAPPORTO                  VARCHAR2,
       P_TIPO_REGISTRO                  VARCHAR2,
       P_TIPO_SOGGETTO                  VARCHAR2,
       P_VIA_IMPRESA                    VARCHAR2,
       P_VIA_IMPRESA_EXTRA              VARCHAR2,
       P_FULL_TEXT                      CLOB,
       P_TXT                            VARCHAR2,
       P_MODINVIO                       VARCHAR2,
       P_PARTITA_IVA                    VARCHAR2,
       P_CFP                            VARCHAR2,
       P_COGNOME_IMPRESA                VARCHAR2,
       P_NOME_IMPRESA                   VARCHAR2,
       P_DESCRIZIONE                    VARCHAR2,
       P_DOCUMENTO_TRAMITE              VARCHAR2,
       P_ID_LISTA_DISTRIBUZIONE         VARCHAR2,
       P_MODALITA                       VARCHAR2,
       P_STATO_PR                       VARCHAR2,
       P_CF_NULLABLE                    VARCHAR2,
       P_RACCOMANDATA_NUMERO            VARCHAR2,
       P_CAP_BENEFICIARIO               VARCHAR2,
       P_CF_BENEFICIARIO                VARCHAR2,
       P_COMUNE_BENEFICIARIO            VARCHAR2,
       P_DATA_NASCITA_BENEFICIARIO      VARCHAR2,
       P_DENOMINAZIONE_BENEFICIARIO     VARCHAR2,
       P_INDIRIZZO_BENEFICIARIO         VARCHAR2,
       P_PI_BENEFICIARIO                VARCHAR2,
       P_PROVINCIA_BENEFICIARIO         VARCHAR2,
       P_MAIL_IMPRESA                   VARCHAR2,
       P_CAP_UO                         VARCHAR2,
       P_COMUNE_UO                      VARCHAR2,
       P_FAX_UO                         VARCHAR2,
       P_INDIRIZZO_UO                   VARCHAR2,
       P_MAIL_UO                        VARCHAR2,
       P_SIGLA_PROV_UO                  VARCHAR2,
       P_TEL_UO                         VARCHAR2,
       P_DATA_SPED                      VARCHAR2,
       P_DOCUMENTO_TRAMITE_FORM         VARCHAR2,
       P_FAX                            VARCHAR2,
       P_FAX_AMM                        VARCHAR2,
       P_FAX_AOO                        VARCHAR2,
       P_FAX_BENEFICIARIO               VARCHAR2,
       P_MAIL_BENEFICIARIO              VARCHAR2,
       P_QUANTITA                       NUMBER,
       P_BC_SPEDIZIONE                  VARCHAR2,
       P_CONOSCENZA                     VARCHAR2,
       p_utente                         VARCHAR2)
       RETURN VARCHAR2
    IS
       d_ret                   VARCHAR2 (4000);
       dep_id_nuovo_rapporto   NUMBER;
    BEGIN
       IF     p_tipo_soggetto = 2
          AND p_codice_fiscale IS NULL
          AND p_descrizione_amm IS NULL
          AND p_descrizione_aoo IS NULL
          AND p_descrizione_uo IS NULL
       THEN
          raise_application_error (
             -20999,
             'Specificare la descrizione dell'' amministrazione/aoo/unità.');
       END IF;

       IF     p_tipo_soggetto IN (3, 4)
          AND nvl(p_codice_fiscale,P_C_FISCALE_IMPRESA) IS NULL
          AND p_nome IS NULL
          AND p_cognome IS NULL
       THEN
          raise_application_error (
             -20999,
             'Specificare nome e cognome dell''impresa.');
       END IF;

       IF is_rapp_duplicato (p_idrif,
                             p_tipo_soggetto,
                             p_denominazione_per_segnatura,
                             p_cognome,
                             p_nome,
                             p_codice_fiscale,
                             p_partita_iva,
                             p_partita_iva_impresa,
                             p_cod_amm,
                             p_cod_aoo,
                             p_cod_uo,
                             p_ni,
                             p_indirizzo_per_segnatura,
                             p_cap_per_segnatura,
                             p_comune_per_segnatura,
                             p_provincia_per_segnatura,
                             p_email)
       THEN
          raise_application_error (
             -20999,
                'Soggetto già presente per questo protocollo. '
             || p_codice_fiscale
             || ' '
             || p_ni);
       END IF;

       dep_id_nuovo_rapporto :=
          CREA_RAPPORTO (P_ID_PADRE,
                                              P_ANNO,
                                              P_CAP_AMM,
                                              P_CAP_AOO,
                                              P_CAP_DOM,
                                              P_CAP_DOM_DIPENDENTE,
                                              P_CAP_IMPRESA,
                                              P_CAP_IMPRESA_EXTRA,
                                              P_CAP_PER_SEGNATURA,
                                              P_CAP_RES,
                                              P_CAP_RES_DIPENDENTE,
                                              P_CFP_EXTRA,
                                              P_CF_PER_SEGNATURA,
                                              P_CODICE_AMM,
                                              P_CODICE_AOO,
                                              P_CODICE_FISCALE,
                                              P_CODICE_FISCALE_DIPENDENTE,
                                              P_COD_AMM,
                                              P_COD_AOO,
                                              P_COD_UO,
                                              P_COGNOME,
                                              P_COGNOME_DIPENDENTE,
                                              P_COGNOME_IMPRESA_EXTRA,
                                              P_COGNOME_PER_SEGNATURA,
                                              P_COMUNE_AMM,
                                              P_COMUNE_AOO,
                                              P_COMUNE_DOM,
                                              P_COMUNE_DOM_DIPENDENTE,
                                              P_COMUNE_IMPRESA,
                                              P_COMUNE_IMPRESA_EXTRA,
                                              P_COMUNE_NASCITA,
                                              P_COMUNE_NASCITA_EXTRA,
                                              P_COMUNE_PER_SEGNATURA,
                                              P_COMUNE_RES,
                                              P_COMUNE_RES_DIPENDENTE,
                                              P_C_FISCALE_IMPRESA,
                                              P_C_FISCALE_IMPRESA_EXTRA,
                                              P_C_VIA_IMPRESA,
                                              P_C_VIA_IMPRESA_EXTRA,
                                              P_DAL,
                                              P_DAL_AMM,
                                              P_DAL_DIPENDENTE,
                                              P_DAL_PERSONA,
                                              P_DATA_NASCITA,
                                              P_DATA_NASCITA_EXTRA,
                                              P_DENOMINAZIONE_PER_SEGNATURA,
                                              P_DENOMINAZIONE_SEDE,
                                              P_DENOMINAZIONE_SEDE_EXTRA,
                                              P_DESCRIZIONE_AMM,
                                              P_DESCRIZIONE_AOO,
                                              P_DESCRIZIONE_INCARICO,
                                              P_DESCRIZIONE_UO,
                                              P_DESC_TIPO_RAPPORTO,
                                              P_EMAIL,
                                              P_FAX_DOM,
                                              P_FAX_RES,
                                              P_IDRIF,
                                              P_INDIRIZZO_AMM,
                                              P_INDIRIZZO_AOO,
                                              P_INDIRIZZO_DOM,
                                              P_INDIRIZZO_DOM_DIPENDENTE,
                                              P_INDIRIZZO_PER_SEGNATURA,
                                              P_INDIRIZZO_RES,
                                              P_INDIRIZZO_RES_DIPENDENTE,
                                              P_INSEGNA,
                                              P_INSEGNA_EXTRA,
                                              P_MAIL_AMM,
                                              P_MAIL_AOO,
                                              P_MAIL_DIPENDENTE,
                                              P_MAIL_PERSONA,
                                              P_NATURA_GIURIDICA,
                                              P_NATURA_GIURIDICA_EXTRA,
                                              P_NI,
                                              P_NI_AMM,
                                              P_NI_DIPENDENTE,
                                              P_NI_IMPRESA,
                                              P_NI_IMPRESA_EXTRA,
                                              P_NI_PERSONA,
                                              P_NOME,
                                              P_NOME_DIPENDENTE,
                                              P_NOME_IMPRESA_EXTRA,
                                              P_NOME_PER_SEGNATURA,
                                              P_NOMINATIVO_COMPONENTE,
                                              P_NUMERO,
                                              P_N_CIVICO_IMPRESA,
                                              P_N_CIVICO_IMPRESA_EXTRA,
                                              P_PARENT_URL,
                                              P_PARTITA_IVA_IMPRESA,
                                              P_PARTITA_IVA_IMPRESA_EXTRA,
                                              P_PROVINCIA_DOM,
                                              P_PROVINCIA_DOM_DIPENDENTE,
                                              P_PROVINCIA_PER_SEGNATURA,
                                              P_PROVINCIA_RES,
                                              P_PROVINCIA_RES_DIPENDENTE,
                                              P_SESSO,
                                              P_SIGLA_PROV_AMM,
                                              P_SIGLA_PROV_AOO,
                                              P_TEL_DOM,
                                              P_TEL_RES,
                                              P_TIPO,
                                              P_TIPO_LOCALIZZAZIONE,
                                              P_TIPO_LOCALIZZAZIONE_EXTRA,
                                              P_TIPO_RAPPORTO,
                                              P_TIPO_REGISTRO,
                                              P_TIPO_SOGGETTO,
                                              P_VIA_IMPRESA,
                                              P_VIA_IMPRESA_EXTRA,
                                              P_FULL_TEXT,
                                              P_TXT,
                                              P_MODINVIO,
                                              P_PARTITA_IVA,
                                              P_CFP,
                                              P_COGNOME_IMPRESA,
                                              P_NOME_IMPRESA,
                                              P_DESCRIZIONE,
                                              P_DOCUMENTO_TRAMITE,
                                              P_ID_LISTA_DISTRIBUZIONE,
                                              P_MODALITA,
                                              P_STATO_PR,
                                              P_CF_NULLABLE,
                                              P_RACCOMANDATA_NUMERO,
                                              P_CAP_BENEFICIARIO,
                                              P_CF_BENEFICIARIO,
                                              P_COMUNE_BENEFICIARIO,
                                              P_DATA_NASCITA_BENEFICIARIO,
                                              P_DENOMINAZIONE_BENEFICIARIO,
                                              P_INDIRIZZO_BENEFICIARIO,
                                              P_PI_BENEFICIARIO,
                                              P_PROVINCIA_BENEFICIARIO,
                                              P_MAIL_IMPRESA,
                                              P_CAP_UO,
                                              P_COMUNE_UO,
                                              P_FAX_UO,
                                              P_INDIRIZZO_UO,
                                              P_MAIL_UO,
                                              P_SIGLA_PROV_UO,
                                              P_TEL_UO,
                                              P_DATA_SPED,
                                              P_DOCUMENTO_TRAMITE_FORM,
                                              P_FAX,
                                              P_FAX_AMM,
                                              P_FAX_AOO,
                                              P_FAX_BENEFICIARIO,
                                              P_MAIL_BENEFICIARIO,
                                              P_QUANTITA,
                                              P_BC_SPEDIZIONE,
                                              P_CONOSCENZA,
                                              P_UTENTE);
       d_ret := '<FUNCTION_OUTPUT><RESULT>ok</RESULT></FUNCTION_OUTPUT>';

       RETURN d_ret;
    EXCEPTION
       WHEN OTHERS
       THEN
          d_ret :=
                '<FUNCTION_OUTPUT><RESULT>nonok</RESULT><ERROR>'
             || SQLERRM
             || '</ERROR></FUNCTION_OUTPUT>';
          RETURN d_ret;
    END;

    /**
           * Scompone la stringa dell'unita ricevente passata dal function iinput.
           * Per individuare codice unita, eventuali note ed eventuale assegnatario.
           * @param unitaRicevente
           * @return un String[] ret, in cui
           *             ret[0] codice dell'unita
           *             ret[1] codice assegnatario
           *             ret[2] note
           * Se non c'è assegnatario p_assegnatario = null
           * Se non ci sono note     p_note = null
           */

    PROCEDURE scomponi_unita_ricevente (p_unita_ricevente   IN OUT VARCHAR2,
                                        p_assegnatario      IN OUT VARCHAR2,
                                        p_note              IN OUT VARCHAR2)
    IS
       d_unita_ricevente   VARCHAR2 (32000) := p_unita_ricevente;
       d_assegnatario      VARCHAR2 (32000) := p_assegnatario;
       d_pos               NUMBER;
    BEGIN
       d_pos := INSTR (d_unita_ricevente, '@');

       IF d_pos > 0
       THEN
          p_unita_ricevente := SUBSTR (d_unita_ricevente, 1, d_pos - 1);
          d_assegnatario := SUBSTR (d_unita_ricevente, d_pos + 1);

          d_pos := INSTR (d_assegnatario, '%=');

          IF d_pos > 0
          THEN
             p_assegnatario := SUBSTR (d_assegnatario, 1, d_pos - 1);
             p_note := SUBSTR (d_assegnatario, d_pos + 2);
          ELSE
             p_assegnatario := d_assegnatario;
             p_note := NULL;
          END IF;
       ELSE
          p_assegnatario := NULL;
          d_pos := INSTR (d_unita_ricevente, '%=');

          IF d_pos > 0
          THEN
             p_unita_ricevente := SUBSTR (d_unita_ricevente, 1, d_pos - 1);
             p_note := SUBSTR (d_unita_ricevente, d_pos + 2);
          ELSE
             p_unita_ricevente := d_unita_ricevente;
             p_note := NULL;
          END IF;
       END IF;
    END;

    FUNCTION crea_smistamento (p_id_padre                  NUMBER,
                               p_idrif                     VARCHAR2,
                               p_smistamento_dal           DATE,
                               p_ufficio_smistamento       VARCHAR2,
                               p_ufficio_trasmissione      VARCHAR2,
                               p_assegnatario              VARCHAR2,
                               p_assegnazione_dal          DATE,
                               p_tipo_smistamento          VARCHAR2,
                               p_note                      VARCHAR2,
                               p_stato_smistamento         VARCHAR2,
                               p_codice_amministrazione    VARCHAR2,
                               p_codice_aoo                VARCHAR2,
                               p_utente                    VARCHAR2)
       RETURN NUMBER
    IS
       dep_id_nuovo_smist           NUMBER;
       dep_cod_rif_smist            VARCHAR2 (100);
       d_des_ufficio_smistamento    VARCHAR2 (1000);
       d_des_ufficio_trasmissione   VARCHAR2 (1000);
       d_des_assegnatario           VARCHAR2 (1000);
       d_assegnazione_dal           DATE := p_assegnazione_dal;
       d_stato_smistamento          VARCHAR2 (1)
                                       := NVL (p_stato_smistamento, 'N');
    BEGIN
       d_des_ufficio_trasmissione :=
          SEG_UNITA_PKG.get_nome_between (p_ufficio_trasmissione,
                                          p_codice_amministrazione,
                                          p_codice_aoo,
                                          p_smistamento_dal);

       d_des_ufficio_smistamento :=
          SEG_UNITA_PKG.get_nome_between (p_ufficio_smistamento,
                                          p_codice_amministrazione,
                                          p_codice_aoo,
                                          p_smistamento_dal);

       DECLARE
          d_check   NUMBER;
       BEGIN
          SELECT COUNT (1)
            INTO d_check
            FROM seg_smistamenti s, documenti d
           WHERE     idrif = p_idrif
                 AND ufficio_smistamento = p_ufficio_smistamento
                 AND ufficio_trasmissione = p_ufficio_trasmissione
                 AND codice_amministrazione = p_codice_amministrazione
                 AND codice_aoo = p_codice_aoo
                 AND stato_smistamento IN ('C', 'R', 'N')
                 AND tipo_smistamento = p_tipo_smistamento
                 AND NVL (codice_assegnatario, ' ') =
                        NVL (p_assegnatario, ' ')
                 AND d.id_documento = s.id_documento
                 AND d.stato_documento not in ('CA', 'RE', 'PB');

          IF d_check > 0
          THEN
             raise_application_error (
                -20999,
                   'Smistamento per '
                || p_tipo_smistamento
                || ' da '
                || d_des_ufficio_trasmissione
                || ' a '
                || d_des_ufficio_smistamento
                || ' attivo già presente.');
          END IF;
       END;

       dep_id_nuovo_smist :=
          gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                      p_modello                   => 'M_SMISTAMENTO',
                                      p_cr                        => NULL,
                                      p_utente                    => p_utente,
                                      p_crea_record_orizzontale   => 1);

       UPDATE DOCUMENTI
          SET ID_DOCUMENTO_PADRE = p_id_padre
        WHERE id_documento = dep_id_nuovo_smist;

       UPDATE seg_SMISTAMENTI
          SET codice_amministrazione = p_codice_amministrazione,
              codice_aoo = p_codice_aoo,
              idrif = p_idrif,
              key_iter_smistamento = -1,
              stato_smistamento = d_stato_smistamento,
              smistamento_dal = p_smistamento_dal,
              tipo_smistamento = p_tipo_smistamento,
              ufficio_smistamento = p_ufficio_smistamento,
              des_ufficio_smistamento = d_des_ufficio_smistamento,
              ufficio_trasmissione = p_ufficio_trasmissione,
              des_ufficio_trasmissione = d_des_ufficio_trasmissione,
              codice_assegnatario = p_assegnatario,
              des_assegnatario =
                 DECODE (p_assegnatario,
                         NULL, NULL,
                         AG_SOGGETTO.GET_DENOMINAZIONE (p_assegnatario)),
              assegnazione_dal = d_assegnazione_dal,
              note = p_note,
              utente_trasmissione = p_utente
        WHERE id_documento = dep_id_nuovo_smist;

       /*dep_cod_rif_allegato :=
          AG_PARAMETRO.GET_VALORE ('COD_RIF_ALLEGATO',
                                   p_codice_amministrazione,
                                   p_codice_aoo,
                                   'PROT_ALLE');

       INSERT INTO RIFERIMENTI (AREA,
                                DATA_AGGIORNAMENTO,
                                ID_DOCUMENTO,
                                ID_DOCUMENTO_RIF,
                                LIBRERIA_REMOTA,
                                TIPO_RELAZIONE,
                                UTENTE_AGGIORNAMENTO)
            VALUES ('SEGRETERIA',
                    SYSDATE,
                    dep_id_nuovo_alle,
                    p_id_padre,
                    NULL,
                    dep_cod_rif_allegato,
                    p_utente);*/

       RETURN dep_id_nuovo_smist;
    EXCEPTION
       WHEN OTHERS
       THEN
          RAISE;
    END;

   PROCEDURE crea_smistamenti (p_id_padre                  NUMBER,
                               p_idrif                     VARCHAR2,
                               p_smistamento_dal           DATE,
                               p_tree_unita_assegnatari    VARCHAR2,
                               p_ufficio_trasmissione      VARCHAR2,
                               p_unita_protocollante       VARCHAR2,
                               p_stato_pr                  VARCHAR2,
                               p_tipo_smistamento          VARCHAR2,
                               p_codice_amministrazione    VARCHAR2,
                               p_codice_aoo                VARCHAR2,
                               p_utente                    VARCHAR2)
   IS
      dep_id_nuovo_smist           NUMBER;
      dep_cod_rif_smist            VARCHAR2 (100);
      d_tree_unita_assegnatari     VARCHAR2 (32000) := p_tree_unita_assegnatari;
      d_ufficio_smistamento        VARCHAR2 (32000);
      d_des_ufficio_smistamento    VARCHAR2 (1000);
      d_des_ufficio_trasmissione   VARCHAR2 (1000);
      d_assegnatario               VARCHAR2 (100);
      d_des_assegnatario           VARCHAR2 (1000);
      d_note                       VARCHAR2 (4000);
      d_assegnazione_dal           DATE := NULL;
      d_stato_smistamento          VARCHAR2 (1);
      d_id_padre                   NUMBER := p_id_padre;
   BEGIN
      IF d_tree_unita_assegnatari IS NULL
      THEN
         raise_application_error (
            -20999,
            'Nessuna unità selezionata: è necessario selezionarne almeno una.');
      END IF;

      IF p_ufficio_trasmissione IS NULL
      THEN
         raise_application_error (
            -20999,
            'Non è stata specificata l''unità di trasmissione.');
      END IF;

      IF p_tipo_smistamento IS NULL
      THEN
         raise_application_error (
            -20999,
            'Non è stato specificato il tipo di smistamento da effettuare.');
      END IF;

      IF p_unita_protocollante IS NULL
      THEN
         raise_application_error (-20999,
                                  'Inserire il campo unità protocollante.');
      END IF;

      IF NVL (p_stato_pr, 'DP') = 'DP'
      THEN
         d_stato_smistamento := 'N';
      ELSE
         d_stato_smistamento := 'R';
      END IF;

      BEGIN
         d_des_ufficio_trasmissione :=
            SEG_UNITA_PKG.get_nome_between (p_ufficio_trasmissione,
                                            p_codice_amministrazione,
                                            p_codice_aoo,
                                            p_smistamento_dal);
      EXCEPTION
         WHEN OTHERS
         THEN
            d_des_ufficio_trasmissione := p_ufficio_trasmissione;
      END;

      WHILE d_tree_unita_assegnatari IS NOT NULL
      LOOP
         d_ufficio_smistamento :=
            AFC.GET_SUBSTR (d_tree_unita_assegnatari, '#');
         scomponi_unita_ricevente (d_ufficio_smistamento,
                                   d_assegnatario,
                                   d_note);

         IF d_assegnatario IS NOT NULL
         THEN
            d_assegnazione_dal := SYSDATE;
         END IF;

         BEGIN
            d_des_ufficio_smistamento :=
               SEG_UNITA_PKG.get_nome_between (d_ufficio_smistamento,
                                               p_codice_amministrazione,
                                               p_codice_aoo,
                                               p_smistamento_dal);
         EXCEPTION
            WHEN OTHERS
            THEN
               d_des_ufficio_smistamento := d_ufficio_smistamento;
         END;

         DECLARE
            d_check   NUMBER;
         BEGIN
            SELECT COUNT (1)
              INTO d_check
              FROM seg_smistamenti s, documenti d
             WHERE     idrif = p_idrif
                   AND ufficio_smistamento = d_ufficio_smistamento
                   AND ufficio_trasmissione = p_ufficio_trasmissione
                   AND codice_amministrazione = p_codice_amministrazione
                   AND codice_aoo = p_codice_aoo
                   AND stato_smistamento IN ('C', 'R', 'N')
                   AND tipo_smistamento = p_tipo_smistamento
                   AND NVL (codice_assegnatario, ' ') =
                          NVL (d_assegnatario, ' ')
                   AND d.id_documento = s.id_documento
                   AND d.stato_documento not in ('CA', 'RE', 'PB');

            IF d_check > 0
            THEN
               raise_application_error (
                  -20999,
                     'Smistamento per '
                  || p_tipo_smistamento
                  || ' da '
                  || d_des_ufficio_trasmissione
                  || ' a '
                  || d_des_ufficio_smistamento
                  || ' attivo già presente (idrif = '|| p_idrif ||').');
            END IF;

            BEGIN
               select 1
                 into d_check
                 from smistabile_view
                where id_documento = d_id_padre
                  and idrif = p_idrif;
            EXCEPTION
               WHEN OTHERS THEN
                  d_id_padre := NULL;
            END;
         END;

         DBMS_OUTPUT.put_line (SYSTIMESTAMP ());

         DBMS_OUTPUT.put_line (
               'crea_smistamento ('''
            || d_id_padre
            || ''','
            || ''''
            || p_idrif
            || ''','
            || p_smistamento_dal
            || ','
            || ''''
            || d_ufficio_smistamento
            || ''','
            || ''''
            || p_ufficio_trasmissione
            || ''','
            || ''''
            || d_assegnatario
            || ''','
            || d_assegnazione_dal
            || ','
            || ''''
            || p_tipo_smistamento
            || ''','
            || ''''
            || d_note
            || ''','''
            || ''''
            || d_stato_smistamento
            || ''','
            || ''''
            || p_codice_amministrazione
            || ''','
            || ''''
            || p_codice_aoo
            || ''','
            || ''''
            || p_utente
            || ''')');
         dep_id_nuovo_smist :=
            crea_smistamento (d_id_padre,
                              p_idrif,
                              p_smistamento_dal,
                              d_ufficio_smistamento,
                              p_ufficio_trasmissione,
                              d_assegnatario,
                              d_assegnazione_dal,
                              p_tipo_smistamento,
                              d_note,
                              d_stato_smistamento,
                              p_codice_amministrazione,
                              p_codice_aoo,
                              p_utente);
         DBMS_OUTPUT.put_line (SYSTIMESTAMP ());
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

    FUNCTION crea_smistamento_e_termina (p_id_padre                  NUMBER,
                                         p_idrif                     VARCHAR2,
                                         p_smistamento_dal           VARCHAR2,
                                         p_tree_unita_assegnatari    VARCHAR2,
                                         p_ufficio_trasmissione      VARCHAR2,
                                         p_unita_protocollante       VARCHAR2,
                                         p_stato_pr                  VARCHAR2,
                                         p_tipo_smistamento          VARCHAR2,
                                         p_codice_amm                VARCHAR2,
                                         p_codice_aoo                VARCHAR2,
                                         p_utente                    VARCHAR2)
       RETURN VARCHAR2
    IS
       d_smistamento_dal   DATE
          := TO_DATE (p_smistamento_dal, 'dd/mm/yyyy hh24:mi:ss');
       d_ret               VARCHAR2 (4000);
    BEGIN
       crea_smistamenti (p_id_padre,
                         p_idrif,
                         d_smistamento_dal,
                         p_tree_unita_assegnatari,
                         p_ufficio_trasmissione,
                         p_unita_protocollante,
                         p_stato_pr,
                         p_tipo_smistamento,
                         p_codice_amm,
                         p_codice_aoo,
                         p_utente);
       d_ret := '<FUNCTION_OUTPUT><RESULT>ok</RESULT></FUNCTION_OUTPUT>';

       RETURN d_ret;
    EXCEPTION
       WHEN OTHERS
       THEN
          d_ret :=
                '<FUNCTION_OUTPUT><RESULT>nonok</RESULT><ERROR>'
             || SQLERRM
             || '</ERROR></FUNCTION_OUTPUT>';
          RETURN d_ret;
    END;

    FUNCTION get_stream_memo_protocollo (p_id_documento IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_ref_cursor   afc.t_ref_cursor;
    BEGIN
       OPEN d_ref_cursor FOR


           SELECT r.id_documento id_documento_protocollo,
                 r.id_documento_rif id_documento_memo,
                 r_stream.tipo_relazione,
                 r_stream.id_documento_rif id_documento_stream,
                 og.id_oggetto_file id_oggetto_file,
                 docu.area area,
                 docu.codice_richiesta codice_richiesta,
                 tido.nome codice_modello
           FROM riferimenti r,
                riferimenti r_princ,
                riferimenti r_stream,


                oggetti_file og,
                documenti docu,
                tipi_documento tido
          WHERE r.id_documento =  p_id_documento
               AND r.tipo_relazione = 'MAIL'
               AND r_princ.tipo_relazione(+) = 'PRINCIPALE'
               AND r_princ.id_documento_rif(+) = r.id_documento_rif
               AND r_stream.tipo_relazione(+) = 'STREAM'
               AND r_stream.id_documento = NVL (r_princ.id_documento, r.id_documento_rif)
               AND r_stream.id_documento_rif = og.id_documento
               AND docu.id_documento = r_stream.id_documento_rif
               AND tido.id_libreria = docu.id_libreria
               AND tido.id_tipodoc = docu.id_tipodoc;


       RETURN d_ref_cursor;
    END;

    FUNCTION get_file_protocollo (
                           p_id_documento   IN VARCHAR2,
                           p_codice_amm   IN VARCHAR2,
                           p_codice_aoo   IN VARCHAR2,
                           p_idrif        IN VARCHAR2)
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
       d_abilita_scelta varchar2(1) := AG_PARAMETRO.GET_VALORE('SCELTA_ALLEGATI_IN_INVIO', p_codice_amm, p_codice_aoo, 'N');
    BEGIN
       OPEN d_result FOR

             SELECT   1 sequenza,
                           doc.id_documento,
                           'Documento principale' descrizione,
                           '' desc_tipo_allegato,
                           id_tipodoc,
                           codice_richiesta,
                           area,
                           doc.data_aggiornamento,
                           doc.utente_aggiornamento,
                           id_documento_padre,
                           stato_documento,
                           id_oggetto_file,
                           filename,
                           d_abilita_scelta abilita_scelta
             FROM     documenti doc, oggetti_file ogfi
             WHERE doc.id_documento = p_id_documento
                         AND ogfi.id_documento  = doc.id_documento
             UNION
             SELECT   2 sequenza,
                           alle.id_documento,
                           desc_tipo_allegato||' - '||descrizione descrizione,
                           desc_tipo_allegato,
                           id_tipodoc,
                           codice_richiesta,
                           area,
                           doc.data_aggiornamento,
                           doc.utente_aggiornamento,
                           id_documento_padre,
                           stato_documento,
                           id_oggetto_file,
                           filename,
                           d_abilita_scelta abilita_scelta
              FROM seg_allegati_protocollo alle, documenti doc, oggetti_file ogfi
             WHERE  alle.idrif = p_idrif
                         AND doc.id_documento = alle.id_documento
                         AND NVL (doc.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
                         AND codice_amministrazione = p_codice_amm
                         AND codice_aoo = p_codice_aoo
                         AND ogfi.id_documento = alle.id_documento
             ORDER BY sequenza,descrizione;
       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_FILE_PROTOCOLLO: ' || SQLERRM);
    END get_file_protocollo;

    function get_url_anagrafica
       RETURN afc.t_ref_cursor
    IS
       d_result   afc.t_ref_cursor;
    BEGIN
       OPEN d_result FOR
        SELECT    ag_parametro.get_valore ('AG_SERVER_URL', '@ag@', '')
               || DECODE (AG_SOGGETTO.ESISTE_ANAGRAFICI_PKG (), 1, ce.url, '')
                  urlANAGRAFICA,
                  ag_parametro.get_valore ('AG_SERVER_URL', '@ag@', '')
               || DECODE (AG_SOGGETTO.ESISTE_ANAGRAFICI_PKG (), 1, ce2.url, '')
                  urlSOGGETTO
          FROM collegamenti_esterni ce, collegamenti_esterni ce2
         WHERE     ce.codiceads = 'SEGRETERIA#AS4'
               AND ce2.codiceads = 'SEGRETERIA#AS4SOGGETTO';
       RETURN d_result;
    EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
             'AG_DOCUMENTO_UTILITY.GET_URL_ANAGRAFICA: ' || SQLERRM);
    END;


   FUNCTION verifica_gestione_anagrafica(p_utente       IN ad4_utenti.utente%TYPE,
                                         p_codice_amm   IN VARCHAR2,
                                         p_codice_aoo   IN VARCHAR2)
    RETURN NUMBER
    IS
      retval            NUMBER := 0;
      d_ottica          VARCHAR2 (1000);
      d_ruoli           afc.t_ref_cursor;
      ruolo             VARCHAR2 (4000);
      descrizione       VARCHAR2 (4000);
      d_lista_ruoli     VARCHAR2(4000) := '';
   BEGIN

       d_lista_ruoli:= AG_PARAMETRO.GET_VALORE ('RUOLI_GEST_ANAG', '@agVar@', 'AGPSUP#AGPPRALL#AGPANAG');
       d_ottica := ag_parametro.get_valore ('SO_OTTICA_PROT',p_codice_amm,p_codice_aoo,'');
       d_ruoli := SO4_AGS_PKG.AD4_UTENTE_GET_RUOLI(p_utente, NULL, NULL, d_ottica, p_codice_amm);

       IF d_ruoli%ISOPEN
       THEN
         LOOP
           BEGIN
             FETCH d_ruoli
               INTO ruolo, descrizione;
               EXIT WHEN d_ruoli%NOTFOUND;
               IF instr('#'||d_lista_ruoli||'#','#'||ruolo||'#')>0 THEN
                  retval:=1;
               END IF;
           END;
          END LOOP;
       END IF;

    RETURN retval;
     EXCEPTION
       WHEN OTHERS
       THEN
          raise_application_error (
             -20999,
                'AG_DOCUMENTO_UTILITY.VERIFICA_GESTIONE_ANAGRAFICA: '|| SQLERRM);
   END verifica_gestione_anagrafica;

   function crea_protocollo_agspr(p_id_documento VARCHAR2, p_utente varchar2, p_id_tipo_protocollo VARCHAR2)
   return varchar2
   is
      d_return varchar2(4000);
      d_id_doc_agspr number;
      d_id_tipo_protocollo number := p_id_tipo_protocollo;
   begin
      d_id_doc_agspr := agspr_agp_trasco_pkg.crea_protocollo_agspr (p_id_documento, d_id_tipo_protocollo, 1);
      d_return := agspr_agp_trasco_pkg.get_url_protocollo (p_id_documento);

      return d_return;
   end;

     function crea_doc_titolario_agspr(p_id_documento VARCHAR2, p_id_documento_titolario  varchar2, p_tipo_fascicolo varchar2, p_utente varchar2)
   return varchar2
   is
      d_id_doc_agspr  varchar2(4000);
      d_id_classificazione  number;
      d_id_fascicolo  number;
      d_class_cod  varchar2(4000);
      d_class_dal date;
      d_class_al date;

   begin

     d_id_classificazione  := NULL;
     d_id_fascicolo   := NULL;

    /*INSERT INTO TEMP_SV(TESTO) VALUES (    'p_id_documento='||p_id_documento||',p_id_documento_titolario='||p_id_documento_titolario||',p_tipo_fascicolo='||p_tipo_fascicolo||',p_utente='||p_utente);
    COMMIT;
*/
     BEGIN
        select id_documento into d_id_classificazione
        from seg_classificazioni
        where id_documento=p_id_documento_titolario;
     EXCEPTION
         WHEN NO_DATA_FOUND
         THEN

        select id_documento, class_cod, class_dal, class_al  into d_id_fascicolo, d_class_cod, d_class_dal, d_class_al
        from seg_fascicoli
        where id_documento=p_id_documento_titolario;

        BEGIN
            select id_documento into d_id_classificazione
            from seg_classificazioni
            where  class_cod = d_class_cod and class_dal = d_class_dal and class_al = d_class_al;
           EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_classificazione := NULL;
         END;

      END;

    IF d_id_classificazione IS NOT NULL THEN
        d_id_doc_agspr := agspr_agp_trasco_pkg.crea_doc_titolario_agspr (p_id_documento, d_id_classificazione, d_id_fascicolo, p_utente);
    END IF;

      return d_id_doc_agspr;
   end;

   FUNCTION IS_PROTOCOLLATO (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      d_return   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_return
           FROM proto_view
          WHERE     id_documento = p_id_documento
                AND anno IS NOT NULL
                AND numero IS NOT NULL
                AND tipo_registro IS NOT NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_return := 0;
      END;

      RETURN d_return;
   END;

 END;
/
