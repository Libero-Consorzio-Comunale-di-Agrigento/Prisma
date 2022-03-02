package it.finmatica.protocollo.documenti

import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.storico.DatoStorico
import it.finmatica.gestionedocumenti.storico.DatoStorico.TipoStorico
import it.finmatica.gestionedocumenti.storico.DocumentoStoricoRepository
import it.finmatica.gestionedocumenti.storico.DocumentoStoricoService
import it.finmatica.gestioneiter.motore.WkfStep
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

@Transactional(readOnly = true)
@Service
@CompileStatic
class ProtocolloStoricoService {

    private final DocumentoStoricoRepository documentoStoricoRepository
    private final DocumentoStoricoService documentoStoricoService
    private final ProtocolloRepository protocolloRepository
    private final DocumentaleService documentaleService
    private final DateService dateService

    @Autowired DataSource dataSource

    ProtocolloStoricoService(DocumentoStoricoService documentoStoricoService, ProtocolloRepository protocolloRepository, DocumentoStoricoRepository documentoStoricoRepository, DocumentaleService documentaleService, DateService dateService) {
        this.documentoStoricoService = documentoStoricoService
        this.protocolloRepository = protocolloRepository
        this.documentoStoricoRepository = documentoStoricoRepository
        this.documentaleService = documentaleService
        this.dateService = dateService
    }

    @CompileDynamic
    void storicizza(Protocollo protocollo, WkfStep stepCorrente = null, boolean logSoloModificati = true, Date dataAggiornamento = null) {
        documentoStoricoService.storicizza(protocollo, {
            oggetto(_key: protocollo.oggetto, _value: protocollo.oggetto, _dataModifica: protocollo.data)
            movimento(_key: protocollo.movimento, _value: protocollo.movimento, _dataModifica: protocollo.data)
            numero(_key: protocollo.numero, _value: protocollo.numero, _dataModifica: protocollo.data)

            // l'id step serve perché quando devo mostrare le notifiche di trasmissione devo controllare che l'utente collegato sia un attore del nodo
            if (stepCorrente != null) {
                step(_key: stepCorrente.id, _value: stepCorrente.cfgStep.titolo, _dataModifica: dateService.getCurrentDate())
                note(protocollo.note ?: "")
                noteTrasmissione(protocollo.noteTrasmissione ?: "")
            }

            // Quando sarà necessario bisognerà inserire come campo l'hash su GDM del file e togliere la _dataModifica che permette oggi di salvare sempre la riga dello storico
            List<FileDocumento> fileDocumenti = protocollo.fileDocumenti
            if (fileDocumenti?.size() > 0) {
                FileDocumento fileTestoPrincipale = fileDocumenti?.first()
                if (fileTestoPrincipale?.idFileEsterno > 0) {
                    Date dataModifica = dateService.getCurrentDate()
                    if (protocollo.data != null && fileTestoPrincipale.firmato) {
                        dataModifica = protocollo.data
                    }
                    testoPrincipale(_key: fileTestoPrincipale.id, _value: fileTestoPrincipale.nome,
                            _idFileEsterno: fileTestoPrincipale.idFileEsterno,
                            _idDocumentoEsterno: protocollo.idDocumentoEsterno,
                            _dataModifica: dataModifica, _hash: this.getHashFile(protocollo, fileTestoPrincipale))
                }
            }

            Fascicolo f = protocollo.fascicolo
            if (f != null) {
                fascicolo(_key: f.id, _value: (f.annoNumero + " - " + f.oggetto), _oggetto: f.oggetto, _dataModifica: protocollo.data)
            }

            Classificazione c = protocollo.classificazione
            if (c != null) {
                classificazione(_key: c.id, _value: (c.codice + " - " + c.descrizione), _codice: c.codice, _descrizione: c.descrizione, _dataModifica: protocollo.data)
            }

            if (protocollo.corrispondenti != null) {
                // dovrebbe essere "corrispondenti" non destinatari
                destinatari(protocollo.corrispondenti, { Corrispondente corrispondente ->
                    _key(corrispondente.id)
                    _value(corrispondente.denominazione ?: "")
                    _dataModifica(protocollo.data)

                    // aggiungo i nuovi campi da mostrare nella stampa dello storico
                    email(corrispondente.email ?: "")
                    indirizzo(corrispondente.indirizzo ?: "")
                    codiceFiscale(corrispondente.codiceFiscale ?: "")
                })
            }

            allegati(protocollo.getAllegati(), { Allegato allegato ->
                _key(allegato.id)
                _value(allegato.descrizione)
                _dataModifica(protocollo.data)
                riservato(allegato.riservato ? "Si" : "No")

                if (allegato.fileDocumenti) {
                    Documento allegatoEsterno = this.getDocumentoEsterno(allegato)

                    file(allegato.fileDocumenti, { FileDocumento file ->
                        if (!file.fileOriginale) {
                            _key(file.id)
                            _value(file.nome)
                            _dataProtocollo(protocollo.data)
                            _dataModifica(file.lastUpdated)
                            _idFileEsterno(file.idFileEsterno)
                            _idDocumentoEsterno(allegato.idDocumentoEsterno)
                            _hash(this.getHashFile(allegatoEsterno, file))
                        }
                    })
                }
            })
        }, logSoloModificati, dataAggiornamento)
    }

    DatoStorico getUltimaVersione(Protocollo protocollo) {
        return documentoStoricoService.getUltimaRevisione(protocollo)
    }

