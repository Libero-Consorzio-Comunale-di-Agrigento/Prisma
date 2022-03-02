package it.finmatica.protocollo.dizionari

import groovy.sql.Sql
import it.finmatica.ad4.dizionari.Ad4ComuneDTO
import it.finmatica.ad4.dizionari.Ad4ProvinciaDTO
import it.finmatica.as4.anagrafica.As4ContattoDTO
import it.finmatica.as4.anagrafica.As4RecapitoDTO
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.corrispondenti.Indirizzo
import it.finmatica.protocollo.corrispondenti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import oracle.jdbc.OracleTypes
import org.apache.commons.lang.StringUtils
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.SQLException

@Transactional
@Service
class ListaDistribuzioneService {

    @Autowired DataSource dataSource
    @Autowired SessionFactory sessionFactory

    ListaDistribuzioneDTO salva (ListaDistribuzioneDTO listaDistribuzioneDto) {

        try{

            ListaDistribuzione listaDistribuzione = ListaDistribuzione.get(listaDistribuzioneDto.id)

            String codice = listaDistribuzioneDto.codice?.toUpperCase()

            if(listaDistribuzione == null && ListaDistribuzione.findByCodice(codice)){
                throw new ProtocolloRuntimeException("il codice "+ codice +" è già stato censito")
            }

            if(listaDistribuzione == null){
                listaDistribuzione = new ListaDistribuzione()
                if(listaDistribuzione.id == null){
                    listaDistribuzione.id = 0
                }
            }

            listaDistribuzione.codice = codice
            listaDistribuzione.descrizione = listaDistribuzioneDto.descrizione?.toUpperCase()
            listaDistribuzione.valido = listaDistribuzioneDto.valido

            listaDistribuzione.save()
            listaDistribuzione = reloadFromDb(codice)

            return 	listaDistribuzione.toDTO(["componenti"])

        }catch (SQLException e){
            throw new ProtocolloRuntimeException(e)
        }
	}

    ListaDistribuzioneDTO aggiungiComponente (ListaDistribuzioneDTO lista, ComponenteListaDistribuzioneDTO componente) {

        try{

            // 1 contatto 2 recapiti

            ComponenteListaDistribuzione componenteNew = new ComponenteListaDistribuzione()

            for (ComponenteListaDistribuzioneDTO c : lista.componenti){

                if(componente.contatto != null && c.contatto != null && componente.contatto.id == c.contatto.id){

                    if(componente.recapito != null && c.recapito != null && componente.recapito.id == c.recapito.id){

                        throw new ProtocolloRuntimeException("Componente già presente nella Lista")
                    }
                }

                if(!StringUtils.isEmpty(componente.codiceAmministrazione)){

                    if(componente.denominazione == c.denominazione &&
                            componente.indirizzoCompleto?.replaceAll(" ", "").equals(c.indirizzoCompleto?.replaceAll(" ", "")) &&
                            (componente.email?:"").equals(c.email?:""))
                    {
                        throw new ProtocolloRuntimeException("Componente già presente nella Lista")
                    }
                }
            }

            componenteNew.uo                    = componente.uo
            componenteNew.aoo                   = componente.aoo
            componenteNew.codiceAmministrazione = componente.codiceAmministrazione
            componenteNew.ni                    = componente.ni
            componenteNew.recapito              = componente.recapito?.domainObject
            componenteNew.contatto              = componente.contatto?.domainObject


            componenteNew.cap                   = componente.cap
            componenteNew.codiceFiscale         = componente.codiceFiscale
            componenteNew.comune                = componente.comune
            componenteNew.email                 = componente.email
            componenteNew.fax                   = componente.fax
            componenteNew.indirizzo             = componente.indirizzo
            componenteNew.provinciaSigla        = componente.provinciaSigla
            componenteNew.partitaIva            = componente.partitaIva
            componenteNew.denominazione         = componente.denominazione
            componenteNew.cognome               = componente.cognome
            componenteNew.nome                  = componente.nome

            ListaDistribuzione l =  ListaDistribuzione.get(lista.id)

            componenteNew.listaDistribuzione = l

            if(componenteNew.id == null){
                componenteNew.id = 0
            }

            componenteNew.save()

            return l.toDTO()

        }catch (SQLException e){
            throw new ProtocolloRuntimeException(e)
        }
    }

