package it.finmatica.protocollo.titolario

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto

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
class FascicoloJPAQLFilter {
    private static final String ALIAS_FASCICOLO = 'FASC'
    private static final String ALIAS_CLASSIFICAZIONE = 'CL'
    private static final String ALIAS_ENTE = 'EN'
    private static final String ALIAS_AMMINISTRAZIONE = 'AMM'
    private static final String ALIAS_UTENTE = 'UT'
    private static final String ALIAS_SOGGETTI = 'SOGG'
    private static final String ALIAS_UNITA = 'UNI'
    private static final String ALIAS_DATI_SCARTO = 'DS'

    private static final String PARAM_CLASSIFICAZIONE = 'codiceClass'
    private static final String PARAM_CLASSIFICAZIONE_LIKE = 'codiceClassLike'
    private static final String PARAM_NUMERO = 'numero'
    private static final String PARAM_NUMERO_LIKE = 'numeroLike'
    private static final String PARAM_ANNO = 'anno'
    private static final String PARAM_DA_ANNO = 'daAnno'
    private static final String PARAM_A_ANNO = 'AAnno'
    private static final String PARAM_OGGETTO = 'oggetto'
    private static final String PARAM_NOTE = 'note'
    private static final String PARAM_STATO = 'stato'
    private static final String PARAM_DATA_APERTURA_DA = 'dataAperturaDa'
    private static final String PARAM_DATA_APERTURA_A = 'dataAperturaA'
    private static final String PARAM_DATA_CHIUSURA_DA = 'dataChiusuraDa'
    private static final String PARAM_DATA_CHIUSURA_A = 'dataChiusuraA'
    private static final String PARAM_DATA_CREAZIONE_DA = 'dataCreazioneDa'
    private static final String PARAM_DATA_CREAZIONE_A = 'dataCreazioneA'
    private static final String PARAM_CODICE_AMMINISTRAZIONE = 'amministrazione'
    private static final String PARAM_AOO = 'aoo'
    private static final String PARAM_NUMERO_DA = 'numeroDa'
    private static final String PARAM_NUMERO_A = 'numeroA'
    private static final String PARAM_STATO_SCARTO = 'statoScarto'
    private static final String PARAM_DATA_SCARTO_DA = 'dataScartoDa'
    private static final String PARAM_DATA_SCARTO_A = 'dataScartoA'
    private static final String PARAM_NOMINATIVO = 'nominativo'
    private static final String PARAM_UNITA = 'unita'
    private static final String PARAM_TIPO_SOGGETTO = 'unita'

    private static final List<String> STATI_SCARTO_VALIDI = ["**", "RR", "CO", "AA", "PS", "SC"]

    boolean aggiuntaJoinEnte = false
    boolean aggiuntaJoinAmministrazione = false
    boolean aggiuntoJoinUnita = false
    boolean aggiuntoJoinDatiScarto = false
    boolean aggiuntoJoinClassificazione = false

    String select = "SELECT ${ALIAS_FASCICOLO} FROM Fascicolo ${ALIAS_FASCICOLO} ".toString()
    List<String> joins = []
    List<String> whereConditions = []
    Map<String,Object> params = [:]

    String toJPAQL() {
        return "${select}\n ${joins.join('\n')}\n WHERE ${whereConditions.join('\nAND ')}".toString()
    }

