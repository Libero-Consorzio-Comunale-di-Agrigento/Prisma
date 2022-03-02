package it.finmatica.protocollo.documenti.storico

import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import org.hibernate.envers.RevisionType
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

@VariableResolver(DelegatingVariableResolver)
class StoricoProtocolloEnversViewModel {

    private Long idDocumento

    @WireVariable
    private DataSource dataSource

    @WireVariable
    private ProtocolloFileDownloader fileDownloader

    private ProtocolloDTO protocollo

    Date ricercaDal
    Date ricercaAl

    def filtroSelezionato
    List filtri

    List<StoricoProtocolloViewModel.DatoStoricoTreeNode> datiStorici = []

    @Init
    void init(@ExecutionArgParam("idDocumento") Long idDocumento) {

        if (idDocumento != null) {
            if (this.idDocumento == null && idDocumento != null) {
                this.idDocumento = idDocumento
            }
            this.protocollo = Protocollo.get(this.idDocumento)?.toDTO()
        }

        filtroSelezionato = [codice: "_TUTTI", titolo: "-- Tutti i Campi --", descrizione: "Mostra tutti i campi", filtri: ["PROT_OGGETTO_MOD", "PROT_RISERVATO_MOD", "PROT_MOVIMENTO_MOD", "PROT_FILE_PRINCIPALE_TYPE", "ALLEGATO_TYPE", "FASCICOLO_MOD", "CLASSIFICAZIONE_MOD", "CORRISPONDENTE_TYPE"]]
        this.filtri = [filtroSelezionato]
        this.filtri.addAll([[codice: "DATI_DOCUMENTO", titolo: "Dati Documento", descrizione: "Dati principali del documento: oggetto, movimento, data", filtri: ["PROT_OGGETTO_MOD", "PROT_RISERVATO_MOD", "PROT_MOVIMENTO_MOD", "PROT_FILE_PRINCIPALE_TYPE", "ALLEGATO_TYPE"]]
                            , [codice: "DATI_FASCICOLAZIONE", titolo: "Dati Fascicolazione", descrizione: "Dati di classificazione e fascicolo", filtri: ["FASCICOLO_MOD", "CLASSIFICAZIONE_MOD"]]
                            , [codice: "DESTINATARI", titolo: "Destinatari", descrizione: "Dati dei destinatari", filtri: ["CORRISPONDENTE_TYPE"]]])
    }

    @NotifyChange("datiStorici")
    @GlobalCommand("onRefreshStoricoProtocollo")
    @Command
    void onRicerca(@BindingParam("idDocumento") Long idDocumento) {

        if (this.idDocumento == null && idDocumento != null) {
            this.idDocumento = idDocumento
        }
        this.protocollo = Protocollo.get(this.idDocumento)?.toDTO()

        datiStorici = ricercaDatiStorici()
    }

    List<DatoStoricoTreeNode> ricercaDatiStorici() {
        if (this.idDocumento == null || protocollo?.data == null) {
            return []
        }

        Date ricercaDal = this.ricercaDal ?: new Date(0, 01, 01)
        Date ricercaAl = this.ricercaAl ?: new Date(3000, 01, 01)

        List<GroovyRowResult> results = []

        Date dataDiProtocollazione = protocollo.data.clone()
        dataDiProtocollazione.clearTime()

        // se il documento è protocollato e l'utente non ha impostato una data di ricerca o l'ha impostata minore della data di protocollo, allora
        if (protocollo.data != null && (ricercaDal == dataDiProtocollazione || ricercaDal.before(dataDiProtocollazione))) {
            // ricerco i dati di protocollo
            results.addAll(getDatiProtocollazione(this.idDocumento))
        }

        // la data di ricerca minima è sempre la data di protocollazione
        if (!(ricercaDal.after(protocollo.data))) {
            ricercaDal = protocollo.data.clone()
        }

        results.addAll(cercaStorico(ricercaDal, ricercaAl))

        return creaTreeNode(results)
    }

