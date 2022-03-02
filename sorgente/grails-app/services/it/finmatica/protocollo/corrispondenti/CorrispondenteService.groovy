package it.finmatica.protocollo.corrispondenti

import groovy.sql.Sql
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.as4.anagrafica.As4AnagraficaDTO
import it.finmatica.as4.anagrafica.As4ContattoDTO
import it.finmatica.as4.anagrafica.As4RecapitoDTO
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.protocollo.dizionari.ListaDistribuzione
import it.finmatica.protocollo.dizionari.ListaDistribuzioneDTO
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import oracle.jdbc.OracleTypes
import org.apache.commons.lang.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

@Service
class CorrispondenteService {

    @Autowired
    DataSource dataSource
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    NotificheService notificheService
    @Autowired
    RegoleCalcoloNotificheProtocolloRepository regoleCalcoloNotificheProtocolloRepository
    @Autowired
    CorrispondenteRepository corrispondenteRepository

    /*
     * sql: SELECT SEG_ANAGRAFICI_PKG.RICERCA ( 'ROSSI', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL )
     * 	   FROM DUAL
     *
     */

    List<CorrispondenteDTO> ricercaPiDenom(String cf_or_pi,
                                           String denomimazione,
                                           boolean ritornaSoloSeUnico) {
        Sql sql = new groovy.sql.Sql(dataSource)
        List<CorrispondenteDTO> resultList = []
        CorrispondenteDTO corrispondente

        int soloUnico = 0
        if (ritornaSoloSeUnico) {
            soloUnico = 1
        }

        if (cf_or_pi == null) {
            cf_or_pi = ""
        }
        if (denomimazione == null) {
            denomimazione = ""
        }

        sql.call("""BEGIN 
                          ? := SEG_ANAGRAFICI_PKG.ricerca_per_cf_pi_den (?,?,?);
                        END; """,
                [Sql.resultSet(OracleTypes.CURSOR), cf_or_pi, denomimazione, soloUnico]) {
            cursorResults ->
                cursorResults.eachRow { result ->
                    corrispondente = buildCorrispondente(result)
                    resultList << corrispondente
                }
        }

        return resultList
    }

    List<CorrispondenteDTO> ricercaDestinatari(String ricerca,
                                               boolean isQuery,
                                               String denominazione = null,
                                               String indirizzo = null,
                                               String codiceFiscale = null,
                                               String partitaIva = null,
                                               String email = null,
                                               Date dal = null,
                                               TipoSoggettoDTO tipoSoggetto = null,
                                               String codiceFiscaleEstero = null,
                                               String tipoRicercaDenominazione = null,
                                               String codAmm = null,
                                               String codAoo = null,
                                               String codUo = null,
                                               String ni = null,
                                               boolean bEscludiRicercaNi = false) {

        Sql sql = new groovy.sql.Sql(dataSource)
        List<CorrispondenteDTO> resultList = []
        CorrispondenteDTO corrispondente

        if (ni != null) {
            //Ricerca per NI diretto
            //Ricerca per aoo amm uo
            sql.call("""BEGIN 
                          ? := SEG_ANAGRAFICI_PKG.ricerca_per_ni (?,?);
                        END; """,
                    [Sql.resultSet(OracleTypes.CURSOR), ni, (tipoSoggetto?.id == null) ? -1 : tipoSoggetto?.id]) {
                cursorResults ->
                    cursorResults.eachRow { result ->
                        corrispondente = buildCorrispondente(result)
                        resultList << corrispondente
                    }
            }
        } else if (codAmm == null && codAoo == null && codUo == null) {
            //Ricerca per generica
            String isQueryS = isQuery ? "Y" : "N"

            if (ricerca == null) {
                isQueryS = "ISQUERY"
            }

            if (tipoRicercaDenominazione == "LIBERA") {
                tipoRicercaDenominazione = null
            }

            int escludiRicercaNi = 0
            if (bEscludiRicercaNi) {
                escludiRicercaNi = 1
            }

            sql.call("""BEGIN 
                          ? := SEG_ANAGRAFICI_PKG.RICERCA (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                        END; """,
                    [Sql.resultSet(OracleTypes.CURSOR), ricerca, isQueryS, denominazione, indirizzo, codiceFiscale, partitaIva, email, dal, (tipoSoggetto?.id == null) ? -1 : tipoSoggetto?.id, codiceFiscaleEstero, tipoRicercaDenominazione, escludiRicercaNi]) {
                cursorResults ->
                    cursorResults.eachRow { result ->
                        corrispondente = buildCorrispondente(result)
                        resultList << corrispondente
                    }
            }
        } else {
            //Ricerca per aoo amm uo
            sql.call("""BEGIN 
                          ? := SEG_ANAGRAFICI_PKG.ricerca_per_amm (?, ?, ?);
                        END; """,
                    [Sql.resultSet(OracleTypes.CURSOR), codAmm, codAoo, codUo]) {
                cursorResults ->
                    cursorResults.eachRow { result ->
                        corrispondente = buildCorrispondente(result)
                        resultList << corrispondente
                    }
            }
        }

        return resultList
    }

