package it.finmatica.protocollo.competenze

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.DocumentoSoggettoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

/**
 * Gestione dei privilegi.
 *
 * In questo service vengono controllati i privilegi e le logiche particolari che alcuni di questi hanno.
 * L'unica cosa che viene "lasciata fuori" è il fatto di verificare che l'utente abbia le competenze di modifica. Questo viene lasciato "fuori" da queste funzioni perché è una informaizone già
 * disponibile dal chiamante (ad es nello .zul o nel ViewModel) che quindi conviene verificare prima di invocare questi metodi (per ragioni di performance).
 *
 * Questo service viene invocato anche direttamente dagli .zul grazie al PropertyResolver (ad esempio protocollo.zul)
 */
@Slf4j
@Transactional(readOnly = true)
@CompileStatic
@Service
class PrivilegioUtenteService {

    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloPkgService protocolloPkgService
    @Autowired
    PrivilegioUtenteRepository privilegioUtenteRepository
    @Autowired
    DocumentoSoggettoRepository documentoSoggettoRepository
    @Autowired
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @Autowired
    ProtocolloService protocolloService

    /**
     * Verifica un privilegio "generico" e senza la gestione del "blocco sul documento" per l'utente
     *
     * @param privilegio il privilegio da verificare
     * @param utente l'utente (default con l'utente loggato)
     * @return true se l'utente ha il privilegio su ag_utenti_priv_tmp, false altrimenti
     */
    boolean utenteHaPrivilegio(String privilegio, Ad4Utente utente = springSecurityService.currentUser) {
        return isUtenteHaPrivilegio(utente, privilegio, null)
    }

    /**
     * Verifica un privilegio "generico" e senza la gestione del "blocco sul documento" per l'utente e per l'unità
     *
     * @param privilegio il privilegio da verificare
     * @param codiceUnita il codice dell'unità per cui verificare il privilegio
     * @param utente l'utente (default con l'utente loggato)
     * @return true se l'utente ha il privilegio su ag_utenti_priv_tmp, false altrimenti
     */
    boolean utenteHaPrivilegioPerUnita(String privilegio, String codiceUnita, Ad4Utente utente = springSecurityService.currentUser) {
        return isUtenteHaPrivilegio(utente, privilegio, codiceUnita)
    }

    /**
     * Verifica un privilegio "generico" e senza la gestione del "blocco sul documento" per l'utente e per l'unità a dataAl
     *
     * @param privilegio il privilegio da verificare
     * @param codiceUnita il codice dell'unità per cui verificare il privilegio
     * @param utente l'utente (default con l'utente loggato)
     * @param dataAl data a cui verificare il privilegio
     * @return true se l'utente ha il privilegio su ag_utenti_priv_tmp, false altrimenti
     */
    boolean utenteHaPrivilegioPerUnita(String privilegio, String codiceUnita, Ad4Utente utente = springSecurityService.currentUser, Date dataAl) {
        return isUtenteHaPrivilegio(utente, privilegio, codiceUnita, dataAl)
    }

    boolean utenteHaprivilegioPerUfficioSmistamento(Smistamento smistamento, String privilegio) {
        if (utenteHaPrivilegioPerUnita(privilegio, smistamento.getUnitaSmistamento()?.codice, springSecurityService.currentUser)) {
            return true
        }

        return false
    }

    /**
     * Verifica un privilegio "generico" e senza la gestione del "blocco sul documento" per l'utente
     *
     * @param privilegio il privilegio da verificare
     * @param utente l'utente (default con l'utente loggato)
     * @return true se l'utente ha il privilegio su ag_utenti_priv_tmp, false altrimenti
     */
    boolean utenteHaPrivilegioGenerico(String privilegio, Ad4Utente utente = springSecurityService.currentUser) {
        return isUtenteHaPrivilegio(utente, privilegio, null)
    }

    boolean isModificaClassifica(ProtocolloDTO protocolloDTO) {
        if (protocolloDTO.numero > 0) {
            return utenteHaPrivilegio(PrivilegioUtente.MODIFICA_CLASSIFICAZIONE) || isModificaFascicoloProtocollo(protocolloDTO)
        }

        return true
    }

    boolean isModificaFascicoloProtocollo(ProtocolloDTO protocolloDTO) {
        if (protocolloDTO.numero > 0) {
            return utenteHaPrivilegio(PrivilegioUtente.MODIFICA_FASCICOLO)
        }

        return true
    }

