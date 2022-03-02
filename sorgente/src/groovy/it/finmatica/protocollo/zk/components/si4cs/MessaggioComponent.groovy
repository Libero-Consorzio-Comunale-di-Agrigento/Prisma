package it.finmatica.protocollo.zk.components.si4cs

import it.finmatica.protocollo.corrispondenti.MessaggioDTO
import org.zkoss.bind.annotation.Command
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Cell
import org.zkoss.zul.Div
import org.zkoss.zul.Html
import org.zkoss.zul.Label
import org.zkoss.zul.Window

import java.text.SimpleDateFormat

@VariableResolver(DelegatingVariableResolver)
class MessaggioComponent extends Div {

    private MessaggioDTO messaggioDTO

    @Wire("#dataSpedizione")
    private Label dataSpedizione
    @Wire("#dataRicezione")
    private Label dataRicezione
    @Wire("#dataRicezioneLabel")
    private Label dataRicezioneLabel
    @Wire("#mittente")
    private Label mittente
    @Wire("#destinatari")
    private Label destinatari
    @Wire("#destinatariConoscenza")
    private Label destinatariConoscenza
    @Wire("#destinatariNascosti")
    private Label destinatariNascosti
    @Wire("#oggetto")
    private Label oggetto
    @Wire("#testo")
    private Html testo
    @Wire("#divTesto")
    private Div divTesto

    MessaggioComponent() {
        Executions.createComponents("/components/messaggio.zul", this, null)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Div))
        Selectors.wireComponents(this, this, false)
        Selectors.wireEventListeners(this, this)
    }

    void setMessaggioDTO(MessaggioDTO messaggioDTO) {
        if (messaggioDTO != null) {
            SimpleDateFormat formatDate = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss")

            dataSpedizione.setValue(messaggioDTO.dataSpedizioneMemo)

            if (!messaggioDTO.inPartenza) {
                dataRicezione.setValue(formatDate.format(messaggioDTO.dataRicezione))
            } else {
                dataRicezioneLabel.visible = false
                dataRicezione.visible = false
            }

            mittente.setValue(messaggioDTO.mittente)
            destinatari.setValue(messaggioDTO.destinatari)
            destinatariConoscenza.setValue(messaggioDTO.destinatariConoscenza)
            destinatariNascosti.setValue(messaggioDTO.destinatariNascosti)
            oggetto.setValue(messaggioDTO.oggetto)
            if (messaggioDTO.corpo?.trim()?.size() == 0) {
                divTesto.height = "10px"
            } else {
                testo.setContent(messaggioDTO.corpo?.replaceAll("\r\n", "<BR>"))
            }

            this.messaggioDTO = messaggioDTO
        }
    }
}