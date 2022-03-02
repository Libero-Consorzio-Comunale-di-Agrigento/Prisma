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
 *         &lt;element name="COGNOME_NOME" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CODICE_FISCALE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="EMAIL" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DENOMINAZIONE" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="INDIRIZZO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CAP" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="IDRIF" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CONOSCENZA" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COD_AMM" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COD_AOO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="COD_UO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_AMM" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DESCRIZIONE_AOO" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
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
    "cognomenome",
    "codicefiscale",
    "email",
    "denominazione",
    "indirizzo",
    "cap",
    "idrif",
    "conoscenza",
    "codamm",
    "codaoo",
    "coduo",
    "descrizioneamm",
    "descrizioneaoo"
})
@XmlRootElement(name = "RAPPORTO")
public class Rapporto {

    @XmlElement(name = "ID_DOCUMENTO")
    protected String iddocumento = "";
    @XmlElement(name = "COGNOME_NOME")
    protected String cognomenome = "";
    @XmlElement(name = "CODICE_FISCALE")
    protected String codicefiscale = "";
    @XmlElement(name = "EMAIL")
    protected String email = "";
    @XmlElement(name = "DENOMINAZIONE")
    protected String denominazione = "";
    @XmlElement(name = "INDIRIZZO")
    protected String indirizzo = "";
    @XmlElement(name = "CAP")
    protected String cap = "";
    @XmlElement(name = "IDRIF")
    protected String idrif = "";
    @XmlElement(name = "CONOSCENZA")
    protected String conoscenza = "";
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
     * Recupera il valore della proprietà cognomenome.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getCOGNOMENOME() {
        return cognomenome;
    }

    /**
     * Imposta il valore della proprietà cognomenome.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setCOGNOMENOME(String value) {
        this.cognomenome = value;
    }

    /**
     * Recupera il valore della proprietà codicefiscale.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getCODICEFISCALE() {
        return codicefiscale;
    }

    /**
     * Imposta il valore della proprietà codicefiscale.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setCODICEFISCALE(String value) {
        this.codicefiscale = value;
    }

    /**
     * Recupera il valore della proprietà email.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getEMAIL() {
        return email;
    }

    /**
     * Imposta il valore della proprietà email.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setEMAIL(String value) {
        this.email = value;
    }

    /**
     * Recupera il valore della proprietà denominazione.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getDENOMINAZIONE() {
        return denominazione;
    }

    /**
     * Imposta il valore della proprietà denominazione.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setDENOMINAZIONE(String value) {
        this.denominazione = value;
    }

    /**
     * Recupera il valore della proprietà indirizzo.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getINDIRIZZO() {
        return indirizzo;
    }

    /**
     * Imposta il valore della proprietà indirizzo.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setINDIRIZZO(String value) {
        this.indirizzo = value;
    }

    /**
     * Recupera il valore della proprietà cap.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getCAP() {
        return cap;
    }

    /**
     * Imposta il valore della proprietà cap.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setCAP(String value) {
        this.cap = value;
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
     * Recupera il valore della proprietà conoscenza.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getCONOSCENZA() {
        return conoscenza;
    }

    /**
     * Imposta il valore della proprietà conoscenza.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setCONOSCENZA(String value) {
        this.conoscenza = value;
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

}
