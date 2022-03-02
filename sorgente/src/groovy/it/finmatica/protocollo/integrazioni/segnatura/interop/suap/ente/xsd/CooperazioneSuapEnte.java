//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.10.15 alle 10:45:51 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.suap.ente.xsd;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;
import javax.xml.datatype.XMLGregorianCalendar;


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
 *         &lt;element name="info-schema">
 *           &lt;complexType>
 *             &lt;simpleContent>
 *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                 &lt;attribute name="versione" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="data" type="{http://www.w3.org/2001/XMLSchema}date" />
 *               &lt;/extension>
 *             &lt;/simpleContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="intestazione">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="suap-competente">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="identificativo-suap" type="{http://www.w3.org/2001/XMLSchema}short" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="ente-destinatario">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="pec" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="codice-pratica" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="impresa">
 *                     &lt;complexType>
 *                       &lt;complexContent>
 *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                           &lt;sequence>
 *                             &lt;element name="forma-giuridica">
 *                               &lt;complexType>
 *                                 &lt;simpleContent>
 *                                   &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                                     &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                                   &lt;/extension>
 *                                 &lt;/simpleContent>
 *                               &lt;/complexType>
 *                             &lt;/element>
 *                             &lt;element name="ragione-sociale" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                             &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}long"/>
 *                             &lt;element name="codice-REA">
 *                               &lt;complexType>
 *                                 &lt;simpleContent>
 *                                   &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>int">
 *                                     &lt;attribute name="provincia" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                                   &lt;/extension>
 *                                 &lt;/simpleContent>
 *                               &lt;/complexType>
 *                             &lt;/element>
 *                             &lt;element name="indirizzo">
 *                               &lt;complexType>
 *                                 &lt;complexContent>
 *                                   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                                     &lt;sequence>
 *                                       &lt;element name="stato">
 *                                         &lt;complexType>
 *                                           &lt;simpleContent>
 *                                             &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                                               &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                                             &lt;/extension>
 *                                           &lt;/simpleContent>
 *                                         &lt;/complexType>
 *                                       &lt;/element>
 *                                       &lt;element name="provincia">
 *                                         &lt;complexType>
 *                                           &lt;simpleContent>
 *                                             &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                                               &lt;attribute name="sigla" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                                             &lt;/extension>
 *                                           &lt;/simpleContent>
 *                                         &lt;/complexType>
 *                                       &lt;/element>
 *                                       &lt;element name="comune">
 *                                         &lt;complexType>
 *                                           &lt;simpleContent>
 *                                             &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                                               &lt;attribute name="codice-catastale" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                                             &lt;/extension>
 *                                           &lt;/simpleContent>
 *                                         &lt;/complexType>
 *                                       &lt;/element>
 *                                       &lt;element name="cap" type="{http://www.w3.org/2001/XMLSchema}short"/>
 *                                       &lt;element name="toponimo" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                                       &lt;element name="denominazione-stradale" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                                       &lt;element name="numero-civico" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                                     &lt;/sequence>
 *                                   &lt;/restriction>
 *                                 &lt;/complexContent>
 *                               &lt;/complexType>
 *                             &lt;/element>
 *                             &lt;element name="legale-rappresentante">
 *                               &lt;complexType>
 *                                 &lt;complexContent>
 *                                   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                                     &lt;sequence>
 *                                       &lt;element name="cognome" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                                       &lt;element name="nome" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                                       &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                                       &lt;element name="carica">
 *                                         &lt;complexType>
 *                                           &lt;simpleContent>
 *                                             &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                                               &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                                             &lt;/extension>
 *                                           &lt;/simpleContent>
 *                                         &lt;/complexType>
 *                                       &lt;/element>
 *                                     &lt;/sequence>
 *                                   &lt;/restriction>
 *                                 &lt;/complexContent>
 *                               &lt;/complexType>
 *                             &lt;/element>
 *                           &lt;/sequence>
 *                         &lt;/restriction>
 *                       &lt;/complexContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="oggetto-pratica">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="tipo-procedimento" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="tipo-intervento" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="protocollo-pratica-suap">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="data-registrazione" type="{http://www.w3.org/2001/XMLSchema}date" />
 *                           &lt;attribute name="numero-registrazione" type="{http://www.w3.org/2001/XMLSchema}int" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="oggetto-comunicazione">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="tipo-cooperazione" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="testo-comunicazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="protocollo">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="data-registrazione" type="{http://www.w3.org/2001/XMLSchema}date" />
 *                           &lt;attribute name="numero-registrazione" type="{http://www.w3.org/2001/XMLSchema}short" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                 &lt;/sequence>
 *                 &lt;attribute name="progressivo" type="{http://www.w3.org/2001/XMLSchema}byte" />
 *                 &lt;attribute name="totale" type="{http://www.w3.org/2001/XMLSchema}byte" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="allegato" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="descrizione" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="nome-file-originale" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *                   &lt;element name="mime" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="dimensione" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *                 &lt;/sequence>
 *                 &lt;attribute name="nome-file" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="cod" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
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
    "infoSchema",
    "intestazione",
    "allegato"
})
@XmlRootElement(name = "cooperazione-suap-ente")
public class CooperazioneSuapEnte {

    @XmlElement(name = "info-schema", required = true)
    protected InfoSchema infoSchema;
    @XmlElement(required = true)
    protected Intestazione intestazione;
    protected List<Allegato> allegato;

    /**
     * Recupera il valore della propriet� infoSchema.
     * 
     * @return
     *     possible object is
     *     {@link InfoSchema }
     *     
     */
    public InfoSchema getInfoSchema() {
        return infoSchema;
    }

    /**
     * Imposta il valore della propriet� infoSchema.
     * 
     * @param value
     *     allowed object is
     *     {@link InfoSchema }
     *     
     */
    public void setInfoSchema(InfoSchema value) {
        this.infoSchema = value;
    }

    /**
     * Recupera il valore della propriet� intestazione.
     * 
     * @return
     *     possible object is
     *     {@link Intestazione }
     *     
     */
    public Intestazione getIntestazione() {
        return intestazione;
    }

