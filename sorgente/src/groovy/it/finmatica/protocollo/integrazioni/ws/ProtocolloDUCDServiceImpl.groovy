package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.affarigenerali.ducd.pec.ParametriIngresso
import it.finmatica.affarigenerali.ducd.pec.ParametriIngressoPG
import it.finmatica.affarigenerali.ducd.pec.ParametriUscita
import it.finmatica.affarigenerali.ducd.pec.PecSOAPImpl
import it.finmatica.protocollo.integrazioni.DucdHelperService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@CompileStatic
class ProtocolloDUCDServiceImpl implements PecSOAPImpl {
    @Autowired
    DucdHelperService ducdHelperService

    @Override
    ParametriUscita invioPecPG(@WebParam(name = "in", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it") ParametriIngressoPG parametriIngressoPG) {
        return ducdHelperService.invioPecPG(parametriIngressoPG)
    }

    @Override
    ParametriUscita invioPec(@WebParam(name = "in", targetNamespace = "http://pec.ducd.affarigenerali.finmatica.it") ParametriIngresso parametriIngresso) {
        return ducdHelperService.invioPec(parametriIngresso)
    }
}