    private CorrispondenteDTO buildCorrispondente(corrispondente) {

        CorrispondenteDTO corrispondenteDTO = new CorrispondenteDTO()
        corrispondenteDTO.tipoSoggetto = TipoSoggetto.get(corrispondente.getAt('TIPO_SOGGETTO').longValue()).toDTO()
        corrispondenteDTO.denominazione = corrispondente.getAt('DENOMINAZIONE') == "" ? null : corrispondente.getAt('DENOMINAZIONE')
        corrispondenteDTO.indirizzo = corrispondente.getAt('INDIRIZZO') == "" ? null : corrispondente.getAt('INDIRIZZO')
        corrispondenteDTO.email = corrispondente.getAt('EMAIL') == "" ? null : (corrispondente.getAt('EMAIL')?.trim())
        corrispondenteDTO.partitaIva = corrispondente.getAt('PARTITA_IVA') == "" ? null : corrispondente.getAt('PARTITA_IVA')
        corrispondenteDTO.codiceFiscale = corrispondente.getAt('CODICE_FISCALE') == "" ? null : corrispondente.getAt('CODICE_FISCALE')
        corrispondenteDTO.idFiscaleEstero = corrispondente.getAt('CF_ESTERO') == "" ? null : corrispondente.getAt('CF_ESTERO')
        corrispondenteDTO.fax = corrispondente.getAt('FAX')
        corrispondenteDTO.comune = corrispondente.getAt('COMUNE')
        corrispondenteDTO.cap = corrispondente.getAt('CAP')
        corrispondenteDTO.provinciaSigla = corrispondente.getAt('PROVINCIA_SIGLA')
        corrispondenteDTO.nome = corrispondente.getAt('NOME')
        corrispondenteDTO.cognome = corrispondente.getAt('COGNOME')

        // da usare per comporre l'immagine
        corrispondenteDTO.anagrafica = corrispondente.getAt('ANAGRAFICA')?.toUpperCase()
        corrispondenteDTO.tipoIndirizzo = corrispondente.getAt('TIPO_INDIRIZZO')

        // utili per il dettaglio delle Amministrazioni
        corrispondenteDTO.codiceAmministrazione = corrispondente.getAt('COD_AMM')
        corrispondenteDTO.aoo = corrispondente.getAt('COD_AOO')
        corrispondenteDTO.uo = corrispondente.getAt('COD_UO')

        def ni = corrispondente.getAt('NI')
        if (ni != null) {
            if (ni.class == String) {
                corrispondenteDTO.ni = new Long(ni)
            } else {
                corrispondenteDTO.ni = ni.longValue()
            }
        }
        return corrispondenteDTO
    }

