package it.finmatica.protocollo.documenti.telematici

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import org.apache.commons.codec.digest.DigestUtils
import org.apache.commons.io.IOUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

@CompileStatic
@Service
@Transactional
class ProtocolloRiferimentoTelematicoService {

    private static final String CODIFICA = "base64"

    @Value("\${finmatica.protocollo.riferimentoTelematico.verificaImpronta:false}")
    boolean verificaImpronta = false

    @Autowired
    IGestoreFile gestoreFile

    @Autowired
    ProtocolloRiferimentoTelematicoRepository protocolloRiferimentoTelematicoRepository

    @Autowired
    UriStreamer uriStreamer

    @Autowired
    ProtocolloService protocolloService

    @Autowired
    AllegatoProtocolloService allegatoProtocolloService

    /**
     * verifica l'impronta di un riferimento; comporta la lettura dell'intero url
     * @param rif il riferimento da verificare
     * @return tre possibilità:  <code>true</code> se la verifica è andata a buon fine, <code>false</code> se la verifica è fallita,
     *  <code>null</code> se la verifica è ignorata da configurazione (vedi <b>finmatica.protocollo.riferimentoTelematico.verificaImpronta</b>)
     * @throw NoSuchAlgorithmException se la codifica non è base64 o l'algoritmo di hash non è riconosciuto
     */
    Boolean controllaImpronta(ProtocolloRiferimentoTelematico rif) {
        if (verificaImpronta) {
            def codifica = rif.improntaCodifica
            if (codifica != CODIFICA) {
                throw new NoSuchAlgorithmException("Algoritmo di codifica ${codifica} non supportato")
            }
            MessageDigest md = MessageDigest.getInstance(rif.improntaAlgoritmo);
            InputStream input = uriStreamer.riferimentoStream(rif)
            input.withCloseable {
                DigestUtils.updateDigest(md, input)
            }
            def digest = md.digest()
            def base64 = Base64.encoder.encode(digest)
            def hash = new String(base64, StandardCharsets.UTF_8)
            return hash == rif.impronta
        } else {
            return null
        }
    }

    private InputStream riferimentoStream(ProtocolloRiferimentoTelematico rif) {
        URL urlAllegato = new URL(rif.uri)
        InputStream input = urlAllegato.openStream()
        input
    }

    List<ProtocolloRiferimentoTelematico> importaRiferimenti(List<ProtocolloRiferimentoTelematico> riferimenti) {
        for (riferimento in riferimenti) {
            def improntaOk = controllaImpronta(riferimento)
            if (improntaOk != null) {
                riferimento.correttezzaImpronta = improntaOk ? 'Y' : 'N'
                protocolloRiferimentoTelematicoRepository.save(riferimento)
            }
        }
        return riferimenti
    }

    void salvaRiferimentiSuProtocollo(Protocollo protocollo, List<ProtocolloRiferimentoTelematico> riferimenti) {
        protocollo = refreshProtocollo(protocollo)
        for (riferimento in riferimenti) {
            riferimento = refreshRiferimento(riferimento)
            ProtocolloRiferimentoTelematico rif = refreshRiferimento(riferimento)
            BufferedInputStream bufferedInputStream = null
            try {
                bufferedInputStream = new BufferedInputStream(new URL(rif.uri).openStream())
            }
            catch(Exception e) {
                throw new ProtocolException("Attenzione! non è possibile scaricare dall'url indicato")
            }
            ByteArrayInputStream bais = new ByteArrayInputStream(IOUtils.toByteArray(bufferedInputStream))

            salvaRiferimentoFileSulProtocollo(protocollo, rif, bais, "application/octet-stream", new File(rif.uri).name)
            rif.scaricato = true
            protocolloRiferimentoTelematicoRepository.save(rif)
        }
    }

    void salvaRiferimentoFileSulProtocollo(Protocollo protocollo, ProtocolloRiferimentoTelematico riferimentoTelematico, InputStream is, String contentType, String nome) {
        if (riferimentoTelematico.tipo == "PRINCIPALE") {
            protocolloService.caricaFilePrincipale(protocollo, is, contentType, nome)
        } else {
            Allegato allegato = new Allegato()
            allegato.tipoAllegato = tipoAllegatoDefault()
            allegato.origine = riferimentoTelematico.uri
            allegato.descrizione = nome
            allegato.statoFirma = StatoFirma.DA_NON_FIRMARE
            allegatoProtocolloService.caricaAllegato(protocollo, allegato, nome, contentType, is)
        }
    }

    @CompileDynamic
    private Protocollo refreshProtocollo(Protocollo protocollo) {
        Protocollo.get(protocollo.id)
    }

    @CompileDynamic
    private Protocollo saveProtocollo(Protocollo protocollo) {
        protocollo.save()
    }

    @CompileDynamic
    private void salvaAllegato(Allegato allegato) {
        allegato.save()
    }

    @CompileDynamic
    private ProtocolloRiferimentoTelematico refreshRiferimento(ProtocolloRiferimentoTelematico riferimento) {
        ProtocolloRiferimentoTelematico.get(riferimento.id)
    }

    @CompileDynamic
    private TipoAllegato tipoAllegatoDefault() {
        TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
    }
}
