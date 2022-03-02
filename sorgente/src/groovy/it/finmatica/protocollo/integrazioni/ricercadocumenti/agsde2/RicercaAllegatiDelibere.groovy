package it.finmatica.protocollo.integrazioni.ricercadocumenti.agsde2

import it.finmatica.ad4.security.SpringSecurityService
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.integrazioni.ricercadocumenti.CampiRicerca
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.integrazioni.ricercadocumenti.RicercaAllegatiDocumentiEsterni
import org.opensaml.saml1.binding.artifact.SAML1ArtifactBuilder
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
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
@Order(2)
@Slf4j
class RicercaAllegatiDelibere implements RicercaAllegatiDocumentiEsterni {

    @Qualifier("dataSource_gdm")
    @Autowired
    private DataSource dataSource_gdm

    @Autowired
    private SpringSecurityService springSecurityService

    @Override
    boolean isAbilitato() {
        try {
            new Sql(dataSource_gdm).rows("select 1 from AGSDE2_DELIBERE_ALLEGATI where rownum = 1")
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
        return "Ricerca Allegati Delibere su Sfera"
    }

    @Override
    String getZulCampiRicerca() {
        return "/protocollo/integrazioni/ricercaDocumenti/agsde2/campiRicercaDelibere.zul"
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
                                       anno_delibera,
                                       numero_delibera,
                                       data_numero_delibera,
                                       oggetto,
                                       codice_registro,
                                       registro,
                                       nome
                                FROM AGSDE2_DELIBERE_ALLEGATI
                                WHERE   ( :anno IS NULL OR anno_delibera = :anno)
                                        AND (numero_delibera BETWEEN :numero_dal AND :numero_al)
                                        AND ( :registro IS NULL OR codice_registro = :registro)
                                        AND ( :esito IS NULL OR codice_esito = :esito)
                                        AND ( :oggetto IS NULL OR UPPER (oggetto) LIKE '%' || UPPER ( :oggetto) || '%')
                                        and ente = :codice_amm """
            String stmSQL = """  SELECT distinct deli.id_documento id_documento, deli.id_documento_esterno id_documento_esterno, tipo_documento,
                                                id_file_esterno, id_file_allegato, anno_delibera, numero_delibera,
                                                data_numero_delibera, oggetto, codice_registro, registro, nome
                                        FROM (${select} ) deli, documenti d,
                                                oggetti_file o
                                        WHERE deli.id_file_esterno = o.id_oggetto_file
                                        AND o.id_documento = d.id_documento
                                        AND gdm_competenza.gdm_verifica ('DOCUMENTI', d.id_documento,'L',:utente,'GDM') = 1
                                        ORDER BY anno_delibera ASC, numero_delibera ASC"""
            Map params = [anno: campiRicerca.filtri.ANNO ?: "",
                          numero_dal: campiRicerca.filtri.NUMERO_DAL ?: Integer.MIN_VALUE,
                          numero_al: campiRicerca.filtri.NUMERO_AL ?: Integer.MAX_VALUE,
                          registro: campiRicerca.filtri.REGISTRO?.codice ?: "",
                          esito: campiRicerca.filtri.ESITO?.codice ?: "",
                          oggetto: campiRicerca.filtri.OGGETTO ?: "",
                          utente: springSecurityService.principal.id,
                          codice_amm: springSecurityService.principal.amm().codice,
                          maxRows: campiRicerca.startFrom + campiRicerca.maxResults,
                          firstRow: campiRicerca.startFrom]
            log.info("*****RICERCA ALLEGATI DELIBERE******" + stmSQL)
            String sqlPaging = "SELECT * FROM ( SELECT tmp.*, rownum rn FROM ( ${stmSQL} ) tmp WHERE rownum <= :maxRows ) WHERE rn > :firstRow"
            def result = sql.rows(sqlPaging, params)
            List<AllegatoEsterno> allegati = result.collect {
                row ->
                    new AllegatoEsterno(idDocumentoPrincipale: row[0],
                            idDocumentoEsterno: row[1],
                            tipoDocumento: "DETERMINA",
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
            throw new ProtocolloRuntimeException(e)
        }
    }

    @Override
    CampiRicerca getCampiRicerca() {
        CampiRicerca campiRicerca = new CampiRicerca()
        campiRicerca.filtri = [:]
        campiRicerca.filtri.LISTA_ESITI = getEsiti()
        campiRicerca.filtri.LISTA_REGISTRI = getRegistri()
        return campiRicerca
    }

    private List<Map> getRegistri() {
        try {
            return new Sql(dataSource_gdm).rows("select '' codice, '' descrizione , 0 ord from dual union SELECT tipo_registro codice, descrizione, 1 ord FROM AGSDE2_TIPI_REGISTRO where delibera = 'Y' order by ord,codice").collect {
                [codice: it.CODICE, descrizione: it.DESCRIZIONE]
            }
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    private List<Map> getEsiti(String ente) {
        try {
            return new Sql(dataSource_gdm).rows("select '' codice, '' descrizione , 0 ord from dual union SELECT titolo codice, descrizione, 1 ord FROM AGSDE2_ODG_ESITI where crea_delibera = 'Y' order by ord,codice").collect {
                [codice: it.CODICE, descrizione: it.DESCRIZIONE]
            }
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }
}
