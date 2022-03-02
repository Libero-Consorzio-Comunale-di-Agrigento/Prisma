--liquibase formatted sql
--changeset esasdelli:20200220_01.synonyms  runOnChange:true stripComments:false

-- AGSPR
create or replace synonym agspr_agp_documenti_tito_pkg for agp_documenti_titolario_pkg
/

-- GDM
create or replace synonym agp_menu for ${global.db.gdm.username}.ag_barra
/

create or replace synonym agp_ruoli_privilegi for ${global.db.gdm.username}.ag_privilegi_ruolo
/

create or replace synonym ags_tipi_soggetto for ${global.db.gdm.username}.ag_tipi_soggetto
/

create or replace synonym ag_get_idrif for ${global.db.gdm.username}.ag_get_idrif
/

create or replace synonym ag_registro_utility for ${global.db.gdm.username}.ag_registro_utility
/

create or replace synonym f_get_maxdim_attach for ${global.db.gdm.username}.f_get_maxdim_attach
/

create or replace synonym gdc_utility_pkg for ${global.db.gdm.username}.gdc_utility_pkg
/

create or replace synonym gdm_ags_riferimenti for ${global.db.gdm.username}.ags_riferimenti
/

create or replace synonym gdm_ag_competenze_protocollo for ${global.db.gdm.username}.ag_competenze_protocollo
/

create or replace synonym gdm_ag_cs_messaggi for ${global.db.gdm.username}.ag_cs_messaggi
/

create or replace synonym gdm_ag_dati_aggiuntivi_pkg for ${global.db.gdm.username}.ag_dati_aggiuntivi_pkg
/

create or replace synonym gdm_ag_fascicolo_utility for ${global.db.gdm.username}.ag_fascicolo_utility
/

create or replace synonym gdm_ag_oggetti_file for ${global.db.gdm.username}.ag_oggetti_file
/

create or replace synonym gdm_ag_parametro for ${global.db.gdm.username}.ag_parametro
/

create or replace synonym gdm_ag_stati_scarto for ${global.db.gdm.username}.ag_stati_scarto
/

create or replace synonym gdm_ag_tipi_soggetto for ${global.db.gdm.username}.ag_tipi_soggetto
/

create or replace synonym gdm_ag_utilities for ${global.db.gdm.username}.ag_utilities
/

create or replace synonym gdm_amvweb for ${global.db.gdm.username}.amvweb
/

create or replace synonym gdm_cartelle for ${global.db.gdm.username}.cartelle
/

create or replace synonym gdm_classificazioni for ${global.db.gdm.username}.seg_classificazioni
/

create or replace synonym gdm_componenti_lista_utility for ${global.db.gdm.username}.ag_componenti_lista_utility
/

create or replace synonym gdm_documenti for ${global.db.gdm.username}.documenti
/

create or replace synonym gdm_fascicoli for ${global.db.gdm.username}.seg_fascicoli
/

create or replace synonym gdm_get_rapporti_doc for ${global.db.gdm.username}.get_rapporti_doc
/

create or replace synonym gdm_impronte_file for ${global.db.gdm.username}.impronte_file
/

create or replace synonym gdm_lettere_uscita for ${global.db.gdm.username}.spr_lettere_uscita
/

create or replace synonym gdm_liste_dist_utility for ${global.db.gdm.username}.ag_liste_dist_utility
/

create or replace synonym gdm_modalita_invio_ricezione for ${global.db.gdm.username}.seg_modalita_ricevimento
/

create or replace synonym gdm_oggetti_file for ${global.db.gdm.username}.oggetti_file
/

create or replace synonym gdm_oggetti_file_log for ${global.db.gdm.username}.oggetti_file_log
/

create or replace synonym gdm_parametri for ${global.db.gdm.username}.parametri
/

create or replace synonym gdm_profilo for ${global.db.gdm.username}.gdm_profilo
/

create or replace synonym gdm_proto_view for ${global.db.gdm.username}.proto_view
/

