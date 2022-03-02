package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class SchemaProtocolloDTO implements it.finmatica.dto.DTO<SchemaProtocollo> , IDocumentoEsterno {


    Long id
    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated

    ClassificazioneDTO  classificazione
    FascicoloDTO fascicolo
    TipoRegistroDTO     tipoRegistro
    TipoProtocolloDTO   tipoProtocollo
    SchemaProtocolloDTO schemaProtocolloRisposta
    Integer scadenza

    // indica l'id del documento sul documentale esterno (ad es. GDM)
    Long idDocumentoEsterno

    So4UnitaPubbDTO ufficioEsibente

    String codice
    String descrizione
    String note
    String oggetto
    String movimento
    boolean conservazioneIllimitata = false
    Integer anniConservazione
    boolean segnatura = false
    boolean segnaturaCompleta = false
    boolean risposta = false
    boolean domandaAccesso = false
    Date validoDal  // da valorizzare alla creazione del record
    Date validoAl   // deve essere valorizzato con la data di sistema quando valido = false
    // quando valido = true deve essere null

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    boolean riservato

    Set<SchemaProtocolloSmistamentoDTO> smistamenti
    Set<SchemaProtocolloUnitaDTO> unitaSet
    Set<SchemaProtocolloFileDTO> files
    Set<SchemaProtocolloCategoriaDTO> categorie

    SchemaProtocollo getDomainObject () {
        return SchemaProtocollo.get(this.id)
    }

    SchemaProtocollo copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    void addToSmistamenti (SchemaProtocolloSmistamentoDTO smistamento) {
        if (this.smistamenti == null)
            this.smistamenti = new HashSet<SchemaProtocolloSmistamentoDTO>()
        this.smistamenti.add (smistamento)
        smistamento.schemaProtocollo = this
    }

    void removeFromSmistamenti (SchemaProtocolloSmistamentoDTO smistamento) {
        if (this.smistamenti == null)
            this.smistamenti = new HashSet<SchemaProtocolloSmistamentoDTO>()
        this.smistamenti.remove (smistamento)
        smistamento.schemaProtocollo = null
    }

    public void addToFiles (SchemaProtocolloFileDTO file) {
        if (this.files == null)
            this.files = new ArrayList<SchemaProtocolloFileDTO>()
        this.files.add (file);
        file.schemaProtocollo = this
    }

    public void removeFromFiles(SchemaProtocolloFileDTO file) {
        if (this.files == null)
            this.files = new ArrayList<SchemaProtocolloFileDTO>()
        this.files.remove (file);
        file.schemaProtocollo = null
    }

    public void addToCategorie (SchemaProtocolloCategoriaDTO categoria) {
        if (this.categorie == null)
            this.categorie = new ArrayList<SchemaProtocolloCategoriaDTO>()
        this.categorie.add (categoria);
        categoria.schemaProtocollo = this
    }

    public void removeFromCategorie(SchemaProtocolloCategoriaDTO categoria) {
        if (this.categorie == null)
            this.categorie = new ArrayList<SchemaProtocolloCategoriaDTO>()
        this.categorie.remove (categoria);
        categoria.schemaProtocollo = null
    }
}
