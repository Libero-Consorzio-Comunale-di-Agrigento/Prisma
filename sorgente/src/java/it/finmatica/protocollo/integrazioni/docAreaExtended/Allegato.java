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
 *         &lt;element name="DESC_TIPO_ALLEGATO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TIPO_ALLEGATO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="IDRIF" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="NUMERO_PAG" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="QUANTITA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="RISERVATO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TITOLO_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COD_AMM" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COD_AOO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COD_UO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_AMM" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_AOO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element ref="{}FILE_ALLEGATI" minOccurs="0"/>
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
    "desctipoallegato",
    "tipoallegato",
    "descrizione",
    "idrif",
    "numeropag",
    "quantita",
    "riservato",
    "titolodocumento",
    "codamm",
    "codaoo",
    "coduo",
    "descrizioneamm",
    "descrizioneaoo",
    "fileallegati"
})
@XmlRootElement(name = "ALLEGATO")
public class Allegato {

    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "DESC_TIPO_ALLEGATO")
    protected String desctipoallegato = "";
    @XmlElement(name = "TIPO_ALLEGATO")
    protected String tipoallegato = "";
    @XmlElement(name = "DESCRIZIONE")
    protected String descrizione = "";
    @XmlElement(name = "IDRIF")
    protected String idrif = "";
    @XmlElement(name = "NUMERO_PAG")
    protected String numeropag = "";
    @XmlElement(name = "QUANTITA")
    protected String quantita = "";
    @XmlElement(name = "RISERVATO")
    protected String riservato = "";
    @XmlElement(name = "TITOLO_DOCUMENTO")
    protected String titolodocumento = "";
    @XmlElement(name = "COD_AMM")
    protected String codamm = "";
    @XmlElement(name = "COD_AOO")
    protected String codaoo = "";
    @XmlElement(name = "COD_UO")
    protected String coduo = "";
    @XmlElement(name = "DESCRIZIONE_AMM")
    protected String descrizioneamm = "";
    @XmlElement(name = "DESCRIZIONE_AOO")
    protected String descrizioneaoo = "";
    @XmlElement(name = "FILE_ALLEGATI")
    protected FileAllegati fileallegati;

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
     * Recupera il valore della proprietà desctipoallegato.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCTIPOALLEGATO() {
        return desctipoallegato;
    }

    /**
     * Imposta il valore della proprietà desctipoallegato.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCTIPOALLEGATO(String value) {
        this.desctipoallegato = value;
    }

    /**
     * Recupera il valore della proprietà tipoallegato.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTIPOALLEGATO() {
        return tipoallegato;
    }

    /**
     * Imposta il valore della proprietà tipoallegato.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTIPOALLEGATO(String value) {
        this.tipoallegato = value;
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
     * Recupera il valore della proprietà numeropag.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNUMEROPAG() {
        return numeropag;
    }

    /**
     * Imposta il valore della proprietà numeropag.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNUMEROPAG(String value) {
        this.numeropag = value;
    }

    /**
     * Recupera il valore della proprietà quantita.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQUANTITA() {
        return quantita;
    }

    /**
     * Imposta il valore della proprietà quantita.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQUANTITA(String value) {
        this.quantita = value;
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
     * Recupera il valore della proprietà titolodocumento.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTITOLODOCUMENTO() {
        return titolodocumento;
    }

    /**
     * Imposta il valore della proprietà titolodocumento.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTITOLODOCUMENTO(String value) {
        this.titolodocumento = value;
    }

    /**
     * Recupera il valore della proprietà codamm.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCODAMM() {
        return codamm;
    }

    /**
     * Imposta il valore della proprietà codamm.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCODAMM(String value) {
        this.codamm = value;
    }

    /**
     * Recupera il valore della proprietà codaoo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCODAOO() {
        return codaoo;
    }

    /**
     * Imposta il valore della proprietà codaoo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCODAOO(String value) {
        this.codaoo = value;
    }

    /**
     * Recupera il valore della proprietà coduo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCODUO() {
        return coduo;
    }

    /**
     * Imposta il valore della proprietà coduo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCODUO(String value) {
        this.coduo = value;
    }

    /**
     * Recupera il valore della proprietà descrizioneamm.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONEAMM() {
        return descrizioneamm;
    }

    /**
     * Imposta il valore della proprietà descrizioneamm.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONEAMM(String value) {
        this.descrizioneamm = value;
    }

    /**
     * Recupera il valore della proprietà descrizioneaoo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDESCRIZIONEAOO() {
        return descrizioneaoo;
    }

    /**
     * Imposta il valore della proprietà descrizioneaoo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDESCRIZIONEAOO(String value) {
        this.descrizioneaoo = value;
    }

    /**
     * Recupera il valore della proprietà fileallegati.
     * 
     * @return
     *     possible object is
     *     {@link FileAllegati }
     *     
     */
    public FileAllegati getFILEALLEGATI() {
        return fileallegati;
    }

    /**
     * Imposta il valore della proprietà fileallegati.
     * 
     * @param value
     *     allowed object is
     *     {@link FileAllegati }
     *     
     */
    public void setFILEALLEGATI(FileAllegati value) {
        this.fileallegati = value;
    }

}
