package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.anagrafica.As4Anagrafica
import it.finmatica.as4.anagrafica.As4Recapito
import it.finmatica.so4.struttura.So4Ottica

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table

@Entity
@Table(name = "SO4_V_UNITA")
@CompileStatic
class So4UnitaBase  {

    @Id
    @Column(name = "progr")
    Long progr

    @Column(name = "codice")
    String codice

    @Column(name = "descrizione")
    String descrizione

    @Column(name = "amministrazione")
    String amministrazione

    @Column(name = "dal")
    Date dal

    @Column(name = "al")
    Date al

    @Column(name = "indirizzo")
    String indirizzo

    @Column(name = "cap")
    String cap

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provincia")
    Ad4Provincia provincia

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comune")
    Ad4Comune comune

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ottica")
    So4Ottica ottica

    @Column(name = "telefono")
    String telefono

    @Column(name = "fax")
    String fax

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        So4UnitaBase that = (So4UnitaBase) o

        if (dal != that.dal) return false
        if (progr != that.progr) return false

        return true
    }

    int hashCode() {
        int result
        result = (progr != null ? progr.hashCode() : 0)
        result = 31 * result + (dal != null ? dal.hashCode() : 0)
        return result
    }
}

