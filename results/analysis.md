# SQL result tables

Snapshot of all 15 queries in [sql/03_analysis.sql](../sql/03_analysis.sql). Numeric values below are formatted for readability. The exact exported strings, source fingerprints and query fingerprints are in [analysis.json](analysis.json). `NULL` means an unavailable value. Monetary amounts retain source currency units.

## Q01. What scale, order value and delivery coverage does the sample represent?

| total_orders | unique_customers | delivered_orders | delivered_item_gmv | average_delivered_order_gmv | delivered_orders_with_items | delivery_date_eligible_orders | late_orders | late_delivery_pct | mean_delivery_days |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 99,441 | 96,096 | 96,478 | 13,221,498.11 | 137.04 | 96,478 | 96,470 | 6,534 | 6.77 | 12.50 |

## Q02. Which order statuses are present, and what share do they represent?

| order_status | orders | order_share_pct |
| --- | --- | --- |
| delivered | 96,478 | 97.02 |
| shipped | 1,107 | 1.11 |
| canceled | 625 | 0.63 |
| unavailable | 609 | 0.61 |
| invoiced | 314 | 0.32 |
| processing | 301 | 0.30 |
| created | 5 | 0.01 |
| approved | 2 | 0.00 |

## Q03. How do delivered merchandise value and order counts change monthly?

| month | boundary_month | orders | delivered_orders | delivered_item_gmv | mom_gmv_growth_pct | yoy_gmv_growth_pct |
| --- | --- | --- | --- | --- | --- | --- |
| 2016-09-01 | true | 4 | 1 | 134.97 | NULL | NULL |
| 2016-10-01 | false | 324 | 265 | 40,325.11 | 29,777.09 | NULL |
| 2016-11-01 | false | 0 | 0 | 0 | -100.00 | NULL |
| 2016-12-01 | false | 1 | 1 | 10.90 | NULL | NULL |
| 2017-01-01 | false | 800 | 750 | 111,798.36 | 1,025,573.03 | NULL |
| 2017-02-01 | false | 1,780 | 1,653 | 234,223.40 | 109.51 | NULL |
| 2017-03-01 | false | 2,682 | 2,546 | 359,198.85 | 53.36 | NULL |
| 2017-04-01 | false | 2,404 | 2,303 | 340,669.68 | -5.16 | NULL |
| 2017-05-01 | false | 3,700 | 3,546 | 489,338.25 | 43.64 | NULL |
| 2017-06-01 | false | 3,245 | 3,135 | 421,923.37 | -13.78 | NULL |
| 2017-07-01 | false | 4,026 | 3,872 | 481,604.52 | 14.15 | NULL |
| 2017-08-01 | false | 4,331 | 4,193 | 554,699.70 | 15.18 | NULL |
| 2017-09-01 | false | 4,285 | 4,150 | 607,399.67 | 9.50 | 449,925.69 |
| 2017-10-01 | false | 4,631 | 4,478 | 648,247.65 | 6.73 | 1,507.55 |
| 2017-11-01 | false | 7,544 | 7,289 | 987,765.37 | 52.37 | NULL |
| 2017-12-01 | false | 5,673 | 5,513 | 726,033.19 | -26.50 | 6,660,754.95 |
| 2018-01-01 | false | 7,269 | 7,069 | 924,645.00 | 27.36 | 727.06 |
| 2018-02-01 | false | 6,728 | 6,555 | 826,437.13 | -10.62 | 252.84 |
| 2018-03-01 | false | 7,211 | 7,003 | 953,356.25 | 15.36 | 165.41 |
| 2018-04-01 | false | 6,939 | 6,798 | 973,534.09 | 2.12 | 185.77 |
| 2018-05-01 | false | 6,873 | 6,749 | 977,544.69 | 0.41 | 99.77 |
| 2018-06-01 | false | 6,167 | 6,099 | 856,077.86 | -12.43 | 102.90 |
| 2018-07-01 | false | 6,292 | 6,159 | 867,953.46 | 1.39 | 80.22 |
| 2018-08-01 | false | 6,512 | 6,351 | 838,576.64 | -3.38 | 51.18 |
| 2018-09-01 | false | 16 | 0 | 0 | -100.00 | -100.00 |
| 2018-10-01 | true | 4 | 0 | 0 | NULL | -100.00 |

