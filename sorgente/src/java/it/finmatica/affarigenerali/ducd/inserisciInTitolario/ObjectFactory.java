
package it.finmatica.affarigenerali.ducd.inserisciInTitolario;

import javax.xml.bind.annotation.XmlRegistry;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the it.finmatica.affarigenerali.ducd.inserisciintitolario package. 
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
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: it.finmatica.affarigenerali.ducd.inserisciintitolario
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link AggiungiAFascicolo }
     * 
     */
    public AggiungiAFascicolo createAggiungiAFascicolo() {
        return new AggiungiAFascicolo();
    }

    /**
     * Create an instance of {@link ParametriIngresso }
     * 
     */
    public ParametriIngresso createParametriIngresso() {
        return new ParametriIngresso();
    }

    /**
     * Create an instance of {@link AggiungiAFascicoloResponse }
     * 
     */
    public AggiungiAFascicoloResponse createAggiungiAFascicoloResponse() {
        return new AggiungiAFascicoloResponse();
    }

    /**
     * Create an instance of {@link ParametriUscita }
     * 
     */
    public ParametriUscita createParametriUscita() {
        return new ParametriUscita();
    }

    /**
     * Create an instance of {@link CreaFascicolo }
     * 
     */
    public CreaFascicolo createCreaFascicolo() {
        return new CreaFascicolo();
    }

    /**
     * Create an instance of {@link CreaFascicoloResponse }
     * 
     */
    public CreaFascicoloResponse createCreaFascicoloResponse() {
        return new CreaFascicoloResponse();
    }

}
