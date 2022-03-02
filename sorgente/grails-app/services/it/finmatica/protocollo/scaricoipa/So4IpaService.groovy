package it.finmatica.protocollo.scaricoipa

import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.integrazioni.So4UnitaBase
import it.finmatica.so4.login.So4SpringSecurityService
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4Ottica
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.Connection
import java.sql.SQLException

@Transactional
@Service
@Slf4j
class So4IpaService {

    @Autowired
    DataSource dataSource
    @Autowired
    So4SpringSecurityService springSecurityService

    String so4_ammi_pkg_ins(ScaricoIpaFilter record, def ni) {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)

        String msg = "OK"
        Date dataAgg = null
        Date dataIst = null
        Date dataSosp = null

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record?.dataAggiornamento)
        } else {
            dataAgg = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        if (record?.dataIstituzione != null) {
            dataIst = new Date().parse('dd/MM/yyyy', record?.dataIstituzione)
        } else {
            dataIst = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        if (record?.dataSoppressione != null) {
            dataSosp = new Date().parse('dd/MM/yyyy', record?.dataSoppressione)
        }

        try {
            sql.call("{ call so4.amministrazione.ins( " +
                    " p_codice_amministrazione  => ?, " +
                    " p_ni  => ?,  " +
                    " p_data_istituzione  => ?, " +
                    " p_data_soppressione  => ?, " +
                    " p_ente  => ?,  " +
                    " p_utente_aggiornamento  => ?, " +
                    " p_data_aggiornamento  => ? " +
                    " )} "
                    , [
                    record?.codiceAmministrazione
                    , ni
                    , (dataIst ? new java.sql.Date(dataIst.time) : null)
                    , (dataSosp ? new java.sql.Date(dataSosp.time) : null)
                    , ((record?.ente) ? "SI" : "NO")
                    , record?.ad4UtenteAgg.utente
                    , (dataAgg ? new java.sql.Date(dataAgg.time) : null)
            ])

            msg = "OK"
        } catch (SQLException e) {
            log.warn("so4_ammi_pkg_ins -> " + e.toString())
            msg = e.toString()
        }

        return msg
    }

    String so4_inte_pkg_agg_automatico(ScaricoIpaFilter record, def id_amm, def id_aoo, def id_uo, String entita) {

        Date dataAgg = null

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record?.dataAggiornamento)
        }

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = "OK"

        try {

            sql.call("{ call so4.indirizzo_telematico.agg_automatico( " +
                    " p_tipo_entita  => ?, " +
                    " p_id_amministrazione  => ?, " +
                    " p_id_aoo => ?, " +
                    " p_id_unita_organizzativa => ?, " +
                    " p_tipo_indirizzo  => ?,  " +
                    " p_indirizzo  => ?, " +
                    " p_contatti  => ?,  " +
                    " p_utente_aggiornamento  => ?, " +
                    " p_data_aggiornamento  => ? " +
                    " )}"
                    , [
                    entita
                    , id_amm
                    , id_aoo
                    , id_uo
                    , 'I'
                    , record?.mail
                    , ''
                    , record?.ad4UtenteAgg.utente
                    , (dataAgg ? new java.sql.Date(dataAgg.time) : null)
            ])
            msg = "OK"
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_inte_pkg_upd_column(String d_codice_amm, String colonna, String valore, String tipo) {

        Date data
        if (tipo == "D") {
            data = new Date().parse('dd/MM/yyyy', valore)
        }

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = "OK"

        try {

            sql.call("{ call so4.amministrazione.upd_column( " +
                    " p_codice_amministrazione  => ?, " +
                    " p_column  => ?,  " +
                    " p_value  => ? " +
                    " )}"
                    , [
                    d_codice_amm
                    , colonna
                    , ((tipo == "D") ? (data ? new java.sql.Date(data.time) : null) : valore)
            ])

            msg = "OK"
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_aoo_pkg_upd_column(String d_progr_aoo, Date dataDal, String colonna, String valore, String tipo) {

        Date data
        if (tipo == "D") {
            data = new Date().parse('dd/MM/yyyy', valore)
        }

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = "OK"

        try {

            sql.call("{ call so4.aoo_pkg.upd_column( " +
                    " p_progr_aoo  => ?, " +
                    " p_dal  => ?,  " +
                    " p_column  => ?,  " +
                    " p_value  => ? " +
                    ") }"
                    , [
                    d_progr_aoo.toLong()
                    , (dataDal ? new java.sql.Date(dataDal.time) : null)
                    , colonna
                    , ((tipo == "D") ? (data ? new java.sql.Date(data.time) : null) : valore)
            ])

            msg = "OK"
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_codici_ipa_tpk_del(String tipoEntita, String progressivo) {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = "OK"

        try {

            sql.call("{ call so4.codici_ipa_tpk.del( " +
                    " p_tipo_entita  => ?, " +
                    " p_progressivo  => ? " +
                    " ) } "
                    , [
                    tipoEntita
                    , progressivo
            ])

            msg = "OK"
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_codici_ipa_tpk_ins(String tipoEntita, String progressivo, String codice) {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = "OK"

        try {

            sql.call("{ call so4.codici_ipa_tpk.ins( " +
                    " p_tipo_entita  => ?, " +
                    " p_progressivo  => ?, " +
                    " p_codice_originale  => ? " +
                    " ) }"
                    , [
                    tipoEntita
                    , progressivo
                    , codice
            ])

            msg = "OK"
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    List<So4AOO> listAooByAsAmmAsAoo(String codice_amm, String codice_aoo) {
        return So4AOO.executeQuery(" select aoo1.progr_aoo, aoo1.dal, aoo1.al " +
                " from So4AOO aoo1 " +
                " where aoo1.amministrazione.codice=:codice_amm " +
                " and aoo1.codice=:codice_aoo " +
                " and nvl(aoo1.al, to_date('3333333','j')) = " +
                " ( " +
                "   select max(nvl(aoo2.al,to_date('3333333','j'))) " +
                "   from So4AOO aoo2 " +
                "   where aoo2.amministrazione.codice=:codice_amm " +
                "   and aoo2.codice=:codice_aoo " +
                " ) "
                , [codice_amm: codice_amm, codice_aoo: codice_aoo])
    }

    So4AOO listAooByAsAmmAsAoo1(String codice_amm, String codice_aoo) {
        return So4AOO.executeQuery(" select aoo1.progr_aoo, aoo1.dal, aoo1.al " +
                " from So4AOO aoo1 " +
                " where aoo1.amministrazione.codice=:codice_amm " +
                " and aoo1.codice=:codice_aoo " +
                " and nvl(aoo1.al, to_date('3333333','j')) = " +
                " ( " +
                "  select max(nvl(aoo2.al,to_date('3333333','j'))) " +
                "  from So4AOO aoo2 " +
                "  where aoo2.amministrazione.codice=:codice_amm " +
                "  and aoo2.codice=:codice_aoo " +
                " ) "
                , [codice_amm: codice_amm, codice_aoo: codice_aoo])
    }

    List<So4UnitaBase> listUnitaByAsAmmAsUo(String codice_amm, String codice_uo) {
        return So4UnitaBase.executeQuery(" select a1.progr, a1.dal, a1.al " +
                " from So4UnitaBase a1 " +
                " where a1.amministrazione=upper(:codice_amm) " +
                " and a1.codice=upper(:codice_uo) " +
                " and nvl(a1.al, to_date('3333333','j')) = " +
                " ( " +
                "   select max(nvl(a2.al,to_date('3333333','j'))) " +
                "   from So4UnitaBase a2 " +
                "   where a2.amministrazione=upper(:codice_amm) " +
                "   and a2.codice=upper(:codice_uo) " +
                " ) "
                , [codice_amm: codice_amm, codice_uo: codice_uo])
    }

    String so4_aoo_pkg_get_id_area() {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg
        try {
            sql.call("BEGIN " +
                    " ? := SO4.AOO_PKG.GET_ID_AREA(); " +
                    " END; ",
                    [Sql.NUMERIC]) { result ->
                msg = result
            }
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_aoo_pkg_get_utente_aggiornamento(String codiceAmm) {
        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = ""
        try {
            sql.call("BEGIN " +
                    " ? := SO4.AMMINISTRAZIONE.GET_UTENTE_AGGIORNAMENTO(?); " +
                    " END; ",
                    [Sql.VARCHAR, codiceAmm]) { result ->
                msg = result
            }
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_aoo_pkg_ins(ScaricoIpaFilter record, String d_progr_aoo, Date d_dal) {

        Date dataAgg = null
        Date dataSopp = null

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record?.dataAggiornamento)
        } else {
            dataAgg = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        if (record?.dataSoppressione != null) {
            dataSopp = new Date().parse('yyyy-MM-dd', record?.dataSoppressione)
        }

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = "OK"

        try {

            sql.call("{ call so4.aoo_pkg.ins( " +
                    " p_progr_aoo  => ?, " +
                    " p_dal  => ?, " +
                    " p_codice_amministrazione  => ?, " +
                    " p_codice_aoo  => ?, " +
                    " p_descrizione  => ?, " +
                    " p_indirizzo  => ?, " +
                    " p_cap  => ?, " +
                    " p_provincia  => ?, " +
                    " p_comune  => ?, " +
                    " p_telefono  => ?, " +
                    " p_fax  => ?, " +
                    " p_al  => ?, " +
                    " p_utente_aggiornamento  => ?, " +
                    " p_data_aggiornamento  => ? " +
                    " ) }"
                    , [
                    d_progr_aoo
                    , (d_dal ? new java.sql.Date(d_dal.time) : null)
                    , record?.codiceAmministrazione
                    , record?.codiceAoo
                    , record?.descrizione
                    , record?.indirizzo
                    , record?.cap
                    , (record?.ad4Provincia) ? record?.ad4Provincia.id : null
                    , (record?.ad4Comune) ? record?.ad4Comune.comune : null
                    , record?.telefono
                    , record?.fax
                    , (dataSopp ? new java.sql.Date(dataSopp.time) : null)
                    , record?.ad4UtenteAgg.utente
                    , (dataAgg ? new java.sql.Date(dataAgg.time) : null)
            ])

            msg = "OK"
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    String so4_auor_pkg_ins(ScaricoIpaFilter record, String d_progr_uo, Date d_dal, So4Ottica ottica, String progr_aoo) {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = ""

        Date dataAgg = null

        if (record?.dataAggiornamento != null) {
            dataAgg = new Date().parse('dd/MM/yyyy', record?.dataAggiornamento)
        } else {
            dataAgg = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        if (d_dal == null) {
            d_dal = new Date().parse('dd/MM/yyyy', new Date().format('dd/MM/yyyy'))
        }

        try {

            sql.call("{ call so4.anagrafe_unita_organizzativa.ins( " +
                    " p_progr_unita_organizzativa => ? ," +
                    " p_dal => ?, " +
                    " p_codice_uo => ? , " +
                    " p_descrizione  => ? , " +
                    " p_descrizione_al1 => ? , " +
                    " p_descrizione_al2 => ? , " +
                    " p_des_abb => ? , " +
                    " p_des_abb_al1 => ? , " +
                    " p_des_abb_al2 => ? , " +
                    " p_id_suddivisione => ? , " +
                    " p_ottica => ? , " +
                    " p_revisione_istituzione => ? , " +
                    " p_revisione_cessazione  => ? , " +
                    " p_tipologia_unita  => ? , " +
                    " p_se_giuridico => ? , " +
                    " p_assegnazione_componenti =>  ?, " +
                    " p_amministrazione => ? , " +
                    " p_progr_aoo => ? , " +
                    " p_indirizzo => ? , " +
                    " p_cap => ? , " +
                    " p_provincia => ? , " +
                    " p_comune => ? , " +
                    " p_telefono => ? , " +
                    " p_fax => ? , " +
                    " p_centro => ? , " +
                    " p_centro_responsabilita => ? , " +
                    " p_al => ? , " +
                    " p_utente_ad4 => ? , " +
                    " p_utente_aggiornamento => ? , " +
                    " p_data_aggiornamento => ?, " +
                    " p_note => ? , " +
                    " p_tipo_unita => ?, " +
                    " p_dal_pubb => ?, " +
                    " p_al_pubb => ?, " +
                    " p_al_prec => ?, " +
                    " p_incarico_resp => ?, " +
                    " p_etichetta => ?, " +
                    " p_aggregatore => ?, " +
                    " p_se_fattura_elettronica => ? " +
                    "  ) }"
                    , [

                    d_progr_uo.toLong()
                    , new java.sql.Date(d_dal.time)
                    , record?.codiceUo
                    , record?.descrizione
                    , null
                    , null
                    , null
                    , null
                    , null
                    , null
                    , ottica?.codice
                    , null
                    , null
                    , null
                    , null
                    , null
                    , record?.codiceAmministrazione
                    , progr_aoo
                    , record?.indirizzo
                    , record?.cap
                    , (record?.ad4Provincia) ? record.ad4Provincia.id : null
                    , (record?.ad4Comune) ? record.ad4Comune.comune : null
                    , record?.telefono
                    , record?.fax
                    , null
                    , null
                    , null
                    , null
                    , record?.ad4UtenteAgg.utente
                    , (dataAgg ? new java.sql.Date(dataAgg.time) : null)
                    , null
                    , null
                    , null
                    , null
                    , null
                    , null
                    , null
                    , null
                    , null
            ])

            /* sql.call("{ call so4.anagrafe_unita_organizzativa.ins( " +
                    " p_progr_unita_organizzativa  => ?, " +
                    " p_dal  => ?, " +
                    " p_codice_uo  => ?, " +
                    " p_descrizione  => ?, " +
                    " p_ottica  => ?, " +
                    " p_ammministrazione  => ?, " +
                    " p_progr_aoo  => ?, " +
                    " p_indirizzo  => ?, " +
                    " p_cap  => ?, " +
                    " p_provincia  => ?, " +
                    " p_comune  => ?, " +
                    " p_telefono  => ?, " +
                    " p_fax  => ?, " +
                    " p_utente_aggiornamento  => ?, " +
                    " p_data_aggiornamento  => ? " +
                    " ) }"
                    , [
                    d_progr_uo.toLong()
                    , new java.sql.Date(d_dal.time)
                    , record?.codiceUo
                    , record?.descrizione
                    , ottica?.codice
                    , record?.codiceAmministrazione
                    , progr_aoo
                    , record?.indirizzo
                    , record?.cap
                    , (record?.ad4Provincia) ? record.ad4Provincia.id : null
                    , (record?.ad4Comune) ? record.ad4Comune.comune : null
                    , record?.telefono
                    , record?.fax
                    , record?.ad4UtenteAgg.utente
                    , (dataAgg ? new java.sql.Date(dataAgg.time) : null)
            ]) */

            msg = "OK"
        } catch (SQLException e) {
            log.warn("so4_auor_pkg_ins -> " + e.toString())
            msg = e.toString()
        }

        return msg
    }

    String so4_auor_pkg_upd_column(String d_progr_uo, Date dataDal, String colonna, String valore, String tipo) {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg = ""

        Date data
        if (tipo == "D") {
            data = new Date().parse('dd/MM/yyyy', valore)
        }

        try {

            sql.call("{ call SO4.anagrafe_unita_organizzativa.upd_column( " +
                    " p_progr_unita_organizzativa  => ?, " +
                    " p_dal  => ?, " +
                    " p_column  => ?, " +
                    " p_value  => ? " +
                    " ) }"
                    , [
                    d_progr_uo.toLong()
                    , new java.sql.Date(dataDal.time)
                    , colonna
                    , ((tipo == "D") ? (data ? new java.sql.Date(data.time) : null) : valore)
            ])

            msg = "OK"
        } catch (SQLException e) {
            log.warn("so4_auor_pkg_upd_column_string -> " + e.toString())
            msg = e.toString()
        }

        return msg
    }

    String so4_auor_pkg_get_id_unita() {

        Connection conn = DataSourceUtils.getConnection(dataSource)
        Sql sql = new Sql(conn)
        String msg
        try {
            sql.call("BEGIN " +
                    " ? := SO4.ANAGRAFE_UNITA_ORGANIZZATIVA.GET_ID_UNITA(); " +
                    " END; "
                    ,
                    [Sql.NUMERIC]) { result ->
                msg = result
            }
        } catch (SQLException e) {
            msg = e.toString()
        }

        return msg
    }

    List<So4UnitaBase> isUnitaBaseModificataIpa(d_progr_uo, dal, descrizione, indirizzo, cap, provincia, comune, telefono, fax) {

        String pDescrizione = (descrizione == null) ? " " : descrizione
        String pIndirizzo = (indirizzo == null) ? " " : indirizzo
        String pFax = (fax == null) ? " " : fax
        String pCap = (cap == null) ? "0" : cap
        String pTelefono = (telefono == null) ? " " : telefono
        long pComune = (comune == null) ? 0 : comune
        Integer pProvincia = (provincia == null) ? 0 : provincia
        Date pDal = (dal ? new java.sql.Date(dal.time) : null)

        return So4UnitaBase.executeQuery(" select u " +
                " from So4UnitaBase u " +
                " where u.progr=:d_progr_aoo " +
                " and u.dal =:d_dal " +
                " and (upper(trim(u.descrizione)) != :descrizione " +
                " or nvl(upper(trim(u.indirizzo)), ' ') != :indirizzo " +
                " or nvl(upper(trim(u.cap)), 0) != :cap " +
                " or nvl(u.provincia.id, 0) != :provincia " +
                " or nvl(u.comune.id, 0) != :comune " +
                " or nvl(upper(trim(u.telefono)), ' ') != :telefono " +
                " or nvl(upper(trim(u.fax)), ' ') != :fax " +
                " ) "
                , [d_progr_aoo: d_progr_uo?.toLong(), descrizione: pDescrizione, indirizzo: pIndirizzo
                   , cap      : pCap, telefono: pTelefono, fax: pFax
                   , provincia: pProvincia, comune: pComune, d_dal: pDal])
    }
}
