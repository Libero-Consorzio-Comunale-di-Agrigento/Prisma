package it.finmatica.protocollo.zk.components.movimento

import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import org.apache.commons.lang.StringUtils
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.SelectEvent
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Combobox
import org.zkoss.zul.Div
import org.zkoss.zul.Label
import org.zkoss.zul.ListModelList

/**
 * Questo componente mostra:
 *
 * - se è possibile modificare il movimento, mostra una combobox con la lista dei movimenti possibili
 * - oppure una label che indica quale è il movimento scelto
 */
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['protocollo:@ZKBIND(ACCESS=both, SAVE_EVENT=onChangeMovimento)'])
class MovimentoComponent extends Div {

    public static final String ON_CHANGE_MOVIMENTO = 'onChangeMovimento'

    // servizi
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private PreferenzeUtenteService preferenzeUtenteService

    // componenti figli
    private Combobox combobox
    private Label movimentoLabel
    private Label label

    // dati
    private ProtocolloDTO protocollo

    // variabili di stato
    private boolean readOnly

    void setReadOnly(boolean readOnly) {
        this.readOnly = readOnly
    }

    MovimentoComponent() {

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Div))
        Selectors.wireEventListeners(this, this)

        label = new Label(visible: false)
        label.setClass("mandatoryLabel")
        label.value = "*"

        combobox = new Combobox(id: 'movimentoCombo', visible: false, readonly: true, vflex: 1, mold: 'rounded')
        List<String> listaMovimenti = getMovimentiDisponibili(protocollo)
        combobox.model = new ListModelList<>(listaMovimenti)
        combobox.addEventListener(Events.ON_SELECT) { SelectEvent event ->
            cambiaMovimento(event.target.value)
        }

        movimentoLabel = new Label(visible: false, sclass: 'documentoSottoTitolo')
        appendChild(label)
        appendChild(combobox)
        appendChild(movimentoLabel)

    }

    ProtocolloDTO getProtocollo() {
        return this.protocollo
    }

    void setProtocollo(ProtocolloDTO protocollo) {
        this.protocollo = protocollo
        update()
    }

    List<String> getMovimenti() {
        return getMovimentiDisponibili(protocollo)
    }

    private List<String> getMovimentiDisponibili(ProtocolloDTO protocollo) {

        if (protocollo?.tipoProtocollo == null) {
            return []
        }

        List<String> movimenti = protocollo?.tipoProtocollo.categoriaProtocollo.movimenti

        if (protocollo.movimento != Protocollo.MOVIMENTO_ARRIVO && !gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.MOVIMENTO_ARRIVO)) {
            movimenti.remove(Protocollo.MOVIMENTO_ARRIVO)
        }

        if (protocollo.movimento != Protocollo.MOVIMENTO_PARTENZA && !gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.MOVIMENTO_PARTENZA)) {
            movimenti.remove(Protocollo.MOVIMENTO_PARTENZA)
        }

        if (protocollo.movimento != Protocollo.MOVIMENTO_INTERNO && !gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.MOVIMENTO_INTERNO)) {
            movimenti.remove(Protocollo.MOVIMENTO_INTERNO)
        }

        return movimenti
    }

    private void cambiaMovimento(String movimento) {
        this.protocollo.movimento = movimento
        Events.postEvent(ON_CHANGE_MOVIMENTO, this, this.protocollo)
    }

    private void update() {
         if(!protocollo){
            return
        }

        this.readOnly = this.readOnly || this.protocollo?.tipoProtocollo?.movimento != null

        if(StringUtils.isEmpty(protocollo.movimento)){
            protocollo.movimento = protocollo?.tipoProtocollo?.movimento
        }

        if(StringUtils.isEmpty(protocollo.movimento)){
            SchemaProtocolloDTO schemaProtocollo = protocollo?.schemaProtocollo
            if (schemaProtocollo) {
                if (schemaProtocollo.isDomandaAccesso()) {
                    protocollo.movimento = protocollo.schemaProtocollo.movimento
                    readOnly = true
                } else {
                    Protocollo p = protocollo?.domainObject
                    if(p){
                        readOnly = !gestoreCompetenze.getCompetenze(p).modifica
                    }
                }
            }
        }

        // se il componente è in sola lettura, mostro la label:
        if (this.readOnly) {
            combobox.visible = false
            movimentoLabel.visible = true
            movimentoLabel.value = protocollo.movimento
            return
        }

        combobox.visible = true
        movimentoLabel.visible = false

        String preferenzaModalita = preferenzeUtenteService.getModalita()
        if (!StringUtils.isEmpty(preferenzaModalita) && StringUtils.isEmpty(protocollo.movimento)) {
            protocollo.movimento = preferenzaModalita
        }

        List<String> listaMovimenti = getMovimentiDisponibili(protocollo)
        combobox.model = new ListModelList<>(listaMovimenti)

        if (listaMovimenti?.size() == 1) {
            combobox.value = listaMovimenti[0]
            protocollo.movimento = listaMovimenti[0]
        } else {
            if (listaMovimenti.contains(protocollo.movimento)) {
                combobox.value = protocollo.movimento
            } else {
                // se non contiene il movimento, non lo imposto e lo resetto "indietro"
                combobox.value = null
                protocollo.movimento = null
            }
        }

    }
}
