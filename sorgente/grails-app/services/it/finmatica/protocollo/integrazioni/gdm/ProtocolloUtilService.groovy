package it.finmatica.protocollo.integrazioni.gdm

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.TokenIntegrazione
import it.finmatica.gestionedocumenti.commons.TokenIntegrazioneService
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.integrazioni.gdm.converters.BooleanConverter
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.mail.MailDTO
import it.finmatica.protocollo.documenti.viste.RiferimentoService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiSi4CSService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviato
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.segreteria.common.ParametriSegreteria
import it.finmatica.segreteria.common.struttura.ParametriProtocollazione
import it.finmatica.segreteria.jprotocollo.interop.DocMemoInterop
import it.finmatica.segreteria.jprotocollo.util.ProtocolloUtil
import it.finmatica.segreteria.organizzazione.UnitaOrganizzativa
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.cxf.common.util.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.Connection

@Slf4j
@CompileStatic
@Transactional
@Service
class ProtocolloUtilService {

    @Autowired
    TokenIntegrazioneService tokenIntegrazioneService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    RiferimentoService riferimentoService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService

    /**
     * Questo flag è una schifezza (perché è una variabile globale pubblica della classe) ma sono è una soluzione veloce che
     * consente l'abilitazione a runtime (tramite la pagina /console) di un comportamento "strano" di questo codice: la commit in protocollazione.
     *
     * Di default ho disabilitato questo comportamento perché lo ritengo dannoso:
     * - la commit in protocollazione rompe la transazionalità e porta a uno stato inconsistente l'allineamento tra AGSPR e GDM.
     * - impedisce la scrittura di test in quanto "sporca" il db creando uno stato inconsistente.
     *
     * È possibile che serva rimetterla perché in protocollazione partono delle "notifiche" che operano su un'altra
     * connessione oracle e quindi non si troverebbero i dati allineati.
     */
    boolean connessioneSenzaCommit = true

    /**
     * Questo Decorator serve per evitare che il JProtocollo faccia commit sulla connessione che gli passo.
     */
    class ConnectionNoCommit implements Connection {
        @Delegate
        private Connection conn

        ConnectionNoCommit(Connection connection) {
            this.conn = connection
        }

        void commit() {
            // impedisce al chiamante di fare commit.
        }

        void rollback() {
            // impedisce al chiamante di fare rollback.
        }
    }

    /**
     * Ritorna true se il memo_protocollo che ha originato il protocollo, possiede un file 'segnatura.xml'
     * @param idDocumentoProtocollo
     * @return
     */
    boolean isConSegnatura(Protocollo protocollo) {
        if (ImpostazioniProtocollo.PEC_USA_SI4CS_WS.valore == "N") {
            Long idMemo = riferimentoService.getIdMemoDaProtocollo(protocollo.idDocumentoEsterno)
            if (idMemo == null) {
                return false
            }

            Documento documentoSmart = new Documento()
            documentoSmart.setId(Long.toString(idMemo))
            documentoSmart = documentaleService.getDocumento(documentoSmart, [Documento.COMPONENTI.FILE])

            List<String> nomiFile = documentoSmart.files*.nome
            String segnatura = nomiFile?.find {
                it.toLowerCase() == "segnatura.xml"
            }

            String idFile = documentoSmart.trovaFile(new File(null, segnatura))?.id
            if (!StringUtils.isEmpty(idFile)) {
                return true
            }

            return false
        }
        else {
            it.finmatica.gestionedocumenti.documenti.Documento documento = messaggiRicevutiService.getCollegamentoMessaggioProtocollo(protocollo)?.documento
            return (documento?.fileDocumenti?.find { it.nome.trim().toLowerCase().equals("segnatura.xml")}!=null)
        }
    }

    /**
     * Ritorna true se il memo_protocollo che ha originato il protocollo, possiede un file 'segnatura.xml'
     * @param idDocumentoProtocollo
     * @return
     */
    boolean isConSegnaturaCittadino(Protocollo protocollo) {
        it.finmatica.gestionedocumenti.documenti.Documento documento = messaggiRicevutiService.getCollegamentoMessaggioProtocollo(protocollo)?.documento
        return (documento?.fileDocumenti?.find { it.nome.trim().toLowerCase().equals("segnatura_cittadino.xml")}!=null)
    }

