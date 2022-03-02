package it.finmatica.protocollo.integrazioni.ws

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoRegola
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.gestionetesti.TipoFile
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamento
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamentoDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.ws.dati.Allegato
import it.finmatica.protocollo.integrazioni.ws.dati.Corrispondente
import it.finmatica.protocollo.integrazioni.ws.dati.DocumentoCollegato
import it.finmatica.protocollo.integrazioni.ws.dati.Protocollo
import it.finmatica.protocollo.integrazioni.ws.dati.Smistamento
import it.finmatica.protocollo.integrazioni.ws.dati.Soggetto
import it.finmatica.protocollo.integrazioni.ws.dati.StatoProtocollo
import it.finmatica.protocollo.integrazioni.ws.dati.UnitaOrganizzativa
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.io.FilenameUtils
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional
import org.zkoss.zk.ui.util.Clients

@Slf4j
@Transactional
class ProtocolloWebServiceBase {

    protected ProtocolloService protocolloService
    protected TipologiaSoggettoService tipologiaSoggettoService
    protected AllegatoProtocolloService allegatoProtocolloService
    protected SpringSecurityService springSecurityService
    protected CorrispondenteService corrispondenteService
    protected ProtocolloGdmService protocolloGdmService
    protected SmistamentoService smistamentoService

    protected DocumentoService documentoService
    protected WkfIterService wkfIterService
    protected IGestoreFile gestoreFile
    protected DateService dateService
    protected DizionariRepository dizionariRepository

    @Transactional(readOnly = true)
    protected void login(Soggetto operatore, long ente) {
        Utils.eseguiAutenticazione(operatore.utenteAd4, ente)
    }

    protected it.finmatica.protocollo.documenti.Protocollo creaProtocolloDaWS(Protocollo protocolloWs) {
        if (!springSecurityService.principal.hasRuolo(ImpostazioniProtocollo.RUOLO_REDATTORE.valore)) {
            throw new ProtocolloRuntimeException("utente operatore non abilitato alla creazione di LETTERE")
        }

        it.finmatica.protocollo.documenti.Protocollo protocollo = buildProtocolloWS(protocolloWs)

        protocolloService.salva(protocollo)

        WkfCfgIter cfgIter = protocollo.tipoProtocollo.getCfgIter()
        wkfIterService.istanziaIter(cfgIter, protocollo)

        if (protocolloWs.allegatoPrincipale?.file != null) {
            GestioneTestiModello modelloTesto
            if (protocollo.tipoProtocollo != null) {
                modelloTesto = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            }

            FileDocumento fileAllegato = new FileDocumento(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                    , nome: protocolloWs.allegatoPrincipale.nomeFile
                    , contentType: protocolloWs.allegatoPrincipale.contentType
                    , valido: true
                    , modificabile: true
                    , firmato: false
                    , modelloTesto: modelloTesto)
            protocollo.addToFileDocumenti(fileAllegato)
            fileAllegato.save()
            gestoreFile.addFile(protocollo, fileAllegato, protocolloWs.allegatoPrincipale.file.inputStream)
        } else {
            if (protocollo.tipoProtocollo == null) {
                throw new ProtocolloRuntimeException("Il tipo di documento non è valorizzato")
            }

            GestioneTestiModello modelloTesto = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            if (modelloTesto == null) {
                throw new ProtocolloRuntimeException("Non è associato un modello di testo predefinito per il tipo di documento scelto: " + protocollo.tipoProtocollo.descrizione)
            }

            protocollo.addToFileDocumenti(new FileDocumento(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                    , nome: "LETTERA." + modelloTesto.tipo
                    , contentType: TipoFile.getInstanceByEstensione(modelloTesto.tipo).contentType
                    , valido: true
                    , modificabile: true
                    , firmato: false
                    , modelloTesto: modelloTesto))
        }

        salvaAllegatiWS(protocolloWs, protocollo)
        salvaDocumentiCollegatiWS(protocolloWs, protocollo)
        salvaCorrispondentiWS(protocolloWs, protocollo)
        salvaSmistamentiWS(protocolloWs, protocollo)

        protocollo.save()

        return protocollo
    }

