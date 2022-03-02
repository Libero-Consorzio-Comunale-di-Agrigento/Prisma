package it.finmatica.protocollo.integrazioni.ricercadocumenti.agsde2

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import groovy.sql.Sql
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.ricercadocumenti.CampiRicerca
import it.finmatica.protocollo.integrazioni.ricercadocumenti.DocumentoEsterno
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.integrazioni.ricercadocumenti.RicercaDocumentiEsterni
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Lazy
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import javax.sql.DataSource
import java.sql.SQLException

/**
 * Created by esasdelli on 03/10/2017.
 */
@Slf4j
@Lazy
@Component
@Order(2)
@Transactional(readOnly = true)
class RicercaDelibere implements RicercaDocumentiEsterni {

    @Qualifier("dataSource_gdm")
    @Autowired
    private DataSource dataSource_gdm

    @Autowired
    private SpringSecurityService springSecurityService

    @Override
    boolean isAbilitato() {
        try {
            new Sql(dataSource_gdm).rows("select 1 from gat_delibera where rownum = 1")
            new Sql(dataSource_gdm).rows("select 1 from AGSDE2_TIPI_REGISTRO where rownum = 1")
            return true
        } catch (SQLException e) {
            // se la select da' errore, significa che la vista non c'è, quindi questo modulo è disabilitato.
            return false
        }
    }

    @Override
    String getTitolo() {
        return "Delibere"
    }

    @Override
    String getDescrizione() {
        return "Ricerca Delibere su Sfera"
    }

    @Override
    String getZulCampiRicerca() {
        return "/protocollo/integrazioni/ricercaDocumenti/agsde2/campiRicercaDelibere.zul"
    }

    @Override
    PagedList<DocumentoEsterno> ricerca(CampiRicerca campiRicerca) {
        try {
            Sql sql = new Sql(dataSource_gdm)
            String select = """select d.anno_delibera,
                               d.numero_delibera,
                               d.id_registro_delibera,
                               d.descr_registro_delibera,
                               d.oggetto,
                               d.id_documento
                          from gat_delibera d
                         where (:anno is null or d.anno_delibera = :anno)
                           and d.data_firma is not null 
                           and (d.data_adozione between :data_dal and :data_al)
                           and (numero_delibera between :numero_dal and :numero_al)
                           and (:oggetto is null or upper (d.oggetto) like '%' || upper (:oggetto) || '%')
                           and (:registro is null or d.id_registro_delibera = :registro)"""
            //    and codice_amministrazione = :codice_amm"""
            String sqlCompetenze = """SELECT anno_delibera, numero_delibera, descr_registro_delibera, oggetto, id_documento
                        FROM (${select}) d
                       WHERE gdm_competenza.gdm_verifica ('DOCUMENTI', d.id_documento, 'L', :utente, 'GDM') = 1
                    ORDER BY anno_delibera DESC, numero_delibera ASC"""
            if (campiRicerca.filtri.ANNO == null
                    && campiRicerca.filtri.NUMERO_DAL == null
                    && campiRicerca.filtri.NUMERO_AL == null
                    && campiRicerca.filtri.REGISTRO?.codice == null
                    && campiRicerca.filtri.OGGETTO == null) {
                throw new ProtocolloRuntimeException("Valorizzare almeno un filtro")
            }
            Map params = [anno: campiRicerca.filtri.ANNO ?: "",
                          numero_dal: campiRicerca.filtri.NUMERO_DAL ?: Integer.MIN_VALUE,
                          numero_al: campiRicerca.filtri.NUMERO_AL ?: Integer.MAX_VALUE,
                          data_dal: new java.sql.Date((campiRicerca.filtri.DATA_DAL ?: new Date().clearTime().copyWith(year: 1800, month: 0, date: 1)).getTime()),
                          data_al: new java.sql.Date((campiRicerca.filtri.DATA_AL ?: new Date().clearTime().copyWith(year: 2800, month: 0, date: 1)).getTime()),
                          registro: campiRicerca.filtri.REGISTRO?.codice ?: "",
                          oggetto: campiRicerca.filtri.OGGETTO ?: "",
                          utente: springSecurityService.principal.id,
                          // codice_amm    : springSecurityService.principal.amm().codice,
                          maxRows: campiRicerca.startFrom + campiRicerca.maxResults,
                          firstRow: campiRicerca.startFrom]
            log.info("Ricerca Delibere: " + sqlCompetenze)
            String sqlPaging = "SELECT * FROM ( SELECT tmp.*, rownum rn FROM ( ${sqlCompetenze} ) tmp WHERE rownum <= :maxRows ) WHERE rn > :firstRow"
            def result = sql.rows(sqlPaging, params)
            List<DocumentoEsterno> documenti = result.collect {
                new DocumentoEsterno(idDocumentoEsterno: it.ID_DOCUMENTO, oggetto: it.OGGETTO, estremi: "${it.NUMERO_DELIBERA} / ${it.ANNO_DELIBERA} - ${it.DESCR_REGISTRO_DELIBERA}")
            }
            String sqlCount = "select count(1) total_count from (${sqlCompetenze})"
            int totalCount = sql.rows(sqlCount, params)[0].TOTAL_COUNT
            return new PagedList<DocumentoEsterno>(documenti, totalCount)
        }
        catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    @Override
    void creaRiferimento(DocumentoEsterno documentoEsterno, String operazione) {
//        return new DocumentoCollegatoDTO(deliberaCollegata: new DeliberaDTO(id: documentoEsterno.idDocumento), operazione: operazione)
    }

    @Override
    CampiRicerca getCampiRicerca() {
        CampiRicerca campiRicerca = new CampiRicerca()
        campiRicerca.filtri = [:]
        campiRicerca.filtri.LISTA_REGISTRI = getRegistri()
        return campiRicerca
    }

    private List<Map> getRegistri() {
        try {
            return new Sql(dataSource_gdm).rows("select '' codice, '' descrizione , 0 ord from dual union SELECT tipo_registro codice, descrizione, 1 ord FROM AGSDE2_TIPI_REGISTRO where delibera = 'Y' order by ord,codice").collect {
                [codice: it.CODICE, descrizione: it.DESCRIZIONE]
            }
        }
        catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }
}
