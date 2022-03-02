package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = "ags_filtri_documenti_esterni")
@CompileStatic
class FiltriDocumentiEsterni {

    @Id
    String chiave

    @Column(name = "descrizione", nullable = false)
    String descrizione

    @Column(name = "campo_data_ordinamento", nullable = false)
    String campoDataOrdinamento
}