package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic

@CompileStatic
interface DocAreaExtendedService {

    /**
     * Restituisce il nome dell'xsd da usare per la validazione
     * @return il nome dell'XSD da usare per la validazione, o <code>null</code> se non richiede validazione
     */
    String getXsdName()

    String execute(String user, Node xml, boolean ignoraCompetenze)

}