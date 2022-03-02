
package it.finmatica.protocollo.integrazioni.ws;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.protocollo.integrazioni.ws package. 
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

    private final static QName _SostituisciDocumentoPrincipaleRetStrDataPG_QNAME = new QName("", "strDataPG");
    private final static QName _SostituisciDocumentoPrincipaleRetStrErrString_QNAME = new QName("", "strErrString");
    private final static QName _LoginRetStrDST_QNAME = new QName("", "strDST");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.protocollo.integrazioni.ws
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link Login }
     * 
     */
    public Login createLogin() {
        return new Login();
    }

    /**
     * Create an instance of {@link LoginResponse }
     * 
     */
    public LoginResponse createLoginResponse() {
        return new LoginResponse();
    }

    /**
     * Create an instance of {@link LoginRet }
     * 
     */
    public LoginRet createLoginRet() {
        return new LoginRet();
    }

    /**
     * Create an instance of {@link Inserimento }
     * 
     */
    public Inserimento createInserimento() {
        return new Inserimento();
    }

    /**
     * Create an instance of {@link InserimentoResponse }
     * 
     */
    public InserimentoResponse createInserimentoResponse() {
        return new InserimentoResponse();
    }

    /**
     * Create an instance of {@link InserimentoRet }
     * 
     */
    public InserimentoRet createInserimentoRet() {
        return new InserimentoRet();
    }

    /**
     * Create an instance of {@link SmistamentoAction }
     * 
     */
    public SmistamentoAction createSmistamentoAction() {
        return new SmistamentoAction();
    }

    /**
     * Create an instance of {@link SmistamentoActionResponse }
     * 
     */
    public SmistamentoActionResponse createSmistamentoActionResponse() {
        return new SmistamentoActionResponse();
    }

    /**
     * Create an instance of {@link SmistamentoActionRet }
     * 
     */
    public SmistamentoActionRet createSmistamentoActionRet() {
        return new SmistamentoActionRet();
    }

    /**
     * Create an instance of {@link Protocollazione }
     * 
     */
    public Protocollazione createProtocollazione() {
        return new Protocollazione();
    }

    /**
     * Create an instance of {@link ProtocollazioneResponse }
     * 
     */
    public ProtocollazioneResponse createProtocollazioneResponse() {
        return new ProtocollazioneResponse();
    }

    /**
     * Create an instance of {@link ProtocollazioneRet }
     * 
     */
    public ProtocollazioneRet createProtocollazioneRet() {
        return new ProtocollazioneRet();
    }

    /**
     * Create an instance of {@link AggiungiAllegato }
     * 
     */
    public AggiungiAllegato createAggiungiAllegato() {
        return new AggiungiAllegato();
    }

    /**
     * Create an instance of {@link AggiungiAllegatoResponse }
     * 
     */
    public AggiungiAllegatoResponse createAggiungiAllegatoResponse() {
        return new AggiungiAllegatoResponse();
    }

    /**
     * Create an instance of {@link AggiungiAllegatoRet }
     * 
     */
    public AggiungiAllegatoRet createAggiungiAllegatoRet() {
        return new AggiungiAllegatoRet();
    }

    /**
     * Create an instance of {@link SostituisciDocumentoPrincipale }
     * 
     */
    public SostituisciDocumentoPrincipale createSostituisciDocumentoPrincipale() {
        return new SostituisciDocumentoPrincipale();
    }

    /**
     * Create an instance of {@link SostituisciDocumentoPrincipaleResponse }
     * 
     */
    public SostituisciDocumentoPrincipaleResponse createSostituisciDocumentoPrincipaleResponse() {
        return new SostituisciDocumentoPrincipaleResponse();
    }

    /**
     * Create an instance of {@link SostituisciDocumentoPrincipaleRet }
     * 
     */
    public SostituisciDocumentoPrincipaleRet createSostituisciDocumentoPrincipaleRet() {
        return new SostituisciDocumentoPrincipaleRet();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strDataPG", scope = SostituisciDocumentoPrincipaleRet.class)
    public JAXBElement<String> createSostituisciDocumentoPrincipaleRetStrDataPG(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrDataPG_QNAME, String.class, SostituisciDocumentoPrincipaleRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strErrString", scope = SostituisciDocumentoPrincipaleRet.class)
    public JAXBElement<String> createSostituisciDocumentoPrincipaleRetStrErrString(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrErrString_QNAME, String.class, SostituisciDocumentoPrincipaleRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strDataPG", scope = AggiungiAllegatoRet.class)
    public JAXBElement<String> createAggiungiAllegatoRetStrDataPG(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrDataPG_QNAME, String.class, AggiungiAllegatoRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strErrString", scope = AggiungiAllegatoRet.class)
    public JAXBElement<String> createAggiungiAllegatoRetStrErrString(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrErrString_QNAME, String.class, AggiungiAllegatoRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strDataPG", scope = ProtocollazioneRet.class)
    public JAXBElement<String> createProtocollazioneRetStrDataPG(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrDataPG_QNAME, String.class, ProtocollazioneRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strErrString", scope = ProtocollazioneRet.class)
    public JAXBElement<String> createProtocollazioneRetStrErrString(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrErrString_QNAME, String.class, ProtocollazioneRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strErrString", scope = SmistamentoActionRet.class)
    public JAXBElement<String> createSmistamentoActionRetStrErrString(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrErrString_QNAME, String.class, SmistamentoActionRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strErrString", scope = InserimentoRet.class)
    public JAXBElement<String> createInserimentoRetStrErrString(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrErrString_QNAME, String.class, InserimentoRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strDST", scope = LoginRet.class)
    public JAXBElement<String> createLoginRetStrDST(String value) {
        return new JAXBElement<String>(_LoginRetStrDST_QNAME, String.class, LoginRet.class, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     * 
     * @param value
     *     Java instance representing xml element's value.
     * @return
     *     the new instance of {@link JAXBElement }{@code <}{@link String }{@code >}
     */
    @XmlElementDecl(namespace = "", name = "strErrString", scope = LoginRet.class)
    public JAXBElement<String> createLoginRetStrErrString(String value) {
        return new JAXBElement<String>(_SostituisciDocumentoPrincipaleRetStrErrString_QNAME, String.class, LoginRet.class, value);
    }

}
