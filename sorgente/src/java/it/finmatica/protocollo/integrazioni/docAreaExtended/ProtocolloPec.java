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
 *         &lt;element ref="{}DATI" minOccurs="0"/>
 *         &lt;element ref="{}MEMO_INVIATI" minOccurs="0"/>
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
    "dati",
    "memoinviati"
})
@XmlRootElement(name = "PROTOCOLLO")
public class ProtocolloPec {

    @XmlElement(name = "DATI")
    protected Dati dati;
    @XmlElement(name = "MEMO_INVIATI")
    protected MemoInviati memoinviati;

    /**
     * Dati del documento di protocollo
     * 
     * @return
     *     possible object is
     *     {@link Dati }
     *     
     */
    public Dati getDati() {
        return dati;
    }

    /**
     * Imposta il valore della proprietà dati.
     * 
     * @param value
     *     allowed object is
     *     {@link Dati }
     *     
     */
    public void setDati(Dati value) {
        this.dati = value;
    }

    /**
     * Collezione dei messaggi inviati dal documento di Protocollo
     * 
     * @return
     *     possible object is
     *     {@link MemoInviati }
     *     
     */
    public MemoInviati getMemoInviati() {
        return memoinviati;
    }

    /**
     * Imposta il valore della proprietà memoinviati.
     * 
     * @param value
     *     allowed object is
     *     {@link MemoInviati }
     *     
     */
    public void setMemoInviati(MemoInviati value) {
        this.memoinviati = value;
    }

}
