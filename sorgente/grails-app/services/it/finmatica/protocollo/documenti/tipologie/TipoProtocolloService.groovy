package it.finmatica.protocollo.documenti.tipologie

import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenza
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenzaDTO
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoModello
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoModelloDTO
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenza
import it.finmatica.gestionetesti.reporter.GestioneTestiModelloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.converters.MovimentoConverter
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.hibernate.FetchMode
import org.hibernate.SessionFactory
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

@Transactional
@Service
class TipoProtocolloService {

    @Autowired
    DataSource dataSource
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    TipoProtocolloRepository tipoProtocolloRepository
    @Autowired
    SessionFactory sessionFactory

    TipoProtocolloDTO salva(TipoProtocolloDTO tipoProtocolloDTO) {
        if (!(tipoProtocolloDTO.categoria?.trim()?.length() > 0)) {
            throw new ProtocolloRuntimeException("Per salvare un tipo di protocollo è necessario selezionare la Categoria")
        }

        TipoProtocollo tipoProtocollo = tipoProtocolloDTO.getDomainObject() ?: new TipoProtocollo()

        if (!tipoProtocolloDTO.valido && tipoProtocolloDTO.predefinito) {
            throw new ProtocolloRuntimeException("Non è possibile cancellare il tipo di protocollo perchè è predefinito")
        }

        tipoProtocollo.valido = tipoProtocolloDTO.valido
        tipoProtocollo.codice = tipoProtocolloDTO.codice
        tipoProtocollo.acronimo = tipoProtocolloDTO.acronimo
        tipoProtocollo.descrizione = tipoProtocolloDTO.descrizione
        tipoProtocollo.commento = tipoProtocolloDTO.commento

        tipoProtocollo.conservazioneSostitutiva = tipoProtocolloDTO.conservazioneSostitutiva
        tipoProtocollo.funzionarioObbligatorio = tipoProtocolloDTO.funzionarioObbligatorio
        tipoProtocollo.firmatarioObbligatorio = tipoProtocolloDTO.firmatarioObbligatorio
        tipoProtocollo.funzionarioVisibile = tipoProtocolloDTO.funzionarioVisibile
        tipoProtocollo.firmatarioVisibile = tipoProtocolloDTO.firmatarioVisibile
        tipoProtocollo.testoObbligatorio = tipoProtocolloDTO.testoObbligatorio

        tipoProtocollo.progressivoCfgIter = tipoProtocolloDTO.progressivoCfgIter
        tipoProtocollo.tipoRegistro = tipoProtocolloDTO.tipoRegistro?.domainObject
        tipoProtocollo.schemaProtocollo = tipoProtocolloDTO.schemaProtocollo?.domainObject
        tipoProtocollo.tipologiaSoggetto = tipoProtocolloDTO.tipologiaSoggetto?.domainObject
        tipoProtocollo.modelliAssociati = tipoProtocolloDTO?.domainObject?.modelliAssociati
        tipoProtocollo.categoria = tipoProtocolloDTO?.categoria
        tipoProtocollo.movimento = tipoProtocolloDTO?.movimento

        boolean predefinito = tipoProtocolloDTO?.predefinito
        // se sto cambiando il predefinito cerco se ne esiste già uno
        if (predefinito) {
            TipoProtocollo predef = getPredefinitoPerCategoria(tipoProtocolloDTO.categoria)
            if (predef && predef.id != tipoProtocollo.id) {
                throw new ProtocolloRuntimeException("Esiste già un predefinito per la categoria scelta: " + predef.descrizione)
            }
        }
        tipoProtocollo.predefinito = predefinito

        tipoProtocollo.ruoloUoDestinataria = tipoProtocolloDTO.ruoloUoDestinataria?.domainObject
        tipoProtocollo.unitaDestinataria = tipoProtocolloDTO.unitaDestinataria?.domainObject

        if (tipoProtocollo.id != null && tipoProtocollo.valido &&
                tipoProtocollo.categoriaProtocollo.modelloTestoObbligatorio &&
                !isModelloPredefinitoPresente(tipoProtocollo, FileDocumento.CODICE_FILE_PRINCIPALE)) {
            throw new ProtocolloRuntimeException("È necessario specificare un modello predefinito")
        }

        if (tipoProtocollo.id != null) {
            // la "save" su una vista fa scattare il trigger di update su gdm.
            tipoProtocollo.save()
        } else {
            tipoProtocollo.id = insert(tipoProtocollo)
            new TipoDocumentoCompetenza(ruoloAd4: Ad4Ruolo.get(ImpostazioniProtocollo.RUOLO_ACCESSO_APPLICATIVO.valore)
                    , descrizione: "Visibile a Tutti"
                    , tipoDocumento: tipoProtocollo
                    , lettura: true).save()
        }

        return tipoProtocollo.toDTO()
    }

