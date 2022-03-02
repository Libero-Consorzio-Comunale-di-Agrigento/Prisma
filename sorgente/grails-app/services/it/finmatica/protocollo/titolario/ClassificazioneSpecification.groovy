package it.finmatica.protocollo.titolario

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.Classificazione
import org.springframework.data.jpa.domain.Specification

import javax.persistence.criteria.CriteriaBuilder
import javax.persistence.criteria.CriteriaQuery
import javax.persistence.criteria.Path
import javax.persistence.criteria.Root

@CompileStatic
abstract class ClassificazioneSpecification {
    static Specification<Classificazione> haCodice(String codice) {
        return {Root<Classificazione> classificazione, CriteriaQuery cq, CriteriaBuilder cb -> cb.equal(classificazione.get('codice'), codice)} as Specification<Classificazione>
    }

    static Specification<Classificazione> haDescrizione(String descrizione) {
        return {Root<Classificazione> classificazione, CriteriaQuery cq, CriteriaBuilder cb -> cb.equal(classificazione.get('descrizione'), descrizione)} as Specification<Classificazione>
    }

    static Specification<Classificazione> haAmministrazione(String amministrazione) {
        return {Root<Classificazione> classificazione, CriteriaQuery cq, CriteriaBuilder cb -> cb.equal(classificazione.get('ente').get('amministrazione').get('codice'), amministrazione)} as Specification<Classificazione>
    }

    static Specification<Classificazione> haAoo(String aoo) {
        return {Root<Classificazione> classificazione, CriteriaQuery cq, CriteriaBuilder cb -> cb.equal(classificazione.get('ente').get('aoo'), aoo)} as Specification<Classificazione>
    }

    @CompileDynamic
    static Specification<Classificazione> contenitoreDocumenti() {
        return {Root<Classificazione> classificazione, CriteriaQuery cq, CriteriaBuilder cb -> cb.isTrue(classificazione.get('contenitoreDocumenti') as Path<Boolean>)} as Specification<Classificazione>
    }

    static Specification<Classificazione> valida() {
        return {Root<Classificazione> classificazione, CriteriaQuery cq, CriteriaBuilder cb -> cb.isNull(classificazione.get('al'))} as Specification<Classificazione>
    }

}
