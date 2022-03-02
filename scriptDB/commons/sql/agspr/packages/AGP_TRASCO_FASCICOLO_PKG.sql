--liquibase formatted sql
--changeset mmalferrari:AGSPR_PACKAGE_AGP_TRASCO_FASCICOLO_PKG runOnChange:true stripComments:false
CREATE OR REPLACE PACKAGE AGP_TRASCO_FASCICOLO_PKG
IS
   /******************************************************************************
    NOME:        AGP_TRASCO_FASCICOLO_PKG
    DESCRIZIONE: Gestione TRASCO da GDM.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    28/08/2020    svalenti       creazione.
    01    07/09/2020    svalenti       in caso di esistenza fascicolo, aggiorno
                                       ugualmente l'ultimo_numero_sub per non
                                       perdere l'allineamento.
    02    08/09/2020    svalenti       modificata select per verifica esistenza
                                       fascicolo.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.02';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION trasco
      RETURN NUMBER;

   FUNCTION elaborazione_documenti
      RETURN NUMBER;

   FUNCTION elaborazione_collegamenti
      RETURN NUMBER;

   FUNCTION elaborazione_fascicolo_padre
      RETURN NUMBER;

   FUNCTION crea_documento (p_id_documento_esterno    NUMBER,
                            p_id_ente                 VARCHAR2,
                            p_utente_ins              VARCHAR2,
                            p_utente_upd              VARCHAR2,
                            p_data_ins                DATE,
                            p_data_upd                DATE,
                            p_riservato               VARCHAR2,
                            p_id_revisione            NUMBER)
      RETURN NUMBER;


   FUNCTION crea_documento_soggetto (p_id_documento     NUMBER,
                                     p_tipo_soggetto    VARCHAR2,
                                     p_utente           VARCHAR2,
                                     p_progr_uo         NUMBER,
                                     p_dal_uo           DATE,
                                     p_ottica_uo        VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_documento_competenza (p_id_documento    NUMBER,
                                       p_utente          VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_documento_dati_scarto (p_id_documento       NUMBER,
                                        p_stato_scarto       VARCHAR2,
                                        p_data_scarto        DATE,
                                        p_nulla_osta         VARCHAR2,
                                        p_data_nulla_osta    DATE,
                                        p_utente             VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_smistamenti (p_id_documento NUMBER, p_idrif VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_TRASCO_FASCICOLO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_TRASCO_FASCICOLO_PKG
    DESCRIZIONEp_ Gestione TRASCO da GDM.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.    Data            Autore        Descrizione.
    000     28/08/2020      svalenti      creazione.
    001     07/09/2020      svalenti      in caso di esistenza fascicolo, aggiorno
                                          ugualmente l'ultimo_numero_sub per non
                                          perdere l'allineamento.
    002     08/09/2020      svalenti      modificata select per verifica
                                          esistenza fascicolo.
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '002';

   -- unita di default in caso di assenza
   d_unita_progr_default       NUMBER;
   d_unita_dal_default         DATE;
   d_unita_ottica_default      VARCHAR2 (255);

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

   FUNCTION crea_revinfo (p_data TIMESTAMP, p_rev NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
   BEGIN
      RETURN revinfo_pkg.crea_revinfo (p_data, p_rev);
   END;

   PROCEDURE del_revinfo (p_rev NUMBER)
   IS
   BEGIN
      revinfo_pkg.del_revinfo (p_rev);
   END;

   FUNCTION trasco
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      BEGIN
         d_return := elaborazione_documenti;

         d_return := elaborazione_fascicolo_padre;

         d_return := elaborazione_collegamenti;
      END;

      d_return := 1;
      RETURN d_return;
   END;


   FUNCTION elaborazione_documenti
      RETURN NUMBER
   IS
      d_return                       NUMBER;
      esistenza_fascicolo            NUMBER;
      p_id_documento                 NUMBER;
      p_id_doc_soggetto_creazione    NUMBER;
      p_id_doc_soggetto_competenza   NUMBER;
      p_id_doc_competenza            NUMBER;
      p_id_doc_dati_scarto           NUMBER;
      creazione_smistamenti          NUMBER;
      p_unita_progr_cre              NUMBER;
      p_unita_dal_cre                DATE;
      p_unita_ottica_cre             VARCHAR2 (200);
      p_unita_progr_comp             NUMBER;
      p_unita_dal_comp               DATE;
      p_unita_ottica_comp            VARCHAR2 (200);
      d_idrif                        VARCHAR2 (200);
      p_id_revisione                 NUMBER;
   BEGIN
      BEGIN

         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TC DISABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TB DISABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER AGS_FASCICOLI_TAIU DISABLE';

         FOR fascicolo
            IN (  SELECT ID_DOCUMENTO_ESTERNO,
                         ID_CLASSIFICAZIONE,
                         ANNO,
                         NUMERO,
                         ANNO_NUMERO,
                         NVL (OGGETTO, '-') OGGETTO,
                         SUBSTR (ANNO_NUMERO || ' - ' || OGGETTO, 0, 255) NOME,
                         DECODE (NUMERO, NULL, 'Y', 'N') NUMERO_PROSSIMO_ANNO,
                         NUMERO_ORD,
                         RESPONSABILE,
                         RISERVATO,
                         DIGITALE,
                         ANNO_ARCHIVIAZIONE,
                         NOTE,
                         TOPOGRAFIA,
                         DATA_APERTURA DATA_CREAZIONE,
                         DATA_APERTURA,
                         DATA_CHIUSURA,
                         IDRIF,
                         STATO,
                         DATA_STATO,
                         ULTIMO_NUMERO_SUB,
                         NVL (SUB, 0) SUB,
                         DATA_ARCHIVIAZIONE,
                         SYSDATE DATA_ULTIMA_OPERAZIONE,
                         STATO_SCARTO,
                         DATA_STATO_SCARTO,
                         NUMERO_NULLA_OSTA,
                         DATA_NULLA_OSTA,
                         NVL (UTENTE_INS, 'RPI') UTENTE_INS,
                         NVL (UTENTE_UPD, 'RPI') UTENTE_UPD,
                         ID_ENTE,
                         NVL (DATA_INS, DATA_UPD) DATA_INS,
                         DATA_UPD,
                         UNITA_COMPETENZA_DAL,
                         UNITA_COMPETENZA_OTTICA,
                         UNITA_COMPETENZA_PROGR,
                         UNITA_CREAZIONE_DAL,
                         UNITA_CREAZIONE_OTTICA,
                         UNITA_CREAZIONE_PROGR,
                         UFFICIO_COMPETENZA,
                         NVL (UFFICIO_CREAZIONE, UFFICIO_COMPETENZA)
                            UFFICIO_CREAZIONE
                    FROM ags_fascicoli_trasco_view
                 ORDER BY anno DESC, numero ASC)
         LOOP
            -- controllo se già il fascicolo è stato inserito
            SELECT COUNT (1)
              INTO esistenza_fascicolo
              FROM ags_fascicoli
             WHERE     id_classificazione = fascicolo.ID_CLASSIFICAZIONE
             and anno=fascicolo.ANNO and numero=fascicolo.NUMERO;

            DBMS_OUTPUT.PUT_LINE (
               'esistenza_fascicolo: ' || esistenza_fascicolo);

            IF esistenza_fascicolo = 0
            THEN

               -- prelevo idrif direttamente da GDM
               BEGIN
                  SELECT idrif
                    INTO d_idrif
                    FROM gdm_fascicoli
                   WHERE id_documento = fascicolo.ID_DOCUMENTO_ESTERNO;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     d_idrif := fascicolo.IDRIF;
               END;

               p_id_revisione := crea_revinfo (SYSTIMESTAMP);

               DBMS_OUTPUT.PUT_LINE ('creo il documento '|| fascicolo.ID_DOCUMENTO_ESTERNO||' su AGSPR');
               p_id_documento :=
                  crea_documento (fascicolo.ID_DOCUMENTO_ESTERNO,
                                  fascicolo.ID_ENTE,
                                  fascicolo.UTENTE_INS,
                                  fascicolo.UTENTE_UPD,
                                  fascicolo.DATA_INS,
                                  fascicolo.DATA_UPD,
                                  fascicolo.RISERVATO,
                                  p_id_revisione);

               DBMS_OUTPUT.PUT_LINE (
                  'creo il documento soggetto UO_CREAZIONE');

               BEGIN
                  SELECT unita_cre.PROGR, unita_cre.DAL, unita_cre.OTTICA
                    INTO p_unita_progr_cre,
                         p_unita_dal_cre,
                         p_unita_ottica_cre
                    FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB unita_cre,
                         ags_fascicoli_trasco_view ft
                   WHERE     ft.id_documento_esterno =
                                fascicolo.ID_DOCUMENTO_ESTERNO
                         AND unita_cre.CODICE(+) = ft.ufficio_creazione
                         AND NVL (ft.data_creazione, ft.data_apertura) BETWEEN unita_cre.dal
                                                                           AND NVL (
                                                                                  unita_cre.al,
                                                                                  TO_DATE (
                                                                                     3333333,
                                                                                     'j'))
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_unita_progr_cre := d_unita_progr_default;
                     p_unita_dal_cre := d_unita_dal_default;
                     p_unita_ottica_cre := d_unita_ottica_default;
               END;

               p_id_doc_soggetto_creazione :=
                  crea_documento_soggetto (p_id_documento,
                                           'UO_CREAZIONE',
                                           NULL,
                                           p_unita_progr_cre,
                                           p_unita_dal_cre,
                                           p_unita_ottica_cre);


               DBMS_OUTPUT.PUT_LINE (
                  'creo il documento soggetto UO_COMPETENZA');

               BEGIN
                  SELECT unita_comp.PROGR, unita_comp.DAL, unita_comp.OTTICA
                    INTO p_unita_progr_comp,
                         p_unita_dal_comp,
                         p_unita_ottica_comp
                    FROM SO4_V_UNITA_ORGANIZZATIVE_PUBB unita_comp,
                         ags_fascicoli_trasco_view ft
                   WHERE     ft.id_documento_esterno =
                                fascicolo.ID_DOCUMENTO_ESTERNO
                         AND unita_comp.CODICE(+) = ft.ufficio_competenza
                         AND NVL (ft.data_creazione, ft.data_apertura) BETWEEN unita_comp.dal
                                                                           AND NVL (
                                                                                  unita_comp.al,
                                                                                  TO_DATE (
                                                                                     3333333,
                                                                                     'j'))
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_unita_progr_comp := d_unita_progr_default;
                     p_unita_dal_comp := d_unita_dal_default;
                     p_unita_ottica_comp := d_unita_ottica_default;
               END;

               p_id_doc_soggetto_competenza :=
                  crea_documento_soggetto (p_id_documento,
                                           'UO_COMPETENZA',
                                           NULL,
                                           p_unita_progr_comp,
                                           p_unita_dal_comp,
                                           p_unita_ottica_comp);


               DBMS_OUTPUT.PUT_LINE ('creo i documenti competenza');
               p_id_doc_competenza :=
                  crea_documento_competenza (p_id_documento,
                                             fascicolo.UTENTE_INS);


               DBMS_OUTPUT.PUT_LINE ('creo il documento dati scarto');
               p_id_doc_dati_scarto :=
                  crea_documento_dati_scarto (p_id_documento,
                                              fascicolo.STATO_SCARTO,
                                              fascicolo.DATA_STATO_SCARTO,
                                              fascicolo.NUMERO_NULLA_OSTA,
                                              fascicolo.DATA_NULLA_OSTA,
                                              fascicolo.UTENTE_INS);


               DBMS_OUTPUT.PUT_LINE ('creo i documenti smistamenti');
               creazione_smistamenti :=
                  crea_smistamenti (p_id_documento, d_idrif);


               DBMS_OUTPUT.PUT_LINE ('creo il fascicolo');

               INSERT INTO AGS_FASCICOLI (ANNO,
                                          ANNO_ARCHIVIAZIONE,
                                          ANNO_NUMERO,
                                          DATA_APERTURA,
                                          DATA_ARCHIVIAZIONE,
                                          DATA_CHIUSURA,
                                          DATA_CREAZIONE,
                                          DATA_STATO,
                                          DATA_ULTIMA_OPERAZIONE,
                                          DIGITALE,
                                          ID_CLASSIFICAZIONE,
                                          ID_DOCUMENTO,
                                          ID_DOCUMENTO_DATI_SCARTO,
                                          IDRIF,
                                          NOME,
                                          NOTE,
                                          NUMERO,
                                          NUMERO_ORD,
                                          NUMERO_PROSSIMO_ANNO,
                                          OGGETTO,
                                          RESPONSABILE,
                                          RISERVATO,
                                          STATO_FASCICOLO,
                                          SUB,
                                          TOPOGRAFIA,
                                          ULTIMO_NUMERO_SUB)
                       VALUES (
                                 fascicolo.ANNO,
                                 fascicolo.ANNO_ARCHIVIAZIONE,
                                 fascicolo.ANNO_NUMERO,
                                 fascicolo.DATA_APERTURA,
                                 fascicolo.DATA_ARCHIVIAZIONE,
                                 fascicolo.DATA_CHIUSURA,
                                 fascicolo.DATA_CREAZIONE,
                                 fascicolo.DATA_STATO,
                                 fascicolo.DATA_ULTIMA_OPERAZIONE,
                                 NVL (fascicolo.DIGITALE, 'N'),
                                 fascicolo.ID_CLASSIFICAZIONE,
                                 p_id_documento,
                                 p_id_doc_dati_scarto,
                                 fascicolo.IDRIF,
                                 fascicolo.NOME,
                                 fascicolo.NOTE,
                                 fascicolo.NUMERO,
                                 fascicolo.NUMERO_ORD,
                                 fascicolo.NUMERO_PROSSIMO_ANNO,
                                 fascicolo.OGGETTO,
                                 fascicolo.RESPONSABILE,
                                 fascicolo.RISERVATO,
                                 DECODE (NVL (fascicolo.STATO, 1),
                                         1, 'CORRENTE',
                                         2, 'DEPOSITO',
                                         3, 'STORICO'),
                                 fascicolo.SUB,
                                 fascicolo.TOPOGRAFIA,
                                 fascicolo.ULTIMO_NUMERO_SUB);

               --  p_id_revisione :=  crea_revinfo (SYSTIMESTAMP);


               INSERT INTO AGS_FASCICOLI_LOG (ANNO,
                    ANNO_MOD,
                    ANNO_ARCHIVIAZIONE,
                    ANNO_ARCHIVIAZIONE_MOD,
                    ANNO_NUMERO,
                    ANNO_NUMERO_MOD,
                    CLASSIFICAZIONE,
                    CLASSIFICAZIONE_MOD,
                    DATA_APERTURA,
                    DATA_APERTURA_MOD,
                    DATA_ARCHIVIAZIONE,
                    DATA_ARCHIVIAZIONE_MOD,
                    DATA_CHIUSURA,
                    DATA_CHIUSURA_MOD,
                    DATA_CREAZIONE,
                    DATA_CREAZIONE_MOD,
                    DATA_STATO,
                    DATA_STATO_MOD,
                    DATA_ULTIMA_OPERAZIONE,
                    DATA_ULTIMA_OPERAZIONE_MOD,
                    DATI_SCARTO_MOD,
                    DESCRIZIONE_SCARTO,
                    DESCRIZIONE_SCARTO_MOD,
                    DIGITALE,
                    DIGITALE_MOD,
                    ID_CLASSIFICAZIONE,
                    ID_CLASSIFICAZIONE_MOD,
                    ID_DOCUMENTO,
                    ID_DOCUMENTO_DATI_SCARTO,
                    ID_FASCICOLO_PADRE,
                    ID_FASCICOLO_PADRE_MOD,
                    IDRIF,
                    IDRIF_MOD,
                    MOVIMENTO,
                    MOVIMENTO_MOD,
                    NOME,
                    NOME_MOD,
                    NOTE,
                    NOTE_MOD,
                    NUMERO,
                    NUMERO_MOD,
                    NUMERO_ORD,
                    NUMERO_ORD_MOD,
                    NUMERO_PROSSIMO_ANNO,
                    NUMERO_PROSSIMO_ANNO_MOD,
                    OGGETTO,
                    OGGETTO_MOD,
                    OSSERVAZIONI_SCARTO,
                    OSSERVAZIONI_SCARTO_MOD,
                    PESO_SCARTO,
                    PESO_SCARTO_MOD,
                    PEZZI_SCARTO,
                    PEZZI_SCARTO_MOD,
                    RESPONSABILE,
                    RESPONSABILE_MOD,
                    REV,
                    RISERVATO,
                    RISERVATO_MOD,
                    STATO_FASCICOLO,
                    STATO_FASCICOLO_MOD,
                    SUB,
                    SUB_MOD,
                    TOPOGRAFIA,
                    TOPOGRAFIA_MOD,
                    UBICAZIONE_SCARTO,
                    UBICAZIONE_SCARTO_MOD,
                    ULTIMO_NUMERO_SUB,
                    ULTIMO_NUMERO_SUB_MOD
            )
                       VALUES (
                    fascicolo.ANNO,
                    0,
                    fascicolo.ANNO_ARCHIVIAZIONE,
                    0,
                    fascicolo.ANNO_NUMERO,
                    0,
                   NULL,
                    0,
                    fascicolo.DATA_APERTURA,
                    0,
                    fascicolo.DATA_ARCHIVIAZIONE,
                    0,
                    fascicolo.DATA_CHIUSURA,
                    0,
                    fascicolo.DATA_CREAZIONE,
                    0,
                    fascicolo.DATA_STATO,
                    0,
                    fascicolo.DATA_ULTIMA_OPERAZIONE,
                    0,
                    0,
                    NULL,
                    0,
                    NVL(fascicolo.DIGITALE, 'N'),
                    0,
                    fascicolo.ID_CLASSIFICAZIONE,
                    0,
                    p_id_documento,
                    NULL,
                    NULL,
                    0,
                    fascicolo.IDRIF,
                    0,
                    NULL,
                    0,
                    fascicolo.NOME,
                    0,
                    fascicolo.NOTE,
                    0,
                    fascicolo.NUMERO,
                    0,
                    fascicolo.NUMERO_ORD,
                    0,
                    fascicolo.NUMERO_PROSSIMO_ANNO,
                    0,
                    fascicolo.OGGETTO,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    NULL,
                    0,
                    fascicolo.RESPONSABILE,
                    0,
                    p_id_revisione,
                    fascicolo.RISERVATO,
                    0,
                    DECODE (NVL (fascicolo.STATO, 1),1, 'CORRENTE',2, 'DEPOSITO',3, 'STORICO'),
                    0,
                    fascicolo.SUB,
                    0,
                    fascicolo.TOPOGRAFIA,
                    0,
                    NULL,
                    0,
                    fascicolo.ULTIMO_NUMERO_SUB,
                    0
                                 );
           ELSE

           update ags_fascicoli
           set ultimo_numero_sub =   fascicolo.ULTIMO_NUMERO_SUB
           WHERE     id_documento = -fascicolo.ID_DOCUMENTO_ESTERNO;

            END IF;



            DBMS_OUTPUT.PUT_LINE ('-----------------------');
            COMMIT;
         END LOOP;

         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TC ENABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TB ENABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER AGS_FASCICOLI_TAIU ENABLE';

      END;



      d_return := 1;
      RETURN d_return;
   END;


   FUNCTION elaborazione_fascicolo_padre
      RETURN NUMBER
   IS
      d_return                       NUMBER;
      p_id_documento_esterno_padre   NUMBER;
      p_id_documento_padre           NUMBER;
      p_id_documento_figlio          NUMBER;
   BEGIN
      BEGIN

         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TC DISABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TB DISABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER AGS_FASCICOLI_TAIU DISABLE';

         FOR fascicolo IN (  SELECT ID_DOCUMENTO_ESTERNO,
                                    ANNO,
                                    NUMERO,
                                    ANNO_FASCICOLO_PADRE,
                                    NUMERO_FASCICOLO_PADRE,
                                    CLASS_COD,
                                    CLASS_DAL,
                                    CR_PADRE
                               FROM ags_fascicoli_trasco_view
                              WHERE numero LIKE '%.%'
                           ORDER BY anno DESC, numero ASC)
         LOOP
            --DBMS_OUTPUT.PUT_LINE('elaborazione='||fascicolo.ID_DOCUMENTO_ESTERNO);

            IF fascicolo.CR_PADRE > 0
            THEN
               BEGIN
                  SELECT id_documento_profilo
                    INTO p_id_documento_esterno_padre
                    FROM gdm_cartelle
                   WHERE id_cartella = fascicolo.CR_PADRE;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_id_documento_esterno_padre := NULL;
               END;
            ELSE
               BEGIN
                  SELECT id_documento_esterno
                    INTO p_id_documento_esterno_padre
                    FROM ags_fascicoli_trasco_view
                   WHERE     anno = fascicolo.ANNO_FASCICOLO_PADRE
                         AND numero = fascicolo.NUMERO_FASCICOLO_PADRE
                         AND class_cod = fascicolo.CLASS_COD
                         AND class_dal = fascicolo.CLASS_DAL
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_id_documento_esterno_padre := NULL;
               END;
            END IF;

            --DBMS_OUTPUT.PUT_LINE(' -> padre ='||p_id_documento_esterno_padre);

            IF p_id_documento_esterno_padre IS NOT NULL
            THEN
               BEGIN
                  SELECT id_documento
                    INTO p_id_documento_padre
                    FROM gdo_documenti
                   WHERE id_documento_esterno = p_id_documento_esterno_padre;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_id_documento_padre := NULL;
               END;

               IF p_id_documento_padre IS NOT NULL
               THEN
                  SELECT id_documento
                    INTO p_id_documento_figlio
                    FROM gdo_documenti
                   WHERE id_documento_esterno =
                            fascicolo.ID_DOCUMENTO_ESTERNO;

                  UPDATE ags_fascicoli
                     SET id_fascicolo_padre = p_id_documento_padre
                   WHERE id_documento = p_id_documento_figlio;
               --DBMS_OUTPUT.PUT_LINE('il padre di ' || p_id_documento_figlio || ' è ' || p_id_documento_padre);

               END IF;
            END IF;
         END LOOP;
      END;

      EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TC ENABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TB ENABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER AGS_FASCICOLI_TAIU ENABLE';

      d_return := 1;
      RETURN d_return;
   END;


   FUNCTION elaborazione_collegamenti
      RETURN NUMBER
   IS
      d_return                 NUMBER;
      d_id_doc_collegamento    NUMBER;
      d_id_tipo_collegamento   NUMBER;
      d_id_documento           NUMBER;
      d_id_collegato           NUMBER;
      p_id_revisione           NUMBER;
   BEGIN
      BEGIN
         --DBMS_OUTPUT.PUT_LINE('**** elaborazione_collegamenti ****');

         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TC DISABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TB DISABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER AGS_FASCICOLI_TAIU DISABLE';

         FOR collegamento
            IN (SELECT NULL ID_DOCUMENTO_COLLEGATO,
                       rif.ID_DOCUMENTO ID_DOCUMENTO,
                       rif.id_documento_rif ID_COLLEGATO,
                       DECODE (rif.TIPO_RELAZIONE,
                               'PROT_FASC', 'F_COLLEGA',
                               'F_PREC_SEG')
                          ID_TIPO_COLLEGAMENTO,
                       rif.data_aggiornamento DATA_INS,
                       rif.data_aggiornamento DATA_UPD,
                       rif.utente_aggiornamento UTENTE_INS,
                       rif.utente_aggiornamento UTENTE_UPD,
                       0 VERSION,
                       'Y' VALIDO
                  FROM gdm_riferimenti rif,
                       gdm_fascicoli fasc,
                       gdm_cartelle cart,
                       gdm_view_cartella vc,
                       gdm_documenti docu,
                       gdm_tipi_relazione tipi
                 WHERE                  -- rif.id_documento in ( 12294980) AND
                      vc   .id_cartella = cart.id_cartella
                       AND fasc.id_documento = cart.id_documento_profilo
                       AND fasc.id_documento = rif.id_documento_rif
                       AND docu.id_documento = fasc.id_documento
                       AND NVL (cart.stato, 'BO') <> 'CA'
                       AND tipi.area = 'SEGRETERIA'
                       AND rif.tipo_relazione LIKE 'PROT_FA%'
                       AND tipi.tipo_relazione = rif.tipo_relazione
                UNION
                SELECT NULL ID_DOCUMENTO_COLLEGATO,
                       rif.ID_DOCUMENTO ID_DOCUMENTO,
                       rif.id_documento_rif ID_COLLEGATO,
                       DECODE (rif.TIPO_RELAZIONE,
                               'PROT_FASC', 'F_COLLEGA',
                               'F_PREC_SEG')
                          ID_TIPO_COLLEGAMENTO,
                       rif.data_aggiornamento DATA_INS,
                       rif.data_aggiornamento DATA_UPD,
                       rif.utente_aggiornamento UTENTE_INS,
                       rif.utente_aggiornamento UTENTE_UPD,
                       0 VERSION,
                       'Y' VALIDO
                  FROM gdm_riferimenti rif,
                       gdm_fascicoli fasc,
                       gdm_cartelle cart,
                       gdm_view_cartella vc,
                       gdm_documenti docu,
                       gdm_tipi_relazione tipi
                 WHERE           --   rif.id_documento_rif in  ( 12294980) AND
                      vc   .id_cartella = cart.id_cartella
                       AND fasc.id_documento = cart.id_documento_profilo
                       AND fasc.id_documento = rif.id_documento
                       AND docu.id_documento = fasc.id_documento
                       AND NVL (cart.stato, 'BO') <> 'CA'
                       AND tipi.area = 'SEGRETERIA'
                       AND rif.tipo_relazione LIKE 'PROT_FAS%'
                       AND tipi.tipo_relazione = rif.tipo_relazione)
         LOOP
            SELECT hibernate_sequence.NEXTVAL
              INTO d_id_doc_collegamento
              FROM DUAL;

            BEGIN
               SELECT id_tipo_collegamento
                 INTO d_id_tipo_collegamento
                 FROM gdo_tipi_collegamento
                WHERE descrizione = collegamento.ID_TIPO_COLLEGAMENTO;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT id_tipo_collegamento
                    INTO d_id_tipo_collegamento
                    FROM gdo_tipi_collegamento
                   WHERE tipo_collegamento = 'F_COLLEGA';
            END;

            -- calcolo id_documento e id_collegato
            BEGIN
               SELECT id_documento
                 INTO d_id_documento
                 FROM gdo_documenti
                WHERE id_documento_esterno = collegamento.ID_DOCUMENTO;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_id_documento := NULL;
            END;

            BEGIN
               SELECT id_documento
                 INTO d_id_collegato
                 FROM gdo_documenti
                WHERE id_documento_esterno = collegamento.ID_COLLEGATO;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_id_collegato := NULL;
            END;

            IF d_id_documento IS NOT NULL AND d_id_collegato IS NOT NULL
            THEN
               INSERT INTO GDO_DOCUMENTI_COLLEGATI (ID_DOCUMENTO_COLLEGATO,
                                                    VERSION,
                                                    ID_COLLEGATO,
                                                    DATA_INS,
                                                    ID_DOCUMENTO,
                                                    DATA_UPD,
                                                    ID_TIPO_COLLEGAMENTO,
                                                    UTENTE_INS,
                                                    UTENTE_UPD,
                                                    VALIDO)
                    VALUES (d_id_doc_collegamento,
                            collegamento.VERSION,
                            d_id_collegato,
                            collegamento.DATA_INS,
                            d_id_documento,
                            collegamento.DATA_UPD,
                            d_id_tipo_collegamento,
                            collegamento.UTENTE_INS,
                            collegamento.UTENTE_UPD,
                            collegamento.VALIDO);

               p_id_revisione := crea_revinfo (SYSTIMESTAMP);


               INSERT
                 INTO GDO_DOCUMENTI_COLLEGATI_LOG (ID_DOCUMENTO_COLLEGATO,
                                                   REV,
                                                   REVTYPE,
                                                   DATA_INS,
                                                   DATE_CREATED_MOD,
                                                   DATA_UPD,
                                                   LAST_UPDATED_MOD,
                                                   VALIDO,
                                                   VALIDO_MOD,
                                                   UTENTE_INS,
                                                   UTENTE_INS_MOD,
                                                   UTENTE_UPD,
                                                   UTENTE_UPD_MOD,
                                                   ID_COLLEGATO,
                                                   COLLEGATO_MOD,
                                                   ID_DOCUMENTO,
                                                   DOCUMENTO_MOD,
                                                   ID_TIPO_COLLEGAMENTO,
                                                   TIPO_COLLEGAMENTO_MOD)
               VALUES (d_id_doc_collegamento,
                       p_id_revisione,
                       0,
                       collegamento.DATA_INS,
                       0,
                       collegamento.DATA_UPD,
                       0,
                       'Y',
                       1,
                       collegamento.UTENTE_INS,
                       0,
                       collegamento.UTENTE_UPD,
                       0,
                       d_id_collegato,
                       0,
                       d_id_documento,
                       0,
                       d_id_tipo_collegamento,
                       0);
            END IF;
         END LOOP;
      END;

      EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TC ENABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER ags_fascicoli_TB ENABLE';
         EXECUTE IMMEDIATE 'ALTER TRIGGER AGS_FASCICOLI_TAIU ENABLE';

      d_return := 1;
      RETURN d_return;
   END;


   FUNCTION crea_documento (p_id_documento_esterno    NUMBER,
                            p_id_ente                 VARCHAR2,
                            p_utente_ins              VARCHAR2,
                            p_utente_upd              VARCHAR2,
                            p_data_ins                DATE,
                            p_data_upd                DATE,
                            p_riservato               VARCHAR2,
                            p_id_revisione            NUMBER)
      RETURN NUMBER
   IS
      p_id_documento   NUMBER;
   BEGIN
      INSERT INTO GDO_DOCUMENTI (ID_DOCUMENTO,
                                 ID_DOCUMENTO_ESTERNO,
                                 ID_ENTE,
                                 TIPO_OGGETTO,
                                 VALIDO,
                                 UTENTE_INS,
                                 DATA_INS,
                                 UTENTE_UPD,
                                 DATA_UPD,
                                 VERSION,
                                 RISERVATO)
           VALUES (p_id_documento_esterno * -1,
                   p_id_documento_esterno,
                   p_id_ente,
                   'FASCICOLO',
                   'Y',
                   p_utente_ins,
                   p_data_ins,
                   p_utente_upd,
                   p_data_upd,
                   0,
                   NVL (p_riservato, 'N'));


      INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                     REV,
                                     REVTYPE,
                                     DATA_INS,
                                     DATE_CREATED_MOD,
                                     DATA_UPD,
                                     LAST_UPDATED_MOD,
                                     VALIDO,
                                     VALIDO_MOD,
                                     ID_DOCUMENTO_ESTERNO,
                                     ID_DOCUMENTO_ESTERNO_MOD,
                                     UTENTE_INS,
                                     UTENTE_INS_MOD,
                                     UTENTE_UPD,
                                     UTENTE_UPD_MOD,
                                     ID_ENTE,
                                     ENTE_MOD,
                                     DOCUMENTI_COLLEGATI_MOD,
                                     FILE_DOCUMENTI_MOD,
                                     ITER_MOD,
                                     TIPO_OGGETTO,
                                     TIPO_OGGETTO_MOD)
           VALUES (p_id_documento_esterno * -1,
                   p_id_revisione,
                   0,
                   p_data_ins,
                   0,
                   p_data_upd,
                   0,
                   'Y',
                   0,
                   p_id_documento_esterno,
                   0,
                   p_utente_ins,
                   0,
                   p_utente_upd,
                   0,
                   p_id_ente,
                   0,
                   0,
                   0,
                   0,
                   'FASCICOLO',
                   0);

      RETURN -p_id_documento_esterno;
   END;

   FUNCTION crea_documento_soggetto (p_id_documento     NUMBER,
                                     p_tipo_soggetto    VARCHAR2,
                                     p_utente           VARCHAR2,
                                     p_progr_uo         NUMBER,
                                     p_dal_uo           DATE,
                                     p_ottica_uo        VARCHAR2)
      RETURN NUMBER
   IS
      d_id_doc_sogg    NUMBER;
      p_id_revisione   NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_sogg FROM DUAL;

      INSERT INTO GDO_DOCUMENTI_SOGGETTI (ID_DOCUMENTO_SOGGETTO,
                                          VERSION,
                                          ATTIVO,
                                          ID_DOCUMENTO,
                                          SEQUENZA,
                                          TIPO_SOGGETTO,
                                          UTENTE,
                                          UNITA_PROGR,
                                          UNITA_DAL,
                                          UNITA_OTTICA)
           VALUES (d_id_doc_sogg,
                   0,
                   'Y',
                   p_id_documento,
                   0,
                   p_tipo_soggetto,
                   p_utente,
                   p_progr_uo,
                   p_dal_uo,
                   p_ottica_uo);

      p_id_revisione := crea_revinfo (SYSTIMESTAMP);


       INSERT INTO GDO_DOCUMENTI_SOGGETTI_LOG (ID_DOCUMENTO_SOGGETTO,
                                              ID_DOCUMENTO,
                                              REV,
                                              REVTYPE,
                                              REVEND,
                                              VERSION_MOD,
                                              UTENTE_AD4_MOD,
                                              ATTIVO,
                                              ATTIVO_MOD,
                                              TIPO_SOGGETTO,
                                              TIPO_SOGGETTO_MOD,
                                              SEQUENZA,
                                              SEQUENZA_MOD,
                                              UNITA_PROGR,
                                              UNITA_PROGR_MOD,
                                              UNITA_DAL,
                                              UNITA_DAL_MOD,
                                              UNITA_OTTICA,
                                              UNITA_OTTICA_MOD,
                                              UNITA_SO4_MOD,
                                              ID_TIPO_COLLEGAMENTO_MOD,
                                              SOGGETTI_MOD,
                                              DOCUMENTO_MOD)
           VALUES (d_id_doc_sogg,
                   p_id_documento,
                   p_id_revisione,
                   0,
                   NULL,
                   0,
                   0,
                   'Y',
                   0,
                   p_tipo_soggetto,
                   0,
                   0,
                   0,
                   p_progr_uo,
                   0,
                   p_dal_uo,
                   0,
                   p_ottica_uo,
                   0,
                   0,
                   0,
                   0,
                   0);

      RETURN d_id_doc_sogg;
   END;

   FUNCTION crea_documento_competenza (p_id_documento    NUMBER,
                                       p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento_competenza   NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL
        INTO d_id_documento_competenza
        FROM DUAL;

      INSERT INTO GDO_DOCUMENTI_COMPETENZE (ID_DOCUMENTO_COMPETENZA,
                                            VERSION,
                                            CANCELLAZIONE,
                                            ID_CFG_COMPETENZA,
                                            LETTURA,
                                            MODIFICA,
                                            ID_DOCUMENTO,
                                            UTENTE)
           VALUES (d_id_documento_competenza,
                   0,
                   'Y',
                   NULL,
                   'Y',
                   'Y',
                   p_id_documento,
                   p_utente);


      RETURN d_id_documento_competenza;
   END;

   FUNCTION crea_documento_dati_scarto (p_id_documento       NUMBER,
                                        p_stato_scarto       VARCHAR2,
                                        p_data_scarto        DATE,
                                        p_nulla_osta         VARCHAR2,
                                        p_data_nulla_osta    DATE,
                                        p_utente             VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento_dati_scarto   NUMBER;
      p_id_revisione               NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL
        INTO d_id_documento_dati_scarto
        FROM DUAL;

      INSERT INTO AGP_DOCUMENTI_DATI_SCARTO (ID_DOCUMENTO_DATI_SCARTO,
                                             STATO,
                                             DATA_STATO,
                                             NULLA_OSTA,
                                             DATA_NULLA_OSTA,
                                             UTENTE_INS,
                                             DATA_INS,
                                             UTENTE_UPD,
                                             VERSION)
           VALUES (d_id_documento_dati_scarto,
                   p_stato_scarto,
                   p_data_scarto,
                   p_nulla_osta,
                   p_data_nulla_osta,
                   p_utente,
                   SYSDATE,
                   p_utente,
                   0);

      p_id_revisione := crea_revinfo (SYSTIMESTAMP);

      INSERT INTO AGP_DOCUMENTI_DATI_SCARTO_LOG (ID_DOCUMENTO_DATI_SCARTO,
                                                 REV,
                                                 REVTYPE,
                                                 STATO,
                                                 STATO_MOD,
                                                 DATA_STATO,
                                                 DATA_STATO_MOD,
                                                 NULLA_OSTA,
                                                 NULLA_OSTA_MOD,
                                                 DATA_NULLA_OSTA,
                                                 DATA_NULLA_OSTA_MOD,
                                                 UTENTE_INS,
                                                 UTENTE_INS_MOD,
                                                 DATA_INS,
                                                 DATE_CREATED_MOD,
                                                 UTENTE_UPD,
                                                 UTENTE_UPD_MOD,
                                                 DATA_UPD,
                                                 LAST_UPDATED_MOD)
           VALUES (d_id_documento_dati_scarto,
                   p_id_revisione,
                   0,
                   p_stato_scarto,
                   0,
                   p_data_scarto,
                   0,
                   p_nulla_osta,
                   0,
                   p_data_nulla_osta,
                   0,
                   p_utente,
                   0,
                   SYSDATE,
                   0,
                   p_utente,
                   0,
                   SYSDATE,
                   0);

      RETURN d_id_documento_dati_scarto;
   END;

   FUNCTION crea_smistamenti (p_id_documento NUMBER, p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      d_id_doc_smist   NUMBER;
   BEGIN
      BEGIN
         FOR smistamento
            IN (SELECT unita_trasm.PROGR UNITA_TRASMISSIONE_PROGR,
                       unita_trasm.DAL UNITA_TRASMISSIONE_DAL,
                       unita_trasm.OTTICA UNITA_TRASMISSIONE_OTTICA,
                       UTENTE_TRASMISSIONE,
                       unita_smist.PROGR UNITA_SMISTAMENTO_PROGR,
                       unita_smist.DAL UNITA_SMISTAMENTO_DAL,
                       unita_smist.OTTICA UNITA_SMISTAMENTO_OTTICA,
                       s.smistamento_dal DATA_SMISTAMENTO,
                       DECODE (stato_smistamento,
                               'N', 'CREATO',
                               'R', 'DA_RICEVERE',
                               'C', 'IN_CARICO',
                               'E', 'ESEGUITO',
                               'S', 'STORICO',
                               'F', 'STORICO',
                               'CREATO')
                          STATO_SMISTAMENTO,
                       TIPO_SMISTAMENTO,
                       s.presa_in_carico_utente UTENTE_PRESA_IN_CARICO,
                       s.presa_in_carico_dal DATA_PRESA_IN_CARICO,
                       UTENTE_ESECUZIONE,
                       DATA_ESECUZIONE,
                       sd.utente_aggiornamento UTENTE_ASSEGNANTE,
                       s.codice_assegnatario UTENTE_ASSEGNATARIO,
                       s.assegnazione_dal DATA_ASSEGNAZIONE,
                       NOTE,
                       NOTE_UTENTE,
                       sd.utente_aggiornamento UTENTE_INS,
                       sd.data_aggiornamento DATA_INS,
                       d.utente_aggiornamento UTENTE_UPD,
                       d.data_aggiornamento DATA_UPD,
                       s.id_documento ID_DOCUMENTO_ESTERNO,
                       NULL UTENTE_RIFIUTO,
                       NULL DATA_RIFIUTO,
                       NULL MOTIVO_RIFIUTO
                  FROM gdm_seg_smistamenti s,
                       gdm_documenti d,
                       gdm_stati_documento sd,
                       SO4_V_UNITA_ORGANIZZATIVE_PUBB unita_smist,
                       SO4_V_UNITA_ORGANIZZATIVE_PUBB unita_trasm,
                       gdo_enti enti
                 WHERE     sd.id_documento = d.id_documento
                       AND s.id_documento = d.id_documento
                       AND d.stato_documento = 'BO'
                       AND ENTI.AMMINISTRAZIONE = s.CODICE_AMMINISTRAZIONE
                       AND ENTI.AOO = s.CODICE_AOO
                       AND ENTI.OTTICA = (SELECT GDM_AG_PARAMETRO.GET_VALORE (
                                                    'SO_OTTICA_PROT',
                                                    s.CODICE_AMMINISTRAZIONE,
                                                    s.CODICE_AOO,
                                                    '')
                                            FROM DUAL)
                       AND unita_smist.CODICE(+) = s.ufficio_smistamento
                       AND unita_trasm.CODICE(+) = s.ufficio_trasmissione
                       AND NVL (unita_smist.ottica, enti.ottica) =
                              enti.ottica
                       AND NVL (unita_trasm.ottica, enti.ottica) =
                              enti.ottica
                       AND NVL (s.smistamento_dal, s.smistamento_dal) BETWEEN unita_smist.dal
                                                                          AND NVL (
                                                                                 unita_smist.al,
                                                                                 TO_DATE (
                                                                                    3333333,
                                                                                    'j'))
                       AND NVL (s.smistamento_dal, s.smistamento_dal) BETWEEN unita_trasm.dal
                                                                          AND NVL (
                                                                                 unita_trasm.al,
                                                                                 TO_DATE (
                                                                                    3333333,
                                                                                    'j'))
                       AND s.idrif = p_idrif)
         LOOP
            SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_smist FROM DUAL;

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
                                                   ID_DOCUMENTO_ESTERNO,
                                                   UTENTE_RIFIUTO,
                                                   DATA_RIFIUTO,
                                                   MOTIVO_RIFIUTO)
                 VALUES (d_id_doc_smist,
                         p_id_documento,
                         smistamento.UNITA_TRASMISSIONE_PROGR,
                         smistamento.UNITA_TRASMISSIONE_DAL,
                         smistamento.UNITA_TRASMISSIONE_OTTICA,
                         smistamento.UTENTE_TRASMISSIONE,
                         smistamento.UNITA_SMISTAMENTO_PROGR,
                         smistamento.UNITA_SMISTAMENTO_DAL,
                         smistamento.UNITA_SMISTAMENTO_OTTICA,
                         smistamento.DATA_SMISTAMENTO,
                         smistamento.STATO_SMISTAMENTO,
                         smistamento.TIPO_SMISTAMENTO,
                         smistamento.UTENTE_PRESA_IN_CARICO,
                         smistamento.DATA_PRESA_IN_CARICO,
                         smistamento.UTENTE_ESECUZIONE,
                         smistamento.DATA_ESECUZIONE,
                         smistamento.UTENTE_ASSEGNANTE,
                         smistamento.UTENTE_ASSEGNATARIO,
                         smistamento.DATA_ASSEGNAZIONE,
                         smistamento.NOTE,
                         smistamento.NOTE_UTENTE,
                         0,
                         'Y',
                         smistamento.UTENTE_INS,
                         smistamento.DATA_INS,
                         smistamento.UTENTE_UPD,
                         smistamento.DATA_UPD,
                         smistamento.ID_DOCUMENTO_ESTERNO,
                         smistamento.UTENTE_RIFIUTO,
                         smistamento.DATA_RIFIUTO,
                         smistamento.MOTIVO_RIFIUTO);
         END LOOP;
      END;



      RETURN 1;
   END;


BEGIN
   BEGIN
      SELECT gdm_ag_parametro.get_valore ('SO_OTTICA_PROT_1', '@agVar@', '*')
        INTO d_unita_ottica_default
        FROM DUAL;

      BEGIN
         SELECT PROGR_UNITA_ORGANIZZATIVA, dal
           INTO d_unita_progr_default, d_unita_dal_default
           FROM so4_auor
          WHERE ottica = d_unita_ottica_default AND CODICE_UO = 'TRASCO';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DECLARE
               d_cod_amm     VARCHAR2 (1000);
               d_progr_aoo   NUMBER;
            BEGIN
               SELECT gdm_ag_parametro.get_valore ('CODICE_AMM_1',
                                                   '@agVar@',
                                                   '*')
                 INTO d_cod_amm
                 FROM DUAL;

               SELECT progr_aoo
                 INTO d_progr_aoo
                 FROM so4_aoo
                WHERE     codice_amministrazione = d_cod_amm
                      AND codice_aoo =
                             (SELECT gdm_ag_parametro.get_valore (
                                        'CODICE_AOO_1',
                                        '@agVar@',
                                        '*')
                                FROM DUAL)
                      AND SYSDATE BETWEEN dal AND NVL (al, SYSDATE);

               SELECT SO4_ANA_UNOR_PKG.get_id_unita
                 INTO d_unita_progr_default
                 FROM DUAL;

               d_unita_dal_default := TO_DATE ('01/01/1951', 'MM/DD/YYYY');

               INSERT INTO so4_auor (PROGR_UNITA_ORGANIZZATIVA,
                                     DAL,
                                     revisione_istituzione,
                                     CODICE_UO,
                                     DESCRIZIONE,
                                     DES_ABB,
                                     OTTICA,
                                     AMMINISTRAZIONE,
                                     PROGR_AOO,
                                     AL,
                                     UTENTE_AGGIORNAMENTO,
                                     DATA_AGGIORNAMENTO,
                                     DAL_PUBB,
                                     AL_PUBB)
                  SELECT d_unita_progr_default,
                         d_unita_dal_default,
                         1,
                         'TRASCO',
                         'UNITA'' PER TRASCODIFICHE',
                         'TRASCO',
                         d_unita_ottica_default,
                         d_cod_amm,
                         d_progr_aoo,
                         TRUNC (SYSDATE) - 1,
                         'TRASCO',
                         TRUNC (SYSDATE),
                         d_unita_dal_default,
                         TRUNC (SYSDATE) - 1
                    FROM DUAL
                   WHERE NOT EXISTS
                            (SELECT 1
                               FROM so4_auor
                              WHERE     ottica = d_unita_ottica_default
                                    AND CODICE_UO = 'TRASCO');

               INSERT INTO so4_unor (OTTICA,
                                     PROGR_UNITA_ORGANIZZATIVA,
                                     DAL,
                                     revisione,
                                     UTENTE_AGGIORNAMENTO,
                                     DATA_AGGIORNAMENTO,
                                     DAL_PUBB,
                                     AL,
                                     AL_PUBB)
                  SELECT d_unita_ottica_default,
                         d_unita_progr_default,
                         d_unita_dal_default,
                         1,
                         'TRASCO',
                         TRUNC (SYSDATE),
                         d_unita_dal_default,
                         TRUNC (SYSDATE) - 1,
                         TRUNC (SYSDATE) - 1
                    FROM DUAL
                   WHERE NOT EXISTS
                            (SELECT 1
                               FROM so4_unita_organizzative
                              WHERE     ottica = d_unita_ottica_default
                                    AND PROGR_UNITA_ORGANIZZATIVA =
                                           d_unita_progr_default);
            END;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         d_unita_ottica_default := '';
         d_unita_progr_default := NULL;
         d_unita_dal_default := NULL;
   END;
END;
/
