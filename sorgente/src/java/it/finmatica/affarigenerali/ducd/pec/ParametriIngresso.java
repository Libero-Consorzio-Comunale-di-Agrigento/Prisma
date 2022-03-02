
package it.finmatica.affarigenerali.ducd.pec;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per ParametriIngresso complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="ParametriIngresso">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="idDocumento" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="listaDestinatari" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="utente_creazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="anno" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="numero" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="tipo_registro" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
@XmlType(name = "ParametriIngresso", propOrder = {
    "idDocumento",
    "listaDestinatari",
    "utenteCreazione",
    "anno",
    "numero",
    "tipoRegistro",
    "invioSingolo",
    "segnaturaCompleta",
    "senzaSegnatura"
})
public class ParametriIngresso {

    protected int idDocumento;
    @XmlElement(required = true, nillable = true)
    protected String listaDestinatari;
    @XmlElement(name = "utente_creazione", required = true, nillable = true)
    protected String utenteCreazione;
    @XmlElement(required = true, nillable = true)
    protected String anno;
    @XmlElement(required = true, nillable = true)
    protected String numero;
    @XmlElement(name = "tipo_registro", required = true, nillable = true)
    protected String tipoRegistro;
    protected boolean invioSingolo;
    protected boolean segnaturaCompleta;
    protected boolean senzaSegnatura;

    /**
     * Recupera il valore della proprietà idDocumento.
     * 
     */
    public int getIdDocumento() {
        return idDocumento;
    }

    /**
     * Imposta il valore della proprietà idDocumento.
     * 
     */
    public void setIdDocumento(int value) {
        this.idDocumento = value;
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
     * Recupera il valore della proprietà anno.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAnno() {
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
    public void setAnno(String value) {
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
    public String getNumero() {
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
    public void setNumero(String value) {
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
