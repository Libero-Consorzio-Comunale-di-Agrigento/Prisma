package it.finmatica.protocollo

import groovy.transform.CompileStatic
import it.finmatica.affarigenerali.ducd.entiAooUtility.EntiAooUtilitySoapBindingImpl
import it.finmatica.affarigenerali.ducd.entiAooUtility.EntiAooUtilitySoapBindingImplService
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.GestisciFascicoliDocumento
import it.finmatica.affarigenerali.ducd.fascicoliSecondari.GestisciFascicoliDocumentoService
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.InserisciInTitolario
import it.finmatica.affarigenerali.ducd.inserisciInTitolario.InserisciInTitolarioService
import it.finmatica.affarigenerali.ducd.pec.PecSOAPImpl
import it.finmatica.affarigenerali.ducd.pec.PecSOAPImplService
import it.finmatica.affarigenerali.ducd.protocollaSoap.ProtocollaSOAPImpl
import it.finmatica.affarigenerali.ducd.protocollaSoap.ProtocollaSOAPImplService
import it.finmatica.protocollo.integrazioni.protocolloextended.ProtocolloExtendedService
import it.finmatica.protocollo.integrazioni.ws.DOCAREAProtoSoapV2
import it.finmatica.protocollo.integrazioni.ws.DocAreaAttachmentHandler
import it.finmatica.protocollo.integrazioni.ws.DocAreaExtendedWebServiceImpl
import it.finmatica.protocollo.integrazioni.ws.DocAreaProtoWebServiceImpl
import it.finmatica.protocollo.integrazioni.ws.EntiAooUtilityServiceImpl
import it.finmatica.protocollo.integrazioni.ws.GestisciFascicoliDocumentoServiceImpl
import it.finmatica.protocollo.integrazioni.ws.InserisciInTitolarioServiceImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocollaSoapServiceImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocolloCompletoWebService
import it.finmatica.protocollo.integrazioni.ws.ProtocolloCompletoWebServiceBaseImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocolloDUCDServiceImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocolloDocAreaMTOMService
import it.finmatica.protocollo.integrazioni.ws.ProtocolloDocAreaMTOMServiceImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocolloEmergenzaWebService
import it.finmatica.protocollo.integrazioni.ws.ProtocolloEmergenzaWebServiceImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocolloWebService
import it.finmatica.protocollo.integrazioni.ws.ProtocolloWebServiceImpl
import it.finmatica.protocollo.integrazioni.ws.ProtocolloWebServiceV2
import it.finmatica.protocollo.integrazioni.ws.si4cs.invio.NotificaInvioServiceImpl
import it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.NotificaRicezioneServiceImpl
import org.apache.cxf.Bus
import org.apache.cxf.binding.soap.SoapBindingConfiguration
import org.apache.cxf.interceptor.LoggingInInterceptor
import org.apache.cxf.interceptor.LoggingOutInterceptor
import org.apache.cxf.jaxws.EndpointImpl
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.multipart.MultipartResolver
import org.springframework.web.multipart.commons.CommonsMultipartResolver
import org.springframework.web.multipart.support.MultipartFilter
import org.springframework.web.multipart.support.StandardServletMultipartResolver

import javax.xml.ws.Endpoint

@CompileStatic
@Configuration
class WebServiceConfig {

    @Bean
    ProtocolloWebServiceImpl protocolloWebService() {
        return new ProtocolloWebServiceImpl()
    }

    @Bean
    ProtocolloEmergenzaWebServiceImpl protocolloEmergenzaWebService() {
        return new ProtocolloEmergenzaWebServiceImpl()
    }

    @Bean
    ProtocolloCompletoWebServiceBaseImpl protocolloCompletoWebService() {
        return new ProtocolloCompletoWebServiceBaseImpl()
    }

    @Bean
    DocAreaProtoWebServiceImpl docAreaProtoWebService() {
        return new DocAreaProtoWebServiceImpl()
    }

    @Bean
    DocAreaExtendedWebServiceImpl docAreaExtendedWebService() {
        return new DocAreaExtendedWebServiceImpl()
    }

    @Bean
    ProtocolloDocAreaMTOMServiceImpl protocolloDocAreaMTOMService() {
        return new ProtocolloDocAreaMTOMServiceImpl()
    }

    @Bean
    ProtocolloDUCDServiceImpl protocolloDUCDService() {
        return new ProtocolloDUCDServiceImpl()
    }

    @Bean
    EntiAooUtilityServiceImpl entiAooUtilityService() {
        return new EntiAooUtilityServiceImpl()
    }

    @Bean
    InserisciInTitolarioServiceImpl inserisciInTitolarioService() {
        return new InserisciInTitolarioServiceImpl()
    }

    @Bean
    GestisciFascicoliDocumentoServiceImpl gestisciFascicoliDocumentoService() {
        return new GestisciFascicoliDocumentoServiceImpl()
    }

    @Bean
    ProtocollaSoapServiceImpl protocollaSoapService() {
        return new ProtocollaSoapServiceImpl()
    }

