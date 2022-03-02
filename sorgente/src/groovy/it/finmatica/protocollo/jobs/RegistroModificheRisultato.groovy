package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.storico.DatoStorico
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.RegistroGiornalieroResult

@CompileStatic
class RegistroModificheRisultato {
    int daNumero
    int aNumero
    int totale = 0
    Date dataPrimoNumero
    Date dataUltimoNumero
    Date ricercaDal
    Date ricercaAl
    List<Protocollo> listaNuovi
    List<ModificaProtocollo> listaModificati
    int totaleAnnullati = 0
    int totaleModificati = 0
}

class ModificaProtocollo {
    Protocollo protocollo
    List<ProprietaProtocollo> datiStorici
    RegistroGiornalieroResult primaVersione
    String utenteAnnullamento
    Date dataModifica
}

class ProprietaProtocollo {
    boolean oggettoCambiato = false
    String oggettoVecchio
    String oggettoNuovo
    boolean modalitaCambiata = false
    String modalitaVecchia
    String modalitaNuova
    List<AllegatoProtocollo> allegati
    List<DestinatarioProtocollo> destinatari
    Date dataModifica
    String nominativoUtente
}

class AllegatoProtocollo {
    Long id
    String nomeFile
    String impronta
    DatoStorico.TipoStorico stato
}

class DestinatarioProtocollo {
    Long id
    String denominazione
    DatoStorico.TipoStorico stato
}



