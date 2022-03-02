
package it.finmatica.affarigenerali.ducd.inserisciInTitolario;

import java.net.MalformedURLException;
import java.net.URL;
import javax.jws.soap.SOAPBinding;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.xml.ws.WebEndpoint;
import javax.xml.ws.WebServiceClient;
import javax.xml.ws.WebServiceException;
import javax.xml.ws.WebServiceFeature;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.2.9-b130926.1035
 * Generated source version: 2.2
 * 
 */
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.WRAPPED, style = SOAPBinding.Style.RPC)
@WebServiceClient(name = "inserisciInTitolario", targetNamespace = "http://ducd.affarigenerali.finmatica.it/inserisciInTitolario/", wsdlLocation = "http://test-agspr-as/ducd/services/inserisciInTitolarioSOAP?wsdl")
public class InserisciInTitolarioService
    extends Service
{

    private final static URL INSERISCIINTITOLARIO_WSDL_LOCATION;
    private final static WebServiceException INSERISCIINTITOLARIO_EXCEPTION;
    private final static QName INSERISCIINTITOLARIO_QNAME = new QName("http://ducd.affarigenerali.finmatica.it/inserisciInTitolario/", "inserisciInTitolario");

    static {
        URL url = null;
        WebServiceException e = null;
        try {
            url = new URL("http://test-agspr-as/ducd/services/inserisciInTitolarioSOAP?wsdl");
        } catch (MalformedURLException ex) {
            e = new WebServiceException(ex);
        }
        INSERISCIINTITOLARIO_WSDL_LOCATION = url;
        INSERISCIINTITOLARIO_EXCEPTION = e;
    }

    public InserisciInTitolarioService() {
        super(__getWsdlLocation(), INSERISCIINTITOLARIO_QNAME);
    }

    public InserisciInTitolarioService(WebServiceFeature... features) {
        super(__getWsdlLocation(), INSERISCIINTITOLARIO_QNAME, features);
    }

    public InserisciInTitolarioService(URL wsdlLocation) {
        super(wsdlLocation, INSERISCIINTITOLARIO_QNAME);
    }

    public InserisciInTitolarioService(URL wsdlLocation, WebServiceFeature... features) {
        super(wsdlLocation, INSERISCIINTITOLARIO_QNAME, features);
    }

    public InserisciInTitolarioService(URL wsdlLocation, QName serviceName) {
        super(wsdlLocation, serviceName);
    }

    public InserisciInTitolarioService(URL wsdlLocation, QName serviceName, WebServiceFeature... features) {
        super(wsdlLocation, serviceName, features);
    }

    /**
     * 
     * @return
     *     returns InserisciInTitolario
     */
    @WebEndpoint(name = "inserisciInTitolarioSOAP")
    public InserisciInTitolario getInserisciInTitolarioSOAP() {
        return super.getPort(new QName("http://ducd.affarigenerali.finmatica.it/inserisciInTitolario/", "inserisciInTitolarioSOAP"), InserisciInTitolario.class);
    }

    /**
     * 
     * @param features
     *     A list of {@link WebServiceFeature} to configure on the proxy.  Supported features not in the <code>features</code> parameter will have their default values.
     * @return
     *     returns InserisciInTitolario
     */
    @WebEndpoint(name = "inserisciInTitolarioSOAP")
    public InserisciInTitolario getInserisciInTitolarioSOAP(WebServiceFeature... features) {
        return super.getPort(new QName("http://ducd.affarigenerali.finmatica.it/inserisciInTitolario/", "inserisciInTitolarioSOAP"), InserisciInTitolario.class, features);
    }

    private static URL __getWsdlLocation() {
        if (INSERISCIINTITOLARIO_EXCEPTION!= null) {
            throw INSERISCIINTITOLARIO_EXCEPTION;
        }
        return INSERISCIINTITOLARIO_WSDL_LOCATION;
    }

}