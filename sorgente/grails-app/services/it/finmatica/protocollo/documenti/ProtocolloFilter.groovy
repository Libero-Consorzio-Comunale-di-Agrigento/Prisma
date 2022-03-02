package it.finmatica.protocollo.documenti

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.data.jpa.domain.Specification
import org.springframework.data.jpa.domain.Specifications

import javax.persistence.criteria.CriteriaBuilder
import javax.persistence.criteria.CriteriaQuery
import javax.persistence.criteria.Path
import javax.persistence.criteria.Predicate
import javax.persistence.criteria.Root

@CompileStatic
class ProtocolloFilter {
    String oggetto
    String classificazione
    Integer fascicoloAnno
    String fascicoloNumero
    boolean protocollati
    Date dataDal
    Date dataAl
    Integer anno
    String numero
    String tipoRegistro
    String movimento
    String ufficioSmistamento
    String unitaProtocollante

    Specification<Protocollo> toSpecification() {
        List<Specification<Protocollo>> specs = []
        if(oggetto) {
            specs.add(haOggetto(oggetto))
        }
        if(classificazione) {
            specs.add(haClassificazione(classificazione))
        }
        if(fascicoloAnno) {
            specs.add(haAnnoFascicolo(fascicoloAnno))
        }
        if(fascicoloNumero) {
            specs.add(haNumeroFascicolo(fascicoloNumero))
        }
        if(protocollati) {
            specs.add(Specifications.not(nonProtocollati()))
        } else {
            specs.add(nonProtocollati())
        }
        if(dataDal) {
            specs.add(daData(dataDal))
        }
        if(dataAl) {
            specs.add(aData(dataAl))
        }
        if(anno) {
            specs.add(haAnno(anno))
        }
        if(numero) {
            specs.add(haNumero(numero))
        }
        if(tipoRegistro) {
            specs.add(haTipoRegistro(tipoRegistro))
        }
        if(movimento) {
            specs.add(haMovimento(movimento))
        }
        if(ufficioSmistamento) {
            specs.add(haUfficioSmistamento(ufficioSmistamento))
        }
        if(unitaProtocollante) {
            specs.add(haUnitaProtocollante(unitaProtocollante))
        }
        if(specs) {
            Iterator<Specification<Protocollo>> iter =  specs.iterator()
            Specifications<Protocollo> sp = Specifications.where(iter.next())
            while(iter.hasNext()) {
                sp.and(iter.next())
            }
            return sp
        } else {
            return Specifications.newInstance()
        }
    }

    private Specification<Protocollo> haOggetto(String oggetto) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('oggetto'), oggetto)
            }
        }
    }

    private Specification<Protocollo> haClassificazione(String codice) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('classificazione').get('codice'), codice)
            }
        }
    }

    private Specification<Protocollo> haNumeroFascicolo(String numero) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('fascicolo').get('numero'), numero)
            }
        }
    }

    private Specification<Protocollo> haAnnoFascicolo(Integer anno) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('fascicolo').get('anno'), anno)
            }
        }
    }

    private Specification<Protocollo> nonProtocollati() {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.isNull(root.get('numero'))
            }
        }
    }

    @CompileDynamic
    private Specification<Protocollo> daData(Date data) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.greaterThanOrEqualTo(root.<Date>get('data') as Path<Date>, data)
            }
        }
    }

    @CompileDynamic
    private Specification<Protocollo> aData(Date data) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.lessThanOrEqualTo(root.<Date>get('data') as Path<Date>, data)
            }
        }

    }

    private Specification<Protocollo> haNumero(String numero) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('numero'), numero)
            }
        }
    }

    private Specification<Protocollo> haAnno(Integer anno) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('anno'), anno)
            }
        }
    }

    private Specification<Protocollo> haTipoRegistro(String codice) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('tipoRegistro').get('codice') as Path<String>, codice)
            }
        }
    }

    private Specification<Protocollo> haMovimento(String movimento) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                cb.equal(root.get('movimento'), movimento)
            }
        }
    }

    private Specification<Protocollo> haUfficioSmistamento(String ufficioSmistamento) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                def pathSmistamenti = root.get('smistamenti') as Path<Smistamento>
                def pathUnita = pathSmistamenti.get('unitaSmistamento') as Path<So4UnitaPubb>
                cb.equal(pathUnita.get('codice') as Path<String>,ufficioSmistamento)
            }
        }
    }

    private Specification<Protocollo> haUnitaProtocollante(String unitaProtocollante) {
        return new Specification<Protocollo>() {
            @Override
            Predicate toPredicate(Root<Protocollo> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                def pathSoggetti = root.get('soggetti') as Path<DocumentoSoggetto>
                def pathUnita = pathSoggetti.get('unitaSo4') as Path<So4UnitaPubb>
                cb.equal(pathUnita.get('codice') as Path<String>, unitaProtocollante)
            }
        }
    }

}
