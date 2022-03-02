package it.finmatica.protocollo.documenti

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggettoDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezioneDTO
import it.finmatica.protocollo.documenti.emergenza.ProtocolloDatiEmergenzaDTO
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilitaDTO
import it.finmatica.protocollo.documenti.scarto.ProtocolloDatiScartoDTO
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematicoDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class ProtocolloDTO extends DocumentoDTO implements it.finmatica.dto.DTO<Protocollo>, ISmistabileDTO {
    private static final long serialVersionUID = 1L

    private static final int NUM_MAX_CORRISPONDENTI_VISIBILI = 5

    Integer anno
    boolean annullato
    ClassificazioneDTO classificazione
    FascicoloDTO fascicolo
    boolean controlloFunzionario
    boolean controlloFirmatario
    Set<CorrispondenteDTO> corrispondenti
    Set<SmistamentoDTO> smistamenti
    Set<DocumentoTitolarioDTO> titolari
    Set<ProtocolloRiferimentoTelematicoDTO> riferimentiTelematici
    Date data
    String idrif
    String movimento
    String note
    String noteTrasmissione
    Integer numero
    String oggetto
    TipoProtocolloDTO tipoProtocollo
    TipoRegistroDTO tipoRegistro
    SchemaProtocolloDTO schemaProtocollo
    String provvedimentoAnnullamento
    Date dataAnnullamento
    Ad4UtenteDTO utenteAnnullamento
    String codiceRaccomandata
    Date dataComunicazione
    Date dataDocumentoEsterno
    String numeroDocumentoEsterno
    Protocollo.StatoArchivio statoArchivio
    Date dataStatoArchivio
    String campiProtetti
    Date dataRedazione
    String registroEmergenza
    Integer numeroEmergenza
    Integer annoEmergenza

    ModalitaInvioRicezioneDTO modalitaInvioRicezione
    ProtocolloDatiScartoDTO datiScarto
    ProtocolloDatiEmergenzaDTO datiEmergenza
    ProtocolloDatiInteroperabilitaDTO datiInteroperabilita
    RegistroGiornalieroDTO registroGiornaliero

    void setEsitoVerifica(String esitoVerifica) {
        this.getFilePrincipale()?.esitoVerifica = esitoVerifica
    }

    String getEsitoVerifica() {
        return this.getFilePrincipale()?.esitoVerifica
    }

    Date getDataVerifica() {
        return this.getFilePrincipale()?.dataVerifica
    }

    void setDataVerifica(Date dataVerifica) {
        this.getFilePrincipale()?.dataVerifica = dataVerifica
    }

    FileDocumentoDTO getFilePrincipale() {
        return getFile(FileDocumento.CODICE_FILE_PRINCIPALE)
    }

    FileDocumentoDTO getFileOriginale() {
        return getFile(FileDocumento.CODICE_FILE_ORIGINALE)
    }

    FileDocumentoDTO getFileFrontespizio() {
        return getFile(FileDocumento.CODICE_FILE_FRONTESPIZIO)
    }

    FileDocumentoDTO getFile(String codice) {
        return fileDocumenti?.find { it.codice == codice }
    }

    void addToCorrispondenti(CorrispondenteDTO corrispondente) {
        if (this.corrispondenti == null) {
            this.corrispondenti = new HashSet<CorrispondenteDTO>()
        }
        this.corrispondenti.add(corrispondente)
        corrispondente.protocollo = this
    }

    void removeFromCorrispondenti(CorrispondenteDTO corrispondente) {
        if (this.corrispondenti == null) {
            this.corrispondenti = new HashSet<CorrispondenteDTO>()
        }
        this.corrispondenti.remove(corrispondente)
        corrispondente.protocollo = null
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

    void addToSoggetti(DocumentoSoggettoDTO documentoSoggetto) {
        if (this.soggetti == null) {
            this.soggetti = new HashSet<DocumentoSoggettoDTO>()
        }
        this.soggetti.add(documentoSoggetto)
        documentoSoggetto.documento = this
    }

    void removeFromSoggetti(DocumentoSoggettoDTO documentoSoggetto) {
        if (this.soggetti == null) {
            this.soggetti = new HashSet<DocumentoSoggettoDTO>()
        }
        this.soggetti.remove(documentoSoggetto)
        documentoSoggetto.documento = null
    }

    Protocollo getDomainObject() {
        return Protocollo.get(this.id)
    }

    Protocollo copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    void addToRiferimentiTelematici(ProtocolloRiferimentoTelematicoDTO riferimentoTelematicoDTO) {
        if (this.riferimentiTelematici == null) {
            this.riferimentiTelematici = new HashSet<ProtocolloRiferimentoTelematicoDTO>()
        }
        this.riferimentiTelematici.add(riferimentoTelematicoDTO)
        riferimentoTelematicoDTO.protocollo = this
    }

    void removeFromRiferimentiTelematici(ProtocolloRiferimentoTelematicoDTO riferimentoTelematicoDTO) {
        if (this.riferimentiTelematici == null) {
            this.riferimentiTelematici = new HashSet<ProtocolloRiferimentoTelematicoDTO>()
        }
        this.riferimentiTelematici.remove(riferimentoTelematicoDTO)
        riferimentoTelematicoDTO.protocollo = null
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    FileDocumentoDTO getTestoPrincipale() {
        return fileDocumenti.find {
            it?.codice == FileDocumento.CODICE_FILE_PRINCIPALE
        }
    }

    void setTestoPrincipale(FileDocumentoDTO fileDocumento) {
        FileDocumentoDTO fd = fileDocumenti.find {
            it.codice == FileDocumento.CODICE_FILE_PRINCIPALE
        }
        fileDocumenti.remove(fd)
        fileDocumenti.add(fileDocumento)
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return tipoProtocollo?.getCategoriaProtocollo()
    }

    boolean isProtocollato() {
        return Protocollo.isProtocollato(numero, anno, data)
    }

    boolean isBloccato() {
        return Protocollo.isBloccato(data)
    }

    boolean isSmistamentoAttivoInCreazione() {
        return (numero > 0) || categoriaProtocollo.isSmistamentoAttivoInCreazione()
    }

    So4UnitaPubbDTO getUnita() {
        return soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_PROTOCOLLANTE
        }?.unitaSo4
    }

    String getAnnoNumeroProtocollo(){
        String annoNumero = ""
        if(numero>0){
            annoNumero =  String.valueOf(anno).concat("/").concat(String.valueOf(numero))
        }
        return annoNumero
    }

    List<CorrispondenteDTO> getCorrispondentiShort(){
        if(this.corrispondenti?.size() > NUM_MAX_CORRISPONDENTI_VISIBILI-1) {
            return this.corrispondenti?.toList().subList(0,NUM_MAX_CORRISPONDENTI_VISIBILI)
        }
        return this.corrispondenti?.toList()
    }

    List<String> getCorrispondentiLong(){
        List<String> corrispondentiLong = new ArrayList<String>()
        for(CorrispondenteDTO corr : this.corrispondenti) {
            String denominazineMailCorr = "-"
            denominazineMailCorr = denominazineMailCorr.concat(corr.denominazione ?: " ").concat(corr.email ?: " ")
            corrispondentiLong.add(denominazineMailCorr)
        }
        return corrispondentiLong
    }

}
