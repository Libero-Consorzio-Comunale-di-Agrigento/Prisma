--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200831_33.gdo_gdo_tipologie_soggetto_ins_fasc
declare
   d_id_tipologia_soggetto   number;
begin
   select hibernate_sequence.nextval into d_id_tipologia_soggetto from dual;

   insert into gdo_tipologie_soggetto (id_tipologia_soggetto
                                     , descrizione
                                     , commento
                                     , layout_soggetti
                                     , tipo_oggetto
                                     , id_ente
                                     , valido
                                     , utente_ins
                                     , data_ins
                                     , utente_upd
                                     , data_upd
                                     , version)
        values (d_id_tipologia_soggetto
              , 'FASCICOLO'
              , 'Fascicolo'
              , '/protocollo/documenti/protocollo/protocolloStandard.zul'
              , 'FASCICOLO'
              , 1
              , 'Y'
              , 'RPI'
              , sysdate
              , 'RPI'
              , sysdate
              , 0);

   insert into gdo_tipologie_soggetto_regole (id_tipologia_soggetto_regola
                                            , version
                                            , data_ins
                                            , id_ente
                                            , data_upd
                                            , regola_default_nome_bean
                                            , regola_default_nome_metodo
                                            , regola_lista_nome_bean
                                            , regola_lista_nome_metodo
                                            , ruolo
                                            , sequenza
                                            , tipo_soggetto
                                            , tipo_soggetto_partenza
                                            , id_tipologia_soggetto
                                            , utente_ins
                                            , utente_upd
                                            , valido)
        values (hibernate_sequence.nextval
              , 0
              , sysdate
              , 1
              , sysdate
              , 'regoleCalcoloSoggettiProtocolloRepository'
              , 'ricercaUnitaPubbDefault'
              , 'regoleCalcoloSoggettiProtocolloRepository'
              , 'ricercaUnitaPubb'
              , null
              , 1
              , 'UO_COMPETENZA'
              , null
              , d_id_tipologia_soggetto
              , 'RPI'
              , 'RPI'
              , 'Y');

   insert into gdo_tipologie_soggetto_regole (id_tipologia_soggetto_regola
                                            , version
                                            , data_ins
                                            , id_ente
                                            , data_upd
                                            , regola_default_nome_bean
                                            , regola_default_nome_metodo
                                            , regola_lista_nome_bean
                                            , regola_lista_nome_metodo
                                            , ruolo
                                            , sequenza
                                            , tipo_soggetto
                                            , tipo_soggetto_partenza
                                            , id_tipologia_soggetto
                                            , utente_ins
                                            , utente_upd
                                            , valido)
        values (hibernate_sequence.nextval
              , 0
              , sysdate
              , 1
              , sysdate
              , 'regoleCalcoloSoggettiProtocolloRepository'
              , 'ricercaUnitaCreazioneFascicoloDefault'
              , 'regoleCalcoloSoggettiProtocolloRepository'
              , 'ricercaUnitaCreazioneFascicolo'
              , null
              , 2
              , 'UO_CREAZIONE'
              , null
              , d_id_tipologia_soggetto
              , 'RPI'
              , 'RPI'
              , 'Y');

   commit;
end;
/
