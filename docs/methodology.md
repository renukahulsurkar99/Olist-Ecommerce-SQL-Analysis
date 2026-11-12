# Data dictionary and methodology

## Source and table grains

| Table | One row represents | Key | Supplied rows |
| --- | --- | --- | ---: |
| `customers` | An order-linked customer record and its location | `customer_id` | 99,441 |
| `orders` | An order | `order_id` | 99,441 |
| `order_items` | An item sequence within an order | `(order_id, order_item_id)` | 112,650 |
| `order_payments` | A payment sequence within an order | `(order_id, payment_sequential)` | 103,886 |
| `order_reviews` | A review associated with an order | `(review_id, order_id)` | 99,224 |
| `products` | A product | `product_id` | 32,951 |
| `sellers` | A seller | `seller_id` | 3,095 |
| `category_translation` | A Portuguese-to-English category mapping | `product_category_name` | 71 |

The SQL schema retains the eight-file source structure. Customer and seller ZIP-code prefixes are text to preserve leading zeros. Money is `numeric(14,2)`. Timestamp fields use `timestamp without time zone` because no time-zone offset is supplied. The original product CSV column spellings `product_name_lenght` and `product_description_lenght` map by position to `product_name_length` and `product_description_length`.

`customer_id` connects orders to customer records. `customer_unique_id` groups the same customer across purchases. Geography is attached to an order through its customer record, so a customer with deliveries in multiple states can appear in more than one state's distinct-customer count.

## Join discipline

Directly joining an order's item rows to payment rows repeats each item once per payment. Joining review rows can multiply them again. The `item_totals` and `payment_totals` views produce one row per order. The `latest_reviews` view also produces one row per reviewed order. `order_facts` then combines these views with the order and customer.

The source contains no complete duplicate review rows. Review IDs repeat across orders, and some orders have multiple reviews. The composite review key preserves all records. For each order, the selected latest response sorts by `review_answer_timestamp DESC`, then `review_creation_date DESC`, then `review_id DESC`. This rule is an analytical choice that can be changed explicitly.

The regression fixture includes one order with two items, two payments and two reviews. It verifies that merchandise value stays 30, payment value stays 35 and the latest review score is 5 after the joins.

## Metric definitions and denominators

| Metric | Definition | Population |
| --- | --- | --- |
| Delivered item GMV | Sum of `order_items.price` | Items belonging to orders with status `delivered` |
| Mean delivered-order GMV | Average order-level item total | Delivered orders with item records |
| Recorded freight | Sum of `freight_value` | Same item population as the associated query |
| Recorded payment value | Sum of `payment_value` | All payment records, unless explicitly filtered |
| Late delivery | Actual delivery calendar date exceeds estimated calendar date | Delivered orders with both dates present |
| Late-delivery rate | Late delivered orders / date-eligible delivered orders | Excludes eight delivered orders with missing actual dates |
| Delivery days | Actual delivery date minus purchase date | Delivered orders with nonnegative, available date intervals |
| Review mean | Average of latest selected review score | Orders with an available review in the selected delivery group |
| Low-review rate | Latest scores of 1–2 / reviewed orders | Same delivery group |
| Repeat purchaser | At least two delivered orders for one `customer_unique_id` | Customers with at least one delivered order |
| Cohort retention | Distinct active customers in a later month / customers in the first-purchase cohort | Delivered-order purchase months |
| Freight-to-GMV ratio | Sum of recorded freight / sum of item price | Delivered items, by category |

Every percentage uses a matching numerator and denominator. `NULLIF` exposes an unavailable ratio when the denominator is zero. Missing actual dates, payment records, reviews and item totals stay missing in the order-level view. Calendar periods with no orders have zero additive totals.

Merchandise value, payment value, freight, and profit represent different financial concepts. The files lack a cost ledger, marketplace commission ledger and refund ledger. The analysis reports the recorded measures available in the source. The CSVs do not explicitly label a currency, so outputs use source currency units.

## Observation windows

Monthly performance groups orders by purchase month and attributes delivered-item totals back to that purchase month. It does not use payment settlement dates or delivery completion month. The calendar spans the first through last observed purchase month. The first and last months are flagged as boundary months. Sparse early activity and September–October 2018 require care when interpreting growth. The chart displays January 2017–August 2018, while exported tables retain every month.

Customer recency uses a fixed reference date of **2018-08-30**, one day after the last delivered-order purchase date. It will therefore remain reproducible after the current date changes. The four customer groups combine single/repeat purchasing with a documented 90-day recency cutoff. This is descriptive grouping rather than a validated marketing targeting model.

Cohorts use the first delivered-order purchase month. A customer contributes once per active calendar month. The view generates offsets 0–5 only up to the latest observed delivered-purchase month, **August 2018**. Future months are unavailable rather than zero. The latest month is flagged in the underlying view and may be partial. Customers who enter near the end have shorter observation windows. Very small cohorts should be interpreted with their size visible.

## Preserved source issues

- Eight delivered orders have missing actual delivery timestamps.
- 775 orders have no item records, one has no payment record, and 768 have no review.
- 610 products have no category. Thirteen products use `pc_gamer` or `portateis_cozinha_e_preparadores_de_alimentos`, which lack translation rows.
- 303 comparable orders have payment/item-plus-freight differences above one cent. The analysis reports these differences without assigning a cause.
- One order can involve several sellers, categories or payment methods. Distinct order counts within those groups need not add to the overall order count.

The source controls in `tests/dataset_controls.sql` apply to the supplied Kaggle snapshot. A different version should be reviewed against the manifest and its expected counts before deliberately updating those controls.

## Interpretation

The source is anonymised commercial marketplace data. Relationships such as late delivery and lower review scores are observational. The dataset cannot isolate causal effects or establish current Brazilian market conditions. Recommendations are investigation proposals and have no measured implementation outcome.