    @Bean
    Endpoint protocolloWebServiceV2(Bus bus, ProtocolloWebServiceImpl protocolloWebService) {
        EndpointImpl endpoint = new EndpointImpl(bus, protocolloWebService);
        endpoint.setImplementorClass(ProtocolloWebServiceV2)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.publish("/protocollo/v2");
        return endpoint;
    }

    @Bean
    Endpoint protocolloWebServiceV1(Bus bus, ProtocolloWebServiceImpl protocolloWebService) {
        EndpointImpl endpoint = new EndpointImpl(bus, protocolloWebService);
        endpoint.setImplementorClass(ProtocolloWebService)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.publish("/protocollo");
        return endpoint;
    }

    @Bean
    Endpoint protocolloEmergenzaWebServiceV1(Bus bus, ProtocolloEmergenzaWebServiceImpl protocolloEmergenzaWebService) {
        EndpointImpl endpoint = new EndpointImpl(bus, protocolloEmergenzaWebService)
        endpoint.setImplementorClass(ProtocolloEmergenzaWebService)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.publish("/protocolloemergenza")
        return endpoint
    }

    @Bean
    Endpoint protocolloCompletoWebServiceV1(Bus bus, ProtocolloCompletoWebServiceBaseImpl protocolloCompletoWebService) {
        EndpointImpl endpoint = new EndpointImpl(bus, protocolloCompletoWebService)
        endpoint.setImplementorClass(ProtocolloCompletoWebService)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.publish("/protocolloCompleto")
        return endpoint
    }

    @Bean
    Endpoint docAreaProtoWebServiceV1(Bus bus, DocAreaProtoWebServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(DOCAREAProtoSoapV2)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.handlers.add(docAreaAttachmentHandler())
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/DOCAREAProtoSoap")
        return endpoint
    }

    @Bean
    Endpoint docAreaExtendedWebServiceV1(Bus bus, DocAreaExtendedWebServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(ProtocolloExtendedService)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.handlers.add(docAreaAttachmentHandler())
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/ProtocolloExtendedServicePort")
        return endpoint
    }

    @Bean
    Endpoint protocolloDocAreaMTOMServiceV1(Bus bus, ProtocolloDocAreaMTOMServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(ProtocolloDocAreaMTOMService)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/DOCAREAProtoSoapMTOM")
        return endpoint
    }

    @Bean
    Endpoint protocolloDucdServiceV1(Bus bus, ProtocolloDUCDServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(PecSOAPImpl)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/PecSOAPImpl")
        return endpoint
    }

    @Bean
    Endpoint entiAooUtilityServiceV1(Bus bus, EntiAooUtilityServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(EntiAooUtilitySoapBindingImpl)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/EntiAooUtilitySoapBindingImpl")
        return endpoint
    }

    @Bean
    Endpoint inserisciInTitolarioServiceV1(Bus bus, InserisciInTitolarioServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(InserisciInTitolario)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/inserisciInTitolarioSOAP")
        return endpoint
    }

    @Bean
    Endpoint gestisciFascicoliDocumentoServiceV1(Bus bus, GestisciFascicoliDocumentoServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(GestisciFascicoliDocumento)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/GestisciFascicoliDocumento")
        return endpoint
    }

    @Bean
    Endpoint protocollaSoapServiceV1(Bus bus, ProtocollaSoapServiceImpl serviceImpl) {
        EndpointImpl endpoint = new EndpointImpl(bus, serviceImpl)
        endpoint.setImplementorClass(ProtocollaSOAPImpl)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.inInterceptors.add(new LoggingInInterceptor())
        endpoint.inInterceptors.add(new LoggingOutInterceptor())
        endpoint.publish("/ProtocollaSOAPImpl")
        return endpoint
    }

    @Bean
    public MultipartResolver multipartResolver() {
        return new StandardServletMultipartResolver()
    }

    @Bean
    DocAreaAttachmentHandler docAreaAttachmentHandler() {
        new DocAreaAttachmentHandler()
    }

    @Bean
    NotificaRicezioneServiceImpl notificaRicezioneWebService() {
        return new NotificaRicezioneServiceImpl()
    }

    @Bean
    Endpoint notificaRicezioneService(Bus bus, NotificaRicezioneServiceImpl notificaRicezioneService) {
        EndpointImpl endpoint = new EndpointImpl(bus, notificaRicezioneService);
        endpoint.setImplementorClass(NotificaRicezioneServiceImpl)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: true))
        endpoint.publish("/creaMessaggioRicevutoSi4Cs")
        return endpoint;
    }

    @Bean
    NotificaInvioServiceImpl notificaInvioWebService() {
        return new NotificaInvioServiceImpl()
    }

    @Bean
    Endpoint notificaInvioService(Bus bus, NotificaInvioServiceImpl notificaInvioService) {
        EndpointImpl endpoint = new EndpointImpl(bus, notificaInvioService);
        endpoint.setImplementorClass(NotificaInvioServiceImpl)
        endpoint.setBindingConfig(new SoapBindingConfiguration(mtomEnabled: false))
        endpoint.publish("/aggiornaMessaggioInviatoSi4Cs")
        return endpoint;
    }
}
