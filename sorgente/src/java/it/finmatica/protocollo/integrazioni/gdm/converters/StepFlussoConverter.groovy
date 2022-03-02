package it.finmatica.protocollo.integrazioni.gdm.converters

import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.Protocollo

@Slf4j
public class StepFlussoConverter {

    public static final StepFlussoConverter INSTANCE = new StepFlussoConverter();

    String convert(String input, String movimento) {

        if (input == null) {
            return "";
        }

        String step = (String) input;
        if (Protocollo.STEP_REDAZIONE.equals(step)) {
            return "REDAZIONE";
        } else if (Protocollo.STEP_DA_INVIARE.equals(step)) {
            if (Protocollo.MOVIMENTO_PARTENZA.equals(movimento)) {
                return "DAINVIARE";
            } else {
                return "DAGESTIRE";
            }
        } else if (Protocollo.STEP_DIRIGENTE.equals(step)) {
            return "DIRIGENTE";
        } else if (Protocollo.STEP_INVIATO.equals(step) || Protocollo.STEP_INTERMEDIO.equals(step)) {
            if (Protocollo.MOVIMENTO_PARTENZA.equals(movimento)) {
                return "INVIATO";
            } else {
                return "CONCLUSO";
            }
        } else if (Protocollo.STEP_REVISORE.equals(step)) {
            return "REVISORE";
        } else if (Protocollo.STEP_FUNZIONARIO.equals(step)) {
            return "FUNZIONARIO";
        } else if (Protocollo.STEP_PROTOCOLLO.equals(step)) {
            return "PROTOCOLLO";
        } else {
            log.error("Non è stato possibile trovare lo step: " + step);
            return "";
        }
    }
}