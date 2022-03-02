package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.viste.IndirizzoTelematico
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

import javax.persistence.EntityManager
import javax.persistence.NoResultException
import javax.persistence.TypedQuery
import javax.sql.DataSource

@Slf4j
@CompileStatic
@Repository
@Transactional
class CustomProtocollloWSRepository {

    private final DataSource dataSource_gdm
    private final DataSource dataSource
    private final EntityManager entityManager

    CustomProtocollloWSRepository(@Qualifier("dataSource_gdm") DataSource dataSource_gdm, DataSource dataSource, EntityManager entityManager) {
        this.dataSource_gdm = dataSource_gdm
        this.dataSource = dataSource
        this.entityManager = entityManager
    }

    public String getProtocolliQueryString(String anno, String numero, String tipoRegistro, String modalita, String codClassifica, String annoFascicolo, String oggetto, String numeroFascicolo, String dal, String al, String descrizioneCorrispondente, String tipoDocumento) {
        String query = "select pws from ProtocolloWS pws "
                if(descrizioneCorrispondente){
                    query = query + " , Corrispondente corr "
                }
                query = query+ " where trunc(pws.data) BETWEEN TO_DATE(:dal, 'DD/MM/YYYY')  AND TO_DATE (:al, 'DD/MM/YYYY') "
                if(anno) {
                    query = query + " AND pws.anno = :anno "
                }
                if(numero){
                    query = query + " AND pws.numero = :numero "
                }
                if(tipoRegistro){
                    query = query + " AND pws.tipoRegistro = :tipoRegistro "
                }
                if(modalita) {
                    query = query + " AND pws.modalita = :modalita "
                }
                if(codClassifica){
                    query = query + " AND pws.classCod = :codClassifica "
                }
                if(annoFascicolo){
                    query = query + " AND pws.fascicoloAnno = : annoFascicolo "
                }
                if(oggetto){
                    query = query + " AND pws.oggetto = :oggetto "
                }
                if(numeroFascicolo){
                    query = query + " AND pws.fascicoloNumero = :numeroFascicolo "
                }
                if(tipoDocumento){
                    query = query + " AND pws.tipoDocumento = :tipoDocumento "
                }
                if(descrizioneCorrispondente){
                    query = query + " AND corr.protocollo.id = pws.idDocumento "
                    query+= " AND ( corr.denominazione LIKE '%' || upper(:descrizioneCorrispondente) || '%' "
                    query+= " OR corr.cognome LIKE '%' || upper(:descrizioneCorrispondente) || '%' "
                    query+= " OR corr.nome LIKE '%' || upper(:descrizioneCorrispondente) || '%' "
                    query+= " OR corr.cognome || ' ' || corr.nome LIKE '%' || upper(:descrizioneCorrispondente) || '%' "
                    query+= " OR corr.nome || ' ' || corr.cognome LIKE '%' || upper(:descrizioneCorrispondente) || '%'  )"
                }

        return query
    }


    List<ProtocolloWS> getProtocolli(String queryString, String anno, String numero, String tipoRegistro, String modalita, String codClassifica, String annoFascicolo, String oggetto, String numeroFascicolo, String dal, String al, String descrizioneCorrispondente, String tipoDocumento) {
        try {
            //Setto i parametri a seconda della queryString
            TypedQuery<ProtocolloWS> query =  entityManager.createQuery(queryString, ProtocolloWS.class)
            if(anno) {
                query.setParameter("anno", new Integer(anno))
            }
            if(numero){
                query.setParameter("numero", new Integer(numero))
            }
            if(tipoRegistro){
                query.setParameter("tipoRegistro", tipoRegistro)
            }
            if(modalita) {
                query.setParameter("modalita", modalita)
            }
            if(codClassifica){
                query.setParameter("codClassifica", codClassifica)
            }
            if(annoFascicolo){
                query.setParameter("annoFascicolo", new Integer(annoFascicolo))
            }
            if(oggetto){
                query.setParameter("oggetto", oggetto)
            }
            if(numeroFascicolo){
                query.setParameter("numeroFascicolo", numeroFascicolo)
            }
            if(tipoDocumento){
                query.setParameter("tipoDocumento", tipoDocumento)
            }
            if(descrizioneCorrispondente){
                query.setParameter("descrizioneCorrispondente", descrizioneCorrispondente)
            }
            query.setParameter("dal", dal)
            query.setParameter("al", al)

            return query.getResultList()

        } catch (NoResultException e) {
            return null
        }
    }


