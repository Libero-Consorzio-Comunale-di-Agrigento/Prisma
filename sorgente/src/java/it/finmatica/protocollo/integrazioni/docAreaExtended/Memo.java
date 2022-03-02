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
 *         &lt;element name="ID_DOCUMENTO" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="DATA_SPEDIZIONE" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="DESTINATARI" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
    "dataspedizione",
    "destinatari",
    "statoSpedizione",
    "fileallegati"
})
@XmlRootElement(name = "MEMO")
public class Memo {

    @XmlElement(name = "ID_DOCUMENTO", required = true)
    protected String iddocumento = "";
    @XmlElement(name = "DATA_SPEDIZIONE", required = true)
    protected String dataspedizione = "";
    @XmlElement(name = "DESTINATARI", required = true)
    protected String destinatari = "";
    @XmlElement(name = "FILE_ALLEGATI")
    protected FileAllegati fileallegati;
    @XmlElement(name = "STATO_SPEDIZIONE", required = true)
    protected String statoSpedizione = "";

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
     * Recupera il valore della proprietà dataspedizione.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getDATASPEDIZIONE() {
        return dataspedizione;
    }

    /**
     * Imposta il valore della proprietà dataspedizione.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setDATASPEDIZIONE(String value) {
        this.dataspedizione = value;
    }

    /**
     * Recupera il valore della proprietà destinatari.
     *
     * @return
     *     possible object is
     *     {@link String }
     *
     */
    public String getDESTINATARI() {
        return destinatari;
    }

    /**
     * Imposta il valore della proprietà destinatari.
     *
     * @param value
     *     allowed object is
     *     {@link String }
     *
     */
    public void setDESTINATARI(String value) {
        this.destinatari = value;
    }

    /**
     * Collezione di file allegati ai messaggi inviati
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

    public String getStatoSpedizione() {
        return statoSpedizione;
    }

    public void setStatoSpedizione(String statoSpedizione) {
        this.statoSpedizione = statoSpedizione;
    }
}

