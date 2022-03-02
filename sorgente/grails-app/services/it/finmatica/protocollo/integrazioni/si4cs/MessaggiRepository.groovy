package it.finmatica.protocollo.integrazioni.si4cs

import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.corrispondenti.Messaggio
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface MessaggiRepository extends JpaRepository<Messaggio, Long> {

}