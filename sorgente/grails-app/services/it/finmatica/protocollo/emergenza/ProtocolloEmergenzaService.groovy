package it.finmatica.protocollo.emergenza

import groovy.util.logging.Slf4j
import groovy.xml.StreamingMarkupBuilder
import groovy.xml.XmlUtil
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.competenze.DocumentoCompetenze
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.notifiche.Notifica
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.emergenza.ProtocolloDatiEmergenza
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.ad4.Ad4Repository
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.ricerca.Ricerca
import it.finmatica.smartdoc.api.ricerca.criteri.Condizioni
import it.finmatica.smartdoc.api.struct.Campo
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

//@CompileStatic
@Slf4j
@Transactional
@Service
class ProtocolloEmergenzaService {

    @Autowired
    ProtocolloService protocolloService
    @Autowired
    ValidazioneProtocolloEmergenzaService validazioneProtocolloEmergenzaService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    Ad4Repository ad4Repository
    @Autowired
    ProtocolloRepository protocolloRepository
    @Autowired
    ClassificazioneRepository classificazioneRepository
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    So4Repository so4Repository
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    NotificheService notificheService
    @Autowired
    WkfIterService wkfIterService

    String importaProtocolli(String xml) {

        String statoEmergenza
        String statoProtocollo
        String descrizioneStatoEmergenza
        String descrizioneStatoProtocollo

        Protocollo protocolloEmergenza
        Protocollo protocolloXml

        String dataInizioReturn
        String dataFineReturn
        String statusReturn
        String descrizioneStatusReturn

        int numDocNonProtocollati = 0
        def xmlReturn

        boolean esistenza = validazioneProtocolloEmergenzaService.verificaPresenzaNumerazione(xml)

        if (!esistenza) {
            def root = new XmlSlurper().parseText(xml)
            /* creo il protocollo di emergenza */
            root.emergenza.each {
                protocolloEmergenza = validazioneProtocolloEmergenzaService.getProtocolloEmergenza(it)
                if (protocolloEmergenza == null) {
                    try {
                        InputStream is = new ByteArrayInputStream(xml.getBytes('UTF-8'))
                        protocolloEmergenza = creaProtocolloEmergenza(it, is)
                        statoEmergenza = "K"
                        descrizioneStatoEmergenza = ""
                    }
                    catch (Exception e) {
                        log.error("Errore in fase di registrazione:", e)
                        statoEmergenza = "E"
                        descrizioneStatoEmergenza = e.getMessage()
                    }

                    try {
                        if (validazioneProtocolloEmergenzaService.validazione(it) && validazioneProtocolloEmergenzaService.datiObbligatoriPerProtocolloEmergenza(it)) {
                            protocolloService.protocolla(protocolloEmergenza)
                            if (protocolloEmergenza.iter == null) {
                                wkfIterService.istanziaIter(protocolloEmergenza.tipoProtocollo.getCfgIter(), protocolloEmergenza)
                            }
                            inviaSmistamenti(protocolloEmergenza, true)
                            statoEmergenza = "K"
                        } else {
                            numDocNonProtocollati++
                            statoEmergenza = "O"
                            descrizioneStatoProtocollo = "Dati mancanti o non validi."
                        }
                    }
                    catch (Exception e) {
                        log.error("Errore in fase di protocollazione:", e)
                        statoEmergenza = "E"
                        descrizioneStatoProtocollo = e.getMessage()
                    }
                } else {
                    statoEmergenza = "K"
                    descrizioneStatoEmergenza = "Esiste un protocollo numerato con date di inizio e fine emergenza."
                }

                dataInizioReturn = it.dataInizio.toString()
                dataFineReturn = it.dataFine.toString()
                statusReturn = statoEmergenza
                descrizioneStatusReturn = descrizioneStatoEmergenza
            }
            log.debug("Protocollo emergenza con id=" + protocolloEmergenza?.id)

            /* creo i protocolli inclusi nell'xml */
            List xmlProto = []
            if (statoEmergenza == "K" || statoEmergenza == "O") {
                root.protocolli.protocollo.each {
                    //if (validazioneProtocolloEmergenzaService.verificaEsistenzaProtocollo(it) == false) {
                    try {
                        protocolloXml = creaProtocolloDaXml(it, protocolloEmergenza)
                        statoProtocollo = "K"
                        descrizioneStatoProtocollo = ""
                    }
                    catch (Exception e) {
                        log.error("Errore in fase di registrazione:", e)
                        statoProtocollo = "E"
                        descrizioneStatoProtocollo = e.getMessage()
                    }

                    try {
                        if (validazioneProtocolloEmergenzaService.validazione(it) && validazioneProtocolloEmergenzaService.datiObbligatoriPerProtocollo(it)) {
                            protocolloService.protocolla(protocolloXml)
                            if (protocolloXml.iter == null) {
                                wkfIterService.istanziaIter(protocolloXml.tipoProtocollo.getCfgIter(), protocolloXml)
                            }
                            inviaSmistamenti(protocolloXml, true)
                            statoProtocollo = "K"
                        } else {
                            numDocNonProtocollati++
                            statoProtocollo = "O"
                            descrizioneStatoProtocollo = "Dati mancanti o non validi."
                        }
                    }
                    catch (Exception e) {
                        log.error("Errore in fase di protocollazione:", e)
                        statoProtocollo = "E"
                        descrizioneStatoProtocollo = e.getMessage()
                    }
                    //} else {
                    //    statoProtocollo = "O"
                    //    descrizioneStatoProtocollo = "Esiste un documento con anno,numero e registro."
                    //}

                    StrutturaXmlRitorno tempXml = new StrutturaXmlRitorno()
                    tempXml.anno = it.anno.toString()
                    tempXml.numero = it.numero.toString()
                    tempXml.codiceRegistro = it.codiceRegistro.toString()
                    tempXml.status = statoProtocollo
                    tempXml.descrizioneStatus = descrizioneStatoProtocollo
                    xmlProto << tempXml
                }
            }

            /* se almeno un protocollo non è stato protocollato mando una notifica */
            if (numDocNonProtocollati > 0) {
                notificheService.invia(Notifica.findByTipoNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_PROTOCOLLO_EMERGENZA), protocolloEmergenza)
            }

            /* genero l'xml di ritorno */
            def builder = new StreamingMarkupBuilder()
            builder.encoding = 'UTF-8'
            xmlReturn = builder.bind {
                mkp.xmlDeclaration()
                radice {
                    emergenza {
                        dataInizio {
                            mkp.yieldUnescaped((dataInizioReturn ?: ""))
                        }
                        dataFine {
                            mkp.yieldUnescaped((dataFineReturn ?: ""))
                        }
                        status {
                            mkp.yieldUnescaped((statusReturn ?: " "))
                        }
                        descrizioneStatus {
                            mkp.yieldUnescaped((descrizioneStatusReturn ?: ""))
                        }
                    }

                    protocolli {
                        xmlProto.each { proto ->
                            protocollo {
                                anno {
                                    mkp.yieldUnescaped(proto.anno)
                                }
                                numero {
                                    mkp.yieldUnescaped(proto.numero)
                                }
                                codiceRegistro {
                                    mkp.yieldUnescaped(proto.codiceRegistro)
                                }
                                status {
                                    mkp.yieldUnescaped(proto.status)
                                }
                                descrizioneStatus {
                                    mkp.yieldUnescaped(proto.descrizioneStatus)
                                }
                            }
                        }
                    }
                }
            }
        } else {

            /* genero l'xml di ritorno in caso di presenza di numerazione di emergenza */
            def root = new XmlSlurper().parseText(xml)
            root.emergenza.each {
                dataInizioReturn = it.dataInizio.toString()
                dataFineReturn = it.dataFine.toString()
            }

            def builder = new StreamingMarkupBuilder()
            builder.encoding = 'UTF-8'
            xmlReturn = builder.bind {
                mkp.xmlDeclaration()
                radice {
                    emergenza {
                        dataInizio {
                            mkp.yieldUnescaped((dataInizioReturn ?: ""))
                        }
                        dataFine {
                            mkp.yieldUnescaped((dataFineReturn ?: ""))
                        }
                        status {
                            mkp.yieldUnescaped(("E"))
                        }
                        descrizioneStatus {
                            mkp.yieldUnescaped(("Numerazione gia' presente"))
                        }
                    }
                }
            }
        }

