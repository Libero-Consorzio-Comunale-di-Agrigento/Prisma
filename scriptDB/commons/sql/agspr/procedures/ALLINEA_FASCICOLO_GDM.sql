--liquibase formatted sql
--changeset mmalferrari:AGSPR_PROCEDURE_ALLINEA_FASCICOLO_GDM runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE allinea_fascicolo_gdm (
   p_operazione                  VARCHAR2,
   p_new_anno                    NUMBER,
   p_new_anno_archiviazione      NUMBER,
   p_new_anno_numero             VARCHAR2,
   p_new_data_apertura           VARCHAR2,
   p_new_data_archiviazione      VARCHAR2,
   p_new_data_chiusura           VARCHAR2,
   p_new_data_creazione          VARCHAR2   --, p_new_data_nulla_osta varchar2
                                         ,
   p_new_data_stato              VARCHAR2 --, p_new_data_stato_scarto varchar2
                                         --, p_new_dati_ripudio varchar2
   ,
   p_new_digitale                CHAR,
   p_new_id_classificazione      NUMBER,
   p_new_id_documento            NUMBER  --, p_new_id_documento_esterno number
                                       ,
   p_new_id_fascicolo_padre      NUMBER,
   p_new_idrif                   VARCHAR2,
   p_new_nome                    VARCHAR2,
   p_new_note                    VARCHAR2,
   p_new_numero                  VARCHAR2 --, p_new_numero_nulla_osta varchar2
                                         ,
   p_new_numero_ord              VARCHAR2,
   p_new_numero_prossimo_anno    CHAR,
   p_new_oggetto                 VARCHAR2,
   p_new_responsabile            VARCHAR2,
   p_new_riservato               CHAR,
   p_new_stato_fascicolo         VARCHAR2      --, p_new_stato_scarto varchar2
                                         ,
   p_new_sub                     NUMBER,
   p_new_topografia              VARCHAR2,
   p_new_ultimo_numero_sub       NUMBER  --, p_old_id_documento_esterno number
                                       ,
   p_old_id_fascicolo_padre      NUMBER)
--procedure che allinea il fascicolo su GDM
IS
   d_ret                          NUMBER;

   d_ufficio_creazione            VARCHAR2 (255);                  -- codiceUO
   d_ufficio_competenza           VARCHAR2 (255);                  -- codiceUO
   d_class_cod                    VARCHAR2 (255);
   d_class_dal                    DATE;
   d_class_al                     DATE;
   d_documento_padre              NUMBER;
   d_id_cartella                  NUMBER;
   d_id_cartella_padre            NUMBER;
   d_id_documento_esterno         NUMBER;
   d_id_gdm                       NUMBER (10);
   d_amministrazione              VARCHAR2 (255);
   d_aoo                          VARCHAR2 (255);
   d_documento_profilo_cartella   NUMBER;
   d_codice_richiesta_padre       NUMBER;
   d_ente                         NUMBER;
   d_cr_padre                     VARCHAR2 (255);
   d_anno_fascicolo_padre         NUMBER;
   d_numero_fascicolo_padre       VARCHAR2 (255);
   d_utente_creazione             VARCHAR2 (255);
   d_utente_modifica              VARCHAR2 (255);
   d_stato_scarto                 VARCHAR2 (255);
   d_numero_nulla_osta            VARCHAR2 (255);
   d_data_stato_scarto            DATE;
   d_data_nulla_osta              DATE;
