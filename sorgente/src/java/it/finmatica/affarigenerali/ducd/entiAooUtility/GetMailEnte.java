
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
 *         &lt;element name="codice_amministrazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="descrizione_amministrazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="codice_aoo" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="descrizione_aoo" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="indirizzo_mail" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
    "codiceAmministrazione",
    "descrizioneAmministrazione",
    "codiceAoo",
    "descrizioneAoo",
    "indirizzoMail"
})
@XmlRootElement(name = "getMailEnte")
public class GetMailEnte {

    @XmlElement(name = "codice_amministrazione", required = true)
    protected String codiceAmministrazione;
    @XmlElement(name = "descrizione_amministrazione", required = true)
    protected String descrizioneAmministrazione;
    @XmlElement(name = "codice_aoo", required = true)
    protected String codiceAoo;
    @XmlElement(name = "descrizione_aoo", required = true)
    protected String descrizioneAoo;
    @XmlElement(name = "indirizzo_mail", required = true)
    protected String indirizzoMail;

    /**
     * Recupera il valore della propriet� codiceAmministrazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCodiceAmministrazione() {
        return codiceAmministrazione;
    }

    /**
     * Imposta il valore della propriet� codiceAmministrazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCodiceAmministrazione(String value) {
        this.codiceAmministrazione = value;
    }

    /**
     * Recupera il valore della propriet� descrizioneAmministrazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDescrizioneAmministrazione() {
        return descrizioneAmministrazione;
    }

    /**
     * Imposta il valore della propriet� descrizioneAmministrazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDescrizioneAmministrazione(String value) {
        this.descrizioneAmministrazione = value;
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
     * Recupera il valore della propriet� descrizioneAoo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDescrizioneAoo() {
        return descrizioneAoo;
    }

    /**
     * Imposta il valore della propriet� descrizioneAoo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDescrizioneAoo(String value) {
        this.descrizioneAoo = value;
    }

    /**
     * Recupera il valore della propriet� indirizzoMail.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndirizzoMail() {
        return indirizzoMail;
    }

    /**
     * Imposta il valore della propriet� indirizzoMail.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndirizzoMail(String value) {
        this.indirizzoMail = value;
    }

}
