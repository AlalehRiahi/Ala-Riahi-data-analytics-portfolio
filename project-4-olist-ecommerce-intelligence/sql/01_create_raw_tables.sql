-------------------------------------------------------------------
-- 01_create_raw_tables.sql
-- Create raw tables mirroring the Olist CSV files
-------------------------------------------------------------------

DROP TABLE IF EXISTS olist_customers_dataset;
DROP TABLE IF EXISTS olist_geolocation_dataset;
DROP TABLE IF EXISTS olist_orders_dataset;
DROP TABLE IF EXISTS olist_order_items_dataset;
DROP TABLE IF EXISTS olist_order_payments_dataset;
DROP TABLE IF EXISTS olist_order_reviews_dataset;
DROP TABLE IF EXISTS olist_products_dataset;
DROP TABLE IF EXISTS olist_sellers_dataset;
DROP TABLE IF EXISTS product_category_name_translation;

-----------------------------
-- Customers
-----------------------------
CREATE TABLE olist_customers_dataset (
    customer_id              TEXT PRIMARY KEY,
    customer_unique_id       TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city            TEXT,
    customer_state           TEXT
);

-----------------------------
-- Geolocation
-----------------------------
CREATE TABLE olist_geolocation_dataset (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             DOUBLE PRECISION,
    geolocation_lng             DOUBLE PRECISION,
    geolocation_city            TEXT,
    geolocation_state           TEXT
);

-----------------------------
-- Orders (core)
-----------------------------
CREATE TABLE olist_orders_dataset (
    order_id                     TEXT PRIMARY KEY,
    customer_id                  TEXT NOT NULL,
    order_status                 TEXT,
    order_purchase_timestamp     TIMESTAMP,
    order_approved_at            TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date DATE
);

-----------------------------
-- Order items
-----------------------------
CREATE TABLE olist_order_items_dataset (
    order_id           TEXT,
    order_item_id      INTEGER,
    product_id         TEXT,
    seller_id          TEXT,
    shipping_limit_date TIMESTAMP,
    price              NUMERIC(10,2),
    freight_value      NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-----------------------------
-- Order payments
-----------------------------
CREATE TABLE olist_order_payments_dataset (
    order_id             TEXT,
    payment_sequential   INTEGER,
    payment_type         TEXT,
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2)
);

-----------------------------
-- Order reviews
-----------------------------
CREATE TABLE olist_order_reviews_dataset (
    review_id              TEXT PRIMARY KEY,
    order_id               TEXT,
    review_score           INTEGER,
    review_comment_title   TEXT,
    review_comment_message TEXT,
    review_creation_date   TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-----------------------------
-- Products
-----------------------------
CREATE TABLE olist_products_dataset (
    product_id                 TEXT PRIMARY KEY,
    product_category_name      TEXT,
    product_name_lenght        INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

-----------------------------
-- Sellers
-----------------------------
CREATE TABLE olist_sellers_dataset (
    seller_id              TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city            TEXT,
    seller_state           TEXT
);

-----------------------------
-- Category name translation
-----------------------------
CREATE TABLE product_category_name_translation (
    product_category_name         TEXT PRIMARY KEY,
    product_category_name_english TEXT
);