--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_CART_STATO_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_cart_stato_tu
   AFTER UPDATE OF stato
   ON cartelle
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   d_ret          NUMBER := 0;
   a_messaggio    VARCHAR2 (200) := '';
   a_istruzione   VARCHAR2 (800) := '';
/******************************************************************************
   NAME:       AG_CART_STATO_TU
   PURPOSE:    Se una cartella viene cancellata ed è una cartella fascicolo,
               riporta indietro la numerazione dei fascicoli sul fascicolo padre
               o sulla classificazione in cui era numerato.
               Un fascicolo è eliminabile solo se è l'ultimo della numerazione,
               quindi è sempre necessario portarla indietro.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/12/2008  AM           1. Created this trigger.A25616.0.0.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CART_STATO_TU
      Sysdate:         04/12/2008
      Date and Time:   04/12/2008, 10.35.52, and 04/12/2008 10.35.52
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      CARTELLE (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   DBMS_OUTPUT.put_line ('INIZIO ' || :NEW.stato || '-' || :OLD.stato);

   IF     NVL (:NEW.stato, ' ') = 'CA'
      AND NVL (:OLD.stato, ' ') <> NVL (:NEW.stato, '')
   THEN
      a_messaggio :=
            'FALLITA CANCELLAZIONE FASCICOLO (ID_CARTELLA='
         || :NEW.id_cartella
         || ')';
      a_istruzione :=
            'declare '
         || 'd_ret number; '
         || 'd_count number:=0; '
         || 'Begin '
         || '   select count(*) into d_count from seg_fascicoli where id_documento='''
         || :NEW.id_documento_profilo
         || '''; '
         || '   if (d_count=1) '
         || '   THEN '
         || '       d_ret:= AG_UTILITIES.ripristina_ultimo('''
         || :NEW.id_documento_profilo
         || '''); '
         || '   END IF; '
         || 'end; ';
      integritypackage.set_postevent (a_istruzione, a_messaggio);
   END IF;
END ag_cart_stato_tu;
/
