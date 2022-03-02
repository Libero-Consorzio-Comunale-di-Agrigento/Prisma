--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_DATI_AGGIUNTIVI_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_DATI_AGGIUNTIVI_PKG
AS
   /******************************************************************************
      NAME:       AGP_DATI_AGGIUNTIVI_PKG
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      00         24/10/2017   rdestasio       1. Created this package.
      01                      mferrara        Creata TEST_CIG
      02         13/08/2019   mmalferrari     Creata CHECK_ESISTENZA_RIGA_OB
      03         15/10/2019   scaputo         Creata P_CHECK_ESISTENZA_RIGA_OB
   ******************************************************************************/

   s_revisione   CONSTANT afc.t_revision := '1.02';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION TEST_FLAG_BOLLO (p_id_documento     IN NUMBER,
                             p_tipo_documento   IN VARCHAR2,
                             p_user_id          IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION TEST_CIG (p_id_documento     IN NUMBER,
                      p_tipo_documento   IN VARCHAR2,
                      p_user_id          IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION CHECK_ESISTENZA_RIGA_OB (p_id_documento     IN NUMBER,
                      p_tipo_documento   IN VARCHAR2,p_user_id          IN VARCHAR2)
      RETURN NUMBER;
   PROCEDURE P_CHECK_ESISTENZA_RIGA_OB (p_id_documento     IN NUMBER,
                                     p_tipo_documento   IN VARCHAR2,
                                     p_user_id          IN VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY AG_DATI_AGGIUNTIVI_PKG
IS
    /******************************************************************************
       NAME:       AGP_DATI_AGGIUNTIVI_PKG
       PURPOSE:

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       000         24/10/2017   rdestasio       1. Created this package.
       001                      mferrara        Creata TEST_CIG
       002         13/08/2019   mmalferrari     Creata CHECK_ESISTENZA_RIGA_OB
       003         15/10/2019   scaputo         Creata P_CHECK_ESISTENZA_RIGA_OB
    ******************************************************************************/
    s_revisione_body   CONSTANT afc.t_revision := '003';

    --------------------------------------------------------------------------------
    FUNCTION versione
        RETURN VARCHAR2
    IS
    /******************************************************************************
     NOME:        versione
     DESCRIZIONE: Versione e revisione di distribuzione del package.
     RITORNA:     varchar2 stringa contenente versione e revisione.
     NOTE:        Primo numero  p_ versione compatibilità del Package.
                  Secondo numerop_ revisione del Package specification.
                  Terzo numero  p_ revisione del Package body.
    ******************************************************************************/
    BEGIN
        RETURN afc.VERSION (s_revisione, s_revisione_body);
    END versione;

    --------------------------------------------------------------------------------
    FUNCTION TEST_FLAG_BOLLO (p_id_documento     IN NUMBER,
                              p_tipo_documento   IN VARCHAR2,
                              p_user_id          IN VARCHAR2)
        RETURN NUMBER
    IS
        d_result   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO d_result
          FROM DPR_DUT_NOTEADD n
         WHERE n.id_protocollo = p_id_documento;

        IF (d_result < 1)
        THEN
            raise_application_error (-20999, 'Valorizzare il flag bollo');
        END IF;

        RETURN 1;
    END;

    FUNCTION TEST_CIG (p_id_documento     IN NUMBER,
                       p_tipo_documento   IN VARCHAR2,
                       p_user_id          IN VARCHAR2)
        RETURN NUMBER
    IS
        d_result   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO d_result
          FROM DPR_CIG c
         WHERE c.id_protocollo = p_id_documento AND c.cig IS NOT NULL;

        IF (d_result < 1)
        THEN
            RETURN 0;
        END IF;

        RETURN 1;
    END;

    FUNCTION CHECK_ESISTENZA_RIGA_OB (p_id_documento     IN NUMBER,
                                      p_tipo_documento   IN VARCHAR2,
                                      p_user_id          IN VARCHAR2)
        RETURN NUMBER
    IS
        d_statement        VARCHAR2 (4000);
        d_ret              NUMBER := 1;
        d_tipo_documento   VARCHAR2 (100) := p_tipo_documento;
    BEGIN
--        IF p_id_documento IS NOT NULL
--        THEN
--            IF d_tipo_documento IS NULL
--            THEN
--                SELECT tipo_documento
--                  INTO d_tipo_documento
--                  FROM proto_view
--                 WHERE id_documento = p_id_documento;
--            END IF;
--
--            FOR T
--                IN (SELECT tabella_riferimento_gdm,
--                           NVL (obbligatorio, 'N')                         obbligatorio,
--                           NVL (label_modello, tabella_riferimento_gdm)    label
--                      FROM dag_mapping_dati
--                     WHERE     dag_mapping_dati.tipo_doc = d_tipo_documento
--                           AND dag_mapping_dati.AREA_GDM =
--                               'DATIAGGIUNTIVI.PROTOCOLLO')
--            LOOP
--                IF t.obbligatorio = 'S' AND d_ret = 1
--                THEN
--                    d_statement :=
--                           'SELECT COUNT (*)  FROM '
--                        || t.tabella_riferimento_gdm
--                        || ' WHERE id_protocollo = '
--                        || p_id_documento;
--
--                    DBMS_OUTPUT.put_line (d_statement);
--
--                    EXECUTE IMMEDIATE d_statement
--                        INTO d_ret;
--
--                    DBMS_OUTPUT.put_line (d_ret);
--
--                    IF (d_ret > 0)
--                    THEN
--                        d_ret := 1;
--                    ELSE
--                        raise_application_error (
--                            -20999,
--                               'Inserire un record nei dati aggiuntivi '''
--                            || t.label
--                            || '''');
--                    END IF;
--                END IF;
--            END LOOP;
--        END IF;

        P_CHECK_ESISTENZA_RIGA_OB (p_id_documento,
                                   p_tipo_documento,
                                   p_user_id);
        RETURN d_ret;
    END;

    PROCEDURE P_CHECK_ESISTENZA_RIGA_OB (p_id_documento     IN NUMBER,
                                         p_tipo_documento   IN VARCHAR2,
                                         p_user_id          IN VARCHAR2)
    IS
        d_statement        VARCHAR2 (4000);
        d_s_ret            VARCHAR2 (4000);
        d_ret              NUMBER := 1;
        d_tipo_documento   VARCHAR2 (100) := p_tipo_documento;
    BEGIN
        IF p_id_documento IS NOT NULL
        THEN
            IF d_tipo_documento IS NULL
            THEN
                SELECT tipo_documento
                  INTO d_tipo_documento
                  FROM proto_view
                 WHERE id_documento = p_id_documento;
            END IF;

            FOR T
                IN (SELECT tabella_riferimento_gdm,
                           NVL (obbligatorio, 'N')                         obbligatorio,
                           NVL (label_modello, tabella_riferimento_gdm)    label
                      FROM dag_mapping_dati
                     WHERE     dag_mapping_dati.tipo_doc = d_tipo_documento
                           AND dag_mapping_dati.AREA_GDM =
                               'DATIAGGIUNTIVI.PROTOCOLLO')
            LOOP
                IF t.obbligatorio = 'S'
                THEN
                    d_statement :=
                           'SELECT COUNT (*)  FROM '
                        || t.tabella_riferimento_gdm
                        || ' WHERE id_protocollo = '
                        || p_id_documento;

                    --DBMS_OUTPUT.put_line (d_statement);

                    EXECUTE IMMEDIATE d_statement
                        INTO d_ret;

                    --DBMS_OUTPUT.put_line (d_ret);

                    IF (d_ret > 0)
                    THEN
                        d_ret := 1;
                    ELSE
                        IF d_s_ret IS NULL
                        THEN
                            d_s_ret :=
                                   'Inserire un record nei dati aggiuntivi:'
                                || ' '
                                || t.label;
                        ELSE
                            d_s_ret := d_s_ret || ', ' || t.label;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF d_s_ret IS NOT NULL
        THEN
            raise_application_error (-20999, d_s_ret);
        END IF;
    END;
END;
/
