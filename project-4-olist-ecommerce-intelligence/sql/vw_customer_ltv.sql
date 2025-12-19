CREATE OR REPLACE VIEW vw_customer_ltv AS
SELECT
    c.customer_unique_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.price) AS total_revenue,

    AVG(oi.price) AS avg_item_price,

    MIN(o.order_purchase_timestamp) AS first_order_date,
    MAX(o.order_purchase_timestamp) AS last_order_date,

    DATE_PART(
        'day',
        MAX(o.order_purchase_timestamp) - MIN(o.order_purchase_timestamp)
    ) AS customer_lifespan_days,

    CASE
        WHEN COUNT(DISTINCT o.order_id) > 1 THEN 1
        ELSE 0
    END AS is_repeat_customer,

    AVG(r.review_score) AS avg_review_score

FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_unique_id;