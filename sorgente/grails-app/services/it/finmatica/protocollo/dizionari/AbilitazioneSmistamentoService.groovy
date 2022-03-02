package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.smistamenti.SmistamentoRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional(readOnly = true)
@CompileStatic
@Service
class AbilitazioneSmistamentoService {
    @Autowired
    SmistamentoRepository smistamentoRepository

    public List<AbilitazioneSmistamento> getAbilitazioneSmistamento(String tipoSmistamento, String statoSmistamento, String azione) {
        return smistamentoRepository.getAbilitazioneSmistamento(tipoSmistamento, statoSmistamento, azione)
    }
}
