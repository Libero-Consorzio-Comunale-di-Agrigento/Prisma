package it.finmatica.protocollo.admin

import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.impostazioni.Impostazione
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenza
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.jobs.TrascodificaStoricoTask
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.beans.factory.annotation.Value
import org.springframework.transaction.annotation.Transactional
import org.springframework.stereotype.Service

import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.Impostazione
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzioneService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.gestioneiter.serializer.WkfCfgIterXMLSerializer
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenza
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.gestionetesti.reporter.GestioneTestiTipoModello
import it.finmatica.protocollo.documenti.CampiProtettiAction
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloRepository
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.jobs.TrascodificaStoricoTask
import org.apache.commons.io.FilenameUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.servlet.ServletContext
import javax.sql.DataSource

@Slf4j
@Service
@Transactional
class AggiornamentoService {

    private static final String PATH_CONFIGURAZIONE_STANDARD = "WEB-INF/configurazioneStandard"
    private static final String PATH_CONFIGURAZIONE_MODELLI_TESTO = "${PATH_CONFIGURAZIONE_STANDARD}/modelliTesto"

    @Autowired
    WkfCfgIterXMLSerializer wkfCfgIterXMLSerializer
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    CampiProtettiAction campiProtettiAction
    @Autowired
    WkfAzioneService wkfAzioneService
    @Autowired
    TipoProtocolloRepository tipoProtocolloRepository
    @Autowired
    ServletContext servletContext
    @Autowired
    DataSource dataSource
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Qualifier("dataSource_jwf")
    @Autowired
    DataSource dataSource_jwf
    @Autowired
    TrascodificaStoricoTask trascodificaStoricoTask

    void trascodificaStorico() {

        //I seguenti aggiornamenti devono essere fatti solo al primo avvio del contesto, ovvero se AGGIORNAMENTO_TERMINATO vale N
        //al termine degli aggiornamenti l'impostazione dovrà assumere valore Y
        if(!Impostazioni.AGGIORNAMENTO_TERMINATO.abilitato) {

            trascodificaStoricoTask.trascodificaStorico()

            Impostazione aggiornamentoTerminato = Impostazione.getImpostazione(Impostazioni.AGGIORNAMENTO_TERMINATO.toString(), springSecurityService.getPrincipal().getEnte()).get()
            if (aggiornamentoTerminato != null) {
                aggiornamentoTerminato.valore  = "Y"
                aggiornamentoTerminato.save()
            }
        }
    }

    void aggiornaDizionari() {

        aggiornaTipiModelloTesto()
        installaModelliTesto("odt")
        installaModelliTesto("doc")
        installaModelliTesto("docx")

        installaConfigurazioniIter()
        aggiornaAzioni()
    }

    void attivaDisattivaIntegrazioneSmartDesktop(String attiva) {
        String gdmUsername, jwfUsername

        Sql sql = new Sql(dataSource)
        sql.eachRow("select user_oracle from ad4_istanze where  istanza='GDM'") { row ->
            gdmUsername = "$row.user_oracle"
        }
        sql.eachRow("select user_oracle from ad4_istanze where  istanza='JWFWEB'") { row ->
            jwfUsername = "$row.user_oracle"
        }

        Sql sqlJwf = new Sql(dataSource_jwf)
        Sql sqlGdm = new Sql(dataSource_gdm)

        if (attiva.equals("Y")) {
            sqlJwf.call("BEGIN EXECUTE IMMEDIATE 'GRANT EXECUTE ON WORKLIST_SERVICES TO " + gdmUsername + "'; END;")
            sqlGdm.call("BEGIN EXECUTE IMMEDIATE 'CREATE OR REPLACE SYNONYM JWF_WORKLIST_SERVICES FOR " + jwfUsername + ".WORKLIST_SERVICES'; END;")
        } else {
            sqlJwf.call("BEGIN EXECUTE IMMEDIATE 'REVOKE EXECUTE ON WORKLIST_SERVICES FROM " + gdmUsername + "'; EXCEPTION WHEN OTHERS THEN NULL; END;")
            sqlGdm.call("BEGIN EXECUTE IMMEDIATE 'DROP SYNONYM JWF_WORKLIST_SERVICES'; EXCEPTION WHEN OTHERS THEN NULL; END;")
        }
    }

