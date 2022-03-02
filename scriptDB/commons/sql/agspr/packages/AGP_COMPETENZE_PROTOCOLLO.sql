--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_COMPETENZE_PROTOCOLLO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AGP_COMPETENZE_PROTOCOLLO"
IS
   /******************************************************************************
    NOME:        AGP_COMPETENZE_PROTOCOLLO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data        Autore   Descrizione.
    00   02/01/2007  SC       Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';
   -- variabile globale per contenere il ritorno del lancio delle funzioni di protocollo
   -- che viene fatto via sqlexecute perche' esistono solo se c'è l'integrazione.
   g_diritto              NUMBER (1);

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

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
   FUNCTION lettura (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_testo (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION lettura_testo_gdm (p_id_documento_esterno    VARCHAR2,
                               p_utente                  VARCHAR2)
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
   FUNCTION modifica (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_testo (p_idDocumento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_testo_gdm (p_id_documento_esterno    VARCHAR2,
                                p_utente                  VARCHAR2)
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
   FUNCTION eliminazione (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION eliminazione_gdm (p_id_documento_esterno    VARCHAR2,
                              p_utente                  VARCHAR2)
      RETURN NUMBER;
END;
/

CREATE OR REPLACE PACKAGE BODY "AGP_COMPETENZE_PROTOCOLLO"
IS
   /******************************************************************************
    NOME:        AGP_COMPETENZE_PROTOCOLLO
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
                 verificare i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data       Autore Descrizione.
   000  02/01/2007 SC     Prima emissione.
   002  23/01/2019 MM     Modificata get_competenza per gestire le competenze sul
                          documento anche dopo la protocollazione.
   003  30/07/2019 MM     Modificata get_competenza_documento aggiungendo test su
                          privilegio VP o VE.
   004  05/08/2019 MM     Modificate modifica_testo e lettura_testo in modo che
                          lancino le funzioni lettura e modifica (prima tornavano
                          sempre 1).
   005  13/08/2019 MM     Modificata get_competenza_documento in modo che la
                          verifica su privilegio VP o VE la faccia indipendentemente
                          dal ruolo per cui l'utente li ha sull'unità data.
   006  05/11/2019 MM     Modificata funzione get_competenza per gestione riservati
   007  18/11/2019 MM     Modificata funzione get_competenza.
   008  27/11/2019 MM     Modificata get_id_doc_from_id_esterno con gestione valido.
   009  19/12/2019 MM     Creata is_riservato che verifichi anche la riservatezza
                          del fascicolo di appartenenza del documento.
   010  02/03/2020 MM     Modificata eliminazione_gdm per gestione competenze se
                          è un documento di interoperabilità e l'utente ha le
                          competenze in  modifica.
   011  19/06/2020 MM     Modificata get_id_doc_from_id_esterno con verifica
                          idrif non nullo.
   012  01/07/2020 MM     Modificata get_competenza_documento in modo che non
                          consideri record legati all'attore UnitaProtocollante
                          in cui sia presente solo il ruolo e non l'uo.
   013  13/08/2020 MM     Modificata funzione lettura per consentire accessi a RPI
                          e GDM.
   013  23/09/2020 MM     Modificata get_competenza.
   014  11/08/2020 MM     Gestione tabella AGS_FASCICOLI (sostituita alla vista)
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '014';

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

   FUNCTION get_id_doc_from_id_esterno (p_id_documento_esterno VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
   BEGIN
      SELECT p.id_documento
        INTO d_id_documento
        FROM gdo_documenti d, agp_protocolli p
       WHERE     d.id_documento_esterno = p_id_documento_esterno
             AND p.id_documento = d.id_documento
             AND p.idrif IS NOT NULL
             AND NVL (d.valido, 'N') = 'Y';

      RETURN d_id_documento;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_competenza_documento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_competenza      VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
      retval           NUMBER;
   BEGIN
      BEGIN
         SELECT 1
           INTO retval
           FROM (SELECT * FROM gdo_documenti_competenze
                 MINUS
                 SELECT *
                   FROM gdo_documenti_competenze
                  WHERE     ruolo IS NOT NULL
                        AND unita_progr IS NULL
                        AND id_cfg_competenza IN (SELECT id_cfg_competenza
                                                    FROM wkf_cfg_competenze
                                                   WHERE id_attore IN (SELECT id_attore
                                                                         FROM wkf_diz_attori
                                                                        WHERE nome =
                                                                                 'UO Protocollante')))
                comp
          WHERE     id_documento = p_id_documento
                AND utente = p_utente
                AND (   (modifica = 'Y' AND p_competenza = 'modifica')
                     OR (lettura = 'Y' AND p_competenza = 'lettura')
                     OR (    cancellazione = 'Y'
                         AND p_competenza = 'cancellazione'))
         UNION
         SELECT 1
           FROM (SELECT * FROM gdo_documenti_competenze
                 MINUS
                 SELECT *
                   FROM gdo_documenti_competenze
                  WHERE     ruolo IS NOT NULL
                        AND unita_progr IS NULL
                        AND id_cfg_competenza IN (SELECT id_cfg_competenza
                                                    FROM wkf_cfg_competenze
                                                   WHERE id_attore IN (SELECT id_attore
                                                                         FROM wkf_diz_attori
                                                                        WHERE nome =
                                                                                 'UO Protocollante')))
                comp,
                ag_priv_utente_tmp u
          WHERE     comp.id_documento = p_id_documento
                AND u.utente = p_utente
                AND EXISTS
                       (SELECT 1
                          FROM ag_priv_utente_tmp
                         WHERE     utente = p_utente
                               AND progr_unita = comp.unita_progr
                               AND privilegio IN ('VP', 'VE')
                               AND SYSDATE BETWEEN dal
                                               AND NVL (
                                                      al,
                                                      TO_DATE (3333333, 'j')))
                AND comp.unita_progr = u.progr_unita
                AND comp.utente IS NULL
                AND NVL (comp.ruolo, u.ruolo) = u.ruolo
                AND (   (modifica = 'Y' AND p_competenza = 'modifica')
                     OR (lettura = 'Y' AND p_competenza = 'lettura')
                     OR (cancellazione = 'Y' AND p_competenza = 'cancellazione'))
                AND SYSDATE BETWEEN u.dal
                                AND NVL (u.al, TO_DATE (3333333, 'j'))
         UNION
         SELECT 1
           FROM gdo_documenti_competenze comp, ag_priv_utente_tmp u
          WHERE     comp.id_documento = p_id_documento
                AND u.utente = p_utente
                AND comp.unita_progr IS NULL
                AND comp.utente IS NULL
                AND comp.ruolo = u.ruolo
                AND (   (modifica = 'Y' AND p_competenza = 'modifica')
                     OR (lettura = 'Y' AND p_competenza = 'lettura')
                     OR (    cancellazione = 'Y'
                         AND p_competenza = 'cancellazione'))
                AND SYSDATE BETWEEN u.dal
                                AND NVL (u.al, TO_DATE (3333333, 'j'));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := 0;
      END;

      RETURN retval;
   END;

   FUNCTION is_riservato (p_id_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      retval      VARCHAR2 (1) := 'N';
      d_id_fasc   NUMBER;
   BEGIN
      SELECT NVL (riservato, 'N'), id_fascicolo
        INTO retval, d_id_fasc
        FROM agp_protocolli p, gdo_documenti d
       WHERE     p.id_documento = p_id_documento
             AND d.id_documento = p.id_documento;

      IF retval = 'N' AND d_id_fasc IS NOT NULL
      THEN
         BEGIN
            SELECT NVL (d.riservato, 'N')
              INTO retval
              FROM ags_fascicoli f, gdo_documenti d
             WHERE     f.id_documento = d_id_fasc
                   AND d.id_documento = f.id_documento
                   AND d.valido = 'Y'
                   AND NVL (d.riservato, 'N') = 'Y'
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               retval := 'N';
         END;
      END IF;

      RETURN retval;
   END is_riservato;

   FUNCTION get_competenza (p_id_documento    NUMBER,
                            p_utente          VARCHAR2,
                            p_competenza      VARCHAR2)
      RETURN NUMBER
   IS
      retval                     NUMBER := NULL;
      dep_is_protocollato        NUMBER := 0;
      d_id_documento_esterno     NUMBER;
      d_id_documento_messaggio   NUMBER;
      d_riservato                VARCHAR2 (1);
   BEGIN
      BEGIN
         SELECT DECODE (anno, NULL, 0, DECODE (numero, NULL, 0, 1)),
                d.id_documento_esterno,
                NVL (d.riservato, 'N')
           INTO dep_is_protocollato, d_id_documento_esterno, d_riservato
           FROM agp_protocolli p, gdo_documenti d
          WHERE     d.id_documento = p.id_documento
                AND p.id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            dep_is_protocollato := 0;
      END;

      IF dep_is_protocollato = 0
      THEN
         d_id_documento_messaggio :=
            agp_competenze_messaggio.get_documento_messaggio (p_id_documento);

         IF d_id_documento_messaggio IS NOT NULL
         THEN
            IF p_competenza = 'lettura'
            THEN
               retval :=
                  agp_competenze_messaggio.lettura_messaggio_arrivo (
                     d_id_documento_messaggio,
                     p_utente);
            ELSE
               retval :=
                  agp_competenze_messaggio.modifica_messaggio_arrivo (
                     d_id_documento_messaggio,
                     p_utente);
            END IF;
         ELSE
            retval :=
               get_competenza_documento (p_id_documento,
                                         p_utente,
                                         p_competenza);
         END IF;
      ELSE
         IF p_competenza = 'lettura'
         THEN
            retval :=
               gdm_ag_competenze_protocollo.lettura (d_id_documento_esterno,
                                                     p_utente);
         END IF;

         IF p_competenza = 'modifica'
         THEN
            retval :=
               gdm_ag_competenze_protocollo.modifica (d_id_documento_esterno,
                                                      p_utente);
         END IF;

         IF p_competenza = 'cancellazione'
         THEN
            retval := 0;
         END IF;

         IF NVL (retval, 0) = 0 AND is_riservato (p_id_documento) = 'N'
         THEN
            retval :=
               get_competenza_documento (p_id_documento,
                                         p_utente,
                                         p_competenza);
         END IF;
      END IF;

      RETURN retval;
   END;

   /*****************************************************************************
       NOME:        LETTURA
       DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON protocollato se il documento
       è in arrivo e collegato ad una mail e se ha un privilegio che gli consente di gestire
       il tag_mail presente sulla mail stessa, altrimenti il controllo è demandato al
       documentale.

      INPUT  p_id_documento varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti in lettura, null altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    26/06/2007  SC  Prima emissione.
      ********************************************************************************/

   FUNCTION lettura_non_protocollati (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      retval := 1;

      RETURN retval;
   END lettura_non_protocollati;

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
      RETURN NUMBER
   IS
      retval   NUMBER := NULL;
   BEGIN
      retval := 1;

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

   FUNCTION modifica (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN get_competenza (p_id_documento, p_utente, 'modifica');
   END modifica;

   /* funzione associata al modello per il calcolo delle competenze */

   FUNCTION modifica_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

      IF d_id_documento IS NOT NULL
      THEN
         retval := modifica (d_id_documento, p_utente);
      ELSE
         NULL;
         retval :=
            gdm_ag_competenze_protocollo.modifica (p_id_documento_esterno,
                                                   p_utente);
      END IF;

      RETURN retval;
   END;

   /*******************************************************************************
         NOME:          MODIFICA_TESTO.
         DESCRIZIONE:   Verifica la possibilita' dell'utente di modificare il testo
                        dell'allegato.
         INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                        p_utente       varchar2: utente che richiede di leggere il
                                                 documento.
         RITORNO:       Un testo è modificabile se è leggibile.

       Rev. Data       Autore   Descrizione.
       003  20/08/2015 MM       Prima emissione.
      *******************************************************************************/

   FUNCTION modifica_testo (p_idDocumento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_ret   NUMBER;
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      d_ret := modifica (p_idDocumento, p_utente);

      RETURN d_ret;
   END;

   FUNCTION modifica_testo_gdm (p_id_documento_esterno    VARCHAR2,
                                p_utente                  VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      IF p_id_documento_esterno = 'PARNONINTERPRETATO'
      THEN
         RETVAL := 1;
      ELSE
         d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

         IF d_id_documento IS NOT NULL
         THEN
            retval := modifica_testo (d_id_documento, p_utente);
         ELSE
            NULL;
            retval :=
               gdm_ag_competenze_protocollo.modifica_testo (
                  p_id_documento_esterno,
                  p_utente);
         END IF;
      END IF;

      RETURN retval;
   END;

   /*****************************************************************************
        NOME:        eliminazione.
        DESCRIZIONE: Un utente ha i diritti in eliminazione se il documento non è
                     protocollato e se ne ha le competenze esplicite oppure, è un
                     documento di interoperabilità e l'utente ha le competenze in
                     modifica.

       INPUT  p_id_documento    varchar2: chiave identificativa del documento.
              p_utente          varchar2: utente che vuole eliminare il documento
       RITORNO:  se il documento è protocollato restituisce sempre 0, altrimenti
                 restituisce null.

        Rev.  Data       Autore Descrizione.

        006   08/09/2016 MM     Modificata  funzione in modo che, per i protocolli
                                M_PROTOCOLLO_INTEROPERABILITA, possa eliminare un
                                documento chi può modificarlo.
   ******************************************************************************/

   FUNCTION eliminazione (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      d_return := get_competenza (p_id_documento, p_utente, 'cancellazione');
      RETURN d_return;
   END eliminazione;

   /* funzione associata al modello per il calcolo delle competenze */

   FUNCTION eliminazione_gdm (p_id_documento_esterno    VARCHAR2,
                              p_utente                  VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

      IF d_id_documento IS NOT NULL
      THEN
         retval := eliminazione (d_id_documento, p_utente);

         IF retval = 0
         THEN
            /* Un utente ha i diritti in eliminazione se il documento non è protocollato e
               se ne ha le competenze esplicite oppure, è un documento di interoperabilità
               e l'utente ha le competenze in  modifica.*/
            DECLARE
               d_anno        NUMBER;
               d_categoria   VARCHAR2 (256);
            BEGIN
               SELECT p.anno, tp.categoria
                 INTO d_anno, d_categoria
                 FROM agp_protocolli p, agp_tipi_protocollo tp
                WHERE     p.id_documento = d_id_documento
                      AND tp.id_tipo_protocollo = p.id_tipo_protocollo;

               IF d_anno IS NULL AND d_categoria = 'PEC'
               THEN
                  NULL;
                  retval := modifica_gdm (p_id_documento_esterno, p_utente);
               END IF;
            END;
         END IF;
      ELSE
         retval :=
            gdm_ag_competenze_protocollo.eliminazione (
               p_id_documento_esterno,
               p_utente);
      END IF;

      RETURN retval;
   END;

   FUNCTION lettura (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      RETURN get_competenza (p_id_documento, p_utente, 'lettura');
   END;

   /* funzione associata al modello per il calcolo delle competenze */

   FUNCTION lettura_gdm (p_id_documento_esterno VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

      IF d_id_documento IS NOT NULL
      THEN
         retval := lettura (d_id_documento, p_utente);
      ELSE
         NULL;
         retval :=
            gdm_ag_competenze_protocollo.lettura (p_id_documento_esterno,
                                                  p_utente);
      END IF;

      RETURN retval;
   END;

   FUNCTION lettura_testo (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := NULL;
   BEGIN
      retval := lettura (p_id_documento, p_utente);

      RETURN retval;
   END;

   FUNCTION lettura_testo_gdm (p_id_documento_esterno    VARCHAR2,
                               p_utente                  VARCHAR2)
      RETURN NUMBER
   IS
      retval           NUMBER := NULL;
      d_id_documento   NUMBER;
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      IF p_id_documento_esterno = 'PARNONINTERPRETATO'
      THEN
         RETVAL := 1;
      ELSE
         d_id_documento := get_id_doc_from_id_esterno (p_id_documento_esterno);

         IF d_id_documento IS NOT NULL
         THEN
            retval := lettura (d_id_documento, p_utente);
         ELSE
            NULL;
            retval :=
               gdm_ag_competenze_protocollo.lettura_testo (
                  p_id_documento_esterno,
                  p_utente);
         END IF;
      END IF;

      RETURN retval;
   END;
END;
/