-- ============================================================
-- Query: Top Categories By Revenue
-- Business question: Top-10 product categories by revenue, per month
-- Techniques: JOIN (3 tables), GROUP BY, Window function (RANK), CTE
-- Note: using order_purchase_timestamp (moment the order was placed)
--       instead of order_approved_at, to avoid NULLs from unconfirmed
--       orders.
-- ============================================================

select
	to_char(month, 'YYYY-MM') as month,
	category,
	price,
	rnk as place
from(
	select
		month,
		category,
		price,
		rank() over(
			partition by month
			order by price desc
		) as rnk
	from(
		select
			date_trunc('month', orders.order_purchase_timestamp) as month,
			order_item_category_table.category as category,
			SUM(order_item_category_table.price) as price
		from orders
		join (select
				order_items.order_id as order_id,
				products.product_category_name as category,
				order_items.price as price
			from order_items
			join products
			on order_items.product_id = products.product_id
		) as order_item_category_table
		on orders.order_id = order_item_category_table.order_id
		group by month, order_item_category_table.category)
)
where rnk < 11
order by month, place;