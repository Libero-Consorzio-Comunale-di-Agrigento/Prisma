package it.finmatica.protocollo.integrazioni.ad4
import org.springframework.beans.factory.annotation.Autowired

import it.finmatica.ad4.dizionari.Ad4Regione
import it.finmatica.ad4.dizionari.Ad4RegioneDTO
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional(readOnly = true)
@Service
class RegioniAd4Service {

    List<Ad4RegioneDTO> ricerca(Long id , String denominazione)  {
        return Ad4Regione.createCriteria().list {

            if (denominazione ?: "" != "") {
                    ilike("denominazione", "%${denominazione}%")
            }

            if (id.longValue()!=-1) {
                eq("id",id)
            }

            order('denominazione', 'asc')
        }.toDTO(["id","denominazione"])

    }
}
