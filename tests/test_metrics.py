import pytest
from conftest import one

from shop.db import query


def test_rfm_one_segment_per_customer(con):
    r = query(con, "rfm")
    assert r["customer_unique_id"].is_unique
    assert len(r) == one(con, "select count(distinct customer_unique_id) from orders")
    assert r["segment"].notna().all()
    assert r[["r", "f", "m"]].isin([1, 2, 3, 4, 5]).all().all()


def test_unit_economics_gmv_matches(con):
    u = query(con, "unit_economics")
    assert u["gmv"].sum() == pytest.approx(one(con, "select sum(revenue) from orders"))
    for col in ["freight_share", "repeat_rate"]:
        assert u[col].between(0, 1).all()
    assert u["aov"].tolist() == pytest.approx((u["gmv"] / u["orders"]).tolist())


def test_delivery_buckets(con):
    d = query(con, "delivery").set_index("bucket")
    assert list(d.index) == ["раньше на 7+ дней", "в срок", "1–3 дня", "4–7 дней", "8+ дней"]
    assert d.loc["8+ дней", "avg_review"] < d.loc["в срок", "avg_review"]
    for col in ["share_1_2_stars", "repeat_rate"]:
        assert d[col].between(0, 1).all()
    assert d["orders"].sum() == one(con, "select count(*) from orders where delivered_at is not null")
