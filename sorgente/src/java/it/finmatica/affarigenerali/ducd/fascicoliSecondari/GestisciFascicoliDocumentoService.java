
package it.finmatica.affarigenerali.ducd.fascicoliSecondari;

import java.net.MalformedURLException;
import java.net.URL;
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
@WebServiceClient(name = "GestisciFascicoliDocumentoService", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it", wsdlLocation = "http://test-agspr-as/ducd/services/GestisciFascicoliDocumento?wsdl")
public class GestisciFascicoliDocumentoService
    extends Service
{

    private final static URL GESTISCIFASCICOLIDOCUMENTOSERVICE_WSDL_LOCATION;
    private final static WebServiceException GESTISCIFASCICOLIDOCUMENTOSERVICE_EXCEPTION;
    private final static QName GESTISCIFASCICOLIDOCUMENTOSERVICE_QNAME = new QName("http://fascicoli.ducd.affarigenerali.finmatica.it", "GestisciFascicoliDocumentoService");

    static {
        URL url = null;
        WebServiceException e = null;
        try {
            url = new URL("http://test-agspr-as/ducd/services/GestisciFascicoliDocumento?wsdl");
        } catch (MalformedURLException ex) {
            e = new WebServiceException(ex);
        }
        GESTISCIFASCICOLIDOCUMENTOSERVICE_WSDL_LOCATION = url;
        GESTISCIFASCICOLIDOCUMENTOSERVICE_EXCEPTION = e;
    }

    public GestisciFascicoliDocumentoService() {
        super(__getWsdlLocation(), GESTISCIFASCICOLIDOCUMENTOSERVICE_QNAME);
    }

    public GestisciFascicoliDocumentoService(WebServiceFeature... features) {
        super(__getWsdlLocation(), GESTISCIFASCICOLIDOCUMENTOSERVICE_QNAME, features);
    }

    public GestisciFascicoliDocumentoService(URL wsdlLocation) {
        super(wsdlLocation, GESTISCIFASCICOLIDOCUMENTOSERVICE_QNAME);
    }

    public GestisciFascicoliDocumentoService(URL wsdlLocation, WebServiceFeature... features) {
        super(wsdlLocation, GESTISCIFASCICOLIDOCUMENTOSERVICE_QNAME, features);
    }

    public GestisciFascicoliDocumentoService(URL wsdlLocation, QName serviceName) {
        super(wsdlLocation, serviceName);
    }

    public GestisciFascicoliDocumentoService(URL wsdlLocation, QName serviceName, WebServiceFeature... features) {
        super(wsdlLocation, serviceName, features);
    }

    /**
     * 
     * @return
     *     returns GestisciFascicoliDocumento
     */
    @WebEndpoint(name = "GestisciFascicoliDocumento")
    public GestisciFascicoliDocumento getGestisciFascicoliDocumento() {
        return super.getPort(new QName("http://fascicoli.ducd.affarigenerali.finmatica.it", "GestisciFascicoliDocumento"), GestisciFascicoliDocumento.class);
    }

    /**
     * 
     * @param features
     *     A list of {@link WebServiceFeature} to configure on the proxy.  Supported features not in the <code>features</code> parameter will have their default values.
     * @return
     *     returns GestisciFascicoliDocumento
     */
    @WebEndpoint(name = "GestisciFascicoliDocumento")
    public GestisciFascicoliDocumento getGestisciFascicoliDocumento(WebServiceFeature... features) {
        return super.getPort(new QName("http://fascicoli.ducd.affarigenerali.finmatica.it", "GestisciFascicoliDocumento"), GestisciFascicoliDocumento.class, features);
    }

    private static URL __getWsdlLocation() {
        if (GESTISCIFASCICOLIDOCUMENTOSERVICE_EXCEPTION!= null) {
            throw GESTISCIFASCICOLIDOCUMENTOSERVICE_EXCEPTION;
        }
        return GESTISCIFASCICOLIDOCUMENTOSERVICE_WSDL_LOCATION;
    }

}
