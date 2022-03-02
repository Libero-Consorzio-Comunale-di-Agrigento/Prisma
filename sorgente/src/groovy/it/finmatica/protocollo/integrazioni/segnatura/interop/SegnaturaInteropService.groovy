package it.finmatica.protocollo.integrazioni.segnatura.interop

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Indirizzo
import it.finmatica.protocollo.corrispondenti.IndirizzoDTO
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.segnatura.interop.ente.suap.xsd.CooperazioneEnteSuap
import it.finmatica.protocollo.integrazioni.segnatura.interop.postacert.xsd.Postacert
import it.finmatica.protocollo.integrazioni.segnatura.interop.suap.ente.xsd.CooperazioneSuapEnte
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AOO
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AggiornamentoConferma
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Allegati
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Amministrazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AnnullamentoProtocollazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.CAP
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Civico
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.CodiceAOO
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.CodiceAmministrazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.CodiceFiscale
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.CodiceRegistro
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Cognome
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Comune
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.ConfermaRicezione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.DataRegistrazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Denominazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Descrizione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Destinatario
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Destinazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Documento
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Fax
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Identificatore
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.IndirizzoPostale
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.IndirizzoTelematico
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.InterventoOperatore
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Intestazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Mittente
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Motivo
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Nome
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.NotificaEccezione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.NumeroRegistrazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Oggetto
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Origine
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Persona
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Provincia
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.RiferimentoDocumentiCartacei
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Risposta
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Segnatura
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Telefono
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.TestoDelMessaggio
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.UnitaOrganizzativa
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import it.finmatica.segreteria.common.StringUtility

import javax.xml.bind.JAXBContext
import javax.xml.bind.JAXBElement
import javax.xml.bind.Marshaller
import javax.xml.bind.Unmarshaller
import javax.xml.datatype.DatatypeFactory
import javax.xml.datatype.XMLGregorianCalendar
import javax.xml.stream.XMLInputFactory
import javax.xml.stream.XMLStreamReader
import javax.xml.stream.util.StreamReaderDelegate

@Slf4j
@Service
class SegnaturaInteropService {
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    So4Repository so4Repository
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService

    private static final String FORMATO_DATE_SEGNATURA = "yyyy-MM-dd"
    private static final String TIPO_INDIRIZZO_TELEMATICO = "smtp"
    private static final String TIPO_RIFERIMENTO_DOCUMENTO_TELEMATICO = "telematico"
    private static final String TIPO_RIFERIMENTO_DOCUMENTO_MIME = "MIME"
    private static final String TIPO_RIFERIMENTO_DOCUMENTO_CARTACEO = "cartaceo"

    private Protocollo protocollo
    private Messaggio messaggio
    private boolean segnaturaCompleta, confermaRicezione, interventoOperatore
    private String casellaRisposta
    private PublicStorageService publicStorage

    public String produciSegnatura(Protocollo protocollo, Messaggio messaggio, boolean segnaturaCompleta, boolean confermaRicezione, boolean interventoOperatore, boolean isImpresaInUnGiorno = false) {
        this.protocollo = protocollo
        this.messaggio = messaggio
        this.segnaturaCompleta = segnaturaCompleta
        this.confermaRicezione = confermaRicezione
        this.interventoOperatore = interventoOperatore
        casellaRisposta = ImpostazioniProtocollo.CASELLA_RISPOSTA.valore
        if (isImpresaInUnGiorno) {
            produciSegnaturaSuap()
        } else {
           produci()
        }

    }

    public String produciSegnatura(Protocollo protocollo, boolean segnaturaCompleta, boolean confermaRicezione, boolean interventoOperatore) {
        this.protocollo = protocollo
        this.segnaturaCompleta = segnaturaCompleta
        this.confermaRicezione = confermaRicezione
        this.interventoOperatore = interventoOperatore
        return produci()
    }

    /**
     * Metodo per genereare entesuap.xml che
     * sostituisce la Segnatura.xml nei messaggi al suap
     *
     * @param protocollo protocollo in partenza
     * @return entesuap.xml
     */
    public String produciSegnaturaSuap() {
        FileDocumento fileDocumento = getCooperazioneSuapEnte(protocollo)
        CooperazioneSuapEnte cooperazioneSuapEnte = getCooperazioneSuapEnteFromFileDocumento(fileDocumento)
        produciSegnaturaSuapXML(cooperazioneSuapEnte)
    }


    /**
     * Metodo per individuare suapente.xml da cui
     * copiare i valori da scrivere in entesuap.xml
     * @param protocollo protocollo in partenza
     * @return suapente.xml unmarshalled
     */
    private FileDocumento getCooperazioneSuapEnte(Protocollo protocollo) {
        //da protocollo in partenza ricavo il precedente in arrivo
        //di cui cerco il messaggio che l'ha generato
        //per caricare l'allegato Suapente.xml
        Protocollo protocolloPrecedente = protocollo.getProtocolloPrecedente()
        DocumentoCollegato documentoCollegato = messaggiRicevutiService.getCollegamentoMessaggioProtocollo(protocolloPrecedente, MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL)
        MessaggioRicevuto messaggioRicevuto = (MessaggioRicevuto) documentoCollegato.documento
        FileDocumento fileDocumento = messaggioRicevuto.fileDocumenti.find {
            it.nome.trim().toLowerCase().equals("suapente.xml")
        }
    }

    /**
     * Cerca nel documentale il file suapente.xml e ne fa unmarshalling
     * @param fileDocumento
     * @return
     */
    private CooperazioneSuapEnte getCooperazioneSuapEnteFromFileDocumento(FileDocumento fileDocumento) {
        CooperazioneSuapEnte cooperazioneSuapEnte
        if (fileDocumento != null) {

            File file
            file = new java.io.File()
            file.setId("" + fileDocumento.idFileEsterno)
            file = documentaleService.getFile(new it.finmatica.smartdoc.api.struct.Documento(), file)

            cooperazioneSuapEnte = getCooperazioneSuapEnteFromStream(file?.inputStream)
        }
        cooperazioneSuapEnte
    }

    private CooperazioneEnteSuap.InfoSchema produciInfoSchemaSuap() {
        log.debug("SegnaturaInteropService.produciInfoSchemaSuap con protocollo: " + protocollo.id)
        CooperazioneEnteSuap.InfoSchema infoSchema = new CooperazioneEnteSuap.InfoSchema()
        infoSchema.setVersione("1.1.0")
        XMLGregorianCalendar dataInfoSchema = DatatypeFactory.newInstance().newXMLGregorianCalendar(new GregorianCalendar(2020,4,10))
        infoSchema.setData(dataInfoSchema)
    }

