
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
 *         &lt;element name="AggiungiAllegatoResult" type="{http://tempuri.org/}AggiungiAllegatoRet"/&gt;
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
    "aggiungiAllegatoResult"
})
@XmlRootElement(name = "aggiungiAllegatoResponse")
public class AggiungiAllegatoResponse {

    @XmlElement(name = "AggiungiAllegatoResult", required = true)
    protected AggiungiAllegatoRet aggiungiAllegatoResult;

    /**
     * Recupera il valore della proprietà aggiungiAllegatoResult.
     * 
     * @return
     *     possible object is
     *     {@link AggiungiAllegatoRet }
     *     
     */
    public AggiungiAllegatoRet getAggiungiAllegatoResult() {
        return aggiungiAllegatoResult;
    }

    /**
     * Imposta il valore della proprietà aggiungiAllegatoResult.
     * 
     * @param value
     *     allowed object is
     *     {@link AggiungiAllegatoRet }
     *     
     */
    public void setAggiungiAllegatoResult(AggiungiAllegatoRet value) {
        this.aggiungiAllegatoResult = value;
    }

}
