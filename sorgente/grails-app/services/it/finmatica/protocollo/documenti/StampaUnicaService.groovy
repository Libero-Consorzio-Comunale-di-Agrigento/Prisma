package it.finmatica.protocollo.documenti

import com.itextpdf.text.Document
import com.itextpdf.text.Element
import com.itextpdf.text.Font
import com.itextpdf.text.Phrase
import com.itextpdf.text.pdf.BaseFont
import com.itextpdf.text.pdf.ColumnText
import com.itextpdf.text.pdf.PdfContentByte
import com.itextpdf.text.pdf.PdfCopy
import com.itextpdf.text.pdf.PdfImportedPage
import com.itextpdf.text.pdf.PdfReader
import com.itextpdf.text.pdf.PdfStamper
import com.itextpdf.text.pdf.PdfWriter
import groovy.util.logging.Slf4j
import it.finmatica.firmadigitale.utils.VerificatoreFirma
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.TipoFile
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.jsign.api.SignedObjectReaderFactory
import it.finmatica.jsign.api.SignedObjectReaderI
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.segreteria.common.FirmaUtilities
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.io.IOUtils
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.zul.Filedownload

import javax.servlet.http.HttpServletResponse

@Slf4j
@Transactional
@Service
class StampaUnicaService {

    @Autowired
    GestioneTestiService gestioneTestiService
    @Autowired
    DocumentoService documentoService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    AllegatoRepository allegatoRepository

    long sommaDimensioneAllegati(Protocollo protocollo) {
        long somma = 0
        for (Allegato allegato : protocollo.getAllegati()) {
            if (!allegato.valido) {
                continue
            }

            // sommo solo gli allegati dei visti validi
            somma += sommaFileAllegati(allegato)
        }
        return somma
    }

    /**
     * Calcola la somma dei file allegati a un documento
     * @param documento
     * @param codiciFile
     * @return
     */
    long sommaFileAllegati(Allegato allegato, List<String> codiciFile = [FileDocumento.CODICE_FILE_ALLEGATO]) {
        // dato un documento, devo recuperare tutti gli allegati caricati dall'utente impostati per andare in stampa unica:
        return (long) (Allegato.createCriteria().get {
            createAlias('fileDocumenti', 'fd', CriteriaSpecification.LEFT_JOIN)

            projections {
                sum("fd.dimensione")
            }

            eq("id", allegato.id)
            eq("valido", true)
            eq("fd.valido", true)
            'in'("fd.codice", codiciFile)
            eq("stampaUnica", true)
        } ?: 0)
    }

    void creaStampaUnicaProtocollo(long idProtocollo, String utente, long idEnte, Closure postCreazioneStampa) {
        Utils.eseguiAutenticazione(utente, idEnte)
        Protocollo protocollo = Protocollo.get(idProtocollo)
        creaAllegatoStampaUnica(protocollo, ImpostazioniProtocollo.STAMPA_UNICA_FRASE_FOOTER.valore, protocollo.nomeFileStampaUnica)
        postCreazioneStampa()
    }

    File getStampaUnicaProtocollo(Protocollo protocollo) {
        return creaStampaUnica(protocollo, ImpostazioniProtocollo.STAMPA_UNICA_FRASE_FOOTER.valore)
    }

    Allegato creaAllegatoStampaUnica(Documento documento, String fraseFooter = "Copia Informatica per Consultazione", String nomeFile = "stampa unica.pdf") {

        File stampaUnicaFile
        try {
            // genero la stampa unica
            stampaUnicaFile = creaStampaUnica(documento, fraseFooter)

            // se non ho creato la stampa unica, esco
            if (stampaUnicaFile == null) {
                return
            }

            // Ottengo l'allegato della stampa unica, se presente:
            Allegato allegatoStampaUnica = getAllegatoStampaUnica(documento)

            FileDocumento stampaUnica = allegatoStampaUnica.getFile(FileDocumento.CODICE_FILE_ALLEGATO)
            if (stampaUnica == null) {
                stampaUnica = new FileDocumento(codice: FileDocumento.CODICE_FILE_ALLEGATO, nome: nomeFile, contentType: GestioneTestiService.getContentType(GestioneTestiService.FORMATO_PDF), dimensione: -1, modificabile: false)
                allegatoStampaUnica.addToFileDocumenti(stampaUnica)
                allegatoStampaUnica.save()
            } else {
                stampaUnica.nome = nomeFile
                stampaUnica.save()
            }

            gestoreFile.addFile(allegatoStampaUnica, stampaUnica, stampaUnicaFile.newInputStream(), true)
            documento.save()

            return allegatoStampaUnica
        } finally {
            FileUtils.deleteQuietly(stampaUnicaFile)
        }
    }

