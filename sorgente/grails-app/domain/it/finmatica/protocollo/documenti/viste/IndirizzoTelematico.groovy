package it.finmatica.protocollo.documenti.viste

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = 'SO4_VISTA_INDIRIZZI_TELEMATICI')
class IndirizzoTelematico {

    @Column(name = "codice_amministrazione", insertable = false, updatable = false)
    String codiceAmministrazione

    @Column(name = "codice_uo", insertable = false, updatable = false)
    String codiceUo

    @Column(name = "codice_aoo", insertable = false, updatable = false)
    String codiceAoo

    @Column(name = "tipo_indirizzo", insertable = false, updatable = false)
    String tipoIndirizzo

    @Id
    @Column(name = "indirizzo", insertable = false, updatable = false)
    String indirizzo

    @Column(name = "provenienza", insertable = false, updatable = false)
    String provenienza

    @Column(name = "comune", insertable = false, updatable = false)
    String comune

    @Column(name = "descrizione_amministrazione", insertable = false, updatable = false)
    String descrizioneAmministrazione

    @Column(name = "descrizione_aoo", insertable = false, updatable = false)
    String descrizioneAoo

    @Column(name = "descrizione_uo", insertable = false, updatable = false)
    String descrizioneUo

    @Column(name = "des_tipo_indirizzo", insertable = false, updatable = false)
    String desTipoIndirizzo

    @Column(name = "provincia", insertable = false, updatable = false)
    String provincia

    @Column(name = "regione", insertable = false, updatable = false)
    String regione

    @Column(name = "sigla_comune", insertable = false, updatable = false)
    String siglaComune

    @Column(name = "sigla_provincia", insertable = false, updatable = false)
    String siglaProvincia
}
