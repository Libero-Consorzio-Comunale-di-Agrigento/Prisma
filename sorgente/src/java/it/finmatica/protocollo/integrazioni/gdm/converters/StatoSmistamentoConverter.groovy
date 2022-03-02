package it.finmatica.protocollo.integrazioni.gdm.converters;

import it.finmatica.gestionedocumenti.integrazioni.gdm.Converter;
import it.finmatica.protocollo.smistamenti.Smistamento;

public class StatoSmistamentoConverter extends Converter<Object, String> {

    public static final StatoSmistamentoConverter INSTANCE = new StatoSmistamentoConverter();

    @Override
    public String convert(Object input) {

        if (input == null) {
            return "";
        }

        String statoSmistamento = (String) input;
        if (Smistamento.CREATO.equals(statoSmistamento)) {
            return "N";
        } else if (Smistamento.DA_RICEVERE.equals(statoSmistamento)) {
            return "R";
        } else if (Smistamento.IN_CARICO.equals(statoSmistamento)) {
            return "C";
        } else if (Smistamento.ESEGUITO.equals(statoSmistamento)) {
            return "E";
        } else if (Smistamento.STORICO.equals(statoSmistamento)) {
            return "F";
        } else {
            return "";
        }
    }
}