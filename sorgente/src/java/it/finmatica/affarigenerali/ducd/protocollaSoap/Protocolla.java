
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
 *         &lt;element name="in" type="{http://protocolla.ducd.affarigenerali.finmatica.it}ParametriIngresso"/>
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
@XmlRootElement(name = "protocolla")
public class Protocolla {

    @XmlElement(required = true)
    protected ParametriIngresso in;

    /**
     * Recupera il valore della propriet� in.
     * 
     * @return
     *     possible object is
     *     {@link ParametriIngresso }
     *     
     */
    public ParametriIngresso getIn() {
        return in;
    }

    /**
     * Imposta il valore della propriet� in.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriIngresso }
     *     
     */
    public void setIn(ParametriIngresso value) {
        this.in = value;
    }

}
