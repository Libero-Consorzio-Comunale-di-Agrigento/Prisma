
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
 *         &lt;element name="invioPecPGReturn" type="{http://pec.ducd.affarigenerali.finmatica.it}ParametriUscita"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(propOrder = {
    "invioPecPGReturn"
})
@XmlRootElement(name = "invioPecPGResponse")
public class InvioPecPGResponse {

    @XmlElement(required = true, name = "invioPecPGReturn")
    protected ParametriUscita invioPecPGReturn;

    /**
     * Recupera il valore della proprietà invioPecPGReturn.
     * 
     * @return
     *     possible object is
     *     {@link ParametriUscita }
     *     
     */
    public ParametriUscita getInvioPecPGReturn() {
        return invioPecPGReturn;
    }

    /**
     * Imposta il valore della proprietà invioPecPGReturn.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriUscita }
     *     
     */
    public void setInvioPecPGReturn(ParametriUscita value) {
        this.invioPecPGReturn = value;
    }

}
