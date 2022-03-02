
package it.finmatica.affarigenerali.ducd.inserisciInTitolario;

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
 *         &lt;element name="fascicolo_numero" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="fascicolo_numero_padre" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="fascicolo_anno" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="classificazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="fascicolo_oggetto" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="data_apertura" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="ufficio_competenza" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="utente_creazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="anno" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="registro" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="numero" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="idDocumento" type="{http://www.w3.org/2001/XMLSchema}int"/>
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
    "fascicoloNumero",
    "fascicoloNumeroPadre",
    "fascicoloAnno",
    "classificazione",
    "fascicoloOggetto",
    "dataApertura",
    "ufficioCompetenza",
    "utenteCreazione",
    "anno",
    "registro",
    "numero",
    "idDocumento"
})
public class ParametriIngresso {

    @XmlElement(name = "fascicolo_numero", required = true)
    protected String fascicoloNumero;
    @XmlElement(name = "fascicolo_numero_padre", required = true)
    protected String fascicoloNumeroPadre;
    @XmlElement(name = "fascicolo_anno")
    protected int fascicoloAnno;
    @XmlElement(required = true)
    protected String classificazione;
    @XmlElement(name = "fascicolo_oggetto", required = true)
    protected String fascicoloOggetto;
    @XmlElement(name = "data_apertura", required = true)
    protected String dataApertura;
    @XmlElement(name = "ufficio_competenza", required = true)
    protected String ufficioCompetenza;
    @XmlElement(name = "utente_creazione", required = true)
    protected String utenteCreazione;
    protected int anno;
    @XmlElement(required = true)
    protected String registro;
    protected int numero;
    protected int idDocumento;

    /**
     * Recupera il valore della propriet� fascicoloNumero.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFascicoloNumero() {
        return fascicoloNumero;
    }

    /**
     * Imposta il valore della propriet� fascicoloNumero.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFascicoloNumero(String value) {
        this.fascicoloNumero = value;
    }

    /**
     * Recupera il valore della propriet� fascicoloNumeroPadre.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFascicoloNumeroPadre() {
        return fascicoloNumeroPadre;
    }

    /**
     * Imposta il valore della propriet� fascicoloNumeroPadre.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFascicoloNumeroPadre(String value) {
        this.fascicoloNumeroPadre = value;
    }

    /**
     * Recupera il valore della propriet� fascicoloAnno.
     * 
     */
    public int getFascicoloAnno() {
        return fascicoloAnno;
    }

    /**
     * Imposta il valore della propriet� fascicoloAnno.
     * 
     */
    public void setFascicoloAnno(int value) {
        this.fascicoloAnno = value;
    }

    /**
     * Recupera il valore della propriet� classificazione.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getClassificazione() {
        return classificazione;
    }

    /**
     * Imposta il valore della propriet� classificazione.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setClassificazione(String value) {
        this.classificazione = value;
    }

    /**
     * Recupera il valore della propriet� fascicoloOggetto.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFascicoloOggetto() {
        return fascicoloOggetto;
    }

    /**
     * Imposta il valore della propriet� fascicoloOggetto.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFascicoloOggetto(String value) {
        this.fascicoloOggetto = value;
    }

    /**
     * Recupera il valore della propriet� dataApertura.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDataApertura() {
        return dataApertura;
    }

    /**
     * Imposta il valore della propriet� dataApertura.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDataApertura(String value) {
        this.dataApertura = value;
    }

    /**
     * Recupera il valore della propriet� ufficioCompetenza.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUfficioCompetenza() {
        return ufficioCompetenza;
    }

    /**
     * Imposta il valore della propriet� ufficioCompetenza.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUfficioCompetenza(String value) {
        this.ufficioCompetenza = value;
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

    /**
     * Recupera il valore della propriet� anno.
     * 
     */
    public int getAnno() {
        return anno;
    }

    /**
     * Imposta il valore della propriet� anno.
     * 
     */
    public void setAnno(int value) {
        this.anno = value;
    }

    /**
     * Recupera il valore della propriet� registro.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRegistro() {
        return registro;
    }

    /**
     * Imposta il valore della propriet� registro.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRegistro(String value) {
        this.registro = value;
    }

    /**
     * Recupera il valore della propriet� numero.
     * 
     */
    public int getNumero() {
        return numero;
    }

    /**
     * Imposta il valore della propriet� numero.
     * 
     */
    public void setNumero(int value) {
        this.numero = value;
    }

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

}
