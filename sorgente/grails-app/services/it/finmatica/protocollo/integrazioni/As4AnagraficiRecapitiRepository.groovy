package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.as4.anagrafica.As4Anagrafica
import it.finmatica.as4.anagrafica.As4Recapito
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

@CompileStatic
interface As4AnagraficiRecapitiRepository extends JpaRepository<As4AnagrificiRecapiti,Long> {
    As4AnagrificiRecapiti findFirstByIdSoggettoAndIdRecapito(Long idSoggetto, Long idRecapito)
    As4AnagrificiRecapiti findFirstByIdSoggettoAndIdRecapitoAndIdContatto(Long idSoggetto, Long idRecapito, Long idContatto)

    @Query('''SELECT ana FROM As4Anagrafica ana WHERE ana.codFiscale = :cfOrPiva OR ana.partitaIva = :cfOrPiva''')
    List<As4Anagrafica> findAnagraficaByCFOrPIVA(@Param('cfOrPiva') String cfOrPiva)

    @Query('''SELECT rec FROM As4Recapito rec JOIN FETCH rec.tipoRecapito tpRec JOIN FETCH rec.provincia prov JOIN FETCH rec.comune comune JOIN FETCH rec.stato stato WHERE rec.ni = :ni AND tpRec.descrizione = 'RESIDENZA'
      AND (rec.al IS NULL OR rec.al > :now)''')
    List<As4Recapito> findIndirizzoDiResidenzaByNi(@Param('ni') Long ni, @Param('now') Date now)
}