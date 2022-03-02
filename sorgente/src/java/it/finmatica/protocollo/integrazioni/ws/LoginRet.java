
package it.finmatica.protocollo.integrazioni.ws;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per LoginRet complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="LoginRet"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="strDST" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
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
@XmlType(name = "LoginRet", propOrder = {
    "strDST",
    "lngErrNumber",
    "strErrString"
})
public class LoginRet {

    @XmlElementRef(name = "strDST", type = JAXBElement.class, required = false)
    protected JAXBElement<String> strDST;
    protected long lngErrNumber;
    @XmlElementRef(name = "strErrString", type = JAXBElement.class, required = false)
    protected JAXBElement<String> strErrString;

    /**
     * Recupera il valore della proprietà strDST.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getStrDST() {
        return strDST;
    }

    /**
     * Imposta il valore della proprietà strDST.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setStrDST(JAXBElement<String> value) {
        this.strDST = value;
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
