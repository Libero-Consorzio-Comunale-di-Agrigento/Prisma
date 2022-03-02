package it.finmatica.protocollo.integrazioni.ricercadocumenti.agspr

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import groovy.sql.Sql
import it.finmatica.gestionedocumenti.documenti.TipoDocumento
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.ricercadocumenti.CampiRicerca
import it.finmatica.protocollo.integrazioni.ricercadocumenti.DocumentoEsterno
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.integrazioni.ricercadocumenti.RicercaDocumentiEsterni
import org.hibernate.FetchMode
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Lazy
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.SQLException

/**
 * Created by esasdelli on 02/10/2017.
 */
@Slf4j
@Lazy
@Component
@Order(4)
@Transactional(readOnly = true)
class RicercaProtocolli implements RicercaDocumentiEsterni {

    @Qualifier("dataSource_gdm")
    @Autowired
    private DataSource dataSource_gdm

    @Autowired
    private SpringSecurityService springSecurityService

    @Value("\${finmatica.protocollo.gdm.areaSegreteriaProtocollo}")
    private String areaSegreteriaProtocollo

    @Override
    boolean isAbilitato() {
        return true
    }

    @Override
    String getTitolo() {
        return "Protocolli"
    }

    @Override
    String getDescrizione() {
        return "Ricerca Protocolli"
    }

    @Override
    String getZulCampiRicerca() {
        return "/protocollo/integrazioni/ricercaDocumenti/agspr/campiRicerca.zul"
    }