create or replace synonym gdm_registro for ${global.db.gdm.username}.registro
/

create or replace synonym gdm_registro_utility for ${global.db.gdm.username}.registro_utility
/

create or replace synonym gdm_riferimenti for ${global.db.gdm.username}.riferimenti
/

create or replace synonym gdm_seg_allegati_protocollo for ${global.db.gdm.username}.seg_allegati_protocollo
/

create or replace synonym gdm_seg_bottoni_notifiche for ${global.db.gdm.username}.seg_bottoni_notifiche
/

create or replace synonym gdm_seg_componenti_lista for ${global.db.gdm.username}.seg_componenti_lista
/

create or replace synonym gdm_seg_liste_distribuzione for ${global.db.gdm.username}.seg_liste_distribuzione
/

create or replace synonym gdm_seg_memo_protocollo for ${global.db.gdm.username}.seg_memo_protocollo
/

create or replace synonym gdm_seg_registri for ${global.db.gdm.username}.seg_registri
/

create or replace synonym gdm_seg_smistamenti for ${global.db.gdm.username}.seg_smistamenti
/

create or replace synonym gdm_seg_soggetti_protocollo for ${global.db.gdm.username}.seg_soggetti_protocollo
/

create or replace synonym gdm_seg_tipi_allegato for ${global.db.gdm.username}.seg_tipi_allegato
/

create or replace synonym gdm_seg_tipi_documento for ${global.db.gdm.username}.seg_tipi_documento
/

create or replace synonym gdm_seg_tipi_frase for ${global.db.gdm.username}.seg_tipi_frase
/

create or replace synonym gdm_seg_unita for ${global.db.gdm.username}.seg_unita
/

create or replace synonym gdm_seq_idrif for ${global.db.gdm.username}.seq_idrif
/

create or replace synonym gdm_smistabile_view for ${global.db.gdm.username}.smistabile_view
/

create or replace synonym gdm_smistamenti_tipi_documento for ${global.db.gdm.username}.seg_smistamenti_tipi_documento
/

create or replace synonym gdm_spr_lettere_uscita for ${global.db.gdm.username}.spr_lettere_uscita
/

create or replace synonym gdm_spr_protocolli for ${global.db.gdm.username}.spr_protocolli
/

create or replace synonym gdm_spr_protocolli_intero for ${global.db.gdm.username}.spr_protocolli_intero
/

create or replace synonym gdm_stati_documento for ${global.db.gdm.username}.stati_documento
/

create or replace synonym gdm_tipi_documento for ${global.db.gdm.username}.tipi_documento
/

create or replace synonym gdm_tipi_documento_utility for ${global.db.gdm.username}.ag_tipi_documento_utility
/

create or replace synonym gdm_tipi_frase_utility for ${global.db.gdm.username}.ag_tipi_frase_utility
/

create or replace synonym gdm_unita_tipi_doc for ${global.db.gdm.username}.seg_unita_tipi_doc
/

create or replace synonym seg_amm_aoo_uo_tab for ${global.db.gdm.username}.seg_amm_aoo_uo_tab
/

create or replace synonym seg_classificazioni for ${global.db.gdm.username}.seg_classificazioni
/

create or replace synonym seg_soggetti_mv for ${global.db.gdm.username}.seg_soggetti_mv
/

create or replace synonym seg_uo_mail for ${global.db.gdm.username}.seg_uo_mail
/

create or replace synonym gdm_ag_memo_utility for ${global.db.gdm.username}.ag_memo_utility
/

create or replace synonym gdm_ag_competenze_documento for ${global.db.gdm.username}.ag_competenze_documento
/

create or replace synonym gdm_seg_numerazioni_classifica for ${global.db.gdm.username}.seg_numerazioni_classifica
/

create or replace synonym gdm_seg_unita_classifica for ${global.db.gdm.username}.seg_unita_classifica
/

create or replace synonym gdm_gdm_cartelle for ${global.db.gdm.username}.gdm_cartelle
/

