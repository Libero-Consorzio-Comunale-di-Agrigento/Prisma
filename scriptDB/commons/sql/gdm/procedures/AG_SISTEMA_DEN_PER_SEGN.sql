--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_SISTEMA_DEN_PER_SEGN runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE AG_SISTEMA_DEN_PER_SEGN
IS
    D_DEN            VARCHAR2 (300);
    d_conta          NUMBER;
    d_conta_totale   NUMBER;
    d_max_id         NUMBER;
    d_min_id         NUMBER;
BEGIN
    DBMS_OUTPUT.put_line (
        'inizio ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
    d_conta := 0;
    d_conta_totale := 0;
    d_den := '';

    SELECT MAX (s.id_documento), MIN (s.id_documento)
      INTO d_max_id, d_min_id
      FROM (  SELECT sopr.id_documento     id_documento
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                     AND DENOMINAZIONE_PER_SEGNATURA IS NULL
                     AND tipo_rapporto != 'DUMMY'
            ORDER BY sopr.id_documento DESC) s
     WHERE ROWNUM < 500000;

    FOR s
        IN (  SELECT sopr.id_documento, TIPO_SOGGETTO, nome_per_segnatura
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                     AND DENOMINAZIONE_PER_SEGNATURA IS NULL
                     AND tipo_rapporto != 'DUMMY'
                     AND sopr.id_documento BETWEEN d_min_id AND d_max_id
            ORDER BY sopr.id_documento DESC)
    LOOP
        d_conta := d_conta + 1;
        d_conta_totale := d_conta_totale + 1;
        d_den := '';

        IF s.tipo_soggetto = 2
        THEN
            DECLARE
                d_des_amm   VARCHAR2 (32000);
                d_des_aoo   VARCHAR2 (32000);
                d_des_uo    VARCHAR2 (32000);
            BEGIN
                SELECT descrizione_amm, descrizione_aoo, descrizione_uo
                  INTO d_des_amm, d_des_aoo, d_des_uo
                  FROM seg_soggetti_protocollo sopr, documenti docu
                 WHERE     docu.id_documento = sopr.id_documento
                       AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                       AND DENOMINAZIONE_PER_SEGNATURA IS NULL
                       AND descrizione_amm IS NOT NULL
                       AND TIPO_SOGGETTO = 2
                       AND sopr.id_documento = s.id_documento;

                D_DEN := d_des_amm;

                IF d_des_aoo IS NOT NULL
                THEN
                    D_DEN := SUBSTR (D_DEN || ':AOO:' || d_des_aoo, 1, 300);
                END IF;

                IF d_des_uo IS NOT NULL
                THEN
                    D_DEN := SUBSTR (D_DEN || ':UO:' || d_des_uo, 1, 300);
                END IF;


                UPDATE seg_soggetti_protocollo
                   SET denominazione_per_segnatura = d_den
                 WHERE id_documento = s.id_documento;
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.put_line (
                        'ERRORE per id_documento ' || s.id_documento);
                    DBMS_OUTPUT.put_line (SQLERRM);
            END;
        ELSE
            IF s.nome_per_segnatura IS NOT NULL
            THEN
                DECLARE
                    d_cognome   VARCHAR2 (32000);
                    d_nome      VARCHAR2 (32000);
                BEGIN
                    SELECT cognome_per_segnatura, nome_per_segnatura
                      INTO d_cognome, d_nome
                      FROM seg_soggetti_protocollo sopr, documenti docu
                     WHERE     docu.id_documento = sopr.id_documento
                           AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                           AND DENOMINAZIONE_PER_SEGNATURA IS NULL
                           AND cognome_per_segnatura IS NOT NULL
                           AND nome_per_segnatura IS NOT NULL
                           AND sopr.id_documento = s.id_documento;


                    d_den := SUBSTR (d_cognome || ' ' || d_nome, 1, 300);

                    UPDATE seg_soggetti_protocollo
                       SET denominazione_per_segnatura = d_den
                     WHERE id_documento = s.id_documento;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'ERRORE per id_documento ' || s.id_documento);
                        DBMS_OUTPUT.put_line (SQLERRM);
                END;
            ELSE
                DECLARE
                    d_cognome   VARCHAR2 (32000);
                BEGIN
                    SELECT cognome_per_segnatura
                      INTO d_cognome
                      FROM seg_soggetti_protocollo sopr, documenti docu
                     WHERE     docu.id_documento = sopr.id_documento
                           AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                           AND DENOMINAZIONE_PER_SEGNATURA IS NULL
                           AND cognome_per_segnatura IS NOT NULL
                           AND nome_per_segnatura IS NULL
                           AND sopr.id_documento = s.id_documento;

                    d_den := SUBSTR (d_cognome, 1, 300);

                    UPDATE seg_soggetti_protocollo
                       SET denominazione_per_segnatura = d_den
                     WHERE id_documento = s.id_documento;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'ERRORE per id_documento ' || s.id_documento);
                        DBMS_OUTPUT.put_line (SQLERRM);
                END;
            END IF;
        END IF;

        IF d_conta = 100
        THEN
            COMMIT;
            d_conta := 0;
        END IF;
    END LOOP;

    COMMIT;

    d_conta := 0;

    FOR s_nuovi
        IN (  SELECT sopr.id_documento, cognome_per_segnatura, nome_per_segnatura
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                     AND TIPO_RAPPORTO != 'DUMMY'
                     AND TIPO_SOGGETTO = -1
                     AND UPPER(sopr.DENOMINAZIONE_PER_SEGNATURA) != UPPER(sopr.COGNOME_PER_SEGNATURA||' '||sopr.NOME_PER_SEGNATURA)
                     AND sopr.COGNOME_PER_SEGNATURA IS NOT NULL
                     AND sopr.NOME_PER_SEGNATURA IS NOT NULL
            ORDER BY sopr.id_documento DESC)
    LOOP
       d_conta := d_conta + 1;
       d_conta_totale := d_conta_totale + 1;
       BEGIN
           d_den := SUBSTR (s_nuovi.cognome_per_segnatura || ' ' || s_nuovi.nome_per_segnatura, 1, 300);

           UPDATE seg_soggetti_protocollo
              SET denominazione_per_segnatura = d_den
            WHERE id_documento = s_nuovi.id_documento;
        EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.put_line (
                    'ERRORE per id_documento ' || s_nuovi.id_documento);
                DBMS_OUTPUT.put_line (SQLERRM);
        END;

        IF d_conta = 100
        THEN
            COMMIT;
            d_conta := 0;
        END IF;

    END LOOP;
    commit;
    d_conta := 0;
    FOR s_nuovi_senza_nome
        IN (  SELECT sopr.id_documento, cognome_per_segnatura, nome_per_segnatura
                FROM seg_soggetti_protocollo sopr, documenti docu
               WHERE     docu.id_documento = sopr.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                     AND TIPO_RAPPORTO != 'DUMMY'
                     AND TIPO_SOGGETTO = -1
                     AND UPPER(sopr.DENOMINAZIONE_PER_SEGNATURA) != UPPER(sopr.COGNOME_PER_SEGNATURA)
                     AND sopr.COGNOME_PER_SEGNATURA IS NOT NULL
                     AND sopr.NOME_PER_SEGNATURA IS NULL
            ORDER BY sopr.id_documento DESC)
    LOOP
       d_conta := d_conta + 1;
       d_conta_totale := d_conta_totale + 1;
       BEGIN
           d_den := SUBSTR (s_nuovi_senza_nome.cognome_per_segnatura , 1, 300);

           UPDATE seg_soggetti_protocollo
              SET denominazione_per_segnatura = d_den
            WHERE id_documento = s_nuovi_senza_nome.id_documento;
        EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.put_line (
                    'ERRORE per id_documento ' || s_nuovi_senza_nome.id_documento);
                DBMS_OUTPUT.put_line (SQLERRM);
        END;

        IF d_conta = 100
        THEN
            COMMIT;
            d_conta := 0;
        END IF;

    END LOOP;
    commit;
    DBMS_OUTPUT.put_line ('aggiornati ' || d_conta_totale || ' documenti.');
    DBMS_OUTPUT.put_line (
        'fine ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
END;
/
