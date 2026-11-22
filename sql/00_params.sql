-- Период анализа: до 2017-01 и после 2018-08 в данных единичные заказы.
create or replace view params as
select timestamp '2017-01-01' as period_start,
       timestamp '2018-09-01' as period_end;
