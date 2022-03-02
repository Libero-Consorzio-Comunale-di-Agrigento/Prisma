--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_REGISTRO_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_REGISTRO_UTILITY
AS
   /******************************************************************************
      NAME:       AGP_REGISTRO_UTILITY
      PURPOSE:
   AGP_REGISTRO_UTILITY
      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2010             1. Created this package.
   ******************************************************************************/

   FUNCTION get_preferenza_utente (p_modulo       IN VARCHAR2,
                                   p_utente       IN VARCHAR2,
                                   p_preferenza   IN VARCHAR2,
                                   p_db_user      IN VARCHAR2 DEFAULT 'GDM')
      RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_REGISTRO_UTILITY
AS
   /******************************************************************************
      NAME:       AG_REGISTRO_UTILITY
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2010             1. Created this package.
   ******************************************************************************/

   FUNCTION trasforma_chiave (in_chiave VARCHAR2, in_db_user VARCHAR2)
      RETURN VARCHAR2
   IS
      chiave_reale   VARCHAR2 (2000) := in_chiave;
   BEGIN
      RETURN chiave_reale;
   END;

   PROCEDURE leggi_stringa (in_chiave    IN     VARCHAR2,
                            in_stringa   IN     VARCHAR2,
                            out_valore      OUT VARCHAR2,
                            in_db_user          VARCHAR2)
   IS
      chiave_reale   VARCHAR2 (2000);
      chiave         VARCHAR2 (2000);
   BEGIN
      chiave := UPPER (in_chiave);
      chiave_reale := trasforma_chiave (chiave, in_db_user);

      SELECT valore
        INTO out_valore
        FROM GDM_registro
       WHERE chiave = chiave_reale AND UPPER (stringa) = UPPER (in_stringa);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         OUT_VALORE := NULL;
   END;

   FUNCTION get_preferenza_utente (p_stringa    VARCHAR2,
                                   p_modulo     VARCHAR2,
                                   p_utente     VARCHAR2,
                                   p_db_user    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_valore   VARCHAR2 (2000) := '';
      d_chiave   VARCHAR2 (512);
   BEGIN
      -- Ricerca preferenza a livello utente di sistema con e senza modulo
      IF p_utente IS NOT NULL AND p_modulo IS NOT NULL
      THEN
         d_chiave :=
               'SI4_DB_USERS/'
            || p_utente
            || '|'
            || USER
            || '/PRODUCTS/'
            || UPPER (p_modulo);
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      IF p_utente IS NOT NULL AND d_valore IS NULL
      THEN
         d_chiave := 'SI4_DB_USERS/' || p_utente || '|' || USER;
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      RETURN d_valore;
   END get_preferenza_utente;

   FUNCTION get_preferenza_portale (p_stringa    VARCHAR2,
                                    p_modulo     VARCHAR2,
                                    p_db_user    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_valore   VARCHAR2 (2000) := '';
      d_chiave   VARCHAR2 (512);
   BEGIN
      -- Ricerca preferenza a livello di db user con e senza modulo
      IF p_modulo IS NOT NULL
      THEN
         d_chiave :=
            'DB_USERS/' || p_db_user || '/PRODUCTS/' || UPPER (p_modulo);
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      IF d_valore IS NULL
      THEN
         d_chiave := 'DB_USERS/' || p_db_user;
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      RETURN d_valore;
   END get_preferenza_portale;

   FUNCTION get_preferenza (p_stringa    VARCHAR2,
                            p_modulo     VARCHAR2,
                            p_utente     VARCHAR2,
                            p_db_user    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_valore   VARCHAR2 (2000);
      d_chiave   VARCHAR2 (512);
   BEGIN
      -- Ricerca preferenza a livello utente di sistema con e senza modulo
      IF p_utente IS NOT NULL AND p_modulo IS NOT NULL
      THEN
         d_chiave :=
               'SI4_DB_USERS/'
            || p_utente
            || '|'
            || p_db_user
            || '/PRODUCTS/'
            || UPPER (p_modulo);
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      IF p_utente IS NOT NULL AND d_valore IS NULL
      THEN
         d_chiave := 'SI4_DB_USERS/' || p_utente || '|' || p_db_user;
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      -- Ricerca preferenza a livello di db user
      IF d_valore IS NULL
      THEN
         d_valore := get_preferenza_portale (p_stringa, p_modulo, p_utente);
      END IF;

      -- Ricerca preferenza a livello generale per lo specifico modulo
      IF d_valore IS NULL AND p_modulo IS NOT NULL
      THEN
         d_chiave := 'PRODUCTS/' || UPPER (p_modulo);
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      -- Ricerca preferenza a livello generale
      IF d_valore IS NULL
      THEN
         d_chiave := 'PRODUCTS/AMV';
         leggi_stringa (d_chiave,
                        p_stringa,
                        d_valore,
                        p_db_user);
      END IF;

      RETURN d_valore;
   END get_preferenza;

   FUNCTION get_preferenza_utente (p_modulo       IN VARCHAR2,
                                   p_utente       IN VARCHAR2,
                                   p_preferenza   IN VARCHAR2,
                                   p_db_user      IN VARCHAR2 DEFAULT 'GDM')
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (2000);
   BEGIN
        SELECT stringa VALORE
          INTO d_return
          FROM GDM_REGISTRO
         WHERE     (   chiave =
                             'SI4_DB_USERS/'
                          || p_utente
                          || '|'
                          || UPPER (p_db_user)
                          || '/PRODUCTS/'
                          || p_modulo
                    OR chiave = 'PRODUCTS/' || p_modulo)
               AND UPPER (stringa) = UPPER (p_preferenza)
      GROUP BY stringa
      ORDER BY stringa;

      d_return :=
         GET_PREFERENZA (d_return,
                         p_modulo,
                         p_utente,
                         p_db_user);

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;
END;
/
