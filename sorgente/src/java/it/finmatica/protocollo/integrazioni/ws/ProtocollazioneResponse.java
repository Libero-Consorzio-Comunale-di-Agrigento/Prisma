
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
 *         &lt;element name="ProtocollazioneResult" type="{http://tempuri.org/}ProtocollazioneRet"/&gt;
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
    "protocollazioneResult"
})
@XmlRootElement(name = "protocollazioneResponse")
public class ProtocollazioneResponse {

    @XmlElement(name = "ProtocollazioneResult", required = true)
    protected ProtocollazioneRet protocollazioneResult;

    /**
     * Recupera il valore della proprietà protocollazioneResult.
     * 
     * @return
     *     possible object is
     *     {@link ProtocollazioneRet }
     *     
     */
    public ProtocollazioneRet getProtocollazioneResult() {
        return protocollazioneResult;
    }

    /**
     * Imposta il valore della proprietà protocollazioneResult.
     * 
     * @param value
     *     allowed object is
     *     {@link ProtocollazioneRet }
     *     
     */
    public void setProtocollazioneResult(ProtocollazioneRet value) {
        this.protocollazioneResult = value;
    }

}