## Q04. Which customer states contribute delivered orders and merchandise value?

| customer_state | delivered_orders | unique_customers | delivered_item_gmv | gmv_share_pct | mean_delivery_days | eligible_deliveries | late_delivery_pct |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SP | 40,501 | 39,156 | 5,067,633.16 | 38.33 | 8.70 | 40,494 | 4.49 |
| RJ | 12,350 | 11,917 | 1,759,651.13 | 13.31 | 15.24 | 12,350 | 12.11 |
| MG | 11,354 | 11,001 | 1,552,481.83 | 11.74 | 11.94 | 11,354 | 4.57 |
| RS | 5,345 | 5,168 | 728,897.47 | 5.51 | 15.25 | 5,344 | 6.08 |
| PR | 4,923 | 4,769 | 666,063.51 | 5.04 | 11.94 | 4,923 | 4.04 |
| SC | 3,546 | 3,449 | 507,012.13 | 3.83 | 14.90 | 3,546 | 8.21 |
| BA | 3,256 | 3,158 | 493,584.14 | 3.73 | 19.28 | 3,256 | 12.16 |
| DF | 2,080 | 2,019 | 296,498.41 | 2.24 | 12.90 | 2,080 | 5.67 |
| GO | 1,957 | 1,895 | 282,836.70 | 2.14 | 15.54 | 1,957 | 6.54 |
| ES | 1,995 | 1,928 | 268,643.45 | 2.03 | 15.72 | 1,995 | 10.73 |
| PE | 1,593 | 1,551 | 251,889.49 | 1.91 | 18.40 | 1,593 | 9.60 |
| CE | 1,279 | 1,258 | 219,757.38 | 1.66 | 21.20 | 1,279 | 13.76 |
| PA | 946 | 922 | 174,470.59 | 1.32 | 23.73 | 946 | 11.21 |
| MT | 886 | 856 | 152,191.62 | 1.15 | 18.00 | 886 | 5.98 |
| MA | 717 | 700 | 117,009.38 | 0.88 | 21.51 | 717 | 17.43 |
| MS | 701 | 681 | 115,429.97 | 0.87 | 15.54 | 701 | 9.70 |
| PB | 517 | 504 | 112,586.82 | 0.85 | 20.39 | 517 | 10.44 |
| PI | 476 | 464 | 84,721.00 | 0.64 | 19.39 | 476 | 13.87 |
| RN | 474 | 464 | 82,105.66 | 0.62 | 19.22 | 474 | 9.28 |
| AL | 397 | 387 | 78,855.72 | 0.60 | 24.50 | 397 | 21.41 |
| SE | 335 | 329 | 56,574.19 | 0.43 | 21.46 | 335 | 15.22 |
| TO | 274 | 267 | 48,402.51 | 0.37 | 17.60 | 274 | 9.85 |
| RO | 243 | 231 | 45,682.76 | 0.35 | 19.28 | 243 | 2.88 |
| AM | 145 | 140 | 22,155.84 | 0.17 | 26.36 | 145 | 2.76 |
| AC | 80 | 76 | 15,930.97 | 0.12 | 21.00 | 80 | 3.75 |
| AP | 67 | 66 | 13,374.81 | 0.10 | 27.18 | 67 | 2.99 |
| RR | 41 | 40 | 7,057.47 | 0.05 | 29.34 | 41 | 12.20 |

## Q05. Which product categories contribute the most delivered merchandise value?