    /**
     * Questa funzione deve ritornare una "fotografia" del documento al momento della protocollazione.
     * Questo perché l'esigenza è che nello storico vengano visualizzati "in cima" i dati relativi alla protocollazione (e non tutte le modifiche precedenti alla protocollazione)
     *
     * La query quindi opera con questo senso:
     * 1. devo ottenere la "fotografia" di quel documento ad una certa revisione.
     * 2. la revisione, è quella a cui il protocollo è stato numerato (quindi con numero_mod = 1)
     * 3. del documento e di tutti gli oggetti collegati quindi, devo filtrare quando rev < revisione_protocollo < nvl(revend, 99999999999)
     *
     * @param idDocumento
     * @return
     */
    private List<GroovyRowResult> getDatiProtocollazione(long idDocumento) {
        return new Sql(dataSource).rows('''
              SELECT (SELECT u.nominativo_soggetto
                        FROM AD4_V_UTENTI u
                       WHERE u.UTENTE =
                                NVL (
                                   pc.utente_upd,
                                   NVL (
                                      af.UTENTE_UPD,
                                      NVL (da.UTENTE_UPD,
                                           NVL (pf.UTENTE_UPD, pd.UTENTE_UPD)))))
                        UTENTE_MODIFICA,
                     p.data DATA_MODIFICA,
                     p.oggetto PROT_OGGETTO,
                     1 PROT_OGGETTO_MOD,
                     pd.riservato PROT_RISERVATO,
                     1 PROT_RISERVATO_MOD,
                     p.NUMERO PROT_NUMERO,
                     1 PROT_NUMERO_MOD,
                     p.ANNO PROT_ANNO,
                     1 PROT_ANNO_MOD,
                     (DECODE (p.id_classificazione, NULL, 0, 1)) CLASSIFICAZIONE_MOD,
                     (DECODE (p.id_fascicolo, NULL, 0, 1)) FASCICOLO_MOD,
                     p.movimento PROT_MOVIMENTO,
                     1 PROT_MOVIMENTO_MOD,
                     cla.DESCRIZIONE CLASS_DESCR,
                     cla.CLASSIFICAZIONE CLASS_COD,
                     ags_fascicoli_pkg.get_OGGETTO (p.id_fascicolo) FASC_OGGETTO,
                     ags_fascicoli_pkg.get_anno (p.id_fascicolo) FASC_ANNO,
                     ags_fascicoli_pkg.get_numero (p.id_fascicolo) FASC_NUMERO,
                     pf.nome PROT_FILE_PRINCIPALE,
                     pf.nome_MOD PROT_FILE_PRINCIPALE_MOD,
                     pf.ID_FILE_ESTERNO PROT_ID_FILE_ESTERNO,
                     pf.ID_FILE_ESTERNO_MOD PROT_ID_FILE_ESTERNO_MOD,
                     CASE
                        WHEN pf.REVTYPE = 2
                        THEN
                           (SELECT MAX (l.revisione_storico)
                              FROM gdo_file_documento_log l
                             WHERE     l.id_file_documento = pf.id_file_documento
                                   AND l.revtype IN (0, 1)
                                   AND l.revisione_storico IS NOT NULL)
                        ELSE
                           pf.revisione_storico
                     END
                        AS PROT_REVISIONE_STORICO -- siccome non sono riuscito a scrivere il numero di revisione nei record di log in caso di cancellazione del file, recupero il valore maggiore (cioè l'ultimo) che va bene lostesso.
                                                 ,
                     pf.DIMENSIONE_MOD PROT_REVISIONE_STORICO_MOD,
                     pd.ID_DOCUMENTO_ESTERNO PROT_ID_DOCUMENTO_ESTERNO,
                     1 PROT_FILE_PRINCIPALE_TYPE,
                     1 ALLEGATO_TYPE,
                     a.DESCRIZIONE ALLEGATO_DESCRIZIONE,
                     da.riservato ALLEGATO_RISERVATO,
                     1 ALLEGATO_RISERVATO_MOD,
                     1 ALLEGATO_FILE_TYPE,
                     case when  NVL (af.revend, 99999999999) > p.rev then   af.nome else to_char(null) end as ALLEGATO_FILE,
                     case when  NVL (af.revend, 99999999999) > p.rev then   af.ID_FILE_ESTERNO else to_number(null) end as ALLE_ID_FILE_ESTERNO, 
                     CASE
                        WHEN AF.REVTYPE = 2
                        THEN
                           (SELECT MAX (l.revisione_storico)
                              FROM gdo_file_documento_log l
                             WHERE     l.id_file_documento = af.id_file_documento
                                   AND l.revtype IN (0, 1)
                                   AND l.revisione_storico IS NOT NULL)
                        ELSE
                           af.revisione_storico
                     END
                        AS ALLE_REVISIONE_STORICO -- siccome non sono riuscito a scrivere il numero di revisione nei record di log in caso di cancellazione del file, recupero il valore maggiore (cioè l'ultimo) che va bene lostesso.
                                                 ,
                     da.ID_DOCUMENTO_ESTERNO ALLE_ID_DOCUMENTO_ESTERNO,
                     1 CORRISPONDENTE_TYPE,
                     pc.ID_PROTOCOLLO_CORRISPONDENTE,
                     pc.DENOMINAZIONE CORRISPONDENTE_NOME,
                     pc.INDIRIZZO CORRISPONDENTE_INDIRIZZO
                FROM agp_protocolli_log p,
                     gdo_documenti_log pd,
                     gdo_file_documento_log pf,
                     gdo_documenti_collegati_log c,
                     gdo_allegati_log a,
                     gdo_documenti_log da,
                     gdo_file_documento_log af,
                     agp_protocolli_corr_log pc,
                     ags_classificazioni cla
               WHERE     pd.id_documento = p.id_documento
                     AND pd.rev = p.rev
                     AND p.id_documento = :idDocumento
                     AND p.numero_mod = 1
                     AND cla.ID_CLASSIFICAZIONE(+) = p.ID_CLASSIFICAZIONE
                     AND (    pc.ID_DOCUMENTO(+) = pd.ID_DOCUMENTO
                          AND pc.rev(+) <= pd.rev
                          AND nvl(pc.revtype, 0) IN (0, 1)
                          AND NVL (pc.revend(+), 9999999999999999) > pd.rev)
                     AND (    pf.id_documento(+) = pd.id_documento
                          AND pf.codice(+) = 'FILE_PRINCIPALE\'
                          AND pf.rev(+) <= pd.rev             
                          AND nvl(pf.revtype, 0) IN (0, 1)
                          AND NVL (pf.revend(+), 9999999999999999) > pd.rev)
                     AND (    c.id_documento(+) = pd.id_documento
                          AND nvl(c.REVTYPE, 0) IN (0, 1)
                          AND c.rev(+) <= pd.rev
                          AND NVL (c.revend(+), 99999999) > pd.rev)
                     AND da.id_documento(+) = c.id_collegato
                     AND da.rev(+) <= c.rev
                     AND nvl(da.revtype, 0) IN (0, 1)
                     AND NVL (da.revend(+), 99999999999) > c.rev
                     AND a.id_documento(+) = da.id_documento
                     AND a.rev(+) = da.rev
                     AND af.id_documento(+) = da.id_documento
                     AND (   af.rev IS NULL
                          OR (af.rev <= p.rev))  
            ORDER BY pd.rev, c.rev, pc.rev''', [idDocumento: idDocumento])

        // tolto AND NVL (af.revend, 99999999999) > p.rev posso anche morire per questo che ho fatto
    }

