package it.finmatica.protocollo.integrazioni.ad4
import org.springframework.beans.factory.annotation.Autowired

import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.ad4.dizionari.Ad4ProvinciaDTO
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class ProvinceAd4Service {

    List<Ad4ProvinciaDTO> ricerca(Long id, Long idRegione) {
        return Ad4Provincia.createCriteria().list {
           // println denominazioneRegione
           // if (denominazioneRegione ?: "" != "") {
                eq("regione.id" ,idRegione)
           // }

            if (id.longValue()!=-1) {
                eq("id",id.toInteger())
            }
            else  {
                eq("regione.id" ,idRegione)
            }

            order('denominazione', 'asc')
        }.toDTO(["id","denominazione"])
    }
}