    TipoProtocollo getPredefinitoPerCategoria(String categoria) {
        return TipoProtocollo.findByPredefinitoAndCategoria(true, categoria)
    }

    private boolean isModelloPredefinitoPresente(TipoProtocollo tipoProtocollo, String codiceModello) {
        for (TipoDocumentoModello tipoDocumentoModello : tipoProtocollo.modelliAssociati) {
            if (tipoDocumentoModello.predefinito && tipoDocumentoModello.codice == codiceModello) {
                return true
            }
        }

        return false
    }

    void eliminaTipoProtocollo(TipoProtocolloDTO tipoProtocolloDto) {
        if (tipoProtocolloDto.predefinito) {
            throw new ProtocolloRuntimeException("Non è possibile cancellare il tipo di protocollo perchè è predefinito")
        }
        TipoProtocollo tipoProtocollo = tipoProtocolloDto.getDomainObject()
        tipoProtocollo.delete(failOnError: true, flush: true)
    }

    void eliminaModelloTesto(TipoDocumentoModelloDTO tipoDocumentoModelliDTO) {
        tipoDocumentoModelliDTO.domainObject.delete()
    }

    TipoDocumentoCompetenzaDTO salva(TipoDocumentoCompetenzaDTO tipoDocumentoCompetenzaDto) {
        TipoDocumentoCompetenza tipoDocumentoCompetenza = new TipoDocumentoCompetenza()
        tipoDocumentoCompetenza.utenteAd4 = tipoDocumentoCompetenzaDto?.utenteAd4?.getDomainObject()
        tipoDocumentoCompetenza.ruoloAd4 = tipoDocumentoCompetenzaDto?.ruoloAd4?.getDomainObject()
        tipoDocumentoCompetenza.unitaSo4 = tipoDocumentoCompetenzaDto?.unitaSo4?.getDomainObject()
        tipoDocumentoCompetenza.tipoDocumento = tipoDocumentoCompetenzaDto.tipoDocumento.getDomainObject()
        tipoDocumentoCompetenza.descrizione = tipoDocumentoCompetenzaDto.descrizione
        tipoDocumentoCompetenza.lettura = tipoDocumentoCompetenzaDto.lettura
        tipoDocumentoCompetenza = tipoDocumentoCompetenza.save()
        return tipoDocumentoCompetenza.toDTO()
    }

    void elimina(TipoDocumentoCompetenzaDTO tipoDocumentoCompetenzaDto) {
        tipoDocumentoCompetenzaDto?.domainObject?.delete(failOnError: true)
    }

    void aggiungiModelloTesto(TipoDocumentoModelloDTO tipoDocumentoModelliDTO) {
        TipoDocumentoModello tipoDocumentoModelli = new TipoDocumentoModello()
        tipoDocumentoModelli.tipoDocumento = tipoDocumentoModelliDTO.tipoDocumento.domainObject
        tipoDocumentoModelli.predefinito = tipoDocumentoModelliDTO.predefinito
        tipoDocumentoModelli.codice = tipoDocumentoModelliDTO.codice
        tipoDocumentoModelli.modelloTesto = tipoDocumentoModelliDTO.modelloTesto.domainObject
        tipoDocumentoModelli.save()
    }