    /**
     * Questa funzione ritorna tutte le modifiche fatte sul documento e su tutti gli oggetti collegati al documento in un certo range di date.
     *
     * Per ottenere questo, metto in join le varie tabelle su tutte le revisioni che hanno, alla fine, filtro per le date che mi interessano.
     * Ad es: rev >= protocollo_rev and rev < protocollo_revend, che significa: dammi tutte le variazioni del "figlio" per il tal periodo di validità del padre.
     *
     * @param ricercaDal
     * @param ricercaAl
     *
     * @return
     */
    private List<GroovyRowResult> cercaStorico(Date ricercaDal, Date ricercaAl) {
        // questa è la query che trova tutta la storia del documento e dei suoi figli.
        return new Sql(dataSource).rows('''select * from (select
       (select u.nominativo_soggetto from AD4_V_UTENTI u where u.UTENTE = nvl(pc.utente_upd, nvl(af.UTENTE_UPD, nvl(da.UTENTE_UPD, nvl(pf.UTENTE_UPD, pd.UTENTE_UPD))))) UTENTE_MODIFICA
     , (select max (r.revtstmp) from revinfo r where r.rev in (af.rev, pc.rev, da.rev , pf.rev, pd.rev)) DATA_MODIFICA
     , p.oggetto PROT_OGGETTO
     , p.oggetto_mod PROT_OGGETTO_MOD
     , pd.riservato PROT_RISERVATO
     , pd.riservato_mod PROT_RISERVATO_MOD
     , p.NUMERO PROT_NUMERO
     , p.NUMERO_MOD PROT_NUMERO_MOD
     , p.ANNO PROT_ANNO
     , p.ANNO_MOD PROT_ANNO_MOD
     , p.classificazione_mod CLASSIFICAZIONE_MOD
     , p.FASCICOLO_MOD FASCICOLO_MOD
     , p.movimento PROT_MOVIMENTO
     , p.movimento_MOD PROT_MOVIMENTO_MOD
     , cla.DESCRIZIONE CLASS_DESCR
     , cla.CLASSIFICAZIONE CLASS_COD
     , ags_fascicoli_pkg.get_OGGETTO(p.id_fascicolo) FASC_OGGETTO
     , ags_fascicoli_pkg.get_anno(p.id_fascicolo) FASC_ANNO
     , ags_fascicoli_pkg.get_numero(p.id_fascicolo) FASC_NUMERO
     , pf.nome PROT_FILE_PRINCIPALE
     , pf.nome_MOD PROT_FILE_PRINCIPALE_MOD
     , pf.ID_FILE_ESTERNO PROT_ID_FILE_ESTERNO
     , pf.ID_FILE_ESTERNO_MOD PROT_ID_FILE_ESTERNO_MOD
     --, pf.REVISIONE_STORICO PROT_REVISIONE_STORICO
     , case when pf.REVTYPE = 2 then (select max(l.revisione_storico) 
                                        from gdo_file_documento_log l 
                                       where l.id_file_documento = pf.id_file_documento 
                                         and l.revtype in (0, 1) 
                                         and l.revisione_storico is not null) 
                                else pf.revisione_storico 
       end as PROT_REVISIONE_STORICO -- siccome non sono riuscito a scrivere il numero di revisione nei record di log in caso di cancellazione del file, recupero il valore maggiore (cioè l'ultimo) che va bene lostesso.
     , pf.DIMENSIONE_MOD PROT_REVISIONE_STORICO_MOD
     , pd.ID_DOCUMENTO_ESTERNO PROT_ID_DOCUMENTO_ESTERNO
     , pf.revtype PROT_FILE_PRINCIPALE_TYPE
     , decode(da.valido, 'N', 2, da.REVTYPE) ALLEGATO_TYPE
     , a.DESCRIZIONE ALLEGATO_DESCRIZIONE
     , da.riservato ALLEGATO_RISERVATO
     , da.riservato_mod ALLEGATO_RISERVATO_MOD
     , af.revtype ALLEGATO_FILE_TYPE
     , af.nome ALLEGATO_FILE
     , af.ID_FILE_ESTERNO ALLE_ID_FILE_ESTERNO
     , case when AF.REVTYPE = 2 then (select max(l.revisione_storico) 
                                        from gdo_file_documento_log l 
                                       where l.id_file_documento = af.id_file_documento 
                                         and l.revtype in (0, 1) 
                                         and l.revisione_storico is not null) 
                                else af.revisione_storico 
       end as ALLE_REVISIONE_STORICO -- siccome non sono riuscito a scrivere il numero di revisione nei record di log in caso di cancellazione del file, recupero il valore maggiore (cioè l'ultimo) che va bene lostesso.
     , da.ID_DOCUMENTO_ESTERNO ALLE_ID_DOCUMENTO_ESTERNO
     , pc.ID_PROTOCOLLO_CORRISPONDENTE
     , pc.REVTYPE CORRISPONDENTE_TYPE
     , pc.DENOMINAZIONE CORRISPONDENTE_NOME
     , pc.INDIRIZZO CORRISPONDENTE_INDIRIZZO     
   from agp_protocolli_log p
      , gdo_documenti_log pd
      , gdo_file_documento_log pf
      , gdo_documenti_collegati_log c
      , gdo_allegati_log a
      , gdo_documenti_log da
      , gdo_file_documento_log af
      , agp_protocolli_corr_log pc
      , ags_classificazioni cla
  where pd.id_documento = p.id_documento
    and pd.rev = p.rev
    and p.id_documento = :idDocumento
    and cla.ID_CLASSIFICAZIONE(+) = p.ID_CLASSIFICAZIONE
    and pc.ID_DOCUMENTO(+) = pd.ID_DOCUMENTO
    and pc.rev(+) >= pd.rev and pc.rev(+) < nvl(pd.revend, 99999999999)
    and pf.id_documento(+) = pd.id_documento
    and pf.rev(+) >= pd.rev and pf.rev(+) < nvl(pd.revend, 99999999999)
    and pf.codice(+) = 'FILE_PRINCIPALE'
    and c.id_documento(+) = pd.id_documento
    and c.rev(+) >= pd.rev and c.rev(+) < nvl(pd.revend, 99999999999)
    and a.id_documento(+) = c.id_collegato
    and a.rev(+) >= c.rev and a.rev(+) < nvl(c.revend, 99999999999)
    and da.id_documento(+) = a.id_documento
    and da.rev(+) = a.rev
    and af.id_documento(+) = da.id_documento
    and af.rev(+) >= da.rev and af.rev(+) < nvl(da.revend, 99999999999)
    order by DATA_MODIFICA) 
  where DATA_MODIFICA > :dataDal
    and trunc(DATA_MODIFICA) <= trunc(:dataAl)
    ''', [idDocumento: idDocumento,
          dataDal    : new java.sql.Timestamp(ricercaDal.time),
          dataAl     : new java.sql.Timestamp(ricercaAl.time)])
    }