    private CooperazioneEnteSuap.Intestazione.EnteMittente produciEnteMittenteSuap(CooperazioneSuapEnte.Intestazione.EnteDestinatario enteDestinatario) {
        CooperazioneEnteSuap.Intestazione.EnteMittente enteMittenteSuap = new CooperazioneEnteSuap.Intestazione.EnteMittente()
        enteMittenteSuap.setPec(enteDestinatario.getPec())
        enteMittenteSuap.setValue(enteDestinatario.getValue())
    }

    private CooperazioneEnteSuap.Intestazione.SuapCompetente produciSuapCompetente(CooperazioneSuapEnte.Intestazione.SuapCompetente suapCompetenteArrivo) {
        CooperazioneEnteSuap.Intestazione.SuapCompetente suapCompetente = new CooperazioneEnteSuap.Intestazione.SuapCompetente()
        suapCompetente.setCodiceAmministrazione(suapCompetenteArrivo.getCodiceAmministrazione())
        suapCompetente.setCodiceAoo(suapCompetenteArrivo.getCodiceAoo())
        suapCompetente.setIdentificativoSuap(suapCompetenteArrivo.getIdentificativoSuap())
        suapCompetente.setValue(suapCompetenteArrivo.getValue())
    }

    private CooperazioneEnteSuap.Intestazione.Impresa.FormaGiuridica produciFormaGiuridicaSuap(CooperazioneSuapEnte.Intestazione.Impresa.FormaGiuridica formaGiuridicaArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.FormaGiuridica formaGiuridica = new CooperazioneEnteSuap.Intestazione.Impresa.FormaGiuridica()
        formaGiuridica.setCodice(formaGiuridicaArrivo.getCodice())
        formaGiuridica.setValue(formaGiuridicaArrivo.getValue())
    }

    private CooperazioneEnteSuap.Intestazione.Impresa.CodiceREA produciCodiceREASuap(CooperazioneSuapEnte.Intestazione.Impresa.CodiceREA codiceREAArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.CodiceREA codiceREA = new CooperazioneEnteSuap.Intestazione.Impresa.CodiceREA()
        codiceREA.setProvincia(codiceREAArrivo.getProvincia())
        codiceREA.setValue(codiceREAArrivo.getValue())
    }

    private CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo produciIndirizzoSuap(CooperazioneSuapEnte.Intestazione.Impresa.Indirizzo indirizzoArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo indirizzo = new CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo()
        indirizzo.setStato(produciStatoSuap(indirizzoArrivo.getStato()))
        indirizzo.setProvincia(produciProvinciaSuap(indirizzoArrivo.getProvincia()))
        indirizzo.setComune(produciComuneSuap(indirizzoArrivo.getComune()))
        indirizzo.setDenominazioneStradale(indirizzoArrivo.getDenominazioneStradale())
        indirizzo.setNumeroCivico(indirizzoArrivo.getNumeroCivico())
    }

    CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Comune produciComuneSuap(CooperazioneSuapEnte.Intestazione.Impresa.Indirizzo.Comune comuneArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Comune comune = new CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Comune()
        comune.setCodiceCatastale(comuneArrivo.getCodiceCatastale())
        comune.setValue(comuneArrivo.getValue())
    }

    CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Provincia produciProvinciaSuap(CooperazioneSuapEnte.Intestazione.Impresa.Indirizzo.Provincia provinciaArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Provincia provincia = new CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Provincia()
        provincia.setSigla(provinciaArrivo.getSigla())
        provincia.setValue(provinciaArrivo.getValue())
    }

    CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Stato produciStatoSuap(CooperazioneSuapEnte.Intestazione.Impresa.Indirizzo.Stato statoArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Stato stato = new CooperazioneEnteSuap.Intestazione.Impresa.Indirizzo.Stato()
        stato.setCodice(statoArrivo.getCodice())
        stato.setValue(statoArrivo.getValue())
    }

    CooperazioneEnteSuap.Intestazione.Impresa.LegaleRappresentante.Carica produciCaricaSuap(CooperazioneSuapEnte.Intestazione.Impresa.LegaleRappresentante.Carica caricaArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.LegaleRappresentante.Carica carica = new CooperazioneEnteSuap.Intestazione.Impresa.LegaleRappresentante.Carica()
        carica.setCodice(caricaArrivo.getCodice())
        carica.setValue(caricaArrivo.getValue())
    }

    CooperazioneEnteSuap.Intestazione.Impresa.LegaleRappresentante produciLegaleRappresentanteSuap(CooperazioneSuapEnte.Intestazione.Impresa.LegaleRappresentante legaleRappresentanteArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa.LegaleRappresentante legaleRappresentante = new CooperazioneEnteSuap.Intestazione.Impresa.LegaleRappresentante()
        legaleRappresentante.setCognome(legaleRappresentanteArrivo.getCognome())
        legaleRappresentante.setNome(legaleRappresentanteArrivo.getNome())
        legaleRappresentante.setCodiceFiscale(legaleRappresentanteArrivo.getCodiceFiscale())
        legaleRappresentante.setCarica(produciCaricaSuap(legaleRappresentanteArrivo.getCarica()))
    }

    private CooperazioneEnteSuap.Intestazione.Impresa produciImpresaSuap(CooperazioneSuapEnte.Intestazione.Impresa impresaArrivo) {
        CooperazioneEnteSuap.Intestazione.Impresa impresa = new CooperazioneEnteSuap.Intestazione.Impresa()
        impresa.setFormaGiuridica(produciFormaGiuridicaSuap(impresaArrivo.getFormaGiuridica()))
        impresa.setRagioneSociale(impresaArrivo.getRagioneSociale())
        impresa.setCodiceFiscale(impresaArrivo.getCodiceFiscale())
        impresa.setPartitaIva(impresaArrivo.getPartitaIva())
        impresa.setCodiceREA(produciCodiceREASuap(impresaArrivo.getCodiceREA()))
        impresa.setIndirizzo(produciIndirizzoSuap(impresaArrivo.getIndirizzo()))
        impresa.setLegaleRappresentante(produciLegaleRappresentanteSuap(impresaArrivo.getLegaleRappresentante()))
    }


