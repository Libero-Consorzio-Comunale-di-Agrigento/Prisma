package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.ProtocolloWSJPQLFilter
import it.finmatica.protocollo.documenti.ProtocolloWSService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class GetDocumentiNonProtocollatiService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ProtocolloWSService protocolloWSService

    GetDocumentiNonProtocollatiService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Documenti)
    }

    @Override
    String getXsdName() {
        return 'getDocumentiNonProtocollati'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Documenti resp = new Documenti()
        String classificazione = getClassificazione(xml)
        String fascicoloAnno = getFascicoloAnno(xml)
        String fascicoloNumero = getFascicoloNumero(xml)
        String oggetto = getOggetto(xml)
        ProtocolloWSJPQLFilter jpqlFilter = new ProtocolloWSJPQLFilter()
        jpqlFilter.haClassificazione(classificazione)
                .haOggetto(oggetto)
                .haAnnoFascicolo(getInteger(fascicoloAnno))
                .haNumeroFascicolo(fascicoloNumero)
                .nonProtocollati()
        resp.documenti = protocolloWSService.findProtocolliIdsByFilter(jpqlFilter).collect {new Documento(iddocumento: String.valueOf(it))}
        return toXml(resp)
    }




}
