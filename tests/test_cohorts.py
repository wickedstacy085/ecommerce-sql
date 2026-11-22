import pytest
from conftest import one

from shop.db import query


def test_retention_month_zero_is_one(con):
    c = query(con, "cohorts")
    assert (c.loc[c["offset"] == 0, "retention"] == 1).all()


def test_cohorts_cover_all_customers(con):
    c = query(con, "cohorts")
    assert c.loc[c["offset"] == 0, "customers"].sum() == one(
        con, "select count(distinct customer_unique_id) from orders")


def test_offset_within_observed_window(con):
    c = query(con, "cohorts")
    last = one(con, "select date_trunc('month', max(purchased_at)) from orders")
    months_left = (last.year - c["cohort_month"].dt.year) * 12 + (last.month - c["cohort_month"].dt.month)
    assert (c["offset"] <= months_left).all()
    # у каждой когорты есть все offset от 0 до конца окна (нули — тоже строки)
    assert (c.groupby("cohort_month")["offset"].count() == months_left.groupby(c["cohort_month"]).first() + 1).all()


def test_ltv_non_decreasing(con):
    l = query(con, "ltv").sort_values(["cohort_month", "offset"])
    assert (l.groupby("cohort_month")["cum_revenue_per_customer"].diff().dropna() >= -1e-9).all()


def test_ltv_month_zero_equals_first_month_revenue(con):
    l = query(con, "ltv")
    first = l[l["offset"] == 0]
    total = one(con, """
        with f as (select customer_unique_id, date_trunc('month', min(purchased_at)) cm
                   from orders group by 1)
        select sum(o.revenue) / count(distinct f.customer_unique_id) from orders o join f using (customer_unique_id)
        where date_trunc('month', o.purchased_at) = f.cm and f.cm = timestamp '2017-06-01'""")
    got = first.loc[first["cohort_month"] == "2017-06-01", "cum_revenue_per_customer"].iloc[0]
    assert got == pytest.approx(total)
