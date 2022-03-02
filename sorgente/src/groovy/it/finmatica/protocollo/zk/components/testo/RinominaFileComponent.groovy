package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.lang.StringUtils
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Label
import org.zkoss.zul.Span
import org.zkoss.zul.Textbox

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class RinominaFileComponent extends Span {

    public static final String ON_CHANGE_FILEDOCUMENTO = 'onChangeFileDocumento'
    public static final String ON_CHANGE_NAME = 'onCambiaNome'

    @WireVariable
    private AllegatoProtocolloService allegatoProtocolloService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private SpringSecurityService springSecurityService

    private FileDocumentoDTO fileDocumento
    private AllegatoDTO allegato

    private final Button cambiaNomeButton = new Button()
    private final Button accettaNomeButton = new Button()
    private final Button annullaRinominaButton = new Button()
    private final Label nomeFilelabel = new Label()
    private Span bottoniSpan = null

    final Textbox nomeFileText = new Textbox()

    RinominaFileComponent(boolean visibileNomeFileLabel = true) {

        setStyle("margin-right:10px;")

        cambiaNomeButton.setMold('trendy')
        cambiaNomeButton.setImage('/images/ags/16x16/pencil.png')
        cambiaNomeButton.setTooltiptext('Modifica nome del file')
        cambiaNomeButton.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            void onEvent(Event event) {
                editaNome()
            }
        })

        accettaNomeButton.setMold('trendy')
        accettaNomeButton.setImage('/images/ags/16x16/viewok.png')
        accettaNomeButton.setTooltiptext('Conferma nome del file')
        accettaNomeButton.setVisible(false)
        accettaNomeButton.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            void onEvent(Event event) {
                accettaRinomina()
            }
        })

        annullaRinominaButton.setMold('trendy')
        annullaRinominaButton.setImage('/images/ags/16x16/removed.png')
        annullaRinominaButton.setVisible(false)
        annullaRinominaButton.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            void onEvent(Event event) {
                annullaRinomina()
            }
        })

        nomeFileText.setStyle("margin-right:10px")
        nomeFileText.mold = "rounded"
        nomeFileText.visible = false

        appendChild(nomeFileText)
        if (visibileNomeFileLabel) {
            appendChild(nomeFilelabel)
            nomeFilelabel.visible = true
            nomeFilelabel.setStyle("margin-right:10px")
        }

        /*
        Span bottoniSpan = new Span()
        bottoniSpan.setWidth("50px")
        bottoniSpan.setStyle("text-align:right;")
        bottoniSpan.appendChild(cambiaNomeButton)
        bottoniSpan.appendChild(accettaNomeButton)
        bottoniSpan.appendChild(annullaRinominaButton)

        appendChild(bottoniSpan)
*/
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Span))
    }

    FileDocumentoDTO getFileDocumento() {
        return fileDocumento
    }

    AllegatoDTO getAllegato() {
        return allegato
    }

    void setAllegato(AllegatoDTO allegato) {
        this.allegato = allegato
    }

    void setFileDocumento(FileDocumentoDTO fileDocumento) {
        this.fileDocumento = fileDocumento
        if (fileDocumento?.nome) {
            nomeFilelabel.value = fileDocumento.nome
            nomeFileText.cols = fileDocumento.nome.size()
            nomeFileText.value = fileDocumento.nome
        }
        if (isVisibleBtnRinomina()) {
            if (null == bottoniSpan) {
                bottoniSpan = new Span()
                bottoniSpan.setWidth("50px")
                bottoniSpan.setStyle("text-align:right;")
                bottoniSpan.appendChild(cambiaNomeButton)
                bottoniSpan.appendChild(accettaNomeButton)
                bottoniSpan.appendChild(annullaRinominaButton)
                appendChild(bottoniSpan)
            } else {
                bottoniSpan.setVisible(true)
            }
        } else {
            cambiaNomeButton.setVisible(false)
        }
    }

    void editaNome() {
        annullaRinominaButton.setVisible(true)
        accettaNomeButton.setVisible(true)
        nomeFileText.visible = true
        nomeFileText.value = fileDocumento.nome
        nomeFilelabel.visible = false
        cambiaNomeButton.setVisible(false)
        Events.postEvent(ON_CHANGE_FILEDOCUMENTO, this, fileDocumento)
    }

    void annullaRinomina() {
        annullaRinominaButton.setVisible(false)
        cambiaNomeButton.setVisible(true)
        accettaNomeButton.setVisible(false)
        nomeFileText.visible = false
        nomeFilelabel.visible = true
        Events.postEvent(ON_CHANGE_FILEDOCUMENTO, this, fileDocumento)
    }

    void accettaRinomina() {

        String nomeNuovo = nomeFileText.value?.trim()
        if (StringUtils.isEmpty(nomeNuovo) || nomeNuovo == fileDocumento.nome || nomeNuovo.lastIndexOf(".") < 1) {
            annullaRinomina()
            return
        }

        //verifica se il nome contiene caratteri non validi
        Set<String> caratteriNonConsentiti = allegatoProtocolloService.verificaCaratteriSpeciali(nomeNuovo)
        if (caratteriNonConsentiti.size() > 0) {
            ClientsUtils.showError("Attenzione sono prensenti caratteri non consentiti " + caratteriNonConsentiti.each { it -> it + " " } + " nel nome del file. Rinominare il file.")
            return
        }

        Protocollo protocollo = null
        Documento documento = fileDocumento.domainObject.documento
        if (documento instanceof Allegato) {
            protocollo = (Protocollo) ((Allegato) documento).documentoPrincipale
        } else if (documento instanceof Protocollo) {
            protocollo = ((Protocollo) documento)
        }

        //il controllo non va fatto se in ARRIVO per PEC e PROT MANUALE
        boolean controllaFormatoAllegato = false
        if (protocollo) {
            if (protocollo.movimento != Protocollo.MOVIMENTO_ARRIVO) {
                controllaFormatoAllegato = true
            } else if (!(protocollo.categoriaProtocollo.isPec() || protocollo.categoriaProtocollo.isProtocollo())) {
                controllaFormatoAllegato = true
            }
        }

        if (controllaFormatoAllegato) {
            if (Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.size() > 0 && Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valore != "") {
                if (!Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.collect {
                    it.toString().toLowerCase()
                }.contains(FilenameUtils.getExtension(nomeNuovo).toLowerCase())) {
                    ClientsUtils.showError("Impossibile rinominare il file. Estensione " + FilenameUtils.getExtension(nomeNuovo) + " non consentita.")
                    return
                }
            }
        }


        if (protocollo) {
            AllegatoProtocolloService.UNIVOCITA_NOMI_FILE univocitaNomiFile
            univocitaNomiFile = allegatoProtocolloService.isNomeFileUnivoco(protocollo, allegato, nomeNuovo)
            if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_PRINCIPALE)) {
                ClientsUtils.showError("Impossibile caricare il file: il file ${nomeNuovo} ha lo stesso nome dei file principale del documento.")
                return
            }
            if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_ALLEGATO)) {
                ClientsUtils.showError("Non è possibile caricare due volte un file con lo stesso nome: ${nomeNuovo}.")
                return
            }
        }

        fileDocumento.nome = nomeNuovo
        allegatoProtocolloService.cambiaNomeFile(fileDocumento.domainObject, nomeNuovo, GestioneTestiService.getContentType(FilenameUtils.getExtension(nomeNuovo)))

        annullaRinominaButton.setVisible(false)
        cambiaNomeButton.setVisible(true)
        accettaNomeButton.setVisible(false)
        nomeFileText.visible = false
        nomeFilelabel.visible = true

        fileDocumento.nome = nomeNuovo
        Events.postEvent(new Event(ON_CHANGE_NAME, this))
    }

    boolean isVisibleBtnRinomina() {
        Ad4Utente utenteAd4 = springSecurityService.currentUser

        ProtocolloDTO protocollo = null
        if (fileDocumento.idFileEsterno == null) {
            return false
        }
        Documento documento = fileDocumento.domainObject.documento
        if (documento instanceof Allegato) {
            Allegato allegato = ((Allegato) documento)
            protocollo = (ProtocolloDTO) allegato.documentoPrincipale.toDTO("tipoProtocollo")
            if (allegato.tipoAllegato?.acronimo == ImpostazioniProtocollo.ALLEGATO_COPIA_CONFORME.valore) {
                if (fileDocumento.nome.startsWith("CC_")) {
                    return false
                }
            }
            protocollo = (ProtocolloDTO) ((Allegato) documento).documentoPrincipale.toDTO("tipoProtocollo")
            return protocolloService.isModificabilitaTesto(protocollo?.domainObject, utenteAd4, true)
        } else if (documento instanceof Protocollo) {
            protocollo = ((ProtocolloDTO) documento.toDTO("tipoProtocollo"))
        }

        return protocolloService.isModificabilitaTesto(protocollo?.domainObject, utenteAd4)
    }
}
