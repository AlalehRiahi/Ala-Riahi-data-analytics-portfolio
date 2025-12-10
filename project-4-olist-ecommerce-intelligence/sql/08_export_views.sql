-------------------------------------------------------------------
-- 08_export_views.sql
-- Export / analytics views built on the dimensional model
--
-- Goals:
--   - Keep proper relational/star structure
--   - Make it easy to use from Excel, Python, Tableau
--
-- Views:
--   1) vw_orders_enriched          → order-level fact with customer + dates
--   2) vw_order_items_enriched     → item-level fact with product + seller
--   3) vw_reviews_enriched         → review-level fact with order + customer
--   4) vw_daily_order_metrics      → daily KPIs (good for Tableau)
--   5) vw_category_monthly_metrics → category x month KPIs (Tableau/Python)
-------------------------------------------------------------------

-----------------------------
-- 0. Drop existing views
-----------------------------

DROP VIEW IF EXISTS vw_category_monthly_metrics;
DROP VIEW IF EXISTS vw_daily_order_metrics;
DROP VIEW IF EXISTS vw_reviews_enriched;
DROP VIEW IF EXISTS vw_order_items_enriched;
DROP VIEW IF EXISTS vw_orders_enriched;

-------------------------------------------------------------------
-- 1) Order-level view (for Excel / direct analysis)
-------------------------------------------------------------------
-- One row per order, enriched with:
--   - customer attributes
--   - purchase / delivery dates from dim_date
--   - payment and delivery metrics from fact_orders
-------------------------------------------------------------------

CREATE VIEW vw_orders_enriched AS
SELECT
    fo.order_id,
    fo.customer_id,

    -- Customer
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,

    -- Status & timestamps
    fo.order_status,
    fo.order_purchase_timestamp,
    fo.order_approved_at,
    fo.order_delivered_carrier_date,
    fo.order_delivered_customer_date,
    fo.order_estimated_delivery_date,

    -- Date dimension (purchase)
    fo.purchase_date_key,
    dd_p.date          AS purchase_date,
    dd_p.year          AS purchase_year,
    dd_p.year_month    AS purchase_year_month,
    dd_p.month         AS purchase_month,
    dd_p.day           AS purchase_day_of_month,
    dd_p.day_of_week   AS purchase_day_of_week,

    -- Delivery date dim (actual)
    fo.delivered_date_key,
    dd_d.date          AS delivered_date,
    dd_d.year_month    AS delivered_year_month,

    -- Delivery date dim (estimated)
    fo.estimated_delivery_date_key,
    dd_est.date        AS estimated_delivery_date,
    dd_est.year_month  AS estimated_delivery_year_month,

    -- Latency metrics
    fo.days_to_approve,
    fo.days_to_ship,
    fo.days_to_deliver,
    fo.delivery_delay_days,
    fo.is_late_delivery,

    -- Payment metrics
    fo.total_payment_value,
    fo.num_payment_installments,
    fo.payment_type_count,
    fo.main_payment_type

FROM fact_orders fo
LEFT JOIN dim_customers c
    ON fo.customer_id = c.customer_id
LEFT JOIN dim_date dd_p
    ON fo.purchase_date_key = dd_p.date_key
LEFT JOIN dim_date dd_d
    ON fo.delivered_date_key = dd_d.date_key
LEFT JOIN dim_date dd_est
    ON fo.estimated_delivery_date_key = dd_est.date_key;

-------------------------------------------------------------------
-- 2) Item-level view (for Excel / Tableau detail analysis)
-------------------------------------------------------------------
-- One row per (order, order_item_id) with:
--   - product attributes (category, volume)
--   - seller attributes
--   - item-level value & freight
--   - link back to order-level metrics (late delivery, total_payment_value)
-------------------------------------------------------------------

CREATE VIEW vw_order_items_enriched AS
SELECT
    foi.order_id,
    foi.order_item_id,

    -- Product
    foi.product_id,
    p.product_category_name,
    p.product_category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    p.product_volume_cm3,

    -- Seller
    foi.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,

    -- Shipping
    foi.shipping_limit_date,
    foi.shipping_limit_date_key,

    -- Monetary
    foi.price,
    foi.freight_value,
    foi.item_total_value,

    -- Order-level metrics joined in (denormalized)
    fo.order_status,
    fo.order_purchase_timestamp,
    fo.order_delivered_customer_date,
    fo.order_estimated_delivery_date,
    fo.delivery_delay_days,
    fo.is_late_delivery,
    fo.total_payment_value,
    fo.main_payment_type

FROM fact_order_items foi
LEFT JOIN dim_products p
    ON foi.product_id = p.product_id
LEFT JOIN dim_sellers s
    ON foi.seller_id = s.seller_id
LEFT JOIN fact_orders fo
    ON foi.order_id = fo.order_id;