    List<IndirizzoDTO> getIndirizziAmministrazione(String codiceAmministrazione,
                                                   String aoo,
                                                   String uo) {
        Sql sql = new groovy.sql.Sql(dataSource)
        List<IndirizzoDTO> resultList = []
        IndirizzoDTO indirizzo

        sql.call("""BEGIN 
					  ? := SEG_ANAGRAFICI_PKG.GET_INDIRIZZI_AMM (?, ?, ?);
					END; """,
                [Sql.resultSet(OracleTypes.CURSOR), codiceAmministrazione, aoo, uo]) {
            cursorResults ->
                cursorResults.eachRow { result ->

                    indirizzo = new IndirizzoDTO()
                    indirizzo.indirizzo = result.getAt('INDIRIZZO')
                    indirizzo.tipoIndirizzo = result.getAt('TIPO_INDIRIZZO')
                    indirizzo.cap = result.getAt('CAP')
                    indirizzo.fax = result.getAt('FAX')
                    indirizzo.email = result.getAt('EMAIL')?.trim()
                    indirizzo.comune = result.getAt('COMUNE')
                    indirizzo.provinciaSigla = result.getAt('provincia_sigla')
                    indirizzo.codice = result.getAt('CODICE')
                    indirizzo.denominazione = result.getAt('DESCRIZIONE')

                    resultList << indirizzo
                }
        }
        return resultList
    }

    @Transactional
    Set<Corrispondente> salva(Protocollo protocollo, List<CorrispondenteDTO> corrispondentiDTO, boolean listaDistribuzione = false, boolean escludiControlloCompentenze = false) {

        if (protocollo.movimento == null) {
            return
        }

        //Prima di inserire salvo il primo corrispondente in lista protocollo, serve per verificare se aggiornare la notifica
        String primoDestinatarioOriginale = regoleCalcoloNotificheProtocolloRepository.getPrimoDestinatario(protocollo)

        for (CorrispondenteDTO corrispondenteDTO : corrispondentiDTO) {

            salvaCorrispondente(corrispondenteDTO, protocollo, listaDistribuzione, escludiControlloCompentenze)
            protocollo.save()
        }

        //verifica se aggiornare notifica
        String primoDestinatario = regoleCalcoloNotificheProtocolloRepository.getPrimoDestinatario(protocollo)
        verificaAggiornaNotifiche(primoDestinatario, primoDestinatarioOriginale, protocollo)
        return protocollo.corrispondenti
    }

    @Transactional
    List<Corrispondente> salvaPerInvio(Protocollo protocollo, List<CorrispondenteDTO> corrispondentiDTO, boolean listaDistribuzione = false, boolean escludiControlloCompentenze = false) {

        if (protocollo.movimento == null) {
            return
        }

        //Prima di inserire salvo il primo corrispondente in lista protocollo, serve per verificare se aggiornare la notifica
        String primoDestinatarioOriginale = regoleCalcoloNotificheProtocolloRepository.getPrimoDestinatario(protocollo)

        List<Corrispondente> corrispondenteList = new ArrayList<Corrispondente>()
        for (CorrispondenteDTO corrispondenteDTO : corrispondentiDTO) {

            Corrispondente c = salvaCorrispondente(corrispondenteDTO, protocollo, listaDistribuzione, escludiControlloCompentenze)
            protocollo.save()
            corrispondenteList.add(c)
        }

        //verifica se aggiornare notifica
        String primoDestinatario = regoleCalcoloNotificheProtocolloRepository.getPrimoDestinatario(protocollo)
        verificaAggiornaNotifiche(primoDestinatario, primoDestinatarioOriginale, protocollo)
        return corrispondenteList
    }

