//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.05.12 alle 03:33:19 PM CEST 
//


package it.finmatica.protocollo.integrazioni.docAreaExtended;

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
 *         &lt;element name="ID_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element ref="{}RAPPORTO"/>
 *         &lt;element name="TIPO_RAPPORTO" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="UTENTE" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
    "iddocumento",
    "rapporto",
    "tiporapporto",
    "utente"
})
@XmlRootElement(name = "ROOT")
public class AddRapporto {

    @XmlElement(name = "ID_DOCUMENTO", required = true)
    protected String iddocumento = "";
    @XmlElement(name = "RAPPORTO", required = true)
    protected RapportWS rapporto;
    @XmlElement(name = "TIPO_RAPPORTO", required = true)
    protected String tiporapporto = "";
    @XmlElement(name = "UTENTE", required = true)
    protected String utente = "";

    /**
     * Recupera il valore della proprietà iddocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIDDOCUMENTO() {
        return iddocumento;
    }

    /**
     * Imposta il valore della proprietà iddocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIDDOCUMENTO(String value) {
        this.iddocumento = value;
    }

    /**
     * Recupera il valore della proprietà rapporto.
     * 
     * @return
     *     possible object is
     *     {@link RapportWS }
     *     
     */
    public RapportWS getRAPPORTO() {
        return rapporto;
    }

    /**
     * Imposta il valore della proprietà rapporto.
     * 
     * @param value
     *     allowed object is
     *     {@link RapportWS }
     *     
     */
    public void setRAPPORTO(RapportWS value) {
        this.rapporto = value;
    }

    /**
     * Recupera il valore della proprietà tiporapporto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTIPORAPPORTO() {
        return tiporapporto;
    }

    /**
     * Imposta il valore della proprietà tiporapporto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTIPORAPPORTO(String value) {
        this.tiporapporto = value;
    }

    /**
     * Recupera il valore della proprietà utente.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUTENTE() {
        return utente;
    }

    /**
     * Imposta il valore della proprietà utente.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUTENTE(String value) {
        this.utente = value;
    }

}
