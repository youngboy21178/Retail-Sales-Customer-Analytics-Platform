-- ============================================================
-- Query: RFM Customer Segmentation
-- Business question: Segment customers by Recency, Frequency,
--                     and Monetary value of their purchases
-- Techniques: CTE, JOIN, GROUP BY, Window function (NTILE/RANK),
--             CASE WHEN, subquery
-- Note: using order_purchase_timestamp for recency calculation;
--       customer_unique_id used instead of customer_id (see
--       retention query note — customer_id is per-order, not
--       per-customer).
-- ============================================================

WITH order_customer_table AS (
    SELECT o.order_id, c.customer_unique_id, o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
),
raw_user_metrics_table AS (
    SELECT
        oct.customer_unique_id,
        SUM(op.payment_value) AS monetary,
        COUNT(DISTINCT oct.order_id) AS frequency,
        now()::date - MAX(oct.order_purchase_timestamp)::date AS recency_days
    FROM order_customer_table oct
    JOIN order_payments op ON op.order_id = oct.order_id
    GROUP BY oct.customer_unique_id
),
user_metrics_table as (
	SELECT
	    customer_unique_id,
	    monetary,
	    frequency,
	    recency_days,
	    NTILE(5) OVER (ORDER BY monetary) AS m_score,
	    NTILE(5) OVER (ORDER BY frequency) AS f_score,
	    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score
	FROM raw_user_metrics_table
),
rfm_segments as (
	select *,
		CASE
		    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
		    WHEN r_score >= 3 AND f_score >= 3                   THEN 'Loyal Customers'
		    WHEN r_score >= 4 AND f_score <= 2                    THEN 'New Customers'
		    WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3   THEN 'At Risk'
		    WHEN r_score <= 2 AND f_score <= 2                    THEN 'Lost'
		    ELSE 'Others'
		END AS segment
	from user_metrics_table
)
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ())::numeric, 1) AS pct_of_total,
    ROUND(AVG(monetary)::numeric, 2) AS avg_monetary
FROM rfm_segments
GROUP BY segment
ORDER BY customer_count DESC;
