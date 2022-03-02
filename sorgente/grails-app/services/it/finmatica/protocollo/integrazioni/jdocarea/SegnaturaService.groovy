package it.finmatica.protocollo.integrazioni.jdocarea

import com.sun.xml.bind.v2.runtime.JaxBeanInfo
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service

import javax.xml.bind.JAXBContext
import javax.xml.bind.Unmarshaller

@CompileStatic
@Service
class SegnaturaService {

    JAXBContext jc
    JAXBContext jcDocPrincipale

    SegnaturaService() {
        // devo creare dei contesti diversi perché gli xml che arrivano hanno tutti lo stesso nodo <Segnatura> e
        // questo crea confusione al parser
        this.jc = JAXBContext.newInstance(Segnatura.class)
        this.jcDocPrincipale = JAXBContext.newInstance(SegnaturaDocPrincipale.class)
    }

    Segnatura leggiSegnatura(String xml) {
        Unmarshaller unm = jc.createUnmarshaller()
        unm.unmarshal(new StringReader(xml)) as Segnatura
    }

    SegnaturaDocPrincipale leggiSegnaturaDocPrincipale(String xml) {
        Unmarshaller unm = jcDocPrincipale.createUnmarshaller()
        unm.unmarshal(new StringReader(xml)) as SegnaturaDocPrincipale
    }
}
