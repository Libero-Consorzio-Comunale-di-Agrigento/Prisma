package it.finmatica.protocollo.documenti.titolario

import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Service
@Transactional
class DocumentoTitolarioService {

    @Autowired
    private DocumentoTitolarioRepository documentoTitolarioRepository

    DocumentoTitolario getDocumentoTitolario(Long idDocumento, Long idFascicolo, Long idClassificazione) {
        documentoTitolarioRepository.getDocumentoTitolario(idDocumento, idFascicolo, idClassificazione)
    }

}
