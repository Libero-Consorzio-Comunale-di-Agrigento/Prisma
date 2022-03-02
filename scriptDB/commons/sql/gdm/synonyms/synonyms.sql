--liquibase formatted sql
--changeset esasdelli:_20200220_synonyms  runOnChange:true stripComments:false
CREATE or replace SYNONYM AGSPR_COMPETENZE_DOCUMENTO FOR ${global.db.agspr.username}.AGP_COMPETENZE_DOCUMENTO
/

CREATE or replace SYNONYM agspr_GDO_NOTIFICHE_ATTIVITA FOR ${global.db.agspr.username}.GDO_NOTIFICHE_ATTIVITA
/

create or replace synonym as4_tipi_recapito_tpk for ${global.db.as4.username}.tipi_recapito_tpk
/

CREATE OR REPLACE SYNONYM AGP_SCHEMI_PROT_INTEGRAZIONI FOR ${global.db.agspr.username}.AGP_SCHEMI_PROT_INTEGRAZIONI
/