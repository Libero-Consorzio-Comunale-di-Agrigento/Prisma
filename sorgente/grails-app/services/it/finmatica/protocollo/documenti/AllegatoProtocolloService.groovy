package it.finmatica.protocollo.documenti

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.firmadigitale.utils.VerificatoreFirma
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoService
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.documentale.IntegrazioneDocumentaleService
import it.finmatica.jsign.api.SignedObjectReaderFactory
import it.finmatica.jsign.api.SignedObjectReaderI
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.viste.Riferimento
import it.finmatica.protocollo.documenti.viste.RiferimentoService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloFile
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.integrazioni.ricercadocumenti.DocumentoEsterno
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.utils.zip.SevenZipUtils
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.File
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.IOUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import sun.net.www.protocol.file.FileURLConnection

import javax.sql.DataSource

@CompileStatic
@Service
@Transactional
class AllegatoProtocolloService {

    public static enum UNIVOCITA_NOMI_FILE {
        OK, KO_PRINCIPALE, KO_ALLEGATO
    }

    @Autowired
    IntegrazioneDocumentaleService integrazioneDocumentaleService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloPkgService protocolloPkgService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    RiferimentoService riferimentoService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DocumentoService documentoService
    @Autowired
    DocumentaleService documentaleService
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    AllegatoRepository allegatoRepository
    @Autowired
    FileDocumentoService fileDocumentoService
    @Autowired
    MailService mailService
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService

    /**
     * Importa i file sul documento principale creando anche i relativi documenti allegati e sostituendo il file principale.
     *
     * @param protocollo
     * @param allegatiDaImportare
     * @param allegatoPrincipale
     * @param copiaFile
     */

    @CompileDynamic
    void importaAllegatiEmail(Protocollo protocollo, List<AllegatoEsterno> allegatiDaImportare, AllegatoEsterno allegatoPrincipale) {
        // evitare la cancellazione dei files
        if (allegatoPrincipale) {
            List<AllegatoEsterno> allegatiDisponibiliPrincipale = getFileDaPec(protocollo)
            boolean contiene = allegatiDisponibiliPrincipale*.idFileEsterno.contains(allegatoPrincipale.idFileEsterno)
            if (!contiene) {
                allegatiDaImportare = allegatiDaImportare + allegatiDisponibiliPrincipale
            }
        }

        if (allegatoPrincipale?.idFileEsterno > 0) {
            if (protocollo.filePrincipale) {
                // trasformo file principale in allegato
                Allegato allegato = new Allegato()
                allegato.descrizione = protocollo.filePrincipale.nome
                allegato.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
                allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
                allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
                allegato.save()
                protocollo.addDocumentoAllegato(allegato)

                FileDocumento fileDocumento = new FileDocumento(nome: protocollo.filePrincipale.nome, contentType: 'application/octet-stream')
                allegato.addToFileDocumenti(fileDocumento)
                allegato.save()

                it.finmatica.smartdoc.api.struct.Documento documentoSmartDoc = new it.finmatica.smartdoc.api.struct.Documento()
                File fileDocumentoSmartDoc = new File()
                fileDocumentoSmartDoc.setId("" + protocollo.filePrincipale.idFileEsterno)
                File file = documentaleService.getFile(documentoSmartDoc, fileDocumentoSmartDoc)

                gestoreFile.addFile(allegato, fileDocumento, file.getInputStream())
                allegato.save()

                if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                    fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
                }
            }

            importaAllegatoPrincipale(protocollo, allegatoPrincipale)
        }