    private String getHashFile(it.finmatica.gestionedocumenti.documenti.Documento documentoOriginale, FileDocumento fileDocumento) {
        return getHashFile(getDocumentoEsterno(documentoOriginale), fileDocumento)
    }

    private String getHashFile(Documento documentoEsterno, FileDocumento fileDocumento) {
        if (fileDocumento == null) {
            return null
        }

        File file = documentoEsterno.getFiles().find { fileDocumento.idFileEsterno.toString().equalsIgnoreCase(it.id) }
        if (file == null) {
            return null
        }
        return file.getHash().getHash()
    }

    private Documento getDocumentoEsterno(it.finmatica.gestionedocumenti.documenti.Documento documentoOriginale) {
        Documento documento = new Documento()
        documento.setId(documentoOriginale.idDocumentoEsterno.toString())
        documento.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        return documentaleService.getDocumento(documento, [Documento.COMPONENTI.FILE])
    }

    @CompileDynamic
    List<Map<String, Object>> getStoricoFlusso(Protocollo protocollo, boolean tutti = false) {
        List<DatoStorico> datiStorici = documentoStoricoService.ricercaStorico(protocollo.id, null, tutti ? null : protocollo.data)
        List<Map<String, Object>> storicoFlusso = []

        for (DatoStorico storico : datiStorici) {
            def map = storico.datiStorici.collectEntries { DatoStorico dato ->
                if (dato.campo.startsWith("testoPrincipale")) {
                    if (dato.tipoStorico == TipoStorico.AGGIUNTO && dato.dati == null) {
                        return [testoPrincipale: dato.valoreNuovo]
                    } else {
                        return [testoPrincipale: dato.dati]
                    }
                }
                if (dato.campo.startsWith("step")) {
                    if (dato.tipoStorico == TipoStorico.AGGIUNTO && dato.dati == null) {
                        return [statoFlusso: dato.valoreNuovo?._value]
                    } else {
                        return [statoFlusso: dato.dati?._value]
                    }
                }
                return [(dato.campo): dato.valore ?: ""]
            }
            map.revisione = storico.revisione
            map.utente = storico.nominativoUtente
            map.data = storico.dataModifica
            if (tutti || map.get("numero._value") == null || map.get("numero._value") < 0) {
                storicoFlusso << map
            }
        }

        return storicoFlusso
    }

    /**
     * Questa funzione ritorna tutte le modifiche fatte sul documento
     *
     * @param ricercaDal
     * @param ricercaAl
     *
     * @return
     */
    public List<GroovyRowResult> cercaStorico(Date ricercaDal, Date ricercaAl, Long id) {
        // questa è la query che trova tutta la storia del documento e dei suoi figli.
        return new Sql(dataSource).rows('''select * from (select 
                 (select u.nominativo_soggetto from AD4_V_UTENTI u where u.UTENTE =dl.utente_upd) UTENTE_MODIFICA,
                    (select r.revtstmp from revinfo r where r.rev =f.rev) DATA_MODIFICA
                     ,f.oggetto OGGETTO, f.oggetto_mod OGGETTO_MOD, f.anno_archiviazione ANNO_ARCHIVIAZIONE, f.anno_archiviazione_mod ANNO_ARCHIVIAZIONE_MOD, f.RESPONSABILE, f.RESPONSABILE_MOD,
                     f.DIGITALE, f.DIGITALE_MOD,dl.RISERVATO, dl.RISERVATO_MOD,f.STATO_FASCICOLO, f.STATO_FASCICOLO_MOD, f.TOPOGRAFIA, f.TOPOGRAFIA_MOD,f.NOTE, 
                     f.NOTE_MOD, TO_CHAR(f.DATA_APERTURA,'dd/mm/yyyy') DATA_APERTURA, f.DATA_APERTURA_MOD, TO_CHAR(F.DATA_CHIUSURA,'dd/mm/yyyy') DATA_CHIUSURA, f.DATA_CHIUSURA_MOD, TO_CHAR(f.DATA_ARCHIVIAZIONE,'dd/mm/yyyy') DATA_ARCHIVIAZIONE,
                      f.DATA_ARCHIVIAZIONE_MOD, f.SUB, f.SUB_MOD
                     , f.CLASSIFICAZIONE, f.CLASSIFICAZIONE_MOD, cla.DESCRIZIONE CLASS_DESCR     , cla.CLASSIFICAZIONE CLASS_COD
                       ,s.unita_progr, 
                        (SELECT MAX(DESCRIZIONE) FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB WHERE PROGR=s.unita_progr) UNITA_COMPETENZA,
                      nvl( decode(s.documento_mod,0,1,1,0),0) unita_progr_mod
                 from ags_fascicoli_log f, gdo_documenti_log dl, ags_classificazioni cla, gdo_documenti_soggetti_log s
                 where f.id_documento = :idDocumento
                 and dl.rev=f.rev
                 and cla.ID_CLASSIFICAZIONE(+) = f.ID_CLASSIFICAZIONE
                    and ( 
                    s.id_documento(+) = dl.id_documento 
                   and s.REVTYPE(+) in (0, 1)
                     and s.rev(+) = dl.rev 
                     and nvl(s.revend(+), 99999999) >= dl.rev
                    and s.tipo_soggetto(+)='UO_COMPETENZA'
                    
                     )
                    order by DATA_MODIFICA) 
                  where DATA_MODIFICA > :dataDal
                    and trunc(DATA_MODIFICA) <= trunc(:dataAl)
    ''', [idDocumento: id,
          dataDal    : new java.sql.Timestamp(ricercaDal.time),
          dataAl     : new java.sql.Timestamp(ricercaAl.time)])
    }
}
