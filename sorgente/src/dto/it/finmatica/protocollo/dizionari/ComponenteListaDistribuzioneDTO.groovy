package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.anagrafica.As4Contatto
import it.finmatica.as4.anagrafica.As4ContattoDTO
import it.finmatica.as4.anagrafica.As4Recapito
import it.finmatica.as4.anagrafica.As4RecapitoDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.struttura.So4AnagrafeUnita
import org.apache.cxf.common.util.StringUtils

class ComponenteListaDistribuzioneDTO implements it.finmatica.dto.DTO<ComponenteListaDistribuzione> {

    private static final long serialVersionUID = 1L

    String 	  ni

    // indica l'id del corrispondente sul documentale esterno (ad es. GDM)
    Long    idDocumentoEsterno

    // utili per il dettaglio delle Amministrazioni
    String codiceAmministrazione
    String aoo
    String uo

    As4RecapitoDTO recapito
    As4ContattoDTO contatto

    ListaDistribuzioneDTO listaDistribuzione

    Long id
    Long version
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    Date lastUpdated
    boolean valido

    EnteDTO ente

    //new
    String cap
    String codiceFiscale
    String comune
    String email
    String fax
    String indirizzo
    String partitaIva
    String provinciaSigla
    String denominazione
    String cognome
    String nome
    //new

    ComponenteListaDistribuzione getDomainObject () {
        return ListaDistribuzione.get(this.id)
    }

    ComponenteListaDistribuzione copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    TipoSoggettoDTO tipoSoggetto
    String anagrafica
    String tipoIndirizzo


    // utile per la visualizzazione
    String getIndirizzoCompleto () {

        String indirizzoCompleto = ""

        if(indirizzo != null && indirizzo != ""){
            indirizzoCompleto = indirizzo
        }
        if(cap != null && cap != ""){
            indirizzoCompleto = indirizzoCompleto + " " + cap
            if(!indirizzo){
                indirizzoCompleto.trim()
            }
        }
        if(comune != null && comune != ""){
            indirizzoCompleto = indirizzoCompleto + " " + comune
        }
        if (provinciaSigla != null && provinciaSigla != "") {
            indirizzoCompleto += " ("+ provinciaSigla +")"
        }

        return indirizzoCompleto
    }

    // TODO[SPRINGBOOT]: verificare se è possibile spostare questa logica dal dto in un punto più "consono"
    boolean isChanged(){

        boolean changed = false

        if(this.contatto){
            As4Contatto contattoD = As4Contatto.get(contatto.id)
            if(contattoD?.tipoContatto?.tipoSpedizione == "MAIL"){
                String valore = contattoD.valore
                if(!StringUtils.isEmpty(valore) && !StringUtils.isEmpty(email)){
                    if(!valore.equalsIgnoreCase(email)){
                        changed = true
                        return changed
                    }
                }
            }
        }

        String denominazioneDaConfrontare = ""
        if(ni != null){

            As4SoggettoCorrente soggetto = As4SoggettoCorrente.get(ni)
            //il soggetto è stato chiuso
            if (!soggetto) {
                changed = true
                return changed
            }
            denominazioneDaConfrontare = As4SoggettoCorrente.get(ni)?.nominativoRicerca
        }
        else{

            So4Amministrazione amm = So4Amministrazione.get(codiceAmministrazione)
            denominazioneDaConfrontare = amm?.soggetto?.denominazione

            if(uo != null){
                denominazioneDaConfrontare = denominazioneDaConfrontare + ":UO:" + So4AnagrafeUnita.findByCodiceAndAmministrazione(uo, amm).descrizione
            }
            else if(aoo != null){
                denominazioneDaConfrontare = denominazioneDaConfrontare + ":AOO:" + So4AOO.allaData().perAmministrazione(amm).findByCodiceAndAlIsNull(aoo)?.descrizione
            }
        }

        if(!StringUtils.isEmpty(denominazioneDaConfrontare) && !StringUtils.isEmpty(denominazione) && !denominazioneDaConfrontare.equalsIgnoreCase(denominazione)){
            changed = true
            return changed
        }

        String indirizzoCompletoDaConfrontare = ""

        if(recapito != null){

            if(recapito.id != null){
                recapito = As4Recapito.get(recapito.id).toDTO(["tipoRecapito", "provincia", "comune"])
            }
            if(recapito.indirizzo != null){
                indirizzoCompletoDaConfrontare = recapito.indirizzo
            }
            if(recapito.cap != null ){
                indirizzoCompletoDaConfrontare = indirizzoCompletoDaConfrontare + " " + recapito.cap
            }
            if(recapito.comune?.denominazione != null){
                indirizzoCompletoDaConfrontare = indirizzoCompletoDaConfrontare + " " + recapito.comune.denominazione
            }
            if (recapito.provincia?.sigla != null) {
                indirizzoCompletoDaConfrontare += " ("+ recapito.provincia.sigla +")"
            }
            String indirizzoCompletoSenzaSpazi = indirizzoCompleto.replaceAll(" ", "")
            indirizzoCompletoDaConfrontare = indirizzoCompletoDaConfrontare.replaceAll(" ", "")
            if(!StringUtils.isEmpty(indirizzoCompletoDaConfrontare) && !StringUtils.isEmpty(indirizzoCompletoSenzaSpazi) && !indirizzoCompletoDaConfrontare.equalsIgnoreCase(indirizzoCompletoSenzaSpazi)){
                changed = true
                return changed
            }
        }
        return changed
    }
}
