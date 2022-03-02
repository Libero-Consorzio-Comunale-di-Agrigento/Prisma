package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_protocolli_corr_indirizzi")
@CompileStatic
class Indirizzo extends AbstractDomain {

    public static final String TIPO_INDIRIZZO_AMMINISTRAZIONE = "AMM"
    public static final String TIPO_INDIRIZZO_UO 			   = "UO"
    public static final String TIPO_INDIRIZZO_AOO 			   = "AOO"

    @GeneratedValue
    @Id
    @Column(name = "id_protocollo_corr_indirizzo")
    Long id
    String cap
    String codice
    String comune
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_protocollo_corrispondente")
    Corrispondente corrispondente
    String denominazione
    String email
    String fax
    String indirizzo
    @Column(name = "provincia_sigla")
    String provinciaSigla
    @Column(name = "tipo_indirizzo")
    String tipoIndirizzo
    @Version
    Long version
}