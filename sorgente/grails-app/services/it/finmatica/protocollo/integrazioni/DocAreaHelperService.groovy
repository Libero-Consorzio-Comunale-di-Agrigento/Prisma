package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.anagrafica.As4Anagrafica
import it.finmatica.as4.anagrafica.As4Contatto
import it.finmatica.as4.anagrafica.As4Recapito
import it.finmatica.as4.dizionari.As4TipoSoggetto
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Indirizzo
import it.finmatica.protocollo.corrispondenti.IndirizzoDTO
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.corrispondenti.TipoSoggettoRepository
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.ContentTypeManager
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.as4.As4Repository
import it.finmatica.protocollo.integrazioni.jdocarea.AOO
import it.finmatica.protocollo.integrazioni.jdocarea.Allegati
import it.finmatica.protocollo.integrazioni.jdocarea.Amministrazione
import it.finmatica.protocollo.integrazioni.jdocarea.Destinatario
import it.finmatica.protocollo.integrazioni.jdocarea.Documento
import it.finmatica.protocollo.integrazioni.jdocarea.IdentificatoreDocPrincipale
import it.finmatica.protocollo.integrazioni.jdocarea.Intestazione
import it.finmatica.protocollo.integrazioni.jdocarea.Mittente
import it.finmatica.protocollo.integrazioni.jdocarea.Parametro
import it.finmatica.protocollo.integrazioni.jdocarea.Persona
import it.finmatica.protocollo.integrazioni.jdocarea.Segnatura
import it.finmatica.protocollo.integrazioni.jdocarea.SegnaturaDocPrincipale
import it.finmatica.protocollo.integrazioni.jdocarea.SegnaturaService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.integrazioni.ws.AggiungiAllegatoRet
import it.finmatica.protocollo.integrazioni.ws.DocAreaAttachmentHandler
import it.finmatica.protocollo.integrazioni.ws.DocAreaAuthHelper
import it.finmatica.protocollo.integrazioni.ws.InserimentoRet
import it.finmatica.protocollo.integrazioni.ws.LoginRet
import it.finmatica.protocollo.integrazioni.ws.ObjectFactory
import it.finmatica.protocollo.integrazioni.ws.ProtocollazioneRet
import it.finmatica.protocollo.integrazioni.ws.SmistamentoActionRet
import it.finmatica.protocollo.integrazioni.ws.SostituisciDocumentoPrincipaleRet
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.segreteria.common.ParametriSegreteria
import it.finmatica.segreteria.common.struttura.CostantiSmistamento
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.apache.commons.lang3.time.DateUtils
import org.apache.commons.lang3.time.FastDateFormat
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.context.request.RequestAttributes
import org.springframework.web.context.request.RequestContextHolder

import javax.annotation.PostConstruct
import javax.persistence.NonUniqueResultException
import javax.xml.soap.AttachmentPart
import java.nio.charset.StandardCharsets
import java.text.SimpleDateFormat

@CompileStatic
@Service
@Transactional
@Slf4j
class DocAreaHelperService {
    private ObjectFactory of = new ObjectFactory()

    @Autowired DocAreaTokenService docAreaTokenService
    @Autowired DocAreaFileService docAreaFileService
    @Autowired DocAreaAuthHelper docAreaAuthHelper
    @Autowired SegnaturaService segnaturaService
    @Autowired ClassificazioneService classificazioneService
    @Autowired FascicoloRepository fascicoloRepository
    @Autowired So4UnitaPubbService so4UnitaPubbService
    @Autowired DizionariRepository dizionariRepository
    @Autowired ProtocolloService protocolloService
    @Autowired WkfIterService wkfIterService
    @Autowired IGestoreFile gestoreFile
    @Autowired DocumentoService documentoService
    @Autowired SpringSecurityService springSecurityService
    @Autowired So4Repository so4Repository
    @Autowired CorrispondenteService corrispondenteService
    @Autowired SmistamentoService smistamentoService
    @Autowired ProtocolloAction protocolloAction
    @Autowired ContentTypeManager contentTypeManager
    @Autowired UserDetailsService userDetailsService
    @Autowired As4AnagraficiRecapitiRepository as4AnagraficiRecapitiRepository
    @Autowired As4Repository as4Repository
    @Autowired TipoSoggettoRepository tipoSoggettoRepository

    @Value('${finmatica.docArea.whitelistNoCompetenze:""}')
    private List<String> listaUtentiWitheList


    private FastDateFormat fdf = FastDateFormat.getInstance('dd/MM/yyyy')



    private static final String COD_MOVIMENTO_FLUSSO_ARR = 'E'
    private static final String COD_MOVIMENTO_FLUSSO_PAR = 'U'
    private static final String COD_MOVIMENTO_FLUSSO_INT = 'I'

    private TipoSoggettoDTO TIPO_SOGGETTO_ALTRI
    private TipoSoggettoDTO TIPO_SOGGETTO_AMMINISTRAZIONE

    InserimentoRet inserimento(String strUserName, String strDST) {
        RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes()
        AttachmentPart attach = requestAttributes.getAttribute(DocAreaAttachmentHandler.ATTACHMENT_ATTRIBUTE, 0) as AttachmentPart
        byte[] file =  attach?.dataHandler?.inputStream?.bytes
        String contentType = attach?.contentType
        return doInserimento(strDST, strUserName, contentType, file)
    }