    ProtocolloUtil istanziaProtocolloUtil() {
        try {
            // questa connessione è quella della transazione attiva su gdm.
            Connection conn = DataSourceUtils.getConnection(dataSource_gdm)
            if (connessioneSenzaCommit) {
                conn = new ConnectionNoCommit(conn)
            }
            // lo "0" come terzo parametro significa "connessione oracle". Questa smerdarina è dovuta a causa delle sempiterne merdosissime DbOperationSQL.
            ParametriSegreteria pg = new ParametriSegreteria(ImpostazioniProtocollo.PROTOCOLLO_GDM_PROPERTIES.valore, conn, 0)
            pg.setControlloCompetenzeAttivo(false)
            ProtocolloUtil protocolloUtil = new ProtocolloUtil(pg)
            return protocolloUtil
        } catch (Exception e) {
            throw new ProtocolloRuntimeException("Errore in istanziazione ProtocolloUtil", e)
        }
    }

    ProtocolloUtil istanziaProtocolloUtil(long idDocumentoEsterno) {
        istanziaProtocolloUtil(idDocumentoEsterno.toString())
    }

    ProtocolloUtil istanziaProtocolloUtil(String idDocumentoEsterno) {
        ProtocolloUtil protocolloUtil = istanziaProtocolloUtil()
        try {
            protocolloUtil.istanziaProtocollo(idDocumentoEsterno, springSecurityService.principal.id, null)
            return protocolloUtil
        } catch (Exception e) {
            throw new ProtocolloRuntimeException("Errore in istanziazione Protocollo", e)
        }
    }

    @CompileDynamic
    void protocolla(Protocollo protocollo, boolean verificaFirma = true) {
        // se il token era già presente e ne ho copiati i valori sul protocollo, esco e non faccio niente.
        if (beginTokenProtocollazione(protocollo)) {
            return
        }
        String utenteProtocollante = springSecurityService.principal.id
        String codiceUnitaProtocollante = protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4?.codice
        ProtocolloUtil protocolloUtil = istanziaProtocolloUtil(protocollo.idDocumentoEsterno.toString())
        try {
            ParametriProtocollazione pp = new ParametriProtocollazione()
            pp.setSmistamentiObbligatori(false)
            pp.setSeparaAllegati(false)
            pp.setTimbrapdf(false)
            pp.setEffettuaCommit(false)
            pp.setVerificaFirma(verificaFirma)
            log.debug("Istanzio il protocollo")
            if (protocolloUtil.getProtocollo() == null) {
                throw new Exception("c'è stato un errore nella creazione del protocollo: " + protocolloUtil.getMessaggioErrore())
            }
            protocolloUtil.getProtocollo().setMovimento(protocollo.movimento?.substring(0, 3))
            protocolloUtil.getProtocollo().setCodiceAmministrazione(protocollo.ente?.amministrazione?.codice)
            protocolloUtil.getProtocollo().setCodiceAoo(protocollo.ente?.aoo)
            protocolloUtil.getProtocollo().setTipoRegistro(protocollo.tipoRegistro?.codice)
            protocolloUtil.getProtocollo().setUnitaProtocollante(codiceUnitaProtocollante)
            log.debug("Protocollo su GDM")
            String codiceModello = protocolloUtil.getProtocollo().getCodiceModello()
            String area = protocolloUtil.getProtocollo().getArea()
            String codiceRichiesta = protocolloUtil.getProtocollo().getCodiceRichiesta()
            protocolloUtil.protocolla(codiceModello, area, codiceRichiesta, utenteProtocollante, "", pp)
            if (protocolloUtil.getProtocollo().getNumero() <= 0) {
                log.error(protocolloUtil.getProtocollo().getError())
                throw new Exception("Si è verificato un errore in protocollazione: " + protocolloUtil.getMessaggioErrore())
            }
            log.info("Protocollazione GDM effettuata sul documento ${protocollo.id}: ${protocolloUtil.getProtocollo().getNumero()}/${protocolloUtil.getProtocollo().getAnno()} in data ${protocolloUtil.getProtocollo().getData()}")
            protocollo.numero = protocolloUtil.getProtocollo().getNumero()
            protocollo.anno = protocolloUtil.getProtocollo().getAnno()
            protocollo.data = protocolloUtil.getProtocollo().getData()
            protocollo.oggetto = protocolloUtil.getProtocollo().getOggetto()
            protocollo.tipoRegistro = TipoRegistro.get(protocolloUtil.getProtocollo().getTipoRegistro())
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        } finally {
            // se ho protocollato, salvo il token
            if (protocolloUtil.protocollo.numero > 0) {
                updateTokenProtocollazione(protocollo, protocolloUtil.protocollo.numero, protocolloUtil.protocollo.anno, protocolloUtil.protocollo.data)
            } else {
                // altrimenti, rimuovo il token inserito
                endTokenProtocollazione(protocollo)
            }
        }
    }

