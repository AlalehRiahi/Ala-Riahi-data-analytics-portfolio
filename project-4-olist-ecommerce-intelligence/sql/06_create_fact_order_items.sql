-------------------------------------------------------------------
-- 06_create_fact_order_items.sql
-- Build fact_order_items from olist_order_items_dataset
-------------------------------------------------------------------

DROP TABLE IF EXISTS fact_order_items;

CREATE TABLE fact_order_items AS
SELECT
    -- optional surrogate key if you want one
    -- ROW_NUMBER() OVER ()::bigint AS order_item_key,
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    oi.shipping_limit_date,
    TO_CHAR(DATE(oi.shipping_limit_date), 'YYYYMMDD')::int AS shipping_limit_date_key,

    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS item_total_value
FROM olist_order_items_dataset oi;

-- If you want a composite PK:
ALTER TABLE fact_order_items
    ADD CONSTRAINT pk_fact_order_items PRIMARY KEY (order_id, order_item_id);

-- Optional FKs
-- ALTER TABLE fact_order_items
--   ADD CONSTRAINT fk_order_items_order
--       FOREIGN KEY (order_id) REFERENCES fact_orders(order_id);
-- ALTER TABLE fact_order_items
--   ADD CONSTRAINT fk_order_items_product
--       FOREIGN KEY (product_id) REFERENCES dim_products(product_id);
-- ALTER TABLE fact_order_items
--   ADD CONSTRAINT fk_order_items_seller
--       FOREIGN KEY (seller_id) REFERENCES dim_sellers(seller_id);