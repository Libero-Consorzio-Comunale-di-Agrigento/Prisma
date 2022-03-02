package it.finmatica.protocollo.titolario

import com.opencsv.CSVReader
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.ClassificazioneNumero
import it.finmatica.protocollo.dizionari.ClassificazioneNumeroDTO
import it.finmatica.protocollo.dizionari.ClassificazioneUnita
import it.finmatica.protocollo.dizionari.ClassificazioneUnitaDTO
import it.finmatica.protocollo.dizionari.ErroreCsv
import it.finmatica.protocollo.dizionari.FiltroDataClassificazioni
import it.finmatica.protocollo.dizionari.ImportazioneCSVException
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ad4.Ad4Repository
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang3.tuple.Pair
import org.hibernate.FetchMode
import org.hibernate.criterion.CriteriaSpecification
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.persistence.EntityManager
import javax.persistence.TypedQuery
import java.text.SimpleDateFormat

@Transactional
@Service
class ClassificazioneService {
    private static final Logger log = LoggerFactory.getLogger(ClassificazioneService)

    @Autowired
    ClassificazioneRepository classificazioneRepository

    @Autowired
    Ad4Repository ad4Repository

    @Autowired
    ClassificazioneUnitaRepository classificazioneUnitaRepository
    @Autowired
    ClassificazioneNumeroRepository classificazioneNumeroRepository
    @Autowired
    ProtocolloPkgService protocolloPkgService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    EntityManager entityManager

    ClassificazioneDTO salva(ClassificazioneDTO classificazioneDto) {
        boolean nuovo = false

        Classificazione classificazione = Classificazione.get(classificazioneDto.id)

        if (Classificazione.findByCodice(classificazioneDto.codice) && classificazione == null) {
            throw new ProtocolloRuntimeException("il codice " + classificazioneDto.codice + " è già stato censito")
        }

        if (classificazione == null) {
            classificazione = new Classificazione()
            nuovo = true
        }

        duplicaProprieta(classificazione, classificazioneDto)

        classificazione = classificazione.save()
        if (nuovo) {
            // associazione di default all'ente, eventualmente modificabile in seguito
            creaUnitaEnteDefault(classificazione)
            salvaNumero(classificazione)
        } else {
            // TODO eventuale aggiornamento
        }

        return classificazione.toDTO()
    }

    private void creaUnitaEnteDefault(Classificazione classificazione) {
        ClassificazioneUnita cu = new ClassificazioneUnita()
        cu.classificazione = classificazione
        cu.ente = classificazione.ente
        cu.save()
    }

    @Transactional(readOnly = true)
    boolean isEliminabile(ClassificazioneDTO classificazione) {
        int presenzaDocumenti = 0
        if (classificazione?.idDocumentoEsterno) {
            it.finmatica.smartdoc.api.struct.Documento documentoSmartClassifica = protocolloGdmService.buildDocumentoSmart(classificazione?.idDocumentoEsterno, false, true, true)
            presenzaDocumenti = documentoSmartClassifica.documentiFigli.findAll {
                it.isFoglia()
            }.size()
            if (documentoSmartClassifica && presenzaDocumenti == 0) {
                return true
            }
        }

        return false
    }

