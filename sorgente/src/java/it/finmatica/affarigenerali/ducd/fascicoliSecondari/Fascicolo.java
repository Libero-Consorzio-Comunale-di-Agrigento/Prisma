
package it.finmatica.affarigenerali.ducd.fascicoliSecondari;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per Fascicolo complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="Fascicolo">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="anno" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="classifica" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="codiceAmm" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="codiceAoo" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="progressivo" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Fascicolo", propOrder = {
    "anno",
    "classifica",
    "codiceAmm",
    "codiceAoo",
    "progressivo"
})
public class Fascicolo {

    protected int anno;
    @XmlElement(required = true, nillable = true)
    protected String classifica;
    @XmlElement(required = true, nillable = true)
    protected String codiceAmm;
    @XmlElement(required = true, nillable = true)
    protected String codiceAoo;
    @XmlElement(required = true, nillable = true)
    protected String progressivo;

    /**
     * Recupera il valore della propriet� anno.
     * 
     */
    public int getAnno() {
        return anno;
    }

    /**
     * Imposta il valore della propriet� anno.
     * 
     */
    public void setAnno(int value) {
        this.anno = value;
    }

    /**
     * Recupera il valore della propriet� classifica.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getClassifica() {
        return classifica;
    }

    /**
     * Imposta il valore della propriet� classifica.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setClassifica(String value) {
        this.classifica = value;
    }

    /**
     * Recupera il valore della propriet� codiceAmm.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCodiceAmm() {
        return codiceAmm;
    }

    /**
     * Imposta il valore della propriet� codiceAmm.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCodiceAmm(String value) {
        this.codiceAmm = value;
    }

    /**
     * Recupera il valore della propriet� codiceAoo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCodiceAoo() {
        return codiceAoo;
    }

    /**
     * Imposta il valore della propriet� codiceAoo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCodiceAoo(String value) {
        this.codiceAoo = value;
    }

    /**
     * Recupera il valore della propriet� progressivo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProgressivo() {
        return progressivo;
    }

    /**
     * Imposta il valore della propriet� progressivo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProgressivo(String value) {
        this.progressivo = value;
    }

}
