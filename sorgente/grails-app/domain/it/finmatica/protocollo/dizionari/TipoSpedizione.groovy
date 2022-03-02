package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import org.hibernate.annotations.Type

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "AGS_TIPI_SPEDIZIONE")
@CompileStatic
class TipoSpedizione extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "ID_TIPO_SPEDIZIONE")
    Long id

    @Column(nullable = false)
    String codice

    @Column(nullable = false)
    String descrizione

    @Type(type = "yes_no")
    @Column(name = "barcode_estero", nullable = false)
    boolean barcodeEstero

    @Type(type = "yes_no")
    @Column(name = "barcode_italia", nullable = false)
    boolean barcodeItalia

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean stampa

    @Version
    Long version

}