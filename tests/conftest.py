import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from shop import db  # noqa: E402


@pytest.fixture(scope="session")
def con():
    return db.connect(ROOT)


def one(con, sql: str):
    return con.execute(sql).fetchall()[0][0]