create or replace synonym gdm_seg_classificazioni for ${global.db.gdm.username}.seg_classificazioni
/

create or replace synonym gdm_links for ${global.db.gdm.username}.links
/

create or replace synonym gdm_seg_stream_memo_proto for ${global.db.gdm.username}.seg_stream_memo_proto
/

create or replace synonym gdm_seg_note for ${global.db.gdm.username}.seg_note
/

create or replace synonym gdm_tipi_spedizione for ${global.db.gdm.username}.seg_tipi_spedizione
/

create or replace synonym gdm_collegamenti_esterni for ${global.db.gdm.username}.collegamenti_esterni
/

create or replace synonym gdm_seg_anagrafici_as4 for ${global.db.gdm.username}.seg_anagrafici_as4
/

create or replace synonym gdm_oggetti_file_pack_gdm for ${global.db.gdm.username}.gdm_oggetti_file
/

create or replace synonym f_elimina_documento_gdm for ${global.db.gdm.username}.f_elimina_documento
/

create or replace synonym gdm_ag_utilities_stampa for ${global.db.gdm.username}.ag_utilities_stampa
/

create or replace synonym gdm_tipi_relazione for ${global.db.gdm.username}.tipi_relazione
/

create or replace synonym gdm_valori_log for ${global.db.gdm.username}.valori_log
/

create or replace synonym gdm_activity_log for ${global.db.gdm.username}.activity_log
/

create or replace synonym gdm_dati for ${global.db.gdm.username}.dati
/

create or replace synonym gdm_dati_modello for ${global.db.gdm.username}.dati_modello
/

create or replace synonym GDM_AG_RADICI_AREA_UTENTE_TMP FOR ${global.db.gdm.username}.AG_RADICI_AREA_UTENTE_TMP
/


CREATE OR REPLACE SYNONYM AD4_ASSISTENTE_VIRTUALE_PKG FOR ${global.db.ad4.username}.ASSISTENTE_VIRTUALE_PKG
/

CREATE OR REPLACE SYNONYM AGP_COMPETENZE_FASCICOLO for ${global.db.gdm.username}.AG_COMPETENZE_FASCICOLO
/

create or replace synonym gdm_jdms_link for ${global.db.gdm.username}.jdms_link
/

create or replace synonym gdm_ag_riferimenti_utility for ${global.db.gdm.username}.ag_riferimenti_utility
/

create or replace synonym gdm_gdc_utility_pkg for ${global.db.gdm.username}.gdc_utility_pkg
/

create or replace synonym gdm_view_cartella for ${global.db.gdm.username}.view_cartella
/

create or replace synonym GDM_TMP_FILE FOR ${global.db.gdm.username}.TMP_FILE
/

create or replace synonym gdm_sposta_file_doc_in_rep for ${global.db.gdm.username}.ag_sposta_file_doc_in_rep
/

create or replace synonym AG_SPEDIZIONE_UTILITY for ${global.db.gdm.username}.AG_SPEDIZIONE_UTILITY
/

create or replace synonym gdm_sposta_file_doc_in_rep for ${global.db.gdm.username}.ag_sposta_file_doc_in_rep
/

create or replace synonym gdm_spr_da_fascicolare for ${global.db.gdm.username}.spr_da_fascicolare
/

create or replace synonym gdm_spr_scarico_ipa for ${global.db.gdm.username}.spr_scarico_ipa
/

-- AS4
create or replace synonym as4_anagrafe_soggetti for ${global.db.as4.username}.anagrafe_soggetti
/

create or replace synonym as4_anagrafe_soggetti_pkg for ${global.db.as4.username}.anagrafe_soggetti_pkg
/

create or replace synonym as4_anagrafe_soggetti_refresh for ${global.db.as4.username}.anagrafe_soggetti_refresh
/

create or replace synonym as4_anagrafe_soggetti_tpk for ${global.db.as4.username}.anagrafe_soggetti_tpk
/

