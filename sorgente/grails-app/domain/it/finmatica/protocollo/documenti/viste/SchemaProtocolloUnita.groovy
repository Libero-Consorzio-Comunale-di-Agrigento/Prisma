package it.finmatica.protocollo.documenti.viste

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinColumns
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_schemi_prot_unita")
@CompileStatic
class SchemaProtocolloUnita extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_schema_prot_unita")
    Long id

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unita

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ruolo")
    Ad4Ruolo ruoloAd4
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente")
    Ad4Utente utenteAd4

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    @Version
    Long version
}