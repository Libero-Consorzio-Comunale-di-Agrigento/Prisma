package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamento
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamentoDTO
import it.finmatica.protocollo.documenti.annullamento.StatoAnnullamento
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.viste.Riferimento
import it.finmatica.protocollo.documenti.viste.RiferimentoService
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional


@Slf4j
@Transactional
@Service
class AnnullamentoService {

    @Autowired
    ProtocolloAnnullamentoRepository protocolloAnnullamentoRepository
    @Autowired
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    DateService dateService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    NotificheService notificheService
    @Autowired
    RiferimentoService riferimentoService
    @Autowired
    ProtocolloPkgService protocolloPkgService

    private List<String> categorie = [Protocollo.CATEGORIA_LETTERA, Protocollo.CATEGORIA_PEC, Protocollo.CATEGORIA_EMERGENZA, Protocollo.CATEGORIA_PROTOCOLLO]

    /**
     *
     * @param testoRicerca
     * @param orderMap
     * @return
     */
    public List<Protocollo> caricaProtocolliDaAnnnullare(String testoRicerca, HashMap<String, String> orderMap) {
        List<Protocollo> protocolliDaAnnullare = getProtocolliDaAnnullare(testoRicerca, orderMap)
        //Filtra su competenze in lettura
        List<Protocollo> protocolliDaAnnullareFinal = new ArrayList<Protocollo>()
        for (Protocollo protocollo : protocolliDaAnnullare) {
            if (gestoreCompetenze.verificaCompetenzeLettura(protocollo)) {
                protocolliDaAnnullareFinal.add(protocollo)
            }
        }
        protocolliDaAnnullareFinal
    }

    /**
     *
     * @param testoRicerca
     * @param orderMap
     * @return
     */
    List<Protocollo> getProtocolliDaAnnullare(String testoRicerca, HashMap<String, String> orderMap ) {
        testoRicerca ="%"+testoRicerca+"%"
        // numeri contenuti nella stringa di ricerca
        Integer numeroRicerca = testoRicerca.replaceAll("\\D+", "") != "" ? new Integer(testoRicerca.replaceAll("\\D+", "")) : 0

        String queryConOrdinamento = creaQueryStringConOrder(orderMap)

        List<Protocollo> protocolliDaAnnullare =  protocolloAnnullamentoRepository.getProtocolliDaAnnulare(queryConOrdinamento, categorie, StatoDocumento.DA_ANNULLARE, StatoAnnullamento.ACCETTATO, testoRicerca, numeroRicerca, TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO )
        return protocolliDaAnnullare
    }

    /**
     * Ritorna la queryString dei protocolli da annullare concatenata con l'order by selezionato
     *
     * @param orderMap
     * @return
     */
    private String creaQueryStringConOrder(HashMap<String, String> orderMap) {
        String order = ""
        for (Map.Entry<String, String> entry : orderMap.entrySet()) {
            order = order.concat(entry.getKey() + " " + entry.getValue().concat(","))
        }
        order = order.substring(0, order.length() - 1)

        return protocolloAnnullamentoRepository.getQueryStringProtocolloDaAnnullare().concat("order by " + order)
    }

    /**
     * Ricerca un protocollo da annullare
     *
     * @param anno
     * @param numero
     * @param codiceTipoRegistro
     * @return
     */
    ProtocolloAnnullamento getProtocolloDaAnnullare(Integer anno, Integer numero, String codiceTipoRegistro){
        Protocollo protocollo =  protocolloAnnullamentoRepository.getProtocolloDaAnnullare(categorie, StatoDocumento.DA_ANNULLARE, StatoAnnullamento.ACCETTATO, anno, numero, codiceTipoRegistro, TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO )
        return null != protocollo ? getProtocolloAnnullamentoByProtocollo(protocollo) : null
    }


    ProtocolloAnnullamento getProtocolloAnnullamentoByProtocollo(Protocollo protocollo){
        return  ProtocolloAnnullamento.findByProtocollo(protocollo)
    }

    /**
     * Annulla i protocolli collegati al provvedimento
     * Per ogni protocollo da annullare:
     * -Storicizza gli smistamenti ancora attivi
     * -elimana le notifiche
     * -annulla l'eventuale albo collegato
     *
     * @param protocollo
     */
    void annullaProtocollo(Protocollo protocollo){
        for(DocumentoCollegato docCollegato : protocollo.documentiCollegati) {
            //filtro solo i provvedimenti di annullamento
            if(docCollegato.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO){
                Protocollo protocolloCollegato = docCollegato.collegato
                protocolloCollegato.dataAnnullamento = dateService.getCurrentDate()
                protocolloCollegato.annullato = true
                protocolloCollegato.utenteAnnullamento = springSecurityService.currentUser
                protocolloCollegato.stato = StatoDocumento.ANNULLATO
                //Storicizza smistamenti del protocollo da annullare
                for (Smistamento smistamento : protocolloCollegato.smistamentiValidi) {
                    if (smistamento.statoSmistamento != Smistamento.STORICO) {
                        smistamentoService.storicizzaSmistamento(smistamento)
                    }
                }
                //Elimina le notifiche del protocollo da annullare
                notificheService.eliminaNotifica(null, protocolloCollegato.idDocumentoEsterno.toString(), null)
                //Annulla albo collegato, se esiste
                ProtocolloAnnullamento pa = ProtocolloAnnullamento.findByProtocollo(protocolloCollegato)
                Riferimento riferimentoAlboCollegato = riferimentoService.getRiferimentoAlboCollegato(pa.protocollo.idDocumentoEsterno)
                if (riferimentoAlboCollegato != null) {
                    protocolloPkgService.annullaAlbo(riferimentoAlboCollegato.idRiferimento, pa.protocollo.dataAnnullamento, pa.protocollo.utenteAnnullamento.id, pa.motivo)
                }
                protocolloService.salva(protocolloCollegato, false)
            }
        }
    }


    /**
     *
     * Verifica su un documento è gia presente in lista da annullare
     *
     * @param protocolloAnnullamentoDTO
     * @return
     */
    private boolean isPresenteInListaDaAnnullare(ProtocolloAnnullamentoDTO protocolloDaAnnullare, List<ProtocolloAnnullamentoDTO> listaProtocolliAnnullamento) {
        for(ProtocolloAnnullamentoDTO protocolloAnnullamento : listaProtocolliAnnullamento) {
            if(protocolloAnnullamento.id == protocolloDaAnnullare.id) {
                return true
            }
        }
        return false
    }

    /**
     * Verifico se ho gia' inserito il collegato nel set non lo inserisco
     * questo perche' l'id==null fa si che lo veda ogni volta come nuovo, duplicando i documenti collegati in fase di salvataggio.
     *
     * @param protocolloAnnullamento
     * @param protocollo
     * @return
     */
    private boolean collegatoPresenteInLista(ProtocolloAnnullamentoDTO protocolloAnnullamento, Protocollo protocollo) {
        for(DocumentoCollegato docCollegato : protocollo.documentiCollegati) {
            if(docCollegato.collegato == protocolloAnnullamento.protocollo.domainObject) {
                return true
            }
        }
        return false
    }
}