| category | items | delivered_orders | delivered_item_gmv | recorded_freight | gmv_share_pct |
| --- | --- | --- | --- | --- | --- |
| health_beauty | 9,465 | 8,647 | 1,233,131.72 | 178,957.81 | 9.33 |
| watches_gifts | 5,859 | 5,495 | 1,166,176.98 | 98,156.14 | 8.82 |
| bed_bath_table | 10,953 | 9,272 | 1,023,434.76 | 201,774.50 | 7.74 |
| sports_leisure | 8,431 | 7,530 | 954,852.55 | 163,404.36 | 7.22 |
| computers_accessories | 7,644 | 6,530 | 888,724.61 | 143,999.16 | 6.72 |
| furniture_decor | 8,160 | 6,307 | 711,927.69 | 168,402.23 | 5.38 |
| housewares | 6,795 | 5,743 | 615,628.69 | 142,763.56 | 4.66 |
| cool_stuff | 3,718 | 3,559 | 610,204.10 | 81,476.79 | 4.62 |
| auto | 4,140 | 3,810 | 578,966.65 | 90,488.10 | 4.38 |
| toys | 4,030 | 3,804 | 471,286.48 | 75,774.58 | 3.56 |
| garden_tools | 4,268 | 3,448 | 470,495.28 | 96,650.40 | 3.56 |
| baby | 2,982 | 2,809 | 400,421.84 | 66,305.81 | 3.03 |
| perfumery | 3,340 | 3,086 | 390,144.65 | 53,026.98 | 2.95 |
| telephony | 4,430 | 4,093 | 309,860.23 | 69,342.39 | 2.34 |
| office_furniture | 1,668 | 1,254 | 268,154.31 | 67,057.05 | 2.03 |

## Q06. Which states have high late-delivery rates with at least 100 eligible orders?

| customer_state | eligible_deliveries | late_orders | late_delivery_pct | mean_delivery_days | median_delivery_days | p90_delivery_days |
| --- | --- | --- | --- | --- | --- | --- |
| AL | 397 | 85 | 21.41 | 24.50 | 22 | 39.40 |
| MA | 717 | 125 | 17.43 | 21.51 | 19 | 34 |
| SE | 335 | 51 | 15.22 | 21.46 | 18 | 35 |
| PI | 476 | 66 | 13.87 | 19.39 | 16 | 30 |
| CE | 1,279 | 176 | 13.76 | 21.20 | 18 | 35 |
| BA | 3,256 | 396 | 12.16 | 19.28 | 17 | 32 |
| RJ | 12,350 | 1,495 | 12.11 | 15.24 | 12 | 29 |
| PA | 946 | 106 | 11.21 | 23.73 | 21 | 39 |
| ES | 1,995 | 214 | 10.73 | 15.72 | 14 | 25 |
| PB | 517 | 54 | 10.44 | 20.39 | 18 | 35 |
| TO | 274 | 27 | 9.85 | 17.60 | 16 | 28 |
| MS | 701 | 68 | 9.70 | 15.54 | 14 | 25 |
| PE | 1,593 | 153 | 9.60 | 18.40 | 16 | 30.80 |
| RN | 474 | 44 | 9.28 | 19.22 | 16 | 32.70 |
| SC | 3,546 | 291 | 8.21 | 14.90 | 13 | 26 |
| GO | 1,957 | 128 | 6.54 | 15.54 | 14 | 25 |
| RS | 5,344 | 325 | 6.08 | 15.25 | 13 | 26 |
| MT | 886 | 53 | 5.98 | 18.00 | 16 | 28 |
| DF | 2,080 | 118 | 5.67 | 12.90 | 11 | 22 |
| MG | 11,354 | 519 | 4.57 | 11.94 | 10 | 20 |
| SP | 40,494 | 1,820 | 4.49 | 8.70 | 7 | 16 |
| PR | 4,923 | 199 | 4.04 | 11.94 | 10 | 20 |
| RO | 243 | 7 | 2.88 | 19.28 | 18 | 29 |
| AM | 145 | 4 | 2.76 | 26.36 | 26 | 39 |

## Q07. How do review scores differ between on-time and late delivered orders?

| delivery_group | eligible_deliveries | reviewed_orders | review_coverage_pct | average_review_score | low_review_pct |
| --- | --- | --- | --- | --- | --- |
| on_time | 89,936 | 89,443 | 99.45 | 4.29 | 9.27 |
| late | 6,534 | 6,381 | 97.66 | 2.27 | 62.42 |

## Q08. What share of recorded payment value uses each method?

