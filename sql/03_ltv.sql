-- Накопленная выручка на одного клиента когорты к месяцу offset.
create or replace view ltv as
with rev as (
    select f.cohort_month,
           date_diff('month', f.cohort_month, date_trunc('month', o.purchased_at)) as "offset",
           sum(o.revenue) as revenue
    from orders o
    join customer_first f using (customer_unique_id)
    group by 1, 2
)
select c.cohort_month, c."offset",
       sum(coalesce(r.revenue, 0)) over (partition by c.cohort_month order by c."offset")
           / c.cohort_size as cum_revenue_per_customer
from cohorts c
left join rev r using (cohort_month, "offset")
order by 1, 2;
