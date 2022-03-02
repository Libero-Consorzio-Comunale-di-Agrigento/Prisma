package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.affarigenerali.ducd.protocollaSoap.ParametriIngresso
import it.finmatica.affarigenerali.ducd.protocollaSoap.ParametriUscita
import it.finmatica.affarigenerali.ducd.protocollaSoap.ProtocollaSOAPImpl
import it.finmatica.protocollo.integrazioni.ProtocollaWSHelperService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@CompileStatic
class ProtocollaSoapServiceImpl implements ProtocollaSOAPImpl {

    @Autowired
    ProtocollaWSHelperService protocollaWSHelperService

    @Override
    ParametriUscita protocolla(@WebParam(name = "in", targetNamespace = "http://protocolla.ducd.affarigenerali.finmatica.it") ParametriIngresso parametriIngresso) {
        return protocollaWSHelperService.protocolla(parametriIngresso)
    }
}
