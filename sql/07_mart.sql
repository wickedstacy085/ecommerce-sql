-- Витрина для Power BI: «звезда» из таблицы фактов заказов и справочника клиентов.
create or replace view mart_fact_orders as
select o.order_id,
       o.customer_unique_id,
       o.purchased_at::date                         as purchase_date,
       o.state,
       round(o.revenue, 2)                          as revenue,
       round(o.freight, 2)                          as freight,
       o.items,
       d.delay_days,
       coalesce(d.bucket, 'нет даты доставки')      as delivery_bucket,
       r.review_score,
       row_number() over (partition by o.customer_unique_id
                          order by o.purchased_at, o.order_id) = 1 as is_first_order
from orders o
left join delivery_orders d using (order_id)
left join order_reviews  r using (order_id);

create or replace view mart_dim_customers as
select r.customer_unique_id,
       f.cohort_month::date as cohort_month,
       r.frequency, round(r.monetary, 2) as monetary, r.recency_days,
       r.r, r.f, r.m, r.segment
from rfm r
join customer_first f using (customer_unique_id);