    Allegato getAllegatoStampaUnica(Protocollo documento) {

        Allegato stampaUnica = documento.getAllegati().find {
            it.tipoAllegato.codice == TipoAllegato.CODICE_TIPO_STAMPA_UNICA
        }

        if (stampaUnica == null) {
            stampaUnica = new Allegato()
            stampaUnica.tipoAllegato = TipoAllegato.findByCodiceAndValido(TipoAllegato.CODICE_TIPO_STAMPA_UNICA, true)
            stampaUnica.descrizione = "Stampa Unica"
            stampaUnica.stampaUnica = false    // la stampa unica non può andare in "stampa unica"
            stampaUnica.sequenza = documento.getAllegati().size() + 1
            stampaUnica.save()
            documento.addDocumentoAllegato(stampaUnica)
            documento.save()
        }

        return stampaUnica
    }

    File creaStampaUnica(Protocollo documento, String fraseFooter) {
        ArrayList<File> files = []
        boolean eliminaFile = true
        FileOutputStream out
        try {
            // aggiungo il file frontespizio
            List<GestioneTestiModello> modelloTesti = TipoProtocollo.modelliTesto(documento.tipoProtocollo.id, FileDocumento.CODICE_FILE_FRONTESPIZIO).list()

            if (modelloTesti.size() > 0) {
                FileDocumento fileDocumentoFrontespizio = documento.getFileFrontespizio()
                if (fileDocumentoFrontespizio == null) {
                    fileDocumentoFrontespizio = new FileDocumento(modelloTesto: modelloTesti.get(0), codice: FileDocumento.CODICE_FILE_FRONTESPIZIO, nome: "Frontespizio." + modelloTesti.get(0).tipo, contentType: GestioneTestiService.getContentType(modelloTesti.get(0).tipo), valido: true, modificabile: false, firmato: false)
                    documento.addToFileDocumenti(fileDocumentoFrontespizio)
                    fileDocumentoFrontespizio.save()
                    documento.save()
                    InputStream inputStream = documentoService.generaStreamTestoDocumento(fileDocumentoFrontespizio, modelloTesti.get(0).tipo, true, [id: documento.id])
                    File fileFrontespizio = generaFileFrontespizio(fileDocumentoFrontespizio, inputStream)
                    files.addAll([fileFrontespizio])
                }
            }

            // aggiungo il file principale
            files.addAll(aggiungiFile(documento, [FileDocumento.CODICE_FILE_PRINCIPALE]))

            // aggiungo i vari allegati
            files.addAll(aggiungiFileAllegati(documento.getAllegati()))

            // se non ho file da mettere in stampa unica, non la genero:
            if (files.size() == 0) {
                log.warn("stampaUnica: Non ho pdf da mettere in stampa unica, non la creo.")
                return null
            }

            log.debug("stampaUnica: eseguo l'unione dei vari pdf (scrivo sul filesystem).")
            File fileTemporaneoSU = File.createTempFile("STAMPA_UNICA", "tmp")
            out = new FileOutputStream(fileTemporaneoSU)

            unisciFilePdf(out, files, fraseFooter, documento)

            return fileTemporaneoSU
        } catch (Throwable t) {
            // in caso di eccezione non eliminare i file (per evenutale debug)
            eliminaFile = false
            throw t
        } finally {
            if (out != null) {
                IOUtils.closeQuietly(out)
            }
            if (eliminaFile) {
                files*.delete()
                // eliminare anche il frontespizio WHAT???? Creo la stampa unica ed ELIMINO il frontespizio?? WHY??
                FileDocumento frontestpizio = documento.getFileFrontespizio()
                if (frontestpizio != null) {
                    documentoService.eliminaFileDocumento(documento, frontestpizio)
                }
            }
        }
    }