| payment_type | payment_records | orders_using_method | recorded_payment_value | payment_value_share_pct | mean_installments_per_payment_record |
| --- | --- | --- | --- | --- | --- |
| credit_card | 76,795 | 76,505 | 12,542,084.19 | 78.34 | 3.51 |
| boleto | 19,784 | 19,784 | 2,869,361.27 | 17.92 | 1.00 |
| voucher | 5,775 | 3,866 | 379,436.87 | 2.37 | 1.00 |
| debit_card | 1,529 | 1,528 | 217,989.79 | 1.36 | 1.00 |
| not_defined | 3 | 3 | 0.00 | 0.00 | 1.00 |

## Q09. How many customers have multiple delivered orders during the observed period?

| customer_group | unique_customers | delivered_orders | delivered_item_gmv | customer_share_pct |
| --- | --- | --- | --- | --- |
| one_delivered_order | 90,557 | 90,557 | 12,493,089.36 | 97.00 |
| two_or_more_delivered_orders | 2,801 | 5,921 | 728,408.75 | 3.00 |

## Q10. How many customers return in each month after their first delivered purchase?

| cohort_month | cohort_customers | month_0_pct | month_1_pct | month_2_pct | month_3_pct | month_4_pct | month_5_pct |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2016-09-01 | 1 | 100.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| 2016-10-01 | 262 | 100.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| 2016-12-01 | 1 | 100.00 | 100.00 | 0.00 | 0.00 | 0.00 | 0.00 |
| 2017-01-01 | 717 | 100.00 | 0.28 | 0.28 | 0.14 | 0.42 | 0.14 |
| 2017-02-01 | 1,628 | 100.00 | 0.18 | 0.31 | 0.12 | 0.43 | 0.12 |
| 2017-03-01 | 2,503 | 100.00 | 0.44 | 0.36 | 0.40 | 0.36 | 0.16 |
| 2017-04-01 | 2,256 | 100.00 | 0.62 | 0.22 | 0.18 | 0.27 | 0.27 |
| 2017-05-01 | 3,451 | 100.00 | 0.46 | 0.46 | 0.29 | 0.29 | 0.32 |
| 2017-06-01 | 3,037 | 100.00 | 0.49 | 0.40 | 0.43 | 0.30 | 0.40 |
| 2017-07-01 | 3,752 | 100.00 | 0.53 | 0.35 | 0.24 | 0.29 | 0.21 |
| 2017-08-01 | 4,057 | 100.00 | 0.69 | 0.35 | 0.27 | 0.35 | 0.52 |
| 2017-09-01 | 4,004 | 100.00 | 0.70 | 0.55 | 0.27 | 0.45 | 0.22 |
| 2017-10-01 | 4,328 | 100.00 | 0.72 | 0.25 | 0.09 | 0.23 | 0.21 |
| 2017-11-01 | 7,060 | 100.00 | 0.57 | 0.37 | 0.17 | 0.17 | 0.18 |
| 2017-12-01 | 5,338 | 100.00 | 0.21 | 0.28 | 0.34 | 0.26 | 0.21 |
| 2018-01-01 | 6,842 | 100.00 | 0.34 | 0.37 | 0.29 | 0.29 | 0.16 |
| 2018-02-01 | 6,288 | 100.00 | 0.35 | 0.40 | 0.30 | 0.25 | 0.22 |
| 2018-03-01 | 6,774 | 100.00 | 0.40 | 0.30 | 0.30 | 0.12 | 0.12 |
| 2018-04-01 | 6,582 | 100.00 | 0.59 | 0.30 | 0.24 | 0.14 | NULL |
| 2018-05-01 | 6,506 | 100.00 | 0.52 | 0.26 | 0.18 | NULL | NULL |
| 2018-06-01 | 5,878 | 100.00 | 0.43 | 0.27 | NULL | NULL | NULL |
| 2018-07-01 | 5,949 | 100.00 | 0.52 | NULL | NULL | NULL | NULL |
| 2018-08-01 | 6,144 | 100.00 | NULL | NULL | NULL | NULL | NULL |

## Q11. How much delivered merchandise value comes from the largest sellers?

