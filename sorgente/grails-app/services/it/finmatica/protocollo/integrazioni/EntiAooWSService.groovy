package it.finmatica.protocollo.integrazioni

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.CustomProtocollloWSRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloWS
import it.finmatica.protocollo.documenti.viste.IndirizzoTelematico
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import org.apache.log4j.Logger
import org.jdom.output.Format
import org.jdom.output.XMLOutputter
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.Node
import org.w3c.dom.NodeList
import org.xml.sax.InputSource
import org.jdom.Attribute

import javax.xml.parsers.DocumentBuilder
import javax.xml.parsers.DocumentBuilderFactory
import java.text.DateFormat
import java.text.SimpleDateFormat

@Transactional
@Service
@Slf4j
class EntiAooWSService {

    @Autowired
    CustomProtocollloWSRepository customProtocollloWSRepository
    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService
    @Autowired
    AllegatoProtocolloService allegatoProtocolloService
    @Autowired
    SpringSecurityService springSecurityService

    private static final String XML_DEFINITION = "<?xml version = '1.0' encoding = 'UTF-8'?>"

    private static final Logger logger = Logger.getLogger(EntiAooWSService.class)

    @Transactional(readOnly = true)
    String getProtocolli(String inputXml){

            String xml=""
            String error=""

            if( inputXml == null || inputXml.length()==0)
                xml =XML_DEFINITION+"<PROTOCOLLI><ERROR>non è stato passato alcun parametro in ingresso</ERROR></ROOT>"
            else
            {

                try{

                    Document docInput=null

                    DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance()
                    DocumentBuilder docBuilder=null

                    docBuilder = docFactory.newDocumentBuilder()
                    docInput = docBuilder.parse( new InputSource( new StringReader( inputXml ) ) )

                    Element rootInput = docInput.getDocumentElement()
                    String anno=getXmlValue("ANNO", rootInput)
                    String numero=getXmlValue("NUMERO", rootInput)
                    String tipoRegistro=getXmlValue("TIPO_REGISTRO", rootInput)
                    String oggetto=getXmlValue("OGGETTO", rootInput)
                    String dal=getXmlValue("DAL", rootInput)
                    String al=getXmlValue("AL", rootInput)
                    String classCod=getXmlValue("CLASS_COD", rootInput)
                    String fascicoloAnno=getXmlValue("FASCICOLO_ANNO", rootInput)
                    String fascicoloNumero=getXmlValue("FASCICOLO_NUMERO", rootInput)
                    String descrizioneRapporto=getXmlValue("DESCRIZIONE_RAPPORTO", rootInput)
                    String modalita=getXmlValue("MODALITA", rootInput)
                    String tipoDocumento=getXmlValue("TIPO_DOCUMENTO", rootInput)

                    //check condizioni
                    anno = anno ?: null
                    numero = numero ?: null
                    tipoRegistro = tipoRegistro ?: null
                    descrizioneRapporto = descrizioneRapporto ?: null
                    classCod = classCod ?: null
                    fascicoloAnno = fascicoloAnno ?: null
                    fascicoloNumero = fascicoloNumero ?: null
                    modalita = modalita ?: null
                    tipoDocumento = tipoDocumento ?: null
                    oggetto = oggetto ?: null

                    if ( (anno == null || anno.length()==0 ) || ( numero == null || numero.length()==0) )
                    {
                        if(dal!=null && al!=null)
                        {
                            if(!checkDate(dal))
                                error+="Data Dal non valida utilizzare (DD/MM/YYYY), "
                            if(!checkDate(al))
                                error+="Data Al non valida utilizzare (DD/MM/YYYY), "
                        }else error+="Parametri Dal e Al obbligatori, "
                    }

                    if(fascicoloAnno!=null || fascicoloNumero!=null)
                        error+="Fascicolo Anno e Fascicolo Numero devono essere presente entrambi, "

                    if(error.length()>0)
                        throw new Exception(error)

                    String queryGetProtocolli = customProtocollloWSRepository.getProtocolliQueryString(anno, numero, tipoRegistro, modalita, classCod, fascicoloAnno,
                                                                                                       oggetto, fascicoloNumero, dal, al, descrizioneRapporto, tipoDocumento )
                    List<ProtocolloWS> protocolliWS = customProtocollloWSRepository.getProtocolli(queryGetProtocolli, anno, numero, tipoRegistro, modalita, classCod, fascicoloAnno,
                            oggetto, fascicoloNumero, dal, al, descrizioneRapporto, tipoDocumento)

                    //NOTA per costruire la stringa xml di output uso le librerie di jdom e non quelle di javax.xml.transform
                    //XSL-1101: (Fatal Error) DOMSource node as this type not supported

                    try {

                        org.jdom.Element company = new org.jdom.Element("PROTOCOLLI")
                        org.jdom.Document doc = new org.jdom.Document(company)
                        doc.setRootElement(company)

                        for(ProtocolloWS protocollo : protocolliWS) {

                            org.jdom.Element  protoTag = new  org.jdom.Element("PROTOCOLLO")
                            protoTag.addContent(new  org.jdom.Element("ID_DOCUMENTO").setText(protocollo.idDocumento ? String.valueOf(protocollo.idDocumento): ""))
                            protoTag.addContent(new  org.jdom.Element("ANNO").setText(protocollo.anno  ? String.valueOf(protocollo.anno): ""))
                            protoTag.addContent(new  org.jdom.Element("NUMERO").setText(protocollo.numero  ? String.valueOf(protocollo.numero) : ""))
                            protoTag.addContent(new  org.jdom.Element("TIPO_REGISTRO").setText(protocollo.tipoRegistro ?: ""))
                            protoTag.addContent(new  org.jdom.Element("OGGETTO").setText(protocollo.oggetto ?: ""))
                            protoTag.addContent(new  org.jdom.Element("DESCRIZIONE_TIPO_DOCUMENTO").setText(protocollo.descrizioneTipoDocumento ?: ""))

                            doc.getRootElement().addContent(protoTag)
                        }

                        XMLOutputter outter = new XMLOutputter()
                        outter.setFormat(Format.getPrettyFormat())
                        xml = new XMLOutputter().outputString(doc)

                    } catch (Exception e) {
                        xml=XML_DEFINITION+"<PROTOCOLLI><ERROR>"+e.getMessage()+"</ERROR></PROTOCOLLI>"
                    }

                } catch(Exception ex){
                    error=ex.getMessage()
                    xml=XML_DEFINITION+"<PROTOCOLLI><ERROR>"+error+"</ERROR></PROTOCOLLI>"
            }
        }

        return xml
    }

