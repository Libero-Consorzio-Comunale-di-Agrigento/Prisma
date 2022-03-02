package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.MarkableFileInputStream
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ws.dati.Protocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang.StringUtils
import org.hibernate.Session
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.util.media.Media

import javax.sql.DataSource
import javax.xml.validation.Schema
import java.sql.SQLException

@Transactional
@Service
class SchemaProtocolloService {

    @Autowired
    DataSource dataSource
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService
    @Autowired
    SessionFactory sessionFactory

    SchemaProtocolloDTO salva(SchemaProtocolloDTO schemaProtocolloDto) {

        try {

            SchemaProtocollo schemaProtocollo = SchemaProtocollo.get(schemaProtocolloDto.id) ?: new SchemaProtocollo()
            schemaProtocollo.valido = schemaProtocolloDto.valido
            schemaProtocolloDto.codice = schemaProtocolloDto.codice.toUpperCase()
            schemaProtocollo.codice = schemaProtocolloDto.codice
            schemaProtocollo.descrizione = schemaProtocolloDto.descrizione
            schemaProtocollo.note = schemaProtocolloDto.note
            schemaProtocollo.oggetto = schemaProtocolloDto.oggetto
            schemaProtocollo.movimento = schemaProtocolloDto.movimento
            schemaProtocollo.conservazioneIllimitata = schemaProtocolloDto.conservazioneIllimitata
            schemaProtocollo.anniConservazione = schemaProtocolloDto.anniConservazione
            schemaProtocollo.segnatura = schemaProtocolloDto.segnatura
            schemaProtocollo.segnaturaCompleta = schemaProtocolloDto.segnaturaCompleta
            schemaProtocollo.risposta = schemaProtocolloDto.risposta
            schemaProtocollo.riservato = schemaProtocolloDto.riservato
            schemaProtocollo.domandaAccesso = schemaProtocolloDto.domandaAccesso
            schemaProtocollo.scadenza = schemaProtocolloDto.scadenza
            schemaProtocollo.classificazione = schemaProtocolloDto.classificazione?.domainObject
            schemaProtocollo.fascicolo = schemaProtocolloDto.fascicolo?.domainObject
            schemaProtocollo.tipoProtocollo = schemaProtocolloDto.tipoProtocollo?.domainObject
            schemaProtocollo.tipoRegistro = schemaProtocolloDto.tipoRegistro?.domainObject
            schemaProtocollo.ufficioEsibente = schemaProtocolloDto.ufficioEsibente?.domainObject
            schemaProtocollo.schemaProtocolloRisposta = schemaProtocolloDto.schemaProtocolloRisposta?.domainObject

            if (schemaProtocollo.id == null) {
                if (SchemaProtocollo.findByCodice(schemaProtocolloDto.codice) != null) {

                    throw new ProtocolloRuntimeException("Il tipo di schema con codice: " + schemaProtocolloDto.codice + " è già presente")
                }
                schemaProtocollo.id = 0
            }

            for (SchemaProtocolloFileDTO f : schemaProtocolloDto.files) {
                SchemaProtocolloFile file = SchemaProtocolloFile.get(f.id)
                file.tipoAllegato = f.tipoAllegato?.domainObject
                file.save()
            }

            for (SchemaProtocolloCategoriaDTO categoriaDTO : schemaProtocolloDto.categorie) {
                SchemaProtocolloCategoria categoria = SchemaProtocolloCategoria.get(categoriaDTO.id)
                if (!categoria) {
                    categoria = new SchemaProtocolloCategoria()
                }
                categoria.tipoProtocollo = categoriaDTO.tipoProtocollo?.domainObject
                categoria.categoria = categoriaDTO.categoria
                categoria.modificabile = categoriaDTO.modificabile
                categoria.schemaProtocollo = schemaProtocollo
                categoria.save()
            }

            schemaProtocollo.save()

            return reloadFromDb(schemaProtocolloDto.codice).toDTO("categorie")
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    void elimina(SchemaProtocolloDTO schemaProtocolloDto) {

        try {
            SchemaProtocollo schemaProtocollo = SchemaProtocollo.findByCodice(schemaProtocolloDto.codice)
            /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
            if (schemaProtocollo.version != schemaProtocolloDto.version) {
                throw new GestioneDocumentiRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
            }
            schemaProtocollo.delete()
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    void associaSchemaProtocollo(SchemaProtocollo schemaProtocollo, it.finmatica.protocollo.documenti.Protocollo protocollo) {
        protocollo.tipoProtocollo = (protocollo.tipoProtocollo == null) ? schemaProtocollo.tipoProtocollo : protocollo.tipoProtocollo

        //Oggetto
        protocollo.oggetto = (protocollo.oggetto == null) ? schemaProtocollo.oggetto : protocollo.oggetto

        //Classificazione
        protocollo.classificazione = (protocollo.classificazione == null) ? schemaProtocollo.classificazione : protocollo.classificazione

        //Fascicolo
        protocollo.fascicolo = (protocollo.fascicolo == null) ? schemaProtocollo.fascicolo : protocollo.fascicolo

        //Smistamenti
        List<SchemaProtocolloSmistamento> smistamentiSchema = SchemaProtocolloSmistamento.createCriteria().list {
            eq("schemaProtocollo.id", schemaProtocollo?.id)
            isNotNull("sequenza")
            order("sequenza")
        }
        List<SchemaProtocolloSmistamento> smistamentiDaCreare = smistamentiSchema
        boolean isSequenza = smistamentiSchema?.size() > 0
        if (isSequenza) {
            List<SchemaProtocolloSmistamento> smistamentiSchemaRestanti = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo.id", schemaProtocollo?.id)
                isNull("sequenza")
                eq("tipoSmistamento", it.finmatica.protocollo.smistamenti.Smistamento.CONOSCENZA)
            }
            smistamentiDaCreare = [smistamentiSchema.get(0)]
            smistamentiDaCreare.addAll(smistamentiSchemaRestanti)
        } else {
            smistamentiDaCreare = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo.id", schemaProtocollo.id)
            }
        }
        for (SchemaProtocolloSmistamento ss : smistamentiDaCreare) {
            if (ss.unitaSo4Smistamento != null) {
                So4UnitaPubb unitaProtocollante = protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4

                protocollo.addToSmistamenti(new Smistamento(tipoSmistamento: ss.tipoSmistamento, dataSmistamento: new Date(),
                        statoSmistamento: Smistamento.CREATO, unitaTrasmissione: unitaProtocollante,
                        utenteTrasmissione: (unitaProtocollante == null) ? springSecurityService.currentUser : null, unitaSmistamento: ss.unitaSo4Smistamento))
            }
        }

        protocollo.schemaProtocollo = schemaProtocollo
    }

    public List<SchemaProtocollo> ricercaSenzaUnitaAssociate(String search, String movimento) {
        Map<String, String> parametri = [idEnte: springSecurityService.principal.idEnte, registro: ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore, search: "%" + search + "%"]
        if (movimento) {
            parametri.movimento = movimento
        }
        SchemaProtocollo.executeQuery("""
				SELECT  schema
				FROM   SchemaProtocollo schema
				WHERE 
						 schema.ente.id       = :idEnte
					   AND schema.valido        = true
					   AND coalesce(schema.codice, '*') != :registro
					   AND (schema.codice like upper(:search) OR upper(schema.descrizione) like upper(:search))
                       ${condizioneMovimento(movimento)}
					   AND schema.risposta      = false 
					   AND NOT EXISTS (
							   SELECT 1 FROM SchemaProtocolloUnita schemaUnita
							   WHERE schemaUnita.schemaProtocollo.id = schema.id)
				
			""", parametri)
    }

    public List<SchemaProtocollo> ricercaPerUo(ArrayList<String> codiciUo, String search, String movimento) {
        Map<String, String> parametri = [utente: springSecurityService.principal.id, idEnte: springSecurityService.principal.idEnte, codiciUo: codiciUo, registro: ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore, search: "%" + search + "%"]
        if (movimento) {
            parametri.movimento = movimento
        }
        SchemaProtocollo.executeQuery("""
				SELECT schema
				FROM   SchemaProtocollo schema, SchemaProtocolloUnita schemaProtocolloUnita, So4UnitaPubb uoUtente
				WHERE  uoUtente.codice IN (:codiciUo) 
                       AND (schemaProtocolloUnita.unita is null OR 
                                     (schemaProtocolloUnita.unita.progr\t= uoUtente.progr
                                        AND schemaProtocolloUnita.unita.dal = uoUtente.dal
                                        AND schemaProtocolloUnita.unita.ottica = uoUtente.ottica.id )
                       )
					   AND schema.id = schemaProtocolloUnita.schemaProtocollo.id
                       AND schema.ente.id       = :idEnte
					   AND schema.valido        = true
					   AND coalesce(schema.codice, '*') != :registro
					   AND (schema.codice like upper(:search) OR upper(schema.descrizione) like upper(:search))
                       ${condizioneMovimento(movimento)}
					   AND schema.risposta      = false 
                       and (schemaProtocolloUnita.utenteAd4 is null or schemaProtocolloUnita.utenteAd4.id = :utente)   
               """, parametri)
    }

    public List<SchemaProtocollo> ricerca(String search, String movimento) {

        Map<String, String> parametri = [idEnte: springSecurityService.principal.idEnte, registro: ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore, search: "%" + search + "%"]
        if (movimento) {
            parametri.movimento = movimento
        }
        SchemaProtocollo.executeQuery("""	
				SELECT  schema
				FROM   SchemaProtocollo schema
				WHERE  
						schema.ente.id = :idEnte
					 AND schema.valido = true
				     AND coalesce(schema.codice, '*') != :registro
				     AND schema.risposta = false 
				     AND (schema.codice like upper(:search) OR upper(schema.descrizione) like upper(:search))
                     ${condizioneMovimento(movimento)}
	
			""", parametri)
    }

    public List<SchemaProtocollo> ricercaAvanzata(String codice, String descrizione, String oggetto, String movimento,
                                                  String fascicoloNumero, String fascicoloAnno, String fascicoloOggetto,
                                                  String classificazioneCodice) {

        boolean classifica = !StringUtils.isEmpty(classificazioneCodice)
        boolean fascicolo = (!StringUtils.isEmpty(fascicoloNumero) ||
                !StringUtils.isEmpty(fascicoloOggetto) ||
                !StringUtils.isEmpty(fascicoloAnno))

        Map<String, String> parametri = [idEnte     : springSecurityService.principal.idEnte,
                                         registro   : ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore,
                                         codice     : StringUtils.join("%", codice, "%"),
                                         descrizione: StringUtils.join("%", descrizione, "%"),
                                         oggetto    : StringUtils.join("%", oggetto, "%")]
        if (movimento) {
            parametri.movimento = movimento
        }
        if (classifica) {
            parametri.putAll([classificazioneCodice: StringUtils.join("%", classificazioneCodice, "%")])
        }
        if (fascicolo) {
            parametri.putAll([fascicoloNumero : StringUtils.join("%", fascicoloNumero, "%"),
                              fascicoloAnno   : StringUtils.join("%", fascicoloAnno, "%"),
                              fascicoloOggetto: StringUtils.join("%", fascicoloOggetto, "%")])
        }

        SchemaProtocollo.executeQuery("""
				SELECT  schema
				FROM   SchemaProtocollo schema
				      WHERE
				        schema.ente.id = :idEnte
					 AND schema.valido = true
				     AND coalesce(schema.codice, '*') != :registro
				     AND schema.risposta = false
				     ${condizioneMovimento(movimento)}
				     AND upper(schema.codice) like coalesce(upper(:codice), upper(schema.codice))
				     AND coalesce(upper(schema.descrizione), '%') like coalesce(upper(:descrizione), coalesce(upper(schema.descrizione),'%'))
				     AND coalesce(upper(schema.oggetto), '%') like coalesce(upper(:oggetto), coalesce(upper(schema.oggetto), '%'))"""
                + (classifica ? "AND upper(schema.classificazione.codice) like upper(:classificazioneCodice)" : "")
                + (fascicolo ? ("AND upper(schema.fascicolo.numero) like upper(:fascicoloNumero)" +
                "AND upper(schema.fascicolo.anno) like upper(:fascicoloAnno)" +
                "AND upper(schema.fascicolo.oggetto) like upper(:fascicoloOggetto)") : "")
                , parametri)
    }

    public List<SchemaProtocollo> ricercaAvanzataSenzaUnitaAssociate(String codice, String descrizione, String oggetto, String movimento,
                                                                     String fascicoloNumero, String fascicoloAnno, String fascicoloOggetto,
                                                                     String classificazioneCodice) {

        boolean classifica = !StringUtils.isEmpty(classificazioneCodice)
        boolean fascicolo = (!StringUtils.isEmpty(fascicoloNumero) ||
                !StringUtils.isEmpty(fascicoloOggetto) ||
                !StringUtils.isEmpty(fascicoloAnno))

        Map<String, String> parametri = [idEnte     : springSecurityService.principal.idEnte,
                                         registro   : ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore,
                                         codice     : StringUtils.join("%", codice, "%"),
                                         descrizione: StringUtils.join("%", descrizione, "%"),
                                         oggetto    : StringUtils.join("%", oggetto, "%")]
        if (movimento) {
            parametri.movimento = movimento
        }
        if (classifica) {
            parametri.putAll([classificazioneCodice: StringUtils.join("%", classificazioneCodice, "%")])
        }
        if (fascicolo) {
            parametri.putAll([fascicoloNumero : StringUtils.join("%", fascicoloNumero, "%"),
                              fascicoloAnno   : StringUtils.join("%", fascicoloAnno, "%"),
                              fascicoloOggetto: StringUtils.join("%", fascicoloOggetto, "%")])
        }

        SchemaProtocollo.executeQuery("""
				SELECT  schema
				FROM   SchemaProtocollo schema
				WHERE 
						 schema.ente.id       = :idEnte
					   AND schema.valido        = true
					   AND coalesce(schema.codice, '*') != :registro
                       ${condizioneMovimento(movimento)}
					   AND schema.risposta      = false 
					   AND NOT EXISTS (
							   SELECT 1 FROM SchemaProtocolloUnita schemaUnita
							   WHERE schemaUnita.schemaProtocollo.id = schema.id)
					   AND upper(schema.codice) like coalesce(upper(:codice), upper(schema.codice))
                       AND coalesce(upper(schema.descrizione), '%') like coalesce(upper(:descrizione), coalesce(upper(schema.descrizione),'%'))
                       AND coalesce(upper(schema.oggetto), '%') like coalesce(upper(:oggetto), coalesce(upper(schema.oggetto), '%'))"""
                + (classifica ? "AND upper(schema.classificazione.codice) like upper(:classificazioneCodice)" : "")
                + (fascicolo ? ("AND upper(schema.fascicolo.numero) like upper(:fascicoloNumero)" +
                "AND upper(schema.fascicolo.anno) like upper(:fascicoloAnno)" +
                "AND upper(schema.fascicolo.oggetto) like upper(:fascicoloOggetto)") : "")
                , parametri)
    }

    public List<SchemaProtocollo> ricercaAvanzataPerUo(ArrayList<String> codiciUo, String movimento, String codice, String descrizione, String oggetto,
                                                       String fascicoloNumero, String fascicoloAnno, String fascicoloOggetto,
                                                       String classificazioneCodice) {

        boolean classifica = !StringUtils.isEmpty(classificazioneCodice)
        boolean fascicolo = (!StringUtils.isEmpty(fascicoloNumero) ||
                !StringUtils.isEmpty(fascicoloOggetto) ||
                !StringUtils.isEmpty(fascicoloAnno))

        Map<String, String> parametri = [idEnte     : springSecurityService.principal.idEnte,
                                         registro   : ImpostazioniProtocollo.TIPO_DOC_REG_PROT.valore,
                                         codiciUo   : codiciUo,
                                         codice     : StringUtils.join("%", codice, "%"),
                                         descrizione: StringUtils.join("%", descrizione, "%"),
                                         oggetto    : StringUtils.join("%", oggetto, "%")]
        if (movimento) {
            parametri.movimento = movimento
        }
        if (classifica) {
            parametri.putAll([classificazioneCodice: StringUtils.join("%", classificazioneCodice, "%")])
        }
        if (fascicolo) {
            parametri.putAll([fascicoloNumero : StringUtils.join("%", fascicoloNumero, "%"),
                              fascicoloAnno   : StringUtils.join("%", fascicoloAnno, "%"),
                              fascicoloOggetto: StringUtils.join("%", fascicoloOggetto, "%")])
        }

        SchemaProtocollo.executeQuery("""
				SELECT  schema
				FROM   SchemaProtocollo schema, SchemaProtocolloUnita schemaProtocolloUnita, So4UnitaPubb uoUtente
				WHERE  uoUtente.codice IN (:codiciUo) 
					   AND schema.id = schemaProtocolloUnita.schemaProtocollo.id
					   AND schemaProtocolloUnita.unita.progr	= uoUtente.progr
					   AND schemaProtocolloUnita.unita.dal = uoUtente.dal
					   AND schemaProtocolloUnita.unita.ottica = uoUtente.ottica.id
					   AND schema.ente.id       = :idEnte
					   AND schema.valido        = true
					   AND coalesce(schema.codice, '*') != :registro
                       ${condizioneMovimento(movimento)}
					   AND schema.risposta      = false 
	                   AND upper(schema.codice) like coalesce(upper(:codice), upper(schema.codice))
                       AND coalesce(upper(schema.descrizione), '%') like coalesce(upper(:descrizione), coalesce(upper(schema.descrizione),'%'))
                       AND coalesce(upper(schema.oggetto), '%') like coalesce(upper(:oggetto), coalesce(upper(schema.oggetto), '%'))"""
                + (classifica ? "AND upper(schema.classificazione.codice) like upper(:classificazioneCodice)" : "")
                + (fascicolo ? ("AND upper(schema.fascicolo.numero) like upper(:fascicoloNumero)" +
                "AND upper(schema.fascicolo.anno) like upper(:fascicoloAnno)" +
                "AND upper(schema.fascicolo.oggetto) like upper(:fascicoloOggetto)") : "")
                , parametri)
    }

    SchemaProtocolloFile uploadFile(SchemaProtocollo schema, Media media) {
        return uploadFile(schema, media.name, media.contentType, media.binary ? media.streamData : new ByteArrayInputStream(media.stringData.bytes))
    }

    List<TipoProtocollo> getTipiProtocolloPerCategoria(String categoria) {
        return TipoProtocollo.findAllByCategoriaAndValido(categoria, true)?.sort {
            it.descrizione
        }
    }

    List<SchemaProtocolloCategoria> categoriePerSchema(SchemaProtocollo schemaProtocollo) {
        return SchemaProtocolloCategoria.createCriteria().list {
            eq("schemaProtocollo", schemaProtocollo)
        }
    }

    SchemaProtocollo schemaBloccatoPerTipoProtocollo(TipoProtocollo tipoProtocollo) {
        return SchemaProtocolloCategoria.createCriteria().get {
            eq("tipoProtocollo", tipoProtocollo)
            eq("modificabile", false)
        }?.schemaProtocollo
    }

    SchemaProtocolloFile uploadFile(SchemaProtocollo schema, String nomeFile, String contentType, InputStream inputStream) {
        SchemaProtocolloFile schemaProtocolloFile = new SchemaProtocolloFile()
        schemaProtocolloFile.nome = getNomeFileUnivoco(schema.id, nomeFile)
        schemaProtocolloFile.contentType = contentType
        schemaProtocolloFile.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)

        schema.addToFiles(schemaProtocolloFile)
        schema.save()

        addFile(schema, schemaProtocolloFile, inputStream)

        return schemaProtocolloFile
    }

    String getNomeFileUnivoco(long idSchema, String nomeFile) {
        // conto i file che hanno il nome richiesto:
        String nome = nomeFile
        int numero = SchemaProtocollo.numeroFilePerNome(idSchema, nome).get()

        // se esiste già un file con questo nome, rinomino e ne creo un altro:
        int counter = 1
        while (numero > 0) {
            nome = nomeFile.replaceAll(/(\..+)$/, "(${counter})\$1")
            counter++
            numero = Documento.numeroFilePerNome(idSchema, nome).get()
        }

        return nome
    }

    void eliminaFileDocumento(SchemaProtocollo schema, SchemaProtocolloFile file) {
        schema.removeFromFiles(file)
        gestoreFile.removeFile(schema, file)
        file.delete()
        //tolta save che fa scattare trigger che fa update su gdm.documenti, già in essere per la chiamata
        // a gestoreFile.removeFile(schema, file)
//        schema.save()
    }

    private addFile(IDocumentoEsterno documento, IFileDocumento fileDocumento, InputStream is) {
        MarkableFileInputStream inputStream
        try {
            inputStream = new MarkableFileInputStream(is)

            if (inputStream.markSupported()) {
                inputStream.mark(Integer.MAX_VALUE)
            }

            // carico il file su gdm:
            salvaFile(documento, fileDocumento, inputStream)

            // ora che ho letto tutto lo stream, ne ho la dimensione e la scrivo:
            fileDocumento.dimensione = inputStream.byteCount
            fileDocumento.save()

            // questo è normalmente true per:
            // - MarkableFileInputStream	<- questo arriva quando si fa un upload di file più grosso di qualche centinaio di KB
            // - ByteArrayInputStream		<- questo arriva quando si fa un edita/testo o upload di file "piccoli"
            // - OracleBlobInputStream 		<- questo non so se arriverà mai
            if (inputStream.markSupported()) {
                inputStream.reset()
            }
        } finally {
            // chiudo qui l'input stream siccome nell'upload alla profilo, anch'essa tenta di chiuderlo
            // ma avendo sovrascritto il metodo close() per poter rileggere l'inputstream,
            // c'è bisogno di chiuderlo qui.
            inputStream.chiudiMeglio()
        }
    }

    private void salvaFile(SchemaProtocollo documento, SchemaProtocolloFile fileDocumento, InputStream inputStream) {
        try {

            it.finmatica.smartdoc.api.struct.Documento documentoSmart = new it.finmatica.smartdoc.api.struct.Documento()
            documentoSmart.setId(Long.toString(documento.idDocumentoEsterno))
            documentoSmart = documentaleService.getDocumento(documentoSmart, [it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.FILE])

            boolean creatoNuovoFileGdm = false

            // se ho l'idFileEsterno, devo sovrascrivere o rinominare il file:
            if (fileDocumento.idFileEsterno > 0) {
                // la "renameFileName" sostituisce il file anche se il nome file non cambia.
                // meglio usare questa funzione siccome la setFileName da' errore nel sostiuire un file
                // con lo stesso nome su un modello che può avere al massimo un file.
                File gdmFile = documentoSmart.trovaFile(new File(id: fileDocumento.idFileEsterno, nome: null))

                documentoSmart.renameFile(documento.idDocumentoEsterno, gdmFile, fileDocumento.nome)
            } else {
                documentoSmart.addFile(new File(fileDocumento.nome, inputStream))
                creatoNuovoFileGdm = true
            }

            documentoSmart = documentaleService.salvaDocumento(documentoSmart)

            if (creatoNuovoFileGdm) {
                fileDocumento.idFileEsterno = Long.parseLong(documentoSmart.trovaFile(new File(null, fileDocumento.nome))?.id)
            }

            fileDocumento.save()
        } catch (SQLException e) {
            throw new GestioneDocumentiRuntimeException(e)
        }
    }

    List<SchemaProtocolloSmistamento> getSchemiProtocolloSmistamento(long idSchemaProtocollo) {
        List<SchemaProtocolloSmistamento> smistamentiSchema = SchemaProtocolloSmistamento.createCriteria().list {
            eq("schemaProtocollo.id", idSchemaProtocollo)
            isNotNull("sequenza")
            order("sequenza", "asc")
        }

        return smistamentiSchema
    }

    List<SchemaProtocollo> ricercaSchemaProtocollo(String filtro, String movimento, TipoProtocollo tipoProtocollo, boolean privilegioMtot, List<String> codiciUoUtente, boolean includiSenzaMovimento = false) {
        So4UserDetail utente = springSecurityService.principal
        if (!movimento && !includiSenzaMovimento) {
            movimento = "*"
        }
        List<SchemaProtocollo> listaSchemiProtocollo
        if (!privilegioMtot && codiciUoUtente.size() > 0) {
            listaSchemiProtocollo = ricercaSenzaUnitaAssociate(filtro, movimento)
            List<SchemaProtocollo> listaSchemiProtocolloUnion = ricercaPerUo(codiciUoUtente as ArrayList<String>, filtro, movimento)
            List<SchemaProtocollo> listaSchemiProtocolloUnionFiltrataPerUoUtenteRuolo = new ArrayList<SchemaProtocollo>()
            if (!listaSchemiProtocolloUnion.isEmpty()) {
                listaSchemiProtocolloUnionFiltrataPerUoUtenteRuolo = strutturaOrganizzativaProtocolloService.filtraSchemaProtocolloPerCompetenze(listaSchemiProtocolloUnion)
            }

            if (listaSchemiProtocolloUnionFiltrataPerUoUtenteRuolo?.size() > 0) {
                listaSchemiProtocollo.addAll(listaSchemiProtocolloUnionFiltrataPerUoUtenteRuolo)
            }
        } else {
            // capo del mondo
            listaSchemiProtocollo = ricerca(filtro, movimento)
        }

        listaSchemiProtocollo = filtraPerTipoProtocollo(listaSchemiProtocollo, tipoProtocollo)
        return listaSchemiProtocollo
    }

    List<SchemaProtocollo> ricercaAvanzataSchemiProtocollo(String codice, String descrizione, String oggetto, String movimento, TipoProtocollo tipoProtocollo, boolean privilegioMtot, List<String> codiciUoUtente,
                                                           String fascicoloNumero, String fascicoloAnno, String fascicoloOggetto,
                                                           String classificazioneCodice, boolean includiSenzaMovimento = false) {
        if (!movimento && !includiSenzaMovimento) {
            movimento = "*"
        }
        List<SchemaProtocollo> listaSchemiProtocollo
        if (!privilegioMtot && codiciUoUtente.size() > 0) {
            listaSchemiProtocollo = ricercaAvanzataSenzaUnitaAssociate(codice, descrizione, oggetto, movimento, fascicoloNumero, fascicoloAnno, fascicoloOggetto,
                    classificazioneCodice)
            List<SchemaProtocollo> listaSchemiProtocolloUnion = ricercaAvanzataPerUo(codiciUoUtente as ArrayList<String>, movimento,
                    codice, descrizione, oggetto,
                    fascicoloNumero, fascicoloAnno, fascicoloOggetto,
                    classificazioneCodice)
            if (listaSchemiProtocolloUnion != null) {
                listaSchemiProtocollo.addAll(listaSchemiProtocolloUnion)
            }
        } else {
            // capo del mondo
            listaSchemiProtocollo = ricercaAvanzata(codice, descrizione, oggetto, movimento,
                    fascicoloNumero, fascicoloAnno, fascicoloOggetto,
                    classificazioneCodice)
        }

        listaSchemiProtocollo = filtraPerTipoProtocollo(listaSchemiProtocollo, tipoProtocollo)
        return listaSchemiProtocollo
    }

    List<SchemaProtocolloUnita> trovaUnita(SchemaProtocollo schema) {
        SchemaProtocolloUnita.createCriteria().list {
            eq('schemaProtocollo', schema)
            unita {
                order('descrizione', 'asc')
            }
        }
    }

    PagedResultList list(int pageSize, int activePage, String filterCondition, boolean visualizzaTutti) {
        if (visualizzaTutti) {
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        }
        try {
            PagedResultList lista = SchemaProtocollo.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
                if (!visualizzaTutti) {
                    eq("valido", true)
                }
                if (filterCondition ?: "" != "") {
                    or {
                        ilike("codice", "%${filterCondition}%")
                        ilike("descrizione", "%${filterCondition}%")
                    }
                }
                order('codice', 'asc')
            }
            return lista
        } finally {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }
    }

