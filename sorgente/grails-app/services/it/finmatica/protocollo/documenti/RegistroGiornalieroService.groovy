package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.storico.DatoStorico
import it.finmatica.gestionedocumenti.storico.DocumentoStoricoService
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.jobscheduler.JobConfig
import it.finmatica.jobscheduler.JobLog
import it.finmatica.jobscheduler.JobSchedulerRepository
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.documenti.exception.RegistroGiornalieroCreazioneException
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ricercadocumenti.FiltriRegistroGiornaliero
import it.finmatica.protocollo.jobs.RegistroGiornalieroTaskAnnullamento
import it.finmatica.protocollo.jobs.RegistroModificheRisultato
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang3.time.FastDateFormat
import org.apache.commons.lang3.tuple.Pair
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.persistence.EntityManager
import javax.persistence.TypedQuery
import javax.persistence.criteria.CriteriaBuilder
import javax.persistence.criteria.CriteriaQuery
import javax.persistence.criteria.Join
import javax.persistence.criteria.JoinType
import javax.persistence.criteria.Predicate
import javax.persistence.criteria.Root

@Slf4j
@Transactional
@Service
class RegistroGiornalieroService {
    private final String PATH_MODELLI = '/META-INF/modelliTesto'

    @Autowired private ProtocolloService protocolloService
    @Autowired private DocumentoService documentoService
    @Autowired private RegistroGiornalieroRepository registroGiornalieroRepository
    @Autowired private SchemaProtocolloService schemaProtocolloService
    @Autowired private JobSchedulerRepository jobSchedulerRepository
    @Autowired private DocumentoStoricoService documentoStoricoService
    @Autowired private IGestoreFile gestoreFile
    @Autowired private TitolarioService titolarioService
    @Autowired private GestioneTestiService gestioneTestiService
    @Autowired private EntityManager em
    @Autowired private WkfIterService wkfIterService
    @Autowired private NotificheService notificheService
    @Autowired private RegistroGiornalieroTaskAnnullamento registroGiornalieroTaskAnnullamento

    private static final Map<Integer,DatoStorico.TipoStorico> REVTYPE_TO_STATO = [0: DatoStorico.TipoStorico.AGGIUNTO, 1: DatoStorico.TipoStorico.MODIFICATO, 2: DatoStorico.TipoStorico.CANCELLATO]
    private FastDateFormat fdf = FastDateFormat.getInstance('dd/MM/yyyy')
    private FastDateFormat fdfName = FastDateFormat.getInstance('dd_MM_yyyy')
    private FastDateFormat fdfDataOra = FastDateFormat.getInstance('dd/MM/yyyy HH:mm:sss')



