-- Snapshot controls for the eight supplied Kaggle CSVs.
DO $$
BEGIN
    IF (SELECT count(*) FROM olist.customers) <> 99441
       OR (SELECT count(*) FROM olist.orders) <> 99441
       OR (SELECT count(*) FROM olist.order_items) <> 112650
       OR (SELECT count(*) FROM olist.order_payments) <> 103886
       OR (SELECT count(*) FROM olist.order_reviews) <> 99224
       OR (SELECT count(*) FROM olist.products) <> 32951
       OR (SELECT count(*) FROM olist.sellers) <> 3095
       OR (SELECT count(*) FROM olist.category_translation) <> 71 THEN
        RAISE EXCEPTION 'Source row counts differ from the supplied dataset';
    END IF;
    IF (SELECT sum(price) FROM olist.order_items) IS DISTINCT FROM 13591643.70
       OR (SELECT sum(freight_value) FROM olist.order_items) IS DISTINCT FROM 2251909.54
       OR (SELECT sum(payment_value) FROM olist.order_payments) IS DISTINCT FROM 16008872.12 THEN
        RAISE EXCEPTION 'Source monetary controls differ from the supplied dataset';
    END IF;
END;
$$;
