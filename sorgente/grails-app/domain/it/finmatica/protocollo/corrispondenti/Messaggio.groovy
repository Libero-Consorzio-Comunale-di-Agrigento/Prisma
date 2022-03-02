package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import org.hibernate.annotations.Type

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Lob
import javax.persistence.OneToMany
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_messaggi")
@CompileStatic
class Messaggio extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_documento")
    Long id

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "messaggio", orphanRemoval = true)
    Set<CorrispondenteMessaggio> corrispondenti

    @Column(name = "data_spedizione_memo", nullable = true)
    String dataSpedizioneMemo

    @Column(name = "data_ricezione", nullable = true)
    Date dataRicezione

    @Lob
    @Column(nullable = false)
    String destinatari

    @Lob
    @Column(name = "destinatari_conoscenza", nullable = false)
    String destinatariConoscenza

    @Lob
    @Column(name = "destinatari_nascosti")
    String destinatariNascosti

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    @Type(type = "yes_no")
    @Column(name = "in_partenza")
    boolean inPartenza

    @Column(name = "link_documento", nullable = false)
    String linkDocumento

    @Column(nullable = false)
    String mittente

    @Column(nullable = false)
    String oggetto

    @Lob
    @Column(name = "corpo")
    String corpo

    @Type(type = "yes_no")
    @Column(name = "registrata_accettazione")
    boolean registrataAccettazione

    @Type(type = "yes_no")
    @Column(name = "registrata_non_accettazione")
    boolean registrataNonAccettazione

    @Type(type = "yes_no")
    boolean spedito

    @Column(name = "stato_memo", nullable = false)
    String statoMemo

    @Column(name = "mittente_amministrazione", nullable = false)
    String mittenteAmministrazione

    @Column(name = "mittente_aoo", nullable = false)
    String mittenteAOO

    @Column(name = "mittente_codice_uo", nullable = false)
    String mittenteCodiceUO

    @Version
    Long version

    void addToCorrispondenti(CorrispondenteMessaggio value) {
        if (this.corrispondenti == null) {
            this.corrispondenti = new HashSet<CorrispondenteMessaggio>()
        }
        this.corrispondenti.add(value);
        value.messaggio = this
    }

    void removeFromCorrispondenti(CorrispondenteMessaggio value) {
        if (this.corrispondenti == null) {
            this.corrispondenti = new HashSet<CorrispondenteMessaggio>()
        }
        this.corrispondenti.remove((Object) value);
        value.messaggio = null
    }
}