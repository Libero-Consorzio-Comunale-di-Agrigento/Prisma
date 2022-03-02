package it.finmatica.protocollo.titolario

import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneUnita
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Repository
@Transactional
interface ClassificazioneUnitaRepository extends JpaRepository<ClassificazioneUnita,Long> {

    ClassificazioneUnita findByClassificazioneAndUnita(Classificazione classificazione, So4UnitaPubb unita)
    List<ClassificazioneUnita> findByClassificazione(Classificazione classificazione)
}