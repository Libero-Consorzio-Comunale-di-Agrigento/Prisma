package it.finmatica.protocollo.integrazioni.ws.dati

import groovy.transform.CompileStatic

import javax.xml.bind.annotation.*

@XmlRootElement(name="statoFlusso")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
@CompileStatic
class StatoProtocollo {
    @XmlElement String stato
    @XmlElement String utente
    @XmlElement Date dataModifica
}