    RegistroGiornaliero salva(RegistroModificheRisultato risultato, Long idTipoProtocollo, Date dataProtocollo, Ente en) throws RegistroGiornalieroCreazioneException {
        Protocollo prot = new Protocollo()
        // oggetto di default se fallisce prima di trovare lo schema protocollo
        prot.oggetto = "Registro giornaliero del ${fdf.format(dataProtocollo)}"
        try {
            String codiceEnte = "${en.amministrazione.codice}-${en.aoo}"
            Date now = new Date()
            RegistroGiornaliero reg = new RegistroGiornaliero()
            SchemaProtocollo schemaProtocollo = SchemaProtocollo.findByCodice(ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore) as SchemaProtocollo
            prot.schemaProtocollo = schemaProtocollo
            prot.oggetto = "${schemaProtocollo.oggetto} del ${fdf.format(dataProtocollo)}"
            DocumentoSoggetto soggetto = new DocumentoSoggetto()
            soggetto.unitaSo4 = So4UnitaPubb.findByCodiceAndAlIsNull(ImpostazioniProtocollo.UNITA_PROTOCOLLO.valore)
            soggetto.tipoSoggetto = 'UO_PROTOCOLLANTE'
            prot.addToSoggetti(soggetto)
            DocumentoSoggetto redattore = new DocumentoSoggetto()
            redattore.tipoSoggetto = 'REDATTORE'
            redattore.utenteAd4 = Ad4Utente.get(ImpostazioniProtocollo.UTENTI_PROTOCOLLO.valore)
            prot.addToSoggetti(redattore)
            prot.classificazione = schemaProtocollo.classificazione
            TipoProtocollo tipoProtocollo = TipoProtocollo.get(idTipoProtocollo) as TipoProtocollo
            prot.tipoProtocollo = tipoProtocollo
            prot.movimento = prot.tipoProtocollo.movimento
            prot.fascicolo = schemaProtocollo.fascicolo
            if(schemaProtocollo?.tipoRegistro) {
                prot.tipoRegistro = schemaProtocollo.tipoRegistro
            } else if(tipoProtocollo.tipoRegistro){
                prot.tipoRegistro = prot.tipoProtocollo.tipoRegistro
            } else {
                prot.tipoRegistro = TipoRegistro.findByCodice(ImpostazioniProtocollo.TIPO_REGISTRO.valore)
            }
            reg.primoNumero = risultato.daNumero
            reg.ultimoNumero = risultato.aNumero
            reg.dataPrimoNumero = risultato.dataPrimoNumero
            reg.dataUltimoNumero = risultato.dataUltimoNumero
            reg.totaleProtocolli = risultato.totale
            reg.ricercaDataDal = risultato.ricercaDal
            reg.ricercaDataAl = risultato.ricercaAl
            reg.totaleAnnullati = risultato.totaleAnnullati
            GestioneTestiModello modelloTestoNuovo = tipoProtocollo.modelliAssociati.find {it.modelloTesto.tipoModello.id == 'REGISTRO_GIORNALIERO' }?.modelloTesto
            GestioneTestiModello modelloTestoModifiche = tipoProtocollo.modelliAssociati.find {it.modelloTesto.tipoModello.id == 'REGISTRO_MODIFICHE' }?.modelloTesto
            // se non c'e uno dei due modelli errore
            if(!modelloTestoNuovo || !modelloTestoModifiche) {
                throw new RegistroGiornalieroCreazioneException("Impossibile recuperare i modelli testo associati")
            }
            protocolloService.salva(prot)
            reg.protocollo = prot
            reg = registroGiornalieroRepository.save(reg)
            prot.registroGiornaliero = reg
            protocolloService.salva(prot)
            FileDocumento fileDocumentoPrinc = getFileDocumento(prot,dataProtocollo)
            fileDocumentoPrinc.modelloTesto = modelloTestoNuovo
            fileDocumentoPrinc.save()
            prot.addToFileDocumenti(fileDocumentoPrinc)
            protocolloService.salva(prot)
            // try catch -> valido = N
            try {
                log.info('Creo documento nuovi protocolli per ente{}, data inizio ricerca {}, data fine ricerca {}', "${en.amministrazione.codice}-${en.aoo}",fdfDataOra.format(reg.ricercaDataDal),fdfDataOra.format(reg.ricercaDataAl))
                documentoService.generaTestoFile(prot, fileDocumentoPrinc, 'pdf', true, [id: reg.id])
            } catch(Exception err) {
                log.error("Errore creazione documento registro giornaliero per ente {}",codiceEnte,err)
                reg.errore = "Errore creazione documento registro giornaliero per ente ${codiceEnte}: ${err.message}".toString()
            }
            if (risultato.totaleModificati > 0) {
                Allegato allegatoModificati = getDefaultAllegato(dataProtocollo)
                allegatoModificati.save()
                prot.addDocumentoAllegato(allegatoModificati)
                prot.save()
                FileDocumento fileModificati = getFileDocumentoPerAllegati(prot, allegatoModificati,dataProtocollo)
                fileModificati.modelloTesto = modelloTestoModifiche
                fileModificati.save()
                allegatoModificati.addToFileDocumenti(fileModificati)
                allegatoModificati.save()
                // try catch -> valido = N
                try {
                    log.info('Creo documento protocolli modificati per ente{}, data inizio ricerca {}, data fine ricerca {}', "${en.amministrazione.codice}-${en.aoo}",fdfDataOra.format(reg.ricercaDataDal),fdfDataOra.format(reg.ricercaDataAl))
                    documentoService.generaTestoFile(allegatoModificati, fileModificati, 'pdf', true, [id: reg.id])
                } catch(Exception err) {
                    log.error("Errore creazione documento registro giornaliero modifiche per ente {}",codiceEnte,err)
                    reg.errore = "Errore creazione documento registro giornaliero modifiche per ente ${codiceEnte}: ${err.message}".toString()
                }
            }
            protocolloService.salva(prot)
            if(prot.valido) {
                if(!prot.classificazione && ImpostazioniProtocollo.CLASS_OB.valore == 'Y') {
                    reg.errore = "Errore creazione documento registro giornaliero per ente ${codiceEnte}: classificazione obbligatoria assente".toString()
                }
            } else {
                throw new RegistroGiornalieroCreazioneException("Errore creazione registro")
            }
            registroGiornalieroRepository.save(reg)
            return reg
        } catch(RegistroGiornalieroCreazioneException e ) {
            throw e
        } catch (Exception e) {
            throw new RegistroGiornalieroCreazioneException(e)
        }
    }

