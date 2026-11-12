-- Observable source issues remain visible. No speculative values are filled.
SELECT 'customers' AS source_table, count(*) AS rows FROM olist.customers
UNION ALL SELECT 'orders',count(*) FROM olist.orders
UNION ALL SELECT 'order_items',count(*) FROM olist.order_items
UNION ALL SELECT 'order_payments',count(*) FROM olist.order_payments
UNION ALL SELECT 'order_reviews',count(*) FROM olist.order_reviews
UNION ALL SELECT 'products',count(*) FROM olist.products
UNION ALL SELECT 'sellers',count(*) FROM olist.sellers
UNION ALL SELECT 'category_translation',count(*) FROM olist.category_translation;

SELECT count(*) FILTER (WHERE order_status='delivered') AS delivered_orders,
       count(*) FILTER (WHERE order_status='delivered' AND order_delivered_customer_date IS NULL) AS delivered_missing_actual_date,
       count(*) FILTER (WHERE order_status='delivered' AND order_estimated_delivery_date IS NULL) AS delivered_missing_estimate,
       count(*) FILTER (WHERE order_status='delivered' AND order_delivered_customer_date < order_purchase_timestamp) AS negative_delivery_intervals,
       count(*) FILTER (WHERE item_gmv IS NULL) AS orders_without_items,
       count(*) FILTER (WHERE payment_value IS NULL) AS orders_without_payments,
       count(*) FILTER (WHERE review_score IS NULL) AS orders_without_reviews
FROM olist.order_facts;

SELECT count(*) AS review_rows, count(DISTINCT review_id) AS distinct_review_ids,
       count(DISTINCT order_id) AS reviewed_orders
FROM olist.order_reviews;

SELECT count(*) AS products,
       count(*) FILTER (WHERE p.product_category_name IS NULL) AS missing_categories,
       count(*) FILTER (WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL) AS products_without_translation
FROM olist.products p LEFT JOIN olist.category_translation t USING (product_category_name);

SELECT 'order_table' AS stage, count(*) AS rows, NULL::numeric AS item_gmv, NULL::numeric AS payment_value FROM olist.orders
UNION ALL SELECT 'source_items',NULL,sum(price),NULL FROM olist.order_items
UNION ALL SELECT 'source_payments',NULL,NULL,sum(payment_value) FROM olist.order_payments
UNION ALL SELECT 'joined_order_facts',count(*),sum(item_gmv),sum(payment_value) FROM olist.order_facts;
