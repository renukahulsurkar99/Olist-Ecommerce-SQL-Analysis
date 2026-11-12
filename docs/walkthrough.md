# Reproduce and explain the project

## 1. Trace a customer and an order

Start with the `olist.customers` and `olist.orders` tables in `sql/00_schema.sql`. Each order refers to a customer record through a foreign key. `customer_unique_id` lets us recognise repeat customers across their order-linked records.

```sql
SELECT o.order_id, c.customer_city, c.customer_state
FROM olist.orders o
JOIN olist.customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id
LIMIT 5;
```

The aliases `o` and `c` identify each column's table. The join condition matches equal customer IDs. The order ID remains the grain of the result.

## 2. Establish the measures before interpreting results

Read Q01 and Q02. Check the total orders, delivery status mix and eligible delivery-date denominator. Write down the difference between an order count, a unique-customer count, an item-value total and a payment-value total.

Explain why eight delivered orders are excluded from the lateness denominator and why the date comparison casts timestamps to dates.

## 3. Understand why raw joins can inflate totals

An order with two item rows and two payment rows creates four rows when those tables are directly joined by order ID. Each item and payment is repeated. `sql/02_views.sql` aggregates the two relationships separately before joining them to orders. Reviews receive a one-row-per-order latest-response selection.

Inspect `tests/fixture.sql` and `tests/behavior.sql`. The synthetic example uses an item total of 30 and a payment total of 35. The tests confirm those amounts survive the join.

## 4. Follow each SQL technique through a business question

- Q03 builds monthly totals and uses `LAG` for previous-month and prior-year comparisons. The full calendar ensures a missing month remains a calendar period.
- Q06 uses `HAVING` to require at least 100 eligible orders per state and calculates the median and 90th percentile.
- Q07 compares latest review scores between delivery outcomes and reports how many eligible orders actually have reviews.
- Q10 groups customers by first-purchase cohort and measures later activity. Future periods remain unavailable.
- Q11 calculates seller ranks and cumulative contribution with an explicit window frame.
- Q13 starts a separate `DENSE_RANK` inside each customer state. Ties can return more than three rows per state.

## 5. Reproduce the checks

Run the full loader against your own project database using the README commands. The load fails if keys, source controls or reconciliation checks fail. Rerun it to confirm that the setup is repeatable. Use the synthetic fixture only in a disposable test database because it reloads the project tables with sample records.

The GitHub Actions run uses this synthetic dataset and executes all 15 queries. Full-source row and monetary controls are verified when you run `sql/run.sql` with the Kaggle files.

## 6. Extend the analysis yourself

1. Change Q04 from customer state to customer city and choose a minimum number of eligible deliveries.
2. Split delivery duration into purchase-to-carrier and carrier-to-customer intervals. Check missing timestamps before calculating the intervals.
3. Compare the latest-review rule with an earliest-review rule, then inspect whether the review-outcome association changes.
4. Compare cohorts only when they have the same amount of observed follow-up and adequate sample size.

## 7. Prepare to discuss the work

Explain the table grains, foreign keys, composite keys, join aggregation, NULL handling, metric denominators, cohort windows and fixed reference date. Be clear about which choices are analytical assumptions. Reproduce at least one finding from source records before discussing the project in an interview.

The project's schema, SQL, source attribution and validation are available to inspect and reproduce.