    void elimina(ClassificazioneDTO classificazioneDto) {
        Classificazione classificazione = Classificazione.get(classificazioneDto.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (classificazione.version != classificazioneDto.version) {
            throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        classificazione.delete(failOnError: true)
    }

    ClassificazioneDTO duplica(ClassificazioneDTO classificazioneDto) {

        classificazioneDto.version = 0
        classificazioneDto.codice += " (duplica)"
        Classificazione duplica = salva(classificazioneDto)
        return duplica.toDTO()
    }

    Pair<Integer, List<ClassificazioneDTO>> list(int pageSize, int activePage, boolean visualizzaTutti, String filterCondition, boolean conDescrizioni = false, FiltroDataClassificazioni filtroData = FiltroDataClassificazioni.VIS_TUTTE, Date dataValiditaTitolario, Date dataAperturaInizio, Date dataAperturaFine, Date dataCreazioneInizio, Date dataCreazioneFine, Date dataChiusuraInizio, Date dataChiusuraFine, String codiceClassifica, String descrizioneClassifica, String usoClassifica, boolean daRicerca) {
        PagedResultList<Classificazione> lista = Classificazione.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
            Date now = new Date()
            now.clearTime()
            if (!visualizzaTutti) {
                eq("valido", true)
            }
            if (descrizioneClassifica ?: "" != "") {
                ilike("descrizione", "%${descrizioneClassifica}%")
            }
            if (codiceClassifica ?: "" != "") {
                ilike("codice", "%${codiceClassifica}%")
            }
            if (usoClassifica != "N" && (dataAperturaInizio == null && dataAperturaFine == null && dataCreazioneInizio == null && dataCreazioneFine == null && dataChiusuraInizio == null && dataChiusuraFine == null)) {
                or {
                    isNull('dal')
                    le('dal', dataValiditaTitolario)
                }
                or {
                    isNull('al')
                    ge('al', dataValiditaTitolario)
                }
            } else {
                if (dataAperturaInizio != null && dataAperturaFine != null) {
                    ge('dal', dataAperturaInizio)
                    le('dal', dataAperturaFine)
                }
                if (dataAperturaInizio != null && dataAperturaFine == null) {
                    ge('dal', dataAperturaInizio)
                }
                if (dataAperturaInizio == null && dataAperturaFine != null) {
                    le('dal', dataAperturaFine)
                }
                if (dataChiusuraInizio != null && dataChiusuraFine != null) {
                    ge('al', dataChiusuraInizio)
                    le('al', dataChiusuraFine)
                }
                if (dataChiusuraInizio != null && dataChiusuraFine == null) {
                    ge('al', dataChiusuraInizio)
                }
                if (dataChiusuraInizio == null && dataChiusuraFine != null) {
                    le('al', dataChiusuraFine)
                }
            }

            // in uso
            if (usoClassifica == "Y") {
                isNull('al')
            }
            // non in uso
            if (usoClassifica == "N") {
                or {
                    isNotNull('al')
                    lt('al', now)
                }
            }

            if (!ImpostazioniProtocollo.TITOLI_ROMANI.abilitato) {
                order('codice', 'asc')
            }
            order('descrizione', 'asc')
            order('dal', 'asc')
        }

        //ordinamento per codiceDecimale asc
        if (ImpostazioniProtocollo.TITOLI_ROMANI.abilitato) {
            lista?.sort { it.codiceDecimale }
        }

        // Richiedono che nella ricerca vengano mostrato l'albero fino alla foglia che soddisfa il criterio di ricerca.
        if (daRicerca) {
            List<Classificazione> tempListClassifichePadre = []
            List<Classificazione> listTemp = []
            List<Classificazione> listaPadri = []

            lista.each {
                listaPadri = []
                listaPadri = listPadri(it, listTemp)
                listaPadri.each {
                    tempListClassifichePadre << it
                }
                listaPadri.removeAll(listaPadri)
            }
            tempListClassifichePadre.unique().each { cp ->
                if (!lista.collect { it?.id }.contains(cp?.id)) {
                    if (cp) {
                        lista << cp
                    }
                }
            }
        }

        List<ClassificazioneDTO> listaDTO = lista.toDTO()
        return Pair.of(lista.totalCount, listaDTO)
    }

    ClassificazioneDTO get(Long id, boolean conNumeri = false) {
        Classificazione.createCriteria().get {
            eq('id', id)
        }?.toDTO()
    }

    /**
     * Cerca la classificazione in base all'id cartella
     * @param idCartella l'id cartella GDM
     * @return
     */
    ClassificazioneDTO findByIdCartella(Long idCartella) {
        Long idDocumentoEsterno = protocolloPkgService.getIdDocumentoProfilo(idCartella)
        findByIdEsterno(idDocumentoEsterno)
    }

    /**
     * Cerca la classificazione in base all'id esterno
     * @param idDocumentoEsterno l'id esterno
     * @return
     */
    ClassificazioneDTO findByIdEsterno(Long idDocumentoEsterno) {
        Classificazione cl = null
        try {
            cl = Classificazione.createCriteria().get {
                eq('idDocumentoEsterno', idDocumentoEsterno)
            }
        } catch (Exception e) {
            // potrebbe esserci stato un errore di molti record restituiti
            List<Classificazione> lista = Classificazione.createCriteria().list {
                eq('idDocumentoEsterno', idDocumentoEsterno)
            }
            cl = lista.find { it.al == null }
            if (!cl && lista) {
                cl = lista.sort { it.al }.last()
            }
        }
        return cl ? cl.toDTO() : null
    }

    Set<ClassificazioneDTO> getAllById(Collection<Long> ids, boolean conDescrizioni = false, boolean conNumeri = false) {
        def lista = Classificazione.createCriteria().list {
            'in'('id', ids)
            resultTransformer(CriteriaSpecification.DISTINCT_ROOT_ENTITY)
        }
        lista?.toDTO()
    }

    List<ClassificazioneDTO> getFigli(Long progressivoPadre, String filtro = null, FiltroDataClassificazioni filtroData = FiltroDataClassificazioni.VIS_TUTTE) {
        Date now = new Date()
        now.clearTime()
        def lista = Classificazione.createCriteria().list {
            if (progressivoPadre) {
                eq('progressivoPadre', progressivoPadre)
            } else {
                isNull('progressivoPadre')
            }

            if (filtro) {
                or {
                    ilike('descrizione', "%${filtro}%")
                    ilike('codice', "%${filtro}%")
                }
            }
            switch (filtroData) {
                case FiltroDataClassificazioni.VIS_ATTIVE:
                    or {
                        isNull('dal')
                        le('dal', now)
                    }
                    or {
                        isNull('al')
                        ge('al', now)
                    }
                    break
                case FiltroDataClassificazioni.VIS_PASSATE:
                    isNotNull('al')
                    lt('al', now)
                    break
                case FiltroDataClassificazioni.VIS_FUTURE:
                    isNotNull('dal')
                    gt('dal', now)
                    break
                default:
                    //visualizza tutte
                    break
            }
            order('codice', 'asc')
            resultTransformer(CriteriaSpecification.DISTINCT_ROOT_ENTITY)
        }

        List res = lista?.toDTO()
        return res
    }

    Boolean classificaUsata(Long id) {
        return Protocollo.createCriteria().count {
            classificazione {
                eq('id', id)
            }
        } > 0
    }

    ClassificazioneDTO chiudiClassificazione(ClassificazioneDTO classificazioneDTO) {
        Classificazione classificazione = classificazioneDTO.domainObject
        classificazione.al = classificazioneDTO.al
        classificazioneRepository.save(classificazione)
        return classificazione.toDTO()
    }

    Map<String, Classificazione> importaCsv(String csv, String username) throws ImportazioneCSVException {
        List<ErroreCsv> errori = []
        Ad4Utente us = ad4Repository.findByNominativo(username)
        SimpleDateFormat df = new SimpleDateFormat('dd/MM/yyyy')
        Map<String, Classificazione> creati = [:]
        CSVReader reader = new CSVReader(new StringReader(csv), ';' as char)
        int rowNumber = 1
        for (String[] row in reader.readAll()) {
            def (String codice, String descrizione, String dal, String al, String numIllimitata, String sequenza,
            String      codicePadre, String dalPadre, String dataCreazione, String contenitoreDoc) = row
            // se il codice sembra quello vuol dire che c'è l'intestazione
            if (codice != 'CLASS_COD') {
                Classificazione classificazione = new Classificazione()
                classificazione.utenteIns = us
                classificazione.utenteUpd = us
                classificazione.codice = codice
                if (codicePadre) {
                    Classificazione padre = creati[codicePadre]
                    if (!padre) {
                        padre = findByCodice(codicePadre)
                        creati[padre.codice] = padre
                    }
                    classificazione.progressivoPadre = padre.progressivo
                } else {
                    classificazione.progressivoPadre = null
                }
                Classificazione esistente = findByCodice(codice)
                if (!esistente) {
                    classificazione.numIllimitata = numIllimitata?.toUpperCase() == 'Y'
                    classificazione.contenitoreDocumenti = contenitoreDoc?.toUpperCase() == 'Y'
                    classificazione.docFascicoliSub = Boolean.FALSE
                    try {
                        creati[codice] = classificazioneRepository.save(classificazione)
                    } catch (Exception e) {
                        errori << new ErroreCsv(riga: rowNumber, dati: row, errore: e.message)
                    }
                } else {
                    errori << new ErroreCsv(riga: rowNumber, dati: row, errore: "Codice duplicato - ${codice}")
                }
            }
            rowNumber++
        }
        if (errori) {
            throw new ImportazioneCSVException(errori)
        }
        return creati
    }

    ClassificazioneUnitaDTO aggiungiUnita(ClassificazioneDTO classificazioneDTO, So4UnitaPubbDTO unita, Date dal = new Date()) {
        Classificazione classificazione = classificazioneRepository.findOne(classificazioneDTO.id)
        ClassificazioneUnita classEnte = classificazioneUnitaRepository.findByClassificazioneAndUnita(classificazione, unita.domainObject)
        if (classEnte) {
            classificazioneUnitaRepository.delete(classEnte)
        }
        ClassificazioneUnita cu = new ClassificazioneUnita()
        cu.classificazione = classificazione
        cu.unita = unita.domainObject
        cu = classificazioneUnitaRepository.save(cu)
        return cu.toDTO()
    }

    void rimuoviUnita(ClassificazioneUnitaDTO unita) {
        ClassificazioneUnita cu = classificazioneUnitaRepository.findOne(unita.id)
        classificazioneUnitaRepository.delete(cu)
        Classificazione classificazione = cu.classificazione
        List<ClassificazioneUnita> listaEsistenti = classificazioneUnitaRepository.findByClassificazione(classificazione)
        // se siamo rimasti senza unità ripristino il valore di default
        if (!listaEsistenti) {
            creaUnitaEnteDefault(classificazione)
        }
    }

    List<ClassificazioneUnitaDTO> getUnitaPerClassificazione(ClassificazioneDTO classificazioneDTO) {
        return ClassificazioneUnita.createCriteria().list {
            eq('classificazione', classificazioneDTO.domainObject)

            createAlias('unita', 'unita')
            fetchMode('unita', FetchMode.JOIN)
        }?.toDTO()
    }

    List<ClassificazioneNumeroDTO> getNumeriPerClassificazione(ClassificazioneDTO classificazioneDTO) {
        classificazioneNumeroRepository.findByClassificazioneOrderByAnnoDesc(classificazioneDTO.domainObject).toDTO()
    }

    List<ClassificazioneDTO> getStoricoPerClassificazione(ClassificazioneDTO classificazioneDTO) {
        return Classificazione.createCriteria().list {
            eq('progressivo', classificazioneDTO.progressivo)
            order('dal', 'desc')
        }?.toDTO()
    }

    ClassificazioneDTO getByProgressivo(Long progressivo) {
        List res = Classificazione.createCriteria().list {
            eq('progressivo', progressivo)
            order('dal', 'desc')
        }
        if (res) {
            return res.first().toDTO()
        } else {
            return null
        }
    }

    ClassificazioneDTO storicizza(ClassificazioneDTO classificazioneDTO) {
        Classificazione classificazione = classificazioneDTO.domainObject
        def cal = Calendar.getInstance()
        // prendo la data fornita
        cal.time = classificazioneDTO.dal
        cal.add(Calendar.DAY_OF_YEAR, -1)
        // imposto la chiusura al giorno prima
        classificazione.al = cal.time
        classificazione.save()

        Classificazione nuova = new Classificazione()
        duplicaProprieta(nuova, classificazioneDTO)
        // la nuova parte con data impostata e nessuna scadenza
        nuova.dal = classificazioneDTO.dal
        nuova.al = null
        nuova.save()

        List<ClassificazioneUnita> listUnita = getUnitaPerClassificazione(classificazioneDTO)
        for (ClassificazioneUnita unita in listUnita) {
            ClassificazioneUnita u = new ClassificazioneUnita(classificazione: nuova)
            u.unita(unita.unita)
            u.valido = true
            u.save()
        }

        salvaNumero(nuova)

        return nuova.toDTO()
    }

    private void duplicaProprieta(Classificazione classificazione, ClassificazioneDTO classificazioneDto) {
        classificazione.codice = classificazioneDto.codice.toUpperCase()
        classificazione.note = classificazioneDto.note
        classificazione.descrizione = classificazioneDto.descrizione
        classificazione.contenitoreDocumenti = classificazioneDto.contenitoreDocumenti
        classificazione.docFascicoliSub = classificazioneDto.docFascicoliSub
        classificazione.numIllimitata = classificazioneDto.numIllimitata
        classificazione.progressivoPadre = classificazioneDto.progressivoPadre
        classificazione.valido = classificazioneDto.valido
        classificazione.dal = classificazioneDto.dal
        classificazione.al = classificazioneDto.al
        classificazione.idDocumentoEsterno = classificazioneDto.idDocumentoEsterno
        classificazione.progressivo = classificazioneDto.progressivo
    }

    void aggiornaProgressivo(Long id) {
        classificazioneRepository.aggiornaProgressivo(id)
    }

    Classificazione findByCodice(String codice, Pageable pag = new PageRequest(0, 1)) {
        List<Classificazione> lista = classificazioneRepository.findTopByCodice(codice, pag)
        if (lista) {
            return lista.first()
        } else {
            return null
        }
    }

    ClassificazioneNumero salvaNumero(Classificazione classificazione) {
        ClassificazioneNumero num = new ClassificazioneNumero()
        num.classificazione = classificazione
        num.anno = Calendar.getInstance().get(Calendar.YEAR)
        num.ultimoNumeroFascicolo = 0
        classificazioneNumeroRepository.save(num)
    }

    ClassificazioneNumero salvaNumero(Classificazione classificazione, Integer anno, Integer ultimoNumeroFascicolo) {
        ClassificazioneNumero num = new ClassificazioneNumero()
        num.classificazione = classificazione
        num.anno = anno
        num.ultimoNumeroFascicolo = ultimoNumeroFascicolo
        classificazioneNumeroRepository.save(num)
    }

    String getNuovoNumeroSub(Integer anno, Classificazione classificazione) {
        Integer ultimoNumero = classificazioneNumeroRepository.getUltimoNumeroSub(classificazione, anno)
        classificazioneNumeroRepository.modificaUltimoNumeroFascicolo(ultimoNumero + 1, classificazione, anno)
        return ultimoNumero + 1
    }

    List<Classificazione> findByFilter(ClassificazioneJPQLFilter filter) {
        def query = filter.toJPQL()
        TypedQuery<Classificazione> q = entityManager.createQuery(query, Classificazione)
        for (Map.Entry<String, Object> entry in filter.params) {
            q.setParameter(entry.key, entry.value)
        }
        return q.resultList
    }

    List<Classificazione> listPadri(Classificazione classificazione, List<Classificazione> result) {
        List<Classificazione> listClassifiche
        Classificazione c
        if (classificazione.progressivoPadre) {
            listClassifiche = classificazioneRepository.listClassificazioniFromProgressivo(classificazione.progressivoPadre)
            if (listClassifiche.size() > 1) {
                listClassifiche.each {
                    if (!it.al) {
                        c = Classificazione.get(it.id)
                        result << c
                    }
                }
            } else {
                c = listClassifiche[0]
                result << c
            }

            if (c?.progressivoPadre) {
                listPadri(c, result)
            }
        }

        return result
    }

    boolean isModificaDataChiusura(ClassificazioneDTO classificazione) {
        if (!classificazione.al) {
            return true
        } else {
            Integer presenza = classificazioneRepository.isModificaDataChiusura(classificazione.codice, classificazione.al)
            if (presenza == 0) {
                return true
            } else {
                return false
            }
        }
    }

    Integer getLivello(ClassificazioneDTO classificazione) {
        if (!classificazione.progressivoPadre) {
            return 0
        } else {
            return getProgressivoPadre(classificazione.progressivoPadre)
        }
    }

    Long getProgressivoPadre(Long progressivo) {
        Long padre
        Integer cont = 1
        padre = classificazioneRepository.getProgressivoPadre(progressivo)
        if (padre) {
            cont++
            getProgressivoPadre(padre)
        } else {
            return cont
        }
        return cont
    }
}