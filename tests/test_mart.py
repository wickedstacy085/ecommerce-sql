import pytest
from conftest import one

from shop.db import query


def test_fact_revenue_matches_orders(con):
    f = query(con, "mart_fact_orders")
    assert f["order_id"].is_unique
    assert f["revenue"].sum() == pytest.approx(one(con, "select sum(revenue) from orders"))


def test_dim_covers_fact(con):
    f = query(con, "mart_fact_orders")
    d = query(con, "mart_dim_customers")
    assert d["customer_unique_id"].is_unique
    assert set(f["customer_unique_id"]) <= set(d["customer_unique_id"])


def test_first_order_flag_one_per_customer(con):
    f = query(con, "mart_fact_orders")
    assert (f.groupby("customer_unique_id")["is_first_order"].sum() == 1).all()
