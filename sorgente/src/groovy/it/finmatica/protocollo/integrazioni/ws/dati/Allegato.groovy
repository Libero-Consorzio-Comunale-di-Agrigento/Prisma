package it.finmatica.protocollo.integrazioni.ws.dati

import javax.activation.DataHandler
import javax.xml.bind.annotation.*


@XmlRootElement(name="allegato")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class Allegato {

    @XmlElement String idRiferimento    // id del documento dell'applicativo esterno

    @XmlElement String contentType

    @XmlElement String nomeFile

    @XmlElement Boolean stampaUnica

    @XmlMimeType("application/octet-stream")
    DataHandler file
}
