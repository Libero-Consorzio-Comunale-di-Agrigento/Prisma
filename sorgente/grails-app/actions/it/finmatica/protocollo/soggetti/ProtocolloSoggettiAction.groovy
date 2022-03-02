package it.finmatica.protocollo.soggetti

import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.Attore
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired

/**
 *
 * Created by esasdelli on 02/02/2017.
 */
@Action
class ProtocolloSoggettiAction {

    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService
    @Autowired
    StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService
    @Autowired
    So4Repository so4Repository
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository

    @Action(tipo = Action.TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna TRUE se il documento ha l'Unità Protocollante",
            descrizione = "Ritorna TRUE se il documento ha l'Unità Protocollante")
    boolean haUnitaProtocollante(Protocollo documento) {
        return documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE) != null
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna l'Unità Protocollante",
            descrizione = "Ritorna l'Unità Protocollante (se presente)")
    List<Attore> getUnitaProtocollante(Protocollo documento) {
        if(documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE) == null){
            return []
        }
        return [new Attore(unitaSo4: documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4)]
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna l'Ufficio Esibente (se presente)",
            descrizione = "Ritorna l'Ufficio Esibente (se non è presente viene restituita l'Uo Protocollante)")
    List<Attore> getUnitaUfficioEsibente(Protocollo documento) {

        DocumentoSoggetto soggetto = documento.getSoggetto(TipoSoggetto.UO_ESIBENTE)
        if (!soggetto) {
            soggetto = documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)
        }
        return [new Attore(unitaSo4: soggetto?.unitaSo4)]
    }

    /*
     *   Attore: se il campo ufficio esibente è vuoto, la lettera torni per l'invio sulla scrivania del solo utente REDATTORE, se invece il campo ufficio esibente è valorizzato deve tornare a tutti gli utenti AGPRED dell'unità indicata.
     */

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna i redattori dell'Ufficio Esibente se valorizzato, altrimenti il solo utente redattore",
            descrizione = "Ritorna gli utenti con ruolo AGPRED dell'Ufficio Esibente se valorizzato, altrimenti il solo utente redattore")
    List<Attore> getRedattoriUfficioEsibenteORedattore(Protocollo documento) {

        DocumentoSoggetto soggetto = documento.getSoggetto(TipoSoggetto.UO_ESIBENTE)
        if (!soggetto) {
            return [new Attore(utenteAd4: documento.getSoggetto(TipoSoggetto.REDATTORE)?.utenteAd4)]
        }
        return [new Attore(unitaSo4: soggetto?.unitaSo4, ruoloAd4: Ad4Ruolo.get(ImpostazioniProtocollo.RUOLO_REDATTORE.valore))]
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna l'Unità e Il Ruolo dei destinatari dello step finale",
            descrizione = "Ritorna l'Unità e Il Ruolo dei destinatari dello step finale configurati nel dizionario del Tipo Protocollo")
    List<Attore> getUnitaDestinataria(Protocollo documento) {

        return [new Attore(unitaSo4: documento.tipoProtocollo?.unitaDestinataria, ruoloAd4: documento.tipoProtocollo?.ruoloUoDestinataria)]
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna l'Utente Corrente",
            descrizione = "Ritorna l'Utente Corrente")
    List<Attore> getUtenteCorrente(Protocollo documento) {

        return [new Attore(utenteAd4: springSecurityService.currentUser)]
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna l'Unità Protocollante e l'Ufficio Esibente",
            descrizione = "Ritorna l'Unità Protocollante e l'Ufficio Esibente")
    List<Attore> getUnitaProtocollanteEUfficioEsibente(Protocollo documento) {

        List<Attore> attori = new ArrayList<Attore>()
        attori.add(new Attore(unitaSo4: documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4))
        So4UnitaPubb esibente = documento.getSoggetto(TipoSoggetto.UO_ESIBENTE)?.unitaSo4
        if (esibente) {
            attori.add(new Attore(unitaSo4: esibente))
        }
        return attori
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna l'Unità Protocollante e il Redattore",
            descrizione = "Ritorna l'Unità Protocollante e il Redattore")
    List<Attore> getUnitaProtocollanteERedattore(Protocollo documento) {

        return [new Attore(unitaSo4: documento.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4),
                new Attore(utenteAd4: documento.getSoggetto(TipoSoggetto.REDATTORE)?.utenteAd4)]
    }

    @Action(tipo = Action.TipoAzione.CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna tutti gli utenti che hanno competenza alla creazione della PEC da messaggio arrivo",
            descrizione = "Ritorna tutti gli utenti che hanno competenza alla creazione della PEC da messaggio arrivo")
    List<Attore> getAttoriCreazionePec(Protocollo documento) {
        List<Attore> listaAttori = []

        //Recupero il messaggio dal protocollo
        MessaggioRicevuto messaggioRicevuto = documentoCollegatoRepository.collegamentoPadrePerTipologia(documento, TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))?.documento

        if (messaggioRicevuto != null) {
            List<String> listaIndirizziMailMessaggio
            listaIndirizziMailMessaggio = messaggiRicevutiService.getListaEmailDaIndirizzi(messaggioRicevuto.destinatari) +
                    messaggiRicevutiService.getListaEmailDaIndirizzi(messaggioRicevuto.destinatariConoscenza)
            List<So4IndirizzoTelematico> listaIndirizziEnte = strutturaOrganizzativaProtocolloService.getListaIndirizziEnte()
            String indizizzoIstituzionale = listaIndirizziEnte.find { it.tipoEntita == "AO" }?.indirizzo

            List<Ente> enteValido = Ente.findAllByValido(true, [sort: 'sequenza', order: 'asc'])

            //Inserisco tutti gli utenti con Privilegio PMAILT
            for (utente in privilegioUtenteService.getAllUtenti(PrivilegioUtente.PMAILT)) {
                listaAttori.add(new Attore(utenteAd4: utente))
            }
            //Inserisco tutti gli utenti con Privilegio PMAILI se non ci sono destinatari oppure fra i destinatari c'è l'indirizzo istituzionale
            if (listaIndirizziMailMessaggio.size() == 0 || listaIndirizziMailMessaggio.contains(indizizzoIstituzionale)) {
                for (utente in privilegioUtenteService.getAllUtenti(PrivilegioUtente.PMAILI)) {
                    listaAttori.add(new Attore(utenteAd4: utente))
                }
            }
            //per tutti gli utenti che hanno privilegio PrivilegioUtente.PMAILU su almeno una unità della ListaUnitaMailMessaggio  (partire però ciclando
            //la lista ListaUnitaMailMessaggio e cercando gli utenti che abbiano PMAILU su di essa, non il contrario)
            if (enteValido?.size() > 0) {
                for (indirizzoMailMessaggio in listaIndirizziMailMessaggio) {
                    List<So4UnitaPubb> listaUnitaPerIndirizzo = so4Repository.getListaUnitaIndirizzo(indirizzoMailMessaggio, enteValido.get(0).amministrazione, enteValido.get(0).aoo)

                    if (listaUnitaPerIndirizzo != null) {
                        for (unita in listaUnitaPerIndirizzo) {
                            for (utente in privilegioUtenteService.getAllUtenti(PrivilegioUtente.PMAILU, unita.codice)) {
                                listaAttori.add(new Attore(utenteAd4: utente))
                            }
                        }
                    }
                }
            }
        }

        return listaAttori
    }
}