    InserimentoRet doInserimento(String strDST, String strUserName, String contentType, byte[] file) {
        InserimentoRet ret = new InserimentoRet()
        if(file == null || file.length == 0) {
            ret.lngErrNumber = ErroriWsDocarea.IMPORTAZIONE_ALLEGATO_MANCANTE.codice
            ret.strErrString = of.createInserimentoRetStrErrString("Errore in fase di importazione del documento: allegato mancante. Il file passato e' di 0 Byte")
            return ret
        }
        initRet(ret)
        DocAreaToken token = docAreaTokenService.findByTokenAndUsername(strDST, strUserName)
        if (token) {
            DocAreaFile f = new DocAreaFile()
            f.token = token
            f.contentType = contentType ?: contentTypeManager.guessContentType(file)
            f.content = file
            DocAreaFile fileSalvato = docAreaFileService.save(f)
            ret.lngDocID = fileSalvato.id
        } else {
            checkUsername(strUserName,ret,ErroriWsDocarea.DST_INVALIDO)
        }
        return ret
    }

    ProtocollazioneRet protocollazione(String strUserName, String strDST) {
        String xmlSegnatura = readXml()
        doProtocollazione(strUserName,strDST,xmlSegnatura)
    }
    ProtocollazioneRet doProtocollazione(String username, String strDST,String xmlSegnatura) {
        ProtocollazioneRet ret = doProtocollazioneInternal(username,strDST,xmlSegnatura)
        if(ret.lngErrNumber.intValue() != ErroriWsDocarea.SUCCESSO.codice) {
            throw new DocAreaProtocollazioneException(ret)
        } else {
            return ret
        }
    }

