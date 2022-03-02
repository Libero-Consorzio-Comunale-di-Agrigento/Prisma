--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_142_upd_seg_memo_protocollo_tipo_mess

UPDATE seg_memo_protocollo
   SET tipo_messaggio = tipo_messaggio
 WHERE tipo_messaggio IS NULL
/