        for (AllegatoEsterno allegato : allegatiDaImportare) {
            if (allegato.idFileEsterno != allegatoPrincipale?.idFileEsterno) {
                importaAllegato(protocollo, allegato)
            }
        }
    }

    /**
     * Ottiene la lista dei file allegati provenienti da PEC non ancora importati nè come file principale nè come file degli allegati.
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    List<AllegatoEsterno> getAllegatiEmailNonImportati(Protocollo protocollo) {
        // ottengo l'elenco dei nomi file allegati alla email
        List<AllegatoEsterno> allegatiEmail = getFileAllegatiEmail(protocollo)

        // ottengo l'elenco dei nomi file allegati al documenti
        List<AllegatoEsterno> allegatiPresenti = getFileAllegatiProtocollo(protocollo)

        // faccio la diff
        // restituisco l'elenco dei nomi file allegati alla email non già allegati al documento.
        for (AllegatoEsterno allegatoEsterno : allegatiPresenti) {
            allegatiEmail.removeAll { it.nome == allegatoEsterno.nome }
        }

        allegatiEmail?.removeAll { it.nome.trim().toLowerCase().equals(MessaggioRicevuto.MESSAGGIO_EML) }

        return allegatiEmail
    }

    @CompileDynamic
    void importaAllegatiDaZip(Allegato allegato, AllegatoEsterno allegatoZipDaCuiImportare, List<AllegatoEsterno> allegatiDaImportare) {
        java.io.File tempZip = getFileTemporaneoZipAllegato(allegatoZipDaCuiImportare)
        Map<String, java.io.File> fileMapEstratti

        try {
            List<String> nomiFileDaEstrarre = new ArrayList<String>()
            for (allegatoEsternoSecondario in allegatiDaImportare) {
                nomiFileDaEstrarre.add(allegatoEsternoSecondario.nome)
            }

            SevenZipUtils zipUtils = new SevenZipUtils()
            fileMapEstratti = zipUtils.extractFromZipFile(tempZip, nomiFileDaEstrarre, "_")

            //Carico gli allegati
            for (allegatoEsterno in allegatiDaImportare) {
                FileDocumento fileDocumento = new FileDocumento(nome: allegatoEsterno.nome, contentType: 'application/octet-stream')
                allegato.addToFileDocumenti(fileDocumento)
                allegato.save()
                gestoreFile.addFile(allegato, fileDocumento, new FileInputStream(fileMapEstratti.get(allegatoEsterno.nome)))
                allegato.save()

                if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                    fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
                    allegato.addToFileDocumenti(fileDocumento)
                }
            }
        } finally {
            //Cancello lo zip
            FileUtils.deleteQuietly(tempZip)

            //Cancello tutti i file temporanei
            if (fileMapEstratti != null) {
                for (itemMapFileEstratti in fileMapEstratti) {
                    FileUtils.deleteQuietly(itemMapFileEstratti.value)
                }
            }
        }
    }

    @CompileDynamic
    void importaAllegatiDaZip(Protocollo protocollo, AllegatoEsterno allegatoZipDaCuiImportare, List<AllegatoEsterno> allegatiSecondariDaImportare, AllegatoEsterno allegatoPrincipale) {
        java.io.File tempZip = getFileTemporaneoZipAllegato(allegatoZipDaCuiImportare)
        Map<String, java.io.File> fileMapEstratti

        try {
            //Carico lo zip come allegato
            Allegato allegato = new Allegato()
            allegato.descrizione = allegatoZipDaCuiImportare.nome
            allegato.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
            allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
            allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
            allegato.save()
            protocollo.addDocumentoAllegato(allegato)
            protocollo.save()

            FileDocumento fileDocumento = new FileDocumento(nome: allegatoZipDaCuiImportare.nome, contentType: 'application/octet-stream')
            allegato.addToFileDocumenti(fileDocumento)
            allegato.save()
            gestoreFile.addFile(allegato, fileDocumento, gestoreFile.getFile(allegatoZipDaCuiImportare.documento, allegatoZipDaCuiImportare))
            allegato.save()

            List<String> nomiFileDaEstrarre = new ArrayList<String>()
            nomiFileDaEstrarre.add(allegatoPrincipale.nome)
            for (allegatoEsternoSecondario in allegatiSecondariDaImportare) {
                nomiFileDaEstrarre.add(allegatoEsternoSecondario.nome)
            }

            SevenZipUtils zipUtils = new SevenZipUtils()
            fileMapEstratti = zipUtils.extractFromZipFile(tempZip, nomiFileDaEstrarre, "_")

            //Carico il file principale sul protocollo
            protocolloService.caricaFilePrincipale(protocollo, new FileInputStream(fileMapEstratti.get(allegatoPrincipale.nome)), 'application/octet-stream', allegatoPrincipale.nome)

            //Carico gli allegati
            for (allegatoEsterno in allegatiSecondariDaImportare) {
                allegato = new Allegato()
                allegato.descrizione = allegatoEsterno.nome
                allegato.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
                allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
                allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
                allegato.save()
                protocollo.addDocumentoAllegato(allegato)
                protocollo.save()

                fileDocumento = new FileDocumento(nome: allegatoEsterno.nome, contentType: 'application/octet-stream')
                allegato.addToFileDocumenti(fileDocumento)
                allegato.save()
                gestoreFile.addFile(allegato, fileDocumento, new FileInputStream(fileMapEstratti.get(allegatoEsterno.nome)))
                allegato.save()

                if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                    fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
                    allegato.addToFileDocumenti(fileDocumento)
                }
            }
        } finally {
            //Cancello lo zip
            FileUtils.deleteQuietly(tempZip)

            //Cancello tutti i file temporanei
            if (fileMapEstratti != null) {
                for (itemMapFileEstratti in fileMapEstratti) {
                    FileUtils.deleteQuietly(itemMapFileEstratti.value)
                }
            }
        }
    }

    @Transactional(readOnly = true)
    java.io.File getFileTemporaneoZipAllegato(AllegatoEsterno allegatoEsterno) {
        InputStream inputStream
        java.io.File tempZip = java.io.File.createTempFile("tempfileToUnzip", "");
        FileOutputStream out = new FileOutputStream(tempZip)
        try {
            inputStream = gestoreFile.getFile(allegatoEsterno.documento, allegatoEsterno)
            IOUtils.copy(inputStream, out)
        } finally {
            IOUtils.closeQuietly((InputStream) inputStream)
            out.close()
        }

        return tempZip
    }

    /**
     * Ottiene l'inputstream della messaggio email.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    InputStream getStreamEmailOriginale(Protocollo protocollo) {
        Long idStream
        Messaggio messaggio = mailService.caricaMessaggioRicevuto(protocollo)
        MessaggioRicevuto messaggioRicevuto = messaggiRicevutiService.getMessaggioRicevutoById(messaggio.id)
        if (messaggioRicevuto == null) {
            idStream = riferimentoService.getIdStreamDaProtocollo(protocollo.idDocumentoEsterno)
        } else {
            idStream = messaggiRicevutiService.getFileDocumentoEml(messaggioRicevuto)?.idFileEsterno
        }
        if (idStream == null) {
            throw new ProtocolloRuntimeException("Non ho trovato il riferimento alla email originale per il documento con id: ${protocollo.idDocumentoEsterno}")
        }

        it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()
        File fileGdm = new File()
        fileGdm.setId("" + idStream)

        File fileMailOriginale = documentaleService.getFile(documentoSmart, fileGdm)

        return fileMailOriginale.inputStream
    }

    /**
     * Ottiene l'elenco dei file con codice 'FILE_DA_MAIL' associati al protocollo.
     * Tali file sono presenti quando il protocollo è stato importato dallo 'scarico pec' e non è stato individuato il file principale.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    List<AllegatoEsterno> getFileDaPec(Protocollo protocollo) {
        List<AllegatoEsterno> fileDaPec = []

        for (FileDocumento fileDocumento : protocollo.fileDocumenti) {
            if (fileDocumento.codice == Protocollo.FILE_DA_MAIL && !fileDocumento.nome.trim().toLowerCase().equals(MessaggioRicevuto.MESSAGGIO_EML)) {
                fileDaPec << new AllegatoEsterno(idFileEsterno: fileDocumento.idFileEsterno
                        , idDocumentoEsterno: protocollo.idDocumentoEsterno
                        , nome: fileDocumento.nome
                        , formatoFile: FilenameUtils.getExtension(fileDocumento.nome)
                        , contentType: fileDocumento.contentType)
            }
        }
        return fileDaPec
    }

    @CompileDynamic
    void cambiaNomeFile(FileDocumento fileDocumento, String nomeFile, String contentType) {
        fileDocumento.nome = nomeFile
        fileDocumento.contentType = contentType
        gestoreFile.renameFileName(fileDocumento.documento.idDocumentoEsterno, fileDocumento.idFileEsterno, nomeFile)
    }

    @CompileDynamic
    void caricaAllegato(Protocollo protocollo, Allegato allegato, String nome, String contentType, InputStream is) {
        allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
        allegato.save()
        protocollo.addDocumentoAllegato(allegato)
        protocollo.save()

        FileDocumento fileDocumento = new FileDocumento(nome: nome, contentType: contentType)
        allegato.addToFileDocumenti(fileDocumento)
        gestoreFile.addFile(allegato, fileDocumento, is)
        allegato.save()

        if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
            fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
            allegato.addToFileDocumenti(fileDocumento)
        }
    }

    /**
     * Importa il singolo allegato copiandone il file oppure spostando solo i riferimenti.
     *
     * Le casistiche di importazione file sono due:
     * 1. il file da importare è collegato su gdm da un riferimento PEC, in tal caso, devo copiare il file sul documento di protocollo
     * 2. il file da importare è già collegato al documento protocollo ma con codice 'FILE_DA_PEC'. In tal caso, si spostano solo i collegamenti su gdm e su agspr senza movimentare i blob.
     *
     * @param protocollo
     * @param allegatoDaImportare
     */
    @CompileDynamic
    private void importaAllegato(Protocollo protocollo, AllegatoEsterno allegatoDaImportare) {
        Allegato allegato = new Allegato()
        allegato.descrizione = allegatoDaImportare.nome
        allegato.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
        allegato.stampaUnica = true
        allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
        allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
        allegato.save()

        FileDocumento fileDocumento = new FileDocumento(nome: allegatoDaImportare.nome, contentType: 'application/octet-stream')
        allegato.addToFileDocumenti(fileDocumento)
        allegato.save()

        protocollo.addDocumentoAllegato(allegato)
        protocollo.save()

        if (allegatoDaImportare.idDocumentoEsterno == protocollo.idDocumentoEsterno) {
            spostaFile(protocollo, allegatoDaImportare, allegato, fileDocumento)
        } else {
            gestoreFile.addFile(allegato, fileDocumento, gestoreFile.getFile(allegatoDaImportare.documento, allegatoDaImportare))
            if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
                allegato.addToFileDocumenti(fileDocumento)
            }
        }
    }

    /**
     * Importa i file collegati allo schema di protocollo
     * @param protocollo
     * @param allegatoDaImportare
     */
    @CompileDynamic
    void importaAllegatoSchemaProtocollo(Protocollo protocollo, SchemaProtocollo schemaProtocollo) {

        for (SchemaProtocolloFile file : schemaProtocollo.files) {
            Allegato allegato = new Allegato()
            allegato.descrizione = file.nome
            allegato.commento = file.nome
            allegato.tipoAllegato = file.tipoAllegato
            allegato.quantita = 1
            allegato.stampaUnica = true
            allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
            allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO() as DocumentoDTO)
            allegato.save()
            protocollo.addDocumentoAllegato(allegato)
            protocollo.save()

            FileDocumento fileDocumento = new FileDocumento(nome: file.nome, contentType: file.contentType)
            allegato.addToFileDocumenti(fileDocumento)
            allegato.save()
            gestoreFile.addFile(allegato, fileDocumento, gestoreFile.getFile(schemaProtocollo, file))
            allegato.save()

            if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
                allegato.addToFileDocumenti(fileDocumento)
            }
        }
    }

    @CompileDynamic
    UNIVOCITA_NOMI_FILE isNomeFileUnivoco(Protocollo protocollo, AllegatoDTO allegatoProvenienza, String nomeFile) {
        boolean isDuplicato = false

        if (nomeFile == protocollo.filePrincipale?.nome ||
                nomeFile == protocollo.fileOriginale?.nome ||
                setNomeFileConEstensioneP7m(allegatoProvenienza?.id, nomeFile, allegatoProvenienza?.statoFirma) == protocollo.filePrincipale?.nome || setNomeFileConEstensioneP7m(allegatoProvenienza?.id, nomeFile, allegatoProvenienza?.statoFirma) == protocollo.fileOriginale?.nome) {
            return UNIVOCITA_NOMI_FILE.KO_PRINCIPALE
        }

        for (Allegato allegato : protocollo.allegati) {
            List<FileDocumento> listaFileDocumento = allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)
            listaFileDocumento.each {
                if (setNomeFileConEstensioneP7m(allegatoProvenienza?.id, nomeFile, allegatoProvenienza?.statoFirma) == it.nome
                        ||
                        nomeFile == setNomeFileConEstensioneP7m(allegato.id, it.nome, allegato.statoFirma)
                        ||
                        setNomeFileConEstensioneP7m(allegatoProvenienza?.id, nomeFile, allegatoProvenienza?.statoFirma) == setNomeFileConEstensioneP7m(allegato.id, it.nome, allegato.statoFirma)
                        ||
                        nomeFile == it.nome) {
                    isDuplicato = true
                }
            }
            if (isDuplicato) {
                return UNIVOCITA_NOMI_FILE.KO_ALLEGATO
            }
        }

        return UNIVOCITA_NOMI_FILE.OK
    }

    @CompileDynamic
    UNIVOCITA_NOMI_FILE isUnivocitaFileAllegati(Protocollo protocollo, AllegatoDTO allegatoProvenienza, StatoFirma statoFirmaInput) {
        boolean isDuplicato = false
        def listFileAllegati = []

        for (Allegato allegato : protocollo.allegati) {
            List<FileDocumento> listaFileDocumento = allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)
            listaFileDocumento.each {
                String tempNomeFile = ""
                if (allegato.id == allegatoProvenienza.id) {
                    tempNomeFile = setNomeFileConEstensioneP7m(null, it.nome, statoFirmaInput)
                } else {
                    tempNomeFile = setNomeFileConEstensioneP7m(allegato.id, it.nome, allegato.statoFirma)
                }
                listFileAllegati << tempNomeFile
            }
            int numeroFiles = listFileAllegati.size()
            int numeroFilesUnivoci = listFileAllegati.unique().size()
            if (numeroFiles != numeroFilesUnivoci) {
                return UNIVOCITA_NOMI_FILE.KO_ALLEGATO
            }
        }

        return UNIVOCITA_NOMI_FILE.OK
    }

    private validaNomiFile(Documento documento) {

        if (documento?.filePrincipale?.nome != null && documento.filePrincipale.nome.lastIndexOf(".") < 1) {
            throw new ProtocolloRuntimeException("Attenzione il nome del file principale non è corretto")
        }

        for (Allegato allegato : documento.allegati) {
            for (FileDocumento fileDocumento : allegato.fileDocumenti) {
                if (fileDocumento.valido) {
                    if (fileDocumento.nome?.lastIndexOf(".") < 1) {
                        throw new ProtocolloRuntimeException("Attenzione il nome di un file dell'allegato " + allegato.descrizione + " non è corretto")
                    }
                }
            }
        }
    }

    private validaNomiFileCaratteriSpeciali(Documento documento) {

        Set<String> caratteriNonConsentiti = new HashSet<>()

        caratteriNonConsentiti.addAll(verificaCaratteriSpeciali(documento?.filePrincipale?.nome))

        for (Allegato allegato : documento.allegati) {
            for (FileDocumento fileDocumento : allegato.fileDocumenti) {
                if (fileDocumento.valido) {
                    caratteriNonConsentiti.addAll(verificaCaratteriSpeciali(fileDocumento.nome))
                }
            }
        }
        if (caratteriNonConsentiti.size() > 0) {
            throw new ProtocolloRuntimeException("Attenzione sono prensenti caratteri non consentiti " + caratteriNonConsentiti.each { it -> it + " " } + " nel nome del documento principale e/o nei nomi degli allegati. Rinominare i files.")
        }
    }

    /**
     *
     * Verifica se il nome di un file contiene caratteri non consentiti
     *
     * @param nomeFile
     * @return
     */
    @Transactional(readOnly = true)
    Set<String> verificaCaratteriSpeciali(String nomeFile) {
        Set<String> caratteriNonConsentiti = new HashSet<>()
        char[] caratteriSpeciali = Impostazioni.CARATTERI_SPECIALI_NOME_FILE.valore.toCharArray()

        if (null != nomeFile) {
            for (char ch : caratteriSpeciali) {
                if (nomeFile.contains(ch.toString())) {
                    caratteriNonConsentiti.add(ch.toString())
                }
            }
        }

        return caratteriNonConsentiti
    }

    /**
     *
     * Il metodo lancia eccezione se il nome dei file importati contengono caratteri non validi
     *
     * @param allegatiEsterni
     */
    void validaNomeAllegatiImport(List<IFileDocumento> allegatiEsterni) {
        Set<String> nomiFilesNonValidi = new HashSet<String>()
        for (IFileDocumento allegatoEsterno : allegatiEsterni) {
            if (verificaCaratteriSpeciali(allegatoEsterno.nome).size() > 0) {
                nomiFilesNonValidi.add(allegatoEsterno.nome)
            }
        }
        if (nomiFilesNonValidi.size() > 0) {
            throw new ProtocolloRuntimeException("Attenzione sono prensenti caratteri non consentiti nei nomi dei files:  " + nomiFilesNonValidi.each { it -> it + " " } + ". Rinominare i files.")
        }
    }

    @CompileDynamic
    private void spostaFile(Protocollo protocollo, AllegatoEsterno fileDaImportare, Allegato allegato, FileDocumento fileDocumento) {
        if (allegato.idDocumentoEsterno == null) {
            allegato.idDocumentoEsterno = integrazioneDocumentaleService.salva(allegato)?.id?.toLong()
        }

        FileDocumento fileDaSpostare = protocollo.fileDocumenti.find {
            it.idFileEsterno == fileDaImportare.idFileEsterno
        }

        protocollo.removeFromFileDocumenti(fileDaSpostare)
        protocollo.save()

        fileDocumento.idFileEsterno = fileDaSpostare.idFileEsterno
        fileDocumento.save()

        // eseguo una update secca su gdm per spostare il file da un documento all'altro:
        protocolloPkgService.spostaFile(protocollo, fileDaImportare, allegato, fileDocumento)
        allegato.addToFileDocumenti(fileDocumento)
        allegato.save()
    }

    @CompileDynamic
    private void importaAllegatoPrincipale(Protocollo protocollo, AllegatoEsterno filePrincipale) {
        // l'allegato da importare come file principale potrebbe già essere collegato al documento, in tal caso devo solo cambiare il tipo di file:
        if (filePrincipale.idDocumentoEsterno == protocollo.idDocumentoEsterno) {
            FileDocumento fileDocumento = protocollo.fileDocumenti.find {
                it.idFileEsterno == filePrincipale.idFileEsterno
            }
            protocollo.removeFromFileDocumenti(fileDocumento)
        }
        protocolloService.caricaFilePrincipale(protocollo, gestoreFile.getFile(new DocumentoEsterno(), filePrincipale), 'application/octet-stream', filePrincipale.nome)
    }

    private List<AllegatoEsterno> getFileAllegatiEmail(Protocollo protocollo) {
        // Ogni riferimento email può essere:
        // 1. o una PEC e in tal caso ho già gli allegati presenti
        Messaggio mail = mailService.caricaMessaggioRicevuto(protocollo)
        MessaggioRicevuto messaggioRicevuto = messaggiRicevutiService.getMessaggioRicevutoById(mail.id)

        if (messaggioRicevuto == null) {
            Riferimento riferimentoEmail = riferimentoService.getRiferimentoMail(protocollo.idDocumentoEsterno)
            if (riferimentoEmail == null) {
                throw new ProtocolloRuntimeException("Non è presente l'email collegata al documento")
            }

            return protocolloGdmService.getFileAllegatiDocumento(riferimentoEmail.idRiferimento)
        } else {
            return getFileAllegatiDocumento(messaggioRicevuto)
        }
    }

    @Transactional(readOnly = true)
    public List<AllegatoEsterno> getFileAllegatiProtocollo(Documento documento) {
        List<AllegatoEsterno> allegati = getFileAllegatiDocumento(documento)

        for (Allegato allegato : documento.allegati) {
            allegati.addAll(getFileAllegatiDocumento(allegato))
        }

        return allegati
    }

    @Transactional(readOnly = true)
    public List<FileDocumento> getFileDocumentiAllegati(Documento documento) {

        List<FileDocumento> fileDocumenti = new ArrayList<FileDocumento>()
        for (Allegato a : documento.allegati) {
            List<FileDocumento> fds = new ArrayList<FileDocumento>()
            for (FileDocumento fd : a.fileDocumenti) {
                fds.add(fd)
            }
            fileDocumenti.addAll(fds)
        }
        return fileDocumenti
    }

    @Transactional(readOnly = true)
    private List<AllegatoEsterno> getFileAllegatiDocumento(Documento documento) {
        List<AllegatoEsterno> nomiFile = []

        if (documento.fileDocumenti != null) {
            for (FileDocumento fileDocumento : documento.fileDocumenti) {
                if (fileDocumento.valido) {
                    nomiFile << new AllegatoEsterno(idFileAllegato: fileDocumento.id, nome: fileDocumento.nome, idDocumentoEsterno: documento.idDocumentoEsterno, idFileEsterno: fileDocumento.idFileEsterno)
                }
            }
        }

        return nomiFile
    }

    String setNomeFileConEstensioneP7m(Long idAllegato, String nomeFile, StatoFirma statoFirma) {

        if (idAllegato > 0) {
            Allegato allegato = allegatoRepository.getAllegatoFromId(idAllegato)

            if (!nomeFile.contains(".p7m") && (!allegato.statoFirma?.daNonFirmare)) {
                nomeFile = nomeFile + ".p7m"
            }
        } else {

            if (!statoFirma) {
                statoFirma = StatoFirma.DA_FIRMARE
            }

            if (!nomeFile.contains(".p7m") && (!statoFirma.daNonFirmare)) {
                nomeFile = nomeFile + ".p7m"
            }
        }

        return nomeFile
    }

    @CompileDynamic
    @Transactional(readOnly = true)
    boolean isFileAllegatoEliminabile(AllegatoDTO allegato) {
        Protocollo protocollo = (Protocollo) allegato.domainObject.getDocumentoPrincipale()
        List<FileDocumento> listaFileDocumento = allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)
        if (ImpostazioniProtocollo.FILE_ALLEGATO_OB.isAbilitato() && protocollo?.numero && listaFileDocumento.size() == 1) {
            return false
        } else {
            return true
        }
    }

    @CompileDynamic
    @Transactional(readOnly = true)
    boolean isValidaFileAllegatoObbligatorio(ProtocolloDTO protocolloDTO) {
        boolean valida = true
        if (ImpostazioniProtocollo.FILE_ALLEGATO_OB.isAbilitato()) {
            for (Allegato allegato : protocolloDTO.domainObject?.allegati) {
                if (allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO).size() == 0) {
                    valida = false
                }
            }
        }
        return valida
    }

    @CompileDynamic
    @Transactional(readOnly = true)
    boolean isAbilitazioneStampaUnica(AllegatoDTO allegato) {
        boolean abilitazione = true
        List<FileDocumento> listaFileDocumento = allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)
        listaFileDocumento.each {
            if (ImpostazioniProtocollo.SU_FORMATI_ESCLUSI.valori.contains(FilenameUtils.getExtension(it.nome.replaceAll('.p7m', '')).toLowerCase())) {
                abilitazione = false
            }
        }
        return abilitazione
    }

    List<VerificatoreFirma.RisultatoVerifica> getFirmatari(Documento documento, IFileDocumento fileDocumento) {
        return new VerificatoreFirma(gestoreFile.getFile(documento, fileDocumento)).verificaFirma()
    }

    boolean isFirmato(Documento documento, IFileDocumento fileDocumento) {
        boolean isFirmato = false
        try {
            SignedObjectReaderI allFirm = SignedObjectReaderFactory.getSignedObjectReader(gestoreFile.getFile(new DocumentoEsterno(), fileDocumento));
            isFirmato = allFirm.isSigned();
        } catch (Exception eSigned) {
            isFirmato = false
        }
        return isFirmato
    }

    @Transactional(readOnly = true)
    long getFileSizeFromUrl(URL url) throws Exception {
        URLConnection urlConnection = null
        HttpURLConnection httpConn = null
        try {
            urlConnection = url.openConnection();
            if (urlConnection instanceof HttpURLConnection) {
                httpConn = (HttpURLConnection) urlConnection;
                httpConn.setRequestMethod("HEAD");
                return httpConn.getContentLengthLong();
            } else if (urlConnection instanceof FileURLConnection) {
                FileURLConnection fileURLConnection = (FileURLConnection) urlConnection;
                return fileURLConnection.getContentLengthLong()
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            if (httpConn != null) {
                httpConn.disconnect();
            }
        }
    }

    @Transactional(readOnly = true)
    List<FileDocumento> getAllegatiByIdAndCodice(Long id, String codice) {
        return allegatoRepository.getFileDocumenti(id, codice)
    }

    @Transactional(readOnly = true)
    File getFile(Long idDocumentale) {
        return documentaleService.getFile(new it.finmatica.smartdoc.api.struct.Documento(), new File(id: "" + idDocumentale))
    }

    @Transactional(readOnly = true)
    boolean presenzaAllegati(Long id) {
        Protocollo protocollo = protocolloService.findById(id)
        FileDocumento principale = protocollo?.filePrincipale
        if (principale) {
            return true
        } else {
            getFileAllegatiProtocollo(protocollo)?.size() > 0
        }
    }
}
