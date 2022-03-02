--liquibase formatted sql
--changeset rdestasio:2.4.4.0_20200221_01

-- aggiungo il parametro applicativo_chiamante ai parametri della jworklist
BEGIN
  for c in (select codice, ente from impostazioni where codice = 'JWORKLIST') loop
    insert into mapping_integrazioni (id_mapping_integrazione, categoria, codice, valore_interno, valore_esterno, ente, sequenza)
        values (hibernate_sequence.nextval, c.codice, 'APPLICATIVO_CHIAMANTE', '*', 'Atti', c.ente, 0);
  end loop;
end;
/

ALTER TABLE DETERMINE MODIFY (CLASSIFICA_DESCRIZIONE VARCHAR2(4000 BYTE))
/

ALTER TABLE DETERMINE_STORICO MODIFY (CLASSIFICA_DESCRIZIONE VARCHAR2(4000 BYTE))
/

ALTER TABLE PROPOSTE_DELIBERA MODIFY (CLASSIFICA_DESCRIZIONE VARCHAR2(4000 BYTE))
/

ALTER TABLE PROPOSTE_DELIBERA_STORICO MODIFY (CLASSIFICA_DESCRIZIONE VARCHAR2(4000 BYTE))
/

ALTER TABLE ODG_SEDUTE_STAMPE MODIFY (CLASSIFICA_DESCRIZIONE VARCHAR2(4000 BYTE))
/

ALTER TABLE ODG_SEDUTE_STAMPE_STORICO MODIFY (CLASSIFICA_DESCRIZIONE VARCHAR2(4000 BYTE))
/

CREATE TABLE FILE_FIRMATI ( ID_FILE_FIRMATO NUMBER NOT NULL PRIMARY KEY, ID_FILE_ALLEGATO NUMBER NOT NULL, ID_DOCUMENTO NUMBER NOT NULL, NOMINATIVO VARCHAR2(4000 BYTE) NOT NULL, DATA_FIRMA DATE, DATA_VERIFICA DATE, STATO varchar2 (255), UTENTE_INS VARCHAR2(255 BYTE), DATA_INS DATE, UTENTE_UPD VARCHAR2(255 BYTE), DATA_UPD DATE, VERSION NUMBER, ENTE VARCHAR2(255 BYTE) ) LOGGING NOCOMPRESS NOCACHE NOPARALLEL MONITORING
/

UPDATE IMPOSTAZIONI SET VALORE = 'alboJMessi' where valore = 'Y' and CODICE = 'INTEGRAZIONE_ALBO'
/