    @Transactional(readOnly = true)
    String getProtocollo(Integer anno, Integer numero,String tipoRegistro){
        String xml =""
        String error = ""

        tipoRegistro = (tipoRegistro!=null?tipoRegistro.toUpperCase():"")

        if(	anno<=0 || numero<=0)
            xml =XML_DEFINITION+"<PROTOCOLLO><ERROR>non è stato passato alcun parametro in ingresso</ERROR></PROTOCOLLO>"
        else {
            // faccio il log dei parametri in ingresso
            try {
                log.info("\nanno:" + anno
                        + "\nnumero:" + numero
                        + "\ntipoRegistro:" + tipoRegistro)
            } catch (Exception e) {
                log.error(e.getMessage())
            }

            DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)

            Protocollo protocollo
            ProtocolloWS protocolloWS = protocolloWSUtilityService.estraiDocumentoDaProtocolloWS(null, anno, numero, tipoRegistro)
            if(protocolloWS) {
                protocollo = protocolloWSUtilityService.completaDatiPerDocumento(protocolloWS, false)
                if(!protocollo) {
                    xml =XML_DEFINITION+"<PROTOCOLLO><ERROR>Protocollo non trovato</ERROR></PROTOCOLLO>"
                } else {
                    //Carica file principale se esiste
                    FileDocumento filePrincipale = allegatoProtocolloService.getAllegatiByIdAndCodice(protocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE)?.get(0)
                    //Carica allegati
                    List<Allegato> listaAllegati = new ArrayList<Allegato>()
                    Set<Smistamento> smistamenti = new HashSet<Smistamento>()
                    Set<Corrispondente> corrispondenti = new HashSet<Corrispondente>()
                    //carico solo se sono "nostri"
                    if(protocolloWS.isCategoriaProtocollo()) {
                        listaAllegati = protocollo?.allegati?.sort { it.sequenza }
                        //Carica smistamenti
                        smistamenti = protocollo.smistamenti
                        corrispondenti = protocollo.corrispondenti
                    }

                    //CREA XML DI RISPOSTA
                    //Prendo i dati del tag DOC da protocolloWS
                    try {

                        org.jdom.Element company = new org.jdom.Element("PROTOCOLLO")
                        org.jdom.Document doc = new org.jdom.Document(company)
                        doc.setRootElement(company)

                        //SEZIONE TAG DOC
                        org.jdom.Element docTag = new org.jdom.Element("DOC")
                        docTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(protocolloWS.idDocumento ? String.valueOf(protocolloWS.idDocumento ): ""))
                        docTag.addContent(new org.jdom.Element("IDRIF").setText(protocolloWS.idrif ?: ""))
                        docTag.addContent(new org.jdom.Element("ANNO").setText(protocolloWS.anno ? String.valueOf(protocolloWS.anno) : ""))
                        docTag.addContent(new org.jdom.Element("NUMERO").setText(protocolloWS.numero ? String.valueOf(protocolloWS.numero ) : ""))
                        docTag.addContent(new org.jdom.Element("TIPO_REGISTRO").setText(protocolloWS.tipoRegistro ?: ""))
                        docTag.addContent(new org.jdom.Element("DESCRIZIONE_TIPO_REGISTRO").setText(protocolloWS.descrizioneTipoRegistro ?: ""))
                        String dateString = ""
                        dateString = format.format(protocolloWS.data)
                        docTag.addContent(new org.jdom.Element("DATA").setText(dateString))
                        docTag.addContent(new org.jdom.Element("OGGETTO").setText(protocolloWS.oggetto ?: ""))
                        docTag.addContent(new org.jdom.Element("CLASS_COD").setText(protocolloWS.classificazione ?: ""))
                        String dateStringClass = ""
                        dateStringClass = format.format(protocolloWS.classDal)
                        docTag.addContent(new org.jdom.Element("CLASS_DAL").setText(dateStringClass))
                        docTag.addContent(new org.jdom.Element("FASCICOLO_ANNO").setText(protocolloWS.annoFascicolo ? String.valueOf(protocolloWS.annoFascicolo) : ""))
                        docTag.addContent(new org.jdom.Element("FASCICOLO_NUMERO").setText(protocolloWS.numeroFascicolo ?: ""))
                        docTag.addContent(new org.jdom.Element("STATO_PR").setText(protocolloWS.statoPr ?: ""))
                        docTag.addContent(new org.jdom.Element("TIPO_DOCUMENTO").setText(protocolloWS.tipoDocumento ?: ""))
                        docTag.addContent(new org.jdom.Element("UNITA_PROTOCOLLANTE").setText(protocolloWS.unitaProtocollante ?: " "))
                        doc.getRootElement().addContent(docTag)

                        //SEZIONE TAG FILE PRINCIPALE
                        org.jdom.Element filePrincipaleTag = new org.jdom.Element("FILE_PRINCIPALE")
                        if(protocolloWS.isCategoriaProtocollo()) {
                            org.jdom.Element fileTag = new org.jdom.Element("FILE")
                            fileTag.addContent(new org.jdom.Element("ID_OGGETTO_FILE").setText(filePrincipale.id ? String.valueOf(filePrincipale.id ) : ""))
                            fileTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(filePrincipale.documento.id ? String.valueOf(filePrincipale.documento.id) : ""))
                            fileTag.addContent(new org.jdom.Element("FILENAME").setText(filePrincipale.nome))
                            filePrincipaleTag.addContent(fileTag)
                        }
                        doc.getRootElement().addContent(filePrincipaleTag)

                        //SEZIONE TAG ALLEGATI
                        org.jdom.Element allegatiTag = new org.jdom.Element("ALLEGATI")
                        if(protocolloWS.isCategoriaProtocollo()) {
                            for(Allegato allegato : listaAllegati) {
                                org.jdom.Element allegatoTag = new org.jdom.Element("ALLEGATO")
                                allegatoTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(allegato.id ? String.valueOf(allegato.id ) : ""))
                                allegatoTag.addContent(new org.jdom.Element("DESC_TIPO_ALLEGATO").setText(allegato.tipoAllegato.descrizione ?: ""))
                                allegatoTag.addContent(new org.jdom.Element("TIPO_ALLEGATO").setText(allegato.tipoAllegato.codice ?: ""))
                                allegatoTag.addContent(new org.jdom.Element("DESCRIZIONE").setText(allegato.commento ?: "")) //sono invertiti i campi descriizione e commento!
                                allegatoTag.addContent(new org.jdom.Element("IDRIF").setText(protocolloWS.idrif))
                                allegatoTag.addContent(new org.jdom.Element("NUMERO_PAG").setText(allegato.numPagine ? String.valueOf(allegato.numPagine) : ""))
                                allegatoTag.addContent(new org.jdom.Element("QUANTITA").setText(allegato.quantita ? String.valueOf(allegato.quantita): ""))
                                String riservatoString = allegato.riservato ? "S" : "N"
                                allegatoTag.addContent(new org.jdom.Element("RISERVATO").setText(riservatoString))
                                allegatoTag.addContent(new org.jdom.Element("TITOLO_DOCUMENTO").setText(allegato.descrizione  ?: ""))

                                //PER OGNI allegato estraggo le info sui file
                                List<FileDocumento> listaFilesAllegati = allegatoProtocolloService.getAllegatiByIdAndCodice(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)

                                org.jdom.Element filesAllegatiTag = new org.jdom.Element("FILE_ALLEGATI")
                                for(FileDocumento fileDoc : listaFilesAllegati) {
                                    org.jdom.Element fileAllegatiTag = new org.jdom.Element("FILE")
                                    fileAllegatiTag.addContent(new org.jdom.Element("ID_OGGETTO_FILE").setText(fileDoc.id ? String.valueOf(fileDoc.id) : ""))
                                    fileAllegatiTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(fileDoc.documento.id  ? String.valueOf(fileDoc.documento.id): ""))
                                    fileAllegatiTag.addContent(new org.jdom.Element("FILENAME").setText(fileDoc.nome))
                                    filesAllegatiTag.addContent(fileAllegatiTag)
                                }
                                allegatoTag.addContent(filesAllegatiTag)
                                allegatiTag.addContent(allegatoTag)
                            }
                        }

