package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface DocAreaFileRepository extends JpaRepository<DocAreaFile,Long> {

    @Modifying
    @Query('DELETE FROM DocAreaFile df WHERE  df.token IN (SELECT tok FROM DocAreaToken tok WHERE tok.dateCreated < :obsoleteTime)')
    int deleteObsolete(@Param('obsoleteTime') Date obsoleteTime)



}