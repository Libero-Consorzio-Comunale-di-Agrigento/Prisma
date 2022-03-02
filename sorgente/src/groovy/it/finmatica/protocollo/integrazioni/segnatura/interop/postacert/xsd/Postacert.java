//
// Questo file ่ stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andrเ persa durante la ricompilazione dello schema di origine. 
// Generato il: 2020.09.02 alle 10:08:33 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.postacert.xsd;

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
 *         &lt;element name="intestazione">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="mittente" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="destinatari">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                           &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="risposte" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="oggetto" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="dati">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="gestore-emittente" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="data">
 *                     &lt;complexType>
 *                       &lt;complexContent>
 *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                           &lt;sequence>
 *                             &lt;element name="giorno" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                             &lt;element name="ora" type="{http://www.w3.org/2001/XMLSchema}time"/>
 *                           &lt;/sequence>
 *                           &lt;attribute name="zona" use="required" type="{http://www.w3.org/2001/XMLSchema}short" />
 *                         &lt;/restriction>
 *                       &lt;/complexContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="identificativo" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                   &lt;element name="msgid" type="{http://www.w3.org/2001/XMLSchema}unsignedShort"/>
 *                   &lt;element name="ricevuta">
 *                     &lt;complexType>
 *                       &lt;complexContent>
 *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                           &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/restriction>
 *                       &lt;/complexContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="consegna" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="errore" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
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
    "dati"
})
@XmlRootElement(name = "postacert")
public class Postacert {

    @XmlElement(required = true)
    protected Postacert.Intestazione intestazione;
    @XmlElement(required = true)
    protected Postacert.Dati dati;
    @XmlAttribute(name = "tipo", required = true)
    protected String tipo;
    @XmlAttribute(name = "errore", required = true)
    protected String errore;

    /**
     * Recupera il valore della proprietเ intestazione.
     * 
     * @return
     *     possible object is
     *     {@link Postacert.Intestazione }
     *     
     */
    public Postacert.Intestazione getIntestazione() {
        return intestazione;
    }

    /**
     * Imposta il valore della proprietเ intestazione.
     * 
     * @param value
     *     allowed object is
     *     {@link Postacert.Intestazione }
     *     
     */
    public void setIntestazione(Postacert.Intestazione value) {
        this.intestazione = value;
    }

    /**
     * Recupera il valore della proprietเ dati.
     * 
     * @return
     *     possible object is
     *     {@link Postacert.Dati }
     *     
     */
    public Postacert.Dati getDati() {
        return dati;
    }

    /**
     * Imposta il valore della proprietเ dati.
     * 
     * @param value
     *     allowed object is
     *     {@link Postacert.Dati }
     *     
     */
    public void setDati(Postacert.Dati value) {
        this.dati = value;
    }

    /**
     * Recupera il valore della proprietเ tipo.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTipo() {
        return tipo;
    }

    /**
     * Imposta il valore della proprietเ tipo.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTipo(String value) {
        this.tipo = value;
    }

    /**
     * Recupera il valore della proprietเ errore.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getErrore() {
        return errore;
    }

    /**
     * Imposta il valore della proprietเ errore.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setErrore(String value) {
        this.errore = value;
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
     *         &lt;element name="gestore-emittente" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="data">
     *           &lt;complexType>
     *             &lt;complexContent>
     *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                 &lt;sequence>
     *                   &lt;element name="giorno" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *                   &lt;element name="ora" type="{http://www.w3.org/2001/XMLSchema}time"/>
     *                 &lt;/sequence>
     *                 &lt;attribute name="zona" use="required" type="{http://www.w3.org/2001/XMLSchema}short" />
     *               &lt;/restriction>
     *             &lt;/complexContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="identificativo" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="msgid" type="{http://www.w3.org/2001/XMLSchema}unsignedShort"/>
     *         &lt;element name="ricevuta">
     *           &lt;complexType>
     *             &lt;complexContent>
     *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                 &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/restriction>
     *             &lt;/complexContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="consegna" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
        "gestoreEmittente",
        "data",
        "identificativo",
        "msgid",
        "ricevuta",
        "consegna"
    })
    public static class Dati {

        @XmlElement(name = "gestore-emittente", required = true)
        protected String gestoreEmittente;
        @XmlElement(required = true)
        protected Postacert.Dati.Data data;
        @XmlElement(required = true)
        protected String identificativo;
        @XmlSchemaType(name = "unsignedShort")
        protected int msgid;
        @XmlElement(required = true)
        protected Postacert.Dati.Ricevuta ricevuta;
        @XmlElement(required = true)
        protected String consegna;

        /**
         * Recupera il valore della proprietเ gestoreEmittente.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getGestoreEmittente() {
            return gestoreEmittente;
        }

        /**
         * Imposta il valore della proprietเ gestoreEmittente.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setGestoreEmittente(String value) {
            this.gestoreEmittente = value;
        }

        /**
         * Recupera il valore della proprietเ data.
         * 
         * @return
         *     possible object is
         *     {@link Postacert.Dati.Data }
         *     
         */
        public Postacert.Dati.Data getData() {
            return data;
        }

        /**
         * Imposta il valore della proprietเ data.
         * 
         * @param value
         *     allowed object is
         *     {@link Postacert.Dati.Data }
         *     
         */
        public void setData(Postacert.Dati.Data value) {
            this.data = value;
        }

        /**
         * Recupera il valore della proprietเ identificativo.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getIdentificativo() {
            return identificativo;
        }

        /**
         * Imposta il valore della proprietเ identificativo.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setIdentificativo(String value) {
            this.identificativo = value;
        }

        /**
         * Recupera il valore della proprietเ msgid.
         * 
         */
        public int getMsgid() {
            return msgid;
        }

