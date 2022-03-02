package it.finmatica.protocollo.corrispondenti

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

@Service
class CorrispondenteMessaggioService {
    @Autowired
    CorrispondenteMessaggioRepository corrispondenteMessaggioRepository

    List<CorrispondenteMessaggio> getCorrispondenteMessaggio(Messaggio messaggio, String eMail) {
        return corrispondenteMessaggioRepository.getCorrispondentiMessaggio(messaggio, eMail)
    }
}