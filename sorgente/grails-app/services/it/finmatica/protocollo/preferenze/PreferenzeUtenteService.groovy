package it.finmatica.protocollo.preferenze

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional
import org.springframework.stereotype.Service

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.cxf.common.util.StringUtils

@Service
@Transactional
class PreferenzeUtenteService {

    public static final String UNITA_PROTOCOLLANTE = "UnitaProtocollante"
    public static final String UNITA_ITER = "UnitaIter"
    public static final String APRI_SOGGETTO_UNIVOCO = "ApriSoggettoUnivoco"
    public static final String REPORT_TIMBRO = "ReportTimbro"
    public static final String REPORT_TIMBRO_ALLEGATO_BC = "timbro_allegato_bc"
    public static final String ABILITA_STAMPA_BC_DIRETTA = "AbilitaStampaBCDiretta"
    public static final String MODALITA = "Modalita"
    public static final String ABILITA_STAMPA_RICEVUTA_DIRETTA = "AbilitaStampaRicDiretta"
    public static final String DUPLICA_PROTOCOLLO_COPIA_FASCICOLO = "DuplicaFasc"
    public static final String DUPLICA_PROTOCOLLO_COPIA_RAPPORTI = "DuplicaRapportiCopia"
    public static final String DUPLICA_PROTOCOLLO_COPIA_SMISTAMENTI = "DuplicaSmistCopia"
    public static final String DUPLICA_PROTOCOLLO_COPIA_RAPPORTI_RISPOSTA = "DuplicaRapportiRisposta"
    public static final String DUPLICA_PROTOCOLLO_COPIA_SMISTAMENTI_RISPOSTA = "DuplicaSmistRisposta"
    public static final String SCAN_ABILITA_IMPOSTAZIONI = "ScanAbilitaImpostazioni"
    public static final String SCAN_RICHIEDI_FILENAME = "ScanRichiediFilename"

    @Autowired SpringSecurityService springSecurityService
    @Autowired PreferenzeUtenteRepository preferenzeUtenteRepository

    String getPreferenza(Ad4Utente utente, String codicePreferenza, String valoreDefault = null) {
        PreferenzeUtente preferenza = PreferenzeUtente.findByUtenteAndPreferenza(utente, codicePreferenza)

        if (preferenza == null) {
            return valoreDefault
        }

        // per qualche strana ragione è possibile avere una riga vuota sulle preferenze utente...
        String valore = preferenza.valore
        if (valore == null) {
            return valoreDefault
        }

        return valore
    }

    String getPreferenza(String codicePreferenza, String valoreDefault = null) {
        return getPreferenza(springSecurityService.currentUser, codicePreferenza, valoreDefault)
    }

    boolean getPreferenzaYN(String codicePreferenza, String valoreDefault = "N") {
        return getPreferenza(codicePreferenza, valoreDefault).toUpperCase() == "Y"
    }

    boolean isApriSoggettoUnivoco() {
        return getPreferenzaYN(APRI_SOGGETTO_UNIVOCO)
    }

    @Override
    boolean equals(Object obj) {
        return super.equals(obj)
    }

    boolean isScansioneDiretta() {
        return !isScanAbilitaImpostazioni()
    }

    boolean isScanAbilitaImpostazioni() {
        return getPreferenzaYN(SCAN_ABILITA_IMPOSTAZIONI, "Y")
    }

    boolean isScanRichiediFilename() {
        return getPreferenzaYN(SCAN_RICHIEDI_FILENAME, "Y")
    }

    So4UnitaPubb getUnitaProtocollante() {
        String codice = getPreferenza(UNITA_PROTOCOLLANTE)
        if (codice == null) {
            return null
        }

        if (!StringUtils.isEmpty(codice)) {
            So4UnitaPubb unita = So4UnitaPubb.allaData().findByCodice(codice)
            if (unita != null) {
                return unita
            }
        }
    }


    So4UnitaPubb getUnitaIter() {
        String codice = getPreferenza(UNITA_ITER)
        if (codice == null) {
            return null
        }

        if (!StringUtils.isEmpty(codice)) {
            So4UnitaPubb unita = So4UnitaPubb.allaData().findByCodice(codice)
            if (unita != null) {
                return unita
            }
        }
    }

    String getReportTimbro() {
        return getPreferenza(REPORT_TIMBRO, ImpostazioniProtocollo.REPORT_TIMBRO.valore)
    }

    String getReportTimbroAllegatoBc() {
        return getPreferenza(REPORT_TIMBRO_ALLEGATO_BC, ImpostazioniProtocollo.REPORT_TIMBRO_ALLEGATO_BC.valore)
    }

    boolean isAbilitaStampaBcDiretta() {
        return getPreferenzaYN(ABILITA_STAMPA_BC_DIRETTA)
    }

    boolean isAbilitaStampaRicevutaDiretta() {
        return getPreferenzaYN(ABILITA_STAMPA_RICEVUTA_DIRETTA)
    }

    String getModalita() {
        return getPreferenza(MODALITA)
    }

    boolean isDuplicaProtocolloCopiaFascicolo() {
        return getPreferenzaYN(DUPLICA_PROTOCOLLO_COPIA_FASCICOLO)
    }

    boolean isDuplicaProtocolloCopiaRapporti() {
        return getPreferenzaYN(DUPLICA_PROTOCOLLO_COPIA_RAPPORTI)
    }

    boolean isDuplicaProtocolloCopiaSmistamenti() {
        return getPreferenzaYN(DUPLICA_PROTOCOLLO_COPIA_SMISTAMENTI)
    }

    List<PreferenzeUtente> findAll(Ad4Utente utente) {
        preferenzeUtenteRepository.findByUtente(utente)
    }

    void saveAll(List<PreferenzeUtente> preferenze) {
        preferenzeUtenteRepository.save(preferenze)
    }
}
