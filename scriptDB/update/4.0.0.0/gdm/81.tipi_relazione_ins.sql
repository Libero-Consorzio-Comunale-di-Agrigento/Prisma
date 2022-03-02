--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_81.tipi_relazione_ins failOnError:false
INSERT INTO TIPI_RELAZIONE (AREA,
                            TIPO_RELAZIONE,
                            DESCRIZIONE,
                            VISIBILE,
                            DIPENDENZA,
                            DATA_AGGIORNAMENTO,
                            UTENTE_AGGIORNAMENTO)
   SELECT 'SEGRETERIA.PROTOCOLLO',
          'PROT_DAFAS',
          'Collegamento tra il documento da fascicolare ed il protocollo generato',
          'S',
          'N',
          SYSDATE,
          'RPI'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM TIPI_RELAZIONE
               WHERE     area = 'SEGRETERIA.PROTOCOLLO'
                     AND tipo_relazione = 'PROT_DAFAS')
/