                        doc.getRootElement().addContent(allegatiTag)

                        //SEZIONE SMISTAMENTI TAG
                        org.jdom.Element smistamentiTag = new org.jdom.Element("SMISTAMENTI")
                        if(protocolloWS.isCategoriaProtocollo()){
                            for(Smistamento smistamento : smistamenti){
                                org.jdom.Element smistamentoTag = new org.jdom.Element("SMISTAMENTO")
                                smistamentoTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(smistamento.documento.id ? String.valueOf(smistamento.documento.id): ""))
                                smistamentoTag.addContent(new org.jdom.Element("DES_UFFICIO_SMISTAMENTO").setText(smistamento.unitaSmistamento.descrizione ?: ""))
                                smistamentoTag.addContent(new org.jdom.Element("DES_UFFICIO_TRASMISSIONE").setText(smistamento.unitaTrasmissione.descrizione ?: ""))
                                smistamentoTag.addContent(new org.jdom.Element("IDRIF").setText(protocolloWS.idrif ?: ""))
                                String dateStringSmistamento = ""
                                dateStringSmistamento = format.format(smistamento.dataSmistamento)
                                smistamentoTag.addContent(new org.jdom.Element("SMISTAMENTO_DAL").setText(dateStringSmistamento))
                                smistamentoTag.addContent(new org.jdom.Element("STATO_SMISTAMENTO").setText(smistamento.statoSmistamento ?: ""))
                                smistamentoTag.addContent(new org.jdom.Element("TIPO_SMISTAMENTO").setText(smistamento.tipoSmistamento ?: ""))
                                smistamentoTag.addContent(new org.jdom.Element("UFFICIO_SMISTAMENTO").setText(smistamento.unitaSmistamento?.codice ?: ""))
                                smistamentoTag.addContent(new org.jdom.Element("UFFICIO_TRASMISSIONE").setText(smistamento.unitaTrasmissione?.codice ?: ""))
                                smistamentoTag.addContent(new org.jdom.Element("UTENTE_TRASMISSIONE").setText(smistamento.utenteTrasmissione?.utente ?: ""))
                                smistamentiTag.addContent(smistamentoTag)
                            }
                        }
                        doc.getRootElement().addContent(smistamentiTag)

                        //SEZIONE CORRISPONDENTI TAG
                        org.jdom.Element corrispondentiTag = new org.jdom.Element("RAPPORTI")
                        if(protocolloWS.isCategoriaProtocollo()) {
                            for(Corrispondente corrispondente : corrispondenti) {
                                org.jdom.Element corrispondenteTag = new org.jdom.Element("RAPPORTO")
                                corrispondenteTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(corrispondente.protocollo.id ? String.valueOf(corrispondente.protocollo.id) : ""))
                                String nomeCognome = corrispondente.cognome != null ? corrispondente.cognome.concat(corrispondente.nome ?: " ") : corrispondente.nome
                                corrispondenteTag.addContent(new org.jdom.Element("COGNOME_NOME").setText(nomeCognome ?: ""))
                                corrispondenteTag.addContent(new org.jdom.Element("CODICE_FISCALE").setText(corrispondente.codiceFiscale ?: ""))
                                corrispondenteTag.addContent(new org.jdom.Element("IDRIF").setText(protocolloWS.idrif ?: ""))
                                String conoscenza = corrispondente.conoscenza ? "S" : "N"
                                corrispondenteTag.addContent(new org.jdom.Element("CONOSCENZA").setText(conoscenza))
                                corrispondentiTag.addContent(corrispondenteTag)
                            }
                        }
                        doc.getRootElement().addContent(corrispondentiTag)


                        XMLOutputter outter = new XMLOutputter()
                        outter.setFormat(Format.getPrettyFormat())
                        xml = new XMLOutputter().outputString(doc)
                    } catch (Exception e) {
                        xml = XML_DEFINITION +"<PROTOCOLLO><ERROR>" + e.getMessage() + "</ERROR></PROTOCOLLO>"
                    }
                }

            } else {
                xml =XML_DEFINITION+"<PROTOCOLLO><ERROR>Protocollo non trovato</ERROR></PROTOCOLLO>"
            }
        }
        return xml
    }

    @Transactional(readOnly = true)
    String getProtocolliDaRicevere(String inputXml){
        String xml =""
        String error = ""

        List<String> statiSmistamento = [Smistamento.DA_RICEVERE]

        if( inputXml == null || inputXml.length()<=0)
            xml =XML_DEFINITION+"<PROTOCOLLI><ERROR>non è stato passato alcun parametro in ingresso</ERROR></PROTOCOLLI>"
        else {
            // faccio il log dei parametri in ingresso
            try {
                log.info("\ninputxml:" + inputXml)
            } catch (Exception e) {
                log.error(e.getMessage())
            }
            try {

                Document docInput = null

                DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance()
                DocumentBuilder docBuilder = null

                docBuilder = docFactory.newDocumentBuilder()
                docInput = docBuilder.parse(new InputSource(new StringReader(inputXml)))

                Element rootInput = docInput.getDocumentElement()
                String utente = getXmlValue("UTENTE", rootInput)
                List<String> listaunita = getXmlListValue("UNITA", rootInput)
                String oggetto = getXmlValue("OGGETTO", rootInput)
                String dal = getXmlValue("DAL", rootInput)
                String al = getXmlValue("AL", rootInput)


                String utenteSmis = ""
                //check condizioni
                if (utente == null || utente.length() == 0) {
                    error = "Parametro Utente non presente, "
                }
                if (listaunita.size() == 0) {
                    error += "E' necessario inserire almeno una unita, "
                }
                if (oggetto == null){
                    oggetto = ""
                }
                if (dal == null) {
                    dal = ""
                }
                if (dal != null && al != null) {
                    if (!checkDate(dal))
                        error += "Data Dal non valida utilizzare (DD/MM/YYYY), "
                    if (!checkDate(al))
                        error += "Data Al non valida utilizzare (DD/MM/YYYY), "
                }

                //Recupera i dati dell'utente
                Ad4Utente usr = Ad4Utente.findByUtente(utente)
                if(!usr) {
                    error += "Utente: "+ utente + " non trovato"
                }


                if(error.length()>0) {
                    return XML_DEFINITION+"<PROTOCOLLI><ERROR>"+ error +"</ERROR></PROTOCOLLI>"
                }

                //verificare se è giusto prendere da questo user il codice ottica.
                String codiceOttica = springSecurityService.principal.ottica.codice
                String queryStringPotocolliDaRicevere = customProtocollloWSRepository.getProtocolliDaRicevereQueryString(listaunita, oggetto, dal, al, utente, codiceOttica, statiSmistamento)
                List<ProtocolloWS> protocolliDaRicevere = customProtocollloWSRepository.getProtocolliDaRicevere(queryStringPotocolliDaRicevere, listaunita, oggetto, dal, al, utente, codiceOttica, statiSmistamento)

                try {

                    org.jdom.Element root = new org.jdom.Element("PROTOCOLLI")
                    org.jdom.Document doc = new org.jdom.Document(root)
                    doc.setRootElement(root)

                    for (ProtocolloWS protocolloDaRicevere : protocolliDaRicevere) {
                        org.jdom.Element protocolloDaRicevereTag = new org.jdom.Element("PROTOCOLLO")
                        protocolloDaRicevereTag.addContent(new org.jdom.Element("ID_DOCUMENTO").setText(protocolloDaRicevere.idDocumento ? String.valueOf(protocolloDaRicevere.idDocumento) : ""))
                        protocolloDaRicevereTag.addContent(new org.jdom.Element("ANNO").setText(protocolloDaRicevere.anno ? String.valueOf(protocolloDaRicevere.anno) : ""))
                        protocolloDaRicevereTag.addContent(new org.jdom.Element("NUMERO").setText(protocolloDaRicevere.numero ? String.valueOf(protocolloDaRicevere.numero) : ""))
                        protocolloDaRicevereTag.addContent(new org.jdom.Element("TIPO_REGISTRO").setText(protocolloDaRicevere.tipoRegistro ?: ""))
                        protocolloDaRicevereTag.addContent(new org.jdom.Element("OGGETTO").setText(protocolloDaRicevere.oggetto ?: ""))
                        protocolloDaRicevereTag.addContent(new org.jdom.Element("DESCRIZIONE_TIPO_DOCUMENTO").setText(protocolloDaRicevere.descrizioneTipoDocumento ?: ""))

                        doc.getRootElement().addContent(protocolloDaRicevereTag)
                    }

                    XMLOutputter outter = new XMLOutputter()
                    outter.setFormat(Format.getPrettyFormat())
                    xml = new XMLOutputter().outputString(doc)

                } catch (Exception e) {
                    xml = XML_DEFINITION+"<PROTOCOLLI><ERROR>" + e.getMessage() + "</ERROR></PROTOCOLLI>"
                }

            }
            catch (Exception e) {
                xml=XML_DEFINITION+"<PROTOCOLLI><ERROR>"+e.getMessage()+"</ERROR></PROTOCOLLI>"
            }
        }
        return xml
    }



    @Transactional(readOnly = true)
    String getMailEnte(String codiceAmministrazione, String descrizioneAmministrazione, String codiceAoo, descrizioneAoo, String indirizzoMail){
        String xml = ""
        String error = ""
        try {
            codiceAmministrazione = codiceAmministrazione?.toUpperCase()
            descrizioneAmministrazione = descrizioneAmministrazione?.toUpperCase()
            codiceAoo = codiceAoo?.toUpperCase()
            descrizioneAoo = descrizioneAoo?.toUpperCase()
            indirizzoMail = indirizzoMail?.toUpperCase()

            if( (codiceAmministrazione == null || codiceAmministrazione.length()==0)
                    && (codiceAoo == null || codiceAoo.length()==0)
                    && (descrizioneAmministrazione == null || descrizioneAmministrazione.length()==0)
                    && (descrizioneAoo == null || descrizioneAoo.length()==0)
                    && (indirizzoMail == null || indirizzoMail.length()==0)
            ) {
                xml =XML_DEFINITION+"<ROOT><ERROR>non è stato passato alcun parametro in ingresso</ERROR></ROOT>"
            }

            else {
                // faccio il log dei parametri in ingresso
                try {
                    logger.info("\ncodice_amministrazione:" + codiceAmministrazione
                            + "\ndescrizione_amministrazione:" + descrizioneAmministrazione
                            + "\ncodice_aoo:" + codiceAoo
                            + "\ndescrizione_aoo:" + descrizioneAoo
                            + "\nindirizzo_mail:" + indirizzoMail)
                } catch (Exception e) {
                    logger.error(e.getMessage())
                }

                String queryGetMailEnte = customProtocollloWSRepository.getMailEnteQueryString(codiceAmministrazione, descrizioneAmministrazione, codiceAoo, descrizioneAoo, indirizzoMail)
                List<IndirizzoTelematico> indirizziMailEnte = customProtocollloWSRepository.getMailEnte(queryGetMailEnte, codiceAmministrazione, descrizioneAmministrazione, codiceAoo, descrizioneAoo, indirizzoMail)

                try {

                    org.jdom.Element company = new org.jdom.Element("ROOT")
                    org.jdom.Document doc = new org.jdom.Document(company)
                    doc.setRootElement(company)

                    //indice ente
                    int num = 1
                    for (IndirizzoTelematico indirizzoMailEnte : indirizziMailEnte) {

                        org.jdom.Element indirizzoTag = new org.jdom.Element("ENTE")
                        indirizzoTag.setAttribute(new Attribute("ID", String.valueOf(num)))
                        num++
                        indirizzoTag.addContent(new org.jdom.Element("CODICE_AMMINISTRAZIONE").setText(indirizzoMailEnte.codiceAmministrazione ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("CODICE_AOO").setText(indirizzoMailEnte.codiceAoo ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("CODICE_UO").setText(indirizzoMailEnte.codiceUo ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("DESCRIZIONE_AMMINISTRAZIONE").setText(indirizzoMailEnte.descrizioneAmministrazione ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("DESCRIZIONE_AOO").setText(indirizzoMailEnte.descrizioneAoo ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("DESCRIZIONE_UO").setText(indirizzoMailEnte.descrizioneUo ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("INDIRIZZO").setText(indirizzoMailEnte.indirizzo ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("PROVENIENZA").setText(indirizzoMailEnte.provenienza ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("PROVINCIA").setText(indirizzoMailEnte.provincia ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("REGIONE").setText(indirizzoMailEnte.regione ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("SIGLA_COMUNE").setText(indirizzoMailEnte.siglaComune ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("SIGLA_PROVINCIA").setText(indirizzoMailEnte.siglaProvincia ?: ""))
                        indirizzoTag.addContent(new org.jdom.Element("TIPO_INDIRIZZO").setText(indirizzoMailEnte.tipoIndirizzo ?: ""))

                        doc.getRootElement().addContent(indirizzoTag)
                    }

                    org.jdom.Element errorTag = new org.jdom.Element("ERROR")
                    errorTag.setText(error)
                    doc.getRootElement().addContent(errorTag)

                    XMLOutputter outter = new XMLOutputter()
                    outter.setFormat(Format.getPrettyFormat())
                    xml = new XMLOutputter().outputString(doc)
                } catch (Exception e) {
                    xml = XML_DEFINITION+"<ROOT><ERROR>" + e.getMessage() + "</ERROR></ROOT>"
                }
            }
        }
        catch (Exception e) {
            xml=XML_DEFINITION+"<ROOT><ERROR>"+e.getMessage()+"</ERROR></ROOT>"
        }
        return xml
    }


    private static String getXmlValue(String tagName, Element element) {
        NodeList list = element.getElementsByTagName(tagName)
        if (list != null && list.getLength() > 0) {
            NodeList subList = list.item(0).getChildNodes()

            if (subList != null && subList.getLength() > 0) {
                return subList.item(0).getNodeValue()
            }
        }

        return null
    }

    private static List<String> getXmlListValue(String tagName, Element element) {
        List<String> unita = new ArrayList<String>()
        NodeList list = element.getElementsByTagName(tagName)
        for (int i = 0; i < list.getLength(); i++) {
            Element ele = (Element) list.item(i)
            Node nod=ele.getFirstChild()
            String val=nod.getNodeValue()
            unita.add(val)
        }
        return unita
    }

    public static boolean checkDate(String data_input) {
        boolean ret = false
        DateFormat fmt = new SimpleDateFormat("dd/MM/yyyy")
        fmt.setLenient(false)
        try {
            fmt.parse(data_input)
            ret = true
        } catch (Exception e) {
        }
        return ret
    }
}
