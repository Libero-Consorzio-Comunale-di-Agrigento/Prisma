package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_tipi_esito_accesso")
@CompileStatic
class TipoEsitoAccesso extends AbstractDomainMultiEnte {
    public static final String NEGATIVO = "NEGATIVO"
    public static final String POSITIVO = "POSITIVO"

    @GeneratedValue
    @Id
    @Column(name = "id_tipo_esito")
    Long id
    @Column(nullable = false)
    String codice
    String commento
    @Column(nullable = false)
    String descrizione
    @Column(nullable = false)
    String tipo
    @Version
    Long version
}