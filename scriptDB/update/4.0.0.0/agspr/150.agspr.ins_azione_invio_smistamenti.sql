--liquibase formatted sql
--changeset rdestasio:4.0.0.0_20200723_150_ins_azione_invio_smistamenti
insert into wkf_diz_azioni (id_azione
                          , version
                          , descrizione
                          , nome
                          , nome_bean
                          , nome_metodo
                          , tipo
                          , tipo_oggetto
                          , valido)
   select hibernate_sequence.nextval
        , 0
        , 'Invio degli smistamenti di un protocollo'
        , 'Invio Smistamenti'
        , 'protocolloAction'
        , 'invioSmistamenti'
        , 'AUTOMATICA'
        , 'PROTOCOLLO'
        , 'Y'
     from dual
    where not exists
             (select 1
                from wkf_diz_azioni
               where nome_bean = 'protocolloAction'
                 and nome_metodo = 'invioSmistamenti'
                 and tipo_oggetto = 'PROTOCOLLO')
/
