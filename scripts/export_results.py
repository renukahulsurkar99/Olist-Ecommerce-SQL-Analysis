"""Export each numbered analysis query through psql into one JSON snapshot."""
import argparse
import csv
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def sql_fingerprints():
    return {path.name: hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted((ROOT / 'sql').glob('*.sql'))}


def analysis_queries():
    text = (ROOT / 'sql' / '03_analysis.sql').read_text()
    pieces = re.split(r'^-- (Q\d{2})\. (.+)$', text, flags=re.MULTILINE)
    queries = []
    for index in range(1, len(pieces), 3):
        key, question, body = pieces[index:index + 3]
        sql = '\n'.join(line for line in body.splitlines() if not line.lstrip().startswith('--')).strip().rstrip(';')
        queries.append((key, question, sql))
    return queries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--docker', action='store_true', help='Use the PostgreSQL container from compose.yaml')
    args = parser.parse_args()
    client = ['docker', 'compose', 'exec', '-T', 'db', 'psql', '-U', 'analyst', '-d', 'olist_analytics'] if args.docker else ['psql']
    output = {'source_manifest': json.loads((ROOT / 'data' / 'manifest.json').read_text()),
              'sql_files': sql_fingerprints(), 'queries': []}
    for key, question, sql in analysis_queries():
        command = f'COPY ({sql}) TO STDOUT WITH (FORMAT csv, HEADER true)'
        result = subprocess.run(client + ['-X', '-v', 'ON_ERROR_STOP=1', '-c', command],
                                cwd=ROOT, text=True, capture_output=True, check=True)
        reader = csv.DictReader(io.StringIO(result.stdout))
        output['queries'].append({'id': key, 'question': question,
            'sql_sha256': hashlib.sha256(sql.encode()).hexdigest(),
            'columns': reader.fieldnames, 'rows': list(reader)})
        print(f'Exported {key}')
    (ROOT / 'results').mkdir(exist_ok=True)
    (ROOT / 'results' / 'analysis.json').write_text(json.dumps(output, indent=2) + '\n')


if __name__ == '__main__':
    main()
