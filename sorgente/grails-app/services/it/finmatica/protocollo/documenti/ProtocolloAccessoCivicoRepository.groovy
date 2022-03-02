package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivico
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface ProtocolloAccessoCivicoRepository extends JpaRepository<ProtocolloAccessoCivico,Long> {

    ProtocolloAccessoCivico findByProtocolloDomanda(Protocollo protocollo)
}