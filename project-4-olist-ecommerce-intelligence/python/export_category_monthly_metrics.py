"""
Export vw_category_monthly_metrics from PostgreSQL to Excel.

Location:
    project-4-olist-ecommerce-intelligence/python/export_category_monthly_metrics.py

Output:
    ../excel/category_monthly_metrics.xlsx

This script can be re-run any time the SQL view or data changes.
"""

from pathlib import Path
import pandas as pd
import psycopg


# ---------- CONFIGURATION ----------

# Database connection settings
DB_NAME = "olist_analytics"
DB_USER = "alalehriahi"      # your macOS user / postgres role
DB_HOST = "localhost"
DB_PORT = 5432
DB_PASSWORD = None           # set to a string if you ever add a password

# SQL to pull from the view
SQL_QUERY = "SELECT * FROM vw_category_monthly_metrics;"

# Paths (relative to this script file)
PROJECT_ROOT = Path(__file__).resolve().parents[1]
EXCEL_DIR = PROJECT_ROOT / "excel"
EXCEL_DIR.mkdir(exist_ok=True)

OUTPUT_PATH = EXCEL_DIR / "category_monthly_metrics.xlsx"


# ---------- MAIN EXPORT LOGIC ----------

def get_connection():
    """
    Create a PostgreSQL connection using psycopg.
    Adjust password handling here if you ever add one.
    """
    conn_kwargs = {
        "dbname": DB_NAME,
        "user": DB_USER,
        "host": DB_HOST,
        "port": DB_PORT,
    }

    if DB_PASSWORD:
        conn_kwargs["password"] = DB_PASSWORD

    return psycopg.connect(**conn_kwargs)


def export_view_to_excel():
    print("Connecting to PostgreSQL...")
    conn = get_connection()

    try:
        print("Running query:")
        print("   ", SQL_QUERY)
        df = pd.read_sql(SQL_QUERY, conn)

        print(f"Fetched {len(df):,} rows.")
        print(f"Writing Excel file to: {OUTPUT_PATH}")

        # index=False -> no extra index column in Excel
        df.to_excel(OUTPUT_PATH, index=False)

        print("Export complete ✅")
    finally:
        conn.close()
        print("Connection closed.")


if __name__ == "__main__":
    export_view_to_excel()