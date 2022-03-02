package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.affarigenerali.ducd.entiAooUtility.EntiAooUtilitySoapBindingImpl
import it.finmatica.protocollo.integrazioni.EntiAooWSService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@CompileStatic
class EntiAooUtilityServiceImpl implements EntiAooUtilitySoapBindingImpl {
    @Autowired
    EntiAooWSService entiAooWSService

    @Override
    boolean checkDate(@WebParam(name = "data_input", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String dataInput) {
        return false
    }

    @Override
    String getMailEnte(@WebParam(name = "codice_amministrazione", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String codiceAmministrazione, @WebParam(name = "descrizione_amministrazione", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String descrizioneAmministrazione, @WebParam(name = "codice_aoo", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String codiceAoo, @WebParam(name = "descrizione_aoo", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String descrizioneAoo, @WebParam(name = "indirizzo_mail", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String indirizzoMail) {
        return entiAooWSService.getMailEnte(codiceAmministrazione, descrizioneAmministrazione, codiceAoo, descrizioneAoo, indirizzoMail)
    }

    @Override
    String getProtocolliDaRicevere(@WebParam(name = "inputXml", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String inputXml) {
        return entiAooWSService.getProtocolliDaRicevere(inputXml)
    }

    @Override
    String getProtocolli(@WebParam(name = "inputXml", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String inputXml) {
        return entiAooWSService.getProtocolli(inputXml)
    }

    @Override
    String getProtocollo(@WebParam(name = "anno", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") int anno, @WebParam(name = "numero", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") int numero, @WebParam(name = "tipoRegistro", targetNamespace = "http://protocolloUtility.ducd.affarigenerali.finmatica.it") String tipoRegistro) {
        return entiAooWSService.getProtocollo(anno, numero, tipoRegistro)
    }
}