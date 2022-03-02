package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

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
@Table(name='ags_classificazioni_num')
class ClassificazioneNumero extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_classificazione_num")
    Long id

    @Column(nullable = false)
    Integer anno

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Column(nullable = false, name='ultimo_numero_fascicolo')
    Integer ultimoNumeroFascicolo = 0

    @Version
    Long version

}
