package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.titolario.ClassificazioneJPQLFilter
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class GetClassificheService extends BaseService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService


    GetClassificheService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService) {
        super(docAreaExtenedHelperService)
        jc = JAXBContext.newInstance(Classifiche)
    }

    @Override
    String getXsdName() {
        return 'getClassifiche'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Classifiche resp = new Classifiche()
        String codice = getCodice(xml)
        String descrizione = getDescrizione(xml)
        String amministrazione = getAmministrazione(xml)
        String aoo = getAoo(xml)
        boolean contenitoreDocumenti = getContenitoreDocumenti(xml)
        boolean valida = getValida(xml)
        ClassificazioneJPQLFilter filter = new ClassificazioneJPQLFilter()
        .haCodiceLike(codice)
        .haDescrizione(descrizione)
        .haCodiceAmministrazione(amministrazione)
        .haCodiceAmministrazione(aoo)
        if(contenitoreDocumenti) {
            filter.contenitoreDocumenti()
        }
        if(valida) {
            filter.valida()
        }
        resp.classifica = classificazioneService.findByFilter(filter).collect {toWs(it)}
        return toXml(resp)
    }

    private Classifica toWs(Classificazione classificazione) {
        Classifica cl = new Classifica()
        cl.iddocumento = String.valueOf(classificazione.id)
        cl.classcod = classificazione.codice
        cl.classdal = formatDate(classificazione.dal)
        cl.classal = formatDate(classificazione.al)
        cl.descrizione = classificazione.descrizione
        cl.datacreazione = formatDate(classificazione.dateCreated)
        cl.contenitoredocumenti = classificazione.contenitoreDocumenti ? 'Y':'N'
        return cl
    }


    @CompileDynamic
    String getCodice(Node node) {
        node.CLASS_COD?.text()
    }

    @CompileDynamic
    String getDescrizione(Node node) {
        node.DESCRIZIONE?.text()
    }

    @CompileDynamic
    String getAmministrazione(Node node) {
        node.CODICE_AMMINISTRAZIONE?.text()
    }

    @CompileDynamic
    String getAoo(Node node) {
        node.CODICE_AOO?.text()
    }

    @CompileDynamic
    boolean getContenitoreDocumenti(Node node) {
        def text = node.CONTENITORE_DOCUMENTI?.text()
        return text == 'Y'
    }

    @CompileDynamic
    boolean getValida(Node node) {
        def text = node.VALIDA?.text()
        return text != 'N'
    }


}
