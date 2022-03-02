package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.InserisciInTitolario
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.ParametriIngresso
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.ParametriUscita
import it.finmatica.protocollo.integrazioni.InserisciInTitolarioHelperService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@CompileStatic
class InserisciInTitolarioServiceImpl implements InserisciInTitolario {

    @Autowired
    InserisciInTitolarioHelperService inserisciInTitolarioHelperService

    @Override
    ParametriUscita aggiungiAFascicolo(@WebParam(name = "in", targetNamespace = "") ParametriIngresso parametriIngresso) {
        return inserisciInTitolarioHelperService.aggiungiAFascicolo(parametriIngresso)
    }

    @Override
    ParametriUscita creaFascicolo(@WebParam(name = "in", targetNamespace = "") ParametriIngresso parametriIngresso) {
        return inserisciInTitolarioHelperService.creaFascicolo(parametriIngresso)
    }
}