    TipoProtocolloDTO duplica(TipoProtocolloDTO tipoProtocolloDTO) {
        tipoProtocolloDTO.id = -1
        tipoProtocolloDTO.version = 0
        tipoProtocolloDTO.codice += " (duplica)"
        tipoProtocolloDTO.acronimo += " (duplica)"
        tipoProtocolloDTO.predefinito = false
        TipoProtocollo duplica = salva(tipoProtocolloDTO).domainObject
        return duplica.toDTO()
    }

    /**
     sql: AGP_TIPI_PROTOCOLLO_PKG.ins(p_ID_ENTE NUMBER,
     p_DESCRIZIONE                  VARCHAR2,
     p_COMMENTO                     VARCHAR2,
     p_CONSERVAZIONE_SOSTITUTIVA    VARCHAR2,
     p_PROGRESSIVO_CFG_ITER         NUMBER,
     p_TESTO_OBBLIGATORIO           VARCHAR2,
     p_ID_TIPOLOGIA_SOGGETTO        NUMBER,
     p_VALIDO                       VARCHAR2,
     p_UTENTE_INS                   VARCHAR2,
     p_DATA_INS                     DATE,
     p_CODICE                       VARCHAR2,
     p_ACRONIMO                     VARCHAR2,
     P_FUNZ_OBBLIGATORIO            VARCHAR2,
     P_FIRM_OBBLIGATORIO            VARCHAR2,
     P_ID_TIPO_REGISTRO             NUMBER,
     P_CATEGORIA                    VARCHAR2,
     P_MOVIMENTO                    VARCHAR2)
     RETURN NUMBER;
     *
     */
    private Long insert(TipoProtocollo tipoProtocollo) {
        tipoProtocollo.save()
        return tipoProtocollo.id
        /*
        try {
            Sql sql = new Sql(dataSource)
            Long id

            // siccome faccio un lavoro "a mano", devo far scattare gli eventi @PrePersist e @PreUpdate di
            tipoProtocollo.beforeInsert()
            tipoProtocollo.utenteUpd = springSecurityService.currentUser
            tipoProtocollo.utenteIns = springSecurityService.currentUser
            tipoProtocollo.dateCreated = new Date()
            tipoProtocollo.lastUpdated = new Date()

            def param = [Sql.NUMERIC,
                         tipoProtocollo.ente.id,
                         tipoProtocollo.descrizione,
                         tipoProtocollo.commento,
                         BooleanConverter.Y_N.newInstance().convert(tipoProtocollo.conservazioneSostitutiva),
                         null,
                         BooleanConverter.Y_N.newInstance().convert(tipoProtocollo.testoObbligatorio),
                         tipoProtocollo.tipologiaSoggetto.id,
                         BooleanConverter.Y_N.newInstance().convert(tipoProtocollo.valido),
                         tipoProtocollo.utenteIns.id,
                         tipoProtocollo.dateCreated,
                         tipoProtocollo.codice,
                         tipoProtocollo.acronimo,
                         BooleanConverter.Y_N.newInstance().convert(tipoProtocollo.funzionarioObbligatorio),
                         tipoProtocollo.tipoRegistro?.id,
                         tipoProtocollo.categoria,
                         tipoProtocollo.unitaDestinataria?.progr,
                         tipoProtocollo.unitaDestinataria?.dal,
                         tipoProtocollo.unitaDestinataria?.ottica?.id,
                         tipoProtocollo.ruoloUoDestinataria?.id,
                         tipoProtocollo.movimento]

            sql.call("""BEGIN 
                          ? := AGP_TIPI_PROTOCOLLO_PKG.ins (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?, ?, ?, ? ,?);
                        END; """,
                    param) { row ->
                id = row
            }

            return id
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
         */
    }

