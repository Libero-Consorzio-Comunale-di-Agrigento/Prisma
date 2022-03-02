//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.05.04 alle 12:48:11 PM CEST 
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
 *         &lt;element name="IDRIF" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ANNO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="NUMERO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TIPO_REGISTRO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_TIPO_REGISTRO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="OGGETTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_COD" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_DAL" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_ANNO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_NUMERO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UNITA_PROTOCOLLANTE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UTENTE_PROTOCOLLANTE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="MODALITA" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="INT"/>
 *               &lt;enumeration value="PAR"/>
 *               &lt;enumeration value="ARR"/>
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
    "idrif",
    "anno",
    "numero",
    "tiporegistro",
    "descrizionetiporegistro",
    "data",
    "oggetto",
    "classcod",
    "classdal",
    "fascicoloanno",
    "fascicolonumero",
    "unitaprotocollante",
    "utenteprotocollante",
    "modalita"
})
@XmlRootElement(name = "DATI")
public class Dati {

    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "IDRIF")
    protected String idrif = "";
    @XmlElement(name = "ANNO")
    protected String anno = "";
    @XmlElement(name = "NUMERO")
    protected String numero = "";
    @XmlElement(name = "TIPO_REGISTRO")
    protected String tiporegistro = "";
    @XmlElement(name = "DESCRIZIONE_TIPO_REGISTRO")
    protected String descrizionetiporegistro = "";
    @XmlElement(name = "DATA")
    protected String data = "";
    @XmlElement(name = "OGGETTO")
    protected String oggetto = "";
    @XmlElement(name = "CLASS_COD")
    protected String classcod = "";
    @XmlElement(name = "CLASS_DAL")
    protected String classdal = "";
    @XmlElement(name = "FASCICOLO_ANNO")
    protected String fascicoloanno = "";
    @XmlElement(name = "FASCICOLO_NUMERO")
    protected String fascicolonumero = "";
    @XmlElement(name = "UNITA_PROTOCOLLANTE")
    protected String unitaprotocollante = "";
    @XmlElement(name = "UTENTE_PROTOCOLLANTE")
    protected String utenteprotocollante = "";
    @XmlElement(name = "MODALITA")
    protected String modalita = "";

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
     * Recupera il valore della proprietà anno.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getANNO() {
        return anno;
    }

    /**
     * Imposta il valore della proprietà anno.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setANNO(String value) {
        this.anno = value;
    }

    /**
     * Recupera il valore della proprietà numero.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNUMERO() {
        return numero;
    }

    /**
     * Imposta il valore della proprietà numero.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNUMERO(String value) {
        this.numero = value;
    }

    /**
     * Recupera il valore della proprietà tiporegistro.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTIPOREGISTRO() {
        return tiporegistro;
    }

    /**
     * Imposta il valore della proprietà tiporegistro.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTIPOREGISTRO(String value) {
        this.tiporegistro = value;
    }

    /**
     * Recupera il valore della proprietà descrizionetiporegistro.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONETIPOREGISTRO() {
        return descrizionetiporegistro;
    }

    /**
     * Imposta il valore della proprietà descrizionetiporegistro.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONETIPOREGISTRO(String value) {
        this.descrizionetiporegistro = value;
    }

    /**
     * Recupera il valore della proprietà data.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATA() {
        return data;
    }

    /**
     * Imposta il valore della proprietà data.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATA(String value) {
        this.data = value;
    }

    /**
     * Recupera il valore della proprietà oggetto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOGGETTO() {
        return oggetto;
    }

    /**
     * Imposta il valore della proprietà oggetto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOGGETTO(String value) {
        this.oggetto = value;
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
     * Recupera il valore della proprietà unitaprotocollante.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUNITAPROTOCOLLANTE() {
        return unitaprotocollante;
    }

    /**
     * Imposta il valore della proprietà unitaprotocollante.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUNITAPROTOCOLLANTE(String value) {
        this.unitaprotocollante = value;
    }

    /**
     * Recupera il valore della proprietà utenteprotocollante.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUTENTEPROTOCOLLANTE() {
        return utenteprotocollante;
    }

    /**
     * Imposta il valore della proprietà utenteprotocollante.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUTENTEPROTOCOLLANTE(String value) {
        this.utenteprotocollante = value;
    }

    /**
     * Recupera il valore della proprietà modalita.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMODALITA() {
        return modalita;
    }

    /**
     * Imposta il valore della proprietà modalita.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMODALITA(String value) {
        this.modalita = value;
    }

}
