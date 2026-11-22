-- Юнит-экономика по месяцам: заказы, клиенты, GMV, средний чек, доля доставки, доля повторных заказов.
create or replace view unit_economics as
with o as (
    select *,
           row_number() over (partition by customer_unique_id order by purchased_at, order_id) > 1 as is_repeat
    from orders
)
select date_trunc('month', purchased_at)        as month,
       count(*)                                 as orders,
       count(distinct customer_unique_id)       as customers,
       sum(revenue)                             as gmv,
       sum(revenue) / count(*)                  as aov,
       sum(freight) / sum(revenue)              as freight_share,
       avg(is_repeat::int)                      as repeat_rate
from o
group by 1
order by 1;
