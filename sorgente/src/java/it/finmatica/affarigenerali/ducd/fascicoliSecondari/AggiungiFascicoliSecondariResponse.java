
package it.finmatica.affarigenerali.ducd.fascicoliSecondari;

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
 *         &lt;element name="aggiungiFascicoliSecondariReturn" type="{http://fascicoli.ducd.affarigenerali.finmatica.it}ParametriUscita"/>
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
    "aggiungiFascicoliSecondariReturn"
})
@XmlRootElement(name = "aggiungiFascicoliSecondariResponse")
public class AggiungiFascicoliSecondariResponse {

    @XmlElement(required = true)
    protected ParametriUscita aggiungiFascicoliSecondariReturn;

    /**
     * Recupera il valore della propriet� aggiungiFascicoliSecondariReturn.
     * 
     * @return
     *     possible object is
     *     {@link ParametriUscita }
     *     
     */
    public ParametriUscita getAggiungiFascicoliSecondariReturn() {
        return aggiungiFascicoliSecondariReturn;
    }

    /**
     * Imposta il valore della propriet� aggiungiFascicoliSecondariReturn.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriUscita }
     *     
     */
    public void setAggiungiFascicoliSecondariReturn(ParametriUscita value) {
        this.aggiungiFascicoliSecondariReturn = value;
    }

}
