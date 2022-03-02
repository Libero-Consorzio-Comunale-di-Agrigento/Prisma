package it.finmatica.protocollo.integrazioni.ws.dati

import javax.xml.bind.annotation.*

@XmlRootElement(name="documentoCollegato")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class DocumentoCollegato
{

    @XmlElement long   id
    @XmlElement String idDocumentoEsterno    // id del documento dell'applicativo esterno

    @XmlElement String tipoCollegamento
}
