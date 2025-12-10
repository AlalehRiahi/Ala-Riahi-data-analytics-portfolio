-------------------------------------------------------------------
-- 04_create_dimensions.sql
-- Build analytical dimension tables:
--   dim_date, dim_customers, dim_sellers, dim_products, dim_geolocation
-------------------------------------------------------------------

-------------------------
-- 1. dim_date
-------------------------

DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date AS
WITH bounds AS (
    SELECT
        DATE(MIN(order_purchase_timestamp))      AS min_date,
        DATE(MAX(order_estimated_delivery_date)) AS max_date
    FROM olist_orders_dataset
),
date_series AS (
    SELECT
        GENERATE_SERIES(min_date, max_date, INTERVAL '1 day')::date AS dt
    FROM bounds
)
SELECT
    TO_CHAR(dt, 'YYYYMMDD')::int                                 AS date_key,
    dt                                                            AS date,
    EXTRACT(YEAR  FROM dt)::int                                   AS year,
    EXTRACT(QUARTER FROM dt)::int                                 AS quarter,
    EXTRACT(MONTH FROM dt)::int                                   AS month,
    TO_CHAR(dt, 'TMMonth')                                        AS month_name,
    EXTRACT(DAY   FROM dt)::int                                   AS day,
    EXTRACT(DOW   FROM dt)::int                                   AS day_of_week,  -- 0=Sunday
    TO_CHAR(dt, 'TMDay')                                          AS day_name,
    CASE WHEN EXTRACT(DOW FROM dt) IN (0,6) THEN 1 ELSE 0 END     AS is_weekend,
    TO_CHAR(dt, 'YYYY-MM')                                        AS year_month
FROM date_series
ORDER BY dt;

ALTER TABLE dim_date
    ADD CONSTRAINT pk_dim_date PRIMARY KEY (date_key);

-------------------------
-- 2. dim_customers
-------------------------

DROP TABLE IF EXISTS dim_customers;

CREATE TABLE dim_customers AS
SELECT DISTINCT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state
FROM olist_customers_dataset c;

ALTER TABLE dim_customers
    ADD CONSTRAINT pk_dim_customers PRIMARY KEY (customer_id);

-------------------------
-- 3. dim_sellers
-------------------------

DROP TABLE IF EXISTS dim_sellers;

CREATE TABLE dim_sellers AS
SELECT DISTINCT
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
FROM olist_sellers_dataset s;

ALTER TABLE dim_sellers
    ADD CONSTRAINT pk_dim_sellers PRIMARY KEY (seller_id);

-------------------------
-- 4. dim_products
-------------------------

DROP TABLE IF EXISTS dim_products;

CREATE TABLE dim_products AS
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_name_lenght          AS product_name_length,
    p.product_description_lenght   AS product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    (p.product_length_cm * p.product_height_cm * p.product_width_cm) AS product_volume_cm3
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

ALTER TABLE dim_products
    ADD CONSTRAINT pk_dim_products PRIMARY KEY (product_id);

-------------------------
-- 5. dim_geolocation
-------------------------
-- Aggregate multiple rows per zip_code_prefix to a single representative point.

DROP TABLE IF EXISTS dim_geolocation;

CREATE TABLE dim_geolocation AS
SELECT
    g.geolocation_zip_code_prefix AS zip_code_prefix,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY g.geolocation_lat) AS lat_median,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY g.geolocation_lng) AS lng_median,
    MODE() WITHIN GROUP (ORDER BY g.geolocation_city)              AS geolocation_city,
    MODE() WITHIN GROUP (ORDER BY g.geolocation_state)             AS geolocation_state
FROM olist_geolocation_dataset g
GROUP BY g.geolocation_zip_code_prefix;

ALTER TABLE dim_geolocation
    ADD CONSTRAINT pk_dim_geolocation PRIMARY KEY (zip_code_prefix);