    void creaAllegatoCopiaConforme(Protocollo protocollo) {
        // ottengo l'allegato della copia conforme (se presente)
        Allegato copiaConforme = (Allegato) protocollo.getAllegati().find {
            it.tipoAllegato.acronimo == ImpostazioniProtocollo.ALLEGATO_COPIA_CONFORME.valore
        }

        // se il file non è firmato, elimino l'allegato presente
        if (copiaConforme != null && !protocollo.filePrincipale.firmato) {
            documentoService.eliminaAllegato(copiaConforme)
            copiaConforme = null
        }

        String nomeFileCopiaConforme = "CC_" + String.valueOf(protocollo.numero) + "_" + protocollo.filePrincipale.nome
        if (nomeFileCopiaConforme.toLowerCase().endsWith(".p7m")) {
            nomeFileCopiaConforme = nomeFileCopiaConforme.substring(0, nomeFileCopiaConforme.toLowerCase().lastIndexOf(".p7m"))
        }

        FileDocumento fileCopiaConforme = copiaConforme?.fileDocumenti?.first()

        // creo l'allegato se non l'ho già:
        if (copiaConforme == null) {
            copiaConforme = new Allegato()
            copiaConforme.descrizione = "Copia conforme del documento principale"
            copiaConforme.tipoAllegato = TipoAllegato.findByAcronimo(ImpostazioniProtocollo.ALLEGATO_COPIA_CONFORME.valore)
            copiaConforme.stampaUnica = false
            copiaConforme.statoFirma = StatoFirma.DA_NON_FIRMARE
            copiaConforme.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
            copiaConforme.save()

            fileCopiaConforme = new FileDocumento(nome: nomeFileCopiaConforme, contentType: TipoFile.PDF.contentType)
            copiaConforme.addToFileDocumenti(fileCopiaConforme)
            copiaConforme.save()

            protocollo.addDocumentoAllegato(copiaConforme)
            protocollo.save()
        }

        InputStream is
        def listaFirmatari = []

        // ottengo l'input stream:
        is = gestoreFile.getFile(protocollo, protocollo.filePrincipale, true)

        if (is == null) {
            throw new ProtocolloRuntimeException("Attenzione! File non trovato!")
        }

        //Recupero la lista dei firmatari
        try {
            listaFirmatari = new VerificatoreFirma(is).verificaFirma()
        }
        catch (Exception e) {
            log.error("Si è verificato un errore nella estrapolazione della lista dei firmatari", e)
        }

        is = rileggoFilePrincipale(protocollo)

        try {

            if (FirmaUtilities.isSigned(is, protocollo.filePrincipale.nome)) {
                is = rileggoFilePrincipale(protocollo)
                SignedObjectReaderI reader = SignedObjectReaderFactory.getSignedObjectReader(is);
                log.debug("convertiPdf: ${protocollo.filePrincipale.nome} è firmato, lo sbusto")
                is = reader.getOriginalContent()

                if (!protocollo.filePrincipale.nomeFileSbustato.toLowerCase()?.endsWith(".pdf")) {
                    try {
                        log.debug("convertiPdf: tento di convertire il file ${protocollo.filePrincipale.nome} in pdf")
                        is = gestioneTestiService.converti(is, GestioneTestiService.FORMATO_PDF)
                    } catch (Throwable e) {
                        log.warn("Non sono riuscito a convertire l'allegato con id=${protocollo.filePrincipale.id} nomefile=${protocollo.filePrincipale.nome}.", e)
                        throw new ProtocolloRuntimeException("Non è possibile creare la copia conforme per il file " + protocollo.filePrincipale.nome)
                    } finally {
                        if (is != null) {
                            IOUtils.closeQuietly(is)
                        }
                    }
                }

            } else {
                is = rileggoFilePrincipale(protocollo)
            }
        } catch (Exception e) {
            throw new ProtocolloRuntimeException("Non è possibile creare la copia conforme per il file " + protocollo.filePrincipale.nome)
        }

        File temp = File.createTempFile("COPIA_CONFORME", "tmp");
        FileOutputStream out;
        try {

            out = creaCopiaConforme(protocollo, is, new FileOutputStream(temp), listaFirmatari, protocollo.filePrincipale.firmato);
            is = new FileInputStream(temp);

        } catch (Exception e) {

            throw new ProtocolloRuntimeException(e.message)

        } finally {
            FileUtils.deleteQuietly(temp);
            IOUtils.closeQuietly((OutputStream) out);
        }

        if (!nomeFileCopiaConforme.toLowerCase().endsWith('.pdf')) {
            fileCopiaConforme.nome = nomeFileCopiaConforme + '.pdf'
        } else {
            fileCopiaConforme.nome = nomeFileCopiaConforme
        }
        gestoreFile.addFile(copiaConforme, fileCopiaConforme, is, true)
    }

