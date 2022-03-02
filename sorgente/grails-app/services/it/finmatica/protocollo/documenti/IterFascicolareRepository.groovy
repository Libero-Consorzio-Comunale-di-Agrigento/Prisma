package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.smistamenti.Smistamento
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
class IterFascicolareRepository  {

    private final DataSource dataSource_gdm
    private final DataSource dataSource
    private final EntityManager entityManager

    IterFascicolareRepository(@Qualifier("dataSource_gdm") DataSource dataSource_gdm, DataSource dataSource, EntityManager entityManager) {
        this.dataSource_gdm = dataSource_gdm
        this.dataSource = dataSource
        this.entityManager = entityManager
    }

    /**
     * Resituisce la queryString per l'estrazione dei documenti dell'iter doumentale
     *
     * @return
     */
    private String getQueryStringIterFascicolareFromFascicolo(boolean daRicevere = false, boolean assegnati = false, boolean inCarico= false, ricercaCodiceABarre = false) {
        String query = "select s " +
                "from Smistamento s, Fascicolo f " +
                "where s.unitaSmistamento.progr = :progrUo " +
                "and s.unitaSmistamento.ottica.codice = :codiceOttica " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and (s.unitaSmistamento.al is null or s.unitaSmistamento.al >= :dataRif) " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and s.statoSmistamento in :statiSmistamento " +
                "and upper (s.documento.tipoOggetto.descrizione) in :tipoOggettiDaEscludereIncludere " +
                "and s.documento.id = f.id " +
                "and ( upper(f.oggetto) like upper(:testoRicerca) or upper(f.nome) like upper (:testoRicerca)  or f.numero like :numeroRicerca ) "
        if(daRicevere ) {
            query = query.concat(" and ( s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :idUtente )" )
            query = query.concat(" AND EXISTS " +
                                   " (SELECT 1 " +
                                      "FROM PrivilegioUtente pu " +
                                      "WHERE pu.progrUnita = s.unitaSmistamento.progr " +
                                            "AND pu.appartenenza = 'D' " +
                                            "AND pu.utente = :idUtente " +
                                            "AND pu.progrUnita = :progrUo " +
                                            "AND (pu.al is null or pu.al >= current_date) " +
                                            "AND pu.dal <= current_date  " +
                                            "AND (   (   pu.privilegio =  "  + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA+"'" +" " +
                                                        "OR (    f.riservato = 'Y' " +
                                                        "AND pu.privilegio =  " + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO+"'"  + " ) ) " +
                                                        "OR (   pu.privilegio =  " +"'"+PrivilegioUtente.VDDR+"'" + " " +
                                                        " OR (f.riservato = 'Y' " +
                                                        "AND pu.privilegio = " +"'"+PrivilegioUtente.VDDRR+"'" + ") ) ) )" )
         } else if(inCarico) {
            query = query.concat(" and ( s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :idUtente )" )
            query = query.concat("AND EXISTS " +
                                " (SELECT 1 " +
                                "FROM PrivilegioUtente pu " +
                                "WHERE pu.progrUnita = s.unitaSmistamento.progr " +
                                "AND pu.appartenenza = 'D' " +
                                "AND pu.utente = :idUtente " +
                                "AND pu.progrUnita = :progrUo " +
                                "AND (pu.al is null or pu.al >= current_date) " +
                                "AND pu.dal <= current_date  " +
                                "AND (  pu.privilegio =  "  + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA+"'" +" " +
                                        "OR (    f.riservato = 'Y' " +
                                        "AND pu.privilegio =  " + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO+"'"  + " ) ) ) " )
        }
        else if (assegnati) {
            query = query.concat(" and ( s.utenteAssegnatario.id = :idUtente ) ")
        }
        if(ricercaCodiceABarre){
            query = query.concat(" and ( s.documento.id = :idDocumento )" )
        }
        if(daRicevere){
            query = query.concat(" order by s.dataSmistamento desc")
        } else {
            query = query.concat(" order by s.lastUpdated desc")
        }

        return query
    }

     /**
     *
     * @param queryString query da eseguire, completa evenentualmente, con order by dinamico
     * @param progrUo
     * @param codiceOttica
     * @param dataRif
     * @param statiSmistamento
     * @param tipoOggettiDaEscludereIncludere
     * @param testoRicerca
     * @param numeroRicerca
     * @return
     */
    public List<Smistamento> getFascicoliIterFromFascicolo(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                                            List < String > tipoOggettiDaEscludereIncludere, String testoRicerca, String numeroRicerca, String idUtente) {
        try {
            //Setto i parametri a seconda della queryString
            return entityManager.createQuery(queryString, Smistamento)
                    .setParameter("progrUo", progrUo)
                    .setParameter("codiceOttica", codiceOttica)
                    .setParameter("dataRif", dataRif)
                    .setParameter("statiSmistamento", statiSmistamento)
                    .setParameter("tipoOggettiDaEscludereIncludere", tipoOggettiDaEscludereIncludere)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("numeroRicerca", numeroRicerca)
                    .setParameter("idUtente", idUtente)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }

    public List<Smistamento> getFascicoliIterFromFascicoloByCodiceABarre(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                                                          List < String > tipoOggettiDaEscludereIncludere, String testoRicerca, String numeroRicerca, String idUtente, Long idDocumento) {
        try {
            //Setto i parametri a seconda della queryString
            return entityManager.createQuery(queryString, Smistamento)
                    .setParameter("progrUo", progrUo)
                    .setParameter("codiceOttica", codiceOttica)
                    .setParameter("dataRif", dataRif)
                    .setParameter("statiSmistamento", statiSmistamento)
                    .setParameter("tipoOggettiDaEscludereIncludere", tipoOggettiDaEscludereIncludere)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("numeroRicerca", numeroRicerca)
                    .setParameter("idUtente", idUtente)
                    .setParameter("idDocumento", idDocumento)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }



}
