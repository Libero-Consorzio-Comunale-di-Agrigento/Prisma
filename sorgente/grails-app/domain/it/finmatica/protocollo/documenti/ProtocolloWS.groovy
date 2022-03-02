package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table

@CompileStatic
@Entity
@Table(name='AGP_WS_PROTOCOLLI')
class ProtocolloWS {
    @Id
    @Column(name="id_documento", insertable = false, updatable = false)
    Long idDocumento
    @Column(insertable = false, updatable = false)
    Integer anno
    @Column(insertable = false, updatable = false)
    Integer numero
    @Column(insertable = false, updatable = false)
    Date data
    @Column(insertable = false, updatable = false)
    String oggetto
    @Column(insertable = false, updatable = false)
    String modalita
    @Column(name="class_cod",insertable = false, updatable = false)
    String classificazione
    @Column(name ="class_dal", insertable = false, updatable = false)
    Date classDal
    @Column(name="fascicolo_anno", insertable = false, updatable = false)
    Integer annoFascicolo
    @Column(name="fascicolo_numero", insertable = false, updatable = false)
    String numeroFascicolo
    @Column(name="tipo_registro", insertable = false, updatable = false)
    String tipoRegistro
    @Column(name="descrizione_tipo_registro", insertable = false, updatable = false)
    String descrizioneTipoRegistro
    @Column(name="categoria", insertable = false, updatable = false)
    String categoria
    @Column(name="idrif", insertable = false, updatable = false)
    String idrif
    @Column(name="id_documento_esterno", insertable = false, updatable = false)
    Long idDocumentoEsterno
    @Column(name="tipo_documento", insertable = false, updatable = false)
    String tipoDocumento
    @Column(name="descrizione_tipo_documento", insertable = false, updatable = false)
    String descrizioneTipoDocumento
    @Column(name="stato_pr", insertable = false, updatable = false)
    String statoPr
    @Column(name="unita_protocollante", insertable = false, updatable = false)
    String unitaProtocollante



    boolean isCategoriaProtocollo () {
        return this.categoria?.toUpperCase() == Protocollo.CATEGORIA_PROTOCOLLO
    }
}
