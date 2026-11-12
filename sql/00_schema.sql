-- PostgreSQL 16+. Every source table has an explicit row grain and key.
CREATE SCHEMA IF NOT EXISTS olist;

CREATE TABLE IF NOT EXISTS olist.customers (
    customer_id text PRIMARY KEY,
    customer_unique_id text NOT NULL,
    customer_zip_code_prefix text NOT NULL,
    customer_city text NOT NULL,
    customer_state char(2) NOT NULL
);
CREATE TABLE IF NOT EXISTS olist.category_translation (
    product_category_name text PRIMARY KEY,
    product_category_name_english text NOT NULL
);
CREATE TABLE IF NOT EXISTS olist.products (
    product_id text PRIMARY KEY,
    product_category_name text,
    product_name_length integer,
    product_description_length integer,
    product_photos_qty integer,
    product_weight_g numeric,
    product_length_cm numeric,
    product_height_cm numeric,
    product_width_cm numeric
);
-- A translation is optional. Two observed source categories have no translation.
CREATE TABLE IF NOT EXISTS olist.sellers (
    seller_id text PRIMARY KEY,
    seller_zip_code_prefix text NOT NULL,
    seller_city text NOT NULL,
    seller_state char(2) NOT NULL
);
CREATE TABLE IF NOT EXISTS olist.orders (
    order_id text PRIMARY KEY,
    customer_id text NOT NULL REFERENCES olist.customers(customer_id),
    order_status text NOT NULL,
    order_purchase_timestamp timestamp NOT NULL,
    order_approved_at timestamp,
    order_delivered_carrier_date timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_delivery_date timestamp
);
CREATE TABLE IF NOT EXISTS olist.order_items (
    order_id text NOT NULL REFERENCES olist.orders(order_id),
    order_item_id integer NOT NULL CHECK (order_item_id > 0),
    product_id text NOT NULL REFERENCES olist.products(product_id),
    seller_id text NOT NULL REFERENCES olist.sellers(seller_id),
    shipping_limit_date timestamp NOT NULL,
    price numeric(14,2) NOT NULL CHECK (price >= 0),
    freight_value numeric(14,2) NOT NULL CHECK (freight_value >= 0),
    PRIMARY KEY (order_id, order_item_id)
);
CREATE TABLE IF NOT EXISTS olist.order_payments (
    order_id text NOT NULL REFERENCES olist.orders(order_id),
    payment_sequential integer NOT NULL CHECK (payment_sequential > 0),
    payment_type text NOT NULL,
    payment_installments integer NOT NULL CHECK (payment_installments >= 0),
    payment_value numeric(14,2) NOT NULL CHECK (payment_value >= 0),
    PRIMARY KEY (order_id, payment_sequential)
);
CREATE TABLE IF NOT EXISTS olist.order_reviews (
    review_id text NOT NULL,
    order_id text NOT NULL REFERENCES olist.orders(order_id),
    review_score integer NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp NOT NULL,
    review_answer_timestamp timestamp NOT NULL,
    PRIMARY KEY (review_id, order_id)
);

CREATE INDEX IF NOT EXISTS orders_customer_idx ON olist.orders(customer_id);
CREATE INDEX IF NOT EXISTS orders_purchase_idx ON olist.orders(order_purchase_timestamp);
CREATE INDEX IF NOT EXISTS customers_unique_idx ON olist.customers(customer_unique_id);
CREATE INDEX IF NOT EXISTS order_items_product_idx ON olist.order_items(product_id);
CREATE INDEX IF NOT EXISTS order_items_seller_idx ON olist.order_items(seller_id);
CREATE INDEX IF NOT EXISTS order_reviews_order_idx ON olist.order_reviews(order_id);
