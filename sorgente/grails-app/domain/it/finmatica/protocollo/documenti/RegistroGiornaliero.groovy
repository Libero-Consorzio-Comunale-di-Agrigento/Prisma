package it.finmatica.protocollo.documenti

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = 'agp_protocolli_dati_reg_giorn')
//@ModelloGdm(tipologiaDocumentale = "PROTOCOLLO")
class RegistroGiornaliero {

    @GeneratedValue
    @Id
    @Column(name = "ID_PROTOCOLLO_DATI_REG_GIORN")
    Long id

    @Column(name='primo_numero', nullable = false)
    int primoNumero
    @Column(name='ultimo_numero', nullable = false)
    int ultimoNumero
    @Column(name='data_primo_numero', nullable = false)
    Date dataPrimoNumero
    @Column(name='data_ultimo_numero', nullable = false)
    Date dataUltimoNumero
    @Column(name='totale_protocolli')
    int totaleProtocolli
    @Column(name='totale_annullati')
    int totaleAnnullati
    @Column(name='ricerca_data_dal')
    Date ricercaDataDal
    @Column(name='ricerca_data_al')
    Date ricercaDataAl
    @Column(name='errore')
    String errore
    transient Protocollo protocollo


}
