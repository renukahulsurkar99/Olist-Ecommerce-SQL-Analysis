"""Generate the findings, complete result tables and chart from SQL exports."""
import datetime as dt
from decimal import Decimal, InvalidOperation
import hashlib
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
from export_results import analysis_queries, sql_fingerprints

ROOT = Path(__file__).resolve().parents[1]


def money(value):
    return f'{Decimal(value):,.2f}'


def display(value):
    if value == '':
        return 'NULL'
    if value in ('t', 'f'):
        return {'t': 'true', 'f': 'false'}[value]
    try:
        number = Decimal(value)
        return f'{number:,.2f}' if '.' in value else f'{int(number):,}'
    except InvalidOperation:
        return value.replace('|', '\\|').replace('\n', ' ')


def write_tables(queries):
    lines = ['# SQL result tables', '',
             'Snapshot of all 15 queries in [sql/03_analysis.sql](../sql/03_analysis.sql). '
             'Numeric values below are formatted for readability. The exact exported strings, '
             'source fingerprints and query fingerprints are in [analysis.json](analysis.json). '
             '`NULL` means an unavailable value. Monetary amounts retain source currency units.', '']
    for query in queries:
        columns = query['columns']
        lines += [f"## {query['id']}. {query['question']}", '',
                  '| ' + ' | '.join(columns) + ' |',
                  '| ' + ' | '.join('---' for _ in columns) + ' |']
        lines += ['| ' + ' | '.join(display(row[c]) for c in columns) + ' |' for row in query['rows']]
        lines += ['']
    (ROOT/'results/analysis.md').write_text('\n'.join(lines))


