--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200828_31.wkf_diz_tipi_oggetto_ins
Insert into WKF_DIZ_TIPI_OGGETTO
   (CODICE, DESCRIZIONE, ITERABILE, NOME, VALIDO)
 Values
   ('FASCICOLO', 'Fascicolo', 'N', 'FASCICOLO', 'Y')
/
