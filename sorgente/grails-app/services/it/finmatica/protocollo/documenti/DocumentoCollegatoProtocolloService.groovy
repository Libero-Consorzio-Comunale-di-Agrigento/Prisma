package it.finmatica.protocollo.documenti

import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviato
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviatoDTO
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.zk.ui.util.Clients

@Transactional
@Service
class DocumentoCollegatoProtocolloService {
    @Autowired
    RegoleCalcoloNotificheProtocolloRepository regoleCalcoloNotificheProtocolloRepository

    void apriDocumentoCollegato(Documento documento, Documento documentoCollegato, String tipoCollegamento, boolean competenzeModifica = false) {
        if (documentoCollegato.class == Protocollo.class) {
            if (tipoCollegamento == TipoCollegamentoConstants.CODICE_PROT_DA_FASCICOLARE) {
                return
            }
            String link = ProtocolloEsterno.findByIdDocumentoEsterno(documentoCollegato.idDocumentoEsterno)?.linkDocumento
            Clients.evalJavaScript(" window.open('" + link + "'); ")
            //Ricarico la url del nuovo pg solo se salvato
            if (documento.idDocumentoEsterno > 0 && documento.class == Protocollo.class) {
                //Verifico se ha competenze di modifica carico la url da regoleCalcoloNotificheProtocolloRepository, altrimenti
                //da ProtocolloEsterno(dovrebbe tornare un url in sola lettura)
                String urlEsecuzione = ""
                if (competenzeModifica) {
                    urlEsecuzione = regoleCalcoloNotificheProtocolloRepository.getUrlDocumento(documento)
                } else {
                    urlEsecuzione = ProtocolloEsterno.findByIdDocumentoEsterno(documento.idDocumentoEsterno)?.linkDocumento
                }
                Clients.evalJavaScript(" window.open('" + urlEsecuzione + "' , '_self'); ")
            }
            else {

            }
        } else if (documentoCollegato.class == MessaggioRicevuto.class) {
            Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_RICEVUTO&id=" + documentoCollegato.id + "');")
        } else if (documentoCollegato.class == MessaggioInviato.class) {
            Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_INVIATO&id=" + documentoCollegato.id + "');")
        }
    }
}
