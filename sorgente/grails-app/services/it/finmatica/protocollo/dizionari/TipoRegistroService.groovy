package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gorm.criteria.PagedResultList
import org.springframework.stereotype.Service

@Service
class TipoRegistroService {

    PagedResultList ricercaTipoRegistro(String filtro, int offset, int max, Boolean registroAperto = null) {
        return ricercaTipoRegistro(new TipoRegistroDTO(codice: filtro, commento: filtro), offset, max)
    }

    PagedResultList ricercaTipoRegistro(TipoRegistroDTO tipoRegistroDTO, int offset, int max,Boolean registroAperto = null) {
        return TipoRegistro.createCriteria().list(max: max, offset: offset) {
            eq("valido", true)
            or {
                if (tipoRegistroDTO.codice != null) {
                    ilike("codice", "%" + tipoRegistroDTO.codice + "%")
                }
                if (tipoRegistroDTO.commento != null) {
                    ilike("commento", "%" + tipoRegistroDTO.commento + "%")
                }
            }
            if(registroAperto != null) {
                registro {
                    eq('aperto', registroAperto)
                }
            }
            order("codice", "asc")
        }
    }
}
