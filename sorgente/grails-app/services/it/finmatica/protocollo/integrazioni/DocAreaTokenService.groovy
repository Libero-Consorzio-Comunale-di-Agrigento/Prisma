package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Ente
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Service
@Transactional
class DocAreaTokenService {

    @Autowired private DocAreaTokenRepository docAreaTokenRepository

    DocAreaToken save (DocAreaToken value) {
        if(!value.token) {
            value.token = UUID.randomUUID().toString()
        }
        return docAreaTokenRepository.save(value)
    }

    Ente findEnteByCodice(String codice) {
        docAreaTokenRepository.findEnteByCodice(codice)
    }

    Ente findEnteByCodiceAndAoo(String codice,String aoo) {
        docAreaTokenRepository.findEnteByCodiceAndAoo(codice, aoo)
    }

    DocAreaToken findByTokenAndUsername(String token, String username) {
        docAreaTokenRepository.findFirstByTokenAndUtenteInsNominativo(token,username)
    }

    int deleteObsolete(Integer ageHours) {
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.HOUR_OF_DAY,ageHours * -1)
        return docAreaTokenRepository.deleteObsolete(cal.time)
    }


}
