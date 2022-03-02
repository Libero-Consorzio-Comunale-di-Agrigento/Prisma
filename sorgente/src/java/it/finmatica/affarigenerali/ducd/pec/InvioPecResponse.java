
package it.finmatica.affarigenerali.ducd.pec;

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
 *         &lt;element name="invioPecReturn" type="{http://pec.ducd.affarigenerali.finmatica.it}ParametriUscita"/>
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
    "invioPecReturn"
})
@XmlRootElement(name = "invioPecResponse")
public class InvioPecResponse {

    @XmlElement(required = true)
    protected ParametriUscita invioPecReturn;

    /**
     * Recupera il valore della proprietà invioPecReturn.
     * 
     * @return
     *     possible object is
     *     {@link ParametriUscita }
     *     
     */
    public ParametriUscita getInvioPecReturn() {
        return invioPecReturn;
    }

    /**
     * Imposta il valore della proprietà invioPecReturn.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriUscita }
     *     
     */
    public void setInvioPecReturn(ParametriUscita value) {
        this.invioPecReturn = value;
    }

}
