#!/usr/bin/env python3
"""
Extract Customer LTV dataset from Postgres view `vw_customer_ltv`
and export:
- python/outputs/customer_ltv.csv
- python/outputs/ltv_summary.csv

Usage:
  python python/01_extract_customer_ltv.py

"""

from __future__ import annotations

import os
from pathlib import Path
import sys
import pandas as pd

# Optional: load .env if present (keeps secrets out of code)
try:
    from dotenv import load_dotenv  # type: ignore
    load_dotenv()
except Exception:
    pass


VIEW_NAME = "vw_customer_ltv"


def get_conn_info() -> dict:
    host = os.getenv("PGHOST", "localhost")
    port = int(os.getenv("PGPORT", "5432"))
    dbname = os.getenv("PGDATABASE", "olist_analytics")
    user = os.getenv("PGUSER") or ""
    password = os.getenv("PGPASSWORD") or ""

    missing = []
    if not user:
        missing.append("PGUSER")
    if not password:
        missing.append("PGPASSWORD")

    if missing:
        raise RuntimeError(
            f"Missing required env vars: {', '.join(missing)}.\n"
            "Set them in your shell or create a .env file (recommended)."
        )

    return {
        "host": host,
        "port": port,
        "dbname": dbname,
        "user": user,
        "password": password,
    }


def project_root() -> Path:
    # This file lives at: <root>/python/01_extract_customer_ltv.py
    return Path(__file__).resolve().parents[1]


def ensure_outputs_dir() -> Path:
    out_dir = project_root() / "python" / "outputs"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "figures").mkdir(parents=True, exist_ok=True)
    return out_dir


def extract_view_to_df() -> pd.DataFrame:
    import psycopg  # psycopg v3

    conn_info = get_conn_info()

    sql = f"SELECT * FROM {VIEW_NAME};"

    with psycopg.connect(**conn_info) as conn:
        df = pd.read_sql(sql, conn)

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """
    Tries to create a useful summary without assuming exact column names.
    It will look for common LTV-like fields if present.
    """
    # normalize columns to lowercase for detection
    cols = {c.lower(): c for c in df.columns}

    def find_any(candidates):
        for c in candidates:
            if c in cols:
                return cols[c]
        return None

    customer_col = find_any(["customer_id", "customer_unique_id"])
    orders_col = find_any(["order_count", "orders", "distinct_orders", "n_orders"])
    revenue_col = find_any(["ltv", "lifetime_value", "total_revenue", "revenue", "gmv"])

    summary_rows = []

    summary_rows.append(("rows", len(df)))

    if customer_col:
        summary_rows.append(("distinct_customers", df[customer_col].nunique(dropna=True)))

    if orders_col and pd.api.types.is_numeric_dtype(df[orders_col]):
        summary_rows.append(("total_orders", float(df[orders_col].sum())))
        summary_rows.append(("avg_orders_per_customer", float(df[orders_col].mean())))

    if revenue_col and pd.api.types.is_numeric_dtype(df[revenue_col]):
        summary_rows.append(("total_revenue", float(df[revenue_col].sum())))
        summary_rows.append(("avg_revenue_per_customer", float(df[revenue_col].mean())))
        summary_rows.append(("median_revenue_per_customer", float(df[revenue_col].median())))

    summary = pd.DataFrame(summary_rows, columns=["metric", "value"])
    return summary


def main() -> int:
    out_dir = ensure_outputs_dir()
    out_csv = out_dir / "customer_ltv.csv"
    out_summary = out_dir / "ltv_summary.csv"

    print(f"Project root: {project_root()}")
    print(f"Extracting view: {VIEW_NAME}")

    df = extract_view_to_df()
    print(f"Pulled {len(df):,} rows, {len(df.columns)} columns.")

    df.to_csv(out_csv, index=False)
    print(f"Saved: {out_csv}")

    summary = build_summary(df)
    summary.to_csv(out_summary, index=False)
    print(f"Saved: {out_summary}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("\nCanceled.")
        raise
    except Exception as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        raise