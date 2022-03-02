package it.finmatica.protocollo.integrazioni.firma

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional
import org.springframework.stereotype.Service

import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.jsign.api.PKCS7Builder
import it.finmatica.protocollo.documenti.Protocollo
import org.springframework.beans.factory.annotation.Value

@Service
@Transactional
class MarcaturaTemporaleService {

    @Value("\${finmatica.protocollo.marcaturaTemporale.url}")
    private String urlServizioMarcaTemporale
    @Value("\${finmatica.protocollo.marcaturaTemporale.utente}")
    private String utenteServizioMarcaTemporale
    @Value("\${finmatica.protocollo.marcaturaTemporale.password}")
    private String passwordServizioMarcaTemporale

    @Autowired IGestoreFile gestoreFile

    List<FileDocumentoDTO> getElencoFileDaMarcare(Protocollo documento) {
        List<FileDocumentoDTO> fileDaMarcare = []

        FileDocumento filePrincipale = documento.filePrincipale
        if (filePrincipale != null && filePrincipale.firmato && !filePrincipale.marcato) {
            fileDaMarcare << filePrincipale.toDTO()
        }

        for (Allegato allegato : documento.allegati) {
            for (FileDocumento fileDocumento : allegato.fileDocumenti) {
                if (fileDocumento.valido && fileDocumento.firmato && !fileDocumento.marcato) {
                    fileDaMarcare << fileDocumento.toDTO()
                }
            }
        }

        return fileDaMarcare
    }

    void apponiMarcaTemporale(FileDocumento fileDocumento) {
        File file = File.createTempFile("marcatura", "tmp")
        try {
            BufferedOutputStream fos = file.newOutputStream()
            InputStream inputStream = new BufferedInputStream(gestoreFile.getFile(fileDocumento.documento, fileDocumento))
            PKCS7Builder.appendTS(inputStream, fos, urlServizioMarcaTemporale, utenteServizioMarcaTemporale, passwordServizioMarcaTemporale)
            fos.close()
            fileDocumento.marcato = true
            gestoreFile.addFile(fileDocumento.documento, fileDocumento, file.newInputStream())
        } finally {
            file.delete()
        }
    }
}
