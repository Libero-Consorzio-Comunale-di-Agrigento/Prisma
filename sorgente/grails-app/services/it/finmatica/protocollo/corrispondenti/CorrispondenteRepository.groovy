package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface CorrispondenteRepository extends JpaRepository<Corrispondente,Long> {
}