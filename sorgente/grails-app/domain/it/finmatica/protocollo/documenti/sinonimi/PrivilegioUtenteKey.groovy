package it.finmatica.protocollo.documenti.sinonimi

import it.finmatica.ad4.autenticazione.Ad4Utente

class PrivilegioUtenteKey implements Serializable {
    String codiceUnita
    String privilegio
    Ad4Utente utente
    String ruolo
    Date dal

    boolean equals(other) {
        if (!(other instanceof PrivilegioUtenteKey)) {
            return false
        }

        return (codiceUnita == other.codiceUnita && privilegio == other.privilegio && utente.id == other.utente.id && dal == other.dal && ruolo == other.ruolo)
    }

    int hashCode() {
        return Objects.hash(codiceUnita, privilegio, utente.id, dal, ruolo)
    }
}
