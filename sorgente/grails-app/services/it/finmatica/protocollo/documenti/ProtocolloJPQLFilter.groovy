package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic

@CompileStatic
/**
 * Classe di supporto per creare query dinamiche in JPAQL su fascicolo.
 * Dove non meglio specificato in genere il parametro dei metodi è il codice o l'id
 * Esempio di uso:
 *
 * <code>
 *     FascicoloJPAQLFilter filter = new FascicoloJPAQLFilter()
 *     String classificazione = ... // codice classificazione
 *     filter.haClassificazione(classificazione)
 *     // ... altri filtri in base alle esigenze
 *     List<Fascicolo> fascicoli = fascicoloService.findByFilter(filter)
 * </code>
 * La classe NON è threadsafe; le istanze sono da considerarsi usa e getta
 */
class ProtocolloJPQLFilter {
    private static final String ALIAS_PROTOCOLLO = 'PROT'
    private static final String ALIAS_CLASSIFICAZIONE = 'CL'
    private static final String ALIAS_TIPO_REGISTRO = 'TPREG'
    private static final String ALIAS_FASCICOLO = 'FASC'
    private static final String ALIAS_SOGGETTI = 'SOGG'
    private static final String ALIAS_UNITA = 'UNI'
    private static final String ALIAS_SMISTAMENTI = 'smist'
    private static final String ALIAS_UNITA_SMISTAMENTO = 'UNISM'

    private static final String PARAM_CLASSIFICAZIONE = 'codiceClass'
    private static final String PARAM_NUMERO = 'numero'
    private static final String PARAM_ANNO = 'anno'
    private static final String PARAM_ANNO_FASCICOLO = 'annoFascicolo'
    private static final String PARAM_OGGETTO = 'oggetto'
    private static final String PARAM_DATA_DA = 'dataDa'
    private static final String PARAM_DATA_A = 'dataA'
    private static final String PARAM_NUMERO_FASCICOLO = 'numeroFascicolo'
    private static final String PARAM_MOVIMENTO = 'movimento'
    private static final String PARAM_TIPO_SOGGETTO = 'tipReg'
    private static final String PARAM_UNITA = 'unita'
    private static final String PARAM_UNITA_SMIST = 'unita'

    boolean aggiuntaJoinTipoRegistro = false
    boolean aggiuntaJoinFascicolo = false
    boolean aggiuntaJoinClassificazione = false
    boolean aggiuntaJoinSoggetti = false
    boolean aggiuntaJoinSmistamenti = false

    List<String> joins = []
    List<String> whereConditions = []
    Map<String,Object> params = [:]

    String toJPQL() {
        return "SELECT ${ALIAS_PROTOCOLLO} FROM Protocollo ${ALIAS_PROTOCOLLO}\n ${getJoins()} ${getWhereClause()} ".toString()
    }

    String toSinglePropertyJPQL(String property) {
        return "SELECT ${ALIAS_PROTOCOLLO}.${property} FROM Protocollo ${ALIAS_PROTOCOLLO}\n ${getJoins()} ${getWhereClause()} ".toString()
    }

    private GString getJoins() {
        "${joins.join('\n')}\n"
    }

    private GString getWhereClause() {
        "WHERE ${whereConditions.join('\nAND ')}"
    }