    @Transactional
    Corrispondente salvaCorrispondente(CorrispondenteDTO corrispondenteDTO, Protocollo protocollo, boolean listaDistribuzione, boolean escludiControlloCompentenze) {
        Corrispondente corrispondente = corrispondenteDTO?.domainObject
        if (corrispondente == null) {
            corrispondente = new Corrispondente()
            protocollo.addToCorrispondenti(corrispondente)
        }

        corrispondente.barcodeSpedizione = corrispondenteDTO.barcodeSpedizione
        corrispondente.cap = corrispondenteDTO.cap
        corrispondente.cognome = corrispondenteDTO.cognome
        corrispondente.comune = corrispondenteDTO.comune
        corrispondente.conoscenza = corrispondenteDTO.conoscenza
        corrispondente.dataSpedizione = corrispondenteDTO.dataSpedizione
        corrispondente.denominazione = corrispondenteDTO.denominazione
        corrispondente.email = corrispondenteDTO.email?.trim()
        corrispondente.fax = corrispondenteDTO.fax
        corrispondente.indirizzo = corrispondenteDTO.indirizzo
        corrispondente.tipoIndirizzo = corrispondenteDTO.tipoIndirizzo
        corrispondente.nome = corrispondenteDTO.nome
        corrispondente.partitaIva = corrispondenteDTO.partitaIva
        corrispondente.codiceFiscale = corrispondenteDTO.codiceFiscale
        corrispondente.idFiscaleEstero = corrispondenteDTO.idFiscaleEstero
        corrispondente.provinciaSigla = corrispondenteDTO.provinciaSigla
        corrispondente.idDocumentoEsterno = corrispondenteDTO.idDocumentoEsterno
        corrispondente.tipoSoggetto = corrispondenteDTO.tipoSoggetto?.domainObject
        corrispondente.suap = (corrispondenteDTO.suap)?corrispondenteDTO.suap:false

        corrispondente.dataSpedizione = corrispondenteDTO.dataSpedizione
        corrispondente.quantita = corrispondenteDTO.quantita
        corrispondente.costoSpedizione = corrispondenteDTO.costoSpedizione
        corrispondente.barcodeSpedizione = corrispondenteDTO.barcodeSpedizione
        corrispondente.modalitaInvioRicezione = corrispondenteDTO.modalitaInvioRicezione?.domainObject

        if (!StringUtils.isEmpty(corrispondente.cognome?.trim()) && corrispondente.tipoSoggetto?.id != 2) {
            corrispondente.denominazione = corrispondente.cognome.concat(" ").concat(corrispondente.nome != null ? corrispondente.nome : "").trim()
        }

        if (protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
            corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO
        } else if (protocollo.movimento == Protocollo.MOVIMENTO_ARRIVO || protocollo.movimento == Protocollo.MOVIMENTO_INTERNO) {
            corrispondente.tipoCorrispondente = Corrispondente.MITTENTE
        }

        // default della modalita invio ricezione = posta ordinaria
        if (corrispondenteDTO?.modalitaInvioRicezione == null) {
            corrispondente.modalitaInvioRicezione = corrispondenteDTO.modalitaInvioRicezione?.domainObject ?: ModalitaInvioRicezione.findByCodice(ModalitaInvioRicezione.CODICE_POSTA_ORDINARIA)
        }

        corrispondente.save()

        if (!listaDistribuzione) {
            // se ci sono degli indirizzi è inutile recuperarli dal package
            if (corrispondenteDTO.indirizzi == null || corrispondenteDTO.indirizzi.size() == 0) {
                corrispondenteDTO.indirizzi = this.getIndirizziAmministrazione(corrispondenteDTO.codiceAmministrazione, corrispondenteDTO.aoo, corrispondenteDTO.uo)
            }
            for (IndirizzoDTO indirizzoDTO : corrispondenteDTO.indirizzi) {

                Indirizzo indirizzo = (indirizzoDTO.id != null) ? Indirizzo.get(indirizzoDTO.id) : new Indirizzo()
                indirizzo.cap = indirizzoDTO.cap
                indirizzo.codice = indirizzoDTO.codice
                indirizzo.comune = indirizzoDTO.comune
                indirizzo.denominazione = indirizzoDTO.denominazione
                indirizzo.email = indirizzoDTO.email?.trim()
                indirizzo.indirizzo = indirizzoDTO.indirizzo
                indirizzo.provinciaSigla = indirizzoDTO.provinciaSigla
                indirizzo.tipoIndirizzo = indirizzoDTO.tipoIndirizzo
                indirizzo.corrispondente = corrispondente
                indirizzo.save()
                corrispondente.addToIndirizzi(indirizzo)
            }
        } else {
            Indirizzo indirizzo = new Indirizzo()
            indirizzo.cap = corrispondente.cap
            indirizzo.comune = corrispondente.comune
            indirizzo.denominazione = corrispondente.denominazione
            indirizzo.email = corrispondente.email?.trim()
            indirizzo.indirizzo = corrispondente.indirizzo
            indirizzo.provinciaSigla = corrispondente.provinciaSigla
            indirizzo.tipoIndirizzo = corrispondente.tipoIndirizzo
            indirizzo.corrispondente = corrispondente
            if (corrispondente.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE) {
                indirizzo.codice = corrispondenteDTO.codiceAmministrazione
            } else if (corrispondente.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_UO) {
                indirizzo.codice = corrispondenteDTO.uo
            } else if (corrispondente.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_AOO) {
                indirizzo.codice = corrispondenteDTO.aoo
            }
            indirizzo.save()
            corrispondente.addToIndirizzi(indirizzo)
        }

        // allineo i dati su GDM
        protocolloGdmService.salvaCorrispondente(corrispondente, listaDistribuzione, escludiControlloCompentenze)

        corrispondente.save()
        return corrispondente
    }

