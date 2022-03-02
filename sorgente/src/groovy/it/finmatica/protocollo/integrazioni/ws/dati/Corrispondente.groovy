package it.finmatica.protocollo.integrazioni.ws.dati

import it.finmatica.protocollo.corrispondenti.TipoSoggetto

import javax.xml.bind.annotation.*

@XmlRootElement(name="corrispondente")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class Corrispondente {

	@XmlElement String  barcodeSpedizione
	@XmlElement String  cap
	@XmlElement String  codiceFiscale
	@XmlElement String  cognome
	@XmlElement String  comune
	@XmlElement boolean conoscenza = false

	@XmlElement String  denominazione
	@XmlElement String  email
	@XmlElement String  fax
	@XmlElement String  indirizzo
	@XmlElement String  tipoIndirizzo
	@XmlElement String  nome
	@XmlElement String  partitaIva
	@XmlElement String  provinciaSigla

	@XmlElement long tipoSoggettoSequenza
}
