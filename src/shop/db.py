"""Подключение к DuckDB: сырые parquet-таблицы как views и SQL-слои из папки sql/."""
from pathlib import Path

import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ["orders", "order_items", "customers", "order_payments", "order_reviews", "products",
       "sellers", "product_category_name_translation"]


def connect(root: str | Path = ROOT) -> duckdb.DuckDBPyConnection:
    """In-memory база: raw_<таблица> поверх parquet, затем все sql/*.sql по порядку номеров."""
    root = Path(root)
    con = duckdb.connect()
    for t in RAW:
        path = (root / "data" / f"{t}.parquet").as_posix().replace("'", "''")
        con.execute(f"create view raw_{t} as select * from read_parquet('{path}')")
    for f in sorted((root / "sql").glob("[0-9][0-9]_*.sql")):
        con.execute(f.read_text(encoding="utf-8"))
    return con


def query(con: duckdb.DuckDBPyConnection, view: str) -> pd.DataFrame:
    """Содержимое view, созданного одним из sql-файлов."""
    return con.execute(f"select * from {view}").df()
