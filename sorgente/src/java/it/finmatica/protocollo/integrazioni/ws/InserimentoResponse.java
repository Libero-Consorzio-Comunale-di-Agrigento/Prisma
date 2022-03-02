
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
 *         &lt;element name="InserimentoResult" type="{http://tempuri.org/}InserimentoRet"/&gt;
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
    "inserimentoResult"
})
@XmlRootElement(name = "inserimentoResponse")
public class InserimentoResponse {

    @XmlElement(name = "InserimentoResult", required = true)
    protected InserimentoRet inserimentoResult;

    /**
     * Recupera il valore della proprietà inserimentoResult.
     * 
     * @return
     *     possible object is
     *     {@link InserimentoRet }
     *     
     */
    public InserimentoRet getInserimentoResult() {
        return inserimentoResult;
    }

    /**
     * Imposta il valore della proprietà inserimentoResult.
     * 
     * @param value
     *     allowed object is
     *     {@link InserimentoRet }
     *     
     */
    public void setInserimentoResult(InserimentoRet value) {
        this.inserimentoResult = value;
    }

}