        /**
         * Imposta il valore della proprietเ msgid.
         * 
         */
        public void setMsgid(int value) {
            this.msgid = value;
        }

        /**
         * Recupera il valore della proprietเ ricevuta.
         * 
         * @return
         *     possible object is
         *     {@link Postacert.Dati.Ricevuta }
         *     
         */
        public Postacert.Dati.Ricevuta getRicevuta() {
            return ricevuta;
        }

        /**
         * Imposta il valore della proprietเ ricevuta.
         * 
         * @param value
         *     allowed object is
         *     {@link Postacert.Dati.Ricevuta }
         *     
         */
        public void setRicevuta(Postacert.Dati.Ricevuta value) {
            this.ricevuta = value;
        }

        /**
         * Recupera il valore della proprietเ consegna.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getConsegna() {
            return consegna;
        }

        /**
         * Imposta il valore della proprietเ consegna.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setConsegna(String value) {
            this.consegna = value;
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
         *         &lt;element name="giorno" type="{http://www.w3.org/2001/XMLSchema}string"/>
         *         &lt;element name="ora" type="{http://www.w3.org/2001/XMLSchema}time"/>
         *       &lt;/sequence>
         *       &lt;attribute name="zona" use="required" type="{http://www.w3.org/2001/XMLSchema}short" />
         *     &lt;/restriction>
         *   &lt;/complexContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "giorno",
            "ora"
        })
        public static class Data {

            @XmlElement(required = true)
            protected String giorno;
            @XmlElement(required = true)
            @XmlSchemaType(name = "time")
            protected XMLGregorianCalendar ora;
            @XmlAttribute(name = "zona", required = true)
            protected short zona;

            /**
             * Recupera il valore della proprietเ giorno.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getGiorno() {
                return giorno;
            }

            /**
             * Imposta il valore della proprietเ giorno.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setGiorno(String value) {
                this.giorno = value;
            }

            /**
             * Recupera il valore della proprietเ ora.
             * 
             * @return
             *     possible object is
             *     {@link XMLGregorianCalendar }
             *     
             */
            public XMLGregorianCalendar getOra() {
                return ora;
            }

            /**
             * Imposta il valore della proprietเ ora.
             * 
             * @param value
             *     allowed object is
             *     {@link XMLGregorianCalendar }
             *     
             */
            public void setOra(XMLGregorianCalendar value) {
                this.ora = value;
            }

            /**
             * Recupera il valore della proprietเ zona.
             * 
             */
            public short getZona() {
                return zona;
            }

            /**
             * Imposta il valore della proprietเ zona.
             * 
             */
            public void setZona(short value) {
                this.zona = value;
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
         *       &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/restriction>
         *   &lt;/complexContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "")
        public static class Ricevuta {

            @XmlAttribute(name = "tipo", required = true)
            protected String tipo;

            /**
             * Recupera il valore della proprietเ tipo.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getTipo() {
                return tipo;
            }

            /**
             * Imposta il valore della proprietเ tipo.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setTipo(String value) {
                this.tipo = value;
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
     *         &lt;element name="mittente" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="destinatari">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *                 &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="risposte" type="{http://www.w3.org/2001/XMLSchema}string"/>
     *         &lt;element name="oggetto" type="{http://www.w3.org/2001/XMLSchema}string"/>
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
        "mittente",
        "destinatari",
        "risposte",
        "oggetto"
    })
    public static class Intestazione {

        @XmlElement(required = true)
        protected String mittente;
        @XmlElement(required = true)
        protected Postacert.Intestazione.Destinatari destinatari;
        @XmlElement(required = true)
        protected String risposte;
        @XmlElement(required = true)
        protected String oggetto;

        /**
         * Recupera il valore della proprietเ mittente.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getMittente() {
            return mittente;
        }

        /**
         * Imposta il valore della proprietเ mittente.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setMittente(String value) {
            this.mittente = value;
        }

        /**
         * Recupera il valore della proprietเ destinatari.
         * 
         * @return
         *     possible object is
         *     {@link Postacert.Intestazione.Destinatari }
         *     
         */
        public Postacert.Intestazione.Destinatari getDestinatari() {
            return destinatari;
        }

        /**
         * Imposta il valore della proprietเ destinatari.
         * 
         * @param value
         *     allowed object is
         *     {@link Postacert.Intestazione.Destinatari }
         *     
         */
        public void setDestinatari(Postacert.Intestazione.Destinatari value) {
            this.destinatari = value;
        }

        /**
         * Recupera il valore della proprietเ risposte.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getRisposte() {
            return risposte;
        }

        /**
         * Imposta il valore della proprietเ risposte.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setRisposte(String value) {
            this.risposte = value;
        }

        /**
         * Recupera il valore della proprietเ oggetto.
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
         * Imposta il valore della proprietเ oggetto.
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
         * <p>Classe Java per anonymous complex type.
         * 
         * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;simpleContent>
         *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
         *       &lt;attribute name="tipo" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
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
        public static class Destinatari {

            @XmlValue
            protected String value;
            @XmlAttribute(name = "tipo", required = true)
            protected String tipo;

            /**
             * Recupera il valore della proprietเ value.
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
             * Imposta il valore della proprietเ value.
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
             * Recupera il valore della proprietเ tipo.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getTipo() {
                return tipo;
            }

            /**
             * Imposta il valore della proprietเ tipo.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setTipo(String value) {
                this.tipo = value;
            }

        }

    }

}
