--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_SPOSTA_PROTOCOLLI_TITOLARIO runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE     ag_sposta_protocolli_titolario (
   from_idcartella   NUMBER,
   to_idcartella     NUMBER,
   tipo              VARCHAR2
)
AS
   idcartelleviste         VARCHAR2 (32000) := '@';
   from_class_cod          VARCHAR2 (100);
   from_class_dal          DATE;
   from_fascicolo_anno     NUMBER;
   from_fascicolo_numero   VARCHAR2 (1000);
   to_class_cod            VARCHAR2 (100);
   to_class_dal            DATE;
   to_fascicolo_anno       NUMBER;
   to_fascicolo_numero     VARCHAR2 (1000);
   carattere_separatore    CHAR             := '*';
   stringa_separatrice     VARCHAR2 (64)    := LPAD ('*', 64, '*');
   conta                   NUMBER           := 0;
   esiste                  NUMBER;
   sql_stmt                VARCHAR2 (32000);
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
   IF tipo = 'C'
   THEN
      SELECT class_cod, class_dal
        INTO from_class_cod, from_class_dal
        FROM seg_classificazioni clas, cartelle cart
       WHERE cart.id_cartella = from_idcartella
         AND cart.id_documento_profilo = clas.id_documento;

      SELECT class_cod, class_dal
        INTO to_class_cod, to_class_dal
        FROM seg_classificazioni clas, cartelle cart
       WHERE cart.id_cartella = to_idcartella
         AND cart.id_documento_profilo = clas.id_documento;
   ELSE
      SELECT class_cod, class_dal, fascicolo_anno,
             fascicolo_numero
        INTO from_class_cod, from_class_dal, from_fascicolo_anno,
             from_fascicolo_numero
        FROM seg_fascicoli fasc, cartelle cart
       WHERE cart.id_cartella = from_idcartella
         AND cart.id_documento_profilo = fasc.id_documento;

      SELECT class_cod, class_dal, fascicolo_anno,
             fascicolo_numero
        INTO to_class_cod, to_class_dal, to_fascicolo_anno,
             to_fascicolo_numero
        FROM seg_fascicoli fasc, cartelle cart
       WHERE cart.id_cartella = from_idcartella
         AND cart.id_documento_profilo = fasc.id_documento;
   END IF;

   FOR protocolli IN (SELECT prot.id_documento, class_cod, class_dal,
                             fascicolo_anno, fascicolo_numero,
                             f_nome_tabella (docu.area,
                                             tido.nome
                                            ) tabella_proto
                        FROM proto_view prot,
                             documenti docu,
                             links,
                             tipi_documento tido
                       WHERE links.id_cartella = from_idcartella
                         AND links.id_oggetto = docu.id_documento
                         AND links.tipo_oggetto = 'D'
                         AND docu.id_documento = prot.id_documento
                         AND docu.stato_documento NOT IN ('CA', 'RE')
                         AND tido.id_tipodoc = docu.id_tipodoc)
   LOOP
      esiste := 0;

--verifico se il documento è già nella cartella di arrivo.
      SELECT nvl(max(1), 0)
        INTO esiste
        FROM links
       WHERE links.id_oggetto = protocolli.id_documento
         AND links.tipo_oggetto = 'D'
         AND links.id_cartella = to_idcartella;

      IF esiste = 0
      THEN
         UPDATE links
            SET id_cartella = to_idcartella
          WHERE links.id_cartella = from_idcartella
            AND links.tipo_oggetto = 'D'
            AND links.id_oggetto = protocolli.id_documento;
      ELSE
         DELETE      links
               WHERE links.id_cartella = from_idcartella
                 AND links.tipo_oggetto = 'D'
                 AND links.id_oggetto = protocolli.id_documento;
      END IF;

-- se sto togliendo il doc dalla class principale,
-- faccio diventare principale quella destinataria.
      IF     protocolli.class_cod = from_class_cod
         AND protocolli.class_dal = from_class_dal
         AND protocolli.fascicolo_anno = from_fascicolo_anno
         AND protocolli.fascicolo_numero = from_fascicolo_numero
      THEN
         IF tipo = 'C'
         THEN
            sql_stmt :=
                  'UPDATE '
               || protocolli.tabella_proto
               || ' prot '
               || 'SET class_cod = '''
               || to_class_cod
               || ''' '
               || ', class_dal = to_date('''
               || TO_CHAR (to_class_dal, 'dd/mm/yyyy')
               || ''', ''dd/mm/yyyy'') '
               || ' WHERE prot.id_documento = '
               || protocolli.id_documento;
         ELSE
            sql_stmt :=
                  'UPDATE '
               || protocolli.tabella_proto
               || ' prot '
               || 'SET class_cod = '''
               || to_class_cod
               || ''' '
               || ', class_dal = to_date('''
               || TO_CHAR (to_class_dal, 'dd/mm/yyyy')
               || ''', ''dd/mm/yyyy'') '
               || ', fascicolo_anno = '
               || to_fascicolo_anno
               || ' '
               || ', fascicolo_numero = '''
               || to_fascicolo_numero
               || ' '
               || ' WHERE prot.id_documento = '
               || protocolli.id_documento;
         END IF;

         execute immediate (sql_stmt);
      END IF;

      COMMIT;
   END LOOP;
END;
/
