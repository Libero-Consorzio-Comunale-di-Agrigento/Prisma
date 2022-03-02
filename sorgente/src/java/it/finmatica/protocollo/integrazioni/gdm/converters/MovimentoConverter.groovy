package it.finmatica.protocollo.integrazioni.gdm.converters

import it.finmatica.gestionedocumenti.integrazioni.gdm.Converter
import it.finmatica.protocollo.documenti.Protocollo
import org.apache.commons.lang.StringUtils

public class MovimentoConverter extends Converter<Object, String> {

    public static final MovimentoConverter INSTANCE = new MovimentoConverter();

    @Override
    public String convert(Object input) {

        if (input == null) {
            return "";
        }

        String movimento = (String) input;
        return StringUtils.substring(movimento, 0, 3);
    }


    public String convertFromOld(Object input) {

        if (input == null) {
            return "";
        }

        String movimento = (String) input;
        if (movimento == 'ARR') {
            return Protocollo.MOVIMENTO_ARRIVO
        } else if (movimento == 'INT') {
            return Protocollo.MOVIMENTO_INTERNO
        } else if (movimento == 'PAR') {
            return Protocollo.MOVIMENTO_PARTENZA
        }
        return ""
    }
}