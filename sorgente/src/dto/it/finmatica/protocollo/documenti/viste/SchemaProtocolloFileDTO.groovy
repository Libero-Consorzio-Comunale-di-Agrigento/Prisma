package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.TipoAllegatoDTO

class SchemaProtocolloFileDTO implements it.finmatica.dto.DTO<SchemaProtocolloFile>, IFileDocumento {


    Long id
    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated

    int sequenza
    String nome
    String contentType
    long dimensione = -1
    Long idFileEsterno      // indica l'id del file se salvato su un repository esterno (ad es GDM)
    Date validoDal  // da valorizzare alla creazione del record
    Date validoAl   // deve essere valorizzato con la data di sistema quando valido = false
    // quando valido = true deve essere null

    SchemaProtocolloDTO schemaProtocollo
    TipoAllegatoDTO tipoAllegato

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    SchemaProtocolloFile getDomainObject () {
        return SchemaProtocolloFile.get(this.id)
    }

    SchemaProtocolloFile copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    public String getDimensioneMB () {
        return new Double(((dimensione) / 1_000_000)).round(2) + " MB"
    }

    @Override
    String getTesto() {
        return null
    }

    @Override
    boolean isPdf() {
        return false
    }

    @Override
    boolean isP7m() {
        return false
    }

    @Override
    boolean isFirmato() {
        return false
    }

    @Override
    boolean isModificabile() {
        return false
    }

    @Override
    String getNomeFileSbustato() {
        return null
    }

    @Override
    String getNomePdf() {
        return null
    }

    IDocumentoEsterno getDocumento() {
        return schemaProtocollo
    }

    @Override
    Date getDataVerifica() {
        return null
    }

    @Override
    String getEsitoVerifica() {
        return null
    }
}
