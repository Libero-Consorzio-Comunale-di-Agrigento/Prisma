--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_PREFERENZE_UTENTE runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_PREFERENZE_UTENTE" ("ID_PREFERENZA", "PREFERENZA", "VALORE", "UTENTE", "MODULO") AS 
  select -get_number_from_string (preferenza || '_' || utente) id_preferenza
        , preferenza
        , decode (preferenza
                , 'Modalita', decode (agp_registro_utility.get_preferenza_utente (modulo
                                                                                , utente
                                                                                , preferenza
                                                                                , 'GDM')
                                    , 'ARR', 'ARRIVO'
                                    , 'PAR', 'PARTENZA'
                                    , 'INT', 'INTERNO')
                , agp_registro_utility.get_preferenza_utente (modulo
                                                            , utente
                                                            , preferenza
                                                            , 'GDM'))
             valore
        , utente
        , modulo
     from (select distinct d.utente, d.modulo
             from ad4_diritti_accesso d, ad4_utenti u
            where modulo = 'AGSPR'
              and u.utente = d.utente
              and u.tipo_utente = 'U'
              and u.stato = 'U') d
        , (select 'UnitaIter' preferenza from agspr_dual
           union
           select 'UnitaProtocollante' preferenza from agspr_dual
           union
           select 'Modalita' preferenza from agspr_dual
           union
           select 'DuplicaRapportiCopia' preferenza from agspr_dual
           union
           select 'DuplicaRapportiRisposta' preferenza from agspr_dual
           union
           select 'DuplicaSmistCopia' preferenza from agspr_dual
           union
           select 'DuplicaSmistRisposta' preferenza from agspr_dual
           union
           select 'DuplicaFasc' preferenza from agspr_dual
           union
           select 'AbilitaStampaBCDiretta' preferenza from agspr_dual
           union
           select 'AbilitaStampaRicDiretta' preferenza from agspr_dual
           union
           select 'ScanRichiediFilename' preferenza from agspr_dual
           union
           select 'ScanAbilitaImpostazioni' preferenza from agspr_dual
           union
           select 'ReportTimbro' preferenza from agspr_dual
           union
           select 'ApriSoggettoUnivoco' preferenza from agspr_dual) preferenze
/