    FascicoloJPAQLFilter haClassificazione(String codiceClassificazione) {
        if(codiceClassificazione) {
            if(!aggiuntoJoinClassificazione) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.classificazione ${ALIAS_CLASSIFICAZIONE} ".toString())
                aggiuntoJoinClassificazione = true
            }
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.codice = :${PARAM_CLASSIFICAZIONE} ".toString())
            params[PARAM_CLASSIFICAZIONE] = codiceClassificazione
        }
        return this
    }

    FascicoloJPAQLFilter haClassificazioneLike(String codice) {
        if(codice) {
            if(!aggiuntoJoinClassificazione) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.classificazione ${ALIAS_CLASSIFICAZIONE} ".toString())
                aggiuntoJoinClassificazione = true
            }
            whereConditions.add(" ${ALIAS_CLASSIFICAZIONE}.codice LIKE :${PARAM_CLASSIFICAZIONE_LIKE} || '%' ".toString())
            params[PARAM_CLASSIFICAZIONE_LIKE] = codice
        }
        return this
    }

    FascicoloJPAQLFilter haNumero(String numero) {
        if(numero) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.numero = :${PARAM_NUMERO} ".toString())
            params[PARAM_NUMERO] = numero
        }
        return this
    }

    FascicoloJPAQLFilter haNumeroLike(String numero) {
        if(numero) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.numero LIKE '%' || :${PARAM_NUMERO_LIKE} || '%' ".toString())
            params[PARAM_NUMERO_LIKE] = numero
        }
        return this
    }

    FascicoloJPAQLFilter haAnno(Integer anno) {
        if(anno) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.anno = :${PARAM_ANNO} ".toString())
            params[PARAM_ANNO] = anno
        }
        return this
    }

    FascicoloJPAQLFilter daAnno(Integer anno) {
        if(anno) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.anno >= :${PARAM_DA_ANNO} ".toString())
            params[PARAM_DA_ANNO] = anno
        }
        return this
    }

    FascicoloJPAQLFilter aAnno(Integer anno) {
        if(anno) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.anno <= :${PARAM_A_ANNO} ".toString())
            params[PARAM_A_ANNO] = anno
        }
        return this
    }

    FascicoloJPAQLFilter haOggetto(String oggetto) {
        if(oggetto) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.oggetto = :${PARAM_OGGETTO} ".toString())
            params[PARAM_OGGETTO] = oggetto
        }
        return this
    }

    FascicoloJPAQLFilter haNote(String note) {
        if(note) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.note = :${PARAM_NOTE} ".toString())
            params[PARAM_NOTE] = note
        }
        return this
    }

    FascicoloJPAQLFilter haStato(String stato) {
        if(stato) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.stato = :${PARAM_STATO} ".toString())
            params[PARAM_STATO] = stato
        }
        return this
    }

    FascicoloJPAQLFilter daDataApertura(final Date dataApertura) {
        if(dataApertura) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.dataApertura >= :${PARAM_DATA_APERTURA_DA} ".toString())
            params[PARAM_DATA_APERTURA_DA] = dataApertura
        }
        return this
    }

    FascicoloJPAQLFilter aDataApertura(final Date dataApertura) {
        if(dataApertura) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.dataApertura <= :${PARAM_DATA_APERTURA_A} ".toString())
            params[PARAM_DATA_APERTURA_A] = dataApertura
        }
        return this
    }

    FascicoloJPAQLFilter daDataChiusura(final Date dataChiusura) {
        if(dataChiusura) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.dataChiusura >= :${PARAM_DATA_CHIUSURA_DA} ".toString())
            params[PARAM_DATA_APERTURA_DA] = dataChiusura
        }
        return this
    }

    FascicoloJPAQLFilter aDataChiusura(final Date dataChiusura) {
        whereConditions.add(" ${ALIAS_FASCICOLO}.dataChiusura <= :${PARAM_DATA_CHIUSURA_A} ".toString())
        params[PARAM_DATA_APERTURA_A] = dataChiusura
        return this
    }

    FascicoloJPAQLFilter daDataCreazione(final Date dataCreazione) {
        if(dataCreazione) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.dateCreated >= :${PARAM_DATA_CREAZIONE_DA} ".toString())
            params[PARAM_DATA_APERTURA_DA] = dataCreazione
        }
        return this
    }

    FascicoloJPAQLFilter aDataCreazione(final Date dataCreazione) {
        if(dataCreazione) {
            whereConditions.add(" ${ALIAS_FASCICOLO}.dateCreated <= :${PARAM_DATA_CREAZIONE_A} ".toString())
            params[PARAM_DATA_APERTURA_A] = dataCreazione
        }
        return this
    }

    FascicoloJPAQLFilter haAmministrazione(String codiceAmministrazione) {
        if(codiceAmministrazione) {
            if(!aggiuntaJoinEnte) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.ente ${ALIAS_ENTE} ".toString())
                aggiuntaJoinEnte = true
            }
            if(!aggiuntaJoinAmministrazione) {
                joins.add(" JOIN ${ALIAS_ENTE}.amministrazione ${ALIAS_AMMINISTRAZIONE} ".toString())
                aggiuntaJoinAmministrazione = true
            }
            whereConditions.add(" ${ALIAS_AMMINISTRAZIONE}.codice = :${PARAM_CODICE_AMMINISTRAZIONE} ".toString())
            params[PARAM_CODICE_AMMINISTRAZIONE] = codiceAmministrazione
        }
        return this
    }

    FascicoloJPAQLFilter haAoo(String aoo) {
        if(aoo) {
            if (!aggiuntaJoinEnte) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.ente ${ALIAS_ENTE} ".toString())
                aggiuntaJoinEnte = true
            }
            whereConditions.add(" ${ALIAS_ENTE}.aoo = :${PARAM_AOO} ".toString())
            params[PARAM_AOO] = aoo
        }
        return this
    }

    FascicoloJPAQLFilter numeroDal(String numero) {
        if(numero) {
            whereConditions.add(" AGS_FASCICOLI_PKG.get_numero_fasc_ord(${ALIAS_FASCICOLO}.numero) >= :${PARAM_NUMERO_DA} ".toString())
            params[PARAM_NUMERO_DA] = numero
        }
        return this
    }

    FascicoloJPAQLFilter numeroA(String numero) {
        if(numero) {
            whereConditions.add(" AGS_FASCICOLI_PKG.get_numero_fasc_ord(${ALIAS_FASCICOLO}.numero) <= :${PARAM_NUMERO_A} ".toString())
            params[PARAM_NUMERO_A] = numero
        }
        return this
    }

    FascicoloJPAQLFilter haStatoScarto(String statoScarto) {
        if(statoScarto && statoScarto in STATI_SCARTO_VALIDI) {
            if(!aggiuntoJoinDatiScarto) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.datiScarto ${ALIAS_DATI_SCARTO} ".toString())
            }
            whereConditions.add(" ${ALIAS_DATI_SCARTO}.stato = :${PARAM_STATO_SCARTO} ".toString())
            params[PARAM_STATO_SCARTO] = statoScarto
        }
        return this
    }

    FascicoloJPAQLFilter dataScartoDalAl(Date dataScartoDal, Date dataScartoAl) {
        if(dataScartoDal && dataScartoAl) {
            if(!aggiuntoJoinDatiScarto) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.datiScarto ${ALIAS_DATI_SCARTO} ".toString())
            }
            whereConditions.add(" ${ALIAS_DATI_SCARTO}.dataStato BETWEEN :${PARAM_DATA_SCARTO_DA} AND :${PARAM_DATA_SCARTO_A} ".toString())
            params[PARAM_DATA_SCARTO_DA] = dataScartoDal
            params[PARAM_DATA_SCARTO_A] = dataScartoAl
        }
        return this
    }

    FascicoloJPAQLFilter haUtenteCreazione(String nominativo) {
        if(nominativo) {
            joins.add(" JOIN ${ALIAS_FASCICOLO}.utenteIns ${ALIAS_UTENTE} ".toString())
            whereConditions.add(" ${ALIAS_UTENTE}.nominativo = :${PARAM_NOMINATIVO} ".toString())
            params[PARAM_NOMINATIVO] = nominativo
        }
        return this
    }

    FascicoloJPAQLFilter haUnitaCompetenza(String unita) {
        haUnita(unita,TipoSoggetto.UO_COMPETENZA)
    }
    FascicoloJPAQLFilter haUnitaCreazione(String unita) {
        haUnita(unita,TipoSoggetto.UO_CREAZIONE)
    }


    private FascicoloJPAQLFilter haUnita(String unita, String tipoSoggetto) {
        if(unita) {
            if(!aggiuntoJoinUnita) {
                joins.add(" JOIN ${ALIAS_FASCICOLO}.soggetti ${ALIAS_SOGGETTI} JOIN soggetti.unitaSo4 ${ALIAS_UNITA} ".toString())
                aggiuntoJoinUnita = true
            }
            whereConditions.add (" ${ALIAS_UNITA}.codice = :${PARAM_UNITA} ".toString())
            whereConditions.add (" ${ALIAS_SOGGETTI}.tipoSoggetto = :${PARAM_TIPO_SOGGETTO} ".toString())
            params[PARAM_UNITA] = unita
            params[PARAM_TIPO_SOGGETTO] = tipoSoggetto
        }
        return this
    }

}
