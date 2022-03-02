package it.finmatica.protocollo.documenti

import it.finmatica.gestionedocumenti.documenti.Allegato

class TipoCollegamentoConstants {

    public static final String CODICE_TIPO_PROTOCOLLO_PRECEDENTE = 'PROT_PREC'
    public static final String CODICE_TIPO_PROT_PEC = 'PROT_PEC'
    public static final String CODICE_TIPO_PROTOCOLLO_RIFERIMENTO = 'PROT_RIFE'
    public static final String CODICE_TIPO_DATI_ACCESSO = 'PROT_DAAC'
    public static final String CODICE_TIPO_REGISTRO_EMERGENZA = 'EMER'
    public static final String CODICE_TIPO_REGISTRO_PROVVEDIMENTO = 'PROV_PROT'
    public static final String CODICE_TIPO_MAIL = 'MAIL'
    public static final String CODICE_PROT_DA_FASCICOLARE = 'PROT_DAFAS'
    public static final String CODICE_TIPO_ALLEGATO = Allegato.CODICE_TIPO_COLLEGAMENTO
    public static final String CODICE_FASC_PREC_SEG = 'F_PREC_SEG'
    public static final String CODICE_FASC_COLLEGATO= 'F_COLLEGA'
    public static final String CODICE_TIPO_COLLEGAMENTO_PROT_CONF = 'PROT_CONF'
    public static final String CODICE_TIPO_COLLEGAMENTO_PROT_AGG = 'PROT_AGG'
    public static final String CODICE_TIPO_COLLEGAMENTO_PROT_ANN = 'PROT_ANN'
    public static final String CODICE_TIPO_COLLEGAMENTO_PROT_ECC = 'PROT_ECC'

    public static final List<String> nonUtilizzabili = [CODICE_TIPO_REGISTRO_EMERGENZA,
                                                        CODICE_TIPO_REGISTRO_PROVVEDIMENTO,
                                                        CODICE_TIPO_ALLEGATO,
                                                        CODICE_PROT_DA_FASCICOLARE,
                                                        CODICE_TIPO_MAIL,
                                                        CODICE_FASC_PREC_SEG,
                                                        CODICE_FASC_COLLEGATO]

    public static final List<String> perFascicolo = [CODICE_FASC_PREC_SEG,
                                                     CODICE_FASC_COLLEGATO]

    public static final List<String> univoci = [CODICE_TIPO_PROTOCOLLO_PRECEDENTE,
                                                CODICE_TIPO_DATI_ACCESSO]
}
