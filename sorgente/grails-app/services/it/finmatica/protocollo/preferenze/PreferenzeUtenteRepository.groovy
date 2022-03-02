package it.finmatica.protocollo.preferenze

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface PreferenzeUtenteRepository extends JpaRepository<PreferenzeUtente,Long> {

    List<PreferenzeUtente> findByUtente(Ad4Utente utente)
}