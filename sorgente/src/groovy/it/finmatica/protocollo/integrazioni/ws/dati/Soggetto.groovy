package it.finmatica.protocollo.integrazioni.ws.dati

import javax.xml.bind.annotation.*

@XmlRootElement(name="soggetto")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class Soggetto {
	@XmlElement String utenteAd4
	@XmlElement String niAs4
	@XmlElement String nome
	@XmlElement String cognome
	@XmlElement String codiceFiscale
}
