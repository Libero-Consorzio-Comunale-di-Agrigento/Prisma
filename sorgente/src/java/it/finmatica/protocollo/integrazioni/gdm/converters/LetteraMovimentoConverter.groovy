package it.finmatica.protocollo.integrazioni.gdm.converters;

import it.finmatica.gestionedocumenti.integrazioni.gdm.Converter;
import it.finmatica.protocollo.documenti.Protocollo;

public class LetteraMovimentoConverter extends Converter<Object, String> {

    public static final LetteraMovimentoConverter INSTANCE = new LetteraMovimentoConverter();

    @Override
    public String convert(Object input) {

        if (input == null) {
            return "";
        }

        String movimento = (String) input;
        if (Protocollo.MOVIMENTO_PARTENZA.equals(movimento)) {
            return "USCITA";
        } else {
            return "INTERNA";
        }
    }
}