--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20200915_1.dbfw_istruzioni_ins.sql failOnError:false

Insert into DBFW_ISTRUZIONI
   (NOME, MODULO, TIPO, DESCRIZIONE,
    VALIDA, UTENTE_INSERIMENTO, DATA_INSERIMENTO, UTENTE_AGGIORNAMENTO, DATA_AGGIORNAMENTO,
    DI_SISTEMA, MODALITA, BLOCKSIZE, NAVIGATION, TEXT_SQL,
    TIPO_RITORNO, TIPO_CONNESSIONE)
 Values
   ('AG_DOCUMENTO_UTILITY_IS_PROTOCOLLATO', 'AGSPR', 'FUNCTION', 'AG_DOCUMENTO_UTILITY_IS_PROTOCOLLATO',
    'S', 'WIZARD', SYSDATE, 'WIZARD', SYSDATE,
    'N', 'execute', 50, 'next', 'AG_DOCUMENTO_UTILITY.IS_PROTOCOLLATO',
    'VARCHAR2', 'AD4')
/

Insert into DBFW_ISTRUZIONI_PARAMETRI
   (NOME_ISTRUZIONE, NOME, SEQUENZA, DIRECTION)
 Values
   ('AG_DOCUMENTO_UTILITY_IS_PROTOCOLLATO', 'P_ID_DOCUMENTO', 0, 'IN')
/
