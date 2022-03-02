package it.finmatica.protocollo.documenti.tipologie

import groovy.transform.CompileStatic
import it.finmatica.gestioneiter.configuratore.dizionari.WkfGruppoStep
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgStep
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "parametri_tipologie")
class ParametroTipologia {

    @GeneratedValue
    @Id
    @Column(name = "id_parametro_tipologia")
    Long id

    @Column(nullable = false)
    String codice

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_gruppo_step")
    WkfGruppoStep gruppoStep

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_protocollo")
    TipoProtocollo tipoProtocollo

    String valore

    @Version
    Long version


    public static String getValoreParametro (def tipologia, WkfCfgStep cfgStep, String codice) {
        String propertyName = null;
        if (tipologia instanceof TipoProtocollo) {
            propertyName = "tipoProtocollo"
        } else {
            throw new ProtocolloRuntimeException ("Attenzione! Tipologia di documento non riconosciuta: ${tipologia?.class}")
        }

        if (cfgStep.gruppoStep == null) {
            throw new ProtocolloRuntimeException ("Attenzione! Configurazione Errata! È necessario specificare un Gruppo Step per ottenere i parametri delle azioni!")
        }

        ParametroTipologia p = ParametroTipologia.createCriteria().get {
            eq (propertyName, 	tipologia)
            eq ("gruppoStep.id",cfgStep.gruppoStep.id)
            eq ("codice", 		codice)
        }

        return p?.valore
    }

    public static Collection<String> getValoriParametri (def tipologia, String codice) {
        String propertyName = null;
        if (tipologia instanceof TipoProtocollo) {
            propertyName = "tipoProtocollo"
        } else {
            throw new ProtocolloRuntimeException ("Attenzione! Tipologia di documento non riconosciuta: ${tipologia?.class}")
        }

        return ParametroTipologia.createCriteria().list {
            projections {
                distinct("valore")
            }
            eq (propertyName, 	tipologia)
            eq ("codice", 		codice)
        }
    }
}