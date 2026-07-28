-- ============================================================
-- Query: Customer Retention & Time Between Purchases
-- Business question: Which customers made repeat purchases (retention),
--                    and how much time passes between their orders?
-- Techniques: Window functions (LAG/LEAD), CTE, GROUP BY, CASE WHEN
-- Note: using order_purchase_timestamp (moment the order was placed)
--       instead of order_approved_at, to avoid NULLs from unconfirmed
--       orders. One row per order per customer (order_items not joined).
-- ============================================================

SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp,
    RANK() OVER (
        PARTITION BY c.customer_unique_id
        ORDER BY o.order_purchase_timestamp
    ) AS order_number,
    COUNT(*) OVER (
        PARTITION BY c.customer_unique_id
    ) > 1 AS is_repeat_customer,
    LAG(o.order_purchase_timestamp) OVER (
    	PARTITION BY c.customer_unique_id
    	ORDER BY o.order_purchase_timestamp
    ) as prev_order_date,
    o.order_purchase_timestamp::date - LAG(o.order_purchase_timestamp) OVER (
	    PARTITION BY c.customer_unique_id
	    ORDER BY o.order_purchase_timestamp
	)::date AS days_since_prev_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY is_repeat_customer desc;