-- ============================================================
-- Query: Delivery Time vs Review Score Correlation
-- Business question: Is there a correlation between delivery
--                     time and the review score customers leave?
-- Techniques: JOIN (3+ tables), CTE, GROUP BY, CASE WHEN
--             (bucketing), aggregate functions (AVG, CORR)
-- Note: delivery time calculated as
--       order_delivered_customer_date - order_approved_at.
--       Excluded 36 orders with negative delivery_time (data
--       quality issue — order_approved_at later than actual
--       delivery date). Orders without a review or delivery
--       date are naturally excluded via the JOIN.
-- ============================================================

with order_delievery_review_table as (
	select 
		t.review_score as score,
		o.order_delivered_customer_date::date - o.order_approved_at::date as delivery_time
	from orders o 
	join order_reviews t 
	on o.order_id = t.order_id 
),
delivery_bucket_table AS (
    SELECT
        *,
        CASE
            WHEN delivery_time < 6 THEN '0-5 days'
            WHEN delivery_time < 11 THEN '6-10 days'
            WHEN delivery_time < 21 THEN '11-20 days'
            WHEN delivery_time >= 21 THEN '21+ days'
        END AS delivery_bucket
    FROM order_delievery_review_table
    WHERE delivery_time >= 0  -- exclude 36 orders with negative delivery_time
                               -- (data quality issue: order_approved_at later
                               -- than order_delivered_customer_date)
)


SELECT
    delivery_bucket,
    COUNT(*) AS order_count,
    ROUND(AVG(score)::numeric, 2) AS avg_review_score,
    MIN(delivery_time) AS sort_helper
FROM delivery_bucket_table
WHERE delivery_bucket IS NOT NULL
GROUP BY delivery_bucket
ORDER BY sort_helper;

-- ============================================================
-- Extra: Pearson correlation coefficient (delivery_time vs score)
-- ============================================================
WITH order_delievery_review_table AS (
    SELECT
        t.review_score AS score,
        o.order_delivered_customer_date::date - o.order_approved_at::date AS delivery_time
    FROM orders o
    JOIN order_reviews t ON o.order_id = t.order_id
)
SELECT
    ROUND(CORR(delivery_time, score)::numeric, 3) AS correlation_coefficient
FROM order_delievery_review_table
WHERE delivery_time >= 0;
