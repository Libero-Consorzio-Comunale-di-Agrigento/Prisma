--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20200912_3.seg_smistamenti_elimina failOnError:false

DECLARE
   i   NUMBER;
BEGIN
   FOR s
      IN (SELECT s.id_documento
            FROM seg_smistamenti s, documenti d, proto_view p
           WHERE     d.id_documento = s.id_documento
                 AND d.stato_documento = 'BO'
                 AND p.idrif = s.idrif
                 AND p.anno IS NOT NULL
                 AND s.stato_smistamento = 'N'
                 AND s.tipo_smistamento <> 'DUMMY')
   LOOP
      i := f_elimina_documento_logico (s.id_documento, 'RPI');
   END LOOP;
   commit;
END;
/