    public String getMailEnteQueryString(String codiceAmministrazione, String descrizioneAmministrazione, String codiceAoo, String descrizioneAoo, String indirizzo) {
        String query = "select it from IndirizzoTelematico it where 1=1 "
        if(codiceAmministrazione && codiceAmministrazione.length() > 0) {
            query = query + " AND it.codiceAmministrazione = :codiceAmministrazione "
        }
        if(descrizioneAmministrazione && descrizioneAmministrazione.length() > 0){
            query = query + " AND UPPER(it.descrizioneAmministrazione) like upper(:descrizioneAmministrazione) "
        }
        if(codiceAoo && codiceAoo.length() > 0){
            query = query + " AND it.codiceAoo = :codiceAoo "
        }
        if(descrizioneAoo && descrizioneAoo.length() > 0) {
            query = query + " AND UPPER(it.descrizioneAoo) like upper(:descrizioneAoo) "
        }
        if(indirizzo && indirizzo.length() > 0) {
            query = query + " AND UPPER(it.indirizzo) like upper(:indirizzo) "
        }
        return query
    }


    List<IndirizzoTelematico> getMailEnte(String queryString, String codiceAmministrazione, String descrizioneAmministrazione, String codiceAoo, String descrizioneAoo, String indirizzo) {
        try {
            //Setto i parametri a seconda della queryString
            TypedQuery<IndirizzoTelematico> query =  entityManager.createQuery(queryString, IndirizzoTelematico.class)
            if(codiceAmministrazione && codiceAmministrazione.length() > 0) {
                query.setParameter("codiceAmministrazione", codiceAmministrazione)
            }
            if(descrizioneAmministrazione && descrizioneAmministrazione.length() > 0) {
                descrizioneAmministrazione = "%"+descrizioneAmministrazione+"%"
                query.setParameter("descrizioneAmministrazione", descrizioneAmministrazione)
            }
            if(codiceAoo && codiceAoo.length() > 0) {
                query.setParameter("codiceAoo", codiceAoo)
            }
            if(descrizioneAoo && descrizioneAoo.length() > 0) {
                descrizioneAoo = "%"+descrizioneAoo+"%"
                query.setParameter("descrizioneAoo", descrizioneAoo)
            }
            if(indirizzo && indirizzo.length() > 0) {
                indirizzo = "%"+indirizzo+"%"
                query.setParameter("indirizzo", indirizzo)
            }

            return query.getResultList()

        } catch (NoResultException e) {
            return null
        }
    }


    public String getProtocolliDaRicevereQueryString(List<String> unita, String oggetto, String dal, String al, String utente,  String codiceOttica, List<String> statiSmistamento) {
        String query =  "select pws " +
                        "from ProtocolloWS pws, Smistamento s " +
                        "where pws.numero is not null " +
                        "AND pws.idDocumento = s.documento.id " +
                        "AND s.statoSmistamento in ( :statiSmistamento) "
        if(oggetto && oggetto.length() > 0) {
            query=  query + "AND upper(pws.oggetto) LIKE upper(:oggetto) "
        }
        if(dal && dal.length() >0) {
            query = query+ "AND pws.data BETWEEN TO_DATE(:dal, 'DD/MM/YYYY')  AND TO_DATE (:al, 'DD/MM/YYYY hh24:mi:ss') "
        }
        if(unita && unita.size() > 0){
            query = query + "AND s.unitaSmistamento.codice in (:unita) " +
                            "AND s.unitaSmistamento.ottica.codice = :codiceOttica " +
                            "AND s.unitaSmistamento.dal <= current_date " +
                            "AND (s.unitaSmistamento.al is null or s.unitaSmistamento.al >= current_date) " +
                            "AND (s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :utente ) "
        }
        return query
    }


    List<ProtocolloWS> getProtocolliDaRicevere(String queryString, List<String> unita, String oggetto, String dal, String al, String utente, String codiceOttica, List<String> statiSmistamento) {
        try {
            //Setto i parametri a seconda della queryString
            TypedQuery<ProtocolloWS> query =  entityManager.createQuery(queryString, ProtocolloWS.class)
            if(unita && unita.size() > 0) {
                query.setParameter("unita", unita)
                query.setParameter("utente", utente)
                query.setParameter("codiceOttica", codiceOttica)
            }
            if(oggetto && oggetto.length() > 0){
                oggetto = "%"+oggetto+"%"
                query.setParameter("oggetto", oggetto)
            }
            if(dal && dal.length() > 0){
                al = al.concat(" 23:59:59")
                query.setParameter("dal", dal)
                query.setParameter("al", al)
            }
            query.setParameter("statiSmistamento", statiSmistamento)

            return query.getResultList()

        } catch (NoResultException e) {
            return null
        }
    }

}
