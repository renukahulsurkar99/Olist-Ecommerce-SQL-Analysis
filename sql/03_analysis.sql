-- Q01. What scale, order value and delivery coverage does the sample represent?
-- Item GMV is recorded merchandise value. Payment value includes other charges.
SELECT count(*) AS total_orders,
       count(DISTINCT customer_unique_id) AS unique_customers,
       count(*) FILTER (WHERE order_status = 'delivered') AS delivered_orders,
       sum(item_gmv) FILTER (WHERE order_status = 'delivered') AS delivered_item_gmv,
       round(avg(item_gmv) FILTER (WHERE order_status = 'delivered'), 2) AS average_delivered_order_gmv,
       count(item_gmv) FILTER (WHERE order_status = 'delivered') AS delivered_orders_with_items,
       count(is_late) AS delivery_date_eligible_orders,
       count(*) FILTER (WHERE is_late) AS late_orders,
       round(100.0 * count(*) FILTER (WHERE is_late) / nullif(count(is_late), 0), 2) AS late_delivery_pct,
       round(avg(delivery_days), 2) AS mean_delivery_days
FROM olist.order_facts;

-- Q02. Which order statuses are present, and what share do they represent?
SELECT order_status, count(*) AS orders,
       round(100.0 * count(*) / sum(count(*)) OVER (), 2) AS order_share_pct
FROM olist.orders GROUP BY order_status ORDER BY orders DESC, order_status;

-- Q03. How do delivered merchandise value and order counts change monthly?
-- The full calendar makes LAG a previous-calendar-month comparison.
WITH compared AS (
    SELECT *, lag(delivered_item_gmv) OVER (ORDER BY month) AS prior_month_gmv,
           lag(delivered_item_gmv, 12) OVER (ORDER BY month) AS prior_year_month_gmv
    FROM olist.monthly_performance
)
SELECT month, boundary_month, orders, delivered_orders, delivered_item_gmv,
       round(100 * (delivered_item_gmv - prior_month_gmv)
             / nullif(prior_month_gmv, 0), 2) AS mom_gmv_growth_pct,
       round(100 * (delivered_item_gmv - prior_year_month_gmv)
             / nullif(prior_year_month_gmv, 0), 2) AS yoy_gmv_growth_pct
FROM compared ORDER BY month;

-- Q04. Which customer states contribute delivered orders and merchandise value?
SELECT customer_state, count(*) AS delivered_orders,
       count(DISTINCT customer_unique_id) AS unique_customers,
       sum(item_gmv) AS delivered_item_gmv,
       round(100 * sum(item_gmv) / sum(sum(item_gmv)) OVER (), 2) AS gmv_share_pct,
       round(avg(delivery_days), 2) AS mean_delivery_days,
       count(is_late) AS eligible_deliveries,
       round(100.0 * count(*) FILTER (WHERE is_late) / nullif(count(is_late), 0), 2) AS late_delivery_pct
FROM olist.order_facts WHERE order_status = 'delivered'
GROUP BY customer_state ORDER BY delivered_item_gmv DESC, customer_state;

-- Q05. Which product categories contribute the most delivered merchandise value?
-- Count distinct orders because one order may contain multiple category items.
SELECT coalesce(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       count(*) AS items, count(DISTINCT i.order_id) AS delivered_orders,
       sum(i.price) AS delivered_item_gmv, sum(i.freight_value) AS recorded_freight,
       round(100 * sum(i.price) / sum(sum(i.price)) OVER (), 2) AS gmv_share_pct
FROM olist.order_items i
JOIN olist.orders o USING (order_id)
JOIN olist.products p USING (product_id)
LEFT JOIN olist.category_translation t USING (product_category_name)
WHERE o.order_status = 'delivered'
GROUP BY 1 ORDER BY delivered_item_gmv DESC, category LIMIT 15;

-- Q06. Which states have high late-delivery rates with at least 100 eligible orders?
-- Rates use delivered orders with both actual and estimated dates available.
SELECT customer_state, count(is_late) AS eligible_deliveries,
       count(*) FILTER (WHERE is_late) AS late_orders,
       round(100.0 * count(*) FILTER (WHERE is_late) / nullif(count(is_late), 0), 2) AS late_delivery_pct,
       round(avg(delivery_days), 2) AS mean_delivery_days,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY delivery_days) AS median_delivery_days,
       percentile_cont(0.9) WITHIN GROUP (ORDER BY delivery_days) AS p90_delivery_days