    @Transactional(readOnly = true)
    protected Protocollo caricaProtocolloWs(Long id,Protocollo protocolloWs = new Protocollo(), Closure cl = null) {
        it.finmatica.protocollo.documenti.Protocollo protocollo = Documento.get(id)
        if (!protocollo) {
            throw new IllegalArgumentException("L'id richiesto [$id] non corrisponde ad un documento esistente")
        }

        protocolloWs.tipo = protocollo.tipoProtocollo.codice
        protocolloWs.schema = protocollo.schemaProtocollo?.codice
        protocolloWs.classificazione = protocollo.classificazione?.codice
        protocolloWs.movimento = Protocollo.Movimento.valueOf(protocollo.movimento)
        protocolloWs.riservato = protocollo.riservato
        protocolloWs.dataRedazione = protocollo.dataRedazione
        protocolloWs.numeroFascicolo = protocollo.fascicolo?.numero
        protocolloWs.annoFascicolo = protocollo.fascicolo?.anno ?: 0
        protocolloWs.id = protocollo.id
        protocolloWs.idRiferimento = protocollo.idDocumentoEsterno as String
        protocolloWs.numero = protocollo.numero
        protocolloWs.anno = protocollo.anno
        protocolloWs.data = protocollo.data
        protocolloWs.registro = protocollo.tipoRegistro?.commento
        protocolloWs.oggetto = protocollo.oggetto
        protocolloWs.note = protocollo.note

        protocolloWs.statoFlusso = protocollo.iter.stepCorrente.cfgStep.titolo

        // TODO: Allegato principale 27/08/2018 al momento non lo mettiamo
//		FileDocumento doc = p.filePrincipale
//		Allegato ap = new Allegato()
//		pw.allegatoPrincipale = ap
//		ap.idRiferimento = doc.id
//		ap.contentType = doc.contentType
//		ap.nomeFile = doc.nome
//		InputStream file = gestoreFile.getFile(p, doc)
//		ap.file = new DataHandler(new InputStreamDataSource(file,doc))

        // unità protocollante
        UnitaOrganizzativa uo = new UnitaOrganizzativa()
        protocolloWs.unitaProtocollante = uo
        for (sogg in protocollo.soggetti) {
            if (sogg.tipoSoggetto == TipoSoggetto.UO_PROTOCOLLANTE) {
                def so4 = sogg.unitaSo4
                uo.codice = so4.codice
                uo.codiceOttica = so4.ottica.codice
                uo.dal = so4.dal
                uo.descrizione = so4.descrizione
                uo.progressivo = so4.progr
            }
        }
        // corrispondenti
        protocolloWs.corrispondenti = []
        for (it.finmatica.protocollo.corrispondenti.Corrispondente c : protocollo.corrispondenti) {
            Corrispondente corrispondente = new Corrispondente()
            corrispondente.barcodeSpedizione = c.barcodeSpedizione
            if (c.tipoSoggetto) {
                corrispondente.tipoSoggettoSequenza = c.tipoSoggetto.sequenza
            }
            corrispondente.cap = c.cap
            corrispondente.codiceFiscale = c.codiceFiscale
            corrispondente.cognome = c.cognome
            corrispondente.comune = c.comune
            corrispondente.conoscenza = c.conoscenza
            corrispondente.email = c.email
            corrispondente.fax = c.fax
            corrispondente.indirizzo = c.indirizzo
            corrispondente.tipoIndirizzo = c.tipoIndirizzo
            corrispondente.nome = c.nome
            corrispondente.partitaIva = c.partitaIva
            corrispondente.provinciaSigla = c.provinciaSigla
            corrispondente.denominazione = c.denominazione

            protocolloWs.corrispondenti.add corrispondente
        }

        // smistamenti
        protocolloWs.smistamenti = []

        for (it.finmatica.protocollo.smistamenti.Smistamento s : protocollo.smistamentiValidi) {
            Smistamento smistamentoWs = new Smistamento()
            smistamentoWs.dataAssegnazione = s.dataAssegnazione
            smistamentoWs.dataSmistamento = s.dataSmistamento
            smistamentoWs.dataEsecuzione = s.dataEsecuzione
            smistamentoWs.dataPresaInCarico = s.dataPresaInCarico
            smistamentoWs.note = s.note
            smistamentoWs.noteUtente = s.noteUtente

            smistamentoWs.tipoSmistamento = Smistamento.TipoSmistamento.valueOf(s.tipoSmistamento)
            smistamentoWs.utenteAssegnatario = s.utenteAssegnatario ? new Soggetto(utenteAd4: s.utenteAssegnatario.nominativo, niAs4: s.utenteAssegnatario.id) : null

            smistamentoWs.utenteTrasmissione = s.utenteTrasmissione ? new Soggetto(utenteAd4: s.utenteTrasmissione.nominativo, niAs4: s.utenteTrasmissione.id) : null
            smistamentoWs.utenteEsecuzione = s.utenteEsecuzione ? new Soggetto(utenteAd4: s.utenteEsecuzione.nominativo, niAs4: s.utenteEsecuzione.id) : null
            smistamentoWs.utentePresaInCarico = s.utentePresaInCarico ? new Soggetto(utenteAd4: s.utentePresaInCarico.nominativo, niAs4: s.utentePresaInCarico.id) : null
            So4UnitaPubb us = s.unitaSmistamento
            smistamentoWs.unitaSmistamento = us ? new UnitaOrganizzativa(codice: us.codice, descrizione: us.descrizione, progressivo: us.progr, codiceOttica: us.ottica.codice, dal: us.dal) : null
            So4UnitaPubb ut = s.unitaTrasmissione
            smistamentoWs.unitaTrasmissione = ut ? new UnitaOrganizzativa(codice: ut.codice, descrizione: ut.descrizione, progressivo: ut.progr, codiceOttica: ut.ottica.codice, dal: ut.dal) : null
            protocolloWs.smistamenti.add(smistamentoWs)
        }

        // TODO: allegati - 27/08/2018 al momento non li mettiamo
//		pw.allegati = []
//		for (it.finmatica.gestionedocumenti.documenti.Allegato a : p.documentiCollegati) {
//			Allegato allegato = new Allegato()
//			allegato.nomeFile = a.filePrincipale.nome
//			allegato.idRiferimento = a.filePrincipale.idFileEsterno as String
//			allegato.contentType = a.filePrincipale.contentType
//			InputStream is = gestoreFile.getFile(p,a)
//			allegato.file = new DataHandler(new InputStreamDataSource(is,a.filePrincipale))
//			pw.allegati.add allegato
//		}

        // collegati
        protocolloWs.collegati = []
        for (it.finmatica.gestionedocumenti.documenti.DocumentoCollegato dc : protocollo.documentiCollegati) {
            DocumentoCollegato docWs = new DocumentoCollegato()
            docWs.id = dc.id
            docWs.idDocumentoEsterno = dc.collegato.idDocumentoEsterno as String
            docWs.tipoCollegamento = dc.tipoCollegamento.codice
            protocolloWs.collegati.add docWs
        }

        // dati storici
        List<Map<String, Object>> storicoFlusso = protocolloService.getStoricoFlusso(protocollo, true)
        List<StatoProtocollo> statiProtocolli = []
        for (Map<String, Object> riga : storicoFlusso) {
            if (!protocollo.data || riga.data < protocollo.data) {
                statiProtocolli.add(new StatoProtocollo(utente: riga.utente, stato: riga.statoFlusso, dataModifica: riga.data))
            } else if (riga['numero._value']) {
                statiProtocolli.add(new StatoProtocollo(utente: riga.utente, stato: 'PROTOCOLLAZIONE', dataModifica: riga.data))
            }
        }

        statiProtocolli.sort(true, { it.dataModifica })
        protocolloWs.storico = statiProtocolli
        if(cl) {
            cl.call(protocollo)
        }
        return protocolloWs
    }

