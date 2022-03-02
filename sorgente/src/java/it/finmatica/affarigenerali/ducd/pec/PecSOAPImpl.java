
package it.finmatica.affarigenerali.ducd.pec;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.RequestWrapper;
import javax.xml.ws.ResponseWrapper;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.2.9-b130926.1035
 * Generated source version: 2.2
 *
 */
@WebService(name = "PecSOAPImpl", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it")
@XmlSeeAlso({
    ObjectFactory.class
})
public interface PecSOAPImpl {


    /**
     *
     * @param in
     * @return
     *     returns it.finmatica.affarigenerali.ducd.pec.ParametriUscita
     */
    @WebMethod
    @WebResult(name = "invioPecPGReturn", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it")
    @RequestWrapper(localName = "invioPecPG", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it", className = "it.finmatica.affarigenerali.ducd.pec.InvioPecPG")
    @ResponseWrapper(localName = "invioPecPGResponse", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it", className = "it.finmatica.affarigenerali.ducd.pec.InvioPecPGResponse")
    public ParametriUscita invioPecPG(
        @WebParam(name = "in", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it")
        ParametriIngressoPG in);

    /**
     *
     * @param in
     * @return
     *     returns it.finmatica.affarigenerali.ducd.pec.ParametriUscita
     */
    @WebMethod
    @WebResult(name = "invioPecReturn", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it")
    @RequestWrapper(localName = "invioPec", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it", className = "it.finmatica.affarigenerali.ducd.pec.InvioPec")
    @ResponseWrapper(localName = "invioPecResponse", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it", className = "it.finmatica.affarigenerali.ducd.pec.InvioPecResponse")
    public ParametriUscita invioPec(
        @WebParam(name = "in", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it")
        ParametriIngresso in);

}