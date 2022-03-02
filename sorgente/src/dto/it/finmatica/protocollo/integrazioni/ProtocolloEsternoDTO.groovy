package it.finmatica.protocollo.integrazioni

import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO

class ProtocolloEsternoDTO implements it.finmatica.dto.DTO<ProtocolloEsterno> {
    private static final long serialVersionUID = 1L

    Integer anno
    String linkDocumento
    Integer numero
    Date data
    String oggetto
    Long idDocumentoEsterno
    String categoria
    String schemaProtocollo
    String codiceModello
    String area
    String codiceRichiesta
    Date dataDocumento
    String numeroDocumento
    String mittente
    Long keyIterProvvedimento
    boolean annullato
    Date dataAnnullamento
    String utenteAnnullamento
    String modalita
    Date dataSpedizione
    Integer fascicoloAnno
    String fascicoloNumero
    boolean riservato

    String utenteAggiornamento

    TipoRegistroDTO tipoRegistro

    ProtocolloEsterno getDomainObject() {
        return ProtocolloEsterno.get(this.id)
    }

    ProtocolloEsterno copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.
}
