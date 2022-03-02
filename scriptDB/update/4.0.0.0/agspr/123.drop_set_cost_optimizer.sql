--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_123.drop_set_cost_optimizer
begin
    execute immediate 'DROP TRIGGER SET_COST_OPTIMIZER';
exception when others then
    null;
end;
/