--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200317_160.gdo_enti_alter
CREATE UNIQUE INDEX GDO_ENTI_UK ON GDO_ENTI
(AMMINISTRAZIONE, AOO, OTTICA)
/