    @Command
    void onDownloadFileStorico(@BindingParam("storico") DatoStoricoTreeNode storico) {
        fileDownloader.downloadFileStorico(storico.idDocumentoEsterno, storico.revisioneFile, storico.valore, storico.idFileEsterno)
    }

    private List<DatoStoricoTreeNode> creaTreeNode(List<GroovyRowResult> datiStorici) {
        // utilizzo un LinkedHashSet per due motivi:
        // 1. Elimina automaticamente i record duplicati (derivati ad es da join su allegati o sui corrispondenti)
        // 2. Mantiene l'ordine dei record inseriti (come una lista)
        List<DatoStoricoTreeNode> treeNodes = []
        for (GroovyRowResult datoStorico : datiStorici) {
            List<DatoStoricoTreeNode> dati = parseDatiStorici(datoStorico)
            for (DatoStoricoTreeNode dato : dati) {
                if (!treeNodes.contains(dato)) {
                    treeNodes.add(dato)
                }
            }
        }

        return treeNodes
    }

    /**
     * questa funzione aggiunge alla maschera i vari dati ottenuti dalla query.
     * @param result
     * @return
     */
    private List<DatoStoricoTreeNode> parseDatiStorici(GroovyRowResult result) {
        List<DatoStoricoTreeNode> datiStorici = []

        // campi del protocollo:
        if (filtroSelezionato.filtri.contains("PROT_OGGETTO_MOD") && result.PROT_OGGETTO_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Oggetto', result.PROT_OGGETTO)
        }

        if (filtroSelezionato.filtri.contains("PROT_RISERVATO_MOD") && result.PROT_RISERVATO_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Riservato', (result.PROT_RISERVATO == 'Y') ? 'Si' : 'No')
        }

        if (filtroSelezionato.filtri.contains("PROT_MOVIMENTO_MOD") && result.PROT_MOVIMENTO_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Movimento', result.PROT_MOVIMENTO)
        }

        if (filtroSelezionato.filtri.contains("CLASSIFICAZIONE_MOD") && result.CLASSIFICAZIONE_MOD > 0) {
            if (result.CLASS_COD == null) {
                datiStorici << new DatoStoricoTreeNode(RevisionType.DEL, 'Classificazione', "Rimossa Classificazione")
            } else {
                datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Classificazione', "${result.CLASS_COD} - ${result.CLASS_DESCR}")
            }
        }

        if (filtroSelezionato.filtri.contains("FASCICOLO_MOD") && result.FASCICOLO_MOD > 0) {
            if (result.FASC_NUMERO == null) {
                datiStorici << new DatoStoricoTreeNode(RevisionType.DEL, 'Fascicolo', "Rimosso Fascicolo")
            } else {
                datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Fascicolo', "${result.FASC_ANNO} / ${result.FASC_NUMERO} - ${result.FASC_OGGETTO}")
            }
        }

        if (filtroSelezionato.filtri.contains("PROT_FILE_PRINCIPALE_TYPE") && result.PROT_FILE_PRINCIPALE_TYPE >= 0) {
            // se ho solo rinominato il file, mostro una riga diversa
            if (result.PROT_FILE_PRINCIPALE_MOD == 1 && result.PROT_REVISIONE_STORICO_MOD == 0) {
                datiStorici << new DatoStoricoTreeNode(result.PROT_ID_FILE_ESTERNO, result.PROT_REVISIONE_STORICO, result.PROT_ID_DOCUMENTO_ESTERNO, getRevisionType(result.PROT_FILE_PRINCIPALE_TYPE), 'File Principale (Rinominato)', result.PROT_FILE_PRINCIPALE)
            } else {
                datiStorici << new DatoStoricoTreeNode(result.PROT_ID_FILE_ESTERNO, result.PROT_REVISIONE_STORICO, result.PROT_ID_DOCUMENTO_ESTERNO, getRevisionType(result.PROT_FILE_PRINCIPALE_TYPE), 'File Principale', result.PROT_FILE_PRINCIPALE)
            }
        }

        // corrispondenti:
        if (filtroSelezionato.filtri.contains("CORRISPONDENTE_TYPE") && result.CORRISPONDENTE_TYPE >= 0 && result.ID_PROTOCOLLO_CORRISPONDENTE > 0) {
            datiStorici << new DatoStoricoTreeNode(getRevisionType(result.CORRISPONDENTE_TYPE), 'Corrispondente', result.CORRISPONDENTE_NOME, result.ID_PROTOCOLLO_CORRISPONDENTE)
        }

        // campi dell'allegato
        if (filtroSelezionato.filtri.contains("ALLEGATO_TYPE") && result.ALLEGATO_TYPE >= 0 && result.ALLE_ID_DOCUMENTO_ESTERNO > 0 && result.ALLEGATO_FILE != null) {
            boolean isCC = result.ALLEGATO_FILE?.startsWith("CC_")
            if (!isCC) {
                datiStorici << new DatoStoricoTreeNode(getRevisionType(result.ALLEGATO_TYPE), 'Allegato', result.ALLEGATO_DESCRIZIONE, result.ALLE_ID_DOCUMENTO_ESTERNO)
            }

            if (result.ALLEGATO_RISERVATO_MOD) {
                datiStorici << new DatoStoricoTreeNode(getRevisionType(result.ALLEGATO_TYPE), 'Riservato', result.ALLEGATO_RISERVATO, result.ALLE_ID_DOCUMENTO_ESTERNO)
            }

            if (result.ALLEGATO_FILE_TYPE >= 0 && !isCC) {
                datiStorici << new DatoStoricoTreeNode(result.ALLE_ID_FILE_ESTERNO, result.ALLE_REVISIONE_STORICO, result.ALLE_ID_DOCUMENTO_ESTERNO, getRevisionType(result.ALLEGATO_FILE_TYPE), 'File', result.ALLEGATO_FILE)
            }
        }

        if (datiStorici.size() > 0) {
            datiStorici[0].dataModifica = result.DATA_MODIFICA.timestampValue()
            datiStorici[0].nominativoUtente = result.UTENTE_MODIFICA
        }

        return datiStorici
    }

