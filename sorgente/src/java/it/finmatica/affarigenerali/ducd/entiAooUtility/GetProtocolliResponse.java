
package it.finmatica.affarigenerali.ducd.entiAooUtility;

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
 *         &lt;element name="getProtocolliReturn" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
    "getProtocolliReturn"
})
@XmlRootElement(name = "getProtocolliResponse")
public class GetProtocolliResponse {

    @XmlElement(required = true)
    protected String getProtocolliReturn;

    /**
     * Recupera il valore della propriet� getProtocolliReturn.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGetProtocolliReturn() {
        return getProtocolliReturn;
    }

    /**
     * Imposta il valore della propriet� getProtocolliReturn.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGetProtocolliReturn(String value) {
        this.getProtocolliReturn = value;
    }

}
