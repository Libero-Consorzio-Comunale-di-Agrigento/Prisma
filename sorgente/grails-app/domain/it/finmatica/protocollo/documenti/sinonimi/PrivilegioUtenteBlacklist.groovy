package it.finmatica.protocollo.documenti.sinonimi

import groovy.transform.CompileStatic

import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table

@CompileStatic
@Table(name = 'AG_PRIV_UTENTE_BLACKLIST')
@Entity
class PrivilegioUtenteBlacklist {
    @Id
    String utente
}