    ListaDistribuzioneDTO rimuoviComponente (ListaDistribuzioneDTO lista, ComponenteListaDistribuzioneDTO componente) {

        try {

            ComponenteListaDistribuzione comp = ComponenteListaDistribuzione.get(componente.id)
            ListaDistribuzione l = ListaDistribuzione.get(lista.id)
            l.removeFromComponenti(comp)
            comp.delete(failOnError: true)
            return l.save(failOnError: true)?.toDTO(["componenti"])

        }catch (SQLException e){
            throw new ProtocolloRuntimeException(e)
        }
    }

    void elimina (ListaDistribuzioneDTO listaDistribuzioneDto) {

        try {

            ListaDistribuzione listaDistribuzione = ListaDistribuzione.get(listaDistribuzioneDto.id)
            /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
            if (listaDistribuzione.version != listaDistribuzioneDto.version) throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
            listaDistribuzione.delete(failOnError: true)

        }catch (SQLException e){
            throw new ProtocolloRuntimeException(e)
        }
	}
    
    ListaDistribuzioneDTO duplica (ListaDistribuzioneDTO listaDistribuzioneDTO) {

        listaDistribuzioneDTO.version = 0
        listaDistribuzioneDTO.codice += " (duplica)"
        ListaDistribuzione duplica = salva(listaDistribuzioneDTO, null).domainObject
        return duplica.toDTO()
    }

    /*
     * sql: SELECT SEG_ANAGRAFICI_PKG.ricerca_anagrafici_base ( 'ROSSI', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL )
     * 	   FROM DUAL
     *
     */
    List<ComponenteListaDistribuzioneDTO> ricercaComponenti(String ricerca,
                                              boolean isQuery,
                                              String denominazione = null,
                                              String indirizzo = null,
                                              String codiceFiscale = null,
                                              String partitaIva = null,
                                              String email = null,
                                              Date dal = null,
                                              TipoSoggettoDTO tipoSoggetto = null) {

        try {

            Sql sql = new groovy.sql.Sql(dataSource)
            List<ComponenteListaDistribuzioneDTO> resultList = []
            ComponenteListaDistribuzioneDTO componente

            String isQueryS = isQuery ? "Y" : "N"

            sql.call("""BEGIN 
					  ? := SEG_ANAGRAFICI_PKG.ricerca_anagrafici_base (?, ?, ?, ?, ?, ?, ?, ?, ?);
					END; """,
                    [Sql.resultSet(OracleTypes.CURSOR), ricerca, isQueryS, denominazione, indirizzo, codiceFiscale, partitaIva, email, dal, tipoSoggetto?.id]) {
                cursorResults ->
                    cursorResults.eachRow { result ->

                        componente = buildComponente(result)

                        resultList << componente
                    }
            }
            return resultList

        }catch (SQLException e){
            throw new ProtocolloRuntimeException(e)
        }
    }

