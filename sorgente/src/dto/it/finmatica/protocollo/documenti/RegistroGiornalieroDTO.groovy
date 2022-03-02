package it.finmatica.protocollo.documenti

import it.finmatica.dto.DTO

class RegistroGiornalieroDTO implements DTO<RegistroGiornaliero> {
    Long id
    int primoNumero
    int ultimoNumero
    Date dataPrimoNumero
    Date dataUltimoNumero
    int totaleProtocolli
    int totaleAnnullati
    Date ricercaDataDal
    Date ricercaDataAl
    List<ProtocolloDTO> protocolli
    String errore

    ProtocolloDTO getProtocollo() {
        return protocolli?.get(0)
    }

    RegistroGiornaliero getDomainObject() {
        return RegistroGiornaliero.get(id)
    }

    RegistroGiornaliero copyToDomainObject() {
        return null
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrÃ  eliminato dalla rigenerazione dei DTO.
}
