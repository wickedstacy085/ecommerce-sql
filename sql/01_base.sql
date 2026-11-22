-- Базовый слой: один доставленный заказ = одна строка.
-- Клиент — customer_unique_id: customer_id в Olist новый у каждого заказа,
-- и по нему повторных покупок не видно вообще.
create or replace view orders as
with items as (
    select order_id,
           sum(price + freight_value) as revenue,
           sum(freight_value)         as freight,
           count(*)                   as items
    from raw_order_items
    group by order_id
)
select o.order_id,
       c.customer_unique_id,
       c.customer_state                    as state,
       o.order_purchase_timestamp          as purchased_at,
       o.order_delivered_customer_date     as delivered_at,
       o.order_estimated_delivery_date     as estimated_at,
       i.revenue, i.freight, i.items
from raw_orders o
join raw_customers c using (customer_id)
join items i using (order_id)
where o.order_status = 'delivered'
  and o.order_purchase_timestamp >= (select period_start from params)
  and o.order_purchase_timestamp <  (select period_end   from params);

-- Один отзыв на заказ: самый поздний по дате ответа.
create or replace view order_reviews as
select order_id, review_score, review_creation_date
from raw_order_reviews
qualify row_number() over (partition by order_id
                           order by review_answer_timestamp desc, review_id) = 1;