    private void installaConfigurazioniIter() {
        log.debug("installo le configurazioni iter")
        if (WkfTipoOggetto.list().size() == 0) {
            new WkfTipoOggetto(codice: Protocollo.TIPO_DOCUMENTO, nome: "Protocollo", descrizione: "Documento di Protocollo", iterabile: true, valido: true, oggettiFigli: "").save()
        }

        // eseguo solo se non ho iter configurati:
        File configurazioneDir = new File(servletContext.getRealPath(PATH_CONFIGURAZIONE_STANDARD), "flussi");
        if (!configurazioneDir.exists()) {
            return
        }

        configurazioneDir.eachFile({ File file ->
            log.debug("installo la configurazione: ${file}")

            String nomeFlusso = FilenameUtils.removeExtension(file.name);
            // se esiste già un flusso con questo nome, non lo ricreo.
            if (WkfCfgIter.countByNome(nomeFlusso) > 0) {
                return
            }

            String xml = file.getText()
            WkfCfgIter cfgIter = wkfCfgIterXMLSerializer.importFromXml(xml, -1)
            cfgIter.stato = WkfCfgIter.STATO_IN_USO
            cfgIter.save()
        })

        List<TipoProtocollo> tipiDaNonProt = tipoProtocolloRepository.findAllByCategoriaAndValidoAndProgressivoCfgIterIsNull(CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice)
        for(TipoProtocollo t : tipiDaNonProt){
           t.progressivoCfgIter = WkfCfgIter.findByNome("STANDARD - DA_NON_PROTOCOLLARE - Base").progressivo
           t.save()
        }
        List<TipoProtocollo> tipiPec = tipoProtocolloRepository.findAllByCategoriaAndValidoAndProgressivoCfgIterIsNull(CategoriaProtocollo.CATEGORIA_PEC.codice)
        for(TipoProtocollo t : tipiPec){
            t.progressivoCfgIter = WkfCfgIter.findByNome("STANDARD - PROTOCOLLO - Da Pec").progressivo
            t.save()
        }
        List<TipoProtocollo> tipiP = tipoProtocolloRepository.findAllByCategoriaAndValidoAndProgressivoCfgIterIsNull(CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codice)
        for(TipoProtocollo t : tipiP){
            t.progressivoCfgIter = WkfCfgIter.findByNome("STANDARD - PROTOCOLLO - Manuale").progressivo
            t.save()
        }
        List<TipoProtocollo> tipiProvv = tipoProtocolloRepository.findAllByCategoriaAndValidoAndProgressivoCfgIterIsNull(CategoriaProtocollo.CATEGORIA_PROVVEDIMENTO.codice)
        for(TipoProtocollo t : tipiProvv){
            t.progressivoCfgIter = WkfCfgIter.findByNome("STANDARD - PROVVEDIMENTO - Firma e Protocolla").progressivo
            t.save()
        }
    }

    private void installaModelliTesto(String formato) {
        log.debug("installo i modelli testo")
        File modelliTestoDir = new File(servletContext.getRealPath(PATH_CONFIGURAZIONE_MODELLI_TESTO), formato)
        if (!modelliTestoDir.exists()) {
            return
        }

        modelliTestoDir.eachFile { File file ->
            log.debug("installo il modello testo: ${file}")
            String codiceTipoModello = file.name.substring(0, file.name.indexOf("."))
            String titolo = file.name.substring(file.name.indexOf(".") + 1, file.name.lastIndexOf("."))
            String tipo = file.name.substring(file.name.lastIndexOf(".") + 1)

            // se il modello testo è già presente, non lo sovrascrivo
            GestioneTestiModello modello = GestioneTestiModello.findByNomeAndTipoModelloAndTipo(titolo, GestioneTestiTipoModello.get(codiceTipoModello), formato)
            if (modello != null) { // && !modello.nome.startsWith("STANDARD")) {
                return null
            }

            if (modello == null) {
                modello = new GestioneTestiModello(nome: titolo, tipoModello: GestioneTestiTipoModello.get(codiceTipoModello))
                modello.tipo = tipo
                modello.descrizione = "${titolo}, tipo: ${tipo}"
                modello.valido = true
                modello.validoAl = null
                modello.fileTemplate = file.getBytes()
                modello.save()
                new GestioneTestiModelloCompetenza(gestioneTestiModello: modello
                        , lettura: true
                        , modifica: true
                        , descrizione: "Visibile a Tutti"
                        , ruoloAd4: Ad4Ruolo.get(ImpostazioniProtocollo.RUOLO_ACCESSO_APPLICATIVO.valore)).save()
            }
        }
    }

