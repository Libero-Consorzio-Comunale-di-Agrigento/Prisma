--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200318_161_spr_da_fascicolare_upd

declare
   d_data   date;
begin
   for c in (select id_documento
               from spr_da_fascicolare
              where data is null)
   loop
      select min (data_aggiornamento)
        into d_data
        from stati_documento
       where id_documento = c.id_documento;

      update spr_da_fascicolare
         set data   = d_data
       where id_documento = c.id_documento;
   end loop;
end;
/