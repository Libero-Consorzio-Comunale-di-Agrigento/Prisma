package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.GestisciFascicoliDocumento
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.ParametriIngresso
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.ParametriUscita
import it.finmatica.protocollo.integrazioni.GestisciFascicoliSecondariHelperService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@CompileStatic
class GestisciFascicoliDocumentoServiceImpl implements GestisciFascicoliDocumento {

    @Autowired
    GestisciFascicoliSecondariHelperService gestisciFascicoliSecondariHelperService

    @Override
    ParametriUscita aggiungiFascicoliSecondari(@WebParam(name = "in", targetNamespace = "http://fascicoli.ducd.affarigenerali.finmatica.it") ParametriIngresso parametriIngresso) {
        return gestisciFascicoliSecondariHelperService.aggiungiFascicoliSecondari(parametriIngresso)
    }
}
