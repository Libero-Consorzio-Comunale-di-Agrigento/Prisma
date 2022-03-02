package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Ente
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface DocAreaTokenRepository extends JpaRepository<DocAreaToken,Long> {

    @Query(value = 'SELECT e FROM Ente e join e.amministrazione amm WHERE amm.codice = :codice')
    Ente findEnteByCodice(@Param('codice') String codice)

    @Query(value = 'SELECT e FROM Ente e join e.amministrazione amm WHERE amm.codice = :codice AND e.aoo = :aoo')
    Ente findEnteByCodiceAndAoo(@Param('codice') String codice, @Param('aoo') String aoo)

    @Query(value = 'SELECT e FROM Ente e join e.amministrazione amm WHERE amm.codice = :codice AND e.aoo = :aoo')
    Ente findEnteById(@Param('codice') String codice, @Param('aoo') String aoo)

    @Query(value = 'SELECT t FROM DocAreaToken t JOIN t.utenteIns u JOIN FETCH t.ente en JOIN FETCH en.amministrazione amm WHERE t.token = :token AND u.nominativo = :nominativo')
    DocAreaToken findFirstByTokenAndUtenteInsNominativo(@Param('token')String token, @Param('nominativo')String nominativo)

    @Modifying
    @Query('DELETE FROM DocAreaToken tok WHERE tok.dateCreated < :obsoleteTime')
    int deleteObsolete(@Param('obsoleteTime') Date obsoleteTime)
}