    private void aggiornaTipiModelloTesto() {
        log.debug("aggiorno i tipi modelli testo:")
        //Chiamando il metodo dalla pagina di admin contexservlet risulta null, se richiamato con il getServletContext, invece, viene valorizzato.
        File modelliTestoDir = new File(getServletContext().getRealPath(PATH_CONFIGURAZIONE_MODELLI_TESTO), "xml")
        modelliTestoDir.eachFile { file ->
            log.debug("aggiorno il tipo modello: ${file}")

            String codiceTipoModello = file.name.substring(0, file.name.length() - 4)
            String descrizione = new XmlSlurper().parse(file).descrizione.text()

            GestioneTestiTipoModello tipoModello = GestioneTestiTipoModello.get(codiceTipoModello) ?: new GestioneTestiTipoModello(codice: codiceTipoModello)
            tipoModello.descrizione = descrizione
            tipoModello.query = file.getBytes()
            tipoModello.save()
        }
    }

    void aggiornaAzioni() {
        log.debug("Aggiorno le azioni")
        // per prima cosa valido le azioni così poi quando ricreo quelle "fittizie" le rimetto a Y.
        wkfAzioneService.validaAzioni()

        // aggiorno le azioni dei blocchi:
        campiProtettiAction.aggiornaAzioni()

        // aggiorno le azioni:
        wkfAzioneService.aggiornaAzioni()
    }

    def getAzioniVecchie() {
        Sql sql = new Sql(dataSource)
        def azioniVecchie = []
        sql.eachRow("""select distinct a.id_azione as id_azione, a.tipo_oggetto, a.nome as nome, a.descrizione, a.categoria, a.nome_bean, a.nome_metodo, pa.id_pulsante, sai.id_cfg_step step_azione_in, s.id_cfg_step step_condizione
  from wkf_diz_azioni a
     , wkf_diz_pulsanti_azioni pa
     , wkf_cfg_step_azioni_in sai
     , wkf_cfg_step s
     , wkf_diz_pulsanti p
     , wkf_diz_attori att
 where a.valido = 'N'
   and pa.id_azione(+) = a.id_azione
   and sai.id_azione_in(+) = a.id_azione
   and s.id_azione_condizione(+) = a.id_azione
   and p.id_condizione_visibilita(+) = a.id_azione
   and att.id_azione_calcolo(+) = a.id_azione
   and (sai.id_cfg_step is not null
   or pa.id_pulsante is not null
   or s.id_cfg_step is not null
   or p.id_condizione_visibilita is not null
   or att.id_azione_calcolo is not null)""") { row ->
            azioniVecchie << [nome: "${row.tipo_oggetto} | ${row.nome_bean}.${row.nome_metodo}() >> " + row.nome + ": " + row.descrizione, id: row.id_azione]
        }

        return azioniVecchie
    }

