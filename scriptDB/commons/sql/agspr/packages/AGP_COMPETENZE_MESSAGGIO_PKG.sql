--liquibase formatted sql
--changeset mmalferrari:AGSPR_PACKAGE_AGP_COMPETENZE_MESSAGGIO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_COMPETENZE_MESSAGGIO
AS
   /******************************************************************************
      NAME:       AGP_COMPETENZE_MESSAGGIO
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/04/2020      gmannella       1. Created this package.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione           CONSTANT VARCHAR2 (40) := 'V1.00';

   G_DA_GESTIRE                   VARCHAR2 (100) := 'DA_GESTIRE';
   G_DA_PROTOCOLLARE_CON_SEGN     VARCHAR2 (100)
                                     := 'DA_PROTOCOLLARE_CON_SEGNATURA';
   G_DA_PROTOCOLLARE_SENZA_SEGN   VARCHAR2 (100)
                                     := 'DA_PROTOCOLLARE_SENZA_SEGNATURA';
   G_GESTITO                      VARCHAR2 (100) := 'GESTITO';
   G_GENERATA_ECCEZIONE           VARCHAR2 (100) := 'GENERATA_ECCEZIONE';
   G_NON_PROTOCOLLATO             VARCHAR2 (100) := 'NON_PROTOCOLLATO';
   G_PROTOCOLLATO                 VARCHAR2 (100) := 'PROTOCOLLATO';
   G_SCARTATO                     VARCHAR2 (100) := 'SCARTATO';

   G_PRIVILEGIO_VTOT              VARCHAR2 (30) := 'VTOT';
   G_PRIVILEGIO_VP                VARCHAR2 (30) := 'VP';
   G_PRIVILEGIO_VISUALIZZA        VARCHAR2 (30) := 'VS';
   G_PRIVILEGIO_VDDR              VARCHAR2 (30) := 'VDDR';
   G_PRIVILEGIO_PMAILT            VARCHAR2 (30) := 'PMAILT';
   G_PRIVILEGIO_PMAILI            VARCHAR2 (30) := 'PMAILI';
   G_PRIVILEGIO_PMAILU            VARCHAR2 (30) := 'PMAILU';
   G_PRIVILEGIO_MTOTR             VARCHAR2 (30) := 'MTOTR';
   G_PRIVILEGIO_MSR               VARCHAR2 (30) := 'MSR';
   G_PRIVILEGIO_MPROTR            VARCHAR2 (30) := 'MPROTR';
   G_PRIVILEGIO_MTOT              VARCHAR2 (30) := 'MTOT';
   G_PRIVILEGIO_MS                VARCHAR2 (30) := 'MS';
   G_PRIVILEGIO_MPROT             VARCHAR2 (30) := 'MPROT';
   G_PRIVILEGIO_MDDEP             VARCHAR2 (30) := 'MDDEP';

   G_SMISTAMENTI_DA_RICEVERE      VARCHAR2 (30) := 'DA_RICEVERE';
   G_SMISTAMENTI_IN_CARICO        VARCHAR2 (30) := 'IN_CARICO';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_documento_messaggio (p_id_protocollo NUMBER)
      RETURN NUMBER;

   FUNCTION lettura_messaggio_arrivo (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_messaggio_arrivo (p_id_documento    NUMBER,
                                       p_utente          VARCHAR2)
      RETURN NUMBER;
END AGP_COMPETENZE_MESSAGGIO;
/

CREATE OR REPLACE PACKAGE BODY AGP_COMPETENZE_MESSAGGIO
AS
   /******************************************************************************
      NAME:       AGP_COMPETENZE_MESSAGGIO
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      001        02/04/2020  gmannella        1. Created this package.
      002        19/10/2020  gmannella
      003        19/10/2020  gmannella     Corretto su lettura_messaggio_arrivo la query che estrae
                                                              l'id protocollo dal messaggio (tornava per essore il messaggio stesso)
   ******************************************************************************/
   -- Revisione del Package baody
   s_revisione_body   CONSTANT afc.t_revision := '003';

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
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END;

   FUNCTION get_documento_messaggio (p_id_protocollo NUMBER)
      RETURN NUMBER
   IS
      d_retval   NUMBER := NULL;
   BEGIN
      SELECT MAX (gdo_documenti_collegati.id_documento)
        INTO d_retval
        FROM gdo_documenti_collegati, gdo_tipi_collegamento
       WHERE     id_collegato = p_id_protocollo
             AND gdo_documenti_collegati.id_tipo_collegamento =
                    gdo_tipi_collegamento.id_tipo_collegamento
             AND gdo_tipi_collegamento.tipo_collegamento = 'MAIL';

      RETURN d_retval;
   END;

   FUNCTION verifica_privilegio_utente (p_unita         VARCHAR2,
                                        p_privilegio    VARCHAR2,
                                        p_utente        VARCHAR2,
                                        p_data          DATE)
      RETURN NUMBER
   IS
      d_retval   NUMBER := 0;
   BEGIN
      d_retval :=
         GDM_AG_UTILITIES.verifica_privilegio_utente (
            p_unita        => p_unita,
            p_privilegio   => p_privilegio,
            p_utente       => p_utente,
            p_data         => p_data);

      RETURN d_retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION verifica_esistenza_smistamento (p_id_documento        NUMBER,
                                            p_utente              VARCHAR2,
                                            p_tipi_smistamento    VARCHAR2)
      RETURN NUMBER
   IS
      d_retval   NUMBER := 0;
   BEGIN
      SELECT 1
        INTO d_retval
        FROM agp_documenti_smistamenti s
       WHERE     s.utente_assegnatario = p_utente
             AND INSTR ('|' || p_tipi_smistamento || '|',
                        '|' || s.tipo_smistamento || '|') > 0
             AND s.id_documento = p_id_documento;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         RETURN 0;
   END;


   FUNCTION is_ute_unit_ricev_smist_vsvddr (p_id_documento    NUMBER,
                                            p_utente          VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      FOR smistamenti
         IN (SELECT so4_v_unita_organizzative_pubb.codice
               FROM agp_documenti_smistamenti s,
                    so4_v_unita_organizzative_pubb
              WHERE     s.id_documento = p_id_documento
                    AND s.unita_smistamento_ottica =
                           so4_v_unita_organizzative_pubb.OTTICA(+)
                    AND s.unita_smistamento_progr =
                           so4_v_unita_organizzative_pubb.PROGR(+)
                    AND s.unita_smistamento_dal =
                           so4_v_unita_organizzative_pubb.DAL(+))
      LOOP
         IF (   verifica_privilegio_utente (smistamenti.codice,
                                            G_PRIVILEGIO_VISUALIZZA,
                                            p_utente,
                                            TRUNC (SYSDATE)) = 1
             OR verifica_privilegio_utente (smistamenti.codice,
                                            G_PRIVILEGIO_VDDR,
                                            p_utente,
                                            TRUNC (SYSDATE)) = 1)
         THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION is_ute_unit_smis_carico_eseg (p_id_documento    NUMBER,
                                          p_utente          VARCHAR2,
                                          p_privilegio      VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      FOR smistamenti
         IN (SELECT so4_v_unita_organizzative_pubb.codice,
                    gdo_documenti.data_ins,
                    s.utente_assegnatario
               FROM agp_documenti_smistamenti s,
                    so4_v_unita_organizzative_pubb,
                    gdo_documenti
              WHERE     s.id_documento = p_id_documento
                    AND gdo_documenti.id_documento = p_id_documento
                    AND s.unita_smistamento_ottica =
                           so4_v_unita_organizzative_pubb.OTTICA(+)
                    AND s.unita_smistamento_progr =
                           so4_v_unita_organizzative_pubb.PROGR(+)
                    AND s.unita_smistamento_dal =
                           so4_v_unita_organizzative_pubb.DAL(+)
                    AND s.tipo_smistamento IN ('ESEGUITO', 'IN_CARICO'))
      LOOP
         IF (   verifica_privilegio_utente (smistamenti.codice,
                                            p_privilegio,
                                            p_utente,
                                            smistamenti.data_ins) = 1
             OR smistamenti.utente_assegnatario = p_utente)
         THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION is_indirizzo_presente_aoo_uo (
      p_id_documento            NUMBER,
      p_listaindirizzi          VARCHAR2,
      p_filtro_aoo_uo           VARCHAR2 DEFAULT NULL,
      p_filtro_uo_utente        VARCHAR2 DEFAULT NULL,
      p_filtro_uo_privilegio    VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      d_retval         NUMBER := 0;
      d_id_ente        gdo_documenti.id_ente%TYPE;
      d_indir          VARCHAR2 (200);
      d_tipo           VARCHAR2 (50);
      d_progr_uo_aoo   NUMBER;
      d_cur            afc.t_ref_cursor;
      d_esiste         NUMBER := 0;
   BEGIN
      SELECT id_ente
        INTO d_id_ente
        FROM gdo_documenti
       WHERE id_documento = p_id_documento;

      d_cur :=
         AGP_SO4_UTILITY_PKG.get_indirizzi_aoo_uo (d_id_ente,
                                                   p_filtro_aoo_uo,
                                                   p_listaindirizzi,
                                                   '=');

      IF d_cur%ISOPEN
      THEN
         IF p_filtro_uo_utente IS NULL
         THEN
            FETCH d_cur INTO d_indir, d_tipo, d_progr_uo_aoo;

            IF d_cur%ROWCOUNT > 0
            THEN
               d_retval := 1;
            END IF;
         ELSE
            LOOP
               FETCH d_cur INTO d_indir, d_tipo, d_progr_uo_aoo;

               EXIT WHEN (d_cur%NOTFOUND OR d_esiste = 1);

               SELECT COUNT (*)
                 INTO d_esiste
                 FROM so4_v_unita_organizzative_pubb u, ag_priv_utente_tmp p
                WHERE     p.utente = p_filtro_uo_utente
                      AND p.privilegio = p_filtro_uo_privilegio
                      AND p.progr_unita = d_progr_uo_aoo
                      AND (    p.dal <= TRUNC (SYSDATE)
                           AND NVL (p.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE))
                      AND (    u.dal <= TRUNC (SYSDATE)
                           AND NVL (u.al, TRUNC (SYSDATE)) >= TRUNC (SYSDATE));

               IF d_esiste > 0
               THEN
                  d_retval := 1;
               END IF;
            END LOOP;
         END IF;

         CLOSE d_cur;
      END IF;

      RETURN d_retval;
   END;

   FUNCTION lettura_messaggio_arrivo (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      d_stato_messaggio              agp_msg_ricevuti_dati_prot.stato%TYPE;
      d_codice_unita                 so4_v_unita_organizzative_pubb.codice%TYPE;
      d_destinatari_messaggio        agp_msg_ricevuti_dati_prot.destinatari%TYPE;
      d_destinatari_conoscenza_msg   agp_msg_ricevuti_dati_prot.destinatari_conoscenza%TYPE;
      d_iddocumento_protocollo      gdo_documenti.id_documento%TYPE := NULL;
      d_retval                       NUMBER := 0;
   BEGIN
    BEGIN
         SELECT stato, destinatari, destinatari_conoscenza
           INTO d_stato_messaggio,
                d_destinatari_messaggio,
                d_destinatari_conoscenza_msg
           FROM agp_msg_ricevuti_dati_prot
          WHERE agp_msg_ricevuti_dati_prot.id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      BEGIN
         SELECT  gdo_documenti_collegati.id_collegato
           INTO   d_iddocumento_protocollo
           FROM agp_msg_ricevuti_dati_prot, gdo_documenti_collegati, gdo_tipi_collegamento
          WHERE agp_msg_ricevuti_dati_prot.id_documento = p_id_documento and
                     agp_msg_ricevuti_dati_prot.id_documento = gdo_documenti_collegati.id_documento  and
                     gdo_documenti_collegati.id_tipo_collegamento =    gdo_tipi_collegamento.id_tipo_collegamento   and
                     gdo_tipi_collegamento.tipo_collegamento = 'MAIL';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_iddocumento_protocollo := NULL;
      END;

      IF d_iddocumento_protocollo IS NOT NULL THEN
          RETURN AGP_COMPETENZE_DOCUMENTO.LETTURA( d_iddocumento_protocollo,p_utente);
      END IF;

      BEGIN
         SELECT codice
           INTO d_codice_unita
           FROM agp_msg_ricevuti_dati_prot,
                gdo_documenti_soggetti,
                so4_v_unita_organizzative_pubb
          WHERE     agp_msg_ricevuti_dati_prot.id_documento = p_id_documento
                AND gdo_documenti_soggetti.id_documento = p_id_documento
                AND gdo_documenti_soggetti.tipo_soggetto = 'UO_MESSAGGIO'
                AND so4_v_unita_organizzative_pubb.ottica =
                       gdo_documenti_soggetti.unita_ottica
                AND so4_v_unita_organizzative_pubb.progr =
                       gdo_documenti_soggetti.unita_progr
                AND so4_v_unita_organizzative_pubb.dal =
                       gdo_documenti_soggetti.unita_dal;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_stato_messaggio = G_DA_GESTIRE
      THEN
         d_retval := 1;
      END IF;

      IF    d_stato_messaggio = G_NON_PROTOCOLLATO
         OR d_stato_messaggio = G_DA_PROTOCOLLARE_CON_SEGN
         OR d_stato_messaggio = G_DA_PROTOCOLLARE_SENZA_SEGN
      THEN
         d_retval :=
            verifica_privilegio_utente (NULL,
                                        G_PRIVILEGIO_VTOT,
                                        p_utente,
                                        TRUNC (SYSDATE));

         IF d_retval = 0
         THEN
            d_retval :=
               verifica_privilegio_utente (d_codice_unita,
                                           G_PRIVILEGIO_VP,
                                           p_utente,
                                           TRUNC (SYSDATE));
         END IF;

         IF d_retval = 0
         THEN
            d_retval :=
               verifica_esistenza_smistamento (
                  p_id_documento,
                  p_utente,
                  G_SMISTAMENTI_DA_RICEVERE || '|' || G_SMISTAMENTI_IN_CARICO);
         END IF;

         IF d_retval = 0
         THEN
            d_retval :=
               is_ute_unit_ricev_smist_vsvddr (p_id_documento, p_utente);
         END IF;
      END IF;

      IF d_retval = 0
      THEN
         IF d_stato_messaggio = G_GESTITO
         THEN

             declare
             a_id_protocoColl NUMBER(10):=null;
             begin
               -- Cerco un collegamento di tipi PROT_PEC  con il messaggio inviato, se lo trovo
               -- la competenza è del protocollo ad esso associato
                 select max(collMsgInviato.id_documento)
                 into a_id_protocoColl
                 from gdo_documenti_collegati coll,
                         gdo_tipi_collegamento tipicoll,
                         gdo_documenti_collegati collMsgInviato
                 where coll.id_collegato = p_id_documento and
                            tipicoll.tipo_collegamento = 'PROT_PEC' and
                            tipicoll.id_tipo_collegamento = coll.id_tipo_collegamento and
                            collMsgInviato.id_collegato = coll.id_documento
                            ;

                 if    a_id_protocoColl is not null then
                   RETURN AGP_COMPETENZE_DOCUMENTO.LETTURA( a_id_protocoColl,p_utente);
                 else
                    --cerco uno dei possibili collegamenti rimasti (gli altri possibili sono PROT_CONF....ETC... ) direttamente con il protocollo
                    --   se lo trovo, la competenza sarà di codello
                    select max(coll.id_documento)
                     into a_id_protocoColl
                     from gdo_documenti_collegati coll
                     where coll.id_documento = p_id_documento ;

                     if    a_id_protocoColl is not null then
                         RETURN AGP_COMPETENZE_DOCUMENTO.LETTURA( a_id_protocoColl,p_utente);
                     end if;
                 end if;
             end;


         END IF;
      END IF;

      IF d_retval = 0
      THEN
         IF    d_stato_messaggio = G_GENERATA_ECCEZIONE
            OR d_stato_messaggio = G_SCARTATO
            OR d_stato_messaggio = G_DA_PROTOCOLLARE_CON_SEGN
            OR d_stato_messaggio = G_DA_PROTOCOLLARE_SENZA_SEGN
         THEN
            d_retval :=
               verifica_privilegio_utente (NULL,
                                           G_PRIVILEGIO_PMAILT,
                                           p_utente,
                                           TRUNC (SYSDATE));

            IF d_retval = 0
            THEN
               IF verifica_privilegio_utente (NULL,
                                              G_PRIVILEGIO_PMAILI,
                                              p_utente,
                                              TRUNC (SYSDATE)) = 1
               THEN
                  IF     NVL (d_destinatari_messaggio, '') = ''
                     AND NVL (d_destinatari_conoscenza_msg, '') = ''
                  THEN
                     d_retval := 1;
                  END IF;

                  IF d_retval = 0
                  THEN
                     IF is_indirizzo_presente_aoo_uo (
                           p_id_documento,
                              NVL (d_destinatari_messaggio, '')
                           || ','
                           || NVL (d_destinatari_conoscenza_msg, ''),
                           'AO') = 1
                     THEN
                        d_retval := 1;
                     ELSE
                        IF is_indirizzo_presente_aoo_uo (
                              p_id_documento,
                                 NVL (d_destinatari_messaggio, '')
                              || ','
                              || NVL (d_destinatari_conoscenza_msg, ''),
                              'UO') = 0
                        THEN
                           d_retval := 1;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               IF d_retval = 0
               THEN
                  IF verifica_privilegio_utente (NULL,
                                                 G_PRIVILEGIO_PMAILU,
                                                 p_utente,
                                                 TRUNC (SYSDATE)) = 1
                  THEN
                     IF is_indirizzo_presente_aoo_uo (
                           p_id_documento,
                              NVL (d_destinatari_messaggio, '')
                           || ','
                           || NVL (d_destinatari_conoscenza_msg, ''),
                           'UO',
                           p_utente,
                           G_PRIVILEGIO_PMAILU) = 0
                     THEN
                        d_retval := 1;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN d_retval;
   END;

   FUNCTION modifica_messaggio_arrivo (p_id_documento    NUMBER,
                                       p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      d_stato_messaggio     agp_msg_ricevuti_dati_prot.stato%TYPE;
      d_codice_unita        so4_v_unita_organizzative_pubb.codice%TYPE;
      d_riservato           gdo_documenti.riservato%TYPE;
      d_stato_fascicolo     ags_fascicoli.stato_fascicolo%TYPE;
      d_priv_utente_mddep   NUMBER (1) := 1;
      d_priv_mtot           VARCHAR2 (100);
      d_priv_ms             VARCHAR2 (100);
      d_priv_mprot          VARCHAR2 (100);
      d_retval              NUMBER := 0;
   BEGIN
      BEGIN
         SELECT agp_msg_ricevuti_dati_prot.stato, gdo_documenti.riservato
           INTO d_stato_messaggio, d_riservato
           FROM agp_msg_ricevuti_dati_prot, gdo_documenti
          WHERE     agp_msg_ricevuti_dati_prot.id_documento = p_id_documento
                AND gdo_documenti.id_documento =
                       agp_msg_ricevuti_dati_prot.id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      BEGIN
         SELECT agp_msg_ricevuti_dati_prot.stato,
                so4_v_unita_organizzative_pubb.codice,
                gdo_documenti.riservato,
                ags_fascicoli.stato_fascicolo
           INTO d_stato_messaggio,
                d_codice_unita,
                d_riservato,
                d_stato_fascicolo
           FROM agp_msg_ricevuti_dati_prot,
                gdo_documenti_soggetti,
                so4_v_unita_organizzative_pubb,
                gdo_documenti,
                ags_fascicoli
          WHERE     agp_msg_ricevuti_dati_prot.id_documento = p_id_documento
                AND gdo_documenti_soggetti.id_documento = p_id_documento
                AND gdo_documenti_soggetti.tipo_soggetto = 'UO_MESSAGGIO'
                AND so4_v_unita_organizzative_pubb.ottica =
                       gdo_documenti_soggetti.unita_ottica
                AND so4_v_unita_organizzative_pubb.progr =
                       gdo_documenti_soggetti.unita_progr
                AND so4_v_unita_organizzative_pubb.dal =
                       gdo_documenti_soggetti.unita_dal
                AND gdo_documenti.id_documento =
                       agp_msg_ricevuti_dati_prot.id_documento
                AND agp_msg_ricevuti_dati_prot.id_fascicolo =
                       ags_fascicoli.id_documento(+);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_riservato = 'Y'
      THEN
         d_priv_mtot := G_PRIVILEGIO_MTOTR;
         d_priv_ms := G_PRIVILEGIO_MSR;
         d_priv_mprot := G_PRIVILEGIO_MPROTR;
      ELSE
         d_priv_mtot := G_PRIVILEGIO_MTOT;
         d_priv_ms := G_PRIVILEGIO_MS;
         d_priv_mprot := G_PRIVILEGIO_MPROT;
      END IF;

      IF    d_stato_messaggio <> G_GESTITO
         OR d_stato_messaggio <> G_GENERATA_ECCEZIONE
      THEN
         IF NVL (d_stato_fascicolo, '') = 'DEPOSITO'
         THEN
            d_priv_utente_mddep :=
               verifica_privilegio_utente (NULL,
                                           G_PRIVILEGIO_MDDEP,
                                           p_utente,
                                           TRUNC (SYSDATE));
         END IF;

         IF verifica_privilegio_utente (NULL,
                                        d_priv_mtot,
                                        p_utente,
                                        TRUNC (SYSDATE)) = 1
         THEN
            IF d_priv_utente_mddep = 1
            THEN
               d_retval := 1;
            END IF;
         END IF;

         IF d_retval = 0
         THEN
            IF verifica_privilegio_utente (d_codice_unita,
                                           d_priv_mprot,
                                           p_utente,
                                           TRUNC (SYSDATE)) = 1
            THEN
               IF d_priv_utente_mddep = 1
               THEN
                  d_retval := 1;
               END IF;
            END IF;
         END IF;

         IF d_retval = 0
         THEN
            IF is_ute_unit_smis_carico_eseg (p_id_documento,
                                             p_utente,
                                             d_priv_ms) = 1
            THEN
               IF d_priv_utente_mddep = 1
               THEN
                  d_retval := 1;
               END IF;
            END IF;
         END IF;
      ELSE
         d_retval := 1;
      END IF;

      RETURN d_retval;
   END;
END AGP_COMPETENZE_MESSAGGIO;
/
