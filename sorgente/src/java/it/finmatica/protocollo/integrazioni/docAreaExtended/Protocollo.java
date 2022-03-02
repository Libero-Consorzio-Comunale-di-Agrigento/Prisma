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
 *         &lt;element ref="{}DOC"/>
 *         &lt;element ref="{}FILE_PRINCIPALE" minOccurs="0"/>
 *         &lt;element ref="{}ALLEGATI" minOccurs="0"/>
 *         &lt;element ref="{}SMISTAMENTI" minOccurs="0"/>
 *         &lt;element ref="{}RAPPORTI" minOccurs="0"/>
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
    "doc",
    "fileprincipale",
    "allegati",
    "smistamenti",
    "rapporti"
})
@XmlRootElement(name = "PROTOCOLLO")
public class Protocollo {

    @XmlElement(name = "DOC", required = true)
    protected Doc doc;
    @XmlElement(name = "FILE_PRINCIPALE")
    protected FilePrincipale fileprincipale;
    @XmlElement(name = "ALLEGATI")
    protected Allegati allegati;
    @XmlElement(name = "SMISTAMENTI")
    protected Smistamenti smistamenti;
    @XmlElement(name = "RAPPORTI")
    protected Rapporti rapporti;

    /**
     * Recupera il valore della proprietà doc.
     * 
     * @return
     *     possible object is
     *     {@link Doc }
     *     
     */
    public Doc getDOC() {
        return doc;
    }

    /**
     * Imposta il valore della proprietà doc.
     * 
     * @param value
     *     allowed object is
     *     {@link Doc }
     *     
     */
    public void setDOC(Doc value) {
        this.doc = value;
    }

    /**
     * Recupera il valore della proprietà fileprincipale.
     * 
     * @return
     *     possible object is
     *     {@link FilePrincipale }
     *     
     */
    public FilePrincipale getFILEPRINCIPALE() {
        return fileprincipale;
    }

    /**
     * Imposta il valore della proprietà fileprincipale.
     * 
     * @param value
     *     allowed object is
     *     {@link FilePrincipale }
     *     
     */
    public void setFILEPRINCIPALE(FilePrincipale value) {
        this.fileprincipale = value;
    }

    /**
     * Recupera il valore della proprietà allegati.
     * 
     * @return
     *     possible object is
     *     {@link Allegati }
     *     
     */
    public Allegati getALLEGATI() {
        return allegati;
    }

    /**
     * Imposta il valore della proprietà allegati.
     * 
     * @param value
     *     allowed object is
     *     {@link Allegati }
     *     
     */
    public void setALLEGATI(Allegati value) {
        this.allegati = value;
    }

    /**
     * Recupera il valore della proprietà smistamenti.
     * 
     * @return
     *     possible object is
     *     {@link Smistamenti }
     *     
     */
    public Smistamenti getSMISTAMENTI() {
        return smistamenti;
    }

    /**
     * Imposta il valore della proprietà smistamenti.
     * 
     * @param value
     *     allowed object is
     *     {@link Smistamenti }
     *     
     */
    public void setSMISTAMENTI(Smistamenti value) {
        this.smistamenti = value;
    }

    /**
     * Recupera il valore della proprietà rapporti.
     * 
     * @return
     *     possible object is
     *     {@link Rapporti }
     *     
     */
    public Rapporti getRAPPORTI() {
        return rapporti;
    }

    /**
     * Imposta il valore della proprietà rapporti.
     * 
     * @param value
     *     allowed object is
     *     {@link Rapporti }
     *     
     */
    public void setRAPPORTI(Rapporti value) {
        this.rapporti = value;
    }

}