    protected void salvaAllegatiWS(Protocollo protocolloWs, it.finmatica.protocollo.documenti.Protocollo protocollo) {

        for (Allegato allegatoWs : protocolloWs.allegati) {

            log.info("WS: Inizio creazione allegato: " + allegatoWs.nomeFile)
            it.finmatica.gestionedocumenti.documenti.Allegato allegato = new it.finmatica.gestionedocumenti.documenti.Allegato()
            allegato.descrizione = allegatoWs.nomeFile
            allegato.commento = allegatoWs.nomeFile
            if(allegatoWs.stampaUnica == null){
                allegato.stampaUnica = Impostazioni.ALLEGATO_STAMPA_UNICA_DEFAULT.abilitato
            }

            allegato.origine = "WS"
            allegato.ubicazione = "WS"
            allegato.tipoAllegato = TipoAllegato.findByCodice(TipoAllegato.CODICE_TIPO_ALLEGATO)

            if (allegatoWs.nomeFile == null) {
                throw new IllegalArgumentException("Specificare il nome del file allegato.")
            }

            if (allegatoWs.nomeFile.contains("'") || allegatoWs.nomeFile.contains("@")) {
                throw new IllegalArgumentException("Impossibile caricare il file: il nome dell'allegato contiene caratteri non consentiti ( ' @ ).")
            }

            // controllo i nomi dei file duplicati in tutti gli allegati del documento, nel file principale ed originale
            if (allegatoWs.nomeFile == protocollo.filePrincipale?.nome || allegatoWs.nomeFile == protocollo.fileOriginale?.nome) {
                throw new IllegalArgumentException("Impossibile caricare il file: il file ha lo stesso nome dei file principale del documento.")
            }

            for (it.finmatica.gestionedocumenti.documenti.Allegato all : protocollo.getAllegati()) {
                for (FileDocumento fileDocumento : all.fileDocumenti) {
                    if (allegatoWs.nomeFile == fileDocumento.nome) {
                        throw new IllegalArgumentException("Non è possibile caricare due volte un file con lo stesso nome: ${allegatoWs.nomeFile}.")
                    }
                }
            }

            if (Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.size() > 0 && Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valore != "") {
                if (!Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.collect{ it.toLowerCase() }.collect{ it.toLowerCase() }.contains(FilenameUtils.getExtension(allegatoWs.nomeFile).toLowerCase())) {
                    Clients.showNotification("Impossibile caricare il file: l'allegato è di un tipo non consentito")
                    return
                }
            }

            allegato.save()
            protocollo.addDocumentoAllegato(allegato)
            documentoService.uploadFile(allegato, allegatoWs.nomeFile, allegatoWs.contentType, allegatoWs.file.inputStream)

            log.info("WS: Fine salvataggio allegato: " + allegatoWs.nomeFile)
        }

        boolean allegatiPresenti = protocolloWs.allegati?.size() > 0
        // controllare che già siano stati associati degli allegati
        if (!allegatiPresenti && protocollo.schemaProtocollo?.files?.size() > 0) {
            allegatoProtocolloService.importaAllegatoSchemaProtocollo(protocollo)
        }

    }

