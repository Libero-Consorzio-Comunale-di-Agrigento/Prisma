package it.finmatica.protocollo.documenti.annullamento

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.EnumType
import javax.persistence.Enumerated
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinColumns
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@Entity
@Table(name = "agp_protocolli_annullamenti")
@CompileStatic
class ProtocolloAnnullamento extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_protocollo_annullamento")
    Long id

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_acc_rif")
    Date dataAccettazioneRifiuto

    @Column(nullable = false, length = 4000)
    String motivo

    @Column(name = "motivo_rifiuto")
    String motivoRifiuto

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento")
    Protocollo protocollo

    @Enumerated(EnumType.STRING)
    StatoAnnullamento stato

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unita

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "utente_acc_rif")
    Ad4Utente utenteAccettazioneRifiuto

    @Version
    Long version
}