FROM olist.order_facts WHERE order_status = 'delivered'
GROUP BY customer_state HAVING count(is_late) >= 100
ORDER BY late_delivery_pct DESC, customer_state;

-- Q07. How do review scores differ between on-time and late delivered orders?
-- One latest review per order. Missing reviews are shown in coverage counts.
SELECT CASE WHEN is_late THEN 'late' ELSE 'on_time' END AS delivery_group,
       count(*) AS eligible_deliveries, count(review_score) AS reviewed_orders,
       round(100.0 * count(review_score) / count(*), 2) AS review_coverage_pct,
       round(avg(review_score), 2) AS average_review_score,
       round(100.0 * count(*) FILTER (WHERE review_score <= 2)
             / nullif(count(review_score), 0), 2) AS low_review_pct
FROM olist.order_facts WHERE is_late IS NOT NULL
GROUP BY is_late ORDER BY is_late;

-- Q08. What share of recorded payment value uses each method?
-- A split-payment order can appear under more than one method.
SELECT payment_type, count(*) AS payment_records, count(DISTINCT order_id) AS orders_using_method,
       sum(payment_value) AS recorded_payment_value,
       round(100 * sum(payment_value) / sum(sum(payment_value)) OVER (), 2) AS payment_value_share_pct,
       round(avg(payment_installments), 2) AS mean_installments_per_payment_record
FROM olist.order_payments GROUP BY payment_type ORDER BY recorded_payment_value DESC, payment_type;

-- Q09. How many customers have multiple delivered orders during the observed period?
SELECT CASE WHEN delivered_orders = 1 THEN 'one_delivered_order'
            ELSE 'two_or_more_delivered_orders' END AS customer_group,
       count(*) AS unique_customers, sum(delivered_orders) AS delivered_orders,
       sum(item_gmv) AS delivered_item_gmv,
       round(100.0 * count(*) / sum(count(*)) OVER (), 2) AS customer_share_pct
FROM olist.customer_metrics GROUP BY 1 ORDER BY customer_group;

-- Q10. How many customers return in each month after their first delivered purchase?
-- Missing future months remain NULL. Zero indicates an observed period with no repeaters.
SELECT cohort_month, max(cohort_size) AS cohort_customers,
       max(retention_pct) FILTER (WHERE month_number = 0) AS month_0_pct,
       max(retention_pct) FILTER (WHERE month_number = 1) AS month_1_pct,
       max(retention_pct) FILTER (WHERE month_number = 2) AS month_2_pct,
       max(retention_pct) FILTER (WHERE month_number = 3) AS month_3_pct,
       max(retention_pct) FILTER (WHERE month_number = 4) AS month_4_pct,
       max(retention_pct) FILTER (WHERE month_number = 5) AS month_5_pct
FROM olist.cohort_retention GROUP BY cohort_month ORDER BY cohort_month;

