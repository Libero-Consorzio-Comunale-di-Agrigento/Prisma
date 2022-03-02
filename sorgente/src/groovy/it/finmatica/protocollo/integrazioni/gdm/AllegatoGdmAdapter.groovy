package it.finmatica.protocollo.integrazioni.gdm

import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException
import it.finmatica.gestionedocumenti.integrazioni.gdm.ModelloGdm
import it.finmatica.jdmsutil.data.ProfiloExtend
import it.finmatica.protocollo.documenti.Protocollo

/**
 * Classe che va a riempire i campi aggiuntivi dell'allegato, in particolare IDRIF, CODICE_AOO e CODICE_AMMINISTRAZIONE leggendo l'idrif dal protocollo
 *
 * Created by esasdelli on 02/02/2017.
 */
class AllegatoGdmAdapter extends ModelloGdm.EMPTY_ADAPTER {

    @Override
    void beforeSave(Object object, ProfiloExtend profiloExtend) {
        Allegato allegato = object
        String idrif = profiloExtend.getCampo("IDRIF")
        if (idrif?.length() > 0) {
            return
        }

        // se questo è un allegato creato per il test della firma, non devo cercare il suo protocollo padre perché non esiste.
        if (allegato.descrizione == "ALLEGATO PER FIRMA DI TEST, SI PUO' ELIMINARE SENZA PROBLEMI.") {
            return
        }

        Protocollo protocollo = allegato.getDocumentoPrincipale()
        if (protocollo == null) {
            throw new GestioneDocumentiRuntimeException("Non ho trovato il Protocollo relativo all'allegato con id: ${allegato.id}.")
        }

        profiloExtend.settaValore("IDRIF", protocollo.idrif)
        profiloExtend.settaValore("CODICE_AOO", allegato.ente.aoo)
        profiloExtend.settaValore("CODICE_AMMINISTRAZIONE", allegato.ente.amministrazione.codice)
    }

    @Override
    void afterSave(Object object, ProfiloExtend profiloExtend) {
        Allegato allegato = object
        // salvo il documento con l'id documento esterno
        allegato.idDocumentoEsterno = Long.parseLong(profiloExtend.getDocNumber())
        allegato.save()
    }
}