    private InputStream rileggoFilePrincipale(Protocollo protocollo) {
        //Rileggo l'input stream perchè già letto dalla funzione verificaFirma
        FileDocumento filePrincipale = protocollo.filePrincipale
        InputStream is = gestoreFile.getFile(protocollo, filePrincipale, true)

        // se il file ha un estensione tra queste posso convertire altrimenti non si puo'
        if (!filePrincipale.isPdf() && !filePrincipale.isP7m() && filePrincipale.convertibilePdf) {
            // se devo scaricare il pdf, eseguo la conversione solo se il file non è già PDF o P7M.
            is = gestioneTestiService.converti(is, GestioneTestiService.FORMATO_PDF)
        }
        return is
    }

    private File convertiPdf(Documento documento, FileDocumento fileAllegato) {
        // se odt va trasformato in pdf, se pdf bene, se p7m va estratto pdf.
        InputStream inputStream = gestoreFile.getFile(documento, fileAllegato)

        if (FirmaUtilities.isSigned(inputStream, fileAllegato.nome)) {
            inputStream = gestoreFile.getFile(documento, fileAllegato)
            SignedObjectReaderI reader = SignedObjectReaderFactory.getSignedObjectReader(inputStream);
            log.debug("convertiPdf: ${fileAllegato.nome} è firmato, lo sbusto")
            inputStream = reader.getOriginalContent()
        } else {
            inputStream = gestoreFile.getFile(documento, fileAllegato)
        }

        File temp = salvaFileTemporaneo(fileAllegato.nome, inputStream)
        if (isPdf(temp)) {
            return temp
        }

        FileInputStream fis = null
        try {
            fis = new FileInputStream(temp)
            log.debug("convertiPdf: tento di convertire il file ${fileAllegato.nome} in pdf")
            inputStream = gestioneTestiService.converti(fis, GestioneTestiService.FORMATO_PDF)
        } catch (Throwable e) {
            log.warn("Non sono riuscito a convertire l'allegato con id=${fileAllegato.id} nomefile=${fileAllegato.nome}.", e)
            return null
        } finally {
            if (fis != null) {
                IOUtils.closeQuietly(fis)
            }
        }

        File file = salvaFileTemporaneo(fileAllegato.nome, inputStream)
        return file
    }

    private File generaFileFrontespizio(FileDocumento fileAllegato, inputStream) {

        File temp = salvaFileTemporaneo(fileAllegato.nome, inputStream)
        if (isPdf(temp)) {
            return temp
        }

        FileInputStream fis = null
        try {
            fis = new FileInputStream(temp)
            log.debug("convertiPdf: tento di convertire il file ${fileAllegato.nome} in pdf")
            inputStream = gestioneTestiService.converti(fis, GestioneTestiService.FORMATO_PDF)
        } catch (Throwable e) {
            log.warn("Non sono riuscito a convertire l'allegato con id=${fileAllegato.id} nomefile=${fileAllegato.nome}.", e)
            return null
        } finally {
            if (fis != null) {
                IOUtils.closeQuietly(fis)
            }
        }

        File file = salvaFileTemporaneo(fileAllegato.nome, inputStream)
        return file
    }

