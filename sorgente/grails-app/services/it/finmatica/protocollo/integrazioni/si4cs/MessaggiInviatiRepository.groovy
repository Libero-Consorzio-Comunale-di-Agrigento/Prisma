package it.finmatica.protocollo.integrazioni.si4cs

import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface MessaggiInviatiRepository extends JpaRepository<MessaggioInviato, Long> {

}
