package it.finmatica.protocollo.integrazioni.ws.dati

import groovy.transform.CompileStatic

import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlType

@CompileStatic
@XmlType(name = "ProtocolloCompleto")
class ProtocolloCompleto extends Protocollo {
    @XmlElement(required=false, nillable=true)
    String campiProtetti
    @XmlElement(required=false, nillable=true)
    String codiceRaccomandata
    @XmlElement(required=false, nillable=true)
    Date dataComunicazione
    //FIXME documento esterno è da prevedere? Non esiste al momento dell'inserimento...
    @XmlElement(required=false, nillable=true)
    String numeroDocumentoEsterno
    @XmlElement(required=false, nillable=true)
    Date dataDocumentoEsterno
    @XmlElement(required=false, nillable=true)
    Date dataStatoArchivio
    @XmlElement(required=false, nillable=true)
    Date dataVerifica
    @XmlElement(required=false, nillable=true)
    String esitoVerifica
    @XmlElement(required=false, nillable=true)
    Integer annoEmergenza
    @XmlElement(required=false, nillable=true)
    Integer numeroEmergenza
    @XmlElement(required=false, nillable=true)
    String registroEmergenza
    @XmlElement(required=false, nillable=true)
    String idrif
    @XmlElement(required=false, nillable=true)
    String modalitaInvioRicezione
    @XmlElement(required=false, nillable=true)
    String noteTrasmissione
    @XmlElement(required=false, nillable=true)
    String tipoRegistro


}
