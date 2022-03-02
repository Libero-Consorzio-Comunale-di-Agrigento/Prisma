package it.finmatica.protocollo.integrazioni.si4cs

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.corrispondenti.MessaggioDTO
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Campo
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.text.SimpleDateFormat

@Slf4j
@Transactional
@Service
class MessaggiInviatiService {

    @Autowired
    DocumentaleService documentaleService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    ProtocolloGdmService protocolloGdmService

    public static final String TIPO_COLLEGAMENTO_MAIL = 'MAIL'
    public static final String TIPO_COLLEGAMENTO_RICEVUTA = 'PROT_RR'
    public static final String TIPO_COLLEGAMENTO_CONFERMA = 'PROT_CONF'
    public static final String TIPO_COLLEGAMENTO_PEC = 'PROT_PEC'
    public static final String TIPO_COLLEGAMENTO_ECCEZIONE = 'PROT_ECC'

    MessaggioInviato getMessaggioInviatoByIdSi4Cs(Long idMessaggioSi4Cs) {
        return MessaggioInviato.findByIdMessaggioSi4Cs(idMessaggioSi4Cs)
    }

    MessaggioInviato getMessaggio(Long id) {
        return MessaggioInviato.get(id)
    }

    MessaggioDTO getMessaggioDto(Long idMessaggio) {
        Messaggio messaggio = Messaggio.findById(idMessaggio)

        return messaggio?.toDTO(["corrispondenti.*"])
    }

    MessaggioInviato salva(MessaggioInviato messaggioInviato) {
        Documento documentoGdm = new Documento()
        boolean aggiornamento = false

        if (messaggioInviato.idDocumentoEsterno > 0) {
            aggiornamento = true
            documentoGdm.setId(String.valueOf(messaggioInviato.idDocumentoEsterno))
            documentoGdm = documentaleService.getDocumento(documentoGdm, new ArrayList<Documento.COMPONENTI>())
            documentoGdm.addChiaveExtra("STATO_DOCUMENTO", "BO")
        } else {
            documentoGdm.addChiaveExtra("AREA", "SEGRETERIA")
            documentoGdm.addChiaveExtra("MODELLO", "MEMO_PROTOCOLLO")
        }
            /*documentoGdm.addChiaveExtra("AREA", "GDMSYS")
            documentoGdm.addChiaveExtra("MODELLO", "REPOSITORY")*/

        String dataSpedizione = ""
        if (messaggioInviato.dataSpedizione != null) {
            dataSpedizione = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(messaggioInviato.dataSpedizione)
        }

        documentoGdm.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        documentoGdm.addChiaveExtra("AREA", "SEGRETERIA")
        documentoGdm.addChiaveExtra("MODELLO", "MEMO_PROTOCOLLO")

        documentoGdm.addCampo(new Campo("MEMO_IN_PARTENZA", "Y"))
        documentoGdm.addCampo(new Campo("PROCESSATO_AG", "Y"))
        documentoGdm.addCampo(new Campo("TAG_MAIL", messaggioInviato.tagmail))
        documentoGdm.addCampo(new Campo("TIPO_MESSAGGIO", "PEC"))
        documentoGdm.addCampo(new Campo("OGGETTO", messaggioInviato.oggetto))
        documentoGdm.addCampo(new Campo("CORPO", messaggioInviato.testo))
        documentoGdm.addCampo(new Campo("DATA_SPEDIZIONE_MEMO", dataSpedizione))

        if (messaggioInviato.mittente?.size() > 200) {
            documentoGdm.addCampo(new Campo("MITTENTE", messaggioInviato.mittente?.substring(0, 199)))
        }
        else {
            documentoGdm.addCampo(new Campo("MITTENTE", messaggioInviato.mittente))
        }
        if (messaggioInviato.destinatari?.size() > 4000) {
            documentoGdm.addCampo(new Campo("DESTINATARI", messaggioInviato.destinatari?.substring(0, 3999)))
        }
        else {
            documentoGdm.addCampo(new Campo("DESTINATARI", messaggioInviato.destinatari))
        }
        if (messaggioInviato.destinatariConoscenza?.size() > 4000) {
            documentoGdm.addCampo(new Campo("DESTINATARI_CONOSCENZA", messaggioInviato.destinatariConoscenza?.substring(0, 3999)))
        }
        else {
            documentoGdm.addCampo(new Campo("DESTINATARI_CONOSCENZA", messaggioInviato.destinatariConoscenza))
        }
        if (messaggioInviato.destinatariNascosti?.size() > 4000) {
            documentoGdm.addCampo(new Campo("DESTINATARI_NASCOSTI", messaggioInviato.destinatariNascosti?.substring(0, 3999)))
        }
        else {
            documentoGdm.addCampo(new Campo("DESTINATARI_NASCOSTI", messaggioInviato.destinatariNascosti))
        }

        if (messaggioInviato.accettazione) {
            documentoGdm.addCampo(new Campo("REGISTRATA_ACCETTAZIONE","Y"))
        }
        else {
            documentoGdm.addCampo(new Campo("REGISTRATA_ACCETTAZIONE",""))
        }
        if (messaggioInviato.nonAccettazione) {
            documentoGdm.addCampo(new Campo("REGISTRATA_NON_ACCETTAZIONE","Y"))
        }
        else {
            documentoGdm.addCampo(new Campo("REGISTRATA_NON_ACCETTAZIONE",""))
        }

        documentoGdm = documentaleService.salvaDocumento(documentoGdm)
        if (!aggiornamento) {
            messaggioInviato.idDocumentoEsterno = Long.parseLong(documentoGdm.getId())
        }

        messaggioInviato.save()

        return messaggioInviato
    }

