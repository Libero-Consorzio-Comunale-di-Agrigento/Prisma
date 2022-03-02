package it.finmatica.protocollo.titolario

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class TitolarioService {

    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze

    @Transactional
    void salva(Protocollo protocollo, List<DocumentoTitolarioDTO> titolari) {
        for (DocumentoTitolarioDTO titolarioDTO : titolari) {
            DocumentoTitolario titolario = titolarioDTO.domainObject
            if (titolario == null) {
                titolario = new DocumentoTitolario()
                protocollo.addToTitolari(titolario)
            }
            titolario.classificazione = titolarioDTO.classificazione?.getDomainObject()
            titolario.fascicolo = titolarioDTO.fascicolo?.getDomainObject()
            titolario.documento = protocollo
            // allineo i dati su GDM
            protocolloGdmService.fascicolaTitolarioSecondario(titolario)
            titolario.save()
            protocollo.save()
        }
    }

    @Transactional
    void salva(MessaggioRicevuto messaggioRicevuto, List<DocumentoTitolarioDTO> titolari) {
        for (DocumentoTitolarioDTO titolarioDTO : titolari) {
            DocumentoTitolario titolario = titolarioDTO.domainObject
            if (titolario == null) {
                titolario = new DocumentoTitolario()
                messaggioRicevuto.addToTitolari(titolario)
            }
            titolario.classificazione = titolarioDTO.classificazione?.getDomainObject()
            titolario.fascicolo = titolarioDTO.fascicolo?.getDomainObject()
            titolario.documento = messaggioRicevuto

            titolario.save()
            messaggioRicevuto.save()
        }
    }

    @Transactional
    void remove(DocumentoDTO documentoDTO, DocumentoTitolarioDTO titolarioDTO) {
        Documento documento = documentoDTO?.getDomainObject()
        DocumentoTitolario titolario = titolarioDTO.domainObject
        if (titolario && documento) {
            if (documentoDTO instanceof ProtocolloDTO) {
                protocolloGdmService.rimuoviFascicolo(titolario, springSecurityService.principal.id, null)
            }
            documento.removeFromTitolari(titolario)
            titolario.delete()
            documento.save()
        }
    }

    PagedResultList ricercaClassificazioni(String filtro, int offset, int max) {
        if (filtro != null && !filtro.equals("") && filtro.length() < 2 && offset == 0) {
            return new PagedResultList([], 0)
        }
        return ricercaClassificazioni(new ClassificazioneDTO(codice: filtro, descrizione: filtro), offset, max, true, false)
    }

    PagedResultList ricercaClassificazioni(String filtro, int offset, int max, boolean ricercaSoloClassificheAperte) {
        if (filtro != null && !filtro.equals("") && filtro.length() < 2 && offset == 0) {
            return new PagedResultList([], 0)
        }
        return ricercaClassificazioni(new ClassificazioneDTO(codice: filtro, descrizione: filtro), offset, max, ricercaSoloClassificheAperte, false)
    }

    PagedResultList ricercaClassificazioni(ClassificazioneDTO classificazioneDTO, int offset, int max, boolean ricercaSoloClassificheAperte = false, boolean ricercaInAnd = false) {
        if (ImpostazioniProtocollo.TITOLI_ROMANI.abilitato) {
            return ricercaClassificazioniTitoliRomani(classificazioneDTO, offset, max, ricercaSoloClassificheAperte, ricercaInAnd)
        } else {
            return ricercaClassificazioniTitoliDecimali(classificazioneDTO, offset, max, ricercaSoloClassificheAperte, ricercaInAnd)
        }
    }

    PagedResultList ricercaClassificazioniTitoliDecimali(ClassificazioneDTO classificazioneDTO, int offset, int max, boolean ricercaSoloClassificheAperte = false, boolean ricercaInAnd = false) {
        return Classificazione.createCriteria().list(max: max, offset: offset) {

            // issue #36855, da migliorare la ricerca
            if (ricercaInAnd) {
                and {
                    if (classificazioneDTO?.codice?.length() > 0) {
                        ilike("codice", "%" + classificazioneDTO.codice + "%")
                    }
                    if (classificazioneDTO?.descrizione?.length() > 0) {
                        ilike("descrizione", "%" + classificazioneDTO.descrizione + "%")
                    }
                }
            } else {
                or {
                    if (classificazioneDTO?.codice?.length() > 0) {
                        ilike("codice", "%" + classificazioneDTO.codice + "%")
                    }
                    if (classificazioneDTO?.descrizione?.length() > 0) {
                        ilike("descrizione", "%" + classificazioneDTO.descrizione + "%")
                    }
                }
            }

            if (ricercaSoloClassificheAperte) {
                // cerco solo tra quelle aperte
                Date oggi = new Date()
                le("dal", oggi)
                or {
                    ge("al", oggi)
                    isNull("al")
                }
            }

            order("codice", "asc")
        }
    }

    private PagedResultList ricercaClassificazioniTitoliRomani(ClassificazioneDTO classificazioneDTO, int offset, int max, boolean ricercaSoloClassificheAperte, boolean ricercaInAnd = false) {

        int count = Classificazione.createCriteria().count() {
            ricercaClassificaRomaniCriteria(delegate)(classificazioneDTO, ricercaSoloClassificheAperte, ricercaInAnd)
        }

        if (count > ImpostazioniProtocollo.CLASSFASC_RICERCA_MAX_NUM.valoreInt) {
            return new PagedResultList([], 0)
        }

        List<Classificazione> list = Classificazione.createCriteria().list() {
            ricercaClassificaRomaniCriteria(delegate)(classificazioneDTO, ricercaSoloClassificheAperte, ricercaInAnd)
        }

        PagedList pagedList
        if (list) {
            list?.sort { it.codiceDecimale }
            pagedList = calcolaPaginazione(list, offset, max)
        } else {
            pagedList = new PagedList([], 0)
        }
        return new PagedResultList(pagedList, pagedList.totalCount)
    }

    private def ricercaClassificaRomaniCriteria(def delegate) {
        def c = { classificazioneDTO, ricercaSoloClassificheAperte, ricercaInAnd ->
            if (ricercaInAnd) {
                and {
                    if (classificazioneDTO.codice != null) {
                        ilike("codice", classificazioneDTO.codice + "%")
                    }
                    if (classificazioneDTO.descrizione != null) {
                        ilike("descrizione", "%" + classificazioneDTO.descrizione + "%")
                    }
                }
            } else {
                or {
                    if (classificazioneDTO.codice != null) {
                        ilike("codice", classificazioneDTO.codice + "%")
                    }
                    if (classificazioneDTO.descrizione != null) {
                        ilike("descrizione", "%" + classificazioneDTO.descrizione + "%")
                    }
                }
            }

            if (ricercaSoloClassificheAperte) {
                // cerco solo tra quelle aperte
                Date oggi = new Date()
                le("dal", oggi)
                or {
                    ge("al", oggi)
                    isNull("al")
                }
            }
        }
        c.delegate = delegate
        return c
    }


    PagedResultList ricercaFascicoli(long idClassificazione, String filtro, int offset, int max, boolean ricercaFascicoliChiusi = false) {
        if (!filtro.equals("%") && filtro?.length() < 2 && offset == 0) {
            return new PagedResultList([], 0)
        }
        return ricercaFascicoli(new ClassificazioneDTO(id: idClassificazione), new FascicoloDTO(annoNumero: filtro, oggetto: filtro), null,  offset, max, ricercaFascicoliChiusi)
    }

    PagedResultList ricercaFascicoli(ClassificazioneDTO ricercaClassificazione, FascicoloDTO ricercaFascicolo, So4UnitaPubbDTO unitaCompetenza, int offset, int max, boolean ricercaFascicoliChiusi = false) {

        boolean escludiClassificaDelPersonale = false
        if ((ImpostazioniProtocollo.CLAS_FASC_PERS.valore != null && !ImpostazioniProtocollo.CLAS_FASC_PERS.valore.equals(""))) {
            escludiClassificaDelPersonale = !gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.USA_FASCICOLI_PERSONALE)
        }

        if (ImpostazioniProtocollo.TITOLI_ROMANI.abilitato) {
            return ricercaFascicoliTitoliRomani(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, offset, max, ricercaFascicoliChiusi, escludiClassificaDelPersonale)
        } else {
            return ricercaFascicoliDecimali(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, offset, max, ricercaFascicoliChiusi, escludiClassificaDelPersonale)
        }
    }

    PagedResultList ricercaFascicoliDecimali(ClassificazioneDTO ricercaClassificazione, FascicoloDTO ricercaFascicolo, So4UnitaPubbDTO unitaCompetenza, int offset, int max, boolean ricercaFascicoliChiusi, boolean escludiClassificaDelPersonale) {

        List<Fascicolo> fascicoli = Fascicolo.createCriteria().list(max: max, offset: offset) {
            fascicoliCriteria(delegate)(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, escludiClassificaDelPersonale, ricercaFascicoliChiusi)

            order("clas.codice", "asc")
            order("anno", "asc")
            order("numeroOrd", "asc")
        }
        return fascicoli
    }

    private PagedResultList ricercaFascicoliTitoliRomani(ClassificazioneDTO ricercaClassificazione, FascicoloDTO ricercaFascicolo, So4UnitaPubbDTO unitaCompetenza, int offset, int max, boolean ricercaFascicoliChiusi, boolean escludiClassificaDelPersonale) {

        if (ricercaFascicoliCount(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, ricercaFascicoliChiusi) > ImpostazioniProtocollo.CLASSFASC_RICERCA_MAX_NUM.valoreInt) {
            return new PagedResultList([], 0)
        }

        List<Fascicolo> list = ricercaFascicoliCriteria(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, escludiClassificaDelPersonale, ricercaFascicoliChiusi, false).unique()

        PagedList pagedList
        if (list) {
            list?.sort { it.numeroOrd }.sort { it.anno }.sort { it.classificazione.codiceDecimale }
            pagedList = calcolaPaginazione(list, offset, max)
        } else {
            pagedList = new PagedList([], 0)
        }
        return new PagedResultList(pagedList, pagedList.totalCount)
    }

    private List<Fascicolo> ricercaFascicoliCriteria(ClassificazioneDTO ricercaClassificazione, FascicoloDTO ricercaFascicolo, So4UnitaPubbDTO unitaCompetenza, boolean escludiClassificaDelPersonale, boolean ricercaFascicoliChiusi, boolean ordina) {

        Fascicolo.createCriteria().list() {
            fascicoliCriteria(delegate)(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, escludiClassificaDelPersonale, ricercaFascicoliChiusi)

            if (ordina) {
                order("clas.codice", "asc")
                order("anno", "asc")
                order("numeroOrd", "asc")
            }
        }
    }

    private def fascicoliCriteria(def delegate) {

        def c = { ricercaClassificazione, ricercaFascicolo, unitaCompetenza, escludiClassificaDelPersonale, ricercaFascicoliChiusi ->
            createAlias('soggetti', 'ds', CriteriaSpecification.INNER_JOIN)
            createAlias("classificazione", "clas")
            isNotNull('anno')
            isNotNull('numero')
            eq("ds.tipoSoggetto", TipoSoggetto.UO_COMPETENZA)

            if (!StringUtils.isEmpty(ricercaFascicolo.numero)) {
                ilike("numero", "${ricercaFascicolo.numero}%")
            }
            // se ho sia oggetto che annoNumero valorizzati, significa che sono in ricerca nella "combobox" e quindi filtro solo per quei valori
            if (!StringUtils.isEmpty(ricercaFascicolo.oggetto) && !StringUtils.isEmpty(ricercaFascicolo.annoNumero)) {
                or {
                    ilike("annoNumero", "%" + ricercaFascicolo.annoNumero + "%")
                    ilike("oggetto", "%" + ricercaFascicolo.oggetto + "%")
                }
            }
            if (!StringUtils.isEmpty(ricercaFascicolo.oggetto) && StringUtils.isEmpty(ricercaFascicolo.annoNumero)) {
                if (ricercaFascicolo.oggetto.trim().startsWith("\"") && ricercaFascicolo.oggetto.endsWith("\"")) {
                    eq("oggetto", ricercaFascicolo.oggetto)
                } else {
                    String[] oggetti = ricercaFascicolo.oggetto.split(" ")
                    and {
                        for (String oggettoAnd : oggetti) {
                            ilike("oggetto", "%" + oggettoAnd + "%")
                        }
                    }
                }
            }
            if (!StringUtils.isEmpty(ricercaFascicolo.note)) {
                ilike("note", "%" + ricercaFascicolo.note + "%")
            }
            if (ricercaFascicolo.anno > 0) {
                eq("anno", ricercaFascicolo.anno)
            }
            if (ricercaClassificazione.id != null) {
                and {
                    eq("clas.id", ricercaClassificazione.id)
                    if (escludiClassificaDelPersonale) {
                        ne("clas.codice", ImpostazioniProtocollo.CLAS_FASC_PERS.valore)
                    }
                }
            } else {
                and {
                    if (!StringUtils.isEmpty(ricercaClassificazione.codice)) {
                        ilike("clas.codice", ricercaClassificazione.codice + "%")
                    }
                    if (!StringUtils.isEmpty(ricercaClassificazione.descrizione)) {
                        ilike("clas.descrizione", "%" + ricercaClassificazione.descrizione + "%")
                    }
                    if (escludiClassificaDelPersonale) {
                        ne("clas.codice", ImpostazioniProtocollo.CLAS_FASC_PERS.valore)
                    }
                }
            }

            if (unitaCompetenza != null && unitaCompetenza?.progr != null) {
                //     unitaCompetenza {
                //         eq("progr", ricercaFascicolo.unitaCompetenza.progr)
                //     }
                eq("ds.unitaSo4.progr", unitaCompetenza.progr.toLong())
            }

       //     if (!ricercaFascicoliChiusi) {
                Date d = new Date()
                le("dataApertura", d)
                or {
                    ge("dataChiusura", d)
                    isNull("dataChiusura")
                }
        //    }

        }
        c.delegate = delegate
        return c
    }

    int ricercaFascicoliCount(ClassificazioneDTO ricercaClassificazione, FascicoloDTO ricercaFascicolo, it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO unitaCompetenza, boolean ricercaFascicoliChiusi) {
        boolean escludiClassificaDelPersonale = false
        if ((ImpostazioniProtocollo.CLAS_FASC_PERS.valore != null && !ImpostazioniProtocollo.CLAS_FASC_PERS.valore.equals(""))) {
            escludiClassificaDelPersonale = !gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.USA_FASCICOLI_PERSONALE)
        }

        Fascicolo.createCriteria().count() {
            fascicoliCriteria(delegate)(ricercaClassificazione, ricercaFascicolo, unitaCompetenza, escludiClassificaDelPersonale, ricercaFascicoliChiusi)
        }
    }

    /**
     * verifica su l'utente ha competeze di lettura sul fascicolo, in caso contrario cambio visualizzazione dell'oggetto con "RISERVATO"
     *
     * @param fascicoli
     */
    List<FascicoloDTO> verificaCompetenzeLetturaFascicolo(List<FascicoloDTO> fascicoli) {
        for (FascicoloDTO fascicolo : fascicoli) {
            verificaCompetenzeLetturaECambiaOggettoFascicoloRiservato(fascicolo)
        }
        return fascicoli
    }

    /**
     *
     * @param fascicolo
     */
    void verificaCompetenzeLetturaECambiaOggettoFascicoloRiservato(FascicoloDTO fascicolo) {
        if (fascicolo.riservato && !hasCompetenzeLetturaFascicolo(fascicolo)) {
            fascicolo.oggetto = "RISERVATO"
        }
    }

    /**
     * Verifica se l'utente ha le competenze di lettura sul fascicolo
     *
     */
    boolean hasCompetenzeLetturaFascicolo(FascicoloDTO fascicolo) {
        Map competenze = gestoreCompetenze.getCompetenzeFascicolo(fascicolo.domainObject)
        if (!competenze || !competenze?.lettura) {
            return false
        }
        return true
    }

    private PagedList calcolaPaginazione(List list, int offset, int max) {
        int totalCount = list.size()
        if (totalCount < offset) {
            offset = 0
        }
        if (totalCount > 0 && totalCount > max) {
            int endIndex = offset + max
            if (endIndex >= list.size()) {
                endIndex = list.size()
            }
            list = list.subList(offset, endIndex)
        }

        return new PagedList(list, totalCount)
    }
}
