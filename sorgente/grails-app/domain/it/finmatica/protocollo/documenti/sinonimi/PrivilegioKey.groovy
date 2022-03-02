package it.finmatica.protocollo.documenti.sinonimi

import it.finmatica.ad4.autenticazione.Ad4Utente

class PrivilegioKey implements Serializable {
    String codiceUnita
    String privilegio
    Ad4Utente utente

    boolean equals(other) {
        if (!(other instanceof PrivilegioKey)) {
            return false
        }

        return (codiceUnita == other.codiceUnita && privilegio == other.privilegio && utente.id == other.utente.id)
    }

    int hashCode() {
        return Objects.hash(codiceUnita, privilegio, utente.id)
    }
}
