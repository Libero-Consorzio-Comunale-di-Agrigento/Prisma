package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic

@CompileStatic
interface RegistroGiornalieroResult {
    String getUtenteModifica()
    Date getDataModifica()
    Date getAllDataModifica()
    Date getCorrDataModifica()
    String getProtOggetto()
    Integer getProtOggettoMod()
    String getOggettoOld()
    String getModalitaInvio()
    Integer getModalitaInvioMod()
    String getModalitaInvioOld()
    String getAllegatoDescrizione()
    Integer getAllegatoFileType()
    String getAllegatoFile()
    Integer getCorrispondenteType()
    String getCorrispondenteNome()
    String getCorrispondenteIndirizzo()
}