    private ProtocollazioneRet doProtocollazioneInternal(String username, String strDST,String xmlSegnatura) {
        ProtocollazioneRet ret = new ProtocollazioneRet()
        initRet(ret)
        Map segn = autenticaELeggiSegnatura(strDST,username,xmlSegnatura)
        if(segn) {
            ErroriWsDocarea errore = segn.errore as ErroriWsDocarea
            if(errore) {
                // errore di autenticazione
                ret.lngErrNumber = errore.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(errore.messaggio)
                return ret
            }
            Segnatura segnatura = segn.segnatura as Segnatura
            ProtocollazioneRet err = validate(ret,segnatura)
            if(err) {
                // se check è valorizzato vuol dire che la validazione non è andata a buon fine
                return err
            }
            Ente ente = segn.ente as Ente
            Ad4Utente user = springSecurityService.currentUser
            Protocollo p = new Protocollo()
            p.note = 'WS'
            p.dataRedazione = new Date()
            p.tipoOggetto = dizionariRepository.getTipoOggetto(Protocollo.TIPO_DOCUMENTO)
            p.tipoProtocollo = dizionariRepository.getTipoProtocollo(Protocollo.CATEGORIA_PROTOCOLLO)
            if(segnatura.descrizione.documento.tipoDocumento) {
                p.schemaProtocollo = dizionariRepository.getSchemaProtocollo(segnatura.descrizione.documento.tipoDocumento.content)
            }
            So4Amministrazione amm = ente.amministrazione
            Intestazione intestazione = segnatura.intestazione
            if(!intestazione.destinatario) {
                ret.lngErrNumber = ErroriWsDocarea.ERRORE_INTERNO.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.ERRORE_INTERNO.messaggio)
                return ret
            }
            p.oggetto = intestazione.oggetto

            p.classificazione = classificazioneService.findByCodice(intestazione.classifica.codiceTitolario)
            Fascicolo fNull = null
            p.fascicolo = intestazione.fascicolo ? fascicoloRepository.getFascicolo(p.classificazione.id,Integer.valueOf(intestazione.fascicolo.anno),intestazione.fascicolo.numero) : fNull
            // salvo a questo punto se no ho problemi se inserisco un corrispondente o altro
            protocolloService.salva(p, true,true,true)
            p.smistamenti = new HashSet<>()
            List<Parametro> parametri = segnatura.applicativoProtocollo.parametro
            String up = parametri.find {it.nome == 'uo'}?.valore
            List so4UnitaPubbs = so4UnitaPubbService.cercaUnitaPubb(amm.codice, Impostazioni.OTTICA_SO4.valore)
            So4UnitaPubb unitaProtocollante = so4UnitaPubbs.find {it.codice == up}
            DocumentoSoggetto unitaProt = new DocumentoSoggetto()
            unitaProt.unitaSo4 = unitaProtocollante
            unitaProt.tipoSoggetto = TipoSoggetto.UO_PROTOCOLLANTE
            unitaProt.attivo = true
            p.addToSoggetti(unitaProt)
            List<SmistamentoDTO> smistamentoDTOList = creaSmistamenti(parametri, so4UnitaPubbs)
            for(smist in smistamentoDTOList) {
                if(!smist.unitaSmistamento) {
                    ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_ERRORE.codice
                    ret.strErrString = of.createProtocollazioneRetStrErrString('Unità di smistamento inesistente')
                    return ret
                }
            }
            String movimento = intestazione.identificatore.flusso
            switch(movimento) {
                case(ParametriSegreteria.CODICE_MOVIMENTO_ARRIVO):
                case(COD_MOVIMENTO_FLUSSO_ARR):
                    p.movimento = Protocollo.MOVIMENTO_ARRIVO
                    if(intestazione.destinatario) {
                        addSmistamentoDestinatario(intestazione, so4UnitaPubbs, parametri, user, smistamentoDTOList)
                    }
                    if(!intestazione.mittente) {
                        ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_ERRORE.codice
                        ret.strErrString = of.createProtocollazioneRetStrErrString('Mittente assente per flusso E')
                        return ret
                    }
                    break
                case(ParametriSegreteria.CODICE_MOVIMENTO_PARTENZA):
                case(COD_MOVIMENTO_FLUSSO_PAR):
                    p.movimento = Protocollo.MOVIMENTO_PARTENZA
                    if(intestazione.mittente) {
                        addSmistamentoMittente(intestazione, so4UnitaPubbs, parametri, user, smistamentoDTOList)
                    }
                    if(!intestazione.destinatario) {
                        ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_ERRORE.codice
                        ret.strErrString = of.createProtocollazioneRetStrErrString('Destinatario assente per flusso U')
                        return ret
                    }
                    break
                case(ParametriSegreteria.CODICE_MOVIMENTO_INTERNO):
                case(COD_MOVIMENTO_FLUSSO_INT):
                    p.movimento = Protocollo.MOVIMENTO_INTERNO;
                    if(intestazione.mittente) {
                        addSmistamentoMittente(intestazione, so4UnitaPubbs, parametri, user, smistamentoDTOList)
                    } else if(intestazione.destinatario) {
                        addSmistamentoDestinatario(intestazione, so4UnitaPubbs, parametri, user, smistamentoDTOList)
                    }
                    break

            }
            Parametro annoPrec = parametri.find {it.nome == 'annoPrecedente'}
            Parametro numeroPrec = parametri.find {it.nome == 'numeroPrecedente'}
            Parametro dataDocumento = parametri.find {it.nome == "dataDocumento"}
            if(dataDocumento) {
                p.dataDocumentoEsterno = DateUtils.parseDate(dataDocumento.valore,'dd/MM/yyyy')
            }

            def tipoProtocollo = dizionariRepository.getTipoProtocolloDefault(Protocollo.TIPO_DOCUMENTO)
            p.tipoProtocollo = tipoProtocollo
            p.tipoRegistro = p.schemaProtocollo?.tipoRegistro ?: tipoProtocollo.tipoRegistro

            if(unitaProtocollante) {
                p.setSoggetto(TipoSoggetto.UO_PROTOCOLLANTE, null, unitaProtocollante)
            }
            p.setSoggetto(TipoSoggetto.REDATTORE, user, unitaProtocollante)
            // il destinatario rappresenta uno smistamento
            List<CorrispondenteDTO> nuoviDest = []
            List<Destinatario> destinatari = intestazione.destinatario
            if(p.movimento == Protocollo.MOVIMENTO_PARTENZA) {
                for (dest in destinatari) {
                    def pers = dest.persona
                    CorrispondenteDTO destinatario = new CorrispondenteDTO()
                    destinatario.tipoSoggetto = getTipoSoggettoAltri()
                    if (dest.amministrazione) {
                        List<CorrispondenteDTO> destinatariRic = corrispondenteService.ricercaDestinatari(null, true, null, null, null, null, null, null, null, null, null, dest.amministrazione.codiceAmministrazione,dest.AOO?.codiceAOO)
                        if (destinatariRic) {
                            destinatario = destinatariRic.first() as CorrispondenteDTO
                        } else {
                            destinatario.codiceAmministrazione = dest.amministrazione.codiceAmministrazione
                            destinatario.indirizzo = dest.amministrazione.indirizzoPostale ?: ''
                            destinatario.email = dest.amministrazione.indirizzoTelematico?.content ?: ''
                            destinatario.tipoIndirizzo = 'AMM'
                            destinatario.tipoSoggetto = getTipoSoggettoAmministrazione()
                            if(dest.AOO) {
                                destinatario.aoo = dest.AOO.codiceAOO
                            }
                        }
                    } else if (pers) {
                        try {
                            destinatario = trovaPersona(pers)
                        } catch(NonUniqueResultException e) {
                            ret.lngErrNumber = ErroriWsDocarea.ERRORE_INTERNO.codice
                            ret.strErrString = of.createProtocollazioneRetStrErrString("Errore destinatario: ${e.message}")
                            return ret
                        }
                    } else if (dest.indirizzoTelematico) {
                        def destinatariRic = corrispondenteService.ricercaDestinatari(null, true, null, null, null, null, dest.indirizzoTelematico.content)
                        if (destinatariRic) {
                            destinatario = destinatariRic.first() as CorrispondenteDTO
                        } else {
                            destinatario.nome = pers.nome
                            destinatario.cognome = pers.cognome
                            destinatario.codiceFiscale = pers.codiceFiscale
                            destinatario.email = pers.indirizzoTelematico?.content
                        }
                    } else {
                        destinatario = null
                    }
                    if(destinatario) {
                        destinatario.tipoCorrispondente = Corrispondente.DESTINATARIO
                        nuoviDest << destinatario
                    }
                }
            }

            if(smistamentoDTOList?.find{it.unitaSmistamento == null}) {
                ret.lngErrNumber = ErroriWsDocarea.ERRORE_INTERNO.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString('Unità di smistamento inesistente')
                return ret
            }

            // uso la variante con tre boolean perché devo forzare il mancato controllo delle competenze
            protocolloService.salva(p, true, true, listaUtentiWitheList.contains(username))
            if(p.movimento == Protocollo.MOVIMENTO_ARRIVO) {
                List<Mittente> mittenti = intestazione.mittente
                for (mitt in mittenti) {
                    if (mitt?.persona || mitt?.AOO || mitt?.amministrazione) {
                        CorrispondenteDTO mittente = null
                        if (mitt.amministrazione) {
                            List<CorrispondenteDTO> destinatariRic = corrispondenteService.ricercaDestinatari(null, true, null, null, null, null, null, null, null, null, null, mitt.amministrazione.codiceAmministrazione,mitt.AOO?.codiceAOO)
                            if (destinatariRic) {
                                mittente = destinatariRic.first() as CorrispondenteDTO
                            } else {
                                mittente.codiceAmministrazione = mitt.amministrazione.codiceAmministrazione
                                mittente.indirizzo = mitt.amministrazione.indirizzoPostale ?: ''
                                mittente.email = mitt.amministrazione.indirizzoTelematico?.content ?: ''
                                mittente.tipoIndirizzo = 'AMM'
                                if(mitt.AOO) {
                                    mittente.aoo = mitt.AOO.codiceAOO
                                }
                            }
                        } else if (mitt.persona) {
                            try {
                                mittente = trovaPersona(mitt.persona)
                            } catch(NonUniqueResultException e) {
                                ret.lngErrNumber = ErroriWsDocarea.ERRORE_INTERNO.codice
                                ret.strErrString = of.createProtocollazioneRetStrErrString("Errore mittente: ${e.message}")
                                return ret
                            }
                        }
                        if(mittente) {
                            mittente.tipoCorrispondente = Corrispondente.MITTENTE
                            nuoviDest << mittente
                        }
                    }
                }
            }
            if(nuoviDest) {
                for(CorrispondenteDTO corrispondente in nuoviDest) {
                    if(!corrispondente.tipoSoggetto?.id) {
                        corrispondente.tipoSoggetto = getTipoSoggettoAltri()
                    }
                    //if(corrispondente.tipoSoggetto.id == getTipoSoggettoAmministrazione().id) {
                      //  caricaIndirizzi(corrispondente)
                    //}
                }
                corrispondenteService.salva(p, nuoviDest)
            }

            if(annoPrec && numeroPrec) {
                Protocollo precedente = protocolloService.findByAnnoAndNumeroAndTipoRegistro(Integer.valueOf(annoPrec.valore), Integer.valueOf(numeroPrec.valore))
                if(precedente) {
                    p.addDocumentoCollegato(precedente, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
                }
            }
            if(segnatura.descrizione.documento) {
                // questo è il file principale
                Documento filePrinc = segnatura.descrizione.documento
                DocAreaFile docAreaFile = docAreaFileService.findById(filePrinc.id)
                GestioneTestiModello modelloTesto = null
                if (p.tipoProtocollo != null) {
                    modelloTesto = getModelloTestoPredefinito(p.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE)
                }

                FileDocumento fileAllegato = new FileDocumento(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                        , nome: filePrinc.nome
                        , contentType: docAreaFile.contentType
                        , valido: true
                        , modificabile: true
                        , firmato: false
                        , modelloTesto: modelloTesto)
                p.addToFileDocumenti(fileAllegato)
                salvaAllegato(fileAllegato,p,docAreaFile.content)

            }
            if(segnatura.descrizione.allegati) {
                // questi sono gli allegati
                int sequenza = 1
                try {
                    salvaAllegati(segnatura.descrizione.allegati, sequenza, p)
                } catch(IllegalArgumentException e) {
                    ret.lngErrNumber = ErroriWsDocarea.IMPORTAZIONE_ALLEGATO_MANCANTE.codice
                    ret.strErrString = of.createProtocollazioneRetStrErrString('Allegato mancante')
                    return ret
                }
            }
            protocolloService.protocolla(p)
            // gli smistamenti non funzionano se salvati prima della protocollazione
            if(smistamentoDTOList) {
                smistamentoService.salva(p.toDTO() as ProtocolloDTO, smistamentoDTOList)
            }
            try {
                protocolloAction.invioSmistamenti(p)
            } catch (Exception e) {
                log.error("Impossibile inviare gli smistamenti",e)
            }
            try {
                wkfIterService.istanziaIter(p.tipoProtocollo.getCfgIter(), p)
            } catch (Exception e) {
                log.error("impossibile avviare l'iter",e)
                ret.strErrString = of.createProtocollazioneRetStrErrString(e.getMessage())
                ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_ERRORE.codice
            }
            ret.lngAnnoPG = p.anno?.longValue() ?: 0
            ret.lngNumPG = p.numero?.longValue() ?: 0
            ret.strDataPG = of.createProtocollazioneRetStrDataPG(p.data ? new SimpleDateFormat('dd/MM/yyyy').format(p.data) : '')

        } else {
            checkUsername(username,ret,ErroriWsDocarea.DST_INVALIDO)
        }
        return ret
    }

