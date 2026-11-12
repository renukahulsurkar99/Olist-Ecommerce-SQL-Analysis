-- Called by run.sql from the repository root. All changes share one transaction.
-- Reload only the eight project tables, in the olist schema.
TRUNCATE olist.order_reviews, olist.order_payments, olist.order_items,
         olist.orders, olist.customers, olist.products, olist.sellers,
         olist.category_translation;

-- Client-side COPY reads local files and works with desktop PostgreSQL or Docker.
-- Original product CSV misspellings (lenght) map by position to *_length columns.
\copy olist.customers FROM 'data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.category_translation FROM 'data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.products FROM 'data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.sellers FROM 'data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.orders FROM 'data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.order_items FROM 'data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.order_payments FROM 'data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy olist.order_reviews FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
ANALYZE olist.orders;
ANALYZE olist.order_items;
ANALYZE olist.order_payments;
ANALYZE olist.order_reviews;
