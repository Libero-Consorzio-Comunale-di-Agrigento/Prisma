package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import org.springframework.data.jpa.repository.JpaRepository

@CompileStatic
interface TipoSoggettoRepository extends JpaRepository<TipoSoggetto,Long>{
}