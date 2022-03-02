package it.finmatica.protocollo.integrazioni.si4cs

import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class MessaggioRicevutoDTO extends DocumentoDTO implements it.finmatica.dto.DTO<MessaggioRicevuto>, ISmistabileDTO {

    private final static int NUM_MAX_DESTINATARI_VISIBILI = 5

    Long idMessaggioSi4Cs
    MessaggioRicevuto.Stato statoMessaggio
    Date dataRicezione
    Date dataStato
    Date dataSpedizione
    String mittente
    String destinatari
    String destinatariConoscenza
    String destinatariNascosti
    ClassificazioneDTO classificazione
    FascicoloDTO fascicolo
    String mimeTesto
    String testo
    String note
    String tipo
    String oggetto
    String idrif
    Set<SmistamentoDTO> smistamenti
    Set<DocumentoTitolarioDTO> titolari

    MessaggioRicevuto getDomainObject() {
        return MessaggioRicevuto.get(this.id)
    }

    MessaggioRicevuto copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    void addToSmistamenti(SmistamentoDTO smistamento) {
        if (this.smistamenti == null) {
            this.smistamenti = new HashSet<SmistamentoDTO>()
        }
        this.smistamenti.add(smistamento)
        smistamento.documento = this
    }

    void removeFromSmistamenti(SmistamentoDTO smistamento) {
        if (this.smistamenti == null) {
            this.smistamenti = new HashSet<SmistamentoDTO>()
        }
        this.smistamenti.remove(smistamento)
        smistamento.documento = null
    }

    void addToTitolari(DocumentoTitolarioDTO titolario) {
        if (this.titolari == null) {
            this.titolari = new HashSet<DocumentoTitolarioDTO>()
        }

        this.titolari.add(titolario)
        titolario.documento = this
    }

    void removeFromTitolari(DocumentoTitolarioDTO titolario) {
        if (this.titolari == null) {
            this.titolari = new HashSet<DocumentoTitolarioDTO>()
        }
        this.titolari.remove(titolario)
        titolario.documento = null
    }

    boolean isSmistamentoAttivoInCreazione() {
        return true
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

    So4UnitaPubbDTO getUnita() {
        return soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_MESSAGGIO
        }?.unitaSo4
    }

    //tronca i destinatari da visualizzare a 5 (se presenti più di 5 in lista)
    String getDestinatariShort(){
        String destinatariTrunc = ""
        List<String> destinatariString =   this.destinatari?.split("[,;]");
        if( destinatariString?.size() > NUM_MAX_DESTINATARI_VISIBILI -1) {
            for(int i=0; i<=NUM_MAX_DESTINATARI_VISIBILI-2; i++){
                destinatariTrunc = destinatariTrunc.concat(destinatariString[i]).concat(",")
            }
            //L'ultimo lo aggiungo senza la virgola
            destinatariTrunc = destinatariTrunc.concat(destinatariString[NUM_MAX_DESTINATARI_VISIBILI-1])
            return destinatariTrunc
        }
        else {
            return this.destinatari
        }
    }

    List<String> getDestinatariList () {
        List<String> destinatariListString =   this.destinatari?.split("[,;]");
        return destinatariListString
    }

}