    JobConfig getConfigForLogId(Long idJobLog) {
        JobLog jl = jobSchedulerRepository.getJobLog(idJobLog)
        def config = JobConfig.get(jl.jobConfig.id)
        return config
    }


    RegistroGiornaliero eseguiEnte(Date ricercaDal, Date ricercaAl, Long idTipoProtocollo, Date dataProtocollo, Ente ente) {
        RegistroGiornaliero res = null
        try {
            TipoRegistro tpRicerca = TipoRegistro.get(ImpostazioniProtocollo.TIPO_REGISTRO.valore)
            List<Protocollo> listaNuovi = protocolloService.trovaNuoviInserimenti(ricercaDal, ricercaAl,tpRicerca,ente.id)
            List<Protocollo> listaAnnullati = protocolloService.trovaAnnullati(ricercaDal, ricercaAl,tpRicerca,ente.id)
            int numeroModificati = registroGiornalieroRepository.countModificheRegistro(ricercaDal,ricercaAl,tpRicerca.codice,ente.id)
            RegistroModificheRisultato risultato = new RegistroModificheRisultato()
            risultato.ricercaDal = ricercaDal
            risultato.ricercaAl = ricercaAl
            risultato.listaModificati = new ArrayList<>()
            risultato.daNumero = Integer.MAX_VALUE
            risultato.aNumero = 0
            risultato.totale = listaNuovi?.size() ?: 0
            risultato.totaleModificati = numeroModificati
            risultato.totaleAnnullati = listaAnnullati?.size() ?: 0
            for (Protocollo p : listaNuovi) {
                // inizializzo i corrispondenti
                p.corrispondenti?.size()
                risultato.totale++
                int numero = p.numero
                if (numero < risultato.daNumero) {
                    risultato.daNumero = numero
                    risultato.dataPrimoNumero = p.data
                }
                if (numero > risultato.aNumero) {
                    risultato.aNumero = numero
                    risultato.dataUltimoNumero = p.data
                }
            }
            // se non ci sono nuovi protocolli annullo il primo numero
            if (risultato.daNumero == Integer.MAX_VALUE) {
                risultato.daNumero = 0
            }
            res = salva(risultato, idTipoProtocollo, dataProtocollo, ente)
        } catch(Exception e) {
            log.error('Errore esecuzione registro giornaliero',e)
            if(res?.protocollo) {
                res.errore = "Errore creazione registro giornaliero: ${e.getMessage()}"
                registroGiornalieroRepository.save(res)
            }
        }
        return res

    }

    PagedResultList<RegistroGiornaliero> list(FiltriRegistroGiornaliero filtro) {
        CriteriaBuilder cb = em.getCriteriaBuilder()
        Pair<CriteriaQuery<Protocollo>,Root<Protocollo>> crit = createListCriteria(filtro, Protocollo)
        CriteriaQuery<Protocollo> cq  = crit.left
        Root<Protocollo> root = crit.right
        root.fetch('registroGiornaliero',JoinType.INNER)
        cq.select(root)
        TypedQuery<Protocollo> query = em.createQuery(cq)
        query.firstResult = filtro.activePage * filtro.pageSize
        query.maxResults = filtro.pageSize
        def list = query.getResultList()
        Pair<CriteriaQuery<Long>,Root<Protocollo>> critCount = createListCriteria(filtro, Long)
        CriteriaQuery<Long> cqCount = critCount.left
        Root<Protocollo> rootCount = critCount.right
        cqCount.select(cb.count(rootCount))
        TypedQuery<Long> count = em.createQuery(cqCount)
        def totalSize = count.getSingleResult().intValue()
        def listaRegistri = list.collect {Protocollo p ->
            RegistroGiornaliero reg = p.registroGiornaliero
            reg.protocollo = p
            return reg
        }
        return new PagedResultList<RegistroGiornaliero>(listaRegistri, totalSize)
    }

