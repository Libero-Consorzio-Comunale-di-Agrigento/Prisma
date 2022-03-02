//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2019.06.10 alle 09:40:58 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Classe Java per PiuInfo complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="PiuInfo">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}MetadatiInterni"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}MetadatiEsterni"/>
 *       &lt;/choice>
 *       &lt;attribute name="XMLSchema" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "PiuInfo", propOrder = {
    "metadatiInterni",
    "metadatiEsterni"
})
public class PiuInfo {

    @XmlElement(name = "MetadatiInterni")
    protected MetadatiInterni metadatiInterni;
    @XmlElement(name = "MetadatiEsterni")
    protected MetadatiEsterni metadatiEsterni;
    @XmlAttribute(name = "XMLSchema", required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String xmlSchema;

    /**
     * Recupera il valore della propriet� metadatiInterni.
     * 
     * @return
     *     possible object is
     *     {@link MetadatiInterni }
     *     
     */
    public MetadatiInterni getMetadatiInterni() {
        return metadatiInterni;
    }

    /**
     * Imposta il valore della propriet� metadatiInterni.
     * 
     * @param value
     *     allowed object is
     *     {@link MetadatiInterni }
     *     
     */
    public void setMetadatiInterni(MetadatiInterni value) {
        this.metadatiInterni = value;
    }

    /**
     * Recupera il valore della propriet� metadatiEsterni.
     * 
     * @return
     *     possible object is
     *     {@link MetadatiEsterni }
     *     
     */
    public MetadatiEsterni getMetadatiEsterni() {
        return metadatiEsterni;
    }

    /**
     * Imposta il valore della propriet� metadatiEsterni.
     * 
     * @param value
     *     allowed object is
     *     {@link MetadatiEsterni }
     *     
     */
    public void setMetadatiEsterni(MetadatiEsterni value) {
        this.metadatiEsterni = value;
    }

    /**
     * Recupera il valore della propriet� xmlSchema.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getXMLSchema() {
        return xmlSchema;
    }

    /**
     * Imposta il valore della propriet� xmlSchema.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setXMLSchema(String value) {
        this.xmlSchema = value;
    }

}
