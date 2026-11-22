"""Выгружает витрину для Power BI в powerbi/*.csv (UTF-8 с BOM, чтобы Excel и Power BI читали кириллицу)."""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from shop import db  # noqa: E402

con = db.connect(ROOT)
for view, name in [("mart_fact_orders", "fact_orders"), ("mart_dim_customers", "dim_customers")]:
    df = db.query(con, view)
    df.to_csv(ROOT / "powerbi" / f"{name}.csv", index=False, encoding="utf-8-sig")
    print(f"{name}.csv: {len(df):,} строк")
