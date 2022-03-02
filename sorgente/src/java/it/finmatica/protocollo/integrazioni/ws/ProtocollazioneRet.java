
package it.finmatica.protocollo.integrazioni.ws;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per ProtocollazioneRet complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="ProtocollazioneRet"&gt;
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
@XmlType(name = "ProtocollazioneRet", propOrder = {
    "lngNumPG",
    "lngAnnoPG",
    "strDataPG",
    "lngErrNumber",
    "strErrString"
})
public class ProtocollazioneRet {

    protected long lngNumPG;
    protected long lngAnnoPG;
    @XmlElementRef(name = "strDataPG", type = JAXBElement.class, required = false)
    protected JAXBElement<String> strDataPG;
    protected long lngErrNumber;
    @XmlElementRef(name = "strErrString", type = JAXBElement.class, required = false)
    protected JAXBElement<String> strErrString;

    /**
     * Recupera il valore della proprietà lngNumPG.
     * 
     */
    public long getLngNumPG() {
        return lngNumPG;
    }

    /**
     * Imposta il valore della proprietà lngNumPG.
     * 
     */
    public void setLngNumPG(long value) {
        this.lngNumPG = value;
    }

    /**
     * Recupera il valore della proprietà lngAnnoPG.
     * 
     */
    public long getLngAnnoPG() {
        return lngAnnoPG;
    }

    /**
     * Imposta il valore della proprietà lngAnnoPG.
     * 
     */
    public void setLngAnnoPG(long value) {
        this.lngAnnoPG = value;
    }

    /**
     * Recupera il valore della proprietà strDataPG.
     * 
     * @return
     *     possible object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public JAXBElement<String> getStrDataPG() {
        return strDataPG;
    }

    /**
     * Imposta il valore della proprietà strDataPG.
     * 
     * @param value
     *     allowed object is
     *     {@link JAXBElement }{@code <}{@link String }{@code >}
     *     
     */
    public void setStrDataPG(JAXBElement<String> value) {
        this.strDataPG = value;
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
