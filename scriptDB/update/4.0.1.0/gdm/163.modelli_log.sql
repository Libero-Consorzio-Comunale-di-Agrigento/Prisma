--liquibase formatted sql
--changeset rdestasio:4.0.1.0_20200315_163_modelli_log
UPDATE tipi_documento
   SET tipo_log = 'S'
 WHERE     nome IN ('LETTERA_USCITA',
                    'M_PROTOCOLLO',
                    'M_REGISTRO_GIORNALIERO',
                    'M_PROTOCOLLO_INTEROPERABILITA',
                    'M_PROTOCOLLO_EMERGENZA',
                    'M_PROVVEDIMENTO',
                    'DOC_DA_FASCICOLARE')
       AND area_modello IN ('SEGRETERIA.PROTOCOLLO')
/