    /**
     * Legge i primi byte di un file per determinare se è un pdf o no.
     *
     * @param file il file da verificare
     * @return true se è un pdf, false altrimenti.
     */
    private boolean isPdf(File file) {
        FileInputStream fis
        try {
            fis = new FileInputStream(file)
            byte[] buffer = new byte[4]
            if (fis.read(buffer) != buffer.length) {
                return false
            }
            return ("%PDF".equals(new String(buffer)))
        } finally {
            if (fis != null) {
                IOUtils.closeQuietly(fis)
            }
        }
    }

    /**
     * Provvede alla stampa unica di più file pdf.
     *
     * @param nomeFileStampaUnica il file della stampa unica da creare
     * @param listaFiles elenco dei file da aggiungere alla stampa unica.
     * @param fraseFooter la frase da aggiungere al footer di ogni pagina
     * @return il file della stampa unica creato
     */
    private void unisciFilePdf(OutputStream outputStream, ArrayList<File> listaFiles, String fraseFooter, Protocollo documento) {
        String testoParametricoFraseFooter = ""
        String numeroProtocollo = ""
        String annoProtocollo = ""
        String dataProtocollo = ""
        String dataOraProtocollo = ""

        if (documento?.numero) {
            numeroProtocollo = documento?.numero
        }
        if (documento?.anno) {
            annoProtocollo = documento?.anno
        }
        if (documento?.data) {
            dataProtocollo = documento?.data.format('dd/MM/yyyy')
            dataOraProtocollo = documento?.data.format('dd/MM/yyyy HH:mm:ss')
        }

        testoParametricoFraseFooter = fraseFooter.replaceAll("[\$]NUMPG[\$]", numeroProtocollo).replaceAll("[\$]ANNOPG[\$]", annoProtocollo).replaceAll("[\$]DATAPG[\$]", dataProtocollo).replaceAll("[\$]DATAORAPG[\$]", dataOraProtocollo)

        int rotazione = ImpostazioniProtocollo.SU_FOOTER_ROT.valoreInt
        int xpos = ImpostazioniProtocollo.SU_FOOTER_XPOS.valoreInt
        int ypos = ImpostazioniProtocollo.SU_FOOTER_YPOS.valoreInt

        // preparo il file di output
        Document document = new Document()
        PdfCopy stampaUnica = new PdfCopy(document, outputStream)
        document.open()

        // per ogni file pdf, lo apro, ne conto le pagine e ogni pagina l'aggiungo alla stampa unica.
        for (File file : listaFiles) {
            FileInputStream pdfFile = null
            try {
                pdfFile = new FileInputStream(file)
                PdfReader reader = new PdfReader(pdfFile)
                PdfReader.unethicalreading = true
                int n = reader.getNumberOfPages()

                // ciclo su ogni pagina
                for (int page = 1; page <= n; page++) {
                    // leggo la pagina
                    PdfImportedPage pdfPage = stampaUnica.getImportedPage(reader, page)

                    // aggiungo il footer
                    PdfCopy.PageStamp footer = stampaUnica.createPageStamp(pdfPage)
                    ColumnText.showTextAligned(footer.getOverContent(), Element.ALIGN_LEFT, new Phrase(testoParametricoFraseFooter), xpos, ypos, rotazione)
                    footer.alterContents()

                    // aggiungo la pagina al pdf finale
                    stampaUnica.addPage(pdfPage)
                }
            } catch (Throwable t) {
                log.warn("ATTENZIONE!!! Errore nell'aggiunta del file PDF: ${file?.getAbsolutePath()} alla stampa unica!: ${t?.message}", t)
            } finally {
                if (pdfFile != null) {
                    IOUtils.closeQuietly(pdfFile)
                }
            }
        }
        document.close()
    }

