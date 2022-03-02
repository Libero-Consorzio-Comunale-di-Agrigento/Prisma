//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2019.06.10 alle 09:40:58 AM CEST 
//

package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlID;
import javax.xml.bind.annotation.XmlIDREF;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

/**
 * <p>Classe Java per Persona complex type.
 *
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 *
 * <pre>
 * &lt;complexType name="Persona">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;choice>
 *           &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Denominazione"/>
 *           &lt;sequence>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Nome" minOccurs="0"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Cognome"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Titolo" minOccurs="0"/>
 *             &lt;element ref="{http://www.digitPa.gov.it/protocollo/}CodiceFiscale" minOccurs="0"/>
 *           &lt;/sequence>
 *         &lt;/choice>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Identificativo" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}ID" />
 *       &lt;attribute name="rife" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "Persona")
@XmlType(name = "Persona", propOrder = {
    "denominazione",
    "nome",
    "cognome",
    "titolo",
    "codiceFiscale",
    "identificativo"
})
public class Persona {

    @XmlElement(name = "Denominazione")
    protected Denominazione denominazione;
    @XmlElement(name = "Nome")
    protected Nome nome;
    @XmlElement(name = "Cognome")
    protected Cognome cognome;
    @XmlElement(name = "Titolo")
    protected Titolo titolo;
    @XmlElement(name = "CodiceFiscale")
    protected CodiceFiscale codiceFiscale;
    @XmlElement(name = "Identificativo")
    protected Identificativo identificativo;
    @XmlAttribute(name = "id")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlID
    @XmlSchemaType(name = "ID")
    protected String id;
    @XmlAttribute(name = "rife")
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object rife;

    /**
     * Recupera il valore della propriet� denominazione.
     *
     * @return possible object is {@link Denominazione }
     */
    public Denominazione getDenominazione() {
        return denominazione;
    }

    /**
     * Imposta il valore della propriet� denominazione.
     *
     * @param value allowed object is {@link Denominazione }
     */
    public void setDenominazione(Denominazione value) {
        this.denominazione = value;
    }

    /**
     * Recupera il valore della propriet� nome.
     *
     * @return possible object is {@link Nome }
     */
    public Nome getNome() {
        return nome;
    }

    /**
     * Imposta il valore della propriet� nome.
     *
     * @param value allowed object is {@link Nome }
     */
    public void setNome(Nome value) {
        this.nome = value;
    }

    /**
     * Recupera il valore della propriet� cognome.
     *
     * @return possible object is {@link Cognome }
     */
    public Cognome getCognome() {
        return cognome;
    }

    /**
     * Imposta il valore della propriet� cognome.
     *
     * @param value allowed object is {@link Cognome }
     */
    public void setCognome(Cognome value) {
        this.cognome = value;
    }

    /**
     * Recupera il valore della propriet� titolo.
     *
     * @return possible object is {@link Titolo }
     */
    public Titolo getTitolo() {
        return titolo;
    }

    /**
     * Imposta il valore della propriet� titolo.
     *
     * @param value allowed object is {@link Titolo }
     */
    public void setTitolo(Titolo value) {
        this.titolo = value;
    }

    /**
     * Recupera il valore della propriet� codiceFiscale.
     *
     * @return possible object is {@link CodiceFiscale }
     */
    public CodiceFiscale getCodiceFiscale() {
        return codiceFiscale;
    }

    /**
     * Imposta il valore della propriet� codiceFiscale.
     *
     * @param value allowed object is {@link CodiceFiscale }
     */
    public void setCodiceFiscale(CodiceFiscale value) {
        this.codiceFiscale = value;
    }

    /**
     * Recupera il valore della propriet� identificativo.
     *
     * @return possible object is {@link Identificativo }
     */
    public Identificativo getIdentificativo() {
        return identificativo;
    }

    /**
     * Imposta il valore della propriet� identificativo.
     *
     * @param value allowed object is {@link Identificativo }
     */
    public void setIdentificativo(Identificativo value) {
        this.identificativo = value;
    }

    /**
     * Recupera il valore della propriet� id.
     *
     * @return possible object is {@link String }
     */
    public String getId() {
        return id;
    }

    /**
     * Imposta il valore della propriet� id.
     *
     * @param value allowed object is {@link String }
     */
    public void setId(String value) {
        this.id = value;
    }

    /**
     * Recupera il valore della propriet� rife.
     *
     * @return possible object is {@link Object }
     */
    public Object getRife() {
        return rife;
    }

    /**
     * Imposta il valore della propriet� rife.
     *
     * @param value allowed object is {@link Object }
     */
    public void setRife(Object value) {
        this.rife = value;
    }
}
