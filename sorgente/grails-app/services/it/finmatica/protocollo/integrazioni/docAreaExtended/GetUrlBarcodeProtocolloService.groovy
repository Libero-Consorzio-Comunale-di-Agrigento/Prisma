package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class GetUrlBarcodeProtocolloService extends BaseDocumentoService implements DocAreaExtendedService {

    public static final String TAG_SERVER       = '[SERVER]'
    public static final String TAG_ID_DOCUMENTO = '[ID_DOCUMENTO]'
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    PreferenzeUtenteService preferenzeUtenteService

    @Value("\${finmatica.protocollo.jasper.jdbcNameGdm}")
    String jdbcNameGdm

    GetUrlBarcodeProtocolloService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'getUrlBarcodeProtocollo'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        String idDoc = getIdDocumento(xml)
        it.finmatica.protocollo.documenti.Protocollo protocollo
        if(!idDoc) {
            String anno = getAnno(xml)
            String numero = getNumero(xml)
            String tipoRegistro = getTipoRegistro(xml)
            protocollo = protocolloService.findByAnnoAndNumeroAndTipoRegistro(getInteger(anno),getInteger(numero),tipoRegistro)
        } else {
            protocollo = docAreaExtenedHelperService.getProtocolloFromId(Long.valueOf(idDoc))
        }
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        resp.errornumber = '0'
        if(protocollo) {
            resp.text = "/../jasperserver4/jasperservlet?project=jprotocollostampe&report=${preferenzeUtenteService.reportTimbro}&conn=${jdbcNameGdm}&ID_DOCUMENTO_PROTOCOLLO=${protocollo.idDocumentoEsterno}"
        } else {
            resp.MESSAGE = 'Documento non trovato'
            resp.EXCEPTION = new NullPointerException("Protocollo non trovato").toString()
            resp.errornumber = ErroriWsDocarea.ERRORE_INTERNO.codice
        }
        return toXml(resp)
    }

}
