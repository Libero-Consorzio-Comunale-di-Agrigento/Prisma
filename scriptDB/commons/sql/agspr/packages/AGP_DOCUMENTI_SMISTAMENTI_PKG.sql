--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_DOCUMENTI_SMISTAMENTI_PKG runOnChange:true stripComments:false
CREATE OR REPLACE PACKAGE AGP_DOCUMENTI_SMISTAMENTI_PKG
IS
   /******************************************************************************
    NOME:        AGP_DOCUMENTI_SMISTAMENTI_PKG
    DESCRIZIONE: Gestione tabella AGP_DOCUMENTI_SMISTAMENTI.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    16/02/2017    mmalferrari    Prima emissione.
    01    18/04/2019    mmalferrari   Create ins, calcola_unita, set_stato

   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.01';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   PROCEDURE ins (p_id_documento_esterno         NUMBER,
                  p_unita_trasmissione_progr     NUMBER,
                  p_unita_trasmissione_dal       DATE,
                  p_unita_trasmissione_ottica    VARCHAR2,
                  p_utente_trasmissione          VARCHAR2,
                  p_unita_smistamento_progr      NUMBER,
                  p_unita_smistamento_dal        DATE,
                  p_unita_smistamento_ottica     VARCHAR2,
                  p_utente_assegnante            VARCHAR2,
                  p_data_smistamento             DATE,
                  p_stato_smistamento            VARCHAR2,
                  p_tipo_smistamento             VARCHAR2,
                  p_utente_presa_in_carico       VARCHAR2,
                  p_data_presa_in_carico         DATE,
                  p_utente_esecuzione            VARCHAR2,
                  p_data_esecuzione              DATE,
                  p_utente_assegnatario          VARCHAR2,
                  p_data_assegnazione            DATE,
                  p_note                         VARCHAR2,
                  p_note_utente                  VARCHAR2,
                  p_id_padre                     NUMBER,
                  p_utente_upd                   VARCHAR2);

   PROCEDURE aggiorna (p_id_documento_esterno      NUMBER,
                       p_unita_trasmissione        VARCHAR2,
                       p_utente_trasmissione       VARCHAR2,
                       p_unita_smistamento         VARCHAR2,
                       p_data_smistamento          DATE,
                       p_stato_smistamento         VARCHAR2,
                       p_tipo_smistamento          VARCHAR2,
                       p_utente_presa_in_carico    VARCHAR2,
                       p_data_presa_in_carico      DATE,
                       p_utente_esecuzione         VARCHAR2,
                       p_data_esecuzione           DATE,
                       p_utente_assegnatario       VARCHAR2,
                       p_data_assegnazione         DATE,
                       p_note                      VARCHAR2,
                       p_note_utente               VARCHAR2,
                       p_id_esterno_padre          NUMBER,
                       p_utente_upd                VARCHAR2);

   PROCEDURE ins (p_id_documento_esterno      NUMBER,
                  p_unita_trasmissione        VARCHAR2,
                  p_utente_trasmissione       VARCHAR2,
                  p_unita_smistamento         VARCHAR2,
                  p_utente_assegnante         VARCHAR2,
                  p_data_smistamento          DATE,
                  p_stato_smistamento         VARCHAR2,
                  p_tipo_smistamento          VARCHAR2,
                  p_utente_presa_in_carico    VARCHAR2,
                  p_data_presa_in_carico      DATE,
                  p_utente_esecuzione         VARCHAR2,
                  p_data_esecuzione           DATE,
                  p_utente_assegnatario       VARCHAR2,
                  p_data_assegnazione         DATE,
                  p_note                      VARCHAR2,
                  p_note_utente               VARCHAR2,
                  p_id_esterno_padre          NUMBER,
                  p_utente_upd                VARCHAR2);

   FUNCTION is_possibile_presa_in_carico (p_id_smistamento    NUMBER,
                                          p_utente            VARCHAR2)
      RETURN NUMBER;

   PROCEDURE set_stato (p_id_documento_esterno    NUMBER,
                        p_stato                   VARCHAR2,
                        p_note                    VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_DOCUMENTI_SMISTAMENTI_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_DOCUMENTI_SMISTAMENTI_PKG
    DESCRIZIONEp_ Gestione tabella AGP_DOCUMENTI_SMISTAMENTI.
    ANNOTAZIONIp_ .
    REVISIONIp_   .
    Rev.  Data          Autore        Descrizione.
    000   16/02/2017    mmalferrari   Prima emissione.
    001   19/01/2018    mmalferrari   Modificata procedura aggiorna
    002   18/04/2019    mmalferrari   Create ins, calcola_unita, set_stato
    003   03/07/2019    mmalferrari   Modificato aggiorna
    004   12/02/2020    mmalferrari   Modificato aggiorna in modo da passare a
                                      calcola_unita come data riferimento la data
                                      dello smistamento invece che sysdate.
    005   24/02/2020    mmalferrari   Corretta set_stato
    006   11/09/2020    mmalferrari   Create prendi_in_carico ed esegui
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '006';

   --------------------------------------------------------------------------------
   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  p_ versione compatibilità del Package.
                 Secondo numerop_ revisione del Package specification.
                 Terzo numero  p_ revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------
   PROCEDURE calcola_unita (p_unita                             VARCHAR2,
                            p_data_rif                          DATE,
                            p_unita_smistamento_progr    IN OUT NUMBER,
                            p_unita_smistamento_dal      IN OUT DATE,
                            p_unita_smistamento_ottica   IN OUT VARCHAR2)
   IS
      d_data_rif   DATE := NVL (p_data_rif, SYSDATE);
   BEGIN
      SELECT progr_unita_organizzativa, dal, ottica
        INTO p_unita_smistamento_progr,
             p_unita_smistamento_dal,
             p_unita_smistamento_ottica
        FROM so4_unita_organizzative_pubb
       WHERE     ottica =
                    NVL (
                       p_unita_smistamento_ottica,
                       GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                          'SO_OTTICA_PROT',
                          1))
             AND codice_uo = p_unita
             AND d_data_rif BETWEEN dal AND NVL (al, TO_DATE (3333333, 'j'));
   EXCEPTION
      WHEN OTHERS
      THEN
         p_unita_smistamento_progr := NULL;
         p_unita_smistamento_dal := NULL;
         p_unita_smistamento_ottica := NULL;
   END;

   --------------------------------------------------------------------------------
   PROCEDURE aggiorna (p_id_documento_esterno      NUMBER,
                       p_unita_trasmissione        VARCHAR2,
                       p_utente_trasmissione       VARCHAR2,
                       p_unita_smistamento         VARCHAR2,
                       p_data_smistamento          DATE,
                       p_stato_smistamento         VARCHAR2,
                       p_tipo_smistamento          VARCHAR2,
                       p_utente_presa_in_carico    VARCHAR2,
                       p_data_presa_in_carico      DATE,
                       p_utente_esecuzione         VARCHAR2,
                       p_data_esecuzione           DATE,
                       p_utente_assegnatario       VARCHAR2,
                       p_data_assegnazione         DATE,
                       p_note                      VARCHAR2,
                       p_note_utente               VARCHAR2,
                       p_id_esterno_padre          NUMBER,
                       p_utente_upd                VARCHAR2)
   IS
      d_note_utente                 VARCHAR2 (4000) := p_note_utente;
      d_unita_smistamento_dal       DATE;
      d_unita_smistamento_ottica    VARCHAR2 (4000);
      d_unita_smistamento_progr     NUMBER;
      d_unita_trasmissione_dal      DATE;
      d_unita_trasmissione_ottica   VARCHAR2 (4000);
      d_unita_trasmissione_progr    NUMBER;
      d_utente_assegnante           VARCHAR2 (4000);
      d_version                     NUMBER := 0;
      d_esiste                      NUMBER;
      d_continua                    BOOLEAN := TRUE;
      d_id_doc_padre                NUMBER;
      d_id_ente                     NUMBER;
   BEGIN
      --raise_application_error(-20999,'AGP_DOCUMENTI_SMISTAMENTI_PKG.AGGIORNA ('|| P_ID_DOCUMENTO_ESTERNO||', '||P_UNITA_TRASMISSIONE||', '||P_UTENTE_TRASMISSIONE||', '||P_UNITA_SMISTAMENTO||', '||P_DATA_SMISTAMENTO||', '||P_STATO_SMISTAMENTO||', '||P_TIPO_SMISTAMENTO||', '||P_UTENTE_PRESA_IN_CARICO||', '||P_DATA_PRESA_IN_CARICO||', '||P_UTENTE_ESECUZIONE||', '||P_DATA_ESECUZIONE||', '||P_UTENTE_ASSEGNATARIO||', '||P_DATA_ASSEGNAZIONE||', '||P_NOTE||', '||P_NOTE_UTENTE||', '||P_ID_ESTERNO_PADRE||', '||P_UTENTE_UPD ||');');

      BEGIN
         SELECT id_documento, id_ente
           INTO d_id_doc_padre, d_id_ente
           FROM gdo_documenti
          WHERE id_documento_esterno = p_id_esterno_padre;

         IF AGP_PROTOCOLLI_PKG.is_protocollo_agspr (p_id_esterno_padre) <> 1
         THEN
            d_continua := FALSE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_continua := FALSE;
      END;

      IF d_continua
      THEN
         IF p_utente_assegnatario IS NOT NULL
         THEN
            d_utente_assegnante := p_utente_upd;
         END IF;

         d_unita_smistamento_ottica :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('SO_OTTICA_PROT',
                                                   d_id_ente);
         calcola_unita (p_unita_smistamento,
                        p_data_smistamento,
                        d_unita_smistamento_progr,
                        d_unita_smistamento_dal,
                        d_unita_smistamento_ottica);

         d_unita_trasmissione_ottica :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('SO_OTTICA_PROT',
                                                   d_id_ente);
         calcola_unita (p_unita_trasmissione,
                        p_data_smistamento,
                        d_unita_trasmissione_progr,
                        d_unita_trasmissione_dal,
                        d_unita_trasmissione_ottica);

         BEGIN
            SELECT 1
              INTO d_esiste
              FROM agp_documenti_smistamenti
             WHERE id_documento_esterno = p_id_documento_esterno;

            SELECT MAX (version) + 1
              INTO d_version
              FROM agp_documenti_smistamenti
             WHERE id_documento_esterno = p_id_documento_esterno;

            UPDATE agp_documenti_smistamenti
               SET data_assegnazione = p_data_assegnazione,
                   data_esecuzione = p_data_esecuzione,
                   data_presa_in_carico = p_data_presa_in_carico,
                   data_smistamento = p_data_smistamento,
                   data_upd = SYSDATE,
                   note = p_note,
                   note_utente = d_note_utente,
                   stato_smistamento =
                      DECODE (p_stato_smistamento,
                              'N', 'CREATO',
                              'R', 'DA_RICEVERE',
                              'C', 'IN_CARICO',
                              'E', 'ESEGUITO',
                              'F', 'STORICO'),
                   unita_smistamento_dal = d_unita_smistamento_dal,
                   unita_smistamento_ottica = d_unita_smistamento_ottica,
                   unita_smistamento_progr = d_unita_smistamento_progr,
                   unita_trasmissione_dal = d_unita_trasmissione_dal,
                   unita_trasmissione_ottica = d_unita_trasmissione_ottica,
                   unita_trasmissione_progr = d_unita_trasmissione_progr,
                   utente_assegnante = d_utente_assegnante,
                   utente_assegnatario = p_utente_assegnatario,
                   utente_esecuzione = p_utente_esecuzione,
                   utente_presa_in_carico = p_utente_presa_in_carico,
                   utente_trasmissione = p_utente_trasmissione,
                   utente_upd = p_utente_upd,
                   version = d_version
             WHERE id_documento_esterno = p_id_documento_esterno;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DECLARE
                  d_stato_smistamento   VARCHAR2 (100);
               BEGIN
                  SELECT DECODE (p_stato_smistamento,
                                 'N', 'CREATO',
                                 'R', 'DA_RICEVERE',
                                 'C', 'IN_CARICO',
                                 'E', 'ESEGUITO',
                                 'F', 'STORICO')
                    INTO d_stato_smistamento
                    FROM DUAL;

                  ins (p_id_documento_esterno,
                       d_unita_trasmissione_progr,
                       d_unita_trasmissione_dal,
                       d_unita_trasmissione_ottica,
                       p_utente_trasmissione,
                       d_unita_smistamento_progr,
                       d_unita_smistamento_dal,
                       d_unita_smistamento_ottica,
                       d_utente_assegnante,
                       p_data_smistamento,
                       d_stato_smistamento,
                       p_tipo_smistamento,
                       p_utente_presa_in_carico,
                       p_data_presa_in_carico,
                       p_utente_esecuzione,
                       p_data_esecuzione,
                       p_utente_assegnatario,
                       p_data_assegnazione,
                       p_note,
                       d_note_utente,
                       d_id_doc_padre,
                       p_utente_upd);
               END;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;
   END;

   --------------------------------------------------------------------------------
   PROCEDURE ins (p_id_documento_esterno         NUMBER,
                  p_unita_trasmissione_progr     NUMBER,
                  p_unita_trasmissione_dal       DATE,
                  p_unita_trasmissione_ottica    VARCHAR2,
                  p_utente_trasmissione          VARCHAR2,
                  p_unita_smistamento_progr      NUMBER,
                  p_unita_smistamento_dal        DATE,
                  p_unita_smistamento_ottica     VARCHAR2,
                  p_utente_assegnante            VARCHAR2,
                  p_data_smistamento             DATE,
                  p_stato_smistamento            VARCHAR2,
                  p_tipo_smistamento             VARCHAR2,
                  p_utente_presa_in_carico       VARCHAR2,
                  p_data_presa_in_carico         DATE,
                  p_utente_esecuzione            VARCHAR2,
                  p_data_esecuzione              DATE,
                  p_utente_assegnatario          VARCHAR2,
                  p_data_assegnazione            DATE,
                  p_note                         VARCHAR2,
                  p_note_utente                  VARCHAR2,
                  p_id_padre                     NUMBER,
                  p_utente_upd                   VARCHAR2)
   IS
      d_new_id   NUMBER;
   BEGIN
      SELECT HIBERNATE_SEQUENCE.NEXTVAL INTO d_new_id FROM DUAL;

      INSERT INTO AGP_DOCUMENTI_SMISTAMENTI (ID_DOCUMENTO_SMISTAMENTO,
                                             ID_DOCUMENTO,
                                             UNITA_TRASMISSIONE_PROGR,
                                             UNITA_TRASMISSIONE_DAL,
                                             UNITA_TRASMISSIONE_OTTICA,
                                             UTENTE_TRASMISSIONE,
                                             UNITA_SMISTAMENTO_PROGR,
                                             UNITA_SMISTAMENTO_DAL,
                                             UNITA_SMISTAMENTO_OTTICA,
                                             DATA_SMISTAMENTO,
                                             STATO_SMISTAMENTO,
                                             TIPO_SMISTAMENTO,
                                             UTENTE_PRESA_IN_CARICO,
                                             DATA_PRESA_IN_CARICO,
                                             UTENTE_ESECUZIONE,
                                             DATA_ESECUZIONE,
                                             UTENTE_ASSEGNANTE,
                                             UTENTE_ASSEGNATARIO,
                                             DATA_ASSEGNAZIONE,
                                             NOTE,
                                             NOTE_UTENTE,
                                             VERSION,
                                             VALIDO,
                                             UTENTE_INS,
                                             DATA_INS,
                                             UTENTE_UPD,
                                             DATA_UPD,
                                             ID_DOCUMENTO_ESTERNO)
           VALUES (d_new_id,
                   p_id_padre,
                   p_unita_trasmissione_progr,
                   p_unita_trasmissione_dal,
                   p_unita_trasmissione_ottica,
                   p_utente_trasmissione,
                   p_unita_smistamento_progr,
                   p_unita_smistamento_dal,
                   p_unita_smistamento_ottica,
                   p_data_smistamento,
                   p_stato_smistamento,
                   p_tipo_smistamento,
                   p_utente_presa_in_carico,
                   p_data_presa_in_carico,
                   p_utente_esecuzione,
                   p_data_esecuzione,
                   p_utente_assegnante,
                   p_utente_assegnatario,
                   p_data_assegnazione,
                   p_note,
                   p_note_utente,
                   0,
                   'Y',
                   p_utente_upd,
                   SYSDATE,
                   p_utente_upd,
                   SYSDATE,
                   p_id_documento_esterno);
   END;

   PROCEDURE ins (p_id_documento_esterno      NUMBER,
                  p_unita_trasmissione        VARCHAR2,
                  p_utente_trasmissione       VARCHAR2,
                  p_unita_smistamento         VARCHAR2,
                  p_utente_assegnante         VARCHAR2,
                  p_data_smistamento          DATE,
                  p_stato_smistamento         VARCHAR2,
                  p_tipo_smistamento          VARCHAR2,
                  p_utente_presa_in_carico    VARCHAR2,
                  p_data_presa_in_carico      DATE,
                  p_utente_esecuzione         VARCHAR2,
                  p_data_esecuzione           DATE,
                  p_utente_assegnatario       VARCHAR2,
                  p_data_assegnazione         DATE,
                  p_note                      VARCHAR2,
                  p_note_utente               VARCHAR2,
                  p_id_esterno_padre          NUMBER,
                  p_utente_upd                VARCHAR2)
   IS
      d_continua                    BOOLEAN;
      d_id_doc_padre                NUMBER;
      d_id_ente                     NUMBER;
      d_utente_assegnante           VARCHAR2 (100);
      d_stato_smistamento           VARCHAR2 (100);
      d_note_utente                 VARCHAR2 (4000) := p_note_utente;
      d_unita_smistamento_dal       DATE;
      d_unita_smistamento_ottica    VARCHAR2 (4000);
      d_unita_smistamento_progr     NUMBER;
      d_unita_trasmissione_dal      DATE;
      d_unita_trasmissione_ottica   VARCHAR2 (4000);
      d_unita_trasmissione_progr    NUMBER;
   BEGIN
      BEGIN
         SELECT id_documento, id_ente
           INTO d_id_doc_padre, d_id_ente
           FROM gdo_documenti
          WHERE id_documento_esterno = p_id_esterno_padre;

         IF AGP_PROTOCOLLI_PKG.is_documento_agspr (p_id_esterno_padre) <> 1
         THEN
            d_continua := FALSE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_continua := FALSE;
      END;

      IF d_continua
      THEN
         IF p_utente_assegnatario IS NOT NULL
         THEN
            d_utente_assegnante := p_utente_upd;
         END IF;

         d_unita_smistamento_ottica :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('SO_OTTICA_PROT',
                                                   d_id_ente);
         calcola_unita (p_unita_smistamento,
                        SYSDATE,
                        d_unita_smistamento_progr,
                        d_unita_smistamento_dal,
                        d_unita_smistamento_ottica);

         d_unita_trasmissione_ottica :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('SO_OTTICA_PROT',
                                                   d_id_ente);
         calcola_unita (p_unita_trasmissione,
                        SYSDATE,
                        d_unita_trasmissione_progr,
                        d_unita_trasmissione_dal,
                        d_unita_trasmissione_ottica);


         SELECT DECODE (p_stato_smistamento,
                        'N', 'CREATO',
                        'R', 'DA_RICEVERE',
                        'C', 'IN_CARICO',
                        'E', 'ESEGUITO',
                        'F', 'STORICO')
           INTO d_stato_smistamento
           FROM DUAL;

         ins (p_id_documento_esterno,
              d_unita_trasmissione_progr,
              d_unita_trasmissione_dal,
              d_unita_trasmissione_ottica,
              p_utente_trasmissione,
              d_unita_smistamento_progr,
              d_unita_smistamento_dal,
              d_unita_smistamento_ottica,
              d_utente_assegnante,
              p_data_smistamento,
              d_stato_smistamento,
              p_tipo_smistamento,
              p_utente_presa_in_carico,
              p_data_presa_in_carico,
              p_utente_esecuzione,
              p_data_esecuzione,
              p_utente_assegnatario,
              p_data_assegnazione,
              p_note,
              d_note_utente,
              d_id_doc_padre,
              p_utente_upd);
      END IF;
   END;

   FUNCTION is_possibile_presa_in_carico (p_id_smistamento    NUMBER,
                                          p_utente            VARCHAR2)
      RETURN NUMBER
   IS
      d_ret   NUMBER := 0;
   BEGIN
      SELECT DISTINCT 1
        INTO d_ret
        FROM gdo_documenti d,
             agp_documenti_smistamenti s,
             AG_PRIV_UTENTE_TMP pvs,
             AG_PRIV_UTENTE_TMP pcarico
       WHERE     s.id_documento_smistamento = p_id_smistamento
             AND d.id_documento = s.id_documento
             AND stato_smistamento = 'DA_RICEVERE'
             AND s.valido = 'Y'
             AND pvs.utente = p_utente
             AND pvs.al IS NULL
             AND pvs.privilegio =
                    'VS' || DECODE (NVL (d.riservato, 'N'), 'Y', 'R', '')
             AND pvs.unita IN (SELECT CODICE
                                 FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB
                                WHERE     PROGR = S.UNITA_SMISTAMENTO_PROGR
                                      AND DAL = S.UNITA_SMISTAMENTO_DAL
                                      AND OTTICA = S.UNITA_SMISTAMENTO_OTTICA)
             AND pcarico.utente = p_utente
             AND pcarico.al IS NULL
             AND pcarico.privilegio = 'CARICO'
             AND pcarico.unita IN (SELECT CODICE
                                     FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB
                                    WHERE     PROGR =
                                                 S.UNITA_SMISTAMENTO_PROGR
                                          AND DAL = S.UNITA_SMISTAMENTO_DAL
                                          AND OTTICA =
                                                 S.UNITA_SMISTAMENTO_OTTICA);

      RETURN d_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   PROCEDURE set_stato (p_id_documento_esterno    NUMBER,
                        p_stato                   VARCHAR2,
                        p_note                    VARCHAR2)
   IS
      d_stato   VARCHAR2 (100);
   BEGIN
      UPDATE agp_documenti_smistamenti
         SET stato_smistamento =
                DECODE (p_stato,
                        'N', 'CREATO',
                        'R', 'DA_RICEVERE',
                        'C', 'IN_CARICO',
                        'E', 'ESEGUITO',
                        'F', 'STORICO'),
             note = p_note
       WHERE id_documento_esterno = p_id_documento_esterno;
   END;

   PROCEDURE prendi_in_carico (p_id_documento_esterno    NUMBER,
                               p_utente                  VARCHAR2,
                               p_data                    DATE)
   IS
   BEGIN
      UPDATE agp_documenti_smistamenti
         SET stato_smistamento = 'IN_CARICO',
             data_presa_in_carico = p_data,
             utente_presa_in_carico = p_utente
       WHERE id_documento_esterno = p_id_documento_esterno;
   END;

   PROCEDURE esegui (p_id_documento_esterno    NUMBER,
                     p_utente                  VARCHAR2,
                     p_data                    DATE)
   IS
   BEGIN
      UPDATE agp_documenti_smistamenti
         SET stato_smistamento = 'ESEGUITO',
             data_esecuzione = p_data,
             utente_esecuzione = p_utente
       WHERE id_documento_esterno = p_id_documento_esterno;
   END;
END;
/
