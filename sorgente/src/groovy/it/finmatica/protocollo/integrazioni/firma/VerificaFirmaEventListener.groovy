package it.finmatica.protocollo.integrazioni.firma

import groovy.transform.CompileStatic
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.integrazioni.firma.FirmaEvent
import it.finmatica.gestionedocumenti.integrazioni.firma.FirmaEventListener
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import org.hibernate.Hibernate
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

/**
 * Dopo la firma, sul file principale del protocollo, bisogna salvare i dati della verifica.
 */
@CompileStatic
@Component
class VerificaFirmaEventListener implements FirmaEventListener {

    @Autowired
    private ProtocolloService protocolloService

    @Override
    void dopoFirma(FirmaEvent event) {
        Documento documento = event.fileDocumento.documento
        if (documento instanceof Protocollo) {
            protocolloService.verificaFirma(documento)
        }
    }
}
