--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_PULISCI_ALLEGATI_REP runOnChange:true stripComments:false

CREATE OR REPLACE procedure ag_pulisci_allegati_rep
is
   i    NUMBER := 0;
   ar   documenti.area%TYPE;
   cr   documenti.codice_richiesta%TYPE;
BEGIN
   FOR ogfi IN (SELECT f.id_documento
                  FROM oggetti_file f, documenti d, tipi_documento t
                 WHERE     d.id_documento = f.id_documento
                       AND t.id_tipodoc = d.id_tipodoc
                       AND t.area_modello = 'SEGRETERIA.PROTOCOLLO'
                       AND t.nome = 'ALLEGATI_REP'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM spr_allegati_rep
                                WHERE id_documento = f.id_documento))
   LOOP
      i := i + 1;
      DBMS_OUTPUT.put_line ('ogfi.id_documento:' || ogfi.id_documento);

      DELETE FROM si4_competenze
            WHERE id_competenza IN (SELECT id_competenza
                                      FROM si4_competenze s,
                                           si4_abilitazioni a,
                                           si4_tipi_oggetto o
                                     WHERE     oggetto =
                                                  TO_CHAR (ogfi.id_documento)
                                           AND tipo_competenza IN ('U', 'F')
                                           AND s.id_abilitazione =
                                                  a.id_abilitazione
                                           AND a.id_tipo_oggetto =
                                                  o.id_tipo_oggetto
                                           AND tipo_oggetto = 'DOCUMENTI');

      DELETE FROM riferimenti
            WHERE    id_documento = ogfi.id_documento
                  OR id_documento_rif = ogfi.id_documento;

      DELETE FROM links
            WHERE id_oggetto = ogfi.id_documento AND tipo_oggetto = 'D';

      DELETE oggetti_file
       WHERE id_documento IN ogfi.id_documento;

      BEGIN
         SELECT AREA, CODICE_RICHIESTA
           INTO AR, CR
           FROM DOCUMENTI
          WHERE ID_DOCUMENTO = ogfi.id_documento;


         DELETE FROM DOCUMENTI
               WHERE ID_DOCUMENTO = ogfi.id_documento;

         DELETE FROM RICHIESTE
               WHERE AREA = AR AND CODICE_RICHIESTA = CR;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF i = 100
      THEN
         COMMIT;
         i := 0;
      END IF;
   END LOOP;

   COMMIT;
END;
/