    private static RevisionType getRevisionType(BigDecimal revType) {
        switch (revType.intValue()) {
            case RevisionType.ADD.ordinal():
                return RevisionType.ADD
            case RevisionType.MOD.ordinal():
                return RevisionType.MOD
            case RevisionType.DEL.ordinal():
                return RevisionType.DEL
        }
        return null
    }

    static class DatoStoricoTreeNode {

        private Date dataModifica
        private String nominativoUtente
        private final RevisionType tipoModifica
        private final String descrizioneCampo
        private final String valore
        private final Long idFileEsterno
        private final Long revisioneFile
        private final Long idDocumentoEsterno

        DatoStoricoTreeNode(BigDecimal idFileEsterno, BigDecimal revisioneFile, BigDecimal idDocumentoEsterno, RevisionType tipoModifica, String descrizioneCampo, String valore) {
            this.idDocumentoEsterno = idDocumentoEsterno?.toLong()
            this.idFileEsterno = idFileEsterno?.toLong()
            this.revisioneFile = revisioneFile?.toLong()
            this.tipoModifica = tipoModifica
            this.descrizioneCampo = descrizioneCampo
            this.valore = valore
        }

        DatoStoricoTreeNode(RevisionType tipoModifica, String descrizioneCampo, String valore) {
            this(null, null, null, tipoModifica, descrizioneCampo, valore)
        }

