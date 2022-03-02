package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Ente
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface RegistroGiornalieroRepository extends JpaRepository<RegistroGiornaliero,Long> {

    @Query(value='''select * from (
                  select (select u.nominativo_soggetto
                          from AD4_V_UTENTI u
                          where u.UTENTE = nvl(pc.utente_upd,
                                               nvl(af.UTENTE_UPD, nvl(da.UTENTE_UPD, pd.UTENTE_UPD)))) utenteModifica
                       , (select r.revtstmp
                          from revinfo r
                          where r.rev = nvl(pc.rev, nvl(af.rev, nvl(da.rev, pd.rev))))                 dataModifica
                       , (select r.revtstmp from revinfo r where r.rev = a.rev)                        allDataModifica
                       , (select r.revtstmp from revinfo r where r.rev = pc.rev)                       corrDataModifica
                       , p.oggetto                                                                     protOggetto
                       , p.oggetto_mod                                                                 protOggettoMod
                       , (SELECT agplogg.OGGETTO
                            FROM (SELECT rev, OGGETTO
                                  FROM agp_protocolli_log
                                  WHERE ID_DOCUMENTO = :idDocumento
                                  ORDER BY REV DESC) agplogg
                            WHERE ROWNUM = 1 AND agplogg.REV < p.REV)                                  oggettoOld
                       , mi.CODICE || mi.DESCRIZIONE                                                   modalitaInvio
                       , p.MODALITA_INVIO_RICEZIONE_MOD                                                modalitaInvioMod
                       , (SELECT agplint.modalita
                            FROM (SELECT agpl.rev, miOld.CODICE || miOld.DESCRIZIONE modalita
                                  FROM agp_protocolli_log agpl,
                                  ags_modalita_invio_ricezione miOld
                                  WHERE  agpl.ID_MODALITA_INVIO_RICEZIONE(+) = miOld.ID_MODALITA_INVIO_RICEZIONE
                                  AND agpl.ID_DOCUMENTO = :idDocumento
                                  ORDER BY agpl.REV DESC) agplint
                            WHERE ROWNUM = 1 AND agplint.REV < p.REV)                                  modalitaInvioOld
                       , a.DESCRIZIONE                                                                 allegatoDescrizione
                       , af.revtype                                                                    allegatoFileType
                       , af.nome                                                                       allegatoFile
                       , pc.REVTYPE                                                                    corrispondenteType
                       , pc.DENOMINAZIONE                                                              corrispondenteNome
                       , pc.INDIRIZZO                                                                  corrispondenteIndirizzo
                  from agp_protocolli_log p
                     , gdo_documenti_log pd
                     , gdo_documenti_collegati_log c
                     , gdo_allegati_log a
                     , gdo_documenti_log da
                     , gdo_file_documento_log af
                     , agp_protocolli_corr_log pc
                     , ags_modalita_invio_ricezione mi
                  where pd.id_documento = p.id_documento
                    and pd.rev = p.rev
                    and pc.ID_DOCUMENTO(+) = pd.ID_DOCUMENTO
                    and pc.rev(+) >= pd.rev
                    and pc.rev(+) < nvl(pd.revend, 99999999999)
                    and c.id_documento(+) = pd.id_documento
                    and c.rev(+) >= pd.rev
                    and c.rev(+) < nvl(pd.revend, 99999999999)
                    and a.id_documento(+) = c.id_collegato
                    and a.rev(+) >= c.rev
                    and a.rev(+) < nvl(c.revend, 99999999999)
                    and da.id_documento(+) = a.id_documento
                    and da.rev(+) = a.rev
                    and af.id_documento(+) = da.id_documento
                    and mi.ID_MODALITA_INVIO_RICEZIONE(+) = p.ID_MODALITA_INVIO_RICEZIONE
                    and af.rev(+) >= da.rev
                    and af.rev(+) < nvl(da.revend, 99999999999)
                    and p.id_documento = :idDocumento
              )
WHERE dataModifica BETWEEN :dataDa AND :dataA
   OR allDataModifica BETWEEN :dataDa AND :dataA
   OR corrDataModifica BETWEEN :dataDa AND :dataA
order by dataModifica''' ,nativeQuery=true   )
    List<RegistroGiornalieroResult> trovaModificheRegistro(@Param('idDocumento') Long idDocumento, @Param('dataDa') Date dataDa, @Param('dataA') Date dataA)

    @Query('SELECT p FROM Protocollo p INNER JOIN FETCH p.registroGiornaliero reg  WHERE p.id = :idDocumento')
    Protocollo findByIdDocumento(@Param('idDocumento') Long idDocumento)

    @Query(value = '''select count(1)
    from agp_protocolli prot 
    where prot.data is not null
    and prot.numero is not null
    AND prot.TIPO_REGISTRO = :tipoRegistro
    and prot.id_documento in (select id_documento
    from agp_registro_modifiche
    where id_ente = :idEnte
    and data_upd BETWEEN :dataDa AND :dataA)
''', nativeQuery = true)
    int countModificheRegistro(@Param('dataDa') Date dataDa, @Param('dataA') Date dataA, @Param('tipoRegistro') String tipoRegistro,@Param('idEnte') Long idEnte)

    @Query(value = 'SELECT e FROM Ente e join e.amministrazione amm WHERE amm.codice = :codice')
    Ente findEnteByCodice(@Param('codice') String codice)

    @Query(value = 'SELECT e FROM Ente e JOIN FETCH e.amministrazione WHERE e.valido = true')
    List<Ente> findEntiValidi()


    @Query('SELECT reg FROM Protocollo protocollo JOIN protocollo.registroGiornaliero reg WHERE protocollo.ente.id = :idEnte AND protocollo.valido = true')
    List<RegistroGiornaliero> findByEnte(@Param('idEnte') Long idEnte, Pageable pageable)

    @Query('UPDATE Protocollo SET valido = false WHERE registroGiornaliero.id = :id')
    @Modifying
    void annullaProtocollo(@Param('id') Long id)

    @Query('SELECT p FROM Protocollo p INNER JOIN FETCH p.registroGiornaliero reg  INNER JOIN FETCH p.tipoProtocollo tp WHERE p.id = :idDocumento')
    Protocollo findByIdDocumentoWithTipoProtocollo(@Param('idDocumento') Long idDocumento)

    @Query('SELECT p FROM Protocollo p INNER JOIN FETCH p.registroGiornaliero reg  WHERE reg.id = :idRegistroGiornaliero')
    Protocollo findByIdRegistroGiornaliero(@Param('idRegistroGiornaliero') Long idRegistroGiornaliero)
}