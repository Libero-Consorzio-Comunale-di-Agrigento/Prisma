
package it.finmatica.affarigenerali.ducd.protocollaSoap;

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
 *         &lt;element name="oggetto" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="tipo_registro" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="utente_creazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
    "oggetto",
    "tipoRegistro",
    "utenteCreazione"
})
public class ParametriIngresso {

    protected int idDocumento;
    @XmlElement(required = true, nillable = true)
    protected String oggetto;
    @XmlElement(name = "tipo_registro", required = true, nillable = true)
    protected String tipoRegistro;
    @XmlElement(name = "utente_creazione", required = true, nillable = true)
    protected String utenteCreazione;

    /**
     * Recupera il valore della propriet� idDocumento.
     * 
     */
    public int getIdDocumento() {
        return idDocumento;
    }

    /**
     * Imposta il valore della propriet� idDocumento.
     * 
     */
    public void setIdDocumento(int value) {
        this.idDocumento = value;
    }

    /**
     * Recupera il valore della propriet� oggetto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOggetto() {
        return oggetto;
    }

    /**
     * Imposta il valore della propriet� oggetto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOggetto(String value) {
        this.oggetto = value;
    }

    /**
     * Recupera il valore della propriet� tipoRegistro.
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
     * Imposta il valore della propriet� tipoRegistro.
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
     * Recupera il valore della propriet� utenteCreazione.
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
     * Imposta il valore della propriet� utenteCreazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUtenteCreazione(String value) {
        this.utenteCreazione = value;
    }

}
