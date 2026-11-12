"""Copy the eight original CSVs into data/raw after checking their headers."""
import argparse
import csv
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
FILES = {
    'olist_customers_dataset.csv': ['customer_id','customer_unique_id','customer_zip_code_prefix','customer_city','customer_state'],
    'olist_orders_dataset.csv': ['order_id','customer_id','order_status','order_purchase_timestamp','order_approved_at','order_delivered_carrier_date','order_delivered_customer_date','order_estimated_delivery_date'],
    'olist_order_items_dataset.csv': ['order_id','order_item_id','product_id','seller_id','shipping_limit_date','price','freight_value'],
    'olist_order_payments_dataset.csv': ['order_id','payment_sequential','payment_type','payment_installments','payment_value'],
    'olist_order_reviews_dataset.csv': ['review_id','order_id','review_score','review_comment_title','review_comment_message','review_creation_date','review_answer_timestamp'],
    'olist_products_dataset.csv': ['product_id','product_category_name','product_name_lenght','product_description_lenght','product_photos_qty','product_weight_g','product_length_cm','product_height_cm','product_width_cm'],
    'olist_sellers_dataset.csv': ['seller_id','seller_zip_code_prefix','seller_city','seller_state'],
    'product_category_name_translation.csv': ['product_category_name','product_category_name_english'],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path, help='Folder extracted from the official Kaggle ZIP')
    args = parser.parse_args()
    manifest = {}
    # Check all sources before copying any file.
    for name, expected_header in FILES.items():
        path = args.source / name
        with path.open(encoding='utf-8-sig', newline='') as handle:
            reader = csv.reader(handle)
            if next(reader) != expected_header:
                raise ValueError(f'Unexpected column order in {name}')
            rows = 0
            for row in reader:
                if len(row) != len(expected_header):
                    raise ValueError(f'Wrong field count in {name} at data row {rows + 1}')
                rows += 1
        manifest[name] = {'rows': rows, 'bytes': path.stat().st_size,
                          'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
    target = ROOT / 'data' / 'raw'
    target.mkdir(parents=True, exist_ok=True)
    for name in FILES:
        destination = target / name
        if (args.source / name).resolve() != destination.resolve():
            shutil.copyfile(args.source / name, destination)
    (ROOT / 'data' / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Prepared {len(FILES)} unchanged CSVs and data/manifest.json')


if __name__ == '__main__':
    main()
