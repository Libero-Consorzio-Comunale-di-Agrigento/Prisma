package it.finmatica.protocollo.hibernate

import groovy.sql.Sql
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import org.hibernate.envers.boot.internal.EnversService
import org.hibernate.event.service.spi.EventListenerRegistry
import org.hibernate.event.spi.EventType
import org.hibernate.internal.SessionFactoryImpl
import org.hibernate.jpa.HibernateEntityManagerFactory

import javax.annotation.PostConstruct
import javax.sql.DataSource

/**
 * L'unico scopo di questo bean è di registrare l'event-listener su envers per l'aggiornamento del log dei file.
 */
@Slf4j
@CompileStatic
class RevisioneStoricoRegister {

    private final DataSource dataSource
    private final DocumentaleService documentaleService
    private final HibernateEntityManagerFactory hibernateEntityManagerFactory

    RevisioneStoricoRegister(HibernateEntityManagerFactory hibernateEntityManagerFactory, DataSource dataSource, DocumentaleService documentaleService) {
        this.hibernateEntityManagerFactory = hibernateEntityManagerFactory
        this.documentaleService = documentaleService
        this.dataSource = dataSource
    }

    @PostConstruct
    void registerEnversListeners() {
        EnversService enversService = hibernateEntityManagerFactory.getSessionFactory().getServiceRegistry().getService(EnversService.class);
        EventListenerRegistry listenerRegistry = ((SessionFactoryImpl) hibernateEntityManagerFactory.getSessionFactory()).getServiceRegistry().getService(EventListenerRegistry.class);

        // registro il listener di envers.
        listenerRegistry.setListeners(EventType.POST_UPDATE, new RevisioneStoricoPostUpdateEventListenerImpl(enversService, this))
        listenerRegistry.setListeners(EventType.POST_DELETE, new RevisioneStoricoPostDeleteEventListenerImpl(enversService, this))
    }

    void aggiornaVersioneStorico(FileDocumento fileDocumento) {
        Sql sql = new Sql(dataSource)

        // non posso accedere ai metodi di hibernate perché altrimenti ricevo un errore hibernate.
        // quindi devo ottenere "a mano" l'id del documento esterno.
        // ottengo l'id del documento esterno dalle tabelle di log, perché in caso di eliminazione del record (ad es quando si elimina un allegato), questa funzione viene invocata dopo l'eliminazione del record
        // quindi la select sulle tabelle "reali" non otterrebbe alcun risultato
        def row = sql.firstRow("select ID_DOCUMENTO_ESTERNO from gdo_documenti_log d, gdo_file_documento_log f where d.id_documento = f.id_documento and f.id_file_documento = :id_file_documento", [id_file_documento: fileDocumento.getId()])
        Long idDocumentoEsterno = (Long) row?.ID_DOCUMENTO_ESTERNO
        log.debug("[${fileDocumento.id}] idDocumentoEsterno: ${idDocumentoEsterno}")

        // se non ho idDocumentoEsterno, non faccio niente.
        // il caso è quello del primo caricamento di un file
        if (idDocumentoEsterno != null) {
            Long revisioneStorico = getRevisioneStorico(idDocumentoEsterno)
            log.debug("[${fileDocumento.id}] revisioneStorico: ${revisioneStorico}")

            // se non ho una revisione, non aggiorno niente
            if (revisioneStorico != null) {
                log.debug("[${fileDocumento.id}] revisioneStorico: ${revisioneStorico}")
                sql.execute("update gdo_file_documento_log f set f.revisione_storico = :revisione_storico where f.id_file_documento = :id_file_documento and f.revend is null", [id_file_documento: fileDocumento.id, revisione_storico: revisioneStorico])
            }
        }
    }

    // devo reimplementare questi metodi copiati dal IntegrazioneGdmService perché in questa classe non devo instaurare nuove @Transaction
    // perché altrimenti ricevo un errore hibernate.
    private it.finmatica.smartdoc.api.struct.Documento getDocumentoSmartDoc(long idDocumentoEsterno, String versione = null) {
        Documento smartDocument = new Documento(id: idDocumentoEsterno.toString(), versione: versione)
        smartDocument.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        it.finmatica.smartdoc.api.struct.Documento documentoSmartDoc = documentaleService.getDocumento(smartDocument, [it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.VERSIONI])
        if (documentoSmartDoc == null) {
            throw new GestioneDocumentiRuntimeException("Non ho trovato il documento su SmartDoc con id: ${idDocumentoEsterno}")
        }

        return documentoSmartDoc
    }

    private Long getRevisioneStorico(long idDocumentoEsterno) {
        String ultimaVersione = getDocumentoSmartDoc(idDocumentoEsterno).getUltimaVersione()
        if (ultimaVersione != null) {
            // ottengo la revisione storica
            return Long.parseLong(ultimaVersione)
        }

        return null
    }
}
