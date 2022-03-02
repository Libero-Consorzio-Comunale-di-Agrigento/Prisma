package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
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
class RinominaFileImportComponent extends Span {

    public static final String ON_CHANGE_FILEDOCUMENTO = 'onChangeFileDocumento'
    public static final String ON_CHANGE_NAME = 'onCambiaNome'

    @WireVariable
    private AllegatoProtocolloService allegatoProtocolloService

    private AllegatoEsterno fileDocumento
    private AllegatoDTO allegato

    private final Button cambiaNomeButton = new Button()
    private final Button accettaNomeButton = new Button()
    private final Button annullaRinominaButton = new Button()
    private final Label nomeFilelabel = new Label()

    final Textbox nomeFileText = new Textbox()

    RinominaFileImportComponent(boolean visibileNomeFileLabel = true) {

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

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Span))
    }

    AllegatoEsterno getFileDocumento() {
        return fileDocumento
    }

    AllegatoDTO getAllegato() {
        return allegato
    }

    void setAllegato(AllegatoDTO allegato) {
        this.allegato = allegato
    }

    void setFileDocumento(AllegatoEsterno fileDocumento) {
        this.fileDocumento = fileDocumento
        if (fileDocumento?.nome) {
            nomeFilelabel.value = fileDocumento.nome
            nomeFileText.cols = fileDocumento.nome.size()
            nomeFileText.value = fileDocumento.nome
        }
        if (isVisibleBtnRinomina()) {
            Span bottoniSpan = new Span()
            bottoniSpan.setWidth("50px")
            bottoniSpan.setStyle("text-align:right;")
            bottoniSpan.appendChild(cambiaNomeButton)
            bottoniSpan.appendChild(accettaNomeButton)
            bottoniSpan.appendChild(annullaRinominaButton)
            appendChild(bottoniSpan)
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

        if (allegato) {
            protocollo = (Protocollo) allegato.domainObject.documentoPrincipale
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


        fileDocumento.nome = nomeFileText.value

        annullaRinominaButton.setVisible(false)
        cambiaNomeButton.setVisible(true)
        accettaNomeButton.setVisible(false)
        nomeFileText.visible = false
        nomeFilelabel.visible = true

        fileDocumento.nome = nomeNuovo
        fileDocumento.contentType = GestioneTestiService.getContentType(FilenameUtils.getExtension(nomeNuovo))
        fileDocumento.contentType = fileDocumento.getContentType()
        Events.postEvent(new Event(ON_CHANGE_NAME, this))
    }

    boolean isVisibleBtnRinomina() {
        return true
    }
}
