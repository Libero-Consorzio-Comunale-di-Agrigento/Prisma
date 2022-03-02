//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2019.06.10 alle 09:40:58 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per Intestazione complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="Intestazione">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Identificatore"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}PrimaRegistrazione" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}OraRegistrazione" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Origine"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Destinazione" maxOccurs="unbounded"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}PerConoscenza" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Risposta" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Riservato" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}InterventoOperatore" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}RiferimentoDocumentiCartacei" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}RiferimentiTelematici" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Oggetto"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Classifica" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Note" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Intestazione", propOrder = {
    "identificatore",
    "primaRegistrazione",
    "oraRegistrazione",
    "origine",
    "destinazione",
    "perConoscenza",
    "risposta",
    "riservato",
    "interventoOperatore",
    "riferimentoDocumentiCartacei",
    "riferimentiTelematici",
    "oggetto",
    "classifica",
    "note"
})
public class Intestazione {

    @XmlElement(name = "Identificatore", required = true)
    protected Identificatore identificatore;
    @XmlElement(name = "PrimaRegistrazione")
    protected PrimaRegistrazione primaRegistrazione;
    @XmlElement(name = "OraRegistrazione")
    protected OraRegistrazione oraRegistrazione;
    @XmlElement(name = "Origine", required = true)
    protected Origine origine;
    @XmlElement(name = "Destinazione", required = true)
    protected List<Destinazione> destinazione;
    @XmlElement(name = "PerConoscenza")
    protected List<PerConoscenza> perConoscenza;
    @XmlElement(name = "Risposta")
    protected Risposta risposta;
    @XmlElement(name = "Riservato")
    protected Riservato riservato;
    @XmlElement(name = "InterventoOperatore")
    protected InterventoOperatore interventoOperatore;
    @XmlElement(name = "RiferimentoDocumentiCartacei")
    protected RiferimentoDocumentiCartacei riferimentoDocumentiCartacei;
    @XmlElement(name = "RiferimentiTelematici")
    protected RiferimentiTelematici riferimentiTelematici;
    @XmlElement(name = "Oggetto", required = true)
    protected Oggetto oggetto;
    @XmlElement(name = "Classifica")
    protected List<Classifica> classifica;
    @XmlElement(name = "Note")
    protected Note note;

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
     * Recupera il valore della propriet� primaRegistrazione.
     * 
     * @return
     *     possible object is
     *     {@link PrimaRegistrazione }
     *     
     */
    public PrimaRegistrazione getPrimaRegistrazione() {
        return primaRegistrazione;
    }

    /**
     * Imposta il valore della propriet� primaRegistrazione.
     * 
     * @param value
     *     allowed object is
     *     {@link PrimaRegistrazione }
     *     
     */
    public void setPrimaRegistrazione(PrimaRegistrazione value) {
        this.primaRegistrazione = value;
    }

    /**
     * Recupera il valore della propriet� oraRegistrazione.
     * 
     * @return
     *     possible object is
     *     {@link OraRegistrazione }
     *     
     */
    public OraRegistrazione getOraRegistrazione() {
        return oraRegistrazione;
    }

    /**
     * Imposta il valore della propriet� oraRegistrazione.
     * 
     * @param value
     *     allowed object is
     *     {@link OraRegistrazione }
     *     
     */
    public void setOraRegistrazione(OraRegistrazione value) {
        this.oraRegistrazione = value;
    }

    /**
     * Recupera il valore della propriet� origine.
     * 
     * @return
     *     possible object is
     *     {@link Origine }
     *     
     */
    public Origine getOrigine() {
        return origine;
    }

    /**
     * Imposta il valore della propriet� origine.
     * 
     * @param value
     *     allowed object is
     *     {@link Origine }
     *     
     */
    public void setOrigine(Origine value) {
        this.origine = value;
    }

    /**
     * Gets the value of the destinazione property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the destinazione property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDestinazione().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Destinazione }
     * 
     * 
     */
    public List<Destinazione> getDestinazione() {
        if (destinazione == null) {
            destinazione = new ArrayList<Destinazione>();
        }
        return this.destinazione;
    }

    public void setDestinazione(List<Destinazione> destinazioneList) {
        this.destinazione=destinazioneList;
    }

