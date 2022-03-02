//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.05.04 alle 12:40:28 PM CEST 
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
 *         &lt;element name="ID_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_COD" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_DAL" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_AL" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_CREAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CONTENITORE_DOCUMENTI" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;pattern value="Y|N"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
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
    "classcod",
    "classdal",
    "classal",
    "descrizione",
    "datacreazione",
    "contenitoredocumenti"
})
@XmlRootElement(name = "CLASSIFICA")
public class Classifica {

    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "CLASS_COD")
    protected String classcod = "";
    @XmlElement(name = "CLASS_DAL")
    protected String classdal = "";
    @XmlElement(name = "CLASS_AL")
    protected String classal = "";
    @XmlElement(name = "DESCRIZIONE")
    protected String descrizione = "";
    @XmlElement(name = "DATA_CREAZIONE")
    protected String datacreazione = "";
    @XmlElement(name = "CONTENITORE_DOCUMENTI")
    protected String contenitoredocumenti = "";

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
     * Recupera il valore della proprietà classcod.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCLASSCOD() {
        return classcod;
    }

    /**
     * Imposta il valore della proprietà classcod.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCLASSCOD(String value) {
        this.classcod = value;
    }

    /**
     * Recupera il valore della proprietà classdal.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCLASSDAL() {
        return classdal;
    }

    /**
     * Imposta il valore della proprietà classdal.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCLASSDAL(String value) {
        this.classdal = value;
    }

    /**
     * Recupera il valore della proprietà classal.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCLASSAL() {
        return classal;
    }

    /**
     * Imposta il valore della proprietà classal.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCLASSAL(String value) {
        this.classal = value;
    }

    /**
     * Recupera il valore della proprietà descrizione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONE() {
        return descrizione;
    }

    /**
     * Imposta il valore della proprietà descrizione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONE(String value) {
        this.descrizione = value;
    }

    /**
     * Recupera il valore della proprietà datacreazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATACREAZIONE() {
        return datacreazione;
    }

    /**
     * Imposta il valore della proprietà datacreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATACREAZIONE(String value) {
        this.datacreazione = value;
    }

    /**
     * Recupera il valore della proprietà contenitoredocumenti.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCONTENITOREDOCUMENTI() {
        return contenitoredocumenti;
    }

    /**
     * Imposta il valore della proprietà contenitoredocumenti.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCONTENITOREDOCUMENTI(String value) {
        this.contenitoredocumenti = value;
    }

}