    private CooperazioneEnteSuap.Intestazione.Protocollo produciProtocolloSuap(Protocollo protocollo) {
        CooperazioneEnteSuap.Intestazione.Protocollo protocolloSuap = new CooperazioneEnteSuap.Intestazione.Protocollo()
        Protocollo protocolloPrecedente = protocollo.getProtocolloPrecedente()
        protocolloSuap.setCodiceAmministrazione(protocolloPrecedente.getEnte().getAmministrazione().getCodice())
        protocolloSuap.setCodiceAoo(protocolloPrecedente.getEnte().getAoo())
        protocolloSuap.setNumeroRegistrazione(protocolloPrecedente.getNumero())
        GregorianCalendar c = new GregorianCalendar();
        c.setTime(protocolloPrecedente.getData());
        XMLGregorianCalendar dataRegistrazione = DatatypeFactory.newInstance().newXMLGregorianCalendar(c);
        protocolloSuap.setDataRegistrazione(dataRegistrazione)
    }

    private CooperazioneEnteSuap.Intestazione produciIntestazioneSuap(CooperazioneSuapEnte.Intestazione intestazioneSuapEnte) {
        log.debug("SegnaturaInteropService.produciIntestazioneSuap con protocollo: " + protocollo.id)
        CooperazioneEnteSuap.Intestazione intestazione = new CooperazioneEnteSuap.Intestazione()
        //attributi di Intestazione
        intestazione.setTotale(intestazioneSuapEnte.getTotale())
        intestazione.setProgressivo(intestazioneSuapEnte.getProgressivo())
        //nodi
        intestazione.setEnteMittente(produciEnteMittenteSuap(intestazioneSuapEnte.enteDestinatario))
        intestazione.setSuapCompetente(produciSuapCompetente(intestazioneSuapEnte.suapCompetente))
        intestazione.setCodicePratica(cooperazioneSuapEnte.getIntestazione().getCodicePratica())
        intestazione.setImpresa(produciImpresaSuap(intestazioneSuapEnte.getImpresa()))
        intestazione.setOggettoPratica(produciOggettoPraticaSuap(intestazioneSuapEnte.getOggettoPratica()))
        intestazione.setProtocolloPraticaSuap(produciProtocolloPraticaSuap(intestazioneSuapEnte.getProtocolloPraticaSuap()))
        intestazione.setOggettoComunicazione(produciOggettoComunicazioneSuap(intestazioneSuapEnte.getOggettoComunicazione()))
        intestazione.setTestoComunicazione(intestazioneSuapEnte.getTestoComunicazione())
        intestazione.setProtocollo(produciProtocolloSuap(protocollo))
    }

    CooperazioneEnteSuap.Intestazione.OggettoComunicazione produciOggettoComunicazioneSuap(CooperazioneSuapEnte.Intestazione.OggettoComunicazione oggettoComunicazioneArrivo) {
        CooperazioneEnteSuap.Intestazione.OggettoComunicazione oggettoComunicazione = new CooperazioneEnteSuap.Intestazione.OggettoComunicazione()
        oggettoComunicazione.setTipoCooperazione(oggettoComunicazioneArrivo.getTipoCooperazione())
        oggettoComunicazione.setValue(oggettoComunicazioneArrivo.getValue())
    }

    CooperazioneEnteSuap.Intestazione.ProtocolloPraticaSuap produciProtocolloPraticaSuap(CooperazioneSuapEnte.Intestazione.ProtocolloPraticaSuap protocolloPraticaSuapArrivo) {
        CooperazioneEnteSuap.Intestazione.ProtocolloPraticaSuap protocolloPraticaSuap = new CooperazioneEnteSuap.Intestazione.ProtocolloPraticaSuap()
        protocolloPraticaSuap.setCodiceAmministrazione(protocolloPraticaSuapArrivo.getCodiceAmministrazione())
        protocolloPraticaSuap.setCodiceAoo(protocolloPraticaSuapArrivo.getCodiceAoo())
        protocolloPraticaSuap.setNumeroRegistrazione(protocolloPraticaSuapArrivo.getNumeroRegistrazione())
        protocolloPraticaSuap.getDataRegistrazione(protocolloPraticaSuapArrivo.getDataRegistrazione())
    }

    CooperazioneEnteSuap.Intestazione.OggettoPratica produciOggettoPraticaSuap(CooperazioneSuapEnte.Intestazione.OggettoPratica oggettoPraticaArrivo) {
        CooperazioneEnteSuap.Intestazione.OggettoPratica oggettoPratica = new CooperazioneEnteSuap.Intestazione.OggettoPratica()
        oggettoPratica.setTipoIntervento(oggettoPraticaArrivo.getTipoIntervento())
        oggettoPratica.setTipoProcedimento(oggettoPraticaArrivo.getTipoProcedimento())
        oggettoPratica.setValue(oggettoPraticaArrivo.getValue())
    }


    /**
    * Genera un elemento Allegato per entesuap.xml, quindi con valori fissi
    * @return CooperazioneEnteSuap.Allegato per entesuap.xml
    */
    CooperazioneEnteSuap.Allegato produciAllegatoEnteSuap() {
        log.debug("SegnaturaInteropService.produciAllegatoEnteSuap con protocollo: " + protocollo.id)

        CooperazioneEnteSuap.Allegato allegato = new CooperazioneEnteSuap.Allegato()
        allegato.setNomeFile("entesuap.xml")
        allegato.setCod("SUXML")
        allegato.setDescrizione("Descrittore pratica XML")
        allegato.setNomeFileOriginale("entesuap.xml")
        allegato.setMime("text/xml")
    }

    private String produciSegnaturaSuapXML(CooperazioneSuapEnte cooperazioneSuapEnte) {
        log.debug("SegnaturaInteropService.produciSegnaturaSuapXML con protocollo: " + protocollo.id)

        CooperazioneEnteSuap cooperazioneEnteSuap = new CooperazioneEnteSuap()
        cooperazioneEnteSuap.setInfoSchema(produciInfoSchemaSuap())
        cooperazioneEnteSuap.setIntestazione(produciIntestazioneSuap(cooperazioneSuapEnte))
        //indica l'allegato entesuap.xml
        cooperazioneEnteSuap.addAllegato(produciAllegatoEnteSuap())
        //file principale
        cooperazioneEnteSuap.addAllegato(produciAllegatoSuap(protocollo.idDocumentoEsterno, protocollo.filePrincipale))
        //altri allegati
        ArrayList<CooperazioneEnteSuap.Allegato> content = produciAllegatiSuap()
        for (CooperazioneEnteSuap.Allegato allegato in content) {
            cooperazioneEnteSuap.addAllegato(allegato)
        }

        //GENERAZIONE DELLA STRINGA DALL'XML
        JAXBContext jaxbContext = JAXBContext.newInstance(CooperazioneEnteSuap.class)
        Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true)

        java.io.StringWriter sw = new StringWriter()

        jaxbMarshaller.marshal(cooperazioneEnteSuap, sw)