        if (log.isInfoEnabled()) {
            log.info(XmlUtil.serialize(xmlReturn))
        }
        return XmlUtil.serialize(xmlReturn)
    }

    private Protocollo creaProtocolloEmergenza(def protocolloXml, InputStream is) throws Exception {

        Protocollo protocollo = new Protocollo()
        protocollo.dateCreated = new Date()
        protocollo.oggetto = protocolloXml.oggetto.toString()

        TipoProtocollo tipoProtocollo = dizionariRepository.getTipoProtocollo(Protocollo.CATEGORIA_EMERGENZA)
        protocollo.tipoProtocollo = tipoProtocollo

        // schema protocollo
        if (protocolloXml.codiceTipoDocumento.toString().size() > 0 && protocolloXml.codiceTipoDocumento.toString() != "null") {
            if (validazioneProtocolloEmergenzaService.isTipoDocumentoValido(protocolloXml.codiceTipoDocumento.toString())) {
                SchemaProtocollo schemaProtocollo = dizionariRepository.getSchemaProtocollo(protocolloXml.codiceTipoDocumento.toString())
                if (schemaProtocollo) {
                    protocollo.schemaProtocollo = schemaProtocollo
                }
            }
        }

        // classificazione
        if (protocolloXml.codiceClassificazione.toString().size() > 0 && protocolloXml.codiceClassificazione.toString() != "null") {
            if (validazioneProtocolloEmergenzaService.isClassificazioneValida(protocolloXml.codiceClassificazione.toString())) {
                Classificazione classificazione = classificazioneRepository.getClassificazioneValida(protocolloXml.codiceClassificazione.toLong(), new Date())
                if (classificazione) {
                    protocollo.classificazione = classificazione
                }
            }
        }

        // fascicolo
        if (protocolloXml.fascicoloAnno.toString().size() > 0 && protocolloXml.fascicoloNumero.toString().size() > 0 && protocolloXml.codiceClassificazione.toString().size() > 0) {
            if (validazioneProtocolloEmergenzaService.isFascicoloValido(protocolloXml.codiceClassificazione.toString(), protocolloXml.fascicoloAnno.toString(), protocolloXml.fascicoloNumero.toString())) {
                if (protocolloXml.fascicoloNumero.toString() != "" && protocolloXml.fascicoloNumero.toString().size() > 0) {
                    Fascicolo fascicolo = fascicoloRepository.getFascicolo(protocolloXml.codiceClassificazione.toLong(), protocolloXml.fascicoloAnno.toInteger(), protocolloXml.fascicoloNumero.toString())
                    if (fascicolo) {
                        protocollo.fascicolo = fascicolo
                    }
                }
            }
        }

        protocollo.tipoOggetto = it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto.findByCodice("PROTOCOLLO")
        protocollo.movimento = Protocollo.MOVIMENTO_INTERNO
        protocollo.dataRedazione = new Date()
        //protocollo.note = "Id riferimento client = " + protocolloXml.id.toString()

        // uo protocollante - redattore
        if (protocolloXml.unita.toString().size() > 0) {
            if (validazioneProtocolloEmergenzaService.isUnitaValida(protocolloXml.unita.toString(), protocolloXml.ottica.toString())) {
                protocollo.setSoggetto(TipoSoggetto.UO_PROTOCOLLANTE, null, so4Repository.getUnita(protocolloXml.unita.toLong(), protocolloXml.ottica.toString(), new Date()))
                protocollo.setSoggetto(TipoSoggetto.REDATTORE, ad4Repository.getUtente(protocolloXml.utente.toString()), so4Repository.getUnita(protocolloXml.unita.toLong(), protocolloXml.ottica.toString(), new Date()))
            }
        }

        ProtocolloDatiEmergenza datiEmergenza = createDatiEmergenza(protocolloXml)
        protocollo.datiEmergenza = datiEmergenza

        protocollo.save()

        new DocumentoCompetenze(documento: protocollo, utenteAd4: ad4Repository.getUtente(protocolloXml.utente.toString()), lettura: true, modifica: true, cancellazione: true).save()

        protocolloService.salva(protocollo)

        setFilePrincipale(protocollo, is)

        //protocolloService.protocolla(protocollo)

        return protocollo
    }

    private Protocollo creaProtocolloDaXml(def protocolloXml, Protocollo protocolloEmergenza) throws Exception {

        Protocollo protocollo = protocolloRepository.getProtocolloEmergenza(protocolloXml.numero.toInteger(), protocolloXml.anno.toInteger(), protocolloXml.codiceRegistro.toString())
        if (protocollo == null) {
            protocollo = new Protocollo()
        }

        protocollo.data = new Date().parse("yyyy-M-d H:m:s", protocolloXml.data.toString())
        protocollo.dateCreated = new Date().parse("yyyy-M-d H:m:s", protocolloXml.data.toString())

        protocollo.oggetto = protocolloXml.oggetto.toString()

        protocollo.annoEmergenza = protocolloXml.anno.toInteger()
        protocollo.numeroEmergenza = protocolloXml.numero.toInteger()
        protocollo.registroEmergenza = protocolloXml.codiceRegistro.toString()

        if (protocolloXml.dataDocEsterno.toString().size() > 0 || protocolloXml.dataDocEsterno.toString() != "") {
            protocollo.dataDocumentoEsterno = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataDocEsterno.toString())
        }

        if (protocolloXml.numDocEsterno.toString().size() > 0 || protocolloXml.numDocEsterno.toString() != "") {
            protocollo.numeroDocumentoEsterno = protocolloXml.numDocEsterno.toString()
        }
        TipoProtocollo tipoProtocollo = dizionariRepository.getTipoProtocollo(Protocollo.CATEGORIA_PROTOCOLLO)

        protocollo.tipoProtocollo = tipoProtocollo

        // schema protocollo
        if (protocolloXml.codiceTipoDocumento.toString().size() > 0 && protocolloXml.codiceTipoDocumento.toString() != "null") {
            if (validazioneProtocolloEmergenzaService.isTipoDocumentoValido(protocolloXml.codiceTipoDocumento.toString())) {
                SchemaProtocollo schemaProtocollo = dizionariRepository.getSchemaProtocollo(protocolloXml.codiceTipoDocumento.toString())
                if (schemaProtocollo) {
                    protocollo.schemaProtocollo = schemaProtocollo
                }
            }
        }

        // classificazione
        if (protocolloXml.codiceClassificazione.toString().size() > 0 && protocolloXml.codiceClassificazione.toString() != "null") {
            if (validazioneProtocolloEmergenzaService.isClassificazioneValida(protocolloXml.codiceClassificazione.toString())) {
                Classificazione classificazione = classificazioneRepository.getClassificazioneValida(protocolloXml.codiceClassificazione.toLong(), new Date())
                if (classificazione) {
                    protocollo.classificazione = classificazione
                }
            }
        }

        // fascicolo
        if (protocolloXml.fascicoloAnno.toString().size() > 0 && protocolloXml.fascicoloNumero.toString().size() > 0 && protocolloXml.codiceClassificazione.toString().size() > 0) {
            if (validazioneProtocolloEmergenzaService.isFascicoloValido(protocolloXml.codiceClassificazione.toString(), protocolloXml.fascicoloAnno.toString(), protocolloXml.fascicoloNumero.toString())) {
                if (protocolloXml.fascicoloNumero.toString() != "" && protocolloXml.fascicoloNumero.toString().size() > 0) {
                    Fascicolo fascicolo = fascicoloRepository.getFascicolo(protocolloXml.codiceClassificazione.toLong(), protocolloXml.fascicoloAnno.toInteger(), protocolloXml.fascicoloNumero.toString())
                    if (fascicolo) {
                        protocollo.fascicolo = fascicolo
                    }
                }
            }
        }

        protocollo.tipoOggetto = it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto.findByCodice("PROTOCOLLO")
        protocollo.movimento = protocolloXml.tipoMovimento.toString().toUpperCase().trim()
        protocollo.dataRedazione = new Date()
        //protocollo.note = "Id riferimento client = " + protocolloXml.id.toString()

        // uo protocollante - redattore
        if (protocolloXml.unita.toString().size() > 0) {
            if (validazioneProtocolloEmergenzaService.isUnitaValida(protocolloXml.unita.toString(), protocolloXml.ottica.toString())) {
                protocollo.setSoggetto(TipoSoggetto.UO_PROTOCOLLANTE, null, so4Repository.getUnita(protocolloXml.unita.toLong(), protocolloXml.ottica.toString(), new Date()))
                protocollo.setSoggetto(TipoSoggetto.REDATTORE, ad4Repository.getUtente(protocolloXml.utente.toString()), so4Repository.getUnita(protocolloXml.unita.toLong(), protocolloXml.ottica.toString(), new Date()))
            }
        }

        // modalità invio ricezione
        ModalitaInvioRicezione modalitaInvioRicezione
        if (protocolloXml.codiceModRic.toString().size() > 0) {
            if (validazioneProtocolloEmergenzaService.isModalitaRicevimentoValida(protocolloXml.codiceModRic.toString())) {
                if (protocolloXml.codiceModRic.toString().size() > 0) {
                    modalitaInvioRicezione = dizionariRepository.getModalitaInvioRicezione(protocolloXml.codiceModRic.toString())
                    protocollo.modalitaInvioRicezione = modalitaInvioRicezione
                }
            }
        }

        if (protocolloXml.dataArrivoSpedizione.toString().size() > 0) {
            protocollo.dataComunicazione = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataArrivoSpedizione.toString())
        }

        protocollo.save()

        new DocumentoCompetenze(documento: protocollo, utenteAd4: ad4Repository.getUtente(protocolloXml.utente.toString()), lettura: true, modifica: true, cancellazione: true).save()

        protocollo.save()
        protocolloService.salva(protocollo)

        if (protocolloXml.tipoSmistamento.toString().size() > 0 && protocolloXml.tipoSmistamento.toString() != "") {
            setSmistamenti(protocollo, protocolloXml)
        }

        setCorrispondenti(protocollo, protocolloXml)
        setCollegamenti(protocolloEmergenza, protocollo)
        protocolloService.salva(protocollo)

        setUltimoNumeroRegistroEmergenza(protocolloXml.numero.toInteger(), protocolloXml.anno.toInteger(), protocolloXml.codiceRegistro.toString(), protocolloXml.unita.toString(), protocolloXml.ottica.toString())

        //protocolloService.protocolla(protocollo)

        //if (protocollo?.numero > 0) {
        //    setUltimoNumeroRegistroEmergenza(protocolloXml.numero.toInteger(), protocolloXml.anno.toInteger(), protocolloXml.codiceRegistro.toString(), protocolloXml.unita.toString(),protocolloXml.ottica.toString())
        //}

        return protocollo
    }

    ProtocolloDatiEmergenza createDatiEmergenza(def protocolloXml) throws Exception {
        ProtocolloDatiEmergenza protocolloDatiEmergenza = new ProtocolloDatiEmergenza()
        protocolloDatiEmergenza.dataInizioEmergenza = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataInizio.toString())
        protocolloDatiEmergenza.dataFineEmergenza = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataFine.toString())
        protocolloDatiEmergenza.motivoEmergenza = protocolloXml.causa.toString()
        protocolloDatiEmergenza.provvedimentoEmergenza = protocolloXml.provvedimento.toString()
        protocolloDatiEmergenza.utenteIns = ad4Repository.getUtente(protocolloXml.utente.toString())
        protocolloDatiEmergenza.utenteUpd = ad4Repository.getUtente(protocolloXml.utente.toString())
        protocolloDatiEmergenza.save()

        return protocolloDatiEmergenza
    }

    private void setFilePrincipale(Protocollo protocollo, InputStream is) throws Exception {
        FileDocumento filePrincipale = new FileDocumento(nome: 'XML_protocollo_di_emergenza.xml', contentType: 'application/octet-stream', codice: FileDocumento.CODICE_FILE_PRINCIPALE)
        protocollo.addToFileDocumenti(filePrincipale)
        protocollo.save()
        gestoreFile.addFile(protocollo, filePrincipale, is)
        filePrincipale.save()
    }

    private void setSmistamenti(Protocollo protocollo, def protocolloXml) throws Exception {
        boolean componente = true
        if (validazioneProtocolloEmergenzaService.isUnitaValida(protocolloXml.codiceUnitaSmistamento.toString(), protocolloXml.ottica.toString())) {
            if (protocolloXml.soggettoUtenteAssegnatario.toString().size() > 0) {
                componente = validazioneProtocolloEmergenzaService.isComponenteValido(protocolloXml.soggettoUtenteAssegnatario.toString(), protocolloXml.ottica.toString())
            }

            if (componente) {
                Smistamento smistamento = new Smistamento()
                smistamento.documento = protocollo
                smistamento.tipoSmistamento = protocolloXml.tipoSmistamento.toString().toUpperCase().trim()

                smistamento.unitaTrasmissione = so4Repository.getUnita(protocolloXml.unita.toLong(), protocolloXml.ottica.toString(), new Date())
                smistamento.unitaSmistamento = so4Repository.getUnita(protocolloXml.codiceUnitaSmistamento.toLong(), protocolloXml.ottica.toString(), new Date())

                smistamento.statoSmistamento = Smistamento.DA_RICEVERE
                smistamento.dataSmistamento = new Date().parse("yyyy-M-d H:m:s", protocolloXml.data.toString())
                smistamento.utenteTrasmissione = ad4Repository.getUtente(protocolloXml.utente.toString())

                if (protocolloXml.codiceUtenteAssegnatario.toString().length() > 0) {
                    smistamento.utenteAssegnatario = ad4Repository.getUtente(protocolloXml.codiceUtenteAssegnatario.toString())
                    smistamento.utenteAssegnante = ad4Repository.getUtente(protocolloXml.utente.toString())
                    smistamento.dataAssegnazione = new Date().parse("yyyy-M-d H:m:s", protocolloXml.data.toString())
                }

                smistamento.save()
                protocolloGdmService.salvaSmistamento(smistamento)
            }
        }
    }

    private void setCollegamenti(Protocollo documento, Protocollo collegato) throws Exception {
        TipoCollegamento tipoCollegamento = dizionariRepository.getTipoCollegamento(TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_EMERGENZA)
        DocumentoCollegato documentoCollegato = new DocumentoCollegato()
        documentoCollegato.documento = documento
        documentoCollegato.collegato = collegato
        documentoCollegato.tipoCollegamento = tipoCollegamento
        documentoCollegato.save()
        protocolloGdmService.salvaDocumentoCollegamento(documento, collegato, TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_EMERGENZA)
    }

    private void setCorrispondenti(Protocollo protocollo, def protocolloXml) throws Exception {

        ModalitaInvioRicezione modalitaInvioRicezione
        if (protocolloXml.codiceModRic.toString().size() > 0) {
            if (validazioneProtocolloEmergenzaService.isModalitaRicevimentoValida(protocolloXml.codiceModRic.toString())) {
                if (protocolloXml.codiceModRic.toString().size() > 0) {
                    modalitaInvioRicezione = dizionariRepository.getModalitaInvioRicezione(protocolloXml.codiceModRic.toString())
                }
            }
        }

        it.finmatica.protocollo.corrispondenti.TipoSoggetto tipoSoggetto

        Corrispondente corrispondente = new Corrispondente()
        corrispondente.protocollo = protocollo
        corrispondente.modalitaInvioRicezione = modalitaInvioRicezione

        if (protocolloXml.dataArrivoSpedizione.toString().size() > 0 && protocolloXml.dataArrivoSpedizione.toString() != "") {
            corrispondente.dataSpedizione = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataArrivoSpedizione.toString())
        }

        tipoSoggetto = dizionariRepository.getTipoSoggetto("Altri Soggetti")
        corrispondente.denominazione = protocolloXml.cognomeCodAmm.toString().toUpperCase().trim() + " " + protocolloXml.nomeCodAoo.toString().toUpperCase().trim()
        corrispondente.cognome = protocolloXml.cognomeCodAmm.toString().toUpperCase().trim()
        corrispondente.nome = protocolloXml.nomeCodAoo.toString().toUpperCase().trim()
        corrispondente.tipoIndirizzo = "RESIDENZA"
        corrispondente.tipoSoggetto = tipoSoggetto

        if (protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
            corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO
        } else {
            corrispondente.tipoCorrispondente = Corrispondente.MITTENTE
        }

        corrispondente.save()
        protocolloGdmService.salvaCorrispondente(corrispondente, false)

        // non vengono più inserite AOO
        /*
        if (protocolloXml.mittDest.toString() == "A") {

            if (validazioneProtocolloEmergenzaService.isAmministrazioneValida(protocolloXml.cognomeCodAmm.toString())) {

                So4AOO so4AOO
                if (protocolloXml.nomeCodAoo.toString().size() > 0) {
                    if (validazioneProtocolloEmergenzaService.isAooValida(protocolloXml.nomeCodAoo.toString(), protocolloXml.cognomeCodAmm.toString())) {
                        so4AOO = so4Repository.getAoo(protocolloXml.nomeCodAoo.toString().toUpperCase().trim(), protocolloXml.cognomeCodAmm.toString().toUpperCase().trim())
                    }
                }

                As4SoggettoCorrente soggetto = so4Repository.getSoggettoAoo(protocolloXml.cognomeCodAmm.toString().toUpperCase().trim())

                Corrispondente corrispondente = new Corrispondente()
                corrispondente.protocollo = protocollo
                corrispondente.modalitaInvioRicezione = modalitaInvioRicezione

                if (so4AOO) {
                    corrispondente.denominazione = soggetto?.cognome + ":AOO:" + so4AOO?.descrizione
                    corrispondente.cognome = so4AOO?.descrizione
                } else {
                    corrispondente.denominazione = soggetto?.cognome
                }

                corrispondente.indirizzo = soggetto?.indirizzoResidenza
                corrispondente.cap = soggetto?.capResidenza
                corrispondente.comune = soggetto?.comuneResidenza
                corrispondente.provinciaSigla = soggetto?.provinciaResidenza
                corrispondente.email = soggetto?.indirizzoWeb
                corrispondente.tipoIndirizzo = "RESIDENZA"

                if (protocolloXml.dataArrivoSpedizione.toString().size() > 0 && protocolloXml.dataArrivoSpedizione.toString() != "") {
                    corrispondente.dataSpedizione = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataArrivoSpedizione.toString())
                }

                tipoSoggetto = dizionariRepository.getTipoSoggetto("Amministrazioni")
                corrispondente.tipoSoggetto = tipoSoggetto

                if (protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
                    corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO
                } else {
                    corrispondente.tipoCorrispondente = Corrispondente.MITTENTE
                }

                corrispondente.save()

                protocolloGdmService.salvaCorrispondente(corrispondente, false)

                if (corrispondente) {
                    List<IndirizzoDTO> listaIndirizzi = corrispondenteService.getIndirizziAmministrazione(protocolloXml.cognomeCodAmm.toString().toUpperCase().trim(), protocolloXml.nomeCodAoo.toString().toUpperCase().trim(), null)
                    listaIndirizzi.each {
                        Indirizzo indirizzo = new Indirizzo()
                        indirizzo.corrispondente = corrispondente
                        indirizzo.denominazione = soggetto.denominazione
                        indirizzo.indirizzo = it.indirizzo
                        indirizzo.cap = it.cap
                        indirizzo.comune = it.comune
                        indirizzo.provinciaSigla = it.provinciaSigla
                        indirizzo.email = it.email
                        indirizzo.fax = it.fax
                        indirizzo.tipoIndirizzo = it.tipoIndirizzo
                        indirizzo.codice = it.codice
                        indirizzo.save()
                        protocolloGdmService.salvaCorrispondente(corrispondente, false)
                    }
                }
            }
        } else {
            Corrispondente corrispondente = new Corrispondente()
            corrispondente.protocollo = protocollo
            corrispondente.modalitaInvioRicezione = modalitaInvioRicezione

            if (protocolloXml.dataArrivoSpedizione.toString().size() > 0 && protocolloXml.dataArrivoSpedizione.toString() != "") {
                corrispondente.dataSpedizione = new Date().parse("yyyy-M-d H:m:s", protocolloXml.dataArrivoSpedizione.toString())
            }

            tipoSoggetto = dizionariRepository.getTipoSoggetto("Altri Soggetti")
            corrispondente.denominazione = protocolloXml.cognomeCodAmm.toString().toUpperCase().trim() + " " + protocolloXml.nomeCodAoo.toString().toUpperCase().trim()
            corrispondente.cognome = protocolloXml.cognomeCodAmm.toString().toUpperCase().trim()
            corrispondente.nome = protocolloXml.nomeCodAoo.toString().toUpperCase().trim()
            corrispondente.tipoIndirizzo = "RESIDENZA"
            corrispondente.tipoSoggetto = tipoSoggetto

            if (protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
                corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO
            } else {
                corrispondente.tipoCorrispondente = Corrispondente.MITTENTE
            }

            corrispondente.save()
            protocolloGdmService.salvaCorrispondente(corrispondente, false)
        }
    */
    }

    private void setUltimoNumeroRegistroEmergenza(int numeroEmergenza, int annoEmergenza, String registroEmergenza, String unita, String ottica) {

        So4UnitaPubb unitaEmergenza = so4Repository.getUnita(unita.toLong(), ottica.toString(), new Date())

        Ricerca criteriRicerca = new Ricerca()
        criteriRicerca.setMappaChiaviExtra([AREA: "SEGRETERIA", MODELLO: "DIZ_REGISTRI"])

        criteriRicerca.aggiungi(Condizioni.eq("ANNO_REG", annoEmergenza)).
                aggiungi(Condizioni.eq("TIPO_REGISTRO", registroEmergenza)).
                aggiungi(Condizioni.eq("UNITA_EMERGENZA", unitaEmergenza.codice));

        List<Documento> documentoList = documentaleService.ricerca(criteriRicerca);

        if (documentoList.size() > 0) {
            Documento documentoSmart = new Documento(id: String.valueOf(documentoList.get(0).getId()))
            documentoSmart.addCampo(new Campo("ULTIMO_NUMERO_REG", numeroEmergenza))
            documentaleService.salvaDocumento(documentoSmart)
        }
    }

    void inviaSmistamenti(ISmistabile smistabile, escludiControlloCompetenze) {
        So4UnitaPubb unitaProtocollante = smistabile?.getUnita()
        So4UnitaPubb unitaSmistamentoTmp = null

        List<Smistamento> smistamentoList = Smistamento.createCriteria().list {
            eq("valido", true)
            eq("documento", smistabile)
        }

        smistamentoList.each {
            if (unitaProtocollante.codice != it.unitaTrasmissione?.codice) {
                it.unitaTrasmissione = unitaProtocollante
            }
            if (it.utenteAssegnante == null) {
                if (unitaSmistamentoTmp?.codice == it.unitaSmistamento?.codice) {
                    throw new ProtocolloRuntimeException("Non è possibile creare più smistamenti alla stessa unità:" + unitaSmistamentoTmp.descrizione)
                }
                unitaSmistamentoTmp = it.unitaSmistamento
            }
            smistamentoService.creaSmistamentoInProtocollazione(it, smistabile.data, escludiControlloCompetenze)
        }
    }
}