    /**
     * Gets the value of the perConoscenza property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the perConoscenza property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getPerConoscenza().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link PerConoscenza }
     * 
     * 
     */
    public List<PerConoscenza> getPerConoscenza() {
        if (perConoscenza == null) {
            perConoscenza = new ArrayList<PerConoscenza>();
        }
        return this.perConoscenza;
    }

    /**
     * Recupera il valore della propriet� risposta.
     * 
     * @return
     *     possible object is
     *     {@link Risposta }
     *     
     */
    public Risposta getRisposta() {
        return risposta;
    }

    /**
     * Imposta il valore della propriet� risposta.
     * 
     * @param value
     *     allowed object is
     *     {@link Risposta }
     *     
     */
    public void setRisposta(Risposta value) {
        this.risposta = value;
    }

    /**
     * Recupera il valore della propriet� riservato.
     * 
     * @return
     *     possible object is
     *     {@link Riservato }
     *     
     */
    public Riservato getRiservato() {
        return riservato;
    }

    /**
     * Imposta il valore della propriet� riservato.
     * 
     * @param value
     *     allowed object is
     *     {@link Riservato }
     *     
     */
    public void setRiservato(Riservato value) {
        this.riservato = value;
    }

    /**
     * Recupera il valore della propriet� interventoOperatore.
     * 
     * @return
     *     possible object is
     *     {@link InterventoOperatore }
     *     
     */
    public InterventoOperatore getInterventoOperatore() {
        return interventoOperatore;
    }

    /**
     * Imposta il valore della propriet� interventoOperatore.
     * 
     * @param value
     *     allowed object is
     *     {@link InterventoOperatore }
     *     
     */
    public void setInterventoOperatore(InterventoOperatore value) {
        this.interventoOperatore = value;
    }

    /**
     * Recupera il valore della propriet� riferimentoDocumentiCartacei.
     * 
     * @return
     *     possible object is
     *     {@link RiferimentoDocumentiCartacei }
     *     
     */
    public RiferimentoDocumentiCartacei getRiferimentoDocumentiCartacei() {
        return riferimentoDocumentiCartacei;
    }

    /**
     * Imposta il valore della propriet� riferimentoDocumentiCartacei.
     * 
     * @param value
     *     allowed object is
     *     {@link RiferimentoDocumentiCartacei }
     *     
     */
    public void setRiferimentoDocumentiCartacei(RiferimentoDocumentiCartacei value) {
        this.riferimentoDocumentiCartacei = value;
    }

    /**
     * Recupera il valore della propriet� riferimentiTelematici.
     * 
     * @return
     *     possible object is
     *     {@link RiferimentiTelematici }
     *     
     */
    public RiferimentiTelematici getRiferimentiTelematici() {
        return riferimentiTelematici;
    }

    /**
     * Imposta il valore della propriet� riferimentiTelematici.
     * 
     * @param value
     *     allowed object is
     *     {@link RiferimentiTelematici }
     *     
     */
    public void setRiferimentiTelematici(RiferimentiTelematici value) {
        this.riferimentiTelematici = value;
    }

    /**
     * Recupera il valore della propriet� oggetto.
     * 
     * @return
     *     possible object is
     *     {@link Oggetto }
     *     
     */
    public Oggetto getOggetto() {
        return oggetto;
    }

    /**
     * Imposta il valore della propriet� oggetto.
     * 
     * @param value
     *     allowed object is
     *     {@link Oggetto }
     *     
     */
    public void setOggetto(Oggetto value) {
        this.oggetto = value;
    }

    /**
     * Gets the value of the classifica property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the classifica property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getClassifica().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Classifica }
     * 
     * 
     */
    public List<Classifica> getClassifica() {
        if (classifica == null) {
            classifica = new ArrayList<Classifica>();
        }
        return this.classifica;
    }

    /**
     * Recupera il valore della propriet� note.
     * 
     * @return
     *     possible object is
     *     {@link Note }
     *     
     */
    public Note getNote() {
        return note;
    }

    /**
     * Imposta il valore della propriet� note.
     * 
     * @param value
     *     allowed object is
     *     {@link Note }
     *     
     */
    public void setNote(Note value) {
        this.note = value;
    }

}
