package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.protocollo.titolario.FascicoloService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
class CreaFascicoloService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository

    @Autowired
    FascicoloService fascicoloService


    CreaFascicoloService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService,@Autowired So4Repository so4Repository,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, so4Repository, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'creaFascicolo'
    }

    @Override
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        Fascicolo fascicolo = new Fascicolo()
        def classificazione = classificazioneService.findByCodice(getClassificazione(xml))
        fascicolo.classificazione = classificazione
        fascicolo.anno = getInteger(getFascicoloAnno(xml))
        String fascicoloAnnoPadre = getFascicoloAnnoPadre(xml)
        String fascicoloNumeroPadre = getFascicoloNumeroPadre(xml)
        if(fascicoloAnnoPadre && fascicoloNumeroPadre) {
            fascicolo.idFascicoloPadre = fascicoloRepository.getFascicolo(fascicolo.classificazione.id,getInteger(fascicoloAnnoPadre),fascicoloNumeroPadre)?.id
        }
        propComuni(xml, fascicolo)
        Map soggetti = [:]
        for(docSog in fascicolo.soggetti) {
            soggetti[docSog.tipoSoggetto] = ['unita':docSog.unitaSo4.toDTO()]
        }
        fascicolo = fascicoloService.salva(fascicolo.toDTO() as FascicoloDTO,soggetti,null,true,false,[])?.domainObject
        resp.id = fascicolo.id.toString()
        resp.fascicolonumero = fascicolo.numero
        resp.fascicoloanno = String.valueOf(fascicolo.anno)
        resp.classcod = classificazione?.codice
        return toXml(resp)
    }

    @CompileDynamic
    String getFascicoloAnnoPadre(Node node) {
        node.FASCICOLO_ANNO_PADRE?.text()
    }

    @CompileDynamic
    String getFascicoloNumeroPadre(Node node) {
        node.FASCICOLO_NUMERO_PADRE?.text()
    }

}
