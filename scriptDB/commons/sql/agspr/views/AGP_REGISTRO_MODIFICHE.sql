--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_REGISTRO_MODIFICHE runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_REGISTRO_MODIFICHE" ("ID_DOCUMENTO", "ID_ENTE", "DATA_UPD", "UTENTE_UPD", "MODIFICA") AS 
  select pl.id_documento
        , gd.id_ente
        , gdl.data_upd
        , gdl.utente_upd
        , 'OGGETTO_MOVIMENTO'
     from agp_protocolli_log pl, gdo_documenti gd, gdo_documenti_log gdl
    where pl.id_documento = gd.id_documento
      and pl.data is not null
      and gd.valido = 'Y'
      and pl.anno_mod = 0
      and (pl.oggetto_mod = 1
        or pl.movimento_mod = 1)
      and gdl.id_documento = pl.id_documento
      and gdl.rev = pl.rev
      and gdl.data_upd > pl.data
   union
   select pcl.id_documento
        , gd.id_ente
        , pcl.data_upd
        , pcl.utente_upd
        , 'CORRISPONDENTE'
     from agp_protocolli p, agp_protocolli_corr_log pcl, gdo_documenti gd
    where p.id_documento = pcl.id_documento
      and p.id_documento = gd.id_documento
      and gd.valido = 'Y'
      and p.data is not null
      and ( (pcl.revtype = 1
         and (pcl.denominazione_mod = 1
           or pcl.codice_fiscale_mod = 1
           or pcl.partita_iva_mod = 1
           or pcl.indirizzo_mod = 1
           or pcl.comune_mod = 1
           or pcl.provincia_sigla_mod = 1
           or pcl.cap_mod = 1
           or pcl.email_mod = 1))
        or (pcl.revtype in (0, 2)))
      and pcl.data_upd > p.data
   union
   select pl.id_documento
        , gd.id_ente
        , pl.data_upd
        , pl.utente_upd
        , 'FILE_PRINCIPALE'
     from agp_protocolli p
        , gdo_documenti gd
        , agp_protocolli_log log_protocollazione
        , gdo_file_documento_log pl
    where p.id_documento = gd.id_documento
      and gd.valido = 'Y'
      and p.data is not null
      and p.id_documento = pl.id_documento
      and log_protocollazione.id_documento = pl.id_documento
      and log_protocollazione.data_mod = 1
      and pl.rev > log_protocollazione.rev
      and not (pl.dimensione_mod = 0 and pl.id_file_esterno_mod = 0 and pl.nome_mod = 1 and pl.revisione_mod = 0)  --condizione che capita quando rinomino il file
   union
   select p.id_documento
        , gd.id_ente
        , pl.data_upd
        , pl.utente_upd
        , 'FILE_ALLEGATO'
     from gdo_file_documento_log pl
        , gdo_documenti_collegati gdc
        , agp_protocolli p
        , agp_protocolli_log log_protocollazione
        , gdo_documenti gd
    where p.id_documento = gd.id_documento
      and gd.valido = 'Y'
      and p.data is not null
      and p.id_documento = gdc.id_documento
      and pl.id_documento = gdc.id_collegato
      and pl.codice = 'FILE_ALLEGATO'
      and p.id_documento = log_protocollazione.id_documento
      and log_protocollazione.data_mod = 1
      and pl.rev > log_protocollazione.rev
      and not (pl.dimensione_mod = 0 and pl.id_file_esterno_mod = 0 and pl.nome_mod = 1 and pl.revisione_mod = 0)  --condizione che capita quando rinomino il file
/