def write_findings(queries):
    q = {query['id']: query['rows'] for query in queries}
    overview = q['Q01'][0]
    states = q['Q04'][:5]
    on_time, late = q['Q07']
    repeat = next(row for row in q['Q09'] if row['customer_group'].startswith('two_'))
    category = q['Q05'][0]
    payment = q['Q08'][0]
    state_lines = '\n'.join(
        f"| {r['customer_state']} | {int(r['delivered_orders']):,} | {money(r['delivered_item_gmv'])} | {r['gmv_share_pct']}% | {r['late_delivery_pct']}% |"
        for r in states)
    text = f'''# Findings and business interpretation

This report is generated from [15 PostgreSQL analyses](../sql/03_analysis.sql). The [complete result tables](../results/analysis.md) and [machine-readable snapshot](../results/analysis.json) make each finding traceable. Olist supplied the anonymised commercial dataset through Kaggle. Monetary values retain the source currency units.

![Olist analysis overview](../assets/analysis-overview.png)

## Scope and definitions

The dataset includes **{int(overview['total_orders']):,} orders**, **{int(overview['unique_customers']):,} unique customer identifiers**, and 112,650 item records. Of these orders, **{int(overview['delivered_orders']):,}** have status `delivered` (Q01–Q02).

Delivered merchandise value is **{money(overview['delivered_item_gmv'])}**, with mean merchandise value of **{money(overview['average_delivered_order_gmv'])}** per delivered order (Q01). This metric sums item prices for delivered orders. Freight is tracked separately. The CSVs do not provide a cost or refund ledger, so the project does not calculate profit or accounting net revenue.

## Delivery reliability and review scores — Q06–Q07

Of **{int(overview['delivery_date_eligible_orders']):,}** delivered orders with actual and estimated delivery dates, **{int(overview['late_orders']):,}** arrived after the estimated calendar day. The late-delivery rate is **{overview['late_delivery_pct']}%**. Eight orders marked delivered have no actual delivery timestamp and are excluded from this denominator.

The average latest review score is **{on_time['average_review_score']}/5 for on-time orders** and **{late['average_review_score']}/5 for late orders**. Low scores of 1–2 stars account for **{on_time['low_review_pct']}%** and **{late['low_review_pct']}%** of reviewed orders in those groups, respectively. Review coverage is {on_time['review_coverage_pct']}% for on-time orders and {late['review_coverage_pct']}% for late orders.

This is an association in observed orders. Product mix, sellers, geography, and other factors may also affect review scores. It does not estimate the causal effect of delivery delays.

Alagoas (`AL`) has the highest late rate among states with at least 100 eligible deliveries, at **21.41% across 397 orders**. Maranhão (`MA`) follows at **17.43% across 717 orders**. The 100-order threshold is an analyst-defined screen. It does not establish statistical significance.

**Suggested follow-up:** investigate the order-to-carrier and carrier-to-customer intervals in states with high rates, alongside order volumes and seller mix. The sample supports identifying investigation candidates. No operational change or improvement has been measured.

## Geographic contribution — Q04

| Customer state | Delivered orders | Delivered item value | Item-value share | Late-delivery rate |
| --- | ---: | ---: | ---: | ---: |
{state_lines}

São Paulo contributes **38.33%** of delivered merchandise value. Rio de Janeiro combines substantial order volume with a **12.11%** late rate. This makes it a candidate for investigating both delay frequency and the number of affected orders. Customer state represents the location attached to each order's customer record.

## Category and freight mix — Q05 and Q12

**{category['category']}** is the largest category by delivered merchandise value, at **{money(category['delivered_item_gmv'])}** or **{category['gmv_share_pct']}%** of the total. Watches/gifts and bed/bath/table follow. Category order counts can overlap because one order can include items from several categories.

Christmas supplies has recorded freight equal to **36.52%** of merchandise value across 150 delivered items. This ratio describes charged freight relative to item prices. It is not a measure of shipping cost or profitability.

## Repeat purchasing and cohorts — Q09–Q10

Among customers with at least one delivered order, **{int(repeat['unique_customers']):,} customers ({repeat['customer_share_pct']}%)** placed two or more delivered orders during the observed period. Customer identity uses `customer_unique_id`, because `customer_id` identifies an order-linked customer record.

The cohort table groups customers by the month of their first delivered-order purchase and measures distinct customers active in later calendar months. Future months are left unavailable. Very small early cohorts can show extreme percentages, and the latest observed activity month can be partial. These figures describe observed repeat purchasing within Olist's sample rather than a complete customer lifetime.

## Payments and reconciliation — Q08 and Q14

**{payment['payment_type']}** accounts for **{payment['payment_value_share_pct']}%** of all recorded payment value. This query includes all order statuses. Split-payment orders can contribute to more than one payment method.

Across orders with both item and payment records, 303 orders have a difference greater than one cent between recorded payment value and item value plus freight. The net recorded difference is 2,870.39. These differences require source interpretation. They do not establish refunds, financial losses, or fraud.

## Data quality and analytical limits

- The imported tables retain the original source records. All row counts and source totals reconcile.
- The 99,224 review rows contain 98,410 distinct review IDs across 98,673 orders. `(review_id, order_id)` is unique. A deterministic latest-response rule selects one review per order for order-level metrics.
- Payments, items and reviews are aggregated or selected to one row per order before joining. This prevents monetary totals from multiplying across one-to-many relationships.
- The file has 775 orders without item records, one without a payment record, and 768 without a review. The order-level view retains these orders and their missing values.
- There are 610 products with no category and 13 products in two categories without English translations. The category query retains Portuguese labels when translation is unavailable.
- The overall purchase range includes sparse early activity and a sparse tail in September–October 2018. The monthly chart focuses on January 2017–August 2018. The SQL exports retain the full calendar, including zero-order months.
- No time-zone offset is supplied in the timestamps. They are stored as `timestamp without time zone`.

## Reproduce the report

After preparing the source files and loading PostgreSQL, run the export and report commands in the README. The JSON snapshot records each query's SHA-256 hash and the source-file manifest so stale results can be identified.
'''
    (ROOT/'docs/findings.md').write_text(text)


