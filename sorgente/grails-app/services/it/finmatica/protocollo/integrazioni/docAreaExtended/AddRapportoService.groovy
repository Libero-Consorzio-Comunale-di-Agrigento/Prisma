package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.corrispondenti.TipoSoggettoRepository
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
class AddRapportoService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    TipoSoggettoRepository tipoSoggettoRepository

    private JAXBContext jcInput

    AddRapportoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
        jcInput = JAXBContext.newInstance(AddRapporto)
    }

    @Override
    String getXsdName() {
        return 'addRapporto'
    }

    @Override
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        AddRapporto addR = jcInput.createUnmarshaller().unmarshal(new StringReader(toXmlString(xml))) as AddRapporto
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): null
        if(protocollo) {
            RapportWS rapp = addR.rapporto
            CorrispondenteDTO corr = new CorrispondenteDTO()
            def persona = rapp.persona
            if (rapp.amministrazione) {
                corr.codiceAmministrazione = rapp.amministrazione.codiceAmministrazione ?: ''
                corr.denominazione = rapp.amministrazione.denominazione?.trim() ?: ''
                corr.email = rapp.amministrazione.indirizzoTelematico.content?.trim() ?: ''
                corr.tipoSoggetto = tipoSoggettoRepository.findOne(2l).toDTO() as TipoSoggettoDTO
                corr.tipoIndirizzo = 'AMM'
            } else if (persona) {
                corr = docAreaExtenedHelperService.trovaPersona(persona)
            }
            corr.tipoCorrispondente = addR.tiporapporto?.trim() ?: ''
            Corrispondente nuovo = corrispondenteService.salvaCorrispondente(corr,protocollo, false, ignoraCompetenze)
            protocollo.save()
            Result resp = new Result()
            if(nuovo) {
                resp.id = nuovo.id
            }
            resp.setRESULT(ResultStatus.OK.name())

            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Protocollo non trovato')
        }
    }
}
