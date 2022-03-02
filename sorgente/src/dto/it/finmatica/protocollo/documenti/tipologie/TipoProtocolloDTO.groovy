package it.finmatica.protocollo.documenti.tipologie

import it.finmatica.ad4.autenticazione.Ad4RuoloDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoDTO
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class TipoProtocolloDTO extends TipoDocumentoDTO implements it.finmatica.dto.DTO<TipoProtocollo> {
    private static final long serialVersionUID = 1L

    boolean funzionarioObbligatorio
    boolean firmatarioObbligatorio
    boolean funzionarioVisibile
    boolean firmatarioVisibile
    boolean predefinito
    TipoRegistroDTO tipoRegistro
    SchemaProtocolloDTO schemaProtocollo
    String categoria
    String movimento

    So4UnitaPubbDTO unitaDestinataria
    Ad4RuoloDTO ruoloUoDestinataria

    TipoProtocollo getDomainObject() {
        return TipoProtocollo.get(this.id)
    }

    TipoProtocollo copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    CategoriaProtocollo getCategoriaProtocollo() {
        return CategoriaProtocollo.getInstance(categoria)
    }

    void setCategoriaProtocollo(CategoriaProtocollo categoriaProtocollo) {
        this.categoria = categoriaProtocollo?.codice
    }
}
