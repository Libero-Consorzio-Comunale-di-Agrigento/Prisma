
package it.finmatica.protocollo.integrazioni.ws;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per anonymous complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="sostituisciDocumentoPrincipaleResult" type="{http://tempuri.org/}SostituisciDocumentoPrincipaleRet"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "sostituisciDocumentoPrincipaleResult"
})
@XmlRootElement(name = "sostituisciDocumentoPrincipaleResponse")
public class SostituisciDocumentoPrincipaleResponse {

    @XmlElement(required = true)
    protected SostituisciDocumentoPrincipaleRet sostituisciDocumentoPrincipaleResult;

    /**
     * Recupera il valore della proprietà sostituisciDocumentoPrincipaleResult.
     * 
     * @return
     *     possible object is
     *     {@link SostituisciDocumentoPrincipaleRet }
     *     
     */
    public SostituisciDocumentoPrincipaleRet getSostituisciDocumentoPrincipaleResult() {
        return sostituisciDocumentoPrincipaleResult;
    }

    /**
     * Imposta il valore della proprietà sostituisciDocumentoPrincipaleResult.
     * 
     * @param value
     *     allowed object is
     *     {@link SostituisciDocumentoPrincipaleRet }
     *     
     */
    public void setSostituisciDocumentoPrincipaleResult(SostituisciDocumentoPrincipaleRet value) {
        this.sostituisciDocumentoPrincipaleResult = value;
    }

}
