
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
 *         &lt;element name="SmistamentoActionResult" type="{http://tempuri.org/}SmistamentoActionRet"/&gt;
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
    "smistamentoActionResult"
})
@XmlRootElement(name = "smistamentoActionResponse")
public class SmistamentoActionResponse {

    @XmlElement(name = "SmistamentoActionResult", required = true)
    protected SmistamentoActionRet smistamentoActionResult;

    /**
     * Recupera il valore della proprietà smistamentoActionResult.
     * 
     * @return
     *     possible object is
     *     {@link SmistamentoActionRet }
     *     
     */
    public SmistamentoActionRet getSmistamentoActionResult() {
        return smistamentoActionResult;
    }

    /**
     * Imposta il valore della proprietà smistamentoActionResult.
     * 
     * @param value
     *     allowed object is
     *     {@link SmistamentoActionRet }
     *     
     */
    public void setSmistamentoActionResult(SmistamentoActionRet value) {
        this.smistamentoActionResult = value;
    }

}
