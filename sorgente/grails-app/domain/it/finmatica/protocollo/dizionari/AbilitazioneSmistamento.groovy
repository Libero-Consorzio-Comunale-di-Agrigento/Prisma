package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = "agp_abilitazioni_smistamento")
@CompileStatic
class AbilitazioneSmistamento extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_abilitazioni_smistamento")
    Long id

    @Column(name = "tipo_smistamento", nullable = false)
    String tipoSmistamento

    @Column(name = "stato_smistamento", nullable = false)
    String statoSmistamento

    @Column(nullable = false)
    String azione

    @Column(name = "tipo_smistamento_generabile", nullable = false)
    String tipoSmistamentoGenerabile
}
