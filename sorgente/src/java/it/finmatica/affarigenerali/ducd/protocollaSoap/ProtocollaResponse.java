
package it.finmatica.affarigenerali.ducd.protocollaSoap;

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
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="protocollaReturn" type="{http://protocolla.ducd.affarigenerali.finmatica.it}ParametriUscita"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "protocollaReturn"
})
@XmlRootElement(name = "protocollaResponse")
public class ProtocollaResponse {

    @XmlElement(required = true)
    protected ParametriUscita protocollaReturn;

    /**
     * Recupera il valore della propriet� protocollaReturn.
     * 
     * @return
     *     possible object is
     *     {@link ParametriUscita }
     *     
     */
    public ParametriUscita getProtocollaReturn() {
        return protocollaReturn;
    }

    /**
     * Imposta il valore della propriet� protocollaReturn.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriUscita }
     *     
     */
    public void setProtocollaReturn(ParametriUscita value) {
        this.protocollaReturn = value;
    }

}
