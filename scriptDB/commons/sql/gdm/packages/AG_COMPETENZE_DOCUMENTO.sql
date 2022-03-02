--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_DOCUMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     "AG_COMPETENZE_DOCUMENTO"
IS
/******************************************************************************
 NOME:        Ag_Competenze_protocollo
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui documenti non protocollati.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev. Data        Autore   Descrizione.
 00   02/01/2007  SC       Prima emissione.
 01   16/05/2012  MM       Modifiche versione 2.1.
******************************************************************************/
-- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.01';
-- variabile globale per contenere il ritorno del lancio delle funzioni di protocollo
-- che viene fatto via sqlexecute perche' esistono solo se c'è l'integrazione.
   g_diritto              NUMBER (1);

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   PROCEDURE set_true;

   PROCEDURE set_false;

   PROCEDURE resetta;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
   INPUT  p_area                    VARCHAR2
    ,     p_modello                 VARCHAR2
    ,     p_codice_richiesta        VARCHAR2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        MODIFICA.
 DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
 - ha ruolo con privilegio MTOT
- è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
- è membro dell'unita esibente  e ha ruolo con privilegio ME
- è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
Un utente ha i diritti in modifica su un protocollo RISERVATO se:
 - ha ruolo con privilegio MTOTR
- è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
- è membro dell'unita esibente  e ha ruolo con privilegio MER
- è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

- se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
INPUT  p_area varchar2
      p_modello varchar2
      p_codice_richiesta varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di modificare il documento.
RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION modifica (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        LETTURA
 DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
- ha ruolo con privilegio VTOT
- è membro dell'unita protocollante  e ha ruolo con privilegio VP
- è membro di un'unita che ha smistato il documento con privilegio VS
- è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS
- è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
Un utente ha i diritti in lettura su un protocollo RISERVATO se:
- ha ruolo con privilegio VTOTR
- è membro dell'unita protocollante  e ha ruolo con privilegio VPR
- se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR
- se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
- se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
- è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        LETTURA
 DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
- ha ruolo con privilegio VTOT
- è membro dell'unita protocollante  e ha ruolo con privilegio VP
- è membro dell'unita esibente  e ha ruolo con privilegio VE
- è membro di un'unita che ha smistato il documento con privilegio VS
- è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS e CARICO
- è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
Un utente ha i diritti in lettura su un protocollo RISERVATO se:
- ha ruolo con privilegio VTOTR
- è membro dell'unita protocollante  e ha ruolo con privilegio VPR
- è membro dell'unita esibenre  e ha ruolo con privilegio VER
- se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR e  CARICO
- se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
- se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
- è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
      p_verifica_esistenza_attivita NUMBER: 0 o 1: se 1 verifica se c'è in attesa
        un'attivita' JSUITE per lo smistamento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
       01/09/2008  SC  A28345.12.0
********************************************************************************/
   FUNCTION lettura (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        MODIFICA.
 DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
 - ha ruolo con privilegio MTOT
- è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
- è membro dell'unita esibente  e ha ruolo con privilegio ME
- è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
Un utente ha i diritti in modifica su un protocollo RISERVATO se:
 - ha ruolo con privilegio MTOTR
- è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
- è membro dell'unita esibente  e ha ruolo con privilegio MER
- è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

- se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di modificare il documento.
RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
       03/07/2007 SC A21081 Anche se l'utente generalmente avrebbe diritto a modificare il documento,
       se il documento appartiene ad un fascicolo in deposito, lo potra' modificare
       solo se ha privilegio MDDEP.
       07/09/2009 SC A30956.0.1 D878 Il documento deve essere in stato C o E per p_utente.
********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2, p_check_protocollante NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION verifica_privilegio_documento (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_privilegio         VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION verifica_privilegio_documento (
      p_id_documento   VARCHAR2,
      p_privilegio     VARCHAR2,
      p_utente         VARCHAR2
   )
      RETURN NUMBER;

-------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        creazione
    DESCRIZIONE: Un utente ha i diritti in creazione di protocolli se:
   - ha ruolo con privilegio CPROT.
   INPUT  p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        eseguito
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in eseguito per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION eseguito (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        in_carico
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
 00    20/05/2009  SC  A32603.0.0 Verifica l'esistenza dell'attivita jsuite.
********************************************************************************/
   FUNCTION in_carico (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        in_carico
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
      p_verifica_esistenza_attivita indica se va verificato che esista attività jsuite
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    20/05/2009  SC  A32603.0.0
********************************************************************************/
   FUNCTION in_carico (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER
   )
      RETURN NUMBER;

   FUNCTION in_carico (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER,
      p_verifica_assegnazione         NUMBER
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        da_ricevere
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION da_ricevere (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER
   )
      RETURN NUMBER;

   FUNCTION da_ricevere (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER,
      p_verifica_assegnazione         NUMBER
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        da_ricevere
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere privilegio VS/VSR o essere assegnatario
 del documento.
 Se tra tutti gli smistamenti in stato R relativi a p_utente, ce n'e' anche uno solo il cui relativo flusso
 non è arrivato ad attivare l'attivita' sul cruscotto, la funzione restituisce 0 per evitare
 disallineamenti tra lo stato dello smistamento e l'effettivo stato del flusso.
 la funzione restituisce 1 se l'utente appartiene all'unita ricevente e ha i diritti di vedere il documento,
 inoltre lo smistamento e il flusso collegato devono essere coerenti: cioe' deve essere attiva
 l'attivita' jsuite sul cruscotto come documento da ricevere per ogni smistamento.
 Se il documento è assegnato  la funzione restituisce 1 se l'utente è l'assegnatario.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
       15/01/2008 SC Faccio in modo che risulti da ricevere
       per p_utente solo se non assegnato o assegnato a p_utente.
      16/01/2008  SC  Prima emissione. A25157.0.0
********************************************************************************/
   FUNCTION da_ricevere (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
 NOME:        da_ricevere
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION da_ricevere (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        eseguito
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato eseguito per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION eseguito (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        in_carico
 DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
 Inoltre p_utente deve avere diritti in lettura sul documento.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION in_carico (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        abilita_azione_smistamento
 DESCRIZIONE: Verifica se è possibile abilitare l'azione richiesta (SMISTA, INOLTRA)
 in base a:
 utente, per quale ragione vede il documento (protocollante, esibente, smistamento)
 se vede il documento a seguito di uno smistamento (l'abilitazione
 varia a seconda dello stato dello smistamento).
 Per SMISTA si restituisce 1 se
 l'utente è l'utente protocollante,
 l'utente è un protocollante o esibente con privilegio ISMI + CPROT;
 l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
 tabella AG_ABILITAZIONI_SMISTAMENTO
 Per INOLTRA e per ASSEGNA si restituisce 1 se:
 l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
 tabella AG_ABILITAZIONI_SMISTAMENTO.
 --A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
 Per CARICO, si verifica che l'utente abbia privilegio CARICO e non privilegio ISMI.
 In tutti gli altri casi si restituisce 0.
INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
      p_azione ('SMISTA', 'INOLTRA')
RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    20/06/2007  SC  Prima emissione.
       20/05/2009  SC  A32601.0.0 Per smistare documenti protocollati
                                    a nome dell'unita protocollante ci vuole ISMI + CPROT.
       20/05/2009  SC A32603.0.0 SC Per tutte le azioni, tranne CARICO, si verifica se
                                    l'utente ha privilegio ISMI, ma per abilitare
                                    la presa in carico si verifica il privilegio CARICO.
       01/06/2009  SC A33037.0.0 L'utente protocollante può sempre inserire smistamenti.
       17/08/2009  SC A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
********************************************************************************/
   FUNCTION abilita_azione_smistamento (
      p_id_documento        VARCHAR2,
      p_utente              VARCHAR2,
      p_azione              VARCHAR2,
      p_stato_smistamento   VARCHAR2 := NULL
   )
      RETURN NUMBER;

   FUNCTION abilita_azione_smistamento (
      p_cr                  VARCHAR2,
      p_area                VARCHAR2,
      p_cm                  VARCHAR2,
      p_utente              VARCHAR2,
      p_azione              VARCHAR2,
      p_stato_smistamento   VARCHAR2 := NULL
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        get_tipo_smistamento
 DESCRIZIONE: Dati in protocollo e un'unita di trasmissione, stabilisce quale
 tipo smistamento è possibile per quell'unita.
 Il tipo smistamento possibile dipende da
 lo stato in cui l'unita' di trasmissione ha il documento (da ricevere, in carico.)
 il tipo di smistamento con cui l'unita ha ricevuto il documento.
 L'azione che si sta compiendo (SMISTA, INOLTRA).
 In base ad essi si vede nella tabella AG_ABILITAZIONI_SMISTAMENTO quali tipi di smistamento sono generabili,
 se sono piu' di uno viene selezionato quello del tipo smistamento piu' importante
 (che è nella tabella ag_tipi_smistamento).


INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
      p_unita_trasmissione VARCHAR2 codice dell'unita che sta creando un nuovo smistamento.
      p_azione ('SMISTA', 'INOLTRA')
RITORNO:  TIPO_SMISTAMENTO possibile, null se non ce n'è nessuno.
 Rev.  Data       Autore  Descrizione.
 00    20/06/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_tipo_smistamento (
      p_id_documento         VARCHAR2,
      p_utente               VARCHAR2,
      p_unita_trasmissione   VARCHAR2,
      p_azione               VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************
 NOME:        eliminazione.
 DESCRIZIONE: Un utente ha i diritti in eliminazione se il documento non è protocollato
 e se ne ha le competenze esplicite in si4_competenze.
Quindi se il documento è protocollato restituisce sempre 0,
se non è protocollato restituisce null.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di modificare il documento.
RITORNO:  se il documento è protocollato restituisce sempre 0,
se non è protocollato restituisce null.
 Rev.  Data       Autore  Descrizione.
 00    29/08/2007 SC A21487.2.0 difetto 56
********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

--FUNCTION lettura_light (p_id_documento VARCHAR2, p_utente VARCHAR2)
--      RETURN NUMBER;

   /*****************************************************************************
    NOME:        check_abilita_ripudio
    DESCRIZIONE: Verifica se l'utente ha possibilita di ripudiare lo smistamento da ricevere

   INPUT p_area               varchar2, area del documento
         p_modello            varchar2, modello
         p_codice_richiesta   varchar2, codice richiesta
         p_utente             varchar2
   RITORNO:  1 se l'utente ha diritti di ripudio , 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    28/01/2009  AM  Prima emissione.
   ********************************************************************************/
   FUNCTION check_abilita_ripudio (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2
   )
      RETURN NUMBER;

    /*****************************************************************************
    NOME:        get_componenti_unita_azione
    DESCRIZIONE: ritorna la lista dei componenti di una data unita che
               hanno la possibilita' di compiere una azione in particolare

   INPUT  p_area               VARCHAR2,
         p_codice_modello     VARCHAR2,
         p_codice_richiesta   VARCHAR2, codice richiesta del protocollo
         p_codice_unita       VARCHAR2, codice unita della unita' da cui ottenere i componenti
         p_azione             VARCHAR2  azione da valutare per ogni utente dell'unita
   RITORNO:  lista dei componenti di una unita che hanno diritti su una azione in particolare
    Rev.  Data       Autore  Descrizione.
    00    20302/2009  AM  Prima emissione.
   ********************************************************************************/
   FUNCTION get_componenti_unita_azione (
      p_area               VARCHAR2,
      p_codice_modello     VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_codice_unita       VARCHAR2,
      p_azione             VARCHAR2
   )
      RETURN VARCHAR;

   FUNCTION get_utenti_notifica_ripudio (
      p_area               VARCHAR2,
      p_codice_modello     VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_codice_unita       VARCHAR2,
      p_azione             VARCHAR2,
      id_smistamenti       VARCHAR2
   )
      RETURN VARCHAR;

   FUNCTION is_riservato (p_id_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION da_ricevere (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER,
      p_verifica_assegnazione         NUMBER,
      p_unita_ricevente               VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION in_carico (
      p_id_documento                  VARCHAR2,
      p_utente                        VARCHAR2,
      p_verifica_esistenza_attivita   NUMBER,
      p_verifica_assegnazione         NUMBER,
      p_unita_ricevente               VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION eseguito (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2,
      p_utente             VARCHAR2,
      p_unita_ricevente    VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION eseguito (
      p_id_documento            VARCHAR2,
      p_utente                  VARCHAR2,
      p_unita_ricevente         VARCHAR2 := NULL,
      p_verifica_assegnazione   NUMBER := 1
   )
      RETURN NUMBER;

   FUNCTION f_valore_campo (p_id_documento NUMBER, p_campo_protocollo VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE check_titolario (
      p_id_documento           NUMBER,
      p_class_cod_old          VARCHAR2,
      p_class_dal_old          DATE,
      p_fascicolo_anno_old     NUMBER,
      p_fascicolo_numero_old   VARCHAR2,
      p_class_cod_new          VARCHAR2,
      p_class_dal_new          DATE,
      p_fascicolo_anno_new     NUMBER,
      p_fascicolo_numero_new   VARCHAR2,
      p_utente                 VARCHAR2
   );

   FUNCTION verifica_per_protocollante (
      p_id_documento   VARCHAR2,
      p_privilegio     VARCHAR2,
      p_utente         VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION is_da_ricevere_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_in_carico_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;
   FUNCTION get_stato_scarto (p_id_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_data_stato_scarto (p_id_documento VARCHAR2)
      RETURN DATE;
END;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_DOCUMENTO"
IS
   /******************************************************************************
    NOME:        AG_COMPETENZE_DOCUMENTO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti documenti non protocollati.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data       Autore Descrizione.
    000  02/01/2007 SC     Prima emissione.
    001  16/05/2012 MM     Modifiche versione 2.1.
         16/06/2017 SC     ALLINEATO ALLO STANDARD
    002  2/09/2019  SC     Bug #37160 Modifiche per performance abilita_azione_smistamento
   ******************************************************************************/
   TYPE ag_refcursor IS REF CURSOR;

   campo_idrif                  VARCHAR2 (5) := 'IDRIF';
   campo_riservato              VARCHAR2 (20) := 'RISERVATO';
   campo_unita_protocollante    VARCHAR2 (30) := 'UNITA_PROTOCOLLANTE';
   campo_utente_protocollante   VARCHAR2 (30) := 'UTENTE_PROTOCOLLANTE';
   s_revisione_body    CONSTANT afc.t_revision := '002';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilità del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, NVL (s_revisione_body, '000'));
   END;

   FUNCTION is_riservato (p_id_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (1);
   BEGIN
      BEGIN
         SELECT NVL (riservato, 'N')
           INTO retval
           FROM classificabile_view
          WHERE id_documento = p_id_documento AND NVL (riservato, 'N') = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT NVL (f.riservato, 'N')
                 INTO retval
                 FROM links l,
                      seg_fascicoli f,
                      cartelle c,
                      documenti d
                WHERE     l.id_oggetto = p_id_documento
                      AND l.tipo_oggetto = 'D'
                      AND l.id_cartella = c.id_cartella
                      AND c.id_documento_profilo = f.id_documento
                      AND f.id_documento = d.id_documento
                      AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND NVL (c.stato, 'BO') != 'CA'
                      AND NVL (f.riservato, 'N') = 'Y'
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  retval := 'N';
            END;
      END;

      RETURN retval;
   END is_riservato;

   FUNCTION is_categoriamodello (p_id_documento NUMBER, p_categoria VARCHAR2)
      RETURN NUMBER
   IS
      d_categoria   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_categoria
           FROM categorie_modello camo, tipi_documento tido, documenti docu
          WHERE     docu.id_documento = p_id_documento
                AND tido.id_tipodoc = docu.id_tipodoc
                AND camo.codice_modello = tido.nome
                AND camo.categoria = p_categoria;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_categoria := 0;
      END;

      RETURN d_categoria;
   END;

   FUNCTION get_tabella (p_id_documento NUMBER, p_campo VARCHAR2)
      RETURN VARCHAR2
   IS
      d_tabella   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT UPPER (
                   NVL (a.acronimo, '-') || '_' || NVL (t.alias_modello, '-'))
           INTO d_tabella
           FROM documenti d, tipi_documento t, aree a
          WHERE     d.id_documento = p_id_documento
                AND d.id_tipodoc = t.id_tipodoc
                AND a.area = t.area_modello;

         DECLARE
            d_esiste   NUMBER;
         BEGIN
            SELECT 1
              INTO d_esiste
              FROM user_tab_columns
             WHERE table_name = d_tabella AND column_name = p_campo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_tabella := 'CLASSIFICABILE_VIEW';
         END;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tabella := 'CLASSIFICABILE_VIEW';
      END;

      RETURN d_tabella;
   END;

   FUNCTION f_valore_campo (p_id_documento        NUMBER,
                            p_campo_protocollo    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return    VARCHAR2 (32767);
      d_tabella   VARCHAR2 (32767);
   BEGIN
      d_tabella := get_tabella (p_id_documento, p_campo_protocollo);

      EXECUTE IMMEDIATE
            'select '
         || p_campo_protocollo
         || ' from '
         || d_tabella
         || ' where id_documento = :id_documento'
         INTO d_return
         USING p_id_documento;

      RETURN d_return;
   END;

   /******************************************************************************
    NOME:        test_attivita_in_attesa
    DESCRIZIONE: Verifica se esiste un'attivita in attesa di esecuzione
                   con execType p_execType, collegata
                 al documento identificato da p_triade (area@codiceModello@codiceRichiesta).
    INPUT  p_triade area@codiceModello@codiceRichiesta del documento che dovrebbe
               avere un flusso collegato
       p_exectype tipo di esecuzione che deve essere collegato all'eventuale attivita'
       in attesa di esecuzione
    RITORNA:     1 se esiste un'attivita' in attesa di esecuzione
               0 se non esiste e in caso di errore.
    Rev.  Data       Autore  Descrizione.
    00    16/01/2008  SC  Prima emissione. A25157.0.0
          02/11/2008  SC  A34963.0.0 Modifica degli indici in JWF ci obbliga a fare una
                           modifica sulla query su syncactivity.
   ******************************************************************************/
   FUNCTION test_attivita_in_attesa (p_triade VARCHAR2, p_exectype VARCHAR2)
      RETURN NUMBER
   IS
      retval      VARCHAR2 (1999) := 0;
      checksmis   seg_smistamenti.key_iter_smistamento%TYPE;
      cr          documenti.codice_richiesta%TYPE;
   BEGIN
      BEGIN
         --      02/11/2008  SC  A34963.0.0 Modifica degli indici in JWF ci obbliga a fare una
         --                        modifica sulla query su syncactivity
         --                       a.id_attivita = s.id_attivita diventa
         --                      a.id_attivita + 0 = s.id_attivita;
         IF INSTR (p_triade, 'SEGRETERIA@M_SMISTAMENTO@') > 0
         THEN
            cr := SUBSTR (p_triade, LENGTH ('SEGRETERIA@M_SMISTAMENTO@') + 1);

            SELECT NVL (key_iter_smistamento, 0)
              INTO checksmis
              FROM seg_smistamenti, documenti
             WHERE     documenti.codice_richiesta = cr
                   AND documenti.id_documento = seg_smistamenti.id_documento;

            IF checksmis = -1
            THEN
               RETURN 1;
            END IF;
         END IF;

         SELECT 1
           INTO retval
           FROM syncactivity a, sync_cruscotto s
          WHERE     a.exectype = p_exectype
                AND a.oggetto = p_triade
                AND a.esecuzione = 0
                AND a.id_attivita + 0 = s.id_attivita;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN                                     --se non ci sono smistamenti
            --con il nodo del cruscotto in attesa
            -- restituisco 0.
            retval := 0;
         WHEN OTHERS
         THEN
            -- in caso di errore non posso che dare 0, ma lo voglio distinguere dal caso del no_data_found.
            retval := 0;
      END;

      RETURN retval;
   END test_attivita_in_attesa;

   -------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   Inoltre si acquistano i diritti su un protocollo se si ha il privilegio di leggere i protocolli di una certa unita
   e uno dei privilegi che stendono i diritti ad altre unita EPSUP, EPSUB, EPEQU.
   Se si ha EPSUP e si hanno diritti in lettura sui protocolli della propria unita allora si possono vedere
   anche quelli dell'unita' padre.
   Se si ha EPSUB e si hanno diritti in lettura sui protocolli della propria unita allora si possono vedere
   anche quelli delle unita' discendenti.
   Se si ha EPEQU e si hanno diritti in lettura sui protocolli della propria unita allora si possono vedere
   anche quelli delle unita del medesimo livello.
   INPUT  p_area                    VARCHAR2
    ,     p_modello                 VARCHAR2
    ,     p_codice_richiesta        VARCHAR2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (p_area                VARCHAR2,
                     p_modello             VARCHAR2,
                     p_codice_richiesta    VARCHAR2,
                     p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := lettura (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;

   -------------------------------------------------------------------------------
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 1;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = ag_utilities.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;


      BEGIN
         retval :=
            ag_utilities_competenze.verifica_privilegio_utente (
               NULL,
               'DAFASC',
               p_utente,
               0,
               TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END creazione;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
    - ha ruolo con privilegio MTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
   - è membro dell'unita esibente  e ha ruolo con privilegio ME
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
   Un utente ha i diritti in modifica su un protocollo RISERVATO se:
    - ha ruolo con privilegio MTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
   - è membro dell'unita esibente  e ha ruolo con privilegio MER
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := modifica (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END modifica;

   /*****************************************************************************
    NOME:        VERIFICA_PER_PROTOCOLLANTE.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo
    come membro dell'unita' protocollante.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha
   il suo ruolo all'interno dell'unita' protocollante.
   INPUT  p_id_documento varchar2 id del documento
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , UnitaUtente         ag_utilities.UnitaUtenteTab Table di unita e ruoli di p_utente
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    31/03/2017  SC  Gestione validita privilegi
   ********************************************************************************/
   FUNCTION verifica_per_protocollante (p_id_documento    VARCHAR2,
                                        p_privilegio      VARCHAR2,
                                        p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      unitaprotocollante   seg_unita.unita%TYPE;
      dep_data_rif         DATE;
   BEGIN
      dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);
      unitaprotocollante :=
         f_valore_campo (p_id_documento, campo_unita_protocollante);

      --verifico se l'utente fa parte dell'unita protocollante con privolegio p_privilegio.
      BEGIN
         SELECT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE     utente = p_utente
                AND privilegio = p_privilegio
                AND unita = unitaprotocollante
                AND dep_data_rif <= NVL (al, TO_DATE (3333333, 'j'))
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN retval;
   END verifica_per_protocollante;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
    - ha ruolo con privilegio MTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
   - è membro dell'unita esibente  e ha ruolo con privilegio ME
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
   Un utente ha i diritti in modifica su un protocollo RISERVATO se:
    - ha ruolo con privilegio MTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
   - è membro dell'unita esibente  e ha ruolo con privilegio MER
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

   - se il documento è in un fascicolo in deposito, ha ruolo con privilegio MDDEP
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario

   I privilegi MTOT*, MDDEP vengono verificati alla data odierna.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          03/07/2007 SC A21081 Anche se l'utente generalmente avrebbe diritto a modificare il documento,
                              se il documento appartiene ad un fascicolo in deposito, lo potra' modificare
                              solo se ha privilegio MDDEP.
          07/09/2009 SC A30956.0.1 D878 Il documento deve essere in stato C o E per p_utente.
          31/03/2017 SC Verifica dei privilegi in base a date di riferimento
   ********************************************************************************/
   FUNCTION modifica (p_id_documento           VARCHAR2,
                      p_utente                 VARCHAR2,
                      p_check_protocollante    NUMBER)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
      riservato              VARCHAR2 (1) := 'N';
      riservato_causa_fasc   VARCHAR2 (1) := 'N';
      continua               NUMBER := 0;
      suffissoprivilegio     VARCHAR2 (1);
      idrifprotocollo        VARCHAR2 (100);
      classcod               VARCHAR2 (100);
      classdal               DATE;
      annofasc               NUMBER;
      numerofasc             VARCHAR2 (100);
      dep_data_rif           DATE;
   BEGIN
      -- DBMS_OUTPUT.put_line ('inizio ' || retval);

      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = ag_utilities.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

      IF     p_check_protocollante = 1
         AND f_valore_campo (p_id_documento, campo_utente_protocollante) =
                p_utente
      THEN
         RETURN 1;
      END IF;

      dep_data_rif := ag_utilities.GET_DATA_RIF_PRIVILEGI (p_id_documento);

      riservato := is_riservato (p_id_documento);

      --  DBMS_OUTPUT.put_line ('stato pr <> dp');
      IF riservato = 'Y'
      THEN
         suffissoprivilegio := 'R';

         IF NVL (f_valore_campo (p_id_documento, campo_riservato), 'N') = 'N'
         THEN
            riservato_causa_fasc := 'Y';
         END IF;
      END IF;

      -- se ha privilegio MTOT vede tutti i protocolli NON riservati.
      -- se ha privilegio MTOTR vede tutti i protocolli riservati.
      retval :=
         ag_utilities.verifica_privilegio_utente (
            p_unita        => NULL,
            p_privilegio   => 'MTOT' || suffissoprivilegio,
            p_utente       => p_utente,
            p_data         => TRUNC (SYSDATE));

      --  DBMS_OUTPUT.put_line ('dopo verifica privilegio MTOT ' || retval);
      IF retval = 0 AND p_check_protocollante = 1
      THEN
         --VERIFICA SE P_UTENTE FA PARTE DELL'UNITA PROTOCOLLANTE CON PRIVILEGIO MPROTR
         -- per i documenti riservati, MPROT per i NON riservati.
         retval :=
            verifica_per_protocollante (
               p_id_documento   => p_id_documento,
               p_privilegio     => 'MPROT' || suffissoprivilegio,
               p_utente         => p_utente);
      -- DBMS_OUTPUT.put_line ('dopo verifica privilegio ME ' || retval);
      END IF;

      -- se il documento e' riservato ma e' stato smistato personalmente a p_utente
      -- o al suo ruolo, p_utente lo puo' cmq modificare.
      -- A30956.0.1 D878 Il documento deve essere in stato C o E per p_utente.
      IF retval = 0
      THEN
         IF ag_parametro.get_valore (
               'ITER_FASCICOLI_' || ag_utilities.indiceaoo,
               '@agVar@',
               'N') = 'Y'
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM DUAL
                WHERE     EXISTS
                             (SELECT 1
                                FROM seg_smistamenti,
                                     documenti docu_smis,
                                     ag_priv_utente_tmp,
                                     ag_privilegi_smistamento,
                                     links,
                                     seg_fascicoli fasc,
                                     documenti docu_fasc,
                                     cartelle cart
                               WHERE     seg_smistamenti.id_documento =
                                            docu_smis.id_documento
                                     AND docu_smis.stato_documento NOT IN ('CA',
                                                                           'RE')
                                     AND seg_smistamenti.idrif = fasc.idrif
                                     AND seg_smistamenti.ufficio_smistamento =
                                            ag_priv_utente_tmp.unita
                                     AND seg_smistamenti.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                                                               ag_utilities.smistamento_eseguito)
                                     AND seg_smistamenti.tipo_smistamento =
                                            ag_privilegi_smistamento.tipo_smistamento
                                     AND ag_priv_utente_tmp.utente = p_utente
                                     AND ag_priv_utente_tmp.privilegio =
                                            'MS' || suffissoprivilegio
                                     AND ag_privilegi_smistamento.privilegio =
                                            ag_priv_utente_tmp.privilegio
                                     AND ag_utilities.get_Data_rif_privilegi (
                                            fasc.id_documento) <=
                                            NVL (ag_priv_utente_tmp.al,
                                                 TO_DATE (333333, 'j'))
                                     AND ag_privilegi_smistamento.aoo =
                                            ag_utilities.indiceaoo
                                     AND links.id_oggetto = p_id_documento
                                     AND links.tipo_oggetto = 'D'
                                     AND links.id_cartella = cart.id_cartella
                                     AND NVL (cart.stato, 'BO') != 'CA'
                                     AND cart.id_documento_profilo =
                                            fasc.id_documento
                                     AND fasc.id_documento =
                                            docu_fasc.id_documento
                                     AND docu_fasc.stato_documento NOT IN ('CA',
                                                                           'RE')
                                     AND DECODE (
                                            riservato_causa_fasc,
                                            'N', 1,
                                            DECODE (
                                               NVL (fasc.riservato, 'N'),
                                               'Y', 1,
                                               0)) = 1)
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;

            IF riservato = 'Y' AND retval = 0
            THEN
               BEGIN
                  SELECT 1
                    INTO retval
                    FROM seg_smistamenti,
                         documenti docu_smis,
                         links,
                         seg_fascicoli fasc,
                         documenti docu_fasc,
                         cartelle cart
                   WHERE     docu_smis.stato_documento NOT IN ('CA', 'RE')
                         AND docu_smis.id_documento =
                                seg_smistamenti.id_documento
                         AND seg_smistamenti.idrif = fasc.idrif
                         AND seg_smistamenti.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                                                   ag_utilities.smistamento_eseguito)
                         AND seg_smistamenti.codice_assegnatario = p_utente
                         AND links.id_oggetto = p_id_documento
                         AND links.tipo_oggetto = 'D'
                         AND links.id_cartella = cart.id_cartella
                         AND NVL (cart.stato, 'BO') != 'CA'
                         AND cart.id_documento_profilo = fasc.id_documento
                         AND fasc.id_documento = docu_fasc.id_documento
                         AND docu_fasc.stato_documento NOT IN ('CA', 'RE')
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;

         IF retval = 0
         THEN
            idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);

            --VERIFICA SE P_UTENTE FA PARTE DI UN'UNITA di carico CON PRIVILEGIO MSR
            -- per i documenti riservati, MS per i NON riservati..
            BEGIN
               SELECT 1
                 INTO retval
                 FROM seg_smistamenti,
                      documenti docu,
                      ag_priv_utente_tmp,
                      ag_privilegi_smistamento
                WHERE     seg_smistamenti.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE')
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND seg_smistamenti.ufficio_smistamento =
                             ag_priv_utente_tmp.unita
                      AND seg_smistamenti.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                                                ag_utilities.smistamento_eseguito)
                      AND seg_smistamenti.tipo_smistamento =
                             ag_privilegi_smistamento.tipo_smistamento
                      AND ag_priv_utente_tmp.utente = p_utente
                      AND ag_priv_utente_tmp.privilegio =
                             'MS' || suffissoprivilegio
                      AND dep_data_rif <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ag_privilegi_smistamento.privilegio =
                             ag_priv_utente_tmp.privilegio
                      AND ag_privilegi_smistamento.aoo =
                             ag_utilities.indiceaoo
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;

            IF riservato = 'Y' AND retval = 0
            THEN
               BEGIN
                  SELECT 1
                    INTO retval
                    FROM seg_smistamenti, documenti docu
                   WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                         AND docu.id_documento = seg_smistamenti.id_documento
                         AND seg_smistamenti.idrif = idrifprotocollo
                         AND seg_smistamenti.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                                                   ag_utilities.smistamento_eseguito)
                         AND seg_smistamenti.codice_assegnatario = p_utente
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;
      END IF;

      --     DBMS_OUTPUT.put_line ('prima di verificare il fascicolo ' || retval);

      -- A21081 Anche se l'utente generalmente avrebbe diritto a modificare il documento,
      -- se il documento appartiene ad un fascicolo in deposito, lo potra' modificare
      -- solo se ha privilegio MDDEP.
      IF retval = 1
      THEN
         BEGIN
            SELECT classificabile_view.class_cod,
                   classificabile_view.class_dal,
                   classificabile_view.fascicolo_anno,
                   classificabile_view.fascicolo_numero
              INTO classcod,
                   classdal,
                   annofasc,
                   numerofasc
              FROM documenti docu, classificabile_view
             WHERE     docu.id_documento = p_id_documento
                   AND classificabile_view.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE');

            IF annofasc IS NOT NULL AND numerofasc IS NOT NULL
            THEN
               IF ag_utilities.get_stato_fascicolo (
                     p_class_cod    => classcod,
                     p_class_dal    => classdal,
                     p_anno         => annofasc,
                     p_numero       => numerofasc,
                     p_indice_aoo   => ag_utilities.indiceaoo) !=
                     ag_utilities.stato_corrente
               THEN
                  --                  DBMS_OUTPUT.put_line
                  --                                    ('fascicolo in stato diverso da corrente');
                  retval :=
                     ag_utilities.verifica_privilegio_utente (
                        NULL,
                        'MDDEP',
                        p_utente,
                        TRUNC (SYSDATE));
               --                  DBMS_OUTPUT.put_line (   'dopo verifica privilegio MDDEP '


               --                                        || retval
               --                                       );
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      --DBMS_OUTPUT.put_line ('alla fine ' || retval);
      RETURN retval;
   END modifica;

   /*****************************************************************************
    NOME:        eliminazione.
    DESCRIZIONE: Un utente ha i diritti in eliminazione se il documento non è protocollato
    e se ne ha le competenze esplicite in si4_competenze.
   Quindi se il documento è protocollato restituisce sempre 0,
   se non è protocollato restituisce null.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  se il documento è protocollato restituisce sempre 0,
   se non è protocollato restituisce null.
    Rev.  Data       Autore  Descrizione.
    00    29/08/2007 SC A21487.2.0 difetto 56
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                  NUMBER := 0;
      diritto_di_modifica     NUMBER := 0;
      riservato               VARCHAR2 (1) := 'N';
      d_check_protocollante   NUMBER := 1;
      suffissoprivilegio      VARCHAR2 (1);
      idrifprotocollo         VARCHAR2 (100);
   BEGIN
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = ag_utilities.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;


      idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);

      -- Verifica i privilegi dell'utente di creazione solo se il doc non ha
      -- smistamenti (ne' propri ne' derivati dall'appartenenza al fascicolo)

      SELECT NVL (MIN (0), 1)
        INTO d_check_protocollante
        FROM seg_smistamenti s, documenti d
       WHERE     s.idrif = idrifprotocollo
             AND s.tipo_smistamento <> 'DUMMY'
             AND s.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                         ag_utilities.smistamento_eseguito,
                                         ag_utilities.smistamento_da_ricevere)
             AND d.id_documento = s.id_documento
             AND d.stato_documento NOT IN ('CA', 'RE', 'PB');



      DBMS_OUTPUT.put_line (
         'd_check_protocollante:' || d_check_protocollante);


      IF     d_check_protocollante = 1
         AND ag_parametro.get_valore (
                'ITER_FASCICOLI_' || ag_utilities.indiceaoo,
                '@agVar@',
                'N') = 'Y'
      THEN
         BEGIN
            SELECT NVL (MIN (0), 1)
              INTO d_check_protocollante
              FROM seg_smistamenti,
                   documenti docu_smis,
                   links,
                   seg_fascicoli fasc,
                   documenti docu_fasc,
                   cartelle cart
             WHERE     seg_smistamenti.id_documento = docu_smis.id_documento
                   AND docu_smis.stato_documento NOT IN ('CA', 'RE')
                   AND seg_smistamenti.idrif = fasc.idrif
                   AND seg_smistamenti.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                                             ag_utilities.smistamento_eseguito,
                                                             ag_utilities.smistamento_da_ricevere)
                   AND links.id_oggetto = p_id_documento
                   AND links.tipo_oggetto = 'D'
                   AND links.id_cartella = cart.id_cartella
                   AND NVL (cart.stato, 'BO') != 'CA'
                   AND cart.id_documento_profilo = fasc.id_documento
                   AND fasc.id_documento = docu_fasc.id_documento
                   AND docu_fasc.stato_documento NOT IN ('CA', 'RE');
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      DBMS_OUTPUT.put_line (
         '2 d_check_protocollante:' || d_check_protocollante);



      IF d_check_protocollante = 1
      THEN
         IF NVL (f_valore_campo (p_id_documento, campo_utente_protocollante),
                 '') <> p_utente
         THEN
            retval := 0;
         ELSE
            retval := 1;
         END IF;
      END IF;

      DBMS_OUTPUT.put_line ('retval:' || retval);

      IF retval = 0
      THEN
         retval :=
            NVL (modifica (p_id_documento, p_utente, d_check_protocollante),
                 0);
      END IF;

      DBMS_OUTPUT.put_line ('modifica retval:' || retval);

      RETURN retval;
   END eliminazione;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_DOCUMENTO.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   - se l'utente è membro di un'unita' cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento.
   Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   Gli smistamenti che vengono coltrollati dipendono dal valore dei parametri
   verifica_smistamenti_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C o R.
   verifica_carico_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C.
   verifica_smistamenti_storici - fa la verifica su smistamenti di unita' dell'utente cons stato_smistamento F.
   INPUT  p_id_documento varchar2 id del documento
         p_privilegio: codice del privilegio da verificare.
         verifica_smistamenti_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali, che siano in carico o da ricevere. 1 = fa il test, 0 non lo fa.
      verifica_carico_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali in carico. 1 = fa il test, 0 non lo fa.
      verifica_smistamenti_storici NUMBER indice se va fatto il test anche sui record di
      smistamenti storici. 1 = fa il test, 0 non lo fa.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    31/03/2017  SC  Gestione validita privilegi
   ********************************************************************************/
   FUNCTION verifica_privilegio_documento (p_id_documento    VARCHAR2,
                                           p_privilegio      VARCHAR2,
                                           p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval              NUMBER := 0;
      idrifprotocollo     VARCHAR2 (100);
      riservato           VARCHAR2 (1);
      utenteinstruttura   NUMBER := 0;
      dep_data_rif        DATE;
   BEGIN
      utenteinstruttura :=
         ag_utilities.inizializza_utente (p_utente => p_utente);
      riservato := is_riservato (p_id_documento);

      dep_data_rif := ag_utilities.get_data_rif_privilegi (p_id_documento);

      --f_valore_campo (p_id_documento, campo_riservato);

      --verifica prima di tutto che esista almeno un'unita' per cui l'utente ha p_privilegio
      -- se cmq non ha il privilegio e' inutile proseguire.
      -- Non sapendo se p_privilegio è di quelli da super utente (tipo MTOT)
      -- che devono essere validi ad oggi, o meno, verifico sia ad oggi sia
      -- alla data di riferimento che dipende dal valore di storico_ruoli
      IF     utenteinstruttura = 1
         AND (   ag_utilities.verifica_privilegio_utente (
                    p_unita        => NULL,
                    p_privilegio   => p_privilegio,
                    p_utente       => p_utente,
                    p_data         => dep_data_rif) = 1
              OR ag_utilities.verifica_privilegio_utente (
                    p_unita        => NULL,
                    p_privilegio   => p_privilegio,
                    p_utente       => p_utente,
                    p_data         => TRUNC (SYSDATE)) = 1)
      THEN
         -- se p_utente ha il privilegio ed e' un superuser, ho finito.
         IF riservato = 'Y'
         THEN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'MTOTR',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         ELSE
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'MTOT',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         END IF;

         -- p_utente ha il privilegio ma non e' superuser, verifico se ha il privilegio come membro
         -- dell'unita protocollante o come membro di un'unita di carico attuale.
         IF retval = 0
         THEN
            retval :=
               verifica_per_protocollante (p_id_documento   => p_id_documento,
                                           p_privilegio     => p_privilegio,
                                           p_utente         => p_utente);

            IF retval = 0
            THEN
               idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);


               BEGIN
                  SELECT 1
                    INTO retval
                    FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
                   WHERE     docu.id_documento = seg_smistamenti.id_documento
                         AND docu.stato_documento NOT IN ('CA', 'RE')
                         AND seg_smistamenti.idrif = idrifprotocollo
                         AND (   seg_smistamenti.stato_smistamento IN (ag_utilities.smistamento_in_carico,
                                                                       ag_utilities.smistamento_eseguito)
                              OR seg_smistamenti.stato_smistamento =
                                    ag_utilities.smistamento_da_ricevere)
                         AND seg_smistamenti.ufficio_smistamento =
                                ag_priv_utente_tmp.unita
                         AND ag_priv_utente_tmp.utente = p_utente
                         AND ag_priv_utente_tmp.privilegio = p_privilegio
                         AND dep_data_rif <=
                                NVL (ag_priv_utente_tmp.al,
                                     TO_DATE (33333333, 'j'))
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;



            IF retval = 0 AND ag_utilities.is_iter_fascicoli_attivo = 1
            THEN
               -- Se c'e' iter_fascicoli, controlla anche l'unita' di smistamento
               -- del fascicolo

               DECLARE
                  dep_idrif_fascicolo             VARCHAR2 (100);
                  dep_ubicazione_fascicolo        VARCHAR2 (100);



                  dep_data_ubicazione_fascicolo   DATE;
                  dep_data_creazione_fascicolo    DATE;
                  dep_id_fascicolo                NUMBER;
               BEGIN
                  SELECT fasc.idrif, fasc.data_creazione, fasc.id_documento
                    INTO dep_idrif_fascicolo,
                         dep_data_creazione_fascicolo,
                         dep_id_fascicolo
                    FROM seg_fascicoli fasc, smistabile_view prot
                   WHERE     prot.id_documento = p_id_documento
                         AND fasc.class_cod = prot.class_cod
                         AND fasc.class_dal = prot.class_dal
                         AND fasc.fascicolo_anno = prot.fascicolo_anno
                         AND fasc.fascicolo_numero = prot.fascicolo_numero;

                  /*dep_ubicazione_fascicolo :=
                     ag_fascicolo_utility.get_unita_comp_attuale (
                        dep_idrif_fascicolo);*/
                  ag_fascicolo_utility.get_unita_data_comp_attuale (
                     p_idrif_fascicolo   => dep_idrif_fascicolo,
                     p_unita_attuale     => dep_ubicazione_fascicolo,
                     p_data_attuale      => dep_data_ubicazione_fascicolo);

                  BEGIN
                     SELECT 1
                       INTO retval
                       FROM ag_priv_utente_tmp
                      WHERE     ag_priv_utente_tmp.unita =
                                   dep_ubicazione_fascicolo
                            AND ag_priv_utente_tmp.utente = p_utente
                            AND ag_priv_utente_tmp.privilegio = p_privilegio
                            AND ag_utilities.get_Data_rif_privilegi (
                                   dep_id_fascicolo) <=
                                   NVL (ag_priv_utente_tmp.al,
                                        TO_DATE (333333, 'j'))
                            AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        retval := 0;
                  END;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END verifica_privilegio_documento;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_DOCUMENTO.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo.
    Serve a verificare i privilegi di modifica sui singoli campi/ dettagli del protocollo,
    quuindi si da per scontato che l'utente abbia diritti generici in modifica sul documento.
    L'utente puo' avere tali diritti perche' membro dell'unita' protocollante, perche' membro
    di un'unita' di carico o di una sua supoeriore, perche' super user; quindi si cerchera' di verificare
    il privilegio specifico (p_privilegio) in tutti questi casi.
    Il super user viene riconosciuto in quanto possessore del privilegio MTOT o MTOTR (documento pubblico o riservato);
    i membri di unita protocollante o unita di carico devono avere tale privilegio associato al ruolo che hanno nell'unita stessa,
    i memebri di unita ascendenti lo devono avere nell'unita' ascendente.
    Inoltre, sempre per membri diunita di carico o ascendenti, il privilegio deve essere previsto dallo smistamento.
    I criteri di verifica sono i seguenti:
   - se l'utente ha privilegio MTOT o MTOTR, si verifica che abbia anche p_privilegio
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   - se l'utente è membro di un'unita' cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento. Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   - se l'utente è membro di un'unita' ascendente di una cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento. Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   Gli smistamenti che vengono coltrollati dipendono dal valore dei parametri
   verifica_smistamenti_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C o R.
   verifica_carico_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C.
   verifica_smistamenti_storici - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento F.
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , verifica_smistamenti_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali, che siano in carico o da ricevere. 1 = fa il test, 0 non lo fa.
      verifica_carico_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali in carico. 1 = fa il test, 0 non lo fa.
      verifica_smistamenti_storici NUMBER indice se va fatto il test anche sui record di
      smistamenti storici. 1 = fa il test, 0 non lo fa.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_privilegio_documento (p_area                VARCHAR2,
                                           p_modello             VARCHAR2,
                                           p_codice_richiesta    VARCHAR2,
                                           p_privilegio          VARCHAR2,
                                           p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            ag_utilities.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval :=
            verifica_privilegio_documento (iddocumento,
                                           p_privilegio,
                                           p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END verifica_privilegio_documento;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro dell'unita esibente  e ha ruolo con privilegio VE
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS e CARICO
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - è membro dell'unita esibenre  e ha ruolo con privilegio VER
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR e  CARICO
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_verifica_esistenza_attivita NUMBER: 0 o 1: se 1 verifica se c'è in attesa
           un'attivita' JSUITE per lo smistamento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          01/09/2008  SC  A28345.12.0
    01    31/03/2017  SC  Gestione validita privilegi
   ********************************************************************************/
   FUNCTION lettura (p_id_documento                   VARCHAR2,
                     p_utente                         VARCHAR2,
                     p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
      riservato              VARCHAR2 (1);
      riservato_causa_fasc   VARCHAR2 (1) := 'N';
      suffissoprivilegio     VARCHAR2 (1);
      idrifprotocollo        VARCHAR2 (100);
      dep_data_rif           DATE;
   BEGIN
      --  DBMS_OUTPUT.put_line ('1VALORE DI RETVAL ' || retval);

      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = ag_utilities.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

      IF f_valore_campo (p_id_documento, campo_utente_protocollante) =
            p_utente
      THEN
         RETURN 1;
      END IF;

      dep_data_rif := ag_utilities.get_data_rif_privilegi (p_id_documento);

      riservato := is_riservato (p_id_documento);

      --f_valore_campo (p_id_documento, campo_riservato);
      IF riservato = 'Y'
      THEN
         suffissoprivilegio := 'R';

         IF NVL (f_valore_campo (p_id_documento, campo_riservato), 'N') = 'N'
         THEN
            riservato_causa_fasc := 'Y';
         END IF;
      END IF;

      -- se ha privilegio VTOT vede tutti i protocolli NON riservati.
      -- se ha privilegio VTOTR vede tutti i protocolli riservati.
      retval :=
         ag_utilities.verifica_privilegio_utente (
            p_unita        => NULL,
            p_privilegio   => 'VTOT' || suffissoprivilegio,
            p_utente       => p_utente,
            p_data         => TRUNC (SYSDATE));

      IF retval = 0
      THEN
         --per documenti NON riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VP.
         --per documenti riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VPR.
         retval :=
            verifica_per_protocollante (
               p_id_documento   => p_id_documento,
               p_privilegio     => 'VP' || suffissoprivilegio,
               p_utente         => p_utente);

         IF retval = 0
         THEN
            --VERIFICA SE P_UTENTE FA PARTE DI UN'UNITA RICEVENTE (ATTUALE O STORICA) CON PRIVILEGIO
            --VS per documenti NON riservati
            --VSR per documenti riservati .
            IF ag_parametro.get_valore (
                  'ITER_FASCICOLI_' || ag_utilities.indiceaoo,
                  '@agVar@',
                  'N') = 'Y'
            THEN
               BEGIN
                  SELECT NVL (MIN (1), 0)
                    INTO retval
                    FROM (SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu_smis,
                                 seg_fascicoli fasc,
                                 links,
                                 cartelle cart,
                                 documenti docu_fasc
                           WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND docu_smis.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = fasc.idrif
                                 AND seg_smistamenti.codice_assegnatario =
                                        p_utente
                                 AND seg_smistamenti.stato_smistamento IN ('R',
                                                                           'C')
                                 AND links.id_oggetto = p_id_documento
                                 AND links.tipo_oggetto = 'D'
                                 AND links.id_cartella = cart.id_cartella
                                 AND NVL (cart.stato, 'BO') != 'CA'
                                 AND cart.id_documento_profilo =
                                        fasc.id_documento
                                 AND fasc.id_documento =
                                        docu_fasc.id_documento
                                 AND docu_fasc.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND DECODE (
                                        riservato_causa_fasc,
                                        'N', 1,
                                        DECODE (NVL (fasc.riservato, 'N'),
                                                'Y', 1,
                                                0)) = 1
                          UNION ALL
                          SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu_smis,
                                 ag_priv_utente_tmp priv_vs,
                                 ag_privilegi_smistamento,
                                 seg_fascicoli fasc,
                                 links,
                                 cartelle cart,
                                 documenti docu_fasc
                           WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND docu_smis.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = fasc.idrif
                                 AND seg_smistamenti.tipo_smistamento =
                                        ag_privilegi_smistamento.tipo_smistamento
                                 AND priv_vs.utente = p_utente
                                 AND priv_vs.privilegio =
                                        'VS' || suffissoprivilegio
                                 AND ag_privilegi_smistamento.privilegio =
                                        priv_vs.privilegio
                                 AND seg_smistamenti.ufficio_smistamento =
                                        priv_vs.unita
                                 AND ag_utilities.get_Data_rif_privilegi (
                                        fasc.id_documento) <=
                                        NVL (priv_vs.al,
                                             TO_DATE (3333333, 'j'))
                                 AND ag_privilegi_smistamento.aoo =
                                        ag_utilities.indiceaoo
                                 AND links.id_oggetto = p_id_documento
                                 AND links.tipo_oggetto = 'D'
                                 AND links.id_cartella = cart.id_cartella
                                 AND NVL (cart.stato, 'BO') != 'CA'
                                 AND cart.id_documento_profilo =
                                        fasc.id_documento
                                 AND fasc.id_documento =
                                        docu_fasc.id_documento
                                 AND docu_fasc.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND DECODE (
                                        riservato_causa_fasc,
                                        'N', 1,
                                        DECODE (NVL (fasc.riservato, 'N'),
                                                'Y', 1,
                                                0)) = 1
                          UNION ALL
                          SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu_smis,
                                 ag_priv_utente_tmp priv,
                                 seg_fascicoli fasc,
                                 links,
                                 cartelle cart,
                                 documenti docu_fasc
                           WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND docu_smis.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = fasc.idrif
                                 -- AND seg_smistamenti.stato_smistamento = 'R'
                                 AND priv.utente = p_utente
                                 AND priv.privilegio =
                                        'VDDR' || suffissoprivilegio
                                 AND ag_utilities.get_data_rif_privilegi (
                                        fasc.id_documento) <=
                                        NVL (priv.al, TO_DATE (3333333, 'j'))
                                 AND seg_smistamenti.ufficio_smistamento =
                                        priv.unita
                                 AND links.id_oggetto = p_id_documento
                                 AND links.tipo_oggetto = 'D'
                                 AND links.id_cartella = cart.id_cartella
                                 AND NVL (cart.stato, 'BO') != 'CA'
                                 AND cart.id_documento_profilo =
                                        fasc.id_documento
                                 AND fasc.id_documento =
                                        docu_fasc.id_documento
                                 AND docu_fasc.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND DECODE (
                                        riservato_causa_fasc,
                                        'N', 1,
                                        DECODE (NVL (fasc.riservato, 'N'),
                                                'Y', 1,
                                                0)) = 1);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;

            IF retval = 0
            THEN
               BEGIN
                  idrifprotocollo :=
                     f_valore_campo (p_id_documento, campo_idrif);

                  SELECT NVL (MIN (1), 0)
                    INTO retval
                    FROM (SELECT 1
                            FROM seg_smistamenti, documenti docu
                           WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                 AND docu.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = idrifprotocollo
                                 AND seg_smistamenti.codice_assegnatario =
                                        p_utente
                                 AND seg_smistamenti.stato_smistamento IN ('R',
                                                                           'C')
                          UNION ALL
                          SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu,
                                 ag_priv_utente_tmp priv_vs,
                                 ag_privilegi_smistamento
                           WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                 AND docu.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = idrifprotocollo
                                 AND seg_smistamenti.tipo_smistamento =
                                        ag_privilegi_smistamento.tipo_smistamento
                                 AND priv_vs.utente = p_utente
                                 AND priv_vs.privilegio IN (   'VS'
                                                            || suffissoprivilegio,
                                                               'VDDR'
                                                            || suffissoprivilegio)
                                 AND ag_privilegi_smistamento.privilegio =
                                        priv_vs.privilegio
                                 AND seg_smistamenti.ufficio_smistamento =
                                        priv_vs.unita
                                 AND dep_data_rif <=
                                        NVL (priv_vs.al,
                                             TO_DATE (3333333, 'j'))
                                 AND ag_privilegi_smistamento.aoo =
                                        ag_utilities.indiceaoo /*UNION ALL




                                                               SELECT 1
                                                                 FROM seg_smistamenti, documenti docu
                                                                WHERE docu.stato_documento NOT IN ('CA', 'RE')




                                                                  AND docu.id_documento =
                                                                                       seg_smistamenti.id_documento
                                                                  AND seg_smistamenti.idrif = idrifprotocollo
                                                                  AND seg_smistamenti.stato_smistamento = 'R'




















                                                                  AND DECODE
                                                                         (seg_smistamenti.stato_smistamento,
                                                                          'R', da_ricevere
                                                                                     (p_id_documento,
                                                                                      p_utente,
                                                                                      p_verifica_esistenza_attivita
                                                                                     ),
                                                                          1
                                                                         ) = 1*/
                                                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('3VALORE DI RETVAL ' || retval);
      RETURN retval;
   END lettura;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro dell'unita esibente  e ha ruolo con privilegio VE
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS e CARICO
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - è membro dell'unita esibenre  e ha ruolo con privilegio VER
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR e  CARICO
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          01/09/2008  SC  A28345.12.0
   ********************************************************************************/
   FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := NULL;
      riservato            VARCHAR2 (1);
      continua             NUMBER := 0;
      suffissoprivilegio   VARCHAR2 (1);
      idrifprotocollo      VARCHAR2 (100);
   BEGIN
      RETURN lettura (p_id_documento                  => p_id_documento,
                      p_utente                        => p_utente,
                      p_verifica_esistenza_attivita   => 1);
   END lettura;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere privilegio VS/VSR o essere assegnatario
    del documento.
    Se tra tutti gli smistamenti in stato R relativi a p_utente, ce n'e' anche uno solo il cui relativo flusso
    non è arrivato ad attivare l'attivita' sul cruscotto, la funzione restituisce 0 per evitare
    disallineamenti tra lo stato dello smistamento e l'effettivo stato del flusso.
    la funzione restituisce 1 se l'utente appartiene all'unita ricevente e ha i diritti di vedere il documento,
    inoltre lo smistamento e il flusso collegato devono essere coerenti: cioe' deve essere attiva
    l'attivita' jsuite sul cruscotto come documento da ricevere per ogni smistamento.
    Se il documento è assegnato  la funzione restituisce 1 se l'utente è l'assegnatario.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
         16/01/2008  SC  Prima emissione. A25157.0.0
   ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN da_ricevere (p_id_documento                  => p_id_documento,
                          p_utente                        => p_utente,
                          p_verifica_esistenza_attivita   => 1);
   END;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE:  Verifica se il documento ha uno smistamento in stato da ricevere
                  per unita cui p_utente appartiene.
                  Inoltre p_utente deve avere diritti in lettura sul documento,
                  cioè deve avere privilegio VDDR/VDDRR oppure VS/VSR e CARICO e il
                  documento non deve essere assegnato oppure essere assegnatario
                  del documento.
                  Se tra tutti gli smistamenti in stato R relativi a p_utente, ce
                  n'e' anche uno solo il cui relativo flusso non è arrivato ad
                  attivare l'attivita' sul cruscotto, la funzione restituisce 0 per
                  evitare disallineamenti tra lo stato dello smistamento e
                  l'effettivo stato del flusso.
                  La funzione restituisce 1 se l'utente appartiene all'unita
                  ricevente e ha i diritti di vedere il documento, inoltre lo
                  smistamento e il flusso collegato devono essere coerenti: cioe'
                  deve essere attiva l'attivita' jsuite sul cruscotto come documento
                  da ricevere per ogni smistamento.
                  Se il documento è assegnato, la funzione restituisce 1 se l'utente
                  è l'assegnatario.
   INPUT    p_id_documento varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
            p_verifica_esistenza_attivita 0 o 1 se si vuole verificare se c'è
            un'attivita' jsuite in attesa.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore   Descrizione.
    00   02/01/2007  SC       Prima emissione.
         15/01/2008  SC       Faccio in modo che risulti da ricevere per
                              p_utente solo se non assegnato o assegnato a p_utente.
         16/01/2008  SC       A25157.0.0
         01/06/2011  MM       A33879.0.0: Aggiungere due ulteriori privilegi
                              (VDDR - VDDRR per i doc. riservati) che consentono di
                              vedere i documenti da ricevere senza poterci fare
                              nulla, è come l'attuale VS ma fa sì che il documento
                              da prendere in carico sia visibile a chi ha i
                              privilegi attuali (CARICO e VS) e a chi ha il nuovo

                              privilegio.
   ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER,
                         p_verifica_assegnazione          NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN da_ricevere (p_id_documento,
                          p_utente,
                          p_verifica_esistenza_attivita,
                          p_verifica_assegnazione,
                          NULL);
   END da_ricevere;

   /*****************************************************************************
     NOME:        da_ricevere
     DESCRIZIONE:  Verifica se il documento ha uno smistamento in stato da ricevere
                   per unita cui p_utente appartiene.
                   Inoltre p_utente deve avere diritti in lettura sul documento,
                   cioè deve avere privilegio VDDR/VDDRR oppure VS/VSR e CARICO e il
                   documento non deve essere assegnato oppure essere assegnatario
                   del documento.
                   Se tra tutti gli smistamenti in stato R relativi a p_utente, ce
                   n'e' anche uno solo il cui relativo flusso non è arrivato ad
                   attivare l'attivita' sul cruscotto, la funzione restituisce 0 per
                   evitare disallineamenti tra lo stato dello smistamento e
                   l'effettivo stato del flusso.
                   La funzione restituisce 1 se l'utente appartiene all'unita
                   ricevente e ha i diritti di vedere il documento, inoltre lo
                   smistamento e il flusso collegato devono essere coerenti: cioe'
                   deve essere attiva l'attivita' jsuite sul cruscotto come documento
                   da ricevere per ogni smistamento.
                   Se il documento è assegnato, la funzione restituisce 1 se l'utente
                   è l'assegnatario.
    INPUT    p_id_documento varchar2: chiave identificativa del documento.
             p_utente varchar2: utente che richiede di leggere il documento.
             p_verifica_esistenza_attivita 0 o 1 se si vuole verificare se c'è
             un'attivita' jsuite in attesa.
    RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
     Rev.  Data       Autore   Descrizione.
     00   02/01/2007  SC       Prima emissione.
          15/01/2008  SC       Faccio in modo che risulti da ricevere per
                               p_utente solo se non assegnato o assegnato a p_utente.
          16/01/2008  SC       A25157.0.0
          01/06/2011  MM       A33879.0.0: Aggiungere due ulteriori privilegi
                               (VDDR - VDDRR per i doc. riservati) che consentono di
                               vedere i documenti da ricevere senza poterci fare
                               nulla, è come l'attuale VS ma fa sì che il documento
                               da prendere in carico sia visibile a chi ha i
                               privilegi attuali (CARICO e VS) e a chi ha il nuovo
                               privilegio.
          05/04/2017  SC       Gestione validità privilegi
    ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER,
                         p_verifica_assegnazione          NUMBER,
                         p_unita_ricevente                VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := 0;
      idrifprotocollo        VARCHAR2 (100);
      riservato              VARCHAR2 (1) := 'N';
      suffissoprivilegio     VARCHAR2 (1);
      continua               NUMBER := 0;
      exectype_ricevimento   VARCHAR2 (100) := 'VISIONE';
      dep_Data_rif           DATE;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := ag_utilities.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
         riservato := is_riservato (p_id_documento);

         dep_Data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

         --f_valore_campo (p_id_documento, campo_riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            FOR s
               IN (SELECT    docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido /*,
                           ag_priv_utente_tmp*/
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.stato_smistamento = 'R'
                          AND seg_smistamenti.codice_assegnatario = p_utente
                          AND p_verifica_assegnazione = 1
                          AND ROWNUM = 1
                   UNION
                   SELECT    docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido,
                          ag_priv_utente_tmp priv_visu,
                          ag_priv_utente_tmp priv_carico
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.ufficio_smistamento =
                                 priv_visu.unita
                          AND seg_smistamenti.ufficio_smistamento =
                                 priv_carico.unita
                          AND seg_smistamenti.stato_smistamento = 'R'
                          AND seg_smistamenti.ufficio_smistamento || '' =
                                 NVL (p_unita_ricevente,
                                      seg_smistamenti.ufficio_smistamento)
                          AND priv_visu.utente = p_utente
                          AND priv_carico.utente = p_utente
                          AND NVL (seg_smistamenti.codice_assegnatario,
                                   p_utente) = p_utente
                          AND priv_visu.privilegio =
                                 'VS' || suffissoprivilegio
                          AND priv_carico.privilegio = 'CARICO'
                          AND dep_Data_rif <=
                                 NVL (priv_visu.al, TO_DATE (3333333, 'j'))
                          AND dep_Data_rif <=
                                 NVL (priv_carico.al, TO_DATE (3333333, 'j'))
                   UNION
                   SELECT    docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido,
                          ag_priv_utente_tmp priv_visu
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.ufficio_smistamento =
                                 priv_visu.unita
                          AND seg_smistamenti.stato_smistamento = 'R'
                          AND priv_visu.utente = p_utente
                          AND dep_Data_rif <=
                                 NVL (priv_visu.al, TO_DATE (3333333, 'j'))
                          AND priv_visu.privilegio =
                                 'VDDR' || suffissoprivilegio)
            LOOP
               --se non ci sono smistamenti da ricevere
               --con il nodo del cruscotto in attesa
               -- considero che il doc non è da ricevere.
               --DBMS_OUTPUT.put_line (s.triade);
               IF p_verifica_esistenza_attivita = 1
               THEN
                  retval :=
                     test_attivita_in_attesa (s.triade, exectype_ricevimento);

                  IF retval = 0
                  THEN
                     EXIT;
                  END IF;
               ELSE
                  retval := 1;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF riservato = 'Y' AND retval = 0
         THEN
            BEGIN
               FOR sriservati
                  IN (SELECT DISTINCT
                                docu.area
                             || '@'
                             || tido.nome
                             || '@'
                             || docu.codice_richiesta
                                triade
                        FROM seg_smistamenti,
                             documenti docu,
                             tipi_documento tido /*,
                              ag_priv_utente_tmp*/
                       WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                             AND docu.id_documento =
                                    seg_smistamenti.id_documento
                             AND docu.id_tipodoc = tido.id_tipodoc
                             AND seg_smistamenti.idrif = idrifprotocollo
                             AND seg_smistamenti.stato_smistamento = 'R'
                             AND seg_smistamenti.codice_assegnatario =
                                    p_utente)
               LOOP
                  IF p_verifica_esistenza_attivita = 1
                  THEN
                     retval :=
                        test_attivita_in_attesa (sriservati.triade,
                                                 exectype_ricevimento);

                     IF retval = 0
                     THEN
                        EXIT;
                     END IF;
                  ELSE
                     retval := 1;
                  END IF;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      RETURN retval;
   END da_ricevere;

   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN da_ricevere (
                p_id_documento                  => p_id_documento,
                p_utente                        => p_utente,
                p_verifica_esistenza_attivita   => p_verifica_esistenza_attivita,
                p_verifica_assegnazione         => 1);
   END da_ricevere;

   /*****************************************************************************
    NOME:        abilita_azione_smistamento
    DESCRIZIONE: Verifica se è possibile abilitare l'azione richiesta (SMISTA, INOLTRA)
    in base a:
    utente, per quale ragione vede il documento (protocollante, esibente, smistamento)
    se vede il documento a seguito di uno smistamento (l'abilitazione
    varia a seconda dello stato dello smistamento).
    Per SMISTA si restituisce 1 se
    l'utente è l'utente protocollante,
    l'utente è un protocollante o esibente con privilegio ISMI + CPROT;
    l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
    tabella AG_ABILITAZIONI_SMISTAMENTO
    Per INOLTRA e per ASSEGNA si restituisce 1 se:
    l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
    tabella AG_ABILITAZIONI_SMISTAMENTO.
    --A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
    Per CARICO, si verifica che l'utente abbia privilegio CARICO e non privilegio ISMI.
    In tutti gli altri casi si restituisce 0.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione (''CARICO', 'ESEGUI', 'ASSEGNA', SMISTA', 'INOLTRA')
         p_stato_smistamento Se è rilevante verificare lo stato dello smistamento,
                           va specificato tramite questo parametro. Default null.
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    20/06/2007  SC  Prima emissione.
          20/05/2009  SC  A32601.0.0 Per smistare documenti protocollati
                                       a nome dell'unita protocollante ci vuole ISMI + CPROT.
          20/05/2009  SC A32603.0.0 SC Per tutte le azioni, tranne CARICO, si verifica se
                                       l'utente ha privilegio ISMI, ma per abilitare
                                       la presa in carico si verifica il privilegio CARICO.
          01/06/2009  SC A33037.0.0 L'utente protocollante può sempre inserire smistamenti.
          17/08/2009  SC A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
          18/08/2009  SC A33906.0.0 Per il carico e assegna, diventa rilevante verificare
                                   se ci sono unità aperte in smistamenti da ricevere.
                                   Altrimenti si abilita il bottone, ma poi
                                   non ha unità di assegnazione da proporre.
          31/03/2017 SC Gestione controllo date su privilegi.
          19/04/2017 SC  Il privilegio ASS viene verificato sempre in data odierna
                         perchè il package che costruisce l'interfaccia fa vedere
                         i componenti cui assegnare solo se privilegio ASS è valido OGGI.
    002  2/09/2019  SC     Bug #37160 Modifiche per performance abilita_azione_smistamento
   ********************************************************************************/
   FUNCTION abilita_azione_smistamento (
      p_id_documento         VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER
   IS
      retval                NUMBER := 0;
      idrifprotocollo       VARCHAR2 (100);
      unita_protocollante   seg_unita.unita%TYPE;
      unita_esibente        seg_unita.unita%TYPE;
      p_privilegio          VARCHAR2 (100) := 'ISMI';
      utenteinstruttura     NUMBER := 0;
      dep_data_rif          DATE;
   BEGIN
      utenteinstruttura :=
         ag_utilities.inizializza_utente (p_utente => p_utente);

      IF utenteinstruttura = 1 AND p_azione = 'SMISTA'
      THEN
         -- A32601.0.0 SC Non verifico se l'unità protocollante è valorizzata,
         -- ma se il documento è protocollato. Fino a quando non è protocollato,
         -- i nuovi smistamenti vengono inseriti da chiuinque abbia ISMI.
         --A33037.0.0 Se si tratta dell'utente protocollante, può smistare il documento.
         IF p_utente =
               f_valore_campo (p_id_documento, campo_utente_protocollante)
         THEN
            retval := 1;
         END IF;

         IF retval = 0
         THEN
            retval :=
               ag_utilities.verifica_privilegio_utente (NULL,
                                                        'ISMITOT',
                                                        p_utente,
                                                        TRUNC (SYSDATE));
         END IF;

         IF retval = 0
         THEN
            retval :=
               verifica_per_protocollante (p_id_documento   => p_id_documento,
                                           p_privilegio     => p_privilegio,
                                           p_utente         => p_utente);
         END IF;
      END IF;

      IF utenteinstruttura = 1 AND retval = 0
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);

         dep_data_rif := ag_utilities.get_data_rif_privilegi (p_id_documento);

         IF p_azione = 'CARICO'
         THEN
            -- A32603.0.0 SC PER LE AZIONI DI CARICO L'UTENTE DEVE AVERE PRIVILEGIO CARICO
            p_privilegio := 'CARICO';
         END IF;

         BEGIN
            --A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp,
                   ag_abilitazioni_smistamento,
                   seg_smistamenti,
                   documenti dosm,
                   seg_unita
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_unita.progr_unita_organizzativa =
                          ag_priv_utente_tmp.progr_unita
                   AND p_stato_smistamento IS NULL
                   AND seg_smistamenti.stato_smistamento =
                          ag_abilitazioni_smistamento.stato_smistamento
                   AND seg_smistamenti.tipo_smistamento =
                          ag_abilitazioni_smistamento.tipo_smistamento
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND (   (    ag_priv_utente_tmp.privilegio = p_privilegio
                            AND dep_Data_rif <=
                                   NVL (ag_priv_utente_tmp.al,
                                        TO_DATE (3333333, 'j')))
                        OR NVL (seg_smistamenti.codice_assegnatario, '*') =
                              p_utente)
                   AND ag_abilitazioni_smistamento.azione = p_azione
                   AND ag_abilitazioni_smistamento.aoo =
                          ag_utilities.indiceaoo
                   AND seg_unita.unita = seg_smistamenti.ufficio_smistamento||''
                   AND seg_unita.codice_amministrazione =
                          seg_smistamenti.codice_amministrazione
                   AND DECODE (ag_abilitazioni_smistamento.azione,
                               'ASSEGNA', seg_unita.al,
                               NULL)
                          IS NULL
                   AND DECODE (
                          ag_abilitazioni_smistamento.azione,
                          'ESEGUI', NULL,
                          DECODE (seg_smistamenti.codice_assegnatario,
                                  NULL, NULL,
                                  ag_priv_utente_tmp.al))
                          IS NULL
                   AND (   NVL ( p_azione, 'x') <> 'ASSEGNA'
                        OR (    p_azione = 'ASSEGNA'
                            AND (SELECT   AG_UTILITIES.verifica_privilegio_utente (
                                             seg_smistamenti.ufficio_smistamento,
                                             'ASS',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                        + AG_UTILITIES.verifica_privilegio_utente (
                                             NULL,
                                             'ASSTOT',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                   FROM DUAL) > 0))
                   AND ROWNUM = 1
            UNION ALL
            SELECT 1
              FROM ag_priv_utente_tmp,
                   ag_abilitazioni_smistamento,
                   seg_smistamenti,
                   documenti dosm,
                   seg_unita
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_unita.progr_unita_organizzativa =
                          ag_priv_utente_tmp.progr_unita
                   AND p_stato_smistamento =
                          seg_smistamenti.stato_smistamento
                   AND seg_smistamenti.stato_smistamento =
                          ag_abilitazioni_smistamento.stato_smistamento
                   AND seg_smistamenti.tipo_smistamento =
                          ag_abilitazioni_smistamento.tipo_smistamento
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND (   (    ag_priv_utente_tmp.privilegio = p_privilegio
                            AND dep_Data_rif <=
                                   NVL (ag_priv_utente_tmp.al,
                                        TO_DATE (3333333, 'j')))
                        OR NVL (seg_smistamenti.codice_assegnatario, '*') =
                              p_utente)
                   AND ag_abilitazioni_smistamento.azione = p_azione
                   AND ag_abilitazioni_smistamento.aoo =
                          ag_utilities.indiceaoo
                   AND seg_unita.unita = seg_smistamenti.ufficio_smistamento||''
                   AND seg_unita.codice_amministrazione =
                          seg_smistamenti.codice_amministrazione
                   AND DECODE (ag_abilitazioni_smistamento.azione,
                               'ASSEGNA', seg_unita.al,
                               NULL)
                          IS NULL
                   AND DECODE (
                          ag_abilitazioni_smistamento.azione,
                          'ESEGUI', NULL,
                          DECODE (seg_smistamenti.codice_assegnatario,
                                  NULL, NULL,
                                  ag_priv_utente_tmp.al))
                          IS NULL
                  AND (   NVL ( p_azione, 'x') <> 'ASSEGNA'
                        OR (    p_azione = 'ASSEGNA'
                            AND (SELECT   AG_UTILITIES.verifica_privilegio_utente (
                                             seg_smistamenti.ufficio_smistamento,
                                             'ASS',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                        + AG_UTILITIES.verifica_privilegio_utente (
                                             NULL,
                                             'ASSTOT',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                   FROM DUAL) > 0))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         --se l'azione è esegui e il documento è assegnato a p_utente,
         -- da ricevere o in carico
         -- consento l'abilitazione.
         IF retval = 0 AND p_azione = 'ESEGUI'
         THEN
            SELECT 1
              INTO retval
              FROM seg_smistamenti, documenti dosm
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_smistamenti.stato_smistamento IN ('R', 'C')
                   AND NVL (seg_smistamenti.codice_assegnatario, '*') =
                          p_utente
                   AND ROWNUM = 1;
         END IF;
      END IF;

      --se l'azione è SMISTA e il documento è assegnato a p_utente,
      -- in carico
      -- consento l'abilitazione.
      IF retval = 0 AND p_azione = 'SMISTA'
      THEN
         SELECT 1
           INTO retval
           FROM seg_smistamenti, documenti dosm
          WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                AND dosm.id_documento = seg_smistamenti.id_documento
                AND seg_smistamenti.idrif = idrifprotocollo
                AND seg_smistamenti.stato_smistamento = 'C'
                AND NVL (seg_smistamenti.codice_assegnatario, '*') = p_utente
                AND ROWNUM = 1;
      END IF;

      RETURN retval;
   END abilita_azione_smistamento;

   FUNCTION abilita_azione_smistamento (
      p_cr                   VARCHAR2,
      p_area                 VARCHAR2,
      p_cm                   VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := gdm_profilo.getdocumento (p_cm, p_area, p_cr);
      RETURN abilita_azione_smistamento (d_id_documento,
                                         p_utente,
                                         p_azione,
                                         p_stato_smistamento);
   EXCEPTION
      WHEN OTHERS
      THEN
         --se non trovo il documento...
         RETURN 1;
   END;

   /*****************************************************************************
    NOME:        get_tipo_smistamento
    DESCRIZIONE: Dati in protocollo e un'unita di trasmissione, stabilisce quale
    tipo smistamento è possibile per quell'unita.
    Il tipo smistamento possibile dipende da
    lo stato in cui l'unita' di trasmissione ha il documento (da ricevere, in carico.)
    il tipo di smistamento con cui l'unita ha ricevuto il documento.
    L'azione che si sta compiendo (SMISTA, INOLTRA).
    In base ad essi si vede nella tabella AG_ABILITAZIONI_SMISTAMENTO quali tipi di smistamento sono generabili,
    se sono piu' di uno viene selezionato quello del tipo smistamento piu' importante
    (che è nella tabella ag_tipi_smistamento).


   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_unita_trasmissione VARCHAR2 codice dell'unita che sta creando un nuovo smistamento.
         p_azione ('SMISTA', 'INOLTRA')
   RITORNO:  TIPO_SMISTAMENTO possibile, null se non ce n'è nessuno.
    Rev.  Data       Autore  Descrizione.
    00    20/06/2007  SC  Prima emissione.
    01    31/03/2017  SC  Inserita gestione confronto date di ag_priv_utente_tmp.
   ********************************************************************************/
   FUNCTION get_tipo_smistamento (p_id_documento          VARCHAR2,
                                  p_utente                VARCHAR2,
                                  p_unita_trasmissione    VARCHAR2,
                                  p_azione                VARCHAR2)
      RETURN VARCHAR2
   IS
      retval            VARCHAR2 (100);
      idrifprotocollo   VARCHAR2 (100);
   BEGIN
      retval := ag_utilities.inizializza_utente (p_utente => p_utente);
      idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);

      /*Dato che in casi particolari ci potrebbe essere piu' di uno smistamento
      per l'utente e l'unita di trasmissione passati, il tipo_smistamento possibile
      è quello associato al tipo_smistamento di partenza piu' importante
      (l'importanza è in AG_TIPI_SMISTAMENTO).
      */
      FOR tipi_smistamento
         IN (  SELECT ag_abilitazioni_smistamento.tipo_smistamento_generabile
                 FROM seg_smistamenti,
                      documenti docu,
                      ag_priv_utente_tmp,
                      ag_abilitazioni_smistamento,
                      ag_tipi_smistamento
                WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                      AND docu.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND seg_smistamenti.ufficio_smistamento =
                             ag_priv_utente_tmp.unita
                      AND seg_smistamenti.stato_smistamento =
                             ag_abilitazioni_smistamento.stato_smistamento
                      AND seg_smistamenti.tipo_smistamento =
                             ag_abilitazioni_smistamento.tipo_smistamento
                      AND ag_priv_utente_tmp.utente = p_utente
                      AND ag_utilities.get_Data_rif_privilegi (p_id_documento) <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ag_abilitazioni_smistamento.azione = p_azione
                      AND ag_abilitazioni_smistamento.aoo =
                             ag_utilities.indiceaoo
                      AND ag_tipi_smistamento.aoo =
                             ag_abilitazioni_smistamento.aoo
                      AND ag_tipi_smistamento.tipo_smistamento =
                             ag_abilitazioni_smistamento.tipo_smistamento
             ORDER BY ag_tipi_smistamento.importanza)
      LOOP
         retval := tipi_smistamento.tipo_smistamento_generabile;
         EXIT;
      END LOOP;

      RETURN retval;
   END get_tipo_smistamento;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per
    unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere un ruolo con privilegio
    VS / VSR o, per documenti riservati, deve essere assegnatario del documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_verifica_esistenza_attivita indica se va verificato che esista attività jsuite.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
           15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
    00    20/05/2009  SC  A32603.0.0 Verifica l'esistenza dell'attivita jsuite solo se richiesto.
    01    31/03/2017  SC  Gestione date di validità dei privilegi
   ********************************************************************************/
   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER,
                       p_verifica_assegnazione          NUMBER,
                       p_unita_ricevente                VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
      exectype_carico      VARCHAR2 (100) := 'ESECUZIONE';
      dep_data_rif         DATE;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := ag_utilities.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
         riservato := is_riservato (p_id_documento);

         dep_data_rif := ag_utilities.get_data_rif_privilegi (p_id_documento);

         --f_valore_campo (p_id_documento, campo_riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            FOR s
               IN (SELECT DISTINCT
                             docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido,
                          ag_priv_utente_tmp
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.ufficio_smistamento =
                                 ag_priv_utente_tmp.unita
                          AND seg_smistamenti.ufficio_smistamento || '' =
                                 NVL (p_unita_ricevente,
                                      seg_smistamenti.ufficio_smistamento)
                          AND seg_smistamenti.stato_smistamento =
                                 ag_utilities.smistamento_in_carico
                          AND (   p_verifica_assegnazione = 0
                               OR seg_smistamenti.codice_assegnatario IS NULL
                               OR seg_smistamenti.codice_assegnatario =
                                     p_utente)
                          AND ag_priv_utente_tmp.utente = p_utente
                          AND dep_data_rif <=
                                 NVL (ag_priv_utente_tmp.al,
                                      TO_DATE (3333333, 'j'))
                          AND ag_priv_utente_tmp.privilegio =
                                 'VS' || suffissoprivilegio
                   UNION ALL
                   SELECT DISTINCT
                             docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido /*,
                           ag_priv_utente_tmp*/
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.stato_smistamento =
                                 ag_utilities.smistamento_in_carico
                          AND seg_smistamenti.codice_assegnatario = p_utente
                          AND p_verifica_assegnazione = 1)
            LOOP
               IF p_verifica_esistenza_attivita = 1
               THEN
                  retval :=
                     test_attivita_in_attesa (s.triade, exectype_carico);

                  IF retval = 0
                  THEN
                     EXIT;
                  END IF;
               ELSE
                  retval := 1;
               END IF;
            END LOOP;

            DBMS_OUTPUT.put_line ('FINE SELECT ' || retval);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
               DBMS_OUTPUT.put_line ('EXCEPTION ' || retval);
         END;

         IF riservato = 'Y' AND retval = 0
         THEN
            BEGIN
               FOR sriservati
                  IN (SELECT DISTINCT
                                docu.area
                             || '@'
                             || tido.nome
                             || '@'
                             || docu.codice_richiesta
                                triade
                        FROM seg_smistamenti,
                             documenti docu,
                             tipi_documento tido /*,
                              ag_priv_utente_tmp*/
                       WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                             AND docu.id_documento =
                                    seg_smistamenti.id_documento
                             AND docu.id_tipodoc = tido.id_tipodoc
                             AND seg_smistamenti.idrif = idrifprotocollo
                             AND seg_smistamenti.stato_smistamento = 'C'
                             AND seg_smistamenti.codice_assegnatario =
                                    p_utente)
               LOOP
                  IF p_verifica_esistenza_attivita = 1
                  THEN
                     retval :=
                        test_attivita_in_attesa (sriservati.triade,
                                                 exectype_carico);

                     IF retval = 0
                     THEN
                        EXIT;
                     END IF;
                  ELSE
                     retval := 1;
                  END IF;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
      RETURN retval;
   END in_carico;

   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER,
                       p_verifica_assegnazione          NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN in_carico (p_id_documento,
                        p_utente,
                        p_verifica_esistenza_attivita,
                        p_verifica_assegnazione,
                        NULL);
   END in_carico;

   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
      exectype_carico      VARCHAR2 (100) := 'ESECUZIONE';
      stato_pr             VARCHAR2 (10);
   BEGIN
      RETURN in_carico (
                p_id_documento                  => p_id_documento,
                p_utente                        => p_utente,
                p_verifica_esistenza_attivita   => p_verifica_esistenza_attivita,
                p_verifica_assegnazione         => 1);
   END in_carico;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere un ruolo con privilegio
    VS / VSR o, per documenti riservati, deve essere assegnatario del documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
           15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
    00    20/05/2009  SC  A32603.0.0 Verifica l'esistenza dell'attivita jsuite.
   ********************************************************************************/
   FUNCTION in_carico (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN in_carico (p_id_documento, p_utente, 1);
   END in_carico;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION in_carico (p_area                VARCHAR2,
                       p_modello             VARCHAR2,
                       p_codice_richiesta    VARCHAR2,
                       p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         ag_utilities.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval := in_carico (iddocumento, p_utente);
      END IF;

      RETURN retval;
   END in_carico;

   /*****************************************************************************
    NOME:        eseguito
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato eseguito per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION eseguito (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         ag_utilities.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval :=
            eseguito (p_id_documento            => TO_CHAR (iddocumento),
                      p_utente                  => p_utente,
                      p_unita_ricevente         => NULL,
                      p_verifica_assegnazione   => 1);
      END IF;

      RETURN retval;
   END eseguito;

   FUNCTION eseguito (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2,
                      p_unita_ricevente     VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         ag_utilities.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval := eseguito (iddocumento, p_utente, p_unita_ricevente);
      END IF;

      RETURN retval;
   END eseguito;

   /*****************************************************************************
    NOME:        eseguito
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato eseguito per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere un ruolo con privilegio
    VS / VSR o, per documenti riservati, deve essere assegnatario del documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
            15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
    01    31/03/2017   SC Gestione date per privilegi
   ********************************************************************************/
   FUNCTION eseguito (p_id_documento             VARCHAR2,
                      p_utente                   VARCHAR2,
                      p_unita_ricevente          VARCHAR2 := NULL,
                      p_verifica_assegnazione    NUMBER := 1)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
      dep_data_rif         DATE;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := ag_utilities.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
         riservato := is_riservato (p_id_documento);
         dep_data_rif := ag_utilities.get_data_rif_privilegi (p_id_documento);

         --f_valore_campo (p_id_documento, campo_riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            SELECT 1
              INTO retval
              FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
             WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                   AND docu.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_smistamenti.ufficio_smistamento =
                          ag_priv_utente_tmp.unita
                   AND seg_smistamenti.ufficio_smistamento || '' =
                          NVL (p_unita_ricevente,
                               seg_smistamenti.ufficio_smistamento)
                   AND seg_smistamenti.stato_smistamento =
                          ag_utilities.smistamento_eseguito
                   AND (   seg_smistamenti.codice_assegnatario IS NULL
                        OR seg_smistamenti.codice_assegnatario = p_utente)
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND ag_priv_utente_tmp.privilegio =
                          'VS' || suffissoprivilegio
                   AND dep_data_rif <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         --DBMS_OUTPUT.put_line ('FINE SELECT ' || retval);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         --DBMS_OUTPUT.put_line ('EXCEPTION ' || retval);
         END;

         IF riservato = 'Y' AND retval = 0
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
                WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                      AND docu.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND seg_smistamenti.stato_smistamento =
                             ag_utilities.smistamento_eseguito
                      AND seg_smistamenti.ufficio_smistamento =
                             ag_priv_utente_tmp.unita
                      AND seg_smistamenti.codice_assegnatario =
                             ag_priv_utente_tmp.utente
                      AND ag_priv_utente_tmp.utente = p_utente
                      AND dep_data_rif <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
      RETURN retval;
   END eseguito;

   FUNCTION eseguito (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
   BEGIN
      RETURN eseguito (p_id_documento            => p_id_documento,
                       p_utente                  => p_utente,
                       p_unita_ricevente         => NULL,
                       p_verifica_assegnazione   => 1);
   END eseguito;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION da_ricevere (p_area                VARCHAR2,
                         p_modello             VARCHAR2,
                         p_codice_richiesta    VARCHAR2,
                         p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;

      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         ag_utilities.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval :=
            da_ricevere (p_id_documento => iddocumento, p_utente => p_utente);
      END IF;

      RETURN retval;
   END da_ricevere;

   /*****************************************************************************
 NOME:        RESETTA
 DESCRIZIONE: Annulla la variabile globale g_diritto utilizzata per verificare le
 competenze su jatti
INPUT

 Rev.  Data       Autore  Descrizione.
 00    06/06/2008  SC  Prima emissione. A27764.0.0
********************************************************************************/
   PROCEDURE resetta
   IS
   BEGIN
      g_diritto := NULL;
   END resetta;

   /*****************************************************************************
 NOME:        SET_TRUE
 DESCRIZIONE: Mette a 1 variabile globale g_diritto utilizzata per verificare le
 competenze su jatti
INPUT

 Rev.  Data       Autore  Descrizione.
 00    06/06/2008  SC  Prima emissione. A27764.0.0
********************************************************************************/
   PROCEDURE set_true
   IS
   BEGIN
      g_diritto := 1;
   END set_true;

   /*****************************************************************************
 NOME:        SET_FALSE
 DESCRIZIONE: Mette a 0 variabile globale g_diritto utilizzata per verificare le
 competenze su jatti
INPUT

 Rev.  Data       Autore  Descrizione.
 00    06/06/2008  SC  Prima emissione. A27764.0.0
********************************************************************************/
   PROCEDURE set_false
   IS
   BEGIN
      g_diritto := 0;
   END set_false;

   /*****************************************************************************
  NOME:        check_abilita_ripudio
  DESCRIZIONE: Verifica se l'utente ha possibilita di ripudiare lo smistamento da ricevere.
  ci deve essere un solo smistamento da ricevere per l'utente che sta aprendo il documento
  o più smistamenti da ricevere ma tutti con la stessa unità di trasmissione.

 INPUT  p_id_documento varchar2: chiave identificativa del documento.
       p_utente varchar2: utente che richiede di leggere il documento.
 RITORNO:  1 se l'utente ha diritti di ripudio , 0 altrimenti.
  Rev.  Data       Autore  Descrizione.
  00    28/01/2009  AM  Prima emissione.
  01    05/04/2017  SC  Gestione date privilegi
 ********************************************************************************/
   FUNCTION check_abilita_ripudio (p_area                VARCHAR2,
                                   p_modello             VARCHAR2,
                                   p_codice_richiesta    VARCHAR2,
                                   p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := 0;
      idrifprotocollo        VARCHAR2 (100);
      riservato              VARCHAR2 (1) := 'N';
      suffissoprivilegio     VARCHAR2 (1);

      continua               NUMBER := 0;
      exectype_ricevimento   VARCHAR2 (100) := 'VISIONE';
      ufficio_trasmissione   seg_unita.unita%TYPE := '';
      iddocumento            documenti.id_documento%TYPE;
      dep_Data_rif           DATE;
   BEGIN
      iddocumento :=
         ag_utilities.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := ag_utilities.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         idrifprotocollo := f_valore_campo (iddocumento, campo_idrif);
         riservato := is_riservato (iddocumento);

         dep_Data_rif := ag_utilities.get_data_rif_privilegi (iddocumento);

         --f_valore_campo (iddocumento, campo_riservato);

         --DBMS_OUTPUT.put_line ('IDRIF ' || idrifprotocollo || ' riservato ' || riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            SELECT a.uftr
              INTO ufficio_trasmissione
              FROM (SELECT DISTINCT
                           seg_smistamenti.ufficio_trasmissione AS uftr
                      FROM seg_smistamenti,
                           documenti docu,
                           tipi_documento tido,
                           ag_priv_utente_tmp
                     WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                           AND docu.id_documento =
                                  seg_smistamenti.id_documento
                           AND docu.id_tipodoc = tido.id_tipodoc
                           AND seg_smistamenti.idrif = idrifprotocollo
                           AND seg_smistamenti.ufficio_smistamento =
                                  ag_priv_utente_tmp.unita
                           AND seg_smistamenti.stato_smistamento = 'R'
                           AND ag_priv_utente_tmp.utente = p_utente
                           AND dep_Data_rif <=
                                  NVL (ag_priv_utente_tmp.al,
                                       TO_DATE (3333333, 'j'))
                           AND (   seg_smistamenti.codice_assegnatario =
                                      ag_priv_utente_tmp.utente
                                OR seg_smistamenti.codice_assegnatario
                                      IS NULL)
                    UNION
                    SELECT DISTINCT
                           seg_smistamenti.ufficio_trasmissione AS uftr
                      FROM seg_smistamenti,
                           documenti docu,
                           tipi_documento tido,
                           ag_priv_utente_tmp priv_visu,
                           ag_priv_utente_tmp priv_carico
                     WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                           AND docu.id_documento =
                                  seg_smistamenti.id_documento
                           AND docu.id_tipodoc = tido.id_tipodoc
                           AND seg_smistamenti.idrif = idrifprotocollo
                           AND seg_smistamenti.ufficio_smistamento =
                                  priv_visu.unita
                           AND seg_smistamenti.ufficio_smistamento =
                                  priv_carico.unita
                           AND seg_smistamenti.stato_smistamento = 'R'
                           AND priv_visu.utente = p_utente
                           AND priv_carico.utente = p_utente
                           AND (   seg_smistamenti.codice_assegnatario =
                                      p_utente
                                OR seg_smistamenti.codice_assegnatario
                                      IS NULL)
                           AND priv_visu.privilegio =
                                  'VS' || suffissoprivilegio
                           AND dep_Data_rif <=
                                  NVL (priv_visu.al, TO_DATE (3333333, 'j'))
                           AND priv_carico.privilegio = 'CARICO'
                           AND dep_Data_rif <=
                                  NVL (priv_carico.al,
                                       TO_DATE (3333333, 'j'))) a;

            retval := 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         --DBMS_OUTPUT.put_line ('EXCEPTION ' || retval);
         END;
      END IF;

      RETURN retval;
   --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
   END;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR
   IS
      d_componenti         VARCHAR2 (4000) := '@';
      dep_id_smistamenti   VARCHAR2 (32000);
      dep_id_smistamento   NUMBER;
      dep_utente           ad4_utenti.utente%TYPE;
   BEGIN
      d_componenti :=
         get_componenti_unita_azione (p_area,
                                      p_codice_modello,
                                      p_codice_richiesta,
                                      p_codice_unita,
                                      p_azione);
      dep_id_smistamenti := id_smistamenti;

      --id_smistamenti: lista id_doc smistamenti separati da virgola
      WHILE NVL (dep_id_smistamenti, ',') <> ','
      LOOP
         dep_id_smistamento :=
            TO_NUMBER (afc.get_substr (dep_id_smistamenti, ','));

         IF NVL (dep_id_smistamento, 0) != 0
         THEN
            dep_utente :=
               f_valore_campo (dep_id_smistamento, 'UTENTE_TRASMISSIONE');

            IF INSTR (d_componenti, '@' || dep_utente || '@') = 0
            THEN
               d_componenti := d_componenti || dep_utente || '@';

               --DEVO RIABILITARE LO SMISTAMENTO PER CONSENTIRE DI SMISTARE NUOVAMENTE
               DECLARE
                  dep_da_riesumare        NUMBER;
                  dep_dal                 DATE;
                  dep_idrif               VARCHAR2 (32000);
                  dep_descrizione_unita   seg_unita.nome%TYPE;
               BEGIN
                  SELECT smistamento_dal, idrif, des_ufficio_smistamento
                    INTO dep_dal, dep_idrif, dep_descrizione_unita
                    FROM seg_smistamenti
                   WHERE id_documento = dep_id_smistamento;

                  SELECT MAX (id_documento)
                    INTO dep_da_riesumare
                    FROM seg_smistamenti s1
                   WHERE     ufficio_smistamento = p_codice_unita
                         AND stato_smistamento = 'F'
                         AND idrif = dep_idrif
                         AND smistamento_dal < dep_dal
                         AND NOT EXISTS
                                (SELECT 1
                                   FROM seg_smistamenti s2
                                  WHERE     s2.ufficio_trasmissione =
                                               s1.ufficio_smistamento
                                        AND s2.stato_smistamento =
                                               s1.stato_smistamento
                                        AND s1.smistamento_dal >
                                               s2.smistamento_dal
                                        AND s1.idrif = s2.idrif
                                        AND s2.smistamento_dal < dep_dal);

                  UPDATE seg_smistamenti
                     SET stato_smistamento = 'E',
                         note =
                               DECODE (note, NULL, '', note || CHR (10))
                            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                            || ' Smistamento riattivato automaticamente per gestione rifiuto da parte di '
                            || dep_descrizione_unita
                   WHERE id_documento = dep_da_riesumare;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END IF;
      END LOOP;

      RETURN d_componenti;
   END;

   /*****************************************************************************
   NOME:        get_componenti_unita_per_azione
   DESCRIZIONE: ritorna la lista dei componenti di una data unita che
              hanno la possibilita' di compiere una azione in particolare

  INPUT  p_area               VARCHAR2,
        p_codice_modello     VARCHAR2,
        p_codice_richiesta   VARCHAR2, codice richiesta del protocollo
        p_codice_unita       VARCHAR2, codice unita della unita' da cui ottenere i componenti
        p_azione             VARCHAR2  azione da valutare per ogni utente dell'unita
  RITORNO:  lista dei componenti di una unita che hanno diritti su una azione in particolare
   Rev.  Data       Autore  Descrizione.
   00    20302/2009  AM  Prima emissione.
  ********************************************************************************/
   FUNCTION get_componenti_unita_azione (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2)
      RETURN VARCHAR
   IS
      componentiunita   afc.t_ref_cursor;

      retval            NUMBER := 0;
      d_componenti      VARCHAR2 (4000) := '@';
      d_ni              NUMBER;
      d_descr           VARCHAR2 (50);
      d_utente          ag_priv_utente_tmp.utente%TYPE;
      dep_aoo_index     NUMBER;
      dep_ottica        VARCHAR2 (1000);
   BEGIN
      dep_aoo_index := ag_utilities.get_defaultaooindex ();
      dep_ottica := ag_utilities.get_ottica_aoo (dep_aoo_index);
      componentiunita :=
         so4_ags_pkg.unita_get_componenti_ord (
            p_codice_uo   => p_codice_unita,
            p_ottica      => dep_ottica);

      IF componentiunita%ISOPEN
      THEN
         LOOP
            FETCH componentiunita INTO d_ni, d_descr, d_utente;

            EXIT WHEN componentiunita%NOTFOUND;
            retval :=
               abilita_azione_smistamento (p_codice_richiesta,
                                           p_area,
                                           p_codice_modello,
                                           d_utente,
                                           p_azione);

            IF (retval = 1)
            THEN
               d_componenti := d_componenti || d_utente || '@';
            END IF;
         END LOOP;

         CLOSE componentiunita;
      END IF;

      RETURN d_componenti;
   END;

   PROCEDURE check_titolario (p_id_documento            NUMBER,
                              p_class_cod_old           VARCHAR2,
                              p_class_dal_old           DATE,
                              p_fascicolo_anno_old      NUMBER,
                              p_fascicolo_numero_old    VARCHAR2,
                              p_class_cod_new           VARCHAR2,
                              p_class_dal_new           DATE,
                              p_fascicolo_anno_new      NUMBER,
                              p_fascicolo_numero_new    VARCHAR2,
                              p_utente                  VARCHAR2)
   IS
      modificata_classifica    NUMBER := 0;
      modificato_fascicolo     NUMBER := 0;
      stato_fascicolo_old      NUMBER;
      privilegio_abilitato     NUMBER := 1;
      descrizione_documento    VARCHAR2 (2000);
      privilegio_controllato   ag_privilegi.privilegio%TYPE;
   BEGIN
      IF    (p_class_cod_old IS NULL AND p_class_cod_new IS NOT NULL)
         OR (p_class_cod_new IS NULL AND p_class_cod_old IS NOT NULL)
         OR (    p_class_cod_old IS NOT NULL
             AND p_class_cod_new IS NOT NULL
             AND p_class_cod_old <> p_class_cod_new)
      THEN
         modificata_classifica := 1;
      END IF;

      IF    (    (   p_fascicolo_anno_old IS NULL
                  OR p_fascicolo_numero_old IS NULL)
             AND (   p_fascicolo_anno_new IS NOT NULL
                  OR p_fascicolo_numero_new IS NOT NULL))
         OR (    (   p_fascicolo_anno_new IS NULL
                  OR p_fascicolo_numero_new IS NULL)
             AND (   p_fascicolo_anno_old IS NOT NULL
                  OR p_fascicolo_numero_old IS NOT NULL))
         OR (    p_fascicolo_anno_old IS NOT NULL
             AND p_fascicolo_numero_old IS NOT NULL
             AND p_fascicolo_anno_new IS NOT NULL
             AND p_fascicolo_numero_new IS NOT NULL
             AND (   p_fascicolo_anno_old <> p_fascicolo_anno_new
                  OR p_fascicolo_numero_old <> p_fascicolo_numero_new))
      THEN
         modificato_fascicolo := 1;
      END IF;

      DBMS_OUTPUT.put_line (
            'mod clas, mod fasc '
         || modificata_classifica
         || ' '
         || modificato_fascicolo);


      IF modificata_classifica = 1
      THEN
         privilegio_abilitato :=
            verifica_privilegio_documento (p_id_documento, 'MC', p_utente);



         privilegio_controllato := 'MC';
         DBMS_OUTPUT.put_line (
            'privilegio_controllato ' || privilegio_controllato);
      END IF;

      IF privilegio_abilitato = 1 AND modificato_fascicolo = 1
      THEN
         BEGIN
            SELECT NVL (stato_fascicolo, 1)
              INTO stato_fascicolo_old
              FROM seg_fascicoli f, cartelle c, documenti d
             WHERE     class_cod = p_class_cod_old
                   AND class_dal = p_class_dal_old
                   AND fascicolo_anno = p_fascicolo_anno_old
                   AND fascicolo_numero = p_fascicolo_numero_old
                   AND c.id_documento_profilo = f.id_documento
                   AND NVL (c.stato, 'BO') != 'CA'
                   AND d.id_documento = c.id_documento_profilo
                   AND d.stato_documento NOT IN ('CA', 'RE', 'PB');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               stato_fascicolo_old := 1;
            WHEN OTHERS
            THEN
               RAISE;
         END;

         DBMS_OUTPUT.put_line ('dopo ndf');

         IF stato_fascicolo_old = 1
         THEN
            privilegio_abilitato :=
               verifica_privilegio_documento (p_id_documento,
                                              'MFD',
                                              p_utente);
            privilegio_controllato := 'MFD';
            DBMS_OUTPUT.put_line (
               'privilegio_controllato ' || privilegio_controllato);
         ELSE
            privilegio_abilitato :=
               verifica_privilegio_documento (p_id_documento,
                                              'MDDEP',
                                              p_utente);
            privilegio_controllato := 'MDDEP';
            DBMS_OUTPUT.put_line (
               'privilegio_controllato ' || privilegio_controllato);
         END IF;
      END IF;

      IF privilegio_abilitato = 0
      THEN
         BEGIN
            SELECT    ' del '
                   || TO_CHAR (TRUNC (DATA), 'DD/MM/YYYY')
                   || DECODE (oggetto, NULL, '', ' oggetto: ' || oggetto)
              INTO descrizione_documento
              FROM spr_da_fascicolare
             WHERE id_documento = p_id_documento;
         EXCEPTION
            WHEN OTHERS
            THEN
               descrizione_documento := ' n. ' || p_id_documento;
         END;

         raise_application_error (
            -20998,
               'L''utente '
            || ad4_utente.get_nominativo (p_utente)
            || ' non è abilitato a modificare la classificazione principale del documento '
            || descrizione_documento
            || ' (privilegio necessario '''
            || privilegio_controllato
            || ''')');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   /*****************************************************************************
   NOME:        is_in_carico_solo_per_ass
   DESCRIZIONE:

  INPUT
  RITORNO:
   Rev.  Data       Autore  Descrizione.
   01    05/04/2014  SC     Gestione date per privilegi
  ********************************************************************************/
   FUNCTION is_in_carico_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      p_id_documento   NUMBER;
      dep_data_rif     DATE;
   BEGIN
      p_id_documento := ag_utilities.get_documento_per_idrif (p_idrif);

      IF     in_carico (p_id_documento                  => p_id_documento,
                        p_utente                        => p_utente,
                        p_verifica_esistenza_attivita   => 0,
                        p_verifica_assegnazione         => 0) = 0
         AND in_carico (p_id_documento                  => p_id_documento,
                        p_utente                        => p_utente,
                        p_verifica_esistenza_attivita   => 0,
                        p_verifica_assegnazione         => 1) = 1
      THEN
         DECLARE
            retval   NUMBER;
         BEGIN
            --            SELECT 1
            --              INTO retval
            --              FROM DUAL
            --             WHERE EXISTS
            --                      (SELECT 1
            --                         FROM ag_priv_utente_tmp
            --                        WHERE     unita IN
            --                                     (SELECT ufficio_smistamento
            --                                        FROM seg_smistamenti
            --                                       WHERE     stato_smistamento = 'C'
            --                                             AND idrif = p_idrif)
            --                              AND al IS NOT NULL
            --                              AND utente = p_utente);
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM ag_priv_utente_tmp priv
                        WHERE     unita IN (SELECT ufficio_smistamento
                                              FROM seg_smistamenti
                                             WHERE     stato_smistamento =
                                                          'C'
                                                   AND idrif = p_idrif)
                              AND ag_utilities.get_data_rif_privilegi (
                                     p_id_documento) <=
                                     NVL (priv.al, TO_DATE (3333333, 'j'))
                              AND priv.utente = p_utente);

            RETURN 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   END is_in_carico_solo_per_ass;

   /*****************************************************************************
   NOME:        is_da_ricevere_solo_per_ass
   DESCRIZIONE:

  INPUT
  RITORNO:
   Rev.  Data       Autore  Descrizione.
   01    05/04/2014  SC     Gestione date per privilegi
  ********************************************************************************/
   FUNCTION is_da_ricevere_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      p_id_documento   NUMBER;
   BEGIN
      p_id_documento := ag_utilities.get_documento_per_idrif (p_idrif);

      IF     da_ricevere (p_id_documento                  => p_id_documento,
                          p_utente                        => p_utente,
                          p_verifica_esistenza_attivita   => 0,
                          p_verifica_assegnazione         => 0) = 0
         AND da_ricevere (p_id_documento                  => p_id_documento,
                          p_utente                        => p_utente,
                          p_verifica_esistenza_attivita   => 0,
                          p_verifica_assegnazione         => 1) = 1
      THEN
         DECLARE
            retval   NUMBER;
         BEGIN
            /*            SELECT 1
                          INTO retval
                          FROM DUAL
                         WHERE EXISTS
                                  (SELECT 1
                                     FROM ag_priv_utente_tmp
                                    WHERE     unita IN
                                                 (SELECT ufficio_smistamento
                                                    FROM seg_smistamenti
                                                   WHERE     stato_smistamento = 'R'
                                                         AND idrif = p_idrif)
                                          AND al IS NOT NULL
                                          AND utente = p_utente);*/
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM ag_priv_utente_tmp
                        WHERE     unita IN (SELECT ufficio_smistamento
                                              FROM seg_smistamenti
                                             WHERE     stato_smistamento =
                                                          'R'
                                                   AND idrif = p_idrif)
                              AND ag_utilities.get_data_rif_privilegi (
                                     p_id_documento) <=
                                     NVL (al, TO_DATE (3333333, 'j'))
                              AND utente = p_utente);

            RETURN 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION get_stato_scarto (p_id_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      retval                 ag_stati_scarto.stato%TYPE;
      dep_scarto_doc         ag_stati_scarto.stato%TYPE;
      dep_conservazione      documenti.conservazione%TYPE;
      dep_class_cod          seg_fascicoli.class_cod%TYPE;
      dep_class_dal          seg_fascicoli.class_dal%TYPE;
      dep_fascicolo_anno     seg_fascicoli.fascicolo_anno%TYPE;
      dep_fascicolo_numero   seg_fascicoli.fascicolo_numero%TYPE;
   BEGIN
      BEGIN
         SELECT stato_scarto,
                conservazione,
                class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero
           INTO dep_scarto_doc,
                dep_conservazione,
                dep_class_cod,
                dep_class_dal,
                dep_fascicolo_anno,
                dep_fascicolo_numero
           FROM spr_da_fascicolare, documenti
          WHERE     documenti.id_documento = spr_da_fascicolare.id_documento
                AND spr_da_fascicolare.id_documento = p_id_documento;

         IF dep_conservazione IN ('CC', 'DC', 'IC')
         THEN
            retval := dep_scarto_doc;
         ELSE
            IF dep_scarto_doc != '**' OR dep_fascicolo_anno IS NULL
            THEN
               retval := dep_scarto_doc;
            ELSE
               BEGIN
                  SELECT stato_scarto
                    INTO retval
                    FROM seg_fascicoli
                   WHERE     class_cod = dep_class_cod
                         AND class_dal = dep_class_dal
                         AND fascicolo_anno = dep_fascicolo_anno
                         AND fascicolo_numero = dep_fascicolo_numero;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := dep_scarto_doc;
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END get_stato_scarto;

   FUNCTION get_data_stato_scarto (p_id_documento VARCHAR2)
      RETURN DATE
   IS
      retval                 seg_fascicoli.data_stato_scarto%TYPE;
      dep_scarto_doc         seg_fascicoli.stato_scarto%TYPE;
      dep_data_scarto_doc    seg_fascicoli.data_stato_scarto%TYPE;
      dep_conservazione      documenti.conservazione%TYPE;
      dep_class_cod          seg_fascicoli.class_cod%TYPE;
      dep_class_dal          seg_fascicoli.class_dal%TYPE;
      dep_fascicolo_anno     seg_fascicoli.fascicolo_anno%TYPE;
      dep_fascicolo_numero   seg_fascicoli.fascicolo_numero%TYPE;
   BEGIN
      BEGIN
         SELECT stato_scarto,
                data_stato_scarto,
                conservazione,
                class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero
           INTO dep_scarto_doc,
                dep_data_scarto_doc,
                dep_conservazione,
                dep_class_cod,
                dep_class_dal,
                dep_fascicolo_anno,
                dep_fascicolo_numero
           FROM spr_da_fascicolare, documenti
          WHERE     documenti.id_documento = spr_da_fascicolare.id_documento
                AND spr_da_fascicolare.id_documento = p_id_documento;

         IF dep_conservazione IN ('CC', 'DC', 'IC')
         THEN
            retval := dep_data_scarto_doc;
         ELSE
            IF dep_scarto_doc != '**' OR dep_fascicolo_anno IS NULL
            THEN
               retval := dep_data_scarto_doc;
            ELSE
               BEGIN
                  SELECT data_stato_scarto
                    INTO retval
                    FROM seg_fascicoli
                   WHERE     class_cod = dep_class_cod
                         AND class_dal = dep_class_dal
                         AND fascicolo_anno = dep_fascicolo_anno
                         AND fascicolo_numero = dep_fascicolo_numero;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := dep_data_scarto_doc;
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END get_data_stato_scarto;
------------
END;
/
