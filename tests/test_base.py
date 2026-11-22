import pytest
from conftest import one

OFFICIAL = {"orders": 99_441, "order_items": 112_650, "customers": 99_441, "order_payments": 103_886,
            "order_reviews": 99_224, "products": 32_951, "sellers": 3_095,
            "product_category_name_translation": 71}


@pytest.mark.parametrize("table,n", OFFICIAL.items())
def test_raw_row_counts(con, table, n):
    assert one(con, f"select count(*) from raw_{table}") == n


def test_orders_unique_and_delivered(con):
    assert one(con, "select count(*) - count(distinct order_id) from orders") == 0
    assert one(con, "select min(purchased_at) from orders").strftime("%Y-%m") >= "2017-01"
    assert one(con, "select max(purchased_at) from orders").strftime("%Y-%m") <= "2018-08"


def test_revenue_matches_items(con):
    expected = one(con, """
        select sum(i.price + i.freight_value) from raw_order_items i
        join raw_orders o using (order_id)
        where o.order_status = 'delivered'
          and o.order_purchase_timestamp >= (select period_start from params)
          and o.order_purchase_timestamp <  (select period_end from params)""")
    assert one(con, "select sum(revenue) from orders") == pytest.approx(expected)


def test_one_review_per_order(con):
    assert one(con, "select count(*) - count(distinct order_id) from order_reviews") == 0
