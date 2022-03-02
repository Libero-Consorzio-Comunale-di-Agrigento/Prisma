
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
 *         &lt;element name="getMailEnteReturn" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
    "getMailEnteReturn"
})
@XmlRootElement(name = "getMailEnteResponse")
public class GetMailEnteResponse {

    @XmlElement(required = true)
    protected String getMailEnteReturn;

    /**
     * Recupera il valore della propriet� getMailEnteReturn.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGetMailEnteReturn() {
        return getMailEnteReturn;
    }

    /**
     * Imposta il valore della propriet� getMailEnteReturn.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGetMailEnteReturn(String value) {
        this.getMailEnteReturn = value;
    }

}
