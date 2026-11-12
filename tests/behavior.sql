-- Concrete regression cases for join multiplication, date boundaries and cohorts.
DO $$
BEGIN
    IF (SELECT item_gmv FROM olist.order_facts WHERE order_id='o1') IS DISTINCT FROM 30
       OR (SELECT payment_value FROM olist.order_facts WHERE order_id='o1') IS DISTINCT FROM 35
       OR (SELECT review_score FROM olist.order_facts WHERE order_id='o1') IS DISTINCT FROM 5
       OR (SELECT count(*) FROM olist.order_facts) <> 4 THEN
        RAISE EXCEPTION 'Multi-item/payment/review order was multiplied or misselected';
    END IF;
    IF (SELECT is_late FROM olist.order_facts WHERE order_id='o1') IS DISTINCT FROM false
       OR (SELECT is_late FROM olist.order_facts WHERE order_id='o2') IS DISTINCT FROM true
       OR (SELECT is_late FROM olist.order_facts WHERE order_id='o4') IS NOT NULL
       OR (SELECT count(is_late) FROM olist.order_facts) <> 2 THEN
        RAISE EXCEPTION 'Same-day or missing-date delivery classification failed';
    END IF;
    IF (SELECT delivered_item_gmv FROM olist.monthly_performance WHERE month='2018-02-01') IS DISTINCT FROM 0
       OR (SELECT count(*) FROM olist.monthly_performance) <> 3 THEN
        RAISE EXCEPTION 'Monthly calendar omitted a zero-order month';
    END IF;
    IF (SELECT delivered_orders FROM olist.customer_metrics WHERE customer_unique_id='u1') IS DISTINCT FROM 2
       OR (SELECT retention_pct FROM olist.cohort_retention WHERE cohort_month='2018-01-01' AND month_number=1) IS DISTINCT FROM 0
       OR (SELECT retention_pct FROM olist.cohort_retention WHERE cohort_month='2018-01-01' AND month_number=2) IS DISTINCT FROM 50
       OR EXISTS (SELECT 1 FROM olist.cohort_retention WHERE activity_month > '2018-03-01') THEN
        RAISE EXCEPTION 'Customer identity, zero retention or future-period handling failed';
    END IF;
END;
$$;
