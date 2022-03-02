package it.finmatica.protocollo.titolario

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto

@CompileStatic

class ClassificazioneJPQLFilter {
    private static final String ALIAS_CLASSIFICAZIONE = 'CL'
    private static final String ALIAS_ENTE = 'EN'
    private static final String ALIAS_AMMINISTRAZIONE = 'AMM'

    private static final String PARAM_CODICE = 'codiceClass'
    private static final String PARAM_CODICE_LIKE = 'codiceClassLike'
    private static final String PARAM_DESCRIZIONE = 'oggetto'
    private static final String PARAM_CODICE_AMMINISTRAZIONE = 'amministrazione'
    private static final String PARAM_AOO = 'aoo'
    private static final String PARAM_VALIDO = 'valido'
    private static final String PARAM_CONTENITORE_DOCUMENTI = 'contDoc'

    boolean aggiuntaJoinEnte = false

    String select = "SELECT ${ALIAS_CLASSIFICAZIONE} FROM Classificazione ${ALIAS_CLASSIFICAZIONE} ".toString()
    List<String> joins = []
    List<String> whereConditions = []
    Map<String,Object> params = [:]

    String toJPQL() {
        return "${select}\n ${joins.join('\n')}\n WHERE ${whereConditions.join('\nAND ')}".toString()
    }

    ClassificazioneJPQLFilter haCodice(String codice) {
        if(codice) {
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.codice = :${PARAM_CODICE} ".toString())
            params[PARAM_CODICE] = codice
        }
        return this
    }

    ClassificazioneJPQLFilter haCodiceLike(String codice) {
        if(codice) {
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.codice LIKE :${PARAM_CODICE_LIKE} || '%' ".toString())
            params[PARAM_CODICE_LIKE] = codice
        }
        return this
    }

    ClassificazioneJPQLFilter haDescrizione(String descrizione) {
        if(descrizione) {
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.descrizione = :${PARAM_DESCRIZIONE} ".toString())
            params[PARAM_DESCRIZIONE] = descrizione
        }
        return this
    }

    ClassificazioneJPQLFilter haCodiceAmministrazione(String codiceAmministrazione) {
        if(codiceAmministrazione) {
            if(!aggiuntaJoinEnte) {
                joins.add(" JOIN ${ALIAS_CLASSIFICAZIONE}.ente ${ALIAS_ENTE} ".toString())
                joins.add(" JOIN ${ALIAS_ENTE}.amministrazione ${ALIAS_AMMINISTRAZIONE} ".toString())
                aggiuntaJoinEnte = true
            }
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.codice = :${PARAM_CODICE_AMMINISTRAZIONE} ".toString())
            params[PARAM_CODICE_AMMINISTRAZIONE] = codiceAmministrazione
        }
        return this
    }

    ClassificazioneJPQLFilter haAoo(String aoo) {
        if(aoo) {
            if (!aggiuntaJoinEnte) {
                joins.add(" JOIN ${ALIAS_CLASSIFICAZIONE}.ente ${ALIAS_ENTE} ".toString())
                joins.add(" JOIN ${ALIAS_ENTE}.amministrazione ${ALIAS_AMMINISTRAZIONE} ".toString())
                aggiuntaJoinEnte = true
            }
            whereConditions.add(" ${ALIAS_ENTE}.aoo = :${PARAM_AOO} ".toString())
            params[PARAM_AOO] = aoo
        }
        return this
    }

    ClassificazioneJPQLFilter contenitoreDocumenti() {
        whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.contenitoreDocumenti = :${PARAM_CONTENITORE_DOCUMENTI} ".toString())
        params[PARAM_CONTENITORE_DOCUMENTI] = true
        return this
    }

    ClassificazioneJPQLFilter valida() {
        whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.valido = :${PARAM_VALIDO} ".toString())
        params[PARAM_VALIDO] = true
        return this
    }
}
