package it.finmatica.protocollo.zk.components.smistamenti

import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import org.apache.commons.lang3.StringUtils
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Div
import org.zkoss.zul.Hlayout
import org.zkoss.zul.Label
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Listcell
import org.zkoss.zul.Listheader
import org.zkoss.zul.Listitem
import org.zkoss.zul.ListitemRenderer
import org.zkoss.zul.Vlayout

import java.text.SimpleDateFormat

@VariableResolver(DelegatingVariableResolver)
class SmistamentiStoriciComponent extends SmistamentiComponent {

    SmistamentiStoriciComponent() {
        Executions.createComponents("/components/smistamentiStorici.zul", this, null)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Div))
        Selectors.wireComponents(this, this, false)
        Selectors.wireEventListeners(this, this)
    }

    protected void creaHeader() {
        if (listbox.listhead.getChildren()?.size() == 0) {
            listbox.listhead.appendChild(new Listheader(label: "Tipo", width: "10%"))
            listbox.listhead.appendChild(new Listheader(label: "Trasmesso", width: "15%"))
            listbox.listhead.appendChild(new Listheader(label: "Ufficio", width: "15%"))
            listbox.listhead.appendChild(new Listheader(label: "Preso in carico", width: "15%"))
            listbox.listhead.appendChild(new Listheader(label: "Assegnante", width: "15%"))
            listbox.listhead.appendChild(new Listheader(label: "Eseguito", width: "15%"))
            listbox.listhead.appendChild(new Listheader(label: "Rifiutato", width: "15%"))
        }
    }

    void setSmistamenti(List<SmistamentoDTO> smistamenti) {
        if (smistamenti?.size() > 0) {
            listbox.setModel(new ListModelList<?>(smistamenti))

            listbox.setItemRenderer(new ListitemRenderer<SmistamentoDTO>() {
                @Override
                void render(Listitem listitem, SmistamentoDTO smistamentoDTO, int i) throws Exception {
                    /* COLONNA TIPO */
                    Listcell listCellColonnaTipo = new Listcell()
                    riempiColonnaTipo(listCellColonnaTipo, smistamentoDTO)

                    /* COLONNA TRASMESSO */
                    Listcell listCellColonnaTrasmesso = new Listcell()
                    Vlayout vlayoutColonnaTrasmesso = creaColonnaVuota(listCellColonnaTrasmesso)
                    riempiColonnaTrasmesso(vlayoutColonnaTrasmesso, smistamentoDTO)

                    /* COLONNA UFFICIO */
                    Listcell listCellColonnaUtenteAssegnatario = new Listcell()
                    Vlayout vlayoutColonnaUtenteAssegnatario = creaColonnaVuota(listCellColonnaUtenteAssegnatario)
                    riempiColonnaUfficio(vlayoutColonnaUtenteAssegnatario, smistamentoDTO)

                    /* COLONNA UTENTE PRESA IN CARICO */
                    Listcell listCellColonnaUtentePresaInCarico = new Listcell()
                    Vlayout vlayoutColonnaUtentePresaInCarico = creaColonnaVuota(listCellColonnaUtentePresaInCarico)
                    riempiColonnaUtentePresaInCarico(vlayoutColonnaUtentePresaInCarico, smistamentoDTO)

                    /* COLONNA UTENTE ASSEGNANTE */
                    Listcell listCellColonnaUtenteAssegnante = new Listcell()
                    Vlayout vlayoutColonnaUtenteAssegnante = creaColonnaVuota(listCellColonnaUtenteAssegnante)
                    riempiColonnaUtenteAssegnante(vlayoutColonnaUtenteAssegnante, smistamentoDTO)

                    /* COLONNA UTENTE ESECUZIONE */
                    Listcell listCellColonnaUtenteEsecuzione = new Listcell()
                    Vlayout vlayoutColonnaUtenteEsecuzione = creaColonnaVuota(listCellColonnaUtenteEsecuzione)
                    riempiColonnaUtenteEsecuzione(vlayoutColonnaUtenteEsecuzione, smistamentoDTO)

                    /* COLONNA RIFIUTO */
                    Listcell listCellColonnaRifiuto = new Listcell()
                    Vlayout vlayoutColonnaRifiuto = creaColonnaVuota(listCellColonnaRifiuto)
                    riempiColonnaUtenteRifiuto(vlayoutColonnaRifiuto, smistamentoDTO)

                    listitem.appendChild(listCellColonnaTipo)
                    listitem.appendChild(listCellColonnaTrasmesso)
                    listitem.appendChild(listCellColonnaUtenteAssegnatario)
                    listitem.appendChild(listCellColonnaUtentePresaInCarico)
                    listitem.appendChild(listCellColonnaUtenteAssegnante)
                    listitem.appendChild(listCellColonnaUtenteEsecuzione)
                    listitem.appendChild(listCellColonnaRifiuto)
                }
            })
        } else {
            listbox.setEmptyMessage("Nessuno Smistamento presente")
        }
    }

    private void riempiColonnaUfficio(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = smistamentoDTO.utenteAssegnatario?.nominativoSoggetto
        if(StringUtils.isEmpty(labelNominativo.value)){
            labelNominativo.value = smistamentoDTO.utenteAssegnatario?.nominativo
        }

        /* Descrizione */
        Hlayout hlayoutDescrizione = new Hlayout()
        Label labelDescrizione = new Label()
        hlayoutDescrizione.appendChild(labelDescrizione)
        vlayout.appendChild(hlayoutDescrizione)
        labelDescrizione.value = getDescrizioneUO(smistamentoDTO.unitaSmistamento)

        /* Data assegnazione */
        Hlayout hlayoutDataEsecuzione = new Hlayout()
        Label labelDataEsecuzione = new Label()
        hlayoutDataEsecuzione.appendChild(labelDataEsecuzione)
        vlayout.appendChild(hlayoutDataEsecuzione)
        labelDataEsecuzione.value = (smistamentoDTO.dataAssegnazione == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataAssegnazione))
    }
}
