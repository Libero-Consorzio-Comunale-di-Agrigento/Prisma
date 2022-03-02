package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.integrazioni.documentale.IntegrazioneDocumentaleService
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.ProtocolloEsternoDTO
import it.finmatica.protocollo.trasco.TrascoService
import it.finmatica.smartdoc.api.struct.Documento
import org.hibernate.FetchMode
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo


@Slf4j
@Transactional
@Service
class ProtocolloEsternoService {

    @Autowired
    ProtocolloEsternoRepository protocolloEsternoRepository
    @Autowired
    TrascoService trascoService
    @Autowired
    IntegrazioneDocumentaleService integrazioneDocumentaleService
    @Autowired
    SessionFactory sessionFactory

    /**
     *
     * @param idDocumentoEsterno
     * @return
     */
    public ProtocolloEsterno getProtocolloEsterno(Long idDocumentoEsterno) {
       return protocolloEsternoRepository.getProtocolloEsterno(idDocumentoEsterno)
    }

    ProtocolloEsterno findProtocolloEsterno(String anno, String numero, String tipoRegistroPrecedente) {
        return ProtocolloEsterno.createCriteria().get() {
            eq("anno", Integer.valueOf(anno))
            eq("numero", Integer.valueOf(numero))
            eq("tipoRegistro.codice", tipoRegistroPrecedente)

            isNotNull("anno")
            isNotNull("numero")
            isNotNull("data")

            fetchMode("tipoRegistro", FetchMode.JOIN)
        }
    }

    Protocollo creaProtocolloDaProtocolloEsterno(ProtocolloEsternoDTO protocolloEsternoDTO) {
        Protocollo prot = new Protocollo(idDocumentoEsterno: protocolloEsternoDTO.idDocumentoEsterno,
                anno: protocolloEsternoDTO.anno,
                oggetto: protocolloEsternoDTO.oggetto,
                data: protocolloEsternoDTO.data,
                tipoRegistro: protocolloEsternoDTO.tipoRegistro?.domainObject,
                tipoProtocollo: TipoProtocollo.findByCategoria(protocolloEsternoDTO.categoria),
                numero: protocolloEsternoDTO.numero)
        prot.save()
        return prot
    }

    Protocollo salvaProtocolloTrascodificato(Long idDocumentoEsterno){
        Protocollo protocollo = Protocollo.findByIdDocumentoEsterno(idDocumentoEsterno)
        if(protocollo?.idrif != null){
            return protocollo
        }
        Documento documento = integrazioneDocumentaleService.getDocumento(idDocumentoEsterno?.toString(), true)
        if (! CategoriaProtocollo.codiciModelloGDM.contains(documento.getMappaChiaviExtra().get("MODELLO"))) {
            return protocollo
        }
        trascoService.creaProtocolloDaGdm(idDocumentoEsterno)
        Protocollo protocolloTrascodificato = Protocollo.findByIdDocumentoEsterno(idDocumentoEsterno)
        if(protocolloTrascodificato == null){
            return null
        }
        sessionFactory.getCurrentSession().refresh(protocolloTrascodificato)
        return protocolloTrascodificato
    }
}