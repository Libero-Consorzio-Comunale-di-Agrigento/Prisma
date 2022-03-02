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
 *         &lt;element name="IDRIF" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ANNO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="NUMERO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TIPO_REGISTRO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_TIPO_REGISTRO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="OGGETTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_ARRIVO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="NUMERO_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_COD" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CLASS_DAL" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_ANNO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_NUMERO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="RISERVATO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="STATO_PR" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DOCUMENTO_TRAMITE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TIPO_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_TIPO_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UNITA_ESIBENTE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UNITA_PROTOCOLLANTE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UTENTE_PROTOCOLLANTE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ANNULLATO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_ANN" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UTENTE_ANN" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="MODALITA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
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
    "datadocumento",
    "dataarrivo",
    "numerodocumento",
    "classcod",
    "classdal",
    "fascicoloanno",
    "fascicolonumero",
    "riservato",
    "statopr",
    "documentotramite",
    "tipodocumento",
    "descrizionetipodocumento",
    "unitaesibente",
    "unitaprotocollante",
    "utenteprotocollante",
    "annullato",
    "dataann",
    "utenteann",
    "modalita",
    "dataSpedizione"
})
@XmlRootElement(name = "DOC")
public class Doc {

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
    @XmlElement(name = "DATA_DOCUMENTO")
    protected String datadocumento = "";
    @XmlElement(name = "DATA_ARRIVO")
    protected String dataarrivo = "";
    @XmlElement(name = "NUMERO_DOCUMENTO")
    protected String numerodocumento = "";
    @XmlElement(name = "CLASS_COD")
    protected String classcod = "";
    @XmlElement(name = "CLASS_DAL")
    protected String classdal = "";
    @XmlElement(name = "FASCICOLO_ANNO")
    protected String fascicoloanno = "";
    @XmlElement(name = "FASCICOLO_NUMERO")
    protected String fascicolonumero = "";
    @XmlElement(name = "RISERVATO")
    protected String riservato = "";
    @XmlElement(name = "STATO_PR")
    protected String statopr = "";
    @XmlElement(name = "DOCUMENTO_TRAMITE")
    protected String documentotramite = "";
    @XmlElement(name = "TIPO_DOCUMENTO")
    protected String tipodocumento = "";
    @XmlElement(name = "DESCRIZIONE_TIPO_DOCUMENTO")
    protected String descrizionetipodocumento = "";
    @XmlElement(name = "UNITA_ESIBENTE")
    protected String unitaesibente = "";
    @XmlElement(name = "UNITA_PROTOCOLLANTE")
    protected String unitaprotocollante = "";
    @XmlElement(name = "UTENTE_PROTOCOLLANTE")
    protected String utenteprotocollante = "";
    @XmlElement(name = "ANNULLATO")
    protected String annullato = "";
    @XmlElement(name = "DATA_ANN")
    protected String dataann = "";
    @XmlElement(name = "UTENTE_ANN")
    protected String utenteann = "";
    @XmlElement(name = "MODALITA")
    protected String modalita = "";
    @XmlElement(name = "DATA_SPEDIZIONE")
    protected String dataSpedizione = "";

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
     * Recupera il valore della proprietà datadocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATADOCUMENTO() {
        return datadocumento;
    }

    /**
     * Imposta il valore della proprietà datadocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATADOCUMENTO(String value) {
        this.datadocumento = value;
    }

    /**
     * Recupera il valore della proprietà dataarrivo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATAARRIVO() {
        return dataarrivo;
    }

    /**
     * Imposta il valore della proprietà dataarrivo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATAARRIVO(String value) {
        this.dataarrivo = value;
    }

    /**
     * Recupera il valore della proprietà numerodocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNUMERODOCUMENTO() {
        return numerodocumento;
    }

    /**
     * Imposta il valore della proprietà numerodocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNUMERODOCUMENTO(String value) {
        this.numerodocumento = value;
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
     * Recupera il valore della proprietà riservato.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRISERVATO() {
        return riservato;
    }

    /**
     * Imposta il valore della proprietà riservato.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRISERVATO(String value) {
        this.riservato = value;
    }

    /**
     * Recupera il valore della proprietà statopr.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSTATOPR() {
        return statopr;
    }

    /**
     * Imposta il valore della proprietà statopr.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSTATOPR(String value) {
        this.statopr = value;
    }

    /**
     * Recupera il valore della proprietà documentotramite.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDOCUMENTOTRAMITE() {
        return documentotramite;
    }

    /**
     * Imposta il valore della proprietà documentotramite.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDOCUMENTOTRAMITE(String value) {
        this.documentotramite = value;
    }

    /**
     * Recupera il valore della proprietà tipodocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTIPODOCUMENTO() {
        return tipodocumento;
    }

    /**
     * Imposta il valore della proprietà tipodocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTIPODOCUMENTO(String value) {
        this.tipodocumento = value;
    }

    /**
     * Recupera il valore della proprietà descrizionetipodocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONETIPODOCUMENTO() {
        return descrizionetipodocumento;
    }

    /**
     * Imposta il valore della proprietà descrizionetipodocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONETIPODOCUMENTO(String value) {
        this.descrizionetipodocumento = value;
    }

    /**
     * Recupera il valore della proprietà unitaesibente.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUNITAESIBENTE() {
        return unitaesibente;
    }

    /**
     * Imposta il valore della proprietà unitaesibente.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUNITAESIBENTE(String value) {
        this.unitaesibente = value;
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
     * Recupera il valore della proprietà annullato.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getANNULLATO() {
        return annullato;
    }

    /**
     * Imposta il valore della proprietà annullato.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setANNULLATO(String value) {
        this.annullato = value;
    }

    /**
     * Recupera il valore della proprietà dataann.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATAANN() {
        return dataann;
    }

    /**
     * Imposta il valore della proprietà dataann.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATAANN(String value) {
        this.dataann = value;
    }

    /**
     * Recupera il valore della proprietà utenteann.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUTENTEANN() {
        return utenteann;
    }

    /**
     * Imposta il valore della proprietà utenteann.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUTENTEANN(String value) {
        this.utenteann = value;
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

    public String getDataSpedizione() {
        return dataSpedizione;
    }

    public void setDataSpedizione(String dataSpedizione) {
        this.dataSpedizione = dataSpedizione;
    }
}