        return sw.toString()
    }

    private ArrayList<CooperazioneEnteSuap.Allegato> produciAllegatiSuap() {
        ArrayList<CooperazioneEnteSuap.Allegato> content = new ArrayList<CooperazioneEnteSuap.Allegato>()
        for (allegato in protocollo.getAllegati()) {
            if (allegato.tipoAllegato.codice == TipoAllegato.CODICE_TIPO_STAMPA_UNICA) {
                continue
            }

            for (fileAllegato in allegato.fileDocumenti) {
                CooperazioneEnteSuap.Allegato allegatoSuap = produciAllegatoSuap(allegato.idDocumentoEsterno, fileAllegato)
                allegatoSuap.setDescrizione(allegato.getDescrizione())
                content.add(allegatoSuap)
            }
        }
        content
    }

    CooperazioneEnteSuap.Allegato produciAllegatoSuap(Long idDocumentoEsterno, FileDocumento fileDocumento) {
        CooperazioneEnteSuap.Allegato allegatoSuap = new CooperazioneEnteSuap.Allegato()
        it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()

        ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI> componentiArrayList = new ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI>()
        componentiArrayList.add(it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.FILE)
        documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        documentoSmart.setId(String.valueOf(idDocumentoEsterno))
        documentoSmart = documentaleService.getDocumento(documentoSmart, componentiArrayList)
        File fileSmart = documentoSmart.trovaFile(new File(fileDocumento.nome))
        if (fileSmart?.isVisibile() && !fileDocumento.nome.equals("segnatura.xml" && !fileDocumento.nome.equals("LETTERAUNIONE.RTFHIDDEN"))) {
            allegatoSuap.setNomeFile(fileDocumento.nome)
            allegatoSuap.setCod("ALLEG")
            allegatoSuap.setDescrizione("")
            allegatoSuap.setNomeFileOriginale(fileDocumento.nome)
            allegatoSuap.setMime(fileDocumento.getContentType())
        }
    }

    public String produciConferma(Protocollo protocollo, boolean soloSeRicezioneConferma) {
        this.protocollo = protocollo
        return produciConfermaXML(soloSeRicezioneConferma)
    }

    public String produciEccezione(Protocollo protocollo) {
        this.protocollo = protocollo
        return produciEccezioneXML()
    }

    private String produciEccezioneXML() {
        log.debug("SegnaturaInteropService.produciEccezioneXML con protocollo: " + protocollo.id + " e identificatore:" + identificatore)

        Segnatura segnatura = getSegnaturaProtocollo(false)
        NotificaEccezione notificaEccezione = new NotificaEccezione()
        if (segnatura != null) {
            notificaEccezione.messaggioRicevuto = produciMessaggioRicevuto(segnatura.intestazione?.identificatore)
        }
        notificaEccezione.motivo = produciMotivo(protocollo?.datiInteroperabilita?.motivoInterventoOperatore)

        JAXBContext jaxbContext = JAXBContext.newInstance(NotificaEccezione.class)
        Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true)
        java.io.StringWriter sw = new StringWriter()

        jaxbMarshaller.marshal(notificaEccezione, sw)

        return sw.toString()
    }

    private String produciConfermaXML(boolean soloSeRicezioneConferma) {
        log.debug("SegnaturaInteropService.produciConfermaXML con protocollo: " + protocollo.id + " e soloSeRicezioneConferma:" + soloSeRicezioneConferma)

        Segnatura segnatura = getSegnaturaProtocollo()

        boolean confermaRicezioneFlag = false
        for (destinazione in segnatura.intestazione.destinazione) {
            if (destinazione.confermaRicezione == "si") {
                for (destinatario in destinazione.getDestinatario()) {
                    if (destinatario.amministrazione?.codiceAmministrazione?.content != null &&
                            destinatario.amministrazione.codiceAmministrazione.content == protocollo.ente?.amministrazione?.codice) {
                        confermaRicezioneFlag = true
                    }
                }
            }
        }

        log.debug("SegnaturaInteropService.produciConfermaXML confermaRicezioneFlag vale " + confermaRicezioneFlag)
        if (soloSeRicezioneConferma && !confermaRicezioneFlag) {
            log.debug("SegnaturaInteropService.produciConfermaXML E' stata richiesta la presenza una conferma di ricezione " +
                    "ma non è stata trovata sulla segnatura di partenza. Torno una segnatura vuota")
            return ""
        } else {
            log.debug("SegnaturaInteropService.produciConfermaXML Creo la segnatura di conferma")
            ConfermaRicezione confermaRicezione = new ConfermaRicezione()
            confermaRicezione.setIdentificatore(produciIdentificatore())

            it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.MessaggioRicevuto messaggioRicevutoXSD =
                    new it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.MessaggioRicevuto()
            messaggioRicevutoXSD.setIdentificatore(produciIdentificatore(segnatura?.intestazione?.identificatore))

            confermaRicezione.setMessaggioRicevuto(messaggioRicevutoXSD)

            JAXBContext jaxbContext = JAXBContext.newInstance(ConfermaRicezione.class)
            Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
            jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true)
            java.io.StringWriter sw = new StringWriter()

            jaxbMarshaller.marshal(confermaRicezione, sw)

            return sw.toString()
        }
    }

    private Segnatura getSegnaturaProtocollo(boolean erroreSegnaturaNonTrovata = true) {
        log.debug("SegnaturaInteropService.getSegnaturaProtocollo Cerco il messaggio in arrivo collegato al protocollo")
        DocumentoCollegato documentoMailRicevuto
        documentoMailRicevuto = documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo,
                TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))
        if (documentoMailRicevuto == null || !(documentoMailRicevuto?.documento instanceof MessaggioRicevuto)) {
            log.debug("SegnaturaInteropService.getSegnaturaProtocollo Errore in produciConfermaXML: non trovo il messaggio ricevuto collegato al protocollo")
            throw new Exception(
                    "Errore in getSegnaturaProtocollo: non trovo il messaggio ricevuto collegato al protocollo");
        }

        MessaggioRicevuto messaggioRicevuto = (MessaggioRicevuto) documentoMailRicevuto.documento
        log.debug("SegnaturaInteropService.getSegnaturaProtocollo Messaggio in arrivo trovato. Ha id: " + messaggioRicevuto.id)
        FileDocumento fileDocumentoSegnatura =
                messaggioRicevuto.fileDocumenti.find {
                    it.nome.toLowerCase().trim().equals("segnatura.xml") || it.nome.toLowerCase().trim().equals("segnatura_cittadino.xml")
                }

        log.debug("SegnaturaInteropService.getSegnaturaProtocollo Recupero la segnatura allegata al messaggio di partenza")
        if (fileDocumentoSegnatura == null && erroreSegnaturaNonTrovata) {
            log.debug("SegnaturaInteropService.getSegnaturaProtocollo Errore in produciConfermaXML: " +
                    "non trovo l'allegato segnatura del messaggio ricevuto collegato al protocollo")
            throw new Exception(
                    "Errore in getSegnaturaProtocollo: non trovo l'allegato segnatura del messaggio ricevuto collegato al protocollo");
        }

        InputStream isSegnatura = null

        if (fileDocumentoSegnatura != null) {
            isSegnatura = gestoreFile.getFile(new it.finmatica.gestionedocumenti.documenti.Documento(), fileDocumentoSegnatura)
        }

        if (isSegnatura == null && erroreSegnaturaNonTrovata) {
            log.debug("SegnaturaInteropService.getSegnaturaProtocollo Errore in produciConfermaXML: " +
                    "non riesco a recuperare l'allegato segnatura del messaggio ricevuto collegato al protocollo.")
            throw new Exception(
                    "Errore in getSegnaturaProtocollo: non riesco a recuperare l'allegato segnatura del messaggio ricevuto collegato al protocollo");
        }

        Segnatura segnatura = null
        if (isSegnatura != null) {
            log.debug("SegnaturaInteropService.getSegnaturaProtocollo Eseguo il parse della segnatura")

            try {
                segnatura = getSegnaturaFromStream(isSegnatura)
            }
            catch (Exception e) {
                log.debug("SegnaturaInteropService.getSegnaturaProtocollo Errore in produciConfermaXML: " +
                        "non riesco a fare il parse della segnatura del messaggio ricevuto collegato al protocollo. Errore=" + e.getMessage())
                throw new Exception(
                        "Errore in getSegnaturaProtocollo: non riesco a fare il parse della segnatura del messaggio ricevuto collegato al protocollo", e);
            }
        } else {
            log.debug("SegnaturaInteropService.getSegnaturaProtocollo Segnatura non trovata")
        }

        return segnatura
    }

    private String produci() {
        Segnatura segnatutaInterop = new Segnatura()
        segnatutaInterop.setIntestazione(produciIntestazione())
        segnatutaInterop.setDescrizione(produciDescrizione())

        JAXBContext jaxbContext = JAXBContext.newInstance(Segnatura.class)
        Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true)
        //File file = new File("C:\\tmp\\file.xml")
        //jaxbMarshaller.marshal(segnatutaInterop, file)
        java.io.StringWriter sw = new StringWriter()

        jaxbMarshaller.marshal(segnatutaInterop, sw)

        return sw.toString()
    }

    private Intestazione produciIntestazione() {
        Intestazione intestazione = new Intestazione()

        intestazione.setIdentificatore(produciIdentificatore())

        //todo manca..: produciPrimaRegistrazione

        intestazione.setOrigine(produciOrigine())

        intestazione.setDestinazione(produciDestinazioni())
        if (!StringUtility.nvl(casellaRisposta, "").equals("")) {
            intestazione.setRisposta(produciRisposta(casellaRisposta))
        }
        if (interventoOperatore) {
            intestazione.setInterventoOperatore(produciInterventoOperatore())
        }
        if (protocollo.allegati?.find { it.fileDocumenti?.size() == 0 } != null) {
            intestazione.setRiferimentoDocumentiCartacei(produciRifDocumentiCartacei())
        }
        if (!StringUtility.nvl(protocollo.oggetto, "").equals("")) {
            intestazione.setOggetto(produciOggetto(protocollo.oggetto))
        }

        return intestazione
    }

    private Identificatore produciIdentificatore() {
        Identificatore identificatore = new Identificatore()

        //todo qui va messo codiceOriginale, non appena fanno la modifica al plugin delle viste so4
        identificatore.setCodiceAmministrazione(produciCodiceAmministrazione(protocollo.ente?.amministrazione?.codice))
        //todo qui va messo aooOriginale, non appena fanno la modifica al plugin delle viste so4
        identificatore.setCodiceAOO(produciCodiceAOO(protocollo.ente?.aoo))
        identificatore.setCodiceRegistro(produciCodiceRegistro(protocollo?.tipoRegistro?.codice))
        identificatore.setNumeroRegistrazione(produciNumeroRegistrazione(protocollo?.numero?.toString()?.padLeft(7, '0').toString() ?: ""))
        identificatore.setDataRegistrazione(produciDataRegistrazione(protocollo.data?.format(SegnaturaInteropService.FORMATO_DATE_SEGNATURA) ?: ""))

        return identificatore
    }

    private Identificatore produciIdentificatore(Identificatore identificatorePartenza) {
        Identificatore identificatore = new Identificatore()

        identificatore.setCodiceAmministrazione(produciCodiceAmministrazione(identificatorePartenza?.codiceAmministrazione?.content))
        identificatore.setCodiceAOO(produciCodiceAOO(identificatorePartenza?.codiceAOO?.content))
        identificatore.setCodiceRegistro(produciCodiceRegistro(identificatorePartenza?.codiceRegistro?.content))
        identificatore.setNumeroRegistrazione(produciNumeroRegistrazione(identificatorePartenza?.numeroRegistrazione?.content))
        identificatore.setDataRegistrazione(produciDataRegistrazione(identificatorePartenza?.dataRegistrazione?.content))

        return identificatore
    }

    private Origine produciOrigine() {
        Origine origine = new Origine()
        Mittente mittente = new Mittente()

        if (messaggio != null) {
            origine.setIndirizzoTelematico(produciIndirizzoTelematico(TIPO_INDIRIZZO_TELEMATICO, messaggio.mittente, ""))

            List<IndirizzoDTO> listaIndirizziAmmAooUo = corrispondenteService.getIndirizziAmministrazione(messaggio.mittenteAmministrazione, messaggio.mittenteAOO, messaggio.mittenteCodiceUO)
            if (listaIndirizziAmmAooUo != null) {
                IndirizzoDTO indirizzoDTOAmm = listaIndirizziAmmAooUo.find {
                    it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE)
                }
                IndirizzoDTO indirizzoDTOAOO = listaIndirizziAmmAooUo.find {
                    it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_AOO)
                }
                IndirizzoDTO indirizzoDTOUO = listaIndirizziAmmAooUo.find {
                    it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_UO)
                }

                if (indirizzoDTOAmm == null) {
                    throw new ProtocolloRuntimeException("Impossibile individuare il mittente")
                }

                if (indirizzoDTOUO?.domainObject?.email != null) {
                    casellaRisposta = indirizzoDTOUO?.domainObject?.email
                }

                mittente.setAmministrazione(produciAmministrazione(indirizzoDTOAmm, indirizzoDTOUO))
                if (indirizzoDTOAOO != null) {
                    mittente.setAOO(produciAOO(indirizzoDTOAOO))
                }
            } else {
                throw new ProtocolloRuntimeException("Impossibile individuare il mittente")
            }
        } else {
            IndirizzoDTO indirizzoAmm
            IndirizzoDTO indirizzoAOO
            if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PINVIOI, springSecurityService.currentUser)) {

                List<IndirizzoDTO> listaIndirizziAmmAooUo = corrispondenteService.getIndirizziAmministrazione(protocollo.ente.amministrazione.codice, protocollo.ente.aoo, null)
                if (listaIndirizziAmmAooUo != null) {
                    indirizzoAmm = listaIndirizziAmmAooUo.find {
                        it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE)
                    }

                    indirizzoAOO = listaIndirizziAmmAooUo.find {
                        it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_AOO)
                    }
                }
            }

            //Li creo vuoti
            if (indirizzoAmm == null) {
                indirizzoAmm = new Indirizzo()
            }
            if (indirizzoAOO == null) {
                indirizzoAOO = new Indirizzo()
            }

            origine.setIndirizzoTelematico(produciIndirizzoTelematico(SegnaturaInteropService.TIPO_INDIRIZZO_TELEMATICO,
                    (indirizzoAOO.email == null) ? indirizzoAmm.email : indirizzoAOO.email, ""))
            mittente.setAmministrazione(produciAmministrazione(indirizzoAmm, null))
            mittente.setAOO(produciAOO(indirizzoAOO))
        }

        origine.setMittente(mittente)

        return origine
    }

    private List<Destinazione> produciDestinazioni() {
        List<Destinazione> destinazioneList = new ArrayList<Destinazione>()
        List<Corrispondente> destinatari = new ArrayList<Corrispondente>()

        if (messaggio == null || segnaturaCompleta) {
            //Metto tutti i destinatari del protocollo
            for (Corrispondente corrispondente : protocollo.corrispondenti) {
                if (corrispondente.tipoCorrispondente.equals(Corrispondente.DESTINATARIO)) {
                    destinatari.add(corrispondente)
                }
            }
        } else {
            //Metto solo i destinatari dei messaggi
            for (CorrispondenteMessaggio corrispondenteMessaggio : messaggio.corrispondenti) {
                if (corrispondenteMessaggio.corrispondente.tipoCorrispondente.equals(Corrispondente.DESTINATARIO)) {
                    destinatari.add(corrispondenteMessaggio.corrispondente)
                }
            }
        }

        //Ciclo sui destinatari da aggiungere alla segnatura
        for (Corrispondente corrispondente : destinatari) {
            Destinazione destinazione = new Destinazione()
            List<Destinatario> destinatarioList = new ArrayList<Destinatario>()

            if (confermaRicezione) {
                destinazione.setConfermaRicezione("si")
            } else {
                destinazione.setConfermaRicezione("no")
            }
            destinazione.setIndirizzoTelematico(produciIndirizzoTelematico(SegnaturaInteropService.TIPO_INDIRIZZO_TELEMATICO, corrispondente.email, ""))

            Destinatario destinatario = new Destinatario()
            ArrayList<JAXBElement<?>> content = new ArrayList<JAXBElement<?>>()
            if (corrispondente.tipoSoggetto?.id == 2) {
                //E' un'amministrazione

                Indirizzo indirizzoAmm = corrispondente.indirizzi.find {
                    it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE)
                }
                Indirizzo indirizzoAoo = corrispondente.indirizzi.find {
                    it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_AOO)
                }
                Indirizzo indirizzoUo = corrispondente.indirizzi.find {
                    it.tipoIndirizzo.equals(Indirizzo.TIPO_INDIRIZZO_UO)
                }

                if (indirizzoAmm != null) {
                    destinatario.setAmministrazione(produciAmministrazione(indirizzoAmm, indirizzoUo))
                }
                if (indirizzoAoo != null) {
                    destinatario.setAoo(produciAOO(indirizzoAoo))
                }
                if (indirizzoAmm != null || indirizzoAoo != null) {
                    destinatario.setAmministrazione(produciAmministrazione(indirizzoAmm, indirizzoUo))
                    destinatario.setAoo(produciAOO(indirizzoAoo))
                }
            } else {
                //todo va bene la partita iva come discriminante?
                if (StringUtility.nvl(corrispondente.partitaIva, "").equals("")) {
                    //E' una persona fisica
                    destinatario.setPersona(produciPersona(corrispondente))
                } else {
                    //E' un'azienda
                    destinatario.setDenominazione(produciDenominazione(corrispondente.denominazione))
                    destinatario.setPersona(produciPersona(corrispondente))
                }
            }

            destinatarioList.add(destinatario)
            destinazione.setDestinatari(destinatarioList)

            destinazioneList.add(destinazione)
        }

        return destinazioneList
    }

    private Persona produciPersona(Corrispondente corrispondente) {
        Persona persona = new Persona()

        persona.setDenominazione(produciDenominazione(corrispondente.denominazione))
        persona.setNome(produciNome(corrispondente.nome))
        persona.setCognome(produciCognome(corrispondente.cognome))
        persona.setCodiceFiscale(produciCodiceFiscale(corrispondente.codiceFiscale))

        return persona
    }

    private Amministrazione produciAmministrazione(Indirizzo indirizzoAmm, Indirizzo indirizzoUo) {
        Amministrazione amministrazione = new Amministrazione()

        amministrazione.setDenominazione(produciDenominazione(indirizzoAmm.denominazione))
        amministrazione.setCodiceAmministrazione(produciCodiceAmministrazione(indirizzoAmm.codice))
        if (indirizzoUo == null) {
            //E' un amm senza UO
            amministrazione.setIndirizzoPostale(produciIndirizzoPostale(indirizzoAmm.indirizzo, indirizzoAmm.cap,
                    indirizzoAmm.comune, indirizzoAmm.provinciaSigla))

            if (!StringUtility.nvl(indirizzoAmm.fax, "").equals("")) {
                amministrazione.setFax([produciFax(indirizzoAmm.fax)])
            }
        } else {
            amministrazione.setUnitaOrganizzativa(produciUO(indirizzoUo))
        }

        return amministrazione
    }

    private Amministrazione produciAmministrazione(IndirizzoDTO indirizzoAmm, IndirizzoDTO indirizzoUo) {
        Amministrazione amministrazione = new Amministrazione()

        amministrazione.setDenominazione(produciDenominazione(indirizzoAmm?.denominazione))
        amministrazione.setCodiceAmministrazione(produciCodiceAmministrazione(indirizzoAmm?.codice))
        if (indirizzoUo == null) {
            //E' un amm senza UO
            amministrazione.setIndirizzoPostale(produciIndirizzoPostale(indirizzoAmm?.indirizzo, indirizzoAmm?.cap,
                    indirizzoAmm?.comune, indirizzoAmm?.provinciaSigla))

            if (!StringUtility.nvl(indirizzoAmm?.fax, "")?.equals("")) {
                amministrazione.setFax([produciFax(indirizzoAmm?.fax)])
            }
        } else {
            amministrazione.setUnitaOrganizzativa(produciUO(indirizzoUo))
        }

        return amministrazione
    }

    private UnitaOrganizzativa produciUO(IndirizzoDTO indirizzoUo) {
        UnitaOrganizzativa uo = new UnitaOrganizzativa()

        uo.setDenominazione(produciDenominazione(indirizzoUo.denominazione))
        uo.setIndirizzoPostale(produciIndirizzoPostale(indirizzoUo.indirizzo, indirizzoUo.cap,
                indirizzoUo.comune, indirizzoUo.provinciaSigla))

        return uo
    }

    private UnitaOrganizzativa produciUO(Indirizzo indirizzoUo) {
        UnitaOrganizzativa uo = new UnitaOrganizzativa()

        uo.setDenominazione(produciDenominazione(indirizzoUo?.denominazione))
        uo.setIndirizzoPostale(produciIndirizzoPostale(indirizzoUo.indirizzo, indirizzoUo.cap,
                indirizzoUo.comune, indirizzoUo.provinciaSigla))

        return uo
    }

    private AOO produciAOO(Indirizzo indirizzAOO) {
        if (indirizzAOO == null) {
            return null
        }

        AOO aoo = new AOO()

        aoo.setCodiceAOO(produciCodiceAOO(indirizzAOO.codice))
        aoo.setDenominazione(produciDenominazione(indirizzAOO.denominazione))

        return aoo
    }

    private AOO produciAOO(IndirizzoDTO indirizzAOO) {
        if (indirizzAOO == null) {
            return null
        }

        AOO aoo = new AOO()

        aoo.setCodiceAOO(produciCodiceAOO(indirizzAOO.codice))
        aoo.setDenominazione(produciDenominazione(indirizzAOO.denominazione))

        return aoo
    }

    private Risposta produciRisposta(String indirizzo) {
        Risposta risposta = new Risposta()
        risposta.setIndirizzoTelematico(produciIndirizzoTelematico(SegnaturaInteropService.TIPO_INDIRIZZO_TELEMATICO, indirizzo, ""))

        return risposta
    }

    private InterventoOperatore produciInterventoOperatore() {
        InterventoOperatore interventoOperatore = new InterventoOperatore()

        interventoOperatore.content = ""

        return interventoOperatore
    }

    private RiferimentoDocumentiCartacei produciRifDocumentiCartacei() {
        return new RiferimentoDocumentiCartacei()
    }

    private Descrizione produciDescrizione() {
        Descrizione descrizione = new Descrizione()
        //1.Aggiunta di Documento o TestoDelMessaggio in base al fatto che esista o meno il file principale
        if (protocollo?.filePrincipale == null) {
            descrizione.setTestoDelMessaggio(produciTestoDelMessagggio())
        } else {
            descrizione.setDocumento(produciDocumento(protocollo.idDocumentoEsterno, protocollo?.filePrincipale))
        }

        //2. Aggiunta di Allegati
        ArrayList<Documento> content = new ArrayList<Documento>()
        for (allegato in protocollo.getAllegati()) {
            if (allegato.tipoAllegato.codice == TipoAllegato.CODICE_TIPO_STAMPA_UNICA) {
                continue
            }

            for (fileAllegato in allegato.fileDocumenti) {
                content.add(produciDocumento(allegato.idDocumentoEsterno, fileAllegato))
            }
        }

        if (content.size() > 0) {
            descrizione.setAllegati(produciAllegati(content))
        }

        return descrizione
    }

    private TestoDelMessaggio produciTestoDelMessagggio() {
        TestoDelMessaggio testoDelMessaggio = new TestoDelMessaggio()

        return testoDelMessaggio
    }

    private Documento produciDocumento(Long idDocumentoEsterno, FileDocumento fileDocumento) {
        Documento documento = new Documento()
        it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()

        ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI> componentiArrayList = new ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI>()
        componentiArrayList.add(it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.FILE)
        documentoSmart.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        documentoSmart.setId(String.valueOf(idDocumentoEsterno))
        documentoSmart = documentaleService.getDocumento(documentoSmart, componentiArrayList)
        File fileSmart = documentoSmart.trovaFile(new File(fileDocumento.nome))
        if (fileSmart?.isVisibile() && !fileDocumento.nome.equals("segnatura.xml" && !fileDocumento.nome.equals("LETTERAUNIONE.RTFHIDDEN"))) {
            documento.setNome(fileDocumento.nome)
            if (publicStorage != null) {
                riempiDocumentoPublicStorage(documento, fileDocumento)
            } else {
                documento.setTipoRiferimento(SegnaturaInteropService.TIPO_RIFERIMENTO_DOCUMENTO_MIME)
                //documento.setOggetto(produciOggetto(fileDocumento.nome))
            }
        }

        return documento
    }

    private void riempiDocumentoPublicStorage(Documento documento, FileDocumento fileDocumento) {

        documento.setTipoRiferimento(SegnaturaInteropService.TIPO_RIFERIMENTO_DOCUMENTO_TELEMATICO)
        //documento.setOggetto(produciOggetto(fileDocumento.nome))
        //todo Finire gestione publicStorage con relativo hash
    }

    /* PRODUZIONE OGGETTI SEMPLICI */

    private IndirizzoTelematico produciIndirizzoTelematico(String tipo, String content, String note) {
        IndirizzoTelematico indirizzoTelematico = new IndirizzoTelematico()
        indirizzoTelematico.setContent(StringUtility.nvl(content, "NA"))
        indirizzoTelematico.setTipo(tipo)
        indirizzoTelematico.setNote(note)

        return indirizzoTelematico
    }

    private IndirizzoPostale produciIndirizzoPostale(String indirizzo, String cap, String comune, String provincia) {
        IndirizzoPostale indirizzoPostale = new IndirizzoPostale()
        it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Indirizzo indirizzoObj = new it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Indirizzo()

        indirizzoObj.setCAP(produciCAP(cap))
        indirizzoObj.setCivico(produciCivico(indirizzo))
        indirizzoObj.setProvincia(produciProvincia(provincia))
        indirizzoObj.setComune(produciComune(comune))

        indirizzoPostale.setIndirizzo(indirizzoObj)

        return indirizzoPostale
    }

    private CodiceAmministrazione produciCodiceAmministrazione(String content) {
        CodiceAmministrazione codiceAmministrazione = new CodiceAmministrazione()
        codiceAmministrazione.setContent(StringUtility.nvl(content, ""))

        return codiceAmministrazione
    }

    private CodiceAOO produciCodiceAOO(String content) {
        CodiceAOO codiceAOO = new CodiceAOO()
        codiceAOO.setContent(StringUtility.nvl(content, ""))

        return codiceAOO
    }

    private CodiceRegistro produciCodiceRegistro(String content) {
        CodiceRegistro codiceRegistro = new CodiceRegistro()
        codiceRegistro.setContent(StringUtility.nvl(content, ""))

        return codiceRegistro
    }

    private NumeroRegistrazione produciNumeroRegistrazione(String content) {
        NumeroRegistrazione numeroRegistrazione = new NumeroRegistrazione()
        numeroRegistrazione.setContent(StringUtility.nvl(content, ""))

        return numeroRegistrazione
    }

    private DataRegistrazione produciDataRegistrazione(String content) {
        DataRegistrazione dataRegistrazione = new DataRegistrazione()
        dataRegistrazione.setContent(StringUtility.nvl(content, ""))

        return dataRegistrazione
    }

    private Denominazione produciDenominazione(String content) {
        Denominazione denominazione = new Denominazione()
        denominazione.setContent(StringUtility.nvl(content, ""))

        return denominazione
    }

    private Nome produciNome(String content) {
        Nome nome = new Nome()
        nome.setContent(StringUtility.nvl(content, ""))

        return nome
    }

    private Cognome produciCognome(String content) {
        Cognome cognome = new Cognome()
        cognome.setContent(StringUtility.nvl(content, ""))

        return cognome
    }

    private CodiceFiscale produciCodiceFiscale(String content) {
        CodiceFiscale codiceFiscale = new CodiceFiscale()
        codiceFiscale.setContent(StringUtility.nvl(content, ""))

        return codiceFiscale
    }

    private CAP produciCAP(String content) {
        CAP cap = new CAP()
        cap.setContent(StringUtility.nvl(content, ""))

        return cap
    }

    private Civico produciCivico(String content) {
        Civico civico = new Civico()
        civico.setContent(StringUtility.nvl(content, ""))

        return civico
    }

    private Provincia produciProvincia(String content) {
        Provincia provincia = new Provincia()
        provincia.setContent(StringUtility.nvl(content, ""))

        return provincia
    }

    private Comune produciComune(String content) {
        Comune comune = new Comune()
        comune.setContent(StringUtility.nvl(content, ""))

        return comune
    }

    private Comune produciTelefono(String content) {
        Telefono telefono = new Telefono()
        telefono.setContent(StringUtility.nvl(content, ""))

        return telefono
    }

    private Fax produciFax(String content) {
        Fax fax = new Telefono()
        fax.setContent(StringUtility.nvl(content, ""))

        return fax
    }

    private Oggetto produciOggetto(String content) {
        Oggetto oggetto = new Oggetto()
        oggetto.setContent(StringUtility.nvl(content, ""))

        return oggetto
    }

    private Allegati produciAllegati(ArrayList<Documento> elementList) {
        Allegati allegato = new Allegati()
        allegato.documentoOrFascicolo.addAll(elementList)

        return allegato
    }

    private Motivo produciMotivo(String content) {
        Motivo motivo = new Motivo()
        motivo.setContent(StringUtility.nvl(content, ""))

        return motivo
    }

    private it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.MessaggioRicevuto produciMessaggioRicevuto(Identificatore identificatore) {
        it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.MessaggioRicevuto messaggioRicevuto = new it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.MessaggioRicevuto()
        messaggioRicevuto.setIdentificatore(identificatore)

        return messaggioRicevuto
    }

    PublicStorageService getPublicStorage() {
        return publicStorage
    }

    void setPublicStorage(PublicStorageService publicStorage) {
        this.publicStorage = publicStorage
    }

    Segnatura getSegnaturaFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(Segnatura.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        Segnatura segnatura = (Segnatura) jaxbUnmarshaller.unmarshal(xr)

        return segnatura
    }

    AggiornamentoConferma getAggiornamentoConfermaFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(AggiornamentoConferma.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        AggiornamentoConferma aggiornamentoConferma = (AggiornamentoConferma) jaxbUnmarshaller.unmarshal(xr)

        return aggiornamentoConferma
    }

    ConfermaRicezione getConfermaRicezioneFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(ConfermaRicezione.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        ConfermaRicezione confermaRicezione = (ConfermaRicezione) jaxbUnmarshaller.unmarshal(xr)

        return confermaRicezione
    }

    NotificaEccezione getNotificaEccezioneFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(NotificaEccezione.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        NotificaEccezione notificaEccezione = (NotificaEccezione) jaxbUnmarshaller.unmarshal(xr)

        return notificaEccezione
    }

    AnnullamentoProtocollazione getAnnullamentoProtocollazioneFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(AnnullamentoProtocollazione.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        AnnullamentoProtocollazione annullamentoProtocollazione = (AnnullamentoProtocollazione) jaxbUnmarshaller.unmarshal(xr)

        return annullamentoProtocollazione
    }

    Postacert getPostaCertFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(Postacert.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        Postacert postacert = (Postacert) jaxbUnmarshaller.unmarshal(xr)

        return postacert
    }

    CooperazioneSuapEnte getCooperazioneSuapEnteFromStream(InputStream is) {
        XMLStreamReader xsr = XMLInputFactory.newFactory().createXMLStreamReader(is);
        XMLReaderWithoutNamespace xr = new XMLReaderWithoutNamespace(xsr);

        JAXBContext jaxbContext = JAXBContext.newInstance(CooperazioneSuapEnte.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        CooperazioneSuapEnte cooperazioneSuapEnte = (CooperazioneSuapEnte) jaxbUnmarshaller.unmarshal(xr)

        return cooperazioneSuapEnte
    }
}

class XMLReaderWithoutNamespace extends StreamReaderDelegate {
    public XMLReaderWithoutNamespace(XMLStreamReader reader) {
        super(reader);
    }

    @Override
    public String getAttributeNamespace(int arg0) {
        return "";
    }

    @Override
    public String getNamespaceURI() {
        return "";
    }
}