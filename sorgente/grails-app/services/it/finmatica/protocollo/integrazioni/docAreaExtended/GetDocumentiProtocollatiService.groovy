package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
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
class GetDocumentiProtocollatiService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ProtocolloWSService protocolloWSService

    GetDocumentiProtocollatiService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Documenti)
    }

    @Override
    String getXsdName() {
        return 'getDocumentiProtocollati'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Documenti resp = new Documenti()
        String classificazione = getClassificazione(xml)
        String fascicoloAnno = getFascicoloAnno(xml)
        String fascicoloNumero = getFascicoloNumero(xml)
        String oggetto = getOggetto(xml)
        Date dataDal = setAtBeginning(getDataDal(xml))
        Date dataAl = setAtEnd(getDataAl(xml))
        String anno = getAnno(xml)
        String numero = getNumero(xml)
        String tipoRegistro = getTipoRegistro(xml)
        String movimento
        String modalita = getModalita(xml)
        if(modalita) {
            switch (modalita) {
                case 'INT': movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO; break
                case 'PAR': movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_PARTENZA; break
                case 'ARR': movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_ARRIVO; break
            }
        }
        ProtocolloWSJPQLFilter jpqlFilter = new ProtocolloWSJPQLFilter()
        jpqlFilter.haClassificazione(classificazione)
        .haOggetto(oggetto)
        .haAnnoFascicolo(getInteger(fascicoloAnno))
        .haNumeroFascicolo(fascicoloNumero)
        .daData(dataDal)
        .aData(dataAl)
        .haAnno(getInteger(anno))
        .haNumero(getInteger(numero))
        .haTipoRegistro(tipoRegistro)
        .haModalita(movimento)
        .protocollati()
        resp.documenti = protocolloWSService.findProtocolliIdsByFilter(jpqlFilter).collect {new Documento(iddocumento: String.valueOf(it))}
        return toXml(resp)
    }



    @CompileDynamic
    Date getDataDal(Node node) {
        getDate(node.DATA_DAL?.text())
    }

    @CompileDynamic
    Date getDataAl(Node node) {
        getDate(node.DATA_AL?.text())
    }


}
