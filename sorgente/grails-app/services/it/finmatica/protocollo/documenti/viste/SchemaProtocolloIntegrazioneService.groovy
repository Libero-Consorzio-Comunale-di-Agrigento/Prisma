package it.finmatica.protocollo.documenti.viste

import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException
import it.finmatica.protocollo.dizionari.SchemaProtocolloIntegrazione
import it.finmatica.protocollo.dizionari.SchemaProtocolloIntegrazioneDTO
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.hibernate.Session
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

@Service
@Transactional
class SchemaProtocolloIntegrazioneService {
    @Autowired
    DataSource dataSource
    @Autowired
    SessionFactory sessionFactory

    SchemaProtocolloIntegrazioneDTO salva(SchemaProtocolloIntegrazioneDTO schemaProtocolloIntegrazioneDTO) {

        SchemaProtocolloIntegrazione schemaProtocolloIntegrazioneDuplicato

        if (schemaProtocolloIntegrazioneDTO.applicativo == SchemaProtocolloIntegrazione.GLOBO) {
            schemaProtocolloIntegrazioneDuplicato = SchemaProtocolloIntegrazione.findByApplicativoAndValido(schemaProtocolloIntegrazioneDTO.applicativo, true)
            if (schemaProtocolloIntegrazioneDuplicato && schemaProtocolloIntegrazioneDuplicato.id != schemaProtocolloIntegrazioneDTO.id) {
                ClientsUtils.showError("Attenzione! Non è possibile indicare più tipi documento per l'integrazione con Globo!")
                return
            }
        }
        if (schemaProtocolloIntegrazioneDTO.applicativo == SchemaProtocolloIntegrazione.IMPRESA_IN_UN_GIORNO) {
            if (!schemaProtocolloIntegrazioneDTO.tipoPratica) {
                ClientsUtils.showError("Attenzione! Indicare il Tipo Pratica!")
                return
            }
        }

        try {
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
            if (schemaProtocolloIntegrazioneDTO.applicativo == SchemaProtocolloIntegrazione.GLOBO) {
                schemaProtocolloIntegrazioneDuplicato = SchemaProtocolloIntegrazione.findByApplicativoAndSchemaProtocollo(schemaProtocolloIntegrazioneDTO.applicativo, schemaProtocolloIntegrazioneDTO.schemaProtocollo.getDomainObject())
            } else {
                schemaProtocolloIntegrazioneDuplicato = SchemaProtocolloIntegrazione.findByApplicativoAndSchemaProtocolloAndTipoPratica(schemaProtocolloIntegrazioneDTO.applicativo, schemaProtocolloIntegrazioneDTO.schemaProtocollo.getDomainObject(), schemaProtocolloIntegrazioneDTO.tipoPratica.toUpperCase())
            }

            if (schemaProtocolloIntegrazioneDuplicato && schemaProtocolloIntegrazioneDuplicato.id != schemaProtocolloIntegrazioneDTO.id) {
                ClientsUtils.showError("Attenzione! Valore già presente! (Controllare anche le righe disabilitate)")
                return
            }
            if (schemaProtocolloIntegrazioneDTO.applicativo == SchemaProtocolloIntegrazione.IMPRESA_IN_UN_GIORNO) {
                schemaProtocolloIntegrazioneDuplicato = SchemaProtocolloIntegrazione.findByApplicativoAndTipoPratica(schemaProtocolloIntegrazioneDTO.applicativo, schemaProtocolloIntegrazioneDTO.tipoPratica.toUpperCase())
            }
            if (schemaProtocolloIntegrazioneDuplicato && schemaProtocolloIntegrazioneDuplicato.id != schemaProtocolloIntegrazioneDTO.id) {
                ClientsUtils.showError("Attenzione! Tipo pratica già associato ad altro tipo documento! (Controllare anche le righe disabilitate)")
                return
            }
        } finally {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }

        SchemaProtocolloIntegrazione schemaProtocolloIntegrazione = SchemaProtocolloIntegrazione.get(schemaProtocolloIntegrazioneDTO.id) ?: new SchemaProtocolloIntegrazione()
        schemaProtocolloIntegrazione.valido = schemaProtocolloIntegrazioneDTO.valido
        schemaProtocolloIntegrazione.applicativo = schemaProtocolloIntegrazioneDTO.applicativo
        schemaProtocolloIntegrazione.schemaProtocollo = schemaProtocolloIntegrazioneDTO.schemaProtocollo.getDomainObject()
        schemaProtocolloIntegrazione.tipoPratica = schemaProtocolloIntegrazioneDTO.tipoPratica.toUpperCase()
        schemaProtocolloIntegrazione = schemaProtocolloIntegrazione.save()

        return schemaProtocolloIntegrazione.toDTO()
    }

    void elimina(SchemaProtocolloIntegrazioneDTO schemaProtocolloIntegrazioneDTO) {

        SchemaProtocolloIntegrazione schemaProtocolloIntegrazione = SchemaProtocolloIntegrazione.get(schemaProtocolloIntegrazioneDTO.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (schemaProtocolloIntegrazione.version != schemaProtocolloIntegrazioneDTO.version) throw new GestioneDocumentiRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        schemaProtocolloIntegrazione.delete()
    }

    boolean isSchemaImpresaInUnGiorno(SchemaProtocollo schemaProtocollo) {

        SchemaProtocolloIntegrazione schemaProtocolloIntegrazione = SchemaProtocolloIntegrazione.findBySchemaProtocolloAndApplicativo(schemaProtocollo, SchemaProtocolloIntegrazione.IMPRESA_IN_UN_GIORNO)
        return schemaProtocolloIntegrazione
    }


    private SchemaProtocolloIntegrazione reloadFromDb(Long id) {
        SchemaProtocolloIntegrazione schema = null
        Session session = sessionFactory.getCurrentSession()
        session.disableFilter("soloValidiFilter")
        try {
            schema = SchemaProtocolloIntegrazione.findById(id)
        } finally {
            session.enableFilter("soloValidiFilter")
        }
        return schema
    }
}