    boolean isInserimentoInClassificheAperte() {
        return utenteHaPrivilegio(PrivilegioUtente.INSERIMENTO_IN_CLASSIFICAZIONI_APERTE) || utenteHaPrivilegio(PrivilegioUtente.INSERIMENTO_IN_CLASSIFICAZIONI_APERTE_TUTTE)
    }

    boolean isInserimentoInClassificheSecondarie() {
        return isInserimentoInClassificheAperte() || isInserimentoInFascicoliAperti() || isInserimentoInFascicoliChiusi()
    }

    boolean isInserimentoInFascicoliChiusi() {
        return utenteHaPrivilegio(PrivilegioUtente.INSERIMENTO_IN_FASCICOLI_CHIUSI)
    }

    boolean isInserimentoInFascicoliAperti(ProtocolloDTO protocollo = null) {
        if (protocollo == null) {
            return utenteHaPrivilegio(PrivilegioUtente.INSERIMENTO_IN_FASCICOLI_APERTI)
        } else if (protocollo.isProtocollato()) {
            return utenteHaPrivilegio(PrivilegioUtente.INSERIMENTO_IN_FASCICOLI_APERTI)
        } else {
            return true
        }
    }

    boolean isCreaFascicolo() {
        return utenteHaPrivilegio(PrivilegioUtente.CREF)
    }

    boolean isCreaClassificazione() {
        return utenteHaPrivilegio(PrivilegioUtente.CRECLA)
    }

    boolean isCreaProtocollo() {
        return utenteHaPrivilegio(PrivilegioUtente.REDATTORE_PROTOCOLLO)
    }

    boolean isCreaLettera() {
        return utenteHaPrivilegio(PrivilegioUtente.REDATTORE_LETTERA)
    }

    boolean isCreaDocumentoDaFascicolare() {
        return utenteHaPrivilegio(PrivilegioUtente.DAFASC)
    }

