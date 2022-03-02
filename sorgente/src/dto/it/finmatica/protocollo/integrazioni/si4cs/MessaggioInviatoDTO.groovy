package it.finmatica.protocollo.integrazioni.si4cs

import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo

class MessaggioInviatoDTO extends DocumentoDTO implements it.finmatica.dto.DTO<MessaggioInviato> {
    Long idMessaggioSi4Cs
    String oggetto
    String testo
    String mittente
    String destinatari
    String destinatariConoscenza
    String destinatariNascosti
    String tagmail
    String mittenteAmministrazione
    String mittenteAoo
    String mittenteUo
    String statoSpedizione
    Date dataSpedizione
    boolean accettazione
    boolean nonAccettazione
    Date dataAccettazione
    Date dataNonAccettazione

    MessaggioInviato getDomainObject() {
        return MessaggioInviato.get(this.id)
    }

    MessaggioInviato copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    SchemaProtocollo getSchemaProtocollo() {
        return null
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return null
    }

    Integer getNumero() {
        return null
    }

    Integer getAnno() {
        return null
    }

    TipoRegistroDTO getTipoRegistro() {
        return null
    }
}
