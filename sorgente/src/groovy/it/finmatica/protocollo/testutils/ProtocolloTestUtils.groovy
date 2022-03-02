package it.finmatica.protocollo.testutils

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.Holders
import it.finmatica.gestionedocumenti.competenze.DocumentoCompetenze
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioniMap
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggettoAction
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggetto
import it.finmatica.gestionedocumenti.testutils.TestUtils
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAttore
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzione
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgCompetenza
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgStep
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.gestionetesti.reporter.GestioneTestiTipoModello
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.security.InizializzaAgPrivUtenteTmpDopoLogin
import it.finmatica.so4.login.So4SpringSecurityService
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.login.detail.UnitaOrganizzativa
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang.math.RandomUtils
import org.springframework.security.authentication.event.InteractiveAuthenticationSuccessEvent
import org.springframework.security.core.Authentication

import javax.sql.DataSource

/**
 * Created by esasdelli on 28/03/2017.
 */
class ProtocolloTestUtils extends TestUtils {

    private static ImpostazioniMap mapImpostazioni = null

    @Override
    static FileDocumento setUpFile(Documento documento, String codice = FileDocumento.CODICE_FILE_PRINCIPALE, String filepath = "test/resources/TEST_LETTERA.odt", String contentType = "application/odt", String filename = null) {
        File file = new File(filepath)
        if (filename == null) {
            filename = file.name
        }
        FileDocumento filePrincipale = new FileDocumento(nome: filename, contentType: contentType, codice: codice)
        documento.addToFileDocumenti(filePrincipale)
        documento.save()
        Holders.getApplicationContext().getBean(IGestoreFile).addFile(documento, filePrincipale, new File(filepath).newInputStream())
        return filePrincipale
    }

    /**
     * Questa schifezza serve per poter personalizzare le impostazioni negli integration tests siccome vanno su una vista su gdm e non posso quindi fare update.
     * Dopo aver invocato questo metodo, è necessario invocare il metodo cleanupImpostazioni che ripristina le impostazioni originali.
     * @param impostazioni
     */
    static void setUpImpostazioni(Map<String, String> impostazioni) {
        if (mapImpostazioni == null) {
            mapImpostazioni = ImpostazioniProtocollo.map
            ImpostazioniProtocollo.map = new MockImpostazioni(mapImpostazioni)
        }

        ((MockImpostazioni) ImpostazioniProtocollo.map).addImpostazioni(impostazioni)
    }

    /**
     * Ripristina le impostazioni originali come modificate da setUpImpostazioni
     */
    static void cleanupImpostazioni() {
        if (mapImpostazioni != null) {
            ImpostazioniProtocollo.map = mapImpostazioni
            mapImpostazioni = null
        }
    }

    static TipoProtocollo setUpTipoProtocollo(String codice = "PROTOCOLLO") {
        return TipoProtocollo.findByCodice(codice)
        /*
        TipoProtocollo tipoDocumento = new TipoProtocollo(valido: true, codice: codice, descrizione: "Lettera in Entrata", commento: "Lettera in Entrata", funzionarioObbligatorio: true, categoria: Protocollo.CATEGORIA_LETTERA, movimento: Protocollo.MOVIMENTO_INTERNO)
        tipoDocumento.id = 0
        tipoDocumento.tipologiaSoggetto = setUpTipologiaSoggetto()
        tipoDocumento.save()
        tipoDocumento.addToModelliAssociati(new TipoDocumentoModello(modelloTesto: setUpModelloTesto(), codice: FileDocumento.CODICE_FILE_PRINCIPALE, predefinito: true))
        return tipoDocumento*/
    }

    static SchemaProtocollo setUpSchemaProtocollo(String codice = "PEC") {
        return SchemaProtocollo.findByCodice(codice)
    }

    static void login (String user, String amministrazione) {
        TestUtils.login(user, amministrazione)
        // dopo aver fatto login, rilancio la generazione di ag_priv_utenti_tmp:
        DataSource dataSource_gdm = Holders.getApplicationContext().getBean("dataSource_gdm", DataSource)
        Authentication authentication = Holders.getApplicationContext().getBean(SpringSecurityService).getAuthentication()
        new InizializzaAgPrivUtenteTmpDopoLogin(dataSource_gdm).onApplicationEvent(new InteractiveAuthenticationSuccessEvent(authentication, ProtocolloTestUtils))
    }

    static Protocollo setUpProtocollo(TipoProtocollo tipoDocumento = setUpTipoProtocollo()) {

        // verifico che il registro di riferimento sia presente sul server:
        WkfTipoOggetto tipoOggetto = setUpTipoOggetto(Protocollo.TIPO_DOCUMENTO, Protocollo.TIPO_DOCUMENTO)

        Protocollo protocollo = new Protocollo(tipoOggetto: tipoOggetto, tipoProtocollo: tipoDocumento, movimento: Protocollo.MOVIMENTO_INTERNO)
        protocollo.dateCreated = Date.parse("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", "1984-06-22T10:12:13.444Z")

        protocollo.tipoRegistro = TipoRegistro.get("PROT")
        if (protocollo.tipoRegistro == null) {
            protocollo.tipoRegistro = new TipoRegistro(codice: "PROT")
            protocollo.tipoRegistro.save()
        }

        protocollo.classificazione = Classificazione.get(-174492)
        protocollo.fascicolo = Fascicolo.get(-174496)
        protocollo.oggetto = "Protocollo di Test"
        protocollo.setSoggetto(TipoSoggetto.REDATTORE, Holders.getApplicationContext().getBean(So4SpringSecurityService).currentUser, null)
        UnitaOrganizzativa uoUtente = getPrincipal().uo()[0]
        So4UnitaPubb uo = So4UnitaPubb.getUnita(uoUtente.id, uoUtente.ottica, uoUtente.dal).get()
        protocollo.setSoggetto(TipoSoggetto.UO_PROTOCOLLANTE, null, uo)
        protocollo.save()

        // do le competenze all'utente corrente:
        new DocumentoCompetenze(documento: protocollo, utenteAd4: protocollo.utenteIns, lettura: true, modifica: true, cancellazione: true).save()
        return protocollo
    }