        DatoStoricoTreeNode(RevisionType tipoModifica, String descrizioneCampo, String valore, BigDecimal idDocumentoEsterno) {
            this(null, null, idDocumentoEsterno, tipoModifica, descrizioneCampo, valore)
        }

        void setDataModifica(Date dataModifica) {
            this.dataModifica = dataModifica
        }

        void setNominativoUtente(String nominativoUtente) {
            this.nominativoUtente = nominativoUtente
        }

        Date getDataModifica() {
            return dataModifica
        }

        String getNominativoUtente() {
            return nominativoUtente
        }

        RevisionType getTipoModifica() {
            return tipoModifica
        }

        String getTipoStorico() {
            switch (tipoModifica) {
                case RevisionType.ADD:
                    return 'AGGIUNTO'
                case RevisionType.MOD:
                    return 'MODIFICATO'
                case RevisionType.DEL:
                    return 'CANCELLATO'
            }
        }

        String getDescrizioneCampo() {
            return descrizioneCampo
        }

        String getValore() {
            return valore
        }

        Long getIdFileEsterno() {
            return idFileEsterno
        }

        Long getRevisioneFile() {
            return revisioneFile
        }

        Long getIdDocumentoEsterno() {
            return idDocumentoEsterno
        }

        boolean equals(Object o) {
            if (!(o instanceof DatoStoricoTreeNode)) {
                return false
            }
            DatoStoricoTreeNode o1 = (DatoStoricoTreeNode) o

            return (this.dataModifica == o1.dataModifica &&
                    this.nominativoUtente == o1.nominativoUtente &&
                    this.tipoModifica == o1.tipoModifica &&
                    this.descrizioneCampo == o1.descrizioneCampo &&
                    this.valore == o1.valore &&
                    this.idFileEsterno == o1.idFileEsterno &&
                    this.revisioneFile == o1.revisioneFile &&
                    this.idDocumentoEsterno == o1.idDocumentoEsterno)
        }
    }
}
