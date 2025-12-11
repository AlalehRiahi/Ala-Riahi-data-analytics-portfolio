"""
Export cleaned vw_category_monthly_metrics to CSV and Excel.

- Connects to the olist_analytics database
- Reads the vw_category_monthly_metrics view
- Cleans:
    * Empty / missing category names -> "Unknown"
    * Drops months with very few total orders (based on distinct_orders)
- Writes:
    * data_exports/category_monthly_metrics.csv
    * data_exports/category_monthly_metrics.xlsx

Adjust the column names and thresholds in the CONFIG section if needed.
"""

from pathlib import Path
import pandas as pd
import psycopg


# -------------------------------------------------------------------
# CONFIG
# -------------------------------------------------------------------

# Database connection
DB_NAME = "olist_analytics"
DB_USER = "alalehriahi"
DB_HOST = "localhost"
DB_PORT = 5432
DB_PASSWORD = None  # set a string here if you ever add a password

# View to export
VIEW_NAME = "vw_category_monthly_metrics"

# Column names in the view (adjust these if your view uses different names)
CATEGORY_COL = "product_category_name_english"   # category name column
MONTH_COL = "year_month"                         # month key column
ORDER_COUNT_COL = "distinct_orders"              # you confirmed this name

# Business rule: keep only months where total distinct orders >= this number
MIN_ORDERS_PER_MONTH = 50

# Output paths
EXPORT_DIR = Path("data_exports")
EXPORT_DIR.mkdir(exist_ok=True)

CSV_PATH = EXPORT_DIR / "category_monthly_metrics.csv"
EXCEL_PATH = EXPORT_DIR / "category_monthly_metrics.xlsx"


# -------------------------------------------------------------------
# MAIN LOGIC
# -------------------------------------------------------------------

def get_connection():
    """Create a PostgreSQL connection using psycopg."""
    conn_kwargs = {
        "dbname": DB_NAME,
        "user": DB_USER,
        "host": DB_HOST,
        "port": DB_PORT,
    }
    if DB_PASSWORD:
        conn_kwargs["password"] = DB_PASSWORD
    return psycopg.connect(**conn_kwargs)


def main():
    print("🔌 Connecting to PostgreSQL...")
    conn = get_connection()

    query = f"SELECT * FROM {VIEW_NAME};"
    print("▶ Running query:")
    print("   ", query)

    df = pd.read_sql(query, conn)
    conn.close()

    print(f"✅ Fetched {len(df):,} rows from {VIEW_NAME}.")
    print("   Columns:", list(df.columns))

    # ---------------------------------------------------------------
    # 1) Clean category names: empty / NULL -> "Unknown"
    # ---------------------------------------------------------------
    if CATEGORY_COL in df.columns:
        print(f"\n🧹 Cleaning category column: {CATEGORY_COL}")
        df[CATEGORY_COL] = df[CATEGORY_COL].fillna("").astype(str).str.strip()
        empty_before = (df[CATEGORY_COL] == "").sum()
        print(f"   Empty values before cleaning: {empty_before}")
        df.loc[df[CATEGORY_COL] == "", CATEGORY_COL] = "Unknown"
        empty_after = (df[CATEGORY_COL] == "").sum()
        print(f"   Empty values after cleaning:  {empty_after}")
    else:
        print(f"\n⚠ WARNING: CATEGORY_COL '{CATEGORY_COL}' not found in df.columns. Skipping category cleaning.")

    # ---------------------------------------------------------------
    # 2) Drop months with too few total distinct orders
    # ---------------------------------------------------------------
    if MONTH_COL in df.columns and ORDER_COUNT_COL in df.columns:
        print(f"\n📉 Filtering out months with total {ORDER_COUNT_COL} < {MIN_ORDERS_PER_MONTH}...")

        # total orders per month (across all categories)
        month_order_counts = df.groupby(MONTH_COL)[ORDER_COUNT_COL].sum()
        print("   Month -> total distinct orders:")
        print(month_order_counts)

        valid_months = month_order_counts[month_order_counts >= MIN_ORDERS_PER_MONTH].index

        print(f"\n   Keeping {len(valid_months)} month(s) with >= {MIN_ORDERS_PER_MONTH} orders.")
        before_rows = len(df)
        df = df[df[MONTH_COL].isin(valid_months)]
        after_rows = len(df)
        print(f"   Rows before filtering: {before_rows:,}")
        print(f"   Rows after filtering:  {after_rows:,}")
    else:
        print(f"\n⚠ WARNING: Could not find both MONTH_COL '{MONTH_COL}' and ORDER_COUNT_COL '{ORDER_COUNT_COL}'.")
        print("   Skipping month-level filtering.")

    # ---------------------------------------------------------------
    # 3) Export to Excel and CSV
    # ---------------------------------------------------------------
    df.to_excel(EXCEL_PATH, index=False)
    print(f"\n💾 Excel exported to: {EXCEL_PATH}")

    df.to_csv(CSV_PATH, index=False)
    print(f"💾 CSV exported to:   {CSV_PATH}")

    print("\n🎉 Export complete.")


if __name__ == "__main__":
    main()