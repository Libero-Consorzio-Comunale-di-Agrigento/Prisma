--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200309_ins_assistente_virtuale

Insert into ASSISTENTE_VIRTUALE
 (ID,AREA_APPLICATIVA,MODULO_SOFTWARE,PAGINA_APPLICATIVA,LINK,VERSIONE_ASSISTENTE,LINGUA,VERSION)
values
 ((select nvl(max(id),0)+1 from ASSISTENTE_VIRTUALE),'Affari Generali','AGSPR','Provvedimento di Annullamento', '/provvedimento-di-annullamento', '4.0.0', 'I' ,1)
/

Insert into ASSISTENTE_VIRTUALE
 (ID,AREA_APPLICATIVA,MODULO_SOFTWARE,PAGINA_APPLICATIVA,LINK,VERSIONE_ASSISTENTE,LINGUA,VERSION)
values
 ((select nvl(max(id),0)+1 from ASSISTENTE_VIRTUALE),'Affari Generali','AGSPR','Lettera', '/lettera','4.0.0', 'I' ,1)
/

Insert into ASSISTENTE_VIRTUALE
 (ID,AREA_APPLICATIVA,MODULO_SOFTWARE,PAGINA_APPLICATIVA,LINK,VERSIONE_ASSISTENTE,LINGUA,VERSION)
values
 ((select nvl(max(id),0)+1 from ASSISTENTE_VIRTUALE),'Affari Generali','AGSPR','Protocollazione', '/protocollazione', '4.0.0', 'I' ,1)
/

commit
/