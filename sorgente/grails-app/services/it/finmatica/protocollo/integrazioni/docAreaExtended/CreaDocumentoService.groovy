package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.Attore
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class CreaDocumentoService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    So4UnitaPubbService so4UnitaPubbService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloGestoreCompetenze protocolloGestoreCompetenze


    CreaDocumentoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService, schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'creaDocumento'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        it.finmatica.protocollo.documenti.Protocollo protocollo = new it.finmatica.protocollo.documenti.Protocollo()
        protocollo.tipoProtocollo = dizionariRepository.getTipoProtocollo(CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codice)
        String classificazione = getClassificazione(xml)
        protocollo.classificazione = classificazioneService.findByCodice(classificazione)
        String fascicoloAnno = getFascicoloAnno(xml)
        String fascicoloNumero = getFascicoloNumero(xml)
        if(fascicoloAnno && fascicoloNumero) {
            protocollo.fascicolo = fascicoloRepository.getFascicolo(protocollo.classificazione.id,getInteger(fascicoloAnno),fascicoloNumero)
        }
        protocollo.oggetto = getOggetto(xml)
        protocollo.note = getNote(xml)
        String amministrazione = getAmministrazione(xml)
        String aoo = getAoo(xml)
        protocollo.ente = dizionariRepository.findEnteByCodiceAndAoo(amministrazione,aoo)
        String modalita = getModalita(xml)
        switch(modalita) {
            case 'INT': protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO; break
            case 'PAR': protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_PARTENZA;break
            case 'ARR': protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_ARRIVO; break
        }
        setTipoDocumento(xml,protocollo)
        String unitaProtocollante = getUnitaProtocollante(xml)
        List so4UnitaPubbs = so4UnitaPubbService.cercaUnitaPubb(amministrazione, Impostazioni.OTTICA_SO4.valore)
        So4UnitaPubb up = so4UnitaPubbs.find {it.codice == unitaProtocollante}
        DocumentoSoggetto unitaProt = new DocumentoSoggetto()
        unitaProt.unitaSo4 = up
        unitaProt.tipoSoggetto = TipoSoggetto.UO_PROTOCOLLANTE
        unitaProt.attivo = true
        protocollo.addToSoggetti(unitaProt)
        protocolloService.salva(protocollo,true,true,ignoraCompetenze,false)
        Attore att = new Attore(utenteAd4: springSecurityService.currentUser)
        protocolloGestoreCompetenze.assegnaCompetenze(protocollo,null,att,true,true,true,null)
        resp.id = protocollo.id.toString()
        return toXml(resp)
    }
}
