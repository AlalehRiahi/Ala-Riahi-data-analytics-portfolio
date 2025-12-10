## Refresh Excel export from PostgreSQL (vw_category_monthly_metrics)

Project root:
`/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence`

### One-time setup

```bash
cd "/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence"

python -m venv .venv
source .venv/bin/activate

pip install "psycopg[binary]" pandas openpyxl
```


### rerun for any changes

```bash

cd "/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence"

source .venv/bin/activate
python python/export_category_monthly_metrics.py