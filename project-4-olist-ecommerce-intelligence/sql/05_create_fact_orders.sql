-------------------------------------------------------------------
-- 05_create_fact_orders.sql
-- Build fact_orders from olist_orders_dataset + olist_order_payments_dataset
-- Includes delivery delay metrics and payment aggregates.
-------------------------------------------------------------------

DROP TABLE IF EXISTS fact_orders;

CREATE TABLE fact_orders AS
WITH payments AS (
    SELECT
        op.order_id,
        SUM(op.payment_value)            AS total_payment_value,
        MAX(op.payment_installments)     AS num_payment_installments,
        COUNT(DISTINCT op.payment_type)  AS payment_type_count,
        -- Choose the payment_type with the highest total value for the order
        (
            SELECT payment_type
            FROM (
                SELECT
                    op2.payment_type,
                    SUM(op2.payment_value) AS total_val,
                    ROW_NUMBER() OVER (ORDER BY SUM(op2.payment_value) DESC) AS rn
                FROM olist_order_payments_dataset op2
                WHERE op2.order_id = op.order_id
                GROUP BY op2.payment_type
            ) x
            WHERE rn = 1
        ) AS main_payment_type
    FROM olist_order_payments_dataset op
    GROUP BY op.order_id
)
SELECT
    o.order_id,
    o.customer_id,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- Date keys
    CASE
        WHEN o.order_purchase_timestamp IS NOT NULL
        THEN TO_CHAR(DATE(o.order_purchase_timestamp), 'YYYYMMDD')::int
        ELSE NULL
    END AS purchase_date_key,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN TO_CHAR(DATE(o.order_delivered_customer_date), 'YYYYMMDD')::int
        ELSE NULL
    END AS delivered_date_key,

    CASE
        WHEN o.order_estimated_delivery_date IS NOT NULL
        THEN TO_CHAR(DATE(o.order_estimated_delivery_date), 'YYYYMMDD')::int
        ELSE NULL
    END AS estimated_delivery_date_key,

    -- Latency metrics (in days)
    CASE
        WHEN o.order_approved_at IS NOT NULL
        THEN DATE(o.order_approved_at) - DATE(o.order_purchase_timestamp)
        ELSE NULL
    END AS days_to_approve,

    CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
         AND o.order_approved_at IS NOT NULL
        THEN DATE(o.order_delivered_carrier_date) - DATE(o.order_approved_at)
        ELSE NULL
    END AS days_to_ship,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
        THEN DATE(o.order_delivered_customer_date) - DATE(o.order_delivered_carrier_date)
        ELSE NULL
    END AS days_to_deliver,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
        THEN DATE(o.order_delivered_customer_date) - DATE(o.order_estimated_delivery_date)
        ELSE NULL
    END AS delivery_delay_days,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)
        THEN 1 ELSE 0
    END AS is_late_delivery,

    -- Payment aggregates
    COALESCE(p.total_payment_value, 0)      AS total_payment_value,
    COALESCE(p.num_payment_installments, 0) AS num_payment_installments,
    COALESCE(p.payment_type_count, 0)       AS payment_type_count,
    p.main_payment_type                     AS main_payment_type

FROM olist_orders_dataset o
LEFT JOIN payments p
    ON o.order_id = p.order_id;
    
ALTER TABLE fact_orders
    ADD CONSTRAINT pk_fact_orders PRIMARY KEY (order_id);