create or replace synonym as4_anagrafici for ${global.db.as4.username}.anagrafici
/

create or replace synonym as4_anagrafici_pkg for ${global.db.as4.username}.anagrafici_pkg
/

create or replace synonym as4_anagrafici_tpk for ${global.db.as4.username}.anagrafici_tpk
/

create or replace synonym as4_contatti for ${global.db.as4.username}.contatti
/

create or replace synonym as4_contatti_pkg for ${global.db.as4.username}.contatti_pkg
/

create or replace synonym as4_contatti_tpk for ${global.db.as4.username}.contatti_tpk
/

create or replace synonym as4_recapiti for ${global.db.as4.username}.recapiti
/

create or replace synonym as4_recapiti_pkg for ${global.db.as4.username}.recapiti_pkg
/

create or replace synonym as4_recapiti_tpk for ${global.db.as4.username}.recapiti_tpk
/

create or replace synonym as4_soggetti for ${global.db.as4.username}.soggetti
/

create or replace synonym as4_tipi_contatto for ${global.db.as4.username}.tipi_contatto
/

create or replace synonym as4_tipi_contatto_tpk for ${global.db.as4.username}.tipi_contatto_tpk
/

create or replace synonym as4_tipi_recapito for ${global.db.as4.username}.tipi_recapito
/

create or replace synonym as4_tipi_recapito_tpk for ${global.db.as4.username}.tipi_recapito_tpk
/

create or replace synonym as4_tipi_soggetto for ${global.db.as4.username}.tipi_soggetto
/

create or replace synonym as4_tipi_soggetto_tpk for ${global.db.as4.username}.tipi_soggetto_tpk
/

-- SO4
create or replace synonym so4_ags_pkg for ${global.db.so4.username}.so4_ags_pkg
/

create or replace synonym so4_albero_unita_org for ${global.db.so4.username}.unita_organizzative
/

create or replace synonym so4_amministrazioni for ${global.db.so4.username}.amministrazioni
/

create or replace synonym so4_aoo for ${global.db.so4.username}.aoo
/

create or replace synonym so4_aoo_view for ${global.db.so4.username}.aoo_view
/

create or replace synonym so4_applicativi for ${global.db.so4.username}.applicativi
/

create or replace synonym so4_attributi_componente for ${global.db.so4.username}.vista_atco_grails
/

create or replace synonym so4_attributi_componente_pubb for ${global.db.so4.username}.vista_atco_grails_pubb
/

create or replace synonym so4_auor for ${global.db.so4.username}.anagrafe_unita_organizzative
/

create or replace synonym so4_competenze_delega for ${global.db.so4.username}.competenze_delega
/

create or replace synonym so4_competenze_delega_tpk for ${global.db.so4.username}.competenze_delega_tpk
/

create or replace synonym so4_componenti for ${global.db.so4.username}.vista_comp_grails
/

create or replace synonym so4_componenti_pubb for ${global.db.so4.username}.vista_comp_grails_pubb
/

create or replace synonym so4_deleghe for ${global.db.so4.username}.deleghe
/

create or replace synonym so4_indirizzi_telematici for ${global.db.so4.username}.indirizzi_telematici
/

create or replace synonym so4_ottiche for ${global.db.so4.username}.ottiche
/

create or replace synonym so4_ruoli_componente for ${global.db.so4.username}.ruoli_componente
/

create or replace synonym so4_ruoli_componente_pubb for ${global.db.so4.username}.vista_pubb_ruco
/

create or replace synonym so4_soggetti_unita for ${global.db.so4.username}.soggetti_unita
/

create or replace synonym so4_suddivisioni_struttura for ${global.db.so4.username}.suddivisioni_struttura
/

create or replace synonym so4_unita_organizzative for ${global.db.so4.username}.vista_unita_organizzative
/

create or replace synonym so4_unita_organizzative_pubb for ${global.db.so4.username}.vista_unita_organizzative_pubb
/

