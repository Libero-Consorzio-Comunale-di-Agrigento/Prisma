--liquibase formatted sql
--changeset rdestasio:install_20200221_integrazioni_01

create or replace force view cons_delibere
(
   id_delibera
 , id_proposta_delibera
 , id_documento_esterno
 , filename
 , id_file_gdm
 , anno_delibera
 , data_numero_delibera
 , numero_delibera
 , registro_delibera
 , descrizione_registro_delibera
 , anno_proposta
 , data_numero_proposta
 , numero_proposta
 , registro_proposta
 , anno_protocollo
 , data_numero_protocollo
 , numero_protocollo
 , registro_protocollo
 , data_pubblicazione
 , data_fine_pubblicazione
 , data_esecutivita
 , tipologia
 , oggetto
 , riservato
 , num_allegati_riservati
 , tipo_delibera
 , unita_proponente
 , redattore
 , funzionario
 , dirigente
 , unita_dirigente
 , descrizione_area
 , descrizione_servizio
 , classifica_codice
 , classifica_dal
 , classifica_descrizione
 , fascicolo_numero
 , fascicolo_anno
 , fascicolo_oggetto
 , stato
 , presidente
 , data_firma_presidente
 , segretario
 , data_firma_segretario
 , dir_amministrativo
 , data_firma_dir_amministrativo
 , dir_sanitario
 , data_firma_dir_sanitario
 , dir_generale
 , data_firma_dir_generale
 , impegno_spesa
 , firmatario_parere_contabile
 , data_firma_parere_contabile
 , unita_parere_contabile
 , esito_parere_contabile
 , numero_albo
 , anno_albo
 , soggetti_notifica
 , ente
)
as
   select d.id_delibera
        , pd.id_proposta_delibera
        , d.id_documento_esterno
        , fa.nome filename
        , fa.id_file_esterno
        , d.anno_delibera
        , d.data_numero_delibera
        , d.numero_delibera
        , d.registro_delibera
        , tr.descrizione
        , pd.anno_proposta
        , pd.data_numero_proposta
        , pd.numero_proposta
        , pd.registro_proposta
        , d.anno_protocollo
        , d.data_numero_protocollo
        , d.numero_protocollo
        , decode (d.numero_protocollo, null, null, nvl (d.registro_protocollo, 'PROT'))
        , d.data_pubblicazione
        , d.data_fine_pubblicazione
        , d.data_esecutivita
        , td.titolo
        , d.oggetto
        , d.riservato
        , (select count (1)
             from allegati alle
            where (alle.id_delibera = d.id_delibera or alle.id_proposta_delibera = d.id_proposta_delibera)
              and alle.valido = 'Y'
              and alle.riservato = 'Y')
             num_allegati_riservati
        , td.titolo tipo_delibera
        , utility_pkg.get_uo_descrizione (uo_prop.unita_progr, uo_prop.unita_dal) unita_proponente
        , utility_pkg.get_cognome_nome (utility_pkg.get_ni_soggetto (redattore.utente)) redattore
        , decode (pd.controllo_funzionario
                , 'Y', utility_pkg.get_cognome_nome (utility_pkg.get_ni_soggetto (funzionario.utente))
                , '')
             funzionario
        , decode (
             d.id_engine_iter
           , null, decode (dirigente.utente
                         , null, 'NON VALORIZZATO ALLA DATA DI PRODUZIONE DEL DOCUMENTO'
                         , utility_pkg.get_cognome_nome (utility_pkg.get_ni_soggetto (dirigente.utente)))
           , utility_pkg.get_cognome_nome (utility_pkg.get_ni_soggetto (dirigente.utente)))
             dirigente
        , utility_pkg.get_uo_descrizione (dirigente.unita_progr, dirigente.unita_dal) unita_dirigente
        , utility_pkg.get_suddivisione_descrizione (uo_prop.unita_progr
                                                  , uo_prop.unita_dal
                                                  , 'SO4_SUDDIVISIONE_AREA'
                                                  , d.ente)
             descrizione_area
        , utility_pkg.get_suddivisione_descrizione (uo_prop.unita_progr
                                                  , uo_prop.unita_dal
                                                  , 'SO4_SUDDIVISIONE_SERVIZIO'
                                                  , d.ente)
             descrizione_servizio
        , pd.classifica_codice
        , pd.classifica_dal
        , pd.classifica_descrizione
        , pd.fascicolo_numero
        , pd.fascicolo_anno
        , pd.fascicolo_oggetto
        , d.stato
        , decode (
             d.id_engine_iter
           , null, decode (utility_pkg.get_firmatario_delibera (d.id_delibera, 'PRESIDENTE')
                         , null, 'NON VALORIZZATO ALLA DATA DI PRODUZIONE DEL DOCUMENTO'
                         , utility_pkg.get_firmatario_delibera (d.id_delibera, 'PRESIDENTE'))
            , nvl (utility_pkg.get_firmatario_delibera (d.id_delibera, 'PRESIDENTE')
                , utility_pkg.get_nominativo_sogg_deli (d.id_delibera, 'PRESIDENTE')))
        , utility_pkg.get_data_firma_delibera (d.id_delibera, 'PRESIDENTE')
        , decode (
             d.id_engine_iter
           , null, decode (utility_pkg.get_firmatario_delibera (d.id_delibera, 'SEGRETARIO')
                         , null, 'NON VALORIZZATO ALLA DATA DI PRODUZIONE DEL DOCUMENTO'
                         , utility_pkg.get_firmatario_delibera (d.id_delibera, 'SEGRETARIO'))
            , nvl (utility_pkg.get_firmatario_delibera (d.id_delibera, 'SEGRETARIO')
                , utility_pkg.get_nominativo_sogg_deli (d.id_delibera, 'SEGRETARIO')))
        , utility_pkg.get_data_firma_delibera (d.id_delibera, 'SEGRETARIO')
        , decode (
             d.id_engine_iter
           , null, decode (utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_AMMINISTRATIVO')
                         , null, 'NON VALORIZZATO ALLA DATA DI PRODUZIONE DEL DOCUMENTO'
                         , utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_AMMINISTRATIVO'))
           , utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_AMMINISTRATIVO'))
        , utility_pkg.get_data_firma_delibera (d.id_delibera, 'DIRETTORE_AMMINISTRATIVO')
        , decode (
             d.id_engine_iter
           , null, decode (utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_SANITARIO')
                         , null, 'NON VALORIZZATO ALLA DATA DI PRODUZIONE DEL DOCUMENTO'
                         , utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_SANITARIO'))
           , utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_SANITARIO'))
        , utility_pkg.get_data_firma_delibera (d.id_delibera, 'DIRETTORE_SANITARIO')
        , decode (
             d.id_engine_iter
           , null, decode (utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_GENERALE')
                         , null, 'NON VALORIZZATO ALLA DATA DI PRODUZIONE DEL DOCUMENTO'
                         , utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_GENERALE'))
           , utility_pkg.get_firmatario_delibera (d.id_delibera, 'DIRETTORE_GENERALE'))
        , utility_pkg.get_data_firma_delibera (d.id_delibera, 'DIRETTORE_GENERALE')
        , (select decode (count (1), 0, 'N', 'Y')
             from visti_pareri vp, tipi_visto_parere tvp
            where (vp.id_delibera = d.id_delibera or vp.id_proposta_delibera = d.id_proposta_delibera)
              and vp.id_tipologia = tvp.id_tipo_visto_parere
              and vp.valido = 'Y'
              and tvp.contabile = 'Y')
             impegno_spesa
        , utility_pkg.get_firmatario_par_contabile (d.id_delibera) firmatario_parere_contabile
        , utility_pkg.get_data_firma_par_contabile (d.id_delibera) data_firma_parere_contabile
        , utility_pkg.get_unita_parere_contabile (d.id_delibera) unita_parere_contabile
        , utility_pkg.get_esito_parere_contabile (d.id_delibera) esito_parere_contabile
        , numero_albo
        , anno_albo
        , utility_pkg.get_sogg_notifica_delibera (d.id_delibera) soggetti_notifica
        , d.ente
     from proposte_delibera_soggetti uo_prop
        , proposte_delibera_soggetti redattore
        , proposte_delibera_soggetti funzionario
        , proposte_delibera_soggetti dirigente
        , file_allegati fa
        , proposte_delibera pd
        , delibere d
        , tipi_delibera td
        , tipi_registro tr
    where pd.id_tipo_delibera = td.id_tipo_delibera
      and d.id_file_allegato_testo = fa.id_file_allegato
      and d.id_proposta_delibera = pd.id_proposta_delibera
      and uo_prop.id_proposta_delibera = d.id_proposta_delibera
      and uo_prop.tipo_soggetto = 'UO_PROPONENTE'
      and redattore.id_proposta_delibera(+) = d.id_proposta_delibera
      and redattore.tipo_soggetto(+) = 'REDATTORE'
      and funzionario.id_proposta_delibera(+) = d.id_proposta_delibera
      and funzionario.tipo_soggetto(+) = 'FUNZIONARIO'
      and dirigente.id_proposta_delibera(+) = d.id_proposta_delibera
      and dirigente.tipo_soggetto(+) = 'DIRIGENTE'
      and d.valido = 'Y'
      and d.registro_delibera = tr.tipo_registro
/
