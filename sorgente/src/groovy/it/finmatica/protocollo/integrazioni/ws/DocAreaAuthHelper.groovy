package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Utils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Service
@Transactional
class DocAreaAuthHelper {
    @Autowired AuthenticationProvider authenticationProvider

    Authentication authenticate(String username, String password) {
        authenticationProvider.authenticate(new UsernamePasswordAuthenticationToken(username, password))
    }

    void autenticaEnte(String username, Long idEnte) {
        Utils.eseguiAutenticazione(username, idEnte)
    }

}
