
package it.finmatica.protocollo.integrazioni.ws;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per SostituisciDocumentoPrincipaleRet complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="SostituisciDocumentoPrincipaleRet"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="lngNumPG" type="{http://www.w3.org/2001/XMLSchema}long"/&gt;
 *         &lt;element name="lngAnnoPG" type="{http://www.w3.org/2001/XMLSchema}long"/&gt;
 *         &lt;element name="strDataPG" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="lngErrNumber" type="{http://www.w3.org/2001/XMLSchema}long"/&gt;
 *         &lt;element name="strErrString" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SostituisciDocumentoPrincipaleRet", propOrder = {
    "lngDocID",
    "lngErrNumber",
    "strErrString"
})
public class SostituisciDocumentoPrincipaleRet {

    protected long lngDocID;
    protected long lngErrNumber;
    @XmlElementRef(name = "strErrString", type = JAXBElement.class, required = false)
    protected JAXBElement<String> strErrString;

    /**
     * Recupera il valore della proprietà lngNumPG.
     * 
     */
    public long getLngDocID() {
        return lngDocID;
    }

    /**
     * Imposta il valore della proprietà lngNumPG.
     * 
     */
    public void setLngDocID(long value) {
        this.lngDocID = value;
    }

    /**
     * Recupera il valore della proprietà lngErrNumber.
     * 
     */
    public long getLngErrNumber() {
        return lngErrNumber;
    }

    /**
     * Imposta il valore della proprietà lngErrNumber.
     * 
     */
    public void setLngErrNumber(long value) {
        this.lngErrNumber = value;
    }

    /**
     * Recupera il valore della proprietà strErrString.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getStrErrString() {
        return strErrString;
    }

    /**
     * Imposta il valore della proprietà strErrString.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setStrErrString(JAXBElement<String> value) {
        this.strErrString = value;
    }

}
