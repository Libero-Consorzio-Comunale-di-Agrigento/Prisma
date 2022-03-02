package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.protocollo.dizionari.Classificazione
import org.apache.commons.lang.StringUtils
import org.zkoss.zk.ui.util.Clients

class ClassificazioneDTO implements it.finmatica.dto.DTO<Classificazione> {

    private static final long serialVersionUID = 1L

    Long id
    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido
    String codice
    Date dal
    Date al
    String descrizione
    String note
    Long idDocumentoEsterno
    Long progressivo
    Long progressivoPadre
    boolean contenitoreDocumenti
    boolean docFascicoliSub
    boolean numIllimitata

    Classificazione getDomainObject() {
        return Classificazione.get(this.id)
    }

    Classificazione copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    public static final String CLASSIFICAZIONE = "CLASSIFICAZIONE"

    String getType() {
        return CLASSIFICAZIONE
    }

    String getNome(){
        if(codice == null){
            return ""
        }
        return StringUtils.join(codice, " - ", descrizione)
    }

    String getDalFormattato(){
        if(dal == null){
            return ""
        }
        return StringUtils.join(dal.toString().substring(8,10) , "/" , dal.toString().substring(5,7) , "/" , dal.toString().substring(0,4))
    }

    String getAlFormattato(){
        if(al == null){
            return ""
        }
        return StringUtils.join(al.toString().substring(8,10) , "/" , al.toString().substring(5,7) , "/" , al.toString().substring(0,4))
    }

    boolean isAperta() {
        Date oggi = new Date().clearTime()
        if (oggi.after(dal)) {
            if (al == null) {
                return true
            } else {
                return oggi.before(al)
            }
        } else {
            return false
        }
    }
}
