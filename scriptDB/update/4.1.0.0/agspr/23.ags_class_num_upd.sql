--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200901_23_1.ags_classificazioni_num_upd

alter table ags_classificazioni_num
   disable all triggers
/
begin
   for c in (select acn.id_classificazione_num, snc.ultimo_numero_sub
               from ags_classificazioni_num acn
                  , ags_classificazioni ac
                  , gdm_seg_classificazioni sc
                  , gdm_seg_numerazioni_classifica snc
              where acn.id_classificazione = ac.id_classificazione
                and -ac.id_classificazione = sc.id_documento
                and sc.class_cod = snc.class_cod
                and sc.class_dal = snc.class_dal
                and acn.anno = snc.anno
                and acn.ultimo_numero_fascicolo <> snc.ultimo_numero_sub)
   loop
      update ags_classificazioni_num
         set ultimo_numero_fascicolo   = c.ultimo_numero_sub
       where id_classificazione_num = c.id_classificazione_num;
   end loop;
end;
/
alter table ags_classificazioni_num
   enable all triggers
/