    private static So4UserDetail getPrincipal() {
        return (So4UserDetail) Holders.getApplicationContext().getBean(So4SpringSecurityService).principal
    }

    static TipoAllegato setUpTipoAllegato(String codice = "ALLEGATO") {
        TipoAllegato tipoAllegato = TipoAllegato.findByCodice(codice, [sort: 'id', order: 'desc'])
        if (tipoAllegato != null) {
            return tipoAllegato
        }

        return new TipoAllegato(codice: codice, descrizione: codice).save()
    }

    static Allegato setUpAllegato() {
        TipoAllegato tipoDocumento = setUpTipoAllegato()
        WkfTipoOggetto tipoOggetto = setUpTipoOggetto("ALLEGATO", "allegato", false)

        Allegato allegato = new Allegato(riservato: true, tipoOggetto: tipoOggetto, tipoAllegato: tipoDocumento)
        allegato.save()

        return allegato
    }

    static TipologiaSoggetto setUpTipologiaSoggetto(String descrizione = "PROTOCOLLO") {
        return TipologiaSoggetto.findByDescrizione(descrizione)
    }

    static WkfTipoOggetto setUpTipoOggetto(String tipoOggetto = Protocollo.TIPO_DOCUMENTO) {
        return WkfTipoOggetto.findByCodice(tipoOggetto) ?: new WkfTipoOggetto(codice: tipoOggetto, descrizione: tipoOggetto, nome: tipoOggetto).save()
    }

    static GestioneTestiModello setUpModelloTesto(String filename = "TEST_LETTERA.odt", String tipo = Protocollo.CATEGORIA_LETTERA) {
        GestioneTestiModello testo = GestioneTestiModello.findByNome(filename) ?: new GestioneTestiModello(nome: filename, descrizione: filename, tipo: filename.substring(filename.length() - 3), fileTemplate: new File("test/resources/${filename}").bytes, tipoModello: setUpTipoModello()).save()
        return testo
    }

    static GestioneTestiTipoModello setUpTipoModello(String codice = Protocollo.TIPO_DOCUMENTO) {
        return GestioneTestiTipoModello.findByCodice(codice) ?: new GestioneTestiTipoModello(codice: codice, descrizione: codice, query: "<root/>".bytes).save()
    }

    static WkfCfgIter setUpCfgIter(String tipoOggetto = Protocollo.TIPO_DOCUMENTO) {
        WkfTipoOggetto wkfTipoOggetto = setUpTipoOggetto(tipoOggetto)
        WkfCfgIter cfgIter = new WkfCfgIter(tipoOggetto: wkfTipoOggetto, descrizione: "test iter", nome: "test iter", progressivo: RandomUtils.nextLong(), stato: WkfCfgIter.STATO_IN_USO, revisione: 0, verificato: true).save()
        WkfAzione azioneRedattore = WkfAzione.findByNomeMetodoAndTipoOggetto(DocumentoSoggettoAction.METODO_GET_UTENTE + TipoSoggetto.REDATTORE, wkfTipoOggetto)
        if (azioneRedattore == null) {
            azioneRedattore = new WkfAzione(tipo: Action.TipoAzione.CALCOLO_ATTORE, nome: "redattore", tipoOggetto: wkfTipoOggetto, nomeBean: "documentoSoggettoAction", nomeMetodo: DocumentoSoggettoAction.METODO_GET_UTENTE + TipoSoggetto.REDATTORE).save()
        }

        WkfAttore redattore = new WkfAttore(nome: 'redattore', metodoDiCalcolo: azioneRedattore, tipoOggetto: wkfTipoOggetto, valido: true).save()

        WkfCfgStep cfgStepRedattore = new WkfCfgStep(sequenza: 1, nome: "step redattore", titolo: "step 1", descrizione: "step 1", attore: redattore)
        cfgStepRedattore.addToCfgCompetenze(new WkfCfgCompetenza(tipoOggetto: wkfTipoOggetto, attore: redattore, lettura: true, modifica: true))
        cfgIter.addToCfgStep(cfgStepRedattore)
        cfgIter.save()

        WkfCfgStep cfgStepFirmatario = new WkfCfgStep(sequenza: 1, nome: "step fine", titolo: "step 1", descrizione: "step 1", attore: redattore)
        cfgIter.addToCfgStep(cfgStepFirmatario)
        cfgIter.save()

        return cfgIter
    }
}