-------------------------------------------------------------------
-- 3) Review-level view (for Python modeling / Excel)
-------------------------------------------------------------------
-- One row per review_id (already deduped in fact_reviews) with:
--   - review text fields
--   - sentiment flags
--   - review delay vs delivery
--   - order- and customer-level context
-------------------------------------------------------------------

CREATE VIEW vw_reviews_enriched AS
SELECT
    fr.review_id,
    fr.order_id,
    fr.review_score,
    fr.review_comment_title,
    fr.review_comment_message,

    fr.review_creation_date,
    fr.review_answer_timestamp,
    fr.review_creation_date_key,
    fr.review_answer_date_key,
    fr.review_delay_days,

    fr.is_low_review,
    fr.is_neutral_review,
    fr.is_high_review,

    -- Join to orders for status & delay context
    fo.order_status,
    fo.order_purchase_timestamp,
    fo.order_delivered_customer_date,
    fo.delivery_delay_days        AS order_delivery_delay_days,
    fo.is_late_delivery          AS order_is_late_delivery,
    fo.total_payment_value,
    fo.main_payment_type,

    -- Join to customer for geography/context
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state

FROM fact_reviews fr
LEFT JOIN fact_orders fo
    ON fr.order_id = fo.order_id
LEFT JOIN dim_customers c
    ON fo.customer_id = c.customer_id;

-------------------------------------------------------------------
-- 4) Daily order metrics (for Tableau / trend analysis)
-------------------------------------------------------------------
-- Grain: one row per calendar date
-- Metrics:
--   - orders_count
--   - revenue
--   - late_delivery_rate
--   - average_review_score
-------------------------------------------------------------------

CREATE VIEW vw_daily_order_metrics AS
SELECT
    dd.date_key,
    dd.date,
    dd.year,
    dd.year_month,
    dd.month,
    dd.day,
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend,

    COUNT(DISTINCT fo.order_id)                              AS orders_count,
    SUM(fo.total_payment_value)                              AS gross_revenue,

    -- Late deliveries
    SUM(CASE WHEN fo.is_late_delivery = 1 THEN 1 ELSE 0 END) AS late_deliveries,
    CASE
        WHEN COUNT(DISTINCT fo.order_id) > 0
        THEN SUM(CASE WHEN fo.is_late_delivery = 1 THEN 1 ELSE 0 END)::numeric
             / COUNT(DISTINCT fo.order_id)
        ELSE NULL
    END AS late_delivery_rate,

    -- Review score (if present)
    AVG(fr.review_score)                                     AS avg_review_score

FROM dim_date dd
LEFT JOIN fact_orders fo
    ON fo.purchase_date_key = dd.date_key
LEFT JOIN fact_reviews fr
    ON fr.order_id = fo.order_id
GROUP BY
    dd.date_key,
    dd.date,
    dd.year,
    dd.year_month,
    dd.month,
    dd.day,
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend
ORDER BY dd.date;

-------------------------------------------------------------------
-- 5) Category x month performance (for Tableau / Python EDA)
-------------------------------------------------------------------
-- Grain: product_category_name_english x year_month
-- Metrics:
--   - order_items_count
--   - distinct_orders
--   - revenue (sum of item_total_value)
--   - average_freight_ratio (freight / item_total_value)
--   - average_review_score
--   - late_delivery_rate
-------------------------------------------------------------------

CREATE VIEW vw_category_monthly_metrics AS
SELECT
    dd.year,
    dd.year_month,
    p.product_category_name_english,

    COUNT(*)                                    AS order_items_count,
    COUNT(DISTINCT foi.order_id)               AS distinct_orders,
    SUM(foi.item_total_value)                  AS revenue,

    AVG(
        CASE
            WHEN foi.item_total_value > 0
            THEN foi.freight_value / foi.item_total_value
            ELSE NULL
        END
    )                                          AS avg_freight_ratio,

    AVG(fr.review_score)                       AS avg_review_score,

    CASE
        WHEN COUNT(DISTINCT fo.order_id) > 0
        THEN SUM(CASE WHEN fo.is_late_delivery = 1 THEN 1 ELSE 0 END)::numeric
             / COUNT(DISTINCT fo.order_id)
        ELSE NULL
    END                                        AS late_delivery_rate

FROM fact_order_items foi
LEFT JOIN dim_products p
    ON foi.product_id = p.product_id
LEFT JOIN fact_orders fo
    ON foi.order_id = fo.order_id
LEFT JOIN dim_date dd
    ON fo.purchase_date_key = dd.date_key
LEFT JOIN fact_reviews fr
    ON fr.order_id = fo.order_id
GROUP BY
    dd.year,
    dd.year_month,
    p.product_category_name_english
ORDER BY
    dd.year,
    dd.year_month,
    p.product_category_name_english;