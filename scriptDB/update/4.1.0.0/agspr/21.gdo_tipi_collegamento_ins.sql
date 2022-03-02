--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200330.21.gdo_tipi_collegamento_ins
Insert into GDO_TIPI_COLLEGAMENTO
   (ID_TIPO_COLLEGAMENTO, TIPO_COLLEGAMENTO, DESCRIZIONE, COMMENTO, ID_ENTE, UTENTE_INS, DATA_INS, UTENTE_UPD, DATA_UPD, VALIDO, SISTEMA)
 select HIBERNATE_SEQUENCE.nextval , 'MAIL', 'Collegamento fra messaggio in arrivo e protocollo', 'Collegamento fra messaggio in arrivo e protocollo',
    1, 'RPI', SYSDATE, 'RPI', SYSDATE,
    'Y', 'Y'
   from dual
  where not exists(select 1 from GDO_TIPI_COLLEGAMENTO where TIPO_COLLEGAMENTO = 'MAIL')
/