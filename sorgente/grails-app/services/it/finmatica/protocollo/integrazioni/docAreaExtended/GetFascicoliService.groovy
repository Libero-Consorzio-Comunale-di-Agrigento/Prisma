package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloJPAQLFilter
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class GetFascicoliService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    FascicoloService fascicoloService

    GetFascicoliService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired So4Repository so4Repository,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, so4Repository, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Fascicoli)
    }

    @Override
    String getXsdName() {
        return 'getFascicoli'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        FascicoloJPAQLFilter filter = new FascicoloJPAQLFilter()
        Fascicoli resp = new Fascicoli()
        String classificazione = getClassificazione(xml)
        filter.haClassificazioneLike(classificazione)
        String fascicoloNumero = getFascicoloNumero(xml)
        if(fascicoloNumero) {
            filter.haNumeroLike(fascicoloNumero)
        }
        String fascicoloAnno = getFascicoloAnno(xml)
        if(fascicoloAnno) {
            filter.haAnno(getInteger(fascicoloAnno))
        }
        String fascicoloAnnoDal = getFascicoloAnnoDal(xml)
        if(fascicoloAnnoDal) {
            filter.daAnno(getInteger(fascicoloAnnoDal))
        }
        String fascicoloAnnoAl = getFascicoloAnnoAl(xml)
        if(fascicoloAnnoAl) {
            filter.aAnno(getInteger(fascicoloAnnoAl))
        }
        String oggetto = getFascicoloOggetto(xml)
        if(oggetto) {
            filter.haOggetto(oggetto)
        }
        String note = getNote(xml)
        if(note) {
            filter.haNote(note)
        }
        String statoFascicolo = getStatoFascicolo(xml)
        if(statoFascicolo) {
            filter.haStato(statoFascicolo)
        }
        Date dataAperturaDal = getDataAperturaDal(xml)
        if(dataAperturaDal) {
            filter.daDataApertura(dataAperturaDal)
        }
        Date dataAperturaAl = getDataAperturaAl(xml)
        if(dataAperturaAl) {
            filter.aDataApertura(dataAperturaAl)
        }
        Date dataChiusuraDal = getDataChiusuraDal(xml)
        if(dataChiusuraDal) {
            filter.daDataChiusura(dataChiusuraDal)
        }
        Date dataChiusuraAl = getDataChiusuraAl(xml)
        if(dataChiusuraAl) {
            filter.aDataChiusura(dataChiusuraAl)
        }
        Date dataCreazioneDal = getDataCreazioneDal(xml)
        if(dataCreazioneDal) {
            filter.daDataCreazione(dataCreazioneDal)
        }
        Date dataCreazioneAl = getDataCreazioneAl(xml)
        if(dataCreazioneAl) {
            filter.aDataCreazione(dataCreazioneAl)
        }
        String codiceAmministrazione = getCodiceAmministrazione(xml)
        if(codiceAmministrazione) {
            filter.haAmministrazione(codiceAmministrazione)
        }
        String codiceAoo = getCodiceAoo(xml)
        if(codiceAoo) {
            filter.haAoo(codiceAoo)
        }
        String fascicoloNumeroDal = getFascicoloNumeroDal(xml)
        if(fascicoloNumeroDal) {
            filter.numeroDal(fascicoloService.numeroOrdinato(fascicoloNumeroDal))
        }
        String fascicoloNumeroAl = getFascicoloNumeroAl(xml)
        if(fascicoloNumeroAl) {
            filter.numeroA(fascicoloService.numeroOrdinato(fascicoloNumeroAl))
        }
        String statoScarto = getStatoScarto(xml)
        if(statoScarto) {
            filter.haStatoScarto(statoScarto)
        }
        String ufficioCompetenza = getUfficioCompetenza(xml)
        if(ufficioCompetenza) {
            filter.haUnitaCompetenza(ufficioCompetenza)
        }
        String ufficioCreazione = getUfficioCreazione(xml)
        if(ufficioCreazione) {
            filter.haUnitaCreazione(ufficioCreazione)
        }
        String utenteCreazione = getUtenteCreazione(xml)
        if(utenteCreazione) {
            filter.haUtenteCreazione(utenteCreazione)
        }
        Date dataScartoDal = getDataScartoDal(xml)
        Date dataScartoAl = getDataScartoAl(xml)
        if(dataScartoDal && dataChiusuraAl) {
            filter.dataScartoDalAl(dataScartoDal,dataScartoAl)
        }
        def fascicoli = fascicoloService.findByFilter(filter)
        resp.fascicolo = fascicoli.collect {toWs(it)}
        return toXml(resp)
    }

    private it.finmatica.protocollo.integrazioni.docAreaExtended.Fascicolo toWs(Fascicolo fasc) {
        it.finmatica.protocollo.integrazioni.docAreaExtended.Fascicolo res = new it.finmatica.protocollo.integrazioni.docAreaExtended.Fascicolo()
        res.classcod = fasc.classificazione.codice
        res.classdal = formatDate(fasc.classificazione.dal)
        res.fascicolonumero = fasc.numero
        res.fascicoloanno = fasc.anno
        res.fascicolooggetto = fasc.oggetto
        res.note = fasc.note
        res.statofascicolo = fasc.stato
        res.dataapertura = formatDate(fasc.dataApertura)
        res.datachiusura = formatDate(fasc.dataChiusura)
        res.datacreazione = formatDate(fasc.dateCreated)
        res.codiceamministrazione = fasc.ente.amministrazione.codice
        res.codiceaoo = fasc.ente.aoo
        res.utentecreazione = fasc.utenteIns.nominativo
        res.iddocumento = fasc.id
        res.statofascicolo = fasc.statoFascicolo
        res.note = fasc.note
        return res
    }

    @CompileDynamic
    String getFascicoloNumeroDal(Node node) {
        node.FASCICOLO_NUMERO_DAL?.text()
    }

    @CompileDynamic
    String getFascicoloNumeroAl(Node node) {
        node.FASCICOLO_NUMERO_AL?.text()
    }

    @CompileDynamic
    String getFascicoloNumero(Node node) {
        node.FASCICOLO_NUMERO?.text()
    }

    @CompileDynamic
    String getFascicoloAnnoDal(Node node) {
        node.FASCICOLO_ANNO_DAL?.text()
    }

    @CompileDynamic
    String getFascicoloAnnoAl(Node node) {
        node.FASCICOLO_ANNO_AL?.text()
    }

    @CompileDynamic
    String getFascicoloOggetto(Node node) {
        node.FASCICOLO_OGGETTO?.text()
    }

    @CompileDynamic
    String getStatoScarto(Node node) {
        node.STATO_SCARTO?.text()
    }

    @CompileDynamic
    String getStatoFascicolo(Node node) {
        node.STATO_FASCICOLO?.text()
    }
    @CompileDynamic
    String getUfficioCompetenza(Node node) {
        node.UFFICIO_COMPETENZA?.text()
    }
    @CompileDynamic
    String getUfficioCreazione(Node node) {
        node.UFFICIO_CREAZIONE?.text()
    }
    @CompileDynamic
    String getUtenteCreazione(Node node) {
        node.UTENTE_CREAZIONE?.text()
    }
    @CompileDynamic
    Date getDataAperturaDal(Node node) {
        getDate(node.DATA_APERTURA_DAL?.text())
    }
    @CompileDynamic
    Date getDataAperturaAl(Node node) {
        getDate(node.DATA_APERTURA_AL?.text())
    }
    @CompileDynamic
    Date getDataScartoDal(Node node) {
        getDate(node.DATA_STATO_SCARTO_DAL?.text())
    }
    @CompileDynamic
    Date getDataScartoAl(Node node) {
        getDate(node.DATA_STATO_SCARTO_AL?.text())
    }
    @CompileDynamic
    Date getDataChiusuraDal(Node node) {
        getDate(node.DATA_CHIUSURA_DAL?.text())
    }
    @CompileDynamic
    Date getDataChiusuraAl(Node node) {
        getDate(node.DATA_CHIUSURA_AL?.text())
    }
    @CompileDynamic
    Date getDataCreazioneDal(Node node) {
        getDate(node.DATA_CREAZIONE_DAL?.text())
    }
    @CompileDynamic
    Date getDataCreazioneAl(Node node) {
        getDate(node.DATA_CREAZIONE_AL?.text())
    }
    @CompileDynamic
    String getCodiceAmministrazione(Node node) {
        node.CODICE_AMMINISTRAZIONE?.text()
    }
    @CompileDynamic
    String getCodiceAoo(Node node) {
        node.CODICE_AOO?.text()
    }
/* stato fascicolo
        RR Con richiesta di scarto rifiutata
        CO Conservato
        AA In attesa di approvazione dello scarto
        PS Proposto per lo scarto
        SC Scartato
        ** default
    */


}