    ProtocolloJPQLFilter haOggetto(String oggetto) {
        if(oggetto) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.oggetto = :${PARAM_OGGETTO} ".toString())
            params[PARAM_OGGETTO] = oggetto
        }
        return this
    }

    ProtocolloJPQLFilter haClassificazione(String classificazione) {
        if(classificazione) {
            if(!aggiuntaJoinClassificazione) {
                joins.add(" JOIN ${ALIAS_PROTOCOLLO}.classificazione ${ALIAS_CLASSIFICAZIONE} ".toString())
                aggiuntaJoinClassificazione = true
            }
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.codice = :${PARAM_CLASSIFICAZIONE} ".toString())
            params[PARAM_CLASSIFICAZIONE] = classificazione
        }
        return this
    }

    ProtocolloJPQLFilter daData(final Date dataDa) {
        if(dataDa) {
            whereConditions.add(" trunc(${ALIAS_PROTOCOLLO}.data) >= trunc(:${PARAM_DATA_DA}) ".toString())
            params[PARAM_DATA_DA] = dataDa
        }
        return this
    }

    ProtocolloJPQLFilter aData(final Date dataA) {
        if(dataA) {
            whereConditions.add(" trunc(${ALIAS_PROTOCOLLO}.data) <= trunc(:${PARAM_DATA_A}) ".toString())
            params[PARAM_DATA_A] = dataA
        }
        return this
    }

    ProtocolloJPQLFilter haNumeroFascicolo(String numero) {
        if(numero) {
            if(!aggiuntaJoinFascicolo) {
                joins.add(" JOIN ${ALIAS_PROTOCOLLO}.fascicolo ${ALIAS_FASCICOLO} ".toString())
                aggiuntaJoinFascicolo = true
            }
            whereConditions.add(" ${ALIAS_FASCICOLO}.numero = :${PARAM_NUMERO_FASCICOLO} ".toString())
            params[PARAM_NUMERO_FASCICOLO] = numero
        }
        return this
    }

    ProtocolloJPQLFilter haAnnoFascicolo(Integer anno) {
        if(anno) {
            if(!aggiuntaJoinFascicolo) {
                joins.add(" JOIN ${ALIAS_PROTOCOLLO}.fascicolo ${ALIAS_FASCICOLO} ".toString())
                aggiuntaJoinFascicolo = true
            }
            whereConditions.add(" ${ALIAS_FASCICOLO}.anno = :${PARAM_ANNO_FASCICOLO} ".toString())
            params[PARAM_ANNO_FASCICOLO] = anno
        }
        return this
    }

    ProtocolloJPQLFilter nonProtocollati() {
        whereConditions.add(" ${ALIAS_PROTOCOLLO}.numero IS NULL ".toString())
        return this
    }

    ProtocolloJPQLFilter protocollati() {
        whereConditions.add(" ${ALIAS_PROTOCOLLO}.numero IS NOT NULL ".toString())
        return this
    }

    ProtocolloJPQLFilter haNumero(Integer numero) {
        if(numero) {

            whereConditions.add(" ${ALIAS_PROTOCOLLO}.numero = :${PARAM_NUMERO} ".toString())
            params[PARAM_NUMERO] = numero
        }
        return this
    }

    ProtocolloJPQLFilter haAnno(Integer anno) {
        if(anno) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.anno = :${PARAM_ANNO} ".toString())
            params[PARAM_ANNO] = anno
        }
        return this
    }

    ProtocolloJPQLFilter haTipoRegistro(String tipoRegistro) {
        if(tipoRegistro) {
            if(!aggiuntaJoinTipoRegistro) {
                joins.add(" JOIN ${ALIAS_PROTOCOLLO}.tipoRegistro ${ALIAS_TIPO_REGISTRO} ".toString())
                aggiuntaJoinTipoRegistro = true
            }
            whereConditions.add(" ${ALIAS_TIPO_REGISTRO}.codice = :${PARAM_TIPO_SOGGETTO} ".toString())
            params[PARAM_TIPO_SOGGETTO] = tipoRegistro
        }
        return this
    }

    ProtocolloJPQLFilter haMovimento(String movimento) {
        if(movimento) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.movimento = :${PARAM_MOVIMENTO} ".toString())
            params[PARAM_MOVIMENTO] = movimento
        }
        return this
    }

    ProtocolloJPQLFilter haUnitaProtocollante(String unita) {
        if(unita) {
            if(!aggiuntaJoinSoggetti) {
                joins.add(" JOIN ${ALIAS_PROTOCOLLO}.soggetti ${ALIAS_SOGGETTI} JOIN ${ALIAS_SOGGETTI}.unitaSo4 ${ALIAS_UNITA} ".toString())
                aggiuntaJoinSoggetti = true
            }
            whereConditions.add (" ${ALIAS_UNITA}.codice = :${PARAM_UNITA} ".toString())
            whereConditions.add (" ${ALIAS_SOGGETTI}.tipoSoggetto = :${PARAM_TIPO_SOGGETTO} ".toString())
            params[PARAM_UNITA] = unita
            params[PARAM_TIPO_SOGGETTO] = it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.UO_PROTOCOLLANTE
        }
        return this
    }

    ProtocolloJPQLFilter haUnitaSmistamento(String unita) {
        if(unita) {
            if(!aggiuntaJoinSmistamenti) {
                joins.add(" JOIN ${ALIAS_PROTOCOLLO}.smistamenti ${ALIAS_SMISTAMENTI} JOIN ${ALIAS_SMISTAMENTI}.unitaSo4 ${ALIAS_UNITA_SMISTAMENTO} ".toString())
                aggiuntaJoinSmistamenti = true
            }
            whereConditions.add (" ${ALIAS_UNITA_SMISTAMENTO}.codice = :${PARAM_UNITA_SMIST} ".toString())
            params[PARAM_UNITA_SMIST] = unita
        }
        return this
    }

}
