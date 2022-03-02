package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.context.request.RequestAttributes
import org.springframework.web.context.request.RequestContextHolder
import org.springframework.web.filter.RequestContextFilter

import javax.xml.namespace.QName
import javax.xml.soap.AttachmentPart
import javax.xml.soap.SOAPMessage
import javax.xml.ws.handler.MessageContext
import javax.xml.ws.handler.soap.SOAPHandler
import javax.xml.ws.handler.soap.SOAPMessageContext

@CompileStatic
class DocAreaAttachmentHandler extends RequestContextFilter implements SOAPHandler<SOAPMessageContext> {

    public static final String ATTACHMENT_ATTRIBUTE = "docareaattachment"
    @Override
    Set<QName> getHeaders() {
        return null
    }

    @Override
    boolean handleMessage(SOAPMessageContext soapMessageContext) {
        SOAPMessage message = soapMessageContext.getMessage()
        Iterator<AttachmentPart> attachments = message.getAttachments()
        int i = 0
        while(attachments.hasNext()) {
            RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes()
            requestAttributes.setAttribute(ATTACHMENT_ATTRIBUTE,attachments.next(),i++)
        }
        return true
    }

    @Override
    boolean handleFault(SOAPMessageContext soapMessageContext) {
        return false
    }

    @Override
    void close(MessageContext messageContext) {
    }
}