BEGIN
   IF p_operazione = 'I' OR p_operazione = 'U'
   THEN
      -- calcolo id_ente (per amm e aoo), utente_creazione e utente_modifica
      SELECT id_ente, utente_ins, utente_upd
        INTO d_ente, d_utente_creazione, d_utente_modifica
        FROM gdo_documenti
       WHERE id_documento = p_new_id_documento;

      -- calcolo id_documento_esterno per idrif
      BEGIN
         SELECT id_documento
           INTO d_id_documento_esterno
           FROM gdm_fascicoli
          WHERE idrif = p_new_idrif;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_documento_esterno := NULL;
      END;

      -- calcolo amm e aoo
      SELECT amministrazione, aoo
        INTO d_amministrazione, d_aoo
        FROM gdo_enti
       WHERE id_ente = d_ente;

      -- recupero id_documento_profilo_cartella della classificazione
      SELECT id_documento_esterno
        INTO d_documento_profilo_cartella
        FROM ags_classificazioni
       WHERE id_classificazione = p_new_id_classificazione;

      -- recupero class_cod, class_dal e class_al
      BEGIN
         SELECT class_cod, class_dal, class_al
           INTO d_class_cod, d_class_dal, d_class_al
           FROM gdm_seg_classificazioni
          WHERE id_documento = d_documento_profilo_cartella;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_class_cod := NULL;
            d_class_dal := NULL;
            d_class_al := NULL;
      END;

      -- recupero codice di ufficio creazione e ufficio competenza
      BEGIN
         SELECT u.codice_uo
           INTO d_ufficio_creazione
           FROM so4_unita_organizzative_pubb u, gdo_documenti_soggetti s
          WHERE     s.unita_progr = u.progr_unita_organizzativa
                AND s.unita_dal = u.dal
                AND s.unita_ottica = u.ottica
                AND s.id_documento = p_new_id_documento
                AND s.tipo_soggetto = 'UO_CREAZIONE';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_ufficio_creazione := NULL;
      END;

      BEGIN
         SELECT u.codice_uo
           INTO d_ufficio_competenza
           FROM so4_unita_organizzative_pubb u, gdo_documenti_soggetti s
          WHERE     s.unita_progr = u.progr_unita_organizzativa
                AND s.unita_dal = u.dal
                AND s.unita_ottica = u.ottica
                AND s.id_documento = p_new_id_documento
                AND s.tipo_soggetto = 'UO_COMPETENZA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_ufficio_competenza := NULL;
      END;

      -- recupero le informazioni dati scarto
      BEGIN
         SELECT sc.codice_gdm,
                ds.data_stato,
                ds.nulla_osta,
                ds.data_nulla_osta
           INTO d_stato_scarto,
                d_data_stato_scarto,
                d_numero_nulla_osta,
                d_data_nulla_osta
           FROM ags_fascicoli f,
                agp_documenti_dati_scarto ds,
                agp_stati_scarto sc
          WHERE     f.id_documento_dati_scarto = ds.id_documento_dati_scarto
                AND sc.codice = ds.stato
                AND f.id_documento = p_new_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_stato_scarto := NULL;
            d_numero_nulla_osta := NULL;
            d_data_stato_scarto := NULL;
            d_data_nulla_osta := NULL;
      END;

      IF p_new_id_fascicolo_padre IS NOT NULL
      THEN
         BEGIN
            SELECT id_documento_esterno
              INTO d_documento_padre
              FROM gdo_documenti
             WHERE id_documento = p_new_id_fascicolo_padre;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_documento_padre := NULL;
         END;

         IF d_documento_padre <> NULL
         THEN
            SELECT fascicolo_anno, fascicolo_numero, d.codice_richiesta
              INTO d_anno_fascicolo_padre,
                   d_numero_fascicolo_padre,
                   d_cr_padre
              FROM gdm_fascicoli f, gdm_documenti d
             WHERE     d.id_documento = f.id_documento
                   AND d.stato_documento = 'BO'
                   AND f.id_documento = d_documento_padre;
         END IF;
      END IF;
   END IF;

   IF p_operazione = 'I'
   THEN
      BEGIN
         --recupero la cartella padre
         --
         IF     p_new_id_fascicolo_padre IS NOT NULL
            AND d_documento_padre IS NOT NULL
         THEN
            BEGIN
               SELECT id_cartella
                 INTO d_id_cartella_padre
                 FROM gdm_cartelle
                WHERE id_documento_profilo = d_documento_padre;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_id_cartella_padre := NULL;
            END;

            BEGIN
               SELECT codice_richiesta
                 INTO d_codice_richiesta_padre
                 FROM gdm_documenti
                WHERE id_documento = d_documento_padre;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_codice_richiesta_padre := NULL;
            END;
         END IF;

         --se non ho trovato la cartella padre, su gdm inserisco il documento nella cartella della classifica
         IF d_id_cartella_padre IS NULL
         THEN
            BEGIN
               SELECT id_cartella
                 INTO d_id_cartella_padre
                 FROM gdm_cartelle
                WHERE id_documento_profilo = d_documento_profilo_cartella;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_id_cartella_padre := NULL;
            END;
         END IF;

         d_id_cartella :=
            gdm_gdm_cartelle.crea_cartella (
               'SEGRETERIA',
               'FASCICOLO',
               SUBSTR (p_new_anno_numero || ' - ' || p_new_oggetto, 0, 100),
               d_id_cartella_padre,
               d_utente_creazione);

         SELECT id_documento_profilo
           INTO d_id_gdm
           FROM gdm_cartelle
          WHERE id_cartella = d_id_cartella;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20999,
               'Errore in GDM_PROFILO.CREA_CARTELLA: ' || SQLERRM);
      END;

      DBMS_OUTPUT.put_line (
         'creati id_doc ' || d_id_gdm || ' per cartella id ' || d_id_cartella);

      INSERT INTO gdm_fascicoli (id_documento,
                                 ANNO_ARCHIVIAZIONE,
                                 ANNO_FASCICOLO_PADRE,
                                 ANNO_MASSIMO_SCARTO,
                                 ANNO_MINIMO_SCARTO,
                                 ANNO_RICHIESTA_SCARTO,
                                 ARCHIVIO_DIGITALE,
                                 BASE_NORMATIVA,
                                 CALCOLA_NOME,
                                 CLASS_AL,
                                 CLASS_COD,
                                 CLASS_DAL,
                                 CODICE_AMMINISTRAZIONE,
                                 CODICE_AOO,
                                 CR_PADRE,
                                 CREATA_CARTELLA,
                                 DATA_APERTURA,
                                 DATA_ARCHIVIAZIONE,
                                 DATA_CHIUSURA,
                                 DATA_CREAZIONE,
                                 DATA_NULLA_OSTA,
                                 DATA_STATO,
                                 DATA_STATO_SCARTO             --,DATI_RIPUDIO
                                                  ,
                                 DESC_PROCEDIMENTO,
                                 DESCRIZIONE_CLASSIFICA,
                                 DESCRIZIONE_CLASSIFICA_VISU,
                                 DESCRIZIONE_SCARTO,
                                 DESCRIZIONE_UFFICIO_COMPETENZA,
                                 FASCICOLO_ANNO,
                                 FASCICOLO_NUMERO,
                                 FASCICOLO_OGGETTO,
                                 ID_UNIVOCO_PERSONALE,
                                 IDRIF,
                                 NOME,
                                 NOTE,
                                 NUMERAZIONE_AUTOMATICA,
                                 NUMERO_FASCICOLO_PADRE,
                                 NUMERO_NULLA_OSTA,
                                 OSSERVAZIONI_SCARTO,
                                 PESO_SCARTO,
                                 PEZZI_SCARTO,
                                 PROCEDIMENTO,
                                 RESPONSABILE,
                                 RISERVATO,
                                 STATO_FASCICOLO,
                                 STATO_SCARTO,
                                 SUB,
                                 TOPOGRAFIA,
                                 UBICAZIONE_SCARTO,
                                 UFF_ASSEGNATARIO,
                                 UFFICIO_COMPETENZA,
                                 UFFICIO_CREAZIONE,
                                 ULTIMO_NUMERO_SUB,
                                 UTENTE_CREAZIONE,
                                 UTENTE_SESSIONE)
              VALUES (
                        d_id_gdm                               -- ID_DOCUMENTO
                                ,
                        p_new_anno_archiviazione         -- ANNO_ARCHIVIAZIONE
                                                ,
                        d_anno_fascicolo_padre         -- ANNO_FASCICOLO_PADRE
                                              ,
                        NULL                            -- ANNO_MASSIMO_SCARTO
                            ,
                        NULL                             -- ANNO_MINIMO_SCARTO
                            ,
                        NULL                          -- ANNO_RICHIESTA_SCARTO
                            ,
                        p_new_digitale                    -- ARCHIVIO_DIGITALE
                                      ,
                        NULL                                 -- BASE_NORMATIVA
                            ,
                        NULL                                   -- CALCOLA_NOME
                            ,
                        d_class_al                                 -- CLASS_AL
                                  ,
                        d_class_cod                               -- CLASS_COD
                                   ,
                        d_class_dal                               -- CLASS_DAL
                                   ,
                        d_amministrazione            -- CODICE_AMMINISTRAZIONE
                                         ,
                        d_aoo                                    -- CODICE_AOO
                             ,
                        d_cr_padre                                 -- CR_PADRE
                                  ,
                        'Y'                                 -- CREATA_CARTELLA
                           ,
                        TO_DATE (p_new_data_apertura, 'dd/mm/yyyy') -- DATA_APERTURA
                                                                   ,
                        TO_DATE (p_new_data_archiviazione, 'dd/mm/yyyy') -- DATA_ARCHIVIAZIONE
                                                                        ,
                        TO_DATE (p_new_data_chiusura, 'dd/mm/yyyy') -- DATA_CHIUSURA
                                                                   ,
                        TO_DATE (p_new_data_creazione, 'dd/mm/yyyy') -- DATA_CREAZIONE
                                                                    ,
                        TO_DATE (d_data_nulla_osta, 'dd/mm/yyyy') -- DATA_NULLA_OSTA
                                                                 ,
                        TO_DATE (p_new_data_stato, 'dd/mm/yyyy hh:mi:ss') -- DATA_STATO
                                                                         ,
                        TO_DATE (d_data_stato_scarto, 'dd/mm/yyyy hh:mi:ss') -- DATA_STATO_SCARTO
                                                                            --, p_new_dati_ripudio                             -- DATI_RIPUDIO
                        ,
                        NULL                              -- DESC_PROCEDIMENTO
                            ,
                        NULL                         -- DESCRIZIONE_CLASSIFICA
                            ,
                        NULL                    -- DESCRIZIONE_CLASSIFICA_VISU
                            ,
                        NULL                             -- DESCRIZIONE_SCARTO
                            ,
                        NULL                 -- DESCRIZIONE_UFFICIO_COMPETENZA
                            ,
                        p_new_anno                           -- FASCICOLO_ANNO
                                  ,
                        p_new_numero --decode(p_new_numero,'',null)                                    -- FASCICOLO_NUMERO
                                    ,
                        p_new_oggetto                     -- FASCICOLO_OGGETTO
                                     ,
                        NULL                           -- ID_UNIVOCO_PERSONALE
                            ,
                        p_new_idrif                                   -- IDRIF
                                   ,
                        p_new_nome                                     -- NOME
                                  ,
                        p_new_note                                     -- NOTE
                                  ,
                        p_new_numero_prossimo_anno   -- NUMERAZIONE_AUTOMATICA
                                                  ,
                        d_numero_fascicolo_padre     -- NUMERO_FASCICOLO_PADRE
                                                ,
                        d_numero_nulla_osta               -- NUMERO_NULLA_OSTA
                                           ,
                        NULL                            -- OSSERVAZIONI_SCARTO
                            ,
                        NULL                                    -- PESO_SCARTO
                            ,
                        NULL                                   -- PEZZI_SCARTO
                            ,
                        NULL                                   -- PROCEDIMENTO
                            ,
                        p_new_responsabile                     -- RESPONSABILE
                                          ,
                        p_new_riservato                           -- RISERVATO
                                       ,
                        --  p_new_stato_fascicolo                    -- STATO_FASCICOLO
                        DECODE (p_new_stato_fascicolo,
                                'CORRENTE', '1',
                                'DEPOSITO', '2',
                                'STORICO', '3',
                                '1'),
                        d_stato_scarto                         -- STATO_SCARTO
                                      ,
                        p_new_sub                                       -- SUB
                                 ,
                        p_new_topografia                         -- TOPOGRAFIA
                                        ,
                        NULL                              -- UBICAZIONE_SCARTO
                            ,
                        NULL                               -- UFF_ASSEGNATARIO
                            ,
                        d_ufficio_competenza                            -- UFF
                                            ,
                        d_ufficio_creazione               -- UFFICIO_CREAZIONE
                                           ,
                        p_new_ultimo_numero_sub           -- ULTIMO_NUMERO_SUB
                                               ,
                        d_utente_creazione                 -- UTENTE_CREAZIONE
                                          ,
                        d_utente_modifica);                 -- UTENTE_SESSIONE
   END IF;

   IF p_operazione = 'U'
   THEN
      --se non ho id_documento_esterno non lo modifico (in fase di creazione la funzione viene chiamata due volte, in insert e in update)
      -- if (p_new_id_documento_esterno is null) and (p_old_id_documento_esterno is not null) then
      --    update ags_fascicoli_new
      --       set id_documento_esterno   = p_old_id_documento_esterno
      --     where id_documento = p_new_id_documento;
      -- end if;

      DBMS_OUTPUT.put_line ('aggiorno id_doc ' || d_id_documento_esterno);
      DBMS_OUTPUT.put_line ('UPDATE gdm_fascicoli');
      DBMS_OUTPUT.put_line (
         'SET ANNO_ARCHIVIAZIONE = ' || p_new_anno_archiviazione || ',');
      DBMS_OUTPUT.put_line (
         'ANNO_FASCICOLO_PADRE = ' || d_anno_fascicolo_padre || ',');
      DBMS_OUTPUT.put_line (
         'ARCHIVIO_DIGITALE = ''' || p_new_digitale || ''',');
      DBMS_OUTPUT.put_line (
            ' CLASS_AL = TO_DATE('''
         || TO_CHAR (d_class_al, 'DD/MM/YYYY')
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (' CLASS_COD = ''' || d_class_cod || ''',');
      DBMS_OUTPUT.put_line (
            ' CLASS_DAL = TO_DATE('''
         || TO_CHAR (d_class_dal, 'DD/MM/YYYY')
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (
         ' CODICE_AMMINISTRAZIONE = ''' || d_amministrazione || ''',');
      DBMS_OUTPUT.put_line ('CODICE_AOO = ''' || d_aoo || ''',');
      DBMS_OUTPUT.put_line (' CR_PADRE = ''' || d_cr_padre || ''',');
      DBMS_OUTPUT.put_line (' CREATA_CARTELLA = ''Y'',');
      DBMS_OUTPUT.put_line (
            ' DATA_APERTURA = TO_DATE ('''
         || p_new_data_apertura
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (
            ' DATA_ARCHIVIAZIONE = TO_DATE ('''
         || p_new_data_archiviazione
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (
            ' DATA_CHIUSURA = TO_DATE ('''
         || p_new_data_chiusura
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (
            ' DATA_CREAZIONE = TO_DATE ('''
         || p_new_data_creazione
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (
            ' DATA_NULLA_OSTA = TO_DATE ('''
         || d_data_nulla_osta
         || ''', ''dd/mm/yyyy''),');
      DBMS_OUTPUT.put_line (
            ' DATA_STATO = TO_DATE ('''
         || p_new_data_stato
         || ''', ''dd/mm/yyyy hh:mi:ss''),');
      DBMS_OUTPUT.put_line (
            'DATA_STATO_SCARTO = TO_DATE ('''
         || d_data_stato_scarto
         || ''', ''dd/mm/yyyy hh:mi:ss''),');
      DBMS_OUTPUT.put_line ('FASCICOLO_ANNO = ' || p_new_anno || ',');
      DBMS_OUTPUT.put_line ('FASCICOLO_NUMERO = ''' || p_new_numero || ''',');
      DBMS_OUTPUT.put_line (
         'FASCICOLO_OGGETTO = ''' || p_new_oggetto || ''',');
      DBMS_OUTPUT.put_line ('IDRIF = ''' || p_new_idrif || ''',');
      DBMS_OUTPUT.put_line (' NOME = ''' || p_new_nome || ''',');
      DBMS_OUTPUT.put_line (' NOTE = ''' || p_new_note || ''',');
      DBMS_OUTPUT.put_line (
            ' NUMERAZIONE_AUTOMATICA = '''
         || p_new_numero_prossimo_anno
         || ''',');
      DBMS_OUTPUT.put_line (
         ' NUMERO_FASCICOLO_PADRE = ''' || d_numero_fascicolo_padre || ''',');
      DBMS_OUTPUT.put_line (
         ' NUMERO_NULLA_OSTA = ''' || d_numero_nulla_osta || ''',');
      DBMS_OUTPUT.put_line (
         ' RESPONSABILE = ''' || p_new_responsabile || ''',');
      DBMS_OUTPUT.put_line (' RISERVATO = ''' || p_new_riservato || ''',');
      DBMS_OUTPUT.put_line (
         ' STATO_FASCICOLO = ''' || p_new_stato_fascicolo || ''',');
      DBMS_OUTPUT.put_line (' STATO_SCARTO = ''' || d_stato_scarto || ''',');
      DBMS_OUTPUT.put_line (' SUB = ' || p_new_sub || ',');
      DBMS_OUTPUT.put_line (' TOPOGRAFIA = ''' || p_new_topografia || ''',');
      DBMS_OUTPUT.put_line (
         ' UFFICIO_COMPETENZA = ''' || d_ufficio_competenza || ''',');
      DBMS_OUTPUT.put_line (
         ' UFFICIO_CREAZIONE = ''' || d_ufficio_creazione || ''',');
      DBMS_OUTPUT.put_line (
         ' ULTIMO_NUMERO_SUB = ' || p_new_ultimo_numero_sub || ',');
      DBMS_OUTPUT.put_line (
         ' UTENTE_CREAZIONE = ''' || d_utente_creazione || ''',');
      DBMS_OUTPUT.put_line (
         ' UTENTE_SESSIONE = ''' || d_utente_modifica || '''');
      DBMS_OUTPUT.put_line (
         '  WHERE id_documento = ' || d_id_documento_esterno || ';');

      UPDATE gdm_fascicoli
         SET ANNO_ARCHIVIAZIONE = p_new_anno_archiviazione,
             ANNO_FASCICOLO_PADRE = d_anno_fascicolo_padre,
             ANNO_MASSIMO_SCARTO = NULL,
             ANNO_MINIMO_SCARTO = NULL,
             ANNO_RICHIESTA_SCARTO = NULL,
             ARCHIVIO_DIGITALE = p_new_digitale,
             BASE_NORMATIVA = NULL,
             CALCOLA_NOME = NULL,
             CLASS_AL = d_class_al,
             CLASS_COD = d_class_cod,
             CLASS_DAL = d_class_dal,
             CODICE_AMMINISTRAZIONE = d_amministrazione,
             CODICE_AOO = d_aoo,
             CR_PADRE = d_cr_padre,
             CREATA_CARTELLA = 'Y',
             DATA_APERTURA = TO_DATE (p_new_data_apertura, 'dd/mm/yyyy'),
             DATA_ARCHIVIAZIONE =
                TO_DATE (p_new_data_archiviazione, 'dd/mm/yyyy'),
             DATA_CHIUSURA = TO_DATE (p_new_data_chiusura, 'dd/mm/yyyy'),
             DATA_CREAZIONE = TO_DATE (p_new_data_creazione, 'dd/mm/yyyy'),
             DATA_NULLA_OSTA = TO_DATE (d_data_nulla_osta, 'dd/mm/yyyy'),
             DATA_STATO = TO_DATE (p_new_data_stato, 'dd/mm/yyyy hh:mi:ss'),
             DATA_STATO_SCARTO =
                TO_DATE (d_data_stato_scarto, 'dd/mm/yyyy hh:mi:ss'),
             -- DATI_RIPUDIO =    p_new_dati_ripudio,
             DESC_PROCEDIMENTO = NULL,
             DESCRIZIONE_CLASSIFICA = NULL,
             DESCRIZIONE_CLASSIFICA_VISU = NULL,
             DESCRIZIONE_SCARTO = NULL,
             DESCRIZIONE_UFFICIO_COMPETENZA = NULL,
             FASCICOLO_ANNO = p_new_anno,
             FASCICOLO_NUMERO = p_new_numero,
             FASCICOLO_OGGETTO = p_new_oggetto,
             ID_UNIVOCO_PERSONALE = NULL,
             IDRIF = p_new_idrif,
             NOME = p_new_nome,
             NOTE = p_new_note,
             NUMERAZIONE_AUTOMATICA = p_new_numero_prossimo_anno,
             NUMERO_FASCICOLO_PADRE = d_numero_fascicolo_padre,
             NUMERO_NULLA_OSTA = d_numero_nulla_osta,
             OSSERVAZIONI_SCARTO = NULL,
             PESO_SCARTO = NULL,
             PEZZI_SCARTO = NULL,
             PROCEDIMENTO = NULL,
             RESPONSABILE = p_new_responsabile,
             RISERVATO = p_new_riservato,
             STATO_FASCICOLO =
                DECODE (p_new_stato_fascicolo,
                        'CORRENTE', '1',
                        'DEPOSITO', '2',
                        'STORICO', '3',
                        '1'),
             STATO_SCARTO = d_stato_scarto,
             SUB = p_new_sub,
             TOPOGRAFIA = p_new_topografia,
             UBICAZIONE_SCARTO = NULL,
             UFF_ASSEGNATARIO = NULL,
             UFFICIO_COMPETENZA = d_ufficio_competenza,
             UFFICIO_CREAZIONE = d_ufficio_creazione,
             ULTIMO_NUMERO_SUB = p_new_ultimo_numero_sub,
             UTENTE_CREAZIONE = d_utente_creazione,
             UTENTE_SESSIONE = d_utente_modifica
       WHERE id_documento = d_id_documento_esterno;

      DBMS_OUTPUT.put_line (
         'aggiorno descrizione  cartella id' || d_id_documento_esterno);

      --Aggiorno la descrizione della cartella
      UPDATE gdm_cartelle
         SET nome =
                SUBSTR (p_new_anno_numero || ' - ' || p_new_oggetto, 1, 100)
       WHERE id_documento_profilo = d_id_documento_esterno;

      DBMS_OUTPUT.put_line (
         'aggiorno date e utente agg documento id' || d_id_documento_esterno);

      UPDATE gdm_documenti
         SET data_aggiornamento = SYSDATE,
             utente_aggiornamento = d_utente_modifica
       WHERE id_documento = d_id_documento_esterno;

      DBMS_OUTPUT.put_line (
            'aggiorno id_documento_esterno in gdo_documenti per id'
         || p_new_id_documento);

      UPDATE gdo_documenti
         SET id_documento_esterno = d_id_documento_esterno
       WHERE id_documento = p_new_id_documento;
   END IF;
END;
/
