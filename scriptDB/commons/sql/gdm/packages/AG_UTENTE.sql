--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTENTE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_utente
IS
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_property (soamodulo    IN VARCHAR2,
                          app_name     IN VARCHAR2,
                          p_utente     IN VARCHAR2,
                          p_property   IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE set_property (soamodulo     IN VARCHAR2,
                           app_name      IN VARCHAR2,
                           p_utente      IN VARCHAR2,
                           p_property    IN VARCHAR2,
                           p_new_value   IN VARCHAR2);

   FUNCTION get_fontsize (soamodulo   IN VARCHAR2,
                          app_name    IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE set_fontsize (soamodulo        IN VARCHAR2,
                           app_name         IN VARCHAR2,
                           p_new_fontsize   IN VARCHAR2);

   FUNCTION get_brightness (soamodulo   IN VARCHAR2,
                            app_name    IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE set_brightness (soamodulo          IN VARCHAR2,
                             app_name           IN VARCHAR2,
                             p_new_brightness   IN VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY ag_utente
IS
   s_revisione_body   VARCHAR2 (30) := '000';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN s_revisione || '.' || s_revisione_body;
   END versione;

   FUNCTION get_fontsize (soamodulo   IN VARCHAR2,
                          app_name    IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_property   VARCHAR2 (20) := 'Fontsize';
      d_utente     VARCHAR2 (100) := si4.utente;
   BEGIN
      RETURN get_property (soamodulo,
                           --app_name,
                           '',
                           d_utente,
                           d_property);
   END;

   PROCEDURE set_fontsize (soamodulo        IN VARCHAR2,
                           app_name         IN VARCHAR2,
                           p_new_fontsize   IN VARCHAR2)
   IS
      d_property   VARCHAR2 (20) := 'Fontsize';
      d_utente     VARCHAR2 (100) := si4.utente;
   BEGIN
      set_property(soamodulo => soamodulo,
                   app_name => '',
                   p_utente => d_utente,
                   p_property => d_property,
                   p_new_value => p_new_fontsize);
   END;

   FUNCTION get_brightness (soamodulo   IN VARCHAR2,
                            app_name    IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_property   VARCHAR2 (20) := 'Brightness';
      d_utente     VARCHAR2 (100) := si4.utente;
   BEGIN
      RETURN get_property (soamodulo,
                           --app_name,
                           '',
                           d_utente,
                           d_property);
   END;

   PROCEDURE set_brightness (soamodulo          IN VARCHAR2,
                             app_name           IN VARCHAR2,
                             p_new_brightness   IN VARCHAR2)
   IS
      d_property   VARCHAR2 (20) := 'Brightness';
      d_utente     VARCHAR2 (100) := si4.utente;
   BEGIN
      set_property(soamodulo => soamodulo,
                   app_name => '',
                   p_utente => d_utente,
                   p_property => d_property,
                   p_new_value => p_new_brightness);
   END;

   FUNCTION get_property (soamodulo    IN VARCHAR2,
                          app_name     IN VARCHAR2,
                          p_utente     IN VARCHAR2,
                          p_property   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_result        VARCHAR2 (3);
      d_stringa       VARCHAR2 (1000);
      d_stringa_app   VARCHAR2 (1000);
   BEGIN
      d_stringa := 'PRODUCTS/' || UPPER (soamodulo) || '/';

      IF app_name IS NOT NULL
      THEN
         d_stringa_app := d_stringa || UPPER (app_name) || '/' || p_utente;
      END IF;

      d_stringa := d_stringa || p_utente;

      IF app_name IS NOT NULL
      THEN
         DBMS_OUTPUT.PUT_LINE('REGISTRO_UTILITY.LEGGI_STRINGA ('''||d_stringa_app||''', '''||p_property||''', 0)');
         d_result :=
            REGISTRO_UTILITY.LEGGI_STRINGA (d_stringa_app, p_property, 0);
      END IF;

      IF d_result IS NULL
      THEN
         DBMS_OUTPUT.PUT_LINE('REGISTRO_UTILITY.LEGGI_STRINGA ('''||d_stringa||''', '''||p_property||''', 0)');
         d_result := REGISTRO_UTILITY.LEGGI_STRINGA (d_stringa, p_property, 0);
      END IF;

      RETURN d_result;
   END;

   PROCEDURE set_property (soamodulo     IN VARCHAR2,
                           app_name      IN VARCHAR2,
                           p_utente      IN VARCHAR2,
                           p_property    IN VARCHAR2,
                           p_new_value   IN VARCHAR2)
   IS
      d_chiave   VARCHAR2 (1000);
   BEGIN
      d_chiave := 'PRODUCTS/' || UPPER (soamodulo) || '/';

      IF app_name IS NOT NULL
      THEN
         d_chiave := d_chiave || UPPER (app_name) || '/';
      END IF;
      d_chiave := d_chiave || p_utente;

      REGISTRO_UTILITY.SCRIVI_STRINGA (in_chiave      => d_chiave,
                                       in_stringa     => p_property,
                                       in_valore      => p_new_value,
                                       in_commento    => NULL,
                                       in_eccezione   => FALSE);
   END;
END;
/
