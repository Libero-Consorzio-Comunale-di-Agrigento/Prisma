package it.finmatica.protocollo.documenti

import groovy.transform.CompileDynamic
import it.finmatica.ad4.security.SpringSecurityService
import groovy.transform.CompileStatic
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzione
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzioneService
import org.springframework.beans.factory.annotation.Autowired

@Action
@CompileStatic
class CampiProtettiAction {

    public static final String BLOCCO_TITOLARIO = 'TITOLARIO'
    public static final String CAMPO_FASCICOLO = 'FASCICOLO'
    public static final String CAMPO_CLASSIFICAZIONE = 'CLASSIFICAZIONE'

    private static final List<BloccoCampi> blocchi = [new BloccoCampi(BLOCCO_TITOLARIO, Protocollo.TIPO_DOCUMENTO, [CAMPO_CLASSIFICAZIONE, CAMPO_FASCICOLO])]

    private static class BloccoCampi {
        private final String codice
        private final String codiceTipoOggetto
        private final List<String> campi

        BloccoCampi(String codice, String codiceTipoOggetto, List<String> campi) {
            this.codice = codice
            this.codiceTipoOggetto = codiceTipoOggetto
            this.campi = campi
        }

        String getCodice() {
            return codice
        }

        String getCodiceTipoOggetto() {
            return codiceTipoOggetto
        }

        List<String> getCampi() {
            return campi
        }
    }

    public static final String METODO_ABILITA_BLOCCO = 'abilitaBlocco_'
    public static final String METODO_PROTEGGI_BLOCCO = 'proteggiBlocco_'
    public static final String METODO_ABILITA_CAMPO = 'abilitaCampo_'
    public static final String METODO_PROTEGGI_CAMPO = 'proteggiCampo_'

    private final WkfAzioneService wkfAzioneService
    private final SpringSecurityService springSecurityService

    CampiProtettiAction(WkfAzioneService wkfAzioneService, SpringSecurityService springSecurityService) {
        this.wkfAzioneService = wkfAzioneService
        this.springSecurityService = springSecurityService
    }

    @CompileDynamic
    def methodMissing(String name, def args) {
        Protocollo protocollo = (Protocollo) ((List)args)[0]

        // i nomi sono della forma:
        // abilitaBlocco_NOME_BLOCCO
        // proteggiBlocco_NOME_BLOCCO
        if (name.startsWith(METODO_ABILITA_BLOCCO)) {
            String codiceBlocco = name.substring(METODO_ABILITA_BLOCCO.length())
            abilitaBlocco(protocollo, codiceBlocco)
        } else if (name.startsWith(METODO_PROTEGGI_BLOCCO)) {
            String codiceBlocco = name.substring(METODO_PROTEGGI_BLOCCO.length())
            proteggiBlocco(protocollo, codiceBlocco)
        } else if (name.startsWith(METODO_ABILITA_CAMPO)) {
            String codiceCampo = name.substring(METODO_ABILITA_CAMPO.length())
            abilitaCampo(protocollo, codiceCampo)
        } else if (name.startsWith(METODO_PROTEGGI_CAMPO)) {
            String codiceCampo = name.substring(METODO_PROTEGGI_CAMPO.length())
            proteggiCampo(protocollo, codiceCampo)
        } else {
            throw new MissingMethodException(name, CampiProtettiAction.class, args)
        }

        protocollo.save()
    }

    void aggiornaAzioni() {
        for (BloccoCampi blocco : blocchi) {
            wkfAzioneService.insertOrUpdate(new WkfAzione([nome         : "Abilita il blocco ${blocco.codice}"
                                                           , descrizione: "Abilita i campi del blocco ${blocco.codice}"
                                                           , nomeBean   : "campiProtettiAction"
                                                           , nomeMetodo : "${METODO_ABILITA_BLOCCO}${blocco.codice}"
                                                           , tipo       : Action.TipoAzione.AUTOMATICA]), blocco.codiceTipoOggetto)

            wkfAzioneService.insertOrUpdate(new WkfAzione([nome         : "Protegge il blocco ${blocco.codice}"
                                                           , descrizione: "Protegge i campi del blocco ${blocco.codice}"
                                                           , nomeBean   : "campiProtettiAction"
                                                           , nomeMetodo : "${METODO_PROTEGGI_BLOCCO}${blocco.codice}"
                                                           , tipo       : Action.TipoAzione.AUTOMATICA]), blocco.codiceTipoOggetto)

            for (String campo : blocco.campi) {
                wkfAzioneService.insertOrUpdate(new WkfAzione([nome         : "Abilita il campo ${campo}"
                                                               , descrizione: "Abilita il ${campo}"
                                                               , nomeBean   : "campiProtettiAction"
                                                               , nomeMetodo : "${METODO_ABILITA_CAMPO}${campo}"
                                                               , tipo       : Action.TipoAzione.AUTOMATICA]), blocco.codiceTipoOggetto)

                wkfAzioneService.insertOrUpdate(new WkfAzione([nome         : "Protegge il campo ${campo}"
                                                               , descrizione: "Protegge il campo ${campo}"
                                                               , nomeBean   : "campiProtettiAction"
                                                               , nomeMetodo : "${METODO_PROTEGGI_CAMPO}${campo}"
                                                               , tipo       : Action.TipoAzione.AUTOMATICA]), blocco.codiceTipoOggetto)
            }
        }
    }

    private void abilitaBlocco(Protocollo protocollo, String codiceBlocco) {
        for (BloccoCampi blocco : blocchi) {
            if (blocco.codice == codiceBlocco) {
                for (String campo : blocco.campi) {
                    abilitaCampo(protocollo, campo)
                }
                return
            }
        }
    }

    private void proteggiBlocco(Protocollo protocollo, String codiceBlocco) {
        for (BloccoCampi blocco : blocchi) {
            if (blocco.codice == codiceBlocco) {
                for (String campo : blocco.campi) {
                    proteggiCampo(protocollo, campo)
                }
                return
            }
        }
    }

    private void abilitaCampo(Protocollo protocollo, String campo) {
        protocollo.abilitaCampo(campo)
    }

    private void proteggiCampo(Protocollo protocollo, String campo) {
        protocollo.proteggiCampo(campo)
    }
}
