package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import org.hibernate.annotations.Type

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

@Entity
@Table(name = "agp_proto_view")
@CompileStatic
class ProtocolloEsterno {

    @Id
    @Column(name = "id_documento")
    Long idDocumentoEsterno

    @Column(nullable = false)
    Integer anno

    @Column(nullable = false)
    String area

    @Column(nullable = false)
    String categoria

    @Column(name = "codice_modello", nullable = false)
    String codiceModello

    @Column(name = "codice_richiesta", nullable = false)
    String codiceRichiesta

    @Temporal(TemporalType.TIMESTAMP)
    @Column(nullable = false)
    Date data

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_documento", nullable = false)
    Date dataDocumento

    @Column(name = "link_documento", nullable = false)
    String linkDocumento

    @Column(nullable = false)
    String mittente

    @Column(nullable = false)
    Integer numero

    @Column(name = "numero_documento", nullable = false)
    String numeroDocumento

    @Column(nullable = false)
    String oggetto

    @Column(name = "tipo_documento", nullable = false)
    String schemaProtocollo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_registro")
    TipoRegistro tipoRegistro

    @Column(name = "utente_aggiornamento", nullable = false)
    String utenteAggiornamento

    @Column(name = "KEY_ITER_PROVVEDIMENTO")
    Long keyIterProvvedimento

    @Column(name = "fascicolo_anno")
    Integer fascicoloAnno

    @Column(name = "fascicolo_numero")
    String fascicoloNumero

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean riservato

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean annullato

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ann")
    Date dataAnnullamento

    @Column(name = "utente_ann")
    String utenteAnnullamento

    @Column(name = "modalita")
    String modalita

    @Column(name="data_spedizione")
    Date dataSpedizione
}