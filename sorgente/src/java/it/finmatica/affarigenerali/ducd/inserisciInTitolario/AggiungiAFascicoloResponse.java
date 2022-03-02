
package it.finmatica.affarigenerali.ducd.inserisciInTitolario;

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
 *         &lt;element name="out" type="{http://ducd.affarigenerali.finmatica.it/inserisciInTitolario/}ParametriUscita"/>
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
    "out"
})
@XmlRootElement(name = "aggiungiAFascicoloResponse")
public class AggiungiAFascicoloResponse {

    @XmlElement(required = true)
    protected ParametriUscita out;

    /**
     * Recupera il valore della propriet� out.
     * 
     * @return
     *     possible object is
     *     {@link ParametriUscita }
     *     
     */
    public ParametriUscita getOut() {
        return out;
    }

    /**
     * Imposta il valore della propriet� out.
     * 
     * @param value
     *     allowed object is
     *     {@link ParametriUscita }
     *     
     */
    public void setOut(ParametriUscita value) {
        this.out = value;
    }

}