    protected it.finmatica.protocollo.documenti.Protocollo buildProtocolloWS(Protocollo protocolloWs) {
        it.finmatica.protocollo.documenti.Protocollo protocollo = new it.finmatica.protocollo.documenti.Protocollo()
        protocollo.tipoOggetto = WkfTipoOggetto.get(it.finmatica.protocollo.documenti.Protocollo.TIPO_DOCUMENTO)
        protocollo.schemaProtocollo = SchemaProtocollo.findByCodiceAndValido(protocolloWs.schema, true)
        protocollo.tipoProtocollo = TipoProtocollo.findByCodiceAndValido(protocolloWs.tipo, true)
        if(!protocollo.tipoProtocollo){
            throw new ProtocolloRuntimeException("Valorizzare un Tipo di Protocollo valido")
        }

        // controllo che il movimento presente sullo schema di protocollo sia comapatibile con quelli del tipo di protocollo
        // nel caso non lo fosse resetto lo schema protocollo
        String movimentoSchema = protocollo.schemaProtocollo?.movimento
        if (movimentoSchema) {
            if (protocollo.tipoProtocollo) {

                List<String> movimentiPossibili = []
                if (protocollo.tipoProtocollo.movimento != null) {
                    movimentiPossibili = [protocollo.tipoProtocollo.movimento]
                } else {
                    movimentiPossibili = protocollo.tipoProtocollo.categoriaProtocollo.movimenti()
                }

                if (movimentiPossibili?.size() > 0 && !movimentiPossibili.contains(movimentoSchema)) {
                    protocollo.schemaProtocollo = null
                }
            }
        }

        So4UnitaPubb uoProtocollante = So4UnitaPubb.findByCodiceAndAlIsNull(protocolloWs.unitaProtocollante?.codice)
        protocollo.setSoggetto(TipoSoggetto.UO_PROTOCOLLANTE, null, uoProtocollante)
        protocollo.setSoggetto(TipoSoggetto.REDATTORE, springSecurityService.currentUser, uoProtocollante)
        protocollo = (it.finmatica.protocollo.documenti.Protocollo) protocollo.save()

        if (protocollo.tipoProtocollo.firmatarioVisibile) {
            creaSoggettoDefault(protocollo, TipoSoggetto.FIRMATARIO)
        }
        if (protocollo.tipoProtocollo.funzionarioVisibile) {
            creaSoggettoDefault(protocollo, TipoSoggetto.FUNZIONARIO)
        }
        protocollo.controlloFirmatario = protocollo.tipoProtocollo?.getFirmatarioObbligatorio()
        protocollo.controlloFunzionario = protocollo.tipoProtocollo?.getFunzionarioObbligatorio()

        creaSoggettoDefault(protocollo, TipoSoggetto.UO_ESIBENTE)

        if (!StringUtils.isEmpty(protocolloWs.classificazione)) {
            protocollo.classificazione = Classificazione.findByCodiceAndValidoAndAlIsNull(protocolloWs.classificazione, true)
        } else if (protocollo.schemaProtocollo != null) {
            protocollo.classificazione = protocollo.schemaProtocollo.classificazione
        }

        if (!StringUtils.isEmpty(protocolloWs.numeroFascicolo) && protocolloWs.annoFascicolo != 0) {
            protocollo.fascicolo = Fascicolo.findByClassificazioneAndAnnoAndNumero(protocollo.classificazione, protocolloWs.annoFascicolo, protocolloWs.numeroFascicolo)
        } else if (protocollo.schemaProtocollo != null && protocollo.classificazione == null) {
            protocollo.fascicolo = protocollo.schemaProtocollo.fascicolo
            protocollo.classificazione = protocollo.fascicolo?.classificazione
        }

        if (!StringUtils.isEmpty(protocolloWs.oggetto)) {
            protocollo.oggetto = protocolloWs.oggetto
        } else if (protocollo.schemaProtocollo != null) {
            protocollo.oggetto = protocollo.schemaProtocollo.oggetto
        }

        protocollo.movimento = protocollo.tipoProtocollo?.movimento
        protocollo.riservato = protocolloWs.riservato
        protocollo.dataRedazione = protocolloWs.dataRedazione
        protocollo.note = protocolloWs.note
        return protocollo
    }

