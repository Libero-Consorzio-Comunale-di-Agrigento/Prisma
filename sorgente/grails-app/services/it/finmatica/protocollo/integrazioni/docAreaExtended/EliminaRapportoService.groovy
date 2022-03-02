package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
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
@CompileStatic
class EliminaRapportoService extends BaseDocumentoService implements DocAreaExtendedService {

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
    PrivilegioUtenteService privilegioUtenteService


    EliminaRapportoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'delRapporto'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        Corrispondente corr = corrispondenteService.findOne(idDocumento)
        it.finmatica.protocollo.documenti.Protocollo protocollo = corr.protocollo
        if(protocollo) {
            boolean protocolloInterno = protocollo.movimento == it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO
            Set<Corrispondente> corrispondenti = protocollo.corrispondenti
            Set<Corrispondente> altriCorrispondenti = corrispondenti.findAll {
                it.id != idDocumento
            }
            boolean isErap = privilegioUtenteService.utenteHaPrivilegio('ERAP')
            boolean isErapBlc = privilegioUtenteService.utenteHaPrivilegio('ERAPBLC')
            // si può fare se il protocollo non è protocollato OPPURE se è interno o ci sono altri corrispondenti E l'utente ha privilegio ERAP con protocollo bloccato OPPURE ERAPBLC
            if (!protocollo.protocollato || ((protocolloInterno || altriCorrispondenti) && (isErap && !protocollo.bloccato || isErapBlc))) {
                resp.setRESULT(ResultStatus.OK.name())
                corrispondenti.removeAll { it.id == idDocumento }
                corrispondenteService.salva(protocollo, corrispondenti.toList().toDTO() as List<CorrispondenteDTO>)
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Impossibile eliminare rapporto; non rispettate le precondizioni')
            }
            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Id documento assente o protocollo inesistente')
        }
    }

}
