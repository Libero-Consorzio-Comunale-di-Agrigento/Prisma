package it.finmatica.protocollo.integrazioni.ws.dati.response

import javax.xml.bind.annotation.XmlAccessType
import javax.xml.bind.annotation.XmlAccessorType
import javax.xml.bind.annotation.XmlElement
import javax.xml.bind.annotation.XmlRootElement
import javax.xml.bind.annotation.XmlType

@XmlRootElement(name="caricaProtocolloCompletoResponse")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class CaricaProtocolloCompletoResponse {

	@XmlElement String esito
	@XmlElement String messaggioErrore
	@XmlElement long   id
	@XmlElement String idDocumentoEsterno    // id del documento dell'applicativo esterno

	@XmlElement String url

}
