--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_053.gdo_tipi_collegamento_alter
alter table gdo_tipi_collegamento
add (sistema char(1) default 'N')
/

update gdo_tipi_collegamento
   set sistema   = 'Y'
 where tipo_collegamento in ('ALLEGATO'
                           , 'PROT_DAAC'
                           , 'PROT_RIFE'
                           , 'PROV_PROT'
                           , 'PROT_PREC'
                           , 'EMER'
                           , 'PROT_DAFAS'
                           , 'MAIL')
/

update gdo_tipi_collegamento
   set tipo_collegamento = 'COLLEGATO'
 where tipo_collegamento = 'DOC_COLLEGATO'
/