    private void verificaAggiornaNotifiche(String primoDestinatario, String primoDestinatarioOriginale, Protocollo protocollo) {
        if (primoDestinatario != primoDestinatarioOriginale) {
            notificheService.aggiorna(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, protocollo)
        }
    }

    @Transactional
    void aggiorna(CorrispondenteDTO corrispondenteDTO) {

        Corrispondente corrispondente = corrispondenteDTO?.domainObject

        corrispondente.barcodeSpedizione = corrispondenteDTO.barcodeSpedizione
        corrispondente.cap = corrispondenteDTO.cap
        corrispondente.cognome = corrispondenteDTO.cognome
        corrispondente.comune = corrispondenteDTO.comune
        corrispondente.conoscenza = corrispondenteDTO.conoscenza
        corrispondente.dataSpedizione = corrispondenteDTO.dataSpedizione
        corrispondente.denominazione = corrispondenteDTO.denominazione
        corrispondente.email = corrispondenteDTO.email?.trim()
        corrispondente.fax = corrispondenteDTO.fax
        corrispondente.indirizzo = corrispondenteDTO.indirizzo
        corrispondente.tipoIndirizzo = corrispondenteDTO.tipoIndirizzo
        corrispondente.nome = corrispondenteDTO.nome
        corrispondente.partitaIva = corrispondenteDTO.partitaIva
        corrispondente.codiceFiscale = corrispondenteDTO.codiceFiscale
        corrispondente.provinciaSigla = corrispondenteDTO.provinciaSigla
        corrispondente.idDocumentoEsterno = corrispondenteDTO.idDocumentoEsterno
        corrispondente.tipoSoggetto = corrispondenteDTO.tipoSoggetto?.domainObject

        corrispondente.dataSpedizione = corrispondenteDTO?.dataSpedizione
        corrispondente.quantita = corrispondenteDTO?.quantita
        corrispondente.costoSpedizione = corrispondenteDTO?.costoSpedizione
        corrispondente.barcodeSpedizione = corrispondenteDTO?.barcodeSpedizione
        corrispondente.modalitaInvioRicezione = corrispondenteDTO?.modalitaInvioRicezione?.domainObject

        if (corrispondente.protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
            corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO
        } else if (corrispondente.protocollo.movimento == Protocollo.MOVIMENTO_ARRIVO || corrispondente.protocollo.movimento == Protocollo.MOVIMENTO_INTERNO) {
            corrispondente.tipoCorrispondente = Corrispondente.MITTENTE
        }

        // default della modalita invio ricezione = posta ordinaria
        if (corrispondenteDTO?.modalitaInvioRicezione == null) {
            corrispondente.modalitaInvioRicezione = corrispondenteDTO.modalitaInvioRicezione?.domainObject ?: ModalitaInvioRicezione.findByCodice(ModalitaInvioRicezione.CODICE_POSTA_ORDINARIA)
        }
        // allineo i dati su GDM
        protocolloGdmService.salvaCorrispondente(corrispondente)

        corrispondente.save()
    }

