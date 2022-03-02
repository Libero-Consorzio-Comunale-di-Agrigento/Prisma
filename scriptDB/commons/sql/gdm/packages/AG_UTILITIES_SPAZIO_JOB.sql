--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_SPAZIO_JOB runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     ag_utilities_spazio_job
AS
    FUNCTION pulisci_prin_ca (p_id_documento                NUMBER,
                              p_versione                    VARCHAR2,
                              p_giorni_da_non_cancellare    NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY     ag_utilities_spazio_job
AS
    FUNCTION pulisci_prin_ca (p_id_documento                NUMBER,
                              p_versione                    VARCHAR2,
                              p_giorni_da_non_cancellare    NUMBER) RETURN NUMBER
    IS
    BEGIN
        return 0;
    END;
END;
/
