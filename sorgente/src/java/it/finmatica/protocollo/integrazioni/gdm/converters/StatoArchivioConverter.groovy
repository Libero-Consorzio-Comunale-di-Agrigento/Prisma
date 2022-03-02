package it.finmatica.protocollo.integrazioni.gdm.converters;

import it.finmatica.gestionedocumenti.integrazioni.gdm.Converter;
import it.finmatica.protocollo.documenti.Protocollo;

public class StatoArchivioConverter extends Converter<Object, String> {

    public static final StatoArchivioConverter INSTANCE = new StatoArchivioConverter();

    @Override
    public String convert(Object input) {
        if (input == null) {
            return "";
        }
        String stato = (String) input;
        if (Protocollo.StatoArchivio.ARCHIVIO.equals(stato)) {
            return "3";
        } else if (Protocollo.StatoArchivio.CORRENTE.equals(stato)) {
            return "1";
        } else if (Protocollo.StatoArchivio.DEPOSITO.equals(stato)) {
            return "2";
        } else {
            return "";
        }
    }
}