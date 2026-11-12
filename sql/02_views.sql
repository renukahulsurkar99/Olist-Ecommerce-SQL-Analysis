-- Aggregate each one-to-many relationship before joining it to orders.
CREATE OR REPLACE VIEW olist.item_totals AS
SELECT order_id, count(*) AS item_count, count(DISTINCT seller_id) AS seller_count,
       sum(price) AS item_gmv, sum(freight_value) AS freight_value
FROM olist.order_items GROUP BY order_id;

CREATE OR REPLACE VIEW olist.payment_totals AS
SELECT order_id, count(*) AS payment_record_count, sum(payment_value) AS payment_value
FROM olist.order_payments GROUP BY order_id;

-- Preserve every review in the source table. Select one deterministic latest
-- response per order for order-level analysis. A review_id can span orders.
CREATE OR REPLACE VIEW olist.latest_reviews AS
SELECT review_id, order_id, review_score, review_answer_timestamp
FROM (
    SELECT r.*, row_number() OVER (
        PARTITION BY order_id
        ORDER BY review_answer_timestamp DESC, review_creation_date DESC, review_id DESC
    ) AS response_rank
    FROM olist.order_reviews r
) ranked WHERE response_rank = 1;

CREATE OR REPLACE VIEW olist.order_facts AS
SELECT o.*, c.customer_unique_id, c.customer_city, c.customer_state,
       i.item_count, i.seller_count, i.item_gmv, i.freight_value,
       p.payment_record_count, p.payment_value,
       r.review_score,
       CASE WHEN o.order_status = 'delivered'
                  AND o.order_delivered_customer_date::date >= o.order_purchase_timestamp::date
            THEN o.order_delivered_customer_date::date - o.order_purchase_timestamp::date
       END AS delivery_days,
       CASE WHEN o.order_status = 'delivered'
                  AND o.order_delivered_customer_date IS NOT NULL
                  AND o.order_estimated_delivery_date IS NOT NULL
            THEN o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date
       END AS is_late
FROM olist.orders o
JOIN olist.customers c USING (customer_id)
LEFT JOIN olist.item_totals i USING (order_id)
LEFT JOIN olist.payment_totals p USING (order_id)
LEFT JOIN olist.latest_reviews r USING (order_id);

CREATE OR REPLACE VIEW olist.monthly_performance AS
WITH bounds AS (
    SELECT date_trunc('month', min(order_purchase_timestamp))::date AS first_month,
           date_trunc('month', max(order_purchase_timestamp))::date AS last_month
    FROM olist.orders
), calendar AS (
    SELECT generate_series(first_month::timestamp, last_month::timestamp,
                           interval '1 month')::date AS month,
           first_month, last_month
    FROM bounds
), totals AS (
    SELECT date_trunc('month', order_purchase_timestamp)::date AS month,
           count(*) AS orders,
           count(*) FILTER (WHERE order_status = 'delivered') AS delivered_orders,
           sum(item_gmv) FILTER (WHERE order_status = 'delivered') AS delivered_item_gmv
    FROM olist.order_facts GROUP BY 1
)
SELECT c.month, c.month IN (c.first_month, c.last_month) AS boundary_month,
       coalesce(t.orders, 0) AS orders, coalesce(t.delivered_orders, 0) AS delivered_orders,
       coalesce(t.delivered_item_gmv, 0::numeric) AS delivered_item_gmv
FROM calendar c LEFT JOIN totals t USING (month);

CREATE OR REPLACE VIEW olist.customer_metrics AS
WITH reference AS (
    SELECT max(order_purchase_timestamp)::date + 1 AS as_of_date
    FROM olist.orders WHERE order_status = 'delivered'
), metrics AS (
    SELECT customer_unique_id, count(*) AS delivered_orders,
           min(order_purchase_timestamp)::date AS first_purchase,
           max(order_purchase_timestamp)::date AS last_purchase,
           sum(item_gmv) AS item_gmv
    FROM olist.order_facts WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
)
SELECT m.*, r.as_of_date, r.as_of_date - m.last_purchase AS recency_days
FROM metrics m CROSS JOIN reference r;

-- Months beyond observed activity are omitted rather than counted as zero.
-- The latest activity month may be partial and is explicitly identified.
CREATE OR REPLACE VIEW olist.cohort_retention AS
WITH purchases AS (
    SELECT DISTINCT customer_unique_id,
           date_trunc('month', order_purchase_timestamp)::date AS activity_month
    FROM olist.order_facts WHERE order_status = 'delivered'
), first_purchase AS (
    SELECT customer_unique_id, min(activity_month) AS cohort_month
    FROM purchases GROUP BY customer_unique_id
), sizes AS (
    SELECT cohort_month, count(*) AS cohort_size FROM first_purchase GROUP BY cohort_month
), activity AS (
    SELECT f.cohort_month, p.activity_month, count(*) AS active_customers
    FROM first_purchase f JOIN purchases p USING (customer_unique_id)
    GROUP BY f.cohort_month, p.activity_month
), observation AS (
    SELECT max(activity_month) AS last_activity_month FROM purchases
), periods AS (
    SELECT s.*, g.month_number,
           (s.cohort_month + g.month_number * interval '1 month')::date AS activity_month,
           o.last_activity_month
    FROM sizes s CROSS JOIN generate_series(0, 5) AS g(month_number)
    CROSS JOIN observation o
)
SELECT p.cohort_month, p.month_number, p.activity_month, p.cohort_size,
       coalesce(a.active_customers, 0) AS active_customers,
       round(100.0 * coalesce(a.active_customers, 0) / p.cohort_size, 2) AS retention_pct,
       p.activity_month = p.last_activity_month AS latest_observed_month
FROM periods p LEFT JOIN activity a USING (cohort_month, activity_month)
WHERE p.activity_month <= p.last_activity_month;