    FileDocumento getFilePrincipale(RegistroGiornaliero reg) {
        Protocollo p = Protocollo.get(reg.protocollo.id)
        p.filePrincipale
    }

    Pair<Documento,FileDocumento> getAllegato(RegistroGiornaliero reg) {
        Protocollo p = Protocollo.get(reg.protocollo.id)
        DocumentoCollegato collAllegati = p.documentiCollegati.find {it.tipoCollegamento.codice == Allegato.CODICE_TIPO_COLLEGAMENTO}
        if(collAllegati) {
            Documento all = Documento.get(collAllegati.collegato.id)
            Pair.of(all, all.fileDocumenti.first())
        } else {
            Pair.of(null,null)
        }
    }



    Protocollo findByIdDocumento(Long idDocumento) {
        registroGiornalieroRepository.findByIdDocumento(idDocumento)
    }

    Protocollo findByIdDocumentoWithTipoProtocollo(Long idDocumento) {
        registroGiornalieroRepository.findByIdDocumentoWithTipoProtocollo(idDocumento)
    }

    List<DocumentoTitolarioDTO> getTitolari(RegistroGiornaliero reg) {
        Protocollo p = Protocollo.get(reg.protocollo.id)
        return p.titolari?.toList()?.toDTO(['classificazione','fascicolo'])
    }

    RegistroGiornaliero findLatest(Long idEnte) {
        List<RegistroGiornaliero> res = registroGiornalieroRepository.findByEnte(idEnte, new PageRequest(0,1, Sort.Direction.DESC,'reg.ricercaDataAl'))
        if(res) {
            return res.first()
        } else {
            return null
        }
    }

    void annullaRegistro(Long idRegistroGiornaliero) {
        registroGiornalieroRepository.annullaProtocollo(idRegistroGiornaliero)
    }

    String istanziaIter(Long idProtocollo) {
        Protocollo prot = findByIdDocumentoWithTipoProtocollo(idProtocollo)
        try {
            wkfIterService.istanziaIter(prot.tipoProtocollo.getCfgIter(), prot)
            return null
        } catch(Exception e) {
            log.error('Errore esecuzione iter per protocollo registro giornaliero id = {}',idProtocollo,e)
            return "Errore esecuzione iter su protocollo id = ${prot.id}: ${e.message}"
        }
    }

