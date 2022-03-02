
package it.finmatica.affarigenerali.ducd.pec;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per ParametriIngressoPG complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="ParametriIngressoPG">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="anno" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="listaDestinatari" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="numero" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="tipoRegistro" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="utente_creazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="invioSingolo" type="{http://www.w3.org/2001/XMLSchema}boolean"/>
 *         &lt;element name="segnaturaCompleta" type="{http://www.w3.org/2001/XMLSchema}boolean"/>
 *         &lt;element name="senzaSegnatura" type="{http://www.w3.org/2001/XMLSchema}boolean"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ParametriIngressoPG", propOrder = {
    "anno",
    "listaDestinatari",
    "numero",
    "tipoRegistro",
    "utenteCreazione",
    "invioSingolo",
    "segnaturaCompleta",
    "senzaSegnatura"
})
public class ParametriIngressoPG {

    protected int anno;
    @XmlElement(required = true, nillable = true)
    protected String listaDestinatari;
    protected int numero;
    @XmlElement(required = true, nillable = true)
    protected String tipoRegistro;
    @XmlElement(name = "utente_creazione", required = true, nillable = true)
    protected String utenteCreazione;
    protected boolean invioSingolo;
    protected boolean segnaturaCompleta;
    protected boolean senzaSegnatura;

    /**
     * Recupera il valore della proprietà anno.
     * 
     */
    public int getAnno() {
        return anno;
    }

    /**
     * Imposta il valore della proprietà anno.
     * 
     */
    public void setAnno(int value) {
        this.anno = value;
    }

    /**
     * Recupera il valore della proprietà listaDestinatari.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getListaDestinatari() {
        return listaDestinatari;
    }

    /**
     * Imposta il valore della proprietà listaDestinatari.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setListaDestinatari(String value) {
        this.listaDestinatari = value;
    }

    /**
     * Recupera il valore della proprietà numero.
     * 
     */
    public int getNumero() {
        return numero;
    }

    /**
     * Imposta il valore della proprietà numero.
     * 
     */
    public void setNumero(int value) {
        this.numero = value;
    }

    /**
     * Recupera il valore della proprietà tipoRegistro.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTipoRegistro() {
        return tipoRegistro;
    }

    /**
     * Imposta il valore della proprietà tipoRegistro.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTipoRegistro(String value) {
        this.tipoRegistro = value;
    }

    /**
     * Recupera il valore della proprietà utenteCreazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUtenteCreazione() {
        return utenteCreazione;
    }

    /**
     * Imposta il valore della proprietà utenteCreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUtenteCreazione(String value) {
        this.utenteCreazione = value;
    }

    /**
     * Recupera il valore della proprietà invioSingolo.
     * 
     */
    public boolean isInvioSingolo() {
        return invioSingolo;
    }

    /**
     * Imposta il valore della proprietà invioSingolo.
     * 
     */
    public void setInvioSingolo(boolean value) {
        this.invioSingolo = value;
    }

    /**
     * Recupera il valore della proprietà segnaturaCompleta.
     * 
     */
    public boolean isSegnaturaCompleta() {
        return segnaturaCompleta;
    }

    /**
     * Imposta il valore della proprietà segnaturaCompleta.
     * 
     */
    public void setSegnaturaCompleta(boolean value) {
        this.segnaturaCompleta = value;
    }

    /**
     * Recupera il valore della proprietà senzaSegnatura.
     * 
     */
    public boolean isSenzaSegnatura() {
        return senzaSegnatura;
    }

    /**
     * Imposta il valore della proprietà senzaSegnatura.
     * 
     */
    public void setSenzaSegnatura(boolean value) {
        this.senzaSegnatura = value;
    }

}
