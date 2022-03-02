package it.finmatica.protocollo.integrazioni.ricercadocumenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.registri.TipoRegistro

@CompileStatic
class FiltriRegistroGiornaliero {
    int activePage = 0
    int pageSize = 10
    Integer anno
    Date dataProtocolloDa
    Date dataProtocolloA
    Integer numeroDa
    Integer numeroA
    Integer numeroInizialeDa
    Integer numeroInizialeA
    Integer numeroFinaleDa
    Integer numeroFinaleA
    Date dataInizialeDa
    Date dataInizialeA
    Date dataFinaleDa
    Date dataFinaleA
    Date dataInizialeRicercaDa
    Date dataInizialeRicercaA
    Date dataFinaleRicercaDa
    Date dataFinaleRicercaA
    String order = "dateCreated"
    String orderDir = "desc"
    TipoRegistro tipoRegistro
    String testoCerca

    void reset() {
        anno                         = null
        dataProtocolloDa             = null
        dataProtocolloA              = null
        numeroDa                     = null
        numeroA                      = null
        numeroInizialeDa             = null
        numeroInizialeA              = null
        numeroFinaleDa               = null
        numeroFinaleA                = null
        dataInizialeDa               = null
        dataInizialeA                = null
        dataFinaleDa                 = null
        dataFinaleA                  = null
        dataInizialeRicercaDa        = null
        dataInizialeRicercaA         = null
        dataFinaleRicercaDa          = null
        dataFinaleRicercaA           = null
        order                        = "dateCreated"
        orderDir                     = "desc"
        tipoRegistro                 = null
        testoCerca                   = null
    }
}
