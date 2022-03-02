
package it.finmatica.affarigenerali.ducd.entiAooUtility;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
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
 *         &lt;element name="checkDateReturn" type="{http://www.w3.org/2001/XMLSchema}boolean"/>
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
    "checkDateReturn"
})
@XmlRootElement(name = "checkDateResponse")
public class CheckDateResponse {

    protected boolean checkDateReturn;

    /**
     * Recupera il valore della propriet� checkDateReturn.
     * 
     */
    public boolean isCheckDateReturn() {
        return checkDateReturn;
    }

    /**
     * Imposta il valore della propriet� checkDateReturn.
     * 
     */
    public void setCheckDateReturn(boolean value) {
        this.checkDateReturn = value;
    }

}
