package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.OneToMany
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_liste_distribuzione")
@CompileStatic
class ListaDistribuzione extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_lista")
    Long id
    @Column(nullable = false)
    String codice
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "listaDistribuzione", orphanRemoval = true)
    Set<ComponenteListaDistribuzione> componenti
    @Column(nullable = false)
    String descrizione
    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno
    @Version
    Long version

    void addToComponenti(ComponenteListaDistribuzione value) {
        if (this.componenti == null) {
            this.componenti = new HashSet<ComponenteListaDistribuzione>()
        }
        this.componenti.add(value);
        value.listaDistribuzione = this
    }

    void removeFromComponenti(ComponenteListaDistribuzione value) {
        if (this.componenti == null) {
            this.componenti = new HashSet<ComponenteListaDistribuzione>()
        }
        this.componenti.remove((Object) value);
        value.listaDistribuzione = null
    }
}