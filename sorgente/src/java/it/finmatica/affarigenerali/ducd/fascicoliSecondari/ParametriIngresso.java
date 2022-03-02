
package it.finmatica.affarigenerali.ducd.fascicoliSecondari;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per ParametriIngresso complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="ParametriIngresso">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="fascicoliSecondari" type="{http://fascicoli.ducd.affarigenerali.finmatica.it}ArrayOfFascicolo"/>
 *         &lt;element name="iddocumento" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ParametriIngresso", propOrder = {
    "fascicoliSecondari",
    "iddocumento"
})
public class ParametriIngresso {

    @XmlElement(required = true, nillable = true)
    protected ArrayOfFascicolo fascicoliSecondari;
    @XmlElement(required = true, nillable = true)
    protected String iddocumento;

    /**
     * Recupera il valore della propriet� fascicoliSecondari.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfFascicolo }
     *     
     */
    public ArrayOfFascicolo getFascicoliSecondari() {
        return fascicoliSecondari;
    }

    /**
     * Imposta il valore della propriet� fascicoliSecondari.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfFascicolo }
     *     
     */
    public void setFascicoliSecondari(ArrayOfFascicolo value) {
        this.fascicoliSecondari = value;
    }

    /**
     * Recupera il valore della propriet� iddocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIddocumento() {
        return iddocumento;
    }

    /**
     * Imposta il valore della propriet� iddocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIddocumento(String value) {
        this.iddocumento = value;
    }

}
