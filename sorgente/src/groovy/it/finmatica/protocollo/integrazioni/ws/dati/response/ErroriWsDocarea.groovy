package it.finmatica.protocollo.integrazioni.ws.dati.response

/**
 * Enumerazione degli errori possibili.
 * Ogni errore ha un codice univoco ed una descrizione sommaria.
 * (copiato dai servizi DocArea)
 * 
 * @author esasdelli
 */
enum ErroriWsDocarea {
	SUCCESSO(0, "Esito positivo dell’operazione richiesta."),
	ERRORE_INTERNO(-1, "Errore nel codice del Web Services."),
	DST_INVALIDO(-2, "DST non valido. Il token DST non è corretto o potrebbe essere scaduto"),
	
	LOGIN_XML_INVALIDO(-3, "Errore in fase di  Login: il file XML di Login non è ben formato."),
	LOGIN_USERID_INVALIDA(-4, "Errore in fase di  Login: UserId non corretta."),
	LOGIN_PASSWORD_INVALIDA(-5, "Errore in fase di  Login: Password non corretta."),
	LOGIN_DB_IRRAGGIUNGIBILE(-6, "Errore in fase di  Login: Database non raggiungibile."),
	LOGIN_EMERGENZA(-7, "Errore in fase di  Login: Sistema in Emergenza."),
	LOGIN_INVALIDO (-8, "Errore in fase di Login: username o password invalidi."),
	ENTE_INESISTENTE(-9, "Errore in fase di Login: Ente non esistente."),
	
	IMPORTAZIONE_ERRORE(-50, "Errore in  fase di importazione del documento"),
	IMPORTAZIONE_FIRMA_INVALIDA(-51, "Errore in  fase di importazione del documento: Verifica della firma fallita"),
	IMPORTAZIONE_ALLEGATO_MANCANTE (-52, "Errore in  fase di importazione del documento: allegato mancante."),
	
	PROTOCOLLAZIONE_ERRORE(-100, "Errore in fase di protocollazione"),
	PROTOCOLLAZIONE_FASCICOLO_INESISTENTE(-101, "Errore in fase di protocollazione: Fascicolo inesistente"),
	PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE(-102, "Errore in fase di protocollazione: Documento inesistente"),
	PROTOCOLLAZIONE_TITOLARIO_CHIUSO(-103, "Errore in fase di protocollazione: Titolario chiuso"),
	PROTOCOLLAZIONE_TITOLARIO_INESISTENTE(-104, "Errore in fase di protocollazione: Titolario inesistente"),
	PROTOCOLLAZIONE_TITOLARIO_NON_TERMINALE(-105, "Errore in fase di protocollazione: Titolario non terminale"),
	PROTOCOLLAZIONE_OGGETTO_NON_COMPILATO(-106, "Errore in fase di protocollazione: Compilare l'oggetto"),
	PROTOCOLLAZIONE_DOCUMENTO_PRINCIPALE_ASSENTE(-107, "Errore in fase di protocollazione: Inserire un documento principale"),
	PROTOCOLLAZIONE_REFERENTE_INESISTENTE(-108, "Errore in fase di protocollazione: Referente inesistente"),
	PROTOCOLLAZIONE_TIPO_DOCUMENTO_INESISTENTE(-111, "Errore in fase di protocollazione: tipo documento inesistente"),
	
	// Miei errori:
	PROTOCOLLAZIONE_PARAMETRI_MANCANTI (-109, "Mancano dei parametri."), 
	PROTOCOLLAZIONE_XML_INVALIDO (-110, "L'xml passato non è valido secondo lo schema definito."),
	AGGIUNGI_ALLEGATO_ERRORE (-120, "Non è stato possibile salvare l'allegato."),
	UPDATE_FILE_ERRORE (-130, "Non è stato possibile salvare il file principale."),
	ISTANZIA_PROTOCOLLO_ERRORE (-140, "Non è stato possibile accedere al protocollo.")

	
	private int codice
	private String messaggio

	private ErroriWsDocarea(int codice, String messaggio) {
		this.codice = codice
		this.messaggio = messaggio
	}

	int getCodice() {
		return codice
	}

	String getMessaggio() {
		return messaggio
	}
}