    @Override
    PagedList<DocumentoEsterno> ricerca(CampiRicerca campiRicerca) {

        try {

            Sql sql = new Sql(dataSource_gdm)

            String select = """SELECT data,
                 anno,
                 numero,
                 descrizione_tipo_registro,
                 oggetto,
                 id_documento
            FROM (SELECT p.data,
                         p.anno,
                         p.numero,
                         p.tipo_registro,
                         p.descrizione_tipo_registro,
                         p.oggetto,
                         p.id_documento
                    FROM proto_view p, documenti d
                   WHERE     p.id_documento = d.id_documento     
                         AND ( :anno IS NULL OR p.anno = :anno)
                         AND (numero BETWEEN :numero_dal AND :numero_al)
                         AND (p.data BETWEEN :data_dal AND :data_al)
                         AND p.oggetto LIKE decode(:oggetto, '', p.oggetto,  '%'||UPPER(:oggetto)||'%') 
                         AND p.tipo_registro LIKE decode(UPPER(:tipo_registro), '', p.tipo_registro, UPPER(:tipo_registro))
                         AND p.modalita LIKE decode(UPPER(:modalita), '', p.modalita, UPPER(:modalita))
                         AND NVL(p.tipo_documento, ' ') LIKE decode(UPPER(:tipo_documento), '', NVL(p.tipo_documento, ' '), UPPER(:tipo_documento))
                  UNION ALL
                  SELECT TO_DATE (NULL),
                         TO_NUMBER (NULL),
                         TO_NUMBER (NULL),
                         TO_CHAR (NULL),
                         TO_CHAR (NULL),
                         TO_CHAR (NULL),
                         TO_NUMBER (NULL)
                    FROM DUAL) p,
                 DUAL
           WHERE    gdm_competenza.gdm_verifica ('DOCUMENTI',
                                                 p.id_documento,
                                                 'L',
                                                 :utente,
                                                 'GDM')
                 || dummy = '1X'
           ORDER BY anno DESC, numero ASC"""

            if (campiRicerca.filtri.ANNO == null
                    && campiRicerca.filtri.NUMERO_DAL == null
                    && campiRicerca.filtri.NUMERO_AL == null
                    && campiRicerca.filtri.NUMERO_AL == null
                    && campiRicerca.filtri.TIPO_DOCUMENTO?.codice == null
                    && campiRicerca.filtri.OGGETTO == null) {

                throw new ProtocolloRuntimeException("Valorizzare almeno un filtro")
            }

            Map params = [anno          : campiRicerca.filtri.ANNO ?: "",
                          numero_dal    : campiRicerca.filtri.NUMERO_DAL ?: Integer.MIN_VALUE,
                          numero_al     : campiRicerca.filtri.NUMERO_AL ?: Integer.MAX_VALUE,
                          data_dal      : new java.sql.Date((campiRicerca.filtri.DATA_DAL ?: new Date().clearTime().copyWith(year: 1800, month: 0, date: 1)).getTime()),
                          data_al       : new java.sql.Date((campiRicerca.filtri.DATA_AL ?: new Date().clearTime().copyWith(year: 2800, month: 0, date: 1)).getTime()),
                          tipo_modalita : campiRicerca.filtri.TIPO_MODALITA?.codice ?: "",
                          tipo_registro : campiRicerca.filtri.TIPO_REGISTRO?.codice ?: "",
                          tipo_documento: campiRicerca.filtri.TIPO_DOCUMENTO?.codice ?: "",
                          oggetto       : campiRicerca.filtri.OGGETTO ?: "",
                          utente        : springSecurityService.principal.id,
                          codice_amm    : springSecurityService.principal.amm().codice,
                          maxRows       : campiRicerca.startFrom + campiRicerca.maxResults,
                          firstRow      : campiRicerca.startFrom,
                          area          : areaSegreteriaProtocollo]

            log.info("Ricerca Protocolli: " + select)

            String sqlPaging = "SELECT * FROM ( SELECT tmp.*, rownum rn FROM ( ${select} ) tmp WHERE rownum <= :maxRows ) WHERE rn > :firstRow"
            def result = sql.rows(sqlPaging, params)
            List<DocumentoEsterno> documenti = result.collect {
                new DocumentoEsterno(idDocumentoEsterno: it.ID_DOCUMENTO, oggetto: it.OGGETTO, estremi: "${it.NUMERO} / ${it.ANNO} - ${it.DESCRIZIONE_TIPO_REGISTRO}")
            }

            String sqlCount = "select count(1) total_count from (${select})"
            int totalCount = sql.rows(sqlCount, params)[0].TOTAL_COUNT

            return new PagedList<DocumentoEsterno>(documenti, totalCount)

        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    @Override
    CampiRicerca getCampiRicerca() {
        return new CampiRicerca(filtri: [LISTA_TIPI_MODALITA : getTipiModalita(),
                                         LISTA_TIPI_REGISTRO : getTipiRegistro(),
                                         LISTA_TIPI_DOCUMENTO: getTipiDocumento()])
    }

    private List<Map> getTipiModalita() {
        List<Map> tipiModalita = []
        tipiModalita.add(0, [codice: "", descrizione: "--"])
        tipiModalita.add(1, [codice: "ARR", descrizione: "Arrivo"])
        tipiModalita.add(2, [codice: "INT", descrizione: "Interno"])
        tipiModalita.add(3, [codice: "PAR", descrizione: "Partenza"])
        return tipiModalita
    }

    private List<Map> getTipiRegistro() {
        List<TipoRegistro> registri = Protocollo.createCriteria().list {
            projections {
                distinct("tipoRegistro")
            }

            eq("valido", true)
            isNotNull("tipoRegistro")

            fetchMode("tipoRegistro", FetchMode.JOIN)
        }

        registri.add(0, new TipoRegistro(codice: "", descrizione: "-- nessuno --"))
        return registri
    }

    private List<TipoDocumento> getTipiDocumento() {
        List<SchemaProtocollo> schemi = Protocollo.createCriteria().list {
            projections {
                distinct("schemaProtocollo")
            }

            schemaProtocollo{
                isNotNull("codice")
                eq("valido", true)
            }

            eq("valido", true)
            isNotNull("schemaProtocollo")
            fetchMode("schemaProtocollo", FetchMode.JOIN)
        }

        schemi.add(0, new SchemaProtocollo(codice: "", descrizione: "-- nessuno --"))
        return schemi
    }

    @Override
    void creaRiferimento(DocumentoEsterno documentoEsterno, String operazione) {

    }
}
