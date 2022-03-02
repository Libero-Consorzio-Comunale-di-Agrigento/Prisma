package it.finmatica.protocollo.integrazioni.wsrest

import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.trasco.TrascoService
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestMethod
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.multipart.MultipartFile

import javax.transaction.Transactional

@RestController
class ProtocolloFileRestController {

    @Autowired IGestoreFile gestoreFile
    @Autowired TrascoService trascoService

    @Autowired SessionFactory sessionFactory

    @GetMapping("/api/v1/basic/pingService")
    String pingService() {
        return "OK"
    }

    @PostMapping("/api/v1/protocollo/uploadFilePrincipale")
    @Transactional
    Response uploadFilePrincipale(@RequestParam(value = "idDocumento") Long idDocumento, @RequestParam("file") MultipartFile file) {
        Documento documento = Documento.findByIdDocumentoEsterno(idDocumento)

        if (documento == null) {
            trascoService.creaProtocolloDaGdm(idDocumento)
            if (idDocumento != null) {
                documento = Documento.findByIdDocumentoEsterno(idDocumento)
                sessionFactory.getCurrentSession().refresh(documento)
            }
        }

        if (documento == null) {
            return new Response(Response.ERROR, "-1", "Documento con id " + idDocumento + " inesistente!")
        }

        if (documento.fileDocumenti?.find { it.codice == FileDocumento.CODICE_FILE_PRINCIPALE } != null) {
            return new Response(Response.ERROR, "-2", "Il documento con id " + idDocumento + " ha già un file principale!")
        }

        try {
            FileDocumento fileDocumento = new FileDocumento()
            fileDocumento.contentType = file.getContentType()
            fileDocumento.nome = file.getOriginalFilename()
            fileDocumento.codice = FileDocumento.CODICE_FILE_PRINCIPALE

            gestoreFile.addFile(documento, fileDocumento, file.getInputStream())

            return new Response(Response.OK, "0", null)
        }
        catch (Exception e) {
            return new Response(Response.ERROR, "-100", e.getMessage())
        }
    }

    static class Response {
        public static final String ERROR = "error";
        public static final String OK = "ok";

        private final String result
        private final String code
        private final String text

        Response(String result, String code, String text) {
            this.result = result
            this.code = code
            this.text = text
        }

        String getResult() {
            return result
        }

        String getCode() {
            return code
        }

        String getText() {
            return text
        }
    }
}