    private File salvaFileTemporaneo(String filename, InputStream is) {
        File temp = File.createTempFile(filename, null)
        FileOutputStream os = new FileOutputStream(temp)
        try {
            IOUtils.copy(is, os)
        } finally {
            if (os != null) {
                IOUtils.closeQuietly(os)
            }
        }
        return temp
    }

    /**
     * Aggiunge ad un array di files gli allegati con il codice specificato
     *
     * @param files Elenco dei files
     * @param codice Codice da utilizzare per la ricerca degli allegati
     * @param atto Atto su cui effettuare la stampa unica
     */
    private List<File> aggiungiFileAllegati(List<Allegato> allegati, List<String> codiciFile = [FileDocumento.CODICE_FILE_ALLEGATO]) {
        List<File> fileDocumenti = []

        for (Allegato allegato : allegati) {
            if (!allegato.stampaUnica) {
                continue
            }

            // mi assicuro di non mettere la stampa unica già esistente dentro la stampa unica... evitiamo le stampeunicheinception
            if (allegato.tipoAllegato?.codice == TipoAllegato.CODICE_TIPO_STAMPA_UNICA) {
                continue
            }
            fileDocumenti.addAll(aggiungiFile(allegato, codiciFile))
        }

        return fileDocumenti
    }

    private List<File> aggiungiFile(Documento documento, List<String> codiciFile) {
        List<File> fileDocumenti = []
        for (Documento allegato : documento) {
            if (!allegato.valido) {
                continue
            }

            List<FileDocumento> listaFileDocumento = allegatoRepository.getFileDocumenti(allegato.id, codiciFile)

            for (FileDocumento fileDocumento : listaFileDocumento) {
                if (!fileDocumento.valido) {
                    continue
                }

                if (ImpostazioniProtocollo.SU_FORMATI_ESCLUSI.valori.contains(FilenameUtils.getExtension(fileDocumento.nome.replaceAll('.p7m', '')).toLowerCase())) {
                    continue
                }

                if (!codiciFile.contains(fileDocumento.codice)) {
                    continue
                }

                File filePdf = convertiPdf(allegato, fileDocumento)
                if (filePdf != null) {
                    log.debug("aggiungiAllegati: aggiungo allegato: " + allegato.id)
                    fileDocumenti << filePdf
                }
            }
        }

        return fileDocumenti
    }

    void downloadCopiaConforme(Documento documento, IFileDocumento fileAllegato, boolean trasformaInPdf = true, boolean sbusta = false, HttpServletResponse response = null) {
        InputStream is
        String nomeFile
        String contentType
        List<VerificatoreFirma.RisultatoVerifica> listaFirmatari = []

        // ottengo l'input stream:
        is = gestoreFile.getFile(documento, fileAllegato)

        if (is == null) {
            throw new ProtocolloRuntimeException("Attenzione! File non trovato!")
        }

        nomeFile = fileAllegato.nome
        contentType = fileAllegato.contentType

        // Recupero la lista dei firmatari
        try {
            listaFirmatari = new VerificatoreFirma(is).verificaFirma()
        }
        catch (Exception e) {
            log.error("Si è verificato un errore nella estrapolazione della lista dei firmatari", e)
        }

        //Rileggo l'input stream perchè già letto dalla funzione verificaFirma
        is = gestoreFile.getFile(documento, fileAllegato)
        try {
            // se devo sbustare, sbusto e scarico il file
            if (sbusta) {

                if (FirmaUtilities.isSigned(is, fileAllegato.nome)) {
                    is = gestoreFile.getFile(documento, fileAllegato)
                    SignedObjectReaderI reader = SignedObjectReaderFactory.getSignedObjectReader(is);
                    log.debug("convertiPdf: ${fileAllegato.nome} è firmato, lo sbusto")
                    is = reader.getOriginalContent()
                } else {
                    is = gestoreFile.getFile(documento, fileAllegato)
                }

                nomeFile = fileAllegato.getNomeFileSbustato()
                contentType = GestioneTestiService.getContentType(nomeFile.substring(nomeFile.lastIndexOf(".") + 1))

                if (!nomeFile?.toLowerCase().endsWith("pdf")) {
                    nomeFile = fileAllegato.getNomePdf()
                    contentType = GestioneTestiService.getContentType(GestioneTestiService.FORMATO_PDF)
                    is = gestioneTestiService.converti(is, GestioneTestiService.FORMATO_PDF)
                }
            } else if (trasformaInPdf && !fileAllegato.isPdf() && !fileAllegato.isP7m()) {
                // se devo scaricare il pdf, eseguo la conversione solo se il file non è già PDF o P7M.
                nomeFile = fileAllegato.getNomePdf()
                contentType = GestioneTestiService.getContentType(GestioneTestiService.FORMATO_PDF)
                is = gestioneTestiService.converti(is, GestioneTestiService.FORMATO_PDF)
            }
        } catch (Exception e) {
            throw new ProtocolloRuntimeException("Non è possibile creare la copia conforme per il file " + nomeFile)
        }

        File temp = File.createTempFile("COPIA_CONFORME", "tmp");
        FileOutputStream out;
        try {

            out = creaCopiaConforme(documento, is, new FileOutputStream(temp), listaFirmatari, fileAllegato.isFirmato());
            is = new FileInputStream(temp);
        } finally {
            FileUtils.deleteQuietly(temp);
            IOUtils.closeQuietly((OutputStream) out);
        }

        if (response == null) {
            Filedownload.save(is, contentType, nomeFile);
        } else {
            response.contentType = contentType
            response.setHeader("Content-disposition", "attachment filename=${nomeFile}")
            IOUtils.copy(is, response.getOutputStream())
            response.outputStream.flush()
        }
    }

