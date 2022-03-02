package it.finmatica.protocollo.documenti.telematici

import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.Protocollo
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface ProtocolloRiferimentoTelematicoRepository extends JpaRepository<ProtocolloRiferimentoTelematico,Long> {

    List<ProtocolloRiferimentoTelematico> findByProtocollo(Protocollo protocollo)
}