-- RFM. R и M — квинтили (5 — лучше). F по квинтилям не считается: 97% клиентов купили один раз,
-- поэтому F — по числу заказов: 1 заказ → 1, 2 → 3, 3+ → 5.
create or replace view rfm as
with c as (
    select customer_unique_id,
           date_diff('day', max(purchased_at),
                     (select max(purchased_at) from orders) + interval 1 day) as recency_days,
           count(*)     as frequency,
           sum(revenue) as monetary
    from orders
    group by 1
),
s as (
    select *,
           ntile(5) over (order by recency_days desc) as r,
           case when frequency = 1 then 1 when frequency = 2 then 3 else 5 end as f,
           ntile(5) over (order by monetary) as m
    from c
)
select *,
       case
           when f >= 3 and r >= 4             then 'Постоянные, недавние'
           when f >= 3                        then 'Постоянные, давно не покупали'
           when r >= 4 and m >= 4             then 'Новые, крупный чек'
           when r >= 4                        then 'Новые'
           when r <= 2 and m >= 4             then 'Ушедшие, крупный чек'
           when r <= 2                        then 'Ушедшие'
           else                                    'Спящие'
       end as segment
from s;
