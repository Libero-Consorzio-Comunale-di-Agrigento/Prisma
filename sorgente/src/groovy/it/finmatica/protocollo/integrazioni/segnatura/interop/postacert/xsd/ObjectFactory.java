//
// Questo file ่ stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrเ persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.09.02 alle 10:08:33 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.postacert.xsd;

import javax.xml.bind.annotation.XmlRegistry;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.protocollo.integrazioni.segnatura.interop.postacert.xsd package. 
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


    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.protocollo.integrazioni.segnatura.interop.postacert.xsd
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link Postacert }
     * 
     */
    public Postacert createPostacert() {
        return new Postacert();
    }

    /**
     * Create an instance of {@link Postacert.Dati }
     * 
     */
    public Postacert.Dati createPostacertDati() {
        return new Postacert.Dati();
    }

    /**
     * Create an instance of {@link Postacert.Intestazione }
     * 
     */
    public Postacert.Intestazione createPostacertIntestazione() {
        return new Postacert.Intestazione();
    }

    /**
     * Create an instance of {@link Postacert.Dati.Data }
     * 
     */
    public Postacert.Dati.Data createPostacertDatiData() {
        return new Postacert.Dati.Data();
    }

    /**
     * Create an instance of {@link Postacert.Dati.Ricevuta }
     * 
     */
    public Postacert.Dati.Ricevuta createPostacertDatiRicevuta() {
        return new Postacert.Dati.Ricevuta();
    }

    /**
     * Create an instance of {@link Postacert.Intestazione.Destinatari }
     * 
     */
    public Postacert.Intestazione.Destinatari createPostacertIntestazioneDestinatari() {
        return new Postacert.Intestazione.Destinatari();
    }

}