    void addSmistamentoMittente(Intestazione intestazione, List<So4UnitaPubb> so4UnitaPubbs, List<Parametro> parametri, Ad4Utente user, List<SmistamentoDTO> smistamentoDTOList) {
        Mittente mitt = intestazione.mittente.first()
        if (mitt?.amministrazione) {
            def codiceUo = mitt.amministrazione.unitaOrganizzativa?.id
            if (codiceUo) {
                So4UnitaPubb unitaSmist = so4UnitaPubbs.find {
                    it.codice == codiceUo
                }
                Smistamento smistamento = new Smistamento(tipoSmistamento: parametri.find { it.nome == 'tipoSmistamento' }?.valore,
                        unitaSmistamento: unitaSmist,
                        utenteTrasmissione: user,
                        statoSmistamento: Smistamento.CREATO)
                smistamentoDTOList.add(smistamento.toDTO() as SmistamentoDTO)
            }
        }
    }

    void addSmistamentoDestinatario(Intestazione intestazione, List<So4UnitaPubb> so4UnitaPubbs, List<Parametro> parametri, Ad4Utente user, List<SmistamentoDTO> smistamentoDTOList) {
        Destinatario dest = intestazione.destinatario.first()
        if (dest?.amministrazione) {
            def codiceUo = dest.amministrazione.unitaOrganizzativa?.id
            if (codiceUo) {
                So4UnitaPubb unitaSmist = so4UnitaPubbs.find {
                    it.codice == codiceUo
                }
                Smistamento smistamento = new Smistamento(tipoSmistamento: parametri.find { it.nome == 'tipoSmistamento' }?.valore,
                        unitaSmistamento: unitaSmist,
                        utenteTrasmissione: user,
                        statoSmistamento: Smistamento.CREATO)
                smistamentoDTOList.add(smistamento.toDTO() as SmistamentoDTO)
            }
        }
    }

