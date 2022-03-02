package it.finmatica.protocollo.integrazioni.ricercadocumenti.agsde2

import it.finmatica.ad4.security.SpringSecurityService
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.integrazioni.ricercadocumenti.CampiRicerca
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.integrazioni.ricercadocumenti.RicercaAllegatiDocumentiEsterni
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Conditional
import org.springframework.context.annotation.Lazy
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import javax.sql.DataSource
import java.sql.SQLException

/**
 * Created by DScandurra on 05/12/2017.
 */
@Lazy
@Component
@Order(1)
@Slf4j
class RicercaAllegatiDetermine implements RicercaAllegatiDocumentiEsterni {

    @Qualifier("dataSource_gdm")
    @Autowired
    private DataSource dataSource_gdm

    @Autowired
    private SpringSecurityService springSecurityService

    @Override
    boolean isAbilitato() {
        try {
            new Sql(dataSource_gdm).rows("select 1 from AGSDE2_DETERMINE_ALLEGATI where rownum = 1")
            return true
        } catch (SQLException e) {
            // se la select da' errore, significa che la vista non c'è, quindi questo modulo è disabilitato.
            return false
        }
    }

    @Override
    String getTitolo() {
        return "Determine"
    }

    @Override
    String getDescrizione() {
        return "Ricerca Allegati Determine su Sfera"
    }

    @Override
    String getZulCampiRicerca() {
        return "/protocollo/integrazioni/ricercaDocumenti/agsde2/campiRicercaDetermine.zul"
    }

    @Override
    PagedList<AllegatoEsterno> ricerca(CampiRicerca campiRicerca) {
        try {
            Sql sql = new Sql(dataSource_gdm)
            String select = """SELECT  id_documento,
                                       id_documento_esterno,
                                       tipo_documento,
                                       id_file_esterno,
                                       id_file_allegato,
                                       anno_determina,
                                       numero_determina,
                                       data_numero_determina,
                                       oggetto,
                                       codice_registro,
                                       registro,
                                       nome                  
                                    FROM AGSDE2_DETERMINE_ALLEGATI
                                WHERE   ( :anno IS NULL OR anno_determina = :anno)
                                        AND (numero_determina BETWEEN :numero_dal AND :numero_al)
                                        AND ( :registro IS NULL OR codice_registro = :registro)
                                        AND ( :oggetto IS NULL OR UPPER (oggetto) LIKE '%' || UPPER ( :oggetto) || '%')
                                        and ente = :codice_amm """
            String stmSQL = """  SELECT distinct det.id_documento id_documento, det.id_documento_esterno id_documento_esterno, tipo_documento,
                                                id_file_esterno, id_file_allegato, anno_determina, numero_determina,
                                                data_numero_determina, oggetto, codice_registro, registro, nome
                                        FROM (${select} ) det, documenti d,
                                                oggetti_file o
                                        WHERE det.id_file_esterno = o.id_oggetto_file
                                        AND o.id_documento = d.id_documento
                                        AND gdm_competenza.gdm_verifica ('DOCUMENTI', d.id_documento,'L',:utente,'GDM') = 1
                                        ORDER BY anno_determina ASC, numero_determina ASC"""
            Map params = [anno      : campiRicerca.filtri.ANNO ?: "",
                          numero_dal: campiRicerca.filtri.NUMERO_DAL ?: Integer.MIN_VALUE,
                          numero_al : campiRicerca.filtri.NUMERO_AL ?: Integer.MAX_VALUE,
                          registro  : campiRicerca.filtri.REGISTRO?.codice ?: "",
                          esito     : campiRicerca.filtri.ESITO?.codice ?: "",
                          oggetto   : campiRicerca.filtri.OGGETTO ?: "",
                          utente    : springSecurityService.principal.id,
                          codice_amm: springSecurityService.principal.amm().codice,
                          maxRows   : campiRicerca.startFrom + campiRicerca.maxResults,
                          firstRow  : campiRicerca.startFrom]
            log.info("*****RICERCA ALLEGATI DETERMINE******" + stmSQL)
            String sqlPaging = "SELECT * FROM ( SELECT tmp.*, rownum rn FROM ( ${stmSQL} ) tmp WHERE rownum <= :maxRows ) WHERE rn > :firstRow"
            def result = sql.rows(sqlPaging, params)
            List<AllegatoEsterno> allegati = result.collect {
                row ->
                    new AllegatoEsterno(idDocumentoPrincipale: row[0],
                            idDocumentoEsterno: row[1],
                            tipoDocumento: row[2],
                            idFileEsterno: row[3],
                            idFileAllegato: row[4],
                            nome: row[11],
                            contentType: "application/octet-stream",
                            estremi: "${row[10]} - ${row[6]} / ${row[5]} - del ${row[7]?.format("dd/MM/yyyy")}",
                            oggetto: row[8])
            }
            String sqlCount = "select count(1) total_count from (${stmSQL})"
            int totalCount = sql.rows(sqlCount, params)[0].TOTAL_COUNT
            return new PagedList<AllegatoEsterno>(allegati, totalCount)
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e.message)
        }
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
            return new Sql(dataSource_gdm).rows("select '' codice, '' descrizione , 0 ord from dual union SELECT tipo_registro codice, descrizione, 1 ord FROM AGSDE2_TIPI_REGISTRO where determina = 'Y' order by ord,codice").collect {
                [codice: it.CODICE, descrizione: it.DESCRIZIONE]
            }
        } catch (SQLException e) {
            new ProtocolloRuntimeException(e)
        }
    }
}

