
package it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione

import javax.xml.bind.JAXBElement
import javax.xml.bind.annotation.XmlElementDecl
import javax.xml.bind.annotation.XmlRegistry
import javax.xml.namespace.QName

/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.protocollo.integrazioni.ws.si4cs package. 
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

    private final static QName _Return_QNAME = new QName("http://ws.finmatica.it/", "return");
    private final static QName _SendMessaggioRicevuto_QNAME = new QName("http://ws.finmatica.it/", "sendMessaggioRicevuto");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.protocollo.integrazioni.ws.si4cs
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link SendMessaggioRicevuto }
     *
     */
    public SendMessaggioRicevuto createSendMessaggioRicevuto() {
        return new SendMessaggioRicevuto();
    }

    /**
     * Create an instance of {@link it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse }
     *
     */
    public it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse createSendMessaggioRicevutoResponse() {
        return new it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse();
    }

    /**
     * Create an instance of {@link it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto }
     *
     */
    public it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto createMessaggioRicevuto() {
        return new it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SendMessaggioRicevutoResponse }{@code >}}
     *
     */
    @XmlElementDecl(namespace = "http://ws.finmatica.it/", name = "return")
    public JAXBElement<it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse> createReturn(it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse value) {
        return new JAXBElement<it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse>(_Return_QNAME, it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link SendMessaggioRicevuto }{@code >}}
     *
     */
    @XmlElementDecl(namespace = "http://ws.finmatica.it/", name = "sendMessaggioRicevuto")
    public JAXBElement<SendMessaggioRicevuto> createSendMessaggioRicevuto(SendMessaggioRicevuto value) {
        return new JAXBElement<SendMessaggioRicevuto>(_SendMessaggioRicevuto_QNAME, SendMessaggioRicevuto.class, null, value);
    }

}
