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
class ProtocolloWSJPQLFilter {
    private static final String ALIAS_PROTOCOLLO = 'PROT'

    private static final String PARAM_CLASSIFICAZIONE = 'codiceClass'
    private static final String PARAM_NUMERO = 'numero'
    private static final String PARAM_ANNO = 'anno'
    private static final String PARAM_ANNO_FASCICOLO = 'annoFascicolo'
    private static final String PARAM_OGGETTO = 'oggetto'
    private static final String PARAM_DATA_DA = 'dataDa'
    private static final String PARAM_DATA_A = 'dataA'
    private static final String PARAM_NUMERO_FASCICOLO = 'numeroFascicolo'
    private static final String PARAM_MODALITA = 'modalita'
    private static final String PARAM_TIPO_REGISTRO = 'tipReg'


    List<String> whereConditions = []
    Map<String,Object> params = [:]

    String toWSJPQL(String property = 'idDocumento') {
        return "SELECT ${ALIAS_PROTOCOLLO}.${property} FROM ProtocolloWS ${ALIAS_PROTOCOLLO}\n ${getWhereClause()} ".toString()
    }

    String toDAFascicolareJPQL(String property = 'idDocumento') {
        return "SELECT ${ALIAS_PROTOCOLLO}.${property} FROM ProtocolloDaFascicolareWS ${ALIAS_PROTOCOLLO}\n ${getWhereClause()} ".toString()
    }

    private GString getWhereClause() {
        "WHERE ${whereConditions.join('\nAND ')}"
    }

    ProtocolloWSJPQLFilter haOggetto(String oggetto) {
        if(oggetto) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.oggetto LIKE '%' || :${PARAM_OGGETTO} || '%' ".toString())
            params[PARAM_OGGETTO] = oggetto
        }
        return this
    }

    ProtocolloWSJPQLFilter haClassificazione(String classificazione) {
        if(classificazione) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.classificazione = :${PARAM_CLASSIFICAZIONE} ".toString())
            params[PARAM_CLASSIFICAZIONE] = classificazione
        }
        return this
    }

    ProtocolloWSJPQLFilter daData(final Date dataDa) {
        if(dataDa) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.data >= :${PARAM_DATA_DA} ".toString())
            params[PARAM_DATA_DA] = dataDa
        }
        return this
    }

    ProtocolloWSJPQLFilter aData(final Date dataA) {
        if(dataA) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.data <=:${PARAM_DATA_A} ".toString())
            params[PARAM_DATA_A] = dataA
        }
        return this
    }

    ProtocolloWSJPQLFilter haNumeroFascicolo(String numero) {
        if(numero) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.numeroFascicolo = :${PARAM_NUMERO_FASCICOLO} ".toString())
            params[PARAM_NUMERO_FASCICOLO] = numero
        }
        return this
    }


    ProtocolloWSJPQLFilter haAnnoFascicolo(Integer anno) {
        if(anno) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.annoFascicolo = :${PARAM_ANNO_FASCICOLO} ".toString())
            params[PARAM_ANNO_FASCICOLO] = anno
        }
        return this
    }

    ProtocolloWSJPQLFilter haNumero(Integer numero) {
        if(numero) {

            whereConditions.add(" ${ALIAS_PROTOCOLLO}.numero = :${PARAM_NUMERO} ".toString())
            params[PARAM_NUMERO] = numero
        }
        return this
    }

    ProtocolloWSJPQLFilter haAnno(Integer anno) {
        if(anno) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.anno = :${PARAM_ANNO} ".toString())
            params[PARAM_ANNO] = anno
        }
        return this
    }

    ProtocolloWSJPQLFilter haTipoRegistro(String tipoRegistro) {
        if(tipoRegistro) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.codice = :${PARAM_TIPO_REGISTRO} ".toString())
            params[PARAM_TIPO_REGISTRO] = tipoRegistro
        }
        return this
    }

    ProtocolloWSJPQLFilter haModalita(String modalita) {
        if(modalita) {
            whereConditions.add(" ${ALIAS_PROTOCOLLO}.movimento = :${PARAM_MODALITA} ".toString())
            params[PARAM_MODALITA] = modalita
        }
        return this
    }

    ProtocolloWSJPQLFilter nonProtocollati() {
        whereConditions.add(" ${ALIAS_PROTOCOLLO}.numero IS NULL ".toString())
        return this
    }

    ProtocolloWSJPQLFilter protocollati() {
        whereConditions.add(" ${ALIAS_PROTOCOLLO}.numero IS NOT NULL ".toString())
        return this
    }

}
