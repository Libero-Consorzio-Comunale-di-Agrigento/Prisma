//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.02.12 alle 12:36:01 PM CET 
//


package it.finmatica.protocollo.integrazioni.jdocarea;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.protocollo.integrazioni.jdocarea package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _IndirizzoPostale_QNAME = new QName("", "IndirizzoPostale");
    private final static QName _Titolo_QNAME = new QName("", "Titolo");
    private final static QName _CodiceAOO_QNAME = new QName("", "CodiceAOO");
    private final static QName _CodiceFiscale_QNAME = new QName("", "CodiceFiscale");
    private final static QName _Identificativo_QNAME = new QName("", "Identificativo");
    private final static QName _DataRegistrazione_QNAME = new QName("", "DataRegistrazione");
    private final static QName _CodiceAmministrazione_QNAME = new QName("", "CodiceAmministrazione");
    private final static QName _Toponimo_QNAME = new QName("", "Toponimo");
    private final static QName _Oggetto_QNAME = new QName("", "Oggetto");
    private final static QName _NumeroRegistrazione_QNAME = new QName("", "NumeroRegistrazione");
    private final static QName _Ruolo_QNAME = new QName("", "Ruolo");
    private final static QName _Telefono_QNAME = new QName("", "Telefono");
    private final static QName _CodiceTitolario_QNAME = new QName("", "CodiceTitolario");
    private final static QName _Nome_QNAME = new QName("", "Nome");
    private final static QName _Flusso_QNAME = new QName("", "Flusso");
    private final static QName _Fax_QNAME = new QName("", "Fax");
    private final static QName _Denominazione_QNAME = new QName("", "Denominazione");
    private final static QName _Cognome_QNAME = new QName("", "Cognome");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.protocollo.integrazioni.jdocarea
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link DescrizioneDocumento }
     * 
     */
    public DescrizioneDocumento createDescrizioneDocumento() {
        return new DescrizioneDocumento();
    }

    /**
     * Create an instance of {@link Persona }
     * 
     */
    public Persona createPersona() {
        return new Persona();
    }

    /**
     * Create an instance of {@link IndirizzoTelematico }
     * 
     */
    public IndirizzoTelematico createIndirizzoTelematico() {
        return new IndirizzoTelematico();
    }

    /**
     * Create an instance of {@link Descrizione }
     * 
     */
    public Descrizione createDescrizione() {
        return new Descrizione();
    }

    /**
     * Create an instance of {@link Documento }
     * 
     */
    public Documento createDocumento() {
        return new Documento();
    }

    /**
     * Create an instance of {@link TipoDocumento }
     * 
     */
    public TipoDocumento createTipoDocumento() {
        return new TipoDocumento();
    }

    /**
     * Create an instance of {@link Allegati }
     * 
     */
    public Allegati createAllegati() {
        return new Allegati();
    }

    /**
     * Create an instance of {@link Comune }
     * 
     */
    public Comune createComune() {
        return new Comune();
    }

    /**
     * Create an instance of {@link Fascicolo }
     * 
     */
    public Fascicolo createFascicolo() {
        return new Fascicolo();
    }

    /**
     * Create an instance of {@link UnitaOrganizzativa }
     * 
     */
    public UnitaOrganizzativa createUnitaOrganizzativa() {
        return new UnitaOrganizzativa();
    }

    /**
     * Create an instance of {@link Provincia }
     * 
     */
    public Provincia createProvincia() {
        return new Provincia();
    }

    /**
     * Create an instance of {@link AOO }
     * 
     */
    public AOO createAOO() {
        return new AOO();
    }

    /**
     * Create an instance of {@link Parametro }
     * 
     */
    public Parametro createParametro() {
        return new Parametro();
    }

    /**
     * Create an instance of {@link ApplicativoProtocollo }
     * 
     */
    public ApplicativoProtocollo createApplicativoProtocollo() {
        return new ApplicativoProtocollo();
    }

    /**
     * Create an instance of {@link Identificatore }
     * 
     */
    public Identificatore createIdentificatore() {
        return new Identificatore();
    }

    /**
     * Create an instance of {@link Amministrazione }
     * 
     */
    public Amministrazione createAmministrazione() {
        return new Amministrazione();
    }

    /**
     * Create an instance of {@link Nazione }
     * 
     */
    public Nazione createNazione() {
        return new Nazione();
    }

    /**
     * Create an instance of {@link Intestazione }
     * 
     */
    public Intestazione createIntestazione() {
        return new Intestazione();
    }

    /**
     * Create an instance of {@link Mittente }
     * 
     */
    public Mittente createMittente() {
        return new Mittente();
    }

    /**
     * Create an instance of {@link Destinatario }
     * 
     */
    public Destinatario createDestinatario() {
        return new Destinatario();
    }

    /**
     * Create an instance of {@link Classifica }
     * 
     */
    public Classifica createClassifica() {
        return new Classifica();
    }

    /**
     * Create an instance of {@link Segnatura }
     * 
     */
    public Segnatura createSegnatura() {
        return new Segnatura();
    }

    /**
     * Create an instance of {@link CAP }
     * 
     */
    public CAP createCAP() {
        return new CAP();
    }

    /**
     * Create an instance of {@link Civico }
     * 
     */
    public Civico createCivico() {
        return new Civico();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "IndirizzoPostale")
    public JAXBElement<String> createIndirizzoPostale(String value) {
        return new JAXBElement<String>(_IndirizzoPostale_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Titolo")
    public JAXBElement<String> createTitolo(String value) {
        return new JAXBElement<String>(_Titolo_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "CodiceAOO")
    public JAXBElement<String> createCodiceAOO(String value) {
        return new JAXBElement<String>(_CodiceAOO_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "CodiceFiscale")
    public JAXBElement<String> createCodiceFiscale(String value) {
        return new JAXBElement<String>(_CodiceFiscale_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Identificativo")
    public JAXBElement<String> createIdentificativo(String value) {
        return new JAXBElement<String>(_Identificativo_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "DataRegistrazione")
    public JAXBElement<String> createDataRegistrazione(String value) {
        return new JAXBElement<String>(_DataRegistrazione_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "CodiceAmministrazione")
    public JAXBElement<String> createCodiceAmministrazione(String value) {
        return new JAXBElement<String>(_CodiceAmministrazione_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Toponimo")
    public JAXBElement<String> createToponimo(String value) {
        return new JAXBElement<String>(_Toponimo_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Oggetto")
    public JAXBElement<String> createOggetto(String value) {
        return new JAXBElement<String>(_Oggetto_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "NumeroRegistrazione")
    public JAXBElement<String> createNumeroRegistrazione(String value) {
        return new JAXBElement<String>(_NumeroRegistrazione_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Ruolo")
    public JAXBElement<String> createRuolo(String value) {
        return new JAXBElement<String>(_Ruolo_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Telefono")
    public JAXBElement<String> createTelefono(String value) {
        return new JAXBElement<String>(_Telefono_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "CodiceTitolario")
    public JAXBElement<String> createCodiceTitolario(String value) {
        return new JAXBElement<String>(_CodiceTitolario_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Nome")
    public JAXBElement<String> createNome(String value) {
        return new JAXBElement<String>(_Nome_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Flusso")
    public JAXBElement<String> createFlusso(String value) {
        return new JAXBElement<String>(_Flusso_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Fax")
    public JAXBElement<String> createFax(String value) {
        return new JAXBElement<String>(_Fax_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Denominazione")
    public JAXBElement<String> createDenominazione(String value) {
        return new JAXBElement<String>(_Denominazione_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "", name = "Cognome")
    public JAXBElement<String> createCognome(String value) {
        return new JAXBElement<String>(_Cognome_QNAME, String.class, null, value);
    }

}