    CorrispondenteDTO trovaPersona(Persona pers) throws NonUniqueResultException {
        CorrispondenteDTO corrispondente = null
        if (pers.id) {
            // è il codice fiscale o la partita iva
            def corrisp = as4AnagraficiRecapitiRepository.findAnagraficaByCFOrPIVA(pers.id)
            if (corrisp && corrisp.size() == 1) {
                corrispondente = toCorrispondenteDTO(corrisp.first())
            } else if(corrisp && corrisp.size() > 1) {
                throw new NonUniqueResultException("Codice fiscale o partita IVA ${pers.id} non univoco")
            }
        } else if (pers.idSoggetto && pers.idRecapito) {
            // oppure è una ricerca su as4
            As4AnagrificiRecapiti rec
            def idSoggetto = Long.valueOf(pers.idSoggetto)
            def idRecapito = Long.valueOf(pers.idRecapito)
            if (pers.idContatto) {
                rec = as4AnagraficiRecapitiRepository.findFirstByIdSoggettoAndIdRecapitoAndIdContatto(idSoggetto, idRecapito, Long.valueOf(pers.idContatto))
            } else {
                rec = as4AnagraficiRecapitiRepository.findFirstByIdSoggettoAndIdRecapito(idSoggetto, idRecapito)
            }
            if (rec) {
                //corrispondenteService.ricercaPiDenom(rec.codiceFiscale ?: rec.partitaIva, null, true)
                def corrisp = as4AnagraficiRecapitiRepository.findAnagraficaByCFOrPIVA(rec.codiceFiscale ?: rec.partitaIva)
                if (corrisp && corrisp.size() == 1) {
                    corrispondente = toCorrispondenteDTO(corrisp.first())
                } else if(corrisp && corrisp.size() > 1) {
                    throw new NonUniqueResultException("Codice fiscale o partita IVA ${rec.codiceFiscale ?: rec.partitaIva} non univoco")
                }
            }
        } else if(ImpostazioniProtocollo.CERCA_NOME_COGNOME.abilitato) {
            // provo una ricerca generica, ma solo se il parametro è abilitato
            def destinatariRic = corrispondenteService.ricercaDestinatari(null, true, "${pers.nome} ${pers.cognome}".toString(), null, pers.codiceFiscale, null)
            if (destinatariRic && destinatariRic.size() == 1) {
                corrispondente = (destinatariRic.first() as CorrispondenteDTO)
            } else if (destinatariRic && destinatariRic.size() > 1) {
                throw new NonUniqueResultException("Codice fiscale ${pers.codiceFiscale} o nome e cognome ${pers.nome} ${pers.cognome} non univoco")
            }

        }
        // se sono arrivato qua è un nuovo contatto
        if (!corrispondente) {
            corrispondente = new CorrispondenteDTO()
            corrispondente.nome = pers.nome
            corrispondente.cognome = pers.cognome
            corrispondente.codiceFiscale = pers.codiceFiscale
            corrispondente.email = pers.indirizzoTelematico?.content
            corrispondente.tipoSoggetto = getTipoSoggettoAltri()
        }
        if(!corrispondente.tipoSoggetto?.id) {
            corrispondente.tipoSoggetto = getTipoSoggettoAltri()
        }
        return corrispondente
    }

    private CorrispondenteDTO toCorrispondenteDTO(As4Anagrafica anag) {
        CorrispondenteDTO corr = new CorrispondenteDTO()
        corr.partitaIva = anag.partitaIva
        corr.codiceFiscale = anag.codFiscale
        corr.nome = anag.nome
        corr.cognome = anag.cognome
        corr.denominazione = anag.denominazione
        corr.ni = anag.ni
        corr.tipoSoggetto = toTipoSoggetto(anag.tipoSoggetto) ?: corr.tipoSoggetto
        As4SoggettoCorrente soggettoCorrente = as4Repository.getSoggettoCorrente(anag.ni)
        if(soggettoCorrente) {
            corr.email = soggettoCorrente.indirizzoWeb
            corr.indirizzo = soggettoCorrente.indirizzoResidenza ?: soggettoCorrente.indirizzoDomicilio
            corr.comune = soggettoCorrente.comuneResidenza?.denominazione ?: soggettoCorrente.comuneDomicilio?.denominazione
            corr.provinciaSigla = soggettoCorrente.provinciaResidenza?.sigla ?: soggettoCorrente.provinciaDomicilio?.sigla
            corr.cap = soggettoCorrente.capResidenza ?: soggettoCorrente.capDomicilio
            corr.tipoIndirizzo = soggettoCorrente.indirizzoResidenza ? 'RESIDENZA' : 'DOMICILIO'
        }

        return corr
    }

    TipoSoggettoDTO toTipoSoggetto(As4TipoSoggetto tp) {
        if(tp) {
            TipoSoggettoDTO res = new TipoSoggettoDTO()
            res.descrizione = tp.descrizione
            return res
        } else {
            return null
        }
    }

    SostituisciDocumentoPrincipaleRet sostituisciDocumentoPrincipale(String strUserName,String strDST) {
        String xmlSegnatura = readXml()
        return doSostituisciDocumentoPrincipale(strDST, strUserName, xmlSegnatura)
    }

