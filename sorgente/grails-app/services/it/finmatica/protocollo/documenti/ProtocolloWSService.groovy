package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.persistence.EntityManager
import javax.persistence.TypedQuery

@Slf4j
@Transactional
@Service
class ProtocolloWSService {

    @Autowired
    EntityManager entityManager
    @Autowired
    ProtocolloWSRepository protocolloWSRepository

    List<Long> findProtocolliIdsByFilter(ProtocolloWSJPQLFilter filter) {
        def query = filter.toWSJPQL()
        TypedQuery<Long> q = entityManager.createQuery(query, Long)
        for (Map.Entry<String, Object> entry in filter.params) {
            q.setParameter(entry.key, entry.value)
        }
        return q.resultList
    }

    ProtocolloWS findOne(Long id) {
        return protocolloWSRepository.findOne(id)
    }


    ProtocolloWS findByAnnoAndNumeroAndTipoRegistro(Integer anno, Integer numero, String tipoRegistro) {
        return protocolloWSRepository.findByAnnoAndNumeroAndTipoRegistro(anno, numero, tipoRegistro)
    }


}