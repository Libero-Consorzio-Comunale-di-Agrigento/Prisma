//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.05.04 alle 12:22:23 PM CEST 
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
 *       &lt;all>
 *         &lt;element name="RESULT">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;pattern value="OK|KO"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="EXCEPTION" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="MESSAGE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ERROR_NUMBER" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ID" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ID_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_ANNO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_NUMERO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_COD" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TEXT" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/all>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {

})
@XmlRootElement(name = "ROOT")
public class Result {

    @XmlElement(name = "RESULT", required = true)
    protected String result = "";
    @XmlElement(name = "EXCEPTION")
    protected String exception = "";
    @XmlElement(name = "MESSAGE")
    protected String message = "";
    @XmlElement(name = "ERROR_NUMBER")
    protected String errornumber = "";
    @XmlElement(name = "ID")
    protected String id = "";
    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "FASCICOLO_ANNO")
    protected String fascicoloanno = "";
    @XmlElement(name = "FASCICOLO_NUMERO")
    protected String fascicolonumero = "";
    @XmlElement(name = "CLASS_COD")
    protected String classcod = "";
    @XmlElement(name = "TEXT")
    protected String text = "";

    /**
     * Recupera il valore della proprietà result.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRESULT() {
        return result;
    }

    /**
     * Imposta il valore della proprietà result.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRESULT(String value) {
        this.result = value;
    }

    /**
     * Recupera il valore della proprietà exception.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEXCEPTION() {
        return exception;
    }

    /**
     * Imposta il valore della proprietà exception.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEXCEPTION(String value) {
        this.exception = value;
    }

    /**
     * Recupera il valore della proprietà message.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMESSAGE() {
        return message;
    }

    /**
     * Imposta il valore della proprietà message.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMESSAGE(String value) {
        this.message = value;
    }

    /**
     * Recupera il valore della proprietà errornumber.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getERRORNUMBER() {
        return errornumber;
    }

    /**
     * Imposta il valore della proprietà errornumber.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setERRORNUMBER(String value) {
        this.errornumber = value;
    }

    /**
     * Recupera il valore della proprietà id.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getID() {
        return id;
    }

    /**
     * Imposta il valore della proprietà id.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setID(String value) {
        this.id = value;
    }

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
     * Recupera il valore della proprietà fascicoloanno.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFASCICOLOANNO() {
        return fascicoloanno;
    }

    /**
     * Imposta il valore della proprietà fascicoloanno.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFASCICOLOANNO(String value) {
        this.fascicoloanno = value;
    }

    /**
     * Recupera il valore della proprietà fascicolonumero.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFASCICOLONUMERO() {
        return fascicolonumero;
    }

    /**
     * Imposta il valore della proprietà fascicolonumero.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFASCICOLONUMERO(String value) {
        this.fascicolonumero = value;
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
     * Recupera il valore della proprietà text.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTEXT() {
        return text;
    }

    /**
     * Imposta il valore della proprietà text.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTEXT(String value) {
        this.text = value;
    }

}
