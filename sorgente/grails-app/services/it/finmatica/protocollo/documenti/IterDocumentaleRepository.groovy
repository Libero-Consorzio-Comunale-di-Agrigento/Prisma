package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoMemoRicevuti
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

import javax.persistence.EntityManager
import javax.persistence.NoResultException
import javax.sql.DataSource

@Slf4j
@CompileStatic
@Repository
@Transactional
class IterDocumentaleRepository  {

    private final DataSource dataSource_gdm
    private final DataSource dataSource
    private final EntityManager entityManager

    IterDocumentaleRepository(@Qualifier("dataSource_gdm") DataSource dataSource_gdm, DataSource dataSource, EntityManager entityManager) {
        this.dataSource_gdm = dataSource_gdm
        this.dataSource = dataSource
        this.entityManager = entityManager
    }

    /**
     * Resituisce la queryString per l'estrazione dei documenti dell'iter doumentale
     *
     * @return
     */
    private String getQueryStringIterDocumentaleFromProtocollo(boolean daRicevere = false, boolean assegnati = false, boolean inCarico= false, ricercaCodiceABarre = false) {
        String query = "select s " +
                "from Smistamento s, Protocollo p " +
                "where s.unitaSmistamento.progr = :progrUo " +
                "and s.unitaSmistamento.ottica.codice = :codiceOttica " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and (s.unitaSmistamento.al is null or s.unitaSmistamento.al >= :dataRif) " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and s.statoSmistamento in :statiSmistamento " +
                "and upper(s.documento.tipoOggetto.descrizione) not in :tipoOggettiDaEscludereIncludere " +
                "and s.documento.idDocumentoEsterno = p.idDocumentoEsterno " +
                "and p.valido = 'Y' " +
                "and ( upper(p.oggetto) like upper(:testoRicerca) or :numeroRicerca = p.numero ) "
        if(daRicevere) {
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
                    "OR (    p.riservato = 'Y' " +
                    "AND pu.privilegio =  " + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO+"'"  + " ) ) " +
                    "OR (   pu.privilegio =  " +"'"+PrivilegioUtente.VDDR+"'" + " " +
                    " OR (p.riservato = 'Y' " +
                    "AND pu.privilegio = " +"'"+PrivilegioUtente.VDDRR+"'" + ") ) ) ) " )
        } else if(inCarico){
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
                    "AND (  pu.privilegio =  "  + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA+"'" +" " +
                    "OR (    p.riservato = 'Y' " +
                    "AND pu.privilegio =  " + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO+"'"  + " ) ) ) "
            )
        } else if (assegnati){
            query = query.concat(" and ( s.utenteAssegnatario.id = :idUtente )" )
        }
        if(ricercaCodiceABarre){
            query = query.concat(" and ( s.documento.idDocumentoEsterno = :idDocumentoEsterno )" )
        }

        return query
    }

    /**
     * Resituisce la queryString per l'estrazione dei documenti dell'iter doumentale
     *
     * @return
     */
    private String getQueryStringIterDocumentaleFromMessaggioRicevuto(boolean daRicevere = false, boolean assegnati = false, boolean inCarico= false, ricercaCodiceABarre = false) {
         String queryUnion ="select s " +
                "from Smistamento s, MessaggioRicevuto mr " +
                "where s.unitaSmistamento.progr = :progrUo " +
                "and s.unitaSmistamento.ottica.codice = :codiceOttica " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and (s.unitaSmistamento.al is null or s.unitaSmistamento.al >= :dataRif) " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and s.statoSmistamento in :statiSmistamento " +
                "and s.documento.id= mr.id " +
                "and ( upper(mr.oggetto) like upper(:testoRicerca) ) "
        if(daRicevere) {
            queryUnion = queryUnion.concat(" and ( s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :idUtente )" )
            queryUnion = queryUnion.concat(" AND EXISTS " +
                    " (SELECT 1 " +
                    "FROM PrivilegioUtente pu " +
                    "WHERE pu.progrUnita = s.unitaSmistamento.progr " +
                    "AND pu.appartenenza = 'D' " +
                    "AND pu.utente = :idUtente " +
                    "AND pu.progrUnita = :progrUo " +
                    "AND (pu.al is null or pu.al >= current_date) " +
                    "AND pu.dal <= current_date  " +
                    "AND (   (   pu.privilegio =  "  + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA+"'" +" " +
                    "OR (    mr.riservato = 'Y' " +
                    "AND pu.privilegio =  " + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO+"'"  + " ) ) " +
                    "OR (   pu.privilegio =  " +"'"+PrivilegioUtente.VDDR+"'" + " " +
                    " OR (mr.riservato = 'Y' " +
                    "AND pu.privilegio = " +"'"+PrivilegioUtente.VDDRR+"'" + ") ) ) ) " )
        } else if(inCarico) {
            queryUnion = queryUnion.concat(" and ( s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :idUtente )" )
            queryUnion = queryUnion.concat(" AND EXISTS " +
                    " (SELECT 1 " +
                    "FROM PrivilegioUtente pu " +
                    "WHERE pu.progrUnita = s.unitaSmistamento.progr " +
                    "AND pu.appartenenza = 'D' " +
                    "AND pu.utente = :idUtente " +
                    "AND pu.progrUnita = :progrUo " +
                    "AND (pu.al is null or pu.al >= current_date) " +
                    "AND pu.dal <= current_date  " +
                    "AND (  pu.privilegio =  "  + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA+"'" +" " +
                    "OR (    mr.riservato = 'Y' " +
                    "AND pu.privilegio =  " + "'"+PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO+"'"  + " ) ) ) "
            )
        }
        else if (assegnati){
            queryUnion = queryUnion.concat(" and ( s.utenteAssegnatario.id = :idUtente )" )
        }
        if(ricercaCodiceABarre){
            queryUnion = queryUnion.concat(" and ( s.documento.id = :id )" )
        }
        return queryUnion
    }



    /**
     * Resituisce la queryString per l'estrazione dei documenti dell'iter doumentale
     *
     * @return
     */
    private String getQueryStringIterDocumentaleFromMemoRicevutoGDM(boolean daRicevere = false, boolean assegnati = false, boolean inCarico= false, ricercaCodiceABarre = false) {
        String queryUnion ="select s " +
                "from SmistamentoMemoRicevuti s, MemoRicevutiGDM mr " +
                "where s.unitaSmistamento.progr = :progrUo " +
                "and s.unitaSmistamento.ottica.codice = :codiceOttica " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and (s.unitaSmistamento.al is null or s.unitaSmistamento.al >= :dataRif) " +
                "and s.unitaSmistamento.dal <= :dataRif " +
                "and s.statoSmistamento in :statiSmistamento " +
                "and s.idrif = mr.idrif " +
                "and ( upper(mr.oggetto) like upper(:testoRicerca) ) "
        if(daRicevere) {
            queryUnion = queryUnion.concat(" and ( s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :idUtente )" )
        } else if(inCarico) {
            queryUnion = queryUnion.concat(" and ( s.utenteAssegnatario.id is null or s.utenteAssegnatario.id = :idUtente )" )
        }
        else if (assegnati){
            queryUnion = queryUnion.concat(" and ( s.utenteAssegnatario.id = :idUtente )" )
        }
        if(ricercaCodiceABarre){
            queryUnion = queryUnion.concat(" and ( s.documento.id = :id )" )
        }
        return queryUnion
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
    public List<Smistamento> getDocumentiIterFromProtocollo(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                             List < String > tipoOggettiDaEscludereIncludere, String testoRicerca, Integer numeroRicerca, String idUtente) {
        try {
            //Setto i parametri a seconda della queryString
            return  entityManager.createQuery(queryString, Smistamento)
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

    public List<Smistamento> getDocumentiIterFromProtocolloByCodiceABarre(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                                            List < String > tipoOggettiDaEscludereIncludere, String testoRicerca, Integer numeroRicerca, String idUtente, Long idDocumentoEsterno) {
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
                    .setParameter("idDocumentoEsterno", idDocumentoEsterno)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }

    /**
     *
     * @param queryString
     * @param progrUo
     * @param codiceOttica
     * @param dataRif
     * @param statiSmistamento
     * @param tipoOggettiDaEscludereIncludere
     * @param testoRicerca
     * @param idUtente
     * @param verificaAssegnatario
     * @return
     */
    public List<Smistamento> getDocumentiIterFromMessaggioRicevuto(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                             String testoRicerca, String idUtente ) {
        try {
            //Setto i parametri a seconda della queryString
            return  entityManager.createQuery(queryString, Smistamento)
                    .setParameter("progrUo", progrUo)
                    .setParameter("codiceOttica", codiceOttica)
                    .setParameter("dataRif", dataRif)
                    .setParameter("statiSmistamento", statiSmistamento)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("idUtente", idUtente)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }

    public List<Smistamento> getDocumentiIterFromMessaggioRicevutoByCodiceABarre(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                                                   String testoRicerca, String idUtente, Long id ) {
        try {
            //Setto i parametri a seconda della queryString
            return entityManager.createQuery(queryString, Smistamento)
                    .setParameter("progrUo", progrUo)
                    .setParameter("codiceOttica", codiceOttica)
                    .setParameter("dataRif", dataRif)
                    .setParameter("statiSmistamento", statiSmistamento)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("idUtente", idUtente)
                    .setParameter("id", id)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }

    /**
     *
     * @param queryString
     * @param progrUo
     * @param codiceOttica
     * @param dataRif
     * @param statiSmistamento
     * @param tipoOggettiDaEscludereIncludere
     * @param testoRicerca
     * @param idUtente
     * @param verificaAssegnatario
     * @return
     */
    public List<SmistamentoMemoRicevuti> getDocumentiIterFromMemoRicevuto(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                                                          String testoRicerca, String idUtente ) {
        try {
            //Setto i parametri a seconda della queryString
            return  entityManager.createQuery(queryString, SmistamentoMemoRicevuti)
                    .setParameter("progrUo", progrUo)
                    .setParameter("codiceOttica", codiceOttica)
                    .setParameter("dataRif", dataRif)
                    .setParameter("statiSmistamento", statiSmistamento)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("idUtente", idUtente)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }

    public List<SmistamentoMemoRicevuti> getDocumentiIterFromMemoRicevutoByCodiceABarre(String queryString, Long progrUo, String codiceOttica, Date dataRif, List < String > statiSmistamento,
                                                                                 String testoRicerca, String idUtente, Long id ) {
        try {
            //Setto i parametri a seconda della queryString
            return entityManager.createQuery(queryString, SmistamentoMemoRicevuti)
                    .setParameter("progrUo", progrUo)
                    .setParameter("codiceOttica", codiceOttica)
                    .setParameter("dataRif", dataRif)
                    .setParameter("statiSmistamento", statiSmistamento)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("idUtente", idUtente)
                    .setParameter("id", id)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }

}