-- Q11. How much delivered merchandise value comes from the largest sellers?
WITH seller_totals AS (
    SELECT i.seller_id, count(DISTINCT i.order_id) AS delivered_orders,
           sum(i.price) AS delivered_item_gmv
    FROM olist.order_items i JOIN olist.orders o USING (order_id)
    WHERE o.order_status = 'delivered' GROUP BY i.seller_id
), ranked AS (
    SELECT *, row_number() OVER (ORDER BY delivered_item_gmv DESC, seller_id) AS seller_rank,
           sum(delivered_item_gmv) OVER () AS total_gmv
    FROM seller_totals
)
SELECT r.seller_rank, r.seller_id, s.seller_state, r.delivered_orders, r.delivered_item_gmv,
       round(100 * r.delivered_item_gmv / r.total_gmv, 2) AS gmv_share_pct,
       round(100 * sum(r.delivered_item_gmv) OVER (
           ORDER BY r.seller_rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) / r.total_gmv, 2) AS cumulative_gmv_share_pct
FROM ranked r JOIN olist.sellers s USING (seller_id)
WHERE r.seller_rank <= 10 ORDER BY r.seller_rank;

-- Q12. How does freight compare with merchandise value across categories?
-- The 100-item minimum is an analyst-defined sample-size screen.
SELECT coalesce(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       count(*) AS items, sum(i.price) AS delivered_item_gmv,
       sum(i.freight_value) AS recorded_freight,
       round(100 * sum(i.freight_value) / nullif(sum(i.price), 0), 2) AS freight_to_gmv_pct
FROM olist.order_items i JOIN olist.orders o USING (order_id)
JOIN olist.products p USING (product_id)
LEFT JOIN olist.category_translation t USING (product_category_name)
WHERE o.order_status = 'delivered'
GROUP BY 1 HAVING count(*) >= 100 ORDER BY freight_to_gmv_pct DESC, category LIMIT 10;

-- Q13. Which categories show the strongest merchandise value in each customer state?
WITH totals AS (
    SELECT c.customer_state,
           coalesce(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
           sum(i.price) AS delivered_item_gmv
    FROM olist.order_items i JOIN olist.orders o USING (order_id)
    JOIN olist.customers c USING (customer_id)
    JOIN olist.products p USING (product_id)
    LEFT JOIN olist.category_translation t USING (product_category_name)
    WHERE o.order_status = 'delivered' GROUP BY 1, 2
), ranked AS (
    SELECT *, dense_rank() OVER (PARTITION BY customer_state ORDER BY delivered_item_gmv DESC) AS category_rank
    FROM totals
)
SELECT * FROM ranked WHERE category_rank <= 3 ORDER BY customer_state, category_rank, category;

-- Q14. How do recorded payments compare with item value plus freight per order?
-- Differences flag source questions. They do not establish refunds, losses or fraud.
SELECT count(*) AS orders, count(item_gmv) AS orders_with_items,
       count(payment_value) AS orders_with_payments,
       count(*) FILTER (WHERE item_gmv IS NOT NULL AND payment_value IS NOT NULL) AS comparable_orders,
       count(*) FILTER (WHERE abs(payment_value - item_gmv - freight_value) > 0.01) AS differences_above_one_cent,
       sum(payment_value - item_gmv - freight_value)
           FILTER (WHERE item_gmv IS NOT NULL AND payment_value IS NOT NULL) AS net_recorded_difference
FROM olist.order_facts;

-- Q15. What descriptive customer groups emerge from frequency and recency?
-- As-of date is fixed to one day after the last delivered purchase in the file.
-- The 90-day rule is an explicit analytical choice, not a validated marketing model.
WITH segmented AS (
    SELECT *, CASE
        WHEN delivered_orders >= 2 AND recency_days <= 90 THEN 'repeat_purchase_recent'
        WHEN delivered_orders >= 2 THEN 'repeat_purchase_older'
        WHEN recency_days <= 90 THEN 'single_purchase_recent'
        ELSE 'single_purchase_older'
    END AS segment FROM olist.customer_metrics
)
SELECT segment, max(as_of_date) AS as_of_date, count(*) AS unique_customers,
       round(avg(recency_days), 1) AS mean_recency_days,
       sum(delivered_orders) AS delivered_orders, sum(item_gmv) AS delivered_item_gmv
FROM segmented GROUP BY segment ORDER BY delivered_item_gmv DESC, segment;
