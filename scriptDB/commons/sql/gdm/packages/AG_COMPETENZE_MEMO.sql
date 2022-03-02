--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_MEMO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_COMPETENZE_MEMO"
IS
/******************************************************************************
 NOME:        Ag_Competenze_memo
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui documenti MEMO dell'area SYSMAIL
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data        Autore  Descrizione.
 00    02/01/2007  SC      Prima emissione.
 01    17/11/2014  MM      Aggiunto parametro p_data alla funzione verifica_privilegio_casella.
******************************************************************************/
   -- Revisione del Package
   s_revisione CONSTANT VARCHAR2 (40) := 'V1.01';
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

/*****************************************************************************
 NOME:        LETTURA.
 DESCRIZIONE: Un utente ha i diritti di vedere uno RAPPORTO se ha
 tale diritto sul protocollo collegato.
INPUT  p_idDocumento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION LETTURA (
      p_idDocumento             VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere uno RAPPORTO se ha
 tale diritto sul protocollo collegato.
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION LETTURA (
      p_area                    VARCHAR2
    , p_modello                 VARCHAR2
    , p_codice_richiesta        VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;

   FUNCTION verifica_privilegio_casella (
      p_iddocumento   VARCHAR2,
      p_utente        VARCHAR2,
      p_data          DATE default null
   )
      RETURN NUMBER;

   FUNCTION modifica (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION eliminazione (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;
END Ag_Competenze_memo;
/
CREATE OR REPLACE PACKAGE BODY ag_competenze_memo
IS
   /******************************************************************************
   -- NOME:        GDM.Ag_Competenze_memo
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti MEMO dell'area sysmail.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev.  Data          Autore   Descrizione.
    000   02/01/2007    SC       Prima emissione.
    001   17/11/2014    MM       Aggiunta gestione della data nella funzione lettura
                                 e modificata funzione verifica_privilegio_casella
                                 aggiungendo parametro p_data.
    002   05/05/2016    MM       Modificata funzione lettura.
    003   07/03/2017    MM       V2.7
    004   16/05/2018    MM       Gestione messaggio senza destinatari dell'ente
    005   25/10/2019    MM       Modificata funzione lettura per gestione
                                 competenze agspr.
   ******************************************************************************/
   s_revisione_body   VARCHAR2 (40) := '005';

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
      RETURN s_revisione || '.' || s_revisione_body;
   END;                                              -- Ag_Competenza.versione

   --------------------------------------------------------------------------------
   FUNCTION modifica (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval      NUMBER := 0;
      statomemo   VARCHAR2 (10);
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

      statomemo := NVL (f_valore_campo (p_iddocumento, 'STATO_MEMO'), 'DG');

      IF statomemo IN ('DG', 'SC')
      THEN
         retval := verifica_privilegio_casella (p_iddocumento, p_utente);
      END IF;

      IF statomemo = 'NP'
      THEN
         retval := ag_competenze_documento.modifica (p_iddocumento, p_utente);
      END IF;

      RETURN retval;
   END;

   /*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE:  Un utente ha i diritti di vedere uno MEMO se ha tale diritto sul
                  protocollo collegato.
                  Se pero' il MEMO è con PROCESSATO_AG = N e GENERATA_ECCEZIONE = N,
                  non c'è nessun protocollo collegato, ma il memo è visibile a
                  chi lo deve protocollare manualmente, cioè a chi ha privilegio
                  PROTMAIL.
   INPUT    p_idDocumento  varchar2: chiave identificativa del documento.
            p_utente       varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
   Rev.  Data        Autore   Descrizione.
   000   02/01/2007  SC       Prima emissione.
   001   17/11/2014  MM       Aggiunta gestione della data nei memo da protocollare.
   002   05/05/2016  MM       Aggiunta gestione dei padri nei memo non protocollati.
   ********************************************************************************/
   FUNCTION lettura (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      iddocumentocollegato   NUMBER;
      retval                 NUMBER := 0;
      inpartenza             VARCHAR2 (1);
      statomemo              VARCHAR2 (10);
   BEGIN
      DBMS_OUTPUT.put_line ('1');

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

      DBMS_OUTPUT.put_line ('2');
      inpartenza :=
         NVL (f_valore_campo (p_iddocumento, 'MEMO_IN_PARTENZA'), 'N');
      DBMS_OUTPUT.put_line ('inpartenza ' || inpartenza);
      statomemo := NVL (f_valore_campo (p_iddocumento, 'STATO_MEMO'), 'DG');
      DBMS_OUTPUT.put_line ('statomemo ' || statomemo);

      --se si tratta di un memo in partenza
      -- la visibilita' del memo dipende da quella del protocollo
      -- O del memo parte attiva della relazione
      IF inpartenza = 'Y'
      THEN
         DBMS_OUTPUT.put_line ('3');

         BEGIN
            FOR c IN (SELECT id_documento
                        FROM riferimenti rife
                       WHERE     rife.tipo_relazione IN ('MAIL',
                                                         'FAX',
                                                         'PROT_CONF',
                                                         'PROT_AGG',
                                                         'PROT_ANN',
                                                         'PROT_ECC',
                                                         'PROT_RR')
                             AND id_documento_rif = p_iddocumento)
            LOOP
               IF ag_utilities.verifica_categoria_documento (
                     c.id_documento,
                     ag_utilities.categoriaprotocollo) = 1
               THEN
                  retval :=
                     agspr_competenze_protocollo.lettura_gdm (c.id_documento,
                                                              p_utente);
               ELSE
                  IF ag_utilities.verifica_categoria_documento (
                        c.id_documento,
                        'POSTA_ELETTRONICA') = 1
                  THEN
                     retval :=
                        ag_competenze_memo.lettura (c.id_documento, p_utente);
                  END IF;
               END IF;

               IF retval = 1
               THEN
                  EXIT;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         RETURN retval;
      END IF;

      IF inpartenza = 'N' AND statomemo = 'PR'
      THEN
         FOR id_protocolli
            IN (SELECT id_documento
                  FROM riferimenti rife
                 WHERE     rife.tipo_relazione IN ('MAIL', 'FAX')
                       AND id_documento_rif = p_iddocumento)
         LOOP
            retval :=
               agspr_competenze_protocollo.lettura_gdm (
                  id_protocolli.id_documento,
                  p_utente);

            IF retval = 1
            THEN
               EXIT;
            END IF;
         END LOOP;

         IF retval = 0
         THEN
            FOR id_messaggio_inside
               IN (SELECT id_documento_rif
                     FROM riferimenti rife
                    WHERE     rife.tipo_relazione IN ('PRINCIPALE')
                          AND id_documento = p_iddocumento)
            LOOP
               retval :=
                  ag_competenze_memo.lettura (
                     id_messaggio_inside.id_documento_rif,
                     p_utente);

               IF retval = 1
               THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         RETURN retval;
      END IF;

      IF inpartenza = 'N' AND statomemo = 'G'
      THEN
         BEGIN
            SELECT id_documento
              INTO iddocumentocollegato
              FROM riferimenti rife
             WHERE     rife.tipo_relazione = 'PRINCIPALE'
                   AND id_documento_rif = p_iddocumento;

            retval :=
               ag_competenze_memo.lettura (iddocumentocollegato, p_utente);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT id_documento
                    INTO iddocumentocollegato
                    FROM riferimenti rife
                   WHERE     rife.tipo_relazione = 'PROT_PEC'
                         AND id_documento_rif = p_iddocumento;

                  retval :=
                     ag_competenze_memo.lettura (iddocumentocollegato,
                                                 p_utente);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT id_documento_rif
                          INTO iddocumentocollegato
                          FROM riferimenti rife
                         WHERE     rife.tipo_relazione = 'PROT_PEC'
                               AND id_documento = p_iddocumento;

                        retval :=
                           ag_competenze_memo.lettura (iddocumentocollegato,
                                                       p_utente);
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           BEGIN
                              SELECT id_documento
                                INTO iddocumentocollegato
                                FROM riferimenti rife
                               WHERE     rife.tipo_relazione IN ('PROT_CONF',
                                                                 'PROT_AGG',
                                                                 'PROT_ANN',
                                                                 'PROT_ECC',
                                                                 'PROT_RIFE')
                                     AND id_documento_rif = p_iddocumento;

                              retval :=
                                 ag_competenze_protocollo.lettura (
                                    iddocumentocollegato,
                                    p_utente);
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 retval := 0;
                           END;
                     END;
               END;
         END;

         RETURN retval;
      END IF;

      IF inpartenza = 'N' AND statomemo = 'NP'
      THEN
         retval :=
            ag_competenze_documento.lettura (
               p_id_documento   => p_iddocumento,
               p_utente         => p_utente);

         IF retval = 0
         THEN
            FOR id_messaggio_inside
               IN (SELECT id_documento
                     FROM riferimenti rife
                    WHERE     rife.tipo_relazione IN ('PRINCIPALE')
                          AND id_documento_rif = p_iddocumento)
            LOOP
               retval :=
                  ag_competenze_memo.lettura (
                     id_messaggio_inside.id_documento,
                     p_utente);

               IF retval = 1
               THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         RETURN retval;
      END IF;

      IF inpartenza = 'N' AND statomemo IN ('DPS', 'DP')
      THEN
         retval :=
            ag_competenze_memo.verifica_privilegio_casella (p_iddocumento,
                                                            p_utente,
                                                            TRUNC (SYSDATE));

         IF NVL (retval, 0) = 0
         THEN
            retval :=
               ag_competenze_documento.lettura (
                  p_id_documento   => p_iddocumento,
                  p_utente         => p_utente);
         END IF;

         RETURN retval;
      END IF;

      --se si tratta di un memo in arrivo non compreso nei casi precedenti
      -- si guardano i diritti sulla casella destinataria
      IF inpartenza = 'N'
      THEN
         retval :=
            ag_competenze_memo.verifica_privilegio_casella (p_iddocumento,
                                                            p_utente);
         RETURN retval;
      END IF;

      RETURN retval;
   END lettura;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_CASELLA.
    DESCRIZIONE:  Verifica se un utente ha il privilegio di visualizzare i memo
                  arrivati ad una certa casella in una certa data.
   INPUT    p_idDocumento  varchar2: chiave identificativa del documento.
            p_utente       varchar2: utente che richiede di leggere il documento.
            p_data         datw:    data di riferimento
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
   Rev.  Data        Autore   Descrizione.
   000   02/01/2007  SC       Prima emissione.
   001   17/11/2014  MM       Aggiunta gestione della data.
   004   16/05/2018    MM     Gestione messaggio senza destinatari dell'ente
   ********************************************************************************/
   FUNCTION verifica_privilegio_casella (p_iddocumento    VARCHAR2,
                                         p_utente         VARCHAR2,
                                         p_data           DATE)
      RETURN NUMBER
   IS
      retval                 NUMBER := 0;
      dep_destinatari        CLOB;
      dep_destinatari_ente   VARCHAR2 (4000);
   BEGIN
      BEGIN
         SELECT    destinatari_clob
                || ','
                || destinatari_cc_clob
                || ','
                || destinatari_nascosti,
                destinatari || ',' || destinatari_conoscenza
           INTO dep_destinatari, dep_destinatari_ente
           FROM seg_memo_protocollo
          WHERE id_documento = p_iddocumento;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      retval :=
         ag_utilities.verifica_privilegio_casella (dep_destinatari,
                                                   p_utente,
                                                   p_data);

      IF dep_destinatari_ente = ','
      THEN
         dep_destinatari_ente := '';
      END IF;

      IF retval = 0 AND dep_destinatari_ente IS NULL
      THEN
         retval :=
            ag_utilities.verifica_privilegio_casella (dep_destinatari_ente,
                                                      p_utente,
                                                      p_data);
      END IF;

      RETURN retval;
   END;

   /*****************************************************************************
       NOME:        LETTURA.
       DESCRIZIONE: Un utente ha i diritti di vedere uno RAPPORTO se ha
    tale diritto sul protocollo collegato.
      INPUT  p_area varchar2
            p_modello varchar2
            p_codice_richiesta varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
      RITORNO:  1 se l'utente ha diritti, 0 altrimenti.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION lettura (p_area                VARCHAR2,
                     p_modello             VARCHAR2,
                     p_codice_richiesta    VARCHAR2,
                     p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   NUMBER;
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

   FUNCTION eliminazione (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval      NUMBER := 0;
      statomemo   VARCHAR2 (10);
   BEGIN
      statomemo := NVL (f_valore_campo (p_iddocumento, 'STATO_MEMO'), 'DG');

      IF statomemo IN ('DG', 'SC')
      THEN
         retval := verifica_privilegio_casella (p_iddocumento, p_utente);
      END IF;

      IF statomemo = 'NP'
      THEN
         retval :=
            ag_competenze_documento.eliminazione (p_iddocumento, p_utente);
      END IF;

      RETURN retval;
   END;
END ag_competenze_memo;
/