    protected void salvaCorrispondentiWS(Protocollo protocolloWs, it.finmatica.protocollo.documenti.Protocollo protocollo) {
        List<CorrispondenteDTO> corrispondenteDTOList = new ArrayList<CorrispondenteDTO>()

        for (Corrispondente corrispondenteWs : protocolloWs.corrispondenti) {
            CorrispondenteDTO corrispondenteDto = new CorrispondenteDTO()
            corrispondenteDto.tipoCorrispondente = it.finmatica.protocollo.corrispondenti.Corrispondente.DESTINATARIO
            corrispondenteDto.barcodeSpedizione = corrispondenteWs.barcodeSpedizione
            corrispondenteDto.tipoSoggetto = it.finmatica.protocollo.corrispondenti.TipoSoggetto.findById(corrispondenteWs.tipoSoggettoSequenza)?.toDTO()
            corrispondenteDto.cap = corrispondenteWs.cap
            corrispondenteDto.codiceFiscale = corrispondenteWs.codiceFiscale
            corrispondenteDto.cognome = corrispondenteWs.cognome
            corrispondenteDto.comune = corrispondenteWs.comune
            corrispondenteDto.conoscenza = corrispondenteWs.conoscenza
            corrispondenteDto.email = corrispondenteWs.email?.trim()
            corrispondenteDto.fax = corrispondenteWs.fax
            corrispondenteDto.indirizzo = corrispondenteWs.indirizzo
            corrispondenteDto.tipoIndirizzo = corrispondenteWs.tipoIndirizzo
            corrispondenteDto.nome = corrispondenteWs.nome
            corrispondenteDto.partitaIva = corrispondenteWs.partitaIva
            corrispondenteDto.provinciaSigla = corrispondenteWs.provinciaSigla
            corrispondenteDto.denominazione = corrispondenteWs.denominazione

            if (corrispondenteDto.denominazione == null || corrispondenteDto.denominazione == "") {
                if (corrispondenteDto.cognome == null || corrispondenteDto.cognome == "") {
                    throw new ProtocolloRuntimeException("I dati del corrispondente risultano incompleti (inserire la denominazione o il cognome)")
                }
                corrispondenteDto.denominazione = corrispondenteWs.cognome?.toUpperCase()
                if (corrispondenteDto.nome != null) {
                    corrispondenteDto.denominazione = corrispondenteDto.denominazione + " " + corrispondenteDto.nome
                }
            }

            corrispondenteDTOList.add(corrispondenteDto)
        }

        corrispondenteService.salva(protocollo, corrispondenteDTOList)
    }

