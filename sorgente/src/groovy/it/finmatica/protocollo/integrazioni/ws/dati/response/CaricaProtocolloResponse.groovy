package it.finmatica.protocollo.integrazioni.ws.dati.response

import it.finmatica.protocollo.integrazioni.ws.dati.Protocollo
import javax.xml.bind.annotation.*

@XmlRootElement(name="caricaProtocolloResponse")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class CaricaProtocolloResponse {

	@XmlElement String esito
	@XmlElement String messaggioErrore

	@XmlElement Protocollo protocollo
}
