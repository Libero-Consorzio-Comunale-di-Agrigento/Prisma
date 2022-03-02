package it.finmatica.protocollo.impostazioni

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioniMap

import java.text.ParseException

@Slf4j
enum ImpostazioniProtocollo {

	// aggiungere qui i codici delle impostazioni
	COPIA_CONFORME_PDF					("Abilita la copia conforme sugli allegati in formato pdf", "COPIA_CONFORME_PDF", "Y", '', true),
	TESTO_COPIA_CONFORME				("Le variabili da gestire sono: \$firmatari, \$registro_protocollo, \$numero_protocollo, \$anno_protocollo, \$data_protocollo, \$acapo con prefizzo il simbolo dollaro", "TESTO_COPIA_CONFORME", "Riproduzione cartacea del documento informatico sottoscritto digitalmente da \$acapo \$firmatari \$acapo \$registro_protocollo: \$anno_protocollo / \$numero_protocollo del \$data_protocollo", '', true),
	TESTO_COPIA_CONFORME_NON_FIRMATO 	("Le variabili da gestire sono: \$firmatari, \$registro_protocollo, \$numero_protocollo, \$anno_protocollo, \$data_protocollo, \$acapo con prefizzo il simbolo dollaro", "TESTO_COPIA_CONFORME", "Riproduzione cartacea del documento \$acapo \$registro_protocollo: \$anno_protocollo / \$numero_protocollo del \$data_protocollo", '', true),
	COPIA_CONFORME_POSIZIONE			("Posizione in stampa del testo", "Posizione in stampa del testo", "ALTO_CENTRATO", null, true),
	FILE_ALLEGATO_OB 			("Indica se è necessaria la presenza di almeno un file in ogni allegato (valori: Y/N, default N)", "FILE_ALLEGATO_OB", "N", '', true),
	FIRMA_ALLEGATO 				("Indica se il singolo allegato può essere firmato (valori: Y/N, default N)", "FIRMA_ALLEGATO", "N", '', true),
	MOD_SPED_ATTIVO				("Indica se il modulo della gestione della spedizione è attivo (valori: Y/N, default N)", "MOD_SPED_ATTIVO", "Y", '', true),
	PROVV_ANN 					("Provvedimentodi Annullamento", "PROVV_ANN", "Provvedimento diretto", '', true),
	ANN_DIRETTO 				("Annullamento diretto", "ANNULLAMENTO DIRETTO", "Y", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	CONCAT_RADICE_UO_PROT		("Determina se concatenare la Uo radice alla Uo Protocollante", "CONCAT RADICE UO PROT", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	FASC_OB                     ("Fascicolo obbligatorio", "FASCICOLO OBBLIGATORIO", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /><row label="PAR" value="PAR" /></rowset>', true),
	CLASS_OB					("Classificazione obbligatoria", "CLASSIFICAZIONE OBBLIGATORIO", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	CLAS_FASC_PERS              ("Classificazione fascicoli del personale", "CLASSIFICAZIONE FASCICOLI DEL PERSONALE", "", null, true),
	ITER_FASCICOLI		        ("Presente Ubicazione", "ITER FASCICOLI", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	ITER_FASC_SMIST_OB	        ("Indica se smistamento e' obbligatorio anche in presenza di iter_fascicoli a true e smistamento ereditato dal fascicolo", "ITER FASC SMIST_OB", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	VCLA_ABILITA_VF	        	("Abilita la lettura dei fascicoli non riservati.", "VCLA_ABILITA_VF", "Y", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	OGG_OB						("Oggetto obbligatorio", "OGGETTO OBBLIGATORIO", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	RAPP_OB					    ("Corrispondente obbligatorio", "RAPP OB", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	SMIST_INT_OB				("Smistamento obbligatorio per documenti interni", "SMIST INT OB", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	SMIST_ARR_OB				("Smistamento obbligatorio per documenti in arrivo", "SMIST ARR OB", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	SMIST_PAR_OB				("Smistamento obbligatorio per documenti in partenza", "SMIST PAR OB", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	SMIST_AUTO_PEC				("Smistamento automatico per le pec in arrivo da segnatura", "SMIST AUTO PEC", "N", null, true),
	FILE_OB						("File Obbligatorio", "FILE OBBLIGATORIO", "N", '<rowset><row label="Solo per documenti in partenza" value="PAR" /><row label="Solo per documenti in partenza e interni" value="PAR_INT" /><row label="No" value="N" /></rowset>', true),
	TIPO_DOC_OB					("Tipo Documento Obbligatorio", "TIPO DOCUMENTO OBBLIGATORIO", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	DATA_ARRIVO_OB				("Data Arrivo Obbligatorio", "DATA ARRIVO OB", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', false),
	DATA_BLOCCO					("Data Bolocco relativa ai privilegi", "DATA_BLOCCO", "", null, true),
	TIPO_REGISTRO				("Tipo di registro", "TIPO REGISTRO", "", '', true),
	PROTOCOLLO_GDM_PROPERTIES	("Path in cui si trova il file gd4dm.properties", "GD4DM.PROPERTIES", "confapps/gd4dm.properties", null, true),
	ANA_FILTRO					("Indica se le anagrafiche presenti in as4 devono essere filtrate considerando la presenza di cf o pi.", "ANA FILTRO","N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	JCONS_WSDL_URL				("Indica l'url al wsdl del ws della conservazione", "JCONS_WSDL_URL", "http://localhost:8080/jconsWS/JConsServicePort?wsdl", null, true),
	JCONS_URL_SERVER			("Indica l'url del server per la visualizzazione del documento in conservazione all'interno del LOG" , "JCONS_URL_SERVER", "http://localhost:8080", null, true),
	JCONS_CONTEXT_PATH			("Indica il nome del contesto del documentale per la visualizzazione del documento in conservazione all'interno del LOG", "JCONS_CONTEXT_PATH", "/jdms", null, true),
	JCONS_NOME_ITER				("Indica il nome dell'iter di workflow da instanziare per la conservazione", "JCONS_NOME_ITER", "JSUITE_CONSERVAZIONE_STD", null, true),
	CONSERVAZIONE_AUTOMATICA_LIMITE ("Numero di documenti massimo che viene inviato in conservazione giornalmente (indicare -1 se non si vuole limitare l'invio)", "Numero Documenti Conservazione", "-1", null, true),
	STAMPA_UNICA				("Abilita la creazione della stampa unica come allegato", "Abilita Stampa Unica", "N", null, true),
	STAMPA_UNICA_SUBITO			("Abilita il download della stampa unica", "Abilita Download Stampa Unica", "N", null, true),
	STAMPA_UNICA_FRASE_FOOTER	("Frase da aggiungere in fondo ad ogni pagina nella stampa unica", "Stampa Unica - Frase Footer", "Copia informatica per consultazione. \$NUMPG\$ / \$ANNOPG\$ del \$DATAPG\$ precisamente \$DATAORAPG\$", null, true),
	SU_FOOTER_ROT				("Rotazione frase footer", "Rotazione frase footer", "0", null, true),
	SU_FOOTER_XPOS				("Coordinata X frase footer", "Coordinata X frase footer", "5", null, true),
	SU_FOOTER_YPOS				("Coordinata Y frase footer", "Coordinata Y frase footer", "5", null, true),
	RISERVATO 					("Definisce se è abilitata la riservatezza oppure no", "RISERVATO", "Y", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	ALIAS_INVIO_MAIL			("Alias selezionato fra quelli indicati nel si4cim.cfg per l'invio di mail NON certicate", "Alias mail NON certificate", "mail", null, true),
	ALIAS_INVIO_MAIL_CERT		("Alias selezionato fra quelli indicati nel si4cim.cfg per l'invio di mail certicate", "Alias mail certificate", "mail_cert", null, true),
	MITTENTE_INVIO_MAIL			("Mittente per l'invio di mail", "Mittente mail", "protocollo@ads.it", null, true),
	MITTENTE_INVIO_MAIL_CERT	("Mittente per l'invio di mail certicate", "Mittente mail certicate", "istituzionaleads@cert.legalmail.it", null, true),
	INTEGRAZIONE_ALBO			("Abilita o meno l'integrazione con l'Albo JMessi.", "Integrazione Albo JMessi", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	INTEGRAZIONE_GDM			("Abilita o meno l'integrazione con il documentale GDM", "Import allegati da documentale", "Y", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	FIRMA_REMOTA				("Definisce se è abilitata la firma remota", "FIRMA REMOTA", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	IMPORT_ALLEGATO_GDM_URL		("Indica l'url alla servlet da invocare per effettuare l'import degli allegati su GDM", "IMPORT_ALLEGATO_GDM_URL", "http://localhost:8080", null, true),
	IMPORT_ALLEGATO_GDM			("Abilita la funzionalità di import degli allegati di GDM", "IMPORT_ALLEGATO_GDM", "N", null, true),
	LUNGHEZZA_OGGETTO			("Lunghezza massima dell'oggetto dei documenti determina/proposta delibera/delibera", "Lunghezza massima dell'oggetto dei documenti", "2000", null, true),
	PROTOCOLLO_ATTIVO			("Indica se è abilitata la protocollazione.", "PROTOCOLLO ATTIVO", "N", '<rowset><row label="No"  value="N" /><row label="Si"  value="Y" /></rowset>', true),
	PROTOCOLLA_NOT_ECC			("Indica se mettere come valido = 'N' un documento di interoperabilità quando viene fatta una notifica di eccezione.", "PROTOCOLLO NOTIFICA ECCEZIONE", "N", '<rowset><row label="No"  value="N" /><row label="Si"  value="Y" /></rowset>', true),
	RUOLO_ACCESSO_APPLICATIVO 	("Ruolo di accesso alla applicazione", "RUOLO ACCESSO APPLICATIVO", "AGP", null, true),
	RUOLO_MODELLI_TESTO 	    ("Ruolo di accesso al dizionario dei modelli di testo", "RUOLO_MODELLI_TESTO", "AGPMOD", null, true),
	CHECK_COMPONENTI			("Assicura che sia possibile smistare solo a utenti abilitati", "SMISTAMENTI SOLO A UTENTI ABILITATI", "N", '<rowset><row label="No"  value="N" /><row label="Si"  value="Y" /></rowset>', true),
    UNITA_EXPAND_LEVEL          ("Indica il numero del livello da aprire in automatico quando si visualizza l'albero delle unità di so4", "LIVELLO DA MOSTRARE NELL'ALBERO SO4", "1", null, true),
	RUOLO_SO4_RESPONSABILE		("Ruolo che identifica il responsabile di una UO", "RUOLO RESPONSABILE", "AGPRESP", null, true),
	RUOLO_REDATTORE     		("Ruolo che identifica il redattore", "RUOLO REDATTORE", "AGPRED", null, true),
	RUOLO_FASC_PERS     		("Ruolo che identifica chi accede ai fascicoli del personale", "RUOLO FASCICOLI PERSONALE", "AGPPERS", null, false),
	TIPO_DOC_REG_PROT           ("Tipo di documento (Schema Protocollo) che contiene il Registro giornaliero", "TIPO_DOC_REG_PROT", "", null, true),
	LETTERA_CONCLUDI_FLUSSO     ("Conclusione del flusso della lettera. Valori Possibili: MANUALE / INVIO (default). Se MANUALE sarà l'utente a dover premere il pulsante Concludi; se INVIO al primo invio della lettera verrà cocluso l'iter.", "LETTERA CONCLUDI FLUSSO", "INVIO", null, true),
	EDITOR_DEFAULT_NOCHECK 		("Indica se l'editor dei testi non deve avere il controllo delle modifiche in sospeso in chiusura.", "EDITOR DEFAULT NOCHECK", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	URL_DATI_AGGIUNTIVI_GDM		("Url di accesso alla pagina di gestione dati aggiuntivi GDM", "URL DATI AGGIUNTIVI GDM", "../appsjsuite/datiaggiuntivi/jsp/datiAggiuntivi.jsp", null, true),
	SCELTA_ALLEGATI_IN_INVIO	("Indica se in invio mail possonono essere scelti gli allegati del protocollo da spedire.", "SCELTA ALLEGATI IN INVIO", "N", '<rowset><row label="No"  value="N" /><row label="Si"  value="Y" /></rowset>', true),
	TIPO_CONSEGNA				("Indica il tipo di consegna di default", "TIPO CONSEGNA", "COMPLETA", '<rowset><row label="BREVE" value="BREVE" /><row label="COMPLETA" value="COMPLETA" /><row label="SINTETICA" value="SINTETICA" /></rowset>', true),
	TIPI_CONSEGNA				("Indica i tipi di consegna gestiti dall'ente", "TIPI CONSEGNA", "BREVE#COMPLETA#SINTETICA", '<rowset><row label="Breve" value="BREVE" /><row label="Breve e Completa" value="BREVE#COMPLETA" /><row label="Breve, Completa e Sintetica" value="BREVE#COMPLETA#SINTETICA" /><row label="Breve e Sintetica" value="BREVE#SINTETICA" /><row label="Completa" value="COMPLETA" /><row label="Completa e Sintetica" value="COMPLETA#SINTETICA" /><row label="Sintetica" value="SINTETICA" /></rowset>', true),
	RUOLO_SO4_DIRIGENTE		 	("Ruolo dirigenti", "RUOLO SO4 DIRIGENTE", "AGDIR", null, true),
	STAMPE_DIRIGENTE  			("Frase da scrivere nei modelli in caso la lettera venga firmata da un dirigente", "MODELLI STAMPE DIRIGENTE", "IL DIRIGENTE", null, true),
	STAMPE_FIRMATARIO  			("Frase da scrivere nei modelli in caso la lettera non venga firmata da un dirigente", "MODELLI STAMPE FIRMATARIO", "Il funzionario delegato", null, true),
	STAMPE_DELEGATO  			("Frase da scrivere nei modelli in caso la lettera venga firmata dal delegato", "MODELLI STAMPE DELEGATO", "IN SOSTITUZIONE DI", null, true),
	SCEGLI_UFFICIO_INVIO_PEC    ("Possibilità si scegliere l'Ufficio di invio pec.", "SCEGLI UFFICIO INVIO PEC", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	BLOCCA_MAIL_SOLO_CC  		("Blocca l'invio della Pec se ci sono solo destinatari in cc.", "BLOCCA MAIL SOLO CC", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
	PREFISSO_RUOLO_AD4			("Prefisso per il filtro dei ruoli", "PREFISSO RUOLI AD4", "AGP", null, false),
	URL_ANAGRAFICA		  		("Url Anagrafica", "\"Url accesso Anagrafica\"", "/Anagrafica/?progettoChiamante=AGS", null, true),
	URL_DOC_W		  			("Url per documento generico", "\"Url per documento generico\"", "../jdms/common/DocumentoView.do?&area=:area&cm=:cm&cr=:cr&rw=W&MVPG=ServletModulisticaDocumento&stato=BO", null, true),
	URL_CARICO_DESC_MEMO        ("notifica inviate per gli smistamenti in carico per la categoria PROTOCOLLO_MEMO", "URL CARICO DESC MEMO", "In carico mail \$oggetto", null, true),
	URL_CARICO_DESC		        ("notifica inviate per gli smistamenti in carico per la categoria PROTOCOLLO", "URL CARICO DESC", "In carico - \$modalita - \$tipo PG \$anno / \$numero7: \$oggetto", null, true),
	URL_CARICO_DESC_NP	        ("notifica inviate per gli smistamenti in carico per la categoria NON PROTOCOLLATI", "URL CARICO DESC NP", "In carico documento \$oggetto del \$data", null, true),
	URL_ASS_DESC_MEMO           ("notifica inviate per gli smistamenti assegnati per la categoria PROTOCOLLO_MEMO", "URL ASS DESC MEMO", "Assegnata mail \$oggetto", null, true),
	URL_ASS_DESC		        ("notifica inviate per gli smistamenti assegnati per la categoria PROTOCOLLO", "URL ASS DESC", "Assegnato - \$modalita - \$tipo PG \$anno / \$numero7: \$oggetto", null, true),
	URL_ASS_DESC_NP	            ("notifica inviate per gli smistamenti assegnati per la categoria NON PROTOCOLLATI", "URL ASS DESC NP", "Assegnato documento \$oggetto del \$data", null, true),
	URL_DA_RIC_COMP_DESC_MEMO   ("notifica inviate per gli smistamenti per competenza da ricevere per la categoria PROTOCOLLO_MEMO", "URL DA RIC COMP DESC MEMO", "Da ricevere mail \$oggetto", null, true),
	URL_DA_RIC_CON_DESC_MEMO    ("notifica inviate per gli smistamenti per conoscenza da ricevere per la categoria PROTOCOLLO_MEMO", "URL DA RIC CON DESC MEMO", "Presa visione mail \$oggetto", null, true),
	URL_DA_RIC_COMP_DESC_NP     ("notifica inviate per gli smistamenti per competenza da ricevere per la categoria NON PROTOCOLLATI", "URL DA RIC COMP DESC NP", "a ricevere documento \$oggetto del \$data", null, true),
	URL_DA_RIC_CON_DESC_NP      ("notifica inviate per gli smistamenti per conoscenza da ricevere per la categoria NON PROTOCOLLATI", "URL DA RIC CON DESC NP", "Presa visione documento \$oggetto del \$data", null, true),
// fascicoli non gestiti per ora da SmartDesktop
// 	URL_DA_RIC_COMP_DESC_F      ("notifica inviate per gli smistamenti per competenza da ricevere per la categoria FASCICOLO", "URL DA RIC COMP DESC F", "Fascicolo da ricevere \$class_cod \$anno / \$numeroR  \$oggetto\t", null, true),
//	URL_DA_RIC_CON_DESC_F       ("notifica inviate per gli smistamenti per conoscenza da ricevere per la categoria FASCICOLO", "URL DA RIC CON DESC F", "Fascicolo da visionare \$class_cod \$anno / \$numeroR  \$oggetto", null, true),
	URL_DA_RIC_COMP_DESC        ("notifica inviate per gli smistamenti per competenza da ricevere per la categoria PROTOCOLLO", "URL DA RIC COMP DESC", "Prendi in carico - \$modalita - \$tipo PG \$anno / \$numero7: \$oggetto", null, true),
	URL_DA_RIC_CON_DESC         ("notifica inviate per gli smistamenti per competenza da ricevere per la categoria PROTOCOLLO", "URL DA RIC COMP DESC", "Da prendere visione - \$modalita - \$tipo PG \$anno / \$numero7: \$oggetto", null, true),

	FILE_GDM_INI				("File di properties di gdm", "\"File di properties di gdm\"", "/workarea/tomcat/webapps/jgdm/config/gd4dm.properties", null, true),
	AG_CONTEXT_PATH_AGSPR		("Contesto agspr e per le servlet degli smistamenti", "\"Contesto agspr e per le servlet degli smistamenti\"", "agspr", null, true),
    ALLEGATI_MOD_POST_INVIO		("Modificabilità degli allegati di protocollo dopo l'invio", "MODIFICA ALLEGATI POST INVIO", "Y", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),

	ADRIER_WS					("Abilita il web service ADRIER per integrazione dell'anagrafica dei destinatari","ADRIER WS","N",null,true),
    ADRIER_WS_URL				("URL del web service ADRIER per integrazione dell'anagrafica dei destinatari","ADRIER WS URL",null,null,true),
    ADRIER_WS_USER				("User del web service ADRIER per integrazione dell'anagrafica dei destinatari","ADRIER WS USER",null,null,true),
    ADRIER_WS_PSW				("Password del web service ADRIER per integrazione dell'anagrafica dei destinatari","ADRIER WS PASSWD",null,null,true),

	ANAG_POPOLAZIONE_WS_URL		("URL del web service SOLWEB per integrazione dell'anagrafica dei destinatari con la popolazione del comune di MODENA","SOLWEB WS URL",null,null,true),
	ANAG_POPOLAZIONE_WS_USER	("User del web service SOLWEB per integrazione dell'anagrafica dei destinatari con la popolazione del comune di MODENA","SOLWEB WS USER",null,null,true),
	ANAG_POPOLAZIONE_WS_PSW		("Password del web service SOLWEB per integrazione dell'anagrafica dei destinatari con la popolazione del comune di MODENA","SOLWEB WS PASSWD",null,null,true),

    TEMP_PATH		            ("Il percorso dei file temporanei sul tomcat", "TEMP_PATH","temp/",null,true),
	REPORT_TIMBRO		        ("Indica il nome del report jasper per la stampa del timbro. Ha una preferenza utente che sovrascrive questa impostazione.","REPORT_TIMBRO","timbro_bc",null,true),
	REPORT_TIMBRO_ALLEGATO_BC   ("Indica il nome del report jasper per la stampa del timbro allegato. Ha una preferenza utente che sovrascrive questa impostazione.","REPORT_TIMBRO_ALLEGATO_BC","timbro_allegato_bc",null,true),
	TIPO_PROTOCOLLO_PEC         ("Il codice del TipoProtocollo che identifica la PEC. Serve allo 'scarico PEC'.","TIPO PROTOCOLLO PEC","PEC",null,true),
	TRAMITE_ARR_OB				("Indica se il tramite è obbligatorio in protocollazione per i documenti in arrivo.","TRAMITE ARR OB","TRAMITEOB",null,true),
	ALLEGATO_COPIA_CONFORME		("Codice della tipologia di allegato per la copia conforme", 'TIPOLOGIA COPIA CONFORME', 'CC', null, true),
	SU_FORMATI_ESCLUSI          ("Definisce quali formati di allegati vengono esclusi dalla Stampa unica (la sintassi è formato1#formato2#formato3)", "SU_FORMATI_ESCLUSI", "zip#rar#7z#eml", null, true),
	INTEROP_ABILITA_UNZIP		("Abilita la funzione per decomprimere i file prima della protocollazione dei protocolli ricevuti via mail", 'INTEROP ABILITA UNZIP', 'N', null, true),
	TIMBRA_PDF_FIRMATI 			("Indica se bisogna creare la copia conforme", 'TIMBRA PDF FIRMATI', 'N', null, true),
	TIMBRA_PDF		 			("creazione automatica della copia conforme solo di file principale non firmato digitalmente", 'TIMBRA PDF', 'N', null, true),
	IS_ENTE_INTERPRO			("Adesione al circuito INTERPRO", 'IS ENTE INTERPRO', 'N', null, true),
	CASELLA_RISPOSTA			("Casella di risposta istituzionale", 'CASELLA_RISPOSTA', null, null, true),

	PAR_PUBLIC_STORAGE_URL      ("Url per il public storage della segnatura", 'PAR_PUBLIC_STORAGE_URL', null, null, true),
	PAR_PUBLIC_STORAGE_MIN_DIM  ("Dimensione minima per utilizzo del public storage della segnatura", 'PAR_PUBLIC_STORAGE_MIN_DIM', null, null, true),
	PAR_PUBLIC_STORAGE_TEXT     ("Text public storage della segnatura", 'PAR_PUBLIC_STORAGE_TEXT', null, null, true),
	PAR_PUBLIC_STORAGE_PATH     ("Path public storage della segnatura", 'PAR_PUBLIC_STORAGE_PATH', null, null, true),
	RUOLI_GEST_ANAG             ("Lista dei ruoli abilitati a vedere la funzionalità GESTIONE ANAGRAFICA", 'RUOLI_GEST_ANAG', null, null, true),
    URL_SI4CS_SERVICE           ("URL per la gestione dei servizi del si4cs", 'URL_SI4CS_SERVICE', null, null, true),
	TAG_MAIL_AUTO				("TAG per la gestione della casella istituzionale di default", 'TAG_MAIL_AUTO', null, null, true),
	UNITA_PROTOCOLLO            ("Unità per registro giornaliero", 'UNITA_PROTOCOLLO', "U_PROT", null, true),
	UTENTI_PROTOCOLLO           ("Utente per protocollazioni automatiche", 'UTENTI_PROTOCOLLO', "RPI", null, true),
	TIPO_ALL_REG_MOD            ("Tipo allegato per registro giornaliero", 'TIPO_ALL_REG_MOD', "RM", null, true),
	NOME_FILE_TESTO_MESSAGGIO 	("Nome del file del testo del messaggio PEC in arrivo", 'NOME_FILE_TESTO_MESSAGGIO', null, null, true),
	MAIL_NO_SEGN_CREA_RAPPORTO  ("Crea il rapporto nel protocollo da messaggio usando la mail del mittente", 'MAIL_NO_SEGN_CREA_RAPPORTO', "N", null, true),
	ACCESSO_CIVICO_OGGETTO_DEFAULT ("Indica se il campo oggetto dei dati di accesso civico deve essere prevalorizzato: OGGETTO = con l'oggetto della domanda, TIPO_ACCESSO = con il tipo di accesso civico, null = il campo non viene prevalorizzato; default: OGGETTO", 'ACCESSO_CIVICO_OGGETTO_DEFAULT', "OGGETTO", null, true),
	ACCESSO_CIVICO_OGGETTO_MOD  ("Indica se modificare o meno l'oggetto dell'accesso civico", 'ACCESSO_CIVICO_OGGETTO_MOD', "Y", null, true),
	PEC_APRI_POPUP_MOTIVO_INT_OPERATORE ("Apre la popup che descrivo il motivo dell'intervento operatore all'apertura della PEC prima della protocollazione", 'PEC_APRI_POPUP_MOTIVO_INT_OPERATORE', "N", null, true),
	CREA_PG_IN_PARTENZA_DA_MAIL ("Indica se è abilitata la voce di meni Crea PG in Partenza sulla form dei messaggio in arrivo", 'CREA_PG_IN_PARTENZA_DA_MAIL', "N", null, true),
    TITOLI_ROMANI 				("Titolario con titoli espressi in numeri romani", "TITOLI IN NUMERI ROMANI", "N", '<rowset><row label="Si" value="Y" /><row label="No" value="N" /></rowset>', true),
    CLASSFASC_RICERCA_MAX_NUM	("Indica il numero massimo di voci di titolario gestito in ricerca", "NUMERO MASSIMO VOCI TITOLARIO IN RICERCA", "250", null, true),
    SEP_CLASSIFICA              ("Separatore classifica", 'SEP_CLASSIFICA', "-", null, true),
	SCANNER                     ("Indica se è possibile acquisire documenti via scanner", 'SCANNER', "Y", null, true),
    SEP_FASCICOLO               ("Separatore fascicolo", 'SEP_FASCICOLO', ".", null, true),
	APERTURA_CLAS               ("Data di apertura delle classifiche. Default 01/01", 'APERTURA_CLAS', "01/01", null, true),
	GLOBO_MITTENTE              ("Mail relativa al mittente con integrazione segnatura GLOBO", 'GLOBO_MITTENTE', null, null, true),
	FIRMA_RIC_AMM				("Gestisce l'obbligatorietà della firma in ricezione PEC con segnatura nel caso di amministrazioni", 'FIRMA_RIC_AMM', "N", null, true),
	FIRMA_RIC_SOG				("Gestisce l'obbligatorietà della firma in ricezione PEC con segnatura nel caso di soggetti", 'FIRMA_RIC_SOG', "N", null, true),
	PEC_3DELETTRONICO			("Indica se è attivata la gestione delle pec in arrivo contenenti 3D elettronici. valori possibili Y/N", '3DELETTRONICO', "N", null, true),
	PEC_3DELETTRONICO_KEYS		("parole chiave di ricerca per 3del", '3DELETTRONICO_KEYS', null, null, true),
	PEC_3DELETTRONICO_NOKEYS	("parole chiave escluse dalla ricerca per 3del", '3DELETTRONICO_NOKEYS', null, null, true),
	PROT_AUTO_CITT              ("Protocollazione Automatica in caso di PEC con segnatura cittadino", 'PROT_AUTO_CITT', "N", null, true),
	ORDINAMENTO_FASC			("Ordinamento dei documenti contenuti in un fascicolo", 'ORDINAMENTO_FASC', "ANNO_DESC_DATA_ASC", null, true),
	RICEVUTA_PROT_AUTO			("Indica se la ricevuta di protocollazione, in caso di documenti senza segnatura, deve essere spedita automaticamente. Valori possibili: Y/N. Default N", 'RICEVUTA_PROT_AUTO', "N", null, true),
	RICEVUTA_PROT				("Testo della mail di ricevuta. Variabili utilizzabili: \$numero = numero di protocollo e \$data = data di protocollo nel formato dd/mm/yyyy hh24:mi:ss. ", 'RICEVUTA_PROT', "", null, true),
	FORMATO_DATAORA				("Formato delle date convertite", 'FORMATO_DATAORA', "", null, true),
	PEC_USA_SI4CS_WS			("Indica se è attivata la gestione dell'invio PEC con il nuovo metodo (non tramite JProtocollo e JDMS ma con le nuove tabelle di AGSPR)", 'PEC_USA_SI4CS_WS', "N", null, true),
	CREA_FASCICOLO_DA_WS		("Indica se è possibile creare dei Fasacicoli da WS", 'CREA_FASCICOLO_DA_WS', "N", null, true),
	CODICE_A_BARRE_ITER			("Indica se abilitare ricerca per codice a barre nell'iter documentale e fascicolare", 'CODICE_A_BARRE_ITER', "N", null, true),
	CERCA_NOME_COGNOME			("Indica se abilitare la ricerca per nome e cognome in anagrafica", 'CERCA_NOME_COGNOME', "N", null, true)


	// proprietà
	private final String descrizione
    private final String etichetta
    private final String predefinito
    private final String caratteristiche
    private final boolean modificabile

    public static final String SEPARATORE = "#"
    public static ImpostazioniMap map

    ImpostazioniProtocollo(String descrizione
                           , String etichetta
                           , String predefinito
                           , String caratteristiche
                           , boolean modificabile) {
		this.descrizione     = descrizione
        this.etichetta       = etichetta
        this.predefinito     = predefinito
        this.caratteristiche = caratteristiche
        this.modificabile    = modificabile
    }

    String getValore (Long ente) {
		return map.getValore(this.toString(), predefinito, ente)
    }

    String getValore () {
		return map.getValore(this.toString(), predefinito)
    }

	int getValoreInt () {
		if(!getValore()){
			return 0
		}
		return Integer.parseInt(getValore())
	}

	Date getValoreData() {
		String date = getValore()
		if (date?.trim()?.length() > 0) {
			try {
				return Date.parse("dd/MM/yyyy", date)
			} catch (ParseException e) {
                log.warn("errore in parse impostazione: ${this.toString()}", e)
				return null
			}
		}

		return null
	}

    String[] getValori () {
		return this.getValore()?.split(SEPARATORE)?:[]
    }

    boolean isAbilitato () {
		return "Y".equalsIgnoreCase(this.getValore())
    }
}
