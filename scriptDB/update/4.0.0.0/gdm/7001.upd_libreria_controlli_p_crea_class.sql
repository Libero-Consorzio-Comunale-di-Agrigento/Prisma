--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200506_7000.upd_libreria_controlli_p_crea_class
update LIBRERIA_CONTROLLI
   set corpo = 'var c = document.getElementById(''idCartella'').value; popup(''/Protocollo/standalone.zul?operazione=APRI_CLASSIFICAZIONE&area=SEGRETERIA&cm=DIZ_CLASSIFICAZIONE&rw=W&Provenienza=C&MVPG=ServletModulisticaDocumento&idCartProveninez=''+c+''&GDC_Link=..%2Fcommon%2FClosePageAndRefresh.do%3FidCartProveninez%3D''+c,500,400, 0, 50);'
 where AREA = 'SEGRETERIA'
   and CONTROLLO = 'P_CREA_CLASS'
/
COMMIT
/