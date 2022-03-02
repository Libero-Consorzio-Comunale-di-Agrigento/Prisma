package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "FascicoloArchi", propOrder = {
    "annoFascicolo",
    "numeroFascicolo",
    "oggettoFascicolo",
})
public class FascicoloArchi {
    @XmlElement(name = "AnnoFascicolo")
    protected String annoFascicolo;

    @XmlElement(name = "NumeroFascicolo")
    protected String numeroFascicolo;

    @XmlElement(name = "OggettoFascicolo")
    protected String oggettoFascicolo;

    public String getAnnoFascicolo() {
        return annoFascicolo;
    }

    public void setAnnoFascicolo(String annoFascicolo) {
        this.annoFascicolo = annoFascicolo;
    }

    public String getNumeroFascicolo() {
        return numeroFascicolo;
    }

    public void setNumeroFascicolo(String numeroFascicolo) {
        this.numeroFascicolo = numeroFascicolo;
    }

    public String getOggettoFascicolo() {
        return oggettoFascicolo;
    }

    public void setOggettoFascicolo(String oggettoFascicolo) {
        this.oggettoFascicolo = oggettoFascicolo;
    }
}
