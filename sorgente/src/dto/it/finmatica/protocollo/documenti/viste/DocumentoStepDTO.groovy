package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4RuoloDTO
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestioneiter.motore.WkfStepDTO
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.viste.DocumentoStep
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.FascicoloArchi
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

public class DocumentoStepDTO implements it.finmatica.dto.DTO<DocumentoStep> {
    private static final long serialVersionUID = 1L;

    Integer anno;
    String descrizioneTipologia;
    Long idDocumento;
    Long idTipologia;
    Date lastUpdated;
    Integer numero;
    String oggetto;
    ProtocolloDTO protocollo;
    MessaggioRicevutoDTO messaggioRicevuto
    boolean riservato;
    String stato;
    String statoConservazione;
    String statoFirma;
    WkfStepDTO step;
    String stepDescrizione;
    String stepNome;
    Ad4RuoloDTO stepRuolo;
    String stepTitolo;
    So4UnitaPubbDTO stepUnita;
    Ad4UtenteDTO stepUtente;
    String tipoOggetto;
    String tipoRegistro;
    String titoloTipologia;
    So4UnitaPubbDTO unitaProtocollante
    String mittente
    String movimento
    ClassificazioneDTO classificazione
    FascicoloDTO fascicolo
    String mittentiProtocollo

    Date dataSpedizione

    public DocumentoStep getDomainObject() {
        return DocumentoStep.get(this.idDocumento)
    }

    public DocumentoStep copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.
}
