package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class AggiungiSmistamentoService extends BaseDocumentoService implements DocAreaExtendedService {

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
    SmistamentoService smistamentoService

    AggiungiSmistamentoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'addSmistamento'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): null
        if(protocollo) {
            String unitaSmistamento = getUnitaSmistamento(xml)
            if (unitaSmistamento) {
                Ente e = dizionariRepository.findEnteById(1L)
                List so4UnitaPubbs = so4UnitaPubbService.cercaUnitaPubb(e.amministrazione.codice, Impostazioni.OTTICA_SO4.valore)
                So4UnitaPubb up = so4UnitaPubbs.find { it.codice == unitaSmistamento }
                if(up) {
                    it.finmatica.protocollo.smistamenti.SmistamentoDTO smistamento = new it.finmatica.protocollo.smistamenti.SmistamentoDTO()
                    smistamento.unitaSmistamento = so4UnitaPubbs.find { it.codice == unitaSmistamento }?.toDTO() as So4UnitaPubbDTO
                    smistamento.tipoSmistamento = getTipoSmistamento(xml)
                    smistamento.statoSmistamento = it.finmatica.protocollo.smistamenti.Smistamento.CREATO
                    smistamentoService.salva(protocollo,[smistamento])
                    resp.iddocumento = smistamento.id
                    resp.id = resp.iddocumento
                } else {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Unità non trovata')
                }

            }
            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Protocollo non trovato')
        }


    }

    @CompileDynamic
    String getUnitaSmistamento(Node node) {
        node.UNITA_SMISTAMENTO?.text()
    }

    @CompileDynamic
    String getTipoSmistamento(Node node) {
        node.TIPO_SMISTAMENTO?.text()
    }

}