create or replace synonym so4_util for ${global.db.so4.username}.so4_util
/

create or replace synonym so4_vista_pubb_unita for ${global.db.so4.username}.vista_pubb_unita
/

create or replace synonym so4_soggetti_aoo for ${global.db.so4.username}.soggetti_aoo
/

create or replace synonym SO4_ANAGRAFE_UNITA FOR ${global.db.so4.username}.ANAGRAFE_UNITA_ORGANIZZATIVE
/

CREATE OR REPLACE SYNONYM SO4_INDIRIZZO_TELEMATICO FOR ${global.db.so4.username}.INDIRIZZO_TELEMATICO
/

CREATE OR REPLACE SYNONYM SO4_CODICI_IPA_TPK FOR ${global.db.so4.username}.CODICI_IPA_TPK
/

create or replace synonym SO4_ANA_UNOR_PKG for ${global.db.so4.username}.anagrafe_unita_organizzativa
/

create or replace synonym so4_unor for ${global.db.so4.username}.unita_organizzative
/

-- SI4CS
CREATE OR REPLACE SYNONYM SI4CS_ALLEGATI FOR ${global.db.si4cs.username}.ALLEGATI
/
CREATE OR REPLACE SYNONYM SI4CS_ALLEGATI_MESSAGGIO FOR ${global.db.si4cs.username}.ALLEGATI_MESSAGGIO
/
CREATE OR REPLACE SYNONYM SI4CS_BINARY_ALLEGATI FOR ${global.db.si4cs.username}.BINARY_ALLEGATI
/
CREATE OR REPLACE SYNONYM SI4CS_CONTATTI FOR ${global.db.si4cs.username}.CONTATTI
/
CREATE OR REPLACE SYNONYM SI4CS_CONT_SQ FOR ${global.db.si4cs.username}.CONT_SQ
/
CREATE OR REPLACE SYNONYM SI4CS_MESSAGGI FOR ${global.db.si4cs.username}.MESSAGGI
/
CREATE OR REPLACE SYNONYM SI4CS_MESSAGGI_BLOB FOR ${global.db.si4cs.username}.MESSAGGI_BLOB
/
CREATE OR REPLACE SYNONYM SI4CS_MESSAGGI_RICEVUTI FOR ${global.db.si4cs.username}.MESSAGGI_RICEVUTI
/
CREATE OR REPLACE SYNONYM SI4CS_MIME_SQ FOR ${global.db.si4cs.username}.MIME_SQ
/
CREATE OR REPLACE SYNONYM SI4CS_MITTENTI_MESSAGGIO FOR ${global.db.si4cs.username}.MITTENTI_MESSAGGIO
/
CREATE OR REPLACE SYNONYM SI4CS_SEQ_ALLEGATI FOR ${global.db.si4cs.username}.SEQ_ALLEGATI
/
CREATE OR REPLACE SYNONYM SI4CS_SEQ_ALLEGATI_MESSAGGIO FOR ${global.db.si4cs.username}.ALME_SQ
/
CREATE OR REPLACE SYNONYM SI4CS_SEQ_BINARY_ALLEGATI FOR ${global.db.si4cs.username}.SEQ_BINARY_ALLEGATI
/
CREATE OR REPLACE SYNONYM SI4CS_SEQ_MESSAGGI FOR ${global.db.si4cs.username}.SEQ_MESSAGGI
/
CREATE OR REPLACE SYNONYM SI4CS_SEQ_MESSAGGI_BLOB FOR ${global.db.si4cs.username}.SEQ_MESSAGGI_BLOB
/
CREATE OR REPLACE SYNONYM SI4CS_SEQ_TESTI_MESSAGGI FOR ${global.db.si4cs.username}.SEQ_TESTI_MESSAGGI
/
CREATE OR REPLACE SYNONYM SI4CS_TESTI_MESSAGGI FOR ${global.db.si4cs.username}.TESTI_MESSAGGI
/