| seller_rank | seller_id | seller_state | delivered_orders | delivered_item_gmv | gmv_share_pct | cumulative_gmv_share_pct |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 4869f7a5dfa277a7dca6462dcf3b52b2 | SP | 1,124 | 226,987.93 | 1.72 | 1.72 |
| 2 | 53243585a1d6dc2643021fd1853d8905 | BA | 348 | 217,940.44 | 1.65 | 3.37 |
| 3 | 4a3ca9315b744ce9f8e9374361493884 | SP | 1,772 | 196,882.12 | 1.49 | 4.85 |
| 4 | fa1c13f2614d7b5c4749cbc52fecda94 | SP | 578 | 190,917.14 | 1.44 | 6.30 |
| 5 | 7c67e1448b00f6e969d365cea6b010ab | SP | 973 | 186,570.05 | 1.41 | 7.71 |
| 6 | 7e93a43ef30c4f03f38b393420bc753a | SP | 319 | 165,981.49 | 1.26 | 8.96 |
| 7 | da8622b14eb17ae2831f4ac5b9dab84a | SP | 1,311 | 159,816.87 | 1.21 | 10.17 |
| 8 | 7a67c85e85bb2ce8582c35f2203ad736 | SP | 1,145 | 139,658.69 | 1.06 | 11.23 |
| 9 | 1025f0e2d44d7041d6cf58b6550e0bfa | SP | 910 | 138,208.56 | 1.05 | 12.28 |
| 10 | 955fee9216a65b617aa5c0531780ce60 | SP | 1,261 | 131,836.71 | 1.00 | 13.27 |

## Q12. How does freight compare with merchandise value across categories?

| category | items | delivered_item_gmv | recorded_freight | freight_to_gmv_pct |
| --- | --- | --- | --- | --- |
| christmas_supplies | 150 | 8,737.84 | 3,190.91 | 36.52 |
| signaling_and_security | 197 | 21,315.05 | 6,477.54 | 30.39 |
| electronics | 2,729 | 155,043.93 | 45,679.16 | 29.46 |
| food_drink | 269 | 14,942.88 | 4,394.89 | 29.41 |
| furniture_living_room | 495 | 67,350.70 | 17,694.37 | 26.27 |
| kitchen_dining_laundry_garden_furniture | 274 | 45,531.98 | 11,540.99 | 25.35 |
| drinks | 361 | 21,529.84 | 5,441.27 | 25.27 |
| office_furniture | 1,668 | 268,154.31 | 67,057.05 | 25.01 |
| food | 499 | 28,731.15 | 7,063.53 | 24.58 |
| furniture_decor | 8,160 | 711,927.69 | 168,402.23 | 23.65 |

## Q13. Which categories show the strongest merchandise value in each customer state?

