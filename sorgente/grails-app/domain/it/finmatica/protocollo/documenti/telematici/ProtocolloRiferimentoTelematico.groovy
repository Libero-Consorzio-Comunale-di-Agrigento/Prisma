package it.finmatica.protocollo.documenti.telematici

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.protocollo.documenti.Protocollo
import org.hibernate.annotations.Type

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@CompileStatic
@Entity
@Table(name = "agp_protocolli_rif_telematici")
class ProtocolloRiferimentoTelematico extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_protocollo_rif_telematico")
    Long id

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento")
    Protocollo protocollo

    @Column(name="uri")
    String uri

    @Column
    Long dimensione

    @Column(name="impronta", length = 4000)
    String impronta
    @Column(name="impronta_algoritmo")
    String improntaAlgoritmo
    @Column(name="impronta_codifica")
    String improntaCodifica
    @Column(name="tipo")
    String tipo
    @Column(nullable = true,name = "correttezza_impronta",length = 1)
    String correttezzaImpronta

    @Type(type = "yes_no")
    @Column(nullable = true,name="scaricato")
    boolean scaricato = true


    @Version
    Long version

}
