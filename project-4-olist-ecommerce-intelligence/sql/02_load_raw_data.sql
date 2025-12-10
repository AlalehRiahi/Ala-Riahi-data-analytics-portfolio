-------------------------------------------------------------------
-- 02_load_raw_data.sql
-- Load CSV files into raw tables using \copy (client-side)
-- Path: /Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw
-------------------------------------------------------------------

-- Optional but useful: clear tables before loading so the script is repeatable
TRUNCATE TABLE
    olist_customers_dataset,
    olist_geolocation_dataset,
    olist_orders_dataset,
    olist_order_items_dataset,
    olist_order_payments_dataset,
    olist_order_reviews_dataset,
    olist_products_dataset,
    olist_sellers_dataset,
    product_category_name_translation;

\echo 'Loading olist_customers_dataset.csv ...'
\copy olist_customers_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_geolocation_dataset.csv ...'
\copy olist_geolocation_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_orders_dataset.csv ...'
\copy olist_orders_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_order_items_dataset.csv ...'
\copy olist_order_items_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_order_payments_dataset.csv ...'
\copy olist_order_payments_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_order_reviews_dataset.csv ...'
\copy olist_order_reviews_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_products_dataset.csv ...'
\copy olist_products_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading olist_sellers_dataset.csv ...'
\copy olist_sellers_dataset FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true);

\echo 'Loading product_category_name_translation.csv ...'
\copy product_category_name_translation FROM '/Users/alalehriahi/Documents/GitHub/Ala-Riahi-data-analytics-portfolio/project-4-olist-ecommerce-intelligence/data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true);

\echo 'All raw tables loaded successfully.'