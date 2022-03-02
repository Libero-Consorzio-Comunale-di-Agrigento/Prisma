
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
 *         &lt;element name="in" type="{http://pec.ducd.affarigenerali.finmatica.it}ParametriIngressoPG"/>
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
    "in"
})
@XmlRootElement(name = "invioPecPG")
public class InvioPecPG {

    @XmlElement(required = true)
    protected ParametriIngressoPG in;

    /**
     * Recupera il valore della proprietà in.
     * 
     * @return
     *     possible object is
     *     {@link ParametriIngressoPG }
     *     
     */
    public ParametriIngressoPG getIn() {
        return in;
    }

    /**
     * Imposta il valore della proprietà in.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriIngressoPG }
     *     
     */
    public void setIn(ParametriIngressoPG value) {
        this.in = value;
    }

}
