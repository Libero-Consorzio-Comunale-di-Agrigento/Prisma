
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
 *         &lt;element name="LoginResult" type="{http://tempuri.org/}LoginRet"/&gt;
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
    "loginResult"
})
@XmlRootElement(name = "loginResponse")
public class LoginResponse {

    @XmlElement(name = "LoginResult", required = true)
    protected LoginRet loginResult;

    /**
     * Recupera il valore della proprietà loginResult.
     * 
     * @return
     *     possible object is
     *     {@link LoginRet }
     *     
     */
    public LoginRet getLoginResult() {
        return loginResult;
    }

    /**
     * Imposta il valore della proprietà loginResult.
     * 
     * @param value
     *     allowed object is
     *     {@link LoginRet }
     *     
     */
    public void setLoginResult(LoginRet value) {
        this.loginResult = value;
    }

}
