package it.finmatica.protocollo.impostazioni

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.integrazioni.firma.CodaFirma
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestioneiter.Attore
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.motore.WkfAttoreStep
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class FunzioniAvanzateService {

    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    NotificheService notificheService

    void cambiaUtenteDocumenti(documenti, Ad4UtenteDTO utentePrecedenteDto, Ad4UtenteDTO utenteNuovoDto, String tipoSoggetto) {
        Ad4Utente utentePrecedente = utentePrecedenteDto.domainObject
        Ad4Utente utenteNuovo = utenteNuovoDto.domainObject
        for (def documento : documenti) {
            Documento d = Documento.get(documento.id)
            cambiaUtente(d, utentePrecedente, utenteNuovo, tipoSoggetto)
        }
    }

    void cambiaUtente(Documento documento, Ad4Utente utentePrecedente, Ad4Utente nuovoUtente, String tipoSoggetto) {

        // per cambiare il firmatario, il procedimento è:
        // 1) cambiare la tabella firmatari
        // 2) cambiare le competenze
        // 3) cambiare il soggetto sul documento
        // 4) eliminare dalla jworklist (se presente) le notifiche per l'utente vecchio, quindi mettere quelle per l'utente nuovo.

        // 1) cambiare il firmatario sulla tabella dei firmatari (se presente)
        List<CodaFirma> firmatari = CodaFirma.createCriteria().list {
            eq("documento", documento)
            eq("firmato", false)
            eq("firmatario.id", utentePrecedente.id)
        }

        for (CodaFirma f : firmatari) {
            f.firmatario = nuovoUtente
            f.save()
        }

        // 2) cambiare le competenze:
        // rimuovo le competenze in scrittura dell'utente precedente:
        WkfTipoOggetto tipoOggetto = documento.tipoOggetto
        gestoreCompetenze.rimuoviCompetenze(documento, tipoOggetto, new Attore(utenteAd4: utentePrecedente), true, true, false, null)

        // le riassegno in lettura:
        gestoreCompetenze.assegnaCompetenze(documento, tipoOggetto, new Attore(utenteAd4: utentePrecedente), true, false, false, null)

        // assegno le competenze in scrittura all'utente richiesto:
        gestoreCompetenze.assegnaCompetenze(documento, tipoOggetto, new Attore(utenteAd4: nuovoUtente), true, true, false, null)

        // 3) cambio il soggetto:
        if (tipoSoggetto == "UTENTE_IN_CARICO") {
            // se sto cambiando l'utente "in carico", allora ciclo su tutti i soggetti del documento e cambio anche quel soggetto, altrimenti
            // potrei ritrovarmi in situazioni spiacevoli (ad es: il documento è in carico al redattore, ma cambio solo l'incarico e non il soggetto redattore, quindi quando il nuovo utente aprirà il documento
            // avrà il doc in modifica ma non vedrà i pulsanti perché non verrà riconosciuto come l'attore giusto.
            for (DocumentoSoggetto soggetto : documento.soggetti) {
                if (soggetto.utenteAd4?.id == nuovoUtente.id) {
                    documento.setSoggetto(soggetto.tipoSoggetto, nuovoUtente, null, soggetto.sequenza)
                }
            }
        } else {
            documento.setSoggetto(tipoSoggetto, nuovoUtente, null)
        }

        // 4) cambio l'attore dello step:
        def attori = documento.iter.stepCorrente.attori
        for (def a : attori) {
            if (a.utenteAd4.id == utentePrecedente.id) {
                a.utenteAd4 = nuovoUtente
                a.save()
            }
        }

        // elimino le eventuali notifiche esistenti e ricreo le notifiche per il nuovo utente
        if (tipoSoggetto == "FIRMATARIO") {
            notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO_FIRMATARIO, documento.idDocumentoEsterno.toString(), utentePrecedente)
            notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO_FIRMATARIO, documento)
        } else {
            notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, documento.idDocumentoEsterno.toString(), utentePrecedente)
            notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, documento)
        }

        documento.save()
    }

    void cambiaUnitaDocumenti(documenti, So4UnitaPubb unitaSo4Old, So4UnitaPubb unitaSo4New) {
        for (Documento documento : documenti) {
            Documento d = Documento.get(documento.id)
            cambiaUnita(d, unitaSo4Old, unitaSo4New)
        }
    }

    void cambiaUnita(Documento documento, So4UnitaPubb unitaPrecedente, So4UnitaPubb nuovaUnita) {
        // per cambiare l'unità di un documento, il procedimento è:
        // 1) cambiare il soggetto sul documento
        // 2) cambiare le competenze
        // 3) cambiare l'attore dello step
        // 4) eliminare dalla jworklist (se presente) le notifiche per l'utente vecchio
        // 5) ricreo le notifiche per la nuova unità quindi mettere quelle per l'utente nuovo

        // 1) cambio il soggetto:
        for (DocumentoSoggetto soggetto : documento.soggetti) {
            if (unitaPrecedente.equals(soggetto.unitaSo4)) {
                documento.setSoggetto(soggetto.tipoSoggetto, soggetto.utenteAd4, nuovaUnita)
            }
        }

        // 2) cambiare le competenze:
        // rimuovo le competenze in lettura e scrittura all'unità precedente:
        WkfTipoOggetto tipoOggetto = WkfTipoOggetto.get(documento.tipoOggetto.codice)
        gestoreCompetenze.rimuoviCompetenze(documento, tipoOggetto, new Attore(unitaSo4: unitaPrecedente), true, true, false, null)

        // assegno le competenze in scrittura all'utente richiesto:
        gestoreCompetenze.assegnaCompetenze(documento, tipoOggetto, new Attore(unitaSo4: nuovaUnita), true, true, false, null)

        // 3) cambio l'attore dello step:
        for (WkfAttoreStep a : documento.iter?.stepCorrente.attori) {
            // per ogni attore dello step che ha l'unità vecchia, cambio l'unità con quella nuova.
            if (unitaPrecedente.equals(a.unitaSo4)) {

                // imposto la nuova unità
                a.unitaSo4 = nuovaUnita
                a.save()
            }
        }

        documento.save()
    }
}
