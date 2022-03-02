package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@Entity
@Table(name = "AGS_MODALITA_INVIO_RICEZIONE")
@CompileStatic
class ModalitaInvioRicezione extends AbstractDomainMultiEnte {

    public static final String CODICE_EMAIL = "EMAIL"
    public static final String CODICE_PEC = "PEC"
    public static final String CODICE_POSTA_ORDINARIA = "POR"

    @GeneratedValue
    @Id
    @Column(name = "ID_MODALITA_INVIO_RICEZIONE")
    Long id

    @Column(nullable = false)
    String codice

    @Column(nullable = true)
    BigDecimal costo

    @Column(nullable = false)
    String descrizione

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_spedizione")
    TipoSpedizione tipoSpedizione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "valido_al")
    Date validoAl

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "valido_dal", nullable = false)
    Date validoDal

    @Version
    Long version

}