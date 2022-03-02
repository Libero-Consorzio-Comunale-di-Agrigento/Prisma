package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.documenti.ProtocolloEsternoService
import it.finmatica.protocollo.documenti.ProtocolloWS
import it.finmatica.protocollo.documenti.ProtocolloWSService
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.gdm.converters.StatoSmistamentoConverter
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class GetDocumentoService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    So4UnitaPubbService so4UnitaPubbService
    @Autowired
    ProtocolloWSService protocolloWSService
    @Autowired
    ProtocolloEsternoService protocolloEsternoService
    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService

    GetDocumentoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Protocollo)
    }

    @Override
    String getXsdName() {
        return 'getDocumento'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): null
        if(protocollo) {
            Protocollo resp = toProtocollo(protocollo)
            return toXml(resp)
        } else {
            if(idDocumento) {
                ProtocolloWS pws = protocolloWSService.findOne(idDocumento)
                if (pws) {
                    Protocollo resp = toProtocollo(pws)
                    return toXml(resp)
                } else {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Documento non trovato')
                }
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Id documento assente')
            }
        }
    }

    private Protocollo toProtocollo(it.finmatica.protocollo.documenti.Protocollo protocollo) {
        Protocollo proto = new Protocollo()
        Doc doc = new Doc()
        proto.doc = doc
        doc.iddocumento = String.valueOf(protocollo.id)
        doc.idrif = protocollo.idrif
        doc.anno = String.valueOf(protocollo.anno)
        doc.numero = protocollo.numero
        doc.tiporegistro = protocollo.tipoRegistro?.codice
        doc.descrizionetiporegistro = protocollo.tipoRegistro?.commento
        doc.data = formatDate(protocollo.data)
        doc.oggetto = protocollo.oggetto
        doc.datadocumento = formatDate(protocollo.dataDocumentoEsterno)
        doc.dataarrivo = formatDate(protocollo.dataRedazione)
        doc.numerodocumento = protocollo.numeroDocumentoEsterno
        doc.classcod = protocollo.classificazione.codice
        doc.classdal = formatDate(protocollo.classificazione.dal)
        doc.fascicoloanno = protocollo.fascicolo?.anno ? String.valueOf(protocollo.fascicolo?.anno) : ''
        doc.fascicolonumero = protocollo.fascicolo?.numero ? String.valueOf(protocollo.fascicolo?.numero) : ''
        doc.riservato = formatBoolean(protocollo.riservato)
        doc.statopr = protocollo.stato?.name()
        doc.tipodocumento = protocollo.tipoProtocollo.codice
        doc.descrizionetipodocumento = protocollo.tipoProtocollo?.commento
        doc.unitaesibente = protocollo.soggetti.find {it.tipoSoggetto == TipoSoggetto.UO_ESIBENTE}?.unitaSo4?.codice
        doc.unitaprotocollante = protocollo.soggetti.find {it.tipoSoggetto == TipoSoggetto.UO_PROTOCOLLANTE}?.unitaSo4?.codice
        doc.utenteprotocollante = protocollo.soggetti.find{it.tipoSoggetto == TipoSoggetto.REDATTORE}?.utenteAd4?.nominativo
        doc.annullato = formatBoolean(protocollo.annullato)
        doc.dataann = formatDate(protocollo.dataAnnullamento)
        doc.utenteann = protocollo.utenteAnnullamento?.nominativo
        switch (protocollo.movimento) {
            case it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO: doc.modalita = 'INT'; break
            case it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_ARRIVO: doc.modalita = 'ARR'; break
            case it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_PARTENZA: doc.modalita = 'PAR'; break
        }
        FileDocumento filePrincipale = protocollo.getFilePrincipale()
        if(filePrincipale) {
            FilePrincipale fp = new FilePrincipale()
            fp.file = new File()
            proto.fileprincipale = fp
            fp.file.idoggettofile = filePrincipale.idFileEsterno
            fp.file.iddocumento = protocollo.idDocumentoEsterno
            fp.file.filename = filePrincipale.nome
        }
        def alleg = protocollo.getAllegati()
        Allegati allegati = new Allegati()
        allegati.allegato = []
        proto.allegati = allegati
        for(it.finmatica.gestionedocumenti.documenti.Allegato all in alleg) {
           Allegato a = new Allegato()
            allegati.allegato.add(a)
            a.iddocumento = String.valueOf(all.id)
            a.tipoallegato = all.tipoAllegato?.acronimo ?: ''
            a.desctipoallegato = all.tipoAllegato?.commento ?: ''
            a.descrizione = all.descrizione
            a.idrif = doc.idrif
            a.numeropag = all.numPagine ? String.valueOf(all.numPagine) : ''
            a.quantita = all.quantita ? String.valueOf(all.quantita) : ''
            a.riservato = formatBoolean(all.riservato)
            a.titolodocumento = all.commento
            a.codamm = all.ente.amministrazione.codice
            a.descrizioneamm = all.ente.amministrazione.soggetto.denominazione
            a.codaoo = all.ente.aoo
            if(all.allegati) {
                a.fileallegati = new FileAllegati()
                a.fileallegati.file = []
                for(fileAll in all.allegati) {
                    File f = new File()
                    a.fileallegati.file.add(f)
                    f.iddocumento = protocollo.idDocumentoEsterno
                    f.idoggettofile = fileAll.idDocumentoEsterno
                    f.filename = fileAll.filePrincipale?.nome
                }
            }
        }
        if(protocollo.smistamenti) {
            Smistamenti smists = new Smistamenti()
            proto.smistamenti = smists
            smists.smistamento = []
            for (smistamento in protocollo.smistamenti) {
                Smistamento sm = new Smistamento()
                smists.smistamento.add(sm)
                sm.iddocumento = smistamento.id
                sm.ufficiosmistamento = smistamento.unitaSmistamento?.codice
                sm.desufficiosmistamento = smistamento.unitaSmistamento?.descrizione
                sm.ufficiotrasmissione = smistamento.unitaTrasmissione?.codice
                sm.desufficiotrasmissione = smistamento.unitaTrasmissione?.descrizione
                sm.idrif = protocollo.idrif
                sm.smistamentodal = formatDate(smistamento.dataSmistamento)
                sm.tiposmistamento = smistamento.tipoSmistamento
                if(smistamento.statoSmistamento) {
                    sm.statosmistamento = StatoSmistamentoConverter.INSTANCE.convert(smistamento.statoSmistamento)
                }
                smistamento.statoSmistamento
            }
        }
        if(protocollo.corrispondenti) {
            proto.rapporti = new Rapporti()
            proto.rapporti.rapporto = []
            for(Corrispondente corr in protocollo.corrispondenti) {
                def docPartenzaMittente = doc.modalita == 'PAR' && corr.tipoCorrispondente == Corrispondente.MITTENTE
                def docArrivoDestinatario = doc.modalita == 'ARR' && corr.tipoCorrispondente == Corrispondente.DESTINATARIO
                if(!(docPartenzaMittente || docArrivoDestinatario)) {
                    Rapporto rapp = new Rapporto()
                    proto.rapporti.rapporto.add(rapp)
                    rapp.iddocumento = corr.id
                    rapp.cognomenome = "${corr.cognome} ${corr.nome}".toString().toUpperCase()
                    rapp.codicefiscale = corr.codiceFiscale
                    rapp.email = corr.email
                    rapp.denominazione = corr.denominazione
                    rapp.indirizzo = corr.indirizzo
                    rapp.cap = corr.cap
                    rapp.idrif = protocollo.idrif
                    rapp.conoscenza = formatBoolean(corr.conoscenza)
                }
            }
        }
        return proto
    }

    private Protocollo toProtocollo(ProtocolloWS protocollo) {
        Protocollo proto = new Protocollo()
        Doc doc = new Doc()
        proto.doc = doc
        doc.iddocumento = String.valueOf(protocollo.idDocumento)
        doc.anno = String.valueOf(protocollo.anno)
        doc.numero = protocollo.numero
        doc.tiporegistro = protocollo.tipoRegistro
        doc.data = formatDate(protocollo.data)
        doc.oggetto = protocollo.oggetto
        doc.classcod = protocollo.classificazione
        // in questo caso l'id che trovo nella vista sopra è l'id esterno di proto_view
        ProtocolloEsterno protocolloEsterno = protocolloEsternoService.getProtocolloEsterno(protocollo.idDocumentoEsterno)
        if(protocolloEsterno) {
            doc.descrizionetiporegistro = protocolloEsterno.tipoRegistro?.commento
            doc.datadocumento = formatDate(protocolloEsterno.dataDocumento)
            doc.numerodocumento = protocolloEsterno.numeroDocumento
            doc.fascicoloanno = protocolloEsterno.fascicoloAnno ? String.valueOf(protocolloEsterno.fascicoloAnno) : ''
            doc.fascicolonumero = protocolloEsterno.fascicoloNumero
            doc.riservato = formatBoolean(protocolloEsterno.riservato)
            doc.tipodocumento = protocolloEsterno.schemaProtocollo
            doc.annullato = formatBoolean(protocolloEsterno.annullato)
            doc.dataann = formatDate(protocolloEsterno.dataAnnullamento)
            doc.utenteann = protocolloEsterno.utenteAnnullamento
            doc.modalita = protocolloEsterno.modalita
            doc.dataSpedizione = formatDate(protocolloEsterno.dataSpedizione)
            List<it.finmatica.smartdoc.api.struct.File> files = protocolloWSUtilityService.caricaFileDaDocumentale(protocollo.idDocumentoEsterno)
            if(files) {
                it.finmatica.smartdoc.api.struct.File file = files.first()
                def princ = new FilePrincipale()
                proto.fileprincipale = princ
                def fp = new File()
                princ.FILE = fp
                fp.filename = file.nome
                fp.idoggettofile = file.id
                fp.iddocumento = doc.iddocumento
            }

        }

        return proto
    }

}