    boolean isEliminaDaClassificheSecondarie() {
        return isInserimentoInClassificheSecondarie() ||
                utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_CLASSIFICAZIONI_APERTE) ||
                utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_CLASSIFICAZIONI_APERTE_TUTTE) ||
                utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_FASCICOLI_APERTI) ||
                utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_FASCICOLI_CHIUSI)
    }

    boolean isModificaDatiArchivio(ProtocolloDTO protocollo) {
        if (protocollo.protocollato) {
            return utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_FASCICOLI_CHIUSI)
        }

        return true
    }

    boolean isInserimentoRapporti(ProtocolloDTO protocollo) {
        if (!protocollo.protocollato) {
            return true
        } else {
            Protocollo p = protocollo.domainObject
            if (protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA && protocolloService.isSpedito(p)) {
                return utenteHaPrivilegioBlocco(PrivilegioUtente.INSERIMENTO_RAPPORTI, protocollo)
            } else {
                return isModificaRapporti(protocollo)
            }
        }
    }

    boolean isModificaRapporti(ProtocolloDTO protocollo) {
        if (!protocollo.protocollato) {
            return true
        }
        return utenteHaPrivilegioBlocco(PrivilegioUtente.MODIFICA_RAPPORTI, protocollo)
    }

    boolean isEliminaRapporti(ProtocolloDTO protocollo) {
        if (!protocollo.protocollato) {
            return true
        }
        return utenteHaPrivilegioBlocco(PrivilegioUtente.ELIMINAZIONE_RAPPORTI, protocollo)
    }

    boolean isModificaOggetto(ProtocolloDTO protocollo) {
        if (!protocollo.isProtocollato()) {
            return true
        }

        return utenteHaPrivilegioBlocco(PrivilegioUtente.MODIFICA_OGGETTO, protocollo)
    }

    boolean isModificaFilePrincipale(ProtocolloDTO protocollo) {
        if (!protocollo.isProtocollato()) {
            return true
        }

        if (protocolloService.isSpedito(protocollo.domainObject) && protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
            return false
        }

        return utenteHaPrivilegioBlocco(PrivilegioUtente.MODIFICA_FILE_ASSOCIATO, protocollo)
    }

    boolean isEliminaFilePrincipale(ProtocolloDTO protocollo) {

        if (protocollo.categoriaProtocollo == null) {
            return false
        }

        if (protocollo.categoriaProtocollo.modelloTestoObbligatorio && (protocollo.isProtocollato() || protocollo.testoPrincipale?.firmato)) {
            return false
        }

        if (protocollo.categoriaProtocollo.isPec()) {
            return false
        }

        if (protocollo.statoFirma?.isFirmaInterrotta()) {
            return false
        }

        boolean eliminabile = isModificaFilePrincipale(protocollo)

        // non deve essere eliminabile se il file è obbligatorio
        if (eliminabile &&
                !protocollo.categoriaProtocollo.modelloTestoObbligatorio &&
                protocollo.isProtocollato()) {

            if (ImpostazioniProtocollo.FILE_OB.valore.equals("Y")) {
                eliminabile = false
            } else if (ImpostazioniProtocollo.FILE_OB.valore.equals("PAR") && Protocollo.MOVIMENTO_PARTENZA.equals(protocollo.movimento)) {
                eliminabile = false
            } else if (ImpostazioniProtocollo.FILE_OB.valore.equals("PAR_INT") &&
                    (Protocollo.MOVIMENTO_PARTENZA.equals(protocollo.movimento) || Protocollo.MOVIMENTO_INTERNO.equals(protocollo.movimento))) {
                eliminabile = false
            }
        }
        return eliminabile
    }

    boolean isPuoFirmare(Protocollo protocollo) {
        return utenteHaPrivilegio(PrivilegioUtente.FIRMA) && utenteHaPrivilegioBlocco(PrivilegioUtente.MODIFICA_FILE_ASSOCIATO, (ProtocolloDTO) protocollo.toDTO())
    }

    boolean isInserimentoAllegati(ProtocolloDTO protocollo) {
        return isPrivilegioAllegati(protocollo, PrivilegioUtente.INSERIMENTO_ALLEGATI)
    }

    boolean isModificaAllegati(ProtocolloDTO protocollo) {
        return isPrivilegioAllegati(protocollo, PrivilegioUtente.MODIFICA_ALLEGATI)
    }

    boolean isEliminaAllegati(ProtocolloDTO protocollo) {
        return isPrivilegioAllegati(protocollo, PrivilegioUtente.ELIMINAZIONE_ALLEGATI)
    }

    List<PrivilegioUtente> getPrivilegi(Ad4Utente utente, String privilegio) {
        return getPrivilegi(utente, privilegio, null)
    }

    List<PrivilegioUtente> getPrivilegi(Ad4Utente utente, String privilegio, String codiceUnita) {
        return privilegioUtenteRepository.getPrivilegi(utente, privilegio, codiceUnita)
    }

    List<PrivilegioUtente> getPrivilegi(Ad4Utente utente, String privilegio, String codiceUnita, Date dataAl) {
        return privilegioUtenteRepository.getPrivilegi(utente, privilegio, codiceUnita, dataAl)
    }

    List<PrivilegioUtente> getAllPrivilegi(Ad4Utente utente, String codiceUnita = null) {
        return privilegioUtenteRepository.getAllPrivilegi(utente, codiceUnita)
    }

    List<Ad4Utente> getAllUtenti(String privilegio, String codiceUnita = null) {
        return privilegioUtenteRepository.getUtentiPerPrivilegi(privilegio, codiceUnita)
    }

    List<So4UnitaPubb> getUnitaPerPrivilegi(Ad4Utente utente, String privilegio, boolean soloAperte) {
        return privilegioUtenteRepository.getUnitaPerPrivilegi(utente, privilegio, soloAperte).unique()
    }

    /**
     * Le possibili unità protocollanti di un utente devono essere visualizzate tutte le unità dell'utente valide ad oggi con privilegio CPROT valido ad oggi
     * e per cui esiste un record in ag_priv_utente_tmp aperto ad oggi su un'unità valida ad oggi a cui l'utente appartiene direttamente
     * che abbia la stessa unità radice d'area dell'unità presa in considerazione
     */
    List<So4UnitaPubb> listUnitaPerPrivilegiEstesi(Ad4Utente utente, String privilegio, String filtro) {

        filtro = "%" + filtro + "%"

        List<So4UnitaPubb> unitaConPrivilegiDiretti = privilegioUtenteRepository.listUnitaPerPrivilegiDiretti(utente, privilegio, filtro)

        List<So4UnitaPubb> listaUnitaConPrivilegioEsteso = privilegioUtenteRepository.listUnitaPrivilegiEstesi(utente, privilegio, filtro)
        List<So4UnitaPubb> listaUnitaConPrivilegiDiretti = privilegioUtenteRepository.listUnitaConPrivilegiDiretti(utente)

        List<So4UnitaPubb> listaUnitaConPrivilegiEstesiConStessaUnitaVertice = new ArrayList<So4UnitaPubb>()
        for (So4UnitaPubb u : listaUnitaConPrivilegioEsteso) {
            So4UnitaPubb unitaUtenteVertice = strutturaOrganizzativaService.getUnitaVertice(u)
            for (So4UnitaPubb unita : listaUnitaConPrivilegiDiretti) {
                So4UnitaPubb uVertice = strutturaOrganizzativaService.getUnitaVertice(unita)
                if (unitaUtenteVertice.id == uVertice.id) {
                    listaUnitaConPrivilegiEstesiConStessaUnitaVertice.add(u)
                    break
                }
            }
        }

        listaUnitaConPrivilegiEstesiConStessaUnitaVertice.addAll(unitaConPrivilegiDiretti)
        List<So4UnitaPubb> listaUnitaConPrivilegiEstesi = listaUnitaConPrivilegiEstesiConStessaUnitaVertice.unique().sort {
            it.descrizione
        }
        return listaUnitaConPrivilegiEstesi
    }

    public String getPrimaUnitaTrasmissioneDefault(Ad4Utente utente) {
        String unitaTrasmissione = null;

        List<So4UnitaPubb> listaUnitaCreaSempre = getUnitaPerPrivilegi(utente, PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, true)

        if (listaUnitaCreaSempre.size() > 0) {
            //qui devo controllare se questo item esiste per l'ottica??
            unitaTrasmissione = listaUnitaCreaSempre.get(0).getCodice()
        } else {
            List<So4UnitaPubb> listaUnitaCrea = getUnitaPerPrivilegi(utente, PrivilegioUtente.SMISTAMENTO_CREA, true)
            if (listaUnitaCrea.size() > 0) {
                //qui devo controllare se questo item esiste per l'ottica??
                unitaTrasmissione = listaUnitaCrea.get(0).getCodice()
            }
        }
        return unitaTrasmissione
    }

    private boolean utenteHaPrivilegioBlocco(String privilegio, ProtocolloDTO protocollo, Ad4Utente utente = springSecurityService.currentUser) {
        if (protocollo.isBloccato()) {
            privilegio = PrivilegioUtente.getPrivilegioBlocco(privilegio)
        }
        return isUtenteHaPrivilegio(utente, privilegio, null)
    }

    @CompileDynamic
    private boolean isUtenteHaPrivilegio(Ad4Utente utente, String privilegio, String codiceUnita) {
        return getPrivilegi(utente, privilegio, codiceUnita).size() > 0
    }

    @CompileDynamic
    private boolean isUtenteHaPrivilegio(Ad4Utente utente, String privilegio, String codiceUnita, Date dataAl) {
        return getPrivilegi(utente, privilegio, codiceUnita, dataAl).size() > 0
    }

    private boolean utenteHaPrivilegioSulDocumento(Protocollo protocollo, String codicePrivilegio, String utente = springSecurityService.principal.id) {
        // se il documento non è ancora salvato su gdm, ritorno false
        if (protocollo.idDocumentoEsterno == null) {
            return false
        }

        if (protocollo.isBloccato()) {
            codicePrivilegio = PrivilegioUtente.getPrivilegioBlocco(codicePrivilegio)
        }

        if (protocollo.categoriaProtocollo.isDaNonProtocollare()) {
            return protocolloPkgService.utenteHaPrivilegioSuDocumentoDaNonProtocollare(protocollo.idDocumentoEsterno, codicePrivilegio, utente)
        }
        return true
    }

    private boolean isPrivilegioAllegati(ProtocolloDTO protocollo, String privilegio) {

        if (!protocollo.isProtocollato()) {
            return true
        }

        // se il protocollo è spedito, posso inserire nuovi allegati solo se l'impostazione lo consente e ho il privilegio
        if (protocolloService.isSpedito(protocollo.domainObject)) {
            if (ImpostazioniProtocollo.ALLEGATI_MOD_POST_INVIO.abilitato) {
                return utenteHaPrivilegioBlocco(privilegio, protocollo)
            } else {
                return false
            }
        } else {
            return utenteHaPrivilegioBlocco(privilegio, protocollo)
        }
    }

    boolean isCompetenzaModificaFascicolo(Fascicolo fascicolo) {
        boolean abilitazione

        // se fascicolo chiuso, non riservato, bisogna avere privilegio MFC
        // se fascicolo chiuso, riservato, bisogna avere privilegio MFCR
        // se fascicolo chiuso, non riservato, appartenente all uo di competenza, bisogna avere il privilegio MFCU all'interno della uo competenza
        // se fascicolo chiuso, riservato, appartenente all uo di competenza, bisogna avere il privilegio MFCRU all'inteerno della uo competenza
        // se fascicolo chiuso, non riservato, appartenente all uo di creazione, bisogna avere il privilegio MFCUCRE all'interno della uo competenza
        // se fascicolo chiuso, riservato, appartenente all uo di creazione, bisogna avere il privilegio MFCRUCRE all'inteerno della uo competenza
        // se fascicolo aperto, non riservato, bisogna avere il privilegio MF
        // se fascicolo aperto, riservato, bisgona avere il privilegio MFR
        // se fascicolo aperto, non riservato, appartenente all uo di competenza, bisogna avere il privilegio MFU all'interno della uo competenza
        // se fascicolo aperto, riservato, appartenente all uo di competenza, bisogna avere il privilegio MFRU all'inteerno della uo competenza
        // se fascicolo aperto, non riservato, appartenente all uo di creazione, bisogna avere il privilegio MFUCRE all'interno della uo competenza
        // se fascicolo aperto, riservato, appartenente all uo di creazione, bisogna avere il privilegio MFRUCRE all'inteerno della uo competenza

        if (fascicolo.dataChiusura) {
            if (fascicolo.riservato) {
                // fascicolo chiuso riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFC)) {
                    return true
                }
                /*if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFRC)) {
                    return true
                } else {
                    if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFRCU)) {
                            return true
                        }
                    }
                    if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFRCUCRE)) {
                            return true
                        }
                    }
                }*/
            } else {
                // fascicolo chiuso non riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFC)) {
                    return true
                }
                /*else {
                    if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFCU)) {
                            return true
                        }
                    }
                    if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFCUCRE)) {
                            return true
                        }
                    }
                }*/
            }
        } else {
            if (fascicolo.riservato) {
                // fascicolo aperto riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFR)) {
                    return true
                } else {
                    if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFRU)) {
                            return true
                        }
                    }
                    if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFRUCRE)) {
                            return true
                        }
                    }
                }
            } else {
                // fascicolo aperto non riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.MF)) {
                    return true
                } else {
                    if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFU)) {
                            return true
                        }
                    }
                    if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.MFUCRE)) {
                            return true
                        }
                    }
                }
            }
        }

        return abilitazione
    }

    boolean isCompetenzaVisualizzaFascicolo(Fascicolo fascicolo) {
        boolean abilitazione

        // se fascicolo chiuso, non riservato, bisogna avere privilegio VFC
        // se fascicolo chiuso, riservato, bisogna avere privilegio VFCR
        // se fascicolo chiuso, non riservato, appartenente all uo di competenza, bisogna avere il privilegio VFCU all'interno della uo competenza
        // se fascicolo chiuso, riservato, appartenente all uo di competenza, bisogna avere il privilegio VFCRU all'inteerno della uo competenza
        // se fascicolo chiuso, non riservato, appartenente all uo di creazione, bisogna avere il privilegio VFCUCRE all'interno della uo competenza
        // se fascicolo chiuso, riservato, appartenente all uo di creazione, bisogna avere il privilegio VFCRUCRE all'inteerno della uo competenza
        // se fascicolo aperto, non riservato, bisogna avere il privilegio VF
        // se fascicolo aperto, riservato, bisgona avere il privilegio VFR
        // se fascicolo aperto, non riservato, appartenente all uo di competenza, bisogna avere il privilegio VFU all'interno della uo competenza
        // se fascicolo aperto, riservato, appartenente all uo di competenza, bisogna avere il privilegio VFRU all'inteerno della uo competenza
        // se fascicolo aperto, non riservato, appartenente all uo di creazione, bisogna avere il privilegio VFUCRE all'interno della uo competenza
        // se fascicolo aperto, riservato, appartenente all uo di creazione, bisogna avere il privilegio VFRUCRE all'inteerno della uo competenza

        if (fascicolo.dataChiusura) {
            if (fascicolo.riservato) {
                // fascicolo chiuso riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFRC)) {
                    return true
                } else {
                    if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFRCU)) {
                            return true
                        }
                    }
                    if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFRCUCRE)) {
                            return true
                        }
                    }
                }
            } else {
                // fascicolo chiuso non riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFC)) {
                    return true
                } else {
                    if (ImpostazioniProtocollo.VCLA_ABILITA_VF.abilitato && utenteHaPrivilegioGenerico(PrivilegioUtente.VCLATOT)) {
                        return true
                    } else {
                        if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                            if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFCU)) {
                                return true
                            }
                        }
                        if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                            if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFCUCRE)) {
                                return true
                            }
                        }
                    }
                }
            }
        } else {
            if (fascicolo.riservato) {
                // fascicolo aperto riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFR)) {
                    return true
                } else {
                    if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFRU)) {
                            return true
                        }
                    }
                    if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                        if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFRUCRE)) {
                            return true
                        }
                    }
                }
            } else {
                // fascicolo aperto non riservato
                if (utenteHaPrivilegioGenerico(PrivilegioUtente.VF)) {
                    return true
                } else {
                    if (ImpostazioniProtocollo.VCLA_ABILITA_VF.abilitato && utenteHaPrivilegioGenerico(PrivilegioUtente.VCLATOT)) {
                        return true
                    } else {
                        if (appartenenzaUoCompetenzaFascicolo(fascicolo)) {
                            if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFU)) {
                                return true
                            }
                        }
                        if (appertenenzaUoCreazioneFascicolo(fascicolo)) {
                            if (utenteHaPrivilegioGenerico(PrivilegioUtente.VFUCRE)) {
                                return true
                            }
                        }
                    }
                }
            }
        }

        return abilitazione
    }

    boolean isCompetenzaModificaClassificazione(Classificazione classificazione) {
        if (!classificazione.al) {
            if (utenteHaPrivilegioGenerico(PrivilegioUtente.MCLA) || utenteHaPrivilegioGenerico(PrivilegioUtente.MCLATOT)) {
                return true
            } else {
                return false
            }
        } else {
            if (utenteHaPrivilegioGenerico(PrivilegioUtente.MCC) || utenteHaPrivilegioGenerico(PrivilegioUtente.MCCTOT)) {
                return true
            } else {
                return false
            }
        }
    }

    boolean isCompetenzaVisualizzaClassificazione(Classificazione classificazione) {
        if (!classificazione.al) {
            if (utenteHaPrivilegioGenerico(PrivilegioUtente.VCLA) || utenteHaPrivilegioGenerico(PrivilegioUtente.VCLATOT)) {
                return true
            } else {
                return false
            }
        } else {
            if (utenteHaPrivilegioGenerico(PrivilegioUtente.VCC) || utenteHaPrivilegioGenerico(PrivilegioUtente.VCCTOT)) {
                return true
            } else {
                return false
            }
        }
    }

    boolean appertenenzaUoCreazioneFascicolo(Fascicolo fascicolo) {
        List<So4UnitaPubb> listUnita = []
        boolean appartenenza

        listUnita = strutturaOrganizzativaService.getUnitaUtente(springSecurityService.currentUser.utente, Impostazioni.OTTICA_SO4.valore)

        So4UnitaPubb UoCompetenzaCreazione = documentoSoggettoRepository.getUnita(fascicolo.id, TipoSoggetto.UO_CREAZIONE)
        listUnita.each {
            if (it.codice == UoCompetenzaCreazione?.codice) {
                appartenenza = true
            }
        }

        return appartenenza
    }

    boolean appartenenzaUoCompetenzaFascicolo(Fascicolo fascicolo) {
        List<So4UnitaPubb> listUnita = []
        boolean appartenenza

        listUnita = strutturaOrganizzativaService.getUnitaUtente(springSecurityService.currentUser.utente, Impostazioni.OTTICA_SO4.valore)

        So4UnitaPubb UoCompetenza = documentoSoggettoRepository.getUnita(fascicolo.id, TipoSoggetto.UO_COMPETENZA)
        listUnita.each {
            if (it.codice == UoCompetenza?.codice) {
                appartenenza = true
            }
        }

        return appartenenza
    }

    boolean isCompetenzaEliminaFascicolo(FascicoloDTO fascicolo) {
        // Un utente ha i diritti di cancellare un FASCICOLO aperto se ha privilegio EF;
        // ha i diritti di cancellare un FASCICOLO chiuso se ha privilegio EFC.
        boolean abilitazione

        if (fascicolo.dataChiusura && utenteHaPrivilegioGenerico("EFC")) {
            return true
        } else {
            if (utenteHaPrivilegioGenerico("EF")) {
                return true
            }
        }

        return abilitazione
    }
}
