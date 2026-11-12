-- Source-independent reconciliation. Exceptions fail the load and CI.
DO $$
DECLARE n bigint;
BEGIN
    SELECT count(*) INTO n FROM olist.orders;
    IF n = 0 THEN RAISE EXCEPTION 'Orders table is empty'; END IF;
    IF (SELECT count(*) FROM olist.order_facts) <> n
       OR (SELECT count(DISTINCT order_id) FROM olist.order_facts) <> n THEN
        RAISE EXCEPTION 'Order-fact joins duplicated or lost orders';
    END IF;
    IF (SELECT sum(item_gmv) FROM olist.order_facts)
        IS DISTINCT FROM (SELECT sum(price) FROM olist.order_items)
       OR (SELECT sum(freight_value) FROM olist.order_facts)
        IS DISTINCT FROM (SELECT sum(freight_value) FROM olist.order_items)
       OR (SELECT sum(payment_value) FROM olist.order_facts)
        IS DISTINCT FROM (SELECT sum(payment_value) FROM olist.order_payments) THEN
        RAISE EXCEPTION 'One-to-many joins changed monetary totals';
    END IF;
    IF (SELECT count(*) FROM olist.latest_reviews)
       <> (SELECT count(DISTINCT order_id) FROM olist.order_reviews) THEN
        RAISE EXCEPTION 'Latest-review selection has incorrect coverage';
    END IF;
    IF (SELECT sum(orders) FROM olist.monthly_performance) IS DISTINCT FROM n::numeric
       OR (SELECT sum(delivered_item_gmv) FROM olist.monthly_performance)
         IS DISTINCT FROM (SELECT coalesce(sum(item_gmv), 0) FROM olist.order_facts WHERE order_status = 'delivered') THEN
        RAISE EXCEPTION 'Monthly reporting does not reconcile';
    END IF;
    IF (SELECT sum(delivered_orders) FROM olist.customer_metrics)
       IS DISTINCT FROM (SELECT count(*)::numeric FROM olist.orders WHERE order_status = 'delivered') THEN
        RAISE EXCEPTION 'Customer metrics lost or duplicated orders';
    END IF;
    IF EXISTS (SELECT 1 FROM olist.cohort_retention
               WHERE active_customers > cohort_size OR retention_pct NOT BETWEEN 0 AND 100
                  OR (month_number = 0 AND active_customers <> cohort_size)) THEN
        RAISE EXCEPTION 'Invalid cohort-retention numerator or denominator';
    END IF;
END;
$$;
