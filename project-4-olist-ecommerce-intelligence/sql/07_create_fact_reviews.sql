-------------------------------------------------------------------
-- 07_create_fact_reviews.sql
-- Build fact_reviews from raw review data
-- Includes deduplication logic for duplicate review_id values
-- and joins to fact_orders to calculate review delay.
-------------------------------------------------------------------

-- Remove the table if it already exists
DROP TABLE IF EXISTS fact_reviews;

-------------------------------------------------------------------
-- Build fact_reviews (with deduplication)
-------------------------------------------------------------------

CREATE TABLE fact_reviews AS
WITH deduped_reviews AS (
    SELECT
        r.*,
        ROW_NUMBER() OVER (
            PARTITION BY r.review_id
            ORDER BY
                r.review_creation_date DESC NULLS LAST,
                r.review_answer_timestamp DESC NULLS LAST
        ) AS rn
    FROM olist_order_reviews_dataset r
)
SELECT
    dr.review_id,
    dr.order_id,
    dr.review_score,
    dr.review_comment_title,
    dr.review_comment_message,

    dr.review_creation_date,
    dr.review_answer_timestamp,

    -- Date dimension key for creation date
    CASE
        WHEN dr.review_creation_date IS NOT NULL
        THEN TO_CHAR(DATE(dr.review_creation_date), 'YYYYMMDD')::int
        ELSE NULL
    END AS review_creation_date_key,

    -- Date dimension key for answer timestamp
    CASE
        WHEN dr.review_answer_timestamp IS NOT NULL
        THEN TO_CHAR(DATE(dr.review_answer_timestamp), 'YYYYMMDD')::int
        ELSE NULL
    END AS review_answer_date_key,

    -- Days between customer receiving the product and submitting the review
    CASE
        WHEN dr.review_creation_date IS NOT NULL
         AND fo.order_delivered_customer_date IS NOT NULL
        THEN DATE(dr.review_creation_date) - DATE(fo.order_delivered_customer_date)
        ELSE NULL
    END AS review_delay_days,

    -- Basic sentiment buckets
    CASE WHEN dr.review_score <= 2 THEN 1 ELSE 0 END AS is_low_review,
    CASE WHEN dr.review_score = 3 THEN 1 ELSE 0 END AS is_neutral_review,
    CASE WHEN dr.review_score >= 4 THEN 1 ELSE 0 END AS is_high_review

FROM deduped_reviews dr
LEFT JOIN fact_orders fo
    ON dr.order_id = fo.order_id
WHERE dr.rn = 1;

-------------------------------------------------------------------
-- Add primary key
-------------------------------------------------------------------

ALTER TABLE fact_reviews
    ADD CONSTRAINT pk_fact_reviews PRIMARY KEY (review_id);