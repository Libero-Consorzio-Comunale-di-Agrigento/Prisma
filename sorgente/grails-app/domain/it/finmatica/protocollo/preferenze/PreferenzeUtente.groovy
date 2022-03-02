package it.finmatica.protocollo.preferenze

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table

@Entity
@Table(name = "agp_preferenze_utente")
@CompileStatic
class PreferenzeUtente {

    @GeneratedValue
    @Id
    @Column(name = "id_preferenza")
    Long id
    @Column(nullable = false)
    String preferenza
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente")
    Ad4Utente utente
    @Column(nullable = false)
    String valore
}