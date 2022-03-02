package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.so4.So4Repository

@CompileStatic
abstract class BaseFascicoloService extends BaseService {
    So4Repository so4Repository
    ProtocolloGestoreCompetenze protocolloGestoreCompetenze

    BaseFascicoloService(DocAreaExtendedHelperService docAreaExtenedHelperService, So4Repository so4Repository, ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService)
        this.so4Repository = so4Repository
        this.protocolloGestoreCompetenze = protocolloGestoreCompetenze
    }

    protected void propComuni(Node xml, it.finmatica.protocollo.dizionari.Fascicolo fascicolo) {
        Date dataApertura = getDataApertura(xml)
        if (dataApertura) {
            fascicolo.dataApertura = dataApertura
        }
        String oggetto = getOggetto(xml)
        if (oggetto) {
            fascicolo.oggetto = oggetto
        }
        if(so4Repository) {
            String unitaCompetenza = getUnitaCompetenza(xml)
            if (unitaCompetenza) {
                addUnita(fascicolo,unitaCompetenza,TipoSoggetto.UO_COMPETENZA)
            }
            String unitaCreazione = getUnitaCreazione(xml)
            if(unitaCreazione) {
                addUnita(fascicolo,unitaCreazione,TipoSoggetto.UO_CREAZIONE)
            }

        }
        String note = getNote(xml)
        if (note) {
            fascicolo.note = note
        }
        if(!fascicolo.dataCreazione) {
            fascicolo.dataCreazione = new Date()
        }
        if(!fascicolo.dataApertura) {
            fascicolo.dataApertura = fascicolo.dataCreazione
        }
        if(!fascicolo.statoFascicolo) {
            fascicolo.statoFascicolo = it.finmatica.protocollo.dizionari.Fascicolo.STATO_CORRENTE
        }
        if(!fascicolo.sub) {
            fascicolo.sub = 0
        }
        if(!fascicolo.dataUltimaOperazione) {
            fascicolo.dataUltimaOperazione = fascicolo.dataCreazione
        }
        if(!fascicolo.ultimoNumeroSub) {
            fascicolo.ultimoNumeroSub = 0
        }
    }

    protected addUnita(it.finmatica.protocollo.dizionari.Fascicolo fascicolo, String unita, String tipoSoggetto) {
        def uc = new DocumentoSoggetto()
        uc.unitaSo4 = so4Repository.getUnitaByCodiceSo4(unita)
        uc.documento = fascicolo
        uc.tipoSoggetto = tipoSoggetto
        fascicolo.addToSoggetti(uc)
    }

    protected boolean utentePuoModificareDocumento(it.finmatica.gestionedocumenti.documenti.Documento doc) {
        Map<String,Boolean> competenze = protocolloGestoreCompetenze.getCompetenze(doc)
        return competenze.modifica
    }

    @CompileDynamic
    protected String getUtente(Node node) {
        node.UTENTE?.text()
    }

    @CompileDynamic
    String getOggetto(Node node) {
        node.OGGETTO?.text()
    }

    @CompileDynamic
    String getUnitaCompetenza(Node node) {
        node.UNITA_COMPETENZA?.text()
    }

    @CompileDynamic
    String getUnitaCreazione(Node node) {
        node.UNITA_CREAZIONE?.text()
    }

    @CompileDynamic
    String getNote(Node node) {
        node.NOTE?.text()
    }

    @CompileDynamic
    String getClassificazione(Node node) {
        node.CLASS_COD?.text()
    }

    @CompileDynamic
    String getFascicoloAnno(Node node) {
        node.FASCICOLO_ANNO?.text()
    }

    @CompileDynamic
    Date getDataApertura(Node node) {
        getDate(node.DATA_APERTURA?.text())
    }
}
