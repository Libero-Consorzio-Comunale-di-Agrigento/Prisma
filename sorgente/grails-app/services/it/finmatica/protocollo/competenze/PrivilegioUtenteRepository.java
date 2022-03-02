package it.finmatica.protocollo.competenze;

import it.finmatica.ad4.autenticazione.Ad4Utente;
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente;
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb;
import java.util.Date;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PrivilegioUtenteRepository extends JpaRepository<PrivilegioUtente, Long> {

    /**
     * Ritorna tutti i privilegi di un utente dato lo user e l'unità (quest'ultima non obbligatoria)
     */
    @Query("select pv "
        + "   from PrivilegioUtente pv "
        + "  where pv.privilegio = :privilegio "
        + "    and pv.utente =:utente "
        + "    and ( (pv.codiceUnita = :codiceUnita and :codiceUnita is not null) "
        + "     or ( :codiceUnita is null ) ) "
        + "    and (pv.al is null or pv.al >= CURRENT_DATE ) "
        + "  order by pv.privilegio asc")
    List<PrivilegioUtente> getPrivilegi(@Param("utente") Ad4Utente utente,
        @Param("privilegio") String privilegio,
        @Param("codiceUnita") String codiceUnita);

    /**
     * Ritorna tutti i privilegi (a data) di un utente dato lo user e l'unità (non obbligatoria) e la data
     */
    @Query("select pv "
        + "   from PrivilegioUtente pv "
        + "  where pv.privilegio = :privilegio "
        + "    and pv.utente =:utente "
        + "    and ( (pv.codiceUnita = :codiceUnita and :codiceUnita is not null) "
        + "     or ( :codiceUnita is null ) ) "
        + "    and (pv.al is null or pv.al >= :dataAl ) "
        + "  order by pv.privilegio asc")
    List<PrivilegioUtente> getPrivilegi(@Param("utente") Ad4Utente utente,
        @Param("privilegio") String privilegio,
        @Param("codiceUnita") String codiceUnita,
        @Param("dataAl") Date dataAl);

    @Query("select unit "
        + "   from PrivilegioUtente pv, So4UnitaPubb unit"
        + "  where pv.privilegio = :privilegio "
        + "    and pv.utente =:utente "
        + "    and pv.progrUnita = unit.progr "
        + "    and (:soloAperte = FALSE or (:soloAperte = TRUE AND (unit.al IS NULL OR unit.al >= CURRENT_DATE))) "
        + "    and coalesce(pv.al,CURRENT_DATE) >= CURRENT_DATE "
        + "  order by  CASE WHEN (pv.appartenenza = 'D') THEN 1 ELSE 2 END , unit.descrizione"
    )
    List<So4UnitaPubb> getUnitaPerPrivilegi(@Param("utente") Ad4Utente utente,
        @Param("privilegio") String privilegio,
        @Param("soloAperte") boolean soloAperte);

    @Query("select distinct unit "
            + "   from PrivilegioUtente pv, So4UnitaPubb unit"
            + "  where pv.privilegio = :privilegio "
            + "    and pv.utente =:utente "
            + "    and pv.appartenenza ='D' "
            + "    and pv.progrUnita = unit.progr "
            + "    AND unit.dal <= CURRENT_DATE"
            + "    AND (unit.al IS NULL OR unit.al >= CURRENT_DATE)"
            + "    and coalesce(pv.al,CURRENT_DATE) >= CURRENT_DATE "
            + "    and ( ( upper(unit.descrizione) like upper(:filtro) )  or ( upper(unit.codice) like upper(:filtro)) ) "
            + "  order by unit.descrizione"
    )
    List<So4UnitaPubb> listUnitaPerPrivilegiDiretti(@Param("utente") Ad4Utente utente,
                                                    @Param("privilegio") String privilegio,
                                                    @Param("filtro") String filtro);

    @Query("select distinct unit "
            + "   from PrivilegioUtente pv, So4UnitaPubb unit"
            + "  where pv.privilegio = :privilegio "
            + "    and pv.utente =:utente "
            + "    and pv.appartenenza ='E' "
            + "    and pv.progrUnita = unit.progr "
            + "    AND unit.dal <= CURRENT_DATE"
            + "    AND (unit.al IS NULL OR unit.al >= CURRENT_DATE)"
            + "    and coalesce(pv.al,CURRENT_DATE) >= CURRENT_DATE "
            + "    and ( ( upper(unit.descrizione) like upper(:filtro) )  or ( upper(unit.codice) like upper(:filtro)) ) "
            + "  order by unit.descrizione"
    )
    List<So4UnitaPubb> listUnitaPrivilegiEstesi(@Param("utente") Ad4Utente utente,
                                                @Param("privilegio") String privilegio,
                                                @Param("filtro") String filtro);

    @Query("select distinct unit "
            + "   from PrivilegioUtente pv, So4UnitaPubb unit"
            + "  where pv.utente =:utente "
            + "    and pv.appartenenza ='D' "
            + "    and pv.progrUnita = unit.progr "
            + "    AND unit.dal <= CURRENT_DATE"
            + "    AND (unit.al IS NULL OR unit.al >= CURRENT_DATE)"
            + "    and coalesce(pv.al,CURRENT_DATE) >= CURRENT_DATE "
            + "  order by unit.descrizione"
    )
    List<So4UnitaPubb> listUnitaConPrivilegiDiretti(@Param("utente") Ad4Utente utente);


    /**
     * Ritorna tutti gli utenti che hanno un determinato privilegio (e unità se specificato)
     */
    @Query("select pv.utente "
        + "   from PrivilegioUtente pv "
        + "  where pv.privilegio = :privilegio "
        + "    and (pv.codiceUnita = :codiceUnita or :codiceUnita is null) "
        + "    and coalesce(pv.al,CURRENT_DATE) >= CURRENT_DATE "
    )
    List<Ad4Utente> getUtentiPerPrivilegi(@Param("privilegio") String privilegio,
        @Param("codiceUnita") String codiceUnita);

    /**
     * Ritorna tutti i privilegi di un utente dato lo user e l'unità (quest'ultima non obbligatoria)
     */
    @Query("select pv "
        + "   from PrivilegioUtente pv "
        + "  where pv.utente =:utente "
        + "    and ( (pv.codiceUnita = :codiceUnita and :codiceUnita is not null) "
        + "     or ( :codiceUnita is null ) ) "
        + "    and (pv.al is null or pv.al >= CURRENT_DATE ) "
        + "  order by pv.privilegio asc")
    List<PrivilegioUtente> getAllPrivilegi(@Param("utente") Ad4Utente utente,
        @Param("codiceUnita") String codiceUnita);
}