    void inviaNotifica (Protocollo prot, RegistroGiornaliero reg) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.ERRORE_REGISTRO_GIORNALIERO, prot, "Errore creazione registro giornaliero con oggetto ${prot?.oggetto}: ${reg?.errore}")
    }

    RegistroGiornaliero save(RegistroGiornaliero reg) {
        return registroGiornalieroRepository.save(reg)
    }

    Protocollo findByIdRegistroGiornaliero(Long idRegistroGiornaliero) {
        return registroGiornalieroRepository.findByIdRegistroGiornaliero(idRegistroGiornaliero)
    }

    private <T> Pair<CriteriaQuery<T>,Root<Protocollo>> createListCriteria(FiltriRegistroGiornaliero filtro, Class<T> clazz) {
        CriteriaBuilder cb = em.getCriteriaBuilder()
        CriteriaQuery<T> cq = cb.createQuery(clazz)
        Root<Protocollo> root = cq.from(Protocollo)
        Collection<Predicate> predicates = new HashSet<>()
        Join<Protocollo,RegistroGiornaliero> fetch = root.join('registroGiornaliero', JoinType.INNER)
        def dc = root.get(filtro.order ?: 'dateCreated')
        cq.orderBy((filtro.orderDir ?: 'desc') == 'desc' ? cb.desc(dc) : cb.asc(dc))
        if (filtro.anno) {
            predicates.add cb.equal(root.get('anno'), filtro.anno)
        }
        if (filtro.dataProtocolloA) {
            predicates.add cb.lessThanOrEqualTo(root.get('data'), filtro.dataProtocolloA)
        }
        if (filtro.dataProtocolloDa) {
            predicates.add cb.greaterThanOrEqualTo(root.get('data'), filtro.dataProtocolloDa)
        }
        if (filtro.numeroA) {
            predicates.add cb.lessThanOrEqualTo(root.get('numero'), filtro.numeroA)
        }
        if (filtro.numeroDa) {
            predicates.add cb.greaterThanOrEqualTo(root.get('numero'), filtro.numeroDa)
        }
        if(filtro.dataFinaleA) {
            predicates.add cb.lessThanOrEqualTo(fetch.<RegistroGiornaliero>get('dataUltimoNumero'),filtro.dataFinaleA)
        }
        if(filtro.dataFinaleDa) {
            predicates.add cb.greaterThanOrEqualTo(fetch.<RegistroGiornaliero>get('dataUltimoNumero'),filtro.dataFinaleDa)
        }
        if(filtro.dataInizialeRicercaA) {
            predicates.add cb.lessThanOrEqualTo(fetch.<RegistroGiornaliero>get('ricercaDataDal'),filtro.dataFinaleRicercaA)
        }
        if(filtro.dataInizialeRicercaDa) {
            predicates.add cb.greaterThanOrEqualTo(fetch.<RegistroGiornaliero>get('ricercaDataDal'),filtro.dataFinaleRicercaDa)
        }
        if(filtro.dataFinaleRicercaA) {
            predicates.add cb.lessThanOrEqualTo(fetch.<RegistroGiornaliero>get('ricercaDataAl'),filtro.dataFinaleRicercaA)
        }
        if(filtro.dataFinaleRicercaDa) {
            predicates.add cb.greaterThanOrEqualTo(fetch.<RegistroGiornaliero>get('ricercaDataAl'),filtro.dataFinaleRicercaDa)
        }

        if(filtro.numeroInizialeA) {
            predicates.add cb.lessThanOrEqualTo(fetch.<RegistroGiornaliero>get('primoNumero'),filtro.numeroInizialeA)
        }
        if(filtro.numeroInizialeDa) {
            predicates.add cb.greaterThanOrEqualTo(fetch.<RegistroGiornaliero>get('primoNumero'),filtro.numeroInizialeDa)
        }
        if(filtro.numeroFinaleA) {
            predicates.add cb.lessThanOrEqualTo(fetch.<RegistroGiornaliero>get('ultimoNumero'),filtro.numeroFinaleA)
        }
        if(filtro.numeroFinaleDa) {
            predicates.add cb.greaterThanOrEqualTo(fetch.<RegistroGiornaliero>get('ultimoNumero'),filtro.numeroFinaleDa)
        }
        if(filtro.tipoRegistro) {
            predicates.add cb.equal(root.get('tipoRegistro').get('codice'),filtro.tipoRegistro.codice)
        }
        if(filtro.testoCerca) {
            predicates.add cb.like(cb.upper(root.get('oggetto')),"%${filtro.testoCerca.toUpperCase()}%")
        }
        if(predicates) {
            cq.where(predicates.toArray(new Predicate[predicates.size()]))
        }
        return Pair.of(cq,root)
    }

    private Allegato getDefaultAllegato(Date now) {
        Allegato allegato = new Allegato(valido: true)
        allegato.tipoAllegato = TipoAllegato.findByAcronimo(ImpostazioniProtocollo.TIPO_ALL_REG_MOD.valore) as TipoAllegato
        allegato.descrizione = "Registro giornaliero modifiche del ${fdf.format(now)}"
        allegato.commento = "Registro giornaliero modifiche del ${fdf.format(now)}"
        allegato
    }

    private FileDocumento getFileDocumento(Protocollo prot, Date now) {
        FileDocumento f = new FileDocumento()
        f.codice = FileDocumento.CODICE_FILE_PRINCIPALE
        f.contentType = "application/pdf"
        f.documento = prot
        f.nome = "RegistroGiornaliero-${fdfName.format(now)}-nuovi.pdf"
        return f

    }

    private FileDocumento getFileDocumentoPerAllegati(Protocollo prot, Allegato allegato, Date now) {
        FileDocumento f = new FileDocumento()
        f.codice = FileDocumento.CODICE_FILE_ALLEGATO
        f.contentType = "application/pdf"
        f.documento = allegato
        f.nome = "RegistroGiornaliero-${fdfName.format(now)}-modificati.pdf"
        return f

    }

}
