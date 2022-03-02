package it.finmatica.protocollo.integrazioni.ws.dati


import javax.xml.bind.annotation.*

@XmlRootElement(name="protocollo")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
@XmlSeeAlso([ProtocolloCompleto])
class Protocollo {

	@XmlType(name = "movimento")
	@XmlEnum
	enum Movimento {

		ARRIVO,
		PARTENZA,
		INTERNO

		String value() {
			return name()
		}

		static Movimento fromValue(String v) {
			return valueOf(v)
		}

	}

	//@XmlElement(required=true, nillable=false) String tipo

	@XmlElement String 		tipo
	@XmlElement String 		schema
	@XmlElement String 		classificazione

	@XmlElement Movimento 	movimento
	@XmlElement boolean  	riservato

	@XmlElement Date	dataRedazione

	@XmlElement String numeroFascicolo
	@XmlElement int    annoFascicolo

	@XmlElement long   id
    @XmlElement String idRiferimento    // id del documento dell'applicativo esterno
	@XmlElement (required = false, nillable = true) Integer numero
	@XmlElement (required = false, nillable = true) Integer   anno
	@XmlElement (required = false, nillable = true) Date 	  data
	@XmlElement (required = false, nillable = true) String registro

	@XmlElement(required=true, nillable=false)
	String oggetto
	@XmlElement String note
	@XmlElement String statoFlusso

	//@XmlElement Soggetto redattore

	@XmlElement(required = false, nillable = true) List<StatoProtocollo> storico

    @XmlElement Allegato allegatoPrincipale

	@XmlElement(required=true, nillable=false)
	UnitaOrganizzativa unitaProtocollante
	@XmlElement List<Corrispondente> corrispondenti

	@XmlElement List<Smistamento> 	 smistamenti
	@XmlElement List<Allegato> allegati
	@XmlElement List<DocumentoCollegato> collegati

}
