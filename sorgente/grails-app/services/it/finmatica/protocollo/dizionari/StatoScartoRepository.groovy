package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface StatoScartoRepository extends JpaRepository<StatoScarto,String> {
}
