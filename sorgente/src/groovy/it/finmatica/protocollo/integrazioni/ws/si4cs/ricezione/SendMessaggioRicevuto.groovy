
package it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlType

/**
 * <p>Classe Java per sendMessaggioRicevuto complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="sendMessaggioRicevuto">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="arg0" type="{http://ws.finmatica.it/}messaggioRicevuto" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "sendMessaggioRicevuto")
public class SendMessaggioRicevuto {

    protected it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto arg0;

    /**
     * Recupera il valore della propriet� arg0.
     * 
     * @return
     *     possible object is
     *     {@link it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto }
     *     
     */
    public it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto getArg0() {
        return arg0;
    }

    /**
     * Imposta il valore della propriet� arg0.
     * 
     * @param value
     *     allowed object is
     *     {@link it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto }
     *     
     */
    public void setArg0(it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.MessaggioRicevuto value) {
        this.arg0 = value;
    }

}
