//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.05.04 alle 12:47:29 PM CEST 
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
 *         &lt;element name="FASCICOLO_ANNO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_NUMERO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="FASCICOLO_OGGETTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="NOTE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="PROCEDIMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="RESPONSABILE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="STATO_FASCICOLO" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="1"/>
 *               &lt;enumeration value="2"/>
 *               &lt;enumeration value="3"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="DESCRIZIONE_STATO_FASCICOLO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UFFICIO_COMPETENZA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_UFFICIO_COMPETENZA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UFFICIO_CREAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_UFFICIO_CREAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="UTENTE_CREAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_UTENTE_CREAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_APERTURA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_CHIUSURA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_CREAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="STATO_SCARTO" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="**"/>
 *               &lt;enumeration value="RR"/>
 *               &lt;enumeration value="CO"/>
 *               &lt;enumeration value="AA"/>
 *               &lt;enumeration value="PS"/>
 *               &lt;enumeration value="SC"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="DESCRIZIONE_STATO_SCARTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DATA_STATO_SCARTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CODICE_AMMINISTRAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CODICE_AOO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
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
    "fascicoloanno",
    "fascicolonumero",
    "fascicolooggetto",
    "note",
    "procedimento",
    "responsabile",
    "statofascicolo",
    "descrizionestatofascicolo",
    "ufficiocompetenza",
    "descrizioneufficiocompetenza",
    "ufficiocreazione",
    "descrizioneufficiocreazione",
    "utentecreazione",
    "descrizioneutentecreazione",
    "dataapertura",
    "datachiusura",
    "datacreazione",
    "statoscarto",
    "descrizionestatoscarto",
    "datastatoscarto",
    "codiceamministrazione",
    "codiceaoo"
})
@XmlRootElement(name = "FASCICOLO")
public class Fascicolo {

    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "CLASS_COD")
    protected String classcod = "";
    @XmlElement(name = "CLASS_DAL")
    protected String classdal = "";
    @XmlElement(name = "FASCICOLO_ANNO")
    protected String fascicoloanno = "";
    @XmlElement(name = "FASCICOLO_NUMERO")
    protected String fascicolonumero = "";
    @XmlElement(name = "FASCICOLO_OGGETTO")
    protected String fascicolooggetto = "";
    @XmlElement(name = "NOTE")
    protected String note = "";
    @XmlElement(name = "PROCEDIMENTO")
    protected String procedimento = "";
    @XmlElement(name = "RESPONSABILE")
    protected String responsabile = "";
    @XmlElement(name = "STATO_FASCICOLO")
    protected String statofascicolo = "";
    @XmlElement(name = "DESCRIZIONE_STATO_FASCICOLO")
    protected String descrizionestatofascicolo = "";
    @XmlElement(name = "UFFICIO_COMPETENZA")
    protected String ufficiocompetenza = "";
    @XmlElement(name = "DESCRIZIONE_UFFICIO_COMPETENZA")
    protected String descrizioneufficiocompetenza = "";
    @XmlElement(name = "UFFICIO_CREAZIONE")
    protected String ufficiocreazione = "";
    @XmlElement(name = "DESCRIZIONE_UFFICIO_CREAZIONE")
    protected String descrizioneufficiocreazione = "";
    @XmlElement(name = "UTENTE_CREAZIONE")
    protected String utentecreazione = "";
    @XmlElement(name = "DESCRIZIONE_UTENTE_CREAZIONE")
    protected String descrizioneutentecreazione = "";
    @XmlElement(name = "DATA_APERTURA")
    protected String dataapertura = "";
    @XmlElement(name = "DATA_CHIUSURA")
    protected String datachiusura = "";
    @XmlElement(name = "DATA_CREAZIONE")
    protected String datacreazione = "";
    @XmlElement(name = "STATO_SCARTO")
    protected String statoscarto = "";
    @XmlElement(name = "DESCRIZIONE_STATO_SCARTO")
    protected String descrizionestatoscarto = "";
    @XmlElement(name = "DATA_STATO_SCARTO")
    protected String datastatoscarto = "";
    @XmlElement(name = "CODICE_AMMINISTRAZIONE")
    protected String codiceamministrazione = "";
    @XmlElement(name = "CODICE_AOO")
    protected String codiceaoo = "";

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
     * Recupera il valore della proprietà fascicolooggetto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFASCICOLOOGGETTO() {
        return fascicolooggetto;
    }

    /**
     * Imposta il valore della proprietà fascicolooggetto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFASCICOLOOGGETTO(String value) {
        this.fascicolooggetto = value;
    }

    /**
     * Recupera il valore della proprietà note.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNOTE() {
        return note;
    }

    /**
     * Imposta il valore della proprietà note.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNOTE(String value) {
        this.note = value;
    }

    /**
     * Recupera il valore della proprietà procedimento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPROCEDIMENTO() {
        return procedimento;
    }

    /**
     * Imposta il valore della proprietà procedimento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPROCEDIMENTO(String value) {
        this.procedimento = value;
    }

    /**
     * Recupera il valore della proprietà responsabile.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRESPONSABILE() {
        return responsabile;
    }

    /**
     * Imposta il valore della proprietà responsabile.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRESPONSABILE(String value) {
        this.responsabile = value;
    }

    /**
     * Recupera il valore della proprietà statofascicolo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSTATOFASCICOLO() {
        return statofascicolo;
    }

    /**
     * Imposta il valore della proprietà statofascicolo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSTATOFASCICOLO(String value) {
        this.statofascicolo = value;
    }

    /**
     * Recupera il valore della proprietà descrizionestatofascicolo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONESTATOFASCICOLO() {
        return descrizionestatofascicolo;
    }

    /**
     * Imposta il valore della proprietà descrizionestatofascicolo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONESTATOFASCICOLO(String value) {
        this.descrizionestatofascicolo = value;
    }

    /**
     * Recupera il valore della proprietà ufficiocompetenza.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUFFICIOCOMPETENZA() {
        return ufficiocompetenza;
    }

    /**
     * Imposta il valore della proprietà ufficiocompetenza.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUFFICIOCOMPETENZA(String value) {
        this.ufficiocompetenza = value;
    }

    /**
     * Recupera il valore della proprietà descrizioneufficiocompetenza.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONEUFFICIOCOMPETENZA() {
        return descrizioneufficiocompetenza;
    }

    /**
     * Imposta il valore della proprietà descrizioneufficiocompetenza.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONEUFFICIOCOMPETENZA(String value) {
        this.descrizioneufficiocompetenza = value;
    }

    /**
     * Recupera il valore della proprietà ufficiocreazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUFFICIOCREAZIONE() {
        return ufficiocreazione;
    }

    /**
     * Imposta il valore della proprietà ufficiocreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUFFICIOCREAZIONE(String value) {
        this.ufficiocreazione = value;
    }

    /**
     * Recupera il valore della proprietà descrizioneufficiocreazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONEUFFICIOCREAZIONE() {
        return descrizioneufficiocreazione;
    }

    /**
     * Imposta il valore della proprietà descrizioneufficiocreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONEUFFICIOCREAZIONE(String value) {
        this.descrizioneufficiocreazione = value;
    }

    /**
     * Recupera il valore della proprietà utentecreazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUTENTECREAZIONE() {
        return utentecreazione;
    }

    /**
     * Imposta il valore della proprietà utentecreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUTENTECREAZIONE(String value) {
        this.utentecreazione = value;
    }

    /**
     * Recupera il valore della proprietà descrizioneutentecreazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONEUTENTECREAZIONE() {
        return descrizioneutentecreazione;
    }

    /**
     * Imposta il valore della proprietà descrizioneutentecreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONEUTENTECREAZIONE(String value) {
        this.descrizioneutentecreazione = value;
    }

    /**
     * Recupera il valore della proprietà dataapertura.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATAAPERTURA() {
        return dataapertura;
    }

    /**
     * Imposta il valore della proprietà dataapertura.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATAAPERTURA(String value) {
        this.dataapertura = value;
    }

    /**
     * Recupera il valore della proprietà datachiusura.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATACHIUSURA() {
        return datachiusura;
    }

    /**
     * Imposta il valore della proprietà datachiusura.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATACHIUSURA(String value) {
        this.datachiusura = value;
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
     * Recupera il valore della proprietà statoscarto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSTATOSCARTO() {
        return statoscarto;
    }

    /**
     * Imposta il valore della proprietà statoscarto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSTATOSCARTO(String value) {
        this.statoscarto = value;
    }

    /**
     * Recupera il valore della proprietà descrizionestatoscarto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONESTATOSCARTO() {
        return descrizionestatoscarto;
    }

    /**
     * Imposta il valore della proprietà descrizionestatoscarto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONESTATOSCARTO(String value) {
        this.descrizionestatoscarto = value;
    }

    /**
     * Recupera il valore della proprietà datastatoscarto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDATASTATOSCARTO() {
        return datastatoscarto;
    }

    /**
     * Imposta il valore della proprietà datastatoscarto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDATASTATOSCARTO(String value) {
        this.datastatoscarto = value;
    }

    /**
     * Recupera il valore della proprietà codiceamministrazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCODICEAMMINISTRAZIONE() {
        return codiceamministrazione;
    }

    /**
     * Imposta il valore della proprietà codiceamministrazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCODICEAMMINISTRAZIONE(String value) {
        this.codiceamministrazione = value;
    }

    /**
     * Recupera il valore della proprietà codiceaoo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCODICEAOO() {
        return codiceaoo;
    }

    /**
     * Imposta il valore della proprietà codiceaoo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCODICEAOO(String value) {
        this.codiceaoo = value;
    }

}
