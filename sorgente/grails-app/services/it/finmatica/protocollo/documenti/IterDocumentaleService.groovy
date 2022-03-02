package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.integrazioni.si4cs.MemoRicevutiGDM
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional
@Service
class IterDocumentaleService {

    @Autowired
    So4Repository so4Repository


    Documento getDocumentoPerSmistamento(Long idDocumento) {
        return Documento.get(idDocumento)
    }

    So4UnitaPubb getUnitaByCodice(String codiceUO) {
        return so4Repository.getUnitaByCodiceSo4(codiceUO)
    }

    String getLinkOldMsg(Long id){
        return MemoRicevutiGDM.get(id).linkDocumento
    }


}


