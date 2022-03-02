package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtenteBlacklist
import org.springframework.data.repository.CrudRepository

@CompileStatic
interface PrivilegioUtenteBlacklistRepository extends CrudRepository<PrivilegioUtenteBlacklist,String> {
}