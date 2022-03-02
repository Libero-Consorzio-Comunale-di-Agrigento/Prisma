--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_AGGIORNA_DATI_PRECARICATI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_aggiorna_dati_precaricati (
   p_area                 VARCHAR2,
   p_codice_modello       VARCHAR2,
   p_indice_aoo           NUMBER DEFAULT 1,
   p_campi_da_annullare   VARCHAR2 DEFAULT NULL
)
AS
/**********************************************************************************
Fa l'update di codice_amministrazione, codice_aoo per tutti i documenti
di area p_area e codice_modello p_codice_modello, mettendoci il valore
presente i tabella parametri per
codice_amm_<p_indice_aoo>
e
codice_aoo_<p_indice_aoo>.
Se ci sono campi di cui eliminare il valore, vanno elencati in p_campi_da_annullare,
separati da @.
**********************************************************************************/
   d_cod_amm          VARCHAR2 (100);
   d_cod_aoo          VARCHAR2 (100);
   d_nome_tabella     VARCHAR2 (30);
   d_sql              VARCHAR2 (32000);
   id_campo_cod_amm   NUMBER;
   id_campo_cod_aoo   NUMBER;
   d_tipodoc          NUMBER;
   idvalore           NUMBER;
   esiste_tabella     NUMBER;
BEGIN
   d_cod_amm :=
      ag_parametro.get_valore ('CODICE_AMM_' || p_indice_aoo, '@agVar@',
                               NULL);
   d_cod_aoo :=
      ag_parametro.get_valore ('CODICE_AOO_' || p_indice_aoo, '@agVar@',
                               NULL);
   d_nome_tabella := f_nome_tabella (p_area, p_codice_modello);

-- se esiste la tabella orizzontale, aggiorno i valori in essa registrati.
   BEGIN
      SELECT 1
        INTO esiste_tabella
        FROM obj
       WHERE object_name = UPPER (d_nome_tabella) AND object_type = 'TABLE';

      d_sql :=
            'update '
         || d_nome_tabella
         || ' set codice_Amministrazione = '''
         || d_cod_amm
         || ''''
         || ', codice_aoo = '''
         || d_cod_aoo
         || ''''
         || ' where nvl(codice_amministrazione, ''*'') != '''
         || d_cod_amm
         || ''''
         || ' or nvl(codice_aoo, ''*'') != '''
         || d_cod_aoo
         || '''';
      DBMS_OUTPUT.put_line (d_sql);

      EXECUTE IMMEDIATE (d_sql);

      IF p_campi_da_annullare IS NOT NULL
      THEN
         FOR dat IN (SELECT dato
                       FROM dati_modello
                      WHERE area = p_area
                        AND codice_modello = p_codice_modello
                        AND INSTR ('@' || p_campi_da_annullare || '@',
                                   '@' || dato || '@'
                                  ) > 0)
         LOOP
            d_sql :=
                  'update '
               || d_nome_tabella
               || ' set '
               || dat.dato
               || ' = NULL'
               || ' where '
               || dat.dato
               || ' IS NOT NULL ';
            DBMS_OUTPUT.put_line (d_sql);

            EXECUTE IMMEDIATE (d_sql);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --se non esiste la tabella orizzontale, lavoro solo sulla VALORI.
         NULL;
   END;

-- in ogni caso provo ad aggiornare i valori sulla tabella VALORI,
-- perche' non ho certezza che non ci siano dati in VALORI ed
--e' meglio tenere allineati la verticale e l'orizzontale.
   BEGIN
      SELECT id_campo
        INTO id_campo_cod_amm
        FROM dati_modello
       WHERE dati_modello.area = p_area
         AND dati_modello.codice_modello = p_codice_modello
         AND dati_modello.dato = 'CODICE_AMMINISTRAZIONE';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         id_campo_cod_amm := 0;
   END;

   BEGIN
      SELECT id_campo
        INTO id_campo_cod_aoo
        FROM dati_modello
       WHERE dati_modello.area = p_area
         AND dati_modello.codice_modello = p_codice_modello
         AND dati_modello.dato = 'CODICE_AOO';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         id_campo_cod_aoo := 0;
   END;

-- se ci sono documenti con i valori 'errati', faccio l'update.
   UPDATE valori
      SET valore_stringa = d_cod_amm,
          valore_clob = d_cod_amm
    WHERE id_campo = id_campo_cod_amm
          AND NVL (valore_stringa, '*') != d_cod_amm;

   UPDATE valori
      SET valore_stringa = d_cod_aoo,
          valore_clob = d_cod_aoo
    WHERE id_campo = id_campo_cod_aoo
          AND NVL (valore_stringa, '*') != d_cod_aoo;

-- se ci sono documenti con i valori nulli faccio l'insert.
   FOR doc IN (SELECT id_documento
                 FROM documenti
                WHERE id_tipodoc = d_tipodoc
                  AND NOT EXISTS (
                         SELECT 1
                           FROM valori
                          WHERE valori.id_documento = documenti.id_documento
                            AND valori.id_campo = id_campo_cod_amm))
   LOOP
      SELECT valo_sq.NEXTVAL
        INTO idvalore
        FROM DUAL;

      INSERT INTO valori
                  (id_valore, id_documento, id_campo, valore_stringa,
                   valore_clob, utente_aggiornamento
                  )
           VALUES (idvalore, doc.id_documento, id_campo_cod_amm, d_cod_amm,
                   d_cod_amm, 'RPI'
                  );
   END LOOP;

   FOR doc IN (SELECT id_documento
                 FROM documenti
                WHERE id_tipodoc = d_tipodoc
                  AND NOT EXISTS (
                         SELECT 1
                           FROM valori
                          WHERE valori.id_documento = documenti.id_documento
                            AND valori.id_campo = id_campo_cod_aoo))
   LOOP
      SELECT valo_sq.NEXTVAL
        INTO idvalore
        FROM DUAL;

      INSERT INTO valori
                  (id_valore, id_documento, id_campo, valore_stringa,
                   valore_clob, utente_aggiornamento
                  )
           VALUES (idvalore, doc.id_documento, id_campo_cod_aoo, d_cod_aoo,
                   d_cod_aoo, 'RPI'
                  );
   END LOOP;

   IF p_campi_da_annullare IS NOT NULL
   THEN
      FOR dat IN (SELECT id_campo
                    FROM dati_modello
                   WHERE area = p_area
                     AND codice_modello = p_codice_modello
                     AND INSTR ('@' || p_campi_da_annullare || '@',
                                '@' || dato || '@'
                               ) > 0)
      LOOP
         UPDATE valori
            SET valore_stringa = NULL,
                valore_clob = NULL,
                valore_numero = NULL,
                valore_data = NULL
          WHERE id_campo = dat.id_campo
            AND (   valore_stringa IS NOT NULL
                 OR valore_numero IS NOT NULL
                 OR valore_data IS NOT NULL
                );
      END LOOP;
   END IF;

   COMMIT;
END;
/
