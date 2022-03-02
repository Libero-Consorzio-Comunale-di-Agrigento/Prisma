package it.finmatica.protocollo.corrispondenti

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.as4.anagrafica.As4ContattoDTO
import it.finmatica.as4.anagrafica.As4RecapitoDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezioneDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO

class CorrispondenteDTO implements it.finmatica.dto.DTO<Corrispondente> {
    private static final long serialVersionUID = 1L

    Long id
    Long version

    String barcodeSpedizione
    String cap
    String codiceFiscale
    String idFiscaleEstero
    String cognome
    String comune
    boolean conoscenza
    boolean suap
    Date dataSpedizione
    Date dateCreated
    String denominazione
    String email
    String fax
    Long idDocumentoEsterno
    Set<IndirizzoDTO> indirizzi
    String indirizzo
    Date lastUpdated
    Set<CorrispondenteMessaggioDTO> messaggi
    String nome
    String partitaIva
    ProtocolloDTO protocollo
    String provinciaSigla
    String tipoCorrispondente
    String tipoIndirizzo
    TipoSoggettoDTO tipoSoggetto
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido
    Long quantita
    BigDecimal costoSpedizione
    ModalitaInvioRicezioneDTO modalitaInvioRicezione

    void addToIndirizzi (IndirizzoDTO indirizzo) {
        if (this.indirizzi == null)
            this.indirizzi = new HashSet<IndirizzoDTO>()
        this.indirizzi.add (indirizzo)
        indirizzo.corrispondente = this
    }

    void removeFromIndirizzi (IndirizzoDTO indirizzo) {
        if (this.indirizzi == null)
            this.indirizzi = new HashSet<IndirizzoDTO>()
        this.indirizzi.remove (indirizzo)
        indirizzo.corrispondente = null
    }

    void addToCorrispondentiMessaggi(CorrispondenteMessaggioDTO messaggio) {
        if (this.messaggi == null)
            this.messaggi = new HashSet<CorrispondenteMessaggioDTO>()
        this.messaggi.add (messaggio)
        messaggio.corrispondente = this
    }

    void removeFromCorrispondentiMessaggi(CorrispondenteMessaggioDTO messaggio) {
        if (this.messaggi == null)
            this.messaggi = new HashSet<CorrispondenteMessaggioDTO>()
        this.messaggi.remove (messaggio)
        messaggio.corrispondente = null
    }

    Corrispondente getDomainObject () {
        return Corrispondente.get(this.id)
    }

    Corrispondente copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

	/* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
	// qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

	// utile per la visualizzazione
	String getIndirizzoCompleto () {

        String indirizzoCompleto = ""
        if(indirizzo != null){
            indirizzoCompleto = indirizzo
            if(cap != null ){
                indirizzoCompleto = indirizzoCompleto + " " + cap
            }
            if(comune != null){
                indirizzoCompleto = indirizzoCompleto + " " + comune
            }
            if (provinciaSigla != null) {
                indirizzoCompleto += " ("+ provinciaSigla +")"
            }
        }
        return indirizzoCompleto
    }

	// utile per comporre le immagini
	String anagrafica

	// utili per il dettaglio delle Amministrazioni
	String codiceAmministrazione
	String aoo
	String uo

    Long ni

    As4RecapitoDTO recapito
    As4ContattoDTO contatto
}
