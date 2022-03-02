
package it.finmatica.affarigenerali.ducd.fascicoliSecondari;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.RequestWrapper;
import javax.xml.ws.ResponseWrapper;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.2.9-b130926.1035
 * Generated source version: 2.2
 * 
 */
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.WRAPPED, style = SOAPBinding.Style.RPC)
@WebService(name = "GestisciFascicoliDocumento", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it")
@XmlSeeAlso({
    ObjectFactory.class
})
public interface GestisciFascicoliDocumento {


    /**
     * 
     * @param in
     * @return
     *     returns it.finmatica.affarigenerali.ducd.fascicoli.ParametriUscita
     */
    @WebMethod
    @WebResult(name = "aggiungiFascicoliSecondariReturn", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it")
    @RequestWrapper(localName = "aggiungiFascicoliSecondari", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it", className = "it.finmatica.affarigenerali.ducd.fascicoli.AggiungiFascicoliSecondari")
    @ResponseWrapper(localName = "aggiungiFascicoliSecondariResponse", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it", className = "it.finmatica.affarigenerali.ducd.fascicoli.AggiungiFascicoliSecondariResponse")
    public ParametriUscita aggiungiFascicoliSecondari(
        @WebParam(name = "in", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it")
            ParametriIngresso in);

}