    private List<SchemaProtocollo> filtraPerTipoProtocollo(List<SchemaProtocollo> listaSchemiProtocollo, TipoProtocollo tipoProtocollo) {

        // se uno schema di protocollo non ha associato un tipo di protocollo può essere scelto
        // se uno schema di protocollo ha associato uno tipo di protocollo, questo deve essere uguale a quello del protocollo
        if (listaSchemiProtocollo && tipoProtocollo != null) {
            listaSchemiProtocollo = listaSchemiProtocollo.findAll {
                TipoProtocollo tipoProtocolloAssociato = it.tipoProtocollo
                tipoProtocolloAssociato == null || tipoProtocolloAssociato.id == tipoProtocollo.id
            }
        }

        // Gli schemi da cui è possibile scegliere, sono tutti quelli disponibili per la categoria (o senza categoria associata)
        listaSchemiProtocollo = listaSchemiProtocollo.findAll {
            List<SchemaProtocolloCategoria> categorie = categoriePerSchema(it)
            canAdd(categorie, tipoProtocollo)
        }
        listaSchemiProtocollo
    }

    private boolean canAdd(List<SchemaProtocolloCategoria> categorie, TipoProtocollo tipoProtocollo) {

        if (categorie == null || categorie.size() == 0) {
            return true
        } else if (categorie.size() == 1 && categorie.get(0).categoria == SchemaProtocolloCategoria.CATEGORIA_TUTTE) {
            return true
        } else {
            for (SchemaProtocolloCategoria cat : categorie) {
                if (tipoProtocollo.categoria == cat.categoria) {
                    if (it.finmatica.protocollo.impostazioni.CategoriaProtocollo.CATEGORIA_LETTERA.codice == tipoProtocollo.categoria) {
                        if (tipoProtocollo.id == cat.tipoProtocollo?.id) {
                            return true
                        } else {
                            return false
                        }
                    }
                    return true
                }
            }
        }
        return false
    }

    private SchemaProtocollo reloadFromDb(String codice) {
        SchemaProtocollo schema = null
        Session session = sessionFactory.getCurrentSession()
        session.disableFilter("soloValidiFilter")
        try {
            schema = SchemaProtocollo.findByCodice(codice)
        } finally {
            session.enableFilter("soloValidiFilter")
        }
        return schema
    }

    private String condizioneMovimento(String movimento) {
        movimento ? ' AND (schema.movimento IS NULL OR schema.movimento = :movimento) ' : ' '
    }
}