    protected void salvaDocumentiCollegatiWS(Protocollo protocolloWs, it.finmatica.protocollo.documenti.Protocollo protocollo) {
        for (DocumentoCollegato documentoCollegatoWs : protocolloWs.collegati) {
            Documento collegato = Documento.get(documentoCollegatoWs?.id)

            if (collegato == null) {
                collegato = Documento.findByIdDocumentoEsterno(documentoCollegatoWs.idDocumentoEsterno)
            }

            if (collegato == null) {
                ProtocolloEsterno protocolloEsterno = ProtocolloEsterno.findByIdDocumentoEsterno(documentoCollegatoWs.idDocumentoEsterno)
                it.finmatica.protocollo.documenti.Protocollo protocolloCollegato = new it.finmatica.protocollo.documenti.Protocollo()
                protocolloCollegato.idDocumentoEsterno = protocolloEsterno.idDocumentoEsterno
                protocolloCollegato.anno = protocolloEsterno.anno
                protocolloCollegato.numero = protocolloEsterno.numero
                protocolloCollegato.oggetto = protocolloEsterno.oggetto
                protocolloCollegato.tipoRegistro = protocolloEsterno.tipoRegistro
                protocolloCollegato.data = protocolloEsterno.data

                if (protocolloCollegato.controlloFirmatario == null) {
                    protocolloCollegato.controlloFirmatario = true
                }

                if (protocolloCollegato.controlloFunzionario == null) {
                    protocolloCollegato.controlloFunzionario = false
                }

                TipoProtocollo tipoProcollo = TipoProtocollo.findByCategoria(protocolloEsterno.categoria)
                protocolloCollegato.tipoProtocollo = tipoProcollo
                collegato = protocolloCollegato.save()
            }

            if (collegato) {
                if (TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE == documentoCollegatoWs.tipoCollegamento) {
                    protocolloService.salvaProtocolloPrecedente(protocollo, (it.finmatica.protocollo.documenti.Protocollo) collegato)
                } else if (TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO == documentoCollegatoWs.tipoCollegamento) {
                    protocolloService.salvaRiferimentoDatiAccesso(protocollo, (it.finmatica.protocollo.documenti.Protocollo) collegato)
                } else {
                    it.finmatica.gestionedocumenti.documenti.DocumentoCollegato documentoCollegato = new it.finmatica.gestionedocumenti.documenti.DocumentoCollegato(documento: protocollo, collegato: collegato, tipoCollegamento: TipoCollegamento.findByCodice(documentoCollegatoWs.tipoCollegamento))
                    protocollo.addToDocumentiCollegati(documentoCollegato)
                    documentoCollegato.save()
                    protocollo.save()
                    protocolloGdmService.salvaDocumentoCollegamento(protocollo, collegato, documentoCollegatoWs.tipoCollegamento)
                }
            }
        }
    }

