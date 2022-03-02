package it.finmatica.protocollo.documenti.mail

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional
@Service
class ConfigurazioniMailService {
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    So4Repository so4Repository
    @Autowired
    SpringSecurityService springSecurityService

    Map csTagTutte = [desrizioneCasella: "(Tutte)",
                      casella          : null,
                      tag              : ""]
    Map csTagNessuna = [desrizioneCasella: "(Nessuna casella)",
                        casella          : null,
                        tag              : "X"]

    public static final String TIPO_CASELLA_ISTITUZIONALE = 'ISTITUZIONALE'
    public static final String TIPO_CASELLA_UNITA = 'UNITA'

    List<HashMap<String, String>> getListaCaselle(boolean aggiungiNessuna = true) {
        def listaCaselle = []

        //Casella principale dell'ente
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILI, springSecurityService.currentUser)) {

            Ente ente = springSecurityService.getPrincipal().getEnte()

            if (ente != null) {
                So4AOO so4AOO = so4Repository.getAoo(ente.aoo, ente.amministrazione.codice)

                if (so4AOO != null) {
                    So4IndirizzoTelematico so4IndirizzoTelematico = so4Repository.getIndirizzoAoo("I", so4AOO.id, so4AOO.dal)

                    listaCaselle << [tipo             : TIPO_CASELLA_ISTITUZIONALE,
                                     desrizioneCasella: so4AOO.descrizione + " (" + so4IndirizzoTelematico?.indirizzo + ")",
                                     casella          : so4IndirizzoTelematico?.indirizzo,
                                     tag              : ImpostazioniProtocollo.TAG_MAIL_AUTO.valore,
                                     codiceEnte       : so4AOO.codice]
                }
            }
        }

        //Caselle legate all'unità dell'utente
        List<So4UnitaPubb> listaUnita = so4Repository.getListUnita(springSecurityService.currentUser, PrivilegioUtente.PMAILU)
        if (listaUnita != null) {
            for (unita in listaUnita) {
                List<So4IndirizzoTelematico> listaIndirizziUo = so4Repository.getListaIndirizzoUo(null, unita)

                if (listaIndirizziUo != null) {
                    for (indirizzo in listaIndirizziUo) {
                        if (indirizzo.tipoIndirizzo.equals("R") || indirizzo.tipoIndirizzo.equals("M") || indirizzo.tipoIndirizzo.equals("F")) {
                            continue
                        }

                        String prefixIndirizzo
                        prefixIndirizzo = ""

                        if (indirizzo.tipoIndirizzo.equals("I")) {
                            prefixIndirizzo = "DEF - "
                        }

                        if (indirizzo.tipoIndirizzo.equals("P")) {
                            prefixIndirizzo = "PEC - "
                        }

                        listaCaselle << [tipo             : TIPO_CASELLA_UNITA,
                                         desrizioneCasella: unita.descrizione + " (" + prefixIndirizzo + indirizzo.indirizzo + ")",
                                         casella          : indirizzo.indirizzo,
                                         tag              : ImpostazioniProtocollo.TAG_MAIL_AUTO.valore,
                                         codiceEnte       : unita.codice]
                    }
                }
            }
        }

        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILT, springSecurityService.currentUser)) {
            listaCaselle.add(0, csTagTutte)
        } else {
            if (listaCaselle.size() == 0 && aggiungiNessuna) {
                listaCaselle.add(0, csTagNessuna)
            }
        }

        return listaCaselle
    }
}
