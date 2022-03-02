package it.finmatica.protocollo.integrazioni

import commons.PopupMarcaturaTemporaleViewModel
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.commons.DeleteOnCloseFileInputStream
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.firma.GestioneDocumentiFirmaService
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gestioneiter.IDocumentoIterabile
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.gestioneiter.annotations.Action.TipoAzione
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.TipoFile
import it.finmatica.jsign.verify.api.SimpleVerifier
import it.finmatica.jsign.verify.result.CriticityLevel
import it.finmatica.jsign.verify.result.VerifyResult
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.File
import org.apache.commons.io.FileUtils
import org.apache.commons.io.IOUtils
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.interceptor.TransactionAspectSupport
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Filedownload

/**
 * Contiene le azioni per la firma dei documenti
 */
@Action
class FirmaAction {

    @Autowired GestioneDocumentiFirmaService gestioneDocumentiFirmaService
    @Autowired PrivilegioUtenteService privilegioUtenteService
    @Autowired SpringSecurityService springSecurityService
    @Autowired ProtocolloGdmService protocolloGdmService
    @Autowired ProtocolloService protocolloService
    @Autowired DocumentoService documentoService
    @Autowired SuccessHandler successHandler
    @Autowired WkfIterService wkfIterService
    @Autowired IGestoreFile gestoreFile
    @Autowired SessionFactory sessionFactory
    @Autowired DocumentaleService documentaleService
    @Autowired GestioneTestiService gestioneTestiService

