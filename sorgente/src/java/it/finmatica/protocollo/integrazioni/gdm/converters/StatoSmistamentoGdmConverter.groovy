package it.finmatica.protocollo.integrazioni.gdm.converters;

import it.finmatica.gestionedocumenti.integrazioni.gdm.Converter;
import it.finmatica.protocollo.smistamenti.Smistamento;

public class StatoSmistamentoGdmConverter extends Converter<Object, String> {

    public static final StatoSmistamentoGdmConverter INSTANCE = new StatoSmistamentoGdmConverter();

    @Override
    public String convert(Object input) {

        if (input == null) {
            return "";
        }

        String statoSmistamento = (String) input;
        if ("N".equals(statoSmistamento)) {
            return Smistamento.CREATO;
        } else if ("R".equals(statoSmistamento)) {
            return Smistamento.DA_RICEVERE;
        } else if ("C".equals(statoSmistamento)) {
            return Smistamento.IN_CARICO;
        } else if ("E".equals(statoSmistamento)) {
            return Smistamento.ESEGUITO;
        } else if ("F".equals(statoSmistamento)) {
            return Smistamento.STORICO;
        } else {
            return "";
        }
    }
}