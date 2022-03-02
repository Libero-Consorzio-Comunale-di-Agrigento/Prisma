package it.finmatica.protocollo.documenti.sinonimi

import it.finmatica.ad4.autenticazione.Ad4Utente

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Id
import javax.persistence.IdClass
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table

@Entity
@Table(name = "ag_radici_area_utente_tmp")
@IdClass(PrivilegioKey)
class RadiceAreaUtente {

    // indica che l'utente può smistare all'area dell'unita
    public static final String VISUALIZZA_AREA_UNITA = "SMISTAAREA"

    // il codice ed il progressivo dell'unità di so4.
    @Id
    @Column(name = "unita_radice_area")
    String codiceUnita

    // il codice del privilegio
    @Id
    String privilegio

    // l'utente che ha il privilegio
    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente")
    Ad4Utente utente

    @Column(name = "progr_unita", nullable = false)
    Long progrUnita

    static namedQueries = {
        getPrivilegi { utenteAd4, String privilegio, unita = null ->
            eq("privilegio", privilegio)

            if (utenteAd4 instanceof Ad4Utente) {
                eq("utente", utenteAd4)
            } else {
                eq("utente.id", utenteAd4)
            }

            if (unita != null && unita instanceof String) {
                eq("codiceUnita", unita)
            }
        }
    }
}