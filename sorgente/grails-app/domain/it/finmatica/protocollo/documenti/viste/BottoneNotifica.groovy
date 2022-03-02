package it.finmatica.protocollo.documenti.viste

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_bottoni_notifiche")
@CompileStatic
class BottoneNotifica extends AbstractDomainMultiEnte {

    @Id
    Long id

    String assegnazione

    @Column(nullable = false)
    String azione

    @Column(name = "azione_multipla")
    int azioneMultipla

    @Column(nullable = false)
    String icona

    @Column(name = "icona_short", nullable = false)
    String iconaShort

    @Column(nullable = false)
    String label

    @Column(nullable = false)
    String modello

    @Column(name = "modello_azione")
    String modelloAzione

    @Column(nullable = false)
    Integer sequenza

    @Column(nullable = false)
    String stato

    @Column(nullable = false)
    String tipo

    @Column(name = "tipo_azione")
    String tipoAzione

    @Column(name = "tipo_smistamento")
    String tipoSmistamento

    String tooltip

    @Column(name = "url_azione")
    String urlAzione

    @Version
    Long version
}