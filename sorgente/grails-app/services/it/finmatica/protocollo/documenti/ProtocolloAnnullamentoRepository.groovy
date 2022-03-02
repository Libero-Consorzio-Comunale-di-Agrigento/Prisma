package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.protocollo.documenti.annullamento.StatoAnnullamento
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
class ProtocolloAnnullamentoRepository  {

    private final DataSource dataSource_gdm
    private final DataSource dataSource
    private final EntityManager entityManager

    ProtocolloAnnullamentoRepository(@Qualifier("dataSource_gdm") DataSource dataSource_gdm, DataSource dataSource, EntityManager entityManager) {
        this.dataSource_gdm = dataSource_gdm
        this.dataSource = dataSource
        this.entityManager = entityManager
    }

    /**
     * Resituisce la queryString per l'estrazione dei documenti da annullare
     * Uso questo metodo per poter concatenere l'order by in modo dinamico
     * Altrimenti avrei dovuto usare in alternativa i criteria.
     *
     * @return
     */
    private String getQueryStringProtocolloDaAnnullare() {
        return "select  p " +
                "from Protocollo p " +
                "where p.tipoProtocollo.categoria in :categorie " +
                "and p.stato = :statoDocumento " +
                "and p.numero is not null " +
                "and p.anno is not null " +
                "and p.valido = 'Y' " +
                "and ( upper(p.oggetto) like upper(:testoRicerca) or upper(p.tipoProtocollo.commento) like upper (:testoRicerca)  or :numeroRicerca = p.numero ) " +
                "and exists(select 1 from ProtocolloAnnullamento pa where pa.protocollo.id = p.id and pa.stato = :statoAnnullamento) " +
                "and not exists(select 1 from DocumentoCollegato dc where dc.collegato.id = p.id  and dc.tipoCollegamento.codice = :tipoCollegamento and dc.valido = 'Y' )"
    }

    /**
     *
     * @param queryString query da eseguire, completa evenentualmente, con order by dinamico
     * @param categorie
     * @param statoDocumento
     * @param statoAnnullamento
     * @param testoRicerca
     * @param numeroRicerca
     * @return
     */
    public List<Protocollo> getProtocolliDaAnnulare(String queryString, List<String> categorie, StatoDocumento statoDocumento, StatoAnnullamento statoAnnullamento, String testoRicerca, Integer numeroRicerca, String tipoCollegamento) {
        try {
            return entityManager.createQuery(queryString, Protocollo)
                    .setParameter("categorie", categorie)
                    .setParameter("testoRicerca", testoRicerca)
                    .setParameter("statoDocumento", statoDocumento)
                    .setParameter("statoAnnullamento", statoAnnullamento)
                    .setParameter("numeroRicerca", numeroRicerca)
                    .setParameter("tipoCollegamento", tipoCollegamento)
                    .getResultList()
        } catch (NoResultException e) {
            return null
        }
    }


    Protocollo getProtocolloDaAnnullare( List<String> categorie, StatoDocumento statoDocumento, StatoAnnullamento statoAnnullamento, Integer anno, Integer numero, String codiceTipoRegistro, String tipoCollegamento ) {
        return entityManager.createQuery("select  p " +
                "from Protocollo p " +
                "where p.tipoProtocollo.categoria in :categorie " +
                "and p.stato = :statoDocumento " +
                "and p.numero = :numero " +
                "and p.anno = :anno " +
                "and p.valido = 'Y' " +
                "and p.tipoRegistro.codice = :codiceTipoRegistro " +
                "and exists(select 1 from ProtocolloAnnullamento pa where pa.protocollo.id = p.id and pa.stato = :statoAnnullamento) " +
                "and not exists(select 1 from DocumentoCollegato dc where dc.collegato.id = p.id  and dc.tipoCollegamento.codice = :tipoCollegamento and dc.valido = 'Y' ) ", Protocollo)
                .setParameter("categorie", categorie)
                .setParameter("anno", anno)
                .setParameter("numero", numero)
                .setParameter("codiceTipoRegistro", codiceTipoRegistro)
                .setParameter("statoDocumento", statoDocumento)
                .setParameter("statoAnnullamento", statoAnnullamento)
                .setParameter("tipoCollegamento", tipoCollegamento)
                .getResultList()[0]
    }

}
