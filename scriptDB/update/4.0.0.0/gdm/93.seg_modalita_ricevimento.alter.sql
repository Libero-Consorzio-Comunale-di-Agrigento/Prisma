--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_93.seg_modalita_ricevimento.alter failOnError:false
alter table seg_modalita_ricevimento
   modify (mod_ricevimento varchar2 (255));
/

update dati
   set lunghezza   = 255
 where area in ('SEGRETERIA', 'SEGRETERIA.PROTOCOLLO')
   and dato = 'MOD_RICEVIMENTO'
/
