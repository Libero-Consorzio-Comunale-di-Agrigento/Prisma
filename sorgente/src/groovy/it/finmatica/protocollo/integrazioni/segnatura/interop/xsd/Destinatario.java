//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2019.06.10 alle 09:40:58 AM CEST 
//

package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlElementRefs;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Classe Java per Destinatario complex type.
 *
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 *
 * <pre>
 * &lt;complexType name="Destinatario">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;choice>
 *           &lt;sequence>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Amministrazione"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}AOO" minOccurs="0"/>
 *           &lt;/sequence>
 *           &lt;sequence>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Denominazione"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Persona" maxOccurs="unbounded" minOccurs="0"/>
 *           &lt;/sequence>
 *           &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Persona" maxOccurs="unbounded"/>
 *         &lt;/choice>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}IndirizzoTelematico" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Telefono" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Fax" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}IndirizzoPostale" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Destinatario", propOrder = {
    "amministrazione",
    "aoo",
    "privato",
    "denominazione",
    "persona",
    "indirizzoTelematico",
    "telefono",
    "fax",
    "indirizzoPostale"
})
public class Destinatario {

    /*@XmlElementRefs({
        @XmlElementRef(name = "AOO", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "Fax", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "IndirizzoPostale", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "Telefono", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "Persona", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "Denominazione", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "Amministrazione", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false),
        @XmlElementRef(name = "IndirizzoTelematico", namespace = "http://www.digitPa.gov.it/protocollo/", type = JAXBElement.class, required = false)
    })
    protected List<JAXBElement<?>> content;*/

    @XmlElement(name = "Amministrazione", required = false)
    protected Amministrazione amministrazione;

    @XmlElement(name = "AOO", required = false)
    protected AOO aoo;

    @XmlElement(name = "Privato", required = false)
    protected Privato privato;

    @XmlElement(name = "Denominazione", required = false)
    protected Denominazione denominazione;

    @XmlElement(name = "Persona", required = false)
    protected Persona persona;

    @XmlElement(name = "IndirizzoTelematico", required = false)
    protected IndirizzoTelematico indirizzoTelematico;

    @XmlElement(name = "Telefono", required = false)
    protected Telefono telefono;

    @XmlElement(name = "Fax", required = false)
    protected Fax fax;

    @XmlElement(name = "IndirizzoPostale", required = false)
    protected IndirizzoPostale indirizzoPostale;

    /**
     * Recupera il resto del modello di contenuto.
     *
     * <p>
     * Questa propriet� "catch-all" viene recuperata per il seguente motivo: Il nome di campo "Persona" � usato da due
     * diverse parti di uno schema. Vedere: riga 191 di file:/C:/tmp/Segnatura.xsd riga 188 di
     * file:/C:/tmp/Segnatura.xsd
     * <p>
     * Per eliminare questa propriet�, applicare una personalizzazione della propriet� a una delle seguenti due
     * dichiarazioni per modificarne il nome: Gets the value of the content property.
     *
     * <p>
     * This accessor method returns a reference to the live list, not a snapshot. Therefore any modification you make to
     * the returned list will be present inside the JAXB object. This is why there is not a <CODE>set</CODE> method for
     * the content property.
     *
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getContent().add(newItem);
     * </pre>
     *
     *
     * <p>
     * Objects of the following type(s) are allowed in the list {@link JAXBElement }{@code <}{@link AOO }{@code >}
     * {@link JAXBElement }{@code <}{@link Fax }{@code >} {@link JAXBElement }{@code <}{@link IndirizzoPostale }{@code
     * >} {@link JAXBElement }{@code <}{@link Telefono }{@code >} {@link JAXBElement }{@code <}{@link Persona }{@code >}
     * {@link JAXBElement }{@code <}{@link Denominazione }{@code >} {@link JAXBElement }{@code <}{@link Amministrazione
     * }{@code >} {@link JAXBElement }{@code <}{@link IndirizzoTelematico }{@code >}
     */
    /*public List<JAXBElement<?>> getContent() {
        if (content == null) {
            content = new ArrayList<JAXBElement<?>>();
        }
        return this.content;
    }

    public void setContent(List<JAXBElement<?>> content) {
        this.content = content;
    }*/

    public Amministrazione getAmministrazione() {
        return amministrazione;
    }

    public void setAmministrazione(Amministrazione amministrazione) {
        this.amministrazione = amministrazione;
    }

    public AOO getAoo() {
        return aoo;
    }

    public void setAoo(AOO aoo) {
        this.aoo = aoo;
    }

    public Denominazione getDenominazione() {
        return denominazione;
    }

    public void setDenominazione(Denominazione denominazione) {
        this.denominazione = denominazione;
    }

    public Persona getPersona() {
        return persona;
    }

    public void setPersona(Persona persona) {
        this.persona = persona;
    }

    public IndirizzoTelematico getIndirizzoTelematico() {
        return indirizzoTelematico;
    }

    public void setIndirizzoTelematico(
        IndirizzoTelematico indirizzoTelematico) {
        this.indirizzoTelematico = indirizzoTelematico;
    }

    public Telefono getTelefono() {
        return telefono;
    }

    public void setTelefono(Telefono telefono) {
        this.telefono = telefono;
    }

    public Fax getFax() {
        return fax;
    }

    public void setFax(Fax fax) {
        this.fax = fax;
    }

    public IndirizzoPostale getIndirizzoPostale() {
        return indirizzoPostale;
    }

    public void setIndirizzoPostale(IndirizzoPostale indirizzoPostale) {
        this.indirizzoPostale = indirizzoPostale;
    }


    public Privato getPrivato() {
        return privato;
    }

    public void setPrivato(Privato privato) {
        this.privato = privato;
    }
}
