//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.05.04 alle 12:46:51 PM CEST 
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
 *         &lt;element name="DES_UFFICIO_SMISTAMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DES_UFFICIO_TRASMISSIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="IDRIF" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="SMISTAMENTO_DAL" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="STATO_SMISTAMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TIPO_SMISTAMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UFFICIO_SMISTAMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UFFICIO_TRASMISSIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UTENTE_TRASMISSIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
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
    "desufficiosmistamento",
    "desufficiotrasmissione",
    "idrif",
    "smistamentodal",
    "statosmistamento",
    "tiposmistamento",
    "ufficiosmistamento",
    "ufficiotrasmissione",
    "utentetrasmissione"
})
@XmlRootElement(name = "SMISTAMENTO")
public class Smistamento {

    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "DES_UFFICIO_SMISTAMENTO")
    protected String desufficiosmistamento = "";
    @XmlElement(name = "DES_UFFICIO_TRASMISSIONE")
    protected String desufficiotrasmissione = "";
    @XmlElement(name = "IDRIF")
    protected String idrif = "";
    @XmlElement(name = "SMISTAMENTO_DAL")
    protected String smistamentodal = "";
    @XmlElement(name = "STATO_SMISTAMENTO")
    protected String statosmistamento = "";
    @XmlElement(name = "TIPO_SMISTAMENTO")
    protected String tiposmistamento = "";
    @XmlElement(name = "UFFICIO_SMISTAMENTO")
    protected String ufficiosmistamento = "";
    @XmlElement(name = "UFFICIO_TRASMISSIONE")
    protected String ufficiotrasmissione = "";
    @XmlElement(name = "UTENTE_TRASMISSIONE")
    protected String utentetrasmissione = "";

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
     * Recupera il valore della proprietà desufficiosmistamento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESUFFICIOSMISTAMENTO() {
        return desufficiosmistamento;
    }

    /**
     * Imposta il valore della proprietà desufficiosmistamento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESUFFICIOSMISTAMENTO(String value) {
        this.desufficiosmistamento = value;
    }

    /**
     * Recupera il valore della proprietà desufficiotrasmissione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESUFFICIOTRASMISSIONE() {
        return desufficiotrasmissione;
    }

    /**
     * Imposta il valore della proprietà desufficiotrasmissione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESUFFICIOTRASMISSIONE(String value) {
        this.desufficiotrasmissione = value;
    }

    /**
     * Recupera il valore della proprietà idrif.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIDRIF() {
        return idrif;
    }

    /**
     * Imposta il valore della proprietà idrif.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIDRIF(String value) {
        this.idrif = value;
    }

    /**
     * Recupera il valore della proprietà smistamentodal.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSMISTAMENTODAL() {
        return smistamentodal;
    }

    /**
     * Imposta il valore della proprietà smistamentodal.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSMISTAMENTODAL(String value) {
        this.smistamentodal = value;
    }

    /**
     * Recupera il valore della proprietà statosmistamento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSTATOSMISTAMENTO() {
        return statosmistamento;
    }

    /**
     * Imposta il valore della proprietà statosmistamento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSTATOSMISTAMENTO(String value) {
        this.statosmistamento = value;
    }

    /**
     * Recupera il valore della proprietà tiposmistamento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTIPOSMISTAMENTO() {
        return tiposmistamento;
    }

    /**
     * Imposta il valore della proprietà tiposmistamento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTIPOSMISTAMENTO(String value) {
        this.tiposmistamento = value;
    }

    /**
     * Recupera il valore della proprietà ufficiosmistamento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUFFICIOSMISTAMENTO() {
        return ufficiosmistamento;
    }

    /**
     * Imposta il valore della proprietà ufficiosmistamento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUFFICIOSMISTAMENTO(String value) {
        this.ufficiosmistamento = value;
    }

    /**
     * Recupera il valore della proprietà ufficiotrasmissione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUFFICIOTRASMISSIONE() {
        return ufficiotrasmissione;
    }

    /**
     * Imposta il valore della proprietà ufficiotrasmissione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUFFICIOTRASMISSIONE(String value) {
        this.ufficiotrasmissione = value;
    }

    /**
     * Recupera il valore della proprietà utentetrasmissione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUTENTETRASMISSIONE() {
        return utentetrasmissione;
    }

    /**
     * Imposta il valore della proprietà utentetrasmissione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUTENTETRASMISSIONE(String value) {
        this.utentetrasmissione = value;
    }

}