    @Transactional
    void remove(documento, Corrispondente corrispondente) {

        //Prima di rimuovere salvo il primo corrispondente in lista protocollo, serve per verificare se aggiornare la notifica
        String primoDestinatarioOriginale = regoleCalcoloNotificheProtocolloRepository.getPrimoDestinatario(documento)

        if (documento.numero > 0) {

            boolean corrispondenteObbligatorio = (ImpostazioniProtocollo.RAPP_OB.abilitato)
            if (documento.movimento == Protocollo.MOVIMENTO_ARRIVO && corrispondenteObbligatorio) {
                if (documento.corrispondenti.size() == 1) {
                    throw new ProtocolloRuntimeException("Deve esistere almeno un mittente")
                }
            } else if (documento.movimento == Protocollo.MOVIMENTO_PARTENZA) {
                if (documento.corrispondenti.size() == 1) {
                    throw new ProtocolloRuntimeException("Deve esistere almeno un destinatario")
                }
            }
        }

        if (corrispondente != null && documento != null) {
            protocolloGdmService.cancellaDocumento(corrispondente.idDocumentoEsterno?.toString())
            documento.removeFromCorrispondenti(corrispondente)
            corrispondente.delete(failOnError: true)
            documento.save(failOnError: true)
        }

        //verifica se aggiornare notifica
        String primoDestinatario = regoleCalcoloNotificheProtocolloRepository.getPrimoDestinatario(documento)
        verificaAggiornaNotifiche(primoDestinatario, primoDestinatarioOriginale, documento)
    }

    /**
     * sql: SELECT SEG_ANAGRAFICI_PKG.get_COMPONENTI_LISTA  ( -id )
     * 	   FROM DUAL
     *
     **/
    List<CorrispondenteDTO> getComponentiListeDistribuzione(List<ListaDistribuzioneDTO> listeDistribuzione) {

        Sql sql = new groovy.sql.Sql(dataSource)
        List<CorrispondenteDTO> resultList = []

        for (ListaDistribuzione lista : listeDistribuzione) {

            CorrispondenteDTO corrispondente

            sql.call("""BEGIN 
					  ? := SEG_ANAGRAFICI_PKG.get_COMPONENTI_LISTA (?);
					END; """,
                    [Sql.resultSet(OracleTypes.CURSOR), lista.id]) {
                cursorResults ->
                    cursorResults.eachRow { result ->

                        corrispondente = buildCorrispondente(result)
                        resultList << corrispondente
                    }
            }
        }
        return resultList
    }

    public CorrispondenteDTO costruisciCorrispondente(As4AnagraficaDTO soggetto) {

        CorrispondenteDTO corrispondente = new CorrispondenteDTO()
        corrispondente.tipoSoggetto = TipoSoggetto.get(1)?.toDTO()
        corrispondente.cognome = soggetto.cognome?.toUpperCase()
        corrispondente.nome = soggetto.nome?.toUpperCase()
        corrispondente.denominazione = soggetto.cognome?.toUpperCase()

        if (corrispondente.nome != null) {
            corrispondente.denominazione = corrispondente.denominazione + " " + corrispondente.nome
        }

        corrispondente.codiceFiscale = soggetto.codFiscale?.toUpperCase()
        corrispondente.partitaIva = soggetto.partitaIva?.toUpperCase()
        corrispondente.anagrafica = "SOGGETTO"
        return corrispondente
    }

