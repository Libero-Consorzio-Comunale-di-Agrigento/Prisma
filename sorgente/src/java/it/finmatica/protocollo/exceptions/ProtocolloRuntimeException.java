package it.finmatica.protocollo.exceptions;

public class ProtocolloRuntimeException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	public static final String ERRORE_MODIFICA_CONCORRENTE = "Un utente ha già modificato il dato.";

	public ProtocolloRuntimeException(String message, Throwable cause) {
		super(message, cause);
	}

	public ProtocolloRuntimeException(String message) {
		super(message);
	}

	public ProtocolloRuntimeException(Throwable cause) {
		super(cause);
	}
}
