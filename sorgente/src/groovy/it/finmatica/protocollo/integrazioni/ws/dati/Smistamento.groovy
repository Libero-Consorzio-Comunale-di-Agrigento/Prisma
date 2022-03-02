package it.finmatica.protocollo.integrazioni.ws.dati

import javax.xml.bind.annotation.*

@XmlRootElement(name="smistamento")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType
class Smistamento {

	@XmlType(name = "tipoSmistamento")
	@XmlEnum
	enum TipoSmistamento {

		CONOSCENZA,
		COMPETENZA

		String value() {
			return name()
		}

		static TipoSmistamento fromValue(String v) {
			return valueOf(v)
		}

	}

	@XmlElement  Date   dataAssegnazione
	@XmlElement  Date   dataEsecuzione
	@XmlElement  Date   dataPresaInCarico
	@XmlElement  Date   dataSmistamento

	@XmlElement  String  note
	@XmlElement  String  noteUtente

	@XmlElement  TipoSmistamento tipoSmistamento

	@XmlElement Soggetto utenteAssegnatario    // utente scelto all'inizio o in fase di assegnazione
	@XmlElement Soggetto utenteEsecuzione      // utente che eseguiSmistamenti lo smistamento
	@XmlElement Soggetto utentePresaInCarico   // che prende in carico lo smistamento
	@XmlElement Soggetto utenteTrasmissione    // utente di sessione

	@XmlElement UnitaOrganizzativa unitaSmistamento   // unità scelta o nel caso di componente è l'unità di appartenenza
	@XmlElement UnitaOrganizzativa unitaTrasmissione  // creazione: unità protocollante
}