| customer_state | category | delivered_item_gmv | category_rank |
| --- | --- | --- | --- |
| AC | sports_leisure | 1,677.46 | 1 |
| AC | watches_gifts | 1,389.60 | 2 |
| AC | health_beauty | 1,386.58 | 3 |
| AL | health_beauty | 12,681.26 | 1 |
| AL | watches_gifts | 11,605.02 | 2 |
| AL | computers_accessories | 7,605.61 | 3 |
| AM | health_beauty | 2,776.03 | 1 |
| AM | garden_tools | 1,980.88 | 2 |
| AM | computers_accessories | 1,815.74 | 3 |
| AP | computers_accessories | 2,050.03 | 1 |
| AP | watches_gifts | 1,639.80 | 2 |
| AP | computers | 1,437.00 | 3 |
| BA | health_beauty | 49,955.12 | 1 |
| BA | watches_gifts | 45,631.52 | 2 |
| BA | sports_leisure | 37,010.06 | 3 |
| CE | health_beauty | 31,544.50 | 1 |
| CE | watches_gifts | 29,025.35 | 2 |
| CE | cool_stuff | 12,005.41 | 3 |
| DF | watches_gifts | 32,292.27 | 1 |
| DF | health_beauty | 29,542.82 | 2 |
| DF | computers_accessories | 23,853.44 | 3 |
| ES | watches_gifts | 28,074.00 | 1 |
| ES | bed_bath_table | 22,589.65 | 2 |
| ES | sports_leisure | 20,086.20 | 3 |
| GO | watches_gifts | 31,486.93 | 1 |
| GO | health_beauty | 27,971.30 | 2 |
| GO | bed_bath_table | 22,285.61 | 3 |
| MA | health_beauty | 12,668.28 | 1 |
| MA | computers_accessories | 12,152.83 | 2 |
| MA | watches_gifts | 9,712.99 | 3 |
| MG | health_beauty | 154,324.15 | 1 |
| MG | bed_bath_table | 128,760.49 | 2 |
| MG | watches_gifts | 121,622.03 | 3 |
| MS | health_beauty | 11,231.58 | 1 |
| MS | housewares | 10,861.74 | 2 |
| MS | computers_accessories | 9,738.80 | 3 |
| MT | health_beauty | 15,241.80 | 1 |
| MT | watches_gifts | 15,006.91 | 2 |
| MT | auto | 10,087.42 | 3 |
| PA | health_beauty | 23,545.84 | 1 |
| PA | watches_gifts | 21,635.82 | 2 |
| PA | sports_leisure | 12,298.65 | 3 |
| PB | health_beauty | 15,692.08 | 1 |
| PB | watches_gifts | 13,102.98 | 2 |
| PB | computers_accessories | 7,195.08 | 3 |
| PE | health_beauty | 40,685.01 | 1 |
| PE | watches_gifts | 30,894.88 | 2 |
| PE | sports_leisure | 18,245.51 | 3 |
| PI | health_beauty | 10,205.20 | 1 |
| PI | auto | 10,017.38 | 2 |
| PI | watches_gifts | 7,736.18 | 3 |
| PR | sports_leisure | 57,653.30 | 1 |
| PR | watches_gifts | 57,287.20 | 2 |
| PR | health_beauty | 53,730.23 | 3 |
| RJ | watches_gifts | 174,895.01 | 1 |
| RJ | bed_bath_table | 144,251.79 | 2 |
| RJ | health_beauty | 140,236.35 | 3 |
| RN | health_beauty | 13,728.98 | 1 |
| RN | watches_gifts | 10,052.42 | 2 |
| RN | telephony | 5,303.29 | 3 |
| RO | health_beauty | 7,085.76 | 1 |
| RO | watches_gifts | 4,428.27 | 2 |
| RO | sports_leisure | 3,212.88 | 3 |
| RR | sports_leisure | 1,350.60 | 1 |
| RR | home_appliances | 954.18 | 2 |
| RR | baby | 949.90 | 3 |
| RS | bed_bath_table | 60,040.95 | 1 |
| RS | furniture_decor | 53,774.90 | 2 |
| RS | computers_accessories | 52,380.04 | 3 |
| SC | sports_leisure | 41,579.03 | 1 |
| SC | health_beauty | 39,260.73 | 2 |
| SC | computers_accessories | 36,058.43 | 3 |
| SE | health_beauty | 8,396.67 | 1 |
| SE | cool_stuff | 5,686.67 | 2 |
| SE | furniture_decor | 4,231.39 | 3 |
| SP | bed_bath_table | 472,238.07 | 1 |
| SP | health_beauty | 453,916.48 | 2 |
| SP | watches_gifts | 421,546.60 | 3 |
| TO | sports_leisure | 5,144.32 | 1 |
| TO | watches_gifts | 4,920.89 | 2 |
| TO | health_beauty | 4,798.99 | 3 |

## Q14. How do recorded payments compare with item value plus freight per order?

| orders | orders_with_items | orders_with_payments | comparable_orders | differences_above_one_cent | net_recorded_difference |
| --- | --- | --- | --- | --- | --- |
| 99,441 | 98,666 | 99,440 | 98,665 | 303 | 2,870.39 |

## Q15. What descriptive customer groups emerge from frequency and recency?

| segment | as_of_date | unique_customers | mean_recency_days | delivered_orders | delivered_item_gmv |
| --- | --- | --- | --- | --- | --- |
| single_purchase_older | 2018-08-30 | 72,778 | 286.40 | 72,778 | 10,035,714.16 |
| single_purchase_recent | 2018-08-30 | 17,779 | 45.20 | 17,779 | 2,457,375.20 |
| repeat_purchase_older | 2018-08-30 | 2,190 | 269.50 | 4,599 | 563,538.66 |
| repeat_purchase_recent | 2018-08-30 | 611 | 46.20 | 1,322 | 164,870.09 |
