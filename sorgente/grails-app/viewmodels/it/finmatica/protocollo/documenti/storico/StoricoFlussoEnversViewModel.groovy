package it.finmatica.protocollo.documenti.storico

import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.beans.FileDownloader
import oracle.sql.TIMESTAMP
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.GlobalCommand
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import javax.sql.DataSource

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class StoricoFlussoEnversViewModel {

    private Long idDocumento

    @WireVariable
    private DataSource dataSource

    @WireVariable
    private FileDownloader fileDownloader

    @Init
    void init(@ExecutionArgParam("idDocumento") Long idDocumento) {
        this.idDocumento = idDocumento
    }

    @NotifyChange("listaStoricoFlusso")
    @GlobalCommand("onRefreshStoricoProtocollo")
    void ricaricaStorico() {
    }

    List<LinkedHashMap> getListaStoricoFlusso() {
        if (idDocumento == null) {
            return []
        }

        return new Sql(dataSource).rows('''select i.rev iter_rev
     , i.revend iter_revend
     , pd.rev doc_rev
     , pd.revend doc_revend
     , pf.rev file_rev
     , pf.revend file_revend
     , u.nominativo_soggetto
     , i.data_upd TIMESTAMP
     , cs.titolo
     , pf.nome nome_file
     , pf.id_file_esterno
     , pf.ID_FILE_DOCUMENTO
     , pf.firmato
     , pd.id_documento_esterno
     , case when pf.REVTYPE = 2 then (select max(l.revisione_storico) 
                                        from gdo_file_documento_log l 
                                       where l.id_file_documento = pf.id_file_documento 
                                         and l.revtype in (0, 1) 
                                         and l.revisione_storico is not null) 
                                else pf.revisione_storico 
       end as REVISIONE_STORICO -- siccome non sono riuscito a scrivere il numero di revisione nei record di log in caso di cancellazione del file, recupero il valore maggiore (cioè l'ultimo) che va bene lostesso.
     , p.note
  from wkf_engine_iter_log i
     , wkf_engine_step s
     , wkf_cfg_step cs
     , gdo_documenti_log pd
     , agp_protocolli_log p
     , gdo_file_documento_log pf
     , ad4_v_utenti u
 where i.id_engine_iter = pd.id_engine_iter
   and i.revend is not null
   and s.id_engine_step = i.id_step_corrente
   and cs.id_cfg_step = s.id_cfg_step
   and pd.id_documento = :idDocumento
   and pd.rev <= i.revend and (pd.revend is null or pd.revend > i.revend)
   and pf.id_documento(+) = pd.id_documento
   and pf.rev <= i.revend and (pf.revend is null or pf.revend > i.revend)   
   and pf.codice = 'FILE_PRINCIPALE'
   and p.id_documento = pd.id_documento
   and p.rev = pd.rev
   and u.utente = s.utente_upd
   order by i.rev asc, pd.rev asc, pf.rev asc''', [idDocumento: idDocumento]).collect { GroovyRowResult row ->
            [DATA                    : ((TIMESTAMP) row.TIMESTAMP).timestampValue() // sempre grazie Oracle... vedi it.finmatica.protocollo.hibernate.SqlDateRevisionListener
             , NOMINATIVO_SOGGETTO   : row.NOMINATIVO_SOGGETTO
             , TITOLO_STEP           : row.TITOLO
             , NOTE                  : row.NOTE
             , FILE_REVISIONE_STORICO: row.REVISIONE_STORICO
             , ID_DOCUMENTO_ESTERNO  : row.ID_DOCUMENTO_ESTERNO
             , ID_FILE_DOCUMENTO     : row.ID_FILE_DOCUMENTO
             , ID_FILE_ESTERNO       : row.ID_FILE_ESTERNO
             , REVISIONE_STORICO     : row.REVISIONE_STORICO
             , NOME_FILE             : row.NOME_FILE]
        }
    }

    @Command
    void onDownloadFileStorico(@BindingParam("storico") Map storico) {
        fileDownloader.downloadFileStorico((long) storico.ID_DOCUMENTO_ESTERNO, (Long) storico.REVISIONE_STORICO, (String) storico.NOME_FILE, (long) storico.ID_FILE_ESTERNO)
    }
}
