package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Service
@Transactional
class DocAreaFileService {

    @Autowired private DocAreaFileRepository docAreaFileRepository

    DocAreaFile save (DocAreaFile value) {
        return docAreaFileRepository.save(value)
    }

    DocAreaFile findById(Long id) {
        docAreaFileRepository.findOne(id)
    }

    int deleteObsolete(Integer ageHours) {
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.HOUR_OF_DAY,ageHours * -1)
        return docAreaFileRepository.deleteObsolete(cal.time)
    }

}
