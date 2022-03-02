--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_CREA_TRIGGER_PROTO runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_crea_trigger_proto
IS
   p_categoria          VARCHAR2(100) := 'PROTO';
   depnometabella       VARCHAR2 (30);
   depstmt              VARCHAR2 (32000);
   depacronimotabella   VARCHAR2 (30);
   depregistro          VARCHAR2 (100);
   deptriggername       VARCHAR2 (100);
   FUNCTION get_acronimo_tabella (p_area VARCHAR2, p_codice_modello VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   tipi_documento.acronimo_modello%TYPE;
   BEGIN
      BEGIN
         SELECT UPPER (t.acronimo_modello)
           INTO retval
           FROM aree a, tipi_documento t
          WHERE a.area = t.area_modello
            AND a.acronimo IS NOT NULL
            AND t.alias_modello IS NOT NULL
            AND t.area_modello = p_area
            AND t.nome = p_codice_modello;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := '';
      END;
      RETURN retval;
   END;
   FUNCTION check_tipo_documento_registro (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
   BEGIN
      IF p_nome_tabella IN
            ('SPR_PROTOCOLLI',
             'SPR_PROTOCOLLI_INTERO',
             'SPR_PROTOCOLLI_EMERGENZA',
             'SPR_LETTERE_USCITA'
            )
      THEN
         depstmt :=  '   IF :NEW.tipo_documento IS NOT NULL and :NEW.numero IS NOT NULL and :OLD.numero IS NULL AND :NEW.utenti_firma <> ''@@TRASCO@@'' THEN'
                  || '      declare'
                  || '         d_tipo_reg_doc varchar2(100);'
                  || '      begin'
                  || '         select tipo_registro_documento'
                  || '           into d_tipo_reg_doc'
                  || '           from seg_tipi_documento tido, '
                  || '                documenti docu_tido'
                  || '          where tipo_documento = :NEW.tipo_documento'
                  || '            AND docu_tido.id_documento = tido.id_documento'
                  || '            AND docu_tido.stato_documento NOT IN (''CA'', ''RE'', ''PB'')'
                  || '            AND nvl(tido.codice_amministrazione, :NEW.codice_amministrazione) = :NEW.codice_amministrazione'
                  || '            AND nvl(tido.codice_aoo, :NEW.codice_aoo) = :NEW.codice_aoo'
                  || '            AND NVL(:NEW.data, TRUNC (SYSDATE))'
                  || '                    BETWEEN NVL (tido.dataval_dal, TO_DATE (2222222, ''j''))'
                  || '                        AND NVL (tido.dataval_al, TO_DATE (3333333, ''j''))'
                  || '         ;'
                  || '         if nvl(d_tipo_reg_doc, :NEW.tipo_registro) <> :NEW.tipo_registro then'
                  || '            raise_application_error(-20999,''Tipo documento ''''''||:NEW.tipo_documento||'''''' non valido per registro ''''''||:NEW.tipo_registro||''''''.'');'
                  || '         end if;'
                  || '      exception'
                  || '         when no_data_found then'
                  || '            raise_application_error(-20999,''Tipo documento ''''''||:NEW.tipo_documento||'''''' non esistente o non valido.'');'
                  || '         when others then'
                  || '            raise;'
                  || '      end;'
                  || '      if :NEW.utenti_firma = ''@@TRASCO@@'' then'
                  || '         :NEW.utenti_firma := null;'
                  || '      end if;'
                  || '   END IF;';
      END IF;
      RETURN depstmt;
   END;
   FUNCTION get_trigger_leus (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
/******************************************************************************
   NAME:       get_trigger_leus
   PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/03/2010         1. AA36823.0.0
******************************************************************************/
   BEGIN
      IF p_nome_tabella = 'SPR_LETTERE_USCITA'
      THEN
         depstmt :=
               'IF NVL (:NEW.so4_dirigente, ''*'') != NVL (:OLD.so4_dirigente, ''*'')'
            || '   AND :NEW.so4_dirigente IS NOT NULL '
            || 'THEN'
            || '   DECLARE'
            || '   dep_nome      VARCHAR2 (32000);'
            || '   dep_cognome   VARCHAR2 (32000);'
            || '   BEGIN'
            || '      dep_nome :=ag_utilities_flusso_lettera.get_nome_utente (:NEW.so4_dirigente);'
            || '      dep_cognome :=ag_utilities_flusso_lettera.get_cognome_utente(:NEW.so4_dirigente);'
            || '      IF NVL (dep_nome, ''*'') != ''*'''
            || '      THEN'
            || '         :NEW.dirigente := dep_cognome || '' '' || dep_nome;'
            || '         :NEW.dirigente_nome_cognome := dep_nome || '' '' || dep_cognome;'
            || '      ELSE'
            || '         :NEW.dirigente := dep_cognome;'
            || '         :NEW.dirigente_nome_cognome := dep_cognome;'
            || '      END IF;'
            || '   END;'
            || 'END IF;';
      END IF;
      RETURN depstmt;
   END;
   FUNCTION get_trigger_prin (p_nome_tabella VARCHAR2)
      RETURN VARCHAR2
   IS
      depstmt   VARCHAR2 (32000) := '';
/******************************************************************************
   NAME:       get_trigger_prin
   PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/03/2010         1. AA36823.0.0
******************************************************************************/
   BEGIN
      IF p_nome_tabella = 'SPR_PROTOCOLLI_INTERO'
      THEN
         depstmt :=
               ' IF     :NEW.anno IS NOT NULL '
            || 'AND :NEW.numero IS NOT NULL '
            || 'AND :NEW.numero <> NVL (:OLD.numero, 0) THEN '
            || 'DECLARE '
            || 'id_memo   NUMBER; '
            || ' BEGIN '
            || '  SELECT id_documento_rif '
            || '    INTO id_memo '
            || '    FROM riferimenti '
            || '   WHERE id_documento = :NEW.id_documento AND tipo_relazione in (''FAX'', ''MAIL''); '
            || ' UPDATE seg_memo_protocollo '
            || '    SET stato_memo = ''PR'' '
            || '  WHERE id_documento = id_memo; '
            || ' EXCEPTION '
            || '      WHEN OTHERS THEN '
            || '      NULL; '
            || ' END; '
            || 'END IF;'
            || 'IF :NEW.numero IS NULL THEN '
            || 'DECLARE '
            || 'id_memo          NUMBER; '
            || 'con_segnatura    NUMBER       := 0; '
            || 'dep_stato_memo   VARCHAR2 (3) := ''DPS''; '
            || ' BEGIN '
            || '   SELECT id_documento_rif '
            || '     INTO id_memo '
            || '     FROM riferimenti '
            || '    WHERE id_documento = :NEW.id_documento AND tipo_relazione in (''FAX'', ''MAIL''); '
            || ' BEGIN '
            || '   SELECT ''DP'' '
            || '     INTO dep_stato_memo '
            || '     FROM oggetti_file '
            || '    WHERE id_documento = id_memo '
            || '      AND UPPER (filename) IN '
            || '          (''SEGNATURA.XML'', ''SEGNATURA_CITTADINO.XML''); '
            || ' EXCEPTION '
            || '      WHEN OTHERS THEN '
            || '      NULL; '
            || ' END; '
            || ' UPDATE seg_memo_protocollo '
            || '    SET stato_memo = dep_stato_memo '
            || '  WHERE id_documento = id_memo; '
            || ' EXCEPTION '
            || ' WHEN OTHERS THEN '
            || ' NULL; '
            || ' END; '
            || 'END IF; ';
      END IF;
      RETURN depstmt;
   END;
   PROCEDURE crea_trigger_proto_tb_tc (p_nome_tabella VARCHAR2)
   IS
      depstmt   VARCHAR2 (32000) := '';
/******************************************************************************
   NAME:       get_trigger_leus
   PURPOSE: Crea la stringa specifica per i trigger su SPR_LETTERE_USCITA.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/03/2010         1. AA36823.0.0
******************************************************************************/
   BEGIN
      DBMS_OUTPUT.put_line ('1');
      DBMS_OUTPUT.put_line ('2');
      depstmt :=
            'CREATE OR REPLACE TRIGGER AG_'
         || p_nome_tabella
         || '_TB '
         || 'BEFORE INSERT OR UPDATE OR DELETE ON '
         || p_nome_tabella
         || ' '
         || 'BEGIN '
         || 'IF INTEGRITYPACKAGE.GETNESTLEVEL = 0 THEN '
         || 'INTEGRITYPACKAGE.INITNESTLEVEL; '
         || 'END IF; '
         || 'END;';
      DBMS_OUTPUT.put_line (depstmt);
      EXECUTE IMMEDIATE depstmt;
      DBMS_OUTPUT.put_line ('4');
      depstmt :=
            'CREATE OR REPLACE TRIGGER AG_'
         || p_nome_tabella
         || '_TC '
         || 'AFTER INSERT OR UPDATE OR DELETE ON '
         || p_nome_tabella
         || ' '
         || 'BEGIN '
         || 'INTEGRITYPACKAGE.EXEC_POSTEVENT; '
         || 'END;';
      DBMS_OUTPUT.put_line ('5');
      EXECUTE IMMEDIATE depstmt;
      DBMS_OUTPUT.put_line ('6');
   END;
BEGIN
   IF p_categoria = 'PROTO'
   THEN
      FOR c_categorie IN (SELECT area, codice_modello
                            FROM categorie_modello
                           WHERE categoria = p_categoria)
      LOOP
         depacronimotabella :=
            SUBSTR
               (get_acronimo_tabella
                                                (c_categorie.area,
                                                 c_categorie.codice_modello
                                                ),
                2
               );
         depnometabella :=
              f_nome_tabella (c_categorie.area, c_categorie.codice_modello);
         IF depnometabella IS NOT NULL
         THEN
            BEGIN
               IF INSTR (c_categorie.area, 'SEGRETERIA.ATTI') > 0 OR INSTR (c_categorie.area, 'SEGRETERIA') = 0
               THEN
                  depregistro := 'null';
               ELSE
                  depregistro := ':NEW.tipo_registro';
               END IF;
               deptriggername :=
                          'ag_' || SUBSTR (depnometabella, 1, 23)
                          || '_tiu ';
               DBMS_OUTPUT.put_line ('1 '||deptriggername);
               -- creazione trigger per valorizzara id_documento_protocollo
               BEGIN
                  depstmt := 'DROP TRIGGER ' || deptriggername;
                  EXECUTE IMMEDIATE depstmt;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
               depstmt :=
                     'CREATE TRIGGER '
                  || deptriggername
                  || ' BEFORE INSERT or UPDATE ON '
                  || depnometabella
                  || ' FOR EACH ROW '
                  || ' BEGIN '
                  || ' if :new.numero is not null and (:new.anno is null or :new.tipo_registro is null ';
               declare
                  d_exists_campo number := 0;
               begin
                  execute immediate 'select count(1) from user_tab_columns where table_name = '''||depnometabella||''' and column_name = ''STATO_PR''' INTO d_exists_campo;
                  IF d_exists_campo = 1 THEN
                     depstmt := depstmt || 'or :new.stato_pr = ''DP''';
                  END IF;
               END;
               depstmt := depstmt
                  || ') then'
                  || ' :new.numero := null;'
                  || ' end if;'
                  || ' IF :NEW.anno IS NOT NULL AND :NEW.numero IS NOT NULL AND :NEW.numero <>  nvl(:OLD.numero, 0) THEN'
                  || ' ag_utilities_protocollo.check_unicita('''
                  || depnometabella
                  || ''', :NEW.anno, '
                  || depregistro
                  || ', :NEW.numero, :NEW.id_documento);'
                  || ' ag_utilities_protocollo.ins_proto_key(:NEW.anno, '
                  || depregistro
                  || ', :NEW.numero);'
                  || ' END IF;';
               DECLARE
                  d_exists_campo   NUMBER := 0;
               BEGIN
                  EXECUTE IMMEDIATE    'select count(1) from user_tab_columns where table_name = '''
                                    || depnometabella
                                    || ''' and column_name = ''STATO_SCARTO'''
                               INTO d_exists_campo;
                  IF d_exists_campo = 1
                  THEN
                     depstmt :=
                           depstmt
                        || ' if nvl(:new.stato_scarto,''**'') <> nvl(:old.stato_scarto,''**'') then'
                        || ' :new.data_stato_scarto := sysdate;'
                        || ' end if;';
                  END IF;
                  EXECUTE IMMEDIATE    'select count(1) from user_tab_columns where table_name = '''
                                    || depnometabella
                                    || ''' and column_name = ''UNITA_ESIBENTE'''
                               INTO d_exists_campo;
                  IF d_exists_campo = 1
                  THEN
                     depstmt :=
                           depstmt
                        || ' IF :new.modalita = ''ARR'' THEN '
                        || ' :new.unita_esibente := null; '
                        || ' END IF; ';
                  END IF;
                  EXECUTE IMMEDIATE    'select count(1) from user_tab_columns where table_name = '''
                                    || depnometabella
                                    || ''' and column_name = ''DATA_ARRIVO'''
                               INTO d_exists_campo;
                  IF d_exists_campo = 1
                  THEN
                     depstmt :=
                           depstmt
                        || ' IF :new.modalita <> ''ARR'' THEN '
                        || ' :new.data_arrivo := null; ';
                     EXECUTE IMMEDIATE    'select count(1) from user_tab_columns where table_name = '''
                                       || depnometabella
                                       || ''' and column_name = ''RACCOMANDATA_NUMERO'''
                                  INTO d_exists_campo;
                     IF d_exists_campo = 1
                     THEN
                        depstmt :=
                           depstmt
                           || ' :new.raccomandata_numero := null; ';
                     END IF;
                     depstmt := depstmt || ' END IF; ';
                  END IF;
               END;
               IF INSTR (c_categorie.area, 'SEGRETERIA.ATTI') = 0 AND INSTR (c_categorie.area, 'SEGRETERIA') > 0
               THEN
                  depstmt :=
                        depstmt
                     || ' IF (:NEW.id_documento_protocollo IS NULL) THEN '
                     || ' :NEW.id_documento_protocollo := :NEW.id_documento; '
                     || ' END IF; '
                     || ' IF (:NEW.numero IS NOT NULL AND :OLD.numero IS NULL) THEN '
                     || ' BEGIN '
                     || ' DECLARE '
                     || ' a_messaggio    VARCHAR2 (32000); '
                     || ' a_istruzione   VARCHAR2 (32000); '
                     || ' BEGIN '
                     || ' a_messaggio := '
                     || ' ''Errore in aggiornamento smistamenti associati a documento '' '
                     || ' || :NEW.id_documento '
                     || ' || ''.''; '
                     || ' a_istruzione := '
                     || ' ''begin ag_smistamento.upd_data_attivazione('''''' '
                     || ' || :NEW.idrif '
                     || ' || '''''', '''''' '
                     || ' || TO_CHAR (:NEW.data, ''dd/mm/yyyy hh24:mi:ss'') '
                     || ' || ''''''); end; ''; '
                     || ' integritypackage.set_postevent (a_istruzione, a_messaggio); '
                     || ' END; '
                     || ' EXCEPTION '
                     || ' WHEN OTHERS '
                     || ' THEN '
                     || ' raise_application_error (-20999, '
                     || ' ''Fallito aggiornamento:'' || SQLERRM); '
                     || ' END; '
                     || ' END IF; '
                     || '  IF NVL (:old.numero , 0) > 0 AND :OLD.DATA is not null '
                     || '  THEN '
                     || '     IF NVL (:NEW.DATA, TO_DATE (''01/01/1900'', ''dd/mm/yyyy'')) != '
                     || '        NVL (:OLD.DATA, TO_DATE (''01/01/1900'', ''dd/mm/yyyy'')) THEN '
                     || '            raise_application_error(-20999, ''Non e'''' consentito modificare la data di protocollo.'');'
                     || '     END IF;'
                     || '     IF NVL (:NEW.numero, 0) != NVL (:OLD.numero, 0) THEN '
                     || '            raise_application_error(-20999, ''Non e'''' consentito modificare il numero di protocollo.'');'
                     || '     END IF; '
                     || '     IF NVL (:NEW.anno, 0) != NVL (:OLD.anno, 0) THEN '
                     || '            raise_application_error(-20999, ''Non e'''' consentito modificare l''''anno di protocollo.'');'
                     || '     END IF; '
                     || '     IF NVL (:NEW.tipo_registro, '' '') != NVL (:OLD.tipo_registro, '' '') THEN '
                     || '            raise_application_error(-20999, ''Non e'''' consentito modificare il registro di protocollo.'');'
                     || '     END IF;'
                     || '     IF NVL (:NEW.unita_protocollante, '' '') != NVL (:OLD.unita_protocollante, '' '') THEN '
                     || '            raise_application_error(-20999, ''Non e'''' consentito modificare l''''unita'''' protocollante.'');'
                     || '     END IF;'
                     || '     IF NVL (:NEW.utente_protocollante, '' '') != NVL (:OLD.utente_protocollante, '' '') THEN '
                     || '            raise_application_error(-20999, ''Non e'''' consentito modificare l''''utente protocollante.'');'
                     || '     END IF;'
                     || '  END IF;'
                     || '  IF NVL (:OLD.modalita, ''x'') != NVL (:NEW.modalita, ''x'')'
                     || '  THEN '
                     || '  DECLARE '
                     || '  movimento_utilizzabile     NUMBER; '
                     || '  dep_utente_aggiornamento   ad4_utenti.utente%TYPE; '
                     || '  des_movimento              seg_movimenti.movimento%TYPE; '
                     || '  BEGIN '
                     || '     BEGIN '
                     || '        SELECT utente_aggiornamento '
                     || '          INTO dep_utente_aggiornamento '
                     || '          FROM documenti '
                     || '         WHERE id_documento = :NEW.id_documento; '
                     || '       BEGIN '
                     || '          SELECT 1 '
                     || '            INTO movimento_utilizzabile '
                     || '            FROM seg_movimenti '
                     || '           WHERE tipo_movimento = NVL (:NEW.modalita, ''x'') '
                     || '             AND gdm_competenza.gdm_verifica (''DOCUMENTI'', '
                     || '                                              seg_movimenti.id_documento, '
                     || '                                              ''L'', '
                     || '                                              dep_utente_aggiornamento, '
                     || '                                              ''GDM'' '
                     || '                                              ) = 1; '
                     || '       EXCEPTION '
                     || '       WHEN NO_DATA_FOUND '
                     || '       THEN '
                     || '          BEGIN '
                     || '             SELECT MIN (movimento) '
                     || '               INTO des_movimento '
                     || '               FROM seg_movimenti '
                     || '              WHERE tipo_movimento = NVL (:NEW.modalita, ''x''); '
                     || '          EXCEPTION '
                     || '          WHEN OTHERS '
                     || '          THEN '
                     || '             des_movimento := NVL (:NEW.modalita, ''x''); '
                     || '          END; '
                     || '          raise_application_error '
                     || '          (-20999, '
                     || '          ''L''''utente '' '
                     || '          || dep_utente_aggiornamento '
                     || '          || '' non e'''' abilitato ad utilizzare il  movimento '' '
                     || '          || des_movimento '
                     || '          ); '
                     || '       END; '
                     || '     EXCEPTION '
                     || '     WHEN NO_DATA_FOUND '
                     || '     THEN '
                     || '     NULL; '
                     || '     END; '
                     || '  END; '
                     || '  END IF;'
                     || '  IF (:NEW.stato_pr = ''DP'' and :NEW.tipo_registro is not null)'
                     || '   THEN'
                     || '     :NEW.tipo_registro_temp := :NEW.tipo_registro;'
                     || '    :NEW.tipo_registro := NULL;'
                     || '   END IF;'
                     || '   IF (:NEW.stato_pr != ''DP'' AND nvl(:NEW.tipo_stato, ''--'') != nvl(:OLD.tipo_stato, ''--''))'
                     || '   THEN'
                     || '     :NEW.data_stato := trunc(sysdate);'
                     || '    END IF;'
                     || '  IF (    :NEW.stato_pr != ''DP'''
                     || '   AND NVL (:NEW.tipo_stato, ''--'') != ''--'''
                     || '   AND :NEW.data_stato IS NULL '
                     || '   )'
                     || '   THEN'
                     || '     :NEW.data_stato := NVL (:OLD.data_stato, TRUNC (SYSDATE));'
                     || '  END IF;'
                     || '  IF (    :NEW.stato_pr != ''DP'''
                     || '   AND NVL (:NEW.tipo_stato, ''--'') = ''--'''
                     || '   AND :NEW.data_stato IS not NULL'
                     || '   )'
                     || '   THEN'
                     || '     :NEW.data_stato := null;'
                     || '   END IF; '
                     || 'IF     :OLD.CLASS_COD IS NOT NULL '
                     || 'AND :OLD.CLASS_DAL IS NOT NULL '
                     || 'AND (   NVL (:NEW.CLASS_COD, '' '') <> :OLD.CLASS_COD '
                     || '   OR NVL (:NEW.CLASS_DAL, TO_DATE (3333333, ''j'')) <> :OLD.CLASS_DAL '
                     || '   OR NVL (:NEW.FASCICOLO_ANNO, 0) <> NVL (:OLD.FASCICOLO_ANNO, 0) '
                     || '   OR NVL (:NEW.FASCICOLO_NUMERO, '' '') <> '
                     || '       NVL (:OLD.FASCICOLO_NUMERO, '' '')) '
                     || 'THEN '
                     || '   BEGIN '
                     || '      DECLARE '
                     || '         a_messaggio    VARCHAR2 (32000); '
                     || '         a_istruzione   VARCHAR2 (32000); '
                     || '      BEGIN '
                     || '         a_messaggio := '
                     || '               ''Errore in aggiornamento link del documento '' '
                     || '            || :OLD.id_documento '
                     || '            || ''.''; '
                     || '         a_istruzione := '
                     || '               ''begin ag_documento_utility.delete_from_titolario('' '
                     || '            || :OLD.id_documento '
                     || '            || '', '''''' '
                     || '            || :OLD.class_cod '
                     || '            || '''''', '''''' '
                     || '            || TO_CHAR (:OLD.class_dal, ''dd/mm/yyyy'') '
                     || '            || '''''', '' '
                     || '            || nvl(:OLD.fascicolo_anno, ''0'') '
                     || '            || '', '''''' '
                     || '            || :OLD.fascicolo_numero '
                     || '            || '''''', '''''' '
                     || '            || :OLD.codice_amministrazione '
                     || '            || '''''', '''''' '
                     || '            || :OLD.codice_aoo '
                     || '            || ''''''); end; ''; '
                     || '         integritypackage.set_postevent (a_istruzione, a_messaggio); '
                     || '      END; '
                     || '   EXCEPTION '
                     || '      WHEN OTHERS '
                     || '      THEN '
                     || '         raise_application_error (-20999, '
                     || '                                  ''Fallito aggiornamento:'' || SQLERRM); '
                     || '   END; '
                     || 'END IF; '
                     || check_tipo_documento_registro (depnometabella)
                     || get_trigger_leus (depnometabella)
                     || get_trigger_prin (depnometabella)
                  ;
               END IF;
               depstmt :=
                     depstmt
                  || ' EXCEPTION '
                  || ' WHEN OTHERS '
                  || ' THEN '
                  || ' RAISE; '
                  || ' END; ';
               EXECUTE IMMEDIATE depstmt;
               crea_trigger_proto_tb_tc (depnometabella);
               --GM 24/06/2011 Aggiunto trigger per allineare oggetto del protocollo con tutti i task esterni
               --              legati agli smistamenti
               IF INSTR (c_categorie.area, 'SEGRETERIA.ATTI') = 0 AND INSTR (c_categorie.area, 'SEGRETERIA') > 0
               THEN
                  deptriggername :=
                          'ag_' || SUBSTR (depnometabella, 1, 23)
                          || '_au ';
                  -- creazione trigger per valorizzara id_documento_protocollo
                  BEGIN
                     depstmt := 'DROP TRIGGER ' || deptriggername;
                     EXECUTE IMMEDIATE depstmt;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
                  depstmt :=
                        'CREATE TRIGGER '
                     || deptriggername
                     || ' AFTER UPDATE ON '
                     || depnometabella
                     || ' REFERENCING NEW AS New OLD AS Old '
                     || ' FOR EACH ROW '
                     || ' BEGIN '
                     || '   IF NVL (:OLD.stato_pr, ''DP'') != NVL (:NEW.stato_pr, ''DP'') AND NVL (:NEW.stato_pr, ''DP'') = ''PR'' THEN '
                     || '      AG_MEMO_UTILITY.SET_STATO_FROM_PROT(:NEW.id_documento, ''PR''); '
                     || '      DECLARE '
                     || '      a_messaggio    VARCHAR2 (32000); '
                     || '      a_istruzione   VARCHAR2 (32000); '
                     || '      BEGIN '
                     || '      a_messaggio := '
                     || '      ''Fallita notifica di inserimento in fascicolo del protocollo identificato da '''
                     || '      || :NEW.id_documento; '
                     || '      a_istruzione := '
                     || '      ''begin ag_documento_utility.notifica_ins_fasc ('''
                     || '      || :NEW.id_documento '
                     || '      || ''); end ;'';'
                     || '      integritypackage.set_postevent (a_istruzione, a_messaggio);'
                     || '      END; '
                     || '   END IF; '
                     || '   IF nvl(:NEW.OGGETTO,'''') <> nvl(:OLD.OGGETTO,'''') THEN '
                     || '      AG_SMISTAMENTO.UPD_OGG_SMIST_TASK_EST_COMMIT (:NEW.IDRIF,nvl(:NEW.OGGETTO,''''),nvl(:OLD.OGGETTO,''''),:NEW.ANNO,:NEW.NUMERO);'
                     || '   END IF;'
                     || '   EXCEPTION WHEN OTHERS THEN'
                     || '      RAISE_APPLICATION_ERROR(-20999,''Errore in aggiornamento oggetto dei task esterni. Errore: ''||sqlerrm);'
                     || ' END;';
                  EXECUTE IMMEDIATE depstmt;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END LOOP;
   END IF;
END;
/