    void spedisciNotificaEccezione(Protocollo protocollo) {
        ProtocolloUtil protocolloUtil = istanziaProtocolloUtil(protocollo.idDocumentoEsterno.toString())
        try {
            String messaggioErrore = protocolloUtil.spedisciNotificaEccezione(protocolloUtil.getProtocollo(), springSecurityService.principal.id, null)
            if (messaggioErrore != null) {
                throw new Exception(messaggioErrore)
            }
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    List<DocMemoInterop> spedisciConSegnatura(Protocollo documento, MailDTO mail, boolean segnaturaCompleta, String testo, boolean segnatura, boolean invioSingolo, Vector<String> vAllegatiFile, Vector<String> destinatari, Vector<String> destinatariCC, String tipoRicevutaConsegna) {
        ProtocolloUtil protocolloUtil = istanziaProtocolloUtil()
        try {
            return protocolloUtil.spedisciConSegnatura(documento.idDocumentoEsterno.toString(),
                    springSecurityService.principal.id,
                    null,
                    mail.tagMail,
                    mail.tipo,
                    BooleanConverter.Y_N.INSTANCE.convert(segnaturaCompleta),
                    testo,
                    segnatura,
                    invioSingolo,
                    vAllegatiFile,
                    documento.getFilePrincipale()?.nome,
                    destinatari,
                    destinatariCC,
                    tipoRicevutaConsegna,
                    mail.email?.trim())
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    void inviaRicevuta(Protocollo protocollo) {
        inviaRicevuta(protocollo.idDocumentoEsterno)
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    void inviaRicevuta(long idDocumentoEsterno, boolean inProtocolloazione = false) {
        ProtocolloUtil protocolloUtil = istanziaProtocolloUtil(idDocumentoEsterno)
        try {
            protocolloUtil.getProtocollo().inviaRicevuta(inProtocolloazione)
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    void spedisciConfermaRicezione(long idDocumentoEsterno) {
        ProtocolloUtil protocolloUtil = istanziaProtocolloUtil(idDocumentoEsterno)
        try {
            protocolloUtil.getProtocollo().spedisciConfermaRicezione(false)
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    @CompileDynamic
    private So4UnitaPubb getUnita(UnitaOrganizzativa unitaOrganizzativa) {
        return So4UnitaPubb.perOttica(unitaOrganizzativa.ottica).findByProgrAndDal(unitaOrganizzativa.progressivo.toLong(), unitaOrganizzativa.dal)
    }

    @CompileDynamic
    private boolean beginTokenProtocollazione(Protocollo protocollo) {
        if (connessioneSenzaCommit) {
            return false
        }
        // creo il token di protocollazione: se lo trovo ed ha successo, vuol dire che ho già protocollato:
        TokenIntegrazione token = tokenIntegrazioneService.beginTokenTransaction("${protocollo.id}", TokenIntegrazione.TIPO_PROTOCOLLO)
        if (token.isStatoSuccesso()) {
            // significa che ho già protocollato: prendo il numero di protocollo, lo assegno al documento ed esco:
            Map map = (Map) Eval.me(token.dati)
            protocollo.numero = (int) map.numero
            protocollo.anno = (int) map.anno
            protocollo.data = Date.parse("dd/MM/yyyy HH:mm:ss", (String) map.data)
            protocollo.save()
            // elimino il token: tutto è andato bene e verrà eliminato solo alla commit sull transaction principale
            tokenIntegrazioneService.endTokenTransaction("${protocollo.id}", TokenIntegrazione.TIPO_PROTOCOLLO)
            // se ho trovato un token valido, ritorno true
            return true
        }
        return false
    }

    private void updateTokenProtocollazione(Protocollo protocollo, int numero, int anno, Date data) {
        if (connessioneSenzaCommit) {
            return
        }
        tokenIntegrazioneService.setTokenSuccess("${protocollo.id}", TokenIntegrazione.TIPO_PROTOCOLLO, "[numero:${numero}, anno:${anno}, data:'${data.format("dd/MM/yyyy HH:mm:ss")}']")
    }

    private void endTokenProtocollazione(Protocollo protocollo) {
        if (connessioneSenzaCommit) {
            return
        }
        // elimino il token: questo avverrà solo se la transazione "normale" di grails andrà a buon fine:
        tokenIntegrazioneService.endTokenTransaction("${protocollo.id}", TokenIntegrazione.TIPO_PROTOCOLLO)
    }
}