def plot(queries):
    q = {query['id']: query['rows'] for query in queries}
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.titlesize':14,
                         'axes.titleweight':'bold','axes.spines.top':False,
                         'axes.spines.right':False,'axes.labelcolor':'#405168',
                         'text.color':'#182b44','axes.edgecolor':'#dce3eb'})
    fig, axes = plt.subplots(2,2,figsize=(15,9.5))
    fig.patch.set_facecolor('#f5f7fb')
    fig.subplots_adjust(left=.10,right=.96,top=.84,bottom=.13,hspace=.60,wspace=.47)
    fig.text(.10,.946,'Olist e-commerce analysis',fontsize=25,weight='bold')
    fig.text(.10,.908,'99,441 orders  |  8 source tables  |  PostgreSQL',fontsize=12,color='#53657b')
    teal, orange = '#087f8c','#cd603e'
    for ax in axes.flat:
        ax.set_facecolor('#f5f7fb')
        ax.grid(axis='y',color='#dce3eb',linewidth=.7)
        ax.set_axisbelow(True)
    monthly=[r for r in q['Q03'] if '2017-01-01'<=r['month']<='2018-08-01']
    dates=[dt.date.fromisoformat(r['month']) for r in monthly]
    values=[float(r['delivered_item_gmv'])/1000 for r in monthly]
    ax=axes[0,0]
    ax.plot(dates,values,color=teal,lw=2.6)
    ax.fill_between(dates,values,color=teal,alpha=.10)
    ax.set_title('Delivered merchandise value',loc='left',pad=16)
    ax.set_ylabel('Source currency units, thousands')
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=4))
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda value,_:f'{value:,.0f}'))
    ax.set_ylim(bottom=0)
    ax=axes[0,1]
    categories=list(reversed(q['Q05'][:5]))
    ax.barh([r['category'].replace('_',' ') for r in categories],
            [float(r['delivered_item_gmv'])/1e6 for r in categories],color=teal,height=.60)
    ax.set_title('Top categories by merchandise value',loc='left',pad=16)
    ax.set_xlabel('Delivered item value, millions of source currency units')
    ax.grid(axis='y',visible=False)
    ax.grid(axis='x',color='#dce3eb',linewidth=.7)
    ax.set_xlim(0,1.5)
    for idx,row in enumerate(categories):
        value=float(row['delivered_item_gmv'])/1e6
        ax.text(value+.025,idx,f'{value:.2f}',va='center',fontsize=10)
    ax=axes[1,0]
    reviews=q['Q07']
    scores=[float(r['average_review_score']) for r in reviews]
    bars=ax.bar(['On time','Late'],scores,color=[teal,orange],width=.45)
    ax.set_title('Review scores by delivery outcome',loc='left',pad=16)
    ax.set_ylabel('Mean latest review score / 5')
    ax.set_ylim(0,5.3)
    for bar,row in zip(bars,reviews):
        ax.text(bar.get_x()+bar.get_width()/2,bar.get_height()+.12,
                f"{row['average_review_score']}\nn = {int(row['reviewed_orders']):,}",ha='center',va='bottom',fontsize=11)
    ax=axes[1,1]
    late_states=list(reversed(q['Q06'][:5]))
    labels=[f"{r['customer_state']}  (n = {int(r['eligible_deliveries']):,})" for r in late_states]
    rates=[float(r['late_delivery_pct']) for r in late_states]
    ax.barh(labels,rates,color=orange,height=.60)
    ax.set_title('Highest late rates by customer state',loc='left',pad=16)
    ax.set_xlabel('Late deliveries (%)  |  at least 100 eligible orders')
    ax.grid(axis='y',visible=False)
    ax.grid(axis='x',color='#dce3eb',linewidth=.7)
    ax.set_xlim(0,25)
    for idx,value in enumerate(rates):ax.text(value+.35,idx,f'{value:.2f}%',va='center',fontsize=10)
    fig.text(.10,.065,'Monthly panel shows Jan 2017–Aug 2018. Late deliveries use calendar dates and exclude eight missing actual dates.',fontsize=10,color='#53657b')
    fig.text(.10,.038,'Source: Olist / Kaggle (CC BY-NC-SA 4.0). Review comparisons describe association.',fontsize=10,color='#53657b')
    output=ROOT/'assets'
    output.mkdir(exist_ok=True)
    fig.savefig(output/'analysis-overview.png',dpi=150,facecolor=fig.get_facecolor())
    plt.close(fig)


def main():
    payload=json.loads((ROOT/'results/analysis.json').read_text())
    expected={key:hashlib.sha256(sql.encode()).hexdigest() for key,_,sql in analysis_queries()}
    actual={query['id']:query['sql_sha256'] for query in payload['queries']}
    if actual != expected:
        raise ValueError('SQL changed since the snapshot. Run scripts/export_results.py again.')
    if payload.get('sql_files') != sql_fingerprints():
        raise ValueError('SQL files changed since the snapshot. Reload and export the data again.')
    if payload['source_manifest'] != json.loads((ROOT/'data/manifest.json').read_text()):
        raise ValueError('Source manifest changed since the snapshot. Reload and export the data again.')
    write_tables(payload['queries'])
    write_findings(payload['queries'])
    plot(payload['queries'])
    print('Generated findings, complete result tables and assets/analysis-overview.png')


if __name__=='__main__':
    main()
