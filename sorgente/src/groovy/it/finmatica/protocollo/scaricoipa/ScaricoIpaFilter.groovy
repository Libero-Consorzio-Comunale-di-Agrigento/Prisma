package it.finmatica.protocollo.scaricoipa

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia

class ScaricoIpaFilter {

    String codiceAmministrazione
    String codiceAoo
    String codiceUo
    String descrizioneAoo
    String descrizioneAmministrazione
    String descrizioneUo
    String descrizione
    String indirizzo
    String cap
    String citta
    String provincia
    String cognomeResponsabile
    String nomeResponsabile
    String mailResp
    String telephonenumberResp
    String titoloResp
    String mail
    String sito
    String telefono
    String fax
    String codiceFiscaleAmm
    String dataIstituzione
    String dataSoppressione
    String unita
    String unitaPadre
    String codiceFiscaleSFE
    String utenteAggiornamento
    String dataAggiornamento
    String ni
    String ente
    String tipologiaEnte
    String regione
    Ad4Provincia ad4Provincia
    Ad4Comune ad4Comune
    Ad4Utente ad4UtenteAgg
    String competenza
    String competenzaEsclusiva
    boolean importaTutteAmm
    boolean importaTutteUnita
    boolean importaTutteAoo

    String getRegione() {
        return regione
    }

    void setRegione(String regione) {
        this.regione = regione
    }

    String getTipologiaEnte() {
        return tipologiaEnte
    }

    void setTipologiaEnte(String tipologiaEnte) {
        this.tipologiaEnte = tipologiaEnte
    }

    String getEnte() {
        return ente
    }

    void setEnte(String ente) {
        this.ente = ente
    }

    String getNi() {
        return ni
    }

    void setNi(String ni) {
        this.ni = ni
    }

    void setUtenteAggiornamento(String utenteAggiornamento) {
        this.utenteAggiornamento = utenteAggiornamento
    }

    String getCompetenza() {
        return competenza
    }

    void setCompetenza(String competenza) {
        this.competenza = competenza
    }

    String getCompetenzaEsclusiva() {
        return competenzaEsclusiva
    }

    void setCompetenzaEsclusiva(String competenzaEsclusiva) {
        this.competenzaEsclusiva = competenzaEsclusiva
    }

    String getUtenteAggiornamento() {
        return utenteAggiornamento
    }

    void getUtenteAggiornamento(String utenteAggiornamento) {
        this.utenteAggiornamento = utenteAggiornamento
    }

    String getDataAggiornamento() {
        return dataAggiornamento
    }

    void setDataAggiornamento(String dataAggiornamento) {
        this.dataAggiornamento = dataAggiornamento
    }

    String getCodiceAmministrazione() {
        return codiceAmministrazione
    }

    void setCodiceAmministrazione(String codiceAmministrazione) {
        this.codiceAmministrazione = codiceAmministrazione
    }

    String getCodiceAoo() {
        return codiceAoo
    }

    void setCodiceAoo(String codiceAoo) {
        this.codiceAoo = codiceAoo
    }

    String getCodiceUo() {
        return codiceUo
    }

    void setCodiceUo(String codiceUo) {
        this.codiceUo = codiceUo
    }

    String getDescrizioneAoo() {
        return descrizioneAoo
    }

    void setDescrizioneAoo(String descrizioneAoo) {
        this.descrizioneAoo = descrizioneAoo
    }

    String getDescrizione() {
        return descrizione
    }

    void setDescrizione(String descrizione) {
        this.descrizione = descrizione
    }

    String getIndirizzo() {
        return indirizzo
    }

    void setIndirizzo(String indirizzo) {
        this.indirizzo = indirizzo
    }

    String getCap() {
        return cap
    }

    void setCap(String cap) {
        this.cap = cap
    }

    String getCitta() {
        return citta
    }

    void setCitta(String citta) {
        this.citta = citta
    }

    String getProvincia() {
        return provincia
    }

    void setProvincia(String provincia) {
        this.provincia = provincia
    }

    String getCognomeResponsabile() {
        return cognomeResponsabile
    }

    void setCognomeResponsabile(String cognomeResponsabile) {
        this.cognomeResponsabile = cognomeResponsabile
    }

    String getNomeResponsabile() {
        return nomeResponsabile
    }

    void setNomeResponsabile(String nomeResponsabile) {
        this.nomeResponsabile = nomeResponsabile
    }

    String getMailResp() {
        return mailResp
    }

    void setMailResp(String mailResp) {
        this.mailResp = mailResp
    }

    String getTelephonenumberResp() {
        return telephonenumberResp
    }

    void setTelephonenumberResp(String telephonenumberResp) {
        this.telephonenumberResp = telephonenumberResp
    }

    String getTitoloResp() {
        return titoloResp
    }

    void setTitoloResp(String titoloResp) {
        this.titoloResp = titoloResp
    }

    String getMail() {
        return mail
    }

    void setMail(String mail) {
        this.mail = mail
    }

    String getSito() {
        return sito
    }

    void setSito(String sito) {
        this.sito = sito
    }

    String getTelefono() {
        return telefono
    }

    void setTelefono(String telefono) {
        this.telefono = telefono
    }

    String getFax() {
        return fax
    }

    void setFax(String fax) {
        this.fax = fax
    }

    String getCodiceFiscaleAmm() {
        return codiceFiscaleAmm
    }

    void setCodiceFiscaleAmm(String codiceFiscaleAmm) {
        this.codiceFiscaleAmm = codiceFiscaleAmm
    }

    String getDataIstituzione() {
        return dataIstituzione
    }

    void setDataIstituzione(String dataIstituzione) {
        this.dataIstituzione = dataIstituzione
    }

    String getDataSoppressione() {
        return dataSoppressione
    }

    void setDataSoppressione(String dataSoppressione) {
        this.dataSoppressione = dataSoppressione
    }

    String getUnita() {
        return unita
    }

    void setUnita(String unita) {
        this.unita = unita
    }

    String getUnitaPadre() {
        return unitaPadre
    }

    void setUnitaPadre(String unitaPadre) {
        this.unitaPadre = unitaPadre
    }

    String getCodiceFiscaleSFE() {
        return codiceFiscaleSFE
    }

    void setCodiceFiscaleSFE(String codiceFiscaleSFE) {
        this.codiceFiscaleSFE = codiceFiscaleSFE
    }

    Ad4Comune getAd4Comune() {
        return ad4Comune
    }

    void setAd4Comune(Ad4Comune ad4Comune) {
        this.ad4Comune = ad4Comune
    }

    Ad4Provincia getAd4Provincia() {
        return ad4Provincia
    }

    void setAd4Provincia(Ad4Provincia ad4Provincia) {
        this.ad4Provincia = ad4Provincia
    }

    ScaricoIpaFilter() {
    }
}
