//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.02.12 alle 12:36:01 PM CET 
//


package it.finmatica.protocollo.integrazioni.jdocarea;

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
 *       &lt;choice>
 *         &lt;sequence>
 *           &lt;element ref="{}Amministrazione"/>
 *           &lt;element ref="{}AOO"/>
 *         &lt;/sequence>
 *         &lt;element ref="{}Persona"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "amministrazione",
    "aoo",
    "persona"
})
@XmlRootElement(name = "Mittente")
public class Mittente {

    @XmlElement(name = "Amministrazione")
    protected Amministrazione amministrazione;
    @XmlElement(name = "AOO")
    protected AOO aoo;
    @XmlElement(name = "Persona")
    protected Persona persona;

    /**
     * Recupera il valore della proprietà amministrazione.
     * 
     * @return
     *     possible object is
     *     {@link Amministrazione }
     *     
     */
    public Amministrazione getAmministrazione() {
        return amministrazione;
    }

    /**
     * Imposta il valore della proprietà amministrazione.
     * 
     * @param value
     *     allowed object is
     *     {@link Amministrazione }
     *     
     */
    public void setAmministrazione(Amministrazione value) {
        this.amministrazione = value;
    }

    /**
     * Recupera il valore della proprietà aoo.
     * 
     * @return
     *     possible object is
     *     {@link AOO }
     *     
     */
    public AOO getAOO() {
        return aoo;
    }

    /**
     * Imposta il valore della proprietà aoo.
     * 
     * @param value
     *     allowed object is
     *     {@link AOO }
     *     
     */
    public void setAOO(AOO value) {
        this.aoo = value;
    }

    /**
     * Recupera il valore della proprietà persona.
     * 
     * @return
     *     possible object is
     *     {@link Persona }
     *     
     */
    public Persona getPersona() {
        return persona;
    }

    /**
     * Imposta il valore della proprietà persona.
     * 
     * @param value
     *     allowed object is
     *     {@link Persona }
     *     
     */
    public void setPersona(Persona value) {
        this.persona = value;
    }

}