    List<TipoProtocolloDTO> tipologiePerCompetenza(String categoria) {
        So4UserDetail utente = springSecurityService.principal
        List<TipoProtocollo> listaTipologieD = TipoProtocollo.createCriteria().list() {
            createAlias("schemaProtocollo", "sp", CriteriaSpecification.LEFT_JOIN)

            eq("categoria", categoria)
            eq("valido", true)
            or {
                isNull("schemaProtocollo")
                eq("sp.risposta", false)
            }

            fetchMode("tipologiaSoggetto", FetchMode.JOIN)
            order("descrizione", "asc")
        }

        List<TipoProtocolloDTO> listaTipologie = []
        for (TipoProtocollo tp : listaTipologieD) {
            if (TipoDocumentoCompetenza.canRead(tp, utente)?.count() > 0) {
                if (gestoreCompetenze.controllaPrivilegio(tp.getCategoriaProtocollo().privilegioCreazione)) {
                    if (tp.movimento == null) {
                        listaTipologie.add(tp.toDTO())
                    } else if (gestoreCompetenze.controllaPrivilegio(MovimentoConverter.INSTANCE.convert(tp.movimento))) {
                        listaTipologie.add(tp.toDTO())
                    }
                }
            }
        }

        return listaTipologie
    }

    List<Long> listaModelliTesto(Long idTipoProtocollo) {

        if (idTipoProtocollo == null) {
            return []
        }

        return TipoProtocollo.createCriteria().list {
            projections {
                modelliAssociati {
                    property("modelloTesto.id")
                }
            }

            eq("id", idTipoProtocollo)
            modelliAssociati {
                eq("codice", FileDocumento.CODICE_FILE_PRINCIPALE)
            }
        }
    }

    List<GestioneTestiModelloDTO> listaModelliTestoConCompetenza(TipoProtocolloDTO tipoProtocollo, So4UnitaPubbDTO unitaProtocollante) {
        So4UserDetail utente = springSecurityService.principal

        if (!tipoProtocollo) {
            return []
        }

        List<Long> listaIdModelliTesto = listaModelliTesto(tipoProtocollo.id)

        if (listaIdModelliTesto.size() <= 0) {
            return []
        }

        if (Utils.isUtenteAmministratore()) {
            return TipoProtocollo.modelliTesto(tipoProtocollo?.id ?: -1, FileDocumento.CODICE_FILE_PRINCIPALE).list().toDTO()
        }

        return GestioneTestiModelloCompetenza.createCriteria().list {
            projections {
                gestioneTestiModello {
                    property("id")
                    property("nome")
                    property("descrizione")
                }
            }
            gestioneTestiModello {
                'in'("id", listaIdModelliTesto)
                eq("valido", true)
            }

            if(unitaProtocollante){
                or {
                    eq("unitaSo4", unitaProtocollante.domainObject)
                    isNull("unitaSo4")
                }
            }
            ProtocolloGestoreCompetenze.controllaCompetenze(delegate)(utente)
        }.collect {
            row -> new GestioneTestiModelloDTO(id: row[0], nome: row[1], descrizione: row[2])
        }.sort{it1,it2 -> it1.nome <=> it2.nome ?: it1.descrizione <=> it2.descrizione }
    }

    /**
     * Ritorna la lista di tipi protocollo valida senza schema protocollo associato e con iter
     *
     * @return
     */
    public List<TipoProtocollo> findAllByValidoAndSchemaProtocolloAndProgressivoCfgIterIsNotNull() {
        return tipoProtocolloRepository.findAllByValidoAndSchemaProtocolloAndProgressivoCfgIterIsNotNull() ?: new ArrayList<TipoProtocollo>()
    }

    TipoProtocollo findByIdConSoggetti(Long id) {

        sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        TipoProtocollo t = TipoProtocollo.findById(id, [fetch: [
                tipologiaSoggetto: 'eager']])
        sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        return t
    }

}
