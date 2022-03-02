--liquibase formatted sql
--changeset rdestasio:4.0.1.0_20200703_166_upd_seg_bottoni_notifiche

UPDATE seg_bottoni_notifiche
   SET sequenza = '10'
 WHERE   azione = 'operazione=CARICO'
       AND stato = 'R'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '20'
 WHERE   azione = 'operazione=CARICO_ESEGUI'
       AND stato = 'R'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '30'
 WHERE   azione = 'operazione=APRI_SMISTA_FLEX'
       AND stato = 'R'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '40'
 WHERE   azione = 'operazione=APRI_CARICO_ASSEGNA'
       AND stato = 'R'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '50'
 WHERE   azione = 'operazione=APRI_SMISTA_ESEGUI_FLEX'
       AND stato = 'R'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '60'
 WHERE   azione = 'operazione=APRI_CARICO_FLEX'
       AND stato = 'R'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '100'
 WHERE   azione = 'operazione=ESEGUI'
       AND stato = 'A'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '110'
 WHERE   azione = 'operazione=APRI_SMISTA_FLEX'
       AND stato = 'A'
/


UPDATE seg_bottoni_notifiche
   SET sequenza = '120'
 WHERE   azione = 'operazione=APRI_INOLTRA_FLEX'
       AND stato = 'A'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '130'
 WHERE   azione = 'operazione=APRI_ASSEGNA'
       AND stato = 'A'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '200'
 WHERE   azione = 'operazione=ESEGUI'
       AND stato = 'C'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '210'
 WHERE   azione = 'operazione=APRI_SMISTA_FLEX'
       AND stato = 'C'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '220'
 WHERE   azione = 'operazione=APRI_INOLTRA_FLEX'
       AND stato = 'C'
/

UPDATE seg_bottoni_notifiche
   SET sequenza = '230'
 WHERE   azione = 'operazione=APRI_ASSEGNA'
       AND stato = 'C'
/