    SostituisciDocumentoPrincipaleRet doSostituisciDocumentoPrincipale(String strDST, String strUserName, String xmlSegnatura) {
        SostituisciDocumentoPrincipaleRet ret = new SostituisciDocumentoPrincipaleRet()
        initRet(ret)
        Map segnatura = autenticaELeggiSegnaturaDocPrincipale(strDST, strUserName, xmlSegnatura)
        if (segnatura) {
            ErroriWsDocarea errore = segnatura.errore as ErroriWsDocarea
            if(errore) {
                // errore di autenticazione
                ret.lngErrNumber = errore.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(errore.messaggio)
                return ret
            }
            SegnaturaDocPrincipale segn = segnatura.segnatura as SegnaturaDocPrincipale
            Documento documento = segn.descrizione.documento
            DocAreaFile docAreaFile = docAreaFileService.findById(documento.id)
            IdentificatoreDocPrincipale identificatore = segn.intestazione.identificatore
            Protocollo protocollo = protocolloService.findByAnnoAndNumeroAndTipoRegistro(Integer.valueOf(identificatore.annoProtocollo), Integer.valueOf(identificatore.numeroProtocollo), identificatore.tipoRegistroProtocollo)
            if(!protocollo) {
                ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.messaggio)
                return ret
            }
            if (docAreaFile) {
                protocolloService.caricaFilePrincipale(protocollo, new ByteArrayInputStream(docAreaFile.content), docAreaFile.contentType, documento.nome)
            }
            ret.lngDocID = protocollo.filePrincipale.id
        } else {
            checkUsername(strUserName,ret,ErroriWsDocarea.DST_INVALIDO)
        }
        return ret
    }

    AggiungiAllegatoRet aggiungiAllegato(String strUserName, String strDST) {
        String xmlSegnatura = readXml()
        return doAggiungiAllegato(strDST, strUserName, xmlSegnatura)
    }

    AggiungiAllegatoRet doAggiungiAllegato(String strDST, String strUserName, String xmlSegnatura) {
        AggiungiAllegatoRet ret = new AggiungiAllegatoRet()
        initRet(ret)
        Map segnatura = autenticaELeggiSegnaturaDocPrincipale(strDST, strUserName, xmlSegnatura)
        if (segnatura) {
            ErroriWsDocarea errore = segnatura.errore as ErroriWsDocarea
            if(errore) {
                // errore di autenticazione
                ret.lngErrNumber = errore.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(errore.messaggio)
                return ret
            }
            SegnaturaDocPrincipale segn = segnatura.segnatura as SegnaturaDocPrincipale
            IdentificatoreDocPrincipale identificatore = segn.intestazione.identificatore
            Protocollo protocollo = protocolloService.findByAnnoAndNumeroAndTipoRegistro(Integer.valueOf(identificatore.annoProtocollo), Integer.valueOf(identificatore.numeroProtocollo), identificatore.tipoRegistroProtocollo)
            if(!protocollo) {
                ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.messaggio)
                return ret
            }
            if (segn.descrizione.allegati) {
                int sequenza = (protocollo.allegati?.size() ?: 0) + 1
                try {
                    ret.lngDocID = salvaAllegati(segn.descrizione.allegati, sequenza, protocollo) ?: 0
                } catch (IllegalArgumentException e) {
                    ret.lngErrNumber = ErroriWsDocarea.IMPORTAZIONE_ALLEGATO_MANCANTE.codice
                    ret.strErrString = of.createProtocollazioneRetStrErrString('Allegato mancante')
                    return ret
                }
            }
        } else {
            checkUsername(strUserName,ret,ErroriWsDocarea.DST_INVALIDO)
        }
        return ret
    }

    SmistamentoActionRet smistamentoAction(String strUserName, String strDST) {
        String xmlSegnatura = readXml()
        return doSimistamanentoAction(strDST, strUserName, xmlSegnatura)
    }

    SmistamentoActionRet doSimistamanentoAction(String strDST, String strUserName, String xmlSegnatura) {
        SmistamentoActionRet ret = new SmistamentoActionRet()
        initRet(ret)
        Map segnatura = autenticaELeggiSegnaturaDocPrincipale(strDST, strUserName, xmlSegnatura)
        if (segnatura) {
            ErroriWsDocarea errore = segnatura.errore as ErroriWsDocarea
            if(errore) {
                // errore di autenticazione
                ret.lngErrNumber = errore.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(errore.messaggio)
                return ret
            }
            SegnaturaDocPrincipale segn = segnatura.segnatura as SegnaturaDocPrincipale
            IdentificatoreDocPrincipale identificatore = segn.intestazione.identificatore
            Protocollo protocollo = protocolloService.findByAnnoAndNumeroAndTipoRegistro(Integer.valueOf(identificatore.annoProtocollo), Integer.valueOf(identificatore.numeroProtocollo), identificatore.tipoRegistroProtocollo)
            if(!protocollo) {
                ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.messaggio)
                return ret
            }
            List<Parametro> parametri = segn.applicativoProtocollo.parametro
            Ente e = segnatura.ente as Ente
            So4Amministrazione amm = e.amministrazione
            String uo = parametri.find {it.nome == 'uo'}?.valore
            String azione = parametri.find {it.nome == 'azione'}?.valore
            def smistamenti = protocollo.smistamenti.findAll {it.unitaSmistamento.codice == uo}
            if(smistamenti) {
                for (Smistamento smist in smistamenti) {
                    if (azione == 'ESEGUI') {
                        smistamentoService.eseguiSmistamento(smist, springSecurityService.currentUser)
                    } else if (azione == 'CARICO') {
                        smistamentoService.prendiInCarico(protocollo, springSecurityService.currentUser, [smist])
                    }
                    ret.lngDocID = smist.id
                }
            } else {
                ret.lngErrNumber = ErroriWsDocarea.ERRORE_INTERNO.codice
                ret.strErrString = of.createSmistamentoActionRetStrErrString("Smistamento non valido")
            }
        } else {
            checkUsername(strUserName,ret,ErroriWsDocarea.DST_INVALIDO)
        }
        return ret
    }

    LoginRet loginAoo(String strCodEnte,String strAoo,String strUserName,String strPassword) {
        LoginRet ret = new LoginRet()
        initRet(ret)
        try {
             docAreaAuthHelper.authenticate(strUserName, strPassword)
        } catch(BadCredentialsException bce) {
            ret.lngErrNumber = ErroriWsDocarea.LOGIN_INVALIDO.codice
            ret.strErrString = of.createLoginRetStrErrString(ErroriWsDocarea.LOGIN_INVALIDO.messaggio)
            return ret
        }
        Ente ente = strAoo ? docAreaTokenService.findEnteByCodiceAndAoo(strCodEnte, strAoo) : docAreaTokenService.findEnteByCodice(strCodEnte)
        if (ente) {
            docAreaAuthHelper.autenticaEnte(strUserName, ente.id)
            DocAreaToken token = docAreaTokenService.save(new DocAreaToken())
            ret.strDST = of.createLoginRetStrDST(token.token)
        } else {
            ret.lngErrNumber = ErroriWsDocarea.ENTE_INESISTENTE.codice
            ret.strErrString = of.createLoginRetStrErrString(ErroriWsDocarea.ENTE_INESISTENTE.messaggio)
        }
        return ret
    }

    private List<SmistamentoDTO> creaSmistamenti(List<Parametro> parametri, List<So4UnitaPubb> so4UnitaPubbs) {
        List<String> smistamenti = parametri.findAll { it.nome == 'smistamento' }.collect { it.valore }
        List<SmistamentoDTO> smistamentoDTOList = []
        for (smist in smistamenti) {
            String[] split = smist.split('@@')
            String unitaSmistamento = split[0]
            String tipoSmistamento = split[1]
            Smistamento smistamento = new Smistamento()
            smistamento.unitaSmistamento = so4UnitaPubbs.find { it.codice == unitaSmistamento }
            smistamento.tipoSmistamento = tipoSmistamento
            smistamento.statoSmistamento = Smistamento.CREATO

            smistamentoDTOList.add(smistamento.toDTO() as SmistamentoDTO)
        }
        smistamentoDTOList
    }

    private Long salvaAllegati(Allegati allegati, final int sequenzaIniziale, Protocollo protocollo) {
        int sequenza = sequenzaIniziale
        Long idDocumento
        for (documento in allegati.documento) {
            Allegato allegato = new Allegato()
            DocAreaFile docAreaFile = docAreaFileService.findById(documento.id)
            if(!docAreaFile) {
                throw new IllegalArgumentException("File non trovato")
            }
            allegato.descrizione = documento.nome
            allegato.commento = documento.nome
            allegato.origine = "WS"
            allegato.ubicazione = "WS"
            allegato.tipoAllegato = dizionariRepository.getTipoAllegatoDaAcronimo(documento.tipoDocumento?.content ?: '0000')
            allegato.sequenza = sequenza++
            salvaFile(allegato, documento, protocollo, docAreaFile.contentType, docAreaFile.content)
            idDocumento =  allegato.idDocumento
        }
        return idDocumento
    }

    @CompileDynamic
    private static GestioneTestiModello getModelloTestoPredefinito(Long tipoProtocolloId, String codiceFile) {
        TipoProtocollo.modelloTestoPredefinito(tipoProtocolloId, codiceFile).get()
    }

    @CompileDynamic
    private void salvaAllegato(FileDocumento fileAllegato,Protocollo protocollo,byte[] content) {
        fileAllegato.save()
        gestoreFile.addFile(protocollo, fileAllegato, new ByteArrayInputStream(content))
    }

    @CompileDynamic
    private void salvaFile(Allegato allegato, Documento documento, Protocollo protocollo, String contentType, byte[] content) {
        allegato.save()
        protocollo.addDocumentoAllegato(allegato)
        documentoService.uploadFile(allegato, documento.nome, contentType, new ByteArrayInputStream(content))
    }

    private So4UnitaPubb findUnita(String codice) {
        so4Repository.getUnitaByCodiceSo4(codice)
    }

    private Map autenticaELeggiSegnatura(String strDST, String strUserName, String xmlSegnatura) {
        ErroriWsDocarea errore = null
        DocAreaToken token = docAreaTokenService.findByTokenAndUsername(strDST,strUserName)
        if(token) {
            Ente e = token.ente
            Segnatura segnatura = segnaturaService.leggiSegnatura(xmlSegnatura)
            Parametro parametro = segnatura.applicativoProtocollo?.parametro?.find { it.nome == 'utente' }
            if(parametro) {
                try {
                    userDetailsService.loadUserByUsername(parametro.valore)
                } catch(UsernameNotFoundException ex) {
                    errore = ErroriWsDocarea.ERRORE_INTERNO
                }
            }
            if(!errore) {
                docAreaAuthHelper.autenticaEnte(parametro ? parametro.valore : strUserName, e.id)
            }
            return [segnatura:segnatura,ente:e, errore: errore]
        }  else {
            return null
        }
    }

    private String readXml() {
        String xmlSegnatura
        RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes()
        AttachmentPart attach = requestAttributes.getAttribute(DocAreaAttachmentHandler.ATTACHMENT_ATTRIBUTE, 0) as AttachmentPart
        InputStream file = attach.dataHandler.inputStream
        file.withCloseable {
            xmlSegnatura = file.getText(StandardCharsets.ISO_8859_1.name())
        }
        xmlSegnatura
    }

    private Map autenticaELeggiSegnaturaDocPrincipale(String strDST, String strUserName, String xmlSegnatura) {
        ErroriWsDocarea errore = null
        DocAreaToken token = docAreaTokenService.findByTokenAndUsername(strDST,strUserName)
        if(token) {
            Ente e = token.ente
            SegnaturaDocPrincipale segnatura = segnaturaService.leggiSegnaturaDocPrincipale(xmlSegnatura)
            Parametro parametro = segnatura.applicativoProtocollo?.parametro?.find { it.nome == 'UTENTE' }
            if(parametro) {
                try {
                    userDetailsService.loadUserByUsername(parametro.valore)
                } catch(UsernameNotFoundException ex) {
                    errore = ErroriWsDocarea.ERRORE_INTERNO
                }
            }
            if(!errore) {
                docAreaAuthHelper.autenticaEnte(parametro ? parametro.valore : strUserName, e.id)
            }
            return [segnatura:segnatura,ente:e, errore:errore]
        }  else {
            return null
        }
    }

    @CompileDynamic
    private initRet(def ret) {
        ret.lngErrNumber = ErroriWsDocarea.SUCCESSO.codice
        ret.strErrString = of.createLoginRetStrErrString(ErroriWsDocarea.SUCCESSO.messaggio)
    }

    @CompileDynamic
    private checkUsername(String username, def ret, ErroriWsDocarea fallback) {
        try {
            // non sono interessato al ritorno
            userDetailsService.loadUserByUsername(username)
            ret.lngErrNumber = fallback.codice
            ret.strErrString = of.createLoginRetStrErrString(fallback.messaggio)
        } catch (UsernameNotFoundException e) {
            ret.lngErrNumber = ErroriWsDocarea.LOGIN_USERID_INVALIDA.codice
            ret.strErrString = of.createLoginRetStrErrString(ErroriWsDocarea.LOGIN_USERID_INVALIDA.messaggio)
        }
    }

    private ProtocollazioneRet validate(ProtocollazioneRet ret, Segnatura segnatura) {
        Classificazione cl = classificazioneService.findByCodice(segnatura.intestazione?.classifica?.codiceTitolario)
        if(!cl && ImpostazioniProtocollo.CLASS_OB.abilitato) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_TITOLARIO_INESISTENTE.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_TITOLARIO_INESISTENTE.messaggio)
            return ret
        }
        if(cl?.al != null && cl?.al?.before(new Date())) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_TITOLARIO_CHIUSO.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_TITOLARIO_CHIUSO.messaggio)
            return ret
        }
        if(segnatura.intestazione.fascicolo && segnatura.intestazione.fascicolo.anno && segnatura.intestazione.fascicolo.numero) {
            Fascicolo fasc = fascicoloRepository.getFascicolo(cl.id, Integer.valueOf(segnatura.intestazione.fascicolo.anno), segnatura.intestazione.fascicolo.numero)
            if (!fasc) {
                ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_FASCICOLO_INESISTENTE.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_FASCICOLO_INESISTENTE.messaggio)
                return ret
            }
        } else if(ImpostazioniProtocollo.FASC_OB.abilitato) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_ERRORE.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString("Fascicolo assente")
            return ret
        }
        if(!segnatura.intestazione.oggetto) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_OGGETTO_NON_COMPILATO.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_OGGETTO_NON_COMPILATO.messaggio)
            return ret
        }
        if(!segnatura.descrizione.documento?.id) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_PRINCIPALE_ASSENTE.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_PRINCIPALE_ASSENTE.messaggio)
            return ret
        }
        def tipoDoc = segnatura.descrizione.documento?.tipoDocumento?.content
        boolean tipoDocAssente = !tipoDoc && ImpostazioniProtocollo.TIPO_DOC_OB.isAbilitato()
        if((tipoDoc && !dizionariRepository.getSchemaProtocollo(tipoDoc))|| tipoDocAssente) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_TIPO_DOCUMENTO_INESISTENTE.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_TIPO_DOCUMENTO_INESISTENTE.messaggio)
            return ret
        }
        if(segnatura.descrizione.documento) {
            DocAreaFile file = docAreaFileService.findById(segnatura.descrizione.documento.id)
            if(!file) {
                ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.codice
                ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_INESISTENTE.messaggio)
                return ret
            }
        }  else if(ImpostazioniProtocollo.FILE_OB.isAbilitato()) {
            ret.lngErrNumber = ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_PRINCIPALE_ASSENTE.codice
            ret.strErrString = of.createProtocollazioneRetStrErrString(ErroriWsDocarea.PROTOCOLLAZIONE_DOCUMENTO_PRINCIPALE_ASSENTE.messaggio)
            return ret
        }
        return null
    }

    private boolean isEmpty(Destinatario destinatario) {
        !destinatario.AOO && !destinatario.indirizzoTelematico && !destinatario.persona && !destinatario.amministrazione
    }

    private TipoSoggettoDTO getTipoSoggettoAltri() {
        // costretto a fare inizializzazione lazy perché al momento della postConstuct la sessionFactory non è ancora stata inizializzata
        if(!TIPO_SOGGETTO_ALTRI) {
            TIPO_SOGGETTO_ALTRI = tipoSoggettoRepository.findOne(1L).toDTO() as TipoSoggettoDTO
        }
        return TIPO_SOGGETTO_ALTRI
    }

    private TipoSoggettoDTO getTipoSoggettoAmministrazione() {
        // costretto a fare inizializzazione lazy perché al momento della postConstuct la sessionFactory non è ancora stata inizializzata
        if(!TIPO_SOGGETTO_AMMINISTRAZIONE) {
            TIPO_SOGGETTO_AMMINISTRAZIONE = tipoSoggettoRepository.findOne(2L).toDTO() as TipoSoggettoDTO
        }
        return TIPO_SOGGETTO_AMMINISTRAZIONE
    }
}