    public void aggiungiContatto(As4ContattoDTO contatto, CorrispondenteDTO corrispondente) {

        corrispondente.indirizzo = contatto.recapito?.indirizzo?.toUpperCase()
        corrispondente.comune = contatto.recapito?.comune?.denominazione?.toUpperCase()
        corrispondente.cap = contatto.recapito?.cap?.toUpperCase()
        corrispondente.tipoIndirizzo = contatto.recapito?.tipoRecapito?.descrizione
        corrispondente.provinciaSigla = contatto.recapito?.provincia?.sigla?.toUpperCase()

        corrispondente.email = contatto.valore?.toUpperCase()

        corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO

        IndirizzoDTO indirizzo = new IndirizzoDTO()
        indirizzo.provinciaSigla = contatto.recapito?.provincia?.sigla?.toUpperCase()
        indirizzo.comune = contatto.recapito?.comune?.denominazione?.toUpperCase()
        indirizzo.indirizzo = contatto.recapito?.indirizzo?.toUpperCase()
        indirizzo.cap = contatto.recapito?.cap?.toUpperCase()
        indirizzo.fax = contatto.valore?.toUpperCase() // ???

        corrispondente.addToIndirizzi(indirizzo)
    }

    public void aggiungiRecapito(As4RecapitoDTO recapito, CorrispondenteDTO corrispondente) {

        corrispondente.indirizzo = recapito?.indirizzo?.toUpperCase()
        corrispondente.comune = recapito?.comune?.denominazione?.toUpperCase()
        corrispondente.cap = recapito?.cap?.toUpperCase()
        corrispondente.tipoIndirizzo = recapito?.tipoRecapito?.descrizione
        corrispondente.provinciaSigla = recapito?.provincia?.sigla?.toUpperCase()

        corrispondente.tipoCorrispondente = Corrispondente.DESTINATARIO

        if (!StringUtils.isEmpty(recapito.indirizzo)) {
            IndirizzoDTO indirizzo = new IndirizzoDTO()
            indirizzo.provinciaSigla = recapito?.provincia?.sigla?.toUpperCase()
            indirizzo.comune = recapito?.comune?.denominazione?.toUpperCase()
            indirizzo.indirizzo = recapito?.indirizzo?.toUpperCase()
            indirizzo.cap = recapito?.cap?.toUpperCase()

            corrispondente.addToIndirizzi(indirizzo)
        }
    }

    List<CorrispondenteDTO> costruisciListaRecapiti(As4AnagraficaDTO soggetto, List<As4RecapitoDTO> recapiti, List<As4ContattoDTO> contatti) {

        List<CorrispondenteDTO> corrispondenti = new ArrayList<CorrispondenteDTO>()
        List<As4RecapitoDTO> recapitiTmp = new ArrayList<As4RecapitoDTO>()

        for (As4ContattoDTO contatto : contatti) {

            CorrispondenteDTO c = costruisciCorrispondente(soggetto)
            aggiungiContatto(contatto, c)
            corrispondenti.add(c)
            recapitiTmp.add(contatto.recapito)
        }

        for (As4RecapitoDTO recapito : recapiti) {

            boolean trovato = false
            for (As4RecapitoDTO recTmp : recapitiTmp) {
                if ((recTmp.descrizione == recapito.descrizione) && (recTmp.tipoRecapito?.id == recapito.tipoRecapito?.id)) {
                    trovato = true
                }
            }
            if (!trovato) {
                CorrispondenteDTO c = costruisciCorrispondente(soggetto)
                aggiungiRecapito(recapito, c)
                corrispondenti.add(c)
            }
        }
        return corrispondenti
    }

    @Transactional(readOnly = true)
    Corrispondente findOne(Long id) {
        corrispondenteRepository.findOne(id)
    }

}