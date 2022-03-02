--liquibase formatted sql
--changeset esasdelli:AGSPR_FUNCTION_GET_ID_TIPO_REGISTRO runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION get_id_tipo_registro (p_tipo_registro VARCHAR2)
   RETURN NUMBER
IS
   d_return    NUMBER;
   d_trovato   BOOLEAN := FALSE;
BEGIN
   -- cerca il record aperto e non cancellato per il max anno
   SELECT MAX (REGI.ID_DOCUMENTO) ID_DOCUMENTO
     INTO d_return
     FROM GDM_SEG_REGISTRI REGI, GDM_DOCUMENTI DOCU
    WHERE     DOCU.ID_DOCUMENTO = REGI.ID_DOCUMENTO
          AND regi.anno_reg IN (SELECT MAX (anno_reg)
                                  FROM GDM_SEG_REGISTRI REGI,
                                       GDM_DOCUMENTI DOCU
                                 WHERE     DOCU.ID_DOCUMENTO =
                                              REGI.ID_DOCUMENTO
                                       AND DOCU.STATO_DOCUMENTO NOT IN ('CA',
                                                                        'RE',
                                                                        'PB')
                                       AND NVL (REGI.IN_USO, 'N') = 'Y'
                                       AND tipo_registro = p_tipo_registro)
          AND DOCU.STATO_DOCUMENTO NOT IN ('CA', 'RE', 'PB')
          AND NVL (REGI.IN_USO, 'N') = 'Y'
          AND regi.tipo_registro = p_tipo_registro;

   IF d_return IS NOT NULL
   THEN
      d_trovato := TRUE;
   ELSE
      DBMS_OUTPUT.PUT_LINE (
         'NON TROVO record aperto e non cancellato per il max anno');
      d_trovato := FALSE;
   END IF;

   IF NOT d_trovato
   THEN
      -- cerca il record chiuso e non cancellato per il max anno
      SELECT MAX (REGI.ID_DOCUMENTO) ID_DOCUMENTO
        INTO d_return
        FROM GDM_SEG_REGISTRI REGI, GDM_DOCUMENTI DOCU
       WHERE     DOCU.ID_DOCUMENTO = REGI.ID_DOCUMENTO
             AND regi.anno_reg IN (SELECT MAX (anno_reg)
                                     FROM GDM_SEG_REGISTRI REGI,
                                          GDM_DOCUMENTI DOCU
                                    WHERE     DOCU.ID_DOCUMENTO =
                                                 REGI.ID_DOCUMENTO
                                          AND DOCU.STATO_DOCUMENTO NOT IN ('CA',
                                                                           'RE',
                                                                           'PB')
                                          AND tipo_registro = p_tipo_registro)
             AND DOCU.STATO_DOCUMENTO NOT IN ('CA', 'RE', 'PB')
             AND regi.tipo_registro = p_tipo_registro;

      IF d_return IS NOT NULL
      THEN
         d_trovato := TRUE;
      ELSE
         DBMS_OUTPUT.PUT_LINE (
            'NON TROVO record non cancellato per il max anno');
         d_trovato := FALSE;
      END IF;
   END IF;

   IF NOT d_trovato
   THEN
      -- cerca il record per il max anno
      SELECT MAX (REGI.ID_DOCUMENTO) ID_DOCUMENTO
        INTO d_return
        FROM GDM_SEG_REGISTRI REGI
       WHERE     regi.anno_reg IN (SELECT MAX (anno_reg)
                                     FROM GDM_SEG_REGISTRI REGI
                                    WHERE tipo_registro = p_tipo_registro)
             AND regi.tipo_registro = p_tipo_registro;

      IF d_return IS NOT NULL
      THEN
         d_trovato := TRUE;
      ELSE
         DBMS_OUTPUT.PUT_LINE ('NON TROVO record per il max anno');
         d_trovato := FALSE;
      END IF;
   END IF;

   RETURN d_return;
END;
/
