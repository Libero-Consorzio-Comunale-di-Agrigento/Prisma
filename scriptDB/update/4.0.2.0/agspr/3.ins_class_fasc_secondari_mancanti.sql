--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20200819_3.ins_class_fasc_secondari_mancanti
BEGIN
   FOR c
      IN (SELECT p.id_documento,
                 p.anno,
                 p.numero,
                 p.tipo_registro,
                 f.class_cod,
                 f.class_dal,
                 f.fascicolo_anno,
                 f.fascicolo_numero,
                 l.utente_aggiornamento
            FROM gdm_proto_view p,
                 gdm_links l,
                 gdm_cartelle c,
                 gdm_fascicoli f,
                 gdm_documenti d
           WHERE     l.id_oggetto = p.id_documento
                 AND d.id_documento = f.id_documento
                 AND c.id_cartella = l.id_cartella
                 AND NVL (c.stato, 'BO') = 'BO'
                 AND NVL (d.stato_documento, 'BO') = 'BO'
                 AND f.id_documento = c.id_documento_profilo
                 AND (   NVL (p.class_cod, ' ') <> NVL (f.class_cod, ' ')
                      OR NVL (p.class_dal, SYSDATE) <>
                            NVL (f.class_dal, SYSDATE)
                      OR NVL (p.fascicolo_anno, 0) <>
                            NVL (f.fascicolo_anno, 0)
                      OR NVL (p.fascicolo_numero, ' ') <>
                            NVL (f.fascicolo_numero, ' '))
                 AND (p.id_documento,
                      f.class_cod,
                      f.class_dal,
                      f.fascicolo_anno,
                      f.fascicolo_numero) NOT IN (SELECT docu.id_documento_esterno,
                                                         clas.classificazione,
                                                         CLAS.CLASSIFICAZIONE_DAL,
                                                         FASC.ANNO,
                                                         FASC.NUMERO
                                                    FROM AGP_DOCUMENTI_TITOLARIO doti,
                                                         gdo_documenti docu,
                                                         ags_classificazioni clas,
                                                         ags_fascicoli fasc
                                                   WHERE     docu.id_documento =
                                                                doti.id_documento
                                                         AND CLAS.ID_CLASSIFICAZIONE =
                                                                DOTI.ID_CLASSIFICAZIONE
                                                         AND FASC.ID_FASCICOLO =
                                                                DOTI.ID_FASCICOLO)
                 AND EXISTS
                        (SELECT 1
                           FROM gdo_documenti docu, agp_protocolli prot
                          WHERE     prot.id_documento = docu.id_documento
                                AND docu.id_documento_esterno =
                                       p.id_documento
                                AND prot.idrif IS NOT NULL)
          UNION
          SELECT p.id_documento,
                 p.anno,
                 p.numero,
                 p.tipo_registro,
                 cl.class_cod,
                 cl.class_dal,
                 NULL,
                 NULL,
                 l.utente_aggiornamento
            FROM gdm_proto_view p,
                 gdm_links l,
                 gdm_cartelle c,
                 gdm_seg_classificazioni cl,
                 gdm_documenti d
           WHERE     l.id_oggetto = p.id_documento
                 AND d.id_documento = cl.id_documento
                 AND c.id_cartella = l.id_cartella
                 AND NVL (c.stato, 'BO') = 'BO'
                 AND NVL (d.stato_documento, 'BO') = 'BO'
                 AND cl.id_documento = c.id_documento_profilo
                 AND (   NVL (p.class_cod, ' ') <> NVL (cl.class_cod, ' ')
                      OR NVL (p.class_dal, SYSDATE) <>
                            NVL (cl.class_dal, SYSDATE))
                 AND (p.fascicolo_anno IS NULL AND p.fascicolo_numero IS NULL)
                 AND (p.id_documento, cl.class_cod, cl.class_dal) NOT IN (SELECT docu.id_documento_esterno,
                                                                                 clas.classificazione,
                                                                                 CLAS.CLASSIFICAZIONE_DAL
                                                                            FROM AGP_DOCUMENTI_TITOLARIO doti,
                                                                                 gdo_documenti docu,
                                                                                 ags_classificazioni clas
                                                                           WHERE     docu.id_documento =
                                                                                        doti.id_documento
                                                                                 AND CLAS.ID_CLASSIFICAZIONE =
                                                                                        DOTI.ID_CLASSIFICAZIONE
                                                                                 AND DOTI.ID_FASCICOLO
                                                                                        IS NULL)
                 AND EXISTS
                        (SELECT 1
                           FROM gdo_documenti docu, agp_protocolli prot
                          WHERE     prot.id_documento = docu.id_documento
                                AND docu.id_documento_esterno =
                                       p.id_documento
                                AND prot.idrif IS NOT NULL))
   LOOP
      BEGIN
         AGP_DOCUMENTI_TITOLARIO_PKG.INSERISCI (c.id_documento,
                                                c.CLASS_COD,
                                                c.CLASS_DAL,
                                                c.FASCICOLO_ANNO,
                                                c.FASCICOLO_NUMERO,
                                                c.UTENTE_AGGIORNAMENTO);
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
                  'NON inserito '
               || c.id_documento
               || ' '
               || c.CLASS_COD
               || ' del '
               || c.CLASS_DAL
               || ' '
               || c.FASCICOLO_ANNO
               || '/'
               || c.FASCICOLO_NUMERO);
      END;
   END LOOP;
END;
/
