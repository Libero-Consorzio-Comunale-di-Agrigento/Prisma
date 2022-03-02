package it.finmatica.protocollo.integrazioni.ws.dati.response

import javax.xml.bind.annotation.*


@XmlRootElement(name="creaLetteraResponse")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class CreaLetteraResponse {

	@XmlElement String esito
	@XmlElement String messaggioErrore

	@XmlElement long   id
	@XmlElement String idDocumentoEsterno    // id del documento dell'applicativo esterno

	@XmlElement String url
}
