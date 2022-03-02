--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_UNIT_EXT_FUNC runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_unit_ext_func (
   old_codice_uo        VARCHAR2,
   new_codice_uo        VARCHAR2,
   old_descrizione_uo   VARCHAR2,
   new_descrizione_uo   VARCHAR2,
   old_dal              DATE,
   new_dal              DATE,
   new_al               DATE
)
AS
   x   NUMBER;
   PRAGMA AUTONOMOUS_TRANSACTION;
   d_old_descrizione_uo varchar2(4000);
   d_new_descrizione_uo varchar2(4000) := new_codice_uo||' - '||new_descrizione_uo;
BEGIN
   if old_descrizione_uo is not null then
      d_old_descrizione_uo := old_codice_uo||' - '||old_descrizione_uo;
   end if;
   DBMS_JOB.submit
      (job         => x,
       what        => 'begin ag_unit_instead_tu('''|| old_codice_uo|| ''', '''|| new_codice_uo|| ''',
                        '''|| d_old_descrizione_uo|| ''', '''|| d_new_descrizione_uo|| ''','||
                        'to_date('''|| TO_CHAR (old_dal, 'dd/mm/yyyy')|| ''',''dd/mm/yyyy''),'||
                        'to_date('''|| TO_CHAR (new_dal, 'dd/mm/yyyy')|| ''',''dd/mm/yyyy''),'||
                        'to_date('''|| TO_CHAR (new_al, 'dd/mm/yyyy')|| ''',''dd/mm/yyyy'')); '||
                      'end;',
       next_date   => sysdate,
       no_parse    => FALSE
      );
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
END;
/