    private ComponenteListaDistribuzioneDTO buildComponente(componente) {

        ComponenteListaDistribuzioneDTO componenteDTO = new ComponenteListaDistribuzioneDTO()

        // utili per il dettaglio delle Amministrazioni
        componenteDTO.codiceAmministrazione = componente.getAt('COD_AMM')?.toUpperCase()
        componenteDTO.aoo = componente.getAt('COD_AOO')?.toUpperCase()
        componenteDTO.uo = componente.getAt('COD_UO')?.toUpperCase()

        componenteDTO.ni = componente.getAt('NI')

        componenteDTO.tipoSoggetto = TipoSoggetto.get(componente.getAt('TIPO_SOGGETTO')).toDTO()
        componenteDTO.denominazione = componente.getAt('DENOMINAZIONE')?.toUpperCase()
        componenteDTO.indirizzo = componente.getAt('INDIRIZZO')?.toUpperCase()
        componenteDTO.email = componente.getAt('EMAIL')?.toUpperCase()
        componenteDTO.partitaIva = componente.getAt('PARTITA_IVA')?.toUpperCase()
        componenteDTO.codiceFiscale = componente.getAt('CODICE_FISCALE')?.toUpperCase()
        componenteDTO.cap = componente.getAt('CAP')?.toUpperCase()
        componenteDTO.provinciaSigla = componente.getAt('PROVINCIA_SIGLA')?.toUpperCase()
        componenteDTO.comune = componente.getAt('COMUNE')?.toUpperCase()
        componenteDTO.fax = componente.getAt('FAX')?.toUpperCase()
        componenteDTO.cognome = componente.getAt('COGNOME')?.toUpperCase()
        componenteDTO.nome = componente.getAt('NOME')?.toUpperCase()

        String recapito = componente.getAt('ID_RECAPITO')
        if(recapito != null && recapito != "")
            componenteDTO.recapito = new As4RecapitoDTO(id: Long.valueOf(recapito))
        String contatto = componente.getAt('ID_CONTATTO')
        if(contatto != null && contatto != "")
            componenteDTO.contatto = new As4ContattoDTO(id: Long.valueOf(contatto))

        // da usare per comporre l'immagine
        componenteDTO.anagrafica = componente.getAt('ANAGRAFICA')?.toUpperCase()
        componenteDTO.tipoIndirizzo = componente.getAt('TIPO_INDIRIZZO')

        return componenteDTO
    }

    As4RecapitoDTO getRecapitoAmministrazione(String codiceAmministrazione,
                                              String aoo,
                                              String uo) {

        try{

            Sql sql = new groovy.sql.Sql(dataSource)

            String tipoIndirizzo = Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE
            if(!StringUtils.isEmpty(aoo)){
                tipoIndirizzo = Indirizzo.TIPO_INDIRIZZO_AOO
            }
            if(!StringUtils.isEmpty(uo)){
                tipoIndirizzo = Indirizzo.TIPO_INDIRIZZO_UO
            }

            As4RecapitoDTO recapito = null

            sql.call("""BEGIN 
                          ? := SEG_ANAGRAFICI_PKG.GET_INDIRIZZI_AMM (?, ?, ?);
                        END; """,
                    [Sql.resultSet(OracleTypes.CURSOR), codiceAmministrazione, aoo, uo]) {
                cursorResults ->
                    cursorResults.eachRow{ result ->

                        if(tipoIndirizzo == result.getAt('TIPO_INDIRIZZO')){
                            recapito = new As4RecapitoDTO()

                            recapito.indirizzo 	    = result.getAt('INDIRIZZO')?.toUpperCase()
                            recapito.cap            = result.getAt('CAP')?.toUpperCase()

                            recapito.comune 		= new Ad4ComuneDTO(denominazione:result.getAt('COMUNE')?.toUpperCase())
                            recapito.provincia      = new Ad4ProvinciaDTO(sigla:result.getAt('PROVINCIA_SIGLA')?.toUpperCase())
                        }
                    }
            }

            return recapito

        }catch (SQLException e){
            throw new ProtocolloRuntimeException(e)
        }
    }

    PagedResultList list(int pageSize, int activePage, String filterCondition, boolean visualizzaTutti) {
        if(visualizzaTutti) {
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        }
        try {
            PagedResultList listaP = ListaDistribuzione.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
                if (!visualizzaTutti) {
                    eq("valido", true)
                }
                if (filterCondition ?: "" != "") ilike("descrizione", "%${filterCondition}%")
                order("codice", "asc")
            }
            return listaP
        } finally {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }
    }

    private ListaDistribuzione reloadFromDb(String codice) {
        ListaDistribuzione listaDistribuzione = null
        sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        try {
            listaDistribuzione = ListaDistribuzione.findByCodice(codice)
        } finally {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }
        return listaDistribuzione
    }
}
