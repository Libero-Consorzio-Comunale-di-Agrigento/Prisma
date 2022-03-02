
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
 *         &lt;element name="strCodEnte" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="strUserName" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="strPassword" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
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
    "strCodEnte",
    "strUserName",
    "strPassword"
})
@XmlRootElement(name = "login")
public class Login {

    @XmlElement(required = true)
    protected String strCodEnte;
    @XmlElement(required = true)
    protected String strUserName;
    @XmlElement(required = true)
    protected String strPassword;

    /**
     * Recupera il valore della proprietà strCodEnte.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStrCodEnte() {
        return strCodEnte;
    }

    /**
     * Imposta il valore della proprietà strCodEnte.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStrCodEnte(String value) {
        this.strCodEnte = value;
    }

    /**
     * Recupera il valore della proprietà strUserName.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStrUserName() {
        return strUserName;
    }

    /**
     * Imposta il valore della proprietà strUserName.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStrUserName(String value) {
        this.strUserName = value;
    }

    /**
     * Recupera il valore della proprietà strPassword.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStrPassword() {
        return strPassword;
    }

    /**
     * Imposta il valore della proprietà strPassword.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStrPassword(String value) {
        this.strPassword = value;
    }

}
