package it.finmatica.protocollo.utils

import groovy.transform.CompileStatic

import java.util.regex.Matcher
import java.util.regex.Pattern

@CompileStatic
class StringUtils {

    public static synchronized String cleanTextContent(String text) {

         // erases all the ASCII control characters
        text = text.replaceAll("[\\p{Cntrl}&&[^\r\n\t]]", "");

        return text.trim();
    }

    public static synchronized boolean checkWords(String testo, String chiavi_ricerca, String separatore) {
        boolean ret = false
        String[] MATCHES = chiavi_ricerca.toLowerCase().split(separatore)
        if (MATCHES.length > 0) {
            String REGEX = ""
            for (int i = 0; i < MATCHES.length - 1; i++) {
                REGEX += MATCHES[i] + "|"
            }
            REGEX += MATCHES[MATCHES.length - 1]

            Pattern p = Pattern.compile(REGEX)
            Matcher m = p.matcher(testo.toLowerCase())
            ret = m.find()
        }
        return ret
    }
}