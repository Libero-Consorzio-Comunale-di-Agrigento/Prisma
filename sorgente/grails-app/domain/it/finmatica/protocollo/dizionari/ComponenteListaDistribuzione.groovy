package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.as4.anagrafica.As4Contatto
import it.finmatica.as4.anagrafica.As4Recapito
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
@Table(name = "AGP_LISTE_DISTRIB_COMPONENTI")
@CompileStatic
class ComponenteListaDistribuzione extends AbstractDomainMultiEnte {

    @Id
    @Column(name = "id_componente")
    Long id

    @Column(name = "cod_aoo")
    String aoo
    String cap

    @Column(name = "cod_amm")
    String codiceAmministrazione

    @Column(name = "codice_fiscale")
    String codiceFiscale
    String cognome
    String comune

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_contatto")
    As4Contatto contatto

    String denominazione
    String email
    String fax

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno
    String indirizzo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_lista")
    ListaDistribuzione listaDistribuzione

    String ni
    String nome

    @Column(name = "partita_iva")
    String partitaIva

    @Column(name = "provincia_sigla")
    String provinciaSigla

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_recapito")
    As4Recapito recapito

    @Column(name = "cod_uo")
    String uo

    @Version
    Long version
}