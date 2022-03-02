package it.finmatica.protocollo.integrazioni.ws.dati

import javax.xml.bind.annotation.*

@XmlRootElement(name="unita")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class UnitaOrganizzativa {

	@XmlElement (required=true, nillable=false)
	String codice
	@XmlElement String descrizione

	@XmlElement long   progressivo
	@XmlElement String codiceOttica
	@XmlElement Date   dal
}