    def sostituisciVecchieAzioniConNuove(List<Long> azioniVecchie, Long azioneNuova) {
//       def azioniVecchie = null
//        if (params.azioneVecchia instanceof String) {
//            azioniVecchie = []
//            azioniVecchie << params.long("azioneVecchia")
//        } else {
//            azioniVecchie = params.azioneVecchia.collect { Long.parseLong(it) }
//        }
//        long azioneNuova = params.azioneNuova

        if (null != azioneNuova) {

            Sql sql = new Sql(dataSource)
            for (long idAzioneVecchia : azioniVecchie) {
                if (azioneNuova < 0) {
                    // elimino le azioni
                    sql.executeUpdate("delete from wkf_diz_pulsanti_azioni where id_azione 	= ?", idAzioneVecchia)
                    sql.executeUpdate("delete from wkf_cfg_step_azioni_in  where id_azione_in	= ?", idAzioneVecchia)
                    sql.executeUpdate("delete from wkf_cfg_step_azioni_out where id_azione_out = ?", idAzioneVecchia)

                    // correggo le sequenze:
                    sql.call("""begin
for c in (
 SELECT pa.id_pulsante, pa.id_azione,
            (ROW_NUMBER ()
            OVER (
               PARTITION BY pa.id_pulsante
               ORDER BY pa.id_pulsante, pa.azioni_idx ASC))-1
           sequenza, pa.azioni_idx
   FROM wkf_diz_pulsanti_azioni pa
ORDER BY pa.id_pulsante)
loop
    update wkf_diz_pulsanti_azioni pa set pa.azioni_idx = c.sequenza where pa.id_pulsante = c.id_pulsante and pa.id_azione = c.id_azione;
    commit;
end loop;

for c in (
 SELECT pa.id_cfg_step, pa.id_azione_in,
            (ROW_NUMBER ()
            OVER (
               PARTITION BY pa.id_cfg_step
               ORDER BY pa.id_cfg_step, pa.azioni_ingresso_idx ASC))-1
           sequenza, pa.azioni_ingresso_idx
   FROM wkf_cfg_step_azioni_in pa
ORDER BY pa.id_cfg_step)
loop
    update wkf_cfg_step_azioni_in pa set pa.azioni_ingresso_idx = c.sequenza where pa.id_cfg_step = c.id_cfg_step and pa.id_azione_in = c.id_azione_in;
    commit;
end loop;

for c in (
 SELECT pa.id_cfg_step, pa.id_azione_out,
            (ROW_NUMBER ()
            OVER (
               PARTITION BY pa.id_cfg_step
               ORDER BY pa.id_cfg_step, pa.azioni_uscita_idx ASC))-1
           sequenza, pa.azioni_uscita_idx
   FROM wkf_cfg_step_azioni_out pa
ORDER BY pa.id_cfg_step)
loop
    update wkf_cfg_step_azioni_out pa set pa.azioni_uscita_idx = c.sequenza where pa.id_cfg_step = c.id_cfg_step and pa.id_azione_out = c.id_azione_out;
    commit;
end loop;

end;""")
                    // elimino le azioni "singole"
                    sql.executeUpdate("update wkf_cfg_step 		   set id_azione_condizione 	= null where id_azione_condizione 		= ?", idAzioneVecchia)
                    sql.executeUpdate("update wkf_diz_pulsanti		   set id_condizione_visibilita = null where id_condizione_visibilita 	= ?", idAzioneVecchia)
                    sql.executeUpdate("update wkf_diz_attori		   set id_azione_calcolo		= null where id_azione_calcolo 			= ?", idAzioneVecchia)
                } else {
                    sql.executeUpdate("update wkf_diz_pulsanti_azioni set id_azione 				= ? where id_azione 				= ?", azioneNuova, idAzioneVecchia)
                    sql.executeUpdate("update wkf_cfg_step_azioni_in  set id_azione_in 			= ? where id_azione_in				= ?", azioneNuova, idAzioneVecchia)
                    sql.executeUpdate("update wkf_cfg_step_azioni_out set id_azione_out			= ? where id_azione_out 			= ?", azioneNuova, idAzioneVecchia)
                    sql.executeUpdate("update wkf_cfg_step 		   set id_azione_condizione 	= ? where id_azione_condizione 		= ?", azioneNuova, idAzioneVecchia)
                    sql.executeUpdate("update wkf_diz_pulsanti		   set id_condizione_visibilita = ? where id_condizione_visibilita 	= ?", azioneNuova, idAzioneVecchia)
                    sql.executeUpdate("update wkf_diz_attori		   set id_azione_calcolo		= ? where id_azione_calcolo 		= ?", azioneNuova, idAzioneVecchia)
                }
            }
        }
    }

    def eliminaAzioni() {
        Sql sql = new Sql(dataSource)
        sql.executeUpdate("delete from wkf_diz_azioni_parametri p where exists(select * from wkf_diz_azioni a where p.id_azione = a.id_azione and valido = 'N')")
        sql.executeUpdate("delete from wkf_diz_azioni where valido = 'N'")
    }
}