    String aggiungiFile(MessaggioInviato messaggioInviato, String testo, String nomeFile) {
        Documento documentoGdm = new Documento()
        documentoGdm.setId("" + messaggioInviato.idDocumentoEsterno)
        documentoGdm.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        File fileGdm = new File()
        fileGdm.nome = nomeFile
        fileGdm.inputStream = new ByteArrayInputStream(testo.getBytes())
        documentoGdm.addFile(fileGdm)
        documentoGdm = documentaleService.salvaDocumento(documentoGdm)
        String idFileEsterno = documentoGdm.getFiles().get(0).id

        FileDocumento fileDocumento = new FileDocumento(nome: nomeFile, sequenza: 0, idFileEsterno: Long.parseLong(idFileEsterno), contentType: "text/xml",
                documento: messaggioInviato)
        fileDocumento.save()

        return idFileEsterno
    }

    void aggiungiAllegati(MessaggioInviato messaggioInviato, List<FileDocumentoDTO> fileAllegati, int initSequenza) {
        int sequenza = initSequenza
        for (allegato in fileAllegati) {
            FileDocumento fileDocumento = new FileDocumento(nome: allegato.nome, sequenza: sequenza++, idFileEsterno: allegato.idFileEsterno, contentType: allegato.contentType,
                    documento: messaggioInviato)
            fileDocumento.save()
        }
    }

    void collegaMessaggioInviatoAProtocollo(MessaggioInviato messaggioInviato, Protocollo protocollo, TipoCollegamento tipoCollegamento) {
        DocumentoCollegato documentoCollegato = new DocumentoCollegato()

        documentoCollegato.documento = protocollo
        documentoCollegato.collegato = messaggioInviato
        documentoCollegato.tipoCollegamento = tipoCollegamento

        documentoCollegato.save()
        protocolloGdmService.salvaDocumentoCollegamento(protocollo, messaggioInviato, tipoCollegamento.codice)
    }

    void collegaMessaggioInviatoAMessaggioRicevuto(MessaggioInviato messaggioInviato, MessaggioRicevuto messaggioRicevuto) {
        DocumentoCollegato documentoCollegato = new DocumentoCollegato()
        documentoCollegato.documento = messaggioInviato
        documentoCollegato.collegato = messaggioRicevuto
        documentoCollegato.tipoCollegamento = TipoCollegamento.findByCodice(TIPO_COLLEGAMENTO_PEC)
        documentoCollegato.save()
        protocolloGdmService.salvaDocumentoCollegamento(messaggioInviato, messaggioRicevuto, documentoCollegato.tipoCollegamento.codice)
    }

    DocumentoCollegato getDocumentoCollegato(MessaggioInviato messaggioInviato) {
        return documentoCollegatoRepository.collegamentoPadre(messaggioInviato)
    }

    List<DocumentoCollegato> getDocumentiReferenti(MessaggioInviato messaggioInviato) {
        return documentoCollegatoRepository.collegamenti(messaggioInviato)
    }

    public boolean isCompetenzaLettura(MessaggioInviato messaggioInviato) {
        //La competenza è sempre del relativo protocollo collegato
        DocumentoCollegato documentoCollegato = getDocumentoCollegato(messaggioInviato)

        if (documentoCollegato != null) {
            Map competenzeProtocollo = gestoreCompetenze.getCompetenze(documentoCollegato.documento)

            return competenzeProtocollo?.lettura
        }

        return false
    }
}