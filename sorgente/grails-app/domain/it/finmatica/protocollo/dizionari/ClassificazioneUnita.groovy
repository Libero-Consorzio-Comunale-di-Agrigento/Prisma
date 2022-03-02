package it.finmatica.protocollo.dizionari

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
@Table(name='ags_classificazioni_unita')
class ClassificazioneUnita  extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_classificazione_unita")
    Long id

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unita

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Version
    Long version


}
