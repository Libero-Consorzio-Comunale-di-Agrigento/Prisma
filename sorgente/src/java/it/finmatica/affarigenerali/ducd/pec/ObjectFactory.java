
package it.finmatica.affarigenerali.ducd.pec;

import javax.xml.bind.annotation.XmlRegistry;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.affarigenerali.ducd.pec package. 
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
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.affarigenerali.ducd.pec
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link InvioPec }
     * 
     */
    public InvioPec createInvioPec() {
        return new InvioPec();
    }

    /**
     * Create an instance of {@link ParametriIngresso }
     * 
     */
    public ParametriIngresso createParametriIngresso() {
        return new ParametriIngresso();
    }

    /**
     * Create an instance of {@link InvioPecResponse }
     * 
     */
    public InvioPecResponse createInvioPecResponse() {
        return new InvioPecResponse();
    }

    /**
     * Create an instance of {@link ParametriUscita }
     * 
     */
    public ParametriUscita createParametriUscita() {
        return new ParametriUscita();
    }

    /**
     * Create an instance of {@link InvioPecPG }
     * 
     */
    public InvioPecPG createInvioPecPG() {
        return new InvioPecPG();
    }

    /**
     * Create an instance of {@link ParametriIngressoPG }
     * 
     */
    public ParametriIngressoPG createParametriIngressoPG() {
        return new ParametriIngressoPG();
    }

    /**
     * Create an instance of {@link InvioPecPGResponse }
     * 
     */
    public InvioPecPGResponse createInvioPecPGResponse() {
        return new InvioPecPGResponse();
    }

}
