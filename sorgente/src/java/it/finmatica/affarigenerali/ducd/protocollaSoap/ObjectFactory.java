
package it.finmatica.affarigenerali.ducd.protocollaSoap;

import javax.xml.bind.annotation.XmlRegistry;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.affarigenerali.ducd.protocolla package. 
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
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.affarigenerali.ducd.protocolla
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link ProtocollaResponse }
     * 
     */
    public ProtocollaResponse createProtocollaResponse() {
        return new ProtocollaResponse();
    }

    /**
     * Create an instance of {@link ParametriUscita }
     * 
     */
    public ParametriUscita createParametriUscita() {
        return new ParametriUscita();
    }

    /**
     * Create an instance of {@link Protocolla }
     * 
     */
    public Protocolla createProtocolla() {
        return new Protocolla();
    }

    /**
     * Create an instance of {@link ParametriIngresso }
     * 
     */
    public ParametriIngresso createParametriIngresso() {
        return new ParametriIngresso();
    }

}
