-- Когорта = месяц первой покупки клиента; retention = доля когорты, купившая в месяце offset.
create or replace view customer_first as
select customer_unique_id,
       date_trunc('month', min(purchased_at)) as cohort_month
from orders
group by 1;

create or replace view customer_activity as
select distinct o.customer_unique_id, f.cohort_month,
       date_diff('month', f.cohort_month, date_trunc('month', o.purchased_at)) as "offset"
from orders o
join customer_first f using (customer_unique_id);

create or replace view cohorts as
with sizes as (
    select cohort_month, count(*) as cohort_size from customer_first group by 1
),
grid as (   -- все offset, которые когорта успела прожить, включая месяцы без покупок
    select s.cohort_month, s.cohort_size, g.o as "offset"
    from sizes s,
         generate_series(0, date_diff('month', s.cohort_month,
                                      (select date_trunc('month', max(purchased_at)) from orders))) g(o)
),
active as (
    select cohort_month, "offset", count(*) as customers
    from customer_activity group by 1, 2
)
select g.cohort_month, g."offset",
       coalesce(a.customers, 0)                   as customers,
       coalesce(a.customers, 0) / g.cohort_size   as retention,
       g.cohort_size
from grid g
left join active a using (cohort_month, "offset")
order by 1, 2;