    @Action(tipo = TipoAzione.CLIENT,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Apre la popup di marcatura temporale.",
            descrizione = "Apre la popup di marcatura temporale.")
    void apriPopupMarcaturaTemporale(AbstractViewModel<? extends IDocumentoIterabile> viewModel, long idCfgPulsante, long idAzioneClient) {
        PopupMarcaturaTemporaleViewModel.apriPopup(viewModel.self, viewModel.getDocumentoIterabile(false).toDTO()).addEventListener(Events.ON_CLOSE) {
            // proseguo il pulsante
            wkfIterService.eseguiPulsante(viewModel.getDocumentoIterabile(false), idCfgPulsante, viewModel, idAzioneClient)

            // aggiorno la maschera
            viewModel.aggiornaMaschera(viewModel.getDocumentoIterabile(false))
        }
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Genera l'impronta dei file su gdm",
            descrizione = "Genera l'impronta dei file su gdm.")
    Protocollo generaImpronta(Protocollo protocollo) {
        protocolloGdmService.generaImpronteFile(protocollo)

        successHandler.addMessage("Impronte file generate.")
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA_CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Aggiunge il Firmatario di default per la firma.",
            descrizione = "Aggiunge il Firmatario di default alla coda dei firmatari per la firma, se il firmatario non è valorizzato, utilizza l'utente corrente che viene anche impostato sul documento.")
    Documento addFirmatarioDefault(Documento documento) {
        if (documento.getSoggetto(TipoSoggetto.FIRMATARIO)?.utenteAd4 == null) {
            documento.setSoggetto(TipoSoggetto.FIRMATARIO, springSecurityService.currentUser, null)
            documento.save()
        }

        gestioneDocumentiFirmaService.aggiungiFirmatarioAllaCoda(documento, documento.getSoggetto(TipoSoggetto.FIRMATARIO)?.utenteAd4)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA_CALCOLO_ATTORE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Aggiunge l'utente corrente come firmatario.",
            descrizione = "Aggiunge l'utente corrente come firmatario alla coda dei firmatari per la firma.")
    Documento addFirmatarioUtenteCorrente(Documento documento) {
        Ad4Utente utenteAd4 = springSecurityService.currentUser
        gestioneDocumentiFirmaService.aggiungiFirmatarioAllaCoda(documento, utenteAd4)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara il documento per la firma con allegati.",
            descrizione = "Prepara il firmatario, aggiunge il testo del documento alla firma, aggiunge gli allegati del documento in stato DA_FIRMARE alla firma.")
    Documento predisponiDocumento(Protocollo documento) {
        if (documento.statoFirma == StatoFirma.DA_FIRMARE
                || documento.statoFirma == StatoFirma.FIRMATO_DA_SBLOCCARE) {
            // se è già protocollato non salvo questa riga di storico
            if (documento.data == null) {
                protocolloService.storicizzaProtocollo(documento, documento.iter?.stepCorrente, false)
            }
        }

        predisponiTestoPrincipale(documento)
        predisponiAllegati(documento)

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara il testo principale per la firma (è necessario il modello testo associato)",
            descrizione = "Prepara il firmatario, aggiunge il testo del documento alla firma, non aggiunge gli allegati.")
    Documento predisponiTestoPrincipale(Documento documento) {

        if (documento.filePrincipale == null) {
            throw new ProtocolloRuntimeException("Per continuare è necessario caricare il testo del documento")
        }

        // per dare la possibilità di calcolare correttamente la data di firma sul testo, preparo (se non lo è già), il firmatario:
        gestioneDocumentiFirmaService.preparaFirmatarioInCoda(documento)

        // preparo il documento da firmare
        gestioneDocumentiFirmaService.preparaFilePerFirma(documento.filePrincipale, true, true, true)

        return documento
    }


    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara il documento per la firma doppia con allegati.",
            descrizione = "Prepara la doppia firma, aggiunge il testo del documento alla firma, aggiunge gli allegati del documento in stato DA_FIRMARE alla firma.")
    Documento predisponiDocumentoFirmaDoppia(Protocollo documento) {
        if (documento.statoFirma == StatoFirma.DA_FIRMARE
                || documento.statoFirma == StatoFirma.FIRMATO_DA_SBLOCCARE) {
            // se è già protocollato non salvo questa riga di storico
            if (documento.data == null) {
                protocolloService.storicizzaProtocollo(documento, documento.iter?.stepCorrente, false)
            }
        }

        predisponiTestoPrincipalePerFirmaDoppia(documento)
        predisponiAllegati(documento)

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Elimina il file firmato",
            descrizione = "Elimina il file firmato.")
    Documento eliminaFileFirmato(Documento documento) {

        if (documento.fileOriginale != null) {

            // prima elimino il lock se presente, poi elimino il testo:
            gestioneTestiService.eliminaLock(documentoService.creaIdRiferimento(documento,  documento.filePrincipale), springSecurityService.currentUser)

            //Copio dal file originale, la copia sarà il nuovo Principale
            FileDocumento file = documento.fileOriginale
            FileDocumento filePrincipale = documento.filePrincipale
            FileDocumento copiaFileOriginale = new FileDocumento(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                    , nome: file.nome
                    , contentType: file.contentType
                    , dimensione: file.dimensione
                    , modificabile: true
                    , modelloTesto: file.modelloTesto
                    , firmato: false)

            //Recupero lo stream dell'originale
            InputStream inps = gestoreFile.getFile(documento, file)

            //Rimuovo il principale e il "vecchio" originale
            documento.removeFromFileDocumenti(filePrincipale)
            gestoreFile.removeFile(documento, filePrincipale)

            documento.removeFromFileDocumenti(file)
            gestoreFile.removeFile(documento, file)

            //Salvo il nuovo principale
            gestoreFile.addFile(documento, copiaFileOriginale, inps)
            copiaFileOriginale.save()
        }

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara il testo principale per la firma doppia (è necessario il modello testo associato)",
            descrizione = "Prepara il firmatario, aggiunge il testo del documento alla firma, non aggiunge gli allegati.")
    Documento predisponiTestoPrincipalePerFirmaDoppia(Documento documento) {

        if (documento.filePrincipale == null) {
            throw new ProtocolloRuntimeException("Per continuare è necessario caricare il testo del documento")
        }

        // per dare la possibilità di calcolare correttamente la data di firma sul testo, preparo (se non lo è già), il firmatario:
        gestioneDocumentiFirmaService.preparaFirmatarioInCoda(documento)

        // preparo il documento da firmare
        gestioneDocumentiFirmaService.preparaFilePerFirma(documento.filePrincipale, false, false, false)

        return documento
    }



    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara il testo principale per la firma senza trasformare in pdf (non è necessario il modello testo associato)",
            descrizione = "Prepara il firmatario, aggiunge il testo del documento alla firma, non trasforma in pdf, non aggiunge gli allegati.")
    Documento predisponiFilePrincipaleSenzaTrasformareInPDF(Documento documento) {

        if (documento.filePrincipale == null) {
            throw new ProtocolloRuntimeException("Per continuare è necessario caricare il testo del documento")
        }

        // per dare la possibilità di calcolare correttamente la data di firma sul testo, preparo (se non lo è già), il firmatario:
        gestioneDocumentiFirmaService.preparaFirmatarioInCoda(documento)

        // preparo il documento da firmare
        gestioneDocumentiFirmaService.preparaFilePerFirma(documento.filePrincipale, false, false, true)

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara il testo principale per la firma (trasforma in PDF, ma non è necessario il modello testo)",
            descrizione = "Prepara il firmatario, aggiunge il testo del documento alla firma, non aggiunge gli allegati (trasform in PDF, ma non è necessario il modello testo).")
    Documento predisponiFilePrincipaleTrasformandoInPdf(Documento documento) {

        // per dare la possibilità di calcolare correttamente la data di firma sul testo, preparo (se non lo è già), il firmatario:
        gestioneDocumentiFirmaService.preparaFirmatarioInCoda(documento)

        // preparo il documento da firmare
        gestioneDocumentiFirmaService.preparaFilePerFirma(documento.filePrincipale, true, false, true)

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Prepara gli allegati per la firma.",
            descrizione = "Aggiunge gli allegati del documento contrassegnati come DA_FIRMARE alla firma.")
    Documento predisponiAllegati(Documento documento) {

        // per dare la possibilità di calcolare correttamente la data di firma sul testo, preparo (se non lo è già), il firmatario:
        gestioneDocumentiFirmaService.preparaFirmatarioInCoda(documento)

        // preparo gli allegati del documento principale
        List<Documento> allegati = documento.getAllegati()

        for (Documento allegato : allegati) {
            List<FileDocumento> listaFileDocumento = allegato.getListaFile(FileDocumento.CODICE_FILE_ALLEGATO)
            verificaFilePdfFirmaPADES(allegato, listaFileDocumento)
            gestioneDocumentiFirmaService.preparaFilePerFirma(listaFileDocumento)
        }

        protocolloService.validaDimensioneAllegati(documento, true)
        return documento
    }

    private void verificaFilePdfFirmaPADES(Documento allegato, List<FileDocumento> listaFileDocumento) {
        // Issue #32968
        // Se sto facendo una firma PADES e nell'allegato non ci sono file pdf imposto da non firmare l'allegato
        if (Impostazioni.FIRMA_PADES.abilitato && allegato.statoFirma == StatoFirma.DA_FIRMARE) {
            boolean presentiFilePdf = false
            for (FileDocumento fileDocumento : listaFileDocumento) {
                if (fileDocumento.nome.toLowerCase().endsWith('.pdf')) {
                    presentiFilePdf = true
                    break
                }
            }
            if (!presentiFilePdf) {
                allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
                allegato.save()
            }
        }
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Predispone la Firma",
            descrizione = "Conclude la transazione di firma e costruisce l'url della popup di firma.")
    Documento finalizzaTransazioneFirma(Documento documento) {
        gestioneDocumentiFirmaService.finalizzaTransazioneFirma()
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "predispone la firma autografa",
            descrizione = "conclude la transazione di firma autografa e costruisce l'url della popup di fine firma (non passa dalla firma con smartcard).")
    Documento finalizzaTransazioneFirmaAutografa(Documento documento) {
        gestioneDocumentiFirmaService.finalizzaTransazioneFirmaAutografa()
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Verifica che il testo sia firmato digitalmente",
            descrizione = "Se il testo non è firmato digitalmente, interrompe l'operazione con un errore.")
    Documento verificaTestoFirmato(Documento documento) {
        try {
            SimpleVerifier v = new SimpleVerifier()
            VerifyResult res = v.isSigned(gestoreFile.getFile(documento, documento.filePrincipale))

            // se non è un file firmato correttamente do errore
            if (!res.isValid(CriticityLevel.HIGH)) {
                throw new ProtocolloRuntimeException("Il testo non è firmato correttamente.")
            }
        } catch (Exception e) {
            throw new ProtocolloRuntimeException("Non è possibile verificare la firma del testo. Il testo è firmato correttamente?")
        }

        return documento
    }

    /*
     * Azioni sugli stati di firma
     */

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Imposta il documento come DA FIRMARE",
            descrizione = "Imposta il campo stato_firma = DA_FIRMARE")
    Documento setStatoFirmaDaFirmare(Documento d) {
        d.statoFirma = StatoFirma.DA_FIRMARE
        return d
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento da firmare?",
            descrizione = "Ritorna TRUE se il documento ha stato_firma = DA_FIRMARE, false altrimenti")
    boolean isStatoFirmaDaFirmare(Documento d) {
        return (d.statoFirma == StatoFirma.DA_FIRMARE)
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Imposta il documento come FIRMATO",
            descrizione = "Imposta il campo stato_firma = FIRMATO")
    Documento setStatoFirmaFirmato(Documento d) {
        d.statoFirma = StatoFirma.FIRMATO
        return d
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento è in stato firmato?",
            descrizione = "Ritorna TRUE se il documento ha stato_firma = FIRMATO, false altrimenti")
    boolean isStatoFirmaFirmato(Documento d) {
        return (d.statoFirma == StatoFirma.FIRMATO)
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento è in firma?",
            descrizione = "Ritorna TRUE se il documento ha stato_firma = IN_FIRMA, false altrimenti")
    boolean isStatoFirmaInFirma(Documento d) {
        return (d.statoFirma == StatoFirma.IN_FIRMA)
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Imposta il documento come DA NON FIRMARE",
            descrizione = "Imposta il campo stato_firma = DA_NON_FIRMARE")
    Documento setStatoFirmaDaNonFirmare(Documento d) {
        d.statoFirma = StatoFirma.DA_NON_FIRMARE
        return d
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Reset del campo stato firma",
            descrizione = "Reset del campo stato firma")
    Documento resetStatoFirma(Documento d) {
        d.statoFirma = null
        return d
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento è da non firmare?",
            descrizione = "Ritorna TRUE se il documento ha stato_firma = DA_NON_FIRMARE, false altrimenti")
    boolean isStatoFirmaDaNonFirmare(Documento d) {
        return (d.statoFirma == StatoFirma.DA_NON_FIRMARE)
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento non è ancora stato firmato?",
            descrizione = "Ritorna TRUE se non è stato ancora firmato.")
    boolean isDocumentoNonFirmato(Documento d) {
        return !d.filePrincipale?.isFirmato()
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Gli Allegati sono già stati firmati?",
            descrizione = "Ritorna TRUE se gli allegati già stati firmati, FALSE altrimenti.")
    boolean isAllegatiFirmati(Documento d) {
        List<Allegato> allegati = d.getAllegati()
        if (allegati.size() == 0) {
            return false
        }
        for (Allegato a : allegati) {
            if (a.statoFirma != StatoFirma.FIRMATO) {
                return false
            }
        }
        return true
    }

    @Action(tipo = Action.TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna TRUE se il protocollo manuale è da firmare",
            descrizione = "Ritorna TRUE se: l'utente ha il privilegio di FIRMA, il file principale esiste e non è firmato, il documento non è protocollato")
    boolean isProtocolloManualeDaFirmare(Protocollo documento) {

        if (!documento) {
            return false
        }

        if (documento.movimento == Protocollo.MOVIMENTO_ARRIVO) {
            return false
        }

        if (!documento.statoFirma.daFirmare) {
            return false
        }

        if (documento.numero > 0) {
            return false
        }

        if (documento.filePrincipale == null) {
            return false
        }

        if (documento.filePrincipale.firmato) {
            return false
        }

        return privilegioUtenteService.isPuoFirmare(documento)
    }

    @Action(tipo = TipoAzione.PULSANTE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Anteprima del Testo",
            descrizione = "Scarica l'anteprima del testo con tutti i campi valorizzati.")
    Protocollo scaricaAnteprimaTesto(Protocollo documento, AbstractViewModel<? extends IDocumentoIterabile> viewModel) {
        InputStream anteprimaIn
        InputStream anteprimaPdfIn
        OutputStream anteprimaOut
        java.io.File fileAnteprima
        try {
            anteprimaIn = gestoreFile.getFile(documento, documento.filePrincipale)
            anteprimaPdfIn = documentoService.convertiStreamInPdf(anteprimaIn)
            fileAnteprima = java.io.File.createTempFile("anteprima", "tmp")
            anteprimaOut = new FileOutputStream(fileAnteprima)
            IOUtils.copy(anteprimaPdfIn, anteprimaOut)
        } finally {
            IOUtils.closeQuietly((InputStream) anteprimaIn)
            IOUtils.closeQuietly((InputStream) anteprimaPdfIn)
            IOUtils.closeQuietly((OutputStream) anteprimaOut)
        }

        OutputStream watermarkedOut
        java.io.File fileWatermarked
        try {
            fileWatermarked = java.io.File.createTempFile("watermarked", "tmp")
            anteprimaIn = new FileInputStream(fileAnteprima)
            watermarkedOut = new FileOutputStream(fileWatermarked)
            documentoService.applicaWatermarkFacsimile(anteprimaIn, watermarkedOut)

            DeleteOnCloseFileInputStream deleteOnCloseFile = new DeleteOnCloseFileInputStream(fileWatermarked)
            Filedownload.save(deleteOnCloseFile, TipoFile.PDF.contentType, "anteprima.pdf")

        } finally {
            IOUtils.closeQuietly((InputStream) anteprimaIn)
            IOUtils.closeQuietly((OutputStream) watermarkedOut)
            FileUtils.deleteQuietly(fileAnteprima)
        }

        // interrompo la transazione e faccio rollback di tutto
        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly()
       // sessionFactory.getCurrentSession().getTransaction().rollback()
        return documento
    }

}
