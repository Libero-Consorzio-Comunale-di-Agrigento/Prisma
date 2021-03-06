//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2019.06.10 alle 09:40:58 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Classe Java per UnitaOrganizzativa complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="UnitaOrganizzativa">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Denominazione"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Identificativo" minOccurs="0"/>
 *         &lt;choice>
 *           &lt;element ref="{http://www.digitPa.gov.it/protocollo/}UnitaOrganizzativa"/>
 *           &lt;sequence>
 *             &lt;choice maxOccurs="unbounded" minOccurs="0">
 *               &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Ruolo"/>
 *               &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Persona"/>
 *             &lt;/choice>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}IndirizzoPostale"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}IndirizzoTelematico" maxOccurs="unbounded" minOccurs="0"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Telefono" maxOccurs="unbounded" minOccurs="0"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Fax" maxOccurs="unbounded" minOccurs="0"/>
 *           &lt;/sequence>
 *         &lt;/choice>
 *       &lt;/sequence>
 *       &lt;attribute name="tipo" default="permanente">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="permanente"/>
 *             &lt;enumeration value="temporanea"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "UnitaOrganizzativa", propOrder = {
    "denominazione",
    "identificativo",
    "unitaOrganizzativa",
    "ruoloOrPersona",
    "indirizzoPostale",
    "indirizzoTelematico",
    "telefono",
    "fax"
})
public class UnitaOrganizzativa {

    @XmlElement(name = "Denominazione", required = true)
    protected Denominazione denominazione;
    @XmlElement(name = "Identificativo")
    protected Identificativo identificativo;
    @XmlElement(name = "UnitaOrganizzativa")
    protected UnitaOrganizzativa unitaOrganizzativa;
    @XmlElements({
        @XmlElement(name = "Ruolo", type = Ruolo.class),
        @XmlElement(name = "Persona", type = Persona.class)
    })
    protected List<Object> ruoloOrPersona;
    @XmlElement(name = "IndirizzoPostale")
    protected IndirizzoPostale indirizzoPostale;
    @XmlElement(name = "IndirizzoTelematico")
    protected List<IndirizzoTelematico> indirizzoTelematico;
    @XmlElement(name = "Telefono")
    protected List<Telefono> telefono;
    @XmlElement(name = "Fax")
    protected List<Fax> fax;
    @XmlAttribute(name = "tipo")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String tipo;

    /**
     * Recupera il valore della propriet� denominazione.
     * 
     * @return
     *     possible object is
     *     {@link Denominazione }
     *     
     */
    public Denominazione getDenominazione() {
        return denominazione;
    }

    /**
     * Imposta il valore della propriet� denominazione.
     * 
     * @param value
     *     allowed object is
     *     {@link Denominazione }
     *     
     */
    public void setDenominazione(Denominazione value) {
        this.denominazione = value;
    }

    /**
     * Recupera il valore della propriet� identificativo.
     * 
     * @return
     *     possible object is
     *     {@link Identificativo }
     *     
     */
    public Identificativo getIdentificativo() {
        return identificativo;
    }

    /**
     * Imposta il valore della propriet� identificativo.
     * 
     * @param value
     *     allowed object is
     *     {@link Identificativo }
     *     
     */
    public void setIdentificativo(Identificativo value) {
        this.identificativo = value;
    }

    /**
     * Recupera il valore della propriet� unitaOrganizzativa.
     * 
     * @return
     *     possible object is
     *     {@link UnitaOrganizzativa }
     *     
     */
    public UnitaOrganizzativa getUnitaOrganizzativa() {
        return unitaOrganizzativa;
    }

    /**
     * Imposta il valore della propriet� unitaOrganizzativa.
     * 
     * @param value
     *     allowed object is
     *     {@link UnitaOrganizzativa }
     *     
     */
    public void setUnitaOrganizzativa(UnitaOrganizzativa value) {
        this.unitaOrganizzativa = value;
    }

    /**
     * Gets the value of the ruoloOrPersona property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the ruoloOrPersona property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getRuoloOrPersona().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Ruolo }
     * {@link Persona }
     * 
     * 
     */
    public List<Object> getRuoloOrPersona() {
        if (ruoloOrPersona == null) {
            ruoloOrPersona = new ArrayList<Object>();
        }
        return this.ruoloOrPersona;
    }

    /**
     * Recupera il valore della propriet� indirizzoPostale.
     * 
     * @return
     *     possible object is
     *     {@link IndirizzoPostale }
     *     
     */
    public IndirizzoPostale getIndirizzoPostale() {
        return indirizzoPostale;
    }

    /**
     * Imposta il valore della propriet� indirizzoPostale.
     * 
     * @param value
     *     allowed object is
     *     {@link IndirizzoPostale }
     *     
     */
    public void setIndirizzoPostale(IndirizzoPostale value) {
        this.indirizzoPostale = value;
    }

    /**
     * Gets the value of the indirizzoTelematico property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the indirizzoTelematico property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getIndirizzoTelematico().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link IndirizzoTelematico }
     * 
     * 
     */
    public List<IndirizzoTelematico> getIndirizzoTelematico() {
        if (indirizzoTelematico == null) {
            indirizzoTelematico = new ArrayList<IndirizzoTelematico>();
        }
        return this.indirizzoTelematico;
    }

    /**
     * Gets the value of the telefono property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the telefono property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getTelefono().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Telefono }
     * 
     * 
     */
    public List<Telefono> getTelefono() {
        if (telefono == null) {
            telefono = new ArrayList<Telefono>();
        }
        return this.telefono;
    }

    /**
     * Gets the value of the fax property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the fax property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getFax().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Fax }
     * 
     * 
     */
    public List<Fax> getFax() {
        if (fax == null) {
            fax = new ArrayList<Fax>();
        }
        return this.fax;
    }

    /**
     * Recupera il valore della propriet� tipo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTipo() {
        if (tipo == null) {
            return "permanente";
        } else {
            return tipo;
        }
    }

    /**
     * Imposta il valore della propriet� tipo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTipo(String value) {
        this.tipo = value;
    }

}
