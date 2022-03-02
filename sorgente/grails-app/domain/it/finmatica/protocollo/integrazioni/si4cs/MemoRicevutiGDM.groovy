package it.finmatica.protocollo.integrazioni.si4cs

import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.smistamenti.SmistamentoMemoRicevuti

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.EnumType
import javax.persistence.Enumerated
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.Lob
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.persistence.Table

@Entity
@Table(name = "agp_memo_ricevuti_gdm")
@CompileStatic
class MemoRicevutiGDM  {

    @GeneratedValue
    @Id
    @Column(name = "id_documento")
    Long id

    @Column(name = "id_messaggio_si4cs", nullable = false)
    Long idMessaggioSi4Cs

    @Column(nullable = false, name = "stato")
    @Enumerated(EnumType.STRING)
    MessaggioRicevuto.Stato statoMessaggio

    @Column(name = "data_ricezione")
    Date dataRicezione

    @Column(name = "data_spedizione")
    String dataSpedizione

    @Column(name = "data_stato", nullable = false)
    Date dataStato

    @Column(length = 2000)
    String mittente

    @Lob
    String destinatari

    @Lob
    @Column(name = "destinatari_conoscenza")
    String destinatariConoscenza

    @Lob
    @Column(name = "destinatari_nascosti")
    String destinatariNascosti

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_fascicolo")
    Fascicolo fascicolo

    @Column(name = "mime_testo")
    String mimeTesto

    @Lob
    String testo

    @Column(length = 4000)
    String note

    @Column(length = 255)
    String tipo

    @Column(length = 2000)
    String oggetto

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<DocumentoTitolario> titolari

    @Column(name = "IDRIF")
    String idrif

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<SmistamentoMemoRicevuti> smistamenti

    @Column(name = "link_documento", length = 4000)
    String linkDocumento
}