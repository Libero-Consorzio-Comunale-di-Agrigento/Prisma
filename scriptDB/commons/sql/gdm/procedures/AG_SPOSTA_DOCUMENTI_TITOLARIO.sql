--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_SPOSTA_DOCUMENTI_TITOLARIO runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE     ag_sposta_documenti_titolario (
   from_idcartella   NUMBER,
   to_idcartella     NUMBER
)
AS
   esiste       NUMBER;
   dep_idlink   NUMBER;
/*****************************************************************************
Prende i protocolli (cat PROTO) che stanno in cartella from_idcartella
(che deve essere una class o un fascicolo) e li mette in to_idcartella
(che deve essere una class o un fascicolo) .
Se from_idcartella corrisponde alla clas principale del protocollo,
fa l'update sul protocollo stesso dei dati della class principale.

Il tipo indica se le cartelle coinvolte sono classifiche (tipo = 'C') o fascicoli
 (tipo = 'F').
*****************************************************************************/
BEGIN
   FOR doc IN (SELECT docu.id_documento
                 FROM documenti docu, links, tipi_documento tido
                WHERE links.id_cartella = from_idcartella
                  AND links.id_oggetto = docu.id_documento
                  AND links.tipo_oggetto = 'D'
                  AND docu.stato_documento NOT IN ('CA', 'RE')
                  AND tido.id_tipodoc = docu.id_tipodoc
                  AND NOT EXISTS (
                         SELECT 1
                           FROM cartelle
                          WHERE docu.id_documento =
                                                 cartelle.id_documento_profilo)
                  AND NOT EXISTS (
                             SELECT 1
                               FROM proto_view
                              WHERE docu.id_documento =
                                                       proto_view.id_documento))
   LOOP
      esiste := 0;

--verifico se il documento è già nella cartella di arrivo.
      SELECT NVL (MAX (1), 0)
        INTO esiste
        FROM links
       WHERE links.id_oggetto = doc.id_documento
         AND links.tipo_oggetto = 'D'
         AND links.id_cartella = to_idcartella;

      IF esiste = 0
      THEN
         UPDATE links
            SET id_cartella = to_idcartella
          WHERE links.id_cartella = from_idcartella
            AND links.tipo_oggetto = 'D'
            AND links.id_oggetto = doc.id_documento;
      ELSE
         DELETE      links
               WHERE links.id_cartella = from_idcartella
                 AND links.tipo_oggetto = 'D'
                 AND links.id_oggetto = doc.id_documento;

         SELECT link_sq.NEXTVAL
           INTO dep_idlink
           FROM DUAL;

         INSERT INTO links
                     (id_link, id_cartella, id_oggetto, tipo_oggetto
                     )
              VALUES (dep_idlink, to_idcartella, doc.id_documento, 'D'
                     );
      END IF;
   END LOOP;
END;
/