    private FileOutputStream creaCopiaConforme(Documento documento, InputStream is, FileOutputStream fos, ArrayList listaFirmatari, boolean firmato) {
        String testoParametricoCopiaConforme = ""

        if (firmato) {
            testoParametricoCopiaConforme = ImpostazioniProtocollo.TESTO_COPIA_CONFORME.valore
        } else {
            testoParametricoCopiaConforme = ImpostazioniProtocollo.TESTO_COPIA_CONFORME_NON_FIRMATO.valore
        }

        PdfReader pdfreader = new PdfReader(is);
        PdfStamper pdfStamp = new PdfStamper(pdfreader, fos);
        int numPages = pdfreader.getNumberOfPages();
        PdfContentByte over;
        BaseFont bf = BaseFont.createFont(BaseFont.TIMES_ROMAN, BaseFont.WINANSI, BaseFont.EMBEDDED);
        Font fontTesto = new Font(bf);
        fontTesto.setSize(8);

        String estremiProtocollo = ""
        String registro_protocollo = ""
        String numero_protocollo = ""
        String anno_protocollo = ""
        String data_protocollo = ""

        if (documento instanceof Protocollo) {
            estremiProtocollo = getInfoDatiProtocollazione(documento)
            registro_protocollo = documento.tipoRegistro.commento
            numero_protocollo = documento.numero
            anno_protocollo = documento.anno
            data_protocollo = documento.data?.format("dd/MM/yyyy")
        } else {
            if (documento instanceof Allegato) {
                Protocollo protocollo = DocumentoCollegato.collegamentiInversi(documento, Allegato.CODICE_TIPO_COLLEGAMENTO)?.get()?.documento
                if (protocollo) {
                    estremiProtocollo = getInfoDatiProtocollazione(protocollo)
                    registro_protocollo = protocollo.tipoRegistro?.commento
                    numero_protocollo = protocollo.numero
                    anno_protocollo = protocollo.anno
                    data_protocollo = protocollo.data?.format("dd/MM/yyyy")
                }
            }
        }

        if (!registro_protocollo) {
            registro_protocollo = ""
        }
        if (!numero_protocollo) {
            numero_protocollo = ""
        }
        if (!anno_protocollo) {
            anno_protocollo = ""
        }
        if (!data_protocollo) {
            data_protocollo = ""
        }

        testoParametricoCopiaConforme = testoParametricoCopiaConforme.replaceAll("[\$]registro_protocollo", registro_protocollo).replaceAll("[\$]numero_protocollo", numero_protocollo).replaceAll("[\$]anno_protocollo", anno_protocollo).replaceAll("[\$]data_protocollo", data_protocollo)

        Document document = new Document();
        PdfWriter writer = PdfWriter.getInstance(document, fos);
        document.open();

        String posizioneTesto = ImpostazioniProtocollo.COPIA_CONFORME_POSIZIONE.valore

        // al centro
        float posx = (document.right() - document.left()) / 2 + document.leftMargin();
        float posy;

        // verticale a sinistra
        // float posx;
        // float posy = (document.top() - document.bottom()) / 2 + document.bottomMargin();

        float incy = 10;
        int i = 0;

        // tutte le pagine
        while (i < numPages) {

            //La posy viene ricalcolata ogni volta ad ogni iterazione
            switch (posizioneTesto) {
                case 'BASSO_CENTRATO':
                    // in basso
                    posy = document.bottom() + 10;
                    break;
                case 'ALTO_CENTRATO':
                    // in alto
                    posy = document.top() - 10;
                    break;
                default:
                    // in alto
                    posy = document.top() - 10;
                    break;
            }

            // verticale a sinistra
            //posx = document.left() - 10
            //posy = document.bottom() + 10;

            i++;
            over = pdfStamp.getOverContent(i);
            over.setTextRenderingMode(PdfContentByte.TEXT_RENDER_MODE_FILL);
            over.setFontAndSize(bf, 8);

            Phrase frase = new Phrase("", fontTesto);

            def righeTesto = testoParametricoCopiaConforme.split("[\$]acapo")
            righeTesto.each {

                if (it.contains("\$firmatari")) {
                    String nuovaRiga = it

                    if (!it.trim().equals("\$firmatari")) {
                        nuovaRiga = it.replaceAll("[\$]firmatari", java.util.regex.Matcher.quoteReplacement("\$" + "acapo " + "\$" + "firmatari" + " " + "\$" + "acapo"))
                    }

                    def rigaConFirmatari = nuovaRiga.split("[\$]acapo")
                    rigaConFirmatari.each {

                        if (!it.trim().equals("\$firmatari")) {
                            posy = posy - incy;
                            frase = new Phrase(it, fontTesto);
                            ColumnText.showTextAligned(over, Element.ALIGN_CENTER, frase, posx, posy, 0);
                        } else {
                            //Aggiungo la dicitura per i firmatari
                            String testo = ""
                            if (listaFirmatari != null) {
                                for (utenteFirmatario in listaFirmatari) {
                                    testo = utenteFirmatario.firmatario?.replaceAll("Documento firmato da: ", "")?.toUpperCase()
                                    if (utenteFirmatario.data) {
                                        testo = testo + " il " + utenteFirmatario.data.format("dd/MM/yyyy HH:mm:ss")
                                    };

                                    //solo all'ultimo firmatario inserisco i riferimenti di legge
                                    if (utenteFirmatario == listaFirmatari.last()) {
                                        testo = testo + " ai sensi dell'art. 20 e 23 del D.lgs 82/2005"
                                    };

                                    posy = posy - incy;
                                    frase = new Phrase(testo, fontTesto);
                                    ColumnText.showTextAligned(over, Element.ALIGN_CENTER, frase, posx, posy, 0);
                                }
                            }
                        }
                    }
                } else {
                    posy = posy - incy;
                    frase = new Phrase(it, fontTesto);
                    ColumnText.showTextAligned(over, Element.ALIGN_CENTER, frase, posx, posy, 0);
                }
            }
        }

        try {
            pdfStamp.close(); pdfreader.close();
        } catch (Exception e) {
        }
        return fos;
    }

    private String getInfoDatiProtocollazione(Protocollo doc) {
        return (doc.numero != null && doc.numero != "") ? doc.tipoRegistro.commento + ": " + doc.anno + " / " + doc.numero + " del " + doc.data?.format("dd/MM/yyyy") : "";
    }
}