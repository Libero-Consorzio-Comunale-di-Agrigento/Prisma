//
// Questo file � stato generato dall'architettura JavaTM per XML Binding (JAXB) Reference Implementation, v2.2.8-b130911.1802 
// Vedere <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Qualsiasi modifica a questo file andr� persa durante la ricompilazione dello schema di origine. 
// Generato il: 2019.06.10 alle 09:40:58 AM CEST 
//


package it.finmatica.protocollo.integrazioni.segnatura.interop.xsd;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Classe Java per Riferimenti complex type.
 * 
 * <p>Il seguente frammento di schema specifica il contenuto previsto contenuto in questa classe.
 * 
 * <pre>
 * &lt;complexType name="Riferimenti">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Messaggio"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}ContestoProcedurale"/>
 *         &lt;element ref="{http://www.digitPa.gov.it/protocollo/}Procedimento"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Riferimenti", propOrder = {
    "messaggioOrContestoProceduraleOrProcedimento"
})
public class Riferimenti {

    @XmlElements({
        @XmlElement(name = "Messaggio", type = Messaggio.class),
        @XmlElement(name = "ContestoProcedurale", type = ContestoProcedurale.class),
        @XmlElement(name = "Procedimento", type = Procedimento.class)
    })
    protected List<Object> messaggioOrContestoProceduraleOrProcedimento;

    /**
     * Gets the value of the messaggioOrContestoProceduraleOrProcedimento property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the messaggioOrContestoProceduraleOrProcedimento property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getMessaggioOrContestoProceduraleOrProcedimento().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Messaggio }
     * {@link ContestoProcedurale }
     * {@link Procedimento }
     * 
     * 
     */
    public List<Object> getMessaggioOrContestoProceduraleOrProcedimento() {
        if (messaggioOrContestoProceduraleOrProcedimento == null) {
            messaggioOrContestoProceduraleOrProcedimento = new ArrayList<Object>();
        }
        return this.messaggioOrContestoProceduraleOrProcedimento;
    }

}
