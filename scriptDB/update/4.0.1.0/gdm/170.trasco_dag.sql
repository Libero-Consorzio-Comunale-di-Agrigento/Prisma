--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200707_169.trasco_dag failOnError:false

DECLARE
   d_tab   VARCHAR2 (1000);
BEGIN
   FOR tab IN (SELECT DISTINCT tabella_riferimento_gdm
                 FROM dag_mapping_dati
                WHERE area_gdm = 'DATIAGGIUNTIVI.PROTOCOLLO')
   LOOP
      d_tab :=
         'begin ag_agg_dag(''' || tab.tabella_riferimento_gdm || '''); end;';
      DBMS_OUTPUT.put_line (d_tab);

      EXECUTE IMMEDIATE d_tab;
   END LOOP;
END;
/