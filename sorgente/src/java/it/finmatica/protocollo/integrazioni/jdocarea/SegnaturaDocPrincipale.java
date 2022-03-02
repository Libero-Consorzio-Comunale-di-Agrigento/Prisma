//
// Questo file è stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrà persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.02.12 alle 12:36:01 PM CET 
//


package it.finmatica.protocollo.integrazioni.jdocarea;

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
 *         &lt;element ref="{}Intestazione"/>
 *         &lt;element ref="{}Descrizione"/>
 *         &lt;element ref="{}ApplicativoProtocollo" minOccurs="0"/>
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
    "intestazione",
    "descrizione",
    "applicativoProtocollo"
})
@XmlRootElement(name = "Segnatura")
public class SegnaturaDocPrincipale {

    @XmlElement(name = "Intestazione", required = true)
    protected IntestazioneDocPrincipale intestazione;
    @XmlElement(name = "Descrizione", required = true)
    protected Descrizione descrizione;
    @XmlElement(name = "ApplicativoProtocollo")
    protected ApplicativoProtocollo applicativoProtocollo;

    /**
     * Recupera il valore della proprietà intestazione.
     * 
     * @return
     *     possible object is
     *     {@link Intestazione }
     *     
     */
    public IntestazioneDocPrincipale getIntestazione() {
        return intestazione;
    }

    /**
     * Imposta il valore della proprietà intestazione.
     * 
     * @param value
     *     allowed object is
     *     {@link Intestazione }
     *     
     */
    public void setIntestazione(IntestazioneDocPrincipale value) {
        this.intestazione = value;
    }

    /**
     * Recupera il valore della proprietà descrizione.
     * 
     * @return
     *     possible object is
     *     {@link Descrizione }
     *     
     */
    public Descrizione getDescrizione() {
        return descrizione;
    }

    /**
     * Imposta il valore della proprietà descrizione.
     * 
     * @param value
     *     allowed object is
     *     {@link Descrizione }
     *     
     */
    public void setDescrizione(Descrizione value) {
        this.descrizione = value;
    }

    public ApplicativoProtocollo getApplicativoProtocollo() {
        return applicativoProtocollo;
    }

    public void setApplicativoProtocollo(
        ApplicativoProtocollo applicativoProtocollo) {
        this.applicativoProtocollo = applicativoProtocollo;
    }
}
