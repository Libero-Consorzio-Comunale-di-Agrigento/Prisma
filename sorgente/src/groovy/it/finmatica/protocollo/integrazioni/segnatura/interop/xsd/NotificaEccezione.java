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
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Classe Java per NotificaEccezione complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="NotificaEccezione">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Identificatore" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}MessaggioRicevuto"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Motivo"/>
 *       &lt;/sequence>
 *       &lt;attribute name="versione" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" fixed="aaaa-mmgg" />
 *       &lt;attribute name="xml-lang" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" fixed="it" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "NotificaEccezione")
@XmlType(name = "NotificaEccezione", propOrder = {
    "identificatore",
    "messaggioRicevuto",
    "motivo"
})
public class NotificaEccezione {

    @XmlElement(name = "Identificatore")
    protected Identificatore identificatore;
    @XmlElement(name = "MessaggioRicevuto", required = true)
    protected MessaggioRicevuto messaggioRicevuto;
    @XmlElement(name = "Motivo", required = true)
    protected Motivo motivo;
    @XmlAttribute(name = "versione")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String versione;
    @XmlAttribute(name = "xml-lang")
    @XmlSchemaType(name = "anySimpleType")
    protected String xmlLang;

    /**
     * Recupera il valore della propriet� identificatore.
     * 
     * @return
     *     possible object is
     *     {@link Identificatore }
     *     
     */
    public Identificatore getIdentificatore() {
        return identificatore;
    }

    /**
     * Imposta il valore della propriet� identificatore.
     * 
     * @param value
     *     allowed object is
     *     {@link Identificatore }
     *     
     */
    public void setIdentificatore(Identificatore value) {
        this.identificatore = value;
    }

    /**
     * Recupera il valore della propriet� messaggioRicevuto.
     * 
     * @return
     *     possible object is
     *     {@link MessaggioRicevuto }
     *     
     */
    public MessaggioRicevuto getMessaggioRicevuto() {
        return messaggioRicevuto;
    }

    /**
     * Imposta il valore della propriet� messaggioRicevuto.
     * 
     * @param value
     *     allowed object is
     *     {@link MessaggioRicevuto }
     *     
     */
    public void setMessaggioRicevuto(MessaggioRicevuto value) {
        this.messaggioRicevuto = value;
    }

    /**
     * Recupera il valore della propriet� motivo.
     * 
     * @return
     *     possible object is
     *     {@link Motivo }
     *     
     */
    public Motivo getMotivo() {
        return motivo;
    }

    /**
     * Imposta il valore della propriet� motivo.
     * 
     * @param value
     *     allowed object is
     *     {@link Motivo }
     *     
     */
    public void setMotivo(Motivo value) {
        this.motivo = value;
    }

    /**
     * Recupera il valore della propriet� versione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVersione() {
        if (versione == null) {
            return "aaaa-mmgg";
        } else {
            return versione;
        }
    }

    /**
     * Imposta il valore della propriet� versione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVersione(String value) {
        this.versione = value;
    }

    /**
     * Recupera il valore della propriet� xmlLang.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getXmlLang() {
        if (xmlLang == null) {
            return "it";
        } else {
            return xmlLang;
        }
    }

    /**
     * Imposta il valore della propriet� xmlLang.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setXmlLang(String value) {
        this.xmlLang = value;
    }

}
