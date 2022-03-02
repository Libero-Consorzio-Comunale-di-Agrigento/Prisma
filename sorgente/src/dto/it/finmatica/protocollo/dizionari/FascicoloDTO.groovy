package it.finmatica.protocollo.dizionari

import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggettoDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScartoDTO
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class FascicoloDTO extends DocumentoDTO implements it.finmatica.dto.DTO<Fascicolo>, ISmistabileDTO {

    private static final long serialVersionUID = 1L
    public static final String TIPO_DOCUMENTO = 'FASCICOLO'

    Long id
    //Long idDocumentoEsterno
    Integer anno
    String numero
    String annoNumero
    boolean numeroProssimoAnno
    String oggetto
    String responsabile
    boolean riservato
    boolean digitale
    String annoArchiviazione
    String statoFascicolo
    String topografia
    String note
    Date dataCreazione
    Date dataApertura
    Date dataChiusura
    Date dataStato
    String nome
    Integer sub
    ClassificazioneDTO classificazione
    Integer ultimoNumeroSub
    String movimento
    String idrif
    String numeroOrd
    Long idFascicoloPadre
    Date dataArchiviazione
    Date dataUltimaOperazione
    DocumentoDatiScartoDTO datiScarto

    Set<SmistamentoDTO> smistamenti

    Fascicolo getDomainObject() {
        return Fascicolo.get(this.id)
    }

    Fascicolo copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    String getType() {
        return TIPO_DOCUMENTO
    }

    boolean isVuoto() {
        if (!numero) {
            return true
        } else {
            if (dataApertura > new Date()) {
                return true
            }
        }
        return false
    }

    List<Long> listIdDocumentiSmistable() {
        List<Long> listaRicerca = []

        List<Long> listaProtocolli = Protocollo.createCriteria().list() {
            projections {
                distinct("id")
            }
            eq("annullato", false)
            eq("fascicolo.id", id)
        }

        // messaggi ricevuti con id_fascicolo
        List<Long> listaMsgRicevuti = MessaggioRicevuto.createCriteria().list() {
            projections {
                distinct("id")
            }
            eq("fascicolo.id", id)
        }

        // documenti titolario
        List<Long> listaDocumentiTitolario = DocumentoTitolario.createCriteria().list() {
            projections {
                distinct("documento.id")
            }
            eq("fascicolo.id", id)
        }

        listaProtocolli.each {
            listaRicerca << it
        }
        listaMsgRicevuti.each {
            listaRicerca << it
        }
        listaDocumentiTitolario.each {
            listaRicerca << it
        }

        return listaRicerca.unique()
    }

    String getNumerazione() {
        if (numero != null) {
            return "${anno} / ${numero}"
        } else {
            return ''
        }
    }

    String getNome() {
        if (numero != null) {
            return "${anno} / ${numero} - ${oggetto}"
        } else {
            return ''
        }
    }

    String getNumero() {
        if (numero != null) {
            return "${numero}"
        } else {
            return ''
        }
    }

    String getEstremiFascicolo() {
        if (numero != null) {
            return "${anno} / ${numero} - ${oggetto}"
        } else {
            return ''
        }
    }

    String getCodiceClassificazione() {
        return classificazione.codice
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return CategoriaProtocollo.getInstance(TIPO_DOCUMENTO)
    }

    SchemaProtocollo getSchemaProtocollo() {
        return null
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

    boolean isSmistamentoAttivoInCreazione() {
        return true
    }

    So4UnitaPubbDTO getUnita() {
        return soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_COMPETENZA
        }?.unitaSo4
    }

    So4UnitaPubbDTO getUnitaDescr() {
        return soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_COMPETENZA
        }?.unitaSo4?.descrizione
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
}