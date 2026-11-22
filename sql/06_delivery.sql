-- Опоздание доставки → оценка в отзыве → вернулся ли клиент.
-- Срок, который Olist обещает, консервативный: большинство заказов приезжает на 1–2 недели раньше.
-- repeat_rate считается по первым заказам клиентов: доля тех, кто после него купил ещё раз.
create or replace view delivery_orders as
select o.*,
       date_diff('day', o.estimated_at::date, o.delivered_at::date)  as delay_days,
       case
           when date_diff('day', o.estimated_at::date, o.delivered_at::date) <= -7 then 'раньше на 7+ дней'
           when date_diff('day', o.estimated_at::date, o.delivered_at::date) <= 0  then 'в срок'
           when date_diff('day', o.estimated_at::date, o.delivered_at::date) <= 3  then '1–3 дня'
           when date_diff('day', o.estimated_at::date, o.delivered_at::date) <= 7  then '4–7 дней'
           else '8+ дней'
       end as bucket,
       r.review_score,
       row_number() over (partition by o.customer_unique_id order by o.purchased_at, o.order_id) = 1 as is_first,
       count(*)     over (partition by o.customer_unique_id) > 1                         as customer_repeated
from orders o
left join order_reviews r using (order_id)
where o.delivered_at is not null;

create or replace view delivery as
select bucket,
       count(*)                                               as orders,
       avg(delay_days)                                        as avg_delay_days,
       avg(review_score)                                      as avg_review,
       avg((review_score <= 2)::int)                          as share_1_2_stars,
       avg(customer_repeated::int) filter (where is_first)   as repeat_rate,
       count(*) filter (where is_first)                       as first_orders
from delivery_orders
group by 1
order by case bucket when 'раньше на 7+ дней' then 1 when 'в срок' then 2 when '1–3 дня' then 3
                     when '4–7 дней' then 4 else 5 end;
