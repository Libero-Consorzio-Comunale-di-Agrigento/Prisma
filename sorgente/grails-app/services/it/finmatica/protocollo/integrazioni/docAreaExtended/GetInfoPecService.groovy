package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.FileDocumentoService
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.dizionari.TipoCollegamentoRepository
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.RiferimentoService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiInviatiService
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Example
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.annotation.PostConstruct
import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class GetInfoPecService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ProtocolloService protocolloService

    @Autowired
    RiferimentoService riferimentoService

    @Autowired
    MessaggiInviatiService messaggiInviatiService

    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository

    @Autowired
    TipoCollegamentoRepository tipoCollegamentoRepository

    private TipoCollegamento tcMail,tcPec

    GetInfoPecService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(ProtocolloPec)
    }

    @PostConstruct
    void init() throws Exception {
        def allTipi = tipoCollegamentoRepository.findAll()
        for(tc in allTipi) {
            if(tc.codice == 'MAIL') {
                tcMail = tc
            } else if(tc.codice == 'PROT_PEC') {
                tcPec = tc
            }
        }

    }

    @Override
    String getXsdName() {
        return 'getInfoPec'
    }

    @Override
    @CompileStatic
    String  execute(String user, Node xml, boolean ignoraCompetenze) {
        String idString = getIdDocumento(xml)?.trim()
        String anno = getAnno(xml)
        String numero = getNumero(xml)
        String tipoRegistro = getTipoRegistro(xml)
        if(!idString && !(anno && numero && tipoRegistro)) {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Dati identificativi di protocollo assenti')
        }
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento):
                protocolloService.findByAnnoAndNumeroAndTipoRegistro(getInteger(anno), getInteger(numero), tipoRegistro)
        if(protocollo) {
            ProtocolloPec resp = new ProtocolloPec()
            def dati = new Dati()
            resp.dati = dati
            dati.iddocumento = protocollo.idDocumentoEsterno
            dati.anno = protocollo.anno
            dati.classcod = protocollo.classificazione?.codice ?: ''
            dati.classdal = formatDate(protocollo.classificazione?.dal)
            dati.data = formatDate (protocollo.data)
            dati.descrizionetiporegistro = protocollo.tipoRegistro?.commento ?: ''
            dati.fascicoloanno = protocollo.fascicolo?.anno ?: ''
            dati.fascicolonumero = protocollo.fascicolo?.numero ?: ''
            dati.idrif = protocollo.idrif
            switch (protocollo.movimento) {
                case it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO: dati.modalita = 'INT'; break
                case it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_ARRIVO: dati.modalita = 'ARR'; break
                case it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_PARTENZA: dati.modalita = 'PAR'; break
            }
            dati.numero = protocollo.numero
            dati.oggetto = protocollo.oggetto
            dati.tiporegistro = protocollo.tipoRegistro?.codice ?: ''
            dati.unitaprotocollante = protocollo.soggetti.find {it.tipoSoggetto == TipoSoggetto.UO_PROTOCOLLANTE}?.unitaSo4?.codice ?: ''
            dati.utenteprotocollante = protocollo.soggetti.find {it.tipoSoggetto == TipoSoggetto.REDATTORE}?.utenteAd4?.nominativo ?: ''
            def memoInviati = new MemoInviati()
            resp.memoInviati = memoInviati
            memoInviati.memo = []
            def documentiCollegati = documentoCollegatoRepository.collegamentiPerTipologia(protocollo, tcMail)
            for (DocumentoCollegato docc in documentiCollegati) {
                Memo m = new Memo()
                memoInviati.memo.add m
                it.finmatica.gestionedocumenti.documenti.Documento rif = docc.collegato
                m.iddocumento = rif.id
                def mess = messaggiInviatiService.getMessaggio(rif.idDocumento)
                if(mess) {
                    m.destinatari = mess.destinatari
                    m.dataspedizione = formatDate(mess.dataSpedizione)
                    m.statoSpedizione = mess.statoSpedizione
                }
                def allegati = new FileAllegati()
                allegati.file = []
                m.fileallegati = allegati
                // prender collegati PROT_PEC
                def documentiPec = documentoCollegatoRepository.collegamentiPerTipologia(rif, tcPec)
                for(DocumentoCollegato docPec in documentiPec) {
                    // prender file con filename = 'daticert.xml'
                    def files = docPec.collegato.fileDocumenti
                    for(fd in files) {
                        if(fd.nome == 'daticert.xml') {
                            File f = new File()
                            f.iddocumento = fd.id
                            f.idoggettofile = fd.idFileEsterno
                            f.filename = fd.nome
                            allegati.file.add f
                        }
                    }
                }
            }
            dati.fascicoloanno = protocollo.fascicolo?.anno?.toString() ?: ''
            dati.fascicolonumero = protocollo.fascicolo?.numero ?: ''
            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Protocollo assente')
        }

    }


}
