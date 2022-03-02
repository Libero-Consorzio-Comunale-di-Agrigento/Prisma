package it.finmatica.protocollo.integrazioni.si4cs

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import org.hibernate.annotations.Type
import org.hibernate.envers.Audited
import org.hibernate.envers.NotAudited

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Lob
import javax.persistence.OneToMany
import javax.persistence.Table

@Audited
@Entity
@Table(name = "agp_msg_inviati_dati_prot")
@CompileStatic
class MessaggioInviato extends Documento {
    @NotAudited
    @Column(name = "id_messaggio_si4cs", nullable = false)
    Long idMessaggioSi4Cs

    @NotAudited
    @Column(length = 2000)
    String oggetto

    @NotAudited
    @Lob
    @Column(name = "testo")
    String testo

    @NotAudited
    @Column(length = 2000)
    String mittente

    @NotAudited
    @Lob
    String destinatari

    @NotAudited
    @Lob
    @Column(name = "destinatari_conoscenza")
    String destinatariConoscenza

    @NotAudited
    @Lob
    @Column(name = "destinatari_nascosti")
    String destinatariNascosti

    @NotAudited
    @Column(length = 2000)
    String tagmail

    @NotAudited
    @Column(name = "mittente_amministrazione", length = 255)
    String mittenteAmministrazione

    @NotAudited
    @Column(name = "mittente_aoo", length = 255)
    String mittenteAoo

    @NotAudited
    @Column(name = "mittente_uo", length = 255)
    String mittenteUo

    @Column(name = "stato_spedizione", length = 240)
    String statoSpedizione

    @Column(name = "data_spedizione")
    Date dataSpedizione

    @Type(type = "yes_no")
    @Column(length = 1)
    boolean accettazione

    @Type(type = "yes_no")
    @Column(name = "non_accettazione", length = 1)
    boolean nonAccettazione

    @Column(name = "data_accettazione")
    Date dataAccettazione

    @Column(name = "data_non_accettazione")
    Date dataNonAccettazione

    SchemaProtocollo getSchemaProtocollo() {
        return null
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return null
    }

    Integer getNumero() {
        return null
    }

    String getMovimento() {
        return null
    }
}