    /**
     * Imposta il valore della propriet� intestazione.
     * 
     * @param value
     *     allowed object is
     *     {@link Intestazione }
     *     
     */
    public void setIntestazione(Intestazione value) {
        this.intestazione = value;
    }

    /**
     * Gets the value of the allegato property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the allegato property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getAllegato().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Allegato }
     * 
     * 
     */
    public List<Allegato> getAllegato() {
        if (allegato == null) {
            allegato = new ArrayList<Allegato>();
        }
        return this.allegato;
    }


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
     *         &lt;element name="descrizione" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="nome-file-originale" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
     *         &lt;element name="mime" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="dimensione" type="{http://www.w3.org/2001/XMLSchema}int"/>
     *       &lt;/sequence>
     *       &lt;attribute name="nome-file" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="cod" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "descrizione",
        "nomeFileOriginale",
        "mime",
        "dimensione"
    })
    public static class Allegato {

        @XmlElement(required = true)
        protected String descrizione;
        @XmlElement(name = "nome-file-originale")
        protected String nomeFileOriginale;
        @XmlElement(required = true)
        protected String mime;
        protected int dimensione;
        @XmlAttribute(name = "nome-file")
        protected String nomeFile;
        @XmlAttribute(name = "cod")
        protected String cod;

        /**
         * Recupera il valore della propriet� descrizione.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getDescrizione() {
            return descrizione;
        }

        /**
         * Imposta il valore della propriet� descrizione.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setDescrizione(String value) {
            this.descrizione = value;
        }

        /**
         * Recupera il valore della propriet� nomeFileOriginale.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getNomeFileOriginale() {
            return nomeFileOriginale;
        }

        /**
         * Imposta il valore della propriet� nomeFileOriginale.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setNomeFileOriginale(String value) {
            this.nomeFileOriginale = value;
        }

        /**
         * Recupera il valore della propriet� mime.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getMime() {
            return mime;
        }

        /**
         * Imposta il valore della propriet� mime.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setMime(String value) {
            this.mime = value;
        }

        /**
         * Recupera il valore della propriet� dimensione.
         * 
         */
        public int getDimensione() {
            return dimensione;
        }

        /**
         * Imposta il valore della propriet� dimensione.
         * 
         */
        public void setDimensione(int value) {
            this.dimensione = value;
        }

        /**
         * Recupera il valore della propriet� nomeFile.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getNomeFile() {
            return nomeFile;
        }

        /**
         * Imposta il valore della propriet� nomeFile.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setNomeFile(String value) {
            this.nomeFile = value;
        }

        /**
         * Recupera il valore della propriet� cod.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getCod() {
            return cod;
        }

        /**
         * Imposta il valore della propriet� cod.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setCod(String value) {
            this.cod = value;
        }

    }


    /**
     * <p>Classe Java per anonymous complex type.
     * 
     * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;simpleContent>
     *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *       &lt;attribute name="versione" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="data" type="{http://www.w3.org/2001/XMLSchema}date" />
     *     &lt;/extension>
     *   &lt;/simpleContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "value"
    })
    public static class InfoSchema {

        @XmlValue
        protected String value;
        @XmlAttribute(name = "versione")
        protected String versione;
        @XmlAttribute(name = "data")
        @XmlSchemaType(name = "date")
        protected XMLGregorianCalendar data;

        /**
         * Recupera il valore della propriet� value.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getValue() {
            return value;
        }

        /**
         * Imposta il valore della propriet� value.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setValue(String value) {
            this.value = value;
        }

        /**
         * Recupera il valore della propriet� versione.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getVersione() {
            return versione;
        }

        /**
         * Imposta il valore della propriet� versione.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setVersione(String value) {
            this.versione = value;
        }

        /**
         * Recupera il valore della propriet� data.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getData() {
            return data;
        }

        /**
         * Imposta il valore della propriet� data.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setData(XMLGregorianCalendar value) {
            this.data = value;
        }

    }


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
     *         &lt;element name="suap-competente">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="identificativo-suap" type="{http://www.w3.org/2001/XMLSchema}short" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="ente-destinatario">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="pec" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="codice-pratica" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="impresa">
     *           &lt;complexType>
     *             &lt;complexContent>
     *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                 &lt;sequence>
     *                   &lt;element name="forma-giuridica">
     *                     &lt;complexType>
     *                       &lt;simpleContent>
     *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                           &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                         &lt;/extension>
     *                       &lt;/simpleContent>
     *                     &lt;/complexType>
     *                   &lt;/element>
     *                   &lt;element name="ragione-sociale" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                   &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}long"/>
     *                   &lt;element name="codice-REA">
     *                     &lt;complexType>
     *                       &lt;simpleContent>
     *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>int">
     *                           &lt;attribute name="provincia" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                         &lt;/extension>
     *                       &lt;/simpleContent>
     *                     &lt;/complexType>
     *                   &lt;/element>
     *                   &lt;element name="indirizzo">
     *                     &lt;complexType>
     *                       &lt;complexContent>
     *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                           &lt;sequence>
     *                             &lt;element name="stato">
     *                               &lt;complexType>
     *                                 &lt;simpleContent>
     *                                   &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                                     &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                                   &lt;/extension>
     *                                 &lt;/simpleContent>
     *                               &lt;/complexType>
     *                             &lt;/element>
     *                             &lt;element name="provincia">
     *                               &lt;complexType>
     *                                 &lt;simpleContent>
     *                                   &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                                     &lt;attribute name="sigla" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                                   &lt;/extension>
     *                                 &lt;/simpleContent>
     *                               &lt;/complexType>
     *                             &lt;/element>
     *                             &lt;element name="comune">
     *                               &lt;complexType>
     *                                 &lt;simpleContent>
     *                                   &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                                     &lt;attribute name="codice-catastale" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                                   &lt;/extension>
     *                                 &lt;/simpleContent>
     *                               &lt;/complexType>
     *                             &lt;/element>
     *                             &lt;element name="cap" type="{http://www.w3.org/2001/XMLSchema}short"/>
     *                             &lt;element name="toponimo" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                             &lt;element name="denominazione-stradale" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                             &lt;element name="numero-civico" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                           &lt;/sequence>
     *                         &lt;/restriction>
     *                       &lt;/complexContent>
     *                     &lt;/complexType>
     *                   &lt;/element>
     *                   &lt;element name="legale-rappresentante">
     *                     &lt;complexType>
     *                       &lt;complexContent>
     *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                           &lt;sequence>
     *                             &lt;element name="cognome" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                             &lt;element name="nome" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                             &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                             &lt;element name="carica">
     *                               &lt;complexType>
     *                                 &lt;simpleContent>
     *                                   &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                                     &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                                   &lt;/extension>
     *                                 &lt;/simpleContent>
     *                               &lt;/complexType>
     *                             &lt;/element>
     *                           &lt;/sequence>
     *                         &lt;/restriction>
     *                       &lt;/complexContent>
     *                     &lt;/complexType>
     *                   &lt;/element>
     *                 &lt;/sequence>
     *               &lt;/restriction>
     *             &lt;/complexContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="oggetto-pratica">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="tipo-procedimento" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="tipo-intervento" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="protocollo-pratica-suap">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="data-registrazione" type="{http://www.w3.org/2001/XMLSchema}date" />
     *                 &lt;attribute name="numero-registrazione" type="{http://www.w3.org/2001/XMLSchema}int" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="oggetto-comunicazione">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="tipo-cooperazione" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="testo-comunicazione" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="protocollo">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="data-registrazione" type="{http://www.w3.org/2001/XMLSchema}date" />
     *                 &lt;attribute name="numero-registrazione" type="{http://www.w3.org/2001/XMLSchema}short" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *       &lt;/sequence>
     *       &lt;attribute name="progressivo" type="{http://www.w3.org/2001/XMLSchema}byte" />
     *       &lt;attribute name="totale" type="{http://www.w3.org/2001/XMLSchema}byte" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "suapCompetente",
        "enteDestinatario",
        "codicePratica",
        "impresa",
        "oggettoPratica",
        "protocolloPraticaSuap",
        "oggettoComunicazione",
        "testoComunicazione",
        "protocollo"
    })
    public static class Intestazione {

        @XmlElement(name = "suap-competente", required = true)
        protected SuapCompetente suapCompetente;
        @XmlElement(name = "ente-destinatario", required = true)
        protected EnteDestinatario enteDestinatario;
        @XmlElement(name = "codice-pratica", required = true)
        protected String codicePratica;
        @XmlElement(required = true)
        protected Impresa impresa;
        @XmlElement(name = "oggetto-pratica", required = true)
        protected OggettoPratica oggettoPratica;
        @XmlElement(name = "protocollo-pratica-suap", required = true)
        protected ProtocolloPraticaSuap protocolloPraticaSuap;
        @XmlElement(name = "oggetto-comunicazione", required = true)
        protected OggettoComunicazione oggettoComunicazione;
        @XmlElement(name = "testo-comunicazione", required = true)
        protected String testoComunicazione;
        @XmlElement(required = true)
        protected Protocollo protocollo;
        @XmlAttribute(name = "progressivo")
        protected Byte progressivo;
        @XmlAttribute(name = "totale")
        protected Byte totale;

        /**
         * Recupera il valore della propriet� suapCompetente.
         * 
         * @return
         *     possible object is
         *     {@link SuapCompetente }
         *     
         */
        public SuapCompetente getSuapCompetente() {
            return suapCompetente;
        }

        /**
         * Imposta il valore della propriet� suapCompetente.
         * 
         * @param value
         *     allowed object is
         *     {@link SuapCompetente }
         *     
         */
        public void setSuapCompetente(SuapCompetente value) {
            this.suapCompetente = value;
        }

        /**
         * Recupera il valore della propriet� enteDestinatario.
         * 
         * @return
         *     possible object is
         *     {@link EnteDestinatario }
         *     
         */
        public EnteDestinatario getEnteDestinatario() {
            return enteDestinatario;
        }

        /**
         * Imposta il valore della propriet� enteDestinatario.
         * 
         * @param value
         *     allowed object is
         *     {@link EnteDestinatario }
         *     
         */
        public void setEnteDestinatario(EnteDestinatario value) {
            this.enteDestinatario = value;
        }

        /**
         * Recupera il valore della propriet� codicePratica.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getCodicePratica() {
            return codicePratica;
        }

        /**
         * Imposta il valore della propriet� codicePratica.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setCodicePratica(String value) {
            this.codicePratica = value;
        }

        /**
         * Recupera il valore della propriet� impresa.
         * 
         * @return
         *     possible object is
         *     {@link Impresa }
         *     
         */
        public Impresa getImpresa() {
            return impresa;
        }

        /**
         * Imposta il valore della propriet� impresa.
         * 
         * @param value
         *     allowed object is
         *     {@link Impresa }
         *     
         */
        public void setImpresa(Impresa value) {
            this.impresa = value;
        }

        /**
         * Recupera il valore della propriet� oggettoPratica.
         * 
         * @return
         *     possible object is
         *     {@link OggettoPratica }
         *     
         */
        public OggettoPratica getOggettoPratica() {
            return oggettoPratica;
        }

        /**
         * Imposta il valore della propriet� oggettoPratica.
         * 
         * @param value
         *     allowed object is
         *     {@link OggettoPratica }
         *     
         */
        public void setOggettoPratica(OggettoPratica value) {
            this.oggettoPratica = value;
        }

        /**
         * Recupera il valore della propriet� protocolloPraticaSuap.
         * 
         * @return
         *     possible object is
         *     {@link ProtocolloPraticaSuap }
         *     
         */
        public ProtocolloPraticaSuap getProtocolloPraticaSuap() {
            return protocolloPraticaSuap;
        }

        /**
         * Imposta il valore della propriet� protocolloPraticaSuap.
         * 
         * @param value
         *     allowed object is
         *     {@link ProtocolloPraticaSuap }
         *     
         */
        public void setProtocolloPraticaSuap(ProtocolloPraticaSuap value) {
            this.protocolloPraticaSuap = value;
        }

        /**
         * Recupera il valore della propriet� oggettoComunicazione.
         * 
         * @return
         *     possible object is
         *     {@link OggettoComunicazione }
         *     
         */
        public OggettoComunicazione getOggettoComunicazione() {
            return oggettoComunicazione;
        }

        /**
         * Imposta il valore della propriet� oggettoComunicazione.
         * 
         * @param value
         *     allowed object is
         *     {@link OggettoComunicazione }
         *     
         */
        public void setOggettoComunicazione(OggettoComunicazione value) {
            this.oggettoComunicazione = value;
        }

        /**
         * Recupera il valore della propriet� testoComunicazione.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getTestoComunicazione() {
            return testoComunicazione;
        }

        /**
         * Imposta il valore della propriet� testoComunicazione.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setTestoComunicazione(String value) {
            this.testoComunicazione = value;
        }

        /**
         * Recupera il valore della propriet� protocollo.
         * 
         * @return
         *     possible object is
         *     {@link Protocollo }
         *     
         */
        public Protocollo getProtocollo() {
            return protocollo;
        }

        /**
         * Imposta il valore della propriet� protocollo.
         * 
         * @param value
         *     allowed object is
         *     {@link Protocollo }
         *     
         */
        public void setProtocollo(Protocollo value) {
            this.protocollo = value;
        }

        /**
         * Recupera il valore della propriet� progressivo.
         * 
         * @return
         *     possible object is
         *     {@link Byte }
         *     
         */
        public Byte getProgressivo() {
            return progressivo;
        }

        /**
         * Imposta il valore della propriet� progressivo.
         * 
         * @param value
         *     allowed object is
         *     {@link Byte }
         *     
         */
        public void setProgressivo(Byte value) {
            this.progressivo = value;
        }

        /**
         * Recupera il valore della propriet� totale.
         * 
         * @return
         *     possible object is
         *     {@link Byte }
         *     
         */
        public Byte getTotale() {
            return totale;
        }

        /**
         * Imposta il valore della propriet� totale.
         * 
         * @param value
         *     allowed object is
         *     {@link Byte }
         *     
         */
        public void setTotale(Byte value) {
            this.totale = value;
        }


        /**
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="pec" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "value"
        })
        public static class EnteDestinatario {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "pec")
            protected String pec;

            /**
             * Recupera il valore della propriet� value.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getValue() {
                return value;
            }

            /**
             * Imposta il valore della propriet� value.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setValue(String value) {
                this.value = value;
            }

            /**
             * Recupera il valore della propriet� pec.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getPec() {
                return pec;
            }

            /**
             * Imposta il valore della propriet� pec.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setPec(String value) {
                this.pec = value;
            }

        }


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
         *         &lt;element name="forma-giuridica">
         *           &lt;complexType>
         *             &lt;simpleContent>
         *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *                 &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
         *               &lt;/extension>
         *             &lt;/simpleContent>
         *           &lt;/complexType>
         *         &lt;/element>
         *         &lt;element name="ragione-sociale" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *         &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}long"/>
         *         &lt;element name="codice-REA">
         *           &lt;complexType>
         *             &lt;simpleContent>
         *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>int">
         *                 &lt;attribute name="provincia" type="{http://www.w3.org/2001/XMLSchema}string" />
         *               &lt;/extension>
         *             &lt;/simpleContent>
         *           &lt;/complexType>
         *         &lt;/element>
         *         &lt;element name="indirizzo">
         *           &lt;complexType>
         *             &lt;complexContent>
         *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
         *                 &lt;sequence>
         *                   &lt;element name="stato">
         *                     &lt;complexType>
         *                       &lt;simpleContent>
         *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *                           &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
         *                         &lt;/extension>
         *                       &lt;/simpleContent>
         *                     &lt;/complexType>
         *                   &lt;/element>
         *                   &lt;element name="provincia">
         *                     &lt;complexType>
         *                       &lt;simpleContent>
         *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *                           &lt;attribute name="sigla" type="{http://www.w3.org/2001/XMLSchema}string" />
         *                         &lt;/extension>
         *                       &lt;/simpleContent>
         *                     &lt;/complexType>
         *                   &lt;/element>
         *                   &lt;element name="comune">
         *                     &lt;complexType>
         *                       &lt;simpleContent>
         *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *                           &lt;attribute name="codice-catastale" type="{http://www.w3.org/2001/XMLSchema}string" />
         *                         &lt;/extension>
         *                       &lt;/simpleContent>
         *                     &lt;/complexType>
         *                   &lt;/element>
         *                   &lt;element name="cap" type="{http://www.w3.org/2001/XMLSchema}short"/>
         *                   &lt;element name="toponimo" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *                   &lt;element name="denominazione-stradale" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *                   &lt;element name="numero-civico" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *                 &lt;/sequence>
         *               &lt;/restriction>
         *             &lt;/complexContent>
         *           &lt;/complexType>
         *         &lt;/element>
         *         &lt;element name="legale-rappresentante">
         *           &lt;complexType>
         *             &lt;complexContent>
         *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
         *                 &lt;sequence>
         *                   &lt;element name="cognome" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *                   &lt;element name="nome" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *                   &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *                   &lt;element name="carica">
         *                     &lt;complexType>
         *                       &lt;simpleContent>
         *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *                           &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
         *                         &lt;/extension>
         *                       &lt;/simpleContent>
         *                     &lt;/complexType>
         *                   &lt;/element>
         *                 &lt;/sequence>
         *               &lt;/restriction>
         *             &lt;/complexContent>
         *           &lt;/complexType>
         *         &lt;/element>
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
            "formaGiuridica",
            "ragioneSociale",
            "codiceFiscale",
            "partitaIva",
            "codiceREA",
            "indirizzo",
            "legaleRappresentante"
        })
        public static class Impresa {

            @XmlElement(name = "forma-giuridica", required = true)
            protected FormaGiuridica formaGiuridica;
            @XmlElement(name = "ragione-sociale", required = true)
            protected String ragioneSociale;
            @XmlElement(name = "codice-fiscale")
            protected String codiceFiscale;
            @XmlElement(name = "partita-iva")
            protected String partitaIva;
            @XmlElement(name = "codice-REA", required = true)
            protected CodiceREA codiceREA;
            @XmlElement(required = true)
            protected Indirizzo indirizzo;
            @XmlElement(name = "legale-rappresentante", required = true)
            protected LegaleRappresentante legaleRappresentante;

            /**
             * Recupera il valore della propriet� formaGiuridica.
             * 
             * @return
             *     possible object is
             *     {@link FormaGiuridica }
             *     
             */
            public FormaGiuridica getFormaGiuridica() {
                return formaGiuridica;
            }

            /**
             * Imposta il valore della propriet� formaGiuridica.
             * 
             * @param value
             *     allowed object is
             *     {@link FormaGiuridica }
             *     
             */
            public void setFormaGiuridica(FormaGiuridica value) {
                this.formaGiuridica = value;
            }

            /**
             * Recupera il valore della propriet� ragioneSociale.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getRagioneSociale() {
                return ragioneSociale;
            }

            /**
             * Imposta il valore della propriet� ragioneSociale.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setRagioneSociale(String value) {
                this.ragioneSociale = value;
            }

            /**
             * Recupera il valore della propriet� codiceFiscale.
             * 
             */
            public String getCodiceFiscale() {
                return codiceFiscale;
            }

            /**
             * Imposta il valore della propriet� codiceFiscale.
             * 
             */
            public void setCodiceFiscale(String value) {
                this.codiceFiscale = value;
            }


            /**
             * Recupera il valore della propriet� partitaIva.
             *
             */
            public String getPartitaIva() {
                return partitaIva;
            }

            /**
             * Imposta il valore della propriet� partitaIva.
             *
             */
            public void setPartitaIva(String value) {
                this.partitaIva = value;
            }

            /**
             * Recupera il valore della propriet� codiceREA.
             * 
             * @return
             *     possible object is
             *     {@link CodiceREA }
             *     
             */
            public CodiceREA getCodiceREA() {
                return codiceREA;
            }

            /**
             * Imposta il valore della propriet� codiceREA.
             * 
             * @param value
             *     allowed object is
             *     {@link CodiceREA }
             *     
             */
            public void setCodiceREA(CodiceREA value) {
                this.codiceREA = value;
            }

            /**
             * Recupera il valore della propriet� indirizzo.
             * 
             * @return
             *     possible object is
             *     {@link Indirizzo }
             *     
             */
            public Indirizzo getIndirizzo() {
                return indirizzo;
            }

            /**
             * Imposta il valore della propriet� indirizzo.
             * 
             * @param value
             *     allowed object is
             *     {@link Indirizzo }
             *     
             */
            public void setIndirizzo(Indirizzo value) {
                this.indirizzo = value;
            }

            /**
             * Recupera il valore della propriet� legaleRappresentante.
             * 
             * @return
             *     possible object is
             *     {@link LegaleRappresentante }
             *     
             */
            public LegaleRappresentante getLegaleRappresentante() {
                return legaleRappresentante;
            }

            /**
             * Imposta il valore della propriet� legaleRappresentante.
             * 
             * @param value
             *     allowed object is
             *     {@link LegaleRappresentante }
             *     
             */
            public void setLegaleRappresentante(LegaleRappresentante value) {
                this.legaleRappresentante = value;
            }


            /**
             * <p>Classe Java per anonymous complex type.
             * 
             * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
             * 
             * <pre>
             * &lt;complexType>
             *   &lt;simpleContent>
             *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>int">
             *       &lt;attribute name="provincia" type="{http://www.w3.org/2001/XMLSchema}string" />
             *     &lt;/extension>
             *   &lt;/simpleContent>
             * &lt;/complexType>
             * </pre>
             * 
             * 
             */
            @XmlAccessorType(XmlAccessType.FIELD)
            @XmlType(name = "", propOrder = {
                "value"
            })
            public static class CodiceREA {

                @XmlValue
                protected int value;
                @XmlAttribute(name = "provincia")
                protected String provincia;

                /**
                 * Recupera il valore della propriet� value.
                 * 
                 */
                public int getValue() {
                    return value;
                }

                /**
                 * Imposta il valore della propriet� value.
                 * 
                 */
                public void setValue(int value) {
                    this.value = value;
                }

                /**
                 * Recupera il valore della propriet� provincia.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getProvincia() {
                    return provincia;
                }

                /**
                 * Imposta il valore della propriet� provincia.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setProvincia(String value) {
                    this.provincia = value;
                }

            }


            /**
             * <p>Classe Java per anonymous complex type.
             * 
             * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
             * 
             * <pre>
             * &lt;complexType>
             *   &lt;simpleContent>
             *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
             *       &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
             *     &lt;/extension>
             *   &lt;/simpleContent>
             * &lt;/complexType>
             * </pre>
             * 
             * 
             */
            @XmlAccessorType(XmlAccessType.FIELD)
            @XmlType(name = "", propOrder = {
                "value"
            })
            public static class FormaGiuridica {

                @XmlValue
                protected String value;
                @XmlAttribute(name = "codice")
                protected String codice;

                /**
                 * Recupera il valore della propriet� value.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getValue() {
                    return value;
                }

                /**
                 * Imposta il valore della propriet� value.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setValue(String value) {
                    this.value = value;
                }

                /**
                 * Recupera il valore della propriet� codice.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getCodice() {
                    return codice;
                }

                /**
                 * Imposta il valore della propriet� codice.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setCodice(String value) {
                    this.codice = value;
                }

            }


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
             *         &lt;element name="stato">
             *           &lt;complexType>
             *             &lt;simpleContent>
             *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
             *                 &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
             *               &lt;/extension>
             *             &lt;/simpleContent>
             *           &lt;/complexType>
             *         &lt;/element>
             *         &lt;element name="provincia">
             *           &lt;complexType>
             *             &lt;simpleContent>
             *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
             *                 &lt;attribute name="sigla" type="{http://www.w3.org/2001/XMLSchema}string" />
             *               &lt;/extension>
             *             &lt;/simpleContent>
             *           &lt;/complexType>
             *         &lt;/element>
             *         &lt;element name="comune">
             *           &lt;complexType>
             *             &lt;simpleContent>
             *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
             *                 &lt;attribute name="codice-catastale" type="{http://www.w3.org/2001/XMLSchema}string" />
             *               &lt;/extension>
             *             &lt;/simpleContent>
             *           &lt;/complexType>
             *         &lt;/element>
             *         &lt;element name="cap" type="{http://www.w3.org/2001/XMLSchema}short"/>
             *         &lt;element name="toponimo" type="{http://www.w3.org/2001/XMLSchema}string"/>
             *         &lt;element name="denominazione-stradale" type="{http://www.w3.org/2001/XMLSchema}string"/>
             *         &lt;element name="numero-civico" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
                "stato",
                "provincia",
                "comune",
                "cap",
                "toponimo",
                "denominazioneStradale",
                "numeroCivico"
            })
            public static class Indirizzo {

                @XmlElement(required = true)
                protected Stato stato;
                @XmlElement(required = true)
                protected Provincia provincia;
                @XmlElement(required = true)
                protected Comune comune;
                protected short cap;
                @XmlElement(required = true)
                protected String toponimo;
                @XmlElement(name = "denominazione-stradale", required = true)
                protected String denominazioneStradale;
                @XmlElement(name = "numero-civico", required = true)
                protected String numeroCivico;

                /**
                 * Recupera il valore della propriet� stato.
                 * 
                 * @return
                 *     possible object is
                 *     {@link Stato }
                 *     
                 */
                public Stato getStato() {
                    return stato;
                }

                /**
                 * Imposta il valore della propriet� stato.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link Stato }
                 *     
                 */
                public void setStato(Stato value) {
                    this.stato = value;
                }

                /**
                 * Recupera il valore della propriet� provincia.
                 * 
                 * @return
                 *     possible object is
                 *     {@link Provincia }
                 *     
                 */
                public Provincia getProvincia() {
                    return provincia;
                }

                /**
                 * Imposta il valore della propriet� provincia.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link Provincia }
                 *     
                 */
                public void setProvincia(Provincia value) {
                    this.provincia = value;
                }

                /**
                 * Recupera il valore della propriet� comune.
                 * 
                 * @return
                 *     possible object is
                 *     {@link Comune }
                 *     
                 */
                public Comune getComune() {
                    return comune;
                }

                /**
                 * Imposta il valore della propriet� comune.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link Comune }
                 *     
                 */
                public void setComune(Comune value) {
                    this.comune = value;
                }

                /**
                 * Recupera il valore della propriet� cap.
                 * 
                 */
                public short getCap() {
                    return cap;
                }

                /**
                 * Imposta il valore della propriet� cap.
                 * 
                 */
                public void setCap(short value) {
                    this.cap = value;
                }

                /**
                 * Recupera il valore della propriet� toponimo.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getToponimo() {
                    return toponimo;
                }

                /**
                 * Imposta il valore della propriet� toponimo.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setToponimo(String value) {
                    this.toponimo = value;
                }

                /**
                 * Recupera il valore della propriet� denominazioneStradale.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getDenominazioneStradale() {
                    return denominazioneStradale;
                }

                /**
                 * Imposta il valore della propriet� denominazioneStradale.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setDenominazioneStradale(String value) {
                    this.denominazioneStradale = value;
                }

                /**
                 * Recupera il valore della propriet� numeroCivico.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getNumeroCivico() {
                    return numeroCivico;
                }

                /**
                 * Imposta il valore della propriet� numeroCivico.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setNumeroCivico(String value) {
                    this.numeroCivico = value;
                }


                /**
                 * <p>Classe Java per anonymous complex type.
                 * 
                 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
                 * 
                 * <pre>
                 * &lt;complexType>
                 *   &lt;simpleContent>
                 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
                 *       &lt;attribute name="codice-catastale" type="{http://www.w3.org/2001/XMLSchema}string" />
                 *     &lt;/extension>
                 *   &lt;/simpleContent>
                 * &lt;/complexType>
                 * </pre>
                 * 
                 * 
                 */
                @XmlAccessorType(XmlAccessType.FIELD)
                @XmlType(name = "", propOrder = {
                    "value"
                })
                public static class Comune {

                    @XmlValue
                    protected String value;
                    @XmlAttribute(name = "codice-catastale")
                    protected String codiceCatastale;

                    /**
                     * Recupera il valore della propriet� value.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getValue() {
                        return value;
                    }

                    /**
                     * Imposta il valore della propriet� value.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setValue(String value) {
                        this.value = value;
                    }

                    /**
                     * Recupera il valore della propriet� codiceCatastale.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getCodiceCatastale() {
                        return codiceCatastale;
                    }

                    /**
                     * Imposta il valore della propriet� codiceCatastale.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setCodiceCatastale(String value) {
                        this.codiceCatastale = value;
                    }

                }


                /**
                 * <p>Classe Java per anonymous complex type.
                 * 
                 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
                 * 
                 * <pre>
                 * &lt;complexType>
                 *   &lt;simpleContent>
                 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
                 *       &lt;attribute name="sigla" type="{http://www.w3.org/2001/XMLSchema}string" />
                 *     &lt;/extension>
                 *   &lt;/simpleContent>
                 * &lt;/complexType>
                 * </pre>
                 * 
                 * 
                 */
                @XmlAccessorType(XmlAccessType.FIELD)
                @XmlType(name = "", propOrder = {
                    "value"
                })
                public static class Provincia {

                    @XmlValue
                    protected String value;
                    @XmlAttribute(name = "sigla")
                    protected String sigla;

                    /**
                     * Recupera il valore della propriet� value.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getValue() {
                        return value;
                    }

                    /**
                     * Imposta il valore della propriet� value.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setValue(String value) {
                        this.value = value;
                    }

                    /**
                     * Recupera il valore della propriet� sigla.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getSigla() {
                        return sigla;
                    }

                    /**
                     * Imposta il valore della propriet� sigla.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setSigla(String value) {
                        this.sigla = value;
                    }

                }


                /**
                 * <p>Classe Java per anonymous complex type.
                 * 
                 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
                 * 
                 * <pre>
                 * &lt;complexType>
                 *   &lt;simpleContent>
                 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
                 *       &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
                 *     &lt;/extension>
                 *   &lt;/simpleContent>
                 * &lt;/complexType>
                 * </pre>
                 * 
                 * 
                 */
                @XmlAccessorType(XmlAccessType.FIELD)
                @XmlType(name = "", propOrder = {
                    "value"
                })
                public static class Stato {

                    @XmlValue
                    protected String value;
                    @XmlAttribute(name = "codice")
                    protected String codice;

                    /**
                     * Recupera il valore della propriet� value.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getValue() {
                        return value;
                    }

                    /**
                     * Imposta il valore della propriet� value.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setValue(String value) {
                        this.value = value;
                    }

                    /**
                     * Recupera il valore della propriet� codice.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getCodice() {
                        return codice;
                    }

                    /**
                     * Imposta il valore della propriet� codice.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setCodice(String value) {
                        this.codice = value;
                    }

                }

            }


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
             *         &lt;element name="cognome" type="{http://www.w3.org/2001/XMLSchema}string"/>
             *         &lt;element name="nome" type="{http://www.w3.org/2001/XMLSchema}string"/>
             *         &lt;element name="codice-fiscale" type="{http://www.w3.org/2001/XMLSchema}string"/>
             *         &lt;element name="carica">
             *           &lt;complexType>
             *             &lt;simpleContent>
             *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
             *                 &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
             *               &lt;/extension>
             *             &lt;/simpleContent>
             *           &lt;/complexType>
             *         &lt;/element>
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
                "cognome",
                "nome",
                "codiceFiscale",
                "carica"
            })
            public static class LegaleRappresentante {

                @XmlElement(required = true)
                protected String cognome;
                @XmlElement(required = true)
                protected String nome;
                @XmlElement(name = "codice-fiscale", required = true)
                protected String codiceFiscale;
                @XmlElement(required = true)
                protected Carica carica;

                /**
                 * Recupera il valore della propriet� cognome.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getCognome() {
                    return cognome;
                }

                /**
                 * Imposta il valore della propriet� cognome.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setCognome(String value) {
                    this.cognome = value;
                }

                /**
                 * Recupera il valore della propriet� nome.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getNome() {
                    return nome;
                }

                /**
                 * Imposta il valore della propriet� nome.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setNome(String value) {
                    this.nome = value;
                }

                /**
                 * Recupera il valore della propriet� codiceFiscale.
                 * 
                 * @return
                 *     possible object is
                 *     {@link String }
                 *     
                 */
                public String getCodiceFiscale() {
                    return codiceFiscale;
                }

                /**
                 * Imposta il valore della propriet� codiceFiscale.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link String }
                 *     
                 */
                public void setCodiceFiscale(String value) {
                    this.codiceFiscale = value;
                }

                /**
                 * Recupera il valore della propriet� carica.
                 * 
                 * @return
                 *     possible object is
                 *     {@link Carica }
                 *     
                 */
                public Carica getCarica() {
                    return carica;
                }

                /**
                 * Imposta il valore della propriet� carica.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link Carica }
                 *     
                 */
                public void setCarica(Carica value) {
                    this.carica = value;
                }


                /**
                 * <p>Classe Java per anonymous complex type.
                 * 
                 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
                 * 
                 * <pre>
                 * &lt;complexType>
                 *   &lt;simpleContent>
                 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
                 *       &lt;attribute name="codice" type="{http://www.w3.org/2001/XMLSchema}string" />
                 *     &lt;/extension>
                 *   &lt;/simpleContent>
                 * &lt;/complexType>
                 * </pre>
                 * 
                 * 
                 */
                @XmlAccessorType(XmlAccessType.FIELD)
                @XmlType(name = "", propOrder = {
                    "value"
                })
                public static class Carica {

                    @XmlValue
                    protected String value;
                    @XmlAttribute(name = "codice")
                    protected String codice;

                    /**
                     * Recupera il valore della propriet� value.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getValue() {
                        return value;
                    }

                    /**
                     * Imposta il valore della propriet� value.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setValue(String value) {
                        this.value = value;
                    }

                    /**
                     * Recupera il valore della propriet� codice.
                     * 
                     * @return
                     *     possible object is
                     *     {@link String }
                     *     
                     */
                    public String getCodice() {
                        return codice;
                    }

                    /**
                     * Imposta il valore della propriet� codice.
                     * 
                     * @param value
                     *     allowed object is
                     *     {@link String }
                     *     
                     */
                    public void setCodice(String value) {
                        this.codice = value;
                    }

                }

            }

        }


        /**
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="tipo-cooperazione" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "value"
        })
        public static class OggettoComunicazione {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "tipo-cooperazione")
            protected String tipoCooperazione;

            /**
             * Recupera il valore della propriet� value.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getValue() {
                return value;
            }

            /**
             * Imposta il valore della propriet� value.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setValue(String value) {
                this.value = value;
            }

            /**
             * Recupera il valore della propriet� tipoCooperazione.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getTipoCooperazione() {
                return tipoCooperazione;
            }

            /**
             * Imposta il valore della propriet� tipoCooperazione.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setTipoCooperazione(String value) {
                this.tipoCooperazione = value;
            }

        }


        /**
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="tipo-procedimento" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="tipo-intervento" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "value"
        })
        public static class OggettoPratica {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "tipo-procedimento")
            protected String tipoProcedimento;
            @XmlAttribute(name = "tipo-intervento")
            protected String tipoIntervento;

            /**
             * Recupera il valore della propriet� value.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getValue() {
                return value;
            }

            /**
             * Imposta il valore della propriet� value.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setValue(String value) {
                this.value = value;
            }

            /**
             * Recupera il valore della propriet� tipoProcedimento.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getTipoProcedimento() {
                return tipoProcedimento;
            }

            /**
             * Imposta il valore della propriet� tipoProcedimento.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setTipoProcedimento(String value) {
                this.tipoProcedimento = value;
            }

            /**
             * Recupera il valore della propriet� tipoIntervento.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getTipoIntervento() {
                return tipoIntervento;
            }

            /**
             * Imposta il valore della propriet� tipoIntervento.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setTipoIntervento(String value) {
                this.tipoIntervento = value;
            }

        }


        /**
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="data-registrazione" type="{http://www.w3.org/2001/XMLSchema}date" />
         *       &lt;attribute name="numero-registrazione" type="{http://www.w3.org/2001/XMLSchema}short" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "value"
        })
        public static class Protocollo {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "codice-amministrazione")
            protected String codiceAmministrazione;
            @XmlAttribute(name = "codice-aoo")
            protected String codiceAoo;
            @XmlAttribute(name = "data-registrazione")
            @XmlSchemaType(name = "date")
            protected XMLGregorianCalendar dataRegistrazione;
            @XmlAttribute(name = "numero-registrazione")
            protected Short numeroRegistrazione;

            /**
             * Recupera il valore della propriet� value.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getValue() {
                return value;
            }

            /**
             * Imposta il valore della propriet� value.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setValue(String value) {
                this.value = value;
            }

            /**
             * Recupera il valore della propriet� codiceAmministrazione.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodiceAmministrazione() {
                return codiceAmministrazione;
            }

            /**
             * Imposta il valore della propriet� codiceAmministrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodiceAmministrazione(String value) {
                this.codiceAmministrazione = value;
            }

            /**
             * Recupera il valore della propriet� codiceAoo.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodiceAoo() {
                return codiceAoo;
            }

            /**
             * Imposta il valore della propriet� codiceAoo.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodiceAoo(String value) {
                this.codiceAoo = value;
            }

            /**
             * Recupera il valore della propriet� dataRegistrazione.
             * 
             * @return
             *     possible object is
             *     {@link XMLGregorianCalendar }
             *     
             */
            public XMLGregorianCalendar getDataRegistrazione() {
                return dataRegistrazione;
            }

            /**
             * Imposta il valore della propriet� dataRegistrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link XMLGregorianCalendar }
             *     
             */
            public void setDataRegistrazione(XMLGregorianCalendar value) {
                this.dataRegistrazione = value;
            }

            /**
             * Recupera il valore della propriet� numeroRegistrazione.
             * 
             * @return
             *     possible object is
             *     {@link Short }
             *     
             */
            public Short getNumeroRegistrazione() {
                return numeroRegistrazione;
            }

            /**
             * Imposta il valore della propriet� numeroRegistrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link Short }
             *     
             */
            public void setNumeroRegistrazione(Short value) {
                this.numeroRegistrazione = value;
            }

        }


        /**
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="data-registrazione" type="{http://www.w3.org/2001/XMLSchema}date" />
         *       &lt;attribute name="numero-registrazione" type="{http://www.w3.org/2001/XMLSchema}int" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "value"
        })
        public static class ProtocolloPraticaSuap {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "codice-amministrazione")
            protected String codiceAmministrazione;
            @XmlAttribute(name = "codice-aoo")
            protected String codiceAoo;
            @XmlAttribute(name = "data-registrazione")
            @XmlSchemaType(name = "date")
            protected XMLGregorianCalendar dataRegistrazione;
            @XmlAttribute(name = "numero-registrazione")
            protected Integer numeroRegistrazione;

            /**
             * Recupera il valore della propriet� value.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getValue() {
                return value;
            }

            /**
             * Imposta il valore della propriet� value.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setValue(String value) {
                this.value = value;
            }

            /**
             * Recupera il valore della propriet� codiceAmministrazione.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodiceAmministrazione() {
                return codiceAmministrazione;
            }

            /**
             * Imposta il valore della propriet� codiceAmministrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodiceAmministrazione(String value) {
                this.codiceAmministrazione = value;
            }

            /**
             * Recupera il valore della propriet� codiceAoo.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodiceAoo() {
                return codiceAoo;
            }

            /**
             * Imposta il valore della propriet� codiceAoo.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodiceAoo(String value) {
                this.codiceAoo = value;
            }

            /**
             * Recupera il valore della propriet� dataRegistrazione.
             * 
             * @return
             *     possible object is
             *     {@link XMLGregorianCalendar }
             *     
             */
            public XMLGregorianCalendar getDataRegistrazione() {
                return dataRegistrazione;
            }

            /**
             * Imposta il valore della propriet� dataRegistrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link XMLGregorianCalendar }
             *     
             */
            public void setDataRegistrazione(XMLGregorianCalendar value) {
                this.dataRegistrazione = value;
            }

            /**
             * Recupera il valore della propriet� numeroRegistrazione.
             * 
             * @return
             *     possible object is
             *     {@link Integer }
             *     
             */
            public Integer getNumeroRegistrazione() {
                return numeroRegistrazione;
            }

            /**
             * Imposta il valore della propriet� numeroRegistrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link Integer }
             *     
             */
            public void setNumeroRegistrazione(Integer value) {
                this.numeroRegistrazione = value;
            }

        }


        /**
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="codice-amministrazione" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="codice-aoo" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="identificativo-suap" type="{http://www.w3.org/2001/XMLSchema}short" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "value"
        })
        public static class SuapCompetente {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "codice-amministrazione")
            protected String codiceAmministrazione;
            @XmlAttribute(name = "codice-aoo")
            protected String codiceAoo;
            @XmlAttribute(name = "identificativo-suap")
            protected Short identificativoSuap;

            /**
             * Recupera il valore della propriet� value.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getValue() {
                return value;
            }

            /**
             * Imposta il valore della propriet� value.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setValue(String value) {
                this.value = value;
            }

            /**
             * Recupera il valore della propriet� codiceAmministrazione.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodiceAmministrazione() {
                return codiceAmministrazione;
            }

            /**
             * Imposta il valore della propriet� codiceAmministrazione.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodiceAmministrazione(String value) {
                this.codiceAmministrazione = value;
            }

            /**
             * Recupera il valore della propriet� codiceAoo.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodiceAoo() {
                return codiceAoo;
            }

            /**
             * Imposta il valore della propriet� codiceAoo.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodiceAoo(String value) {
                this.codiceAoo = value;
            }

            /**
             * Recupera il valore della propriet� identificativoSuap.
             * 
             * @return
             *     possible object is
             *     {@link Short }
             *     
             */
            public Short getIdentificativoSuap() {
                return identificativoSuap;
            }

            /**
             * Imposta il valore della propriet� identificativoSuap.
             * 
             * @param value
             *     allowed object is
             *     {@link Short }
             *     
             */
            public void setIdentificativoSuap(Short value) {
                this.identificativoSuap = value;
            }

        }

    }

}