    protected void salvaSmistamentiWS(Protocollo protocolloWs, it.finmatica.protocollo.documenti.Protocollo protocollo) {
        SchemaProtocollo schemaProtocollo = protocollo.schemaProtocollo
        List<SchemaProtocolloSmistamento> smistamentiSchema = SchemaProtocolloSmistamento.createCriteria().list {
            eq("schemaProtocollo.id", schemaProtocollo?.id)
            isNotNull("sequenza")
            order("sequenza")
        }

        List<SchemaProtocolloSmistamento> smistamentiDaCreare = smistamentiSchema
        boolean isSequenza = smistamentiSchema?.size() > 0
        if (isSequenza) {
            List<SchemaProtocolloSmistamento> smistamentiSchemaRestanti = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo.id", schemaProtocollo?.id)
                isNull("sequenza")
                eq("tipoSmistamento", it.finmatica.protocollo.smistamenti.Smistamento.CONOSCENZA)
            }
            smistamentiDaCreare = [smistamentiSchema.get(0)]
            smistamentiDaCreare.addAll(smistamentiSchemaRestanti)
        } else if (schemaProtocollo != null && (protocolloWs.smistamenti == null || protocolloWs.smistamenti.isEmpty())) {
            smistamentiDaCreare = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo.id", schemaProtocollo.id)
            }
        }

        if (isSequenza) {
            creaSmistamentiDaSchema(smistamentiDaCreare, protocollo)
            return
        }

        List<SmistamentoDTO> smistamentoDTOList = new ArrayList<SmistamentoDTO>()

        for (Smistamento smistamentoWs : protocolloWs?.smistamenti) {
            SmistamentoDTO smistamentoDTO = buildSmistamentoDTO(smistamentoWs)
            smistamentoDTOList.add(smistamentoDTO)
        }

        if (smistamentoDTOList.size() == 0) {
            salvaSmistamentiDaSchema(smistamentiDaCreare, smistamentoDTOList)
        }

        smistamentoService.salva(protocollo.toDTO(), smistamentoDTOList)
    }

    protected SmistamentoDTO buildSmistamentoDTO(Smistamento smistamentoWs) {
        SmistamentoDTO smistamentoDTO = new SmistamentoDTO()
        smistamentoDTO.dataAssegnazione = smistamentoWs.dataAssegnazione
        smistamentoDTO.dataSmistamento = smistamentoWs.dataSmistamento
        smistamentoDTO.dataEsecuzione = smistamentoWs.dataEsecuzione
        smistamentoDTO.dataPresaInCarico = smistamentoWs.dataPresaInCarico
        smistamentoDTO.note = smistamentoWs.note
        smistamentoDTO.noteUtente = smistamentoWs.noteUtente

        smistamentoDTO.tipoSmistamento = smistamentoWs.tipoSmistamento

        smistamentoDTO.utenteAssegnatario = Ad4Utente.findByNominativo(smistamentoWs.utenteAssegnatario?.utenteAd4)?.toDTO()
        smistamentoDTO.utenteAssegnante = springSecurityService.currentUser?.toDTO()
        smistamentoDTO.utenteTrasmissione = Ad4Utente.findByNominativo(smistamentoWs.utenteTrasmissione?.utenteAd4)?.toDTO()
        if (!smistamentoDTO.utenteTrasmissione) {
            smistamentoDTO.utenteTrasmissione = springSecurityService.currentUser?.toDTO()
        }
        smistamentoDTO.utenteEsecuzione = Ad4Utente.findByNominativo(smistamentoWs.utenteEsecuzione?.utenteAd4)?.toDTO()
        smistamentoDTO.utentePresaInCarico = Ad4Utente.findByNominativo(smistamentoWs.utentePresaInCarico?.utenteAd4)?.toDTO()

        smistamentoDTO.unitaSmistamento = So4UnitaPubb.findByCodiceAndAlIsNull(smistamentoWs.unitaSmistamento?.codice)?.toDTO()
        smistamentoDTO.unitaTrasmissione = So4UnitaPubb.findByCodiceAndAlIsNull(smistamentoWs.unitaTrasmissione?.codice)?.toDTO()

        return smistamentoDTO
    }

    protected void salvaSmistamentiDaSchema(List<SchemaProtocolloSmistamento> smistamentidaSchema, List<SmistamentoDTO> smistamenti) {
        for (SchemaProtocolloSmistamentoDTO smistamentoSchema : smistamentidaSchema?.toDTO()) {
            SmistamentoDTO smistamentoDTO = new SmistamentoDTO()

            smistamentoDTO.unitaSmistamento = smistamentoSchema.unitaSo4Smistamento

            if (smistamentoDTO.unitaSmistamento != null) {
                smistamentoDTO.tipoSmistamento = smistamentoSchema.tipoSmistamento
                smistamentoDTO.utenteTrasmissione = springSecurityService.currentUser.toDTO()
                smistamentoDTO.statoSmistamento = it.finmatica.protocollo.smistamenti.Smistamento.CREATO
                smistamentoDTO.dataSmistamento = dateService.getCurrentDate()
                smistamenti.add(smistamentoDTO)
            }
        }
    }

    protected void creaSmistamentiDaSchema(List<SchemaProtocolloSmistamento> smistamentiDaCreare, it.finmatica.protocollo.documenti.Protocollo p) {
        for (SchemaProtocolloSmistamento ss : smistamentiDaCreare) {
            SmistamentoDTO smistamentoDTO = new SmistamentoDTO()
            So4UnitaPubb unita = ss.unitaSo4Smistamento
            smistamentoDTO.unitaSmistamento = unita.toDTO()

            if (smistamentoDTO.unitaSmistamento != null) {
                smistamentoDTO.tipoSmistamento = ss.tipoSmistamento
                smistamentoDTO.utenteTrasmissione = springSecurityService.currentUser.toDTO()
                smistamentoDTO.statoSmistamento = it.finmatica.protocollo.smistamenti.Smistamento.CREATO
                smistamentoDTO.dataSmistamento = dateService.getCurrentDate()
                if (p.id > 0) {
                    smistamentoService.creaSmistamento(p, smistamentoDTO.tipoSmistamento, null, springSecurityService.currentUser, smistamentoDTO.unitaSmistamento?.domainObject, null, null)
                }
            }
        }
    }

    protected void creaSoggettoDefault(it.finmatica.protocollo.documenti.Protocollo protocollo, String soggetto) {

        TipologiaSoggettoRegola regola = TipologiaSoggettoRegola.createCriteria().get {
            eq("tipologiaSoggetto.id", protocollo.tipoProtocollo.tipologiaSoggetto.id)
            eq("tipoSoggetto", soggetto)

            fetchMode("tipoSoggetto", FetchMode.JOIN)
            fetchMode("tipoSoggettoPartenza", FetchMode.JOIN)
            fetchMode("regolaDefault", FetchMode.JOIN)
        }

        Map soggetti = tipologiaSoggettoService.calcolaSoggettiDto(protocollo)
        Map soggettoResult = tipologiaSoggettoService.creaSoggetto(protocollo, regola, soggetti)
        protocollo.setSoggetto(soggetto, soggettoResult?.utente?.domainObject, soggettoResult?.unita?.domainObject)
    }

    @Autowired
    void setProtocolloService(ProtocolloService protocolloService) {
        this.protocolloService = protocolloService
    }

    @Autowired
    void setTipologiaSoggettoService(TipologiaSoggettoService tipologiaSoggettoService) {
        this.tipologiaSoggettoService = tipologiaSoggettoService
    }

    @Autowired
    void setAllegatoProtocolloService(AllegatoProtocolloService allegatoProtocolloService) {
        this.allegatoProtocolloService = allegatoProtocolloService
    }

    @Autowired
    void setSpringSecurityService(SpringSecurityService springSecurityService) {
        this.springSecurityService = springSecurityService
    }

    @Autowired
    void setCorrispondenteService(CorrispondenteService corrispondenteService) {
        this.corrispondenteService = corrispondenteService
    }

    @Autowired
    void setProtocolloGdmService(ProtocolloGdmService protocolloGdmService) {
        this.protocolloGdmService = protocolloGdmService
    }

    @Autowired
    void setSmistamentoService(SmistamentoService smistamentoService) {
        this.smistamentoService = smistamentoService
    }

    @Autowired
    void setDocumentoService(DocumentoService documentoService) {
        this.documentoService = documentoService
    }

    @Autowired
    void setWkfIterService(WkfIterService wkfIterService) {
        this.wkfIterService = wkfIterService
    }

    @Autowired
    void setGestoreFile(IGestoreFile gestoreFile) {
        this.gestoreFile = gestoreFile
    }

    @Autowired
    void setDateService(DateService dateService) {
        this.dateService = dateService
    }

    @Autowired
    void setDizionariRepository(DizionariRepository dizionariRepository) {
        this.dizionariRepository = dizionariRepository
    }
}
