package it.finmatica.protocollo.integrazioni.gdm


import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.transform.CompileStatic
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.SQLException
import java.text.DateFormat
import java.text.SimpleDateFormat
/**
 * Mettiamo qui invocazioni a pkg e query secche su gdm / pkg
 */
@Transactional
@CompileStatic
@Service
class ProtocolloPkgService {

    @Autowired SpringSecurityService springSecurityService
    @Autowired IGestoreFile gestoreFile

    @Autowired DataSource dataSource
    @Qualifier("dataSource_gdm") @Autowired DataSource dataSource_gdm

    boolean utenteHaPrivilegioSuDocumentoDaNonProtocollare(long idDocumento, String codicePrivilegio, String utente = springSecurityService.principal.id) {
        try {
            Sql sql = new Sql(dataSource_gdm)
            GroovyRowResult result = sql.firstRow('select ag_competenze_documento.verifica_privilegio_documento(?, ?, ?) HA_PRIVILEGIO from dual', idDocumento.toString(), codicePrivilegio, utente)
            return (result.HA_PRIVILEGIO == 1)
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    String gdcUtilityPkgGetUrlOggetto(long idDocumentoGdm) {
        try {
            Sql sql = new Sql(dataSource_gdm)

            // se il documento gdm è una cartella, devo invocare una query diversa con un nome diverso
            Long idCartella = (Long) sql.firstRow('select id_cartella from cartelle where id_documento_profilo = ?', idDocumentoGdm.toString())?.ID_CARTELLA
            String tipoDoc = 'D'
            Long idDoc = idDocumentoGdm
            if (idCartella != null) {
                tipoDoc = 'C'
                idDoc = idCartella
            }

            return sql.firstRow("select gdc_utility_pkg.f_get_url_oggetto ('', '', ?, ?, '', '', '', 'R', '', '', '5', 'N') URL from dual", idDoc.toString(), tipoDoc).URL
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    List<String> agpMenuGetBarraMProtocollo(long idDocumentoGdm, String categoria, boolean competenzaInModifica) {
        try {
            Sql sql = new Sql(dataSource)
            List<GroovyRowResult> rows
            if(categoria == CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice) {
                rows = sql.rows('select AGP_MENU.GET_BARRA_DA_FASCICOLARE (?, ?, ?) VOCI_MENU from dual', [idDocumentoGdm, springSecurityService.principal.id, competenzaInModifica ? 'W' : 'R'].toArray())
            } else {
                rows = sql.rows('select AGP_MENU.GET_BARRA_MPROTOCOLLO (?, ?, ?) VOCI_MENU from dual', [idDocumentoGdm, springSecurityService.principal.id, competenzaInModifica ? 'W' : 'R'].toArray())
            }
            String menus = rows[0].VOCI_MENU
            return menus.split('#').toUnique() as ArrayList<String>
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    void spostaFile(IDocumentoEsterno documentoOrigine, IFileDocumento fileOrigine, IDocumentoEsterno documentoDestinazione, IFileDocumento fileDestinazione) {
        // eseguo una update secca su gdm per spostare il file da un documento all'altro:
        if (isFileSuFileSystem(fileOrigine.idFileEsterno)) {
            gestoreFile.addFile(documentoDestinazione, fileDestinazione, gestoreFile.getFile(documentoOrigine, fileOrigine))
        } else {
            try {
                Sql sql = new Sql(dataSource_gdm)
                sql.execute('update oggetti_file set id_documento = ? where ID_OGGETTO_FILE = ?', [documentoDestinazione.idDocumentoEsterno, fileOrigine.idFileEsterno].toArray())
                sql.execute('update impronte_file set ID_DOCUMENTO = ? where ID_DOCUMENTO = ? and FILENAME = ?', [documentoDestinazione.idDocumentoEsterno, documentoOrigine.idDocumentoEsterno, fileOrigine.nome].toArray())
            } catch (SQLException e) {
                throw new ProtocolloRuntimeException(e)
            }
        }
    }

    private boolean isFileSuFileSystem(long idFileOrigine) {
        try {
            def row =  new Sql(dataSource_gdm).firstRow('select count(1) OGGETTO_SU_FILE from oggetti_file where "FILE" is not null and id_oggetto_file = ?', [idFileOrigine].toArray())
            return (((BigDecimal)row.OGGETTO_SU_FILE).intValue() == 1)
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    String gdcUtilityPkgGetUrlCartella(long idDocumentoGdm) {
        try {
            Sql sql = new Sql(dataSource_gdm)
            List<GroovyRowResult> rows = sql.rows("select gdc_utility_pkg.f_get_url_oggetto ('', '', id_cartella, 'C', '', '', '', 'R', '', '', '5', 'N') URL from cartelle where id_documento_profilo = ?", [idDocumentoGdm.toString()].toArray())
            return rows[0].URL
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    /**
     *
     * @param idDocumento
     * @param dataAnnullamento
     * @param utenteAnnullamento
     * @param motivoAnnullamento
     */
    void annullaAlbo(long idDocumento, Date dataAnnullamento, String utenteAnnullamento, String motivoAnnullamento) {
        Boolean lettura = false
        DateFormat format = new SimpleDateFormat("dd/MM/yyyy", Locale.ITALIAN)
        String data = ""
        if(dataAnnullamento){
            data = format.format(dataAnnullamento)
        }
        try {
            Sql sql = new Sql(dataSource_gdm)
            sql.call("""BEGIN 
					  ? := AG_MES_UTILITY.f_annulla_albo(?, ?, ?, ?);
					END; """,
                    [Sql.VARCHAR, idDocumento.toString(), data, utenteAnnullamento, motivoAnnullamento]){ row ->
                lettura = (row == 1)
            }
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    /**
     * fornisce l'id documento esterno dato l'id cartella; il risultato può essere un id o di classificazione o di fascicolo
     * @param idCartProveninenz l'id cartella
     * @return l'id del documento esterno cercato
     */
    Long getIdDocumentoProfilo (Long idCartProveninenz) {
        // select id_documento_profilo from gdm_cartelle where id_cartella = :idCartProveninenz
        Sql sql = new Sql(dataSource_gdm)
        GroovyRowResult res =sql.firstRow('select id_documento_profilo from cartelle where id_cartella = ?',[idCartProveninenz].toArray())
        return res.id_documento_profilo as Long
    }


    /**
     * fornisce l'id cartella dato l'id documento esterno;
     * @param l'id del documento esterno
     * @return idCartProveninenz l'id cartella cercata
     */
    Long getIdCartella (Long idDocumentoEsterno) {
        Sql sql = new Sql(dataSource_gdm)
        GroovyRowResult res =sql.firstRow('select id_cartella from cartelle where id_documento_profilo = ?',[idDocumentoEsterno].toArray())
        return res.id_cartella as Long
    }


}
