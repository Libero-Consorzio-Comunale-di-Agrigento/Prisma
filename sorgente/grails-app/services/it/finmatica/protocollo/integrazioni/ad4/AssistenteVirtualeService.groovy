package it.finmatica.protocollo.integrazioni.ad4

import groovy.sql.Sql
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.SQLException

@Transactional
@Service
class AssistenteVirtualeService {
    private final static String AREA_APPLICATICA = "Affari Generali"
    private final static String MODULO_SOFTWARE = "AGSPR"

    final static String PAGINA_APPLICATICA_PROTOCOLLAZIONE = "Protocollazione"
    final static String PAGINA_APPLICATICA_LETTERA         = "Lettera"
    final static String PAGINA_APPLICATICA_PROVVEDIMENTO   = "Provvedimento di Annullamento"

    @Autowired DataSource dataSource

    String getUrlAssistenteViruale(String paginaApplicativa) {
        try {
            Sql sql = new Sql(dataSource)

            return sql.firstRow("select AD4_ASSISTENTE_VIRTUALE_PKG.get_link_av(?, ?, ?) URL from dual", [AREA_APPLICATICA, MODULO_SOFTWARE, paginaApplicativa]).URL
        } catch (SQLException e) {

            return ""
        }
    }
}
