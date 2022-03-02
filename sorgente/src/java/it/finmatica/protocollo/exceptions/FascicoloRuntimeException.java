package it.finmatica.protocollo.exceptions;

public class FascicoloRuntimeException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	public FascicoloRuntimeException(String message, Throwable cause) {
		super(message, cause);
	}

	public FascicoloRuntimeException(String message) {
		super(message);
	}

	public FascicoloRuntimeException(Throwable cause) {
		super(cause);
	}
}
