package it.finmatica.protocollo.dizionari

import it.finmatica.dto.DTO

class StatoScartoDTO implements DTO<StatoScarto> {

    String codice
    String descrizione
    String codiceGdm

    @Override
    StatoScarto getDomainObject() {
        return StatoScarto.get(codice)
    }

    StatoScarto copyToDomainObject() {
        return null
    }
}
