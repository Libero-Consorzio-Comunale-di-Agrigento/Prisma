package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.Lob
import javax.persistence.ManyToOne
import javax.persistence.Table

@CompileStatic
@Table(name = 'AS4_V_ANAGRAFICI_RECAPITI')
@Entity
class As4AnagrificiRecapiti {
    @Id
    @Column(name = "ID_SOGGETTO")
    Long idSoggetto
    @Column(name = "ID_RECAPITO")
    Long idRecapito
    @Column(name = "ID_CONTATTO")
    Long idContatto

    @Column(nullable = true, name = 'CODICE_FISCALE')
    String codiceFiscale
    @Column(nullable = true, name = 'PARTITA_IVA')
    String partitaIva


}
