package it.finmatica.protocollo.scaricoipa

import groovy.sql.Sql
import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.Connection
import java.sql.SQLException

@Slf4j
@Transactional
@Service
class As4IpaService {

    @Autowired
    DataSource dataSource

    String as4_anagrafici_pkg_allinea_anagrafica_amm_da_ipa(ScaricoIpaFilter record, String ni) {
        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)

        String msg = ""
        Date dataAgg

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record?.dataAggiornamento)
        } else {
            dataAgg = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        try {
            sql.call("{ call as4.anagrafici_pkg.allinea_anagrafica_amm_da_ipa( "+
                    " p_ni  => ?, " +
                            " p_cognome  => ?, " +
                            " p_codice_fiscale  => ?, " +
                            " p_competenza  => ?, " +
                            " p_competenza_esclusiva  => ?, " +
                            " p_tipo_soggetto  => ?, " +
                            " p_stato_soggetto  => ?, " +
                            " p_note_anag  => ?, " +
                            " p_indirizzo_res  => ?, " +
                            " p_provincia_res  => ?, " +
                            " p_comune_res  => ?, " +
                            " p_cap_res  => ?, " +
                            " p_tel_res  => ?, " +
                            " p_fax_res  => ?, " +
                            " p_utente  => ?, " +
                            " p_data_agg  => ?  " +
                            ") }"
                    , [
                    ni
                    , record?.descrizione
                    , record?.codiceFiscaleAmm
                    , record?.competenza
                    , record?.competenzaEsclusiva
                    , 'E'
                    , 'U'
                    , record?.codiceAmministrazione
                    , record?.indirizzo
                    , (record?.ad4Provincia) ? record.ad4Provincia.id : null
                    , (record?.ad4Comune) ? record.ad4Comune.comune : null
                    , record?.cap
                    , record?.telefono
                    , record?.fax
                    , record?.utenteAggiornamento
                    , (dataAgg ? new java.sql.Date(dataAgg.time) : null)
            ])

            msg = "OK"
        } catch (SQLException e) {
            log.warn("as4_anagrafici_pkg_allinea_anagrafica_amm_da_ipa -> " + e.toString())
            msg = e.toString()
        }

        return msg
    }
}